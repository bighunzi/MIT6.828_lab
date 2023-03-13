
obj/fs/fs：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain//调用lib/libmain.c中的libmain()
  80002c:	e8 61 1a 00 00       	call   801a92 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c3                	mov    %eax,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  80003f:	89 c1                	mov    %eax,%ecx
  800041:	83 e1 c0             	and    $0xffffffc0,%ecx
  800044:	80 f9 40             	cmp    $0x40,%cl
  800047:	75 f5                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800049:	ba 00 00 00 00       	mov    $0x0,%edx
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004e:	84 db                	test   %bl,%bl
  800050:	74 0a                	je     80005c <ide_wait_ready+0x29>
  800052:	a8 21                	test   $0x21,%al
  800054:	0f 95 c2             	setne  %dl
  800057:	0f b6 d2             	movzbl %dl,%edx
  80005a:	f7 da                	neg    %edx
}
  80005c:	89 d0                	mov    %edx,%eax
  80005e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800061:	c9                   	leave  
  800062:	c3                   	ret    

00800063 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006a:	b8 00 00 00 00       	mov    $0x0,%eax
  80006f:	e8 bf ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800074:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007f:	b9 00 00 00 00       	mov    $0x0,%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800084:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800089:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  80008a:	a8 a1                	test   $0xa1,%al
  80008c:	74 0b                	je     800099 <ide_probe_disk1+0x36>
	     x++)
  80008e:	83 c1 01             	add    $0x1,%ecx
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800091:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800097:	75 f0                	jne    800089 <ide_probe_disk1+0x26>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000a3:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a4:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000aa:	0f 9e c3             	setle  %bl
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	0f b6 c3             	movzbl %bl,%eax
  8000b3:	50                   	push   %eax
  8000b4:	68 60 38 80 00       	push   $0x803860
  8000b9:	e8 0f 1b 00 00       	call   801bcd <cprintf>
	return (x < 1000);
}
  8000be:	89 d8                	mov    %ebx,%eax
  8000c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	83 ec 08             	sub    $0x8,%esp
  8000cb:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000ce:	83 f8 01             	cmp    $0x1,%eax
  8000d1:	77 07                	ja     8000da <ide_set_disk+0x15>
		panic("bad disk number");
	diskno = d;
  8000d3:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000d8:	c9                   	leave  
  8000d9:	c3                   	ret    
		panic("bad disk number");
  8000da:	83 ec 04             	sub    $0x4,%esp
  8000dd:	68 77 38 80 00       	push   $0x803877
  8000e2:	6a 3a                	push   $0x3a
  8000e4:	68 87 38 80 00       	push   $0x803887
  8000e9:	e8 04 1a 00 00       	call   801af2 <_panic>

008000ee <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800100:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800106:	0f 87 87 00 00 00    	ja     800193 <ide_read+0xa5>

	ide_wait_ready(0);
  80010c:	b8 00 00 00 00       	mov    $0x0,%eax
  800111:	e8 1d ff ff ff       	call   800033 <ide_wait_ready>
  800116:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80011b:	89 f0                	mov    %esi,%eax
  80011d:	ee                   	out    %al,(%dx)
  80011e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800123:	89 f8                	mov    %edi,%eax
  800125:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800126:	89 f8                	mov    %edi,%eax
  800128:	c1 e8 08             	shr    $0x8,%eax
  80012b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800130:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800131:	89 f8                	mov    %edi,%eax
  800133:	c1 e8 10             	shr    $0x10,%eax
  800136:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80013b:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80013c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800143:	c1 e0 04             	shl    $0x4,%eax
  800146:	83 e0 10             	and    $0x10,%eax
  800149:	c1 ef 18             	shr    $0x18,%edi
  80014c:	83 e7 0f             	and    $0xf,%edi
  80014f:	09 f8                	or     %edi,%eax
  800151:	83 c8 e0             	or     $0xffffffe0,%eax
  800154:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800159:	ee                   	out    %al,(%dx)
  80015a:	b8 20 00 00 00       	mov    $0x20,%eax
  80015f:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800164:	ee                   	out    %al,(%dx)
  800165:	c1 e6 09             	shl    $0x9,%esi
  800168:	01 de                	add    %ebx,%esi
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80016a:	39 f3                	cmp    %esi,%ebx
  80016c:	74 3b                	je     8001a9 <ide_read+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  80016e:	b8 01 00 00 00       	mov    $0x1,%eax
  800173:	e8 bb fe ff ff       	call   800033 <ide_wait_ready>
  800178:	85 c0                	test   %eax,%eax
  80017a:	78 32                	js     8001ae <ide_read+0xc0>
	asm volatile("cld\n\trepne\n\tinsl"
  80017c:	89 df                	mov    %ebx,%edi
  80017e:	b9 80 00 00 00       	mov    $0x80,%ecx
  800183:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800188:	fc                   	cld    
  800189:	f2 6d                	repnz insl (%dx),%es:(%edi)
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80018b:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800191:	eb d7                	jmp    80016a <ide_read+0x7c>
	assert(nsecs <= 256);
  800193:	68 90 38 80 00       	push   $0x803890
  800198:	68 9d 38 80 00       	push   $0x80389d
  80019d:	6a 44                	push   $0x44
  80019f:	68 87 38 80 00       	push   $0x803887
  8001a4:	e8 49 19 00 00       	call   801af2 <_panic>
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c8:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001ce:	0f 87 87 00 00 00    	ja     80025b <ide_write+0xa5>

	ide_wait_ready(0);
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	e8 55 fe ff ff       	call   800033 <ide_wait_ready>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001de:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001e3:	89 f8                	mov    %edi,%eax
  8001e5:	ee                   	out    %al,(%dx)
  8001e6:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001eb:	89 f0                	mov    %esi,%eax
  8001ed:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001ee:	89 f0                	mov    %esi,%eax
  8001f0:	c1 e8 08             	shr    $0x8,%eax
  8001f3:	ba f4 01 00 00       	mov    $0x1f4,%edx
  8001f8:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001f9:	89 f0                	mov    %esi,%eax
  8001fb:	c1 e8 10             	shr    $0x10,%eax
  8001fe:	ba f5 01 00 00       	mov    $0x1f5,%edx
  800203:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800204:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  80020b:	c1 e0 04             	shl    $0x4,%eax
  80020e:	83 e0 10             	and    $0x10,%eax
  800211:	c1 ee 18             	shr    $0x18,%esi
  800214:	83 e6 0f             	and    $0xf,%esi
  800217:	09 f0                	or     %esi,%eax
  800219:	83 c8 e0             	or     $0xffffffe0,%eax
  80021c:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800221:	ee                   	out    %al,(%dx)
  800222:	b8 30 00 00 00       	mov    $0x30,%eax
  800227:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80022c:	ee                   	out    %al,(%dx)
  80022d:	c1 e7 09             	shl    $0x9,%edi
  800230:	01 df                	add    %ebx,%edi
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800232:	39 fb                	cmp    %edi,%ebx
  800234:	74 3b                	je     800271 <ide_write+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  800236:	b8 01 00 00 00       	mov    $0x1,%eax
  80023b:	e8 f3 fd ff ff       	call   800033 <ide_wait_ready>
  800240:	85 c0                	test   %eax,%eax
  800242:	78 32                	js     800276 <ide_write+0xc0>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800244:	89 de                	mov    %ebx,%esi
  800246:	b9 80 00 00 00       	mov    $0x80,%ecx
  80024b:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800250:	fc                   	cld    
  800251:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800253:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800259:	eb d7                	jmp    800232 <ide_write+0x7c>
	assert(nsecs <= 256);
  80025b:	68 90 38 80 00       	push   $0x803890
  800260:	68 9d 38 80 00       	push   $0x80389d
  800265:	6a 5d                	push   $0x5d
  800267:	68 87 38 80 00       	push   $0x803887
  80026c:	e8 81 18 00 00       	call   801af2 <_panic>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800286:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800288:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80028e:	89 c6                	mov    %eax,%esi
  800290:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800293:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800298:	0f 87 98 00 00 00    	ja     800336 <bc_pgfault+0xb8>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80029e:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8002a3:	85 c0                	test   %eax,%eax
  8002a5:	74 09                	je     8002b0 <bc_pgfault+0x32>
  8002a7:	39 70 04             	cmp    %esi,0x4(%eax)
  8002aa:	0f 86 a1 00 00 00    	jbe    800351 <bc_pgfault+0xd3>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr =(void *) ROUNDDOWN(addr, PGSIZE);
  8002b0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ( (r = sys_page_alloc(0, addr, PTE_SYSCALL) ) < 0)/*envid 为0即当前环境*/
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	68 07 0e 00 00       	push   $0xe07
  8002be:	53                   	push   %ebx
  8002bf:	6a 00                	push   $0x0
  8002c1:	e8 dd 22 00 00       	call   8025a3 <sys_page_alloc>
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	85 c0                	test   %eax,%eax
  8002cb:	0f 88 92 00 00 00    	js     800363 <bc_pgfault+0xe5>
		panic("bc_pgfault, sys_page_alloc: %e", r);

	if( r= ide_read(blockno * BLKSECTS , addr, BLKSECTS)<0 ) panic("bc_pgfault, ide_read: %e", r);
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 08                	push   $0x8
  8002d6:	53                   	push   %ebx
  8002d7:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002de:	50                   	push   %eax
  8002df:	e8 0a fe ff ff       	call   8000ee <ide_read>
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	0f 88 86 00 00 00    	js     800375 <bc_pgfault+0xf7>
	
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 e8 0c             	shr    $0xc,%eax
  8002f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002fb:	83 ec 0c             	sub    $0xc,%esp
  8002fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800303:	50                   	push   %eax
  800304:	53                   	push   %ebx
  800305:	6a 00                	push   $0x0
  800307:	53                   	push   %ebx
  800308:	6a 00                	push   $0x0
  80030a:	e8 d7 22 00 00       	call   8025e6 <sys_page_map>
  80030f:	83 c4 20             	add    $0x20,%esp
  800312:	85 c0                	test   %eax,%eax
  800314:	78 72                	js     800388 <bc_pgfault+0x10a>
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800316:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  80031d:	74 10                	je     80032f <bc_pgfault+0xb1>
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	56                   	push   %esi
  800323:	e8 fb 04 00 00       	call   800823 <block_is_free>
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	84 c0                	test   %al,%al
  80032d:	75 6b                	jne    80039a <bc_pgfault+0x11c>
		panic("reading free block %08x\n", blockno);
}
  80032f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	ff 72 04             	push   0x4(%edx)
  80033c:	53                   	push   %ebx
  80033d:	ff 72 28             	push   0x28(%edx)
  800340:	68 b4 38 80 00       	push   $0x8038b4
  800345:	6a 27                	push   $0x27
  800347:	68 90 39 80 00       	push   $0x803990
  80034c:	e8 a1 17 00 00       	call   801af2 <_panic>
		panic("reading non-existent block %08x\n", blockno);
  800351:	56                   	push   %esi
  800352:	68 e4 38 80 00       	push   $0x8038e4
  800357:	6a 2c                	push   $0x2c
  800359:	68 90 39 80 00       	push   $0x803990
  80035e:	e8 8f 17 00 00       	call   801af2 <_panic>
		panic("bc_pgfault, sys_page_alloc: %e", r);
  800363:	50                   	push   %eax
  800364:	68 08 39 80 00       	push   $0x803908
  800369:	6a 36                	push   $0x36
  80036b:	68 90 39 80 00       	push   $0x803990
  800370:	e8 7d 17 00 00       	call   801af2 <_panic>
	if( r= ide_read(blockno * BLKSECTS , addr, BLKSECTS)<0 ) panic("bc_pgfault, ide_read: %e", r);
  800375:	6a 01                	push   $0x1
  800377:	68 98 39 80 00       	push   $0x803998
  80037c:	6a 38                	push   $0x38
  80037e:	68 90 39 80 00       	push   $0x803990
  800383:	e8 6a 17 00 00       	call   801af2 <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800388:	50                   	push   %eax
  800389:	68 28 39 80 00       	push   $0x803928
  80038e:	6a 3d                	push   $0x3d
  800390:	68 90 39 80 00       	push   $0x803990
  800395:	e8 58 17 00 00       	call   801af2 <_panic>
		panic("reading free block %08x\n", blockno);
  80039a:	56                   	push   %esi
  80039b:	68 b1 39 80 00       	push   $0x8039b1
  8003a0:	6a 43                	push   $0x43
  8003a2:	68 90 39 80 00       	push   $0x803990
  8003a7:	e8 46 17 00 00       	call   801af2 <_panic>

008003ac <diskaddr>:
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	74 19                	je     8003d2 <diskaddr+0x26>
  8003b9:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8003bf:	85 d2                	test   %edx,%edx
  8003c1:	74 05                	je     8003c8 <diskaddr+0x1c>
  8003c3:	39 42 04             	cmp    %eax,0x4(%edx)
  8003c6:	76 0a                	jbe    8003d2 <diskaddr+0x26>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c8:	05 00 00 01 00       	add    $0x10000,%eax
  8003cd:	c1 e0 0c             	shl    $0xc,%eax
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  8003d2:	50                   	push   %eax
  8003d3:	68 48 39 80 00       	push   $0x803948
  8003d8:	6a 0a                	push   $0xa
  8003da:	68 90 39 80 00       	push   $0x803990
  8003df:	e8 0e 17 00 00       	call   801af2 <_panic>

008003e4 <va_is_mapped>:
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003ea:	89 d0                	mov    %edx,%eax
  8003ec:	c1 e8 16             	shr    $0x16,%eax
  8003ef:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	f6 c1 01             	test   $0x1,%cl
  8003fe:	74 0d                	je     80040d <va_is_mapped+0x29>
  800400:	c1 ea 0c             	shr    $0xc,%edx
  800403:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80040a:	83 e0 01             	and    $0x1,%eax
  80040d:	83 e0 01             	and    $0x1,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <va_is_dirty>:
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	c1 e8 0c             	shr    $0xc,%eax
  80041b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800422:	c1 e8 06             	shr    $0x6,%eax
  800425:	83 e0 01             	and    $0x1,%eax
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	56                   	push   %esi
  80042e:	53                   	push   %ebx
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800432:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800438:	81 fe ff ff ff bf    	cmp    $0xbfffffff,%esi
  80043e:	77 1e                	ja     80045e <flush_block+0x34>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	//panic("flush_block not implemented");
	int r;
	addr =(void *) ROUNDDOWN(addr, PGSIZE);
  800440:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800445:	89 c3                	mov    %eax,%ebx
	if(va_is_mapped(addr) && va_is_dirty(addr)){
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	50                   	push   %eax
  80044b:	e8 94 ff ff ff       	call   8003e4 <va_is_mapped>
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	84 c0                	test   %al,%al
  800455:	75 19                	jne    800470 <flush_block+0x46>
			panic("flush_block, ide_write: %e", r);
		
		if( (r= sys_page_map(0,addr,0,addr, /*uvpt[PGNUM(va)] & 不需要，直接按照注释用即可*/ PTE_SYSCALL ) ) < 0 )       
			panic("flush_block, sys_page_map: %e", r);
	}
}
  800457:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80045a:	5b                   	pop    %ebx
  80045b:	5e                   	pop    %esi
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  80045e:	50                   	push   %eax
  80045f:	68 ca 39 80 00       	push   $0x8039ca
  800464:	6a 53                	push   $0x53
  800466:	68 90 39 80 00       	push   $0x803990
  80046b:	e8 82 16 00 00       	call   801af2 <_panic>
	if(va_is_mapped(addr) && va_is_dirty(addr)){
  800470:	83 ec 0c             	sub    $0xc,%esp
  800473:	53                   	push   %ebx
  800474:	e8 99 ff ff ff       	call   800412 <va_is_dirty>
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	84 c0                	test   %al,%al
  80047e:	74 d7                	je     800457 <flush_block+0x2d>
		if(( r= ide_write(blockno * BLKSECTS , addr, BLKSECTS)) < 0 ) 
  800480:	83 ec 04             	sub    $0x4,%esp
  800483:	6a 08                	push   $0x8
  800485:	53                   	push   %ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800486:	c1 ee 0c             	shr    $0xc,%esi
		if(( r= ide_write(blockno * BLKSECTS , addr, BLKSECTS)) < 0 ) 
  800489:	c1 e6 03             	shl    $0x3,%esi
  80048c:	56                   	push   %esi
  80048d:	e8 24 fd ff ff       	call   8001b6 <ide_write>
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 c0                	test   %eax,%eax
  800497:	78 2c                	js     8004c5 <flush_block+0x9b>
		if( (r= sys_page_map(0,addr,0,addr, /*uvpt[PGNUM(va)] & 不需要，直接按照注释用即可*/ PTE_SYSCALL ) ) < 0 )       
  800499:	83 ec 0c             	sub    $0xc,%esp
  80049c:	68 07 0e 00 00       	push   $0xe07
  8004a1:	53                   	push   %ebx
  8004a2:	6a 00                	push   $0x0
  8004a4:	53                   	push   %ebx
  8004a5:	6a 00                	push   $0x0
  8004a7:	e8 3a 21 00 00       	call   8025e6 <sys_page_map>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 a4                	jns    800457 <flush_block+0x2d>
			panic("flush_block, sys_page_map: %e", r);
  8004b3:	50                   	push   %eax
  8004b4:	68 00 3a 80 00       	push   $0x803a00
  8004b9:	6a 5e                	push   $0x5e
  8004bb:	68 90 39 80 00       	push   $0x803990
  8004c0:	e8 2d 16 00 00       	call   801af2 <_panic>
			panic("flush_block, ide_write: %e", r);
  8004c5:	50                   	push   %eax
  8004c6:	68 e5 39 80 00       	push   $0x8039e5
  8004cb:	6a 5b                	push   $0x5b
  8004cd:	68 90 39 80 00       	push   $0x803990
  8004d2:	e8 1b 16 00 00       	call   801af2 <_panic>

008004d7 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	53                   	push   %ebx
  8004db:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004e1:	68 7e 02 80 00       	push   $0x80027e
  8004e6:	e8 a9 22 00 00       	call   802794 <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  8004eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f2:	e8 b5 fe ff ff       	call   8003ac <diskaddr>
  8004f7:	83 c4 0c             	add    $0xc,%esp
  8004fa:	68 08 01 00 00       	push   $0x108
  8004ff:	50                   	push   %eax
  800500:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800506:	50                   	push   %eax
  800507:	e8 31 1e 00 00       	call   80233d <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80050c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800513:	e8 94 fe ff ff       	call   8003ac <diskaddr>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	68 1e 3a 80 00       	push   $0x803a1e
  800520:	50                   	push   %eax
  800521:	e8 81 1c 00 00       	call   8021a7 <strcpy>
	flush_block(diskaddr(1));
  800526:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052d:	e8 7a fe ff ff       	call   8003ac <diskaddr>
  800532:	89 04 24             	mov    %eax,(%esp)
  800535:	e8 f0 fe ff ff       	call   80042a <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80053a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800541:	e8 66 fe ff ff       	call   8003ac <diskaddr>
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	e8 96 fe ff ff       	call   8003e4 <va_is_mapped>
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	84 c0                	test   %al,%al
  800553:	0f 84 d1 01 00 00    	je     80072a <bc_init+0x253>
	assert(!va_is_dirty(diskaddr(1)));
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	6a 01                	push   $0x1
  80055e:	e8 49 fe ff ff       	call   8003ac <diskaddr>
  800563:	89 04 24             	mov    %eax,(%esp)
  800566:	e8 a7 fe ff ff       	call   800412 <va_is_dirty>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	84 c0                	test   %al,%al
  800570:	0f 85 ca 01 00 00    	jne    800740 <bc_init+0x269>
	sys_page_unmap(0, diskaddr(1));
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	6a 01                	push   $0x1
  80057b:	e8 2c fe ff ff       	call   8003ac <diskaddr>
  800580:	83 c4 08             	add    $0x8,%esp
  800583:	50                   	push   %eax
  800584:	6a 00                	push   $0x0
  800586:	e8 9d 20 00 00       	call   802628 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80058b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800592:	e8 15 fe ff ff       	call   8003ac <diskaddr>
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	e8 45 fe ff ff       	call   8003e4 <va_is_mapped>
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	84 c0                	test   %al,%al
  8005a4:	0f 85 ac 01 00 00    	jne    800756 <bc_init+0x27f>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	6a 01                	push   $0x1
  8005af:	e8 f8 fd ff ff       	call   8003ac <diskaddr>
  8005b4:	83 c4 08             	add    $0x8,%esp
  8005b7:	68 1e 3a 80 00       	push   $0x803a1e
  8005bc:	50                   	push   %eax
  8005bd:	e8 96 1c 00 00       	call   802258 <strcmp>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	0f 85 9f 01 00 00    	jne    80076c <bc_init+0x295>
	memmove(diskaddr(1), &backup, sizeof backup);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	6a 01                	push   $0x1
  8005d2:	e8 d5 fd ff ff       	call   8003ac <diskaddr>
  8005d7:	83 c4 0c             	add    $0xc,%esp
  8005da:	68 08 01 00 00       	push   $0x108
  8005df:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8005e5:	53                   	push   %ebx
  8005e6:	50                   	push   %eax
  8005e7:	e8 51 1d 00 00       	call   80233d <memmove>
	flush_block(diskaddr(1));
  8005ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005f3:	e8 b4 fd ff ff       	call   8003ac <diskaddr>
  8005f8:	89 04 24             	mov    %eax,(%esp)
  8005fb:	e8 2a fe ff ff       	call   80042a <flush_block>
	memmove(&backup, diskaddr(1), sizeof backup);
  800600:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800607:	e8 a0 fd ff ff       	call   8003ac <diskaddr>
  80060c:	83 c4 0c             	add    $0xc,%esp
  80060f:	68 08 01 00 00       	push   $0x108
  800614:	50                   	push   %eax
  800615:	53                   	push   %ebx
  800616:	e8 22 1d 00 00       	call   80233d <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80061b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800622:	e8 85 fd ff ff       	call   8003ac <diskaddr>
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	68 1e 3a 80 00       	push   $0x803a1e
  80062f:	50                   	push   %eax
  800630:	e8 72 1b 00 00       	call   8021a7 <strcpy>
	flush_block(diskaddr(1) + 20);
  800635:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063c:	e8 6b fd ff ff       	call   8003ac <diskaddr>
  800641:	83 c0 14             	add    $0x14,%eax
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	e8 de fd ff ff       	call   80042a <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80064c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800653:	e8 54 fd ff ff       	call   8003ac <diskaddr>
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	e8 84 fd ff ff       	call   8003e4 <va_is_mapped>
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	84 c0                	test   %al,%al
  800665:	0f 84 17 01 00 00    	je     800782 <bc_init+0x2ab>
	sys_page_unmap(0, diskaddr(1));
  80066b:	83 ec 0c             	sub    $0xc,%esp
  80066e:	6a 01                	push   $0x1
  800670:	e8 37 fd ff ff       	call   8003ac <diskaddr>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	50                   	push   %eax
  800679:	6a 00                	push   $0x0
  80067b:	e8 a8 1f 00 00       	call   802628 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800680:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800687:	e8 20 fd ff ff       	call   8003ac <diskaddr>
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 50 fd ff ff       	call   8003e4 <va_is_mapped>
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	84 c0                	test   %al,%al
  800699:	0f 85 fc 00 00 00    	jne    80079b <bc_init+0x2c4>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80069f:	83 ec 0c             	sub    $0xc,%esp
  8006a2:	6a 01                	push   $0x1
  8006a4:	e8 03 fd ff ff       	call   8003ac <diskaddr>
  8006a9:	83 c4 08             	add    $0x8,%esp
  8006ac:	68 1e 3a 80 00       	push   $0x803a1e
  8006b1:	50                   	push   %eax
  8006b2:	e8 a1 1b 00 00       	call   802258 <strcmp>
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	85 c0                	test   %eax,%eax
  8006bc:	0f 85 f2 00 00 00    	jne    8007b4 <bc_init+0x2dd>
	memmove(diskaddr(1), &backup, sizeof backup);
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	6a 01                	push   $0x1
  8006c7:	e8 e0 fc ff ff       	call   8003ac <diskaddr>
  8006cc:	83 c4 0c             	add    $0xc,%esp
  8006cf:	68 08 01 00 00       	push   $0x108
  8006d4:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8006da:	52                   	push   %edx
  8006db:	50                   	push   %eax
  8006dc:	e8 5c 1c 00 00       	call   80233d <memmove>
	flush_block(diskaddr(1));
  8006e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e8:	e8 bf fc ff ff       	call   8003ac <diskaddr>
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	e8 35 fd ff ff       	call   80042a <flush_block>
	cprintf("block cache is good\n");
  8006f5:	c7 04 24 5a 3a 80 00 	movl   $0x803a5a,(%esp)
  8006fc:	e8 cc 14 00 00       	call   801bcd <cprintf>
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800701:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800708:	e8 9f fc ff ff       	call   8003ac <diskaddr>
  80070d:	83 c4 0c             	add    $0xc,%esp
  800710:	68 08 01 00 00       	push   $0x108
  800715:	50                   	push   %eax
  800716:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	e8 1b 1c 00 00       	call   80233d <memmove>
}
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800728:	c9                   	leave  
  800729:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  80072a:	68 40 3a 80 00       	push   $0x803a40
  80072f:	68 9d 38 80 00       	push   $0x80389d
  800734:	6a 6f                	push   $0x6f
  800736:	68 90 39 80 00       	push   $0x803990
  80073b:	e8 b2 13 00 00       	call   801af2 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800740:	68 25 3a 80 00       	push   $0x803a25
  800745:	68 9d 38 80 00       	push   $0x80389d
  80074a:	6a 70                	push   $0x70
  80074c:	68 90 39 80 00       	push   $0x803990
  800751:	e8 9c 13 00 00       	call   801af2 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800756:	68 3f 3a 80 00       	push   $0x803a3f
  80075b:	68 9d 38 80 00       	push   $0x80389d
  800760:	6a 74                	push   $0x74
  800762:	68 90 39 80 00       	push   $0x803990
  800767:	e8 86 13 00 00       	call   801af2 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80076c:	68 6c 39 80 00       	push   $0x80396c
  800771:	68 9d 38 80 00       	push   $0x80389d
  800776:	6a 77                	push   $0x77
  800778:	68 90 39 80 00       	push   $0x803990
  80077d:	e8 70 13 00 00       	call   801af2 <_panic>
	assert(va_is_mapped(diskaddr(1)));
  800782:	68 40 3a 80 00       	push   $0x803a40
  800787:	68 9d 38 80 00       	push   $0x80389d
  80078c:	68 88 00 00 00       	push   $0x88
  800791:	68 90 39 80 00       	push   $0x803990
  800796:	e8 57 13 00 00       	call   801af2 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  80079b:	68 3f 3a 80 00       	push   $0x803a3f
  8007a0:	68 9d 38 80 00       	push   $0x80389d
  8007a5:	68 90 00 00 00       	push   $0x90
  8007aa:	68 90 39 80 00       	push   $0x803990
  8007af:	e8 3e 13 00 00       	call   801af2 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007b4:	68 6c 39 80 00       	push   $0x80396c
  8007b9:	68 9d 38 80 00       	push   $0x80389d
  8007be:	68 93 00 00 00       	push   $0x93
  8007c3:	68 90 39 80 00       	push   $0x803990
  8007c8:	e8 25 13 00 00       	call   801af2 <_panic>

008007cd <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007d3:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8007d8:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007de:	75 1b                	jne    8007fb <check_super+0x2e>
		panic("bad file system magic number");

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007e0:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e7:	77 26                	ja     80080f <check_super+0x42>
		panic("file system is too large");

	cprintf("superblock is good\n");
  8007e9:	83 ec 0c             	sub    $0xc,%esp
  8007ec:	68 ad 3a 80 00       	push   $0x803aad
  8007f1:	e8 d7 13 00 00       	call   801bcd <cprintf>
}
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
		panic("bad file system magic number");
  8007fb:	83 ec 04             	sub    $0x4,%esp
  8007fe:	68 6f 3a 80 00       	push   $0x803a6f
  800803:	6a 12                	push   $0x12
  800805:	68 8c 3a 80 00       	push   $0x803a8c
  80080a:	e8 e3 12 00 00       	call   801af2 <_panic>
		panic("file system is too large");
  80080f:	83 ec 04             	sub    $0x4,%esp
  800812:	68 94 3a 80 00       	push   $0x803a94
  800817:	6a 15                	push   $0x15
  800819:	68 8c 3a 80 00       	push   $0x803a8c
  80081e:	e8 cf 12 00 00       	call   801af2 <_panic>

00800823 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80082a:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80082f:	85 c0                	test   %eax,%eax
  800831:	74 29                	je     80085c <block_is_free+0x39>
		return 0;
  800833:	ba 00 00 00 00       	mov    $0x0,%edx
	if (super == 0 || blockno >= super->s_nblocks)
  800838:	39 48 04             	cmp    %ecx,0x4(%eax)
  80083b:	76 18                	jbe    800855 <block_is_free+0x32>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80083d:	89 cb                	mov    %ecx,%ebx
  80083f:	c1 eb 05             	shr    $0x5,%ebx
  800842:	b8 01 00 00 00       	mov    $0x1,%eax
  800847:	d3 e0                	shl    %cl,%eax
  800849:	8b 15 00 a0 80 00    	mov    0x80a000,%edx
  80084f:	23 04 9a             	and    (%edx,%ebx,4),%eax
  800852:	0f 95 c2             	setne  %dl
		return 1;
	return 0;
}
  800855:	89 d0                	mov    %edx,%eax
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    
		return 0;
  80085c:	ba 00 00 00 00       	mov    $0x0,%edx
  800861:	eb f2                	jmp    800855 <block_is_free+0x32>

00800863 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	83 ec 04             	sub    $0x4,%esp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 1a                	je     80088b <free_block+0x28>
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);//从此处可以看出 位图 中1代表空闲。
  800871:	89 cb                	mov    %ecx,%ebx
  800873:	c1 eb 05             	shr    $0x5,%ebx
  800876:	8b 15 00 a0 80 00    	mov    0x80a000,%edx
  80087c:	b8 01 00 00 00       	mov    $0x1,%eax
  800881:	d3 e0                	shl    %cl,%eax
  800883:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    
		panic("attempt to free zero block");
  80088b:	83 ec 04             	sub    $0x4,%esp
  80088e:	68 c1 3a 80 00       	push   $0x803ac1
  800893:	6a 30                	push   $0x30
  800895:	68 8c 3a 80 00       	push   $0x803a8c
  80089a:	e8 53 12 00 00       	call   801af2 <_panic>

0080089f <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	for(uint32_t i=0; i<super->s_nblocks ; i++){
  8008a4:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8008a9:	8b 70 04             	mov    0x4(%eax),%esi
  8008ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008b1:	eb 03                	jmp    8008b6 <alloc_block+0x17>
  8008b3:	83 c3 01             	add    $0x1,%ebx
  8008b6:	39 de                	cmp    %ebx,%esi
  8008b8:	74 41                	je     8008fb <alloc_block+0x5c>
		if( block_is_free(i) ){
  8008ba:	83 ec 0c             	sub    $0xc,%esp
  8008bd:	53                   	push   %ebx
  8008be:	e8 60 ff ff ff       	call   800823 <block_is_free>
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 e9                	je     8008b3 <alloc_block+0x14>
			bitmap[i/32] &=  ~( 1<<(i%32) );//0代表占用
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	c1 e8 05             	shr    $0x5,%eax
  8008cf:	c1 e0 02             	shl    $0x2,%eax
  8008d2:	89 c6                	mov    %eax,%esi
  8008d4:	03 35 00 a0 80 00    	add    0x80a000,%esi
  8008da:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  8008df:	89 d9                	mov    %ebx,%ecx
  8008e1:	d3 c2                	rol    %cl,%edx
  8008e3:	21 16                	and    %edx,(%esi)
			flush_block(&bitmap[i/32]);
  8008e5:	83 ec 0c             	sub    $0xc,%esp
  8008e8:	03 05 00 a0 80 00    	add    0x80a000,%eax
  8008ee:	50                   	push   %eax
  8008ef:	e8 36 fb ff ff       	call   80042a <flush_block>
			return i;
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	eb 05                	jmp    800900 <alloc_block+0x61>
		} 
	}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  8008fb:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <file_block_walk>:
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
//将文件内的块偏移量映射到struct File中该块或间接块的指针
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	83 ec 1c             	sub    $0x1c,%esp
  800910:	89 c6                	mov    %eax,%esi
  800912:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
       // LAB 5: Your code here.
       //panic("file_block_walk not implemented");
       
       int r;
       if (filebno >= NDIRECT + NINDIRECT)  return -E_INVAL;
  800918:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80091e:	0f 87 88 00 00 00    	ja     8009ac <file_block_walk+0xa5>
       
       if(filebno<NDIRECT){
  800924:	83 fa 09             	cmp    $0x9,%edx
  800927:	76 73                	jbe    80099c <file_block_walk+0x95>
		*ppdiskbno=& (f->f_direct[filebno]);
		return 0;
       }
       
       filebno -= NDIRECT;
  800929:	8d 5a f6             	lea    -0xa(%edx),%ebx
       //如果   indirect block还没有被分配
       if(f->f_indirect==0){
  80092c:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800933:	75 41                	jne    800976 <file_block_walk+0x6f>
		if(alloc==0) return -E_NOT_FOUND;
  800935:	84 c0                	test   %al,%al
  800937:	74 7a                	je     8009b3 <file_block_walk+0xac>
		if((r=alloc_block() )<0 ) return -E_NO_DISK;
  800939:	e8 61 ff ff ff       	call   80089f <alloc_block>
  80093e:	89 c7                	mov    %eax,%edi
  800940:	85 c0                	test   %eax,%eax
  800942:	78 76                	js     8009ba <file_block_walk+0xb3>
		f->f_indirect=r;
  800944:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
		memset(diskaddr(r), 0, BLKSIZE);
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	50                   	push   %eax
  80094e:	e8 59 fa ff ff       	call   8003ac <diskaddr>
  800953:	83 c4 0c             	add    $0xc,%esp
  800956:	68 00 10 00 00       	push   $0x1000
  80095b:	6a 00                	push   $0x0
  80095d:	50                   	push   %eax
  80095e:	e8 94 19 00 00       	call   8022f7 <memset>
		flush_block(diskaddr(r));//刷新回磁盘
  800963:	89 3c 24             	mov    %edi,(%esp)
  800966:	e8 41 fa ff ff       	call   8003ac <diskaddr>
  80096b:	89 04 24             	mov    %eax,(%esp)
  80096e:	e8 b7 fa ff ff       	call   80042a <flush_block>
  800973:	83 c4 10             	add    $0x10,%esp
       }
       *ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + filebno;
  800976:	83 ec 0c             	sub    $0xc,%esp
  800979:	ff b6 b0 00 00 00    	push   0xb0(%esi)
  80097f:	e8 28 fa ff ff       	call   8003ac <diskaddr>
  800984:	8d 04 98             	lea    (%eax,%ebx,4),%eax
  800987:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80098a:	89 03                	mov    %eax,(%ebx)
       return 0;     
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800994:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    
		*ppdiskbno=& (f->f_direct[filebno]);
  80099c:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  8009a3:	89 01                	mov    %eax,(%ecx)
		return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	eb e8                	jmp    800994 <file_block_walk+0x8d>
       if (filebno >= NDIRECT + NINDIRECT)  return -E_INVAL;
  8009ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b1:	eb e1                	jmp    800994 <file_block_walk+0x8d>
		if(alloc==0) return -E_NOT_FOUND;
  8009b3:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8009b8:	eb da                	jmp    800994 <file_block_walk+0x8d>
		if((r=alloc_block() )<0 ) return -E_NO_DISK;
  8009ba:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  8009bf:	eb d3                	jmp    800994 <file_block_walk+0x8d>

008009c1 <check_bitmap>:
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009c6:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8009cb:	8b 70 04             	mov    0x4(%eax),%esi
  8009ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009d3:	89 d8                	mov    %ebx,%eax
  8009d5:	c1 e0 0f             	shl    $0xf,%eax
  8009d8:	39 c6                	cmp    %eax,%esi
  8009da:	76 2e                	jbe    800a0a <check_bitmap+0x49>
		assert(!block_is_free(2+i));
  8009dc:	83 ec 0c             	sub    $0xc,%esp
  8009df:	8d 43 02             	lea    0x2(%ebx),%eax
  8009e2:	50                   	push   %eax
  8009e3:	e8 3b fe ff ff       	call   800823 <block_is_free>
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	84 c0                	test   %al,%al
  8009ed:	75 05                	jne    8009f4 <check_bitmap+0x33>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009ef:	83 c3 01             	add    $0x1,%ebx
  8009f2:	eb df                	jmp    8009d3 <check_bitmap+0x12>
		assert(!block_is_free(2+i));
  8009f4:	68 dc 3a 80 00       	push   $0x803adc
  8009f9:	68 9d 38 80 00       	push   $0x80389d
  8009fe:	6a 5a                	push   $0x5a
  800a00:	68 8c 3a 80 00       	push   $0x803a8c
  800a05:	e8 e8 10 00 00       	call   801af2 <_panic>
	assert(!block_is_free(0));
  800a0a:	83 ec 0c             	sub    $0xc,%esp
  800a0d:	6a 00                	push   $0x0
  800a0f:	e8 0f fe ff ff       	call   800823 <block_is_free>
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	84 c0                	test   %al,%al
  800a19:	75 28                	jne    800a43 <check_bitmap+0x82>
	assert(!block_is_free(1));
  800a1b:	83 ec 0c             	sub    $0xc,%esp
  800a1e:	6a 01                	push   $0x1
  800a20:	e8 fe fd ff ff       	call   800823 <block_is_free>
  800a25:	83 c4 10             	add    $0x10,%esp
  800a28:	84 c0                	test   %al,%al
  800a2a:	75 2d                	jne    800a59 <check_bitmap+0x98>
	cprintf("bitmap is good\n");
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	68 14 3b 80 00       	push   $0x803b14
  800a34:	e8 94 11 00 00       	call   801bcd <cprintf>
}
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
	assert(!block_is_free(0));
  800a43:	68 f0 3a 80 00       	push   $0x803af0
  800a48:	68 9d 38 80 00       	push   $0x80389d
  800a4d:	6a 5d                	push   $0x5d
  800a4f:	68 8c 3a 80 00       	push   $0x803a8c
  800a54:	e8 99 10 00 00       	call   801af2 <_panic>
	assert(!block_is_free(1));
  800a59:	68 02 3b 80 00       	push   $0x803b02
  800a5e:	68 9d 38 80 00       	push   $0x80389d
  800a63:	6a 5e                	push   $0x5e
  800a65:	68 8c 3a 80 00       	push   $0x803a8c
  800a6a:	e8 83 10 00 00       	call   801af2 <_panic>

00800a6f <fs_init>:
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800a75:	e8 e9 f5 ff ff       	call   800063 <ide_probe_disk1>
  800a7a:	84 c0                	test   %al,%al
  800a7c:	74 41                	je     800abf <fs_init+0x50>
		ide_set_disk(1);
  800a7e:	83 ec 0c             	sub    $0xc,%esp
  800a81:	6a 01                	push   $0x1
  800a83:	e8 3d f6 ff ff       	call   8000c5 <ide_set_disk>
  800a88:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a8b:	e8 47 fa ff ff       	call   8004d7 <bc_init>
	super = diskaddr(1);
  800a90:	83 ec 0c             	sub    $0xc,%esp
  800a93:	6a 01                	push   $0x1
  800a95:	e8 12 f9 ff ff       	call   8003ac <diskaddr>
  800a9a:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_super();
  800a9f:	e8 29 fd ff ff       	call   8007cd <check_super>
	bitmap = diskaddr(2);
  800aa4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800aab:	e8 fc f8 ff ff       	call   8003ac <diskaddr>
  800ab0:	a3 00 a0 80 00       	mov    %eax,0x80a000
	check_bitmap();
  800ab5:	e8 07 ff ff ff       	call   8009c1 <check_bitmap>
}
  800aba:	83 c4 10             	add    $0x10,%esp
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    
		ide_set_disk(0);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	6a 00                	push   $0x0
  800ac4:	e8 fc f5 ff ff       	call   8000c5 <ide_set_disk>
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	eb bd                	jmp    800a8b <fs_init+0x1c>

00800ace <file_get_block>:
//
// Hint: Use file_block_walk and alloc_block.
//将文件内的块偏移量映射到实际的磁盘块，在必要时分配一个新的磁盘块。
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 1c             	sub    $0x1c,%esp
       // LAB 5: Your code here.
       //panic("file_get_block not implemented");
       uint32_t *pdiskbno=NULL;
  800ad6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
       int r;
       if( (r = file_block_walk(f, filebno, &pdiskbno, 1)) < 0) return r;
  800add:	6a 01                	push   $0x1
  800adf:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	e8 1a fe ff ff       	call   800907 <file_block_walk>
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 58                	js     800b4e <file_get_block+0x80>
       
       //file_block_walk(): 有可能f->f_direct[filebno] 或者 间接块项为0, 即还未分配。
       if(*pdiskbno == 0){
  800af6:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800af9:	83 3e 00             	cmpl   $0x0,(%esi)
  800afc:	75 39                	jne    800b37 <file_get_block+0x69>
		if ( (r = alloc_block()) < 0)  return r;
  800afe:	e8 9c fd ff ff       	call   80089f <alloc_block>
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 45                	js     800b4e <file_get_block+0x80>
		*pdiskbno = r;
  800b09:	89 06                	mov    %eax,(%esi)
		memset(diskaddr(r), 0, BLKSIZE);
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	50                   	push   %eax
  800b0f:	e8 98 f8 ff ff       	call   8003ac <diskaddr>
  800b14:	83 c4 0c             	add    $0xc,%esp
  800b17:	68 00 10 00 00       	push   $0x1000
  800b1c:	6a 00                	push   $0x0
  800b1e:	50                   	push   %eax
  800b1f:	e8 d3 17 00 00       	call   8022f7 <memset>
		flush_block(diskaddr(r));
  800b24:	89 1c 24             	mov    %ebx,(%esp)
  800b27:	e8 80 f8 ff ff       	call   8003ac <diskaddr>
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	e8 f6 f8 ff ff       	call   80042a <flush_block>
  800b34:	83 c4 10             	add    $0x10,%esp
       }
       // 最终指向块
       *blk = diskaddr(*pdiskbno);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	ff 36                	push   (%esi)
  800b3c:	e8 6b f8 ff ff       	call   8003ac <diskaddr>
  800b41:	8b 55 10             	mov    0x10(%ebp),%edx
  800b44:	89 02                	mov    %eax,(%edx)
       return 0;
  800b46:	83 c4 10             	add    $0x10,%esp
  800b49:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b63:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b69:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
	while (*p == '/')
  800b6f:	eb 03                	jmp    800b74 <walk_path+0x1d>
		p++;
  800b71:	83 c0 01             	add    $0x1,%eax
	while (*p == '/')
  800b74:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b77:	74 f8                	je     800b71 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b79:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  800b7f:	83 c1 08             	add    $0x8,%ecx
  800b82:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b88:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b8f:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b95:	85 c9                	test   %ecx,%ecx
  800b97:	74 06                	je     800b9f <walk_path+0x48>
		*pdir = 0;
  800b99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b9f:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800ba5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	dir = 0;
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800bb0:	e9 c2 01 00 00       	jmp    800d77 <walk_path+0x220>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800bb5:	83 c7 01             	add    $0x1,%edi
		while (*path != '/' && *path != '\0')
  800bb8:	0f b6 17             	movzbl (%edi),%edx
  800bbb:	80 fa 2f             	cmp    $0x2f,%dl
  800bbe:	74 04                	je     800bc4 <walk_path+0x6d>
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 f1                	jne    800bb5 <walk_path+0x5e>
		if (path - p >= MAXNAMELEN)
  800bc4:	89 fb                	mov    %edi,%ebx
  800bc6:	29 c3                	sub    %eax,%ebx
  800bc8:	83 fb 7f             	cmp    $0x7f,%ebx
  800bcb:	0f 8f 7e 01 00 00    	jg     800d4f <walk_path+0x1f8>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800bd1:	83 ec 04             	sub    $0x4,%esp
  800bd4:	53                   	push   %ebx
  800bd5:	50                   	push   %eax
  800bd6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800bdc:	50                   	push   %eax
  800bdd:	e8 5b 17 00 00       	call   80233d <memmove>
		name[path - p] = '\0';
  800be2:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800be9:	00 
	while (*p == '/')
  800bea:	83 c4 10             	add    $0x10,%esp
  800bed:	eb 03                	jmp    800bf2 <walk_path+0x9b>
		p++;
  800bef:	83 c7 01             	add    $0x1,%edi
	while (*p == '/')
  800bf2:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800bf5:	74 f8                	je     800bef <walk_path+0x98>
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800bf7:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800bfd:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c04:	0f 85 4c 01 00 00    	jne    800d56 <walk_path+0x1ff>
	assert((dir->f_size % BLKSIZE) == 0);
  800c0a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c10:	89 c1                	mov    %eax,%ecx
  800c12:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  800c18:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
  800c1e:	0f 85 8e 00 00 00    	jne    800cb2 <walk_path+0x15b>
	nblock = dir->f_size / BLKSIZE;
  800c24:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	0f 48 c2             	cmovs  %edx,%eax
  800c2f:	c1 f8 0c             	sar    $0xc,%eax
  800c32:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
			if (strcmp(f[j].f_name, name) == 0) {
  800c38:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  800c3e:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800c44:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c4a:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c50:	74 79                	je     800ccb <walk_path+0x174>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c52:	83 ec 04             	sub    $0x4,%esp
  800c55:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c5b:	50                   	push   %eax
  800c5c:	ff b5 50 ff ff ff    	push   -0xb0(%ebp)
  800c62:	ff b5 4c ff ff ff    	push   -0xb4(%ebp)
  800c68:	e8 61 fe ff ff       	call   800ace <file_get_block>
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	85 c0                	test   %eax,%eax
  800c72:	0f 88 a3 00 00 00    	js     800d1b <walk_path+0x1c4>
  800c78:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c7e:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			if (strcmp(f[j].f_name, name) == 0) {
  800c84:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c8a:	83 ec 08             	sub    $0x8,%esp
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	e8 c4 15 00 00       	call   802258 <strcmp>
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	85 c0                	test   %eax,%eax
  800c99:	0f 84 be 00 00 00    	je     800d5d <walk_path+0x206>
		for (j = 0; j < BLKFILES; j++)
  800c9f:	81 c3 00 01 00 00    	add    $0x100,%ebx
  800ca5:	39 df                	cmp    %ebx,%edi
  800ca7:	75 db                	jne    800c84 <walk_path+0x12d>
	for (i = 0; i < nblock; i++) {
  800ca9:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800cb0:	eb 92                	jmp    800c44 <walk_path+0xed>
	assert((dir->f_size % BLKSIZE) == 0);
  800cb2:	68 24 3b 80 00       	push   $0x803b24
  800cb7:	68 9d 38 80 00       	push   $0x80389d
  800cbc:	68 da 00 00 00       	push   $0xda
  800cc1:	68 8c 3a 80 00       	push   $0x803a8c
  800cc6:	e8 27 0e 00 00       	call   801af2 <_panic>
  800ccb:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800cd1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
			if (r == -E_NOT_FOUND && *path == '\0') {
  800cd6:	80 3f 00             	cmpb   $0x0,(%edi)
  800cd9:	75 6c                	jne    800d47 <walk_path+0x1f0>
				if (pdir)
  800cdb:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 08                	je     800ced <walk_path+0x196>
					*pdir = dir;
  800ce5:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800ceb:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800ced:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cf1:	74 15                	je     800d08 <walk_path+0x1b1>
					strcpy(lastelem, name);
  800cf3:	83 ec 08             	sub    $0x8,%esp
  800cf6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800cfc:	50                   	push   %eax
  800cfd:	ff 75 08             	push   0x8(%ebp)
  800d00:	e8 a2 14 00 00       	call   8021a7 <strcpy>
  800d05:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d08:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return r;
  800d14:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d19:	eb 2c                	jmp    800d47 <walk_path+0x1f0>
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d1b:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d21:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d24:	75 21                	jne    800d47 <walk_path+0x1f0>
  800d26:	eb a9                	jmp    800cd1 <walk_path+0x17a>
		}
	}

	if (pdir)
  800d28:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	74 02                	je     800d34 <walk_path+0x1dd>
		*pdir = dir;
  800d32:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800d34:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d3a:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d40:	89 08                	mov    %ecx,(%eax)
	return 0;
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    
			return -E_BAD_PATH;
  800d4f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d54:	eb f1                	jmp    800d47 <walk_path+0x1f0>
			return -E_NOT_FOUND;
  800d56:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d5b:	eb ea                	jmp    800d47 <walk_path+0x1f0>
  800d5d:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d63:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
			if (strcmp(f[j].f_name, name) == 0) {
  800d69:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d6f:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d75:	89 f8                	mov    %edi,%eax
	while (*path != '\0') {
  800d77:	80 38 00             	cmpb   $0x0,(%eax)
  800d7a:	74 ac                	je     800d28 <walk_path+0x1d1>
  800d7c:	89 c7                	mov    %eax,%edi
  800d7e:	e9 35 fe ff ff       	jmp    800bb8 <walk_path+0x61>

00800d83 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d89:	6a 00                	push   $0x0
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	e8 bc fd ff ff       	call   800b57 <walk_path>
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
  800da6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800da9:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800dba:	39 fa                	cmp    %edi,%edx
  800dbc:	7e 7a                	jle    800e38 <file_read+0x9b>

	count = MIN(count, f->f_size - offset);
  800dbe:	29 fa                	sub    %edi,%edx
  800dc0:	39 ca                	cmp    %ecx,%edx
  800dc2:	0f 46 ca             	cmovbe %edx,%ecx
  800dc5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800dc8:	89 fb                	mov    %edi,%ebx
  800dca:	01 cf                	add    %ecx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	39 df                	cmp    %ebx,%edi
  800dd0:	76 63                	jbe    800e35 <file_read+0x98>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800dd8:	50                   	push   %eax
  800dd9:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800ddf:	85 db                	test   %ebx,%ebx
  800de1:	0f 49 c3             	cmovns %ebx,%eax
  800de4:	c1 f8 0c             	sar    $0xc,%eax
  800de7:	50                   	push   %eax
  800de8:	ff 75 08             	push   0x8(%ebp)
  800deb:	e8 de fc ff ff       	call   800ace <file_get_block>
  800df0:	83 c4 10             	add    $0x10,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 41                	js     800e38 <file_read+0x9b>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800df7:	89 da                	mov    %ebx,%edx
  800df9:	c1 fa 1f             	sar    $0x1f,%edx
  800dfc:	c1 ea 14             	shr    $0x14,%edx
  800dff:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800e02:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e07:	29 d0                	sub    %edx,%eax
  800e09:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e0e:	29 c2                	sub    %eax,%edx
  800e10:	89 f9                	mov    %edi,%ecx
  800e12:	29 f1                	sub    %esi,%ecx
  800e14:	39 ca                	cmp    %ecx,%edx
  800e16:	89 ce                	mov    %ecx,%esi
  800e18:	0f 46 f2             	cmovbe %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	56                   	push   %esi
  800e1f:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e22:	50                   	push   %eax
  800e23:	ff 75 0c             	push   0xc(%ebp)
  800e26:	e8 12 15 00 00       	call   80233d <memmove>
		pos += bn;
  800e2b:	01 f3                	add    %esi,%ebx
		buf += bn;
  800e2d:	01 75 0c             	add    %esi,0xc(%ebp)
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	eb 97                	jmp    800dcc <file_read+0x2f>
	}

	return count;
  800e35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 2c             	sub    $0x2c,%esp
  800e49:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e4c:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e52:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e55:	7f 1f                	jg     800e76 <file_set_size+0x36>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800e60:	83 ec 0c             	sub    $0xc,%esp
  800e63:	56                   	push   %esi
  800e64:	e8 c1 f5 ff ff       	call   80042a <flush_block>
	return 0;
}
  800e69:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e76:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800e7c:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e81:	0f 48 c2             	cmovs  %edx,%eax
  800e84:	c1 f8 0c             	sar    $0xc,%eax
  800e87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e95:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e9b:	0f 49 c2             	cmovns %edx,%eax
  800e9e:	c1 f8 0c             	sar    $0xc,%eax
  800ea1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	eb 3c                	jmp    800ee4 <file_set_size+0xa4>
	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800ea8:	83 7d d0 0a          	cmpl   $0xa,-0x30(%ebp)
  800eac:	77 a9                	ja     800e57 <file_set_size+0x17>
  800eae:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	74 9f                	je     800e57 <file_set_size+0x17>
		free_block(f->f_indirect);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	50                   	push   %eax
  800ebc:	e8 a2 f9 ff ff       	call   800863 <free_block>
		f->f_indirect = 0;
  800ec1:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800ec8:	00 00 00 
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	eb 87                	jmp    800e57 <file_set_size+0x17>
			cprintf("warning: file_free_block: %e", r);
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	50                   	push   %eax
  800ed4:	68 41 3b 80 00       	push   $0x803b41
  800ed9:	e8 ef 0c 00 00       	call   801bcd <cprintf>
  800ede:	83 c4 10             	add    $0x10,%esp
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ee1:	83 c3 01             	add    $0x1,%ebx
  800ee4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800ee7:	76 bf                	jbe    800ea8 <file_set_size+0x68>
	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	6a 00                	push   $0x0
  800eee:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800ef1:	89 da                	mov    %ebx,%edx
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	e8 0d fa ff ff       	call   800907 <file_block_walk>
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	78 cf                	js     800ed0 <file_set_size+0x90>
	if (*ptr) {
  800f01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f04:	8b 07                	mov    (%edi),%eax
  800f06:	85 c0                	test   %eax,%eax
  800f08:	74 d7                	je     800ee1 <file_set_size+0xa1>
		free_block(*ptr);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	50                   	push   %eax
  800f0e:	e8 50 f9 ff ff       	call   800863 <free_block>
		*ptr = 0;
  800f13:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	eb c3                	jmp    800ee1 <file_set_size+0xa1>

00800f1e <file_write>:
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 1c             	sub    $0x1c,%esp
  800f27:	8b 5d 14             	mov    0x14(%ebp),%ebx
	if (offset + count > f->f_size)
  800f2a:	89 df                	mov    %ebx,%edi
  800f2c:	03 7d 10             	add    0x10(%ebp),%edi
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	3b b8 80 00 00 00    	cmp    0x80(%eax),%edi
  800f38:	77 69                	ja     800fa3 <file_write+0x85>
	for (pos = offset; pos < offset + count; ) {
  800f3a:	89 de                	mov    %ebx,%esi
  800f3c:	39 df                	cmp    %ebx,%edi
  800f3e:	76 76                	jbe    800fb6 <file_write+0x98>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f46:	50                   	push   %eax
  800f47:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f4d:	85 db                	test   %ebx,%ebx
  800f4f:	0f 49 c3             	cmovns %ebx,%eax
  800f52:	c1 f8 0c             	sar    $0xc,%eax
  800f55:	50                   	push   %eax
  800f56:	ff 75 08             	push   0x8(%ebp)
  800f59:	e8 70 fb ff ff       	call   800ace <file_get_block>
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 54                	js     800fb9 <file_write+0x9b>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f65:	89 da                	mov    %ebx,%edx
  800f67:	c1 fa 1f             	sar    $0x1f,%edx
  800f6a:	c1 ea 14             	shr    $0x14,%edx
  800f6d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800f70:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f75:	29 d0                	sub    %edx,%eax
  800f77:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f7c:	29 c1                	sub    %eax,%ecx
  800f7e:	89 fa                	mov    %edi,%edx
  800f80:	29 f2                	sub    %esi,%edx
  800f82:	39 d1                	cmp    %edx,%ecx
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	56                   	push   %esi
  800f8d:	ff 75 0c             	push   0xc(%ebp)
  800f90:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	e8 a4 13 00 00       	call   80233d <memmove>
		pos += bn;
  800f99:	01 f3                	add    %esi,%ebx
		buf += bn;
  800f9b:	01 75 0c             	add    %esi,0xc(%ebp)
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	eb 97                	jmp    800f3a <file_write+0x1c>
		if ((r = file_set_size(f, offset + count)) < 0)
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	57                   	push   %edi
  800fa7:	50                   	push   %eax
  800fa8:	e8 93 fe ff ff       	call   800e40 <file_set_size>
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	79 86                	jns    800f3a <file_write+0x1c>
  800fb4:	eb 03                	jmp    800fb9 <file_write+0x9b>
	return count;
  800fb6:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 10             	sub    $0x10,%esp
  800fc9:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd1:	eb 03                	jmp    800fd6 <file_flush+0x15>
  800fd3:	83 c3 01             	add    $0x1,%ebx
  800fd6:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fdc:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800fe2:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800fe8:	0f 49 c2             	cmovns %edx,%eax
  800feb:	c1 f8 0c             	sar    $0xc,%eax
  800fee:	39 d8                	cmp    %ebx,%eax
  800ff0:	7e 3b                	jle    80102d <file_flush+0x6c>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	6a 00                	push   $0x0
  800ff7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ffa:	89 da                	mov    %ebx,%edx
  800ffc:	89 f0                	mov    %esi,%eax
  800ffe:	e8 04 f9 ff ff       	call   800907 <file_block_walk>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 c9                	js     800fd3 <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80100d:	85 c0                	test   %eax,%eax
  80100f:	74 c2                	je     800fd3 <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  801011:	8b 00                	mov    (%eax),%eax
  801013:	85 c0                	test   %eax,%eax
  801015:	74 bc                	je     800fd3 <file_flush+0x12>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	50                   	push   %eax
  80101b:	e8 8c f3 ff ff       	call   8003ac <diskaddr>
  801020:	89 04 24             	mov    %eax,(%esp)
  801023:	e8 02 f4 ff ff       	call   80042a <flush_block>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	eb a6                	jmp    800fd3 <file_flush+0x12>
	}
	flush_block(f);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	56                   	push   %esi
  801031:	e8 f4 f3 ff ff       	call   80042a <flush_block>
	if (f->f_indirect)
  801036:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	75 07                	jne    80104a <file_flush+0x89>
		flush_block(diskaddr(f->f_indirect));
}
  801043:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	e8 59 f3 ff ff       	call   8003ac <diskaddr>
  801053:	89 04 24             	mov    %eax,(%esp)
  801056:	e8 cf f3 ff ff       	call   80042a <flush_block>
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	eb e3                	jmp    801043 <file_flush+0x82>

00801060 <file_create>:
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	81 ec a8 00 00 00    	sub    $0xa8,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80106c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801072:	50                   	push   %eax
  801073:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801079:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	e8 d0 fa ff ff       	call   800b57 <walk_path>
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	0f 84 b9 00 00 00    	je     80114b <file_create+0xeb>
	if (r != -E_NOT_FOUND || dir == 0)
  801092:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801095:	0f 85 de 00 00 00    	jne    801179 <file_create+0x119>
  80109b:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  8010a1:	85 ff                	test   %edi,%edi
  8010a3:	0f 84 d0 00 00 00    	je     801179 <file_create+0x119>
	assert((dir->f_size % BLKSIZE) == 0);
  8010a9:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
  8010af:	89 c6                	mov    %eax,%esi
  8010b1:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
  8010b7:	75 4f                	jne    801108 <file_create+0xa8>
	nblock = dir->f_size / BLKSIZE;
  8010b9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	0f 48 c2             	cmovs  %edx,%eax
  8010c4:	c1 f8 0c             	sar    $0xc,%eax
  8010c7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < nblock; i++) {
  8010c9:	39 f3                	cmp    %esi,%ebx
  8010cb:	74 54                	je     801121 <file_create+0xc1>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	56                   	push   %esi
  8010d8:	57                   	push   %edi
  8010d9:	e8 f0 f9 ff ff       	call   800ace <file_get_block>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	0f 88 90 00 00 00    	js     801179 <file_create+0x119>
  8010e9:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010ef:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
			if (f[j].f_name[0] == '\0') {
  8010f5:	80 38 00             	cmpb   $0x0,(%eax)
  8010f8:	74 58                	je     801152 <file_create+0xf2>
		for (j = 0; j < BLKFILES; j++)
  8010fa:	05 00 01 00 00       	add    $0x100,%eax
  8010ff:	39 d0                	cmp    %edx,%eax
  801101:	75 f2                	jne    8010f5 <file_create+0x95>
	for (i = 0; i < nblock; i++) {
  801103:	83 c6 01             	add    $0x1,%esi
  801106:	eb c1                	jmp    8010c9 <file_create+0x69>
	assert((dir->f_size % BLKSIZE) == 0);
  801108:	68 24 3b 80 00       	push   $0x803b24
  80110d:	68 9d 38 80 00       	push   $0x80389d
  801112:	68 f3 00 00 00       	push   $0xf3
  801117:	68 8c 3a 80 00       	push   $0x803a8c
  80111c:	e8 d1 09 00 00       	call   801af2 <_panic>
	dir->f_size += BLKSIZE;
  801121:	81 87 80 00 00 00 00 	addl   $0x1000,0x80(%edi)
  801128:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	56                   	push   %esi
  801136:	57                   	push   %edi
  801137:	e8 92 f9 ff ff       	call   800ace <file_get_block>
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 36                	js     801179 <file_create+0x119>
	f = (struct File*) blk;
  801143:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
	return 0;
  801149:	eb 09                	jmp    801154 <file_create+0xf4>
		return -E_FILE_EXISTS;
  80114b:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801150:	eb 27                	jmp    801179 <file_create+0x119>
  801152:	89 c3                	mov    %eax,%ebx
	strcpy(f->f_name, name);
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	53                   	push   %ebx
  80115f:	e8 43 10 00 00       	call   8021a7 <strcpy>
	*pf = f;
  801164:	8b 45 0c             	mov    0xc(%ebp),%eax
  801167:	89 18                	mov    %ebx,(%eax)
	file_flush(dir);
  801169:	89 3c 24             	mov    %edi,(%esp)
  80116c:	e8 50 fe ff ff       	call   800fc1 <file_flush>
	return 0;
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	53                   	push   %ebx
  801185:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80118d:	eb 17                	jmp    8011a6 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80118f:	83 ec 0c             	sub    $0xc,%esp
  801192:	53                   	push   %ebx
  801193:	e8 14 f2 ff ff       	call   8003ac <diskaddr>
  801198:	89 04 24             	mov    %eax,(%esp)
  80119b:	e8 8a f2 ff ff       	call   80042a <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  8011a0:	83 c3 01             	add    $0x1,%ebx
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8011ab:	39 58 04             	cmp    %ebx,0x4(%eax)
  8011ae:	77 df                	ja     80118f <fs_sync+0xe>
}
  8011b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8011bb:	e8 c1 ff ff ff       	call   801181 <fs_sync>
	return 0;
}
  8011c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <serve_init>:
{
  8011c7:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  8011cc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011d6:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011d8:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011db:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011e1:	83 c0 01             	add    $0x1,%eax
  8011e4:	83 c2 10             	add    $0x10,%edx
  8011e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ec:	75 e8                	jne    8011d6 <serve_init+0xf>
}
  8011ee:	c3                   	ret    

008011ef <openfile_alloc>:
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	57                   	push   %edi
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	89 de                	mov    %ebx,%esi
  801202:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	ff b6 6c 50 80 00    	push   0x80506c(%esi)
  80120e:	e8 f4 1e 00 00       	call   803107 <pageref>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	74 17                	je     801231 <openfile_alloc+0x42>
  80121a:	83 f8 01             	cmp    $0x1,%eax
  80121d:	74 30                	je     80124f <openfile_alloc+0x60>
	for (i = 0; i < MAXOPEN; i++) {
  80121f:	83 c3 01             	add    $0x1,%ebx
  801222:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801228:	75 d6                	jne    801200 <openfile_alloc+0x11>
	return -E_MAX_OPEN;
  80122a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80122f:	eb 4f                	jmp    801280 <openfile_alloc+0x91>
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	6a 07                	push   $0x7
  801236:	89 d8                	mov    %ebx,%eax
  801238:	c1 e0 04             	shl    $0x4,%eax
  80123b:	ff b0 6c 50 80 00    	push   0x80506c(%eax)
  801241:	6a 00                	push   $0x0
  801243:	e8 5b 13 00 00       	call   8025a3 <sys_page_alloc>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 31                	js     801280 <openfile_alloc+0x91>
			opentab[i].o_fileid += MAXOPEN;
  80124f:	c1 e3 04             	shl    $0x4,%ebx
  801252:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801259:	04 00 00 
			*o = &opentab[i];
  80125c:	81 c6 60 50 80 00    	add    $0x805060,%esi
  801262:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801264:	83 ec 04             	sub    $0x4,%esp
  801267:	68 00 10 00 00       	push   $0x1000
  80126c:	6a 00                	push   $0x0
  80126e:	ff b3 6c 50 80 00    	push   0x80506c(%ebx)
  801274:	e8 7e 10 00 00       	call   8022f7 <memset>
			return (*o)->o_fileid;
  801279:	8b 07                	mov    (%edi),%eax
  80127b:	8b 00                	mov    (%eax),%eax
  80127d:	83 c4 10             	add    $0x10,%esp
}
  801280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <openfile_lookup>:
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 18             	sub    $0x18,%esp
  801291:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  801294:	89 fb                	mov    %edi,%ebx
  801296:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80129c:	89 de                	mov    %ebx,%esi
  80129e:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012a1:	ff b6 6c 50 80 00    	push   0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  8012a7:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012ad:	e8 55 1e 00 00       	call   803107 <pageref>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	83 f8 01             	cmp    $0x1,%eax
  8012b8:	7e 1d                	jle    8012d7 <openfile_lookup+0x4f>
  8012ba:	c1 e3 04             	shl    $0x4,%ebx
  8012bd:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  8012c3:	75 19                	jne    8012de <openfile_lookup+0x56>
	*po = o;
  8012c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c8:	89 30                	mov    %esi,(%eax)
	return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d2:	5b                   	pop    %ebx
  8012d3:	5e                   	pop    %esi
  8012d4:	5f                   	pop    %edi
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    
		return -E_INVAL;
  8012d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dc:	eb f1                	jmp    8012cf <openfile_lookup+0x47>
  8012de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e3:	eb ea                	jmp    8012cf <openfile_lookup+0x47>

008012e5 <serve_set_size>:
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 18             	sub    $0x18,%esp
  8012ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	ff 33                	push   (%ebx)
  8012f5:	ff 75 08             	push   0x8(%ebp)
  8012f8:	e8 8b ff ff ff       	call   801288 <openfile_lookup>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 14                	js     801318 <serve_set_size+0x33>
	return file_set_size(o->o_file, req->req_size);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 73 04             	push   0x4(%ebx)
  80130a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130d:	ff 70 04             	push   0x4(%eax)
  801310:	e8 2b fb ff ff       	call   800e40 <file_set_size>
  801315:	83 c4 10             	add    $0x10,%esp
}
  801318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <serve_read>:
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 14             	sub    $0x14,%esp
  801325:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ( (r = openfile_lookup(envid, req->req_fileid, &o) )< 0)   return r;
  801328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	ff 33                	push   (%ebx)
  80132e:	ff 75 08             	push   0x8(%ebp)
  801331:	e8 52 ff ff ff       	call   801288 <openfile_lookup>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 22                	js     80135f <serve_read+0x42>
	if ( (r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset))< 0)  return r;
  80133d:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801340:	8b 46 0c             	mov    0xc(%esi),%eax
  801343:	ff 70 04             	push   0x4(%eax)
  801346:	ff 73 04             	push   0x4(%ebx)
  801349:	53                   	push   %ebx
  80134a:	ff 76 04             	push   0x4(%esi)
  80134d:	e8 4b fa ff ff       	call   800d9d <file_read>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 06                	js     80135f <serve_read+0x42>
	o->o_fd->fd_offset += r;
  801359:	8b 56 0c             	mov    0xc(%esi),%edx
  80135c:	01 42 04             	add    %eax,0x4(%edx)
}
  80135f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <serve_write>:
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	83 ec 14             	sub    $0x14,%esp
  80136e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ( (r = openfile_lookup(envid, req->req_fileid, &o) )< 0)   return r;
  801371:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801374:	50                   	push   %eax
  801375:	ff 33                	push   (%ebx)
  801377:	ff 75 08             	push   0x8(%ebp)
  80137a:	e8 09 ff ff ff       	call   801288 <openfile_lookup>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 25                	js     8013ab <serve_write+0x45>
	if ( (r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)   return r;
  801386:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801389:	8b 46 0c             	mov    0xc(%esi),%eax
  80138c:	ff 70 04             	push   0x4(%eax)
  80138f:	ff 73 04             	push   0x4(%ebx)
  801392:	83 c3 08             	add    $0x8,%ebx
  801395:	53                   	push   %ebx
  801396:	ff 76 04             	push   0x4(%esi)
  801399:	e8 80 fb ff ff       	call   800f1e <file_write>
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 06                	js     8013ab <serve_write+0x45>
	o->o_fd->fd_offset += r;
  8013a5:	8b 56 0c             	mov    0xc(%esi),%edx
  8013a8:	01 42 04             	add    %eax,0x4(%edx)
}
  8013ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <serve_stat>:
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 14             	sub    $0x14,%esp
  8013ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	ff 33                	push   (%ebx)
  8013c3:	ff 75 08             	push   0x8(%ebp)
  8013c6:	e8 bd fe ff ff       	call   801288 <openfile_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 3c                	js     80140e <serve_stat+0x5c>
	strcpy(ret->ret_name, o->o_file->f_name);
  8013d2:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	ff 76 04             	push   0x4(%esi)
  8013db:	53                   	push   %ebx
  8013dc:	e8 c6 0d 00 00       	call   8021a7 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013e1:	8b 46 04             	mov    0x4(%esi),%eax
  8013e4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8013ea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013f0:	8b 46 04             	mov    0x4(%esi),%eax
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8013fd:	0f 94 c0             	sete   %al
  801400:	0f b6 c0             	movzbl %al,%eax
  801403:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <serve_flush>:
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80141b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801422:	ff 30                	push   (%eax)
  801424:	ff 75 08             	push   0x8(%ebp)
  801427:	e8 5c fe ff ff       	call   801288 <openfile_lookup>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 16                	js     801449 <serve_flush+0x34>
	file_flush(o->o_file);
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	ff 70 04             	push   0x4(%eax)
  80143c:	e8 80 fb ff ff       	call   800fc1 <file_flush>
	return 0;
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <serve_open>:
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801455:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  801458:	68 00 04 00 00       	push   $0x400
  80145d:	53                   	push   %ebx
  80145e:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	e8 d3 0e 00 00       	call   80233d <memmove>
	path[MAXPATHLEN-1] = 0;
  80146a:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  80146e:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801474:	89 04 24             	mov    %eax,(%esp)
  801477:	e8 73 fd ff ff       	call   8011ef <openfile_alloc>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	0f 88 ea 00 00 00    	js     801571 <serve_open+0x126>
	if (req->req_omode & O_CREAT) {
  801487:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80148e:	74 33                	je     8014c3 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	e8 ba fb ff ff       	call   801060 <file_create>
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	79 37                	jns    8014e4 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8014ad:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8014b4:	0f 85 b7 00 00 00    	jne    801571 <serve_open+0x126>
  8014ba:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014bd:	0f 85 ae 00 00 00    	jne    801571 <serve_open+0x126>
		if ((r = file_open(path, &f)) < 0) {
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	e8 aa f8 ff ff       	call   800d83 <file_open>
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	0f 88 8d 00 00 00    	js     801571 <serve_open+0x126>
	if (req->req_omode & O_TRUNC) {
  8014e4:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014eb:	74 17                	je     801504 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	6a 00                	push   $0x0
  8014f2:	ff b5 f4 fb ff ff    	push   -0x40c(%ebp)
  8014f8:	e8 43 f9 ff ff       	call   800e40 <file_set_size>
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 6d                	js     801571 <serve_open+0x126>
	if ((r = file_open(path, &f)) < 0) {
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	e8 69 f8 ff ff       	call   800d83 <file_open>
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 50                	js     801571 <serve_open+0x126>
	o->o_file = f;
  801521:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801527:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80152d:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  801530:	8b 50 0c             	mov    0xc(%eax),%edx
  801533:	8b 08                	mov    (%eax),%ecx
  801535:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801538:	8b 48 0c             	mov    0xc(%eax),%ecx
  80153b:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801541:	83 e2 03             	and    $0x3,%edx
  801544:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801547:	8b 50 0c             	mov    0xc(%eax),%edx
  80154a:	8b 0d 64 90 80 00    	mov    0x809064,%ecx
  801550:	89 0a                	mov    %ecx,(%edx)
	o->o_mode = req->req_omode;
  801552:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801558:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  80155b:	8b 50 0c             	mov    0xc(%eax),%edx
  80155e:	8b 45 10             	mov    0x10(%ebp),%eax
  801561:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80157e:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801581:	8d 75 f4             	lea    -0xc(%ebp),%esi
  801584:	eb 13                	jmp    801599 <serve+0x23>
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
			cprintf("Invalid request from %08x: no argument page\n",
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	ff 75 f4             	push   -0xc(%ebp)
  80158c:	68 60 3b 80 00       	push   $0x803b60
  801591:	e8 37 06 00 00       	call   801bcd <cprintf>
				whom);
			continue; // just leave it hanging...
  801596:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  801599:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	ff 35 44 50 80 00    	push   0x805044
  8015aa:	56                   	push   %esi
  8015ab:	e8 80 12 00 00       	call   802830 <ipc_recv>
		if (!(perm & PTE_P)) {
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8015b7:	74 cd                	je     801586 <serve+0x10>
		}

		pg = NULL;
  8015b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8015c0:	83 f8 01             	cmp    $0x1,%eax
  8015c3:	74 23                	je     8015e8 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015c5:	83 f8 08             	cmp    $0x8,%eax
  8015c8:	77 36                	ja     801600 <serve+0x8a>
  8015ca:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8015d1:	85 d2                	test   %edx,%edx
  8015d3:	74 2b                	je     801600 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	ff 35 44 50 80 00    	push   0x805044
  8015de:	ff 75 f4             	push   -0xc(%ebp)
  8015e1:	ff d2                	call   *%edx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 31                	jmp    801619 <serve+0xa3>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015e8:	53                   	push   %ebx
  8015e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	ff 35 44 50 80 00    	push   0x805044
  8015f3:	ff 75 f4             	push   -0xc(%ebp)
  8015f6:	e8 50 fe ff ff       	call   80144b <serve_open>
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb 19                	jmp    801619 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	ff 75 f4             	push   -0xc(%ebp)
  801606:	50                   	push   %eax
  801607:	68 90 3b 80 00       	push   $0x803b90
  80160c:	e8 bc 05 00 00       	call   801bcd <cprintf>
  801611:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801614:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801619:	ff 75 f0             	push   -0x10(%ebp)
  80161c:	ff 75 ec             	push   -0x14(%ebp)
  80161f:	50                   	push   %eax
  801620:	ff 75 f4             	push   -0xc(%ebp)
  801623:	e8 6f 12 00 00       	call   802897 <ipc_send>
		sys_page_unmap(0, fsreq);
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	ff 35 44 50 80 00    	push   0x805044
  801631:	6a 00                	push   $0x0
  801633:	e8 f0 0f 00 00       	call   802628 <sys_page_unmap>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	e9 59 ff ff ff       	jmp    801599 <serve+0x23>

00801640 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801646:	c7 05 60 90 80 00 b3 	movl   $0x803bb3,0x809060
  80164d:	3b 80 00 
	cprintf("FS is running\n");
  801650:	68 b6 3b 80 00       	push   $0x803bb6
  801655:	e8 73 05 00 00       	call   801bcd <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80165a:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80165f:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801664:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801666:	c7 04 24 c5 3b 80 00 	movl   $0x803bc5,(%esp)
  80166d:	e8 5b 05 00 00       	call   801bcd <cprintf>

	serve_init();
  801672:	e8 50 fb ff ff       	call   8011c7 <serve_init>
	fs_init();
  801677:	e8 f3 f3 ff ff       	call   800a6f <fs_init>
        fs_test();
  80167c:	e8 05 00 00 00       	call   801686 <fs_test>
	serve();
  801681:	e8 f0 fe ff ff       	call   801576 <serve>

00801686 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80168c:	6a 07                	push   $0x7
  80168e:	68 00 10 00 00       	push   $0x1000
  801693:	6a 00                	push   $0x0
  801695:	e8 09 0f 00 00       	call   8025a3 <sys_page_alloc>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	0f 88 59 02 00 00    	js     8018fe <fs_test+0x278>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	68 00 10 00 00       	push   $0x1000
  8016ad:	ff 35 00 a0 80 00    	push   0x80a000
  8016b3:	68 00 10 00 00       	push   $0x1000
  8016b8:	e8 80 0c 00 00       	call   80233d <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016bd:	e8 dd f1 ff ff       	call   80089f <alloc_block>
  8016c2:	89 c1                	mov    %eax,%ecx
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	0f 88 41 02 00 00    	js     801910 <fs_test+0x28a>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016cf:	8d 40 1f             	lea    0x1f(%eax),%eax
  8016d2:	0f 49 c1             	cmovns %ecx,%eax
  8016d5:	c1 f8 05             	sar    $0x5,%eax
  8016d8:	ba 01 00 00 00       	mov    $0x1,%edx
  8016dd:	d3 e2                	shl    %cl,%edx
  8016df:	89 d1                	mov    %edx,%ecx
  8016e1:	23 0c 85 00 10 00 00 	and    0x1000(,%eax,4),%ecx
  8016e8:	0f 84 34 02 00 00    	je     801922 <fs_test+0x29c>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016ee:	8b 0d 00 a0 80 00    	mov    0x80a000,%ecx
  8016f4:	23 14 81             	and    (%ecx,%eax,4),%edx
  8016f7:	0f 85 3b 02 00 00    	jne    801938 <fs_test+0x2b2>
	cprintf("alloc_block is good\n");
  8016fd:	83 ec 0c             	sub    $0xc,%esp
  801700:	68 1c 3c 80 00       	push   $0x803c1c
  801705:	e8 c3 04 00 00       	call   801bcd <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80170a:	83 c4 08             	add    $0x8,%esp
  80170d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	68 31 3c 80 00       	push   $0x803c31
  801716:	e8 68 f6 ff ff       	call   800d83 <file_open>
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801721:	74 08                	je     80172b <fs_test+0xa5>
  801723:	85 c0                	test   %eax,%eax
  801725:	0f 88 23 02 00 00    	js     80194e <fs_test+0x2c8>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  80172b:	85 c0                	test   %eax,%eax
  80172d:	0f 84 2d 02 00 00    	je     801960 <fs_test+0x2da>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801739:	50                   	push   %eax
  80173a:	68 55 3c 80 00       	push   $0x803c55
  80173f:	e8 3f f6 ff ff       	call   800d83 <file_open>
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	0f 88 25 02 00 00    	js     801974 <fs_test+0x2ee>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	68 75 3c 80 00       	push   $0x803c75
  801757:	e8 71 04 00 00       	call   801bcd <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80175c:	83 c4 0c             	add    $0xc,%esp
  80175f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801762:	50                   	push   %eax
  801763:	6a 00                	push   $0x0
  801765:	ff 75 f4             	push   -0xc(%ebp)
  801768:	e8 61 f3 ff ff       	call   800ace <file_get_block>
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	0f 88 0e 02 00 00    	js     801986 <fs_test+0x300>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  801778:	83 ec 08             	sub    $0x8,%esp
  80177b:	68 bc 3d 80 00       	push   $0x803dbc
  801780:	ff 75 f0             	push   -0x10(%ebp)
  801783:	e8 d0 0a 00 00       	call   802258 <strcmp>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	0f 85 05 02 00 00    	jne    801998 <fs_test+0x312>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	68 9b 3c 80 00       	push   $0x803c9b
  80179b:	e8 2d 04 00 00       	call   801bcd <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a3:	0f b6 10             	movzbl (%eax),%edx
  8017a6:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ab:	c1 e8 0c             	shr    $0xc,%eax
  8017ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	a8 40                	test   $0x40,%al
  8017ba:	0f 84 ec 01 00 00    	je     8019ac <fs_test+0x326>
	file_flush(f);
  8017c0:	83 ec 0c             	sub    $0xc,%esp
  8017c3:	ff 75 f4             	push   -0xc(%ebp)
  8017c6:	e8 f6 f7 ff ff       	call   800fc1 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ce:	c1 e8 0c             	shr    $0xc,%eax
  8017d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	a8 40                	test   $0x40,%al
  8017dd:	0f 85 df 01 00 00    	jne    8019c2 <fs_test+0x33c>
	cprintf("file_flush is good\n");
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	68 cf 3c 80 00       	push   $0x803ccf
  8017eb:	e8 dd 03 00 00       	call   801bcd <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8017f0:	83 c4 08             	add    $0x8,%esp
  8017f3:	6a 00                	push   $0x0
  8017f5:	ff 75 f4             	push   -0xc(%ebp)
  8017f8:	e8 43 f6 ff ff       	call   800e40 <file_set_size>
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	85 c0                	test   %eax,%eax
  801802:	0f 88 d0 01 00 00    	js     8019d8 <fs_test+0x352>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  801808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180b:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801812:	0f 85 d2 01 00 00    	jne    8019ea <fs_test+0x364>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801818:	c1 e8 0c             	shr    $0xc,%eax
  80181b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801822:	a8 40                	test   $0x40,%al
  801824:	0f 85 d6 01 00 00    	jne    801a00 <fs_test+0x37a>
	cprintf("file_truncate is good\n");
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	68 23 3d 80 00       	push   $0x803d23
  801832:	e8 96 03 00 00       	call   801bcd <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801837:	c7 04 24 bc 3d 80 00 	movl   $0x803dbc,(%esp)
  80183e:	e8 29 09 00 00       	call   80216c <strlen>
  801843:	83 c4 08             	add    $0x8,%esp
  801846:	50                   	push   %eax
  801847:	ff 75 f4             	push   -0xc(%ebp)
  80184a:	e8 f1 f5 ff ff       	call   800e40 <file_set_size>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	0f 88 bc 01 00 00    	js     801a16 <fs_test+0x390>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80185a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185d:	89 c2                	mov    %eax,%edx
  80185f:	c1 ea 0c             	shr    $0xc,%edx
  801862:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801869:	f6 c2 40             	test   $0x40,%dl
  80186c:	0f 85 b6 01 00 00    	jne    801a28 <fs_test+0x3a2>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801878:	52                   	push   %edx
  801879:	6a 00                	push   $0x0
  80187b:	50                   	push   %eax
  80187c:	e8 4d f2 ff ff       	call   800ace <file_get_block>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	0f 88 b2 01 00 00    	js     801a3e <fs_test+0x3b8>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	68 bc 3d 80 00       	push   $0x803dbc
  801894:	ff 75 f0             	push   -0x10(%ebp)
  801897:	e8 0b 09 00 00       	call   8021a7 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189f:	c1 e8 0c             	shr    $0xc,%eax
  8018a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	a8 40                	test   $0x40,%al
  8018ae:	0f 84 9c 01 00 00    	je     801a50 <fs_test+0x3ca>
	file_flush(f);
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	ff 75 f4             	push   -0xc(%ebp)
  8018ba:	e8 02 f7 ff ff       	call   800fc1 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c2:	c1 e8 0c             	shr    $0xc,%eax
  8018c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	a8 40                	test   $0x40,%al
  8018d1:	0f 85 8f 01 00 00    	jne    801a66 <fs_test+0x3e0>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018da:	c1 e8 0c             	shr    $0xc,%eax
  8018dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e4:	a8 40                	test   $0x40,%al
  8018e6:	0f 85 90 01 00 00    	jne    801a7c <fs_test+0x3f6>
	cprintf("file rewrite is good\n");
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	68 63 3d 80 00       	push   $0x803d63
  8018f4:	e8 d4 02 00 00       	call   801bcd <cprintf>
}
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8018fe:	50                   	push   %eax
  8018ff:	68 d4 3b 80 00       	push   $0x803bd4
  801904:	6a 12                	push   $0x12
  801906:	68 e7 3b 80 00       	push   $0x803be7
  80190b:	e8 e2 01 00 00       	call   801af2 <_panic>
		panic("alloc_block: %e", r);
  801910:	50                   	push   %eax
  801911:	68 f1 3b 80 00       	push   $0x803bf1
  801916:	6a 17                	push   $0x17
  801918:	68 e7 3b 80 00       	push   $0x803be7
  80191d:	e8 d0 01 00 00       	call   801af2 <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  801922:	68 01 3c 80 00       	push   $0x803c01
  801927:	68 9d 38 80 00       	push   $0x80389d
  80192c:	6a 19                	push   $0x19
  80192e:	68 e7 3b 80 00       	push   $0x803be7
  801933:	e8 ba 01 00 00       	call   801af2 <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801938:	68 7c 3d 80 00       	push   $0x803d7c
  80193d:	68 9d 38 80 00       	push   $0x80389d
  801942:	6a 1b                	push   $0x1b
  801944:	68 e7 3b 80 00       	push   $0x803be7
  801949:	e8 a4 01 00 00       	call   801af2 <_panic>
		panic("file_open /not-found: %e", r);
  80194e:	50                   	push   %eax
  80194f:	68 3c 3c 80 00       	push   $0x803c3c
  801954:	6a 1f                	push   $0x1f
  801956:	68 e7 3b 80 00       	push   $0x803be7
  80195b:	e8 92 01 00 00       	call   801af2 <_panic>
		panic("file_open /not-found succeeded!");
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	68 9c 3d 80 00       	push   $0x803d9c
  801968:	6a 21                	push   $0x21
  80196a:	68 e7 3b 80 00       	push   $0x803be7
  80196f:	e8 7e 01 00 00       	call   801af2 <_panic>
		panic("file_open /newmotd: %e", r);
  801974:	50                   	push   %eax
  801975:	68 5e 3c 80 00       	push   $0x803c5e
  80197a:	6a 23                	push   $0x23
  80197c:	68 e7 3b 80 00       	push   $0x803be7
  801981:	e8 6c 01 00 00       	call   801af2 <_panic>
		panic("file_get_block: %e", r);
  801986:	50                   	push   %eax
  801987:	68 88 3c 80 00       	push   $0x803c88
  80198c:	6a 27                	push   $0x27
  80198e:	68 e7 3b 80 00       	push   $0x803be7
  801993:	e8 5a 01 00 00       	call   801af2 <_panic>
		panic("file_get_block returned wrong data");
  801998:	83 ec 04             	sub    $0x4,%esp
  80199b:	68 e4 3d 80 00       	push   $0x803de4
  8019a0:	6a 29                	push   $0x29
  8019a2:	68 e7 3b 80 00       	push   $0x803be7
  8019a7:	e8 46 01 00 00       	call   801af2 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019ac:	68 b4 3c 80 00       	push   $0x803cb4
  8019b1:	68 9d 38 80 00       	push   $0x80389d
  8019b6:	6a 2d                	push   $0x2d
  8019b8:	68 e7 3b 80 00       	push   $0x803be7
  8019bd:	e8 30 01 00 00       	call   801af2 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019c2:	68 b3 3c 80 00       	push   $0x803cb3
  8019c7:	68 9d 38 80 00       	push   $0x80389d
  8019cc:	6a 2f                	push   $0x2f
  8019ce:	68 e7 3b 80 00       	push   $0x803be7
  8019d3:	e8 1a 01 00 00       	call   801af2 <_panic>
		panic("file_set_size: %e", r);
  8019d8:	50                   	push   %eax
  8019d9:	68 e3 3c 80 00       	push   $0x803ce3
  8019de:	6a 33                	push   $0x33
  8019e0:	68 e7 3b 80 00       	push   $0x803be7
  8019e5:	e8 08 01 00 00       	call   801af2 <_panic>
	assert(f->f_direct[0] == 0);
  8019ea:	68 f5 3c 80 00       	push   $0x803cf5
  8019ef:	68 9d 38 80 00       	push   $0x80389d
  8019f4:	6a 34                	push   $0x34
  8019f6:	68 e7 3b 80 00       	push   $0x803be7
  8019fb:	e8 f2 00 00 00       	call   801af2 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a00:	68 09 3d 80 00       	push   $0x803d09
  801a05:	68 9d 38 80 00       	push   $0x80389d
  801a0a:	6a 35                	push   $0x35
  801a0c:	68 e7 3b 80 00       	push   $0x803be7
  801a11:	e8 dc 00 00 00       	call   801af2 <_panic>
		panic("file_set_size 2: %e", r);
  801a16:	50                   	push   %eax
  801a17:	68 3a 3d 80 00       	push   $0x803d3a
  801a1c:	6a 39                	push   $0x39
  801a1e:	68 e7 3b 80 00       	push   $0x803be7
  801a23:	e8 ca 00 00 00       	call   801af2 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a28:	68 09 3d 80 00       	push   $0x803d09
  801a2d:	68 9d 38 80 00       	push   $0x80389d
  801a32:	6a 3a                	push   $0x3a
  801a34:	68 e7 3b 80 00       	push   $0x803be7
  801a39:	e8 b4 00 00 00       	call   801af2 <_panic>
		panic("file_get_block 2: %e", r);
  801a3e:	50                   	push   %eax
  801a3f:	68 4e 3d 80 00       	push   $0x803d4e
  801a44:	6a 3c                	push   $0x3c
  801a46:	68 e7 3b 80 00       	push   $0x803be7
  801a4b:	e8 a2 00 00 00       	call   801af2 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a50:	68 b4 3c 80 00       	push   $0x803cb4
  801a55:	68 9d 38 80 00       	push   $0x80389d
  801a5a:	6a 3e                	push   $0x3e
  801a5c:	68 e7 3b 80 00       	push   $0x803be7
  801a61:	e8 8c 00 00 00       	call   801af2 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a66:	68 b3 3c 80 00       	push   $0x803cb3
  801a6b:	68 9d 38 80 00       	push   $0x80389d
  801a70:	6a 40                	push   $0x40
  801a72:	68 e7 3b 80 00       	push   $0x803be7
  801a77:	e8 76 00 00 00       	call   801af2 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a7c:	68 09 3d 80 00       	push   $0x803d09
  801a81:	68 9d 38 80 00       	push   $0x80389d
  801a86:	6a 41                	push   $0x41
  801a88:	68 e7 3b 80 00       	push   $0x803be7
  801a8d:	e8 60 00 00 00       	call   801af2 <_panic>

00801a92 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  801a9d:	e8 c3 0a 00 00       	call   802565 <sys_getenvid>
  801aa2:	25 ff 03 00 00       	and    $0x3ff,%eax
  801aa7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aaa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aaf:	a3 08 a0 80 00       	mov    %eax,0x80a008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801ab4:	85 db                	test   %ebx,%ebx
  801ab6:	7e 07                	jle    801abf <libmain+0x2d>
		binaryname = argv[0];
  801ab8:	8b 06                	mov    (%esi),%eax
  801aba:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	e8 77 fb ff ff       	call   801640 <umain>

	// exit gracefully
	exit();
  801ac9:	e8 0a 00 00 00       	call   801ad8 <exit>
}
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801ade:	e8 0d 10 00 00       	call   802af0 <close_all>
	sys_env_destroy(0);
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 37 0a 00 00       	call   802524 <sys_env_destroy>
}
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801af7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801afa:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801b00:	e8 60 0a 00 00       	call   802565 <sys_getenvid>
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	ff 75 0c             	push   0xc(%ebp)
  801b0b:	ff 75 08             	push   0x8(%ebp)
  801b0e:	56                   	push   %esi
  801b0f:	50                   	push   %eax
  801b10:	68 14 3e 80 00       	push   $0x803e14
  801b15:	e8 b3 00 00 00       	call   801bcd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b1a:	83 c4 18             	add    $0x18,%esp
  801b1d:	53                   	push   %ebx
  801b1e:	ff 75 10             	push   0x10(%ebp)
  801b21:	e8 56 00 00 00       	call   801b7c <vcprintf>
	cprintf("\n");
  801b26:	c7 04 24 23 3a 80 00 	movl   $0x803a23,(%esp)
  801b2d:	e8 9b 00 00 00       	call   801bcd <cprintf>
  801b32:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b35:	cc                   	int3   
  801b36:	eb fd                	jmp    801b35 <_panic+0x43>

00801b38 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b42:	8b 13                	mov    (%ebx),%edx
  801b44:	8d 42 01             	lea    0x1(%edx),%eax
  801b47:	89 03                	mov    %eax,(%ebx)
  801b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b50:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b55:	74 09                	je     801b60 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801b57:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	68 ff 00 00 00       	push   $0xff
  801b68:	8d 43 08             	lea    0x8(%ebx),%eax
  801b6b:	50                   	push   %eax
  801b6c:	e8 76 09 00 00       	call   8024e7 <sys_cputs>
		b->idx = 0;
  801b71:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	eb db                	jmp    801b57 <putch+0x1f>

00801b7c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b85:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b8c:	00 00 00 
	b.cnt = 0;
  801b8f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b96:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b99:	ff 75 0c             	push   0xc(%ebp)
  801b9c:	ff 75 08             	push   0x8(%ebp)
  801b9f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	68 38 1b 80 00       	push   $0x801b38
  801bab:	e8 14 01 00 00       	call   801cc4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bb0:	83 c4 08             	add    $0x8,%esp
  801bb3:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801bb9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	e8 22 09 00 00       	call   8024e7 <sys_cputs>

	return b.cnt;
}
  801bc5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bd3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bd6:	50                   	push   %eax
  801bd7:	ff 75 08             	push   0x8(%ebp)
  801bda:	e8 9d ff ff ff       	call   801b7c <vcprintf>
	va_end(ap);

	return cnt;
}
  801bdf:	c9                   	leave  
  801be0:	c3                   	ret    

00801be1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	57                   	push   %edi
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
  801be7:	83 ec 1c             	sub    $0x1c,%esp
  801bea:	89 c7                	mov    %eax,%edi
  801bec:	89 d6                	mov    %edx,%esi
  801bee:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf4:	89 d1                	mov    %edx,%ecx
  801bf6:	89 c2                	mov    %eax,%edx
  801bf8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bfb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801bfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801c01:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801c0e:	39 c2                	cmp    %eax,%edx
  801c10:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801c13:	72 3e                	jb     801c53 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 18             	push   0x18(%ebp)
  801c1b:	83 eb 01             	sub    $0x1,%ebx
  801c1e:	53                   	push   %ebx
  801c1f:	50                   	push   %eax
  801c20:	83 ec 08             	sub    $0x8,%esp
  801c23:	ff 75 e4             	push   -0x1c(%ebp)
  801c26:	ff 75 e0             	push   -0x20(%ebp)
  801c29:	ff 75 dc             	push   -0x24(%ebp)
  801c2c:	ff 75 d8             	push   -0x28(%ebp)
  801c2f:	e8 dc 19 00 00       	call   803610 <__udivdi3>
  801c34:	83 c4 18             	add    $0x18,%esp
  801c37:	52                   	push   %edx
  801c38:	50                   	push   %eax
  801c39:	89 f2                	mov    %esi,%edx
  801c3b:	89 f8                	mov    %edi,%eax
  801c3d:	e8 9f ff ff ff       	call   801be1 <printnum>
  801c42:	83 c4 20             	add    $0x20,%esp
  801c45:	eb 13                	jmp    801c5a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c47:	83 ec 08             	sub    $0x8,%esp
  801c4a:	56                   	push   %esi
  801c4b:	ff 75 18             	push   0x18(%ebp)
  801c4e:	ff d7                	call   *%edi
  801c50:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801c53:	83 eb 01             	sub    $0x1,%ebx
  801c56:	85 db                	test   %ebx,%ebx
  801c58:	7f ed                	jg     801c47 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c5a:	83 ec 08             	sub    $0x8,%esp
  801c5d:	56                   	push   %esi
  801c5e:	83 ec 04             	sub    $0x4,%esp
  801c61:	ff 75 e4             	push   -0x1c(%ebp)
  801c64:	ff 75 e0             	push   -0x20(%ebp)
  801c67:	ff 75 dc             	push   -0x24(%ebp)
  801c6a:	ff 75 d8             	push   -0x28(%ebp)
  801c6d:	e8 be 1a 00 00       	call   803730 <__umoddi3>
  801c72:	83 c4 14             	add    $0x14,%esp
  801c75:	0f be 80 37 3e 80 00 	movsbl 0x803e37(%eax),%eax
  801c7c:	50                   	push   %eax
  801c7d:	ff d7                	call   *%edi
}
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5f                   	pop    %edi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c90:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c94:	8b 10                	mov    (%eax),%edx
  801c96:	3b 50 04             	cmp    0x4(%eax),%edx
  801c99:	73 0a                	jae    801ca5 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c9b:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c9e:	89 08                	mov    %ecx,(%eax)
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	88 02                	mov    %al,(%edx)
}
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <printfmt>:
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801cad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801cb0:	50                   	push   %eax
  801cb1:	ff 75 10             	push   0x10(%ebp)
  801cb4:	ff 75 0c             	push   0xc(%ebp)
  801cb7:	ff 75 08             	push   0x8(%ebp)
  801cba:	e8 05 00 00 00       	call   801cc4 <vprintfmt>
}
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <vprintfmt>:
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	57                   	push   %edi
  801cc8:	56                   	push   %esi
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 3c             	sub    $0x3c,%esp
  801ccd:	8b 75 08             	mov    0x8(%ebp),%esi
  801cd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cd3:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cd6:	eb 0a                	jmp    801ce2 <vprintfmt+0x1e>
			putch(ch, putdat);
  801cd8:	83 ec 08             	sub    $0x8,%esp
  801cdb:	53                   	push   %ebx
  801cdc:	50                   	push   %eax
  801cdd:	ff d6                	call   *%esi
  801cdf:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ce2:	83 c7 01             	add    $0x1,%edi
  801ce5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ce9:	83 f8 25             	cmp    $0x25,%eax
  801cec:	74 0c                	je     801cfa <vprintfmt+0x36>
			if (ch == '\0')
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	75 e6                	jne    801cd8 <vprintfmt+0x14>
}
  801cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5f                   	pop    %edi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
		padc = ' ';
  801cfa:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801cfe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801d05:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801d0c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801d13:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801d18:	8d 47 01             	lea    0x1(%edi),%eax
  801d1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d1e:	0f b6 17             	movzbl (%edi),%edx
  801d21:	8d 42 dd             	lea    -0x23(%edx),%eax
  801d24:	3c 55                	cmp    $0x55,%al
  801d26:	0f 87 bb 03 00 00    	ja     8020e7 <vprintfmt+0x423>
  801d2c:	0f b6 c0             	movzbl %al,%eax
  801d2f:	ff 24 85 80 3f 80 00 	jmp    *0x803f80(,%eax,4)
  801d36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801d39:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801d3d:	eb d9                	jmp    801d18 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d42:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801d46:	eb d0                	jmp    801d18 <vprintfmt+0x54>
  801d48:	0f b6 d2             	movzbl %dl,%edx
  801d4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d53:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801d56:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d59:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d5d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d60:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801d63:	83 f9 09             	cmp    $0x9,%ecx
  801d66:	77 55                	ja     801dbd <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801d68:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801d6b:	eb e9                	jmp    801d56 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801d6d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d70:	8b 00                	mov    (%eax),%eax
  801d72:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d75:	8b 45 14             	mov    0x14(%ebp),%eax
  801d78:	8d 40 04             	lea    0x4(%eax),%eax
  801d7b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801d7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d85:	79 91                	jns    801d18 <vprintfmt+0x54>
				width = precision, precision = -1;
  801d87:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d8d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801d94:	eb 82                	jmp    801d18 <vprintfmt+0x54>
  801d96:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d99:	85 d2                	test   %edx,%edx
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801da0:	0f 49 c2             	cmovns %edx,%eax
  801da3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801da6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801da9:	e9 6a ff ff ff       	jmp    801d18 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801dae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801db1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801db8:	e9 5b ff ff ff       	jmp    801d18 <vprintfmt+0x54>
  801dbd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801dc0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dc3:	eb bc                	jmp    801d81 <vprintfmt+0xbd>
			lflag++;
  801dc5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801dc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801dcb:	e9 48 ff ff ff       	jmp    801d18 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801dd0:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd3:	8d 78 04             	lea    0x4(%eax),%edi
  801dd6:	83 ec 08             	sub    $0x8,%esp
  801dd9:	53                   	push   %ebx
  801dda:	ff 30                	push   (%eax)
  801ddc:	ff d6                	call   *%esi
			break;
  801dde:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801de1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801de4:	e9 9d 02 00 00       	jmp    802086 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  801de9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dec:	8d 78 04             	lea    0x4(%eax),%edi
  801def:	8b 10                	mov    (%eax),%edx
  801df1:	89 d0                	mov    %edx,%eax
  801df3:	f7 d8                	neg    %eax
  801df5:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801df8:	83 f8 0f             	cmp    $0xf,%eax
  801dfb:	7f 23                	jg     801e20 <vprintfmt+0x15c>
  801dfd:	8b 14 85 e0 40 80 00 	mov    0x8040e0(,%eax,4),%edx
  801e04:	85 d2                	test   %edx,%edx
  801e06:	74 18                	je     801e20 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801e08:	52                   	push   %edx
  801e09:	68 af 38 80 00       	push   $0x8038af
  801e0e:	53                   	push   %ebx
  801e0f:	56                   	push   %esi
  801e10:	e8 92 fe ff ff       	call   801ca7 <printfmt>
  801e15:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e18:	89 7d 14             	mov    %edi,0x14(%ebp)
  801e1b:	e9 66 02 00 00       	jmp    802086 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801e20:	50                   	push   %eax
  801e21:	68 4f 3e 80 00       	push   $0x803e4f
  801e26:	53                   	push   %ebx
  801e27:	56                   	push   %esi
  801e28:	e8 7a fe ff ff       	call   801ca7 <printfmt>
  801e2d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e30:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801e33:	e9 4e 02 00 00       	jmp    802086 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801e38:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3b:	83 c0 04             	add    $0x4,%eax
  801e3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801e41:	8b 45 14             	mov    0x14(%ebp),%eax
  801e44:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801e46:	85 d2                	test   %edx,%edx
  801e48:	b8 48 3e 80 00       	mov    $0x803e48,%eax
  801e4d:	0f 45 c2             	cmovne %edx,%eax
  801e50:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801e53:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e57:	7e 06                	jle    801e5f <vprintfmt+0x19b>
  801e59:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801e5d:	75 0d                	jne    801e6c <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e62:	89 c7                	mov    %eax,%edi
  801e64:	03 45 e0             	add    -0x20(%ebp),%eax
  801e67:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e6a:	eb 55                	jmp    801ec1 <vprintfmt+0x1fd>
  801e6c:	83 ec 08             	sub    $0x8,%esp
  801e6f:	ff 75 d8             	push   -0x28(%ebp)
  801e72:	ff 75 cc             	push   -0x34(%ebp)
  801e75:	e8 0a 03 00 00       	call   802184 <strnlen>
  801e7a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e7d:	29 c1                	sub    %eax,%ecx
  801e7f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801e87:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801e8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801e8e:	eb 0f                	jmp    801e9f <vprintfmt+0x1db>
					putch(padc, putdat);
  801e90:	83 ec 08             	sub    $0x8,%esp
  801e93:	53                   	push   %ebx
  801e94:	ff 75 e0             	push   -0x20(%ebp)
  801e97:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801e99:	83 ef 01             	sub    $0x1,%edi
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	85 ff                	test   %edi,%edi
  801ea1:	7f ed                	jg     801e90 <vprintfmt+0x1cc>
  801ea3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801ea6:	85 d2                	test   %edx,%edx
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ead:	0f 49 c2             	cmovns %edx,%eax
  801eb0:	29 c2                	sub    %eax,%edx
  801eb2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801eb5:	eb a8                	jmp    801e5f <vprintfmt+0x19b>
					putch(ch, putdat);
  801eb7:	83 ec 08             	sub    $0x8,%esp
  801eba:	53                   	push   %ebx
  801ebb:	52                   	push   %edx
  801ebc:	ff d6                	call   *%esi
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ec4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ec6:	83 c7 01             	add    $0x1,%edi
  801ec9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ecd:	0f be d0             	movsbl %al,%edx
  801ed0:	85 d2                	test   %edx,%edx
  801ed2:	74 4b                	je     801f1f <vprintfmt+0x25b>
  801ed4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ed8:	78 06                	js     801ee0 <vprintfmt+0x21c>
  801eda:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801ede:	78 1e                	js     801efe <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801ee0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801ee4:	74 d1                	je     801eb7 <vprintfmt+0x1f3>
  801ee6:	0f be c0             	movsbl %al,%eax
  801ee9:	83 e8 20             	sub    $0x20,%eax
  801eec:	83 f8 5e             	cmp    $0x5e,%eax
  801eef:	76 c6                	jbe    801eb7 <vprintfmt+0x1f3>
					putch('?', putdat);
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	53                   	push   %ebx
  801ef5:	6a 3f                	push   $0x3f
  801ef7:	ff d6                	call   *%esi
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	eb c3                	jmp    801ec1 <vprintfmt+0x1fd>
  801efe:	89 cf                	mov    %ecx,%edi
  801f00:	eb 0e                	jmp    801f10 <vprintfmt+0x24c>
				putch(' ', putdat);
  801f02:	83 ec 08             	sub    $0x8,%esp
  801f05:	53                   	push   %ebx
  801f06:	6a 20                	push   $0x20
  801f08:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801f0a:	83 ef 01             	sub    $0x1,%edi
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 ff                	test   %edi,%edi
  801f12:	7f ee                	jg     801f02 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801f14:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801f17:	89 45 14             	mov    %eax,0x14(%ebp)
  801f1a:	e9 67 01 00 00       	jmp    802086 <vprintfmt+0x3c2>
  801f1f:	89 cf                	mov    %ecx,%edi
  801f21:	eb ed                	jmp    801f10 <vprintfmt+0x24c>
	if (lflag >= 2)
  801f23:	83 f9 01             	cmp    $0x1,%ecx
  801f26:	7f 1b                	jg     801f43 <vprintfmt+0x27f>
	else if (lflag)
  801f28:	85 c9                	test   %ecx,%ecx
  801f2a:	74 63                	je     801f8f <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801f2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2f:	8b 00                	mov    (%eax),%eax
  801f31:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f34:	99                   	cltd   
  801f35:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f38:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3b:	8d 40 04             	lea    0x4(%eax),%eax
  801f3e:	89 45 14             	mov    %eax,0x14(%ebp)
  801f41:	eb 17                	jmp    801f5a <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801f43:	8b 45 14             	mov    0x14(%ebp),%eax
  801f46:	8b 50 04             	mov    0x4(%eax),%edx
  801f49:	8b 00                	mov    (%eax),%eax
  801f4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f4e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f51:	8b 45 14             	mov    0x14(%ebp),%eax
  801f54:	8d 40 08             	lea    0x8(%eax),%eax
  801f57:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801f5a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f5d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801f60:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801f65:	85 c9                	test   %ecx,%ecx
  801f67:	0f 89 ff 00 00 00    	jns    80206c <vprintfmt+0x3a8>
				putch('-', putdat);
  801f6d:	83 ec 08             	sub    $0x8,%esp
  801f70:	53                   	push   %ebx
  801f71:	6a 2d                	push   $0x2d
  801f73:	ff d6                	call   *%esi
				num = -(long long) num;
  801f75:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f78:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f7b:	f7 da                	neg    %edx
  801f7d:	83 d1 00             	adc    $0x0,%ecx
  801f80:	f7 d9                	neg    %ecx
  801f82:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801f85:	bf 0a 00 00 00       	mov    $0xa,%edi
  801f8a:	e9 dd 00 00 00       	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801f8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f92:	8b 00                	mov    (%eax),%eax
  801f94:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f97:	99                   	cltd   
  801f98:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f9e:	8d 40 04             	lea    0x4(%eax),%eax
  801fa1:	89 45 14             	mov    %eax,0x14(%ebp)
  801fa4:	eb b4                	jmp    801f5a <vprintfmt+0x296>
	if (lflag >= 2)
  801fa6:	83 f9 01             	cmp    $0x1,%ecx
  801fa9:	7f 1e                	jg     801fc9 <vprintfmt+0x305>
	else if (lflag)
  801fab:	85 c9                	test   %ecx,%ecx
  801fad:	74 32                	je     801fe1 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801faf:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb2:	8b 10                	mov    (%eax),%edx
  801fb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fb9:	8d 40 04             	lea    0x4(%eax),%eax
  801fbc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fbf:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801fc4:	e9 a3 00 00 00       	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801fc9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fcc:	8b 10                	mov    (%eax),%edx
  801fce:	8b 48 04             	mov    0x4(%eax),%ecx
  801fd1:	8d 40 08             	lea    0x8(%eax),%eax
  801fd4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fd7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  801fdc:	e9 8b 00 00 00       	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801fe1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe4:	8b 10                	mov    (%eax),%edx
  801fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801feb:	8d 40 04             	lea    0x4(%eax),%eax
  801fee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801ff1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801ff6:	eb 74                	jmp    80206c <vprintfmt+0x3a8>
	if (lflag >= 2)
  801ff8:	83 f9 01             	cmp    $0x1,%ecx
  801ffb:	7f 1b                	jg     802018 <vprintfmt+0x354>
	else if (lflag)
  801ffd:	85 c9                	test   %ecx,%ecx
  801fff:	74 2c                	je     80202d <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  802001:	8b 45 14             	mov    0x14(%ebp),%eax
  802004:	8b 10                	mov    (%eax),%edx
  802006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80200b:	8d 40 04             	lea    0x4(%eax),%eax
  80200e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  802011:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  802016:	eb 54                	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  802018:	8b 45 14             	mov    0x14(%ebp),%eax
  80201b:	8b 10                	mov    (%eax),%edx
  80201d:	8b 48 04             	mov    0x4(%eax),%ecx
  802020:	8d 40 08             	lea    0x8(%eax),%eax
  802023:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  802026:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80202b:	eb 3f                	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80202d:	8b 45 14             	mov    0x14(%ebp),%eax
  802030:	8b 10                	mov    (%eax),%edx
  802032:	b9 00 00 00 00       	mov    $0x0,%ecx
  802037:	8d 40 04             	lea    0x4(%eax),%eax
  80203a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80203d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  802042:	eb 28                	jmp    80206c <vprintfmt+0x3a8>
			putch('0', putdat);
  802044:	83 ec 08             	sub    $0x8,%esp
  802047:	53                   	push   %ebx
  802048:	6a 30                	push   $0x30
  80204a:	ff d6                	call   *%esi
			putch('x', putdat);
  80204c:	83 c4 08             	add    $0x8,%esp
  80204f:	53                   	push   %ebx
  802050:	6a 78                	push   $0x78
  802052:	ff d6                	call   *%esi
			num = (unsigned long long)
  802054:	8b 45 14             	mov    0x14(%ebp),%eax
  802057:	8b 10                	mov    (%eax),%edx
  802059:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80205e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  802061:	8d 40 04             	lea    0x4(%eax),%eax
  802064:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802067:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80206c:	83 ec 0c             	sub    $0xc,%esp
  80206f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  802073:	50                   	push   %eax
  802074:	ff 75 e0             	push   -0x20(%ebp)
  802077:	57                   	push   %edi
  802078:	51                   	push   %ecx
  802079:	52                   	push   %edx
  80207a:	89 da                	mov    %ebx,%edx
  80207c:	89 f0                	mov    %esi,%eax
  80207e:	e8 5e fb ff ff       	call   801be1 <printnum>
			break;
  802083:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  802086:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802089:	e9 54 fc ff ff       	jmp    801ce2 <vprintfmt+0x1e>
	if (lflag >= 2)
  80208e:	83 f9 01             	cmp    $0x1,%ecx
  802091:	7f 1b                	jg     8020ae <vprintfmt+0x3ea>
	else if (lflag)
  802093:	85 c9                	test   %ecx,%ecx
  802095:	74 2c                	je     8020c3 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  802097:	8b 45 14             	mov    0x14(%ebp),%eax
  80209a:	8b 10                	mov    (%eax),%edx
  80209c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020a1:	8d 40 04             	lea    0x4(%eax),%eax
  8020a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020a7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8020ac:	eb be                	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8020ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b1:	8b 10                	mov    (%eax),%edx
  8020b3:	8b 48 04             	mov    0x4(%eax),%ecx
  8020b6:	8d 40 08             	lea    0x8(%eax),%eax
  8020b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020bc:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8020c1:	eb a9                	jmp    80206c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8020c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c6:	8b 10                	mov    (%eax),%edx
  8020c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020cd:	8d 40 04             	lea    0x4(%eax),%eax
  8020d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020d3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8020d8:	eb 92                	jmp    80206c <vprintfmt+0x3a8>
			putch(ch, putdat);
  8020da:	83 ec 08             	sub    $0x8,%esp
  8020dd:	53                   	push   %ebx
  8020de:	6a 25                	push   $0x25
  8020e0:	ff d6                	call   *%esi
			break;
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	eb 9f                	jmp    802086 <vprintfmt+0x3c2>
			putch('%', putdat);
  8020e7:	83 ec 08             	sub    $0x8,%esp
  8020ea:	53                   	push   %ebx
  8020eb:	6a 25                	push   $0x25
  8020ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	89 f8                	mov    %edi,%eax
  8020f4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8020f8:	74 05                	je     8020ff <vprintfmt+0x43b>
  8020fa:	83 e8 01             	sub    $0x1,%eax
  8020fd:	eb f5                	jmp    8020f4 <vprintfmt+0x430>
  8020ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802102:	eb 82                	jmp    802086 <vprintfmt+0x3c2>

00802104 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	83 ec 18             	sub    $0x18,%esp
  80210a:	8b 45 08             	mov    0x8(%ebp),%eax
  80210d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802110:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802113:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802117:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80211a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802121:	85 c0                	test   %eax,%eax
  802123:	74 26                	je     80214b <vsnprintf+0x47>
  802125:	85 d2                	test   %edx,%edx
  802127:	7e 22                	jle    80214b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802129:	ff 75 14             	push   0x14(%ebp)
  80212c:	ff 75 10             	push   0x10(%ebp)
  80212f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802132:	50                   	push   %eax
  802133:	68 8a 1c 80 00       	push   $0x801c8a
  802138:	e8 87 fb ff ff       	call   801cc4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80213d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802140:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802146:	83 c4 10             	add    $0x10,%esp
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    
		return -E_INVAL;
  80214b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802150:	eb f7                	jmp    802149 <vsnprintf+0x45>

00802152 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
  802155:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802158:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80215b:	50                   	push   %eax
  80215c:	ff 75 10             	push   0x10(%ebp)
  80215f:	ff 75 0c             	push   0xc(%ebp)
  802162:	ff 75 08             	push   0x8(%ebp)
  802165:	e8 9a ff ff ff       	call   802104 <vsnprintf>
	va_end(ap);

	return rc;
}
  80216a:	c9                   	leave  
  80216b:	c3                   	ret    

0080216c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802172:	b8 00 00 00 00       	mov    $0x0,%eax
  802177:	eb 03                	jmp    80217c <strlen+0x10>
		n++;
  802179:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80217c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802180:	75 f7                	jne    802179 <strlen+0xd>
	return n;
}
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80218d:	b8 00 00 00 00       	mov    $0x0,%eax
  802192:	eb 03                	jmp    802197 <strnlen+0x13>
		n++;
  802194:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802197:	39 d0                	cmp    %edx,%eax
  802199:	74 08                	je     8021a3 <strnlen+0x1f>
  80219b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80219f:	75 f3                	jne    802194 <strnlen+0x10>
  8021a1:	89 c2                	mov    %eax,%edx
	return n;
}
  8021a3:	89 d0                	mov    %edx,%eax
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	53                   	push   %ebx
  8021ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8021b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8021ba:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8021bd:	83 c0 01             	add    $0x1,%eax
  8021c0:	84 d2                	test   %dl,%dl
  8021c2:	75 f2                	jne    8021b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8021c4:	89 c8                	mov    %ecx,%eax
  8021c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	53                   	push   %ebx
  8021cf:	83 ec 10             	sub    $0x10,%esp
  8021d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021d5:	53                   	push   %ebx
  8021d6:	e8 91 ff ff ff       	call   80216c <strlen>
  8021db:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8021de:	ff 75 0c             	push   0xc(%ebp)
  8021e1:	01 d8                	add    %ebx,%eax
  8021e3:	50                   	push   %eax
  8021e4:	e8 be ff ff ff       	call   8021a7 <strcpy>
	return dst;
}
  8021e9:	89 d8                	mov    %ebx,%eax
  8021eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	56                   	push   %esi
  8021f4:	53                   	push   %ebx
  8021f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021fb:	89 f3                	mov    %esi,%ebx
  8021fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802200:	89 f0                	mov    %esi,%eax
  802202:	eb 0f                	jmp    802213 <strncpy+0x23>
		*dst++ = *src;
  802204:	83 c0 01             	add    $0x1,%eax
  802207:	0f b6 0a             	movzbl (%edx),%ecx
  80220a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80220d:	80 f9 01             	cmp    $0x1,%cl
  802210:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  802213:	39 d8                	cmp    %ebx,%eax
  802215:	75 ed                	jne    802204 <strncpy+0x14>
	}
	return ret;
}
  802217:	89 f0                	mov    %esi,%eax
  802219:	5b                   	pop    %ebx
  80221a:	5e                   	pop    %esi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    

0080221d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80221d:	55                   	push   %ebp
  80221e:	89 e5                	mov    %esp,%ebp
  802220:	56                   	push   %esi
  802221:	53                   	push   %ebx
  802222:	8b 75 08             	mov    0x8(%ebp),%esi
  802225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802228:	8b 55 10             	mov    0x10(%ebp),%edx
  80222b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80222d:	85 d2                	test   %edx,%edx
  80222f:	74 21                	je     802252 <strlcpy+0x35>
  802231:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802235:	89 f2                	mov    %esi,%edx
  802237:	eb 09                	jmp    802242 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802239:	83 c1 01             	add    $0x1,%ecx
  80223c:	83 c2 01             	add    $0x1,%edx
  80223f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  802242:	39 c2                	cmp    %eax,%edx
  802244:	74 09                	je     80224f <strlcpy+0x32>
  802246:	0f b6 19             	movzbl (%ecx),%ebx
  802249:	84 db                	test   %bl,%bl
  80224b:	75 ec                	jne    802239 <strlcpy+0x1c>
  80224d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80224f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802252:	29 f0                	sub    %esi,%eax
}
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    

00802258 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802261:	eb 06                	jmp    802269 <strcmp+0x11>
		p++, q++;
  802263:	83 c1 01             	add    $0x1,%ecx
  802266:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  802269:	0f b6 01             	movzbl (%ecx),%eax
  80226c:	84 c0                	test   %al,%al
  80226e:	74 04                	je     802274 <strcmp+0x1c>
  802270:	3a 02                	cmp    (%edx),%al
  802272:	74 ef                	je     802263 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802274:	0f b6 c0             	movzbl %al,%eax
  802277:	0f b6 12             	movzbl (%edx),%edx
  80227a:	29 d0                	sub    %edx,%eax
}
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    

0080227e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	53                   	push   %ebx
  802282:	8b 45 08             	mov    0x8(%ebp),%eax
  802285:	8b 55 0c             	mov    0xc(%ebp),%edx
  802288:	89 c3                	mov    %eax,%ebx
  80228a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80228d:	eb 06                	jmp    802295 <strncmp+0x17>
		n--, p++, q++;
  80228f:	83 c0 01             	add    $0x1,%eax
  802292:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  802295:	39 d8                	cmp    %ebx,%eax
  802297:	74 18                	je     8022b1 <strncmp+0x33>
  802299:	0f b6 08             	movzbl (%eax),%ecx
  80229c:	84 c9                	test   %cl,%cl
  80229e:	74 04                	je     8022a4 <strncmp+0x26>
  8022a0:	3a 0a                	cmp    (%edx),%cl
  8022a2:	74 eb                	je     80228f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8022a4:	0f b6 00             	movzbl (%eax),%eax
  8022a7:	0f b6 12             	movzbl (%edx),%edx
  8022aa:	29 d0                	sub    %edx,%eax
}
  8022ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022af:	c9                   	leave  
  8022b0:	c3                   	ret    
		return 0;
  8022b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b6:	eb f4                	jmp    8022ac <strncmp+0x2e>

008022b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022c2:	eb 03                	jmp    8022c7 <strchr+0xf>
  8022c4:	83 c0 01             	add    $0x1,%eax
  8022c7:	0f b6 10             	movzbl (%eax),%edx
  8022ca:	84 d2                	test   %dl,%dl
  8022cc:	74 06                	je     8022d4 <strchr+0x1c>
		if (*s == c)
  8022ce:	38 ca                	cmp    %cl,%dl
  8022d0:	75 f2                	jne    8022c4 <strchr+0xc>
  8022d2:	eb 05                	jmp    8022d9 <strchr+0x21>
			return (char *) s;
	return 0;
  8022d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    

008022db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022e5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022e8:	38 ca                	cmp    %cl,%dl
  8022ea:	74 09                	je     8022f5 <strfind+0x1a>
  8022ec:	84 d2                	test   %dl,%dl
  8022ee:	74 05                	je     8022f5 <strfind+0x1a>
	for (; *s; s++)
  8022f0:	83 c0 01             	add    $0x1,%eax
  8022f3:	eb f0                	jmp    8022e5 <strfind+0xa>
			break;
	return (char *) s;
}
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    

008022f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	57                   	push   %edi
  8022fb:	56                   	push   %esi
  8022fc:	53                   	push   %ebx
  8022fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  802300:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802303:	85 c9                	test   %ecx,%ecx
  802305:	74 2f                	je     802336 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802307:	89 f8                	mov    %edi,%eax
  802309:	09 c8                	or     %ecx,%eax
  80230b:	a8 03                	test   $0x3,%al
  80230d:	75 21                	jne    802330 <memset+0x39>
		c &= 0xFF;
  80230f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802313:	89 d0                	mov    %edx,%eax
  802315:	c1 e0 08             	shl    $0x8,%eax
  802318:	89 d3                	mov    %edx,%ebx
  80231a:	c1 e3 18             	shl    $0x18,%ebx
  80231d:	89 d6                	mov    %edx,%esi
  80231f:	c1 e6 10             	shl    $0x10,%esi
  802322:	09 f3                	or     %esi,%ebx
  802324:	09 da                	or     %ebx,%edx
  802326:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802328:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80232b:	fc                   	cld    
  80232c:	f3 ab                	rep stos %eax,%es:(%edi)
  80232e:	eb 06                	jmp    802336 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802330:	8b 45 0c             	mov    0xc(%ebp),%eax
  802333:	fc                   	cld    
  802334:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802336:	89 f8                	mov    %edi,%eax
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	57                   	push   %edi
  802341:	56                   	push   %esi
  802342:	8b 45 08             	mov    0x8(%ebp),%eax
  802345:	8b 75 0c             	mov    0xc(%ebp),%esi
  802348:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80234b:	39 c6                	cmp    %eax,%esi
  80234d:	73 32                	jae    802381 <memmove+0x44>
  80234f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802352:	39 c2                	cmp    %eax,%edx
  802354:	76 2b                	jbe    802381 <memmove+0x44>
		s += n;
		d += n;
  802356:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802359:	89 d6                	mov    %edx,%esi
  80235b:	09 fe                	or     %edi,%esi
  80235d:	09 ce                	or     %ecx,%esi
  80235f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802365:	75 0e                	jne    802375 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802367:	83 ef 04             	sub    $0x4,%edi
  80236a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80236d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  802370:	fd                   	std    
  802371:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802373:	eb 09                	jmp    80237e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802375:	83 ef 01             	sub    $0x1,%edi
  802378:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80237b:	fd                   	std    
  80237c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80237e:	fc                   	cld    
  80237f:	eb 1a                	jmp    80239b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802381:	89 f2                	mov    %esi,%edx
  802383:	09 c2                	or     %eax,%edx
  802385:	09 ca                	or     %ecx,%edx
  802387:	f6 c2 03             	test   $0x3,%dl
  80238a:	75 0a                	jne    802396 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80238c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80238f:	89 c7                	mov    %eax,%edi
  802391:	fc                   	cld    
  802392:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802394:	eb 05                	jmp    80239b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  802396:	89 c7                	mov    %eax,%edi
  802398:	fc                   	cld    
  802399:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    

0080239f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8023a5:	ff 75 10             	push   0x10(%ebp)
  8023a8:	ff 75 0c             	push   0xc(%ebp)
  8023ab:	ff 75 08             	push   0x8(%ebp)
  8023ae:	e8 8a ff ff ff       	call   80233d <memmove>
}
  8023b3:	c9                   	leave  
  8023b4:	c3                   	ret    

008023b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8023b5:	55                   	push   %ebp
  8023b6:	89 e5                	mov    %esp,%ebp
  8023b8:	56                   	push   %esi
  8023b9:	53                   	push   %ebx
  8023ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023c0:	89 c6                	mov    %eax,%esi
  8023c2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023c5:	eb 06                	jmp    8023cd <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8023c7:	83 c0 01             	add    $0x1,%eax
  8023ca:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8023cd:	39 f0                	cmp    %esi,%eax
  8023cf:	74 14                	je     8023e5 <memcmp+0x30>
		if (*s1 != *s2)
  8023d1:	0f b6 08             	movzbl (%eax),%ecx
  8023d4:	0f b6 1a             	movzbl (%edx),%ebx
  8023d7:	38 d9                	cmp    %bl,%cl
  8023d9:	74 ec                	je     8023c7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8023db:	0f b6 c1             	movzbl %cl,%eax
  8023de:	0f b6 db             	movzbl %bl,%ebx
  8023e1:	29 d8                	sub    %ebx,%eax
  8023e3:	eb 05                	jmp    8023ea <memcmp+0x35>
	}

	return 0;
  8023e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023ea:	5b                   	pop    %ebx
  8023eb:	5e                   	pop    %esi
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    

008023ee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8023f7:	89 c2                	mov    %eax,%edx
  8023f9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8023fc:	eb 03                	jmp    802401 <memfind+0x13>
  8023fe:	83 c0 01             	add    $0x1,%eax
  802401:	39 d0                	cmp    %edx,%eax
  802403:	73 04                	jae    802409 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  802405:	38 08                	cmp    %cl,(%eax)
  802407:	75 f5                	jne    8023fe <memfind+0x10>
			break;
	return (void *) s;
}
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	57                   	push   %edi
  80240f:	56                   	push   %esi
  802410:	53                   	push   %ebx
  802411:	8b 55 08             	mov    0x8(%ebp),%edx
  802414:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802417:	eb 03                	jmp    80241c <strtol+0x11>
		s++;
  802419:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80241c:	0f b6 02             	movzbl (%edx),%eax
  80241f:	3c 20                	cmp    $0x20,%al
  802421:	74 f6                	je     802419 <strtol+0xe>
  802423:	3c 09                	cmp    $0x9,%al
  802425:	74 f2                	je     802419 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  802427:	3c 2b                	cmp    $0x2b,%al
  802429:	74 2a                	je     802455 <strtol+0x4a>
	int neg = 0;
  80242b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  802430:	3c 2d                	cmp    $0x2d,%al
  802432:	74 2b                	je     80245f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802434:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80243a:	75 0f                	jne    80244b <strtol+0x40>
  80243c:	80 3a 30             	cmpb   $0x30,(%edx)
  80243f:	74 28                	je     802469 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802441:	85 db                	test   %ebx,%ebx
  802443:	b8 0a 00 00 00       	mov    $0xa,%eax
  802448:	0f 44 d8             	cmove  %eax,%ebx
  80244b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802450:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802453:	eb 46                	jmp    80249b <strtol+0x90>
		s++;
  802455:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  802458:	bf 00 00 00 00       	mov    $0x0,%edi
  80245d:	eb d5                	jmp    802434 <strtol+0x29>
		s++, neg = 1;
  80245f:	83 c2 01             	add    $0x1,%edx
  802462:	bf 01 00 00 00       	mov    $0x1,%edi
  802467:	eb cb                	jmp    802434 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802469:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80246d:	74 0e                	je     80247d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80246f:	85 db                	test   %ebx,%ebx
  802471:	75 d8                	jne    80244b <strtol+0x40>
		s++, base = 8;
  802473:	83 c2 01             	add    $0x1,%edx
  802476:	bb 08 00 00 00       	mov    $0x8,%ebx
  80247b:	eb ce                	jmp    80244b <strtol+0x40>
		s += 2, base = 16;
  80247d:	83 c2 02             	add    $0x2,%edx
  802480:	bb 10 00 00 00       	mov    $0x10,%ebx
  802485:	eb c4                	jmp    80244b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  802487:	0f be c0             	movsbl %al,%eax
  80248a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80248d:	3b 45 10             	cmp    0x10(%ebp),%eax
  802490:	7d 3a                	jge    8024cc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  802492:	83 c2 01             	add    $0x1,%edx
  802495:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  802499:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  80249b:	0f b6 02             	movzbl (%edx),%eax
  80249e:	8d 70 d0             	lea    -0x30(%eax),%esi
  8024a1:	89 f3                	mov    %esi,%ebx
  8024a3:	80 fb 09             	cmp    $0x9,%bl
  8024a6:	76 df                	jbe    802487 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8024a8:	8d 70 9f             	lea    -0x61(%eax),%esi
  8024ab:	89 f3                	mov    %esi,%ebx
  8024ad:	80 fb 19             	cmp    $0x19,%bl
  8024b0:	77 08                	ja     8024ba <strtol+0xaf>
			dig = *s - 'a' + 10;
  8024b2:	0f be c0             	movsbl %al,%eax
  8024b5:	83 e8 57             	sub    $0x57,%eax
  8024b8:	eb d3                	jmp    80248d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8024ba:	8d 70 bf             	lea    -0x41(%eax),%esi
  8024bd:	89 f3                	mov    %esi,%ebx
  8024bf:	80 fb 19             	cmp    $0x19,%bl
  8024c2:	77 08                	ja     8024cc <strtol+0xc1>
			dig = *s - 'A' + 10;
  8024c4:	0f be c0             	movsbl %al,%eax
  8024c7:	83 e8 37             	sub    $0x37,%eax
  8024ca:	eb c1                	jmp    80248d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8024cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024d0:	74 05                	je     8024d7 <strtol+0xcc>
		*endptr = (char *) s;
  8024d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8024d7:	89 c8                	mov    %ecx,%eax
  8024d9:	f7 d8                	neg    %eax
  8024db:	85 ff                	test   %edi,%edi
  8024dd:	0f 45 c8             	cmovne %eax,%ecx
}
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	5b                   	pop    %ebx
  8024e3:	5e                   	pop    %esi
  8024e4:	5f                   	pop    %edi
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    

008024e7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024e7:	55                   	push   %ebp
  8024e8:	89 e5                	mov    %esp,%ebp
  8024ea:	57                   	push   %edi
  8024eb:	56                   	push   %esi
  8024ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8024ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f8:	89 c3                	mov    %eax,%ebx
  8024fa:	89 c7                	mov    %eax,%edi
  8024fc:	89 c6                	mov    %eax,%esi
  8024fe:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    

00802505 <sys_cgetc>:

int
sys_cgetc(void)
{
  802505:	55                   	push   %ebp
  802506:	89 e5                	mov    %esp,%ebp
  802508:	57                   	push   %edi
  802509:	56                   	push   %esi
  80250a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80250b:	ba 00 00 00 00       	mov    $0x0,%edx
  802510:	b8 01 00 00 00       	mov    $0x1,%eax
  802515:	89 d1                	mov    %edx,%ecx
  802517:	89 d3                	mov    %edx,%ebx
  802519:	89 d7                	mov    %edx,%edi
  80251b:	89 d6                	mov    %edx,%esi
  80251d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    

00802524 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	57                   	push   %edi
  802528:	56                   	push   %esi
  802529:	53                   	push   %ebx
  80252a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80252d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802532:	8b 55 08             	mov    0x8(%ebp),%edx
  802535:	b8 03 00 00 00       	mov    $0x3,%eax
  80253a:	89 cb                	mov    %ecx,%ebx
  80253c:	89 cf                	mov    %ecx,%edi
  80253e:	89 ce                	mov    %ecx,%esi
  802540:	cd 30                	int    $0x30
	if(check && ret > 0)
  802542:	85 c0                	test   %eax,%eax
  802544:	7f 08                	jg     80254e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802549:	5b                   	pop    %ebx
  80254a:	5e                   	pop    %esi
  80254b:	5f                   	pop    %edi
  80254c:	5d                   	pop    %ebp
  80254d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80254e:	83 ec 0c             	sub    $0xc,%esp
  802551:	50                   	push   %eax
  802552:	6a 03                	push   $0x3
  802554:	68 3f 41 80 00       	push   $0x80413f
  802559:	6a 2a                	push   $0x2a
  80255b:	68 5c 41 80 00       	push   $0x80415c
  802560:	e8 8d f5 ff ff       	call   801af2 <_panic>

00802565 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	57                   	push   %edi
  802569:	56                   	push   %esi
  80256a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80256b:	ba 00 00 00 00       	mov    $0x0,%edx
  802570:	b8 02 00 00 00       	mov    $0x2,%eax
  802575:	89 d1                	mov    %edx,%ecx
  802577:	89 d3                	mov    %edx,%ebx
  802579:	89 d7                	mov    %edx,%edi
  80257b:	89 d6                	mov    %edx,%esi
  80257d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    

00802584 <sys_yield>:

void
sys_yield(void)
{
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	57                   	push   %edi
  802588:	56                   	push   %esi
  802589:	53                   	push   %ebx
	asm volatile("int %1\n"
  80258a:	ba 00 00 00 00       	mov    $0x0,%edx
  80258f:	b8 0b 00 00 00       	mov    $0xb,%eax
  802594:	89 d1                	mov    %edx,%ecx
  802596:	89 d3                	mov    %edx,%ebx
  802598:	89 d7                	mov    %edx,%edi
  80259a:	89 d6                	mov    %edx,%esi
  80259c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80259e:	5b                   	pop    %ebx
  80259f:	5e                   	pop    %esi
  8025a0:	5f                   	pop    %edi
  8025a1:	5d                   	pop    %ebp
  8025a2:	c3                   	ret    

008025a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8025a3:	55                   	push   %ebp
  8025a4:	89 e5                	mov    %esp,%ebp
  8025a6:	57                   	push   %edi
  8025a7:	56                   	push   %esi
  8025a8:	53                   	push   %ebx
  8025a9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025ac:	be 00 00 00 00       	mov    $0x0,%esi
  8025b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8025bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025bf:	89 f7                	mov    %esi,%edi
  8025c1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8025c3:	85 c0                	test   %eax,%eax
  8025c5:	7f 08                	jg     8025cf <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ca:	5b                   	pop    %ebx
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8025cf:	83 ec 0c             	sub    $0xc,%esp
  8025d2:	50                   	push   %eax
  8025d3:	6a 04                	push   $0x4
  8025d5:	68 3f 41 80 00       	push   $0x80413f
  8025da:	6a 2a                	push   $0x2a
  8025dc:	68 5c 41 80 00       	push   $0x80415c
  8025e1:	e8 0c f5 ff ff       	call   801af2 <_panic>

008025e6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025e6:	55                   	push   %ebp
  8025e7:	89 e5                	mov    %esp,%ebp
  8025e9:	57                   	push   %edi
  8025ea:	56                   	push   %esi
  8025eb:	53                   	push   %ebx
  8025ec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8025f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8025fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025fd:	8b 7d 14             	mov    0x14(%ebp),%edi
  802600:	8b 75 18             	mov    0x18(%ebp),%esi
  802603:	cd 30                	int    $0x30
	if(check && ret > 0)
  802605:	85 c0                	test   %eax,%eax
  802607:	7f 08                	jg     802611 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802609:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802611:	83 ec 0c             	sub    $0xc,%esp
  802614:	50                   	push   %eax
  802615:	6a 05                	push   $0x5
  802617:	68 3f 41 80 00       	push   $0x80413f
  80261c:	6a 2a                	push   $0x2a
  80261e:	68 5c 41 80 00       	push   $0x80415c
  802623:	e8 ca f4 ff ff       	call   801af2 <_panic>

00802628 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802628:	55                   	push   %ebp
  802629:	89 e5                	mov    %esp,%ebp
  80262b:	57                   	push   %edi
  80262c:	56                   	push   %esi
  80262d:	53                   	push   %ebx
  80262e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802631:	bb 00 00 00 00       	mov    $0x0,%ebx
  802636:	8b 55 08             	mov    0x8(%ebp),%edx
  802639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80263c:	b8 06 00 00 00       	mov    $0x6,%eax
  802641:	89 df                	mov    %ebx,%edi
  802643:	89 de                	mov    %ebx,%esi
  802645:	cd 30                	int    $0x30
	if(check && ret > 0)
  802647:	85 c0                	test   %eax,%eax
  802649:	7f 08                	jg     802653 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80264b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264e:	5b                   	pop    %ebx
  80264f:	5e                   	pop    %esi
  802650:	5f                   	pop    %edi
  802651:	5d                   	pop    %ebp
  802652:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802653:	83 ec 0c             	sub    $0xc,%esp
  802656:	50                   	push   %eax
  802657:	6a 06                	push   $0x6
  802659:	68 3f 41 80 00       	push   $0x80413f
  80265e:	6a 2a                	push   $0x2a
  802660:	68 5c 41 80 00       	push   $0x80415c
  802665:	e8 88 f4 ff ff       	call   801af2 <_panic>

0080266a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	57                   	push   %edi
  80266e:	56                   	push   %esi
  80266f:	53                   	push   %ebx
  802670:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802673:	bb 00 00 00 00       	mov    $0x0,%ebx
  802678:	8b 55 08             	mov    0x8(%ebp),%edx
  80267b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80267e:	b8 08 00 00 00       	mov    $0x8,%eax
  802683:	89 df                	mov    %ebx,%edi
  802685:	89 de                	mov    %ebx,%esi
  802687:	cd 30                	int    $0x30
	if(check && ret > 0)
  802689:	85 c0                	test   %eax,%eax
  80268b:	7f 08                	jg     802695 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80268d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802690:	5b                   	pop    %ebx
  802691:	5e                   	pop    %esi
  802692:	5f                   	pop    %edi
  802693:	5d                   	pop    %ebp
  802694:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802695:	83 ec 0c             	sub    $0xc,%esp
  802698:	50                   	push   %eax
  802699:	6a 08                	push   $0x8
  80269b:	68 3f 41 80 00       	push   $0x80413f
  8026a0:	6a 2a                	push   $0x2a
  8026a2:	68 5c 41 80 00       	push   $0x80415c
  8026a7:	e8 46 f4 ff ff       	call   801af2 <_panic>

008026ac <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8026ac:	55                   	push   %ebp
  8026ad:	89 e5                	mov    %esp,%ebp
  8026af:	57                   	push   %edi
  8026b0:	56                   	push   %esi
  8026b1:	53                   	push   %ebx
  8026b2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8026bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026c0:	b8 09 00 00 00       	mov    $0x9,%eax
  8026c5:	89 df                	mov    %ebx,%edi
  8026c7:	89 de                	mov    %ebx,%esi
  8026c9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026cb:	85 c0                	test   %eax,%eax
  8026cd:	7f 08                	jg     8026d7 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d2:	5b                   	pop    %ebx
  8026d3:	5e                   	pop    %esi
  8026d4:	5f                   	pop    %edi
  8026d5:	5d                   	pop    %ebp
  8026d6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8026d7:	83 ec 0c             	sub    $0xc,%esp
  8026da:	50                   	push   %eax
  8026db:	6a 09                	push   $0x9
  8026dd:	68 3f 41 80 00       	push   $0x80413f
  8026e2:	6a 2a                	push   $0x2a
  8026e4:	68 5c 41 80 00       	push   $0x80415c
  8026e9:	e8 04 f4 ff ff       	call   801af2 <_panic>

008026ee <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026ee:	55                   	push   %ebp
  8026ef:	89 e5                	mov    %esp,%ebp
  8026f1:	57                   	push   %edi
  8026f2:	56                   	push   %esi
  8026f3:	53                   	push   %ebx
  8026f4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802702:	b8 0a 00 00 00       	mov    $0xa,%eax
  802707:	89 df                	mov    %ebx,%edi
  802709:	89 de                	mov    %ebx,%esi
  80270b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80270d:	85 c0                	test   %eax,%eax
  80270f:	7f 08                	jg     802719 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802711:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802714:	5b                   	pop    %ebx
  802715:	5e                   	pop    %esi
  802716:	5f                   	pop    %edi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802719:	83 ec 0c             	sub    $0xc,%esp
  80271c:	50                   	push   %eax
  80271d:	6a 0a                	push   $0xa
  80271f:	68 3f 41 80 00       	push   $0x80413f
  802724:	6a 2a                	push   $0x2a
  802726:	68 5c 41 80 00       	push   $0x80415c
  80272b:	e8 c2 f3 ff ff       	call   801af2 <_panic>

00802730 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	57                   	push   %edi
  802734:	56                   	push   %esi
  802735:	53                   	push   %ebx
	asm volatile("int %1\n"
  802736:	8b 55 08             	mov    0x8(%ebp),%edx
  802739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80273c:	b8 0c 00 00 00       	mov    $0xc,%eax
  802741:	be 00 00 00 00       	mov    $0x0,%esi
  802746:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802749:	8b 7d 14             	mov    0x14(%ebp),%edi
  80274c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80274e:	5b                   	pop    %ebx
  80274f:	5e                   	pop    %esi
  802750:	5f                   	pop    %edi
  802751:	5d                   	pop    %ebp
  802752:	c3                   	ret    

00802753 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802753:	55                   	push   %ebp
  802754:	89 e5                	mov    %esp,%ebp
  802756:	57                   	push   %edi
  802757:	56                   	push   %esi
  802758:	53                   	push   %ebx
  802759:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80275c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802761:	8b 55 08             	mov    0x8(%ebp),%edx
  802764:	b8 0d 00 00 00       	mov    $0xd,%eax
  802769:	89 cb                	mov    %ecx,%ebx
  80276b:	89 cf                	mov    %ecx,%edi
  80276d:	89 ce                	mov    %ecx,%esi
  80276f:	cd 30                	int    $0x30
	if(check && ret > 0)
  802771:	85 c0                	test   %eax,%eax
  802773:	7f 08                	jg     80277d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802775:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802778:	5b                   	pop    %ebx
  802779:	5e                   	pop    %esi
  80277a:	5f                   	pop    %edi
  80277b:	5d                   	pop    %ebp
  80277c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80277d:	83 ec 0c             	sub    $0xc,%esp
  802780:	50                   	push   %eax
  802781:	6a 0d                	push   $0xd
  802783:	68 3f 41 80 00       	push   $0x80413f
  802788:	6a 2a                	push   $0x2a
  80278a:	68 5c 41 80 00       	push   $0x80415c
  80278f:	e8 5e f3 ff ff       	call   801af2 <_panic>

00802794 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802794:	55                   	push   %ebp
  802795:	89 e5                	mov    %esp,%ebp
  802797:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80279a:	83 3d 0c a0 80 00 00 	cmpl   $0x0,0x80a00c
  8027a1:	74 0a                	je     8027ad <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a6:	a3 0c a0 80 00       	mov    %eax,0x80a00c
}
  8027ab:	c9                   	leave  
  8027ac:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8027ad:	e8 b3 fd ff ff       	call   802565 <sys_getenvid>
  8027b2:	83 ec 04             	sub    $0x4,%esp
  8027b5:	68 07 0e 00 00       	push   $0xe07
  8027ba:	68 00 f0 bf ee       	push   $0xeebff000
  8027bf:	50                   	push   %eax
  8027c0:	e8 de fd ff ff       	call   8025a3 <sys_page_alloc>
		if (r < 0) {
  8027c5:	83 c4 10             	add    $0x10,%esp
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	78 2c                	js     8027f8 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8027cc:	e8 94 fd ff ff       	call   802565 <sys_getenvid>
  8027d1:	83 ec 08             	sub    $0x8,%esp
  8027d4:	68 0a 28 80 00       	push   $0x80280a
  8027d9:	50                   	push   %eax
  8027da:	e8 0f ff ff ff       	call   8026ee <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8027df:	83 c4 10             	add    $0x10,%esp
  8027e2:	85 c0                	test   %eax,%eax
  8027e4:	79 bd                	jns    8027a3 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8027e6:	50                   	push   %eax
  8027e7:	68 ac 41 80 00       	push   $0x8041ac
  8027ec:	6a 28                	push   $0x28
  8027ee:	68 e2 41 80 00       	push   $0x8041e2
  8027f3:	e8 fa f2 ff ff       	call   801af2 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8027f8:	50                   	push   %eax
  8027f9:	68 6c 41 80 00       	push   $0x80416c
  8027fe:	6a 23                	push   $0x23
  802800:	68 e2 41 80 00       	push   $0x8041e2
  802805:	e8 e8 f2 ff ff       	call   801af2 <_panic>

0080280a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80280a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80280b:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	call *%eax
  802810:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802812:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802815:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802819:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80281c:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802820:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802824:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802826:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802829:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80282a:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80282d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80282e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80282f:	c3                   	ret    

00802830 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802830:	55                   	push   %ebp
  802831:	89 e5                	mov    %esp,%ebp
  802833:	56                   	push   %esi
  802834:	53                   	push   %ebx
  802835:	8b 75 08             	mov    0x8(%ebp),%esi
  802838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80283b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80283e:	85 c0                	test   %eax,%eax
  802840:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802845:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802848:	83 ec 0c             	sub    $0xc,%esp
  80284b:	50                   	push   %eax
  80284c:	e8 02 ff ff ff       	call   802753 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802851:	83 c4 10             	add    $0x10,%esp
  802854:	85 f6                	test   %esi,%esi
  802856:	74 14                	je     80286c <ipc_recv+0x3c>
  802858:	ba 00 00 00 00       	mov    $0x0,%edx
  80285d:	85 c0                	test   %eax,%eax
  80285f:	78 09                	js     80286a <ipc_recv+0x3a>
  802861:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  802867:	8b 52 74             	mov    0x74(%edx),%edx
  80286a:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80286c:	85 db                	test   %ebx,%ebx
  80286e:	74 14                	je     802884 <ipc_recv+0x54>
  802870:	ba 00 00 00 00       	mov    $0x0,%edx
  802875:	85 c0                	test   %eax,%eax
  802877:	78 09                	js     802882 <ipc_recv+0x52>
  802879:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80287f:	8b 52 78             	mov    0x78(%edx),%edx
  802882:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802884:	85 c0                	test   %eax,%eax
  802886:	78 08                	js     802890 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802888:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80288d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802890:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802893:	5b                   	pop    %ebx
  802894:	5e                   	pop    %esi
  802895:	5d                   	pop    %ebp
  802896:	c3                   	ret    

00802897 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802897:	55                   	push   %ebp
  802898:	89 e5                	mov    %esp,%ebp
  80289a:	57                   	push   %edi
  80289b:	56                   	push   %esi
  80289c:	53                   	push   %ebx
  80289d:	83 ec 0c             	sub    $0xc,%esp
  8028a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8028a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8028a9:	85 db                	test   %ebx,%ebx
  8028ab:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8028b0:	0f 44 d8             	cmove  %eax,%ebx
  8028b3:	eb 05                	jmp    8028ba <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8028b5:	e8 ca fc ff ff       	call   802584 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8028ba:	ff 75 14             	push   0x14(%ebp)
  8028bd:	53                   	push   %ebx
  8028be:	56                   	push   %esi
  8028bf:	57                   	push   %edi
  8028c0:	e8 6b fe ff ff       	call   802730 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8028c5:	83 c4 10             	add    $0x10,%esp
  8028c8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028cb:	74 e8                	je     8028b5 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8028cd:	85 c0                	test   %eax,%eax
  8028cf:	78 08                	js     8028d9 <ipc_send+0x42>
	}while (r<0);

}
  8028d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028d4:	5b                   	pop    %ebx
  8028d5:	5e                   	pop    %esi
  8028d6:	5f                   	pop    %edi
  8028d7:	5d                   	pop    %ebp
  8028d8:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8028d9:	50                   	push   %eax
  8028da:	68 f0 41 80 00       	push   $0x8041f0
  8028df:	6a 3d                	push   $0x3d
  8028e1:	68 04 42 80 00       	push   $0x804204
  8028e6:	e8 07 f2 ff ff       	call   801af2 <_panic>

008028eb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028eb:	55                   	push   %ebp
  8028ec:	89 e5                	mov    %esp,%ebp
  8028ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028f1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028f6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028ff:	8b 52 50             	mov    0x50(%edx),%edx
  802902:	39 ca                	cmp    %ecx,%edx
  802904:	74 11                	je     802917 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802906:	83 c0 01             	add    $0x1,%eax
  802909:	3d 00 04 00 00       	cmp    $0x400,%eax
  80290e:	75 e6                	jne    8028f6 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802910:	b8 00 00 00 00       	mov    $0x0,%eax
  802915:	eb 0b                	jmp    802922 <ipc_find_env+0x37>
			return envs[i].env_id;
  802917:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80291a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80291f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802922:	5d                   	pop    %ebp
  802923:	c3                   	ret    

00802924 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802924:	55                   	push   %ebp
  802925:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802927:	8b 45 08             	mov    0x8(%ebp),%eax
  80292a:	05 00 00 00 30       	add    $0x30000000,%eax
  80292f:	c1 e8 0c             	shr    $0xc,%eax
}
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    

00802934 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802934:	55                   	push   %ebp
  802935:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802937:	8b 45 08             	mov    0x8(%ebp),%eax
  80293a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80293f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802944:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802949:	5d                   	pop    %ebp
  80294a:	c3                   	ret    

0080294b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80294b:	55                   	push   %ebp
  80294c:	89 e5                	mov    %esp,%ebp
  80294e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802953:	89 c2                	mov    %eax,%edx
  802955:	c1 ea 16             	shr    $0x16,%edx
  802958:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80295f:	f6 c2 01             	test   $0x1,%dl
  802962:	74 29                	je     80298d <fd_alloc+0x42>
  802964:	89 c2                	mov    %eax,%edx
  802966:	c1 ea 0c             	shr    $0xc,%edx
  802969:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802970:	f6 c2 01             	test   $0x1,%dl
  802973:	74 18                	je     80298d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  802975:	05 00 10 00 00       	add    $0x1000,%eax
  80297a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80297f:	75 d2                	jne    802953 <fd_alloc+0x8>
  802981:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  802986:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80298b:	eb 05                	jmp    802992 <fd_alloc+0x47>
			return 0;
  80298d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  802992:	8b 55 08             	mov    0x8(%ebp),%edx
  802995:	89 02                	mov    %eax,(%edx)
}
  802997:	89 c8                	mov    %ecx,%eax
  802999:	5d                   	pop    %ebp
  80299a:	c3                   	ret    

0080299b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80299b:	55                   	push   %ebp
  80299c:	89 e5                	mov    %esp,%ebp
  80299e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8029a1:	83 f8 1f             	cmp    $0x1f,%eax
  8029a4:	77 30                	ja     8029d6 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8029a6:	c1 e0 0c             	shl    $0xc,%eax
  8029a9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8029ae:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8029b4:	f6 c2 01             	test   $0x1,%dl
  8029b7:	74 24                	je     8029dd <fd_lookup+0x42>
  8029b9:	89 c2                	mov    %eax,%edx
  8029bb:	c1 ea 0c             	shr    $0xc,%edx
  8029be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029c5:	f6 c2 01             	test   $0x1,%dl
  8029c8:	74 1a                	je     8029e4 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8029ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029cd:	89 02                	mov    %eax,(%edx)
	return 0;
  8029cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029d4:	5d                   	pop    %ebp
  8029d5:	c3                   	ret    
		return -E_INVAL;
  8029d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029db:	eb f7                	jmp    8029d4 <fd_lookup+0x39>
		return -E_INVAL;
  8029dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029e2:	eb f0                	jmp    8029d4 <fd_lookup+0x39>
  8029e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029e9:	eb e9                	jmp    8029d4 <fd_lookup+0x39>

008029eb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8029eb:	55                   	push   %ebp
  8029ec:	89 e5                	mov    %esp,%ebp
  8029ee:	53                   	push   %ebx
  8029ef:	83 ec 04             	sub    $0x4,%esp
  8029f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8029f5:	b8 8c 42 80 00       	mov    $0x80428c,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8029fa:	bb 64 90 80 00       	mov    $0x809064,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8029ff:	39 13                	cmp    %edx,(%ebx)
  802a01:	74 32                	je     802a35 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  802a03:	83 c0 04             	add    $0x4,%eax
  802a06:	8b 18                	mov    (%eax),%ebx
  802a08:	85 db                	test   %ebx,%ebx
  802a0a:	75 f3                	jne    8029ff <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a0c:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802a11:	8b 40 48             	mov    0x48(%eax),%eax
  802a14:	83 ec 04             	sub    $0x4,%esp
  802a17:	52                   	push   %edx
  802a18:	50                   	push   %eax
  802a19:	68 10 42 80 00       	push   $0x804210
  802a1e:	e8 aa f1 ff ff       	call   801bcd <cprintf>
	*dev = 0;
	return -E_INVAL;
  802a23:	83 c4 10             	add    $0x10,%esp
  802a26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  802a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a2e:	89 1a                	mov    %ebx,(%edx)
}
  802a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a33:	c9                   	leave  
  802a34:	c3                   	ret    
			return 0;
  802a35:	b8 00 00 00 00       	mov    $0x0,%eax
  802a3a:	eb ef                	jmp    802a2b <dev_lookup+0x40>

00802a3c <fd_close>:
{
  802a3c:	55                   	push   %ebp
  802a3d:	89 e5                	mov    %esp,%ebp
  802a3f:	57                   	push   %edi
  802a40:	56                   	push   %esi
  802a41:	53                   	push   %ebx
  802a42:	83 ec 24             	sub    $0x24,%esp
  802a45:	8b 75 08             	mov    0x8(%ebp),%esi
  802a48:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a4b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a4e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a4f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a55:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a58:	50                   	push   %eax
  802a59:	e8 3d ff ff ff       	call   80299b <fd_lookup>
  802a5e:	89 c3                	mov    %eax,%ebx
  802a60:	83 c4 10             	add    $0x10,%esp
  802a63:	85 c0                	test   %eax,%eax
  802a65:	78 05                	js     802a6c <fd_close+0x30>
	    || fd != fd2)
  802a67:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802a6a:	74 16                	je     802a82 <fd_close+0x46>
		return (must_exist ? r : 0);
  802a6c:	89 f8                	mov    %edi,%eax
  802a6e:	84 c0                	test   %al,%al
  802a70:	b8 00 00 00 00       	mov    $0x0,%eax
  802a75:	0f 44 d8             	cmove  %eax,%ebx
}
  802a78:	89 d8                	mov    %ebx,%eax
  802a7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a7d:	5b                   	pop    %ebx
  802a7e:	5e                   	pop    %esi
  802a7f:	5f                   	pop    %edi
  802a80:	5d                   	pop    %ebp
  802a81:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a82:	83 ec 08             	sub    $0x8,%esp
  802a85:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802a88:	50                   	push   %eax
  802a89:	ff 36                	push   (%esi)
  802a8b:	e8 5b ff ff ff       	call   8029eb <dev_lookup>
  802a90:	89 c3                	mov    %eax,%ebx
  802a92:	83 c4 10             	add    $0x10,%esp
  802a95:	85 c0                	test   %eax,%eax
  802a97:	78 1a                	js     802ab3 <fd_close+0x77>
		if (dev->dev_close)
  802a99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a9c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802a9f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802aa4:	85 c0                	test   %eax,%eax
  802aa6:	74 0b                	je     802ab3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  802aa8:	83 ec 0c             	sub    $0xc,%esp
  802aab:	56                   	push   %esi
  802aac:	ff d0                	call   *%eax
  802aae:	89 c3                	mov    %eax,%ebx
  802ab0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802ab3:	83 ec 08             	sub    $0x8,%esp
  802ab6:	56                   	push   %esi
  802ab7:	6a 00                	push   $0x0
  802ab9:	e8 6a fb ff ff       	call   802628 <sys_page_unmap>
	return r;
  802abe:	83 c4 10             	add    $0x10,%esp
  802ac1:	eb b5                	jmp    802a78 <fd_close+0x3c>

00802ac3 <close>:

int
close(int fdnum)
{
  802ac3:	55                   	push   %ebp
  802ac4:	89 e5                	mov    %esp,%ebp
  802ac6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802acc:	50                   	push   %eax
  802acd:	ff 75 08             	push   0x8(%ebp)
  802ad0:	e8 c6 fe ff ff       	call   80299b <fd_lookup>
  802ad5:	83 c4 10             	add    $0x10,%esp
  802ad8:	85 c0                	test   %eax,%eax
  802ada:	79 02                	jns    802ade <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  802adc:	c9                   	leave  
  802add:	c3                   	ret    
		return fd_close(fd, 1);
  802ade:	83 ec 08             	sub    $0x8,%esp
  802ae1:	6a 01                	push   $0x1
  802ae3:	ff 75 f4             	push   -0xc(%ebp)
  802ae6:	e8 51 ff ff ff       	call   802a3c <fd_close>
  802aeb:	83 c4 10             	add    $0x10,%esp
  802aee:	eb ec                	jmp    802adc <close+0x19>

00802af0 <close_all>:

void
close_all(void)
{
  802af0:	55                   	push   %ebp
  802af1:	89 e5                	mov    %esp,%ebp
  802af3:	53                   	push   %ebx
  802af4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802af7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802afc:	83 ec 0c             	sub    $0xc,%esp
  802aff:	53                   	push   %ebx
  802b00:	e8 be ff ff ff       	call   802ac3 <close>
	for (i = 0; i < MAXFD; i++)
  802b05:	83 c3 01             	add    $0x1,%ebx
  802b08:	83 c4 10             	add    $0x10,%esp
  802b0b:	83 fb 20             	cmp    $0x20,%ebx
  802b0e:	75 ec                	jne    802afc <close_all+0xc>
}
  802b10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b13:	c9                   	leave  
  802b14:	c3                   	ret    

00802b15 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b15:	55                   	push   %ebp
  802b16:	89 e5                	mov    %esp,%ebp
  802b18:	57                   	push   %edi
  802b19:	56                   	push   %esi
  802b1a:	53                   	push   %ebx
  802b1b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b1e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b21:	50                   	push   %eax
  802b22:	ff 75 08             	push   0x8(%ebp)
  802b25:	e8 71 fe ff ff       	call   80299b <fd_lookup>
  802b2a:	89 c3                	mov    %eax,%ebx
  802b2c:	83 c4 10             	add    $0x10,%esp
  802b2f:	85 c0                	test   %eax,%eax
  802b31:	78 7f                	js     802bb2 <dup+0x9d>
		return r;
	close(newfdnum);
  802b33:	83 ec 0c             	sub    $0xc,%esp
  802b36:	ff 75 0c             	push   0xc(%ebp)
  802b39:	e8 85 ff ff ff       	call   802ac3 <close>

	newfd = INDEX2FD(newfdnum);
  802b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b41:	c1 e6 0c             	shl    $0xc,%esi
  802b44:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802b4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802b4d:	89 3c 24             	mov    %edi,(%esp)
  802b50:	e8 df fd ff ff       	call   802934 <fd2data>
  802b55:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802b57:	89 34 24             	mov    %esi,(%esp)
  802b5a:	e8 d5 fd ff ff       	call   802934 <fd2data>
  802b5f:	83 c4 10             	add    $0x10,%esp
  802b62:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b65:	89 d8                	mov    %ebx,%eax
  802b67:	c1 e8 16             	shr    $0x16,%eax
  802b6a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b71:	a8 01                	test   $0x1,%al
  802b73:	74 11                	je     802b86 <dup+0x71>
  802b75:	89 d8                	mov    %ebx,%eax
  802b77:	c1 e8 0c             	shr    $0xc,%eax
  802b7a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b81:	f6 c2 01             	test   $0x1,%dl
  802b84:	75 36                	jne    802bbc <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b86:	89 f8                	mov    %edi,%eax
  802b88:	c1 e8 0c             	shr    $0xc,%eax
  802b8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b92:	83 ec 0c             	sub    $0xc,%esp
  802b95:	25 07 0e 00 00       	and    $0xe07,%eax
  802b9a:	50                   	push   %eax
  802b9b:	56                   	push   %esi
  802b9c:	6a 00                	push   $0x0
  802b9e:	57                   	push   %edi
  802b9f:	6a 00                	push   $0x0
  802ba1:	e8 40 fa ff ff       	call   8025e6 <sys_page_map>
  802ba6:	89 c3                	mov    %eax,%ebx
  802ba8:	83 c4 20             	add    $0x20,%esp
  802bab:	85 c0                	test   %eax,%eax
  802bad:	78 33                	js     802be2 <dup+0xcd>
		goto err;

	return newfdnum;
  802baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802bb2:	89 d8                	mov    %ebx,%eax
  802bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bb7:	5b                   	pop    %ebx
  802bb8:	5e                   	pop    %esi
  802bb9:	5f                   	pop    %edi
  802bba:	5d                   	pop    %ebp
  802bbb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802bbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802bc3:	83 ec 0c             	sub    $0xc,%esp
  802bc6:	25 07 0e 00 00       	and    $0xe07,%eax
  802bcb:	50                   	push   %eax
  802bcc:	ff 75 d4             	push   -0x2c(%ebp)
  802bcf:	6a 00                	push   $0x0
  802bd1:	53                   	push   %ebx
  802bd2:	6a 00                	push   $0x0
  802bd4:	e8 0d fa ff ff       	call   8025e6 <sys_page_map>
  802bd9:	89 c3                	mov    %eax,%ebx
  802bdb:	83 c4 20             	add    $0x20,%esp
  802bde:	85 c0                	test   %eax,%eax
  802be0:	79 a4                	jns    802b86 <dup+0x71>
	sys_page_unmap(0, newfd);
  802be2:	83 ec 08             	sub    $0x8,%esp
  802be5:	56                   	push   %esi
  802be6:	6a 00                	push   $0x0
  802be8:	e8 3b fa ff ff       	call   802628 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802bed:	83 c4 08             	add    $0x8,%esp
  802bf0:	ff 75 d4             	push   -0x2c(%ebp)
  802bf3:	6a 00                	push   $0x0
  802bf5:	e8 2e fa ff ff       	call   802628 <sys_page_unmap>
	return r;
  802bfa:	83 c4 10             	add    $0x10,%esp
  802bfd:	eb b3                	jmp    802bb2 <dup+0x9d>

00802bff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bff:	55                   	push   %ebp
  802c00:	89 e5                	mov    %esp,%ebp
  802c02:	56                   	push   %esi
  802c03:	53                   	push   %ebx
  802c04:	83 ec 18             	sub    $0x18,%esp
  802c07:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c0d:	50                   	push   %eax
  802c0e:	56                   	push   %esi
  802c0f:	e8 87 fd ff ff       	call   80299b <fd_lookup>
  802c14:	83 c4 10             	add    $0x10,%esp
  802c17:	85 c0                	test   %eax,%eax
  802c19:	78 3c                	js     802c57 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c1b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  802c1e:	83 ec 08             	sub    $0x8,%esp
  802c21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c24:	50                   	push   %eax
  802c25:	ff 33                	push   (%ebx)
  802c27:	e8 bf fd ff ff       	call   8029eb <dev_lookup>
  802c2c:	83 c4 10             	add    $0x10,%esp
  802c2f:	85 c0                	test   %eax,%eax
  802c31:	78 24                	js     802c57 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c33:	8b 43 08             	mov    0x8(%ebx),%eax
  802c36:	83 e0 03             	and    $0x3,%eax
  802c39:	83 f8 01             	cmp    $0x1,%eax
  802c3c:	74 20                	je     802c5e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c41:	8b 40 08             	mov    0x8(%eax),%eax
  802c44:	85 c0                	test   %eax,%eax
  802c46:	74 37                	je     802c7f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c48:	83 ec 04             	sub    $0x4,%esp
  802c4b:	ff 75 10             	push   0x10(%ebp)
  802c4e:	ff 75 0c             	push   0xc(%ebp)
  802c51:	53                   	push   %ebx
  802c52:	ff d0                	call   *%eax
  802c54:	83 c4 10             	add    $0x10,%esp
}
  802c57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c5a:	5b                   	pop    %ebx
  802c5b:	5e                   	pop    %esi
  802c5c:	5d                   	pop    %ebp
  802c5d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c5e:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802c63:	8b 40 48             	mov    0x48(%eax),%eax
  802c66:	83 ec 04             	sub    $0x4,%esp
  802c69:	56                   	push   %esi
  802c6a:	50                   	push   %eax
  802c6b:	68 51 42 80 00       	push   $0x804251
  802c70:	e8 58 ef ff ff       	call   801bcd <cprintf>
		return -E_INVAL;
  802c75:	83 c4 10             	add    $0x10,%esp
  802c78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c7d:	eb d8                	jmp    802c57 <read+0x58>
		return -E_NOT_SUPP;
  802c7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802c84:	eb d1                	jmp    802c57 <read+0x58>

00802c86 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c86:	55                   	push   %ebp
  802c87:	89 e5                	mov    %esp,%ebp
  802c89:	57                   	push   %edi
  802c8a:	56                   	push   %esi
  802c8b:	53                   	push   %ebx
  802c8c:	83 ec 0c             	sub    $0xc,%esp
  802c8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c92:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c9a:	eb 02                	jmp    802c9e <readn+0x18>
  802c9c:	01 c3                	add    %eax,%ebx
  802c9e:	39 f3                	cmp    %esi,%ebx
  802ca0:	73 21                	jae    802cc3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802ca2:	83 ec 04             	sub    $0x4,%esp
  802ca5:	89 f0                	mov    %esi,%eax
  802ca7:	29 d8                	sub    %ebx,%eax
  802ca9:	50                   	push   %eax
  802caa:	89 d8                	mov    %ebx,%eax
  802cac:	03 45 0c             	add    0xc(%ebp),%eax
  802caf:	50                   	push   %eax
  802cb0:	57                   	push   %edi
  802cb1:	e8 49 ff ff ff       	call   802bff <read>
		if (m < 0)
  802cb6:	83 c4 10             	add    $0x10,%esp
  802cb9:	85 c0                	test   %eax,%eax
  802cbb:	78 04                	js     802cc1 <readn+0x3b>
			return m;
		if (m == 0)
  802cbd:	75 dd                	jne    802c9c <readn+0x16>
  802cbf:	eb 02                	jmp    802cc3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802cc1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802cc3:	89 d8                	mov    %ebx,%eax
  802cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cc8:	5b                   	pop    %ebx
  802cc9:	5e                   	pop    %esi
  802cca:	5f                   	pop    %edi
  802ccb:	5d                   	pop    %ebp
  802ccc:	c3                   	ret    

00802ccd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802ccd:	55                   	push   %ebp
  802cce:	89 e5                	mov    %esp,%ebp
  802cd0:	56                   	push   %esi
  802cd1:	53                   	push   %ebx
  802cd2:	83 ec 18             	sub    $0x18,%esp
  802cd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cdb:	50                   	push   %eax
  802cdc:	53                   	push   %ebx
  802cdd:	e8 b9 fc ff ff       	call   80299b <fd_lookup>
  802ce2:	83 c4 10             	add    $0x10,%esp
  802ce5:	85 c0                	test   %eax,%eax
  802ce7:	78 37                	js     802d20 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ce9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802cec:	83 ec 08             	sub    $0x8,%esp
  802cef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cf2:	50                   	push   %eax
  802cf3:	ff 36                	push   (%esi)
  802cf5:	e8 f1 fc ff ff       	call   8029eb <dev_lookup>
  802cfa:	83 c4 10             	add    $0x10,%esp
  802cfd:	85 c0                	test   %eax,%eax
  802cff:	78 1f                	js     802d20 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d01:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802d05:	74 20                	je     802d27 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d0a:	8b 40 0c             	mov    0xc(%eax),%eax
  802d0d:	85 c0                	test   %eax,%eax
  802d0f:	74 37                	je     802d48 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d11:	83 ec 04             	sub    $0x4,%esp
  802d14:	ff 75 10             	push   0x10(%ebp)
  802d17:	ff 75 0c             	push   0xc(%ebp)
  802d1a:	56                   	push   %esi
  802d1b:	ff d0                	call   *%eax
  802d1d:	83 c4 10             	add    $0x10,%esp
}
  802d20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d23:	5b                   	pop    %ebx
  802d24:	5e                   	pop    %esi
  802d25:	5d                   	pop    %ebp
  802d26:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d27:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802d2c:	8b 40 48             	mov    0x48(%eax),%eax
  802d2f:	83 ec 04             	sub    $0x4,%esp
  802d32:	53                   	push   %ebx
  802d33:	50                   	push   %eax
  802d34:	68 6d 42 80 00       	push   $0x80426d
  802d39:	e8 8f ee ff ff       	call   801bcd <cprintf>
		return -E_INVAL;
  802d3e:	83 c4 10             	add    $0x10,%esp
  802d41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d46:	eb d8                	jmp    802d20 <write+0x53>
		return -E_NOT_SUPP;
  802d48:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d4d:	eb d1                	jmp    802d20 <write+0x53>

00802d4f <seek>:

int
seek(int fdnum, off_t offset)
{
  802d4f:	55                   	push   %ebp
  802d50:	89 e5                	mov    %esp,%ebp
  802d52:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d58:	50                   	push   %eax
  802d59:	ff 75 08             	push   0x8(%ebp)
  802d5c:	e8 3a fc ff ff       	call   80299b <fd_lookup>
  802d61:	83 c4 10             	add    $0x10,%esp
  802d64:	85 c0                	test   %eax,%eax
  802d66:	78 0e                	js     802d76 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d68:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d6e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d76:	c9                   	leave  
  802d77:	c3                   	ret    

00802d78 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d78:	55                   	push   %ebp
  802d79:	89 e5                	mov    %esp,%ebp
  802d7b:	56                   	push   %esi
  802d7c:	53                   	push   %ebx
  802d7d:	83 ec 18             	sub    $0x18,%esp
  802d80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d86:	50                   	push   %eax
  802d87:	53                   	push   %ebx
  802d88:	e8 0e fc ff ff       	call   80299b <fd_lookup>
  802d8d:	83 c4 10             	add    $0x10,%esp
  802d90:	85 c0                	test   %eax,%eax
  802d92:	78 34                	js     802dc8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d94:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802d97:	83 ec 08             	sub    $0x8,%esp
  802d9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d9d:	50                   	push   %eax
  802d9e:	ff 36                	push   (%esi)
  802da0:	e8 46 fc ff ff       	call   8029eb <dev_lookup>
  802da5:	83 c4 10             	add    $0x10,%esp
  802da8:	85 c0                	test   %eax,%eax
  802daa:	78 1c                	js     802dc8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802dac:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802db0:	74 1d                	je     802dcf <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db5:	8b 40 18             	mov    0x18(%eax),%eax
  802db8:	85 c0                	test   %eax,%eax
  802dba:	74 34                	je     802df0 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802dbc:	83 ec 08             	sub    $0x8,%esp
  802dbf:	ff 75 0c             	push   0xc(%ebp)
  802dc2:	56                   	push   %esi
  802dc3:	ff d0                	call   *%eax
  802dc5:	83 c4 10             	add    $0x10,%esp
}
  802dc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dcb:	5b                   	pop    %ebx
  802dcc:	5e                   	pop    %esi
  802dcd:	5d                   	pop    %ebp
  802dce:	c3                   	ret    
			thisenv->env_id, fdnum);
  802dcf:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802dd4:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802dd7:	83 ec 04             	sub    $0x4,%esp
  802dda:	53                   	push   %ebx
  802ddb:	50                   	push   %eax
  802ddc:	68 30 42 80 00       	push   $0x804230
  802de1:	e8 e7 ed ff ff       	call   801bcd <cprintf>
		return -E_INVAL;
  802de6:	83 c4 10             	add    $0x10,%esp
  802de9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802dee:	eb d8                	jmp    802dc8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  802df0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802df5:	eb d1                	jmp    802dc8 <ftruncate+0x50>

00802df7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802df7:	55                   	push   %ebp
  802df8:	89 e5                	mov    %esp,%ebp
  802dfa:	56                   	push   %esi
  802dfb:	53                   	push   %ebx
  802dfc:	83 ec 18             	sub    $0x18,%esp
  802dff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e05:	50                   	push   %eax
  802e06:	ff 75 08             	push   0x8(%ebp)
  802e09:	e8 8d fb ff ff       	call   80299b <fd_lookup>
  802e0e:	83 c4 10             	add    $0x10,%esp
  802e11:	85 c0                	test   %eax,%eax
  802e13:	78 49                	js     802e5e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e15:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802e18:	83 ec 08             	sub    $0x8,%esp
  802e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e1e:	50                   	push   %eax
  802e1f:	ff 36                	push   (%esi)
  802e21:	e8 c5 fb ff ff       	call   8029eb <dev_lookup>
  802e26:	83 c4 10             	add    $0x10,%esp
  802e29:	85 c0                	test   %eax,%eax
  802e2b:	78 31                	js     802e5e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  802e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e30:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e34:	74 2f                	je     802e65 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e36:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e39:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e40:	00 00 00 
	stat->st_isdir = 0;
  802e43:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e4a:	00 00 00 
	stat->st_dev = dev;
  802e4d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e53:	83 ec 08             	sub    $0x8,%esp
  802e56:	53                   	push   %ebx
  802e57:	56                   	push   %esi
  802e58:	ff 50 14             	call   *0x14(%eax)
  802e5b:	83 c4 10             	add    $0x10,%esp
}
  802e5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e61:	5b                   	pop    %ebx
  802e62:	5e                   	pop    %esi
  802e63:	5d                   	pop    %ebp
  802e64:	c3                   	ret    
		return -E_NOT_SUPP;
  802e65:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e6a:	eb f2                	jmp    802e5e <fstat+0x67>

00802e6c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e6c:	55                   	push   %ebp
  802e6d:	89 e5                	mov    %esp,%ebp
  802e6f:	56                   	push   %esi
  802e70:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e71:	83 ec 08             	sub    $0x8,%esp
  802e74:	6a 00                	push   $0x0
  802e76:	ff 75 08             	push   0x8(%ebp)
  802e79:	e8 e4 01 00 00       	call   803062 <open>
  802e7e:	89 c3                	mov    %eax,%ebx
  802e80:	83 c4 10             	add    $0x10,%esp
  802e83:	85 c0                	test   %eax,%eax
  802e85:	78 1b                	js     802ea2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e87:	83 ec 08             	sub    $0x8,%esp
  802e8a:	ff 75 0c             	push   0xc(%ebp)
  802e8d:	50                   	push   %eax
  802e8e:	e8 64 ff ff ff       	call   802df7 <fstat>
  802e93:	89 c6                	mov    %eax,%esi
	close(fd);
  802e95:	89 1c 24             	mov    %ebx,(%esp)
  802e98:	e8 26 fc ff ff       	call   802ac3 <close>
	return r;
  802e9d:	83 c4 10             	add    $0x10,%esp
  802ea0:	89 f3                	mov    %esi,%ebx
}
  802ea2:	89 d8                	mov    %ebx,%eax
  802ea4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ea7:	5b                   	pop    %ebx
  802ea8:	5e                   	pop    %esi
  802ea9:	5d                   	pop    %ebp
  802eaa:	c3                   	ret    

00802eab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802eab:	55                   	push   %ebp
  802eac:	89 e5                	mov    %esp,%ebp
  802eae:	56                   	push   %esi
  802eaf:	53                   	push   %ebx
  802eb0:	89 c6                	mov    %eax,%esi
  802eb2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802eb4:	83 3d 00 c0 80 00 00 	cmpl   $0x0,0x80c000
  802ebb:	74 27                	je     802ee4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ebd:	6a 07                	push   $0x7
  802ebf:	68 00 b0 80 00       	push   $0x80b000
  802ec4:	56                   	push   %esi
  802ec5:	ff 35 00 c0 80 00    	push   0x80c000
  802ecb:	e8 c7 f9 ff ff       	call   802897 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802ed0:	83 c4 0c             	add    $0xc,%esp
  802ed3:	6a 00                	push   $0x0
  802ed5:	53                   	push   %ebx
  802ed6:	6a 00                	push   $0x0
  802ed8:	e8 53 f9 ff ff       	call   802830 <ipc_recv>
}
  802edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ee0:	5b                   	pop    %ebx
  802ee1:	5e                   	pop    %esi
  802ee2:	5d                   	pop    %ebp
  802ee3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802ee4:	83 ec 0c             	sub    $0xc,%esp
  802ee7:	6a 01                	push   $0x1
  802ee9:	e8 fd f9 ff ff       	call   8028eb <ipc_find_env>
  802eee:	a3 00 c0 80 00       	mov    %eax,0x80c000
  802ef3:	83 c4 10             	add    $0x10,%esp
  802ef6:	eb c5                	jmp    802ebd <fsipc+0x12>

00802ef8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802ef8:	55                   	push   %ebp
  802ef9:	89 e5                	mov    %esp,%ebp
  802efb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802efe:	8b 45 08             	mov    0x8(%ebp),%eax
  802f01:	8b 40 0c             	mov    0xc(%eax),%eax
  802f04:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f09:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f0c:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f11:	ba 00 00 00 00       	mov    $0x0,%edx
  802f16:	b8 02 00 00 00       	mov    $0x2,%eax
  802f1b:	e8 8b ff ff ff       	call   802eab <fsipc>
}
  802f20:	c9                   	leave  
  802f21:	c3                   	ret    

00802f22 <devfile_flush>:
{
  802f22:	55                   	push   %ebp
  802f23:	89 e5                	mov    %esp,%ebp
  802f25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f28:	8b 45 08             	mov    0x8(%ebp),%eax
  802f2b:	8b 40 0c             	mov    0xc(%eax),%eax
  802f2e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f33:	ba 00 00 00 00       	mov    $0x0,%edx
  802f38:	b8 06 00 00 00       	mov    $0x6,%eax
  802f3d:	e8 69 ff ff ff       	call   802eab <fsipc>
}
  802f42:	c9                   	leave  
  802f43:	c3                   	ret    

00802f44 <devfile_stat>:
{
  802f44:	55                   	push   %ebp
  802f45:	89 e5                	mov    %esp,%ebp
  802f47:	53                   	push   %ebx
  802f48:	83 ec 04             	sub    $0x4,%esp
  802f4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  802f51:	8b 40 0c             	mov    0xc(%eax),%eax
  802f54:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f59:	ba 00 00 00 00       	mov    $0x0,%edx
  802f5e:	b8 05 00 00 00       	mov    $0x5,%eax
  802f63:	e8 43 ff ff ff       	call   802eab <fsipc>
  802f68:	85 c0                	test   %eax,%eax
  802f6a:	78 2c                	js     802f98 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f6c:	83 ec 08             	sub    $0x8,%esp
  802f6f:	68 00 b0 80 00       	push   $0x80b000
  802f74:	53                   	push   %ebx
  802f75:	e8 2d f2 ff ff       	call   8021a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f7a:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f85:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f90:	83 c4 10             	add    $0x10,%esp
  802f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f9b:	c9                   	leave  
  802f9c:	c3                   	ret    

00802f9d <devfile_write>:
{
  802f9d:	55                   	push   %ebp
  802f9e:	89 e5                	mov    %esp,%ebp
  802fa0:	83 ec 0c             	sub    $0xc,%esp
  802fa3:	8b 45 10             	mov    0x10(%ebp),%eax
  802fa6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802fab:	39 d0                	cmp    %edx,%eax
  802fad:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  802fb3:	8b 52 0c             	mov    0xc(%edx),%edx
  802fb6:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802fbc:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802fc1:	50                   	push   %eax
  802fc2:	ff 75 0c             	push   0xc(%ebp)
  802fc5:	68 08 b0 80 00       	push   $0x80b008
  802fca:	e8 6e f3 ff ff       	call   80233d <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  802fcf:	ba 00 00 00 00       	mov    $0x0,%edx
  802fd4:	b8 04 00 00 00       	mov    $0x4,%eax
  802fd9:	e8 cd fe ff ff       	call   802eab <fsipc>
}
  802fde:	c9                   	leave  
  802fdf:	c3                   	ret    

00802fe0 <devfile_read>:
{
  802fe0:	55                   	push   %ebp
  802fe1:	89 e5                	mov    %esp,%ebp
  802fe3:	56                   	push   %esi
  802fe4:	53                   	push   %ebx
  802fe5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  802feb:	8b 40 0c             	mov    0xc(%eax),%eax
  802fee:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802ff3:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  802ffe:	b8 03 00 00 00       	mov    $0x3,%eax
  803003:	e8 a3 fe ff ff       	call   802eab <fsipc>
  803008:	89 c3                	mov    %eax,%ebx
  80300a:	85 c0                	test   %eax,%eax
  80300c:	78 1f                	js     80302d <devfile_read+0x4d>
	assert(r <= n);
  80300e:	39 f0                	cmp    %esi,%eax
  803010:	77 24                	ja     803036 <devfile_read+0x56>
	assert(r <= PGSIZE);
  803012:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803017:	7f 33                	jg     80304c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803019:	83 ec 04             	sub    $0x4,%esp
  80301c:	50                   	push   %eax
  80301d:	68 00 b0 80 00       	push   $0x80b000
  803022:	ff 75 0c             	push   0xc(%ebp)
  803025:	e8 13 f3 ff ff       	call   80233d <memmove>
	return r;
  80302a:	83 c4 10             	add    $0x10,%esp
}
  80302d:	89 d8                	mov    %ebx,%eax
  80302f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803032:	5b                   	pop    %ebx
  803033:	5e                   	pop    %esi
  803034:	5d                   	pop    %ebp
  803035:	c3                   	ret    
	assert(r <= n);
  803036:	68 9c 42 80 00       	push   $0x80429c
  80303b:	68 9d 38 80 00       	push   $0x80389d
  803040:	6a 7c                	push   $0x7c
  803042:	68 a3 42 80 00       	push   $0x8042a3
  803047:	e8 a6 ea ff ff       	call   801af2 <_panic>
	assert(r <= PGSIZE);
  80304c:	68 ae 42 80 00       	push   $0x8042ae
  803051:	68 9d 38 80 00       	push   $0x80389d
  803056:	6a 7d                	push   $0x7d
  803058:	68 a3 42 80 00       	push   $0x8042a3
  80305d:	e8 90 ea ff ff       	call   801af2 <_panic>

00803062 <open>:
{
  803062:	55                   	push   %ebp
  803063:	89 e5                	mov    %esp,%ebp
  803065:	56                   	push   %esi
  803066:	53                   	push   %ebx
  803067:	83 ec 1c             	sub    $0x1c,%esp
  80306a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80306d:	56                   	push   %esi
  80306e:	e8 f9 f0 ff ff       	call   80216c <strlen>
  803073:	83 c4 10             	add    $0x10,%esp
  803076:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80307b:	7f 6c                	jg     8030e9 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80307d:	83 ec 0c             	sub    $0xc,%esp
  803080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803083:	50                   	push   %eax
  803084:	e8 c2 f8 ff ff       	call   80294b <fd_alloc>
  803089:	89 c3                	mov    %eax,%ebx
  80308b:	83 c4 10             	add    $0x10,%esp
  80308e:	85 c0                	test   %eax,%eax
  803090:	78 3c                	js     8030ce <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  803092:	83 ec 08             	sub    $0x8,%esp
  803095:	56                   	push   %esi
  803096:	68 00 b0 80 00       	push   $0x80b000
  80309b:	e8 07 f1 ff ff       	call   8021a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8030a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030a3:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8030a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8030b0:	e8 f6 fd ff ff       	call   802eab <fsipc>
  8030b5:	89 c3                	mov    %eax,%ebx
  8030b7:	83 c4 10             	add    $0x10,%esp
  8030ba:	85 c0                	test   %eax,%eax
  8030bc:	78 19                	js     8030d7 <open+0x75>
	return fd2num(fd);
  8030be:	83 ec 0c             	sub    $0xc,%esp
  8030c1:	ff 75 f4             	push   -0xc(%ebp)
  8030c4:	e8 5b f8 ff ff       	call   802924 <fd2num>
  8030c9:	89 c3                	mov    %eax,%ebx
  8030cb:	83 c4 10             	add    $0x10,%esp
}
  8030ce:	89 d8                	mov    %ebx,%eax
  8030d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030d3:	5b                   	pop    %ebx
  8030d4:	5e                   	pop    %esi
  8030d5:	5d                   	pop    %ebp
  8030d6:	c3                   	ret    
		fd_close(fd, 0);
  8030d7:	83 ec 08             	sub    $0x8,%esp
  8030da:	6a 00                	push   $0x0
  8030dc:	ff 75 f4             	push   -0xc(%ebp)
  8030df:	e8 58 f9 ff ff       	call   802a3c <fd_close>
		return r;
  8030e4:	83 c4 10             	add    $0x10,%esp
  8030e7:	eb e5                	jmp    8030ce <open+0x6c>
		return -E_BAD_PATH;
  8030e9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8030ee:	eb de                	jmp    8030ce <open+0x6c>

008030f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030f0:	55                   	push   %ebp
  8030f1:	89 e5                	mov    %esp,%ebp
  8030f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8030fb:	b8 08 00 00 00       	mov    $0x8,%eax
  803100:	e8 a6 fd ff ff       	call   802eab <fsipc>
}
  803105:	c9                   	leave  
  803106:	c3                   	ret    

00803107 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803107:	55                   	push   %ebp
  803108:	89 e5                	mov    %esp,%ebp
  80310a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80310d:	89 c2                	mov    %eax,%edx
  80310f:	c1 ea 16             	shr    $0x16,%edx
  803112:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  803119:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80311e:	f6 c1 01             	test   $0x1,%cl
  803121:	74 1c                	je     80313f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  803123:	c1 e8 0c             	shr    $0xc,%eax
  803126:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80312d:	a8 01                	test   $0x1,%al
  80312f:	74 0e                	je     80313f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803131:	c1 e8 0c             	shr    $0xc,%eax
  803134:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80313b:	ef 
  80313c:	0f b7 d2             	movzwl %dx,%edx
}
  80313f:	89 d0                	mov    %edx,%eax
  803141:	5d                   	pop    %ebp
  803142:	c3                   	ret    

00803143 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803143:	55                   	push   %ebp
  803144:	89 e5                	mov    %esp,%ebp
  803146:	56                   	push   %esi
  803147:	53                   	push   %ebx
  803148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80314b:	83 ec 0c             	sub    $0xc,%esp
  80314e:	ff 75 08             	push   0x8(%ebp)
  803151:	e8 de f7 ff ff       	call   802934 <fd2data>
  803156:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803158:	83 c4 08             	add    $0x8,%esp
  80315b:	68 ba 42 80 00       	push   $0x8042ba
  803160:	53                   	push   %ebx
  803161:	e8 41 f0 ff ff       	call   8021a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803166:	8b 46 04             	mov    0x4(%esi),%eax
  803169:	2b 06                	sub    (%esi),%eax
  80316b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803171:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803178:	00 00 00 
	stat->st_dev = &devpipe;
  80317b:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803182:	90 80 00 
	return 0;
}
  803185:	b8 00 00 00 00       	mov    $0x0,%eax
  80318a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80318d:	5b                   	pop    %ebx
  80318e:	5e                   	pop    %esi
  80318f:	5d                   	pop    %ebp
  803190:	c3                   	ret    

00803191 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803191:	55                   	push   %ebp
  803192:	89 e5                	mov    %esp,%ebp
  803194:	53                   	push   %ebx
  803195:	83 ec 0c             	sub    $0xc,%esp
  803198:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80319b:	53                   	push   %ebx
  80319c:	6a 00                	push   $0x0
  80319e:	e8 85 f4 ff ff       	call   802628 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8031a3:	89 1c 24             	mov    %ebx,(%esp)
  8031a6:	e8 89 f7 ff ff       	call   802934 <fd2data>
  8031ab:	83 c4 08             	add    $0x8,%esp
  8031ae:	50                   	push   %eax
  8031af:	6a 00                	push   $0x0
  8031b1:	e8 72 f4 ff ff       	call   802628 <sys_page_unmap>
}
  8031b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031b9:	c9                   	leave  
  8031ba:	c3                   	ret    

008031bb <_pipeisclosed>:
{
  8031bb:	55                   	push   %ebp
  8031bc:	89 e5                	mov    %esp,%ebp
  8031be:	57                   	push   %edi
  8031bf:	56                   	push   %esi
  8031c0:	53                   	push   %ebx
  8031c1:	83 ec 1c             	sub    $0x1c,%esp
  8031c4:	89 c7                	mov    %eax,%edi
  8031c6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8031c8:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8031cd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8031d0:	83 ec 0c             	sub    $0xc,%esp
  8031d3:	57                   	push   %edi
  8031d4:	e8 2e ff ff ff       	call   803107 <pageref>
  8031d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8031dc:	89 34 24             	mov    %esi,(%esp)
  8031df:	e8 23 ff ff ff       	call   803107 <pageref>
		nn = thisenv->env_runs;
  8031e4:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8031ea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8031ed:	83 c4 10             	add    $0x10,%esp
  8031f0:	39 cb                	cmp    %ecx,%ebx
  8031f2:	74 1b                	je     80320f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8031f4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8031f7:	75 cf                	jne    8031c8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8031f9:	8b 42 58             	mov    0x58(%edx),%eax
  8031fc:	6a 01                	push   $0x1
  8031fe:	50                   	push   %eax
  8031ff:	53                   	push   %ebx
  803200:	68 c1 42 80 00       	push   $0x8042c1
  803205:	e8 c3 e9 ff ff       	call   801bcd <cprintf>
  80320a:	83 c4 10             	add    $0x10,%esp
  80320d:	eb b9                	jmp    8031c8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80320f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803212:	0f 94 c0             	sete   %al
  803215:	0f b6 c0             	movzbl %al,%eax
}
  803218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80321b:	5b                   	pop    %ebx
  80321c:	5e                   	pop    %esi
  80321d:	5f                   	pop    %edi
  80321e:	5d                   	pop    %ebp
  80321f:	c3                   	ret    

00803220 <devpipe_write>:
{
  803220:	55                   	push   %ebp
  803221:	89 e5                	mov    %esp,%ebp
  803223:	57                   	push   %edi
  803224:	56                   	push   %esi
  803225:	53                   	push   %ebx
  803226:	83 ec 28             	sub    $0x28,%esp
  803229:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80322c:	56                   	push   %esi
  80322d:	e8 02 f7 ff ff       	call   802934 <fd2data>
  803232:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803234:	83 c4 10             	add    $0x10,%esp
  803237:	bf 00 00 00 00       	mov    $0x0,%edi
  80323c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80323f:	75 09                	jne    80324a <devpipe_write+0x2a>
	return i;
  803241:	89 f8                	mov    %edi,%eax
  803243:	eb 23                	jmp    803268 <devpipe_write+0x48>
			sys_yield();
  803245:	e8 3a f3 ff ff       	call   802584 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80324a:	8b 43 04             	mov    0x4(%ebx),%eax
  80324d:	8b 0b                	mov    (%ebx),%ecx
  80324f:	8d 51 20             	lea    0x20(%ecx),%edx
  803252:	39 d0                	cmp    %edx,%eax
  803254:	72 1a                	jb     803270 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  803256:	89 da                	mov    %ebx,%edx
  803258:	89 f0                	mov    %esi,%eax
  80325a:	e8 5c ff ff ff       	call   8031bb <_pipeisclosed>
  80325f:	85 c0                	test   %eax,%eax
  803261:	74 e2                	je     803245 <devpipe_write+0x25>
				return 0;
  803263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80326b:	5b                   	pop    %ebx
  80326c:	5e                   	pop    %esi
  80326d:	5f                   	pop    %edi
  80326e:	5d                   	pop    %ebp
  80326f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803273:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803277:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80327a:	89 c2                	mov    %eax,%edx
  80327c:	c1 fa 1f             	sar    $0x1f,%edx
  80327f:	89 d1                	mov    %edx,%ecx
  803281:	c1 e9 1b             	shr    $0x1b,%ecx
  803284:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803287:	83 e2 1f             	and    $0x1f,%edx
  80328a:	29 ca                	sub    %ecx,%edx
  80328c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803294:	83 c0 01             	add    $0x1,%eax
  803297:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80329a:	83 c7 01             	add    $0x1,%edi
  80329d:	eb 9d                	jmp    80323c <devpipe_write+0x1c>

0080329f <devpipe_read>:
{
  80329f:	55                   	push   %ebp
  8032a0:	89 e5                	mov    %esp,%ebp
  8032a2:	57                   	push   %edi
  8032a3:	56                   	push   %esi
  8032a4:	53                   	push   %ebx
  8032a5:	83 ec 18             	sub    $0x18,%esp
  8032a8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8032ab:	57                   	push   %edi
  8032ac:	e8 83 f6 ff ff       	call   802934 <fd2data>
  8032b1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8032b3:	83 c4 10             	add    $0x10,%esp
  8032b6:	be 00 00 00 00       	mov    $0x0,%esi
  8032bb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8032be:	75 13                	jne    8032d3 <devpipe_read+0x34>
	return i;
  8032c0:	89 f0                	mov    %esi,%eax
  8032c2:	eb 02                	jmp    8032c6 <devpipe_read+0x27>
				return i;
  8032c4:	89 f0                	mov    %esi,%eax
}
  8032c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032c9:	5b                   	pop    %ebx
  8032ca:	5e                   	pop    %esi
  8032cb:	5f                   	pop    %edi
  8032cc:	5d                   	pop    %ebp
  8032cd:	c3                   	ret    
			sys_yield();
  8032ce:	e8 b1 f2 ff ff       	call   802584 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8032d3:	8b 03                	mov    (%ebx),%eax
  8032d5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8032d8:	75 18                	jne    8032f2 <devpipe_read+0x53>
			if (i > 0)
  8032da:	85 f6                	test   %esi,%esi
  8032dc:	75 e6                	jne    8032c4 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8032de:	89 da                	mov    %ebx,%edx
  8032e0:	89 f8                	mov    %edi,%eax
  8032e2:	e8 d4 fe ff ff       	call   8031bb <_pipeisclosed>
  8032e7:	85 c0                	test   %eax,%eax
  8032e9:	74 e3                	je     8032ce <devpipe_read+0x2f>
				return 0;
  8032eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8032f0:	eb d4                	jmp    8032c6 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8032f2:	99                   	cltd   
  8032f3:	c1 ea 1b             	shr    $0x1b,%edx
  8032f6:	01 d0                	add    %edx,%eax
  8032f8:	83 e0 1f             	and    $0x1f,%eax
  8032fb:	29 d0                	sub    %edx,%eax
  8032fd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803305:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803308:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80330b:	83 c6 01             	add    $0x1,%esi
  80330e:	eb ab                	jmp    8032bb <devpipe_read+0x1c>

00803310 <pipe>:
{
  803310:	55                   	push   %ebp
  803311:	89 e5                	mov    %esp,%ebp
  803313:	56                   	push   %esi
  803314:	53                   	push   %ebx
  803315:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  803318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80331b:	50                   	push   %eax
  80331c:	e8 2a f6 ff ff       	call   80294b <fd_alloc>
  803321:	89 c3                	mov    %eax,%ebx
  803323:	83 c4 10             	add    $0x10,%esp
  803326:	85 c0                	test   %eax,%eax
  803328:	0f 88 23 01 00 00    	js     803451 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80332e:	83 ec 04             	sub    $0x4,%esp
  803331:	68 07 04 00 00       	push   $0x407
  803336:	ff 75 f4             	push   -0xc(%ebp)
  803339:	6a 00                	push   $0x0
  80333b:	e8 63 f2 ff ff       	call   8025a3 <sys_page_alloc>
  803340:	89 c3                	mov    %eax,%ebx
  803342:	83 c4 10             	add    $0x10,%esp
  803345:	85 c0                	test   %eax,%eax
  803347:	0f 88 04 01 00 00    	js     803451 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80334d:	83 ec 0c             	sub    $0xc,%esp
  803350:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803353:	50                   	push   %eax
  803354:	e8 f2 f5 ff ff       	call   80294b <fd_alloc>
  803359:	89 c3                	mov    %eax,%ebx
  80335b:	83 c4 10             	add    $0x10,%esp
  80335e:	85 c0                	test   %eax,%eax
  803360:	0f 88 db 00 00 00    	js     803441 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803366:	83 ec 04             	sub    $0x4,%esp
  803369:	68 07 04 00 00       	push   $0x407
  80336e:	ff 75 f0             	push   -0x10(%ebp)
  803371:	6a 00                	push   $0x0
  803373:	e8 2b f2 ff ff       	call   8025a3 <sys_page_alloc>
  803378:	89 c3                	mov    %eax,%ebx
  80337a:	83 c4 10             	add    $0x10,%esp
  80337d:	85 c0                	test   %eax,%eax
  80337f:	0f 88 bc 00 00 00    	js     803441 <pipe+0x131>
	va = fd2data(fd0);
  803385:	83 ec 0c             	sub    $0xc,%esp
  803388:	ff 75 f4             	push   -0xc(%ebp)
  80338b:	e8 a4 f5 ff ff       	call   802934 <fd2data>
  803390:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803392:	83 c4 0c             	add    $0xc,%esp
  803395:	68 07 04 00 00       	push   $0x407
  80339a:	50                   	push   %eax
  80339b:	6a 00                	push   $0x0
  80339d:	e8 01 f2 ff ff       	call   8025a3 <sys_page_alloc>
  8033a2:	89 c3                	mov    %eax,%ebx
  8033a4:	83 c4 10             	add    $0x10,%esp
  8033a7:	85 c0                	test   %eax,%eax
  8033a9:	0f 88 82 00 00 00    	js     803431 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033af:	83 ec 0c             	sub    $0xc,%esp
  8033b2:	ff 75 f0             	push   -0x10(%ebp)
  8033b5:	e8 7a f5 ff ff       	call   802934 <fd2data>
  8033ba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8033c1:	50                   	push   %eax
  8033c2:	6a 00                	push   $0x0
  8033c4:	56                   	push   %esi
  8033c5:	6a 00                	push   $0x0
  8033c7:	e8 1a f2 ff ff       	call   8025e6 <sys_page_map>
  8033cc:	89 c3                	mov    %eax,%ebx
  8033ce:	83 c4 20             	add    $0x20,%esp
  8033d1:	85 c0                	test   %eax,%eax
  8033d3:	78 4e                	js     803423 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8033d5:	a1 80 90 80 00       	mov    0x809080,%eax
  8033da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033dd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8033df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033e2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8033e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8033ec:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8033ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033f1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8033f8:	83 ec 0c             	sub    $0xc,%esp
  8033fb:	ff 75 f4             	push   -0xc(%ebp)
  8033fe:	e8 21 f5 ff ff       	call   802924 <fd2num>
  803403:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803406:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803408:	83 c4 04             	add    $0x4,%esp
  80340b:	ff 75 f0             	push   -0x10(%ebp)
  80340e:	e8 11 f5 ff ff       	call   802924 <fd2num>
  803413:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803416:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803419:	83 c4 10             	add    $0x10,%esp
  80341c:	bb 00 00 00 00       	mov    $0x0,%ebx
  803421:	eb 2e                	jmp    803451 <pipe+0x141>
	sys_page_unmap(0, va);
  803423:	83 ec 08             	sub    $0x8,%esp
  803426:	56                   	push   %esi
  803427:	6a 00                	push   $0x0
  803429:	e8 fa f1 ff ff       	call   802628 <sys_page_unmap>
  80342e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  803431:	83 ec 08             	sub    $0x8,%esp
  803434:	ff 75 f0             	push   -0x10(%ebp)
  803437:	6a 00                	push   $0x0
  803439:	e8 ea f1 ff ff       	call   802628 <sys_page_unmap>
  80343e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  803441:	83 ec 08             	sub    $0x8,%esp
  803444:	ff 75 f4             	push   -0xc(%ebp)
  803447:	6a 00                	push   $0x0
  803449:	e8 da f1 ff ff       	call   802628 <sys_page_unmap>
  80344e:	83 c4 10             	add    $0x10,%esp
}
  803451:	89 d8                	mov    %ebx,%eax
  803453:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803456:	5b                   	pop    %ebx
  803457:	5e                   	pop    %esi
  803458:	5d                   	pop    %ebp
  803459:	c3                   	ret    

0080345a <pipeisclosed>:
{
  80345a:	55                   	push   %ebp
  80345b:	89 e5                	mov    %esp,%ebp
  80345d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803463:	50                   	push   %eax
  803464:	ff 75 08             	push   0x8(%ebp)
  803467:	e8 2f f5 ff ff       	call   80299b <fd_lookup>
  80346c:	83 c4 10             	add    $0x10,%esp
  80346f:	85 c0                	test   %eax,%eax
  803471:	78 18                	js     80348b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  803473:	83 ec 0c             	sub    $0xc,%esp
  803476:	ff 75 f4             	push   -0xc(%ebp)
  803479:	e8 b6 f4 ff ff       	call   802934 <fd2data>
  80347e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  803480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803483:	e8 33 fd ff ff       	call   8031bb <_pipeisclosed>
  803488:	83 c4 10             	add    $0x10,%esp
}
  80348b:	c9                   	leave  
  80348c:	c3                   	ret    

0080348d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80348d:	b8 00 00 00 00       	mov    $0x0,%eax
  803492:	c3                   	ret    

00803493 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803493:	55                   	push   %ebp
  803494:	89 e5                	mov    %esp,%ebp
  803496:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803499:	68 d9 42 80 00       	push   $0x8042d9
  80349e:	ff 75 0c             	push   0xc(%ebp)
  8034a1:	e8 01 ed ff ff       	call   8021a7 <strcpy>
	return 0;
}
  8034a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8034ab:	c9                   	leave  
  8034ac:	c3                   	ret    

008034ad <devcons_write>:
{
  8034ad:	55                   	push   %ebp
  8034ae:	89 e5                	mov    %esp,%ebp
  8034b0:	57                   	push   %edi
  8034b1:	56                   	push   %esi
  8034b2:	53                   	push   %ebx
  8034b3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8034b9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8034be:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8034c4:	eb 2e                	jmp    8034f4 <devcons_write+0x47>
		m = n - tot;
  8034c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8034c9:	29 f3                	sub    %esi,%ebx
  8034cb:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8034d0:	39 c3                	cmp    %eax,%ebx
  8034d2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8034d5:	83 ec 04             	sub    $0x4,%esp
  8034d8:	53                   	push   %ebx
  8034d9:	89 f0                	mov    %esi,%eax
  8034db:	03 45 0c             	add    0xc(%ebp),%eax
  8034de:	50                   	push   %eax
  8034df:	57                   	push   %edi
  8034e0:	e8 58 ee ff ff       	call   80233d <memmove>
		sys_cputs(buf, m);
  8034e5:	83 c4 08             	add    $0x8,%esp
  8034e8:	53                   	push   %ebx
  8034e9:	57                   	push   %edi
  8034ea:	e8 f8 ef ff ff       	call   8024e7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8034ef:	01 de                	add    %ebx,%esi
  8034f1:	83 c4 10             	add    $0x10,%esp
  8034f4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8034f7:	72 cd                	jb     8034c6 <devcons_write+0x19>
}
  8034f9:	89 f0                	mov    %esi,%eax
  8034fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034fe:	5b                   	pop    %ebx
  8034ff:	5e                   	pop    %esi
  803500:	5f                   	pop    %edi
  803501:	5d                   	pop    %ebp
  803502:	c3                   	ret    

00803503 <devcons_read>:
{
  803503:	55                   	push   %ebp
  803504:	89 e5                	mov    %esp,%ebp
  803506:	83 ec 08             	sub    $0x8,%esp
  803509:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80350e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803512:	75 07                	jne    80351b <devcons_read+0x18>
  803514:	eb 1f                	jmp    803535 <devcons_read+0x32>
		sys_yield();
  803516:	e8 69 f0 ff ff       	call   802584 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80351b:	e8 e5 ef ff ff       	call   802505 <sys_cgetc>
  803520:	85 c0                	test   %eax,%eax
  803522:	74 f2                	je     803516 <devcons_read+0x13>
	if (c < 0)
  803524:	78 0f                	js     803535 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  803526:	83 f8 04             	cmp    $0x4,%eax
  803529:	74 0c                	je     803537 <devcons_read+0x34>
	*(char*)vbuf = c;
  80352b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80352e:	88 02                	mov    %al,(%edx)
	return 1;
  803530:	b8 01 00 00 00       	mov    $0x1,%eax
}
  803535:	c9                   	leave  
  803536:	c3                   	ret    
		return 0;
  803537:	b8 00 00 00 00       	mov    $0x0,%eax
  80353c:	eb f7                	jmp    803535 <devcons_read+0x32>

0080353e <cputchar>:
{
  80353e:	55                   	push   %ebp
  80353f:	89 e5                	mov    %esp,%ebp
  803541:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803544:	8b 45 08             	mov    0x8(%ebp),%eax
  803547:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80354a:	6a 01                	push   $0x1
  80354c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80354f:	50                   	push   %eax
  803550:	e8 92 ef ff ff       	call   8024e7 <sys_cputs>
}
  803555:	83 c4 10             	add    $0x10,%esp
  803558:	c9                   	leave  
  803559:	c3                   	ret    

0080355a <getchar>:
{
  80355a:	55                   	push   %ebp
  80355b:	89 e5                	mov    %esp,%ebp
  80355d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  803560:	6a 01                	push   $0x1
  803562:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803565:	50                   	push   %eax
  803566:	6a 00                	push   $0x0
  803568:	e8 92 f6 ff ff       	call   802bff <read>
	if (r < 0)
  80356d:	83 c4 10             	add    $0x10,%esp
  803570:	85 c0                	test   %eax,%eax
  803572:	78 06                	js     80357a <getchar+0x20>
	if (r < 1)
  803574:	74 06                	je     80357c <getchar+0x22>
	return c;
  803576:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80357a:	c9                   	leave  
  80357b:	c3                   	ret    
		return -E_EOF;
  80357c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  803581:	eb f7                	jmp    80357a <getchar+0x20>

00803583 <iscons>:
{
  803583:	55                   	push   %ebp
  803584:	89 e5                	mov    %esp,%ebp
  803586:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803589:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80358c:	50                   	push   %eax
  80358d:	ff 75 08             	push   0x8(%ebp)
  803590:	e8 06 f4 ff ff       	call   80299b <fd_lookup>
  803595:	83 c4 10             	add    $0x10,%esp
  803598:	85 c0                	test   %eax,%eax
  80359a:	78 11                	js     8035ad <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80359c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80359f:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035a5:	39 10                	cmp    %edx,(%eax)
  8035a7:	0f 94 c0             	sete   %al
  8035aa:	0f b6 c0             	movzbl %al,%eax
}
  8035ad:	c9                   	leave  
  8035ae:	c3                   	ret    

008035af <opencons>:
{
  8035af:	55                   	push   %ebp
  8035b0:	89 e5                	mov    %esp,%ebp
  8035b2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8035b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035b8:	50                   	push   %eax
  8035b9:	e8 8d f3 ff ff       	call   80294b <fd_alloc>
  8035be:	83 c4 10             	add    $0x10,%esp
  8035c1:	85 c0                	test   %eax,%eax
  8035c3:	78 3a                	js     8035ff <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035c5:	83 ec 04             	sub    $0x4,%esp
  8035c8:	68 07 04 00 00       	push   $0x407
  8035cd:	ff 75 f4             	push   -0xc(%ebp)
  8035d0:	6a 00                	push   $0x0
  8035d2:	e8 cc ef ff ff       	call   8025a3 <sys_page_alloc>
  8035d7:	83 c4 10             	add    $0x10,%esp
  8035da:	85 c0                	test   %eax,%eax
  8035dc:	78 21                	js     8035ff <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8035de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e1:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035e7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8035e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035ec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8035f3:	83 ec 0c             	sub    $0xc,%esp
  8035f6:	50                   	push   %eax
  8035f7:	e8 28 f3 ff ff       	call   802924 <fd2num>
  8035fc:	83 c4 10             	add    $0x10,%esp
}
  8035ff:	c9                   	leave  
  803600:	c3                   	ret    
  803601:	66 90                	xchg   %ax,%ax
  803603:	66 90                	xchg   %ax,%ax
  803605:	66 90                	xchg   %ax,%ax
  803607:	66 90                	xchg   %ax,%ax
  803609:	66 90                	xchg   %ax,%ax
  80360b:	66 90                	xchg   %ax,%ax
  80360d:	66 90                	xchg   %ax,%ax
  80360f:	90                   	nop

00803610 <__udivdi3>:
  803610:	f3 0f 1e fb          	endbr32 
  803614:	55                   	push   %ebp
  803615:	57                   	push   %edi
  803616:	56                   	push   %esi
  803617:	53                   	push   %ebx
  803618:	83 ec 1c             	sub    $0x1c,%esp
  80361b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80361f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803623:	8b 74 24 34          	mov    0x34(%esp),%esi
  803627:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80362b:	85 c0                	test   %eax,%eax
  80362d:	75 19                	jne    803648 <__udivdi3+0x38>
  80362f:	39 f3                	cmp    %esi,%ebx
  803631:	76 4d                	jbe    803680 <__udivdi3+0x70>
  803633:	31 ff                	xor    %edi,%edi
  803635:	89 e8                	mov    %ebp,%eax
  803637:	89 f2                	mov    %esi,%edx
  803639:	f7 f3                	div    %ebx
  80363b:	89 fa                	mov    %edi,%edx
  80363d:	83 c4 1c             	add    $0x1c,%esp
  803640:	5b                   	pop    %ebx
  803641:	5e                   	pop    %esi
  803642:	5f                   	pop    %edi
  803643:	5d                   	pop    %ebp
  803644:	c3                   	ret    
  803645:	8d 76 00             	lea    0x0(%esi),%esi
  803648:	39 f0                	cmp    %esi,%eax
  80364a:	76 14                	jbe    803660 <__udivdi3+0x50>
  80364c:	31 ff                	xor    %edi,%edi
  80364e:	31 c0                	xor    %eax,%eax
  803650:	89 fa                	mov    %edi,%edx
  803652:	83 c4 1c             	add    $0x1c,%esp
  803655:	5b                   	pop    %ebx
  803656:	5e                   	pop    %esi
  803657:	5f                   	pop    %edi
  803658:	5d                   	pop    %ebp
  803659:	c3                   	ret    
  80365a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803660:	0f bd f8             	bsr    %eax,%edi
  803663:	83 f7 1f             	xor    $0x1f,%edi
  803666:	75 48                	jne    8036b0 <__udivdi3+0xa0>
  803668:	39 f0                	cmp    %esi,%eax
  80366a:	72 06                	jb     803672 <__udivdi3+0x62>
  80366c:	31 c0                	xor    %eax,%eax
  80366e:	39 eb                	cmp    %ebp,%ebx
  803670:	77 de                	ja     803650 <__udivdi3+0x40>
  803672:	b8 01 00 00 00       	mov    $0x1,%eax
  803677:	eb d7                	jmp    803650 <__udivdi3+0x40>
  803679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803680:	89 d9                	mov    %ebx,%ecx
  803682:	85 db                	test   %ebx,%ebx
  803684:	75 0b                	jne    803691 <__udivdi3+0x81>
  803686:	b8 01 00 00 00       	mov    $0x1,%eax
  80368b:	31 d2                	xor    %edx,%edx
  80368d:	f7 f3                	div    %ebx
  80368f:	89 c1                	mov    %eax,%ecx
  803691:	31 d2                	xor    %edx,%edx
  803693:	89 f0                	mov    %esi,%eax
  803695:	f7 f1                	div    %ecx
  803697:	89 c6                	mov    %eax,%esi
  803699:	89 e8                	mov    %ebp,%eax
  80369b:	89 f7                	mov    %esi,%edi
  80369d:	f7 f1                	div    %ecx
  80369f:	89 fa                	mov    %edi,%edx
  8036a1:	83 c4 1c             	add    $0x1c,%esp
  8036a4:	5b                   	pop    %ebx
  8036a5:	5e                   	pop    %esi
  8036a6:	5f                   	pop    %edi
  8036a7:	5d                   	pop    %ebp
  8036a8:	c3                   	ret    
  8036a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036b0:	89 f9                	mov    %edi,%ecx
  8036b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8036b7:	29 fa                	sub    %edi,%edx
  8036b9:	d3 e0                	shl    %cl,%eax
  8036bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8036bf:	89 d1                	mov    %edx,%ecx
  8036c1:	89 d8                	mov    %ebx,%eax
  8036c3:	d3 e8                	shr    %cl,%eax
  8036c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8036c9:	09 c1                	or     %eax,%ecx
  8036cb:	89 f0                	mov    %esi,%eax
  8036cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8036d1:	89 f9                	mov    %edi,%ecx
  8036d3:	d3 e3                	shl    %cl,%ebx
  8036d5:	89 d1                	mov    %edx,%ecx
  8036d7:	d3 e8                	shr    %cl,%eax
  8036d9:	89 f9                	mov    %edi,%ecx
  8036db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8036df:	89 eb                	mov    %ebp,%ebx
  8036e1:	d3 e6                	shl    %cl,%esi
  8036e3:	89 d1                	mov    %edx,%ecx
  8036e5:	d3 eb                	shr    %cl,%ebx
  8036e7:	09 f3                	or     %esi,%ebx
  8036e9:	89 c6                	mov    %eax,%esi
  8036eb:	89 f2                	mov    %esi,%edx
  8036ed:	89 d8                	mov    %ebx,%eax
  8036ef:	f7 74 24 08          	divl   0x8(%esp)
  8036f3:	89 d6                	mov    %edx,%esi
  8036f5:	89 c3                	mov    %eax,%ebx
  8036f7:	f7 64 24 0c          	mull   0xc(%esp)
  8036fb:	39 d6                	cmp    %edx,%esi
  8036fd:	72 19                	jb     803718 <__udivdi3+0x108>
  8036ff:	89 f9                	mov    %edi,%ecx
  803701:	d3 e5                	shl    %cl,%ebp
  803703:	39 c5                	cmp    %eax,%ebp
  803705:	73 04                	jae    80370b <__udivdi3+0xfb>
  803707:	39 d6                	cmp    %edx,%esi
  803709:	74 0d                	je     803718 <__udivdi3+0x108>
  80370b:	89 d8                	mov    %ebx,%eax
  80370d:	31 ff                	xor    %edi,%edi
  80370f:	e9 3c ff ff ff       	jmp    803650 <__udivdi3+0x40>
  803714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803718:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80371b:	31 ff                	xor    %edi,%edi
  80371d:	e9 2e ff ff ff       	jmp    803650 <__udivdi3+0x40>
  803722:	66 90                	xchg   %ax,%ax
  803724:	66 90                	xchg   %ax,%ax
  803726:	66 90                	xchg   %ax,%ax
  803728:	66 90                	xchg   %ax,%ax
  80372a:	66 90                	xchg   %ax,%ax
  80372c:	66 90                	xchg   %ax,%ax
  80372e:	66 90                	xchg   %ax,%ax

00803730 <__umoddi3>:
  803730:	f3 0f 1e fb          	endbr32 
  803734:	55                   	push   %ebp
  803735:	57                   	push   %edi
  803736:	56                   	push   %esi
  803737:	53                   	push   %ebx
  803738:	83 ec 1c             	sub    $0x1c,%esp
  80373b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80373f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803743:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  803747:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80374b:	89 f0                	mov    %esi,%eax
  80374d:	89 da                	mov    %ebx,%edx
  80374f:	85 ff                	test   %edi,%edi
  803751:	75 15                	jne    803768 <__umoddi3+0x38>
  803753:	39 dd                	cmp    %ebx,%ebp
  803755:	76 39                	jbe    803790 <__umoddi3+0x60>
  803757:	f7 f5                	div    %ebp
  803759:	89 d0                	mov    %edx,%eax
  80375b:	31 d2                	xor    %edx,%edx
  80375d:	83 c4 1c             	add    $0x1c,%esp
  803760:	5b                   	pop    %ebx
  803761:	5e                   	pop    %esi
  803762:	5f                   	pop    %edi
  803763:	5d                   	pop    %ebp
  803764:	c3                   	ret    
  803765:	8d 76 00             	lea    0x0(%esi),%esi
  803768:	39 df                	cmp    %ebx,%edi
  80376a:	77 f1                	ja     80375d <__umoddi3+0x2d>
  80376c:	0f bd cf             	bsr    %edi,%ecx
  80376f:	83 f1 1f             	xor    $0x1f,%ecx
  803772:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803776:	75 40                	jne    8037b8 <__umoddi3+0x88>
  803778:	39 df                	cmp    %ebx,%edi
  80377a:	72 04                	jb     803780 <__umoddi3+0x50>
  80377c:	39 f5                	cmp    %esi,%ebp
  80377e:	77 dd                	ja     80375d <__umoddi3+0x2d>
  803780:	89 da                	mov    %ebx,%edx
  803782:	89 f0                	mov    %esi,%eax
  803784:	29 e8                	sub    %ebp,%eax
  803786:	19 fa                	sbb    %edi,%edx
  803788:	eb d3                	jmp    80375d <__umoddi3+0x2d>
  80378a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803790:	89 e9                	mov    %ebp,%ecx
  803792:	85 ed                	test   %ebp,%ebp
  803794:	75 0b                	jne    8037a1 <__umoddi3+0x71>
  803796:	b8 01 00 00 00       	mov    $0x1,%eax
  80379b:	31 d2                	xor    %edx,%edx
  80379d:	f7 f5                	div    %ebp
  80379f:	89 c1                	mov    %eax,%ecx
  8037a1:	89 d8                	mov    %ebx,%eax
  8037a3:	31 d2                	xor    %edx,%edx
  8037a5:	f7 f1                	div    %ecx
  8037a7:	89 f0                	mov    %esi,%eax
  8037a9:	f7 f1                	div    %ecx
  8037ab:	89 d0                	mov    %edx,%eax
  8037ad:	31 d2                	xor    %edx,%edx
  8037af:	eb ac                	jmp    80375d <__umoddi3+0x2d>
  8037b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8037bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8037c1:	29 c2                	sub    %eax,%edx
  8037c3:	89 c1                	mov    %eax,%ecx
  8037c5:	89 e8                	mov    %ebp,%eax
  8037c7:	d3 e7                	shl    %cl,%edi
  8037c9:	89 d1                	mov    %edx,%ecx
  8037cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8037cf:	d3 e8                	shr    %cl,%eax
  8037d1:	89 c1                	mov    %eax,%ecx
  8037d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8037d7:	09 f9                	or     %edi,%ecx
  8037d9:	89 df                	mov    %ebx,%edi
  8037db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8037df:	89 c1                	mov    %eax,%ecx
  8037e1:	d3 e5                	shl    %cl,%ebp
  8037e3:	89 d1                	mov    %edx,%ecx
  8037e5:	d3 ef                	shr    %cl,%edi
  8037e7:	89 c1                	mov    %eax,%ecx
  8037e9:	89 f0                	mov    %esi,%eax
  8037eb:	d3 e3                	shl    %cl,%ebx
  8037ed:	89 d1                	mov    %edx,%ecx
  8037ef:	89 fa                	mov    %edi,%edx
  8037f1:	d3 e8                	shr    %cl,%eax
  8037f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8037f8:	09 d8                	or     %ebx,%eax
  8037fa:	f7 74 24 08          	divl   0x8(%esp)
  8037fe:	89 d3                	mov    %edx,%ebx
  803800:	d3 e6                	shl    %cl,%esi
  803802:	f7 e5                	mul    %ebp
  803804:	89 c7                	mov    %eax,%edi
  803806:	89 d1                	mov    %edx,%ecx
  803808:	39 d3                	cmp    %edx,%ebx
  80380a:	72 06                	jb     803812 <__umoddi3+0xe2>
  80380c:	75 0e                	jne    80381c <__umoddi3+0xec>
  80380e:	39 c6                	cmp    %eax,%esi
  803810:	73 0a                	jae    80381c <__umoddi3+0xec>
  803812:	29 e8                	sub    %ebp,%eax
  803814:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803818:	89 d1                	mov    %edx,%ecx
  80381a:	89 c7                	mov    %eax,%edi
  80381c:	89 f5                	mov    %esi,%ebp
  80381e:	8b 74 24 04          	mov    0x4(%esp),%esi
  803822:	29 fd                	sub    %edi,%ebp
  803824:	19 cb                	sbb    %ecx,%ebx
  803826:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80382b:	89 d8                	mov    %ebx,%eax
  80382d:	d3 e0                	shl    %cl,%eax
  80382f:	89 f1                	mov    %esi,%ecx
  803831:	d3 ed                	shr    %cl,%ebp
  803833:	d3 eb                	shr    %cl,%ebx
  803835:	09 e8                	or     %ebp,%eax
  803837:	89 da                	mov    %ebx,%edx
  803839:	83 c4 1c             	add    $0x1c,%esp
  80383c:	5b                   	pop    %ebx
  80383d:	5e                   	pop    %esi
  80383e:	5f                   	pop    %edi
  80383f:	5d                   	pop    %ebp
  803840:	c3                   	ret    
