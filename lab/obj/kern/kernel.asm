
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
f0100015:	b8 00 f0 17 00       	mov    $0x17f000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 1c e8 07 00    	add    $0x7e81c,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 10 18 f0    	mov    $0xf0181000,%eax
f0100058:	c7 c2 e0 00 18 f0    	mov    $0xf01800e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 3c 46 00 00       	call   f01046a5 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4f 05 00 00       	call   f01005bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 78 62 f8 ff    	lea    -0x79d88(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 a5 35 00 00       	call   f0103627 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 03 13 00 00       	call   f010138a <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 2b 31 00 00       	call   f01031b7 <env_init>
	trap_init();
f010008c:	e8 49 36 00 00       	call   f01036da <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010009c:	e8 52 32 00 00       	call   f01032f3 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 50 03 18 f0    	mov    $0xf0180350,%eax
f01000aa:	ff 30                	push   (%eax)
f01000ac:	e8 c5 34 00 00       	call   f0103576 <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	e8 ac 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bb:	81 c3 ad e7 07 00    	add    $0x7e7ad,%ebx
	va_list ap;

	if (panicstr)
f01000c1:	83 bb 78 18 00 00 00 	cmpl   $0x0,0x1878(%ebx)
f01000c8:	74 0f                	je     f01000d9 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ca:	83 ec 0c             	sub    $0xc,%esp
f01000cd:	6a 00                	push   $0x0
f01000cf:	e8 60 08 00 00       	call   f0100934 <monitor>
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	eb f1                	jmp    f01000ca <_panic+0x19>
	panicstr = fmt;
f01000d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01000dc:	89 83 78 18 00 00    	mov    %eax,0x1878(%ebx)
	asm volatile("cli; cld");
f01000e2:	fa                   	cli    
f01000e3:	fc                   	cld    
	va_start(ap, fmt);
f01000e4:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e7:	83 ec 04             	sub    $0x4,%esp
f01000ea:	ff 75 0c             	push   0xc(%ebp)
f01000ed:	ff 75 08             	push   0x8(%ebp)
f01000f0:	8d 83 93 62 f8 ff    	lea    -0x79d6d(%ebx),%eax
f01000f6:	50                   	push   %eax
f01000f7:	e8 2b 35 00 00       	call   f0103627 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	56                   	push   %esi
f0100100:	ff 75 10             	push   0x10(%ebp)
f0100103:	e8 e8 34 00 00       	call   f01035f0 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 01 6a f8 ff    	lea    -0x795ff(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 11 35 00 00       	call   f0103627 <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb af                	jmp    f01000ca <_panic+0x19>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 43 e7 07 00    	add    $0x7e743,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	push   0xc(%ebp)
f0100134:	ff 75 08             	push   0x8(%ebp)
f0100137:	8d 83 ab 62 f8 ff    	lea    -0x79d55(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 e4 34 00 00       	call   f0103627 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	push   0x10(%ebp)
f010014a:	e8 a1 34 00 00       	call   f01035f0 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 01 6a f8 ff    	lea    -0x795ff(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 ca 34 00 00       	call   f0103627 <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100170:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100171:	a8 01                	test   $0x1,%al
f0100173:	74 0a                	je     f010017f <serial_proc_data+0x14>
f0100175:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017b:	0f b6 c0             	movzbl %al,%eax
f010017e:	c3                   	ret    
		return -1;
f010017f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100184:	c3                   	ret    

f0100185 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100185:	55                   	push   %ebp
f0100186:	89 e5                	mov    %esp,%ebp
f0100188:	57                   	push   %edi
f0100189:	56                   	push   %esi
f010018a:	53                   	push   %ebx
f010018b:	83 ec 1c             	sub    $0x1c,%esp
f010018e:	e8 6a 05 00 00       	call   f01006fd <__x86.get_pc_thunk.si>
f0100193:	81 c6 d5 e6 07 00    	add    $0x7e6d5,%esi
f0100199:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010019b:	8d 1d b8 18 00 00    	lea    0x18b8,%ebx
f01001a1:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001aa:	eb 25                	jmp    f01001d1 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001b3:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001b9:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c7:	0f 44 d0             	cmove  %eax,%edx
f01001ca:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001d4:	ff d0                	call   *%eax
f01001d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d9:	74 06                	je     f01001e1 <cons_intr+0x5c>
		if (c == 0)
f01001db:	85 c0                	test   %eax,%eax
f01001dd:	75 cd                	jne    f01001ac <cons_intr+0x27>
f01001df:	eb f0                	jmp    f01001d1 <cons_intr+0x4c>
	}
}
f01001e1:	83 c4 1c             	add    $0x1c,%esp
f01001e4:	5b                   	pop    %ebx
f01001e5:	5e                   	pop    %esi
f01001e6:	5f                   	pop    %edi
f01001e7:	5d                   	pop    %ebp
f01001e8:	c3                   	ret    

f01001e9 <kbd_proc_data>:
{
f01001e9:	55                   	push   %ebp
f01001ea:	89 e5                	mov    %esp,%ebp
f01001ec:	56                   	push   %esi
f01001ed:	53                   	push   %ebx
f01001ee:	e8 74 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001f3:	81 c3 75 e6 07 00    	add    $0x7e675,%ebx
f01001f9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001fe:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001ff:	a8 01                	test   $0x1,%al
f0100201:	0f 84 f7 00 00 00    	je     f01002fe <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100207:	a8 20                	test   $0x20,%al
f0100209:	0f 85 f6 00 00 00    	jne    f0100305 <kbd_proc_data+0x11c>
f010020f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100214:	ec                   	in     (%dx),%al
f0100215:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100217:	3c e0                	cmp    $0xe0,%al
f0100219:	74 64                	je     f010027f <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010021b:	84 c0                	test   %al,%al
f010021d:	78 75                	js     f0100294 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010021f:	8b 8b 98 18 00 00    	mov    0x1898(%ebx),%ecx
f0100225:	f6 c1 40             	test   $0x40,%cl
f0100228:	74 0e                	je     f0100238 <kbd_proc_data+0x4f>
		data |= 0x80;
f010022a:	83 c8 80             	or     $0xffffff80,%eax
f010022d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010022f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100232:	89 8b 98 18 00 00    	mov    %ecx,0x1898(%ebx)
	shift |= shiftcode[data];
f0100238:	0f b6 d2             	movzbl %dl,%edx
f010023b:	0f b6 84 13 f8 63 f8 	movzbl -0x79c08(%ebx,%edx,1),%eax
f0100242:	ff 
f0100243:	0b 83 98 18 00 00    	or     0x1898(%ebx),%eax
	shift ^= togglecode[data];
f0100249:	0f b6 8c 13 f8 62 f8 	movzbl -0x79d08(%ebx,%edx,1),%ecx
f0100250:	ff 
f0100251:	31 c8                	xor    %ecx,%eax
f0100253:	89 83 98 18 00 00    	mov    %eax,0x1898(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100259:	89 c1                	mov    %eax,%ecx
f010025b:	83 e1 03             	and    $0x3,%ecx
f010025e:	8b 8c 8b b8 17 00 00 	mov    0x17b8(%ebx,%ecx,4),%ecx
f0100265:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100269:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010026c:	a8 08                	test   $0x8,%al
f010026e:	74 61                	je     f01002d1 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f0100270:	89 f2                	mov    %esi,%edx
f0100272:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100275:	83 f9 19             	cmp    $0x19,%ecx
f0100278:	77 4b                	ja     f01002c5 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f010027a:	83 ee 20             	sub    $0x20,%esi
f010027d:	eb 0c                	jmp    f010028b <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010027f:	83 8b 98 18 00 00 40 	orl    $0x40,0x1898(%ebx)
		return 0;
f0100286:	be 00 00 00 00       	mov    $0x0,%esi
}
f010028b:	89 f0                	mov    %esi,%eax
f010028d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100290:	5b                   	pop    %ebx
f0100291:	5e                   	pop    %esi
f0100292:	5d                   	pop    %ebp
f0100293:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100294:	8b 8b 98 18 00 00    	mov    0x1898(%ebx),%ecx
f010029a:	83 e0 7f             	and    $0x7f,%eax
f010029d:	f6 c1 40             	test   $0x40,%cl
f01002a0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 f8 63 f8 	movzbl -0x79c08(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	83 c8 40             	or     $0x40,%eax
f01002b1:	0f b6 c0             	movzbl %al,%eax
f01002b4:	f7 d0                	not    %eax
f01002b6:	21 c8                	and    %ecx,%eax
f01002b8:	89 83 98 18 00 00    	mov    %eax,0x1898(%ebx)
		return 0;
f01002be:	be 00 00 00 00       	mov    $0x0,%esi
f01002c3:	eb c6                	jmp    f010028b <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002c5:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c8:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002cb:	83 fa 1a             	cmp    $0x1a,%edx
f01002ce:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d1:	f7 d0                	not    %eax
f01002d3:	a8 06                	test   $0x6,%al
f01002d5:	75 b4                	jne    f010028b <kbd_proc_data+0xa2>
f01002d7:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002dd:	75 ac                	jne    f010028b <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01002df:	83 ec 0c             	sub    $0xc,%esp
f01002e2:	8d 83 c5 62 f8 ff    	lea    -0x79d3b(%ebx),%eax
f01002e8:	50                   	push   %eax
f01002e9:	e8 39 33 00 00       	call   f0103627 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f8:	ee                   	out    %al,(%dx)
}
f01002f9:	83 c4 10             	add    $0x10,%esp
f01002fc:	eb 8d                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f01002fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100303:	eb 86                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f0100305:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010030a:	e9 7c ff ff ff       	jmp    f010028b <kbd_proc_data+0xa2>

f010030f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010030f:	55                   	push   %ebp
f0100310:	89 e5                	mov    %esp,%ebp
f0100312:	57                   	push   %edi
f0100313:	56                   	push   %esi
f0100314:	53                   	push   %ebx
f0100315:	83 ec 1c             	sub    $0x1c,%esp
f0100318:	e8 4a fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010031d:	81 c3 4b e5 07 00    	add    $0x7e54b,%ebx
f0100323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100326:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100330:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100335:	89 fa                	mov    %edi,%edx
f0100337:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100338:	a8 20                	test   $0x20,%al
f010033a:	75 13                	jne    f010034f <cons_putc+0x40>
f010033c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100342:	7f 0b                	jg     f010034f <cons_putc+0x40>
f0100344:	89 ca                	mov    %ecx,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	ec                   	in     (%dx),%al
f0100349:	ec                   	in     (%dx),%al
	     i++)
f010034a:	83 c6 01             	add    $0x1,%esi
f010034d:	eb e6                	jmp    f0100335 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f010034f:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100353:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100356:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010035b:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	bf 79 03 00 00       	mov    $0x379,%edi
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
f010036e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100374:	7f 0f                	jg     f0100385 <cons_putc+0x76>
f0100376:	84 c0                	test   %al,%al
f0100378:	78 0b                	js     f0100385 <cons_putc+0x76>
f010037a:	89 ca                	mov    %ecx,%edx
f010037c:	ec                   	in     (%dx),%al
f010037d:	ec                   	in     (%dx),%al
f010037e:	ec                   	in     (%dx),%al
f010037f:	ec                   	in     (%dx),%al
f0100380:	83 c6 01             	add    $0x1,%esi
f0100383:	eb e6                	jmp    f010036b <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	ba 78 03 00 00       	mov    $0x378,%edx
f010038a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010038e:	ee                   	out    %al,(%dx)
f010038f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100394:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100399:	ee                   	out    %al,(%dx)
f010039a:	b8 08 00 00 00       	mov    $0x8,%eax
f010039f:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003a3:	89 f8                	mov    %edi,%eax
f01003a5:	80 cc 07             	or     $0x7,%ah
f01003a8:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003ae:	0f 45 c7             	cmovne %edi,%eax
f01003b1:	89 c7                	mov    %eax,%edi
f01003b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b6:	0f b6 c0             	movzbl %al,%eax
f01003b9:	89 f9                	mov    %edi,%ecx
f01003bb:	80 f9 0a             	cmp    $0xa,%cl
f01003be:	0f 84 e4 00 00 00    	je     f01004a8 <cons_putc+0x199>
f01003c4:	83 f8 0a             	cmp    $0xa,%eax
f01003c7:	7f 46                	jg     f010040f <cons_putc+0x100>
f01003c9:	83 f8 08             	cmp    $0x8,%eax
f01003cc:	0f 84 a8 00 00 00    	je     f010047a <cons_putc+0x16b>
f01003d2:	83 f8 09             	cmp    $0x9,%eax
f01003d5:	0f 85 da 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		cons_putc(' ');
f01003db:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e0:	e8 2a ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ea:	e8 20 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f4:	e8 16 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fe:	e8 0c ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f0100403:	b8 20 00 00 00       	mov    $0x20,%eax
f0100408:	e8 02 ff ff ff       	call   f010030f <cons_putc>
		break;
f010040d:	eb 26                	jmp    f0100435 <cons_putc+0x126>
	switch (c & 0xff) {
f010040f:	83 f8 0d             	cmp    $0xd,%eax
f0100412:	0f 85 9d 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100418:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f010041f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100425:	c1 e8 16             	shr    $0x16,%eax
f0100428:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010042b:	c1 e0 04             	shl    $0x4,%eax
f010042e:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100435:	66 81 bb c0 1a 00 00 	cmpw   $0x7cf,0x1ac0(%ebx)
f010043c:	cf 07 
f010043e:	0f 87 98 00 00 00    	ja     f01004dc <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100444:	8b 8b c8 1a 00 00    	mov    0x1ac8(%ebx),%ecx
f010044a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010044f:	89 ca                	mov    %ecx,%edx
f0100451:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100452:	0f b7 9b c0 1a 00 00 	movzwl 0x1ac0(%ebx),%ebx
f0100459:	8d 71 01             	lea    0x1(%ecx),%esi
f010045c:	89 d8                	mov    %ebx,%eax
f010045e:	66 c1 e8 08          	shr    $0x8,%ax
f0100462:	89 f2                	mov    %esi,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	b8 0f 00 00 00       	mov    $0xf,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100472:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100475:	5b                   	pop    %ebx
f0100476:	5e                   	pop    %esi
f0100477:	5f                   	pop    %edi
f0100478:	5d                   	pop    %ebp
f0100479:	c3                   	ret    
		if (crt_pos > 0) {
f010047a:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f0100481:	66 85 c0             	test   %ax,%ax
f0100484:	74 be                	je     f0100444 <cons_putc+0x135>
			crt_pos--;
f0100486:	83 e8 01             	sub    $0x1,%eax
f0100489:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100490:	0f b7 c0             	movzwl %ax,%eax
f0100493:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100497:	b2 00                	mov    $0x0,%dl
f0100499:	83 ca 20             	or     $0x20,%edx
f010049c:	8b 8b c4 1a 00 00    	mov    0x1ac4(%ebx),%ecx
f01004a2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004a6:	eb 8d                	jmp    f0100435 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004a8:	66 83 83 c0 1a 00 00 	addw   $0x50,0x1ac0(%ebx)
f01004af:	50 
f01004b0:	e9 63 ff ff ff       	jmp    f0100418 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b5:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f01004bc:	8d 50 01             	lea    0x1(%eax),%edx
f01004bf:	66 89 93 c0 1a 00 00 	mov    %dx,0x1ac0(%ebx)
f01004c6:	0f b7 c0             	movzwl %ax,%eax
f01004c9:	8b 93 c4 1a 00 00    	mov    0x1ac4(%ebx),%edx
f01004cf:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004d3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01004d7:	e9 59 ff ff ff       	jmp    f0100435 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004dc:	8b 83 c4 1a 00 00    	mov    0x1ac4(%ebx),%eax
f01004e2:	83 ec 04             	sub    $0x4,%esp
f01004e5:	68 00 0f 00 00       	push   $0xf00
f01004ea:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f0:	52                   	push   %edx
f01004f1:	50                   	push   %eax
f01004f2:	e8 f4 41 00 00       	call   f01046eb <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004f7:	8b 93 c4 1a 00 00    	mov    0x1ac4(%ebx),%edx
f01004fd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100503:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100509:	83 c4 10             	add    $0x10,%esp
f010050c:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100511:	83 c0 02             	add    $0x2,%eax
f0100514:	39 d0                	cmp    %edx,%eax
f0100516:	75 f4                	jne    f010050c <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100518:	66 83 ab c0 1a 00 00 	subw   $0x50,0x1ac0(%ebx)
f010051f:	50 
f0100520:	e9 1f ff ff ff       	jmp    f0100444 <cons_putc+0x135>

f0100525 <serial_intr>:
{
f0100525:	e8 cf 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010052a:	05 3e e3 07 00       	add    $0x7e33e,%eax
	if (serial_exists)
f010052f:	80 b8 cc 1a 00 00 00 	cmpb   $0x0,0x1acc(%eax)
f0100536:	75 01                	jne    f0100539 <serial_intr+0x14>
f0100538:	c3                   	ret    
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 03 19 f8 ff    	lea    -0x7e6fd(%eax),%eax
f0100545:	e8 3b fc ff ff       	call   f0100185 <cons_intr>
}
f010054a:	c9                   	leave  
f010054b:	c3                   	ret    

f010054c <kbd_intr>:
{
f010054c:	55                   	push   %ebp
f010054d:	89 e5                	mov    %esp,%ebp
f010054f:	83 ec 08             	sub    $0x8,%esp
f0100552:	e8 a2 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0100557:	05 11 e3 07 00       	add    $0x7e311,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 81 19 f8 ff    	lea    -0x7e67f(%eax),%eax
f0100562:	e8 1e fc ff ff       	call   f0100185 <cons_intr>
}
f0100567:	c9                   	leave  
f0100568:	c3                   	ret    

f0100569 <cons_getc>:
{
f0100569:	55                   	push   %ebp
f010056a:	89 e5                	mov    %esp,%ebp
f010056c:	53                   	push   %ebx
f010056d:	83 ec 04             	sub    $0x4,%esp
f0100570:	e8 f2 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100575:	81 c3 f3 e2 07 00    	add    $0x7e2f3,%ebx
	serial_intr();
f010057b:	e8 a5 ff ff ff       	call   f0100525 <serial_intr>
	kbd_intr();
f0100580:	e8 c7 ff ff ff       	call   f010054c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100585:	8b 83 b8 1a 00 00    	mov    0x1ab8(%ebx),%eax
	return 0;
f010058b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100590:	3b 83 bc 1a 00 00    	cmp    0x1abc(%ebx),%eax
f0100596:	74 1e                	je     f01005b6 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100598:	8d 48 01             	lea    0x1(%eax),%ecx
f010059b:	0f b6 94 03 b8 18 00 	movzbl 0x18b8(%ebx,%eax,1),%edx
f01005a2:	00 
			cons.rpos = 0;
f01005a3:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	0f 45 c1             	cmovne %ecx,%eax
f01005b0:	89 83 b8 1a 00 00    	mov    %eax,0x1ab8(%ebx)
}
f01005b6:	89 d0                	mov    %edx,%eax
f01005b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005bb:	c9                   	leave  
f01005bc:	c3                   	ret    

f01005bd <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	57                   	push   %edi
f01005c1:	56                   	push   %esi
f01005c2:	53                   	push   %ebx
f01005c3:	83 ec 1c             	sub    $0x1c,%esp
f01005c6:	e8 9c fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005cb:	81 c3 9d e2 07 00    	add    $0x7e29d,%ebx
	was = *cp;
f01005d1:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005df:	5a a5 
	if (*cp != 0xA55A) {
f01005e1:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e8:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005ed:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f01005f2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005f6:	0f 84 ac 00 00 00    	je     f01006a8 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f01005fc:	89 8b c8 1a 00 00    	mov    %ecx,0x1ac8(%ebx)
f0100602:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010060a:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060d:	89 f2                	mov    %esi,%edx
f010060f:	ec                   	in     (%dx),%al
f0100610:	0f b6 c0             	movzbl %al,%eax
f0100613:	c1 e0 08             	shl    $0x8,%eax
f0100616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	b8 0f 00 00 00       	mov    $0xf,%eax
f010061e:	89 ca                	mov    %ecx,%edx
f0100620:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100621:	89 f2                	mov    %esi,%edx
f0100623:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100624:	89 bb c4 1a 00 00    	mov    %edi,0x1ac4(%ebx)
	pos |= inb(addr_6845 + 1);
f010062a:	0f b6 c0             	movzbl %al,%eax
f010062d:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100630:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100637:	b9 00 00 00 00       	mov    $0x0,%ecx
f010063c:	89 c8                	mov    %ecx,%eax
f010063e:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100643:	ee                   	out    %al,(%dx)
f0100644:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100649:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010064e:	89 fa                	mov    %edi,%edx
f0100650:	ee                   	out    %al,(%dx)
f0100651:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100656:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010065b:	ee                   	out    %al,(%dx)
f010065c:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100661:	89 c8                	mov    %ecx,%eax
f0100663:	89 f2                	mov    %esi,%edx
f0100665:	ee                   	out    %al,(%dx)
f0100666:	b8 03 00 00 00       	mov    $0x3,%eax
f010066b:	89 fa                	mov    %edi,%edx
f010066d:	ee                   	out    %al,(%dx)
f010066e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100673:	89 c8                	mov    %ecx,%eax
f0100675:	ee                   	out    %al,(%dx)
f0100676:	b8 01 00 00 00       	mov    $0x1,%eax
f010067b:	89 f2                	mov    %esi,%edx
f010067d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100683:	ec                   	in     (%dx),%al
f0100684:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100686:	3c ff                	cmp    $0xff,%al
f0100688:	0f 95 83 cc 1a 00 00 	setne  0x1acc(%ebx)
f010068f:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100694:	ec                   	in     (%dx),%al
f0100695:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069a:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010069b:	80 f9 ff             	cmp    $0xff,%cl
f010069e:	74 1e                	je     f01006be <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a3:	5b                   	pop    %ebx
f01006a4:	5e                   	pop    %esi
f01006a5:	5f                   	pop    %edi
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    
		*cp = was;
f01006a8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006af:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006b9:	e9 3e ff ff ff       	jmp    f01005fc <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006be:	83 ec 0c             	sub    $0xc,%esp
f01006c1:	8d 83 d1 62 f8 ff    	lea    -0x79d2f(%ebx),%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 5a 2f 00 00       	call   f0103627 <cprintf>
f01006cd:	83 c4 10             	add    $0x10,%esp
}
f01006d0:	eb ce                	jmp    f01006a0 <cons_init+0xe3>

f01006d2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006db:	e8 2f fc ff ff       	call   f010030f <cons_putc>
}
f01006e0:	c9                   	leave  
f01006e1:	c3                   	ret    

f01006e2 <getchar>:

int
getchar(void)
{
f01006e2:	55                   	push   %ebp
f01006e3:	89 e5                	mov    %esp,%ebp
f01006e5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006e8:	e8 7c fe ff ff       	call   f0100569 <cons_getc>
f01006ed:	85 c0                	test   %eax,%eax
f01006ef:	74 f7                	je     f01006e8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    

f01006f3 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01006f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f8:	c3                   	ret    

f01006f9 <__x86.get_pc_thunk.ax>:
f01006f9:	8b 04 24             	mov    (%esp),%eax
f01006fc:	c3                   	ret    

f01006fd <__x86.get_pc_thunk.si>:
f01006fd:	8b 34 24             	mov    (%esp),%esi
f0100700:	c3                   	ret    

f0100701 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100701:	55                   	push   %ebp
f0100702:	89 e5                	mov    %esp,%ebp
f0100704:	56                   	push   %esi
f0100705:	53                   	push   %ebx
f0100706:	e8 5c fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010070b:	81 c3 5d e1 07 00    	add    $0x7e15d,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100711:	83 ec 04             	sub    $0x4,%esp
f0100714:	8d 83 f8 64 f8 ff    	lea    -0x79b08(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	8d 83 16 65 f8 ff    	lea    -0x79aea(%ebx),%eax
f0100721:	50                   	push   %eax
f0100722:	8d b3 1b 65 f8 ff    	lea    -0x79ae5(%ebx),%esi
f0100728:	56                   	push   %esi
f0100729:	e8 f9 2e 00 00       	call   f0103627 <cprintf>
f010072e:	83 c4 0c             	add    $0xc,%esp
f0100731:	8d 83 bc 65 f8 ff    	lea    -0x79a44(%ebx),%eax
f0100737:	50                   	push   %eax
f0100738:	8d 83 24 65 f8 ff    	lea    -0x79adc(%ebx),%eax
f010073e:	50                   	push   %eax
f010073f:	56                   	push   %esi
f0100740:	e8 e2 2e 00 00       	call   f0103627 <cprintf>
	return 0;
}
f0100745:	b8 00 00 00 00       	mov    $0x0,%eax
f010074a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010074d:	5b                   	pop    %ebx
f010074e:	5e                   	pop    %esi
f010074f:	5d                   	pop    %ebp
f0100750:	c3                   	ret    

f0100751 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	57                   	push   %edi
f0100755:	56                   	push   %esi
f0100756:	53                   	push   %ebx
f0100757:	83 ec 18             	sub    $0x18,%esp
f010075a:	e8 08 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010075f:	81 c3 09 e1 07 00    	add    $0x7e109,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100765:	8d 83 2d 65 f8 ff    	lea    -0x79ad3(%ebx),%eax
f010076b:	50                   	push   %eax
f010076c:	e8 b6 2e 00 00       	call   f0103627 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100771:	83 c4 08             	add    $0x8,%esp
f0100774:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010077a:	8d 83 e4 65 f8 ff    	lea    -0x79a1c(%ebx),%eax
f0100780:	50                   	push   %eax
f0100781:	e8 a1 2e 00 00       	call   f0103627 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078f:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100795:	50                   	push   %eax
f0100796:	57                   	push   %edi
f0100797:	8d 83 0c 66 f8 ff    	lea    -0x799f4(%ebx),%eax
f010079d:	50                   	push   %eax
f010079e:	e8 84 2e 00 00       	call   f0103627 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	c7 c0 d1 4a 10 f0    	mov    $0xf0104ad1,%eax
f01007ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b2:	52                   	push   %edx
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 30 66 f8 ff    	lea    -0x799d0(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	e8 67 2e 00 00       	call   f0103627 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	c7 c0 e0 00 18 f0    	mov    $0xf01800e0,%eax
f01007c9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007cf:	52                   	push   %edx
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 54 66 f8 ff    	lea    -0x799ac(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 4a 2e 00 00       	call   f0103627 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dd:	83 c4 0c             	add    $0xc,%esp
f01007e0:	c7 c6 00 10 18 f0    	mov    $0xf0181000,%esi
f01007e6:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007ec:	50                   	push   %eax
f01007ed:	56                   	push   %esi
f01007ee:	8d 83 78 66 f8 ff    	lea    -0x79988(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	e8 2d 2e 00 00       	call   f0103627 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fa:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fd:	29 fe                	sub    %edi,%esi
f01007ff:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	c1 fe 0a             	sar    $0xa,%esi
f0100808:	56                   	push   %esi
f0100809:	8d 83 9c 66 f8 ff    	lea    -0x79964(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 12 2e 00 00       	call   f0103627 <cprintf>
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	5f                   	pop    %edi
f0100820:	5d                   	pop    %ebp
f0100821:	c3                   	ret    

f0100822 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100822:	55                   	push   %ebp
f0100823:	89 e5                	mov    %esp,%ebp
f0100825:	57                   	push   %edi
f0100826:	56                   	push   %esi
f0100827:	53                   	push   %ebx
f0100828:	83 ec 48             	sub    $0x48,%esp
f010082b:	e8 37 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100830:	81 c3 38 e0 07 00    	add    $0x7e038,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));//I guess it means moving ebp register value to local variable. 
f0100836:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t * ebp;
	struct Eipdebuginfo info;
	
	ebp=(uint32_t *)read_ebp();
	cprintf("Stack backtrace:\n");
f0100838:	8d 83 46 65 f8 ff    	lea    -0x79aba(%ebx),%eax
f010083e:	50                   	push   %eax
f010083f:	e8 e3 2d 00 00       	call   f0103627 <cprintf>
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100844:	83 c4 10             	add    $0x10,%esp
		//Exercise 11
		cprintf(" ebp %08x",(uint32_t) ebp);
f0100847:	8d 83 58 65 f8 ff    	lea    -0x79aa8(%ebx),%eax
f010084d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf(" eip %08x",*(ebp+1));
f0100850:	8d 83 62 65 f8 ff    	lea    -0x79a9e(%ebx),%eax
f0100856:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f0100859:	e9 c1 00 00 00       	jmp    f010091f <mon_backtrace+0xfd>
		cprintf(" ebp %08x",(uint32_t) ebp);
f010085e:	83 ec 08             	sub    $0x8,%esp
f0100861:	56                   	push   %esi
f0100862:	ff 75 c4             	push   -0x3c(%ebp)
f0100865:	e8 bd 2d 00 00       	call   f0103627 <cprintf>
		cprintf(" eip %08x",*(ebp+1));
f010086a:	83 c4 08             	add    $0x8,%esp
f010086d:	ff 76 04             	push   0x4(%esi)
f0100870:	ff 75 c0             	push   -0x40(%ebp)
f0100873:	e8 af 2d 00 00       	call   f0103627 <cprintf>
		cprintf(" args");
f0100878:	8d 83 6c 65 f8 ff    	lea    -0x79a94(%ebx),%eax
f010087e:	89 04 24             	mov    %eax,(%esp)
f0100881:	e8 a1 2d 00 00       	call   f0103627 <cprintf>
		// the order of arguments is reverse in the stack. For example, func(a,b), in the stack is b,a.
		cprintf(" %08x",*(ebp+2));
f0100886:	83 c4 08             	add    $0x8,%esp
f0100889:	ff 76 08             	push   0x8(%esi)
f010088c:	8d bb 5c 65 f8 ff    	lea    -0x79aa4(%ebx),%edi
f0100892:	57                   	push   %edi
f0100893:	e8 8f 2d 00 00       	call   f0103627 <cprintf>
		cprintf(" %08x",*(ebp+3));
f0100898:	83 c4 08             	add    $0x8,%esp
f010089b:	ff 76 0c             	push   0xc(%esi)
f010089e:	57                   	push   %edi
f010089f:	e8 83 2d 00 00       	call   f0103627 <cprintf>
		cprintf(" %08x",*(ebp+4));
f01008a4:	83 c4 08             	add    $0x8,%esp
f01008a7:	ff 76 10             	push   0x10(%esi)
f01008aa:	57                   	push   %edi
f01008ab:	e8 77 2d 00 00       	call   f0103627 <cprintf>
		cprintf(" %08x",*(ebp+5));
f01008b0:	83 c4 08             	add    $0x8,%esp
f01008b3:	ff 76 14             	push   0x14(%esi)
f01008b6:	57                   	push   %edi
f01008b7:	e8 6b 2d 00 00       	call   f0103627 <cprintf>
		cprintf(" %08x\n",*(ebp+6));
f01008bc:	83 c4 08             	add    $0x8,%esp
f01008bf:	ff 76 18             	push   0x18(%esi)
f01008c2:	8d 83 69 72 f8 ff    	lea    -0x78d97(%ebx),%eax
f01008c8:	50                   	push   %eax
f01008c9:	e8 59 2d 00 00       	call   f0103627 <cprintf>
		
		//Exercise 12
		debuginfo_eip(*(ebp+1) , &info);
f01008ce:	83 c4 08             	add    $0x8,%esp
f01008d1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008d4:	50                   	push   %eax
f01008d5:	ff 76 04             	push   0x4(%esi)
f01008d8:	e8 ee 32 00 00       	call   f0103bcb <debuginfo_eip>
		cprintf("\t%s:",info.eip_file);
f01008dd:	83 c4 08             	add    $0x8,%esp
f01008e0:	ff 75 d0             	push   -0x30(%ebp)
f01008e3:	8d 83 72 65 f8 ff    	lea    -0x79a8e(%ebx),%eax
f01008e9:	50                   	push   %eax
f01008ea:	e8 38 2d 00 00       	call   f0103627 <cprintf>
		cprintf("%d: ",info.eip_line);
f01008ef:	83 c4 08             	add    $0x8,%esp
f01008f2:	ff 75 d4             	push   -0x2c(%ebp)
f01008f5:	8d 83 a6 62 f8 ff    	lea    -0x79d5a(%ebx),%eax
f01008fb:	50                   	push   %eax
f01008fc:	e8 26 2d 00 00       	call   f0103627 <cprintf>
		cprintf("%.*s+%d\n", info.eip_fn_namelen , info.eip_fn_name , *(ebp+1) - info.eip_fn_addr );
f0100901:	8b 46 04             	mov    0x4(%esi),%eax
f0100904:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100907:	50                   	push   %eax
f0100908:	ff 75 d8             	push   -0x28(%ebp)
f010090b:	ff 75 dc             	push   -0x24(%ebp)
f010090e:	8d 83 77 65 f8 ff    	lea    -0x79a89(%ebx),%eax
f0100914:	50                   	push   %eax
f0100915:	e8 0d 2d 00 00       	call   f0103627 <cprintf>
		
		//
		ebp=(uint32_t *)(*ebp);
f010091a:	8b 36                	mov    (%esi),%esi
f010091c:	83 c4 20             	add    $0x20,%esp
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
f010091f:	85 f6                	test   %esi,%esi
f0100921:	0f 85 37 ff ff ff    	jne    f010085e <mon_backtrace+0x3c>
    	cprintf("x=%d y=%d\n", 3);
    	
	cprintf("Lab1 Exercise8 qusetion3 finish!\n");
	*/
	return 0;
}
f0100927:	b8 00 00 00 00       	mov    $0x0,%eax
f010092c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092f:	5b                   	pop    %ebx
f0100930:	5e                   	pop    %esi
f0100931:	5f                   	pop    %edi
f0100932:	5d                   	pop    %ebp
f0100933:	c3                   	ret    

f0100934 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100934:	55                   	push   %ebp
f0100935:	89 e5                	mov    %esp,%ebp
f0100937:	57                   	push   %edi
f0100938:	56                   	push   %esi
f0100939:	53                   	push   %ebx
f010093a:	83 ec 68             	sub    $0x68,%esp
f010093d:	e8 25 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100942:	81 c3 26 df 07 00    	add    $0x7df26,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100948:	8d 83 c8 66 f8 ff    	lea    -0x79938(%ebx),%eax
f010094e:	50                   	push   %eax
f010094f:	e8 d3 2c 00 00       	call   f0103627 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100954:	8d 83 ec 66 f8 ff    	lea    -0x79914(%ebx),%eax
f010095a:	89 04 24             	mov    %eax,(%esp)
f010095d:	e8 c5 2c 00 00       	call   f0103627 <cprintf>

	if (tf != NULL)
f0100962:	83 c4 10             	add    $0x10,%esp
f0100965:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100969:	74 0e                	je     f0100979 <monitor+0x45>
		print_trapframe(tf);
f010096b:	83 ec 0c             	sub    $0xc,%esp
f010096e:	ff 75 08             	push   0x8(%ebp)
f0100971:	e8 1a 2e 00 00       	call   f0103790 <print_trapframe>
f0100976:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100979:	8d bb 84 65 f8 ff    	lea    -0x79a7c(%ebx),%edi
f010097f:	eb 4a                	jmp    f01009cb <monitor+0x97>
f0100981:	83 ec 08             	sub    $0x8,%esp
f0100984:	0f be c0             	movsbl %al,%eax
f0100987:	50                   	push   %eax
f0100988:	57                   	push   %edi
f0100989:	e8 d8 3c 00 00       	call   f0104666 <strchr>
f010098e:	83 c4 10             	add    $0x10,%esp
f0100991:	85 c0                	test   %eax,%eax
f0100993:	74 08                	je     f010099d <monitor+0x69>
			*buf++ = 0;
f0100995:	c6 06 00             	movb   $0x0,(%esi)
f0100998:	8d 76 01             	lea    0x1(%esi),%esi
f010099b:	eb 79                	jmp    f0100a16 <monitor+0xe2>
		if (*buf == 0)
f010099d:	80 3e 00             	cmpb   $0x0,(%esi)
f01009a0:	74 7f                	je     f0100a21 <monitor+0xed>
		if (argc == MAXARGS-1) {
f01009a2:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009a6:	74 0f                	je     f01009b7 <monitor+0x83>
		argv[argc++] = buf;
f01009a8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009ab:	8d 48 01             	lea    0x1(%eax),%ecx
f01009ae:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009b1:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009b5:	eb 44                	jmp    f01009fb <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009b7:	83 ec 08             	sub    $0x8,%esp
f01009ba:	6a 10                	push   $0x10
f01009bc:	8d 83 89 65 f8 ff    	lea    -0x79a77(%ebx),%eax
f01009c2:	50                   	push   %eax
f01009c3:	e8 5f 2c 00 00       	call   f0103627 <cprintf>
			return 0;
f01009c8:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009cb:	8d 83 80 65 f8 ff    	lea    -0x79a80(%ebx),%eax
f01009d1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009d4:	83 ec 0c             	sub    $0xc,%esp
f01009d7:	ff 75 a4             	push   -0x5c(%ebp)
f01009da:	e8 36 3a 00 00       	call   f0104415 <readline>
f01009df:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009e1:	83 c4 10             	add    $0x10,%esp
f01009e4:	85 c0                	test   %eax,%eax
f01009e6:	74 ec                	je     f01009d4 <monitor+0xa0>
	argv[argc] = 0;
f01009e8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009ef:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009f6:	eb 1e                	jmp    f0100a16 <monitor+0xe2>
			buf++;
f01009f8:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009fb:	0f b6 06             	movzbl (%esi),%eax
f01009fe:	84 c0                	test   %al,%al
f0100a00:	74 14                	je     f0100a16 <monitor+0xe2>
f0100a02:	83 ec 08             	sub    $0x8,%esp
f0100a05:	0f be c0             	movsbl %al,%eax
f0100a08:	50                   	push   %eax
f0100a09:	57                   	push   %edi
f0100a0a:	e8 57 3c 00 00       	call   f0104666 <strchr>
f0100a0f:	83 c4 10             	add    $0x10,%esp
f0100a12:	85 c0                	test   %eax,%eax
f0100a14:	74 e2                	je     f01009f8 <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a16:	0f b6 06             	movzbl (%esi),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	0f 85 60 ff ff ff    	jne    f0100981 <monitor+0x4d>
	argv[argc] = 0;
f0100a21:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a24:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a2b:	00 
	if (argc == 0)
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	74 9b                	je     f01009cb <monitor+0x97>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a30:	83 ec 08             	sub    $0x8,%esp
f0100a33:	8d 83 16 65 f8 ff    	lea    -0x79aea(%ebx),%eax
f0100a39:	50                   	push   %eax
f0100a3a:	ff 75 a8             	push   -0x58(%ebp)
f0100a3d:	e8 c4 3b 00 00       	call   f0104606 <strcmp>
f0100a42:	83 c4 10             	add    $0x10,%esp
f0100a45:	85 c0                	test   %eax,%eax
f0100a47:	74 38                	je     f0100a81 <monitor+0x14d>
f0100a49:	83 ec 08             	sub    $0x8,%esp
f0100a4c:	8d 83 24 65 f8 ff    	lea    -0x79adc(%ebx),%eax
f0100a52:	50                   	push   %eax
f0100a53:	ff 75 a8             	push   -0x58(%ebp)
f0100a56:	e8 ab 3b 00 00       	call   f0104606 <strcmp>
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	85 c0                	test   %eax,%eax
f0100a60:	74 1a                	je     f0100a7c <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a62:	83 ec 08             	sub    $0x8,%esp
f0100a65:	ff 75 a8             	push   -0x58(%ebp)
f0100a68:	8d 83 a6 65 f8 ff    	lea    -0x79a5a(%ebx),%eax
f0100a6e:	50                   	push   %eax
f0100a6f:	e8 b3 2b 00 00       	call   f0103627 <cprintf>
	return 0;
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	e9 4f ff ff ff       	jmp    f01009cb <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a7c:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a81:	83 ec 04             	sub    $0x4,%esp
f0100a84:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a87:	ff 75 08             	push   0x8(%ebp)
f0100a8a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a8d:	52                   	push   %edx
f0100a8e:	ff 75 a4             	push   -0x5c(%ebp)
f0100a91:	ff 94 83 d0 17 00 00 	call   *0x17d0(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a98:	83 c4 10             	add    $0x10,%esp
f0100a9b:	85 c0                	test   %eax,%eax
f0100a9d:	0f 89 28 ff ff ff    	jns    f01009cb <monitor+0x97>
				break;
	}
}
f0100aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa6:	5b                   	pop    %ebx
f0100aa7:	5e                   	pop    %esi
f0100aa8:	5f                   	pop    %edi
f0100aa9:	5d                   	pop    %ebp
f0100aaa:	c3                   	ret    

f0100aab <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100aab:	55                   	push   %ebp
f0100aac:	89 e5                	mov    %esp,%ebp
f0100aae:	57                   	push   %edi
f0100aaf:	56                   	push   %esi
f0100ab0:	53                   	push   %ebx
f0100ab1:	83 ec 18             	sub    $0x18,%esp
f0100ab4:	e8 ae f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ab9:	81 c3 af dd 07 00    	add    $0x7ddaf,%ebx
f0100abf:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac1:	50                   	push   %eax
f0100ac2:	e8 d9 2a 00 00       	call   f01035a0 <mc146818_read>
f0100ac7:	89 c7                	mov    %eax,%edi
f0100ac9:	83 c6 01             	add    $0x1,%esi
f0100acc:	89 34 24             	mov    %esi,(%esp)
f0100acf:	e8 cc 2a 00 00       	call   f01035a0 <mc146818_read>
f0100ad4:	c1 e0 08             	shl    $0x8,%eax
f0100ad7:	09 f8                	or     %edi,%eax
}
f0100ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100adc:	5b                   	pop    %ebx
f0100add:	5e                   	pop    %esi
f0100ade:	5f                   	pop    %edi
f0100adf:	5d                   	pop    %ebp
f0100ae0:	c3                   	ret    

f0100ae1 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ae1:	55                   	push   %ebp
f0100ae2:	89 e5                	mov    %esp,%ebp
f0100ae4:	53                   	push   %ebx
f0100ae5:	83 ec 04             	sub    $0x4,%esp
f0100ae8:	e8 7a f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100aed:	81 c3 7b dd 07 00    	add    $0x7dd7b,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af3:	83 bb dc 1a 00 00 00 	cmpl   $0x0,0x1adc(%ebx)
f0100afa:	74 26                	je     f0100b22 <boot_alloc+0x41>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	
	//
	// LAB 2: Your code here.
	result=nextfree;
f0100afc:	8b 8b dc 1a 00 00    	mov    0x1adc(%ebx),%ecx
	nextfree=ROUNDUP(nextfree+n, PGSIZE);
f0100b02:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100b09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b0e:	89 83 dc 1a 00 00    	mov    %eax,0x1adc(%ebx)
	if( (uint32_t)nextfree < KERNBASE ){
f0100b14:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b19:	76 21                	jbe    f0100b3c <boot_alloc+0x5b>
	//这也与博客的写法 if( (uint32_t)nextfree - KERNBASE > (npages*PGSIZE))所不同。
	
	return result;

	//return NULL;
}
f0100b1b:	89 c8                	mov    %ecx,%eax
f0100b1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b20:	c9                   	leave  
f0100b21:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);//ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向上对齐，即增大数a至n的倍数。
f0100b22:	c7 c1 00 10 18 f0    	mov    $0xf0181000,%ecx
f0100b28:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100b2e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b34:	89 8b dc 1a 00 00    	mov    %ecx,0x1adc(%ebx)
f0100b3a:	eb c0                	jmp    f0100afc <boot_alloc+0x1b>
		panic("boot_alloc: out of memory\n");
f0100b3c:	83 ec 04             	sub    $0x4,%esp
f0100b3f:	8d 83 11 67 f8 ff    	lea    -0x798ef(%ebx),%eax
f0100b45:	50                   	push   %eax
f0100b46:	6a 6e                	push   $0x6e
f0100b48:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100b4e:	50                   	push   %eax
f0100b4f:	e8 5d f5 ff ff       	call   f01000b1 <_panic>

f0100b54 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b54:	55                   	push   %ebp
f0100b55:	89 e5                	mov    %esp,%ebp
f0100b57:	53                   	push   %ebx
f0100b58:	83 ec 04             	sub    $0x4,%esp
f0100b5b:	e8 8b 25 00 00       	call   f01030eb <__x86.get_pc_thunk.cx>
f0100b60:	81 c1 08 dd 07 00    	add    $0x7dd08,%ecx
f0100b66:	89 c3                	mov    %eax,%ebx
f0100b68:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b6a:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100b6d:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100b70:	f6 c2 01             	test   $0x1,%dl
f0100b73:	74 54                	je     f0100bc9 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b75:	89 d3                	mov    %edx,%ebx
f0100b77:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b7d:	c1 ea 0c             	shr    $0xc,%edx
f0100b80:	3b 91 d8 1a 00 00    	cmp    0x1ad8(%ecx),%edx
f0100b86:	73 26                	jae    f0100bae <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100b88:	c1 e8 0c             	shr    $0xc,%eax
f0100b8b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100b90:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b97:	89 d0                	mov    %edx,%eax
f0100b99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b9e:	f6 c2 01             	test   $0x1,%dl
f0100ba1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ba6:	0f 44 c2             	cmove  %edx,%eax
}
f0100ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bac:	c9                   	leave  
f0100bad:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bae:	53                   	push   %ebx
f0100baf:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f0100bb5:	50                   	push   %eax
f0100bb6:	68 3a 03 00 00       	push   $0x33a
f0100bbb:	8d 81 2c 67 f8 ff    	lea    -0x798d4(%ecx),%eax
f0100bc1:	50                   	push   %eax
f0100bc2:	89 cb                	mov    %ecx,%ebx
f0100bc4:	e8 e8 f4 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100bc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bce:	eb d9                	jmp    f0100ba9 <check_va2pa+0x55>

f0100bd0 <check_page_free_list>:
{
f0100bd0:	55                   	push   %ebp
f0100bd1:	89 e5                	mov    %esp,%ebp
f0100bd3:	57                   	push   %edi
f0100bd4:	56                   	push   %esi
f0100bd5:	53                   	push   %ebx
f0100bd6:	83 ec 2c             	sub    $0x2c,%esp
f0100bd9:	e8 11 25 00 00       	call   f01030ef <__x86.get_pc_thunk.di>
f0100bde:	81 c7 8a dc 07 00    	add    $0x7dc8a,%edi
f0100be4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100be7:	84 c0                	test   %al,%al
f0100be9:	0f 85 dc 02 00 00    	jne    f0100ecb <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100bef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bf2:	83 b8 e0 1a 00 00 00 	cmpl   $0x0,0x1ae0(%eax)
f0100bf9:	74 0a                	je     f0100c05 <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100bfb:	bf 00 04 00 00       	mov    $0x400,%edi
f0100c00:	e9 29 03 00 00       	jmp    f0100f2e <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100c05:	83 ec 04             	sub    $0x4,%esp
f0100c08:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c0b:	8d 83 58 6a f8 ff    	lea    -0x795a8(%ebx),%eax
f0100c11:	50                   	push   %eax
f0100c12:	68 76 02 00 00       	push   $0x276
f0100c17:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100c1d:	50                   	push   %eax
f0100c1e:	e8 8e f4 ff ff       	call   f01000b1 <_panic>
f0100c23:	50                   	push   %eax
f0100c24:	89 cb                	mov    %ecx,%ebx
f0100c26:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f0100c2c:	50                   	push   %eax
f0100c2d:	6a 57                	push   $0x57
f0100c2f:	8d 81 38 67 f8 ff    	lea    -0x798c8(%ecx),%eax
f0100c35:	50                   	push   %eax
f0100c36:	e8 76 f4 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c3b:	8b 36                	mov    (%esi),%esi
f0100c3d:	85 f6                	test   %esi,%esi
f0100c3f:	74 47                	je     f0100c88 <check_page_free_list+0xb8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100c41:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c44:	89 f0                	mov    %esi,%eax
f0100c46:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0100c4c:	c1 f8 03             	sar    $0x3,%eax
f0100c4f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c52:	89 c2                	mov    %eax,%edx
f0100c54:	c1 ea 16             	shr    $0x16,%edx
f0100c57:	39 fa                	cmp    %edi,%edx
f0100c59:	73 e0                	jae    f0100c3b <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100c5b:	89 c2                	mov    %eax,%edx
f0100c5d:	c1 ea 0c             	shr    $0xc,%edx
f0100c60:	3b 91 d8 1a 00 00    	cmp    0x1ad8(%ecx),%edx
f0100c66:	73 bb                	jae    f0100c23 <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100c68:	83 ec 04             	sub    $0x4,%esp
f0100c6b:	68 80 00 00 00       	push   $0x80
f0100c70:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c7a:	50                   	push   %eax
f0100c7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c7e:	e8 22 3a 00 00       	call   f01046a5 <memset>
f0100c83:	83 c4 10             	add    $0x10,%esp
f0100c86:	eb b3                	jmp    f0100c3b <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100c88:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c8d:	e8 4f fe ff ff       	call   f0100ae1 <boot_alloc>
f0100c92:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c98:	8b 90 e0 1a 00 00    	mov    0x1ae0(%eax),%edx
		assert(pp >= pages);
f0100c9e:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
		assert(pp < pages + npages);
f0100ca4:	8b 80 d8 1a 00 00    	mov    0x1ad8(%eax),%eax
f0100caa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cad:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cb0:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cba:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cbd:	e9 07 01 00 00       	jmp    f0100dc9 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100cc2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cc5:	8d 83 46 67 f8 ff    	lea    -0x798ba(%ebx),%eax
f0100ccb:	50                   	push   %eax
f0100ccc:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100cd2:	50                   	push   %eax
f0100cd3:	68 90 02 00 00       	push   $0x290
f0100cd8:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100cde:	50                   	push   %eax
f0100cdf:	e8 cd f3 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100ce4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ce7:	8d 83 67 67 f8 ff    	lea    -0x79899(%ebx),%eax
f0100ced:	50                   	push   %eax
f0100cee:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100cf4:	50                   	push   %eax
f0100cf5:	68 91 02 00 00       	push   $0x291
f0100cfa:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100d00:	50                   	push   %eax
f0100d01:	e8 ab f3 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d06:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d09:	8d 83 7c 6a f8 ff    	lea    -0x79584(%ebx),%eax
f0100d0f:	50                   	push   %eax
f0100d10:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100d16:	50                   	push   %eax
f0100d17:	68 92 02 00 00       	push   $0x292
f0100d1c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100d22:	50                   	push   %eax
f0100d23:	e8 89 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100d28:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d2b:	8d 83 7b 67 f8 ff    	lea    -0x79885(%ebx),%eax
f0100d31:	50                   	push   %eax
f0100d32:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100d38:	50                   	push   %eax
f0100d39:	68 95 02 00 00       	push   $0x295
f0100d3e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100d44:	50                   	push   %eax
f0100d45:	e8 67 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d4a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d4d:	8d 83 8c 67 f8 ff    	lea    -0x79874(%ebx),%eax
f0100d53:	50                   	push   %eax
f0100d54:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100d5a:	50                   	push   %eax
f0100d5b:	68 96 02 00 00       	push   $0x296
f0100d60:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100d66:	50                   	push   %eax
f0100d67:	e8 45 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d6f:	8d 83 b0 6a f8 ff    	lea    -0x79550(%ebx),%eax
f0100d75:	50                   	push   %eax
f0100d76:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100d7c:	50                   	push   %eax
f0100d7d:	68 97 02 00 00       	push   $0x297
f0100d82:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100d88:	50                   	push   %eax
f0100d89:	e8 23 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d8e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d91:	8d 83 a5 67 f8 ff    	lea    -0x7985b(%ebx),%eax
f0100d97:	50                   	push   %eax
f0100d98:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100d9e:	50                   	push   %eax
f0100d9f:	68 98 02 00 00       	push   $0x298
f0100da4:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100daa:	50                   	push   %eax
f0100dab:	e8 01 f3 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100db0:	89 c3                	mov    %eax,%ebx
f0100db2:	c1 eb 0c             	shr    $0xc,%ebx
f0100db5:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100db8:	76 6d                	jbe    f0100e27 <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100dba:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dbf:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100dc2:	77 7c                	ja     f0100e40 <check_page_free_list+0x270>
			++nfree_extmem;
f0100dc4:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dc7:	8b 12                	mov    (%edx),%edx
f0100dc9:	85 d2                	test   %edx,%edx
f0100dcb:	0f 84 91 00 00 00    	je     f0100e62 <check_page_free_list+0x292>
		assert(pp >= pages);
f0100dd1:	39 d1                	cmp    %edx,%ecx
f0100dd3:	0f 87 e9 fe ff ff    	ja     f0100cc2 <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100dd9:	39 d6                	cmp    %edx,%esi
f0100ddb:	0f 86 03 ff ff ff    	jbe    f0100ce4 <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100de1:	89 d0                	mov    %edx,%eax
f0100de3:	29 c8                	sub    %ecx,%eax
f0100de5:	a8 07                	test   $0x7,%al
f0100de7:	0f 85 19 ff ff ff    	jne    f0100d06 <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100ded:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100df0:	c1 e0 0c             	shl    $0xc,%eax
f0100df3:	0f 84 2f ff ff ff    	je     f0100d28 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100df9:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dfe:	0f 84 46 ff ff ff    	je     f0100d4a <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e04:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e09:	0f 84 5d ff ff ff    	je     f0100d6c <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e0f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e14:	0f 84 74 ff ff ff    	je     f0100d8e <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e1a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e1f:	77 8f                	ja     f0100db0 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100e21:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100e25:	eb a0                	jmp    f0100dc7 <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e27:	50                   	push   %eax
f0100e28:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e2b:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f0100e31:	50                   	push   %eax
f0100e32:	6a 57                	push   $0x57
f0100e34:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f0100e3a:	50                   	push   %eax
f0100e3b:	e8 71 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e43:	8d 83 d4 6a f8 ff    	lea    -0x7952c(%ebx),%eax
f0100e49:	50                   	push   %eax
f0100e4a:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100e50:	50                   	push   %eax
f0100e51:	68 99 02 00 00       	push   $0x299
f0100e56:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100e5c:	50                   	push   %eax
f0100e5d:	e8 4f f2 ff ff       	call   f01000b1 <_panic>
	assert(nfree_basemem > 0);
f0100e62:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e65:	85 db                	test   %ebx,%ebx
f0100e67:	7e 1e                	jle    f0100e87 <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100e69:	85 ff                	test   %edi,%edi
f0100e6b:	7e 3c                	jle    f0100ea9 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e6d:	83 ec 0c             	sub    $0xc,%esp
f0100e70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e73:	8d 83 1c 6b f8 ff    	lea    -0x794e4(%ebx),%eax
f0100e79:	50                   	push   %eax
f0100e7a:	e8 a8 27 00 00       	call   f0103627 <cprintf>
}
f0100e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e82:	5b                   	pop    %ebx
f0100e83:	5e                   	pop    %esi
f0100e84:	5f                   	pop    %edi
f0100e85:	5d                   	pop    %ebp
f0100e86:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e87:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e8a:	8d 83 bf 67 f8 ff    	lea    -0x79841(%ebx),%eax
f0100e90:	50                   	push   %eax
f0100e91:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100e97:	50                   	push   %eax
f0100e98:	68 a1 02 00 00       	push   $0x2a1
f0100e9d:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100ea3:	50                   	push   %eax
f0100ea4:	e8 08 f2 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100ea9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100eac:	8d 83 d1 67 f8 ff    	lea    -0x7982f(%ebx),%eax
f0100eb2:	50                   	push   %eax
f0100eb3:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0100eb9:	50                   	push   %eax
f0100eba:	68 a2 02 00 00       	push   $0x2a2
f0100ebf:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0100ec5:	50                   	push   %eax
f0100ec6:	e8 e6 f1 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100ecb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ece:	8b 80 e0 1a 00 00    	mov    0x1ae0(%eax),%eax
f0100ed4:	85 c0                	test   %eax,%eax
f0100ed6:	0f 84 29 fd ff ff    	je     f0100c05 <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100edc:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100edf:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ee2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ee5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0100ee8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100eeb:	89 c2                	mov    %eax,%edx
f0100eed:	2b 97 d0 1a 00 00    	sub    0x1ad0(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ef3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ef9:	0f 95 c2             	setne  %dl
f0100efc:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100eff:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f03:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f05:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f09:	8b 00                	mov    (%eax),%eax
f0100f0b:	85 c0                	test   %eax,%eax
f0100f0d:	75 d9                	jne    f0100ee8 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f18:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f1e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f20:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f23:	89 87 e0 1a 00 00    	mov    %eax,0x1ae0(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;//pdx页目录索引，NPDENTRIES宏在mmu.h中定义，为1024
f0100f29:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f31:	8b b0 e0 1a 00 00    	mov    0x1ae0(%eax),%esi
f0100f37:	e9 01 fd ff ff       	jmp    f0100c3d <check_page_free_list+0x6d>

f0100f3c <page_init>:
{
f0100f3c:	55                   	push   %ebp
f0100f3d:	89 e5                	mov    %esp,%ebp
f0100f3f:	57                   	push   %edi
f0100f40:	56                   	push   %esi
f0100f41:	53                   	push   %ebx
f0100f42:	83 ec 0c             	sub    $0xc,%esp
f0100f45:	e8 1d f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100f4a:	81 c3 1e d9 07 00    	add    $0x7d91e,%ebx
	page_free_list = NULL;//其实是多余的，因为它本就是空指针，这只是为了方便阅读一点。
f0100f50:	c7 83 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%ebx)
f0100f57:	00 00 00 
	uint32_t EXTPHYSMEM_alloc = (uint32_t)boot_alloc(0) - KERNBASE;//EXTPHYSMEM_alloc：在EXTPHYSMEM区域已经被占用的bytes数
f0100f5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5f:	e8 7d fb ff ff       	call   f0100ae1 <boot_alloc>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)){//不标记为free的页
f0100f64:	8d b0 00 00 10 10    	lea    0x10100000(%eax),%esi
f0100f6a:	c1 ee 0c             	shr    $0xc,%esi
	for (i = 0; i < npages; i++) {
f0100f6d:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f72:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7c:	eb 10                	jmp    f0100f8e <page_init+0x52>
			pages[i].pp_ref = 1;
f0100f7e:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f0100f84:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
	for (i = 0; i < npages; i++) {
f0100f8b:	83 c0 01             	add    $0x1,%eax
f0100f8e:	39 83 d8 1a 00 00    	cmp    %eax,0x1ad8(%ebx)
f0100f94:	76 35                	jbe    f0100fcb <page_init+0x8f>
		if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)){//不标记为free的页
f0100f96:	85 c0                	test   %eax,%eax
f0100f98:	74 e4                	je     f0100f7e <page_init+0x42>
f0100f9a:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100f9f:	76 04                	jbe    f0100fa5 <page_init+0x69>
f0100fa1:	39 c6                	cmp    %eax,%esi
f0100fa3:	77 d9                	ja     f0100f7e <page_init+0x42>
f0100fa5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100fac:	89 d7                	mov    %edx,%edi
f0100fae:	03 bb d0 1a 00 00    	add    0x1ad0(%ebx),%edi
f0100fb4:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100fba:	89 0f                	mov    %ecx,(%edi)
			page_free_list = &pages[i];	
f0100fbc:	89 d1                	mov    %edx,%ecx
f0100fbe:	03 8b d0 1a 00 00    	add    0x1ad0(%ebx),%ecx
f0100fc4:	bf 01 00 00 00       	mov    $0x1,%edi
f0100fc9:	eb c0                	jmp    f0100f8b <page_init+0x4f>
f0100fcb:	89 f8                	mov    %edi,%eax
f0100fcd:	84 c0                	test   %al,%al
f0100fcf:	74 06                	je     f0100fd7 <page_init+0x9b>
f0100fd1:	89 8b e0 1a 00 00    	mov    %ecx,0x1ae0(%ebx)
}
f0100fd7:	83 c4 0c             	add    $0xc,%esp
f0100fda:	5b                   	pop    %ebx
f0100fdb:	5e                   	pop    %esi
f0100fdc:	5f                   	pop    %edi
f0100fdd:	5d                   	pop    %ebp
f0100fde:	c3                   	ret    

f0100fdf <page_alloc>:
{
f0100fdf:	55                   	push   %ebp
f0100fe0:	89 e5                	mov    %esp,%ebp
f0100fe2:	56                   	push   %esi
f0100fe3:	53                   	push   %ebx
f0100fe4:	e8 7e f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100fe9:	81 c3 7f d8 07 00    	add    $0x7d87f,%ebx
	if(!page_free_list) return res;
f0100fef:	8b b3 e0 1a 00 00    	mov    0x1ae0(%ebx),%esi
f0100ff5:	85 f6                	test   %esi,%esi
f0100ff7:	74 14                	je     f010100d <page_alloc+0x2e>
	page_free_list=page_free_list -> pp_link;
f0100ff9:	8b 06                	mov    (%esi),%eax
f0100ffb:	89 83 e0 1a 00 00    	mov    %eax,0x1ae0(%ebx)
	res ->pp_link=NULL;
f0101001:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO){//尚未发现ALLOC_ZERO宏在哪个文件中定义，直接根据注释来
f0101007:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010100b:	75 09                	jne    f0101016 <page_alloc+0x37>
}
f010100d:	89 f0                	mov    %esi,%eax
f010100f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101012:	5b                   	pop    %ebx
f0101013:	5e                   	pop    %esi
f0101014:	5d                   	pop    %ebp
f0101015:	c3                   	ret    
f0101016:	89 f0                	mov    %esi,%eax
f0101018:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f010101e:	c1 f8 03             	sar    $0x3,%eax
f0101021:	89 c2                	mov    %eax,%edx
f0101023:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101026:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010102b:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0101031:	73 1b                	jae    f010104e <page_alloc+0x6f>
		memset(page2kva(res) , '\0' ,  PGSIZE );
f0101033:	83 ec 04             	sub    $0x4,%esp
f0101036:	68 00 10 00 00       	push   $0x1000
f010103b:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010103d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101043:	52                   	push   %edx
f0101044:	e8 5c 36 00 00       	call   f01046a5 <memset>
f0101049:	83 c4 10             	add    $0x10,%esp
f010104c:	eb bf                	jmp    f010100d <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010104e:	52                   	push   %edx
f010104f:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f0101055:	50                   	push   %eax
f0101056:	6a 57                	push   $0x57
f0101058:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f010105e:	50                   	push   %eax
f010105f:	e8 4d f0 ff ff       	call   f01000b1 <_panic>

f0101064 <page_free>:
{
f0101064:	55                   	push   %ebp
f0101065:	89 e5                	mov    %esp,%ebp
f0101067:	53                   	push   %ebx
f0101068:	83 ec 04             	sub    $0x4,%esp
f010106b:	e8 f7 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101070:	81 c3 f8 d7 07 00    	add    $0x7d7f8,%ebx
f0101076:	8b 45 08             	mov    0x8(%ebp),%eax
      	assert(pp->pp_ref == 0);
f0101079:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010107e:	75 18                	jne    f0101098 <page_free+0x34>
      	assert(pp->pp_link == NULL);
f0101080:	83 38 00             	cmpl   $0x0,(%eax)
f0101083:	75 32                	jne    f01010b7 <page_free+0x53>
	pp->pp_link=page_free_list;
f0101085:	8b 8b e0 1a 00 00    	mov    0x1ae0(%ebx),%ecx
f010108b:	89 08                	mov    %ecx,(%eax)
	page_free_list=pp;
f010108d:	89 83 e0 1a 00 00    	mov    %eax,0x1ae0(%ebx)
}
f0101093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101096:	c9                   	leave  
f0101097:	c3                   	ret    
      	assert(pp->pp_ref == 0);
f0101098:	8d 83 e2 67 f8 ff    	lea    -0x7981e(%ebx),%eax
f010109e:	50                   	push   %eax
f010109f:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01010a5:	50                   	push   %eax
f01010a6:	68 69 01 00 00       	push   $0x169
f01010ab:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01010b1:	50                   	push   %eax
f01010b2:	e8 fa ef ff ff       	call   f01000b1 <_panic>
      	assert(pp->pp_link == NULL);
f01010b7:	8d 83 f2 67 f8 ff    	lea    -0x7980e(%ebx),%eax
f01010bd:	50                   	push   %eax
f01010be:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01010c4:	50                   	push   %eax
f01010c5:	68 6a 01 00 00       	push   $0x16a
f01010ca:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01010d0:	50                   	push   %eax
f01010d1:	e8 db ef ff ff       	call   f01000b1 <_panic>

f01010d6 <page_decref>:
{
f01010d6:	55                   	push   %ebp
f01010d7:	89 e5                	mov    %esp,%ebp
f01010d9:	83 ec 08             	sub    $0x8,%esp
f01010dc:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010df:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010e3:	83 e8 01             	sub    $0x1,%eax
f01010e6:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010ea:	66 85 c0             	test   %ax,%ax
f01010ed:	74 02                	je     f01010f1 <page_decref+0x1b>
}
f01010ef:	c9                   	leave  
f01010f0:	c3                   	ret    
		page_free(pp);
f01010f1:	83 ec 0c             	sub    $0xc,%esp
f01010f4:	52                   	push   %edx
f01010f5:	e8 6a ff ff ff       	call   f0101064 <page_free>
f01010fa:	83 c4 10             	add    $0x10,%esp
}
f01010fd:	eb f0                	jmp    f01010ef <page_decref+0x19>

f01010ff <pgdir_walk>:
{
f01010ff:	55                   	push   %ebp
f0101100:	89 e5                	mov    %esp,%ebp
f0101102:	57                   	push   %edi
f0101103:	56                   	push   %esi
f0101104:	53                   	push   %ebx
f0101105:	83 ec 0c             	sub    $0xc,%esp
f0101108:	e8 5a f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010110d:	81 c3 5b d7 07 00    	add    $0x7d75b,%ebx
f0101113:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde_t* dir_entry=pgdir+PDX(va); //PDX(va)返回page directory index,dir_entry是指向页目录中的DIR ENTRY(见图)的指针。
f0101116:	89 fe                	mov    %edi,%esi
f0101118:	c1 ee 16             	shr    $0x16,%esi
f010111b:	c1 e6 02             	shl    $0x2,%esi
f010111e:	03 75 08             	add    0x8(%ebp),%esi
	if( !(*dir_entry & PTE_P) ){//如果这个页表不存在
f0101121:	f6 06 01             	testb  $0x1,(%esi)
f0101124:	75 67                	jne    f010118d <pgdir_walk+0x8e>
		if(create==false) return NULL;
f0101126:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010112a:	0f 84 b9 00 00 00    	je     f01011e9 <pgdir_walk+0xea>
			struct PageInfo * new_pp =page_alloc(1);//别忘了这个它返回的是struct PageInfo *
f0101130:	83 ec 0c             	sub    $0xc,%esp
f0101133:	6a 01                	push   $0x1
f0101135:	e8 a5 fe ff ff       	call   f0100fdf <page_alloc>
			if(new_pp==NULL){
f010113a:	83 c4 10             	add    $0x10,%esp
f010113d:	85 c0                	test   %eax,%eax
f010113f:	74 71                	je     f01011b2 <pgdir_walk+0xb3>
			new_pp->pp_ref++;
f0101141:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101146:	89 c2                	mov    %eax,%edx
f0101148:	2b 93 d0 1a 00 00    	sub    0x1ad0(%ebx),%edx
f010114e:	c1 fa 03             	sar    $0x3,%edx
f0101151:	c1 e2 0c             	shl    $0xc,%edx
			*dir_entry=(page2pa(new_pp) | PTE_P | PTE_W | PTE_U);//设置dir_entry的标志位。注释中说可以设置宽松，所以这里全部设置为最宽松：可读写，应用程序级别即可访问。 dirty位 和access位不做设置。
f0101154:	83 ca 07             	or     $0x7,%edx
f0101157:	89 16                	mov    %edx,(%esi)
f0101159:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f010115f:	c1 f8 03             	sar    $0x3,%eax
f0101162:	89 c2                	mov    %eax,%edx
f0101164:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101167:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010116c:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0101172:	73 46                	jae    f01011ba <pgdir_walk+0xbb>
			memset(page2kva(new_pp) , '\0' ,  PGSIZE);//初始化new_page的物理内存，一定要用虚拟地址!!!!!			
f0101174:	83 ec 04             	sub    $0x4,%esp
f0101177:	68 00 10 00 00       	push   $0x1000
f010117c:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010117e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101184:	52                   	push   %edx
f0101185:	e8 1b 35 00 00       	call   f01046a5 <memset>
f010118a:	83 c4 10             	add    $0x10,%esp
	pte_t * page_base = KADDR(PTE_ADDR(*dir_entry));//注意这块的类型定义，这涉及地址运算。 很重要，之前的bug就是因为这里!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f010118d:	8b 06                	mov    (%esi),%eax
f010118f:	89 c2                	mov    %eax,%edx
f0101191:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101197:	c1 e8 0c             	shr    $0xc,%eax
f010119a:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f01011a0:	73 2e                	jae    f01011d0 <pgdir_walk+0xd1>
	return  &page_base[PTX(va)];	
f01011a2:	c1 ef 0a             	shr    $0xa,%edi
f01011a5:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01011ab:	8d 84 3a 00 00 00 f0 	lea    -0x10000000(%edx,%edi,1),%eax
}
f01011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b5:	5b                   	pop    %ebx
f01011b6:	5e                   	pop    %esi
f01011b7:	5f                   	pop    %edi
f01011b8:	5d                   	pop    %ebp
f01011b9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ba:	52                   	push   %edx
f01011bb:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f01011c1:	50                   	push   %eax
f01011c2:	6a 57                	push   $0x57
f01011c4:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f01011ca:	50                   	push   %eax
f01011cb:	e8 e1 ee ff ff       	call   f01000b1 <_panic>
f01011d0:	52                   	push   %edx
f01011d1:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f01011d7:	50                   	push   %eax
f01011d8:	68 a5 01 00 00       	push   $0x1a5
f01011dd:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01011e3:	50                   	push   %eax
f01011e4:	e8 c8 ee ff ff       	call   f01000b1 <_panic>
		if(create==false) return NULL;
f01011e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ee:	eb c2                	jmp    f01011b2 <pgdir_walk+0xb3>

f01011f0 <boot_map_region>:
{
f01011f0:	55                   	push   %ebp
f01011f1:	89 e5                	mov    %esp,%ebp
f01011f3:	57                   	push   %edi
f01011f4:	56                   	push   %esi
f01011f5:	53                   	push   %ebx
f01011f6:	83 ec 1c             	sub    $0x1c,%esp
f01011f9:	e8 f1 1e 00 00       	call   f01030ef <__x86.get_pc_thunk.di>
f01011fe:	81 c7 6a d6 07 00    	add    $0x7d66a,%edi
f0101204:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0101207:	89 c7                	mov    %eax,%edi
f0101209:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010120c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i=0; i<size;i+=PGSIZE){
f010120f:	be 00 00 00 00       	mov    $0x0,%esi
f0101214:	89 f3                	mov    %esi,%ebx
f0101216:	03 5d 08             	add    0x8(%ebp),%ebx
f0101219:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f010121c:	76 46                	jbe    f0101264 <boot_map_region+0x74>
		pt_entry=pgdir_walk(pgdir, (void *) va ,1);
f010121e:	83 ec 04             	sub    $0x4,%esp
f0101221:	6a 01                	push   $0x1
f0101223:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101226:	01 f0                	add    %esi,%eax
f0101228:	50                   	push   %eax
f0101229:	57                   	push   %edi
f010122a:	e8 d0 fe ff ff       	call   f01010ff <pgdir_walk>
		if (pt_entry == NULL) {
f010122f:	83 c4 10             	add    $0x10,%esp
f0101232:	85 c0                	test   %eax,%eax
f0101234:	74 10                	je     f0101246 <boot_map_region+0x56>
		* pt_entry=(pa |perm | PTE_P);//按照注释对pg_entry置标志位。
f0101236:	0b 5d 0c             	or     0xc(%ebp),%ebx
f0101239:	83 cb 01             	or     $0x1,%ebx
f010123c:	89 18                	mov    %ebx,(%eax)
	for(int i=0; i<size;i+=PGSIZE){
f010123e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101244:	eb ce                	jmp    f0101214 <boot_map_region+0x24>
            		panic("boot_map_region(): out of memory\n");
f0101246:	83 ec 04             	sub    $0x4,%esp
f0101249:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010124c:	8d 83 40 6b f8 ff    	lea    -0x794c0(%ebx),%eax
f0101252:	50                   	push   %eax
f0101253:	68 be 01 00 00       	push   $0x1be
f0101258:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010125e:	50                   	push   %eax
f010125f:	e8 4d ee ff ff       	call   f01000b1 <_panic>
}
f0101264:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101267:	5b                   	pop    %ebx
f0101268:	5e                   	pop    %esi
f0101269:	5f                   	pop    %edi
f010126a:	5d                   	pop    %ebp
f010126b:	c3                   	ret    

f010126c <page_lookup>:
{
f010126c:	55                   	push   %ebp
f010126d:	89 e5                	mov    %esp,%ebp
f010126f:	56                   	push   %esi
f0101270:	53                   	push   %ebx
f0101271:	e8 f1 ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101276:	81 c3 f2 d5 07 00    	add    $0x7d5f2,%ebx
f010127c:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t * pt_entry=pgdir_walk(pgdir,va,0);
f010127f:	83 ec 04             	sub    $0x4,%esp
f0101282:	6a 00                	push   $0x0
f0101284:	ff 75 0c             	push   0xc(%ebp)
f0101287:	ff 75 08             	push   0x8(%ebp)
f010128a:	e8 70 fe ff ff       	call   f01010ff <pgdir_walk>
	if(pt_entry==NULL)  return NULL;
f010128f:	83 c4 10             	add    $0x10,%esp
f0101292:	85 c0                	test   %eax,%eax
f0101294:	74 21                	je     f01012b7 <page_lookup+0x4b>
	if(!(*pt_entry & PTE_P))  return NULL;
f0101296:	f6 00 01             	testb  $0x1,(%eax)
f0101299:	74 3b                	je     f01012d6 <page_lookup+0x6a>
	if(pte_store) *pte_store=pt_entry;
f010129b:	85 f6                	test   %esi,%esi
f010129d:	74 02                	je     f01012a1 <page_lookup+0x35>
f010129f:	89 06                	mov    %eax,(%esi)
f01012a1:	8b 00                	mov    (%eax),%eax
f01012a3:	c1 e8 0c             	shr    $0xc,%eax

//返回对应物理地址的 struct PageInfo* 部分
static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01012a6:	39 83 d8 1a 00 00    	cmp    %eax,0x1ad8(%ebx)
f01012ac:	76 10                	jbe    f01012be <page_lookup+0x52>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012ae:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f01012b4:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012ba:	5b                   	pop    %ebx
f01012bb:	5e                   	pop    %esi
f01012bc:	5d                   	pop    %ebp
f01012bd:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012be:	83 ec 04             	sub    $0x4,%esp
f01012c1:	8d 83 64 6b f8 ff    	lea    -0x7949c(%ebx),%eax
f01012c7:	50                   	push   %eax
f01012c8:	6a 50                	push   $0x50
f01012ca:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f01012d0:	50                   	push   %eax
f01012d1:	e8 db ed ff ff       	call   f01000b1 <_panic>
	if(!(*pt_entry & PTE_P))  return NULL;
f01012d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012db:	eb da                	jmp    f01012b7 <page_lookup+0x4b>

f01012dd <page_remove>:
{
f01012dd:	55                   	push   %ebp
f01012de:	89 e5                	mov    %esp,%ebp
f01012e0:	53                   	push   %ebx
f01012e1:	83 ec 18             	sub    $0x18,%esp
f01012e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo * pp=page_lookup(pgdir,va,&pt_entry);
f01012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ea:	50                   	push   %eax
f01012eb:	53                   	push   %ebx
f01012ec:	ff 75 08             	push   0x8(%ebp)
f01012ef:	e8 78 ff ff ff       	call   f010126c <page_lookup>
	if(pp==NULL) return ;
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	85 c0                	test   %eax,%eax
f01012f9:	74 18                	je     f0101313 <page_remove+0x36>
	page_decref(pp);
f01012fb:	83 ec 0c             	sub    $0xc,%esp
f01012fe:	50                   	push   %eax
f01012ff:	e8 d2 fd ff ff       	call   f01010d6 <page_decref>
	*pt_entry= 0;
f0101304:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101307:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010130d:	0f 01 3b             	invlpg (%ebx)
f0101310:	83 c4 10             	add    $0x10,%esp
}
f0101313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101316:	c9                   	leave  
f0101317:	c3                   	ret    

f0101318 <page_insert>:
{
f0101318:	55                   	push   %ebp
f0101319:	89 e5                	mov    %esp,%ebp
f010131b:	57                   	push   %edi
f010131c:	56                   	push   %esi
f010131d:	53                   	push   %ebx
f010131e:	83 ec 10             	sub    $0x10,%esp
f0101321:	e8 c9 1d 00 00       	call   f01030ef <__x86.get_pc_thunk.di>
f0101326:	81 c7 42 d5 07 00    	add    $0x7d542,%edi
f010132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* pt_entry=pgdir_walk(pgdir,va,1);
f010132f:	6a 01                	push   $0x1
f0101331:	ff 75 10             	push   0x10(%ebp)
f0101334:	ff 75 08             	push   0x8(%ebp)
f0101337:	e8 c3 fd ff ff       	call   f01010ff <pgdir_walk>
	if(pt_entry==NULL) return -E_NO_MEM;
f010133c:	83 c4 10             	add    $0x10,%esp
f010133f:	85 c0                	test   %eax,%eax
f0101341:	74 40                	je     f0101383 <page_insert+0x6b>
f0101343:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;//这个一定要在前面，否则如果相同的pp 重新插入相同的va就会把  pp释放掉了。
f0101345:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if( (*pt_entry) & PTE_P ){//如果这个页已经存在
f010134a:	f6 00 01             	testb  $0x1,(%eax)
f010134d:	75 21                	jne    f0101370 <page_insert+0x58>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010134f:	2b 9f d0 1a 00 00    	sub    0x1ad0(%edi),%ebx
f0101355:	c1 fb 03             	sar    $0x3,%ebx
f0101358:	c1 e3 0c             	shl    $0xc,%ebx
	*pt_entry = *pt_entry | perm | PTE_P ;
f010135b:	0b 5d 14             	or     0x14(%ebp),%ebx
f010135e:	83 cb 01             	or     $0x1,%ebx
f0101361:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101363:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101368:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010136b:	5b                   	pop    %ebx
f010136c:	5e                   	pop    %esi
f010136d:	5f                   	pop    %edi
f010136e:	5d                   	pop    %ebp
f010136f:	c3                   	ret    
		page_remove(pgdir, va);
f0101370:	83 ec 08             	sub    $0x8,%esp
f0101373:	ff 75 10             	push   0x10(%ebp)
f0101376:	ff 75 08             	push   0x8(%ebp)
f0101379:	e8 5f ff ff ff       	call   f01012dd <page_remove>
f010137e:	83 c4 10             	add    $0x10,%esp
f0101381:	eb cc                	jmp    f010134f <page_insert+0x37>
	if(pt_entry==NULL) return -E_NO_MEM;
f0101383:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101388:	eb de                	jmp    f0101368 <page_insert+0x50>

f010138a <mem_init>:
{
f010138a:	55                   	push   %ebp
f010138b:	89 e5                	mov    %esp,%ebp
f010138d:	57                   	push   %edi
f010138e:	56                   	push   %esi
f010138f:	53                   	push   %ebx
f0101390:	83 ec 3c             	sub    $0x3c,%esp
f0101393:	e8 61 f3 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0101398:	05 d0 d4 07 00       	add    $0x7d4d0,%eax
f010139d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01013a0:	b8 15 00 00 00       	mov    $0x15,%eax
f01013a5:	e8 01 f7 ff ff       	call   f0100aab <nvram_read>
f01013aa:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013ac:	b8 17 00 00 00       	mov    $0x17,%eax
f01013b1:	e8 f5 f6 ff ff       	call   f0100aab <nvram_read>
f01013b6:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013b8:	b8 34 00 00 00       	mov    $0x34,%eax
f01013bd:	e8 e9 f6 ff ff       	call   f0100aab <nvram_read>
	if (ext16mem)
f01013c2:	c1 e0 06             	shl    $0x6,%eax
f01013c5:	0f 84 c0 00 00 00    	je     f010148b <mem_init+0x101>
		totalmem = 16 * 1024 + ext16mem;
f01013cb:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013d0:	89 c2                	mov    %eax,%edx
f01013d2:	c1 ea 02             	shr    $0x2,%edx
f01013d5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01013d8:	89 91 d8 1a 00 00    	mov    %edx,0x1ad8(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013de:	89 c2                	mov    %eax,%edx
f01013e0:	29 da                	sub    %ebx,%edx
f01013e2:	52                   	push   %edx
f01013e3:	53                   	push   %ebx
f01013e4:	50                   	push   %eax
f01013e5:	8d 81 84 6b f8 ff    	lea    -0x7947c(%ecx),%eax
f01013eb:	50                   	push   %eax
f01013ec:	89 cb                	mov    %ecx,%ebx
f01013ee:	e8 34 22 00 00       	call   f0103627 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013f3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013f8:	e8 e4 f6 ff ff       	call   f0100ae1 <boot_alloc>
f01013fd:	89 83 d4 1a 00 00    	mov    %eax,0x1ad4(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101403:	83 c4 0c             	add    $0xc,%esp
f0101406:	68 00 10 00 00       	push   $0x1000
f010140b:	6a 00                	push   $0x0
f010140d:	50                   	push   %eax
f010140e:	e8 92 32 00 00       	call   f01046a5 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101413:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101419:	83 c4 10             	add    $0x10,%esp
f010141c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101421:	76 78                	jbe    f010149b <mem_init+0x111>
	return (physaddr_t)kva - KERNBASE;
f0101423:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101429:	83 ca 05             	or     $0x5,%edx
f010142c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = boot_alloc(npages * sizeof(struct PageInfo));//pages是页信息数组的地址
f0101432:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101435:	8b 87 d8 1a 00 00    	mov    0x1ad8(%edi),%eax
f010143b:	c1 e0 03             	shl    $0x3,%eax
f010143e:	e8 9e f6 ff ff       	call   f0100ae1 <boot_alloc>
f0101443:	89 87 d0 1a 00 00    	mov    %eax,0x1ad0(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101449:	83 ec 04             	sub    $0x4,%esp
f010144c:	8b 97 d8 1a 00 00    	mov    0x1ad8(%edi),%edx
f0101452:	c1 e2 03             	shl    $0x3,%edx
f0101455:	52                   	push   %edx
f0101456:	6a 00                	push   $0x0
f0101458:	50                   	push   %eax
f0101459:	89 fb                	mov    %edi,%ebx
f010145b:	e8 45 32 00 00       	call   f01046a5 <memset>
	page_init();
f0101460:	e8 d7 fa ff ff       	call   f0100f3c <page_init>
	check_page_free_list(1);
f0101465:	b8 01 00 00 00       	mov    $0x1,%eax
f010146a:	e8 61 f7 ff ff       	call   f0100bd0 <check_page_free_list>
	if (!pages)
f010146f:	83 c4 10             	add    $0x10,%esp
f0101472:	83 bf d0 1a 00 00 00 	cmpl   $0x0,0x1ad0(%edi)
f0101479:	74 3c                	je     f01014b7 <mem_init+0x12d>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010147b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010147e:	8b 80 e0 1a 00 00    	mov    0x1ae0(%eax),%eax
f0101484:	be 00 00 00 00       	mov    $0x0,%esi
f0101489:	eb 4f                	jmp    f01014da <mem_init+0x150>
		totalmem = 1 * 1024 + extmem;
f010148b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101491:	85 f6                	test   %esi,%esi
f0101493:	0f 44 c3             	cmove  %ebx,%eax
f0101496:	e9 35 ff ff ff       	jmp    f01013d0 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010149b:	50                   	push   %eax
f010149c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010149f:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f01014a5:	50                   	push   %eax
f01014a6:	68 98 00 00 00       	push   $0x98
f01014ab:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01014b1:	50                   	push   %eax
f01014b2:	e8 fa eb ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f01014b7:	83 ec 04             	sub    $0x4,%esp
f01014ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014bd:	8d 83 06 68 f8 ff    	lea    -0x797fa(%ebx),%eax
f01014c3:	50                   	push   %eax
f01014c4:	68 b5 02 00 00       	push   $0x2b5
f01014c9:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01014cf:	50                   	push   %eax
f01014d0:	e8 dc eb ff ff       	call   f01000b1 <_panic>
		++nfree;
f01014d5:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014d8:	8b 00                	mov    (%eax),%eax
f01014da:	85 c0                	test   %eax,%eax
f01014dc:	75 f7                	jne    f01014d5 <mem_init+0x14b>
	assert((pp0 = page_alloc(0)));
f01014de:	83 ec 0c             	sub    $0xc,%esp
f01014e1:	6a 00                	push   $0x0
f01014e3:	e8 f7 fa ff ff       	call   f0100fdf <page_alloc>
f01014e8:	89 c3                	mov    %eax,%ebx
f01014ea:	83 c4 10             	add    $0x10,%esp
f01014ed:	85 c0                	test   %eax,%eax
f01014ef:	0f 84 3a 02 00 00    	je     f010172f <mem_init+0x3a5>
	assert((pp1 = page_alloc(0)));
f01014f5:	83 ec 0c             	sub    $0xc,%esp
f01014f8:	6a 00                	push   $0x0
f01014fa:	e8 e0 fa ff ff       	call   f0100fdf <page_alloc>
f01014ff:	89 c7                	mov    %eax,%edi
f0101501:	83 c4 10             	add    $0x10,%esp
f0101504:	85 c0                	test   %eax,%eax
f0101506:	0f 84 45 02 00 00    	je     f0101751 <mem_init+0x3c7>
	assert((pp2 = page_alloc(0)));
f010150c:	83 ec 0c             	sub    $0xc,%esp
f010150f:	6a 00                	push   $0x0
f0101511:	e8 c9 fa ff ff       	call   f0100fdf <page_alloc>
f0101516:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101519:	83 c4 10             	add    $0x10,%esp
f010151c:	85 c0                	test   %eax,%eax
f010151e:	0f 84 4f 02 00 00    	je     f0101773 <mem_init+0x3e9>
	assert(pp1 && pp1 != pp0);
f0101524:	39 fb                	cmp    %edi,%ebx
f0101526:	0f 84 69 02 00 00    	je     f0101795 <mem_init+0x40b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010152c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010152f:	39 c3                	cmp    %eax,%ebx
f0101531:	0f 84 80 02 00 00    	je     f01017b7 <mem_init+0x42d>
f0101537:	39 c7                	cmp    %eax,%edi
f0101539:	0f 84 78 02 00 00    	je     f01017b7 <mem_init+0x42d>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010153f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101542:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101548:	8b 90 d8 1a 00 00    	mov    0x1ad8(%eax),%edx
f010154e:	c1 e2 0c             	shl    $0xc,%edx
f0101551:	89 d8                	mov    %ebx,%eax
f0101553:	29 c8                	sub    %ecx,%eax
f0101555:	c1 f8 03             	sar    $0x3,%eax
f0101558:	c1 e0 0c             	shl    $0xc,%eax
f010155b:	39 d0                	cmp    %edx,%eax
f010155d:	0f 83 76 02 00 00    	jae    f01017d9 <mem_init+0x44f>
f0101563:	89 f8                	mov    %edi,%eax
f0101565:	29 c8                	sub    %ecx,%eax
f0101567:	c1 f8 03             	sar    $0x3,%eax
f010156a:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010156d:	39 c2                	cmp    %eax,%edx
f010156f:	0f 86 86 02 00 00    	jbe    f01017fb <mem_init+0x471>
f0101575:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101578:	29 c8                	sub    %ecx,%eax
f010157a:	c1 f8 03             	sar    $0x3,%eax
f010157d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101580:	39 c2                	cmp    %eax,%edx
f0101582:	0f 86 95 02 00 00    	jbe    f010181d <mem_init+0x493>
	fl = page_free_list;
f0101588:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010158b:	8b 88 e0 1a 00 00    	mov    0x1ae0(%eax),%ecx
f0101591:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101594:	c7 80 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%eax)
f010159b:	00 00 00 
	assert(!page_alloc(0));
f010159e:	83 ec 0c             	sub    $0xc,%esp
f01015a1:	6a 00                	push   $0x0
f01015a3:	e8 37 fa ff ff       	call   f0100fdf <page_alloc>
f01015a8:	83 c4 10             	add    $0x10,%esp
f01015ab:	85 c0                	test   %eax,%eax
f01015ad:	0f 85 8c 02 00 00    	jne    f010183f <mem_init+0x4b5>
	page_free(pp0);
f01015b3:	83 ec 0c             	sub    $0xc,%esp
f01015b6:	53                   	push   %ebx
f01015b7:	e8 a8 fa ff ff       	call   f0101064 <page_free>
	page_free(pp1);
f01015bc:	89 3c 24             	mov    %edi,(%esp)
f01015bf:	e8 a0 fa ff ff       	call   f0101064 <page_free>
	page_free(pp2);
f01015c4:	83 c4 04             	add    $0x4,%esp
f01015c7:	ff 75 d0             	push   -0x30(%ebp)
f01015ca:	e8 95 fa ff ff       	call   f0101064 <page_free>
	assert((pp0 = page_alloc(0)));
f01015cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015d6:	e8 04 fa ff ff       	call   f0100fdf <page_alloc>
f01015db:	89 c7                	mov    %eax,%edi
f01015dd:	83 c4 10             	add    $0x10,%esp
f01015e0:	85 c0                	test   %eax,%eax
f01015e2:	0f 84 79 02 00 00    	je     f0101861 <mem_init+0x4d7>
	assert((pp1 = page_alloc(0)));
f01015e8:	83 ec 0c             	sub    $0xc,%esp
f01015eb:	6a 00                	push   $0x0
f01015ed:	e8 ed f9 ff ff       	call   f0100fdf <page_alloc>
f01015f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015f5:	83 c4 10             	add    $0x10,%esp
f01015f8:	85 c0                	test   %eax,%eax
f01015fa:	0f 84 83 02 00 00    	je     f0101883 <mem_init+0x4f9>
	assert((pp2 = page_alloc(0)));
f0101600:	83 ec 0c             	sub    $0xc,%esp
f0101603:	6a 00                	push   $0x0
f0101605:	e8 d5 f9 ff ff       	call   f0100fdf <page_alloc>
f010160a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010160d:	83 c4 10             	add    $0x10,%esp
f0101610:	85 c0                	test   %eax,%eax
f0101612:	0f 84 8d 02 00 00    	je     f01018a5 <mem_init+0x51b>
	assert(pp1 && pp1 != pp0);
f0101618:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f010161b:	0f 84 a6 02 00 00    	je     f01018c7 <mem_init+0x53d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101621:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101624:	39 c7                	cmp    %eax,%edi
f0101626:	0f 84 bd 02 00 00    	je     f01018e9 <mem_init+0x55f>
f010162c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010162f:	0f 84 b4 02 00 00    	je     f01018e9 <mem_init+0x55f>
	assert(!page_alloc(0));
f0101635:	83 ec 0c             	sub    $0xc,%esp
f0101638:	6a 00                	push   $0x0
f010163a:	e8 a0 f9 ff ff       	call   f0100fdf <page_alloc>
f010163f:	83 c4 10             	add    $0x10,%esp
f0101642:	85 c0                	test   %eax,%eax
f0101644:	0f 85 c1 02 00 00    	jne    f010190b <mem_init+0x581>
f010164a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010164d:	89 f8                	mov    %edi,%eax
f010164f:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101655:	c1 f8 03             	sar    $0x3,%eax
f0101658:	89 c2                	mov    %eax,%edx
f010165a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010165d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101662:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101668:	0f 83 bf 02 00 00    	jae    f010192d <mem_init+0x5a3>
	memset(page2kva(pp0), 1, PGSIZE);
f010166e:	83 ec 04             	sub    $0x4,%esp
f0101671:	68 00 10 00 00       	push   $0x1000
f0101676:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101678:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010167e:	52                   	push   %edx
f010167f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101682:	e8 1e 30 00 00       	call   f01046a5 <memset>
	page_free(pp0);
f0101687:	89 3c 24             	mov    %edi,(%esp)
f010168a:	e8 d5 f9 ff ff       	call   f0101064 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010168f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101696:	e8 44 f9 ff ff       	call   f0100fdf <page_alloc>
f010169b:	83 c4 10             	add    $0x10,%esp
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	0f 84 9f 02 00 00    	je     f0101945 <mem_init+0x5bb>
	assert(pp && pp0 == pp);
f01016a6:	39 c7                	cmp    %eax,%edi
f01016a8:	0f 85 b9 02 00 00    	jne    f0101967 <mem_init+0x5dd>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f01016ae:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016b1:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f01016b7:	c1 f8 03             	sar    $0x3,%eax
f01016ba:	89 c2                	mov    %eax,%edx
f01016bc:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016bf:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016c4:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f01016ca:	0f 83 b9 02 00 00    	jae    f0101989 <mem_init+0x5ff>
	return (void *)(pa + KERNBASE);
f01016d0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01016d6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01016dc:	80 38 00             	cmpb   $0x0,(%eax)
f01016df:	0f 85 bc 02 00 00    	jne    f01019a1 <mem_init+0x617>
	for (i = 0; i < PGSIZE; i++)
f01016e5:	83 c0 01             	add    $0x1,%eax
f01016e8:	39 d0                	cmp    %edx,%eax
f01016ea:	75 f0                	jne    f01016dc <mem_init+0x352>
	page_free_list = fl;
f01016ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ef:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01016f2:	89 8b e0 1a 00 00    	mov    %ecx,0x1ae0(%ebx)
	page_free(pp0);
f01016f8:	83 ec 0c             	sub    $0xc,%esp
f01016fb:	57                   	push   %edi
f01016fc:	e8 63 f9 ff ff       	call   f0101064 <page_free>
	page_free(pp1);
f0101701:	83 c4 04             	add    $0x4,%esp
f0101704:	ff 75 d0             	push   -0x30(%ebp)
f0101707:	e8 58 f9 ff ff       	call   f0101064 <page_free>
	page_free(pp2);
f010170c:	83 c4 04             	add    $0x4,%esp
f010170f:	ff 75 cc             	push   -0x34(%ebp)
f0101712:	e8 4d f9 ff ff       	call   f0101064 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101717:	8b 83 e0 1a 00 00    	mov    0x1ae0(%ebx),%eax
f010171d:	83 c4 10             	add    $0x10,%esp
f0101720:	85 c0                	test   %eax,%eax
f0101722:	0f 84 9b 02 00 00    	je     f01019c3 <mem_init+0x639>
		--nfree;
f0101728:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010172b:	8b 00                	mov    (%eax),%eax
f010172d:	eb f1                	jmp    f0101720 <mem_init+0x396>
	assert((pp0 = page_alloc(0)));
f010172f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101732:	8d 83 21 68 f8 ff    	lea    -0x797df(%ebx),%eax
f0101738:	50                   	push   %eax
f0101739:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010173f:	50                   	push   %eax
f0101740:	68 bd 02 00 00       	push   $0x2bd
f0101745:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010174b:	50                   	push   %eax
f010174c:	e8 60 e9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101751:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101754:	8d 83 37 68 f8 ff    	lea    -0x797c9(%ebx),%eax
f010175a:	50                   	push   %eax
f010175b:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0101761:	50                   	push   %eax
f0101762:	68 be 02 00 00       	push   $0x2be
f0101767:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010176d:	50                   	push   %eax
f010176e:	e8 3e e9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101773:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101776:	8d 83 4d 68 f8 ff    	lea    -0x797b3(%ebx),%eax
f010177c:	50                   	push   %eax
f010177d:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0101783:	50                   	push   %eax
f0101784:	68 bf 02 00 00       	push   $0x2bf
f0101789:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010178f:	50                   	push   %eax
f0101790:	e8 1c e9 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101795:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101798:	8d 83 63 68 f8 ff    	lea    -0x7979d(%ebx),%eax
f010179e:	50                   	push   %eax
f010179f:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01017a5:	50                   	push   %eax
f01017a6:	68 c2 02 00 00       	push   $0x2c2
f01017ab:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01017b1:	50                   	push   %eax
f01017b2:	e8 fa e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ba:	8d 83 e4 6b f8 ff    	lea    -0x7941c(%ebx),%eax
f01017c0:	50                   	push   %eax
f01017c1:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01017c7:	50                   	push   %eax
f01017c8:	68 c3 02 00 00       	push   $0x2c3
f01017cd:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01017d3:	50                   	push   %eax
f01017d4:	e8 d8 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01017d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017dc:	8d 83 75 68 f8 ff    	lea    -0x7978b(%ebx),%eax
f01017e2:	50                   	push   %eax
f01017e3:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01017e9:	50                   	push   %eax
f01017ea:	68 c4 02 00 00       	push   $0x2c4
f01017ef:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01017f5:	50                   	push   %eax
f01017f6:	e8 b6 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017fe:	8d 83 92 68 f8 ff    	lea    -0x7976e(%ebx),%eax
f0101804:	50                   	push   %eax
f0101805:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010180b:	50                   	push   %eax
f010180c:	68 c5 02 00 00       	push   $0x2c5
f0101811:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0101817:	50                   	push   %eax
f0101818:	e8 94 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010181d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101820:	8d 83 af 68 f8 ff    	lea    -0x79751(%ebx),%eax
f0101826:	50                   	push   %eax
f0101827:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010182d:	50                   	push   %eax
f010182e:	68 c6 02 00 00       	push   $0x2c6
f0101833:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0101839:	50                   	push   %eax
f010183a:	e8 72 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010183f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101842:	8d 83 cc 68 f8 ff    	lea    -0x79734(%ebx),%eax
f0101848:	50                   	push   %eax
f0101849:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010184f:	50                   	push   %eax
f0101850:	68 cd 02 00 00       	push   $0x2cd
f0101855:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010185b:	50                   	push   %eax
f010185c:	e8 50 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0101861:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101864:	8d 83 21 68 f8 ff    	lea    -0x797df(%ebx),%eax
f010186a:	50                   	push   %eax
f010186b:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0101871:	50                   	push   %eax
f0101872:	68 d4 02 00 00       	push   $0x2d4
f0101877:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010187d:	50                   	push   %eax
f010187e:	e8 2e e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101883:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101886:	8d 83 37 68 f8 ff    	lea    -0x797c9(%ebx),%eax
f010188c:	50                   	push   %eax
f010188d:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0101893:	50                   	push   %eax
f0101894:	68 d5 02 00 00       	push   $0x2d5
f0101899:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010189f:	50                   	push   %eax
f01018a0:	e8 0c e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01018a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a8:	8d 83 4d 68 f8 ff    	lea    -0x797b3(%ebx),%eax
f01018ae:	50                   	push   %eax
f01018af:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01018b5:	50                   	push   %eax
f01018b6:	68 d6 02 00 00       	push   $0x2d6
f01018bb:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01018c1:	50                   	push   %eax
f01018c2:	e8 ea e7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01018c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ca:	8d 83 63 68 f8 ff    	lea    -0x7979d(%ebx),%eax
f01018d0:	50                   	push   %eax
f01018d1:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01018d7:	50                   	push   %eax
f01018d8:	68 d8 02 00 00       	push   $0x2d8
f01018dd:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01018e3:	50                   	push   %eax
f01018e4:	e8 c8 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ec:	8d 83 e4 6b f8 ff    	lea    -0x7941c(%ebx),%eax
f01018f2:	50                   	push   %eax
f01018f3:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01018f9:	50                   	push   %eax
f01018fa:	68 d9 02 00 00       	push   $0x2d9
f01018ff:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0101905:	50                   	push   %eax
f0101906:	e8 a6 e7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010190b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010190e:	8d 83 cc 68 f8 ff    	lea    -0x79734(%ebx),%eax
f0101914:	50                   	push   %eax
f0101915:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010191b:	50                   	push   %eax
f010191c:	68 da 02 00 00       	push   $0x2da
f0101921:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0101927:	50                   	push   %eax
f0101928:	e8 84 e7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010192d:	52                   	push   %edx
f010192e:	89 cb                	mov    %ecx,%ebx
f0101930:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f0101936:	50                   	push   %eax
f0101937:	6a 57                	push   $0x57
f0101939:	8d 81 38 67 f8 ff    	lea    -0x798c8(%ecx),%eax
f010193f:	50                   	push   %eax
f0101940:	e8 6c e7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101945:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101948:	8d 83 db 68 f8 ff    	lea    -0x79725(%ebx),%eax
f010194e:	50                   	push   %eax
f010194f:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0101955:	50                   	push   %eax
f0101956:	68 df 02 00 00       	push   $0x2df
f010195b:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0101961:	50                   	push   %eax
f0101962:	e8 4a e7 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101967:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010196a:	8d 83 f9 68 f8 ff    	lea    -0x79707(%ebx),%eax
f0101970:	50                   	push   %eax
f0101971:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0101977:	50                   	push   %eax
f0101978:	68 e0 02 00 00       	push   $0x2e0
f010197d:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0101983:	50                   	push   %eax
f0101984:	e8 28 e7 ff ff       	call   f01000b1 <_panic>
f0101989:	52                   	push   %edx
f010198a:	89 cb                	mov    %ecx,%ebx
f010198c:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f0101992:	50                   	push   %eax
f0101993:	6a 57                	push   $0x57
f0101995:	8d 81 38 67 f8 ff    	lea    -0x798c8(%ecx),%eax
f010199b:	50                   	push   %eax
f010199c:	e8 10 e7 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01019a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019a4:	8d 83 09 69 f8 ff    	lea    -0x796f7(%ebx),%eax
f01019aa:	50                   	push   %eax
f01019ab:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01019b1:	50                   	push   %eax
f01019b2:	68 e3 02 00 00       	push   $0x2e3
f01019b7:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01019bd:	50                   	push   %eax
f01019be:	e8 ee e6 ff ff       	call   f01000b1 <_panic>
	assert(nfree == 0);
f01019c3:	85 f6                	test   %esi,%esi
f01019c5:	0f 85 39 08 00 00    	jne    f0102204 <mem_init+0xe7a>
	cprintf("check_page_alloc() succeeded!\n");
f01019cb:	83 ec 0c             	sub    $0xc,%esp
f01019ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019d1:	8d 83 04 6c f8 ff    	lea    -0x793fc(%ebx),%eax
f01019d7:	50                   	push   %eax
f01019d8:	e8 4a 1c 00 00       	call   f0103627 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e4:	e8 f6 f5 ff ff       	call   f0100fdf <page_alloc>
f01019e9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019ec:	83 c4 10             	add    $0x10,%esp
f01019ef:	85 c0                	test   %eax,%eax
f01019f1:	0f 84 2f 08 00 00    	je     f0102226 <mem_init+0xe9c>
	assert((pp1 = page_alloc(0)));
f01019f7:	83 ec 0c             	sub    $0xc,%esp
f01019fa:	6a 00                	push   $0x0
f01019fc:	e8 de f5 ff ff       	call   f0100fdf <page_alloc>
f0101a01:	89 c7                	mov    %eax,%edi
f0101a03:	83 c4 10             	add    $0x10,%esp
f0101a06:	85 c0                	test   %eax,%eax
f0101a08:	0f 84 3a 08 00 00    	je     f0102248 <mem_init+0xebe>
	assert((pp2 = page_alloc(0)));
f0101a0e:	83 ec 0c             	sub    $0xc,%esp
f0101a11:	6a 00                	push   $0x0
f0101a13:	e8 c7 f5 ff ff       	call   f0100fdf <page_alloc>
f0101a18:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a1b:	83 c4 10             	add    $0x10,%esp
f0101a1e:	85 c0                	test   %eax,%eax
f0101a20:	0f 84 44 08 00 00    	je     f010226a <mem_init+0xee0>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a26:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101a29:	0f 84 5d 08 00 00    	je     f010228c <mem_init+0xf02>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a2f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a32:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101a35:	0f 84 73 08 00 00    	je     f01022ae <mem_init+0xf24>
f0101a3b:	39 c7                	cmp    %eax,%edi
f0101a3d:	0f 84 6b 08 00 00    	je     f01022ae <mem_init+0xf24>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a46:	8b 88 e0 1a 00 00    	mov    0x1ae0(%eax),%ecx
f0101a4c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101a4f:	c7 80 e0 1a 00 00 00 	movl   $0x0,0x1ae0(%eax)
f0101a56:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a59:	83 ec 0c             	sub    $0xc,%esp
f0101a5c:	6a 00                	push   $0x0
f0101a5e:	e8 7c f5 ff ff       	call   f0100fdf <page_alloc>
f0101a63:	83 c4 10             	add    $0x10,%esp
f0101a66:	85 c0                	test   %eax,%eax
f0101a68:	0f 85 62 08 00 00    	jne    f01022d0 <mem_init+0xf46>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a6e:	83 ec 04             	sub    $0x4,%esp
f0101a71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a74:	50                   	push   %eax
f0101a75:	6a 00                	push   $0x0
f0101a77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a7a:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101a80:	e8 e7 f7 ff ff       	call   f010126c <page_lookup>
f0101a85:	83 c4 10             	add    $0x10,%esp
f0101a88:	85 c0                	test   %eax,%eax
f0101a8a:	0f 85 62 08 00 00    	jne    f01022f2 <mem_init+0xf68>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a90:	6a 02                	push   $0x2
f0101a92:	6a 00                	push   $0x0
f0101a94:	57                   	push   %edi
f0101a95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a98:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101a9e:	e8 75 f8 ff ff       	call   f0101318 <page_insert>
f0101aa3:	83 c4 10             	add    $0x10,%esp
f0101aa6:	85 c0                	test   %eax,%eax
f0101aa8:	0f 89 66 08 00 00    	jns    f0102314 <mem_init+0xf8a>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101aae:	83 ec 0c             	sub    $0xc,%esp
f0101ab1:	ff 75 cc             	push   -0x34(%ebp)
f0101ab4:	e8 ab f5 ff ff       	call   f0101064 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ab9:	6a 02                	push   $0x2
f0101abb:	6a 00                	push   $0x0
f0101abd:	57                   	push   %edi
f0101abe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac1:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101ac7:	e8 4c f8 ff ff       	call   f0101318 <page_insert>
f0101acc:	83 c4 20             	add    $0x20,%esp
f0101acf:	85 c0                	test   %eax,%eax
f0101ad1:	0f 85 5f 08 00 00    	jne    f0102336 <mem_init+0xfac>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ad7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ada:	8b 98 d4 1a 00 00    	mov    0x1ad4(%eax),%ebx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101ae0:	8b b0 d0 1a 00 00    	mov    0x1ad0(%eax),%esi
f0101ae6:	8b 13                	mov    (%ebx),%edx
f0101ae8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101aee:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101af1:	29 f0                	sub    %esi,%eax
f0101af3:	c1 f8 03             	sar    $0x3,%eax
f0101af6:	c1 e0 0c             	shl    $0xc,%eax
f0101af9:	39 c2                	cmp    %eax,%edx
f0101afb:	0f 85 57 08 00 00    	jne    f0102358 <mem_init+0xfce>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b01:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b06:	89 d8                	mov    %ebx,%eax
f0101b08:	e8 47 f0 ff ff       	call   f0100b54 <check_va2pa>
f0101b0d:	89 c2                	mov    %eax,%edx
f0101b0f:	89 f8                	mov    %edi,%eax
f0101b11:	29 f0                	sub    %esi,%eax
f0101b13:	c1 f8 03             	sar    $0x3,%eax
f0101b16:	c1 e0 0c             	shl    $0xc,%eax
f0101b19:	39 c2                	cmp    %eax,%edx
f0101b1b:	0f 85 59 08 00 00    	jne    f010237a <mem_init+0xff0>
	assert(pp1->pp_ref == 1);
f0101b21:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b26:	0f 85 70 08 00 00    	jne    f010239c <mem_init+0x1012>
	assert(pp0->pp_ref == 1);
f0101b2c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101b2f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b34:	0f 85 84 08 00 00    	jne    f01023be <mem_init+0x1034>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b3a:	6a 02                	push   $0x2
f0101b3c:	68 00 10 00 00       	push   $0x1000
f0101b41:	ff 75 d0             	push   -0x30(%ebp)
f0101b44:	53                   	push   %ebx
f0101b45:	e8 ce f7 ff ff       	call   f0101318 <page_insert>
f0101b4a:	83 c4 10             	add    $0x10,%esp
f0101b4d:	85 c0                	test   %eax,%eax
f0101b4f:	0f 85 8b 08 00 00    	jne    f01023e0 <mem_init+0x1056>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b55:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b5a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b5d:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101b63:	e8 ec ef ff ff       	call   f0100b54 <check_va2pa>
f0101b68:	89 c2                	mov    %eax,%edx
f0101b6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b6d:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101b73:	c1 f8 03             	sar    $0x3,%eax
f0101b76:	c1 e0 0c             	shl    $0xc,%eax
f0101b79:	39 c2                	cmp    %eax,%edx
f0101b7b:	0f 85 81 08 00 00    	jne    f0102402 <mem_init+0x1078>
	assert(pp2->pp_ref == 1);
f0101b81:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b84:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b89:	0f 85 95 08 00 00    	jne    f0102424 <mem_init+0x109a>

	// should be no free memory
	assert(!page_alloc(0));
f0101b8f:	83 ec 0c             	sub    $0xc,%esp
f0101b92:	6a 00                	push   $0x0
f0101b94:	e8 46 f4 ff ff       	call   f0100fdf <page_alloc>
f0101b99:	83 c4 10             	add    $0x10,%esp
f0101b9c:	85 c0                	test   %eax,%eax
f0101b9e:	0f 85 a2 08 00 00    	jne    f0102446 <mem_init+0x10bc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ba4:	6a 02                	push   $0x2
f0101ba6:	68 00 10 00 00       	push   $0x1000
f0101bab:	ff 75 d0             	push   -0x30(%ebp)
f0101bae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bb1:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101bb7:	e8 5c f7 ff ff       	call   f0101318 <page_insert>
f0101bbc:	83 c4 10             	add    $0x10,%esp
f0101bbf:	85 c0                	test   %eax,%eax
f0101bc1:	0f 85 a1 08 00 00    	jne    f0102468 <mem_init+0x10de>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bc7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bcc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bcf:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101bd5:	e8 7a ef ff ff       	call   f0100b54 <check_va2pa>
f0101bda:	89 c2                	mov    %eax,%edx
f0101bdc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bdf:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101be5:	c1 f8 03             	sar    $0x3,%eax
f0101be8:	c1 e0 0c             	shl    $0xc,%eax
f0101beb:	39 c2                	cmp    %eax,%edx
f0101bed:	0f 85 97 08 00 00    	jne    f010248a <mem_init+0x1100>
	assert(pp2->pp_ref == 1);
f0101bf3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bf6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bfb:	0f 85 ab 08 00 00    	jne    f01024ac <mem_init+0x1122>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c01:	83 ec 0c             	sub    $0xc,%esp
f0101c04:	6a 00                	push   $0x0
f0101c06:	e8 d4 f3 ff ff       	call   f0100fdf <page_alloc>
f0101c0b:	83 c4 10             	add    $0x10,%esp
f0101c0e:	85 c0                	test   %eax,%eax
f0101c10:	0f 85 b8 08 00 00    	jne    f01024ce <mem_init+0x1144>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c16:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c19:	8b 91 d4 1a 00 00    	mov    0x1ad4(%ecx),%edx
f0101c1f:	8b 02                	mov    (%edx),%eax
f0101c21:	89 c3                	mov    %eax,%ebx
f0101c23:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101c29:	c1 e8 0c             	shr    $0xc,%eax
f0101c2c:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101c32:	0f 83 b8 08 00 00    	jae    f01024f0 <mem_init+0x1166>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c38:	83 ec 04             	sub    $0x4,%esp
f0101c3b:	6a 00                	push   $0x0
f0101c3d:	68 00 10 00 00       	push   $0x1000
f0101c42:	52                   	push   %edx
f0101c43:	e8 b7 f4 ff ff       	call   f01010ff <pgdir_walk>
f0101c48:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	39 d8                	cmp    %ebx,%eax
f0101c53:	0f 85 b2 08 00 00    	jne    f010250b <mem_init+0x1181>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c59:	6a 06                	push   $0x6
f0101c5b:	68 00 10 00 00       	push   $0x1000
f0101c60:	ff 75 d0             	push   -0x30(%ebp)
f0101c63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c66:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c6c:	e8 a7 f6 ff ff       	call   f0101318 <page_insert>
f0101c71:	83 c4 10             	add    $0x10,%esp
f0101c74:	85 c0                	test   %eax,%eax
f0101c76:	0f 85 b1 08 00 00    	jne    f010252d <mem_init+0x11a3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c7c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101c7f:	8b 9e d4 1a 00 00    	mov    0x1ad4(%esi),%ebx
f0101c85:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c8a:	89 d8                	mov    %ebx,%eax
f0101c8c:	e8 c3 ee ff ff       	call   f0100b54 <check_va2pa>
f0101c91:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0101c93:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c96:	2b 86 d0 1a 00 00    	sub    0x1ad0(%esi),%eax
f0101c9c:	c1 f8 03             	sar    $0x3,%eax
f0101c9f:	c1 e0 0c             	shl    $0xc,%eax
f0101ca2:	39 c2                	cmp    %eax,%edx
f0101ca4:	0f 85 a5 08 00 00    	jne    f010254f <mem_init+0x11c5>
	assert(pp2->pp_ref == 1);
f0101caa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cad:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cb2:	0f 85 b9 08 00 00    	jne    f0102571 <mem_init+0x11e7>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cb8:	83 ec 04             	sub    $0x4,%esp
f0101cbb:	6a 00                	push   $0x0
f0101cbd:	68 00 10 00 00       	push   $0x1000
f0101cc2:	53                   	push   %ebx
f0101cc3:	e8 37 f4 ff ff       	call   f01010ff <pgdir_walk>
f0101cc8:	83 c4 10             	add    $0x10,%esp
f0101ccb:	f6 00 04             	testb  $0x4,(%eax)
f0101cce:	0f 84 bf 08 00 00    	je     f0102593 <mem_init+0x1209>
	assert(kern_pgdir[0] & PTE_U);
f0101cd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd7:	8b 80 d4 1a 00 00    	mov    0x1ad4(%eax),%eax
f0101cdd:	f6 00 04             	testb  $0x4,(%eax)
f0101ce0:	0f 84 cf 08 00 00    	je     f01025b5 <mem_init+0x122b>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ce6:	6a 02                	push   $0x2
f0101ce8:	68 00 10 00 00       	push   $0x1000
f0101ced:	ff 75 d0             	push   -0x30(%ebp)
f0101cf0:	50                   	push   %eax
f0101cf1:	e8 22 f6 ff ff       	call   f0101318 <page_insert>
f0101cf6:	83 c4 10             	add    $0x10,%esp
f0101cf9:	85 c0                	test   %eax,%eax
f0101cfb:	0f 85 d6 08 00 00    	jne    f01025d7 <mem_init+0x124d>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d01:	83 ec 04             	sub    $0x4,%esp
f0101d04:	6a 00                	push   $0x0
f0101d06:	68 00 10 00 00       	push   $0x1000
f0101d0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d0e:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101d14:	e8 e6 f3 ff ff       	call   f01010ff <pgdir_walk>
f0101d19:	83 c4 10             	add    $0x10,%esp
f0101d1c:	f6 00 02             	testb  $0x2,(%eax)
f0101d1f:	0f 84 d4 08 00 00    	je     f01025f9 <mem_init+0x126f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d25:	83 ec 04             	sub    $0x4,%esp
f0101d28:	6a 00                	push   $0x0
f0101d2a:	68 00 10 00 00       	push   $0x1000
f0101d2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d32:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101d38:	e8 c2 f3 ff ff       	call   f01010ff <pgdir_walk>
f0101d3d:	83 c4 10             	add    $0x10,%esp
f0101d40:	f6 00 04             	testb  $0x4,(%eax)
f0101d43:	0f 85 d2 08 00 00    	jne    f010261b <mem_init+0x1291>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d49:	6a 02                	push   $0x2
f0101d4b:	68 00 00 40 00       	push   $0x400000
f0101d50:	ff 75 cc             	push   -0x34(%ebp)
f0101d53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d56:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101d5c:	e8 b7 f5 ff ff       	call   f0101318 <page_insert>
f0101d61:	83 c4 10             	add    $0x10,%esp
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	0f 89 d1 08 00 00    	jns    f010263d <mem_init+0x12b3>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d6c:	6a 02                	push   $0x2
f0101d6e:	68 00 10 00 00       	push   $0x1000
f0101d73:	57                   	push   %edi
f0101d74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d77:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101d7d:	e8 96 f5 ff ff       	call   f0101318 <page_insert>
f0101d82:	83 c4 10             	add    $0x10,%esp
f0101d85:	85 c0                	test   %eax,%eax
f0101d87:	0f 85 d2 08 00 00    	jne    f010265f <mem_init+0x12d5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d8d:	83 ec 04             	sub    $0x4,%esp
f0101d90:	6a 00                	push   $0x0
f0101d92:	68 00 10 00 00       	push   $0x1000
f0101d97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d9a:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101da0:	e8 5a f3 ff ff       	call   f01010ff <pgdir_walk>
f0101da5:	83 c4 10             	add    $0x10,%esp
f0101da8:	f6 00 04             	testb  $0x4,(%eax)
f0101dab:	0f 85 d0 08 00 00    	jne    f0102681 <mem_init+0x12f7>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101db1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101db4:	8b b3 d4 1a 00 00    	mov    0x1ad4(%ebx),%esi
f0101dba:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dbf:	89 f0                	mov    %esi,%eax
f0101dc1:	e8 8e ed ff ff       	call   f0100b54 <check_va2pa>
f0101dc6:	89 d9                	mov    %ebx,%ecx
f0101dc8:	89 fb                	mov    %edi,%ebx
f0101dca:	2b 99 d0 1a 00 00    	sub    0x1ad0(%ecx),%ebx
f0101dd0:	c1 fb 03             	sar    $0x3,%ebx
f0101dd3:	c1 e3 0c             	shl    $0xc,%ebx
f0101dd6:	39 d8                	cmp    %ebx,%eax
f0101dd8:	0f 85 c5 08 00 00    	jne    f01026a3 <mem_init+0x1319>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dde:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de3:	89 f0                	mov    %esi,%eax
f0101de5:	e8 6a ed ff ff       	call   f0100b54 <check_va2pa>
f0101dea:	39 c3                	cmp    %eax,%ebx
f0101dec:	0f 85 d3 08 00 00    	jne    f01026c5 <mem_init+0x133b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101df2:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101df7:	0f 85 ea 08 00 00    	jne    f01026e7 <mem_init+0x135d>
	assert(pp2->pp_ref == 0);
f0101dfd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e00:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e05:	0f 85 fe 08 00 00    	jne    f0102709 <mem_init+0x137f>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e0b:	83 ec 0c             	sub    $0xc,%esp
f0101e0e:	6a 00                	push   $0x0
f0101e10:	e8 ca f1 ff ff       	call   f0100fdf <page_alloc>
f0101e15:	83 c4 10             	add    $0x10,%esp
f0101e18:	85 c0                	test   %eax,%eax
f0101e1a:	0f 84 0b 09 00 00    	je     f010272b <mem_init+0x13a1>
f0101e20:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e23:	0f 85 02 09 00 00    	jne    f010272b <mem_init+0x13a1>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e29:	83 ec 08             	sub    $0x8,%esp
f0101e2c:	6a 00                	push   $0x0
f0101e2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e31:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101e37:	e8 a1 f4 ff ff       	call   f01012dd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e3c:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101e42:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e47:	89 d8                	mov    %ebx,%eax
f0101e49:	e8 06 ed ff ff       	call   f0100b54 <check_va2pa>
f0101e4e:	83 c4 10             	add    $0x10,%esp
f0101e51:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e54:	0f 85 f3 08 00 00    	jne    f010274d <mem_init+0x13c3>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e5a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e5f:	89 d8                	mov    %ebx,%eax
f0101e61:	e8 ee ec ff ff       	call   f0100b54 <check_va2pa>
f0101e66:	89 c2                	mov    %eax,%edx
f0101e68:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e6b:	89 f8                	mov    %edi,%eax
f0101e6d:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101e73:	c1 f8 03             	sar    $0x3,%eax
f0101e76:	c1 e0 0c             	shl    $0xc,%eax
f0101e79:	39 c2                	cmp    %eax,%edx
f0101e7b:	0f 85 ee 08 00 00    	jne    f010276f <mem_init+0x13e5>
	assert(pp1->pp_ref == 1);
f0101e81:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e86:	0f 85 04 09 00 00    	jne    f0102790 <mem_init+0x1406>
	assert(pp2->pp_ref == 0);
f0101e8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e8f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e94:	0f 85 18 09 00 00    	jne    f01027b2 <mem_init+0x1428>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e9a:	6a 00                	push   $0x0
f0101e9c:	68 00 10 00 00       	push   $0x1000
f0101ea1:	57                   	push   %edi
f0101ea2:	53                   	push   %ebx
f0101ea3:	e8 70 f4 ff ff       	call   f0101318 <page_insert>
f0101ea8:	83 c4 10             	add    $0x10,%esp
f0101eab:	85 c0                	test   %eax,%eax
f0101ead:	0f 85 21 09 00 00    	jne    f01027d4 <mem_init+0x144a>
	assert(pp1->pp_ref);
f0101eb3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101eb8:	0f 84 38 09 00 00    	je     f01027f6 <mem_init+0x146c>
	assert(pp1->pp_link == NULL);
f0101ebe:	83 3f 00             	cmpl   $0x0,(%edi)
f0101ec1:	0f 85 51 09 00 00    	jne    f0102818 <mem_init+0x148e>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ec7:	83 ec 08             	sub    $0x8,%esp
f0101eca:	68 00 10 00 00       	push   $0x1000
f0101ecf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ed2:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101ed8:	e8 00 f4 ff ff       	call   f01012dd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101edd:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101ee3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ee8:	89 d8                	mov    %ebx,%eax
f0101eea:	e8 65 ec ff ff       	call   f0100b54 <check_va2pa>
f0101eef:	83 c4 10             	add    $0x10,%esp
f0101ef2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef5:	0f 85 3f 09 00 00    	jne    f010283a <mem_init+0x14b0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101efb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f00:	89 d8                	mov    %ebx,%eax
f0101f02:	e8 4d ec ff ff       	call   f0100b54 <check_va2pa>
f0101f07:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f0a:	0f 85 4c 09 00 00    	jne    f010285c <mem_init+0x14d2>
	assert(pp1->pp_ref == 0);
f0101f10:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f15:	0f 85 63 09 00 00    	jne    f010287e <mem_init+0x14f4>
	assert(pp2->pp_ref == 0);
f0101f1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f1e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f23:	0f 85 77 09 00 00    	jne    f01028a0 <mem_init+0x1516>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f29:	83 ec 0c             	sub    $0xc,%esp
f0101f2c:	6a 00                	push   $0x0
f0101f2e:	e8 ac f0 ff ff       	call   f0100fdf <page_alloc>
f0101f33:	83 c4 10             	add    $0x10,%esp
f0101f36:	39 c7                	cmp    %eax,%edi
f0101f38:	0f 85 84 09 00 00    	jne    f01028c2 <mem_init+0x1538>
f0101f3e:	85 c0                	test   %eax,%eax
f0101f40:	0f 84 7c 09 00 00    	je     f01028c2 <mem_init+0x1538>

	// should be no free memory
	assert(!page_alloc(0));
f0101f46:	83 ec 0c             	sub    $0xc,%esp
f0101f49:	6a 00                	push   $0x0
f0101f4b:	e8 8f f0 ff ff       	call   f0100fdf <page_alloc>
f0101f50:	83 c4 10             	add    $0x10,%esp
f0101f53:	85 c0                	test   %eax,%eax
f0101f55:	0f 85 89 09 00 00    	jne    f01028e4 <mem_init+0x155a>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f5e:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0101f64:	8b 11                	mov    (%ecx),%edx
f0101f66:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f6c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101f6f:	2b 98 d0 1a 00 00    	sub    0x1ad0(%eax),%ebx
f0101f75:	89 d8                	mov    %ebx,%eax
f0101f77:	c1 f8 03             	sar    $0x3,%eax
f0101f7a:	c1 e0 0c             	shl    $0xc,%eax
f0101f7d:	39 c2                	cmp    %eax,%edx
f0101f7f:	0f 85 81 09 00 00    	jne    f0102906 <mem_init+0x157c>
	kern_pgdir[0] = 0;
f0101f85:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f8b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f8e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f93:	0f 85 8f 09 00 00    	jne    f0102928 <mem_init+0x159e>
	pp0->pp_ref = 0;
f0101f99:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f9c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101fa2:	83 ec 0c             	sub    $0xc,%esp
f0101fa5:	50                   	push   %eax
f0101fa6:	e8 b9 f0 ff ff       	call   f0101064 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101fab:	83 c4 0c             	add    $0xc,%esp
f0101fae:	6a 01                	push   $0x1
f0101fb0:	68 00 10 40 00       	push   $0x401000
f0101fb5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fb8:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101fbe:	e8 3c f1 ff ff       	call   f01010ff <pgdir_walk>
f0101fc3:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101fc5:	89 d9                	mov    %ebx,%ecx
f0101fc7:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101fcd:	8b 43 04             	mov    0x4(%ebx),%eax
f0101fd0:	89 c2                	mov    %eax,%edx
f0101fd2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101fd8:	8b 89 d8 1a 00 00    	mov    0x1ad8(%ecx),%ecx
f0101fde:	c1 e8 0c             	shr    $0xc,%eax
f0101fe1:	83 c4 10             	add    $0x10,%esp
f0101fe4:	39 c8                	cmp    %ecx,%eax
f0101fe6:	0f 83 5e 09 00 00    	jae    f010294a <mem_init+0x15c0>
	assert(ptep == ptep1 + PTX(va));
f0101fec:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101ff2:	39 d6                	cmp    %edx,%esi
f0101ff4:	0f 85 6c 09 00 00    	jne    f0102966 <mem_init+0x15dc>
	kern_pgdir[PDX(va)] = 0;
f0101ffa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102001:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102004:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f010200a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010200d:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0102013:	c1 f8 03             	sar    $0x3,%eax
f0102016:	89 c2                	mov    %eax,%edx
f0102018:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010201b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102020:	39 c1                	cmp    %eax,%ecx
f0102022:	0f 86 60 09 00 00    	jbe    f0102988 <mem_init+0x15fe>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102028:	83 ec 04             	sub    $0x4,%esp
f010202b:	68 00 10 00 00       	push   $0x1000
f0102030:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102035:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010203b:	52                   	push   %edx
f010203c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010203f:	e8 61 26 00 00       	call   f01046a5 <memset>
	page_free(pp0);
f0102044:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102047:	89 34 24             	mov    %esi,(%esp)
f010204a:	e8 15 f0 ff ff       	call   f0101064 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010204f:	83 c4 0c             	add    $0xc,%esp
f0102052:	6a 01                	push   $0x1
f0102054:	6a 00                	push   $0x0
f0102056:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f010205c:	e8 9e f0 ff ff       	call   f01010ff <pgdir_walk>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102061:	89 f0                	mov    %esi,%eax
f0102063:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0102069:	c1 f8 03             	sar    $0x3,%eax
f010206c:	89 c2                	mov    %eax,%edx
f010206e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102071:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102076:	83 c4 10             	add    $0x10,%esp
f0102079:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f010207f:	0f 83 19 09 00 00    	jae    f010299e <mem_init+0x1614>
	return (void *)(pa + KERNBASE);
f0102085:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010208b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102091:	8b 30                	mov    (%eax),%esi
f0102093:	83 e6 01             	and    $0x1,%esi
f0102096:	0f 85 1b 09 00 00    	jne    f01029b7 <mem_init+0x162d>
	for(i=0; i<NPTENTRIES; i++)
f010209c:	83 c0 04             	add    $0x4,%eax
f010209f:	39 c2                	cmp    %eax,%edx
f01020a1:	75 ee                	jne    f0102091 <mem_init+0xd07>
	kern_pgdir[0] = 0;
f01020a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020a6:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f01020ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01020b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020b5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01020bb:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01020be:	89 93 e0 1a 00 00    	mov    %edx,0x1ae0(%ebx)

	// free the pages we took
	page_free(pp0);
f01020c4:	83 ec 0c             	sub    $0xc,%esp
f01020c7:	50                   	push   %eax
f01020c8:	e8 97 ef ff ff       	call   f0101064 <page_free>
	page_free(pp1);
f01020cd:	89 3c 24             	mov    %edi,(%esp)
f01020d0:	e8 8f ef ff ff       	call   f0101064 <page_free>
	page_free(pp2);
f01020d5:	83 c4 04             	add    $0x4,%esp
f01020d8:	ff 75 d0             	push   -0x30(%ebp)
f01020db:	e8 84 ef ff ff       	call   f0101064 <page_free>

	cprintf("check_page() succeeded!\n");
f01020e0:	8d 83 ea 69 f8 ff    	lea    -0x79616(%ebx),%eax
f01020e6:	89 04 24             	mov    %eax,(%esp)
f01020e9:	e8 39 15 00 00       	call   f0103627 <cprintf>
	boot_map_region(kern_pgdir, UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE) , PADDR(pages), PTE_U | PTE_P);
f01020ee:	8b 83 d0 1a 00 00    	mov    0x1ad0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01020f4:	83 c4 10             	add    $0x10,%esp
f01020f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020fc:	0f 86 d7 08 00 00    	jbe    f01029d9 <mem_init+0x164f>
f0102102:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102105:	8b 97 d8 1a 00 00    	mov    0x1ad8(%edi),%edx
f010210b:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102112:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102118:	83 ec 08             	sub    $0x8,%esp
f010211b:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010211d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102122:	50                   	push   %eax
f0102123:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102128:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f010212e:	e8 bd f0 ff ff       	call   f01011f0 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102133:	c7 c0 00 20 11 f0    	mov    $0xf0112000,%eax
f0102139:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010213c:	83 c4 10             	add    $0x10,%esp
f010213f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102144:	0f 86 ab 08 00 00    	jbe    f01029f5 <mem_init+0x166b>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010214a:	83 ec 08             	sub    $0x8,%esp
f010214d:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f010214f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102152:	05 00 00 00 10       	add    $0x10000000,%eax
f0102157:	50                   	push   %eax
f0102158:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010215d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102162:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102165:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f010216b:	e8 80 f0 ff ff       	call   f01011f0 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE , 0, PTE_W);
f0102170:	83 c4 08             	add    $0x8,%esp
f0102173:	6a 02                	push   $0x2
f0102175:	6a 00                	push   $0x0
f0102177:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010217c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102181:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f0102187:	e8 64 f0 ff ff       	call   f01011f0 <boot_map_region>
	pgdir = kern_pgdir;
f010218c:	89 f9                	mov    %edi,%ecx
f010218e:	8b bf d4 1a 00 00    	mov    0x1ad4(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102194:	8b 81 d8 1a 00 00    	mov    0x1ad8(%ecx),%eax
f010219a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010219d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021a9:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021ab:	8b 81 d0 1a 00 00    	mov    0x1ad0(%ecx),%eax
f01021b1:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01021b4:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01021ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01021bd:	83 c4 10             	add    $0x10,%esp
f01021c0:	89 f3                	mov    %esi,%ebx
f01021c2:	89 75 c0             	mov    %esi,-0x40(%ebp)
f01021c5:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021c8:	89 d6                	mov    %edx,%esi
f01021ca:	89 c7                	mov    %eax,%edi
f01021cc:	39 de                	cmp    %ebx,%esi
f01021ce:	0f 86 82 08 00 00    	jbe    f0102a56 <mem_init+0x16cc>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021d4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021da:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021dd:	e8 72 e9 ff ff       	call   f0100b54 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021e2:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01021e8:	0f 86 28 08 00 00    	jbe    f0102a16 <mem_init+0x168c>
f01021ee:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01021f1:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01021f4:	39 c2                	cmp    %eax,%edx
f01021f6:	0f 85 38 08 00 00    	jne    f0102a34 <mem_init+0x16aa>
	for (i = 0; i < n; i += PGSIZE)
f01021fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102202:	eb c8                	jmp    f01021cc <mem_init+0xe42>
	assert(nfree == 0);
f0102204:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102207:	8d 83 13 69 f8 ff    	lea    -0x796ed(%ebx),%eax
f010220d:	50                   	push   %eax
f010220e:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102214:	50                   	push   %eax
f0102215:	68 f0 02 00 00       	push   $0x2f0
f010221a:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102220:	50                   	push   %eax
f0102221:	e8 8b de ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102226:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102229:	8d 83 21 68 f8 ff    	lea    -0x797df(%ebx),%eax
f010222f:	50                   	push   %eax
f0102230:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102236:	50                   	push   %eax
f0102237:	68 4e 03 00 00       	push   $0x34e
f010223c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102242:	50                   	push   %eax
f0102243:	e8 69 de ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102248:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010224b:	8d 83 37 68 f8 ff    	lea    -0x797c9(%ebx),%eax
f0102251:	50                   	push   %eax
f0102252:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102258:	50                   	push   %eax
f0102259:	68 4f 03 00 00       	push   $0x34f
f010225e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102264:	50                   	push   %eax
f0102265:	e8 47 de ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010226a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010226d:	8d 83 4d 68 f8 ff    	lea    -0x797b3(%ebx),%eax
f0102273:	50                   	push   %eax
f0102274:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010227a:	50                   	push   %eax
f010227b:	68 50 03 00 00       	push   $0x350
f0102280:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102286:	50                   	push   %eax
f0102287:	e8 25 de ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010228c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010228f:	8d 83 63 68 f8 ff    	lea    -0x7979d(%ebx),%eax
f0102295:	50                   	push   %eax
f0102296:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010229c:	50                   	push   %eax
f010229d:	68 53 03 00 00       	push   $0x353
f01022a2:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01022a8:	50                   	push   %eax
f01022a9:	e8 03 de ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022ae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022b1:	8d 83 e4 6b f8 ff    	lea    -0x7941c(%ebx),%eax
f01022b7:	50                   	push   %eax
f01022b8:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01022be:	50                   	push   %eax
f01022bf:	68 54 03 00 00       	push   $0x354
f01022c4:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	e8 e1 dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01022d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022d3:	8d 83 cc 68 f8 ff    	lea    -0x79734(%ebx),%eax
f01022d9:	50                   	push   %eax
f01022da:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01022e0:	50                   	push   %eax
f01022e1:	68 5b 03 00 00       	push   $0x35b
f01022e6:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01022ec:	50                   	push   %eax
f01022ed:	e8 bf dd ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022f5:	8d 83 24 6c f8 ff    	lea    -0x793dc(%ebx),%eax
f01022fb:	50                   	push   %eax
f01022fc:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102302:	50                   	push   %eax
f0102303:	68 5e 03 00 00       	push   $0x35e
f0102308:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	e8 9d dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102314:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102317:	8d 83 5c 6c f8 ff    	lea    -0x793a4(%ebx),%eax
f010231d:	50                   	push   %eax
f010231e:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102324:	50                   	push   %eax
f0102325:	68 61 03 00 00       	push   $0x361
f010232a:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102330:	50                   	push   %eax
f0102331:	e8 7b dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102336:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102339:	8d 83 8c 6c f8 ff    	lea    -0x79374(%ebx),%eax
f010233f:	50                   	push   %eax
f0102340:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102346:	50                   	push   %eax
f0102347:	68 65 03 00 00       	push   $0x365
f010234c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	e8 59 dd ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102358:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010235b:	8d 83 bc 6c f8 ff    	lea    -0x79344(%ebx),%eax
f0102361:	50                   	push   %eax
f0102362:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102368:	50                   	push   %eax
f0102369:	68 66 03 00 00       	push   $0x366
f010236e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102374:	50                   	push   %eax
f0102375:	e8 37 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010237a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010237d:	8d 83 e4 6c f8 ff    	lea    -0x7931c(%ebx),%eax
f0102383:	50                   	push   %eax
f0102384:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010238a:	50                   	push   %eax
f010238b:	68 67 03 00 00       	push   $0x367
f0102390:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	e8 15 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010239c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010239f:	8d 83 1e 69 f8 ff    	lea    -0x796e2(%ebx),%eax
f01023a5:	50                   	push   %eax
f01023a6:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01023ac:	50                   	push   %eax
f01023ad:	68 68 03 00 00       	push   $0x368
f01023b2:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	e8 f3 dc ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01023be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023c1:	8d 83 2f 69 f8 ff    	lea    -0x796d1(%ebx),%eax
f01023c7:	50                   	push   %eax
f01023c8:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01023ce:	50                   	push   %eax
f01023cf:	68 69 03 00 00       	push   $0x369
f01023d4:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	e8 d1 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023e3:	8d 83 14 6d f8 ff    	lea    -0x792ec(%ebx),%eax
f01023e9:	50                   	push   %eax
f01023ea:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01023f0:	50                   	push   %eax
f01023f1:	68 6c 03 00 00       	push   $0x36c
f01023f6:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01023fc:	50                   	push   %eax
f01023fd:	e8 af dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102402:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102405:	8d 83 50 6d f8 ff    	lea    -0x792b0(%ebx),%eax
f010240b:	50                   	push   %eax
f010240c:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102412:	50                   	push   %eax
f0102413:	68 6d 03 00 00       	push   $0x36d
f0102418:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	e8 8d dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102424:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102427:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f010242d:	50                   	push   %eax
f010242e:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102434:	50                   	push   %eax
f0102435:	68 6e 03 00 00       	push   $0x36e
f010243a:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102440:	50                   	push   %eax
f0102441:	e8 6b dc ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102446:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102449:	8d 83 cc 68 f8 ff    	lea    -0x79734(%ebx),%eax
f010244f:	50                   	push   %eax
f0102450:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102456:	50                   	push   %eax
f0102457:	68 71 03 00 00       	push   $0x371
f010245c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102462:	50                   	push   %eax
f0102463:	e8 49 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102468:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010246b:	8d 83 14 6d f8 ff    	lea    -0x792ec(%ebx),%eax
f0102471:	50                   	push   %eax
f0102472:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102478:	50                   	push   %eax
f0102479:	68 74 03 00 00       	push   $0x374
f010247e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102484:	50                   	push   %eax
f0102485:	e8 27 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010248a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010248d:	8d 83 50 6d f8 ff    	lea    -0x792b0(%ebx),%eax
f0102493:	50                   	push   %eax
f0102494:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010249a:	50                   	push   %eax
f010249b:	68 75 03 00 00       	push   $0x375
f01024a0:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01024a6:	50                   	push   %eax
f01024a7:	e8 05 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024ac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024af:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f01024b5:	50                   	push   %eax
f01024b6:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01024bc:	50                   	push   %eax
f01024bd:	68 76 03 00 00       	push   $0x376
f01024c2:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01024c8:	50                   	push   %eax
f01024c9:	e8 e3 db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01024ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d1:	8d 83 cc 68 f8 ff    	lea    -0x79734(%ebx),%eax
f01024d7:	50                   	push   %eax
f01024d8:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01024de:	50                   	push   %eax
f01024df:	68 7a 03 00 00       	push   $0x37a
f01024e4:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01024ea:	50                   	push   %eax
f01024eb:	e8 c1 db ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024f0:	53                   	push   %ebx
f01024f1:	89 cb                	mov    %ecx,%ebx
f01024f3:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f01024f9:	50                   	push   %eax
f01024fa:	68 7d 03 00 00       	push   $0x37d
f01024ff:	8d 81 2c 67 f8 ff    	lea    -0x798d4(%ecx),%eax
f0102505:	50                   	push   %eax
f0102506:	e8 a6 db ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010250b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010250e:	8d 83 80 6d f8 ff    	lea    -0x79280(%ebx),%eax
f0102514:	50                   	push   %eax
f0102515:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010251b:	50                   	push   %eax
f010251c:	68 7e 03 00 00       	push   $0x37e
f0102521:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102527:	50                   	push   %eax
f0102528:	e8 84 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010252d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102530:	8d 83 c0 6d f8 ff    	lea    -0x79240(%ebx),%eax
f0102536:	50                   	push   %eax
f0102537:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010253d:	50                   	push   %eax
f010253e:	68 81 03 00 00       	push   $0x381
f0102543:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102549:	50                   	push   %eax
f010254a:	e8 62 db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010254f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102552:	8d 83 50 6d f8 ff    	lea    -0x792b0(%ebx),%eax
f0102558:	50                   	push   %eax
f0102559:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010255f:	50                   	push   %eax
f0102560:	68 82 03 00 00       	push   $0x382
f0102565:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010256b:	50                   	push   %eax
f010256c:	e8 40 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102571:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102574:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f010257a:	50                   	push   %eax
f010257b:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102581:	50                   	push   %eax
f0102582:	68 83 03 00 00       	push   $0x383
f0102587:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	e8 1e db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102593:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102596:	8d 83 00 6e f8 ff    	lea    -0x79200(%ebx),%eax
f010259c:	50                   	push   %eax
f010259d:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01025a3:	50                   	push   %eax
f01025a4:	68 84 03 00 00       	push   $0x384
f01025a9:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01025af:	50                   	push   %eax
f01025b0:	e8 fc da ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025b8:	8d 83 51 69 f8 ff    	lea    -0x796af(%ebx),%eax
f01025be:	50                   	push   %eax
f01025bf:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01025c5:	50                   	push   %eax
f01025c6:	68 85 03 00 00       	push   $0x385
f01025cb:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	e8 da da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025da:	8d 83 14 6d f8 ff    	lea    -0x792ec(%ebx),%eax
f01025e0:	50                   	push   %eax
f01025e1:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01025e7:	50                   	push   %eax
f01025e8:	68 88 03 00 00       	push   $0x388
f01025ed:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01025f3:	50                   	push   %eax
f01025f4:	e8 b8 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025fc:	8d 83 34 6e f8 ff    	lea    -0x791cc(%ebx),%eax
f0102602:	50                   	push   %eax
f0102603:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102609:	50                   	push   %eax
f010260a:	68 89 03 00 00       	push   $0x389
f010260f:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	e8 96 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010261b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010261e:	8d 83 68 6e f8 ff    	lea    -0x79198(%ebx),%eax
f0102624:	50                   	push   %eax
f0102625:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010262b:	50                   	push   %eax
f010262c:	68 8a 03 00 00       	push   $0x38a
f0102631:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102637:	50                   	push   %eax
f0102638:	e8 74 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010263d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102640:	8d 83 a0 6e f8 ff    	lea    -0x79160(%ebx),%eax
f0102646:	50                   	push   %eax
f0102647:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010264d:	50                   	push   %eax
f010264e:	68 8d 03 00 00       	push   $0x38d
f0102653:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	e8 52 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010265f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102662:	8d 83 d8 6e f8 ff    	lea    -0x79128(%ebx),%eax
f0102668:	50                   	push   %eax
f0102669:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010266f:	50                   	push   %eax
f0102670:	68 90 03 00 00       	push   $0x390
f0102675:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	e8 30 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102681:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102684:	8d 83 68 6e f8 ff    	lea    -0x79198(%ebx),%eax
f010268a:	50                   	push   %eax
f010268b:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102691:	50                   	push   %eax
f0102692:	68 91 03 00 00       	push   $0x391
f0102697:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	e8 0e da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026a6:	8d 83 14 6f f8 ff    	lea    -0x790ec(%ebx),%eax
f01026ac:	50                   	push   %eax
f01026ad:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01026b3:	50                   	push   %eax
f01026b4:	68 94 03 00 00       	push   $0x394
f01026b9:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01026bf:	50                   	push   %eax
f01026c0:	e8 ec d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c8:	8d 83 40 6f f8 ff    	lea    -0x790c0(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01026d5:	50                   	push   %eax
f01026d6:	68 95 03 00 00       	push   $0x395
f01026db:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01026e1:	50                   	push   %eax
f01026e2:	e8 ca d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f01026e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026ea:	8d 83 67 69 f8 ff    	lea    -0x79699(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01026f7:	50                   	push   %eax
f01026f8:	68 97 03 00 00       	push   $0x397
f01026fd:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102703:	50                   	push   %eax
f0102704:	e8 a8 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102709:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010270c:	8d 83 78 69 f8 ff    	lea    -0x79688(%ebx),%eax
f0102712:	50                   	push   %eax
f0102713:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102719:	50                   	push   %eax
f010271a:	68 98 03 00 00       	push   $0x398
f010271f:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102725:	50                   	push   %eax
f0102726:	e8 86 d9 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010272b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010272e:	8d 83 70 6f f8 ff    	lea    -0x79090(%ebx),%eax
f0102734:	50                   	push   %eax
f0102735:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010273b:	50                   	push   %eax
f010273c:	68 9b 03 00 00       	push   $0x39b
f0102741:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102747:	50                   	push   %eax
f0102748:	e8 64 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010274d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102750:	8d 83 94 6f f8 ff    	lea    -0x7906c(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010275d:	50                   	push   %eax
f010275e:	68 9f 03 00 00       	push   $0x39f
f0102763:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102769:	50                   	push   %eax
f010276a:	e8 42 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010276f:	89 cb                	mov    %ecx,%ebx
f0102771:	8d 81 40 6f f8 ff    	lea    -0x790c0(%ecx),%eax
f0102777:	50                   	push   %eax
f0102778:	8d 81 52 67 f8 ff    	lea    -0x798ae(%ecx),%eax
f010277e:	50                   	push   %eax
f010277f:	68 a0 03 00 00       	push   $0x3a0
f0102784:	8d 81 2c 67 f8 ff    	lea    -0x798d4(%ecx),%eax
f010278a:	50                   	push   %eax
f010278b:	e8 21 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102790:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102793:	8d 83 1e 69 f8 ff    	lea    -0x796e2(%ebx),%eax
f0102799:	50                   	push   %eax
f010279a:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01027a0:	50                   	push   %eax
f01027a1:	68 a1 03 00 00       	push   $0x3a1
f01027a6:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01027ac:	50                   	push   %eax
f01027ad:	e8 ff d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01027b2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b5:	8d 83 78 69 f8 ff    	lea    -0x79688(%ebx),%eax
f01027bb:	50                   	push   %eax
f01027bc:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01027c2:	50                   	push   %eax
f01027c3:	68 a2 03 00 00       	push   $0x3a2
f01027c8:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	e8 dd d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01027d4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d7:	8d 83 b8 6f f8 ff    	lea    -0x79048(%ebx),%eax
f01027dd:	50                   	push   %eax
f01027de:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01027e4:	50                   	push   %eax
f01027e5:	68 a5 03 00 00       	push   $0x3a5
f01027ea:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	e8 bb d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01027f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027f9:	8d 83 89 69 f8 ff    	lea    -0x79677(%ebx),%eax
f01027ff:	50                   	push   %eax
f0102800:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102806:	50                   	push   %eax
f0102807:	68 a6 03 00 00       	push   $0x3a6
f010280c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	e8 99 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102818:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010281b:	8d 83 95 69 f8 ff    	lea    -0x7966b(%ebx),%eax
f0102821:	50                   	push   %eax
f0102822:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102828:	50                   	push   %eax
f0102829:	68 a7 03 00 00       	push   $0x3a7
f010282e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102834:	50                   	push   %eax
f0102835:	e8 77 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010283a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010283d:	8d 83 94 6f f8 ff    	lea    -0x7906c(%ebx),%eax
f0102843:	50                   	push   %eax
f0102844:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010284a:	50                   	push   %eax
f010284b:	68 ab 03 00 00       	push   $0x3ab
f0102850:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102856:	50                   	push   %eax
f0102857:	e8 55 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010285c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010285f:	8d 83 f0 6f f8 ff    	lea    -0x79010(%ebx),%eax
f0102865:	50                   	push   %eax
f0102866:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010286c:	50                   	push   %eax
f010286d:	68 ac 03 00 00       	push   $0x3ac
f0102872:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	e8 33 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f010287e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102881:	8d 83 aa 69 f8 ff    	lea    -0x79656(%ebx),%eax
f0102887:	50                   	push   %eax
f0102888:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f010288e:	50                   	push   %eax
f010288f:	68 ad 03 00 00       	push   $0x3ad
f0102894:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010289a:	50                   	push   %eax
f010289b:	e8 11 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01028a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028a3:	8d 83 78 69 f8 ff    	lea    -0x79688(%ebx),%eax
f01028a9:	50                   	push   %eax
f01028aa:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01028b0:	50                   	push   %eax
f01028b1:	68 ae 03 00 00       	push   $0x3ae
f01028b6:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01028bc:	50                   	push   %eax
f01028bd:	e8 ef d7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01028c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028c5:	8d 83 18 70 f8 ff    	lea    -0x78fe8(%ebx),%eax
f01028cb:	50                   	push   %eax
f01028cc:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01028d2:	50                   	push   %eax
f01028d3:	68 b1 03 00 00       	push   $0x3b1
f01028d8:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01028de:	50                   	push   %eax
f01028df:	e8 cd d7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01028e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e7:	8d 83 cc 68 f8 ff    	lea    -0x79734(%ebx),%eax
f01028ed:	50                   	push   %eax
f01028ee:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01028f4:	50                   	push   %eax
f01028f5:	68 b4 03 00 00       	push   $0x3b4
f01028fa:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102900:	50                   	push   %eax
f0102901:	e8 ab d7 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102906:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102909:	8d 83 bc 6c f8 ff    	lea    -0x79344(%ebx),%eax
f010290f:	50                   	push   %eax
f0102910:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102916:	50                   	push   %eax
f0102917:	68 b7 03 00 00       	push   $0x3b7
f010291c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102922:	50                   	push   %eax
f0102923:	e8 89 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102928:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010292b:	8d 83 2f 69 f8 ff    	lea    -0x796d1(%ebx),%eax
f0102931:	50                   	push   %eax
f0102932:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102938:	50                   	push   %eax
f0102939:	68 b9 03 00 00       	push   $0x3b9
f010293e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102944:	50                   	push   %eax
f0102945:	e8 67 d7 ff ff       	call   f01000b1 <_panic>
f010294a:	52                   	push   %edx
f010294b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010294e:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	68 c0 03 00 00       	push   $0x3c0
f010295a:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102960:	50                   	push   %eax
f0102961:	e8 4b d7 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102966:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102969:	8d 83 bb 69 f8 ff    	lea    -0x79645(%ebx),%eax
f010296f:	50                   	push   %eax
f0102970:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102976:	50                   	push   %eax
f0102977:	68 c1 03 00 00       	push   $0x3c1
f010297c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102982:	50                   	push   %eax
f0102983:	e8 29 d7 ff ff       	call   f01000b1 <_panic>
f0102988:	52                   	push   %edx
f0102989:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f010298f:	50                   	push   %eax
f0102990:	6a 57                	push   $0x57
f0102992:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f0102998:	50                   	push   %eax
f0102999:	e8 13 d7 ff ff       	call   f01000b1 <_panic>
f010299e:	52                   	push   %edx
f010299f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a2:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f01029a8:	50                   	push   %eax
f01029a9:	6a 57                	push   $0x57
f01029ab:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f01029b1:	50                   	push   %eax
f01029b2:	e8 fa d6 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01029b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ba:	8d 83 d3 69 f8 ff    	lea    -0x7962d(%ebx),%eax
f01029c0:	50                   	push   %eax
f01029c1:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01029c7:	50                   	push   %eax
f01029c8:	68 cb 03 00 00       	push   $0x3cb
f01029cd:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01029d3:	50                   	push   %eax
f01029d4:	e8 d8 d6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029d9:	50                   	push   %eax
f01029da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029dd:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f01029e3:	50                   	push   %eax
f01029e4:	68 c3 00 00 00       	push   $0xc3
f01029e9:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01029ef:	50                   	push   %eax
f01029f0:	e8 bc d6 ff ff       	call   f01000b1 <_panic>
f01029f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029f8:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f01029fe:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f0102a04:	50                   	push   %eax
f0102a05:	68 d9 00 00 00       	push   $0xd9
f0102a0a:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102a10:	50                   	push   %eax
f0102a11:	e8 9b d6 ff ff       	call   f01000b1 <_panic>
f0102a16:	ff 75 bc             	push   -0x44(%ebp)
f0102a19:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a1c:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f0102a22:	50                   	push   %eax
f0102a23:	68 08 03 00 00       	push   $0x308
f0102a28:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102a2e:	50                   	push   %eax
f0102a2f:	e8 7d d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a34:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a37:	8d 83 3c 70 f8 ff    	lea    -0x78fc4(%ebx),%eax
f0102a3d:	50                   	push   %eax
f0102a3e:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102a44:	50                   	push   %eax
f0102a45:	68 08 03 00 00       	push   $0x308
f0102a4a:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102a50:	50                   	push   %eax
f0102a51:	e8 5b d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a56:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102a59:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102a5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a5f:	c7 c0 50 03 18 f0    	mov    $0xf0180350,%eax
f0102a65:	8b 00                	mov    (%eax),%eax
f0102a67:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102a6a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102a6f:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f0102a75:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102a78:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a7b:	89 c6                	mov    %eax,%esi
f0102a7d:	89 da                	mov    %ebx,%edx
f0102a7f:	89 f8                	mov    %edi,%eax
f0102a81:	e8 ce e0 ff ff       	call   f0100b54 <check_va2pa>
f0102a86:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a8c:	76 45                	jbe    f0102ad3 <mem_init+0x1749>
f0102a8e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a91:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a94:	39 c2                	cmp    %eax,%edx
f0102a96:	75 59                	jne    f0102af1 <mem_init+0x1767>
	for (i = 0; i < n; i += PGSIZE)
f0102a98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a9e:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f0102aa4:	75 d7                	jne    f0102a7d <mem_init+0x16f3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102aa6:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102aa9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102aac:	c1 e0 0c             	shl    $0xc,%eax
f0102aaf:	89 f3                	mov    %esi,%ebx
f0102ab1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102ab4:	89 c6                	mov    %eax,%esi
f0102ab6:	39 f3                	cmp    %esi,%ebx
f0102ab8:	73 7b                	jae    f0102b35 <mem_init+0x17ab>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aba:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102ac0:	89 f8                	mov    %edi,%eax
f0102ac2:	e8 8d e0 ff ff       	call   f0100b54 <check_va2pa>
f0102ac7:	39 c3                	cmp    %eax,%ebx
f0102ac9:	75 48                	jne    f0102b13 <mem_init+0x1789>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102acb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ad1:	eb e3                	jmp    f0102ab6 <mem_init+0x172c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ad3:	ff 75 c0             	push   -0x40(%ebp)
f0102ad6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ad9:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f0102adf:	50                   	push   %eax
f0102ae0:	68 0d 03 00 00       	push   $0x30d
f0102ae5:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102aeb:	50                   	push   %eax
f0102aec:	e8 c0 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102af1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af4:	8d 83 70 70 f8 ff    	lea    -0x78f90(%ebx),%eax
f0102afa:	50                   	push   %eax
f0102afb:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102b01:	50                   	push   %eax
f0102b02:	68 0d 03 00 00       	push   $0x30d
f0102b07:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102b0d:	50                   	push   %eax
f0102b0e:	e8 9e d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b16:	8d 83 a4 70 f8 ff    	lea    -0x78f5c(%ebx),%eax
f0102b1c:	50                   	push   %eax
f0102b1d:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102b23:	50                   	push   %eax
f0102b24:	68 11 03 00 00       	push   $0x311
f0102b29:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102b2f:	50                   	push   %eax
f0102b30:	e8 7c d5 ff ff       	call   f01000b1 <_panic>
f0102b35:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b3a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102b3d:	05 00 80 00 20       	add    $0x20008000,%eax
f0102b42:	89 c6                	mov    %eax,%esi
f0102b44:	89 da                	mov    %ebx,%edx
f0102b46:	89 f8                	mov    %edi,%eax
f0102b48:	e8 07 e0 ff ff       	call   f0100b54 <check_va2pa>
f0102b4d:	89 c2                	mov    %eax,%edx
f0102b4f:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102b52:	39 c2                	cmp    %eax,%edx
f0102b54:	75 44                	jne    f0102b9a <mem_init+0x1810>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b56:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b5c:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102b62:	75 e0                	jne    f0102b44 <mem_init+0x17ba>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b64:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102b67:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102b6c:	89 f8                	mov    %edi,%eax
f0102b6e:	e8 e1 df ff ff       	call   f0100b54 <check_va2pa>
f0102b73:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b76:	74 71                	je     f0102be9 <mem_init+0x185f>
f0102b78:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b7b:	8d 83 14 71 f8 ff    	lea    -0x78eec(%ebx),%eax
f0102b81:	50                   	push   %eax
f0102b82:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102b88:	50                   	push   %eax
f0102b89:	68 16 03 00 00       	push   $0x316
f0102b8e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102b94:	50                   	push   %eax
f0102b95:	e8 17 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b9d:	8d 83 cc 70 f8 ff    	lea    -0x78f34(%ebx),%eax
f0102ba3:	50                   	push   %eax
f0102ba4:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102baa:	50                   	push   %eax
f0102bab:	68 15 03 00 00       	push   $0x315
f0102bb0:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102bb6:	50                   	push   %eax
f0102bb7:	e8 f5 d4 ff ff       	call   f01000b1 <_panic>
		switch (i) {
f0102bbc:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102bc2:	75 25                	jne    f0102be9 <mem_init+0x185f>
			assert(pgdir[i] & PTE_P);
f0102bc4:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102bc8:	74 4f                	je     f0102c19 <mem_init+0x188f>
	for (i = 0; i < NPDENTRIES; i++) {
f0102bca:	83 c6 01             	add    $0x1,%esi
f0102bcd:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102bd3:	0f 87 b1 00 00 00    	ja     f0102c8a <mem_init+0x1900>
		switch (i) {
f0102bd9:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102bdf:	77 db                	ja     f0102bbc <mem_init+0x1832>
f0102be1:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0102be7:	77 db                	ja     f0102bc4 <mem_init+0x183a>
			if (i >= PDX(KERNBASE)) {
f0102be9:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102bef:	77 4a                	ja     f0102c3b <mem_init+0x18b1>
				assert(pgdir[i] == 0);
f0102bf1:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102bf5:	74 d3                	je     f0102bca <mem_init+0x1840>
f0102bf7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bfa:	8d 83 25 6a f8 ff    	lea    -0x795db(%ebx),%eax
f0102c00:	50                   	push   %eax
f0102c01:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102c07:	50                   	push   %eax
f0102c08:	68 26 03 00 00       	push   $0x326
f0102c0d:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102c13:	50                   	push   %eax
f0102c14:	e8 98 d4 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c19:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c1c:	8d 83 03 6a f8 ff    	lea    -0x795fd(%ebx),%eax
f0102c22:	50                   	push   %eax
f0102c23:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102c29:	50                   	push   %eax
f0102c2a:	68 1f 03 00 00       	push   $0x31f
f0102c2f:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102c35:	50                   	push   %eax
f0102c36:	e8 76 d4 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102c3b:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102c3e:	a8 01                	test   $0x1,%al
f0102c40:	74 26                	je     f0102c68 <mem_init+0x18de>
				assert(pgdir[i] & PTE_W);
f0102c42:	a8 02                	test   $0x2,%al
f0102c44:	75 84                	jne    f0102bca <mem_init+0x1840>
f0102c46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c49:	8d 83 14 6a f8 ff    	lea    -0x795ec(%ebx),%eax
f0102c4f:	50                   	push   %eax
f0102c50:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102c56:	50                   	push   %eax
f0102c57:	68 24 03 00 00       	push   $0x324
f0102c5c:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102c62:	50                   	push   %eax
f0102c63:	e8 49 d4 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102c68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c6b:	8d 83 03 6a f8 ff    	lea    -0x795fd(%ebx),%eax
f0102c71:	50                   	push   %eax
f0102c72:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102c78:	50                   	push   %eax
f0102c79:	68 23 03 00 00       	push   $0x323
f0102c7e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102c84:	50                   	push   %eax
f0102c85:	e8 27 d4 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c8a:	83 ec 0c             	sub    $0xc,%esp
f0102c8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c90:	8d 83 44 71 f8 ff    	lea    -0x78ebc(%ebx),%eax
f0102c96:	50                   	push   %eax
f0102c97:	e8 8b 09 00 00       	call   f0103627 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c9c:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102ca2:	83 c4 10             	add    $0x10,%esp
f0102ca5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102caa:	0f 86 2c 02 00 00    	jbe    f0102edc <mem_init+0x1b52>
	return (physaddr_t)kva - KERNBASE;
f0102cb0:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102cb5:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102cb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cbd:	e8 0e df ff ff       	call   f0100bd0 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102cc2:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102cc5:	83 e0 f3             	and    $0xfffffff3,%eax
f0102cc8:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ccd:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102cd0:	83 ec 0c             	sub    $0xc,%esp
f0102cd3:	6a 00                	push   $0x0
f0102cd5:	e8 05 e3 ff ff       	call   f0100fdf <page_alloc>
f0102cda:	89 c6                	mov    %eax,%esi
f0102cdc:	83 c4 10             	add    $0x10,%esp
f0102cdf:	85 c0                	test   %eax,%eax
f0102ce1:	0f 84 11 02 00 00    	je     f0102ef8 <mem_init+0x1b6e>
	assert((pp1 = page_alloc(0)));
f0102ce7:	83 ec 0c             	sub    $0xc,%esp
f0102cea:	6a 00                	push   $0x0
f0102cec:	e8 ee e2 ff ff       	call   f0100fdf <page_alloc>
f0102cf1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102cf4:	83 c4 10             	add    $0x10,%esp
f0102cf7:	85 c0                	test   %eax,%eax
f0102cf9:	0f 84 1b 02 00 00    	je     f0102f1a <mem_init+0x1b90>
	assert((pp2 = page_alloc(0)));
f0102cff:	83 ec 0c             	sub    $0xc,%esp
f0102d02:	6a 00                	push   $0x0
f0102d04:	e8 d6 e2 ff ff       	call   f0100fdf <page_alloc>
f0102d09:	89 c7                	mov    %eax,%edi
f0102d0b:	83 c4 10             	add    $0x10,%esp
f0102d0e:	85 c0                	test   %eax,%eax
f0102d10:	0f 84 26 02 00 00    	je     f0102f3c <mem_init+0x1bb2>
	page_free(pp0);
f0102d16:	83 ec 0c             	sub    $0xc,%esp
f0102d19:	56                   	push   %esi
f0102d1a:	e8 45 e3 ff ff       	call   f0101064 <page_free>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d1f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d22:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d25:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102d2b:	c1 f8 03             	sar    $0x3,%eax
f0102d2e:	89 c2                	mov    %eax,%edx
f0102d30:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d33:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d38:	83 c4 10             	add    $0x10,%esp
f0102d3b:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102d41:	0f 83 17 02 00 00    	jae    f0102f5e <mem_init+0x1bd4>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d47:	83 ec 04             	sub    $0x4,%esp
f0102d4a:	68 00 10 00 00       	push   $0x1000
f0102d4f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d51:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d57:	52                   	push   %edx
f0102d58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d5b:	e8 45 19 00 00       	call   f01046a5 <memset>
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102d60:	89 f8                	mov    %edi,%eax
f0102d62:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0102d68:	c1 f8 03             	sar    $0x3,%eax
f0102d6b:	89 c2                	mov    %eax,%edx
f0102d6d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d70:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d75:	83 c4 10             	add    $0x10,%esp
f0102d78:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0102d7e:	0f 83 f2 01 00 00    	jae    f0102f76 <mem_init+0x1bec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d84:	83 ec 04             	sub    $0x4,%esp
f0102d87:	68 00 10 00 00       	push   $0x1000
f0102d8c:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d8e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d94:	52                   	push   %edx
f0102d95:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d98:	e8 08 19 00 00       	call   f01046a5 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d9d:	6a 02                	push   $0x2
f0102d9f:	68 00 10 00 00       	push   $0x1000
f0102da4:	ff 75 d0             	push   -0x30(%ebp)
f0102da7:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0102dad:	e8 66 e5 ff ff       	call   f0101318 <page_insert>
	assert(pp1->pp_ref == 1);
f0102db2:	83 c4 20             	add    $0x20,%esp
f0102db5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102db8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102dbd:	0f 85 cc 01 00 00    	jne    f0102f8f <mem_init+0x1c05>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102dc3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102dca:	01 01 01 
f0102dcd:	0f 85 de 01 00 00    	jne    f0102fb1 <mem_init+0x1c27>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102dd3:	6a 02                	push   $0x2
f0102dd5:	68 00 10 00 00       	push   $0x1000
f0102dda:	57                   	push   %edi
f0102ddb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dde:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102de4:	e8 2f e5 ff ff       	call   f0101318 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102de9:	83 c4 10             	add    $0x10,%esp
f0102dec:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102df3:	02 02 02 
f0102df6:	0f 85 d7 01 00 00    	jne    f0102fd3 <mem_init+0x1c49>
	assert(pp2->pp_ref == 1);
f0102dfc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102e01:	0f 85 ee 01 00 00    	jne    f0102ff5 <mem_init+0x1c6b>
	assert(pp1->pp_ref == 0);
f0102e07:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102e0a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102e0f:	0f 85 02 02 00 00    	jne    f0103017 <mem_init+0x1c8d>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e15:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e1c:	03 03 03 
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102e1f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e22:	89 f8                	mov    %edi,%eax
f0102e24:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102e2a:	c1 f8 03             	sar    $0x3,%eax
f0102e2d:	89 c2                	mov    %eax,%edx
f0102e2f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e32:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e37:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102e3d:	0f 83 f6 01 00 00    	jae    f0103039 <mem_init+0x1caf>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e43:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102e4a:	03 03 03 
f0102e4d:	0f 85 fe 01 00 00    	jne    f0103051 <mem_init+0x1cc7>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e53:	83 ec 08             	sub    $0x8,%esp
f0102e56:	68 00 10 00 00       	push   $0x1000
f0102e5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e5e:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102e64:	e8 74 e4 ff ff       	call   f01012dd <page_remove>
	assert(pp2->pp_ref == 0);
f0102e69:	83 c4 10             	add    $0x10,%esp
f0102e6c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e71:	0f 85 fc 01 00 00    	jne    f0103073 <mem_init+0x1ce9>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e7a:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0102e80:	8b 11                	mov    (%ecx),%edx
f0102e82:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;//PGSHIFT宏于mmu.h中定义，为12，目的应该是找到pp所对应的物理地址
f0102e88:	89 f7                	mov    %esi,%edi
f0102e8a:	2b b8 d0 1a 00 00    	sub    0x1ad0(%eax),%edi
f0102e90:	89 f8                	mov    %edi,%eax
f0102e92:	c1 f8 03             	sar    $0x3,%eax
f0102e95:	c1 e0 0c             	shl    $0xc,%eax
f0102e98:	39 c2                	cmp    %eax,%edx
f0102e9a:	0f 85 f5 01 00 00    	jne    f0103095 <mem_init+0x1d0b>
	kern_pgdir[0] = 0;
f0102ea0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ea6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102eab:	0f 85 06 02 00 00    	jne    f01030b7 <mem_init+0x1d2d>
	pp0->pp_ref = 0;
f0102eb1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102eb7:	83 ec 0c             	sub    $0xc,%esp
f0102eba:	56                   	push   %esi
f0102ebb:	e8 a4 e1 ff ff       	call   f0101064 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ec0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec3:	8d 83 d8 71 f8 ff    	lea    -0x78e28(%ebx),%eax
f0102ec9:	89 04 24             	mov    %eax,(%esp)
f0102ecc:	e8 56 07 00 00       	call   f0103627 <cprintf>
}
f0102ed1:	83 c4 10             	add    $0x10,%esp
f0102ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ed7:	5b                   	pop    %ebx
f0102ed8:	5e                   	pop    %esi
f0102ed9:	5f                   	pop    %edi
f0102eda:	5d                   	pop    %ebp
f0102edb:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102edc:	50                   	push   %eax
f0102edd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ee0:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f0102ee6:	50                   	push   %eax
f0102ee7:	68 f5 00 00 00       	push   $0xf5
f0102eec:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102ef2:	50                   	push   %eax
f0102ef3:	e8 b9 d1 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102ef8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102efb:	8d 83 21 68 f8 ff    	lea    -0x797df(%ebx),%eax
f0102f01:	50                   	push   %eax
f0102f02:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102f08:	50                   	push   %eax
f0102f09:	68 e6 03 00 00       	push   $0x3e6
f0102f0e:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102f14:	50                   	push   %eax
f0102f15:	e8 97 d1 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f1a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f1d:	8d 83 37 68 f8 ff    	lea    -0x797c9(%ebx),%eax
f0102f23:	50                   	push   %eax
f0102f24:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102f2a:	50                   	push   %eax
f0102f2b:	68 e7 03 00 00       	push   $0x3e7
f0102f30:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102f36:	50                   	push   %eax
f0102f37:	e8 75 d1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102f3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f3f:	8d 83 4d 68 f8 ff    	lea    -0x797b3(%ebx),%eax
f0102f45:	50                   	push   %eax
f0102f46:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102f4c:	50                   	push   %eax
f0102f4d:	68 e8 03 00 00       	push   $0x3e8
f0102f52:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102f58:	50                   	push   %eax
f0102f59:	e8 53 d1 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f5e:	52                   	push   %edx
f0102f5f:	89 cb                	mov    %ecx,%ebx
f0102f61:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f0102f67:	50                   	push   %eax
f0102f68:	6a 57                	push   $0x57
f0102f6a:	8d 81 38 67 f8 ff    	lea    -0x798c8(%ecx),%eax
f0102f70:	50                   	push   %eax
f0102f71:	e8 3b d1 ff ff       	call   f01000b1 <_panic>
f0102f76:	52                   	push   %edx
f0102f77:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f7a:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f0102f80:	50                   	push   %eax
f0102f81:	6a 57                	push   $0x57
f0102f83:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f0102f89:	50                   	push   %eax
f0102f8a:	e8 22 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102f8f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f92:	8d 83 1e 69 f8 ff    	lea    -0x796e2(%ebx),%eax
f0102f98:	50                   	push   %eax
f0102f99:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102f9f:	50                   	push   %eax
f0102fa0:	68 ed 03 00 00       	push   $0x3ed
f0102fa5:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102fab:	50                   	push   %eax
f0102fac:	e8 00 d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102fb1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fb4:	8d 83 64 71 f8 ff    	lea    -0x78e9c(%ebx),%eax
f0102fba:	50                   	push   %eax
f0102fbb:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102fc1:	50                   	push   %eax
f0102fc2:	68 ee 03 00 00       	push   $0x3ee
f0102fc7:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102fcd:	50                   	push   %eax
f0102fce:	e8 de d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fd3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd6:	8d 83 88 71 f8 ff    	lea    -0x78e78(%ebx),%eax
f0102fdc:	50                   	push   %eax
f0102fdd:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0102fe3:	50                   	push   %eax
f0102fe4:	68 f0 03 00 00       	push   $0x3f0
f0102fe9:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0102fef:	50                   	push   %eax
f0102ff0:	e8 bc d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102ff5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff8:	8d 83 40 69 f8 ff    	lea    -0x796c0(%ebx),%eax
f0102ffe:	50                   	push   %eax
f0102fff:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103005:	50                   	push   %eax
f0103006:	68 f1 03 00 00       	push   $0x3f1
f010300b:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0103011:	50                   	push   %eax
f0103012:	e8 9a d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0103017:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010301a:	8d 83 aa 69 f8 ff    	lea    -0x79656(%ebx),%eax
f0103020:	50                   	push   %eax
f0103021:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103027:	50                   	push   %eax
f0103028:	68 f2 03 00 00       	push   $0x3f2
f010302d:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f0103033:	50                   	push   %eax
f0103034:	e8 78 d0 ff ff       	call   f01000b1 <_panic>
f0103039:	52                   	push   %edx
f010303a:	89 cb                	mov    %ecx,%ebx
f010303c:	8d 81 34 6a f8 ff    	lea    -0x795cc(%ecx),%eax
f0103042:	50                   	push   %eax
f0103043:	6a 57                	push   $0x57
f0103045:	8d 81 38 67 f8 ff    	lea    -0x798c8(%ecx),%eax
f010304b:	50                   	push   %eax
f010304c:	e8 60 d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103051:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103054:	8d 83 ac 71 f8 ff    	lea    -0x78e54(%ebx),%eax
f010305a:	50                   	push   %eax
f010305b:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103061:	50                   	push   %eax
f0103062:	68 f4 03 00 00       	push   $0x3f4
f0103067:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010306d:	50                   	push   %eax
f010306e:	e8 3e d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103073:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103076:	8d 83 78 69 f8 ff    	lea    -0x79688(%ebx),%eax
f010307c:	50                   	push   %eax
f010307d:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103083:	50                   	push   %eax
f0103084:	68 f6 03 00 00       	push   $0x3f6
f0103089:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f010308f:	50                   	push   %eax
f0103090:	e8 1c d0 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103095:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103098:	8d 83 bc 6c f8 ff    	lea    -0x79344(%ebx),%eax
f010309e:	50                   	push   %eax
f010309f:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01030a5:	50                   	push   %eax
f01030a6:	68 f9 03 00 00       	push   $0x3f9
f01030ab:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01030b1:	50                   	push   %eax
f01030b2:	e8 fa cf ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01030b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ba:	8d 83 2f 69 f8 ff    	lea    -0x796d1(%ebx),%eax
f01030c0:	50                   	push   %eax
f01030c1:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f01030c7:	50                   	push   %eax
f01030c8:	68 fb 03 00 00       	push   $0x3fb
f01030cd:	8d 83 2c 67 f8 ff    	lea    -0x798d4(%ebx),%eax
f01030d3:	50                   	push   %eax
f01030d4:	e8 d8 cf ff ff       	call   f01000b1 <_panic>

f01030d9 <tlb_invalidate>:
{
f01030d9:	55                   	push   %ebp
f01030da:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01030dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030df:	0f 01 38             	invlpg (%eax)
}
f01030e2:	5d                   	pop    %ebp
f01030e3:	c3                   	ret    

f01030e4 <user_mem_check>:
}
f01030e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e9:	c3                   	ret    

f01030ea <user_mem_assert>:
}
f01030ea:	c3                   	ret    

f01030eb <__x86.get_pc_thunk.cx>:
f01030eb:	8b 0c 24             	mov    (%esp),%ecx
f01030ee:	c3                   	ret    

f01030ef <__x86.get_pc_thunk.di>:
f01030ef:	8b 3c 24             	mov    (%esp),%edi
f01030f2:	c3                   	ret    

f01030f3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01030f3:	55                   	push   %ebp
f01030f4:	89 e5                	mov    %esp,%ebp
f01030f6:	53                   	push   %ebx
f01030f7:	e8 ef ff ff ff       	call   f01030eb <__x86.get_pc_thunk.cx>
f01030fc:	81 c1 6c b7 07 00    	add    $0x7b76c,%ecx
f0103102:	8b 45 08             	mov    0x8(%ebp),%eax
f0103105:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103108:	85 c0                	test   %eax,%eax
f010310a:	74 4c                	je     f0103158 <envid2env+0x65>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010310c:	89 c2                	mov    %eax,%edx
f010310e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103114:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103117:	c1 e2 05             	shl    $0x5,%edx
f010311a:	03 91 e8 1a 00 00    	add    0x1ae8(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103120:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103124:	74 42                	je     f0103168 <envid2env+0x75>
f0103126:	39 42 48             	cmp    %eax,0x48(%edx)
f0103129:	75 49                	jne    f0103174 <envid2env+0x81>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
	return 0;
f010312b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103130:	84 db                	test   %bl,%bl
f0103132:	74 2a                	je     f010315e <envid2env+0x6b>
f0103134:	8b 89 e4 1a 00 00    	mov    0x1ae4(%ecx),%ecx
f010313a:	39 d1                	cmp    %edx,%ecx
f010313c:	74 20                	je     f010315e <envid2env+0x6b>
f010313e:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103141:	3b 41 48             	cmp    0x48(%ecx),%eax
f0103144:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103149:	0f 45 d3             	cmovne %ebx,%edx
f010314c:	0f 94 c0             	sete   %al
f010314f:	0f b6 c0             	movzbl %al,%eax
f0103152:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f0103156:	eb 06                	jmp    f010315e <envid2env+0x6b>
		*env_store = curenv;
f0103158:	8b 91 e4 1a 00 00    	mov    0x1ae4(%ecx),%edx
f010315e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103161:	89 11                	mov    %edx,(%ecx)
}
f0103163:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103166:	c9                   	leave  
f0103167:	c3                   	ret    
f0103168:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f010316d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103172:	eb ea                	jmp    f010315e <envid2env+0x6b>
f0103174:	ba 00 00 00 00       	mov    $0x0,%edx
f0103179:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010317e:	eb de                	jmp    f010315e <envid2env+0x6b>

f0103180 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103180:	e8 74 d5 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103185:	05 e3 b6 07 00       	add    $0x7b6e3,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f010318a:	8d 80 98 17 00 00    	lea    0x1798(%eax),%eax
f0103190:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103193:	b8 23 00 00 00       	mov    $0x23,%eax
f0103198:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010319a:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010319c:	b8 10 00 00 00       	mov    $0x10,%eax
f01031a1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01031a3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01031a5:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01031a7:	ea ae 31 10 f0 08 00 	ljmp   $0x8,$0xf01031ae
	asm volatile("lldt %0" : : "r" (sel));
f01031ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01031b3:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01031b6:	c3                   	ret    

f01031b7 <env_init>:
{
f01031b7:	55                   	push   %ebp
f01031b8:	89 e5                	mov    %esp,%ebp
f01031ba:	83 ec 08             	sub    $0x8,%esp
	env_init_percpu();
f01031bd:	e8 be ff ff ff       	call   f0103180 <env_init_percpu>
}
f01031c2:	c9                   	leave  
f01031c3:	c3                   	ret    

f01031c4 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01031c4:	55                   	push   %ebp
f01031c5:	89 e5                	mov    %esp,%ebp
f01031c7:	56                   	push   %esi
f01031c8:	53                   	push   %ebx
f01031c9:	e8 99 cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01031ce:	81 c3 9a b6 07 00    	add    $0x7b69a,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01031d4:	8b b3 ec 1a 00 00    	mov    0x1aec(%ebx),%esi
f01031da:	85 f6                	test   %esi,%esi
f01031dc:	0f 84 03 01 00 00    	je     f01032e5 <env_alloc+0x121>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01031e2:	83 ec 0c             	sub    $0xc,%esp
f01031e5:	6a 01                	push   $0x1
f01031e7:	e8 f3 dd ff ff       	call   f0100fdf <page_alloc>
f01031ec:	83 c4 10             	add    $0x10,%esp
f01031ef:	85 c0                	test   %eax,%eax
f01031f1:	0f 84 f5 00 00 00    	je     f01032ec <env_alloc+0x128>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031f7:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01031fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ff:	0f 86 c7 00 00 00    	jbe    f01032cc <env_alloc+0x108>
	return (physaddr_t)kva - KERNBASE;
f0103205:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010320b:	83 ca 05             	or     $0x5,%edx
f010320e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103214:	8b 46 48             	mov    0x48(%esi),%eax
f0103217:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f010321c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103221:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103226:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103229:	89 f2                	mov    %esi,%edx
f010322b:	2b 93 e8 1a 00 00    	sub    0x1ae8(%ebx),%edx
f0103231:	c1 fa 05             	sar    $0x5,%edx
f0103234:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010323a:	09 d0                	or     %edx,%eax
f010323c:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010323f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103242:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103245:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f010324c:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103253:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010325a:	83 ec 04             	sub    $0x4,%esp
f010325d:	6a 44                	push   $0x44
f010325f:	6a 00                	push   $0x0
f0103261:	56                   	push   %esi
f0103262:	e8 3e 14 00 00       	call   f01046a5 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103267:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f010326d:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103273:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103279:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103280:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103286:	8b 46 44             	mov    0x44(%esi),%eax
f0103289:	89 83 ec 1a 00 00    	mov    %eax,0x1aec(%ebx)
	*newenv_store = e;
f010328f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103292:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103294:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103297:	8b 83 e4 1a 00 00    	mov    0x1ae4(%ebx),%eax
f010329d:	83 c4 10             	add    $0x10,%esp
f01032a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01032a5:	85 c0                	test   %eax,%eax
f01032a7:	74 03                	je     f01032ac <env_alloc+0xe8>
f01032a9:	8b 50 48             	mov    0x48(%eax),%edx
f01032ac:	83 ec 04             	sub    $0x4,%esp
f01032af:	51                   	push   %ecx
f01032b0:	52                   	push   %edx
f01032b1:	8d 83 45 72 f8 ff    	lea    -0x78dbb(%ebx),%eax
f01032b7:	50                   	push   %eax
f01032b8:	e8 6a 03 00 00       	call   f0103627 <cprintf>
	return 0;
f01032bd:	83 c4 10             	add    $0x10,%esp
f01032c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032c8:	5b                   	pop    %ebx
f01032c9:	5e                   	pop    %esi
f01032ca:	5d                   	pop    %ebp
f01032cb:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032cc:	50                   	push   %eax
f01032cd:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f01032d3:	50                   	push   %eax
f01032d4:	68 b9 00 00 00       	push   $0xb9
f01032d9:	8d 83 3a 72 f8 ff    	lea    -0x78dc6(%ebx),%eax
f01032df:	50                   	push   %eax
f01032e0:	e8 cc cd ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f01032e5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032ea:	eb d9                	jmp    f01032c5 <env_alloc+0x101>
		return -E_NO_MEM;
f01032ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01032f1:	eb d2                	jmp    f01032c5 <env_alloc+0x101>

f01032f3 <env_create>:
//
void
env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
}
f01032f3:	c3                   	ret    

f01032f4 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032f4:	55                   	push   %ebp
f01032f5:	89 e5                	mov    %esp,%ebp
f01032f7:	57                   	push   %edi
f01032f8:	56                   	push   %esi
f01032f9:	53                   	push   %ebx
f01032fa:	83 ec 2c             	sub    $0x2c,%esp
f01032fd:	e8 65 ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103302:	81 c3 66 b5 07 00    	add    $0x7b566,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103308:	8b 93 e4 1a 00 00    	mov    0x1ae4(%ebx),%edx
f010330e:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103311:	74 47                	je     f010335a <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103313:	8b 45 08             	mov    0x8(%ebp),%eax
f0103316:	8b 48 48             	mov    0x48(%eax),%ecx
f0103319:	b8 00 00 00 00       	mov    $0x0,%eax
f010331e:	85 d2                	test   %edx,%edx
f0103320:	74 03                	je     f0103325 <env_free+0x31>
f0103322:	8b 42 48             	mov    0x48(%edx),%eax
f0103325:	83 ec 04             	sub    $0x4,%esp
f0103328:	51                   	push   %ecx
f0103329:	50                   	push   %eax
f010332a:	8d 83 5a 72 f8 ff    	lea    -0x78da6(%ebx),%eax
f0103330:	50                   	push   %eax
f0103331:	e8 f1 02 00 00       	call   f0103627 <cprintf>
f0103336:	83 c4 10             	add    $0x10,%esp
f0103339:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0103340:	c7 c0 40 03 18 f0    	mov    $0xf0180340,%eax
f0103346:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f0103349:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f010334c:	c7 c0 38 03 18 f0    	mov    $0xf0180338,%eax
f0103352:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103355:	e9 bf 00 00 00       	jmp    f0103419 <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f010335a:	c7 c0 3c 03 18 f0    	mov    $0xf018033c,%eax
f0103360:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103362:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103367:	76 10                	jbe    f0103379 <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f0103369:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010336e:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103371:	8b 45 08             	mov    0x8(%ebp),%eax
f0103374:	8b 48 48             	mov    0x48(%eax),%ecx
f0103377:	eb a9                	jmp    f0103322 <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103379:	50                   	push   %eax
f010337a:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f0103380:	50                   	push   %eax
f0103381:	68 68 01 00 00       	push   $0x168
f0103386:	8d 83 3a 72 f8 ff    	lea    -0x78dc6(%ebx),%eax
f010338c:	50                   	push   %eax
f010338d:	e8 1f cd ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103392:	57                   	push   %edi
f0103393:	8d 83 34 6a f8 ff    	lea    -0x795cc(%ebx),%eax
f0103399:	50                   	push   %eax
f010339a:	68 77 01 00 00       	push   $0x177
f010339f:	8d 83 3a 72 f8 ff    	lea    -0x78dc6(%ebx),%eax
f01033a5:	50                   	push   %eax
f01033a6:	e8 06 cd ff ff       	call   f01000b1 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033ab:	83 c7 04             	add    $0x4,%edi
f01033ae:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01033b4:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f01033ba:	74 1e                	je     f01033da <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f01033bc:	f6 07 01             	testb  $0x1,(%edi)
f01033bf:	74 ea                	je     f01033ab <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033c1:	83 ec 08             	sub    $0x8,%esp
f01033c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c7:	09 f0                	or     %esi,%eax
f01033c9:	50                   	push   %eax
f01033ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cd:	ff 70 5c             	push   0x5c(%eax)
f01033d0:	e8 08 df ff ff       	call   f01012dd <page_remove>
f01033d5:	83 c4 10             	add    $0x10,%esp
f01033d8:	eb d1                	jmp    f01033ab <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01033da:	8b 45 08             	mov    0x8(%ebp),%eax
f01033dd:	8b 40 5c             	mov    0x5c(%eax),%eax
f01033e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01033e3:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f01033ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033f0:	3b 10                	cmp    (%eax),%edx
f01033f2:	73 67                	jae    f010345b <env_free+0x167>
		page_decref(pa2page(pa));
f01033f4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01033fa:	8b 00                	mov    (%eax),%eax
f01033fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033ff:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103402:	50                   	push   %eax
f0103403:	e8 ce dc ff ff       	call   f01010d6 <page_decref>
f0103408:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010340b:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f010340f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103412:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103417:	74 5a                	je     f0103473 <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103419:	8b 45 08             	mov    0x8(%ebp),%eax
f010341c:	8b 40 5c             	mov    0x5c(%eax),%eax
f010341f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103422:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0103425:	a8 01                	test   $0x1,%al
f0103427:	74 e2                	je     f010340b <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103429:	89 c7                	mov    %eax,%edi
f010342b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0103431:	c1 e8 0c             	shr    $0xc,%eax
f0103434:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103437:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010343a:	3b 02                	cmp    (%edx),%eax
f010343c:	0f 83 50 ff ff ff    	jae    f0103392 <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f0103442:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0103448:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010344b:	c1 e0 14             	shl    $0x14,%eax
f010344e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103451:	be 00 00 00 00       	mov    $0x0,%esi
f0103456:	e9 61 ff ff ff       	jmp    f01033bc <env_free+0xc8>
		panic("pa2page called with invalid pa");
f010345b:	83 ec 04             	sub    $0x4,%esp
f010345e:	8d 83 64 6b f8 ff    	lea    -0x7949c(%ebx),%eax
f0103464:	50                   	push   %eax
f0103465:	6a 50                	push   $0x50
f0103467:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f010346d:	50                   	push   %eax
f010346e:	e8 3e cc ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103473:	8b 45 08             	mov    0x8(%ebp),%eax
f0103476:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103479:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010347e:	76 57                	jbe    f01034d7 <env_free+0x1e3>
	e->env_pgdir = 0;
f0103480:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103483:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f010348a:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)//PGNUM()在 mmu.h中定义，作用是返回地址的页码字段。
f010348f:	c1 e8 0c             	shr    $0xc,%eax
f0103492:	c7 c2 40 03 18 f0    	mov    $0xf0180340,%edx
f0103498:	3b 02                	cmp    (%edx),%eax
f010349a:	73 54                	jae    f01034f0 <env_free+0x1fc>
	page_decref(pa2page(pa));
f010349c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010349f:	c7 c2 38 03 18 f0    	mov    $0xf0180338,%edx
f01034a5:	8b 12                	mov    (%edx),%edx
f01034a7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034aa:	50                   	push   %eax
f01034ab:	e8 26 dc ff ff       	call   f01010d6 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01034b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01034b3:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01034ba:	8b 83 ec 1a 00 00    	mov    0x1aec(%ebx),%eax
f01034c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01034c3:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f01034c6:	89 8b ec 1a 00 00    	mov    %ecx,0x1aec(%ebx)
}
f01034cc:	83 c4 10             	add    $0x10,%esp
f01034cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034d2:	5b                   	pop    %ebx
f01034d3:	5e                   	pop    %esi
f01034d4:	5f                   	pop    %edi
f01034d5:	5d                   	pop    %ebp
f01034d6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d7:	50                   	push   %eax
f01034d8:	8d 83 c0 6b f8 ff    	lea    -0x79440(%ebx),%eax
f01034de:	50                   	push   %eax
f01034df:	68 85 01 00 00       	push   $0x185
f01034e4:	8d 83 3a 72 f8 ff    	lea    -0x78dc6(%ebx),%eax
f01034ea:	50                   	push   %eax
f01034eb:	e8 c1 cb ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f01034f0:	83 ec 04             	sub    $0x4,%esp
f01034f3:	8d 83 64 6b f8 ff    	lea    -0x7949c(%ebx),%eax
f01034f9:	50                   	push   %eax
f01034fa:	6a 50                	push   $0x50
f01034fc:	8d 83 38 67 f8 ff    	lea    -0x798c8(%ebx),%eax
f0103502:	50                   	push   %eax
f0103503:	e8 a9 cb ff ff       	call   f01000b1 <_panic>

f0103508 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103508:	55                   	push   %ebp
f0103509:	89 e5                	mov    %esp,%ebp
f010350b:	53                   	push   %ebx
f010350c:	83 ec 10             	sub    $0x10,%esp
f010350f:	e8 53 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103514:	81 c3 54 b3 07 00    	add    $0x7b354,%ebx
	env_free(e);
f010351a:	ff 75 08             	push   0x8(%ebp)
f010351d:	e8 d2 fd ff ff       	call   f01032f4 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103522:	8d 83 04 72 f8 ff    	lea    -0x78dfc(%ebx),%eax
f0103528:	89 04 24             	mov    %eax,(%esp)
f010352b:	e8 f7 00 00 00       	call   f0103627 <cprintf>
f0103530:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103533:	83 ec 0c             	sub    $0xc,%esp
f0103536:	6a 00                	push   $0x0
f0103538:	e8 f7 d3 ff ff       	call   f0100934 <monitor>
f010353d:	83 c4 10             	add    $0x10,%esp
f0103540:	eb f1                	jmp    f0103533 <env_destroy+0x2b>

f0103542 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103542:	55                   	push   %ebp
f0103543:	89 e5                	mov    %esp,%ebp
f0103545:	53                   	push   %ebx
f0103546:	83 ec 08             	sub    $0x8,%esp
f0103549:	e8 19 cc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010354e:	81 c3 1a b3 07 00    	add    $0x7b31a,%ebx
	asm volatile(
f0103554:	8b 65 08             	mov    0x8(%ebp),%esp
f0103557:	61                   	popa   
f0103558:	07                   	pop    %es
f0103559:	1f                   	pop    %ds
f010355a:	83 c4 08             	add    $0x8,%esp
f010355d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010355e:	8d 83 70 72 f8 ff    	lea    -0x78d90(%ebx),%eax
f0103564:	50                   	push   %eax
f0103565:	68 ae 01 00 00       	push   $0x1ae
f010356a:	8d 83 3a 72 f8 ff    	lea    -0x78dc6(%ebx),%eax
f0103570:	50                   	push   %eax
f0103571:	e8 3b cb ff ff       	call   f01000b1 <_panic>

f0103576 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103576:	55                   	push   %ebp
f0103577:	89 e5                	mov    %esp,%ebp
f0103579:	53                   	push   %ebx
f010357a:	83 ec 08             	sub    $0x8,%esp
f010357d:	e8 e5 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103582:	81 c3 e6 b2 07 00    	add    $0x7b2e6,%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0103588:	8d 83 7c 72 f8 ff    	lea    -0x78d84(%ebx),%eax
f010358e:	50                   	push   %eax
f010358f:	68 cd 01 00 00       	push   $0x1cd
f0103594:	8d 83 3a 72 f8 ff    	lea    -0x78dc6(%ebx),%eax
f010359a:	50                   	push   %eax
f010359b:	e8 11 cb ff ff       	call   f01000b1 <_panic>

f01035a0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035a0:	55                   	push   %ebp
f01035a1:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035a6:	ba 70 00 00 00       	mov    $0x70,%edx
f01035ab:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035ac:	ba 71 00 00 00       	mov    $0x71,%edx
f01035b1:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035b2:	0f b6 c0             	movzbl %al,%eax
}
f01035b5:	5d                   	pop    %ebp
f01035b6:	c3                   	ret    

f01035b7 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035b7:	55                   	push   %ebp
f01035b8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01035bd:	ba 70 00 00 00       	mov    $0x70,%edx
f01035c2:	ee                   	out    %al,(%dx)
f01035c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035c6:	ba 71 00 00 00       	mov    $0x71,%edx
f01035cb:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035cc:	5d                   	pop    %ebp
f01035cd:	c3                   	ret    

f01035ce <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01035ce:	55                   	push   %ebp
f01035cf:	89 e5                	mov    %esp,%ebp
f01035d1:	53                   	push   %ebx
f01035d2:	83 ec 10             	sub    $0x10,%esp
f01035d5:	e8 8d cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035da:	81 c3 8e b2 07 00    	add    $0x7b28e,%ebx
	cputchar(ch);
f01035e0:	ff 75 08             	push   0x8(%ebp)
f01035e3:	e8 ea d0 ff ff       	call   f01006d2 <cputchar>
	*cnt++;
}
f01035e8:	83 c4 10             	add    $0x10,%esp
f01035eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ee:	c9                   	leave  
f01035ef:	c3                   	ret    

f01035f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01035f0:	55                   	push   %ebp
f01035f1:	89 e5                	mov    %esp,%ebp
f01035f3:	53                   	push   %ebx
f01035f4:	83 ec 14             	sub    $0x14,%esp
f01035f7:	e8 6b cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035fc:	81 c3 6c b2 07 00    	add    $0x7b26c,%ebx
	int cnt = 0;
f0103602:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103609:	ff 75 0c             	push   0xc(%ebp)
f010360c:	ff 75 08             	push   0x8(%ebp)
f010360f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103612:	50                   	push   %eax
f0103613:	8d 83 66 4d f8 ff    	lea    -0x7b29a(%ebx),%eax
f0103619:	50                   	push   %eax
f010361a:	e8 d9 08 00 00       	call   f0103ef8 <vprintfmt>
	return cnt;
}
f010361f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103625:	c9                   	leave  
f0103626:	c3                   	ret    

f0103627 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103627:	55                   	push   %ebp
f0103628:	89 e5                	mov    %esp,%ebp
f010362a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010362d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103630:	50                   	push   %eax
f0103631:	ff 75 08             	push   0x8(%ebp)
f0103634:	e8 b7 ff ff ff       	call   f01035f0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103639:	c9                   	leave  
f010363a:	c3                   	ret    

f010363b <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010363b:	55                   	push   %ebp
f010363c:	89 e5                	mov    %esp,%ebp
f010363e:	57                   	push   %edi
f010363f:	56                   	push   %esi
f0103640:	53                   	push   %ebx
f0103641:	83 ec 04             	sub    $0x4,%esp
f0103644:	e8 1e cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103649:	81 c3 1f b2 07 00    	add    $0x7b21f,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010364f:	c7 83 1c 23 00 00 00 	movl   $0xf0000000,0x231c(%ebx)
f0103656:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103659:	66 c7 83 20 23 00 00 	movw   $0x10,0x2320(%ebx)
f0103660:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103662:	66 c7 83 7e 23 00 00 	movw   $0x68,0x237e(%ebx)
f0103669:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010366b:	c7 c0 00 b3 11 f0    	mov    $0xf011b300,%eax
f0103671:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103677:	8d b3 18 23 00 00    	lea    0x2318(%ebx),%esi
f010367d:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103681:	89 f2                	mov    %esi,%edx
f0103683:	c1 ea 10             	shr    $0x10,%edx
f0103686:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103689:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f010368d:	83 e2 f0             	and    $0xfffffff0,%edx
f0103690:	83 ca 09             	or     $0x9,%edx
f0103693:	83 e2 9f             	and    $0xffffff9f,%edx
f0103696:	83 ca 80             	or     $0xffffff80,%edx
f0103699:	88 55 f3             	mov    %dl,-0xd(%ebp)
f010369c:	88 50 2d             	mov    %dl,0x2d(%eax)
f010369f:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01036a3:	83 e1 c0             	and    $0xffffffc0,%ecx
f01036a6:	83 c9 40             	or     $0x40,%ecx
f01036a9:	83 e1 7f             	and    $0x7f,%ecx
f01036ac:	88 48 2e             	mov    %cl,0x2e(%eax)
f01036af:	c1 ee 18             	shr    $0x18,%esi
f01036b2:	89 f1                	mov    %esi,%ecx
f01036b4:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01036b7:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01036bb:	83 e2 ef             	and    $0xffffffef,%edx
f01036be:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01036c1:	b8 28 00 00 00       	mov    $0x28,%eax
f01036c6:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01036c9:	8d 83 a0 17 00 00    	lea    0x17a0(%ebx),%eax
f01036cf:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01036d2:	83 c4 04             	add    $0x4,%esp
f01036d5:	5b                   	pop    %ebx
f01036d6:	5e                   	pop    %esi
f01036d7:	5f                   	pop    %edi
f01036d8:	5d                   	pop    %ebp
f01036d9:	c3                   	ret    

f01036da <trap_init>:
{
f01036da:	55                   	push   %ebp
f01036db:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f01036dd:	e8 59 ff ff ff       	call   f010363b <trap_init_percpu>
}
f01036e2:	5d                   	pop    %ebp
f01036e3:	c3                   	ret    

f01036e4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01036e4:	55                   	push   %ebp
f01036e5:	89 e5                	mov    %esp,%ebp
f01036e7:	56                   	push   %esi
f01036e8:	53                   	push   %ebx
f01036e9:	e8 79 ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01036ee:	81 c3 7a b1 07 00    	add    $0x7b17a,%ebx
f01036f4:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01036f7:	83 ec 08             	sub    $0x8,%esp
f01036fa:	ff 36                	push   (%esi)
f01036fc:	8d 83 98 72 f8 ff    	lea    -0x78d68(%ebx),%eax
f0103702:	50                   	push   %eax
f0103703:	e8 1f ff ff ff       	call   f0103627 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103708:	83 c4 08             	add    $0x8,%esp
f010370b:	ff 76 04             	push   0x4(%esi)
f010370e:	8d 83 a7 72 f8 ff    	lea    -0x78d59(%ebx),%eax
f0103714:	50                   	push   %eax
f0103715:	e8 0d ff ff ff       	call   f0103627 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010371a:	83 c4 08             	add    $0x8,%esp
f010371d:	ff 76 08             	push   0x8(%esi)
f0103720:	8d 83 b6 72 f8 ff    	lea    -0x78d4a(%ebx),%eax
f0103726:	50                   	push   %eax
f0103727:	e8 fb fe ff ff       	call   f0103627 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010372c:	83 c4 08             	add    $0x8,%esp
f010372f:	ff 76 0c             	push   0xc(%esi)
f0103732:	8d 83 c5 72 f8 ff    	lea    -0x78d3b(%ebx),%eax
f0103738:	50                   	push   %eax
f0103739:	e8 e9 fe ff ff       	call   f0103627 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010373e:	83 c4 08             	add    $0x8,%esp
f0103741:	ff 76 10             	push   0x10(%esi)
f0103744:	8d 83 d4 72 f8 ff    	lea    -0x78d2c(%ebx),%eax
f010374a:	50                   	push   %eax
f010374b:	e8 d7 fe ff ff       	call   f0103627 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103750:	83 c4 08             	add    $0x8,%esp
f0103753:	ff 76 14             	push   0x14(%esi)
f0103756:	8d 83 e3 72 f8 ff    	lea    -0x78d1d(%ebx),%eax
f010375c:	50                   	push   %eax
f010375d:	e8 c5 fe ff ff       	call   f0103627 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103762:	83 c4 08             	add    $0x8,%esp
f0103765:	ff 76 18             	push   0x18(%esi)
f0103768:	8d 83 f2 72 f8 ff    	lea    -0x78d0e(%ebx),%eax
f010376e:	50                   	push   %eax
f010376f:	e8 b3 fe ff ff       	call   f0103627 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103774:	83 c4 08             	add    $0x8,%esp
f0103777:	ff 76 1c             	push   0x1c(%esi)
f010377a:	8d 83 01 73 f8 ff    	lea    -0x78cff(%ebx),%eax
f0103780:	50                   	push   %eax
f0103781:	e8 a1 fe ff ff       	call   f0103627 <cprintf>
}
f0103786:	83 c4 10             	add    $0x10,%esp
f0103789:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010378c:	5b                   	pop    %ebx
f010378d:	5e                   	pop    %esi
f010378e:	5d                   	pop    %ebp
f010378f:	c3                   	ret    

f0103790 <print_trapframe>:
{
f0103790:	55                   	push   %ebp
f0103791:	89 e5                	mov    %esp,%ebp
f0103793:	57                   	push   %edi
f0103794:	56                   	push   %esi
f0103795:	53                   	push   %ebx
f0103796:	83 ec 14             	sub    $0x14,%esp
f0103799:	e8 c9 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010379e:	81 c3 ca b0 07 00    	add    $0x7b0ca,%ebx
f01037a4:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f01037a7:	56                   	push   %esi
f01037a8:	8d 83 37 74 f8 ff    	lea    -0x78bc9(%ebx),%eax
f01037ae:	50                   	push   %eax
f01037af:	e8 73 fe ff ff       	call   f0103627 <cprintf>
	print_regs(&tf->tf_regs);
f01037b4:	89 34 24             	mov    %esi,(%esp)
f01037b7:	e8 28 ff ff ff       	call   f01036e4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01037bc:	83 c4 08             	add    $0x8,%esp
f01037bf:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f01037c3:	50                   	push   %eax
f01037c4:	8d 83 52 73 f8 ff    	lea    -0x78cae(%ebx),%eax
f01037ca:	50                   	push   %eax
f01037cb:	e8 57 fe ff ff       	call   f0103627 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01037d0:	83 c4 08             	add    $0x8,%esp
f01037d3:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f01037d7:	50                   	push   %eax
f01037d8:	8d 83 65 73 f8 ff    	lea    -0x78c9b(%ebx),%eax
f01037de:	50                   	push   %eax
f01037df:	e8 43 fe ff ff       	call   f0103627 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037e4:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f01037e7:	83 c4 10             	add    $0x10,%esp
f01037ea:	83 fa 13             	cmp    $0x13,%edx
f01037ed:	0f 86 e2 00 00 00    	jbe    f01038d5 <print_trapframe+0x145>
		return "System call";
f01037f3:	83 fa 30             	cmp    $0x30,%edx
f01037f6:	8d 83 10 73 f8 ff    	lea    -0x78cf0(%ebx),%eax
f01037fc:	8d 8b 1f 73 f8 ff    	lea    -0x78ce1(%ebx),%ecx
f0103802:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103805:	83 ec 04             	sub    $0x4,%esp
f0103808:	50                   	push   %eax
f0103809:	52                   	push   %edx
f010380a:	8d 83 78 73 f8 ff    	lea    -0x78c88(%ebx),%eax
f0103810:	50                   	push   %eax
f0103811:	e8 11 fe ff ff       	call   f0103627 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103816:	83 c4 10             	add    $0x10,%esp
f0103819:	39 b3 f8 22 00 00    	cmp    %esi,0x22f8(%ebx)
f010381f:	0f 84 bc 00 00 00    	je     f01038e1 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0103825:	83 ec 08             	sub    $0x8,%esp
f0103828:	ff 76 2c             	push   0x2c(%esi)
f010382b:	8d 83 99 73 f8 ff    	lea    -0x78c67(%ebx),%eax
f0103831:	50                   	push   %eax
f0103832:	e8 f0 fd ff ff       	call   f0103627 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103837:	83 c4 10             	add    $0x10,%esp
f010383a:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010383e:	0f 85 c2 00 00 00    	jne    f0103906 <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103844:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103847:	a8 01                	test   $0x1,%al
f0103849:	8d 8b 2b 73 f8 ff    	lea    -0x78cd5(%ebx),%ecx
f010384f:	8d 93 36 73 f8 ff    	lea    -0x78cca(%ebx),%edx
f0103855:	0f 44 ca             	cmove  %edx,%ecx
f0103858:	a8 02                	test   $0x2,%al
f010385a:	8d 93 42 73 f8 ff    	lea    -0x78cbe(%ebx),%edx
f0103860:	8d bb 48 73 f8 ff    	lea    -0x78cb8(%ebx),%edi
f0103866:	0f 44 d7             	cmove  %edi,%edx
f0103869:	a8 04                	test   $0x4,%al
f010386b:	8d 83 4d 73 f8 ff    	lea    -0x78cb3(%ebx),%eax
f0103871:	8d bb 62 74 f8 ff    	lea    -0x78b9e(%ebx),%edi
f0103877:	0f 44 c7             	cmove  %edi,%eax
f010387a:	51                   	push   %ecx
f010387b:	52                   	push   %edx
f010387c:	50                   	push   %eax
f010387d:	8d 83 a7 73 f8 ff    	lea    -0x78c59(%ebx),%eax
f0103883:	50                   	push   %eax
f0103884:	e8 9e fd ff ff       	call   f0103627 <cprintf>
f0103889:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010388c:	83 ec 08             	sub    $0x8,%esp
f010388f:	ff 76 30             	push   0x30(%esi)
f0103892:	8d 83 b6 73 f8 ff    	lea    -0x78c4a(%ebx),%eax
f0103898:	50                   	push   %eax
f0103899:	e8 89 fd ff ff       	call   f0103627 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010389e:	83 c4 08             	add    $0x8,%esp
f01038a1:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01038a5:	50                   	push   %eax
f01038a6:	8d 83 c5 73 f8 ff    	lea    -0x78c3b(%ebx),%eax
f01038ac:	50                   	push   %eax
f01038ad:	e8 75 fd ff ff       	call   f0103627 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01038b2:	83 c4 08             	add    $0x8,%esp
f01038b5:	ff 76 38             	push   0x38(%esi)
f01038b8:	8d 83 d8 73 f8 ff    	lea    -0x78c28(%ebx),%eax
f01038be:	50                   	push   %eax
f01038bf:	e8 63 fd ff ff       	call   f0103627 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01038c4:	83 c4 10             	add    $0x10,%esp
f01038c7:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01038cb:	75 50                	jne    f010391d <print_trapframe+0x18d>
}
f01038cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038d0:	5b                   	pop    %ebx
f01038d1:	5e                   	pop    %esi
f01038d2:	5f                   	pop    %edi
f01038d3:	5d                   	pop    %ebp
f01038d4:	c3                   	ret    
		return excnames[trapno];
f01038d5:	8b 84 93 f8 17 00 00 	mov    0x17f8(%ebx,%edx,4),%eax
f01038dc:	e9 24 ff ff ff       	jmp    f0103805 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01038e1:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01038e5:	0f 85 3a ff ff ff    	jne    f0103825 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01038eb:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01038ee:	83 ec 08             	sub    $0x8,%esp
f01038f1:	50                   	push   %eax
f01038f2:	8d 83 8a 73 f8 ff    	lea    -0x78c76(%ebx),%eax
f01038f8:	50                   	push   %eax
f01038f9:	e8 29 fd ff ff       	call   f0103627 <cprintf>
f01038fe:	83 c4 10             	add    $0x10,%esp
f0103901:	e9 1f ff ff ff       	jmp    f0103825 <print_trapframe+0x95>
		cprintf("\n");
f0103906:	83 ec 0c             	sub    $0xc,%esp
f0103909:	8d 83 01 6a f8 ff    	lea    -0x795ff(%ebx),%eax
f010390f:	50                   	push   %eax
f0103910:	e8 12 fd ff ff       	call   f0103627 <cprintf>
f0103915:	83 c4 10             	add    $0x10,%esp
f0103918:	e9 6f ff ff ff       	jmp    f010388c <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010391d:	83 ec 08             	sub    $0x8,%esp
f0103920:	ff 76 3c             	push   0x3c(%esi)
f0103923:	8d 83 e7 73 f8 ff    	lea    -0x78c19(%ebx),%eax
f0103929:	50                   	push   %eax
f010392a:	e8 f8 fc ff ff       	call   f0103627 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010392f:	83 c4 08             	add    $0x8,%esp
f0103932:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103936:	50                   	push   %eax
f0103937:	8d 83 f6 73 f8 ff    	lea    -0x78c0a(%ebx),%eax
f010393d:	50                   	push   %eax
f010393e:	e8 e4 fc ff ff       	call   f0103627 <cprintf>
f0103943:	83 c4 10             	add    $0x10,%esp
}
f0103946:	eb 85                	jmp    f01038cd <print_trapframe+0x13d>

f0103948 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103948:	55                   	push   %ebp
f0103949:	89 e5                	mov    %esp,%ebp
f010394b:	57                   	push   %edi
f010394c:	56                   	push   %esi
f010394d:	53                   	push   %ebx
f010394e:	83 ec 0c             	sub    $0xc,%esp
f0103951:	e8 11 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103956:	81 c3 12 af 07 00    	add    $0x7af12,%ebx
f010395c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010395f:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103960:	9c                   	pushf  
f0103961:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103962:	f6 c4 02             	test   $0x2,%ah
f0103965:	74 1f                	je     f0103986 <trap+0x3e>
f0103967:	8d 83 09 74 f8 ff    	lea    -0x78bf7(%ebx),%eax
f010396d:	50                   	push   %eax
f010396e:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103974:	50                   	push   %eax
f0103975:	68 a8 00 00 00       	push   $0xa8
f010397a:	8d 83 22 74 f8 ff    	lea    -0x78bde(%ebx),%eax
f0103980:	50                   	push   %eax
f0103981:	e8 2b c7 ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103986:	83 ec 08             	sub    $0x8,%esp
f0103989:	56                   	push   %esi
f010398a:	8d 83 2e 74 f8 ff    	lea    -0x78bd2(%ebx),%eax
f0103990:	50                   	push   %eax
f0103991:	e8 91 fc ff ff       	call   f0103627 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103996:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010399a:	83 e0 03             	and    $0x3,%eax
f010399d:	83 c4 10             	add    $0x10,%esp
f01039a0:	66 83 f8 03          	cmp    $0x3,%ax
f01039a4:	75 1d                	jne    f01039c3 <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f01039a6:	c7 c0 4c 03 18 f0    	mov    $0xf018034c,%eax
f01039ac:	8b 00                	mov    (%eax),%eax
f01039ae:	85 c0                	test   %eax,%eax
f01039b0:	74 68                	je     f0103a1a <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01039b2:	b9 11 00 00 00       	mov    $0x11,%ecx
f01039b7:	89 c7                	mov    %eax,%edi
f01039b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01039bb:	c7 c0 4c 03 18 f0    	mov    $0xf018034c,%eax
f01039c1:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01039c3:	89 b3 f8 22 00 00    	mov    %esi,0x22f8(%ebx)
	print_trapframe(tf);
f01039c9:	83 ec 0c             	sub    $0xc,%esp
f01039cc:	56                   	push   %esi
f01039cd:	e8 be fd ff ff       	call   f0103790 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01039d2:	83 c4 10             	add    $0x10,%esp
f01039d5:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01039da:	74 5d                	je     f0103a39 <trap+0xf1>
		env_destroy(curenv);
f01039dc:	83 ec 0c             	sub    $0xc,%esp
f01039df:	c7 c6 4c 03 18 f0    	mov    $0xf018034c,%esi
f01039e5:	ff 36                	push   (%esi)
f01039e7:	e8 1c fb ff ff       	call   f0103508 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01039ec:	8b 06                	mov    (%esi),%eax
f01039ee:	83 c4 10             	add    $0x10,%esp
f01039f1:	85 c0                	test   %eax,%eax
f01039f3:	74 06                	je     f01039fb <trap+0xb3>
f01039f5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01039f9:	74 59                	je     f0103a54 <trap+0x10c>
f01039fb:	8d 83 ac 75 f8 ff    	lea    -0x78a54(%ebx),%eax
f0103a01:	50                   	push   %eax
f0103a02:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103a08:	50                   	push   %eax
f0103a09:	68 c0 00 00 00       	push   $0xc0
f0103a0e:	8d 83 22 74 f8 ff    	lea    -0x78bde(%ebx),%eax
f0103a14:	50                   	push   %eax
f0103a15:	e8 97 c6 ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0103a1a:	8d 83 49 74 f8 ff    	lea    -0x78bb7(%ebx),%eax
f0103a20:	50                   	push   %eax
f0103a21:	8d 83 52 67 f8 ff    	lea    -0x798ae(%ebx),%eax
f0103a27:	50                   	push   %eax
f0103a28:	68 ae 00 00 00       	push   $0xae
f0103a2d:	8d 83 22 74 f8 ff    	lea    -0x78bde(%ebx),%eax
f0103a33:	50                   	push   %eax
f0103a34:	e8 78 c6 ff ff       	call   f01000b1 <_panic>
		panic("unhandled trap in kernel");
f0103a39:	83 ec 04             	sub    $0x4,%esp
f0103a3c:	8d 83 50 74 f8 ff    	lea    -0x78bb0(%ebx),%eax
f0103a42:	50                   	push   %eax
f0103a43:	68 97 00 00 00       	push   $0x97
f0103a48:	8d 83 22 74 f8 ff    	lea    -0x78bde(%ebx),%eax
f0103a4e:	50                   	push   %eax
f0103a4f:	e8 5d c6 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0103a54:	83 ec 0c             	sub    $0xc,%esp
f0103a57:	50                   	push   %eax
f0103a58:	e8 19 fb ff ff       	call   f0103576 <env_run>

f0103a5d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103a5d:	55                   	push   %ebp
f0103a5e:	89 e5                	mov    %esp,%ebp
f0103a60:	57                   	push   %edi
f0103a61:	56                   	push   %esi
f0103a62:	53                   	push   %ebx
f0103a63:	83 ec 0c             	sub    $0xc,%esp
f0103a66:	e8 fc c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a6b:	81 c3 fd ad 07 00    	add    $0x7adfd,%ebx
f0103a71:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103a74:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103a77:	ff 77 30             	push   0x30(%edi)
f0103a7a:	50                   	push   %eax
f0103a7b:	c7 c6 4c 03 18 f0    	mov    $0xf018034c,%esi
f0103a81:	8b 06                	mov    (%esi),%eax
f0103a83:	ff 70 48             	push   0x48(%eax)
f0103a86:	8d 83 d8 75 f8 ff    	lea    -0x78a28(%ebx),%eax
f0103a8c:	50                   	push   %eax
f0103a8d:	e8 95 fb ff ff       	call   f0103627 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103a92:	89 3c 24             	mov    %edi,(%esp)
f0103a95:	e8 f6 fc ff ff       	call   f0103790 <print_trapframe>
	env_destroy(curenv);
f0103a9a:	83 c4 04             	add    $0x4,%esp
f0103a9d:	ff 36                	push   (%esi)
f0103a9f:	e8 64 fa ff ff       	call   f0103508 <env_destroy>
}
f0103aa4:	83 c4 10             	add    $0x10,%esp
f0103aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103aaa:	5b                   	pop    %ebx
f0103aab:	5e                   	pop    %esi
f0103aac:	5f                   	pop    %edi
f0103aad:	5d                   	pop    %ebp
f0103aae:	c3                   	ret    

f0103aaf <syscall>:
f0103aaf:	55                   	push   %ebp
f0103ab0:	89 e5                	mov    %esp,%ebp
f0103ab2:	53                   	push   %ebx
f0103ab3:	83 ec 08             	sub    $0x8,%esp
f0103ab6:	e8 ac c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103abb:	81 c3 ad ad 07 00    	add    $0x7adad,%ebx
f0103ac1:	8d 83 fb 75 f8 ff    	lea    -0x78a05(%ebx),%eax
f0103ac7:	50                   	push   %eax
f0103ac8:	6a 49                	push   $0x49
f0103aca:	8d 83 13 76 f8 ff    	lea    -0x789ed(%ebx),%eax
f0103ad0:	50                   	push   %eax
f0103ad1:	e8 db c5 ff ff       	call   f01000b1 <_panic>

f0103ad6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103ad6:	55                   	push   %ebp
f0103ad7:	89 e5                	mov    %esp,%ebp
f0103ad9:	57                   	push   %edi
f0103ada:	56                   	push   %esi
f0103adb:	53                   	push   %ebx
f0103adc:	83 ec 14             	sub    $0x14,%esp
f0103adf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ae2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103ae5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ae8:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103aeb:	8b 1a                	mov    (%edx),%ebx
f0103aed:	8b 01                	mov    (%ecx),%eax
f0103aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103af2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103af9:	eb 2f                	jmp    f0103b2a <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103afb:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103afe:	39 c3                	cmp    %eax,%ebx
f0103b00:	7f 4e                	jg     f0103b50 <stab_binsearch+0x7a>
f0103b02:	0f b6 0a             	movzbl (%edx),%ecx
f0103b05:	83 ea 0c             	sub    $0xc,%edx
f0103b08:	39 f1                	cmp    %esi,%ecx
f0103b0a:	75 ef                	jne    f0103afb <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103b0c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b0f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103b12:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103b16:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103b19:	73 3a                	jae    f0103b55 <stab_binsearch+0x7f>
			*region_left = m;
f0103b1b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103b1e:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103b20:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103b23:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103b2a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103b2d:	7f 53                	jg     f0103b82 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0103b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b32:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0103b35:	89 d0                	mov    %edx,%eax
f0103b37:	c1 e8 1f             	shr    $0x1f,%eax
f0103b3a:	01 d0                	add    %edx,%eax
f0103b3c:	89 c7                	mov    %eax,%edi
f0103b3e:	d1 ff                	sar    %edi
f0103b40:	83 e0 fe             	and    $0xfffffffe,%eax
f0103b43:	01 f8                	add    %edi,%eax
f0103b45:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103b48:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103b4c:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103b4e:	eb ae                	jmp    f0103afe <stab_binsearch+0x28>
			l = true_m + 1;
f0103b50:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103b53:	eb d5                	jmp    f0103b2a <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103b55:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103b58:	76 14                	jbe    f0103b6e <stab_binsearch+0x98>
			*region_right = m - 1;
f0103b5a:	83 e8 01             	sub    $0x1,%eax
f0103b5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103b60:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103b63:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103b65:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103b6c:	eb bc                	jmp    f0103b2a <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103b6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b71:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103b73:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103b77:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103b79:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103b80:	eb a8                	jmp    f0103b2a <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103b82:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103b86:	75 15                	jne    f0103b9d <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103b88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b8b:	8b 00                	mov    (%eax),%eax
f0103b8d:	83 e8 01             	sub    $0x1,%eax
f0103b90:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103b93:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103b95:	83 c4 14             	add    $0x14,%esp
f0103b98:	5b                   	pop    %ebx
f0103b99:	5e                   	pop    %esi
f0103b9a:	5f                   	pop    %edi
f0103b9b:	5d                   	pop    %ebp
f0103b9c:	c3                   	ret    
		for (l = *region_right;
f0103b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ba0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103ba2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ba5:	8b 0f                	mov    (%edi),%ecx
f0103ba7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103baa:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103bad:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103bb1:	39 c1                	cmp    %eax,%ecx
f0103bb3:	7d 0f                	jge    f0103bc4 <stab_binsearch+0xee>
f0103bb5:	0f b6 1a             	movzbl (%edx),%ebx
f0103bb8:	83 ea 0c             	sub    $0xc,%edx
f0103bbb:	39 f3                	cmp    %esi,%ebx
f0103bbd:	74 05                	je     f0103bc4 <stab_binsearch+0xee>
		     l--)
f0103bbf:	83 e8 01             	sub    $0x1,%eax
f0103bc2:	eb ed                	jmp    f0103bb1 <stab_binsearch+0xdb>
		*region_left = l;
f0103bc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103bc7:	89 07                	mov    %eax,(%edi)
}
f0103bc9:	eb ca                	jmp    f0103b95 <stab_binsearch+0xbf>

f0103bcb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103bcb:	55                   	push   %ebp
f0103bcc:	89 e5                	mov    %esp,%ebp
f0103bce:	57                   	push   %edi
f0103bcf:	56                   	push   %esi
f0103bd0:	53                   	push   %ebx
f0103bd1:	83 ec 4c             	sub    $0x4c,%esp
f0103bd4:	e8 8e c5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103bd9:	81 c3 8f ac 07 00    	add    $0x7ac8f,%ebx
f0103bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103be2:	8d 83 22 76 f8 ff    	lea    -0x789de(%ebx),%eax
f0103be8:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103bea:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103bf1:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103bf4:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103bfb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bfe:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0103c01:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103c08:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103c0d:	0f 87 29 01 00 00    	ja     f0103d3c <debuginfo_eip+0x171>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103c13:	a1 00 00 20 00       	mov    0x200000,%eax
f0103c18:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103c1b:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103c20:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103c26:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0103c29:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103c2f:	89 7d c0             	mov    %edi,-0x40(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103c32:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103c35:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0103c38:	0f 83 99 01 00 00    	jae    f0103dd7 <debuginfo_eip+0x20c>
f0103c3e:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103c42:	0f 85 96 01 00 00    	jne    f0103dde <debuginfo_eip+0x213>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103c48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103c4f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103c52:	29 f8                	sub    %edi,%eax
f0103c54:	c1 f8 02             	sar    $0x2,%eax
f0103c57:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103c5d:	83 e8 01             	sub    $0x1,%eax
f0103c60:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103c63:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103c66:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103c69:	ff 75 08             	push   0x8(%ebp)
f0103c6c:	6a 64                	push   $0x64
f0103c6e:	89 f8                	mov    %edi,%eax
f0103c70:	e8 61 fe ff ff       	call   f0103ad6 <stab_binsearch>
	if (lfile == 0)
f0103c75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c78:	83 c4 08             	add    $0x8,%esp
f0103c7b:	85 ff                	test   %edi,%edi
f0103c7d:	0f 84 62 01 00 00    	je     f0103de5 <debuginfo_eip+0x21a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103c83:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0103c86:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c89:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0103c8c:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103c8f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103c92:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103c95:	ff 75 08             	push   0x8(%ebp)
f0103c98:	6a 24                	push   $0x24
f0103c9a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103c9d:	e8 34 fe ff ff       	call   f0103ad6 <stab_binsearch>

	if (lfun <= rfun) {
f0103ca2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ca5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0103ca8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103cab:	89 c1                	mov    %eax,%ecx
f0103cad:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0103cb0:	83 c4 08             	add    $0x8,%esp
f0103cb3:	89 f8                	mov    %edi,%eax
f0103cb5:	39 ca                	cmp    %ecx,%edx
f0103cb7:	7f 2d                	jg     f0103ce6 <debuginfo_eip+0x11b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103cb9:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103cbc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103cbf:	8d 14 82             	lea    (%edx,%eax,4),%edx
f0103cc2:	8b 02                	mov    (%edx),%eax
f0103cc4:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103cc7:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0103cca:	39 c8                	cmp    %ecx,%eax
f0103ccc:	73 06                	jae    f0103cd4 <debuginfo_eip+0x109>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103cce:	03 45 bc             	add    -0x44(%ebp),%eax
f0103cd1:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103cd4:	8b 42 08             	mov    0x8(%edx),%eax
f0103cd7:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103cda:	29 45 08             	sub    %eax,0x8(%ebp)
f0103cdd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0103ce0:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0103ce3:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103ce6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103ce9:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103cec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103cef:	83 ec 08             	sub    $0x8,%esp
f0103cf2:	6a 3a                	push   $0x3a
f0103cf4:	ff 76 08             	push   0x8(%esi)
f0103cf7:	e8 8d 09 00 00       	call   f0104689 <strfind>
f0103cfc:	2b 46 08             	sub    0x8(%esi),%eax
f0103cff:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103d02:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103d05:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103d08:	83 c4 08             	add    $0x8,%esp
f0103d0b:	ff 75 08             	push   0x8(%ebp)
f0103d0e:	6a 44                	push   $0x44
f0103d10:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0103d13:	89 d8                	mov    %ebx,%eax
f0103d15:	e8 bc fd ff ff       	call   f0103ad6 <stab_binsearch>
	if (lline <= rline) {
f0103d1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d1d:	83 c4 10             	add    $0x10,%esp
f0103d20:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103d23:	0f 8f c3 00 00 00    	jg     f0103dec <debuginfo_eip+0x221>
    		info->eip_line = stabs[lline].n_desc;
f0103d29:	89 c2                	mov    %eax,%edx
f0103d2b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103d2e:	0f b7 4c 83 06       	movzwl 0x6(%ebx,%eax,4),%ecx
f0103d33:	89 4e 04             	mov    %ecx,0x4(%esi)
f0103d36:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103d3a:	eb 2c                	jmp    f0103d68 <debuginfo_eip+0x19d>
		stabstr_end = __STABSTR_END__;
f0103d3c:	c7 c0 17 11 11 f0    	mov    $0xf0111117,%eax
f0103d42:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103d45:	c7 c0 f5 d8 10 f0    	mov    $0xf010d8f5,%eax
f0103d4b:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = __STAB_END__;
f0103d4e:	c7 c0 f4 d8 10 f0    	mov    $0xf010d8f4,%eax
		stabs = __STAB_BEGIN__;
f0103d54:	c7 c7 88 60 10 f0    	mov    $0xf0106088,%edi
f0103d5a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0103d5d:	e9 d0 fe ff ff       	jmp    f0103c32 <debuginfo_eip+0x67>
f0103d62:	83 ea 01             	sub    $0x1,%edx
f0103d65:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103d68:	39 d7                	cmp    %edx,%edi
f0103d6a:	7f 2e                	jg     f0103d9a <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f0103d6c:	0f b6 08             	movzbl (%eax),%ecx
f0103d6f:	80 f9 84             	cmp    $0x84,%cl
f0103d72:	74 0b                	je     f0103d7f <debuginfo_eip+0x1b4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103d74:	80 f9 64             	cmp    $0x64,%cl
f0103d77:	75 e9                	jne    f0103d62 <debuginfo_eip+0x197>
f0103d79:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0103d7d:	74 e3                	je     f0103d62 <debuginfo_eip+0x197>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103d7f:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103d82:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103d85:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103d88:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103d8b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103d8e:	29 f8                	sub    %edi,%eax
f0103d90:	39 c2                	cmp    %eax,%edx
f0103d92:	73 06                	jae    f0103d9a <debuginfo_eip+0x1cf>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103d94:	89 f8                	mov    %edi,%eax
f0103d96:	01 d0                	add    %edx,%eax
f0103d98:	89 06                	mov    %eax,(%esi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103d9a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103d9f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103da2:	8b 5d b0             	mov    -0x50(%ebp),%ebx
f0103da5:	39 df                	cmp    %ebx,%edi
f0103da7:	7d 4f                	jge    f0103df8 <debuginfo_eip+0x22d>
		for (lline = lfun + 1;
f0103da9:	83 c7 01             	add    $0x1,%edi
f0103dac:	89 f8                	mov    %edi,%eax
f0103dae:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0103db1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103db4:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103db8:	eb 04                	jmp    f0103dbe <debuginfo_eip+0x1f3>
			info->eip_fn_narg++;
f0103dba:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103dbe:	39 c3                	cmp    %eax,%ebx
f0103dc0:	7e 31                	jle    f0103df3 <debuginfo_eip+0x228>
f0103dc2:	0f b6 0a             	movzbl (%edx),%ecx
f0103dc5:	83 c0 01             	add    $0x1,%eax
f0103dc8:	83 c2 0c             	add    $0xc,%edx
f0103dcb:	80 f9 a0             	cmp    $0xa0,%cl
f0103dce:	74 ea                	je     f0103dba <debuginfo_eip+0x1ef>
	return 0;
f0103dd0:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dd5:	eb 21                	jmp    f0103df8 <debuginfo_eip+0x22d>
		return -1;
f0103dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ddc:	eb 1a                	jmp    f0103df8 <debuginfo_eip+0x22d>
f0103dde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103de3:	eb 13                	jmp    f0103df8 <debuginfo_eip+0x22d>
		return -1;
f0103de5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103dea:	eb 0c                	jmp    f0103df8 <debuginfo_eip+0x22d>
    		return -1;
f0103dec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103df1:	eb 05                	jmp    f0103df8 <debuginfo_eip+0x22d>
	return 0;
f0103df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103dfb:	5b                   	pop    %ebx
f0103dfc:	5e                   	pop    %esi
f0103dfd:	5f                   	pop    %edi
f0103dfe:	5d                   	pop    %ebp
f0103dff:	c3                   	ret    

f0103e00 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103e00:	55                   	push   %ebp
f0103e01:	89 e5                	mov    %esp,%ebp
f0103e03:	57                   	push   %edi
f0103e04:	56                   	push   %esi
f0103e05:	53                   	push   %ebx
f0103e06:	83 ec 2c             	sub    $0x2c,%esp
f0103e09:	e8 dd f2 ff ff       	call   f01030eb <__x86.get_pc_thunk.cx>
f0103e0e:	81 c1 5a aa 07 00    	add    $0x7aa5a,%ecx
f0103e14:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103e17:	89 c7                	mov    %eax,%edi
f0103e19:	89 d6                	mov    %edx,%esi
f0103e1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e21:	89 d1                	mov    %edx,%ecx
f0103e23:	89 c2                	mov    %eax,%edx
f0103e25:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103e28:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103e2b:	8b 45 10             	mov    0x10(%ebp),%eax
f0103e2e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103e31:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103e34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103e3b:	39 c2                	cmp    %eax,%edx
f0103e3d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103e40:	72 41                	jb     f0103e83 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103e42:	83 ec 0c             	sub    $0xc,%esp
f0103e45:	ff 75 18             	push   0x18(%ebp)
f0103e48:	83 eb 01             	sub    $0x1,%ebx
f0103e4b:	53                   	push   %ebx
f0103e4c:	50                   	push   %eax
f0103e4d:	83 ec 08             	sub    $0x8,%esp
f0103e50:	ff 75 e4             	push   -0x1c(%ebp)
f0103e53:	ff 75 e0             	push   -0x20(%ebp)
f0103e56:	ff 75 d4             	push   -0x2c(%ebp)
f0103e59:	ff 75 d0             	push   -0x30(%ebp)
f0103e5c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103e5f:	e8 3c 0a 00 00       	call   f01048a0 <__udivdi3>
f0103e64:	83 c4 18             	add    $0x18,%esp
f0103e67:	52                   	push   %edx
f0103e68:	50                   	push   %eax
f0103e69:	89 f2                	mov    %esi,%edx
f0103e6b:	89 f8                	mov    %edi,%eax
f0103e6d:	e8 8e ff ff ff       	call   f0103e00 <printnum>
f0103e72:	83 c4 20             	add    $0x20,%esp
f0103e75:	eb 13                	jmp    f0103e8a <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103e77:	83 ec 08             	sub    $0x8,%esp
f0103e7a:	56                   	push   %esi
f0103e7b:	ff 75 18             	push   0x18(%ebp)
f0103e7e:	ff d7                	call   *%edi
f0103e80:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103e83:	83 eb 01             	sub    $0x1,%ebx
f0103e86:	85 db                	test   %ebx,%ebx
f0103e88:	7f ed                	jg     f0103e77 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103e8a:	83 ec 08             	sub    $0x8,%esp
f0103e8d:	56                   	push   %esi
f0103e8e:	83 ec 04             	sub    $0x4,%esp
f0103e91:	ff 75 e4             	push   -0x1c(%ebp)
f0103e94:	ff 75 e0             	push   -0x20(%ebp)
f0103e97:	ff 75 d4             	push   -0x2c(%ebp)
f0103e9a:	ff 75 d0             	push   -0x30(%ebp)
f0103e9d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103ea0:	e8 1b 0b 00 00       	call   f01049c0 <__umoddi3>
f0103ea5:	83 c4 14             	add    $0x14,%esp
f0103ea8:	0f be 84 03 2c 76 f8 	movsbl -0x789d4(%ebx,%eax,1),%eax
f0103eaf:	ff 
f0103eb0:	50                   	push   %eax
f0103eb1:	ff d7                	call   *%edi
}
f0103eb3:	83 c4 10             	add    $0x10,%esp
f0103eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103eb9:	5b                   	pop    %ebx
f0103eba:	5e                   	pop    %esi
f0103ebb:	5f                   	pop    %edi
f0103ebc:	5d                   	pop    %ebp
f0103ebd:	c3                   	ret    

f0103ebe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103ebe:	55                   	push   %ebp
f0103ebf:	89 e5                	mov    %esp,%ebp
f0103ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103ec4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103ec8:	8b 10                	mov    (%eax),%edx
f0103eca:	3b 50 04             	cmp    0x4(%eax),%edx
f0103ecd:	73 0a                	jae    f0103ed9 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103ecf:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103ed2:	89 08                	mov    %ecx,(%eax)
f0103ed4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ed7:	88 02                	mov    %al,(%edx)
}
f0103ed9:	5d                   	pop    %ebp
f0103eda:	c3                   	ret    

f0103edb <printfmt>:
{
f0103edb:	55                   	push   %ebp
f0103edc:	89 e5                	mov    %esp,%ebp
f0103ede:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103ee1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103ee4:	50                   	push   %eax
f0103ee5:	ff 75 10             	push   0x10(%ebp)
f0103ee8:	ff 75 0c             	push   0xc(%ebp)
f0103eeb:	ff 75 08             	push   0x8(%ebp)
f0103eee:	e8 05 00 00 00       	call   f0103ef8 <vprintfmt>
}
f0103ef3:	83 c4 10             	add    $0x10,%esp
f0103ef6:	c9                   	leave  
f0103ef7:	c3                   	ret    

f0103ef8 <vprintfmt>:
{
f0103ef8:	55                   	push   %ebp
f0103ef9:	89 e5                	mov    %esp,%ebp
f0103efb:	57                   	push   %edi
f0103efc:	56                   	push   %esi
f0103efd:	53                   	push   %ebx
f0103efe:	83 ec 3c             	sub    $0x3c,%esp
f0103f01:	e8 f3 c7 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103f06:	05 62 a9 07 00       	add    $0x7a962,%eax
f0103f0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103f0e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f11:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103f17:	8d 80 48 18 00 00    	lea    0x1848(%eax),%eax
f0103f1d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103f20:	eb 0a                	jmp    f0103f2c <vprintfmt+0x34>
			putch(ch, putdat);
f0103f22:	83 ec 08             	sub    $0x8,%esp
f0103f25:	57                   	push   %edi
f0103f26:	50                   	push   %eax
f0103f27:	ff d6                	call   *%esi
f0103f29:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103f2c:	83 c3 01             	add    $0x1,%ebx
f0103f2f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103f33:	83 f8 25             	cmp    $0x25,%eax
f0103f36:	74 0c                	je     f0103f44 <vprintfmt+0x4c>
			if (ch == '\0')
f0103f38:	85 c0                	test   %eax,%eax
f0103f3a:	75 e6                	jne    f0103f22 <vprintfmt+0x2a>
}
f0103f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f3f:	5b                   	pop    %ebx
f0103f40:	5e                   	pop    %esi
f0103f41:	5f                   	pop    %edi
f0103f42:	5d                   	pop    %ebp
f0103f43:	c3                   	ret    
		padc = ' ';
f0103f44:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0103f48:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0103f4f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103f56:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103f5d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f62:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103f65:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103f68:	8d 43 01             	lea    0x1(%ebx),%eax
f0103f6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f6e:	0f b6 13             	movzbl (%ebx),%edx
f0103f71:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103f74:	3c 55                	cmp    $0x55,%al
f0103f76:	0f 87 fd 03 00 00    	ja     f0104379 <.L20>
f0103f7c:	0f b6 c0             	movzbl %al,%eax
f0103f7f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f82:	89 ce                	mov    %ecx,%esi
f0103f84:	03 b4 81 b8 76 f8 ff 	add    -0x78948(%ecx,%eax,4),%esi
f0103f8b:	ff e6                	jmp    *%esi

f0103f8d <.L68>:
f0103f8d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0103f90:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0103f94:	eb d2                	jmp    f0103f68 <vprintfmt+0x70>

f0103f96 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0103f96:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103f99:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0103f9d:	eb c9                	jmp    f0103f68 <vprintfmt+0x70>

f0103f9f <.L31>:
f0103f9f:	0f b6 d2             	movzbl %dl,%edx
f0103fa2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0103fa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103faa:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0103fad:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103fb0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103fb4:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0103fb7:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103fba:	83 f9 09             	cmp    $0x9,%ecx
f0103fbd:	77 58                	ja     f0104017 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0103fbf:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0103fc2:	eb e9                	jmp    f0103fad <.L31+0xe>

f0103fc4 <.L34>:
			precision = va_arg(ap, int);
f0103fc4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fc7:	8b 00                	mov    (%eax),%eax
f0103fc9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103fcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fcf:	8d 40 04             	lea    0x4(%eax),%eax
f0103fd2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103fd5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0103fd8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103fdc:	79 8a                	jns    f0103f68 <vprintfmt+0x70>
				width = precision, precision = -1;
f0103fde:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103fe4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103feb:	e9 78 ff ff ff       	jmp    f0103f68 <vprintfmt+0x70>

f0103ff0 <.L33>:
f0103ff0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ff3:	85 d2                	test   %edx,%edx
f0103ff5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ffa:	0f 49 c2             	cmovns %edx,%eax
f0103ffd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104000:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0104003:	e9 60 ff ff ff       	jmp    f0103f68 <vprintfmt+0x70>

f0104008 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0104008:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010400b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0104012:	e9 51 ff ff ff       	jmp    f0103f68 <vprintfmt+0x70>
f0104017:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010401a:	89 75 08             	mov    %esi,0x8(%ebp)
f010401d:	eb b9                	jmp    f0103fd8 <.L34+0x14>

f010401f <.L27>:
			lflag++;
f010401f:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104023:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0104026:	e9 3d ff ff ff       	jmp    f0103f68 <vprintfmt+0x70>

f010402b <.L30>:
			putch(va_arg(ap, int), putdat);
f010402b:	8b 75 08             	mov    0x8(%ebp),%esi
f010402e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104031:	8d 58 04             	lea    0x4(%eax),%ebx
f0104034:	83 ec 08             	sub    $0x8,%esp
f0104037:	57                   	push   %edi
f0104038:	ff 30                	push   (%eax)
f010403a:	ff d6                	call   *%esi
			break;
f010403c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010403f:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0104042:	e9 c8 02 00 00       	jmp    f010430f <.L25+0x45>

f0104047 <.L28>:
			err = va_arg(ap, int);
f0104047:	8b 75 08             	mov    0x8(%ebp),%esi
f010404a:	8b 45 14             	mov    0x14(%ebp),%eax
f010404d:	8d 58 04             	lea    0x4(%eax),%ebx
f0104050:	8b 10                	mov    (%eax),%edx
f0104052:	89 d0                	mov    %edx,%eax
f0104054:	f7 d8                	neg    %eax
f0104056:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104059:	83 f8 06             	cmp    $0x6,%eax
f010405c:	7f 27                	jg     f0104085 <.L28+0x3e>
f010405e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104061:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0104064:	85 d2                	test   %edx,%edx
f0104066:	74 1d                	je     f0104085 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0104068:	52                   	push   %edx
f0104069:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010406c:	8d 80 64 67 f8 ff    	lea    -0x7989c(%eax),%eax
f0104072:	50                   	push   %eax
f0104073:	57                   	push   %edi
f0104074:	56                   	push   %esi
f0104075:	e8 61 fe ff ff       	call   f0103edb <printfmt>
f010407a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010407d:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104080:	e9 8a 02 00 00       	jmp    f010430f <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104085:	50                   	push   %eax
f0104086:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104089:	8d 80 44 76 f8 ff    	lea    -0x789bc(%eax),%eax
f010408f:	50                   	push   %eax
f0104090:	57                   	push   %edi
f0104091:	56                   	push   %esi
f0104092:	e8 44 fe ff ff       	call   f0103edb <printfmt>
f0104097:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010409a:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010409d:	e9 6d 02 00 00       	jmp    f010430f <.L25+0x45>

f01040a2 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01040a2:	8b 75 08             	mov    0x8(%ebp),%esi
f01040a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01040a8:	83 c0 04             	add    $0x4,%eax
f01040ab:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01040ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01040b1:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01040b3:	85 d2                	test   %edx,%edx
f01040b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040b8:	8d 80 3d 76 f8 ff    	lea    -0x789c3(%eax),%eax
f01040be:	0f 45 c2             	cmovne %edx,%eax
f01040c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01040c4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01040c8:	7e 06                	jle    f01040d0 <.L24+0x2e>
f01040ca:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01040ce:	75 0d                	jne    f01040dd <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01040d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01040d3:	89 c3                	mov    %eax,%ebx
f01040d5:	03 45 d4             	add    -0x2c(%ebp),%eax
f01040d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01040db:	eb 58                	jmp    f0104135 <.L24+0x93>
f01040dd:	83 ec 08             	sub    $0x8,%esp
f01040e0:	ff 75 d8             	push   -0x28(%ebp)
f01040e3:	ff 75 c8             	push   -0x38(%ebp)
f01040e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01040e9:	e8 44 04 00 00       	call   f0104532 <strnlen>
f01040ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01040f1:	29 c2                	sub    %eax,%edx
f01040f3:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01040f6:	83 c4 10             	add    $0x10,%esp
f01040f9:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01040fb:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01040ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104102:	eb 0f                	jmp    f0104113 <.L24+0x71>
					putch(padc, putdat);
f0104104:	83 ec 08             	sub    $0x8,%esp
f0104107:	57                   	push   %edi
f0104108:	ff 75 d4             	push   -0x2c(%ebp)
f010410b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010410d:	83 eb 01             	sub    $0x1,%ebx
f0104110:	83 c4 10             	add    $0x10,%esp
f0104113:	85 db                	test   %ebx,%ebx
f0104115:	7f ed                	jg     f0104104 <.L24+0x62>
f0104117:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010411a:	85 d2                	test   %edx,%edx
f010411c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104121:	0f 49 c2             	cmovns %edx,%eax
f0104124:	29 c2                	sub    %eax,%edx
f0104126:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104129:	eb a5                	jmp    f01040d0 <.L24+0x2e>
					putch(ch, putdat);
f010412b:	83 ec 08             	sub    $0x8,%esp
f010412e:	57                   	push   %edi
f010412f:	52                   	push   %edx
f0104130:	ff d6                	call   *%esi
f0104132:	83 c4 10             	add    $0x10,%esp
f0104135:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104138:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010413a:	83 c3 01             	add    $0x1,%ebx
f010413d:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104141:	0f be d0             	movsbl %al,%edx
f0104144:	85 d2                	test   %edx,%edx
f0104146:	74 4b                	je     f0104193 <.L24+0xf1>
f0104148:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010414c:	78 06                	js     f0104154 <.L24+0xb2>
f010414e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104152:	78 1e                	js     f0104172 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0104154:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104158:	74 d1                	je     f010412b <.L24+0x89>
f010415a:	0f be c0             	movsbl %al,%eax
f010415d:	83 e8 20             	sub    $0x20,%eax
f0104160:	83 f8 5e             	cmp    $0x5e,%eax
f0104163:	76 c6                	jbe    f010412b <.L24+0x89>
					putch('?', putdat);
f0104165:	83 ec 08             	sub    $0x8,%esp
f0104168:	57                   	push   %edi
f0104169:	6a 3f                	push   $0x3f
f010416b:	ff d6                	call   *%esi
f010416d:	83 c4 10             	add    $0x10,%esp
f0104170:	eb c3                	jmp    f0104135 <.L24+0x93>
f0104172:	89 cb                	mov    %ecx,%ebx
f0104174:	eb 0e                	jmp    f0104184 <.L24+0xe2>
				putch(' ', putdat);
f0104176:	83 ec 08             	sub    $0x8,%esp
f0104179:	57                   	push   %edi
f010417a:	6a 20                	push   $0x20
f010417c:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010417e:	83 eb 01             	sub    $0x1,%ebx
f0104181:	83 c4 10             	add    $0x10,%esp
f0104184:	85 db                	test   %ebx,%ebx
f0104186:	7f ee                	jg     f0104176 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0104188:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010418b:	89 45 14             	mov    %eax,0x14(%ebp)
f010418e:	e9 7c 01 00 00       	jmp    f010430f <.L25+0x45>
f0104193:	89 cb                	mov    %ecx,%ebx
f0104195:	eb ed                	jmp    f0104184 <.L24+0xe2>

f0104197 <.L29>:
	if (lflag >= 2)
f0104197:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010419a:	8b 75 08             	mov    0x8(%ebp),%esi
f010419d:	83 f9 01             	cmp    $0x1,%ecx
f01041a0:	7f 1b                	jg     f01041bd <.L29+0x26>
	else if (lflag)
f01041a2:	85 c9                	test   %ecx,%ecx
f01041a4:	74 63                	je     f0104209 <.L29+0x72>
		return va_arg(*ap, long);
f01041a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01041a9:	8b 00                	mov    (%eax),%eax
f01041ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041ae:	99                   	cltd   
f01041af:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01041b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01041b5:	8d 40 04             	lea    0x4(%eax),%eax
f01041b8:	89 45 14             	mov    %eax,0x14(%ebp)
f01041bb:	eb 17                	jmp    f01041d4 <.L29+0x3d>
		return va_arg(*ap, long long);
f01041bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01041c0:	8b 50 04             	mov    0x4(%eax),%edx
f01041c3:	8b 00                	mov    (%eax),%eax
f01041c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01041cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01041ce:	8d 40 08             	lea    0x8(%eax),%eax
f01041d1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01041d4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01041d7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01041da:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01041df:	85 db                	test   %ebx,%ebx
f01041e1:	0f 89 0e 01 00 00    	jns    f01042f5 <.L25+0x2b>
				putch('-', putdat);
f01041e7:	83 ec 08             	sub    $0x8,%esp
f01041ea:	57                   	push   %edi
f01041eb:	6a 2d                	push   $0x2d
f01041ed:	ff d6                	call   *%esi
				num = -(long long) num;
f01041ef:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01041f2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01041f5:	f7 d9                	neg    %ecx
f01041f7:	83 d3 00             	adc    $0x0,%ebx
f01041fa:	f7 db                	neg    %ebx
f01041fc:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01041ff:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104204:	e9 ec 00 00 00       	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, int);
f0104209:	8b 45 14             	mov    0x14(%ebp),%eax
f010420c:	8b 00                	mov    (%eax),%eax
f010420e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104211:	99                   	cltd   
f0104212:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104215:	8b 45 14             	mov    0x14(%ebp),%eax
f0104218:	8d 40 04             	lea    0x4(%eax),%eax
f010421b:	89 45 14             	mov    %eax,0x14(%ebp)
f010421e:	eb b4                	jmp    f01041d4 <.L29+0x3d>

f0104220 <.L23>:
	if (lflag >= 2)
f0104220:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104223:	8b 75 08             	mov    0x8(%ebp),%esi
f0104226:	83 f9 01             	cmp    $0x1,%ecx
f0104229:	7f 1e                	jg     f0104249 <.L23+0x29>
	else if (lflag)
f010422b:	85 c9                	test   %ecx,%ecx
f010422d:	74 32                	je     f0104261 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f010422f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104232:	8b 08                	mov    (%eax),%ecx
f0104234:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104239:	8d 40 04             	lea    0x4(%eax),%eax
f010423c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010423f:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104244:	e9 ac 00 00 00       	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104249:	8b 45 14             	mov    0x14(%ebp),%eax
f010424c:	8b 08                	mov    (%eax),%ecx
f010424e:	8b 58 04             	mov    0x4(%eax),%ebx
f0104251:	8d 40 08             	lea    0x8(%eax),%eax
f0104254:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104257:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f010425c:	e9 94 00 00 00       	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104261:	8b 45 14             	mov    0x14(%ebp),%eax
f0104264:	8b 08                	mov    (%eax),%ecx
f0104266:	bb 00 00 00 00       	mov    $0x0,%ebx
f010426b:	8d 40 04             	lea    0x4(%eax),%eax
f010426e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104271:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0104276:	eb 7d                	jmp    f01042f5 <.L25+0x2b>

f0104278 <.L26>:
	if (lflag >= 2)
f0104278:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010427b:	8b 75 08             	mov    0x8(%ebp),%esi
f010427e:	83 f9 01             	cmp    $0x1,%ecx
f0104281:	7f 1b                	jg     f010429e <.L26+0x26>
	else if (lflag)
f0104283:	85 c9                	test   %ecx,%ecx
f0104285:	74 2c                	je     f01042b3 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0104287:	8b 45 14             	mov    0x14(%ebp),%eax
f010428a:	8b 08                	mov    (%eax),%ecx
f010428c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104291:	8d 40 04             	lea    0x4(%eax),%eax
f0104294:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0104297:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f010429c:	eb 57                	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010429e:	8b 45 14             	mov    0x14(%ebp),%eax
f01042a1:	8b 08                	mov    (%eax),%ecx
f01042a3:	8b 58 04             	mov    0x4(%eax),%ebx
f01042a6:	8d 40 08             	lea    0x8(%eax),%eax
f01042a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f01042ac:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f01042b1:	eb 42                	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01042b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01042b6:	8b 08                	mov    (%eax),%ecx
f01042b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01042bd:	8d 40 04             	lea    0x4(%eax),%eax
f01042c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f01042c3:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f01042c8:	eb 2b                	jmp    f01042f5 <.L25+0x2b>

f01042ca <.L25>:
			putch('0', putdat);
f01042ca:	8b 75 08             	mov    0x8(%ebp),%esi
f01042cd:	83 ec 08             	sub    $0x8,%esp
f01042d0:	57                   	push   %edi
f01042d1:	6a 30                	push   $0x30
f01042d3:	ff d6                	call   *%esi
			putch('x', putdat);
f01042d5:	83 c4 08             	add    $0x8,%esp
f01042d8:	57                   	push   %edi
f01042d9:	6a 78                	push   $0x78
f01042db:	ff d6                	call   *%esi
			num = (unsigned long long)
f01042dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01042e0:	8b 08                	mov    (%eax),%ecx
f01042e2:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01042e7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01042ea:	8d 40 04             	lea    0x4(%eax),%eax
f01042ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01042f0:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01042f5:	83 ec 0c             	sub    $0xc,%esp
f01042f8:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01042fc:	50                   	push   %eax
f01042fd:	ff 75 d4             	push   -0x2c(%ebp)
f0104300:	52                   	push   %edx
f0104301:	53                   	push   %ebx
f0104302:	51                   	push   %ecx
f0104303:	89 fa                	mov    %edi,%edx
f0104305:	89 f0                	mov    %esi,%eax
f0104307:	e8 f4 fa ff ff       	call   f0103e00 <printnum>
			break;
f010430c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010430f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104312:	e9 15 fc ff ff       	jmp    f0103f2c <vprintfmt+0x34>

f0104317 <.L21>:
	if (lflag >= 2)
f0104317:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010431a:	8b 75 08             	mov    0x8(%ebp),%esi
f010431d:	83 f9 01             	cmp    $0x1,%ecx
f0104320:	7f 1b                	jg     f010433d <.L21+0x26>
	else if (lflag)
f0104322:	85 c9                	test   %ecx,%ecx
f0104324:	74 2c                	je     f0104352 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0104326:	8b 45 14             	mov    0x14(%ebp),%eax
f0104329:	8b 08                	mov    (%eax),%ecx
f010432b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104330:	8d 40 04             	lea    0x4(%eax),%eax
f0104333:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104336:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010433b:	eb b8                	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010433d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104340:	8b 08                	mov    (%eax),%ecx
f0104342:	8b 58 04             	mov    0x4(%eax),%ebx
f0104345:	8d 40 08             	lea    0x8(%eax),%eax
f0104348:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010434b:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0104350:	eb a3                	jmp    f01042f5 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104352:	8b 45 14             	mov    0x14(%ebp),%eax
f0104355:	8b 08                	mov    (%eax),%ecx
f0104357:	bb 00 00 00 00       	mov    $0x0,%ebx
f010435c:	8d 40 04             	lea    0x4(%eax),%eax
f010435f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104362:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0104367:	eb 8c                	jmp    f01042f5 <.L25+0x2b>

f0104369 <.L35>:
			putch(ch, putdat);
f0104369:	8b 75 08             	mov    0x8(%ebp),%esi
f010436c:	83 ec 08             	sub    $0x8,%esp
f010436f:	57                   	push   %edi
f0104370:	6a 25                	push   $0x25
f0104372:	ff d6                	call   *%esi
			break;
f0104374:	83 c4 10             	add    $0x10,%esp
f0104377:	eb 96                	jmp    f010430f <.L25+0x45>

f0104379 <.L20>:
			putch('%', putdat);
f0104379:	8b 75 08             	mov    0x8(%ebp),%esi
f010437c:	83 ec 08             	sub    $0x8,%esp
f010437f:	57                   	push   %edi
f0104380:	6a 25                	push   $0x25
f0104382:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104384:	83 c4 10             	add    $0x10,%esp
f0104387:	89 d8                	mov    %ebx,%eax
f0104389:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010438d:	74 05                	je     f0104394 <.L20+0x1b>
f010438f:	83 e8 01             	sub    $0x1,%eax
f0104392:	eb f5                	jmp    f0104389 <.L20+0x10>
f0104394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104397:	e9 73 ff ff ff       	jmp    f010430f <.L25+0x45>

f010439c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010439c:	55                   	push   %ebp
f010439d:	89 e5                	mov    %esp,%ebp
f010439f:	53                   	push   %ebx
f01043a0:	83 ec 14             	sub    $0x14,%esp
f01043a3:	e8 bf bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01043a8:	81 c3 c0 a4 07 00    	add    $0x7a4c0,%ebx
f01043ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01043b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01043b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01043b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01043bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01043be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01043c5:	85 c0                	test   %eax,%eax
f01043c7:	74 2b                	je     f01043f4 <vsnprintf+0x58>
f01043c9:	85 d2                	test   %edx,%edx
f01043cb:	7e 27                	jle    f01043f4 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01043cd:	ff 75 14             	push   0x14(%ebp)
f01043d0:	ff 75 10             	push   0x10(%ebp)
f01043d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01043d6:	50                   	push   %eax
f01043d7:	8d 83 56 56 f8 ff    	lea    -0x7a9aa(%ebx),%eax
f01043dd:	50                   	push   %eax
f01043de:	e8 15 fb ff ff       	call   f0103ef8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01043e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01043e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043ec:	83 c4 10             	add    $0x10,%esp
}
f01043ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01043f2:	c9                   	leave  
f01043f3:	c3                   	ret    
		return -E_INVAL;
f01043f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043f9:	eb f4                	jmp    f01043ef <vsnprintf+0x53>

f01043fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01043fb:	55                   	push   %ebp
f01043fc:	89 e5                	mov    %esp,%ebp
f01043fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104401:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104404:	50                   	push   %eax
f0104405:	ff 75 10             	push   0x10(%ebp)
f0104408:	ff 75 0c             	push   0xc(%ebp)
f010440b:	ff 75 08             	push   0x8(%ebp)
f010440e:	e8 89 ff ff ff       	call   f010439c <vsnprintf>
	va_end(ap);

	return rc;
}
f0104413:	c9                   	leave  
f0104414:	c3                   	ret    

f0104415 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104415:	55                   	push   %ebp
f0104416:	89 e5                	mov    %esp,%ebp
f0104418:	57                   	push   %edi
f0104419:	56                   	push   %esi
f010441a:	53                   	push   %ebx
f010441b:	83 ec 1c             	sub    $0x1c,%esp
f010441e:	e8 44 bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104423:	81 c3 45 a4 07 00    	add    $0x7a445,%ebx
f0104429:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010442c:	85 c0                	test   %eax,%eax
f010442e:	74 13                	je     f0104443 <readline+0x2e>
		cprintf("%s", prompt);
f0104430:	83 ec 08             	sub    $0x8,%esp
f0104433:	50                   	push   %eax
f0104434:	8d 83 64 67 f8 ff    	lea    -0x7989c(%ebx),%eax
f010443a:	50                   	push   %eax
f010443b:	e8 e7 f1 ff ff       	call   f0103627 <cprintf>
f0104440:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104443:	83 ec 0c             	sub    $0xc,%esp
f0104446:	6a 00                	push   $0x0
f0104448:	e8 a6 c2 ff ff       	call   f01006f3 <iscons>
f010444d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104450:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104453:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0104458:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f010445e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104461:	eb 45                	jmp    f01044a8 <readline+0x93>
			cprintf("read error: %e\n", c);
f0104463:	83 ec 08             	sub    $0x8,%esp
f0104466:	50                   	push   %eax
f0104467:	8d 83 10 78 f8 ff    	lea    -0x787f0(%ebx),%eax
f010446d:	50                   	push   %eax
f010446e:	e8 b4 f1 ff ff       	call   f0103627 <cprintf>
			return NULL;
f0104473:	83 c4 10             	add    $0x10,%esp
f0104476:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010447b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010447e:	5b                   	pop    %ebx
f010447f:	5e                   	pop    %esi
f0104480:	5f                   	pop    %edi
f0104481:	5d                   	pop    %ebp
f0104482:	c3                   	ret    
			if (echoing)
f0104483:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104487:	75 05                	jne    f010448e <readline+0x79>
			i--;
f0104489:	83 ef 01             	sub    $0x1,%edi
f010448c:	eb 1a                	jmp    f01044a8 <readline+0x93>
				cputchar('\b');
f010448e:	83 ec 0c             	sub    $0xc,%esp
f0104491:	6a 08                	push   $0x8
f0104493:	e8 3a c2 ff ff       	call   f01006d2 <cputchar>
f0104498:	83 c4 10             	add    $0x10,%esp
f010449b:	eb ec                	jmp    f0104489 <readline+0x74>
			buf[i++] = c;
f010449d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01044a0:	89 f0                	mov    %esi,%eax
f01044a2:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01044a5:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01044a8:	e8 35 c2 ff ff       	call   f01006e2 <getchar>
f01044ad:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01044af:	85 c0                	test   %eax,%eax
f01044b1:	78 b0                	js     f0104463 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01044b3:	83 f8 08             	cmp    $0x8,%eax
f01044b6:	0f 94 c0             	sete   %al
f01044b9:	83 fe 7f             	cmp    $0x7f,%esi
f01044bc:	0f 94 c2             	sete   %dl
f01044bf:	08 d0                	or     %dl,%al
f01044c1:	74 04                	je     f01044c7 <readline+0xb2>
f01044c3:	85 ff                	test   %edi,%edi
f01044c5:	7f bc                	jg     f0104483 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01044c7:	83 fe 1f             	cmp    $0x1f,%esi
f01044ca:	7e 1c                	jle    f01044e8 <readline+0xd3>
f01044cc:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01044d2:	7f 14                	jg     f01044e8 <readline+0xd3>
			if (echoing)
f01044d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01044d8:	74 c3                	je     f010449d <readline+0x88>
				cputchar(c);
f01044da:	83 ec 0c             	sub    $0xc,%esp
f01044dd:	56                   	push   %esi
f01044de:	e8 ef c1 ff ff       	call   f01006d2 <cputchar>
f01044e3:	83 c4 10             	add    $0x10,%esp
f01044e6:	eb b5                	jmp    f010449d <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f01044e8:	83 fe 0a             	cmp    $0xa,%esi
f01044eb:	74 05                	je     f01044f2 <readline+0xdd>
f01044ed:	83 fe 0d             	cmp    $0xd,%esi
f01044f0:	75 b6                	jne    f01044a8 <readline+0x93>
			if (echoing)
f01044f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01044f6:	75 13                	jne    f010450b <readline+0xf6>
			buf[i] = 0;
f01044f8:	c6 84 3b 98 23 00 00 	movb   $0x0,0x2398(%ebx,%edi,1)
f01044ff:	00 
			return buf;
f0104500:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f0104506:	e9 70 ff ff ff       	jmp    f010447b <readline+0x66>
				cputchar('\n');
f010450b:	83 ec 0c             	sub    $0xc,%esp
f010450e:	6a 0a                	push   $0xa
f0104510:	e8 bd c1 ff ff       	call   f01006d2 <cputchar>
f0104515:	83 c4 10             	add    $0x10,%esp
f0104518:	eb de                	jmp    f01044f8 <readline+0xe3>

f010451a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010451a:	55                   	push   %ebp
f010451b:	89 e5                	mov    %esp,%ebp
f010451d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104520:	b8 00 00 00 00       	mov    $0x0,%eax
f0104525:	eb 03                	jmp    f010452a <strlen+0x10>
		n++;
f0104527:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010452a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010452e:	75 f7                	jne    f0104527 <strlen+0xd>
	return n;
}
f0104530:	5d                   	pop    %ebp
f0104531:	c3                   	ret    

f0104532 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104532:	55                   	push   %ebp
f0104533:	89 e5                	mov    %esp,%ebp
f0104535:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104538:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010453b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104540:	eb 03                	jmp    f0104545 <strnlen+0x13>
		n++;
f0104542:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104545:	39 d0                	cmp    %edx,%eax
f0104547:	74 08                	je     f0104551 <strnlen+0x1f>
f0104549:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010454d:	75 f3                	jne    f0104542 <strnlen+0x10>
f010454f:	89 c2                	mov    %eax,%edx
	return n;
}
f0104551:	89 d0                	mov    %edx,%eax
f0104553:	5d                   	pop    %ebp
f0104554:	c3                   	ret    

f0104555 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104555:	55                   	push   %ebp
f0104556:	89 e5                	mov    %esp,%ebp
f0104558:	53                   	push   %ebx
f0104559:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010455c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010455f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104564:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0104568:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010456b:	83 c0 01             	add    $0x1,%eax
f010456e:	84 d2                	test   %dl,%dl
f0104570:	75 f2                	jne    f0104564 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104572:	89 c8                	mov    %ecx,%eax
f0104574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104577:	c9                   	leave  
f0104578:	c3                   	ret    

f0104579 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104579:	55                   	push   %ebp
f010457a:	89 e5                	mov    %esp,%ebp
f010457c:	53                   	push   %ebx
f010457d:	83 ec 10             	sub    $0x10,%esp
f0104580:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104583:	53                   	push   %ebx
f0104584:	e8 91 ff ff ff       	call   f010451a <strlen>
f0104589:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f010458c:	ff 75 0c             	push   0xc(%ebp)
f010458f:	01 d8                	add    %ebx,%eax
f0104591:	50                   	push   %eax
f0104592:	e8 be ff ff ff       	call   f0104555 <strcpy>
	return dst;
}
f0104597:	89 d8                	mov    %ebx,%eax
f0104599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010459c:	c9                   	leave  
f010459d:	c3                   	ret    

f010459e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010459e:	55                   	push   %ebp
f010459f:	89 e5                	mov    %esp,%ebp
f01045a1:	56                   	push   %esi
f01045a2:	53                   	push   %ebx
f01045a3:	8b 75 08             	mov    0x8(%ebp),%esi
f01045a6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045a9:	89 f3                	mov    %esi,%ebx
f01045ab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01045ae:	89 f0                	mov    %esi,%eax
f01045b0:	eb 0f                	jmp    f01045c1 <strncpy+0x23>
		*dst++ = *src;
f01045b2:	83 c0 01             	add    $0x1,%eax
f01045b5:	0f b6 0a             	movzbl (%edx),%ecx
f01045b8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01045bb:	80 f9 01             	cmp    $0x1,%cl
f01045be:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01045c1:	39 d8                	cmp    %ebx,%eax
f01045c3:	75 ed                	jne    f01045b2 <strncpy+0x14>
	}
	return ret;
}
f01045c5:	89 f0                	mov    %esi,%eax
f01045c7:	5b                   	pop    %ebx
f01045c8:	5e                   	pop    %esi
f01045c9:	5d                   	pop    %ebp
f01045ca:	c3                   	ret    

f01045cb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01045cb:	55                   	push   %ebp
f01045cc:	89 e5                	mov    %esp,%ebp
f01045ce:	56                   	push   %esi
f01045cf:	53                   	push   %ebx
f01045d0:	8b 75 08             	mov    0x8(%ebp),%esi
f01045d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01045d6:	8b 55 10             	mov    0x10(%ebp),%edx
f01045d9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01045db:	85 d2                	test   %edx,%edx
f01045dd:	74 21                	je     f0104600 <strlcpy+0x35>
f01045df:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01045e3:	89 f2                	mov    %esi,%edx
f01045e5:	eb 09                	jmp    f01045f0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01045e7:	83 c1 01             	add    $0x1,%ecx
f01045ea:	83 c2 01             	add    $0x1,%edx
f01045ed:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f01045f0:	39 c2                	cmp    %eax,%edx
f01045f2:	74 09                	je     f01045fd <strlcpy+0x32>
f01045f4:	0f b6 19             	movzbl (%ecx),%ebx
f01045f7:	84 db                	test   %bl,%bl
f01045f9:	75 ec                	jne    f01045e7 <strlcpy+0x1c>
f01045fb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01045fd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104600:	29 f0                	sub    %esi,%eax
}
f0104602:	5b                   	pop    %ebx
f0104603:	5e                   	pop    %esi
f0104604:	5d                   	pop    %ebp
f0104605:	c3                   	ret    

f0104606 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104606:	55                   	push   %ebp
f0104607:	89 e5                	mov    %esp,%ebp
f0104609:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010460c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010460f:	eb 06                	jmp    f0104617 <strcmp+0x11>
		p++, q++;
f0104611:	83 c1 01             	add    $0x1,%ecx
f0104614:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104617:	0f b6 01             	movzbl (%ecx),%eax
f010461a:	84 c0                	test   %al,%al
f010461c:	74 04                	je     f0104622 <strcmp+0x1c>
f010461e:	3a 02                	cmp    (%edx),%al
f0104620:	74 ef                	je     f0104611 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104622:	0f b6 c0             	movzbl %al,%eax
f0104625:	0f b6 12             	movzbl (%edx),%edx
f0104628:	29 d0                	sub    %edx,%eax
}
f010462a:	5d                   	pop    %ebp
f010462b:	c3                   	ret    

f010462c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010462c:	55                   	push   %ebp
f010462d:	89 e5                	mov    %esp,%ebp
f010462f:	53                   	push   %ebx
f0104630:	8b 45 08             	mov    0x8(%ebp),%eax
f0104633:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104636:	89 c3                	mov    %eax,%ebx
f0104638:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010463b:	eb 06                	jmp    f0104643 <strncmp+0x17>
		n--, p++, q++;
f010463d:	83 c0 01             	add    $0x1,%eax
f0104640:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104643:	39 d8                	cmp    %ebx,%eax
f0104645:	74 18                	je     f010465f <strncmp+0x33>
f0104647:	0f b6 08             	movzbl (%eax),%ecx
f010464a:	84 c9                	test   %cl,%cl
f010464c:	74 04                	je     f0104652 <strncmp+0x26>
f010464e:	3a 0a                	cmp    (%edx),%cl
f0104650:	74 eb                	je     f010463d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104652:	0f b6 00             	movzbl (%eax),%eax
f0104655:	0f b6 12             	movzbl (%edx),%edx
f0104658:	29 d0                	sub    %edx,%eax
}
f010465a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010465d:	c9                   	leave  
f010465e:	c3                   	ret    
		return 0;
f010465f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104664:	eb f4                	jmp    f010465a <strncmp+0x2e>

f0104666 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104666:	55                   	push   %ebp
f0104667:	89 e5                	mov    %esp,%ebp
f0104669:	8b 45 08             	mov    0x8(%ebp),%eax
f010466c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104670:	eb 03                	jmp    f0104675 <strchr+0xf>
f0104672:	83 c0 01             	add    $0x1,%eax
f0104675:	0f b6 10             	movzbl (%eax),%edx
f0104678:	84 d2                	test   %dl,%dl
f010467a:	74 06                	je     f0104682 <strchr+0x1c>
		if (*s == c)
f010467c:	38 ca                	cmp    %cl,%dl
f010467e:	75 f2                	jne    f0104672 <strchr+0xc>
f0104680:	eb 05                	jmp    f0104687 <strchr+0x21>
			return (char *) s;
	return 0;
f0104682:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104687:	5d                   	pop    %ebp
f0104688:	c3                   	ret    

f0104689 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104689:	55                   	push   %ebp
f010468a:	89 e5                	mov    %esp,%ebp
f010468c:	8b 45 08             	mov    0x8(%ebp),%eax
f010468f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104693:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104696:	38 ca                	cmp    %cl,%dl
f0104698:	74 09                	je     f01046a3 <strfind+0x1a>
f010469a:	84 d2                	test   %dl,%dl
f010469c:	74 05                	je     f01046a3 <strfind+0x1a>
	for (; *s; s++)
f010469e:	83 c0 01             	add    $0x1,%eax
f01046a1:	eb f0                	jmp    f0104693 <strfind+0xa>
			break;
	return (char *) s;
}
f01046a3:	5d                   	pop    %ebp
f01046a4:	c3                   	ret    

f01046a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01046a5:	55                   	push   %ebp
f01046a6:	89 e5                	mov    %esp,%ebp
f01046a8:	57                   	push   %edi
f01046a9:	56                   	push   %esi
f01046aa:	53                   	push   %ebx
f01046ab:	8b 7d 08             	mov    0x8(%ebp),%edi
f01046ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01046b1:	85 c9                	test   %ecx,%ecx
f01046b3:	74 2f                	je     f01046e4 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01046b5:	89 f8                	mov    %edi,%eax
f01046b7:	09 c8                	or     %ecx,%eax
f01046b9:	a8 03                	test   $0x3,%al
f01046bb:	75 21                	jne    f01046de <memset+0x39>
		c &= 0xFF;
f01046bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01046c1:	89 d0                	mov    %edx,%eax
f01046c3:	c1 e0 08             	shl    $0x8,%eax
f01046c6:	89 d3                	mov    %edx,%ebx
f01046c8:	c1 e3 18             	shl    $0x18,%ebx
f01046cb:	89 d6                	mov    %edx,%esi
f01046cd:	c1 e6 10             	shl    $0x10,%esi
f01046d0:	09 f3                	or     %esi,%ebx
f01046d2:	09 da                	or     %ebx,%edx
f01046d4:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01046d6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01046d9:	fc                   	cld    
f01046da:	f3 ab                	rep stos %eax,%es:(%edi)
f01046dc:	eb 06                	jmp    f01046e4 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01046de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046e1:	fc                   	cld    
f01046e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01046e4:	89 f8                	mov    %edi,%eax
f01046e6:	5b                   	pop    %ebx
f01046e7:	5e                   	pop    %esi
f01046e8:	5f                   	pop    %edi
f01046e9:	5d                   	pop    %ebp
f01046ea:	c3                   	ret    

f01046eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01046eb:	55                   	push   %ebp
f01046ec:	89 e5                	mov    %esp,%ebp
f01046ee:	57                   	push   %edi
f01046ef:	56                   	push   %esi
f01046f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01046f3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01046f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01046f9:	39 c6                	cmp    %eax,%esi
f01046fb:	73 32                	jae    f010472f <memmove+0x44>
f01046fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104700:	39 c2                	cmp    %eax,%edx
f0104702:	76 2b                	jbe    f010472f <memmove+0x44>
		s += n;
		d += n;
f0104704:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104707:	89 d6                	mov    %edx,%esi
f0104709:	09 fe                	or     %edi,%esi
f010470b:	09 ce                	or     %ecx,%esi
f010470d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104713:	75 0e                	jne    f0104723 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104715:	83 ef 04             	sub    $0x4,%edi
f0104718:	8d 72 fc             	lea    -0x4(%edx),%esi
f010471b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010471e:	fd                   	std    
f010471f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104721:	eb 09                	jmp    f010472c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104723:	83 ef 01             	sub    $0x1,%edi
f0104726:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104729:	fd                   	std    
f010472a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010472c:	fc                   	cld    
f010472d:	eb 1a                	jmp    f0104749 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010472f:	89 f2                	mov    %esi,%edx
f0104731:	09 c2                	or     %eax,%edx
f0104733:	09 ca                	or     %ecx,%edx
f0104735:	f6 c2 03             	test   $0x3,%dl
f0104738:	75 0a                	jne    f0104744 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010473a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010473d:	89 c7                	mov    %eax,%edi
f010473f:	fc                   	cld    
f0104740:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104742:	eb 05                	jmp    f0104749 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104744:	89 c7                	mov    %eax,%edi
f0104746:	fc                   	cld    
f0104747:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104749:	5e                   	pop    %esi
f010474a:	5f                   	pop    %edi
f010474b:	5d                   	pop    %ebp
f010474c:	c3                   	ret    

f010474d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010474d:	55                   	push   %ebp
f010474e:	89 e5                	mov    %esp,%ebp
f0104750:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104753:	ff 75 10             	push   0x10(%ebp)
f0104756:	ff 75 0c             	push   0xc(%ebp)
f0104759:	ff 75 08             	push   0x8(%ebp)
f010475c:	e8 8a ff ff ff       	call   f01046eb <memmove>
}
f0104761:	c9                   	leave  
f0104762:	c3                   	ret    

f0104763 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104763:	55                   	push   %ebp
f0104764:	89 e5                	mov    %esp,%ebp
f0104766:	56                   	push   %esi
f0104767:	53                   	push   %ebx
f0104768:	8b 45 08             	mov    0x8(%ebp),%eax
f010476b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010476e:	89 c6                	mov    %eax,%esi
f0104770:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104773:	eb 06                	jmp    f010477b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104775:	83 c0 01             	add    $0x1,%eax
f0104778:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f010477b:	39 f0                	cmp    %esi,%eax
f010477d:	74 14                	je     f0104793 <memcmp+0x30>
		if (*s1 != *s2)
f010477f:	0f b6 08             	movzbl (%eax),%ecx
f0104782:	0f b6 1a             	movzbl (%edx),%ebx
f0104785:	38 d9                	cmp    %bl,%cl
f0104787:	74 ec                	je     f0104775 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0104789:	0f b6 c1             	movzbl %cl,%eax
f010478c:	0f b6 db             	movzbl %bl,%ebx
f010478f:	29 d8                	sub    %ebx,%eax
f0104791:	eb 05                	jmp    f0104798 <memcmp+0x35>
	}

	return 0;
f0104793:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104798:	5b                   	pop    %ebx
f0104799:	5e                   	pop    %esi
f010479a:	5d                   	pop    %ebp
f010479b:	c3                   	ret    

f010479c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010479c:	55                   	push   %ebp
f010479d:	89 e5                	mov    %esp,%ebp
f010479f:	8b 45 08             	mov    0x8(%ebp),%eax
f01047a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01047a5:	89 c2                	mov    %eax,%edx
f01047a7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01047aa:	eb 03                	jmp    f01047af <memfind+0x13>
f01047ac:	83 c0 01             	add    $0x1,%eax
f01047af:	39 d0                	cmp    %edx,%eax
f01047b1:	73 04                	jae    f01047b7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01047b3:	38 08                	cmp    %cl,(%eax)
f01047b5:	75 f5                	jne    f01047ac <memfind+0x10>
			break;
	return (void *) s;
}
f01047b7:	5d                   	pop    %ebp
f01047b8:	c3                   	ret    

f01047b9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01047b9:	55                   	push   %ebp
f01047ba:	89 e5                	mov    %esp,%ebp
f01047bc:	57                   	push   %edi
f01047bd:	56                   	push   %esi
f01047be:	53                   	push   %ebx
f01047bf:	8b 55 08             	mov    0x8(%ebp),%edx
f01047c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01047c5:	eb 03                	jmp    f01047ca <strtol+0x11>
		s++;
f01047c7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01047ca:	0f b6 02             	movzbl (%edx),%eax
f01047cd:	3c 20                	cmp    $0x20,%al
f01047cf:	74 f6                	je     f01047c7 <strtol+0xe>
f01047d1:	3c 09                	cmp    $0x9,%al
f01047d3:	74 f2                	je     f01047c7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01047d5:	3c 2b                	cmp    $0x2b,%al
f01047d7:	74 2a                	je     f0104803 <strtol+0x4a>
	int neg = 0;
f01047d9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01047de:	3c 2d                	cmp    $0x2d,%al
f01047e0:	74 2b                	je     f010480d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01047e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01047e8:	75 0f                	jne    f01047f9 <strtol+0x40>
f01047ea:	80 3a 30             	cmpb   $0x30,(%edx)
f01047ed:	74 28                	je     f0104817 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01047ef:	85 db                	test   %ebx,%ebx
f01047f1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01047f6:	0f 44 d8             	cmove  %eax,%ebx
f01047f9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01047fe:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104801:	eb 46                	jmp    f0104849 <strtol+0x90>
		s++;
f0104803:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0104806:	bf 00 00 00 00       	mov    $0x0,%edi
f010480b:	eb d5                	jmp    f01047e2 <strtol+0x29>
		s++, neg = 1;
f010480d:	83 c2 01             	add    $0x1,%edx
f0104810:	bf 01 00 00 00       	mov    $0x1,%edi
f0104815:	eb cb                	jmp    f01047e2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104817:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010481b:	74 0e                	je     f010482b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010481d:	85 db                	test   %ebx,%ebx
f010481f:	75 d8                	jne    f01047f9 <strtol+0x40>
		s++, base = 8;
f0104821:	83 c2 01             	add    $0x1,%edx
f0104824:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104829:	eb ce                	jmp    f01047f9 <strtol+0x40>
		s += 2, base = 16;
f010482b:	83 c2 02             	add    $0x2,%edx
f010482e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104833:	eb c4                	jmp    f01047f9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0104835:	0f be c0             	movsbl %al,%eax
f0104838:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010483b:	3b 45 10             	cmp    0x10(%ebp),%eax
f010483e:	7d 3a                	jge    f010487a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104840:	83 c2 01             	add    $0x1,%edx
f0104843:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0104847:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0104849:	0f b6 02             	movzbl (%edx),%eax
f010484c:	8d 70 d0             	lea    -0x30(%eax),%esi
f010484f:	89 f3                	mov    %esi,%ebx
f0104851:	80 fb 09             	cmp    $0x9,%bl
f0104854:	76 df                	jbe    f0104835 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0104856:	8d 70 9f             	lea    -0x61(%eax),%esi
f0104859:	89 f3                	mov    %esi,%ebx
f010485b:	80 fb 19             	cmp    $0x19,%bl
f010485e:	77 08                	ja     f0104868 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0104860:	0f be c0             	movsbl %al,%eax
f0104863:	83 e8 57             	sub    $0x57,%eax
f0104866:	eb d3                	jmp    f010483b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0104868:	8d 70 bf             	lea    -0x41(%eax),%esi
f010486b:	89 f3                	mov    %esi,%ebx
f010486d:	80 fb 19             	cmp    $0x19,%bl
f0104870:	77 08                	ja     f010487a <strtol+0xc1>
			dig = *s - 'A' + 10;
f0104872:	0f be c0             	movsbl %al,%eax
f0104875:	83 e8 37             	sub    $0x37,%eax
f0104878:	eb c1                	jmp    f010483b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f010487a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010487e:	74 05                	je     f0104885 <strtol+0xcc>
		*endptr = (char *) s;
f0104880:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104883:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0104885:	89 c8                	mov    %ecx,%eax
f0104887:	f7 d8                	neg    %eax
f0104889:	85 ff                	test   %edi,%edi
f010488b:	0f 45 c8             	cmovne %eax,%ecx
}
f010488e:	89 c8                	mov    %ecx,%eax
f0104890:	5b                   	pop    %ebx
f0104891:	5e                   	pop    %esi
f0104892:	5f                   	pop    %edi
f0104893:	5d                   	pop    %ebp
f0104894:	c3                   	ret    
f0104895:	66 90                	xchg   %ax,%ax
f0104897:	66 90                	xchg   %ax,%ax
f0104899:	66 90                	xchg   %ax,%ax
f010489b:	66 90                	xchg   %ax,%ax
f010489d:	66 90                	xchg   %ax,%ax
f010489f:	90                   	nop

f01048a0 <__udivdi3>:
f01048a0:	f3 0f 1e fb          	endbr32 
f01048a4:	55                   	push   %ebp
f01048a5:	57                   	push   %edi
f01048a6:	56                   	push   %esi
f01048a7:	53                   	push   %ebx
f01048a8:	83 ec 1c             	sub    $0x1c,%esp
f01048ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01048af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01048b3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01048b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01048bb:	85 c0                	test   %eax,%eax
f01048bd:	75 19                	jne    f01048d8 <__udivdi3+0x38>
f01048bf:	39 f3                	cmp    %esi,%ebx
f01048c1:	76 4d                	jbe    f0104910 <__udivdi3+0x70>
f01048c3:	31 ff                	xor    %edi,%edi
f01048c5:	89 e8                	mov    %ebp,%eax
f01048c7:	89 f2                	mov    %esi,%edx
f01048c9:	f7 f3                	div    %ebx
f01048cb:	89 fa                	mov    %edi,%edx
f01048cd:	83 c4 1c             	add    $0x1c,%esp
f01048d0:	5b                   	pop    %ebx
f01048d1:	5e                   	pop    %esi
f01048d2:	5f                   	pop    %edi
f01048d3:	5d                   	pop    %ebp
f01048d4:	c3                   	ret    
f01048d5:	8d 76 00             	lea    0x0(%esi),%esi
f01048d8:	39 f0                	cmp    %esi,%eax
f01048da:	76 14                	jbe    f01048f0 <__udivdi3+0x50>
f01048dc:	31 ff                	xor    %edi,%edi
f01048de:	31 c0                	xor    %eax,%eax
f01048e0:	89 fa                	mov    %edi,%edx
f01048e2:	83 c4 1c             	add    $0x1c,%esp
f01048e5:	5b                   	pop    %ebx
f01048e6:	5e                   	pop    %esi
f01048e7:	5f                   	pop    %edi
f01048e8:	5d                   	pop    %ebp
f01048e9:	c3                   	ret    
f01048ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01048f0:	0f bd f8             	bsr    %eax,%edi
f01048f3:	83 f7 1f             	xor    $0x1f,%edi
f01048f6:	75 48                	jne    f0104940 <__udivdi3+0xa0>
f01048f8:	39 f0                	cmp    %esi,%eax
f01048fa:	72 06                	jb     f0104902 <__udivdi3+0x62>
f01048fc:	31 c0                	xor    %eax,%eax
f01048fe:	39 eb                	cmp    %ebp,%ebx
f0104900:	77 de                	ja     f01048e0 <__udivdi3+0x40>
f0104902:	b8 01 00 00 00       	mov    $0x1,%eax
f0104907:	eb d7                	jmp    f01048e0 <__udivdi3+0x40>
f0104909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104910:	89 d9                	mov    %ebx,%ecx
f0104912:	85 db                	test   %ebx,%ebx
f0104914:	75 0b                	jne    f0104921 <__udivdi3+0x81>
f0104916:	b8 01 00 00 00       	mov    $0x1,%eax
f010491b:	31 d2                	xor    %edx,%edx
f010491d:	f7 f3                	div    %ebx
f010491f:	89 c1                	mov    %eax,%ecx
f0104921:	31 d2                	xor    %edx,%edx
f0104923:	89 f0                	mov    %esi,%eax
f0104925:	f7 f1                	div    %ecx
f0104927:	89 c6                	mov    %eax,%esi
f0104929:	89 e8                	mov    %ebp,%eax
f010492b:	89 f7                	mov    %esi,%edi
f010492d:	f7 f1                	div    %ecx
f010492f:	89 fa                	mov    %edi,%edx
f0104931:	83 c4 1c             	add    $0x1c,%esp
f0104934:	5b                   	pop    %ebx
f0104935:	5e                   	pop    %esi
f0104936:	5f                   	pop    %edi
f0104937:	5d                   	pop    %ebp
f0104938:	c3                   	ret    
f0104939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104940:	89 f9                	mov    %edi,%ecx
f0104942:	ba 20 00 00 00       	mov    $0x20,%edx
f0104947:	29 fa                	sub    %edi,%edx
f0104949:	d3 e0                	shl    %cl,%eax
f010494b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010494f:	89 d1                	mov    %edx,%ecx
f0104951:	89 d8                	mov    %ebx,%eax
f0104953:	d3 e8                	shr    %cl,%eax
f0104955:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104959:	09 c1                	or     %eax,%ecx
f010495b:	89 f0                	mov    %esi,%eax
f010495d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104961:	89 f9                	mov    %edi,%ecx
f0104963:	d3 e3                	shl    %cl,%ebx
f0104965:	89 d1                	mov    %edx,%ecx
f0104967:	d3 e8                	shr    %cl,%eax
f0104969:	89 f9                	mov    %edi,%ecx
f010496b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010496f:	89 eb                	mov    %ebp,%ebx
f0104971:	d3 e6                	shl    %cl,%esi
f0104973:	89 d1                	mov    %edx,%ecx
f0104975:	d3 eb                	shr    %cl,%ebx
f0104977:	09 f3                	or     %esi,%ebx
f0104979:	89 c6                	mov    %eax,%esi
f010497b:	89 f2                	mov    %esi,%edx
f010497d:	89 d8                	mov    %ebx,%eax
f010497f:	f7 74 24 08          	divl   0x8(%esp)
f0104983:	89 d6                	mov    %edx,%esi
f0104985:	89 c3                	mov    %eax,%ebx
f0104987:	f7 64 24 0c          	mull   0xc(%esp)
f010498b:	39 d6                	cmp    %edx,%esi
f010498d:	72 19                	jb     f01049a8 <__udivdi3+0x108>
f010498f:	89 f9                	mov    %edi,%ecx
f0104991:	d3 e5                	shl    %cl,%ebp
f0104993:	39 c5                	cmp    %eax,%ebp
f0104995:	73 04                	jae    f010499b <__udivdi3+0xfb>
f0104997:	39 d6                	cmp    %edx,%esi
f0104999:	74 0d                	je     f01049a8 <__udivdi3+0x108>
f010499b:	89 d8                	mov    %ebx,%eax
f010499d:	31 ff                	xor    %edi,%edi
f010499f:	e9 3c ff ff ff       	jmp    f01048e0 <__udivdi3+0x40>
f01049a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01049a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01049ab:	31 ff                	xor    %edi,%edi
f01049ad:	e9 2e ff ff ff       	jmp    f01048e0 <__udivdi3+0x40>
f01049b2:	66 90                	xchg   %ax,%ax
f01049b4:	66 90                	xchg   %ax,%ax
f01049b6:	66 90                	xchg   %ax,%ax
f01049b8:	66 90                	xchg   %ax,%ax
f01049ba:	66 90                	xchg   %ax,%ax
f01049bc:	66 90                	xchg   %ax,%ax
f01049be:	66 90                	xchg   %ax,%ax

f01049c0 <__umoddi3>:
f01049c0:	f3 0f 1e fb          	endbr32 
f01049c4:	55                   	push   %ebp
f01049c5:	57                   	push   %edi
f01049c6:	56                   	push   %esi
f01049c7:	53                   	push   %ebx
f01049c8:	83 ec 1c             	sub    $0x1c,%esp
f01049cb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01049cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01049d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01049d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01049db:	89 f0                	mov    %esi,%eax
f01049dd:	89 da                	mov    %ebx,%edx
f01049df:	85 ff                	test   %edi,%edi
f01049e1:	75 15                	jne    f01049f8 <__umoddi3+0x38>
f01049e3:	39 dd                	cmp    %ebx,%ebp
f01049e5:	76 39                	jbe    f0104a20 <__umoddi3+0x60>
f01049e7:	f7 f5                	div    %ebp
f01049e9:	89 d0                	mov    %edx,%eax
f01049eb:	31 d2                	xor    %edx,%edx
f01049ed:	83 c4 1c             	add    $0x1c,%esp
f01049f0:	5b                   	pop    %ebx
f01049f1:	5e                   	pop    %esi
f01049f2:	5f                   	pop    %edi
f01049f3:	5d                   	pop    %ebp
f01049f4:	c3                   	ret    
f01049f5:	8d 76 00             	lea    0x0(%esi),%esi
f01049f8:	39 df                	cmp    %ebx,%edi
f01049fa:	77 f1                	ja     f01049ed <__umoddi3+0x2d>
f01049fc:	0f bd cf             	bsr    %edi,%ecx
f01049ff:	83 f1 1f             	xor    $0x1f,%ecx
f0104a02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104a06:	75 40                	jne    f0104a48 <__umoddi3+0x88>
f0104a08:	39 df                	cmp    %ebx,%edi
f0104a0a:	72 04                	jb     f0104a10 <__umoddi3+0x50>
f0104a0c:	39 f5                	cmp    %esi,%ebp
f0104a0e:	77 dd                	ja     f01049ed <__umoddi3+0x2d>
f0104a10:	89 da                	mov    %ebx,%edx
f0104a12:	89 f0                	mov    %esi,%eax
f0104a14:	29 e8                	sub    %ebp,%eax
f0104a16:	19 fa                	sbb    %edi,%edx
f0104a18:	eb d3                	jmp    f01049ed <__umoddi3+0x2d>
f0104a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104a20:	89 e9                	mov    %ebp,%ecx
f0104a22:	85 ed                	test   %ebp,%ebp
f0104a24:	75 0b                	jne    f0104a31 <__umoddi3+0x71>
f0104a26:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a2b:	31 d2                	xor    %edx,%edx
f0104a2d:	f7 f5                	div    %ebp
f0104a2f:	89 c1                	mov    %eax,%ecx
f0104a31:	89 d8                	mov    %ebx,%eax
f0104a33:	31 d2                	xor    %edx,%edx
f0104a35:	f7 f1                	div    %ecx
f0104a37:	89 f0                	mov    %esi,%eax
f0104a39:	f7 f1                	div    %ecx
f0104a3b:	89 d0                	mov    %edx,%eax
f0104a3d:	31 d2                	xor    %edx,%edx
f0104a3f:	eb ac                	jmp    f01049ed <__umoddi3+0x2d>
f0104a41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104a48:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104a4c:	ba 20 00 00 00       	mov    $0x20,%edx
f0104a51:	29 c2                	sub    %eax,%edx
f0104a53:	89 c1                	mov    %eax,%ecx
f0104a55:	89 e8                	mov    %ebp,%eax
f0104a57:	d3 e7                	shl    %cl,%edi
f0104a59:	89 d1                	mov    %edx,%ecx
f0104a5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104a5f:	d3 e8                	shr    %cl,%eax
f0104a61:	89 c1                	mov    %eax,%ecx
f0104a63:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104a67:	09 f9                	or     %edi,%ecx
f0104a69:	89 df                	mov    %ebx,%edi
f0104a6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104a6f:	89 c1                	mov    %eax,%ecx
f0104a71:	d3 e5                	shl    %cl,%ebp
f0104a73:	89 d1                	mov    %edx,%ecx
f0104a75:	d3 ef                	shr    %cl,%edi
f0104a77:	89 c1                	mov    %eax,%ecx
f0104a79:	89 f0                	mov    %esi,%eax
f0104a7b:	d3 e3                	shl    %cl,%ebx
f0104a7d:	89 d1                	mov    %edx,%ecx
f0104a7f:	89 fa                	mov    %edi,%edx
f0104a81:	d3 e8                	shr    %cl,%eax
f0104a83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104a88:	09 d8                	or     %ebx,%eax
f0104a8a:	f7 74 24 08          	divl   0x8(%esp)
f0104a8e:	89 d3                	mov    %edx,%ebx
f0104a90:	d3 e6                	shl    %cl,%esi
f0104a92:	f7 e5                	mul    %ebp
f0104a94:	89 c7                	mov    %eax,%edi
f0104a96:	89 d1                	mov    %edx,%ecx
f0104a98:	39 d3                	cmp    %edx,%ebx
f0104a9a:	72 06                	jb     f0104aa2 <__umoddi3+0xe2>
f0104a9c:	75 0e                	jne    f0104aac <__umoddi3+0xec>
f0104a9e:	39 c6                	cmp    %eax,%esi
f0104aa0:	73 0a                	jae    f0104aac <__umoddi3+0xec>
f0104aa2:	29 e8                	sub    %ebp,%eax
f0104aa4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104aa8:	89 d1                	mov    %edx,%ecx
f0104aaa:	89 c7                	mov    %eax,%edi
f0104aac:	89 f5                	mov    %esi,%ebp
f0104aae:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104ab2:	29 fd                	sub    %edi,%ebp
f0104ab4:	19 cb                	sbb    %ecx,%ebx
f0104ab6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104abb:	89 d8                	mov    %ebx,%eax
f0104abd:	d3 e0                	shl    %cl,%eax
f0104abf:	89 f1                	mov    %esi,%ecx
f0104ac1:	d3 ed                	shr    %cl,%ebp
f0104ac3:	d3 eb                	shr    %cl,%ebx
f0104ac5:	09 e8                	or     %ebp,%eax
f0104ac7:	89 da                	mov    %ebx,%edx
f0104ac9:	83 c4 1c             	add    $0x1c,%esp
f0104acc:	5b                   	pop    %ebx
f0104acd:	5e                   	pop    %esi
f0104ace:	5f                   	pop    %edi
f0104acf:	5d                   	pop    %ebp
f0104ad0:	c3                   	ret    
