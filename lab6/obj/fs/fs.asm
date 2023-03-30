
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
  80002c:	e8 5c 1a 00 00       	call   801a8d <libmain>
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
  8000b4:	68 20 3d 80 00       	push   $0x803d20
  8000b9:	e8 0a 1b 00 00       	call   801bc8 <cprintf>
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
  8000dd:	68 37 3d 80 00       	push   $0x803d37
  8000e2:	6a 3a                	push   $0x3a
  8000e4:	68 47 3d 80 00       	push   $0x803d47
  8000e9:	e8 ff 19 00 00       	call   801aed <_panic>

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
  800193:	68 50 3d 80 00       	push   $0x803d50
  800198:	68 5d 3d 80 00       	push   $0x803d5d
  80019d:	6a 44                	push   $0x44
  80019f:	68 47 3d 80 00       	push   $0x803d47
  8001a4:	e8 44 19 00 00       	call   801aed <_panic>
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
  80025b:	68 50 3d 80 00       	push   $0x803d50
  800260:	68 5d 3d 80 00       	push   $0x803d5d
  800265:	6a 5d                	push   $0x5d
  800267:	68 47 3d 80 00       	push   $0x803d47
  80026c:	e8 7c 18 00 00       	call   801aed <_panic>
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
  8002c1:	e8 d8 22 00 00       	call   80259e <sys_page_alloc>
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
  80030a:	e8 d2 22 00 00       	call   8025e1 <sys_page_map>
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
  800340:	68 74 3d 80 00       	push   $0x803d74
  800345:	6a 27                	push   $0x27
  800347:	68 50 3e 80 00       	push   $0x803e50
  80034c:	e8 9c 17 00 00       	call   801aed <_panic>
		panic("reading non-existent block %08x\n", blockno);
  800351:	56                   	push   %esi
  800352:	68 a4 3d 80 00       	push   $0x803da4
  800357:	6a 2c                	push   $0x2c
  800359:	68 50 3e 80 00       	push   $0x803e50
  80035e:	e8 8a 17 00 00       	call   801aed <_panic>
		panic("bc_pgfault, sys_page_alloc: %e", r);
  800363:	50                   	push   %eax
  800364:	68 c8 3d 80 00       	push   $0x803dc8
  800369:	6a 36                	push   $0x36
  80036b:	68 50 3e 80 00       	push   $0x803e50
  800370:	e8 78 17 00 00       	call   801aed <_panic>
	if( r= ide_read(blockno * BLKSECTS , addr, BLKSECTS)<0 ) panic("bc_pgfault, ide_read: %e", r);
  800375:	6a 01                	push   $0x1
  800377:	68 58 3e 80 00       	push   $0x803e58
  80037c:	6a 38                	push   $0x38
  80037e:	68 50 3e 80 00       	push   $0x803e50
  800383:	e8 65 17 00 00       	call   801aed <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800388:	50                   	push   %eax
  800389:	68 e8 3d 80 00       	push   $0x803de8
  80038e:	6a 3d                	push   $0x3d
  800390:	68 50 3e 80 00       	push   $0x803e50
  800395:	e8 53 17 00 00       	call   801aed <_panic>
		panic("reading free block %08x\n", blockno);
  80039a:	56                   	push   %esi
  80039b:	68 71 3e 80 00       	push   $0x803e71
  8003a0:	6a 43                	push   $0x43
  8003a2:	68 50 3e 80 00       	push   $0x803e50
  8003a7:	e8 41 17 00 00       	call   801aed <_panic>

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
  8003d3:	68 08 3e 80 00       	push   $0x803e08
  8003d8:	6a 0a                	push   $0xa
  8003da:	68 50 3e 80 00       	push   $0x803e50
  8003df:	e8 09 17 00 00       	call   801aed <_panic>

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
  80045f:	68 8a 3e 80 00       	push   $0x803e8a
  800464:	6a 53                	push   $0x53
  800466:	68 50 3e 80 00       	push   $0x803e50
  80046b:	e8 7d 16 00 00       	call   801aed <_panic>
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
  8004a7:	e8 35 21 00 00       	call   8025e1 <sys_page_map>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 a4                	jns    800457 <flush_block+0x2d>
			panic("flush_block, sys_page_map: %e", r);
  8004b3:	50                   	push   %eax
  8004b4:	68 c0 3e 80 00       	push   $0x803ec0
  8004b9:	6a 5e                	push   $0x5e
  8004bb:	68 50 3e 80 00       	push   $0x803e50
  8004c0:	e8 28 16 00 00       	call   801aed <_panic>
			panic("flush_block, ide_write: %e", r);
  8004c5:	50                   	push   %eax
  8004c6:	68 a5 3e 80 00       	push   $0x803ea5
  8004cb:	6a 5b                	push   $0x5b
  8004cd:	68 50 3e 80 00       	push   $0x803e50
  8004d2:	e8 16 16 00 00       	call   801aed <_panic>

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
  8004e6:	e8 05 23 00 00       	call   8027f0 <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  8004eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f2:	e8 b5 fe ff ff       	call   8003ac <diskaddr>
  8004f7:	83 c4 0c             	add    $0xc,%esp
  8004fa:	68 08 01 00 00       	push   $0x108
  8004ff:	50                   	push   %eax
  800500:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800506:	50                   	push   %eax
  800507:	e8 2c 1e 00 00       	call   802338 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80050c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800513:	e8 94 fe ff ff       	call   8003ac <diskaddr>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	68 de 3e 80 00       	push   $0x803ede
  800520:	50                   	push   %eax
  800521:	e8 7c 1c 00 00       	call   8021a2 <strcpy>
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
  800586:	e8 98 20 00 00       	call   802623 <sys_page_unmap>
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
  8005b7:	68 de 3e 80 00       	push   $0x803ede
  8005bc:	50                   	push   %eax
  8005bd:	e8 91 1c 00 00       	call   802253 <strcmp>
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
  8005e7:	e8 4c 1d 00 00       	call   802338 <memmove>
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
  800616:	e8 1d 1d 00 00       	call   802338 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80061b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800622:	e8 85 fd ff ff       	call   8003ac <diskaddr>
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	68 de 3e 80 00       	push   $0x803ede
  80062f:	50                   	push   %eax
  800630:	e8 6d 1b 00 00       	call   8021a2 <strcpy>
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
  80067b:	e8 a3 1f 00 00       	call   802623 <sys_page_unmap>
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
  8006ac:	68 de 3e 80 00       	push   $0x803ede
  8006b1:	50                   	push   %eax
  8006b2:	e8 9c 1b 00 00       	call   802253 <strcmp>
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
  8006dc:	e8 57 1c 00 00       	call   802338 <memmove>
	flush_block(diskaddr(1));
  8006e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e8:	e8 bf fc ff ff       	call   8003ac <diskaddr>
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	e8 35 fd ff ff       	call   80042a <flush_block>
	cprintf("block cache is good\n");
  8006f5:	c7 04 24 1a 3f 80 00 	movl   $0x803f1a,(%esp)
  8006fc:	e8 c7 14 00 00       	call   801bc8 <cprintf>
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
  80071d:	e8 16 1c 00 00       	call   802338 <memmove>
}
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800728:	c9                   	leave  
  800729:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  80072a:	68 00 3f 80 00       	push   $0x803f00
  80072f:	68 5d 3d 80 00       	push   $0x803d5d
  800734:	6a 6f                	push   $0x6f
  800736:	68 50 3e 80 00       	push   $0x803e50
  80073b:	e8 ad 13 00 00       	call   801aed <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800740:	68 e5 3e 80 00       	push   $0x803ee5
  800745:	68 5d 3d 80 00       	push   $0x803d5d
  80074a:	6a 70                	push   $0x70
  80074c:	68 50 3e 80 00       	push   $0x803e50
  800751:	e8 97 13 00 00       	call   801aed <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800756:	68 ff 3e 80 00       	push   $0x803eff
  80075b:	68 5d 3d 80 00       	push   $0x803d5d
  800760:	6a 74                	push   $0x74
  800762:	68 50 3e 80 00       	push   $0x803e50
  800767:	e8 81 13 00 00       	call   801aed <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80076c:	68 2c 3e 80 00       	push   $0x803e2c
  800771:	68 5d 3d 80 00       	push   $0x803d5d
  800776:	6a 77                	push   $0x77
  800778:	68 50 3e 80 00       	push   $0x803e50
  80077d:	e8 6b 13 00 00       	call   801aed <_panic>
	assert(va_is_mapped(diskaddr(1)));
  800782:	68 00 3f 80 00       	push   $0x803f00
  800787:	68 5d 3d 80 00       	push   $0x803d5d
  80078c:	68 88 00 00 00       	push   $0x88
  800791:	68 50 3e 80 00       	push   $0x803e50
  800796:	e8 52 13 00 00       	call   801aed <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  80079b:	68 ff 3e 80 00       	push   $0x803eff
  8007a0:	68 5d 3d 80 00       	push   $0x803d5d
  8007a5:	68 90 00 00 00       	push   $0x90
  8007aa:	68 50 3e 80 00       	push   $0x803e50
  8007af:	e8 39 13 00 00       	call   801aed <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007b4:	68 2c 3e 80 00       	push   $0x803e2c
  8007b9:	68 5d 3d 80 00       	push   $0x803d5d
  8007be:	68 93 00 00 00       	push   $0x93
  8007c3:	68 50 3e 80 00       	push   $0x803e50
  8007c8:	e8 20 13 00 00       	call   801aed <_panic>

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
  8007ec:	68 6d 3f 80 00       	push   $0x803f6d
  8007f1:	e8 d2 13 00 00       	call   801bc8 <cprintf>
}
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
		panic("bad file system magic number");
  8007fb:	83 ec 04             	sub    $0x4,%esp
  8007fe:	68 2f 3f 80 00       	push   $0x803f2f
  800803:	6a 12                	push   $0x12
  800805:	68 4c 3f 80 00       	push   $0x803f4c
  80080a:	e8 de 12 00 00       	call   801aed <_panic>
		panic("file system is too large");
  80080f:	83 ec 04             	sub    $0x4,%esp
  800812:	68 54 3f 80 00       	push   $0x803f54
  800817:	6a 15                	push   $0x15
  800819:	68 4c 3f 80 00       	push   $0x803f4c
  80081e:	e8 ca 12 00 00       	call   801aed <_panic>

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
  80088e:	68 81 3f 80 00       	push   $0x803f81
  800893:	6a 30                	push   $0x30
  800895:	68 4c 3f 80 00       	push   $0x803f4c
  80089a:	e8 4e 12 00 00       	call   801aed <_panic>

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
  80095e:	e8 8f 19 00 00       	call   8022f2 <memset>
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
  8009f4:	68 9c 3f 80 00       	push   $0x803f9c
  8009f9:	68 5d 3d 80 00       	push   $0x803d5d
  8009fe:	6a 5a                	push   $0x5a
  800a00:	68 4c 3f 80 00       	push   $0x803f4c
  800a05:	e8 e3 10 00 00       	call   801aed <_panic>
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
  800a2f:	68 d4 3f 80 00       	push   $0x803fd4
  800a34:	e8 8f 11 00 00       	call   801bc8 <cprintf>
}
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
	assert(!block_is_free(0));
  800a43:	68 b0 3f 80 00       	push   $0x803fb0
  800a48:	68 5d 3d 80 00       	push   $0x803d5d
  800a4d:	6a 5d                	push   $0x5d
  800a4f:	68 4c 3f 80 00       	push   $0x803f4c
  800a54:	e8 94 10 00 00       	call   801aed <_panic>
	assert(!block_is_free(1));
  800a59:	68 c2 3f 80 00       	push   $0x803fc2
  800a5e:	68 5d 3d 80 00       	push   $0x803d5d
  800a63:	6a 5e                	push   $0x5e
  800a65:	68 4c 3f 80 00       	push   $0x803f4c
  800a6a:	e8 7e 10 00 00       	call   801aed <_panic>

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
  800b1f:	e8 ce 17 00 00       	call   8022f2 <memset>
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
  800bdd:	e8 56 17 00 00       	call   802338 <memmove>
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
  800c8f:	e8 bf 15 00 00       	call   802253 <strcmp>
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
  800cb2:	68 e4 3f 80 00       	push   $0x803fe4
  800cb7:	68 5d 3d 80 00       	push   $0x803d5d
  800cbc:	68 da 00 00 00       	push   $0xda
  800cc1:	68 4c 3f 80 00       	push   $0x803f4c
  800cc6:	e8 22 0e 00 00       	call   801aed <_panic>
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
  800d00:	e8 9d 14 00 00       	call   8021a2 <strcpy>
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
  800e26:	e8 0d 15 00 00       	call   802338 <memmove>
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
  800ed4:	68 01 40 80 00       	push   $0x804001
  800ed9:	e8 ea 0c 00 00       	call   801bc8 <cprintf>
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
  800f94:	e8 9f 13 00 00       	call   802338 <memmove>
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
  801108:	68 e4 3f 80 00       	push   $0x803fe4
  80110d:	68 5d 3d 80 00       	push   $0x803d5d
  801112:	68 f3 00 00 00       	push   $0xf3
  801117:	68 4c 3f 80 00       	push   $0x803f4c
  80111c:	e8 cc 09 00 00       	call   801aed <_panic>
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
  80115f:	e8 3e 10 00 00       	call   8021a2 <strcpy>
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
  80120e:	e8 55 1f 00 00       	call   803168 <pageref>
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
  801243:	e8 56 13 00 00       	call   80259e <sys_page_alloc>
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
  801274:	e8 79 10 00 00       	call   8022f2 <memset>
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
  8012ad:	e8 b6 1e 00 00       	call   803168 <pageref>
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
  8013dc:	e8 c1 0d 00 00       	call   8021a2 <strcpy>
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
  801465:	e8 ce 0e 00 00       	call   802338 <memmove>
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
  80158c:	68 20 40 80 00       	push   $0x804020
  801591:	e8 32 06 00 00       	call   801bc8 <cprintf>
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
  8015ab:	e8 dc 12 00 00       	call   80288c <ipc_recv>
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
  801607:	68 50 40 80 00       	push   $0x804050
  80160c:	e8 b7 05 00 00       	call   801bc8 <cprintf>
  801611:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801614:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801619:	ff 75 f0             	push   -0x10(%ebp)
  80161c:	ff 75 ec             	push   -0x14(%ebp)
  80161f:	50                   	push   %eax
  801620:	ff 75 f4             	push   -0xc(%ebp)
  801623:	e8 cb 12 00 00       	call   8028f3 <ipc_send>
		sys_page_unmap(0, fsreq);
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	ff 35 44 50 80 00    	push   0x805044
  801631:	6a 00                	push   $0x0
  801633:	e8 eb 0f 00 00       	call   802623 <sys_page_unmap>
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
  801646:	c7 05 60 90 80 00 73 	movl   $0x804073,0x809060
  80164d:	40 80 00 
	cprintf("FS is running\n");
  801650:	68 76 40 80 00       	push   $0x804076
  801655:	e8 6e 05 00 00       	call   801bc8 <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80165a:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80165f:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801664:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801666:	c7 04 24 85 40 80 00 	movl   $0x804085,(%esp)
  80166d:	e8 56 05 00 00       	call   801bc8 <cprintf>

	serve_init();
  801672:	e8 50 fb ff ff       	call   8011c7 <serve_init>
	fs_init();
  801677:	e8 f3 f3 ff ff       	call   800a6f <fs_init>
	serve();
  80167c:	e8 f5 fe ff ff       	call   801576 <serve>

00801681 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801687:	6a 07                	push   $0x7
  801689:	68 00 10 00 00       	push   $0x1000
  80168e:	6a 00                	push   $0x0
  801690:	e8 09 0f 00 00       	call   80259e <sys_page_alloc>
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	0f 88 59 02 00 00    	js     8018f9 <fs_test+0x278>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	68 00 10 00 00       	push   $0x1000
  8016a8:	ff 35 00 a0 80 00    	push   0x80a000
  8016ae:	68 00 10 00 00       	push   $0x1000
  8016b3:	e8 80 0c 00 00       	call   802338 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016b8:	e8 e2 f1 ff ff       	call   80089f <alloc_block>
  8016bd:	89 c1                	mov    %eax,%ecx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	0f 88 41 02 00 00    	js     80190b <fs_test+0x28a>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016ca:	8d 40 1f             	lea    0x1f(%eax),%eax
  8016cd:	0f 49 c1             	cmovns %ecx,%eax
  8016d0:	c1 f8 05             	sar    $0x5,%eax
  8016d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8016d8:	d3 e2                	shl    %cl,%edx
  8016da:	89 d1                	mov    %edx,%ecx
  8016dc:	23 0c 85 00 10 00 00 	and    0x1000(,%eax,4),%ecx
  8016e3:	0f 84 34 02 00 00    	je     80191d <fs_test+0x29c>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016e9:	8b 0d 00 a0 80 00    	mov    0x80a000,%ecx
  8016ef:	23 14 81             	and    (%ecx,%eax,4),%edx
  8016f2:	0f 85 3b 02 00 00    	jne    801933 <fs_test+0x2b2>
	cprintf("alloc_block is good\n");
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	68 dc 40 80 00       	push   $0x8040dc
  801700:	e8 c3 04 00 00       	call   801bc8 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801705:	83 c4 08             	add    $0x8,%esp
  801708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	68 f1 40 80 00       	push   $0x8040f1
  801711:	e8 6d f6 ff ff       	call   800d83 <file_open>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80171c:	74 08                	je     801726 <fs_test+0xa5>
  80171e:	85 c0                	test   %eax,%eax
  801720:	0f 88 23 02 00 00    	js     801949 <fs_test+0x2c8>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  801726:	85 c0                	test   %eax,%eax
  801728:	0f 84 2d 02 00 00    	je     80195b <fs_test+0x2da>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	68 15 41 80 00       	push   $0x804115
  80173a:	e8 44 f6 ff ff       	call   800d83 <file_open>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	0f 88 25 02 00 00    	js     80196f <fs_test+0x2ee>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  80174a:	83 ec 0c             	sub    $0xc,%esp
  80174d:	68 35 41 80 00       	push   $0x804135
  801752:	e8 71 04 00 00       	call   801bc8 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801757:	83 c4 0c             	add    $0xc,%esp
  80175a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	6a 00                	push   $0x0
  801760:	ff 75 f4             	push   -0xc(%ebp)
  801763:	e8 66 f3 ff ff       	call   800ace <file_get_block>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	0f 88 0e 02 00 00    	js     801981 <fs_test+0x300>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	68 7c 42 80 00       	push   $0x80427c
  80177b:	ff 75 f0             	push   -0x10(%ebp)
  80177e:	e8 d0 0a 00 00       	call   802253 <strcmp>
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	0f 85 05 02 00 00    	jne    801993 <fs_test+0x312>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	68 5b 41 80 00       	push   $0x80415b
  801796:	e8 2d 04 00 00       	call   801bc8 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179e:	0f b6 10             	movzbl (%eax),%edx
  8017a1:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8017a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a6:	c1 e8 0c             	shr    $0xc,%eax
  8017a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	a8 40                	test   $0x40,%al
  8017b5:	0f 84 ec 01 00 00    	je     8019a7 <fs_test+0x326>
	file_flush(f);
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	ff 75 f4             	push   -0xc(%ebp)
  8017c1:	e8 fb f7 ff ff       	call   800fc1 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	c1 e8 0c             	shr    $0xc,%eax
  8017cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	a8 40                	test   $0x40,%al
  8017d8:	0f 85 df 01 00 00    	jne    8019bd <fs_test+0x33c>
	cprintf("file_flush is good\n");
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	68 8f 41 80 00       	push   $0x80418f
  8017e6:	e8 dd 03 00 00       	call   801bc8 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8017eb:	83 c4 08             	add    $0x8,%esp
  8017ee:	6a 00                	push   $0x0
  8017f0:	ff 75 f4             	push   -0xc(%ebp)
  8017f3:	e8 48 f6 ff ff       	call   800e40 <file_set_size>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	0f 88 d0 01 00 00    	js     8019d3 <fs_test+0x352>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  801803:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801806:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80180d:	0f 85 d2 01 00 00    	jne    8019e5 <fs_test+0x364>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801813:	c1 e8 0c             	shr    $0xc,%eax
  801816:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80181d:	a8 40                	test   $0x40,%al
  80181f:	0f 85 d6 01 00 00    	jne    8019fb <fs_test+0x37a>
	cprintf("file_truncate is good\n");
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	68 e3 41 80 00       	push   $0x8041e3
  80182d:	e8 96 03 00 00       	call   801bc8 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801832:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  801839:	e8 29 09 00 00       	call   802167 <strlen>
  80183e:	83 c4 08             	add    $0x8,%esp
  801841:	50                   	push   %eax
  801842:	ff 75 f4             	push   -0xc(%ebp)
  801845:	e8 f6 f5 ff ff       	call   800e40 <file_set_size>
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	85 c0                	test   %eax,%eax
  80184f:	0f 88 bc 01 00 00    	js     801a11 <fs_test+0x390>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801858:	89 c2                	mov    %eax,%edx
  80185a:	c1 ea 0c             	shr    $0xc,%edx
  80185d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801864:	f6 c2 40             	test   $0x40,%dl
  801867:	0f 85 b6 01 00 00    	jne    801a23 <fs_test+0x3a2>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801873:	52                   	push   %edx
  801874:	6a 00                	push   $0x0
  801876:	50                   	push   %eax
  801877:	e8 52 f2 ff ff       	call   800ace <file_get_block>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	0f 88 b2 01 00 00    	js     801a39 <fs_test+0x3b8>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	68 7c 42 80 00       	push   $0x80427c
  80188f:	ff 75 f0             	push   -0x10(%ebp)
  801892:	e8 0b 09 00 00       	call   8021a2 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	c1 e8 0c             	shr    $0xc,%eax
  80189d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	a8 40                	test   $0x40,%al
  8018a9:	0f 84 9c 01 00 00    	je     801a4b <fs_test+0x3ca>
	file_flush(f);
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	ff 75 f4             	push   -0xc(%ebp)
  8018b5:	e8 07 f7 ff ff       	call   800fc1 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bd:	c1 e8 0c             	shr    $0xc,%eax
  8018c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	a8 40                	test   $0x40,%al
  8018cc:	0f 85 8f 01 00 00    	jne    801a61 <fs_test+0x3e0>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d5:	c1 e8 0c             	shr    $0xc,%eax
  8018d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018df:	a8 40                	test   $0x40,%al
  8018e1:	0f 85 90 01 00 00    	jne    801a77 <fs_test+0x3f6>
	cprintf("file rewrite is good\n");
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	68 23 42 80 00       	push   $0x804223
  8018ef:	e8 d4 02 00 00       	call   801bc8 <cprintf>
}
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8018f9:	50                   	push   %eax
  8018fa:	68 94 40 80 00       	push   $0x804094
  8018ff:	6a 12                	push   $0x12
  801901:	68 a7 40 80 00       	push   $0x8040a7
  801906:	e8 e2 01 00 00       	call   801aed <_panic>
		panic("alloc_block: %e", r);
  80190b:	50                   	push   %eax
  80190c:	68 b1 40 80 00       	push   $0x8040b1
  801911:	6a 17                	push   $0x17
  801913:	68 a7 40 80 00       	push   $0x8040a7
  801918:	e8 d0 01 00 00       	call   801aed <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  80191d:	68 c1 40 80 00       	push   $0x8040c1
  801922:	68 5d 3d 80 00       	push   $0x803d5d
  801927:	6a 19                	push   $0x19
  801929:	68 a7 40 80 00       	push   $0x8040a7
  80192e:	e8 ba 01 00 00       	call   801aed <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801933:	68 3c 42 80 00       	push   $0x80423c
  801938:	68 5d 3d 80 00       	push   $0x803d5d
  80193d:	6a 1b                	push   $0x1b
  80193f:	68 a7 40 80 00       	push   $0x8040a7
  801944:	e8 a4 01 00 00       	call   801aed <_panic>
		panic("file_open /not-found: %e", r);
  801949:	50                   	push   %eax
  80194a:	68 fc 40 80 00       	push   $0x8040fc
  80194f:	6a 1f                	push   $0x1f
  801951:	68 a7 40 80 00       	push   $0x8040a7
  801956:	e8 92 01 00 00       	call   801aed <_panic>
		panic("file_open /not-found succeeded!");
  80195b:	83 ec 04             	sub    $0x4,%esp
  80195e:	68 5c 42 80 00       	push   $0x80425c
  801963:	6a 21                	push   $0x21
  801965:	68 a7 40 80 00       	push   $0x8040a7
  80196a:	e8 7e 01 00 00       	call   801aed <_panic>
		panic("file_open /newmotd: %e", r);
  80196f:	50                   	push   %eax
  801970:	68 1e 41 80 00       	push   $0x80411e
  801975:	6a 23                	push   $0x23
  801977:	68 a7 40 80 00       	push   $0x8040a7
  80197c:	e8 6c 01 00 00       	call   801aed <_panic>
		panic("file_get_block: %e", r);
  801981:	50                   	push   %eax
  801982:	68 48 41 80 00       	push   $0x804148
  801987:	6a 27                	push   $0x27
  801989:	68 a7 40 80 00       	push   $0x8040a7
  80198e:	e8 5a 01 00 00       	call   801aed <_panic>
		panic("file_get_block returned wrong data");
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	68 a4 42 80 00       	push   $0x8042a4
  80199b:	6a 29                	push   $0x29
  80199d:	68 a7 40 80 00       	push   $0x8040a7
  8019a2:	e8 46 01 00 00       	call   801aed <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019a7:	68 74 41 80 00       	push   $0x804174
  8019ac:	68 5d 3d 80 00       	push   $0x803d5d
  8019b1:	6a 2d                	push   $0x2d
  8019b3:	68 a7 40 80 00       	push   $0x8040a7
  8019b8:	e8 30 01 00 00       	call   801aed <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019bd:	68 73 41 80 00       	push   $0x804173
  8019c2:	68 5d 3d 80 00       	push   $0x803d5d
  8019c7:	6a 2f                	push   $0x2f
  8019c9:	68 a7 40 80 00       	push   $0x8040a7
  8019ce:	e8 1a 01 00 00       	call   801aed <_panic>
		panic("file_set_size: %e", r);
  8019d3:	50                   	push   %eax
  8019d4:	68 a3 41 80 00       	push   $0x8041a3
  8019d9:	6a 33                	push   $0x33
  8019db:	68 a7 40 80 00       	push   $0x8040a7
  8019e0:	e8 08 01 00 00       	call   801aed <_panic>
	assert(f->f_direct[0] == 0);
  8019e5:	68 b5 41 80 00       	push   $0x8041b5
  8019ea:	68 5d 3d 80 00       	push   $0x803d5d
  8019ef:	6a 34                	push   $0x34
  8019f1:	68 a7 40 80 00       	push   $0x8040a7
  8019f6:	e8 f2 00 00 00       	call   801aed <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019fb:	68 c9 41 80 00       	push   $0x8041c9
  801a00:	68 5d 3d 80 00       	push   $0x803d5d
  801a05:	6a 35                	push   $0x35
  801a07:	68 a7 40 80 00       	push   $0x8040a7
  801a0c:	e8 dc 00 00 00       	call   801aed <_panic>
		panic("file_set_size 2: %e", r);
  801a11:	50                   	push   %eax
  801a12:	68 fa 41 80 00       	push   $0x8041fa
  801a17:	6a 39                	push   $0x39
  801a19:	68 a7 40 80 00       	push   $0x8040a7
  801a1e:	e8 ca 00 00 00       	call   801aed <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a23:	68 c9 41 80 00       	push   $0x8041c9
  801a28:	68 5d 3d 80 00       	push   $0x803d5d
  801a2d:	6a 3a                	push   $0x3a
  801a2f:	68 a7 40 80 00       	push   $0x8040a7
  801a34:	e8 b4 00 00 00       	call   801aed <_panic>
		panic("file_get_block 2: %e", r);
  801a39:	50                   	push   %eax
  801a3a:	68 0e 42 80 00       	push   $0x80420e
  801a3f:	6a 3c                	push   $0x3c
  801a41:	68 a7 40 80 00       	push   $0x8040a7
  801a46:	e8 a2 00 00 00       	call   801aed <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a4b:	68 74 41 80 00       	push   $0x804174
  801a50:	68 5d 3d 80 00       	push   $0x803d5d
  801a55:	6a 3e                	push   $0x3e
  801a57:	68 a7 40 80 00       	push   $0x8040a7
  801a5c:	e8 8c 00 00 00       	call   801aed <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a61:	68 73 41 80 00       	push   $0x804173
  801a66:	68 5d 3d 80 00       	push   $0x803d5d
  801a6b:	6a 40                	push   $0x40
  801a6d:	68 a7 40 80 00       	push   $0x8040a7
  801a72:	e8 76 00 00 00       	call   801aed <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a77:	68 c9 41 80 00       	push   $0x8041c9
  801a7c:	68 5d 3d 80 00       	push   $0x803d5d
  801a81:	6a 41                	push   $0x41
  801a83:	68 a7 40 80 00       	push   $0x8040a7
  801a88:	e8 60 00 00 00       	call   801aed <_panic>

00801a8d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a95:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  801a98:	e8 c3 0a 00 00       	call   802560 <sys_getenvid>
  801a9d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801aa2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aa5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aaa:	a3 08 a0 80 00       	mov    %eax,0x80a008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	7e 07                	jle    801aba <libmain+0x2d>
		binaryname = argv[0];
  801ab3:	8b 06                	mov    (%esi),%eax
  801ab5:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	e8 7c fb ff ff       	call   801640 <umain>

	// exit gracefully
	exit();
  801ac4:	e8 0a 00 00 00       	call   801ad3 <exit>
}
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801ad9:	e8 73 10 00 00       	call   802b51 <close_all>
	sys_env_destroy(0);
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 37 0a 00 00       	call   80251f <sys_env_destroy>
}
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801af2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801af5:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801afb:	e8 60 0a 00 00       	call   802560 <sys_getenvid>
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	ff 75 0c             	push   0xc(%ebp)
  801b06:	ff 75 08             	push   0x8(%ebp)
  801b09:	56                   	push   %esi
  801b0a:	50                   	push   %eax
  801b0b:	68 d4 42 80 00       	push   $0x8042d4
  801b10:	e8 b3 00 00 00       	call   801bc8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b15:	83 c4 18             	add    $0x18,%esp
  801b18:	53                   	push   %ebx
  801b19:	ff 75 10             	push   0x10(%ebp)
  801b1c:	e8 56 00 00 00       	call   801b77 <vcprintf>
	cprintf("\n");
  801b21:	c7 04 24 e3 3e 80 00 	movl   $0x803ee3,(%esp)
  801b28:	e8 9b 00 00 00       	call   801bc8 <cprintf>
  801b2d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b30:	cc                   	int3   
  801b31:	eb fd                	jmp    801b30 <_panic+0x43>

00801b33 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b3d:	8b 13                	mov    (%ebx),%edx
  801b3f:	8d 42 01             	lea    0x1(%edx),%eax
  801b42:	89 03                	mov    %eax,(%ebx)
  801b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b47:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b4b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b50:	74 09                	je     801b5b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801b52:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	68 ff 00 00 00       	push   $0xff
  801b63:	8d 43 08             	lea    0x8(%ebx),%eax
  801b66:	50                   	push   %eax
  801b67:	e8 76 09 00 00       	call   8024e2 <sys_cputs>
		b->idx = 0;
  801b6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	eb db                	jmp    801b52 <putch+0x1f>

00801b77 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b80:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b87:	00 00 00 
	b.cnt = 0;
  801b8a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b91:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b94:	ff 75 0c             	push   0xc(%ebp)
  801b97:	ff 75 08             	push   0x8(%ebp)
  801b9a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	68 33 1b 80 00       	push   $0x801b33
  801ba6:	e8 14 01 00 00       	call   801cbf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bab:	83 c4 08             	add    $0x8,%esp
  801bae:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801bb4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bba:	50                   	push   %eax
  801bbb:	e8 22 09 00 00       	call   8024e2 <sys_cputs>

	return b.cnt;
}
  801bc0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bd1:	50                   	push   %eax
  801bd2:	ff 75 08             	push   0x8(%ebp)
  801bd5:	e8 9d ff ff ff       	call   801b77 <vcprintf>
	va_end(ap);

	return cnt;
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	57                   	push   %edi
  801be0:	56                   	push   %esi
  801be1:	53                   	push   %ebx
  801be2:	83 ec 1c             	sub    $0x1c,%esp
  801be5:	89 c7                	mov    %eax,%edi
  801be7:	89 d6                	mov    %edx,%esi
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bef:	89 d1                	mov    %edx,%ecx
  801bf1:	89 c2                	mov    %eax,%edx
  801bf3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bf6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801bf9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c02:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801c09:	39 c2                	cmp    %eax,%edx
  801c0b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801c0e:	72 3e                	jb     801c4e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 18             	push   0x18(%ebp)
  801c16:	83 eb 01             	sub    $0x1,%ebx
  801c19:	53                   	push   %ebx
  801c1a:	50                   	push   %eax
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	ff 75 e4             	push   -0x1c(%ebp)
  801c21:	ff 75 e0             	push   -0x20(%ebp)
  801c24:	ff 75 dc             	push   -0x24(%ebp)
  801c27:	ff 75 d8             	push   -0x28(%ebp)
  801c2a:	e8 a1 1e 00 00       	call   803ad0 <__udivdi3>
  801c2f:	83 c4 18             	add    $0x18,%esp
  801c32:	52                   	push   %edx
  801c33:	50                   	push   %eax
  801c34:	89 f2                	mov    %esi,%edx
  801c36:	89 f8                	mov    %edi,%eax
  801c38:	e8 9f ff ff ff       	call   801bdc <printnum>
  801c3d:	83 c4 20             	add    $0x20,%esp
  801c40:	eb 13                	jmp    801c55 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	56                   	push   %esi
  801c46:	ff 75 18             	push   0x18(%ebp)
  801c49:	ff d7                	call   *%edi
  801c4b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801c4e:	83 eb 01             	sub    $0x1,%ebx
  801c51:	85 db                	test   %ebx,%ebx
  801c53:	7f ed                	jg     801c42 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	56                   	push   %esi
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	ff 75 e4             	push   -0x1c(%ebp)
  801c5f:	ff 75 e0             	push   -0x20(%ebp)
  801c62:	ff 75 dc             	push   -0x24(%ebp)
  801c65:	ff 75 d8             	push   -0x28(%ebp)
  801c68:	e8 83 1f 00 00       	call   803bf0 <__umoddi3>
  801c6d:	83 c4 14             	add    $0x14,%esp
  801c70:	0f be 80 f7 42 80 00 	movsbl 0x8042f7(%eax),%eax
  801c77:	50                   	push   %eax
  801c78:	ff d7                	call   *%edi
}
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c8b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c8f:	8b 10                	mov    (%eax),%edx
  801c91:	3b 50 04             	cmp    0x4(%eax),%edx
  801c94:	73 0a                	jae    801ca0 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c96:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c99:	89 08                	mov    %ecx,(%eax)
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	88 02                	mov    %al,(%edx)
}
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <printfmt>:
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801ca8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801cab:	50                   	push   %eax
  801cac:	ff 75 10             	push   0x10(%ebp)
  801caf:	ff 75 0c             	push   0xc(%ebp)
  801cb2:	ff 75 08             	push   0x8(%ebp)
  801cb5:	e8 05 00 00 00       	call   801cbf <vprintfmt>
}
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <vprintfmt>:
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	57                   	push   %edi
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 3c             	sub    $0x3c,%esp
  801cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801ccb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cce:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cd1:	eb 0a                	jmp    801cdd <vprintfmt+0x1e>
			putch(ch, putdat);
  801cd3:	83 ec 08             	sub    $0x8,%esp
  801cd6:	53                   	push   %ebx
  801cd7:	50                   	push   %eax
  801cd8:	ff d6                	call   *%esi
  801cda:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cdd:	83 c7 01             	add    $0x1,%edi
  801ce0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ce4:	83 f8 25             	cmp    $0x25,%eax
  801ce7:	74 0c                	je     801cf5 <vprintfmt+0x36>
			if (ch == '\0')
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	75 e6                	jne    801cd3 <vprintfmt+0x14>
}
  801ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5f                   	pop    %edi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    
		padc = ' ';
  801cf5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801cf9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801d00:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801d07:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801d0e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801d13:	8d 47 01             	lea    0x1(%edi),%eax
  801d16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d19:	0f b6 17             	movzbl (%edi),%edx
  801d1c:	8d 42 dd             	lea    -0x23(%edx),%eax
  801d1f:	3c 55                	cmp    $0x55,%al
  801d21:	0f 87 bb 03 00 00    	ja     8020e2 <vprintfmt+0x423>
  801d27:	0f b6 c0             	movzbl %al,%eax
  801d2a:	ff 24 85 40 44 80 00 	jmp    *0x804440(,%eax,4)
  801d31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801d34:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801d38:	eb d9                	jmp    801d13 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d3d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801d41:	eb d0                	jmp    801d13 <vprintfmt+0x54>
  801d43:	0f b6 d2             	movzbl %dl,%edx
  801d46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801d51:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d54:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d58:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d5b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801d5e:	83 f9 09             	cmp    $0x9,%ecx
  801d61:	77 55                	ja     801db8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801d63:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801d66:	eb e9                	jmp    801d51 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801d68:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6b:	8b 00                	mov    (%eax),%eax
  801d6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d70:	8b 45 14             	mov    0x14(%ebp),%eax
  801d73:	8d 40 04             	lea    0x4(%eax),%eax
  801d76:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801d79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801d7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d80:	79 91                	jns    801d13 <vprintfmt+0x54>
				width = precision, precision = -1;
  801d82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d88:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801d8f:	eb 82                	jmp    801d13 <vprintfmt+0x54>
  801d91:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d94:	85 d2                	test   %edx,%edx
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	0f 49 c2             	cmovns %edx,%eax
  801d9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801da1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801da4:	e9 6a ff ff ff       	jmp    801d13 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801da9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801dac:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801db3:	e9 5b ff ff ff       	jmp    801d13 <vprintfmt+0x54>
  801db8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801dbb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dbe:	eb bc                	jmp    801d7c <vprintfmt+0xbd>
			lflag++;
  801dc0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801dc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801dc6:	e9 48 ff ff ff       	jmp    801d13 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801dcb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dce:	8d 78 04             	lea    0x4(%eax),%edi
  801dd1:	83 ec 08             	sub    $0x8,%esp
  801dd4:	53                   	push   %ebx
  801dd5:	ff 30                	push   (%eax)
  801dd7:	ff d6                	call   *%esi
			break;
  801dd9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801ddc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801ddf:	e9 9d 02 00 00       	jmp    802081 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  801de4:	8b 45 14             	mov    0x14(%ebp),%eax
  801de7:	8d 78 04             	lea    0x4(%eax),%edi
  801dea:	8b 10                	mov    (%eax),%edx
  801dec:	89 d0                	mov    %edx,%eax
  801dee:	f7 d8                	neg    %eax
  801df0:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801df3:	83 f8 0f             	cmp    $0xf,%eax
  801df6:	7f 23                	jg     801e1b <vprintfmt+0x15c>
  801df8:	8b 14 85 a0 45 80 00 	mov    0x8045a0(,%eax,4),%edx
  801dff:	85 d2                	test   %edx,%edx
  801e01:	74 18                	je     801e1b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801e03:	52                   	push   %edx
  801e04:	68 6f 3d 80 00       	push   $0x803d6f
  801e09:	53                   	push   %ebx
  801e0a:	56                   	push   %esi
  801e0b:	e8 92 fe ff ff       	call   801ca2 <printfmt>
  801e10:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e13:	89 7d 14             	mov    %edi,0x14(%ebp)
  801e16:	e9 66 02 00 00       	jmp    802081 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801e1b:	50                   	push   %eax
  801e1c:	68 0f 43 80 00       	push   $0x80430f
  801e21:	53                   	push   %ebx
  801e22:	56                   	push   %esi
  801e23:	e8 7a fe ff ff       	call   801ca2 <printfmt>
  801e28:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e2b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801e2e:	e9 4e 02 00 00       	jmp    802081 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801e33:	8b 45 14             	mov    0x14(%ebp),%eax
  801e36:	83 c0 04             	add    $0x4,%eax
  801e39:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801e3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801e41:	85 d2                	test   %edx,%edx
  801e43:	b8 08 43 80 00       	mov    $0x804308,%eax
  801e48:	0f 45 c2             	cmovne %edx,%eax
  801e4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801e4e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e52:	7e 06                	jle    801e5a <vprintfmt+0x19b>
  801e54:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801e58:	75 0d                	jne    801e67 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e5a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e5d:	89 c7                	mov    %eax,%edi
  801e5f:	03 45 e0             	add    -0x20(%ebp),%eax
  801e62:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e65:	eb 55                	jmp    801ebc <vprintfmt+0x1fd>
  801e67:	83 ec 08             	sub    $0x8,%esp
  801e6a:	ff 75 d8             	push   -0x28(%ebp)
  801e6d:	ff 75 cc             	push   -0x34(%ebp)
  801e70:	e8 0a 03 00 00       	call   80217f <strnlen>
  801e75:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e78:	29 c1                	sub    %eax,%ecx
  801e7a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801e82:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801e86:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801e89:	eb 0f                	jmp    801e9a <vprintfmt+0x1db>
					putch(padc, putdat);
  801e8b:	83 ec 08             	sub    $0x8,%esp
  801e8e:	53                   	push   %ebx
  801e8f:	ff 75 e0             	push   -0x20(%ebp)
  801e92:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801e94:	83 ef 01             	sub    $0x1,%edi
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 ff                	test   %edi,%edi
  801e9c:	7f ed                	jg     801e8b <vprintfmt+0x1cc>
  801e9e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801ea1:	85 d2                	test   %edx,%edx
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	0f 49 c2             	cmovns %edx,%eax
  801eab:	29 c2                	sub    %eax,%edx
  801ead:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801eb0:	eb a8                	jmp    801e5a <vprintfmt+0x19b>
					putch(ch, putdat);
  801eb2:	83 ec 08             	sub    $0x8,%esp
  801eb5:	53                   	push   %ebx
  801eb6:	52                   	push   %edx
  801eb7:	ff d6                	call   *%esi
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ebf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ec1:	83 c7 01             	add    $0x1,%edi
  801ec4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ec8:	0f be d0             	movsbl %al,%edx
  801ecb:	85 d2                	test   %edx,%edx
  801ecd:	74 4b                	je     801f1a <vprintfmt+0x25b>
  801ecf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ed3:	78 06                	js     801edb <vprintfmt+0x21c>
  801ed5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801ed9:	78 1e                	js     801ef9 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801edb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801edf:	74 d1                	je     801eb2 <vprintfmt+0x1f3>
  801ee1:	0f be c0             	movsbl %al,%eax
  801ee4:	83 e8 20             	sub    $0x20,%eax
  801ee7:	83 f8 5e             	cmp    $0x5e,%eax
  801eea:	76 c6                	jbe    801eb2 <vprintfmt+0x1f3>
					putch('?', putdat);
  801eec:	83 ec 08             	sub    $0x8,%esp
  801eef:	53                   	push   %ebx
  801ef0:	6a 3f                	push   $0x3f
  801ef2:	ff d6                	call   *%esi
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	eb c3                	jmp    801ebc <vprintfmt+0x1fd>
  801ef9:	89 cf                	mov    %ecx,%edi
  801efb:	eb 0e                	jmp    801f0b <vprintfmt+0x24c>
				putch(' ', putdat);
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	53                   	push   %ebx
  801f01:	6a 20                	push   $0x20
  801f03:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801f05:	83 ef 01             	sub    $0x1,%edi
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	7f ee                	jg     801efd <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801f0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801f12:	89 45 14             	mov    %eax,0x14(%ebp)
  801f15:	e9 67 01 00 00       	jmp    802081 <vprintfmt+0x3c2>
  801f1a:	89 cf                	mov    %ecx,%edi
  801f1c:	eb ed                	jmp    801f0b <vprintfmt+0x24c>
	if (lflag >= 2)
  801f1e:	83 f9 01             	cmp    $0x1,%ecx
  801f21:	7f 1b                	jg     801f3e <vprintfmt+0x27f>
	else if (lflag)
  801f23:	85 c9                	test   %ecx,%ecx
  801f25:	74 63                	je     801f8a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801f27:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2a:	8b 00                	mov    (%eax),%eax
  801f2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f2f:	99                   	cltd   
  801f30:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f33:	8b 45 14             	mov    0x14(%ebp),%eax
  801f36:	8d 40 04             	lea    0x4(%eax),%eax
  801f39:	89 45 14             	mov    %eax,0x14(%ebp)
  801f3c:	eb 17                	jmp    801f55 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801f3e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f41:	8b 50 04             	mov    0x4(%eax),%edx
  801f44:	8b 00                	mov    (%eax),%eax
  801f46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f49:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4f:	8d 40 08             	lea    0x8(%eax),%eax
  801f52:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801f55:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f58:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801f5b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801f60:	85 c9                	test   %ecx,%ecx
  801f62:	0f 89 ff 00 00 00    	jns    802067 <vprintfmt+0x3a8>
				putch('-', putdat);
  801f68:	83 ec 08             	sub    $0x8,%esp
  801f6b:	53                   	push   %ebx
  801f6c:	6a 2d                	push   $0x2d
  801f6e:	ff d6                	call   *%esi
				num = -(long long) num;
  801f70:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f73:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f76:	f7 da                	neg    %edx
  801f78:	83 d1 00             	adc    $0x0,%ecx
  801f7b:	f7 d9                	neg    %ecx
  801f7d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801f80:	bf 0a 00 00 00       	mov    $0xa,%edi
  801f85:	e9 dd 00 00 00       	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801f8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8d:	8b 00                	mov    (%eax),%eax
  801f8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f92:	99                   	cltd   
  801f93:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f96:	8b 45 14             	mov    0x14(%ebp),%eax
  801f99:	8d 40 04             	lea    0x4(%eax),%eax
  801f9c:	89 45 14             	mov    %eax,0x14(%ebp)
  801f9f:	eb b4                	jmp    801f55 <vprintfmt+0x296>
	if (lflag >= 2)
  801fa1:	83 f9 01             	cmp    $0x1,%ecx
  801fa4:	7f 1e                	jg     801fc4 <vprintfmt+0x305>
	else if (lflag)
  801fa6:	85 c9                	test   %ecx,%ecx
  801fa8:	74 32                	je     801fdc <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801faa:	8b 45 14             	mov    0x14(%ebp),%eax
  801fad:	8b 10                	mov    (%eax),%edx
  801faf:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fb4:	8d 40 04             	lea    0x4(%eax),%eax
  801fb7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fba:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801fbf:	e9 a3 00 00 00       	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801fc4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc7:	8b 10                	mov    (%eax),%edx
  801fc9:	8b 48 04             	mov    0x4(%eax),%ecx
  801fcc:	8d 40 08             	lea    0x8(%eax),%eax
  801fcf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fd2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  801fd7:	e9 8b 00 00 00       	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdf:	8b 10                	mov    (%eax),%edx
  801fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fe6:	8d 40 04             	lea    0x4(%eax),%eax
  801fe9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fec:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801ff1:	eb 74                	jmp    802067 <vprintfmt+0x3a8>
	if (lflag >= 2)
  801ff3:	83 f9 01             	cmp    $0x1,%ecx
  801ff6:	7f 1b                	jg     802013 <vprintfmt+0x354>
	else if (lflag)
  801ff8:	85 c9                	test   %ecx,%ecx
  801ffa:	74 2c                	je     802028 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801ffc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fff:	8b 10                	mov    (%eax),%edx
  802001:	b9 00 00 00 00       	mov    $0x0,%ecx
  802006:	8d 40 04             	lea    0x4(%eax),%eax
  802009:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80200c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  802011:	eb 54                	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  802013:	8b 45 14             	mov    0x14(%ebp),%eax
  802016:	8b 10                	mov    (%eax),%edx
  802018:	8b 48 04             	mov    0x4(%eax),%ecx
  80201b:	8d 40 08             	lea    0x8(%eax),%eax
  80201e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  802021:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  802026:	eb 3f                	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  802028:	8b 45 14             	mov    0x14(%ebp),%eax
  80202b:	8b 10                	mov    (%eax),%edx
  80202d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802032:	8d 40 04             	lea    0x4(%eax),%eax
  802035:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  802038:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80203d:	eb 28                	jmp    802067 <vprintfmt+0x3a8>
			putch('0', putdat);
  80203f:	83 ec 08             	sub    $0x8,%esp
  802042:	53                   	push   %ebx
  802043:	6a 30                	push   $0x30
  802045:	ff d6                	call   *%esi
			putch('x', putdat);
  802047:	83 c4 08             	add    $0x8,%esp
  80204a:	53                   	push   %ebx
  80204b:	6a 78                	push   $0x78
  80204d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80204f:	8b 45 14             	mov    0x14(%ebp),%eax
  802052:	8b 10                	mov    (%eax),%edx
  802054:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  802059:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80205c:	8d 40 04             	lea    0x4(%eax),%eax
  80205f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802062:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80206e:	50                   	push   %eax
  80206f:	ff 75 e0             	push   -0x20(%ebp)
  802072:	57                   	push   %edi
  802073:	51                   	push   %ecx
  802074:	52                   	push   %edx
  802075:	89 da                	mov    %ebx,%edx
  802077:	89 f0                	mov    %esi,%eax
  802079:	e8 5e fb ff ff       	call   801bdc <printnum>
			break;
  80207e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  802081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802084:	e9 54 fc ff ff       	jmp    801cdd <vprintfmt+0x1e>
	if (lflag >= 2)
  802089:	83 f9 01             	cmp    $0x1,%ecx
  80208c:	7f 1b                	jg     8020a9 <vprintfmt+0x3ea>
	else if (lflag)
  80208e:	85 c9                	test   %ecx,%ecx
  802090:	74 2c                	je     8020be <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  802092:	8b 45 14             	mov    0x14(%ebp),%eax
  802095:	8b 10                	mov    (%eax),%edx
  802097:	b9 00 00 00 00       	mov    $0x0,%ecx
  80209c:	8d 40 04             	lea    0x4(%eax),%eax
  80209f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020a2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8020a7:	eb be                	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8020a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ac:	8b 10                	mov    (%eax),%edx
  8020ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8020b1:	8d 40 08             	lea    0x8(%eax),%eax
  8020b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020b7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8020bc:	eb a9                	jmp    802067 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8020be:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c1:	8b 10                	mov    (%eax),%edx
  8020c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020c8:	8d 40 04             	lea    0x4(%eax),%eax
  8020cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020ce:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8020d3:	eb 92                	jmp    802067 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8020d5:	83 ec 08             	sub    $0x8,%esp
  8020d8:	53                   	push   %ebx
  8020d9:	6a 25                	push   $0x25
  8020db:	ff d6                	call   *%esi
			break;
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	eb 9f                	jmp    802081 <vprintfmt+0x3c2>
			putch('%', putdat);
  8020e2:	83 ec 08             	sub    $0x8,%esp
  8020e5:	53                   	push   %ebx
  8020e6:	6a 25                	push   $0x25
  8020e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	89 f8                	mov    %edi,%eax
  8020ef:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8020f3:	74 05                	je     8020fa <vprintfmt+0x43b>
  8020f5:	83 e8 01             	sub    $0x1,%eax
  8020f8:	eb f5                	jmp    8020ef <vprintfmt+0x430>
  8020fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020fd:	eb 82                	jmp    802081 <vprintfmt+0x3c2>

008020ff <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	83 ec 18             	sub    $0x18,%esp
  802105:	8b 45 08             	mov    0x8(%ebp),%eax
  802108:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80210b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80210e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802112:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802115:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80211c:	85 c0                	test   %eax,%eax
  80211e:	74 26                	je     802146 <vsnprintf+0x47>
  802120:	85 d2                	test   %edx,%edx
  802122:	7e 22                	jle    802146 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802124:	ff 75 14             	push   0x14(%ebp)
  802127:	ff 75 10             	push   0x10(%ebp)
  80212a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80212d:	50                   	push   %eax
  80212e:	68 85 1c 80 00       	push   $0x801c85
  802133:	e8 87 fb ff ff       	call   801cbf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802138:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80213b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	83 c4 10             	add    $0x10,%esp
}
  802144:	c9                   	leave  
  802145:	c3                   	ret    
		return -E_INVAL;
  802146:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80214b:	eb f7                	jmp    802144 <vsnprintf+0x45>

0080214d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802153:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802156:	50                   	push   %eax
  802157:	ff 75 10             	push   0x10(%ebp)
  80215a:	ff 75 0c             	push   0xc(%ebp)
  80215d:	ff 75 08             	push   0x8(%ebp)
  802160:	e8 9a ff ff ff       	call   8020ff <vsnprintf>
	va_end(ap);

	return rc;
}
  802165:	c9                   	leave  
  802166:	c3                   	ret    

00802167 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802167:	55                   	push   %ebp
  802168:	89 e5                	mov    %esp,%ebp
  80216a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
  802172:	eb 03                	jmp    802177 <strlen+0x10>
		n++;
  802174:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  802177:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80217b:	75 f7                	jne    802174 <strlen+0xd>
	return n;
}
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    

0080217f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80217f:	55                   	push   %ebp
  802180:	89 e5                	mov    %esp,%ebp
  802182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802185:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802188:	b8 00 00 00 00       	mov    $0x0,%eax
  80218d:	eb 03                	jmp    802192 <strnlen+0x13>
		n++;
  80218f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802192:	39 d0                	cmp    %edx,%eax
  802194:	74 08                	je     80219e <strnlen+0x1f>
  802196:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80219a:	75 f3                	jne    80218f <strnlen+0x10>
  80219c:	89 c2                	mov    %eax,%edx
	return n;
}
  80219e:	89 d0                	mov    %edx,%eax
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    

008021a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	53                   	push   %ebx
  8021a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8021b5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8021b8:	83 c0 01             	add    $0x1,%eax
  8021bb:	84 d2                	test   %dl,%dl
  8021bd:	75 f2                	jne    8021b1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8021bf:	89 c8                	mov    %ecx,%eax
  8021c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c4:	c9                   	leave  
  8021c5:	c3                   	ret    

008021c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	53                   	push   %ebx
  8021ca:	83 ec 10             	sub    $0x10,%esp
  8021cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021d0:	53                   	push   %ebx
  8021d1:	e8 91 ff ff ff       	call   802167 <strlen>
  8021d6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8021d9:	ff 75 0c             	push   0xc(%ebp)
  8021dc:	01 d8                	add    %ebx,%eax
  8021de:	50                   	push   %eax
  8021df:	e8 be ff ff ff       	call   8021a2 <strcpy>
	return dst;
}
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	56                   	push   %esi
  8021ef:	53                   	push   %ebx
  8021f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f6:	89 f3                	mov    %esi,%ebx
  8021f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021fb:	89 f0                	mov    %esi,%eax
  8021fd:	eb 0f                	jmp    80220e <strncpy+0x23>
		*dst++ = *src;
  8021ff:	83 c0 01             	add    $0x1,%eax
  802202:	0f b6 0a             	movzbl (%edx),%ecx
  802205:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802208:	80 f9 01             	cmp    $0x1,%cl
  80220b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80220e:	39 d8                	cmp    %ebx,%eax
  802210:	75 ed                	jne    8021ff <strncpy+0x14>
	}
	return ret;
}
  802212:	89 f0                	mov    %esi,%eax
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    

00802218 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	56                   	push   %esi
  80221c:	53                   	push   %ebx
  80221d:	8b 75 08             	mov    0x8(%ebp),%esi
  802220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802223:	8b 55 10             	mov    0x10(%ebp),%edx
  802226:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802228:	85 d2                	test   %edx,%edx
  80222a:	74 21                	je     80224d <strlcpy+0x35>
  80222c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802230:	89 f2                	mov    %esi,%edx
  802232:	eb 09                	jmp    80223d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802234:	83 c1 01             	add    $0x1,%ecx
  802237:	83 c2 01             	add    $0x1,%edx
  80223a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80223d:	39 c2                	cmp    %eax,%edx
  80223f:	74 09                	je     80224a <strlcpy+0x32>
  802241:	0f b6 19             	movzbl (%ecx),%ebx
  802244:	84 db                	test   %bl,%bl
  802246:	75 ec                	jne    802234 <strlcpy+0x1c>
  802248:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80224a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80224d:	29 f0                	sub    %esi,%eax
}
  80224f:	5b                   	pop    %ebx
  802250:	5e                   	pop    %esi
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802259:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80225c:	eb 06                	jmp    802264 <strcmp+0x11>
		p++, q++;
  80225e:	83 c1 01             	add    $0x1,%ecx
  802261:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  802264:	0f b6 01             	movzbl (%ecx),%eax
  802267:	84 c0                	test   %al,%al
  802269:	74 04                	je     80226f <strcmp+0x1c>
  80226b:	3a 02                	cmp    (%edx),%al
  80226d:	74 ef                	je     80225e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80226f:	0f b6 c0             	movzbl %al,%eax
  802272:	0f b6 12             	movzbl (%edx),%edx
  802275:	29 d0                	sub    %edx,%eax
}
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    

00802279 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	53                   	push   %ebx
  80227d:	8b 45 08             	mov    0x8(%ebp),%eax
  802280:	8b 55 0c             	mov    0xc(%ebp),%edx
  802283:	89 c3                	mov    %eax,%ebx
  802285:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802288:	eb 06                	jmp    802290 <strncmp+0x17>
		n--, p++, q++;
  80228a:	83 c0 01             	add    $0x1,%eax
  80228d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  802290:	39 d8                	cmp    %ebx,%eax
  802292:	74 18                	je     8022ac <strncmp+0x33>
  802294:	0f b6 08             	movzbl (%eax),%ecx
  802297:	84 c9                	test   %cl,%cl
  802299:	74 04                	je     80229f <strncmp+0x26>
  80229b:	3a 0a                	cmp    (%edx),%cl
  80229d:	74 eb                	je     80228a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80229f:	0f b6 00             	movzbl (%eax),%eax
  8022a2:	0f b6 12             	movzbl (%edx),%edx
  8022a5:	29 d0                	sub    %edx,%eax
}
  8022a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022aa:	c9                   	leave  
  8022ab:	c3                   	ret    
		return 0;
  8022ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b1:	eb f4                	jmp    8022a7 <strncmp+0x2e>

008022b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022bd:	eb 03                	jmp    8022c2 <strchr+0xf>
  8022bf:	83 c0 01             	add    $0x1,%eax
  8022c2:	0f b6 10             	movzbl (%eax),%edx
  8022c5:	84 d2                	test   %dl,%dl
  8022c7:	74 06                	je     8022cf <strchr+0x1c>
		if (*s == c)
  8022c9:	38 ca                	cmp    %cl,%dl
  8022cb:	75 f2                	jne    8022bf <strchr+0xc>
  8022cd:	eb 05                	jmp    8022d4 <strchr+0x21>
			return (char *) s;
	return 0;
  8022cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022e3:	38 ca                	cmp    %cl,%dl
  8022e5:	74 09                	je     8022f0 <strfind+0x1a>
  8022e7:	84 d2                	test   %dl,%dl
  8022e9:	74 05                	je     8022f0 <strfind+0x1a>
	for (; *s; s++)
  8022eb:	83 c0 01             	add    $0x1,%eax
  8022ee:	eb f0                	jmp    8022e0 <strfind+0xa>
			break;
	return (char *) s;
}
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    

008022f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	57                   	push   %edi
  8022f6:	56                   	push   %esi
  8022f7:	53                   	push   %ebx
  8022f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8022fe:	85 c9                	test   %ecx,%ecx
  802300:	74 2f                	je     802331 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802302:	89 f8                	mov    %edi,%eax
  802304:	09 c8                	or     %ecx,%eax
  802306:	a8 03                	test   $0x3,%al
  802308:	75 21                	jne    80232b <memset+0x39>
		c &= 0xFF;
  80230a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80230e:	89 d0                	mov    %edx,%eax
  802310:	c1 e0 08             	shl    $0x8,%eax
  802313:	89 d3                	mov    %edx,%ebx
  802315:	c1 e3 18             	shl    $0x18,%ebx
  802318:	89 d6                	mov    %edx,%esi
  80231a:	c1 e6 10             	shl    $0x10,%esi
  80231d:	09 f3                	or     %esi,%ebx
  80231f:	09 da                	or     %ebx,%edx
  802321:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802323:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  802326:	fc                   	cld    
  802327:	f3 ab                	rep stos %eax,%es:(%edi)
  802329:	eb 06                	jmp    802331 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80232b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232e:	fc                   	cld    
  80232f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802331:	89 f8                	mov    %edi,%eax
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    

00802338 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	57                   	push   %edi
  80233c:	56                   	push   %esi
  80233d:	8b 45 08             	mov    0x8(%ebp),%eax
  802340:	8b 75 0c             	mov    0xc(%ebp),%esi
  802343:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802346:	39 c6                	cmp    %eax,%esi
  802348:	73 32                	jae    80237c <memmove+0x44>
  80234a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80234d:	39 c2                	cmp    %eax,%edx
  80234f:	76 2b                	jbe    80237c <memmove+0x44>
		s += n;
		d += n;
  802351:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802354:	89 d6                	mov    %edx,%esi
  802356:	09 fe                	or     %edi,%esi
  802358:	09 ce                	or     %ecx,%esi
  80235a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802360:	75 0e                	jne    802370 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802362:	83 ef 04             	sub    $0x4,%edi
  802365:	8d 72 fc             	lea    -0x4(%edx),%esi
  802368:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80236b:	fd                   	std    
  80236c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80236e:	eb 09                	jmp    802379 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802370:	83 ef 01             	sub    $0x1,%edi
  802373:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  802376:	fd                   	std    
  802377:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802379:	fc                   	cld    
  80237a:	eb 1a                	jmp    802396 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80237c:	89 f2                	mov    %esi,%edx
  80237e:	09 c2                	or     %eax,%edx
  802380:	09 ca                	or     %ecx,%edx
  802382:	f6 c2 03             	test   $0x3,%dl
  802385:	75 0a                	jne    802391 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802387:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80238a:	89 c7                	mov    %eax,%edi
  80238c:	fc                   	cld    
  80238d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80238f:	eb 05                	jmp    802396 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  802391:	89 c7                	mov    %eax,%edi
  802393:	fc                   	cld    
  802394:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802396:	5e                   	pop    %esi
  802397:	5f                   	pop    %edi
  802398:	5d                   	pop    %ebp
  802399:	c3                   	ret    

0080239a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8023a0:	ff 75 10             	push   0x10(%ebp)
  8023a3:	ff 75 0c             	push   0xc(%ebp)
  8023a6:	ff 75 08             	push   0x8(%ebp)
  8023a9:	e8 8a ff ff ff       	call   802338 <memmove>
}
  8023ae:	c9                   	leave  
  8023af:	c3                   	ret    

008023b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	56                   	push   %esi
  8023b4:	53                   	push   %ebx
  8023b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023bb:	89 c6                	mov    %eax,%esi
  8023bd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023c0:	eb 06                	jmp    8023c8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8023c2:	83 c0 01             	add    $0x1,%eax
  8023c5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8023c8:	39 f0                	cmp    %esi,%eax
  8023ca:	74 14                	je     8023e0 <memcmp+0x30>
		if (*s1 != *s2)
  8023cc:	0f b6 08             	movzbl (%eax),%ecx
  8023cf:	0f b6 1a             	movzbl (%edx),%ebx
  8023d2:	38 d9                	cmp    %bl,%cl
  8023d4:	74 ec                	je     8023c2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8023d6:	0f b6 c1             	movzbl %cl,%eax
  8023d9:	0f b6 db             	movzbl %bl,%ebx
  8023dc:	29 d8                	sub    %ebx,%eax
  8023de:	eb 05                	jmp    8023e5 <memcmp+0x35>
	}

	return 0;
  8023e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023e5:	5b                   	pop    %ebx
  8023e6:	5e                   	pop    %esi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    

008023e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8023f2:	89 c2                	mov    %eax,%edx
  8023f4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8023f7:	eb 03                	jmp    8023fc <memfind+0x13>
  8023f9:	83 c0 01             	add    $0x1,%eax
  8023fc:	39 d0                	cmp    %edx,%eax
  8023fe:	73 04                	jae    802404 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  802400:	38 08                	cmp    %cl,(%eax)
  802402:	75 f5                	jne    8023f9 <memfind+0x10>
			break;
	return (void *) s;
}
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    

00802406 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	57                   	push   %edi
  80240a:	56                   	push   %esi
  80240b:	53                   	push   %ebx
  80240c:	8b 55 08             	mov    0x8(%ebp),%edx
  80240f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802412:	eb 03                	jmp    802417 <strtol+0x11>
		s++;
  802414:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  802417:	0f b6 02             	movzbl (%edx),%eax
  80241a:	3c 20                	cmp    $0x20,%al
  80241c:	74 f6                	je     802414 <strtol+0xe>
  80241e:	3c 09                	cmp    $0x9,%al
  802420:	74 f2                	je     802414 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  802422:	3c 2b                	cmp    $0x2b,%al
  802424:	74 2a                	je     802450 <strtol+0x4a>
	int neg = 0;
  802426:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80242b:	3c 2d                	cmp    $0x2d,%al
  80242d:	74 2b                	je     80245a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80242f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802435:	75 0f                	jne    802446 <strtol+0x40>
  802437:	80 3a 30             	cmpb   $0x30,(%edx)
  80243a:	74 28                	je     802464 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80243c:	85 db                	test   %ebx,%ebx
  80243e:	b8 0a 00 00 00       	mov    $0xa,%eax
  802443:	0f 44 d8             	cmove  %eax,%ebx
  802446:	b9 00 00 00 00       	mov    $0x0,%ecx
  80244b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80244e:	eb 46                	jmp    802496 <strtol+0x90>
		s++;
  802450:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  802453:	bf 00 00 00 00       	mov    $0x0,%edi
  802458:	eb d5                	jmp    80242f <strtol+0x29>
		s++, neg = 1;
  80245a:	83 c2 01             	add    $0x1,%edx
  80245d:	bf 01 00 00 00       	mov    $0x1,%edi
  802462:	eb cb                	jmp    80242f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802464:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802468:	74 0e                	je     802478 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80246a:	85 db                	test   %ebx,%ebx
  80246c:	75 d8                	jne    802446 <strtol+0x40>
		s++, base = 8;
  80246e:	83 c2 01             	add    $0x1,%edx
  802471:	bb 08 00 00 00       	mov    $0x8,%ebx
  802476:	eb ce                	jmp    802446 <strtol+0x40>
		s += 2, base = 16;
  802478:	83 c2 02             	add    $0x2,%edx
  80247b:	bb 10 00 00 00       	mov    $0x10,%ebx
  802480:	eb c4                	jmp    802446 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  802482:	0f be c0             	movsbl %al,%eax
  802485:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802488:	3b 45 10             	cmp    0x10(%ebp),%eax
  80248b:	7d 3a                	jge    8024c7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80248d:	83 c2 01             	add    $0x1,%edx
  802490:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  802494:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  802496:	0f b6 02             	movzbl (%edx),%eax
  802499:	8d 70 d0             	lea    -0x30(%eax),%esi
  80249c:	89 f3                	mov    %esi,%ebx
  80249e:	80 fb 09             	cmp    $0x9,%bl
  8024a1:	76 df                	jbe    802482 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8024a3:	8d 70 9f             	lea    -0x61(%eax),%esi
  8024a6:	89 f3                	mov    %esi,%ebx
  8024a8:	80 fb 19             	cmp    $0x19,%bl
  8024ab:	77 08                	ja     8024b5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8024ad:	0f be c0             	movsbl %al,%eax
  8024b0:	83 e8 57             	sub    $0x57,%eax
  8024b3:	eb d3                	jmp    802488 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8024b5:	8d 70 bf             	lea    -0x41(%eax),%esi
  8024b8:	89 f3                	mov    %esi,%ebx
  8024ba:	80 fb 19             	cmp    $0x19,%bl
  8024bd:	77 08                	ja     8024c7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8024bf:	0f be c0             	movsbl %al,%eax
  8024c2:	83 e8 37             	sub    $0x37,%eax
  8024c5:	eb c1                	jmp    802488 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8024c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024cb:	74 05                	je     8024d2 <strtol+0xcc>
		*endptr = (char *) s;
  8024cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8024d2:	89 c8                	mov    %ecx,%eax
  8024d4:	f7 d8                	neg    %eax
  8024d6:	85 ff                	test   %edi,%edi
  8024d8:	0f 45 c8             	cmovne %eax,%ecx
}
  8024db:	89 c8                	mov    %ecx,%eax
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    

008024e2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024e2:	55                   	push   %ebp
  8024e3:	89 e5                	mov    %esp,%ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8024e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f3:	89 c3                	mov    %eax,%ebx
  8024f5:	89 c7                	mov    %eax,%edi
  8024f7:	89 c6                	mov    %eax,%esi
  8024f9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024fb:	5b                   	pop    %ebx
  8024fc:	5e                   	pop    %esi
  8024fd:	5f                   	pop    %edi
  8024fe:	5d                   	pop    %ebp
  8024ff:	c3                   	ret    

00802500 <sys_cgetc>:

int
sys_cgetc(void)
{
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
  802503:	57                   	push   %edi
  802504:	56                   	push   %esi
  802505:	53                   	push   %ebx
	asm volatile("int %1\n"
  802506:	ba 00 00 00 00       	mov    $0x0,%edx
  80250b:	b8 01 00 00 00       	mov    $0x1,%eax
  802510:	89 d1                	mov    %edx,%ecx
  802512:	89 d3                	mov    %edx,%ebx
  802514:	89 d7                	mov    %edx,%edi
  802516:	89 d6                	mov    %edx,%esi
  802518:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80251a:	5b                   	pop    %ebx
  80251b:	5e                   	pop    %esi
  80251c:	5f                   	pop    %edi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    

0080251f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	57                   	push   %edi
  802523:	56                   	push   %esi
  802524:	53                   	push   %ebx
  802525:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802528:	b9 00 00 00 00       	mov    $0x0,%ecx
  80252d:	8b 55 08             	mov    0x8(%ebp),%edx
  802530:	b8 03 00 00 00       	mov    $0x3,%eax
  802535:	89 cb                	mov    %ecx,%ebx
  802537:	89 cf                	mov    %ecx,%edi
  802539:	89 ce                	mov    %ecx,%esi
  80253b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80253d:	85 c0                	test   %eax,%eax
  80253f:	7f 08                	jg     802549 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802541:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5f                   	pop    %edi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802549:	83 ec 0c             	sub    $0xc,%esp
  80254c:	50                   	push   %eax
  80254d:	6a 03                	push   $0x3
  80254f:	68 ff 45 80 00       	push   $0x8045ff
  802554:	6a 2a                	push   $0x2a
  802556:	68 1c 46 80 00       	push   $0x80461c
  80255b:	e8 8d f5 ff ff       	call   801aed <_panic>

00802560 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	57                   	push   %edi
  802564:	56                   	push   %esi
  802565:	53                   	push   %ebx
	asm volatile("int %1\n"
  802566:	ba 00 00 00 00       	mov    $0x0,%edx
  80256b:	b8 02 00 00 00       	mov    $0x2,%eax
  802570:	89 d1                	mov    %edx,%ecx
  802572:	89 d3                	mov    %edx,%ebx
  802574:	89 d7                	mov    %edx,%edi
  802576:	89 d6                	mov    %edx,%esi
  802578:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80257a:	5b                   	pop    %ebx
  80257b:	5e                   	pop    %esi
  80257c:	5f                   	pop    %edi
  80257d:	5d                   	pop    %ebp
  80257e:	c3                   	ret    

0080257f <sys_yield>:

void
sys_yield(void)
{
  80257f:	55                   	push   %ebp
  802580:	89 e5                	mov    %esp,%ebp
  802582:	57                   	push   %edi
  802583:	56                   	push   %esi
  802584:	53                   	push   %ebx
	asm volatile("int %1\n"
  802585:	ba 00 00 00 00       	mov    $0x0,%edx
  80258a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80258f:	89 d1                	mov    %edx,%ecx
  802591:	89 d3                	mov    %edx,%ebx
  802593:	89 d7                	mov    %edx,%edi
  802595:	89 d6                	mov    %edx,%esi
  802597:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802599:	5b                   	pop    %ebx
  80259a:	5e                   	pop    %esi
  80259b:	5f                   	pop    %edi
  80259c:	5d                   	pop    %ebp
  80259d:	c3                   	ret    

0080259e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025a7:	be 00 00 00 00       	mov    $0x0,%esi
  8025ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8025af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8025b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025ba:	89 f7                	mov    %esi,%edi
  8025bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8025be:	85 c0                	test   %eax,%eax
  8025c0:	7f 08                	jg     8025ca <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c5:	5b                   	pop    %ebx
  8025c6:	5e                   	pop    %esi
  8025c7:	5f                   	pop    %edi
  8025c8:	5d                   	pop    %ebp
  8025c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8025ca:	83 ec 0c             	sub    $0xc,%esp
  8025cd:	50                   	push   %eax
  8025ce:	6a 04                	push   $0x4
  8025d0:	68 ff 45 80 00       	push   $0x8045ff
  8025d5:	6a 2a                	push   $0x2a
  8025d7:	68 1c 46 80 00       	push   $0x80461c
  8025dc:	e8 0c f5 ff ff       	call   801aed <_panic>

008025e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025e1:	55                   	push   %ebp
  8025e2:	89 e5                	mov    %esp,%ebp
  8025e4:	57                   	push   %edi
  8025e5:	56                   	push   %esi
  8025e6:	53                   	push   %ebx
  8025e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8025f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8025fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  802600:	85 c0                	test   %eax,%eax
  802602:	7f 08                	jg     80260c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80260c:	83 ec 0c             	sub    $0xc,%esp
  80260f:	50                   	push   %eax
  802610:	6a 05                	push   $0x5
  802612:	68 ff 45 80 00       	push   $0x8045ff
  802617:	6a 2a                	push   $0x2a
  802619:	68 1c 46 80 00       	push   $0x80461c
  80261e:	e8 ca f4 ff ff       	call   801aed <_panic>

00802623 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802623:	55                   	push   %ebp
  802624:	89 e5                	mov    %esp,%ebp
  802626:	57                   	push   %edi
  802627:	56                   	push   %esi
  802628:	53                   	push   %ebx
  802629:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80262c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802631:	8b 55 08             	mov    0x8(%ebp),%edx
  802634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802637:	b8 06 00 00 00       	mov    $0x6,%eax
  80263c:	89 df                	mov    %ebx,%edi
  80263e:	89 de                	mov    %ebx,%esi
  802640:	cd 30                	int    $0x30
	if(check && ret > 0)
  802642:	85 c0                	test   %eax,%eax
  802644:	7f 08                	jg     80264e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802649:	5b                   	pop    %ebx
  80264a:	5e                   	pop    %esi
  80264b:	5f                   	pop    %edi
  80264c:	5d                   	pop    %ebp
  80264d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80264e:	83 ec 0c             	sub    $0xc,%esp
  802651:	50                   	push   %eax
  802652:	6a 06                	push   $0x6
  802654:	68 ff 45 80 00       	push   $0x8045ff
  802659:	6a 2a                	push   $0x2a
  80265b:	68 1c 46 80 00       	push   $0x80461c
  802660:	e8 88 f4 ff ff       	call   801aed <_panic>

00802665 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802665:	55                   	push   %ebp
  802666:	89 e5                	mov    %esp,%ebp
  802668:	57                   	push   %edi
  802669:	56                   	push   %esi
  80266a:	53                   	push   %ebx
  80266b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80266e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802673:	8b 55 08             	mov    0x8(%ebp),%edx
  802676:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802679:	b8 08 00 00 00       	mov    $0x8,%eax
  80267e:	89 df                	mov    %ebx,%edi
  802680:	89 de                	mov    %ebx,%esi
  802682:	cd 30                	int    $0x30
	if(check && ret > 0)
  802684:	85 c0                	test   %eax,%eax
  802686:	7f 08                	jg     802690 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268b:	5b                   	pop    %ebx
  80268c:	5e                   	pop    %esi
  80268d:	5f                   	pop    %edi
  80268e:	5d                   	pop    %ebp
  80268f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802690:	83 ec 0c             	sub    $0xc,%esp
  802693:	50                   	push   %eax
  802694:	6a 08                	push   $0x8
  802696:	68 ff 45 80 00       	push   $0x8045ff
  80269b:	6a 2a                	push   $0x2a
  80269d:	68 1c 46 80 00       	push   $0x80461c
  8026a2:	e8 46 f4 ff ff       	call   801aed <_panic>

008026a7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8026a7:	55                   	push   %ebp
  8026a8:	89 e5                	mov    %esp,%ebp
  8026aa:	57                   	push   %edi
  8026ab:	56                   	push   %esi
  8026ac:	53                   	push   %ebx
  8026ad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8026b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8026c0:	89 df                	mov    %ebx,%edi
  8026c2:	89 de                	mov    %ebx,%esi
  8026c4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026c6:	85 c0                	test   %eax,%eax
  8026c8:	7f 08                	jg     8026d2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026cd:	5b                   	pop    %ebx
  8026ce:	5e                   	pop    %esi
  8026cf:	5f                   	pop    %edi
  8026d0:	5d                   	pop    %ebp
  8026d1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8026d2:	83 ec 0c             	sub    $0xc,%esp
  8026d5:	50                   	push   %eax
  8026d6:	6a 09                	push   $0x9
  8026d8:	68 ff 45 80 00       	push   $0x8045ff
  8026dd:	6a 2a                	push   $0x2a
  8026df:	68 1c 46 80 00       	push   $0x80461c
  8026e4:	e8 04 f4 ff ff       	call   801aed <_panic>

008026e9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026e9:	55                   	push   %ebp
  8026ea:	89 e5                	mov    %esp,%ebp
  8026ec:	57                   	push   %edi
  8026ed:	56                   	push   %esi
  8026ee:	53                   	push   %ebx
  8026ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8026fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  802702:	89 df                	mov    %ebx,%edi
  802704:	89 de                	mov    %ebx,%esi
  802706:	cd 30                	int    $0x30
	if(check && ret > 0)
  802708:	85 c0                	test   %eax,%eax
  80270a:	7f 08                	jg     802714 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80270c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80270f:	5b                   	pop    %ebx
  802710:	5e                   	pop    %esi
  802711:	5f                   	pop    %edi
  802712:	5d                   	pop    %ebp
  802713:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802714:	83 ec 0c             	sub    $0xc,%esp
  802717:	50                   	push   %eax
  802718:	6a 0a                	push   $0xa
  80271a:	68 ff 45 80 00       	push   $0x8045ff
  80271f:	6a 2a                	push   $0x2a
  802721:	68 1c 46 80 00       	push   $0x80461c
  802726:	e8 c2 f3 ff ff       	call   801aed <_panic>

0080272b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80272b:	55                   	push   %ebp
  80272c:	89 e5                	mov    %esp,%ebp
  80272e:	57                   	push   %edi
  80272f:	56                   	push   %esi
  802730:	53                   	push   %ebx
	asm volatile("int %1\n"
  802731:	8b 55 08             	mov    0x8(%ebp),%edx
  802734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802737:	b8 0c 00 00 00       	mov    $0xc,%eax
  80273c:	be 00 00 00 00       	mov    $0x0,%esi
  802741:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802744:	8b 7d 14             	mov    0x14(%ebp),%edi
  802747:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802749:	5b                   	pop    %ebx
  80274a:	5e                   	pop    %esi
  80274b:	5f                   	pop    %edi
  80274c:	5d                   	pop    %ebp
  80274d:	c3                   	ret    

0080274e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80274e:	55                   	push   %ebp
  80274f:	89 e5                	mov    %esp,%ebp
  802751:	57                   	push   %edi
  802752:	56                   	push   %esi
  802753:	53                   	push   %ebx
  802754:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802757:	b9 00 00 00 00       	mov    $0x0,%ecx
  80275c:	8b 55 08             	mov    0x8(%ebp),%edx
  80275f:	b8 0d 00 00 00       	mov    $0xd,%eax
  802764:	89 cb                	mov    %ecx,%ebx
  802766:	89 cf                	mov    %ecx,%edi
  802768:	89 ce                	mov    %ecx,%esi
  80276a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80276c:	85 c0                	test   %eax,%eax
  80276e:	7f 08                	jg     802778 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802773:	5b                   	pop    %ebx
  802774:	5e                   	pop    %esi
  802775:	5f                   	pop    %edi
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802778:	83 ec 0c             	sub    $0xc,%esp
  80277b:	50                   	push   %eax
  80277c:	6a 0d                	push   $0xd
  80277e:	68 ff 45 80 00       	push   $0x8045ff
  802783:	6a 2a                	push   $0x2a
  802785:	68 1c 46 80 00       	push   $0x80461c
  80278a:	e8 5e f3 ff ff       	call   801aed <_panic>

0080278f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80278f:	55                   	push   %ebp
  802790:	89 e5                	mov    %esp,%ebp
  802792:	57                   	push   %edi
  802793:	56                   	push   %esi
  802794:	53                   	push   %ebx
	asm volatile("int %1\n"
  802795:	ba 00 00 00 00       	mov    $0x0,%edx
  80279a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80279f:	89 d1                	mov    %edx,%ecx
  8027a1:	89 d3                	mov    %edx,%ebx
  8027a3:	89 d7                	mov    %edx,%edi
  8027a5:	89 d6                	mov    %edx,%esi
  8027a7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8027a9:	5b                   	pop    %ebx
  8027aa:	5e                   	pop    %esi
  8027ab:	5f                   	pop    %edi
  8027ac:	5d                   	pop    %ebp
  8027ad:	c3                   	ret    

008027ae <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8027ae:	55                   	push   %ebp
  8027af:	89 e5                	mov    %esp,%ebp
  8027b1:	57                   	push   %edi
  8027b2:	56                   	push   %esi
  8027b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8027bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027bf:	b8 0f 00 00 00       	mov    $0xf,%eax
  8027c4:	89 df                	mov    %ebx,%edi
  8027c6:	89 de                	mov    %ebx,%esi
  8027c8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8027ca:	5b                   	pop    %ebx
  8027cb:	5e                   	pop    %esi
  8027cc:	5f                   	pop    %edi
  8027cd:	5d                   	pop    %ebp
  8027ce:	c3                   	ret    

008027cf <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8027cf:	55                   	push   %ebp
  8027d0:	89 e5                	mov    %esp,%ebp
  8027d2:	57                   	push   %edi
  8027d3:	56                   	push   %esi
  8027d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027da:	8b 55 08             	mov    0x8(%ebp),%edx
  8027dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8027e5:	89 df                	mov    %ebx,%edi
  8027e7:	89 de                	mov    %ebx,%esi
  8027e9:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8027eb:	5b                   	pop    %ebx
  8027ec:	5e                   	pop    %esi
  8027ed:	5f                   	pop    %edi
  8027ee:	5d                   	pop    %ebp
  8027ef:	c3                   	ret    

008027f0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027f0:	55                   	push   %ebp
  8027f1:	89 e5                	mov    %esp,%ebp
  8027f3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8027f6:	83 3d 0c a0 80 00 00 	cmpl   $0x0,0x80a00c
  8027fd:	74 0a                	je     802809 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802802:	a3 0c a0 80 00       	mov    %eax,0x80a00c
}
  802807:	c9                   	leave  
  802808:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802809:	e8 52 fd ff ff       	call   802560 <sys_getenvid>
  80280e:	83 ec 04             	sub    $0x4,%esp
  802811:	68 07 0e 00 00       	push   $0xe07
  802816:	68 00 f0 bf ee       	push   $0xeebff000
  80281b:	50                   	push   %eax
  80281c:	e8 7d fd ff ff       	call   80259e <sys_page_alloc>
		if (r < 0) {
  802821:	83 c4 10             	add    $0x10,%esp
  802824:	85 c0                	test   %eax,%eax
  802826:	78 2c                	js     802854 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802828:	e8 33 fd ff ff       	call   802560 <sys_getenvid>
  80282d:	83 ec 08             	sub    $0x8,%esp
  802830:	68 66 28 80 00       	push   $0x802866
  802835:	50                   	push   %eax
  802836:	e8 ae fe ff ff       	call   8026e9 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80283b:	83 c4 10             	add    $0x10,%esp
  80283e:	85 c0                	test   %eax,%eax
  802840:	79 bd                	jns    8027ff <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802842:	50                   	push   %eax
  802843:	68 6c 46 80 00       	push   $0x80466c
  802848:	6a 28                	push   $0x28
  80284a:	68 a2 46 80 00       	push   $0x8046a2
  80284f:	e8 99 f2 ff ff       	call   801aed <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802854:	50                   	push   %eax
  802855:	68 2c 46 80 00       	push   $0x80462c
  80285a:	6a 23                	push   $0x23
  80285c:	68 a2 46 80 00       	push   $0x8046a2
  802861:	e8 87 f2 ff ff       	call   801aed <_panic>

00802866 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802866:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802867:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	call *%eax
  80286c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80286e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802871:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802875:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802878:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80287c:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802880:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802882:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802885:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802886:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802889:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80288a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80288b:	c3                   	ret    

0080288c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80288c:	55                   	push   %ebp
  80288d:	89 e5                	mov    %esp,%ebp
  80288f:	56                   	push   %esi
  802890:	53                   	push   %ebx
  802891:	8b 75 08             	mov    0x8(%ebp),%esi
  802894:	8b 45 0c             	mov    0xc(%ebp),%eax
  802897:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80289a:	85 c0                	test   %eax,%eax
  80289c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028a1:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8028a4:	83 ec 0c             	sub    $0xc,%esp
  8028a7:	50                   	push   %eax
  8028a8:	e8 a1 fe ff ff       	call   80274e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8028ad:	83 c4 10             	add    $0x10,%esp
  8028b0:	85 f6                	test   %esi,%esi
  8028b2:	74 14                	je     8028c8 <ipc_recv+0x3c>
  8028b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8028b9:	85 c0                	test   %eax,%eax
  8028bb:	78 09                	js     8028c6 <ipc_recv+0x3a>
  8028bd:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8028c3:	8b 52 74             	mov    0x74(%edx),%edx
  8028c6:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8028c8:	85 db                	test   %ebx,%ebx
  8028ca:	74 14                	je     8028e0 <ipc_recv+0x54>
  8028cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8028d1:	85 c0                	test   %eax,%eax
  8028d3:	78 09                	js     8028de <ipc_recv+0x52>
  8028d5:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8028db:	8b 52 78             	mov    0x78(%edx),%edx
  8028de:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8028e0:	85 c0                	test   %eax,%eax
  8028e2:	78 08                	js     8028ec <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8028e4:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8028e9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028ef:	5b                   	pop    %ebx
  8028f0:	5e                   	pop    %esi
  8028f1:	5d                   	pop    %ebp
  8028f2:	c3                   	ret    

008028f3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028f3:	55                   	push   %ebp
  8028f4:	89 e5                	mov    %esp,%ebp
  8028f6:	57                   	push   %edi
  8028f7:	56                   	push   %esi
  8028f8:	53                   	push   %ebx
  8028f9:	83 ec 0c             	sub    $0xc,%esp
  8028fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8028ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  802902:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802905:	85 db                	test   %ebx,%ebx
  802907:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80290c:	0f 44 d8             	cmove  %eax,%ebx
  80290f:	eb 05                	jmp    802916 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802911:	e8 69 fc ff ff       	call   80257f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802916:	ff 75 14             	push   0x14(%ebp)
  802919:	53                   	push   %ebx
  80291a:	56                   	push   %esi
  80291b:	57                   	push   %edi
  80291c:	e8 0a fe ff ff       	call   80272b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802921:	83 c4 10             	add    $0x10,%esp
  802924:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802927:	74 e8                	je     802911 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802929:	85 c0                	test   %eax,%eax
  80292b:	78 08                	js     802935 <ipc_send+0x42>
	}while (r<0);

}
  80292d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802930:	5b                   	pop    %ebx
  802931:	5e                   	pop    %esi
  802932:	5f                   	pop    %edi
  802933:	5d                   	pop    %ebp
  802934:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802935:	50                   	push   %eax
  802936:	68 b0 46 80 00       	push   $0x8046b0
  80293b:	6a 3d                	push   $0x3d
  80293d:	68 c4 46 80 00       	push   $0x8046c4
  802942:	e8 a6 f1 ff ff       	call   801aed <_panic>

00802947 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802947:	55                   	push   %ebp
  802948:	89 e5                	mov    %esp,%ebp
  80294a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80294d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802952:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802955:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80295b:	8b 52 50             	mov    0x50(%edx),%edx
  80295e:	39 ca                	cmp    %ecx,%edx
  802960:	74 11                	je     802973 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802962:	83 c0 01             	add    $0x1,%eax
  802965:	3d 00 04 00 00       	cmp    $0x400,%eax
  80296a:	75 e6                	jne    802952 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80296c:	b8 00 00 00 00       	mov    $0x0,%eax
  802971:	eb 0b                	jmp    80297e <ipc_find_env+0x37>
			return envs[i].env_id;
  802973:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802976:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80297b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80297e:	5d                   	pop    %ebp
  80297f:	c3                   	ret    

00802980 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802980:	55                   	push   %ebp
  802981:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802983:	8b 45 08             	mov    0x8(%ebp),%eax
  802986:	05 00 00 00 30       	add    $0x30000000,%eax
  80298b:	c1 e8 0c             	shr    $0xc,%eax
}
  80298e:	5d                   	pop    %ebp
  80298f:	c3                   	ret    

00802990 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802990:	55                   	push   %ebp
  802991:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802993:	8b 45 08             	mov    0x8(%ebp),%eax
  802996:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80299b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8029a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8029a5:	5d                   	pop    %ebp
  8029a6:	c3                   	ret    

008029a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8029a7:	55                   	push   %ebp
  8029a8:	89 e5                	mov    %esp,%ebp
  8029aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8029af:	89 c2                	mov    %eax,%edx
  8029b1:	c1 ea 16             	shr    $0x16,%edx
  8029b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029bb:	f6 c2 01             	test   $0x1,%dl
  8029be:	74 29                	je     8029e9 <fd_alloc+0x42>
  8029c0:	89 c2                	mov    %eax,%edx
  8029c2:	c1 ea 0c             	shr    $0xc,%edx
  8029c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029cc:	f6 c2 01             	test   $0x1,%dl
  8029cf:	74 18                	je     8029e9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8029d1:	05 00 10 00 00       	add    $0x1000,%eax
  8029d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8029db:	75 d2                	jne    8029af <fd_alloc+0x8>
  8029dd:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8029e2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8029e7:	eb 05                	jmp    8029ee <fd_alloc+0x47>
			return 0;
  8029e9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8029ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8029f1:	89 02                	mov    %eax,(%edx)
}
  8029f3:	89 c8                	mov    %ecx,%eax
  8029f5:	5d                   	pop    %ebp
  8029f6:	c3                   	ret    

008029f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8029f7:	55                   	push   %ebp
  8029f8:	89 e5                	mov    %esp,%ebp
  8029fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8029fd:	83 f8 1f             	cmp    $0x1f,%eax
  802a00:	77 30                	ja     802a32 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802a02:	c1 e0 0c             	shl    $0xc,%eax
  802a05:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802a0a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  802a10:	f6 c2 01             	test   $0x1,%dl
  802a13:	74 24                	je     802a39 <fd_lookup+0x42>
  802a15:	89 c2                	mov    %eax,%edx
  802a17:	c1 ea 0c             	shr    $0xc,%edx
  802a1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a21:	f6 c2 01             	test   $0x1,%dl
  802a24:	74 1a                	je     802a40 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a29:	89 02                	mov    %eax,(%edx)
	return 0;
  802a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a30:	5d                   	pop    %ebp
  802a31:	c3                   	ret    
		return -E_INVAL;
  802a32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a37:	eb f7                	jmp    802a30 <fd_lookup+0x39>
		return -E_INVAL;
  802a39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a3e:	eb f0                	jmp    802a30 <fd_lookup+0x39>
  802a40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a45:	eb e9                	jmp    802a30 <fd_lookup+0x39>

00802a47 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802a47:	55                   	push   %ebp
  802a48:	89 e5                	mov    %esp,%ebp
  802a4a:	53                   	push   %ebx
  802a4b:	83 ec 04             	sub    $0x4,%esp
  802a4e:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802a51:	b8 00 00 00 00       	mov    $0x0,%eax
  802a56:	bb 64 90 80 00       	mov    $0x809064,%ebx
		if (devtab[i]->dev_id == dev_id) {
  802a5b:	39 13                	cmp    %edx,(%ebx)
  802a5d:	74 37                	je     802a96 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  802a5f:	83 c0 01             	add    $0x1,%eax
  802a62:	8b 1c 85 4c 47 80 00 	mov    0x80474c(,%eax,4),%ebx
  802a69:	85 db                	test   %ebx,%ebx
  802a6b:	75 ee                	jne    802a5b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a6d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802a72:	8b 40 48             	mov    0x48(%eax),%eax
  802a75:	83 ec 04             	sub    $0x4,%esp
  802a78:	52                   	push   %edx
  802a79:	50                   	push   %eax
  802a7a:	68 d0 46 80 00       	push   $0x8046d0
  802a7f:	e8 44 f1 ff ff       	call   801bc8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  802a84:	83 c4 10             	add    $0x10,%esp
  802a87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  802a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a8f:	89 1a                	mov    %ebx,(%edx)
}
  802a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a94:	c9                   	leave  
  802a95:	c3                   	ret    
			return 0;
  802a96:	b8 00 00 00 00       	mov    $0x0,%eax
  802a9b:	eb ef                	jmp    802a8c <dev_lookup+0x45>

00802a9d <fd_close>:
{
  802a9d:	55                   	push   %ebp
  802a9e:	89 e5                	mov    %esp,%ebp
  802aa0:	57                   	push   %edi
  802aa1:	56                   	push   %esi
  802aa2:	53                   	push   %ebx
  802aa3:	83 ec 24             	sub    $0x24,%esp
  802aa6:	8b 75 08             	mov    0x8(%ebp),%esi
  802aa9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802aac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802aaf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802ab0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802ab6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802ab9:	50                   	push   %eax
  802aba:	e8 38 ff ff ff       	call   8029f7 <fd_lookup>
  802abf:	89 c3                	mov    %eax,%ebx
  802ac1:	83 c4 10             	add    $0x10,%esp
  802ac4:	85 c0                	test   %eax,%eax
  802ac6:	78 05                	js     802acd <fd_close+0x30>
	    || fd != fd2)
  802ac8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802acb:	74 16                	je     802ae3 <fd_close+0x46>
		return (must_exist ? r : 0);
  802acd:	89 f8                	mov    %edi,%eax
  802acf:	84 c0                	test   %al,%al
  802ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  802ad6:	0f 44 d8             	cmove  %eax,%ebx
}
  802ad9:	89 d8                	mov    %ebx,%eax
  802adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ade:	5b                   	pop    %ebx
  802adf:	5e                   	pop    %esi
  802ae0:	5f                   	pop    %edi
  802ae1:	5d                   	pop    %ebp
  802ae2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802ae3:	83 ec 08             	sub    $0x8,%esp
  802ae6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802ae9:	50                   	push   %eax
  802aea:	ff 36                	push   (%esi)
  802aec:	e8 56 ff ff ff       	call   802a47 <dev_lookup>
  802af1:	89 c3                	mov    %eax,%ebx
  802af3:	83 c4 10             	add    $0x10,%esp
  802af6:	85 c0                	test   %eax,%eax
  802af8:	78 1a                	js     802b14 <fd_close+0x77>
		if (dev->dev_close)
  802afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802afd:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802b00:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802b05:	85 c0                	test   %eax,%eax
  802b07:	74 0b                	je     802b14 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  802b09:	83 ec 0c             	sub    $0xc,%esp
  802b0c:	56                   	push   %esi
  802b0d:	ff d0                	call   *%eax
  802b0f:	89 c3                	mov    %eax,%ebx
  802b11:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802b14:	83 ec 08             	sub    $0x8,%esp
  802b17:	56                   	push   %esi
  802b18:	6a 00                	push   $0x0
  802b1a:	e8 04 fb ff ff       	call   802623 <sys_page_unmap>
	return r;
  802b1f:	83 c4 10             	add    $0x10,%esp
  802b22:	eb b5                	jmp    802ad9 <fd_close+0x3c>

00802b24 <close>:

int
close(int fdnum)
{
  802b24:	55                   	push   %ebp
  802b25:	89 e5                	mov    %esp,%ebp
  802b27:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b2d:	50                   	push   %eax
  802b2e:	ff 75 08             	push   0x8(%ebp)
  802b31:	e8 c1 fe ff ff       	call   8029f7 <fd_lookup>
  802b36:	83 c4 10             	add    $0x10,%esp
  802b39:	85 c0                	test   %eax,%eax
  802b3b:	79 02                	jns    802b3f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  802b3d:	c9                   	leave  
  802b3e:	c3                   	ret    
		return fd_close(fd, 1);
  802b3f:	83 ec 08             	sub    $0x8,%esp
  802b42:	6a 01                	push   $0x1
  802b44:	ff 75 f4             	push   -0xc(%ebp)
  802b47:	e8 51 ff ff ff       	call   802a9d <fd_close>
  802b4c:	83 c4 10             	add    $0x10,%esp
  802b4f:	eb ec                	jmp    802b3d <close+0x19>

00802b51 <close_all>:

void
close_all(void)
{
  802b51:	55                   	push   %ebp
  802b52:	89 e5                	mov    %esp,%ebp
  802b54:	53                   	push   %ebx
  802b55:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802b58:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802b5d:	83 ec 0c             	sub    $0xc,%esp
  802b60:	53                   	push   %ebx
  802b61:	e8 be ff ff ff       	call   802b24 <close>
	for (i = 0; i < MAXFD; i++)
  802b66:	83 c3 01             	add    $0x1,%ebx
  802b69:	83 c4 10             	add    $0x10,%esp
  802b6c:	83 fb 20             	cmp    $0x20,%ebx
  802b6f:	75 ec                	jne    802b5d <close_all+0xc>
}
  802b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b74:	c9                   	leave  
  802b75:	c3                   	ret    

00802b76 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b76:	55                   	push   %ebp
  802b77:	89 e5                	mov    %esp,%ebp
  802b79:	57                   	push   %edi
  802b7a:	56                   	push   %esi
  802b7b:	53                   	push   %ebx
  802b7c:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b82:	50                   	push   %eax
  802b83:	ff 75 08             	push   0x8(%ebp)
  802b86:	e8 6c fe ff ff       	call   8029f7 <fd_lookup>
  802b8b:	89 c3                	mov    %eax,%ebx
  802b8d:	83 c4 10             	add    $0x10,%esp
  802b90:	85 c0                	test   %eax,%eax
  802b92:	78 7f                	js     802c13 <dup+0x9d>
		return r;
	close(newfdnum);
  802b94:	83 ec 0c             	sub    $0xc,%esp
  802b97:	ff 75 0c             	push   0xc(%ebp)
  802b9a:	e8 85 ff ff ff       	call   802b24 <close>

	newfd = INDEX2FD(newfdnum);
  802b9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ba2:	c1 e6 0c             	shl    $0xc,%esi
  802ba5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802bab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802bae:	89 3c 24             	mov    %edi,(%esp)
  802bb1:	e8 da fd ff ff       	call   802990 <fd2data>
  802bb6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802bb8:	89 34 24             	mov    %esi,(%esp)
  802bbb:	e8 d0 fd ff ff       	call   802990 <fd2data>
  802bc0:	83 c4 10             	add    $0x10,%esp
  802bc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802bc6:	89 d8                	mov    %ebx,%eax
  802bc8:	c1 e8 16             	shr    $0x16,%eax
  802bcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802bd2:	a8 01                	test   $0x1,%al
  802bd4:	74 11                	je     802be7 <dup+0x71>
  802bd6:	89 d8                	mov    %ebx,%eax
  802bd8:	c1 e8 0c             	shr    $0xc,%eax
  802bdb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802be2:	f6 c2 01             	test   $0x1,%dl
  802be5:	75 36                	jne    802c1d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802be7:	89 f8                	mov    %edi,%eax
  802be9:	c1 e8 0c             	shr    $0xc,%eax
  802bec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802bf3:	83 ec 0c             	sub    $0xc,%esp
  802bf6:	25 07 0e 00 00       	and    $0xe07,%eax
  802bfb:	50                   	push   %eax
  802bfc:	56                   	push   %esi
  802bfd:	6a 00                	push   $0x0
  802bff:	57                   	push   %edi
  802c00:	6a 00                	push   $0x0
  802c02:	e8 da f9 ff ff       	call   8025e1 <sys_page_map>
  802c07:	89 c3                	mov    %eax,%ebx
  802c09:	83 c4 20             	add    $0x20,%esp
  802c0c:	85 c0                	test   %eax,%eax
  802c0e:	78 33                	js     802c43 <dup+0xcd>
		goto err;

	return newfdnum;
  802c10:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802c13:	89 d8                	mov    %ebx,%eax
  802c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c18:	5b                   	pop    %ebx
  802c19:	5e                   	pop    %esi
  802c1a:	5f                   	pop    %edi
  802c1b:	5d                   	pop    %ebp
  802c1c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802c1d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c24:	83 ec 0c             	sub    $0xc,%esp
  802c27:	25 07 0e 00 00       	and    $0xe07,%eax
  802c2c:	50                   	push   %eax
  802c2d:	ff 75 d4             	push   -0x2c(%ebp)
  802c30:	6a 00                	push   $0x0
  802c32:	53                   	push   %ebx
  802c33:	6a 00                	push   $0x0
  802c35:	e8 a7 f9 ff ff       	call   8025e1 <sys_page_map>
  802c3a:	89 c3                	mov    %eax,%ebx
  802c3c:	83 c4 20             	add    $0x20,%esp
  802c3f:	85 c0                	test   %eax,%eax
  802c41:	79 a4                	jns    802be7 <dup+0x71>
	sys_page_unmap(0, newfd);
  802c43:	83 ec 08             	sub    $0x8,%esp
  802c46:	56                   	push   %esi
  802c47:	6a 00                	push   $0x0
  802c49:	e8 d5 f9 ff ff       	call   802623 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802c4e:	83 c4 08             	add    $0x8,%esp
  802c51:	ff 75 d4             	push   -0x2c(%ebp)
  802c54:	6a 00                	push   $0x0
  802c56:	e8 c8 f9 ff ff       	call   802623 <sys_page_unmap>
	return r;
  802c5b:	83 c4 10             	add    $0x10,%esp
  802c5e:	eb b3                	jmp    802c13 <dup+0x9d>

00802c60 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802c60:	55                   	push   %ebp
  802c61:	89 e5                	mov    %esp,%ebp
  802c63:	56                   	push   %esi
  802c64:	53                   	push   %ebx
  802c65:	83 ec 18             	sub    $0x18,%esp
  802c68:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c6e:	50                   	push   %eax
  802c6f:	56                   	push   %esi
  802c70:	e8 82 fd ff ff       	call   8029f7 <fd_lookup>
  802c75:	83 c4 10             	add    $0x10,%esp
  802c78:	85 c0                	test   %eax,%eax
  802c7a:	78 3c                	js     802cb8 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c7c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  802c7f:	83 ec 08             	sub    $0x8,%esp
  802c82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c85:	50                   	push   %eax
  802c86:	ff 33                	push   (%ebx)
  802c88:	e8 ba fd ff ff       	call   802a47 <dev_lookup>
  802c8d:	83 c4 10             	add    $0x10,%esp
  802c90:	85 c0                	test   %eax,%eax
  802c92:	78 24                	js     802cb8 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c94:	8b 43 08             	mov    0x8(%ebx),%eax
  802c97:	83 e0 03             	and    $0x3,%eax
  802c9a:	83 f8 01             	cmp    $0x1,%eax
  802c9d:	74 20                	je     802cbf <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ca2:	8b 40 08             	mov    0x8(%eax),%eax
  802ca5:	85 c0                	test   %eax,%eax
  802ca7:	74 37                	je     802ce0 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802ca9:	83 ec 04             	sub    $0x4,%esp
  802cac:	ff 75 10             	push   0x10(%ebp)
  802caf:	ff 75 0c             	push   0xc(%ebp)
  802cb2:	53                   	push   %ebx
  802cb3:	ff d0                	call   *%eax
  802cb5:	83 c4 10             	add    $0x10,%esp
}
  802cb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802cbb:	5b                   	pop    %ebx
  802cbc:	5e                   	pop    %esi
  802cbd:	5d                   	pop    %ebp
  802cbe:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802cbf:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802cc4:	8b 40 48             	mov    0x48(%eax),%eax
  802cc7:	83 ec 04             	sub    $0x4,%esp
  802cca:	56                   	push   %esi
  802ccb:	50                   	push   %eax
  802ccc:	68 11 47 80 00       	push   $0x804711
  802cd1:	e8 f2 ee ff ff       	call   801bc8 <cprintf>
		return -E_INVAL;
  802cd6:	83 c4 10             	add    $0x10,%esp
  802cd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802cde:	eb d8                	jmp    802cb8 <read+0x58>
		return -E_NOT_SUPP;
  802ce0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802ce5:	eb d1                	jmp    802cb8 <read+0x58>

00802ce7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802ce7:	55                   	push   %ebp
  802ce8:	89 e5                	mov    %esp,%ebp
  802cea:	57                   	push   %edi
  802ceb:	56                   	push   %esi
  802cec:	53                   	push   %ebx
  802ced:	83 ec 0c             	sub    $0xc,%esp
  802cf0:	8b 7d 08             	mov    0x8(%ebp),%edi
  802cf3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cfb:	eb 02                	jmp    802cff <readn+0x18>
  802cfd:	01 c3                	add    %eax,%ebx
  802cff:	39 f3                	cmp    %esi,%ebx
  802d01:	73 21                	jae    802d24 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d03:	83 ec 04             	sub    $0x4,%esp
  802d06:	89 f0                	mov    %esi,%eax
  802d08:	29 d8                	sub    %ebx,%eax
  802d0a:	50                   	push   %eax
  802d0b:	89 d8                	mov    %ebx,%eax
  802d0d:	03 45 0c             	add    0xc(%ebp),%eax
  802d10:	50                   	push   %eax
  802d11:	57                   	push   %edi
  802d12:	e8 49 ff ff ff       	call   802c60 <read>
		if (m < 0)
  802d17:	83 c4 10             	add    $0x10,%esp
  802d1a:	85 c0                	test   %eax,%eax
  802d1c:	78 04                	js     802d22 <readn+0x3b>
			return m;
		if (m == 0)
  802d1e:	75 dd                	jne    802cfd <readn+0x16>
  802d20:	eb 02                	jmp    802d24 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d22:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802d24:	89 d8                	mov    %ebx,%eax
  802d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d29:	5b                   	pop    %ebx
  802d2a:	5e                   	pop    %esi
  802d2b:	5f                   	pop    %edi
  802d2c:	5d                   	pop    %ebp
  802d2d:	c3                   	ret    

00802d2e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802d2e:	55                   	push   %ebp
  802d2f:	89 e5                	mov    %esp,%ebp
  802d31:	56                   	push   %esi
  802d32:	53                   	push   %ebx
  802d33:	83 ec 18             	sub    $0x18,%esp
  802d36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d3c:	50                   	push   %eax
  802d3d:	53                   	push   %ebx
  802d3e:	e8 b4 fc ff ff       	call   8029f7 <fd_lookup>
  802d43:	83 c4 10             	add    $0x10,%esp
  802d46:	85 c0                	test   %eax,%eax
  802d48:	78 37                	js     802d81 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d4a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802d4d:	83 ec 08             	sub    $0x8,%esp
  802d50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d53:	50                   	push   %eax
  802d54:	ff 36                	push   (%esi)
  802d56:	e8 ec fc ff ff       	call   802a47 <dev_lookup>
  802d5b:	83 c4 10             	add    $0x10,%esp
  802d5e:	85 c0                	test   %eax,%eax
  802d60:	78 1f                	js     802d81 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d62:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802d66:	74 20                	je     802d88 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d6b:	8b 40 0c             	mov    0xc(%eax),%eax
  802d6e:	85 c0                	test   %eax,%eax
  802d70:	74 37                	je     802da9 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d72:	83 ec 04             	sub    $0x4,%esp
  802d75:	ff 75 10             	push   0x10(%ebp)
  802d78:	ff 75 0c             	push   0xc(%ebp)
  802d7b:	56                   	push   %esi
  802d7c:	ff d0                	call   *%eax
  802d7e:	83 c4 10             	add    $0x10,%esp
}
  802d81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d84:	5b                   	pop    %ebx
  802d85:	5e                   	pop    %esi
  802d86:	5d                   	pop    %ebp
  802d87:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d88:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802d8d:	8b 40 48             	mov    0x48(%eax),%eax
  802d90:	83 ec 04             	sub    $0x4,%esp
  802d93:	53                   	push   %ebx
  802d94:	50                   	push   %eax
  802d95:	68 2d 47 80 00       	push   $0x80472d
  802d9a:	e8 29 ee ff ff       	call   801bc8 <cprintf>
		return -E_INVAL;
  802d9f:	83 c4 10             	add    $0x10,%esp
  802da2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802da7:	eb d8                	jmp    802d81 <write+0x53>
		return -E_NOT_SUPP;
  802da9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802dae:	eb d1                	jmp    802d81 <write+0x53>

00802db0 <seek>:

int
seek(int fdnum, off_t offset)
{
  802db0:	55                   	push   %ebp
  802db1:	89 e5                	mov    %esp,%ebp
  802db3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802db9:	50                   	push   %eax
  802dba:	ff 75 08             	push   0x8(%ebp)
  802dbd:	e8 35 fc ff ff       	call   8029f7 <fd_lookup>
  802dc2:	83 c4 10             	add    $0x10,%esp
  802dc5:	85 c0                	test   %eax,%eax
  802dc7:	78 0e                	js     802dd7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  802dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dcf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802dd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802dd7:	c9                   	leave  
  802dd8:	c3                   	ret    

00802dd9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802dd9:	55                   	push   %ebp
  802dda:	89 e5                	mov    %esp,%ebp
  802ddc:	56                   	push   %esi
  802ddd:	53                   	push   %ebx
  802dde:	83 ec 18             	sub    $0x18,%esp
  802de1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802de4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802de7:	50                   	push   %eax
  802de8:	53                   	push   %ebx
  802de9:	e8 09 fc ff ff       	call   8029f7 <fd_lookup>
  802dee:	83 c4 10             	add    $0x10,%esp
  802df1:	85 c0                	test   %eax,%eax
  802df3:	78 34                	js     802e29 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802df5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802df8:	83 ec 08             	sub    $0x8,%esp
  802dfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dfe:	50                   	push   %eax
  802dff:	ff 36                	push   (%esi)
  802e01:	e8 41 fc ff ff       	call   802a47 <dev_lookup>
  802e06:	83 c4 10             	add    $0x10,%esp
  802e09:	85 c0                	test   %eax,%eax
  802e0b:	78 1c                	js     802e29 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e0d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802e11:	74 1d                	je     802e30 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e16:	8b 40 18             	mov    0x18(%eax),%eax
  802e19:	85 c0                	test   %eax,%eax
  802e1b:	74 34                	je     802e51 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802e1d:	83 ec 08             	sub    $0x8,%esp
  802e20:	ff 75 0c             	push   0xc(%ebp)
  802e23:	56                   	push   %esi
  802e24:	ff d0                	call   *%eax
  802e26:	83 c4 10             	add    $0x10,%esp
}
  802e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e2c:	5b                   	pop    %ebx
  802e2d:	5e                   	pop    %esi
  802e2e:	5d                   	pop    %ebp
  802e2f:	c3                   	ret    
			thisenv->env_id, fdnum);
  802e30:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802e35:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802e38:	83 ec 04             	sub    $0x4,%esp
  802e3b:	53                   	push   %ebx
  802e3c:	50                   	push   %eax
  802e3d:	68 f0 46 80 00       	push   $0x8046f0
  802e42:	e8 81 ed ff ff       	call   801bc8 <cprintf>
		return -E_INVAL;
  802e47:	83 c4 10             	add    $0x10,%esp
  802e4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e4f:	eb d8                	jmp    802e29 <ftruncate+0x50>
		return -E_NOT_SUPP;
  802e51:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e56:	eb d1                	jmp    802e29 <ftruncate+0x50>

00802e58 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802e58:	55                   	push   %ebp
  802e59:	89 e5                	mov    %esp,%ebp
  802e5b:	56                   	push   %esi
  802e5c:	53                   	push   %ebx
  802e5d:	83 ec 18             	sub    $0x18,%esp
  802e60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e66:	50                   	push   %eax
  802e67:	ff 75 08             	push   0x8(%ebp)
  802e6a:	e8 88 fb ff ff       	call   8029f7 <fd_lookup>
  802e6f:	83 c4 10             	add    $0x10,%esp
  802e72:	85 c0                	test   %eax,%eax
  802e74:	78 49                	js     802ebf <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e76:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802e79:	83 ec 08             	sub    $0x8,%esp
  802e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e7f:	50                   	push   %eax
  802e80:	ff 36                	push   (%esi)
  802e82:	e8 c0 fb ff ff       	call   802a47 <dev_lookup>
  802e87:	83 c4 10             	add    $0x10,%esp
  802e8a:	85 c0                	test   %eax,%eax
  802e8c:	78 31                	js     802ebf <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  802e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e91:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e95:	74 2f                	je     802ec6 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e97:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e9a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802ea1:	00 00 00 
	stat->st_isdir = 0;
  802ea4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802eab:	00 00 00 
	stat->st_dev = dev;
  802eae:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802eb4:	83 ec 08             	sub    $0x8,%esp
  802eb7:	53                   	push   %ebx
  802eb8:	56                   	push   %esi
  802eb9:	ff 50 14             	call   *0x14(%eax)
  802ebc:	83 c4 10             	add    $0x10,%esp
}
  802ebf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ec2:	5b                   	pop    %ebx
  802ec3:	5e                   	pop    %esi
  802ec4:	5d                   	pop    %ebp
  802ec5:	c3                   	ret    
		return -E_NOT_SUPP;
  802ec6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802ecb:	eb f2                	jmp    802ebf <fstat+0x67>

00802ecd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802ecd:	55                   	push   %ebp
  802ece:	89 e5                	mov    %esp,%ebp
  802ed0:	56                   	push   %esi
  802ed1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ed2:	83 ec 08             	sub    $0x8,%esp
  802ed5:	6a 00                	push   $0x0
  802ed7:	ff 75 08             	push   0x8(%ebp)
  802eda:	e8 e4 01 00 00       	call   8030c3 <open>
  802edf:	89 c3                	mov    %eax,%ebx
  802ee1:	83 c4 10             	add    $0x10,%esp
  802ee4:	85 c0                	test   %eax,%eax
  802ee6:	78 1b                	js     802f03 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ee8:	83 ec 08             	sub    $0x8,%esp
  802eeb:	ff 75 0c             	push   0xc(%ebp)
  802eee:	50                   	push   %eax
  802eef:	e8 64 ff ff ff       	call   802e58 <fstat>
  802ef4:	89 c6                	mov    %eax,%esi
	close(fd);
  802ef6:	89 1c 24             	mov    %ebx,(%esp)
  802ef9:	e8 26 fc ff ff       	call   802b24 <close>
	return r;
  802efe:	83 c4 10             	add    $0x10,%esp
  802f01:	89 f3                	mov    %esi,%ebx
}
  802f03:	89 d8                	mov    %ebx,%eax
  802f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f08:	5b                   	pop    %ebx
  802f09:	5e                   	pop    %esi
  802f0a:	5d                   	pop    %ebp
  802f0b:	c3                   	ret    

00802f0c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802f0c:	55                   	push   %ebp
  802f0d:	89 e5                	mov    %esp,%ebp
  802f0f:	56                   	push   %esi
  802f10:	53                   	push   %ebx
  802f11:	89 c6                	mov    %eax,%esi
  802f13:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802f15:	83 3d 00 c0 80 00 00 	cmpl   $0x0,0x80c000
  802f1c:	74 27                	je     802f45 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802f1e:	6a 07                	push   $0x7
  802f20:	68 00 b0 80 00       	push   $0x80b000
  802f25:	56                   	push   %esi
  802f26:	ff 35 00 c0 80 00    	push   0x80c000
  802f2c:	e8 c2 f9 ff ff       	call   8028f3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802f31:	83 c4 0c             	add    $0xc,%esp
  802f34:	6a 00                	push   $0x0
  802f36:	53                   	push   %ebx
  802f37:	6a 00                	push   $0x0
  802f39:	e8 4e f9 ff ff       	call   80288c <ipc_recv>
}
  802f3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f41:	5b                   	pop    %ebx
  802f42:	5e                   	pop    %esi
  802f43:	5d                   	pop    %ebp
  802f44:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802f45:	83 ec 0c             	sub    $0xc,%esp
  802f48:	6a 01                	push   $0x1
  802f4a:	e8 f8 f9 ff ff       	call   802947 <ipc_find_env>
  802f4f:	a3 00 c0 80 00       	mov    %eax,0x80c000
  802f54:	83 c4 10             	add    $0x10,%esp
  802f57:	eb c5                	jmp    802f1e <fsipc+0x12>

00802f59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802f59:	55                   	push   %ebp
  802f5a:	89 e5                	mov    %esp,%ebp
  802f5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f62:	8b 40 0c             	mov    0xc(%eax),%eax
  802f65:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f6d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f72:	ba 00 00 00 00       	mov    $0x0,%edx
  802f77:	b8 02 00 00 00       	mov    $0x2,%eax
  802f7c:	e8 8b ff ff ff       	call   802f0c <fsipc>
}
  802f81:	c9                   	leave  
  802f82:	c3                   	ret    

00802f83 <devfile_flush>:
{
  802f83:	55                   	push   %ebp
  802f84:	89 e5                	mov    %esp,%ebp
  802f86:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f89:	8b 45 08             	mov    0x8(%ebp),%eax
  802f8c:	8b 40 0c             	mov    0xc(%eax),%eax
  802f8f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f94:	ba 00 00 00 00       	mov    $0x0,%edx
  802f99:	b8 06 00 00 00       	mov    $0x6,%eax
  802f9e:	e8 69 ff ff ff       	call   802f0c <fsipc>
}
  802fa3:	c9                   	leave  
  802fa4:	c3                   	ret    

00802fa5 <devfile_stat>:
{
  802fa5:	55                   	push   %ebp
  802fa6:	89 e5                	mov    %esp,%ebp
  802fa8:	53                   	push   %ebx
  802fa9:	83 ec 04             	sub    $0x4,%esp
  802fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802faf:	8b 45 08             	mov    0x8(%ebp),%eax
  802fb2:	8b 40 0c             	mov    0xc(%eax),%eax
  802fb5:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802fba:	ba 00 00 00 00       	mov    $0x0,%edx
  802fbf:	b8 05 00 00 00       	mov    $0x5,%eax
  802fc4:	e8 43 ff ff ff       	call   802f0c <fsipc>
  802fc9:	85 c0                	test   %eax,%eax
  802fcb:	78 2c                	js     802ff9 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802fcd:	83 ec 08             	sub    $0x8,%esp
  802fd0:	68 00 b0 80 00       	push   $0x80b000
  802fd5:	53                   	push   %ebx
  802fd6:	e8 c7 f1 ff ff       	call   8021a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802fdb:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802fe0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802fe6:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802feb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802ff1:	83 c4 10             	add    $0x10,%esp
  802ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ff9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ffc:	c9                   	leave  
  802ffd:	c3                   	ret    

00802ffe <devfile_write>:
{
  802ffe:	55                   	push   %ebp
  802fff:	89 e5                	mov    %esp,%ebp
  803001:	83 ec 0c             	sub    $0xc,%esp
  803004:	8b 45 10             	mov    0x10(%ebp),%eax
  803007:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80300c:	39 d0                	cmp    %edx,%eax
  80300e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803011:	8b 55 08             	mov    0x8(%ebp),%edx
  803014:	8b 52 0c             	mov    0xc(%edx),%edx
  803017:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  80301d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  803022:	50                   	push   %eax
  803023:	ff 75 0c             	push   0xc(%ebp)
  803026:	68 08 b0 80 00       	push   $0x80b008
  80302b:	e8 08 f3 ff ff       	call   802338 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  803030:	ba 00 00 00 00       	mov    $0x0,%edx
  803035:	b8 04 00 00 00       	mov    $0x4,%eax
  80303a:	e8 cd fe ff ff       	call   802f0c <fsipc>
}
  80303f:	c9                   	leave  
  803040:	c3                   	ret    

00803041 <devfile_read>:
{
  803041:	55                   	push   %ebp
  803042:	89 e5                	mov    %esp,%ebp
  803044:	56                   	push   %esi
  803045:	53                   	push   %ebx
  803046:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  803049:	8b 45 08             	mov    0x8(%ebp),%eax
  80304c:	8b 40 0c             	mov    0xc(%eax),%eax
  80304f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803054:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80305a:	ba 00 00 00 00       	mov    $0x0,%edx
  80305f:	b8 03 00 00 00       	mov    $0x3,%eax
  803064:	e8 a3 fe ff ff       	call   802f0c <fsipc>
  803069:	89 c3                	mov    %eax,%ebx
  80306b:	85 c0                	test   %eax,%eax
  80306d:	78 1f                	js     80308e <devfile_read+0x4d>
	assert(r <= n);
  80306f:	39 f0                	cmp    %esi,%eax
  803071:	77 24                	ja     803097 <devfile_read+0x56>
	assert(r <= PGSIZE);
  803073:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803078:	7f 33                	jg     8030ad <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80307a:	83 ec 04             	sub    $0x4,%esp
  80307d:	50                   	push   %eax
  80307e:	68 00 b0 80 00       	push   $0x80b000
  803083:	ff 75 0c             	push   0xc(%ebp)
  803086:	e8 ad f2 ff ff       	call   802338 <memmove>
	return r;
  80308b:	83 c4 10             	add    $0x10,%esp
}
  80308e:	89 d8                	mov    %ebx,%eax
  803090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803093:	5b                   	pop    %ebx
  803094:	5e                   	pop    %esi
  803095:	5d                   	pop    %ebp
  803096:	c3                   	ret    
	assert(r <= n);
  803097:	68 60 47 80 00       	push   $0x804760
  80309c:	68 5d 3d 80 00       	push   $0x803d5d
  8030a1:	6a 7c                	push   $0x7c
  8030a3:	68 67 47 80 00       	push   $0x804767
  8030a8:	e8 40 ea ff ff       	call   801aed <_panic>
	assert(r <= PGSIZE);
  8030ad:	68 72 47 80 00       	push   $0x804772
  8030b2:	68 5d 3d 80 00       	push   $0x803d5d
  8030b7:	6a 7d                	push   $0x7d
  8030b9:	68 67 47 80 00       	push   $0x804767
  8030be:	e8 2a ea ff ff       	call   801aed <_panic>

008030c3 <open>:
{
  8030c3:	55                   	push   %ebp
  8030c4:	89 e5                	mov    %esp,%ebp
  8030c6:	56                   	push   %esi
  8030c7:	53                   	push   %ebx
  8030c8:	83 ec 1c             	sub    $0x1c,%esp
  8030cb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8030ce:	56                   	push   %esi
  8030cf:	e8 93 f0 ff ff       	call   802167 <strlen>
  8030d4:	83 c4 10             	add    $0x10,%esp
  8030d7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8030dc:	7f 6c                	jg     80314a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8030de:	83 ec 0c             	sub    $0xc,%esp
  8030e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030e4:	50                   	push   %eax
  8030e5:	e8 bd f8 ff ff       	call   8029a7 <fd_alloc>
  8030ea:	89 c3                	mov    %eax,%ebx
  8030ec:	83 c4 10             	add    $0x10,%esp
  8030ef:	85 c0                	test   %eax,%eax
  8030f1:	78 3c                	js     80312f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8030f3:	83 ec 08             	sub    $0x8,%esp
  8030f6:	56                   	push   %esi
  8030f7:	68 00 b0 80 00       	push   $0x80b000
  8030fc:	e8 a1 f0 ff ff       	call   8021a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803101:	8b 45 0c             	mov    0xc(%ebp),%eax
  803104:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803109:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80310c:	b8 01 00 00 00       	mov    $0x1,%eax
  803111:	e8 f6 fd ff ff       	call   802f0c <fsipc>
  803116:	89 c3                	mov    %eax,%ebx
  803118:	83 c4 10             	add    $0x10,%esp
  80311b:	85 c0                	test   %eax,%eax
  80311d:	78 19                	js     803138 <open+0x75>
	return fd2num(fd);
  80311f:	83 ec 0c             	sub    $0xc,%esp
  803122:	ff 75 f4             	push   -0xc(%ebp)
  803125:	e8 56 f8 ff ff       	call   802980 <fd2num>
  80312a:	89 c3                	mov    %eax,%ebx
  80312c:	83 c4 10             	add    $0x10,%esp
}
  80312f:	89 d8                	mov    %ebx,%eax
  803131:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803134:	5b                   	pop    %ebx
  803135:	5e                   	pop    %esi
  803136:	5d                   	pop    %ebp
  803137:	c3                   	ret    
		fd_close(fd, 0);
  803138:	83 ec 08             	sub    $0x8,%esp
  80313b:	6a 00                	push   $0x0
  80313d:	ff 75 f4             	push   -0xc(%ebp)
  803140:	e8 58 f9 ff ff       	call   802a9d <fd_close>
		return r;
  803145:	83 c4 10             	add    $0x10,%esp
  803148:	eb e5                	jmp    80312f <open+0x6c>
		return -E_BAD_PATH;
  80314a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80314f:	eb de                	jmp    80312f <open+0x6c>

00803151 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803151:	55                   	push   %ebp
  803152:	89 e5                	mov    %esp,%ebp
  803154:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803157:	ba 00 00 00 00       	mov    $0x0,%edx
  80315c:	b8 08 00 00 00       	mov    $0x8,%eax
  803161:	e8 a6 fd ff ff       	call   802f0c <fsipc>
}
  803166:	c9                   	leave  
  803167:	c3                   	ret    

00803168 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803168:	55                   	push   %ebp
  803169:	89 e5                	mov    %esp,%ebp
  80316b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80316e:	89 c2                	mov    %eax,%edx
  803170:	c1 ea 16             	shr    $0x16,%edx
  803173:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80317a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80317f:	f6 c1 01             	test   $0x1,%cl
  803182:	74 1c                	je     8031a0 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  803184:	c1 e8 0c             	shr    $0xc,%eax
  803187:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80318e:	a8 01                	test   $0x1,%al
  803190:	74 0e                	je     8031a0 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803192:	c1 e8 0c             	shr    $0xc,%eax
  803195:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80319c:	ef 
  80319d:	0f b7 d2             	movzwl %dx,%edx
}
  8031a0:	89 d0                	mov    %edx,%eax
  8031a2:	5d                   	pop    %ebp
  8031a3:	c3                   	ret    

008031a4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8031a4:	55                   	push   %ebp
  8031a5:	89 e5                	mov    %esp,%ebp
  8031a7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8031aa:	68 7e 47 80 00       	push   $0x80477e
  8031af:	ff 75 0c             	push   0xc(%ebp)
  8031b2:	e8 eb ef ff ff       	call   8021a2 <strcpy>
	return 0;
}
  8031b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8031bc:	c9                   	leave  
  8031bd:	c3                   	ret    

008031be <devsock_close>:
{
  8031be:	55                   	push   %ebp
  8031bf:	89 e5                	mov    %esp,%ebp
  8031c1:	53                   	push   %ebx
  8031c2:	83 ec 10             	sub    $0x10,%esp
  8031c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8031c8:	53                   	push   %ebx
  8031c9:	e8 9a ff ff ff       	call   803168 <pageref>
  8031ce:	89 c2                	mov    %eax,%edx
  8031d0:	83 c4 10             	add    $0x10,%esp
		return 0;
  8031d3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8031d8:	83 fa 01             	cmp    $0x1,%edx
  8031db:	74 05                	je     8031e2 <devsock_close+0x24>
}
  8031dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031e0:	c9                   	leave  
  8031e1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8031e2:	83 ec 0c             	sub    $0xc,%esp
  8031e5:	ff 73 0c             	push   0xc(%ebx)
  8031e8:	e8 b7 02 00 00       	call   8034a4 <nsipc_close>
  8031ed:	83 c4 10             	add    $0x10,%esp
  8031f0:	eb eb                	jmp    8031dd <devsock_close+0x1f>

008031f2 <devsock_write>:
{
  8031f2:	55                   	push   %ebp
  8031f3:	89 e5                	mov    %esp,%ebp
  8031f5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8031f8:	6a 00                	push   $0x0
  8031fa:	ff 75 10             	push   0x10(%ebp)
  8031fd:	ff 75 0c             	push   0xc(%ebp)
  803200:	8b 45 08             	mov    0x8(%ebp),%eax
  803203:	ff 70 0c             	push   0xc(%eax)
  803206:	e8 79 03 00 00       	call   803584 <nsipc_send>
}
  80320b:	c9                   	leave  
  80320c:	c3                   	ret    

0080320d <devsock_read>:
{
  80320d:	55                   	push   %ebp
  80320e:	89 e5                	mov    %esp,%ebp
  803210:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803213:	6a 00                	push   $0x0
  803215:	ff 75 10             	push   0x10(%ebp)
  803218:	ff 75 0c             	push   0xc(%ebp)
  80321b:	8b 45 08             	mov    0x8(%ebp),%eax
  80321e:	ff 70 0c             	push   0xc(%eax)
  803221:	e8 ef 02 00 00       	call   803515 <nsipc_recv>
}
  803226:	c9                   	leave  
  803227:	c3                   	ret    

00803228 <fd2sockid>:
{
  803228:	55                   	push   %ebp
  803229:	89 e5                	mov    %esp,%ebp
  80322b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80322e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803231:	52                   	push   %edx
  803232:	50                   	push   %eax
  803233:	e8 bf f7 ff ff       	call   8029f7 <fd_lookup>
  803238:	83 c4 10             	add    $0x10,%esp
  80323b:	85 c0                	test   %eax,%eax
  80323d:	78 10                	js     80324f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80323f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803242:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  803248:	39 08                	cmp    %ecx,(%eax)
  80324a:	75 05                	jne    803251 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80324c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80324f:	c9                   	leave  
  803250:	c3                   	ret    
		return -E_NOT_SUPP;
  803251:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803256:	eb f7                	jmp    80324f <fd2sockid+0x27>

00803258 <alloc_sockfd>:
{
  803258:	55                   	push   %ebp
  803259:	89 e5                	mov    %esp,%ebp
  80325b:	56                   	push   %esi
  80325c:	53                   	push   %ebx
  80325d:	83 ec 1c             	sub    $0x1c,%esp
  803260:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  803262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803265:	50                   	push   %eax
  803266:	e8 3c f7 ff ff       	call   8029a7 <fd_alloc>
  80326b:	89 c3                	mov    %eax,%ebx
  80326d:	83 c4 10             	add    $0x10,%esp
  803270:	85 c0                	test   %eax,%eax
  803272:	78 43                	js     8032b7 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  803274:	83 ec 04             	sub    $0x4,%esp
  803277:	68 07 04 00 00       	push   $0x407
  80327c:	ff 75 f4             	push   -0xc(%ebp)
  80327f:	6a 00                	push   $0x0
  803281:	e8 18 f3 ff ff       	call   80259e <sys_page_alloc>
  803286:	89 c3                	mov    %eax,%ebx
  803288:	83 c4 10             	add    $0x10,%esp
  80328b:	85 c0                	test   %eax,%eax
  80328d:	78 28                	js     8032b7 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80328f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803292:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803298:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80329d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8032a4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8032a7:	83 ec 0c             	sub    $0xc,%esp
  8032aa:	50                   	push   %eax
  8032ab:	e8 d0 f6 ff ff       	call   802980 <fd2num>
  8032b0:	89 c3                	mov    %eax,%ebx
  8032b2:	83 c4 10             	add    $0x10,%esp
  8032b5:	eb 0c                	jmp    8032c3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8032b7:	83 ec 0c             	sub    $0xc,%esp
  8032ba:	56                   	push   %esi
  8032bb:	e8 e4 01 00 00       	call   8034a4 <nsipc_close>
		return r;
  8032c0:	83 c4 10             	add    $0x10,%esp
}
  8032c3:	89 d8                	mov    %ebx,%eax
  8032c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032c8:	5b                   	pop    %ebx
  8032c9:	5e                   	pop    %esi
  8032ca:	5d                   	pop    %ebp
  8032cb:	c3                   	ret    

008032cc <accept>:
{
  8032cc:	55                   	push   %ebp
  8032cd:	89 e5                	mov    %esp,%ebp
  8032cf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8032d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8032d5:	e8 4e ff ff ff       	call   803228 <fd2sockid>
  8032da:	85 c0                	test   %eax,%eax
  8032dc:	78 1b                	js     8032f9 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8032de:	83 ec 04             	sub    $0x4,%esp
  8032e1:	ff 75 10             	push   0x10(%ebp)
  8032e4:	ff 75 0c             	push   0xc(%ebp)
  8032e7:	50                   	push   %eax
  8032e8:	e8 0e 01 00 00       	call   8033fb <nsipc_accept>
  8032ed:	83 c4 10             	add    $0x10,%esp
  8032f0:	85 c0                	test   %eax,%eax
  8032f2:	78 05                	js     8032f9 <accept+0x2d>
	return alloc_sockfd(r);
  8032f4:	e8 5f ff ff ff       	call   803258 <alloc_sockfd>
}
  8032f9:	c9                   	leave  
  8032fa:	c3                   	ret    

008032fb <bind>:
{
  8032fb:	55                   	push   %ebp
  8032fc:	89 e5                	mov    %esp,%ebp
  8032fe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803301:	8b 45 08             	mov    0x8(%ebp),%eax
  803304:	e8 1f ff ff ff       	call   803228 <fd2sockid>
  803309:	85 c0                	test   %eax,%eax
  80330b:	78 12                	js     80331f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80330d:	83 ec 04             	sub    $0x4,%esp
  803310:	ff 75 10             	push   0x10(%ebp)
  803313:	ff 75 0c             	push   0xc(%ebp)
  803316:	50                   	push   %eax
  803317:	e8 31 01 00 00       	call   80344d <nsipc_bind>
  80331c:	83 c4 10             	add    $0x10,%esp
}
  80331f:	c9                   	leave  
  803320:	c3                   	ret    

00803321 <shutdown>:
{
  803321:	55                   	push   %ebp
  803322:	89 e5                	mov    %esp,%ebp
  803324:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803327:	8b 45 08             	mov    0x8(%ebp),%eax
  80332a:	e8 f9 fe ff ff       	call   803228 <fd2sockid>
  80332f:	85 c0                	test   %eax,%eax
  803331:	78 0f                	js     803342 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  803333:	83 ec 08             	sub    $0x8,%esp
  803336:	ff 75 0c             	push   0xc(%ebp)
  803339:	50                   	push   %eax
  80333a:	e8 43 01 00 00       	call   803482 <nsipc_shutdown>
  80333f:	83 c4 10             	add    $0x10,%esp
}
  803342:	c9                   	leave  
  803343:	c3                   	ret    

00803344 <connect>:
{
  803344:	55                   	push   %ebp
  803345:	89 e5                	mov    %esp,%ebp
  803347:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80334a:	8b 45 08             	mov    0x8(%ebp),%eax
  80334d:	e8 d6 fe ff ff       	call   803228 <fd2sockid>
  803352:	85 c0                	test   %eax,%eax
  803354:	78 12                	js     803368 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  803356:	83 ec 04             	sub    $0x4,%esp
  803359:	ff 75 10             	push   0x10(%ebp)
  80335c:	ff 75 0c             	push   0xc(%ebp)
  80335f:	50                   	push   %eax
  803360:	e8 59 01 00 00       	call   8034be <nsipc_connect>
  803365:	83 c4 10             	add    $0x10,%esp
}
  803368:	c9                   	leave  
  803369:	c3                   	ret    

0080336a <listen>:
{
  80336a:	55                   	push   %ebp
  80336b:	89 e5                	mov    %esp,%ebp
  80336d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803370:	8b 45 08             	mov    0x8(%ebp),%eax
  803373:	e8 b0 fe ff ff       	call   803228 <fd2sockid>
  803378:	85 c0                	test   %eax,%eax
  80337a:	78 0f                	js     80338b <listen+0x21>
	return nsipc_listen(r, backlog);
  80337c:	83 ec 08             	sub    $0x8,%esp
  80337f:	ff 75 0c             	push   0xc(%ebp)
  803382:	50                   	push   %eax
  803383:	e8 6b 01 00 00       	call   8034f3 <nsipc_listen>
  803388:	83 c4 10             	add    $0x10,%esp
}
  80338b:	c9                   	leave  
  80338c:	c3                   	ret    

0080338d <socket>:

int
socket(int domain, int type, int protocol)
{
  80338d:	55                   	push   %ebp
  80338e:	89 e5                	mov    %esp,%ebp
  803390:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803393:	ff 75 10             	push   0x10(%ebp)
  803396:	ff 75 0c             	push   0xc(%ebp)
  803399:	ff 75 08             	push   0x8(%ebp)
  80339c:	e8 41 02 00 00       	call   8035e2 <nsipc_socket>
  8033a1:	83 c4 10             	add    $0x10,%esp
  8033a4:	85 c0                	test   %eax,%eax
  8033a6:	78 05                	js     8033ad <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8033a8:	e8 ab fe ff ff       	call   803258 <alloc_sockfd>
}
  8033ad:	c9                   	leave  
  8033ae:	c3                   	ret    

008033af <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8033af:	55                   	push   %ebp
  8033b0:	89 e5                	mov    %esp,%ebp
  8033b2:	53                   	push   %ebx
  8033b3:	83 ec 04             	sub    $0x4,%esp
  8033b6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8033b8:	83 3d 00 e0 80 00 00 	cmpl   $0x0,0x80e000
  8033bf:	74 26                	je     8033e7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8033c1:	6a 07                	push   $0x7
  8033c3:	68 00 d0 80 00       	push   $0x80d000
  8033c8:	53                   	push   %ebx
  8033c9:	ff 35 00 e0 80 00    	push   0x80e000
  8033cf:	e8 1f f5 ff ff       	call   8028f3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8033d4:	83 c4 0c             	add    $0xc,%esp
  8033d7:	6a 00                	push   $0x0
  8033d9:	6a 00                	push   $0x0
  8033db:	6a 00                	push   $0x0
  8033dd:	e8 aa f4 ff ff       	call   80288c <ipc_recv>
}
  8033e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033e5:	c9                   	leave  
  8033e6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8033e7:	83 ec 0c             	sub    $0xc,%esp
  8033ea:	6a 02                	push   $0x2
  8033ec:	e8 56 f5 ff ff       	call   802947 <ipc_find_env>
  8033f1:	a3 00 e0 80 00       	mov    %eax,0x80e000
  8033f6:	83 c4 10             	add    $0x10,%esp
  8033f9:	eb c6                	jmp    8033c1 <nsipc+0x12>

008033fb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8033fb:	55                   	push   %ebp
  8033fc:	89 e5                	mov    %esp,%ebp
  8033fe:	56                   	push   %esi
  8033ff:	53                   	push   %ebx
  803400:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803403:	8b 45 08             	mov    0x8(%ebp),%eax
  803406:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80340b:	8b 06                	mov    (%esi),%eax
  80340d:	a3 04 d0 80 00       	mov    %eax,0x80d004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803412:	b8 01 00 00 00       	mov    $0x1,%eax
  803417:	e8 93 ff ff ff       	call   8033af <nsipc>
  80341c:	89 c3                	mov    %eax,%ebx
  80341e:	85 c0                	test   %eax,%eax
  803420:	79 09                	jns    80342b <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  803422:	89 d8                	mov    %ebx,%eax
  803424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803427:	5b                   	pop    %ebx
  803428:	5e                   	pop    %esi
  803429:	5d                   	pop    %ebp
  80342a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80342b:	83 ec 04             	sub    $0x4,%esp
  80342e:	ff 35 10 d0 80 00    	push   0x80d010
  803434:	68 00 d0 80 00       	push   $0x80d000
  803439:	ff 75 0c             	push   0xc(%ebp)
  80343c:	e8 f7 ee ff ff       	call   802338 <memmove>
		*addrlen = ret->ret_addrlen;
  803441:	a1 10 d0 80 00       	mov    0x80d010,%eax
  803446:	89 06                	mov    %eax,(%esi)
  803448:	83 c4 10             	add    $0x10,%esp
	return r;
  80344b:	eb d5                	jmp    803422 <nsipc_accept+0x27>

0080344d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80344d:	55                   	push   %ebp
  80344e:	89 e5                	mov    %esp,%ebp
  803450:	53                   	push   %ebx
  803451:	83 ec 08             	sub    $0x8,%esp
  803454:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803457:	8b 45 08             	mov    0x8(%ebp),%eax
  80345a:	a3 00 d0 80 00       	mov    %eax,0x80d000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80345f:	53                   	push   %ebx
  803460:	ff 75 0c             	push   0xc(%ebp)
  803463:	68 04 d0 80 00       	push   $0x80d004
  803468:	e8 cb ee ff ff       	call   802338 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80346d:	89 1d 14 d0 80 00    	mov    %ebx,0x80d014
	return nsipc(NSREQ_BIND);
  803473:	b8 02 00 00 00       	mov    $0x2,%eax
  803478:	e8 32 ff ff ff       	call   8033af <nsipc>
}
  80347d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803480:	c9                   	leave  
  803481:	c3                   	ret    

00803482 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  803482:	55                   	push   %ebp
  803483:	89 e5                	mov    %esp,%ebp
  803485:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803488:	8b 45 08             	mov    0x8(%ebp),%eax
  80348b:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.shutdown.req_how = how;
  803490:	8b 45 0c             	mov    0xc(%ebp),%eax
  803493:	a3 04 d0 80 00       	mov    %eax,0x80d004
	return nsipc(NSREQ_SHUTDOWN);
  803498:	b8 03 00 00 00       	mov    $0x3,%eax
  80349d:	e8 0d ff ff ff       	call   8033af <nsipc>
}
  8034a2:	c9                   	leave  
  8034a3:	c3                   	ret    

008034a4 <nsipc_close>:

int
nsipc_close(int s)
{
  8034a4:	55                   	push   %ebp
  8034a5:	89 e5                	mov    %esp,%ebp
  8034a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8034aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8034ad:	a3 00 d0 80 00       	mov    %eax,0x80d000
	return nsipc(NSREQ_CLOSE);
  8034b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8034b7:	e8 f3 fe ff ff       	call   8033af <nsipc>
}
  8034bc:	c9                   	leave  
  8034bd:	c3                   	ret    

008034be <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8034be:	55                   	push   %ebp
  8034bf:	89 e5                	mov    %esp,%ebp
  8034c1:	53                   	push   %ebx
  8034c2:	83 ec 08             	sub    $0x8,%esp
  8034c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8034c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8034cb:	a3 00 d0 80 00       	mov    %eax,0x80d000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8034d0:	53                   	push   %ebx
  8034d1:	ff 75 0c             	push   0xc(%ebp)
  8034d4:	68 04 d0 80 00       	push   $0x80d004
  8034d9:	e8 5a ee ff ff       	call   802338 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8034de:	89 1d 14 d0 80 00    	mov    %ebx,0x80d014
	return nsipc(NSREQ_CONNECT);
  8034e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8034e9:	e8 c1 fe ff ff       	call   8033af <nsipc>
}
  8034ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034f1:	c9                   	leave  
  8034f2:	c3                   	ret    

008034f3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8034f3:	55                   	push   %ebp
  8034f4:	89 e5                	mov    %esp,%ebp
  8034f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8034f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8034fc:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.listen.req_backlog = backlog;
  803501:	8b 45 0c             	mov    0xc(%ebp),%eax
  803504:	a3 04 d0 80 00       	mov    %eax,0x80d004
	return nsipc(NSREQ_LISTEN);
  803509:	b8 06 00 00 00       	mov    $0x6,%eax
  80350e:	e8 9c fe ff ff       	call   8033af <nsipc>
}
  803513:	c9                   	leave  
  803514:	c3                   	ret    

00803515 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803515:	55                   	push   %ebp
  803516:	89 e5                	mov    %esp,%ebp
  803518:	56                   	push   %esi
  803519:	53                   	push   %ebx
  80351a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80351d:	8b 45 08             	mov    0x8(%ebp),%eax
  803520:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.recv.req_len = len;
  803525:	89 35 04 d0 80 00    	mov    %esi,0x80d004
	nsipcbuf.recv.req_flags = flags;
  80352b:	8b 45 14             	mov    0x14(%ebp),%eax
  80352e:	a3 08 d0 80 00       	mov    %eax,0x80d008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803533:	b8 07 00 00 00       	mov    $0x7,%eax
  803538:	e8 72 fe ff ff       	call   8033af <nsipc>
  80353d:	89 c3                	mov    %eax,%ebx
  80353f:	85 c0                	test   %eax,%eax
  803541:	78 22                	js     803565 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  803543:	b8 3f 06 00 00       	mov    $0x63f,%eax
  803548:	39 c6                	cmp    %eax,%esi
  80354a:	0f 4e c6             	cmovle %esi,%eax
  80354d:	39 c3                	cmp    %eax,%ebx
  80354f:	7f 1d                	jg     80356e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803551:	83 ec 04             	sub    $0x4,%esp
  803554:	53                   	push   %ebx
  803555:	68 00 d0 80 00       	push   $0x80d000
  80355a:	ff 75 0c             	push   0xc(%ebp)
  80355d:	e8 d6 ed ff ff       	call   802338 <memmove>
  803562:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803565:	89 d8                	mov    %ebx,%eax
  803567:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80356a:	5b                   	pop    %ebx
  80356b:	5e                   	pop    %esi
  80356c:	5d                   	pop    %ebp
  80356d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80356e:	68 8a 47 80 00       	push   $0x80478a
  803573:	68 5d 3d 80 00       	push   $0x803d5d
  803578:	6a 62                	push   $0x62
  80357a:	68 9f 47 80 00       	push   $0x80479f
  80357f:	e8 69 e5 ff ff       	call   801aed <_panic>

00803584 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803584:	55                   	push   %ebp
  803585:	89 e5                	mov    %esp,%ebp
  803587:	53                   	push   %ebx
  803588:	83 ec 04             	sub    $0x4,%esp
  80358b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80358e:	8b 45 08             	mov    0x8(%ebp),%eax
  803591:	a3 00 d0 80 00       	mov    %eax,0x80d000
	assert(size < 1600);
  803596:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80359c:	7f 2e                	jg     8035cc <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80359e:	83 ec 04             	sub    $0x4,%esp
  8035a1:	53                   	push   %ebx
  8035a2:	ff 75 0c             	push   0xc(%ebp)
  8035a5:	68 0c d0 80 00       	push   $0x80d00c
  8035aa:	e8 89 ed ff ff       	call   802338 <memmove>
	nsipcbuf.send.req_size = size;
  8035af:	89 1d 04 d0 80 00    	mov    %ebx,0x80d004
	nsipcbuf.send.req_flags = flags;
  8035b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8035b8:	a3 08 d0 80 00       	mov    %eax,0x80d008
	return nsipc(NSREQ_SEND);
  8035bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8035c2:	e8 e8 fd ff ff       	call   8033af <nsipc>
}
  8035c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035ca:	c9                   	leave  
  8035cb:	c3                   	ret    
	assert(size < 1600);
  8035cc:	68 ab 47 80 00       	push   $0x8047ab
  8035d1:	68 5d 3d 80 00       	push   $0x803d5d
  8035d6:	6a 6d                	push   $0x6d
  8035d8:	68 9f 47 80 00       	push   $0x80479f
  8035dd:	e8 0b e5 ff ff       	call   801aed <_panic>

008035e2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8035e2:	55                   	push   %ebp
  8035e3:	89 e5                	mov    %esp,%ebp
  8035e5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8035e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8035eb:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.socket.req_type = type;
  8035f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035f3:	a3 04 d0 80 00       	mov    %eax,0x80d004
	nsipcbuf.socket.req_protocol = protocol;
  8035f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8035fb:	a3 08 d0 80 00       	mov    %eax,0x80d008
	return nsipc(NSREQ_SOCKET);
  803600:	b8 09 00 00 00       	mov    $0x9,%eax
  803605:	e8 a5 fd ff ff       	call   8033af <nsipc>
}
  80360a:	c9                   	leave  
  80360b:	c3                   	ret    

0080360c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80360c:	55                   	push   %ebp
  80360d:	89 e5                	mov    %esp,%ebp
  80360f:	56                   	push   %esi
  803610:	53                   	push   %ebx
  803611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803614:	83 ec 0c             	sub    $0xc,%esp
  803617:	ff 75 08             	push   0x8(%ebp)
  80361a:	e8 71 f3 ff ff       	call   802990 <fd2data>
  80361f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803621:	83 c4 08             	add    $0x8,%esp
  803624:	68 b7 47 80 00       	push   $0x8047b7
  803629:	53                   	push   %ebx
  80362a:	e8 73 eb ff ff       	call   8021a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80362f:	8b 46 04             	mov    0x4(%esi),%eax
  803632:	2b 06                	sub    (%esi),%eax
  803634:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80363a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803641:	00 00 00 
	stat->st_dev = &devpipe;
  803644:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  80364b:	90 80 00 
	return 0;
}
  80364e:	b8 00 00 00 00       	mov    $0x0,%eax
  803653:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803656:	5b                   	pop    %ebx
  803657:	5e                   	pop    %esi
  803658:	5d                   	pop    %ebp
  803659:	c3                   	ret    

0080365a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80365a:	55                   	push   %ebp
  80365b:	89 e5                	mov    %esp,%ebp
  80365d:	53                   	push   %ebx
  80365e:	83 ec 0c             	sub    $0xc,%esp
  803661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803664:	53                   	push   %ebx
  803665:	6a 00                	push   $0x0
  803667:	e8 b7 ef ff ff       	call   802623 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80366c:	89 1c 24             	mov    %ebx,(%esp)
  80366f:	e8 1c f3 ff ff       	call   802990 <fd2data>
  803674:	83 c4 08             	add    $0x8,%esp
  803677:	50                   	push   %eax
  803678:	6a 00                	push   $0x0
  80367a:	e8 a4 ef ff ff       	call   802623 <sys_page_unmap>
}
  80367f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803682:	c9                   	leave  
  803683:	c3                   	ret    

00803684 <_pipeisclosed>:
{
  803684:	55                   	push   %ebp
  803685:	89 e5                	mov    %esp,%ebp
  803687:	57                   	push   %edi
  803688:	56                   	push   %esi
  803689:	53                   	push   %ebx
  80368a:	83 ec 1c             	sub    $0x1c,%esp
  80368d:	89 c7                	mov    %eax,%edi
  80368f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  803691:	a1 08 a0 80 00       	mov    0x80a008,%eax
  803696:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803699:	83 ec 0c             	sub    $0xc,%esp
  80369c:	57                   	push   %edi
  80369d:	e8 c6 fa ff ff       	call   803168 <pageref>
  8036a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8036a5:	89 34 24             	mov    %esi,(%esp)
  8036a8:	e8 bb fa ff ff       	call   803168 <pageref>
		nn = thisenv->env_runs;
  8036ad:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8036b3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8036b6:	83 c4 10             	add    $0x10,%esp
  8036b9:	39 cb                	cmp    %ecx,%ebx
  8036bb:	74 1b                	je     8036d8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8036bd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8036c0:	75 cf                	jne    803691 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8036c2:	8b 42 58             	mov    0x58(%edx),%eax
  8036c5:	6a 01                	push   $0x1
  8036c7:	50                   	push   %eax
  8036c8:	53                   	push   %ebx
  8036c9:	68 be 47 80 00       	push   $0x8047be
  8036ce:	e8 f5 e4 ff ff       	call   801bc8 <cprintf>
  8036d3:	83 c4 10             	add    $0x10,%esp
  8036d6:	eb b9                	jmp    803691 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8036d8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8036db:	0f 94 c0             	sete   %al
  8036de:	0f b6 c0             	movzbl %al,%eax
}
  8036e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036e4:	5b                   	pop    %ebx
  8036e5:	5e                   	pop    %esi
  8036e6:	5f                   	pop    %edi
  8036e7:	5d                   	pop    %ebp
  8036e8:	c3                   	ret    

008036e9 <devpipe_write>:
{
  8036e9:	55                   	push   %ebp
  8036ea:	89 e5                	mov    %esp,%ebp
  8036ec:	57                   	push   %edi
  8036ed:	56                   	push   %esi
  8036ee:	53                   	push   %ebx
  8036ef:	83 ec 28             	sub    $0x28,%esp
  8036f2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8036f5:	56                   	push   %esi
  8036f6:	e8 95 f2 ff ff       	call   802990 <fd2data>
  8036fb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8036fd:	83 c4 10             	add    $0x10,%esp
  803700:	bf 00 00 00 00       	mov    $0x0,%edi
  803705:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803708:	75 09                	jne    803713 <devpipe_write+0x2a>
	return i;
  80370a:	89 f8                	mov    %edi,%eax
  80370c:	eb 23                	jmp    803731 <devpipe_write+0x48>
			sys_yield();
  80370e:	e8 6c ee ff ff       	call   80257f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803713:	8b 43 04             	mov    0x4(%ebx),%eax
  803716:	8b 0b                	mov    (%ebx),%ecx
  803718:	8d 51 20             	lea    0x20(%ecx),%edx
  80371b:	39 d0                	cmp    %edx,%eax
  80371d:	72 1a                	jb     803739 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80371f:	89 da                	mov    %ebx,%edx
  803721:	89 f0                	mov    %esi,%eax
  803723:	e8 5c ff ff ff       	call   803684 <_pipeisclosed>
  803728:	85 c0                	test   %eax,%eax
  80372a:	74 e2                	je     80370e <devpipe_write+0x25>
				return 0;
  80372c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803731:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803734:	5b                   	pop    %ebx
  803735:	5e                   	pop    %esi
  803736:	5f                   	pop    %edi
  803737:	5d                   	pop    %ebp
  803738:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80373c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803740:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803743:	89 c2                	mov    %eax,%edx
  803745:	c1 fa 1f             	sar    $0x1f,%edx
  803748:	89 d1                	mov    %edx,%ecx
  80374a:	c1 e9 1b             	shr    $0x1b,%ecx
  80374d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803750:	83 e2 1f             	and    $0x1f,%edx
  803753:	29 ca                	sub    %ecx,%edx
  803755:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803759:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80375d:	83 c0 01             	add    $0x1,%eax
  803760:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  803763:	83 c7 01             	add    $0x1,%edi
  803766:	eb 9d                	jmp    803705 <devpipe_write+0x1c>

00803768 <devpipe_read>:
{
  803768:	55                   	push   %ebp
  803769:	89 e5                	mov    %esp,%ebp
  80376b:	57                   	push   %edi
  80376c:	56                   	push   %esi
  80376d:	53                   	push   %ebx
  80376e:	83 ec 18             	sub    $0x18,%esp
  803771:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803774:	57                   	push   %edi
  803775:	e8 16 f2 ff ff       	call   802990 <fd2data>
  80377a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80377c:	83 c4 10             	add    $0x10,%esp
  80377f:	be 00 00 00 00       	mov    $0x0,%esi
  803784:	3b 75 10             	cmp    0x10(%ebp),%esi
  803787:	75 13                	jne    80379c <devpipe_read+0x34>
	return i;
  803789:	89 f0                	mov    %esi,%eax
  80378b:	eb 02                	jmp    80378f <devpipe_read+0x27>
				return i;
  80378d:	89 f0                	mov    %esi,%eax
}
  80378f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803792:	5b                   	pop    %ebx
  803793:	5e                   	pop    %esi
  803794:	5f                   	pop    %edi
  803795:	5d                   	pop    %ebp
  803796:	c3                   	ret    
			sys_yield();
  803797:	e8 e3 ed ff ff       	call   80257f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80379c:	8b 03                	mov    (%ebx),%eax
  80379e:	3b 43 04             	cmp    0x4(%ebx),%eax
  8037a1:	75 18                	jne    8037bb <devpipe_read+0x53>
			if (i > 0)
  8037a3:	85 f6                	test   %esi,%esi
  8037a5:	75 e6                	jne    80378d <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8037a7:	89 da                	mov    %ebx,%edx
  8037a9:	89 f8                	mov    %edi,%eax
  8037ab:	e8 d4 fe ff ff       	call   803684 <_pipeisclosed>
  8037b0:	85 c0                	test   %eax,%eax
  8037b2:	74 e3                	je     803797 <devpipe_read+0x2f>
				return 0;
  8037b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8037b9:	eb d4                	jmp    80378f <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8037bb:	99                   	cltd   
  8037bc:	c1 ea 1b             	shr    $0x1b,%edx
  8037bf:	01 d0                	add    %edx,%eax
  8037c1:	83 e0 1f             	and    $0x1f,%eax
  8037c4:	29 d0                	sub    %edx,%eax
  8037c6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8037cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8037ce:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8037d1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8037d4:	83 c6 01             	add    $0x1,%esi
  8037d7:	eb ab                	jmp    803784 <devpipe_read+0x1c>

008037d9 <pipe>:
{
  8037d9:	55                   	push   %ebp
  8037da:	89 e5                	mov    %esp,%ebp
  8037dc:	56                   	push   %esi
  8037dd:	53                   	push   %ebx
  8037de:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8037e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037e4:	50                   	push   %eax
  8037e5:	e8 bd f1 ff ff       	call   8029a7 <fd_alloc>
  8037ea:	89 c3                	mov    %eax,%ebx
  8037ec:	83 c4 10             	add    $0x10,%esp
  8037ef:	85 c0                	test   %eax,%eax
  8037f1:	0f 88 23 01 00 00    	js     80391a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037f7:	83 ec 04             	sub    $0x4,%esp
  8037fa:	68 07 04 00 00       	push   $0x407
  8037ff:	ff 75 f4             	push   -0xc(%ebp)
  803802:	6a 00                	push   $0x0
  803804:	e8 95 ed ff ff       	call   80259e <sys_page_alloc>
  803809:	89 c3                	mov    %eax,%ebx
  80380b:	83 c4 10             	add    $0x10,%esp
  80380e:	85 c0                	test   %eax,%eax
  803810:	0f 88 04 01 00 00    	js     80391a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  803816:	83 ec 0c             	sub    $0xc,%esp
  803819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80381c:	50                   	push   %eax
  80381d:	e8 85 f1 ff ff       	call   8029a7 <fd_alloc>
  803822:	89 c3                	mov    %eax,%ebx
  803824:	83 c4 10             	add    $0x10,%esp
  803827:	85 c0                	test   %eax,%eax
  803829:	0f 88 db 00 00 00    	js     80390a <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80382f:	83 ec 04             	sub    $0x4,%esp
  803832:	68 07 04 00 00       	push   $0x407
  803837:	ff 75 f0             	push   -0x10(%ebp)
  80383a:	6a 00                	push   $0x0
  80383c:	e8 5d ed ff ff       	call   80259e <sys_page_alloc>
  803841:	89 c3                	mov    %eax,%ebx
  803843:	83 c4 10             	add    $0x10,%esp
  803846:	85 c0                	test   %eax,%eax
  803848:	0f 88 bc 00 00 00    	js     80390a <pipe+0x131>
	va = fd2data(fd0);
  80384e:	83 ec 0c             	sub    $0xc,%esp
  803851:	ff 75 f4             	push   -0xc(%ebp)
  803854:	e8 37 f1 ff ff       	call   802990 <fd2data>
  803859:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80385b:	83 c4 0c             	add    $0xc,%esp
  80385e:	68 07 04 00 00       	push   $0x407
  803863:	50                   	push   %eax
  803864:	6a 00                	push   $0x0
  803866:	e8 33 ed ff ff       	call   80259e <sys_page_alloc>
  80386b:	89 c3                	mov    %eax,%ebx
  80386d:	83 c4 10             	add    $0x10,%esp
  803870:	85 c0                	test   %eax,%eax
  803872:	0f 88 82 00 00 00    	js     8038fa <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803878:	83 ec 0c             	sub    $0xc,%esp
  80387b:	ff 75 f0             	push   -0x10(%ebp)
  80387e:	e8 0d f1 ff ff       	call   802990 <fd2data>
  803883:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80388a:	50                   	push   %eax
  80388b:	6a 00                	push   $0x0
  80388d:	56                   	push   %esi
  80388e:	6a 00                	push   $0x0
  803890:	e8 4c ed ff ff       	call   8025e1 <sys_page_map>
  803895:	89 c3                	mov    %eax,%ebx
  803897:	83 c4 20             	add    $0x20,%esp
  80389a:	85 c0                	test   %eax,%eax
  80389c:	78 4e                	js     8038ec <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80389e:	a1 9c 90 80 00       	mov    0x80909c,%eax
  8038a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8038a6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8038a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8038ab:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8038b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8038b5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8038b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8038ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8038c1:	83 ec 0c             	sub    $0xc,%esp
  8038c4:	ff 75 f4             	push   -0xc(%ebp)
  8038c7:	e8 b4 f0 ff ff       	call   802980 <fd2num>
  8038cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8038d1:	83 c4 04             	add    $0x4,%esp
  8038d4:	ff 75 f0             	push   -0x10(%ebp)
  8038d7:	e8 a4 f0 ff ff       	call   802980 <fd2num>
  8038dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038df:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8038e2:	83 c4 10             	add    $0x10,%esp
  8038e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8038ea:	eb 2e                	jmp    80391a <pipe+0x141>
	sys_page_unmap(0, va);
  8038ec:	83 ec 08             	sub    $0x8,%esp
  8038ef:	56                   	push   %esi
  8038f0:	6a 00                	push   $0x0
  8038f2:	e8 2c ed ff ff       	call   802623 <sys_page_unmap>
  8038f7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8038fa:	83 ec 08             	sub    $0x8,%esp
  8038fd:	ff 75 f0             	push   -0x10(%ebp)
  803900:	6a 00                	push   $0x0
  803902:	e8 1c ed ff ff       	call   802623 <sys_page_unmap>
  803907:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80390a:	83 ec 08             	sub    $0x8,%esp
  80390d:	ff 75 f4             	push   -0xc(%ebp)
  803910:	6a 00                	push   $0x0
  803912:	e8 0c ed ff ff       	call   802623 <sys_page_unmap>
  803917:	83 c4 10             	add    $0x10,%esp
}
  80391a:	89 d8                	mov    %ebx,%eax
  80391c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80391f:	5b                   	pop    %ebx
  803920:	5e                   	pop    %esi
  803921:	5d                   	pop    %ebp
  803922:	c3                   	ret    

00803923 <pipeisclosed>:
{
  803923:	55                   	push   %ebp
  803924:	89 e5                	mov    %esp,%ebp
  803926:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80392c:	50                   	push   %eax
  80392d:	ff 75 08             	push   0x8(%ebp)
  803930:	e8 c2 f0 ff ff       	call   8029f7 <fd_lookup>
  803935:	83 c4 10             	add    $0x10,%esp
  803938:	85 c0                	test   %eax,%eax
  80393a:	78 18                	js     803954 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80393c:	83 ec 0c             	sub    $0xc,%esp
  80393f:	ff 75 f4             	push   -0xc(%ebp)
  803942:	e8 49 f0 ff ff       	call   802990 <fd2data>
  803947:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  803949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80394c:	e8 33 fd ff ff       	call   803684 <_pipeisclosed>
  803951:	83 c4 10             	add    $0x10,%esp
}
  803954:	c9                   	leave  
  803955:	c3                   	ret    

00803956 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  803956:	b8 00 00 00 00       	mov    $0x0,%eax
  80395b:	c3                   	ret    

0080395c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80395c:	55                   	push   %ebp
  80395d:	89 e5                	mov    %esp,%ebp
  80395f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803962:	68 d6 47 80 00       	push   $0x8047d6
  803967:	ff 75 0c             	push   0xc(%ebp)
  80396a:	e8 33 e8 ff ff       	call   8021a2 <strcpy>
	return 0;
}
  80396f:	b8 00 00 00 00       	mov    $0x0,%eax
  803974:	c9                   	leave  
  803975:	c3                   	ret    

00803976 <devcons_write>:
{
  803976:	55                   	push   %ebp
  803977:	89 e5                	mov    %esp,%ebp
  803979:	57                   	push   %edi
  80397a:	56                   	push   %esi
  80397b:	53                   	push   %ebx
  80397c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  803982:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803987:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80398d:	eb 2e                	jmp    8039bd <devcons_write+0x47>
		m = n - tot;
  80398f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803992:	29 f3                	sub    %esi,%ebx
  803994:	b8 7f 00 00 00       	mov    $0x7f,%eax
  803999:	39 c3                	cmp    %eax,%ebx
  80399b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80399e:	83 ec 04             	sub    $0x4,%esp
  8039a1:	53                   	push   %ebx
  8039a2:	89 f0                	mov    %esi,%eax
  8039a4:	03 45 0c             	add    0xc(%ebp),%eax
  8039a7:	50                   	push   %eax
  8039a8:	57                   	push   %edi
  8039a9:	e8 8a e9 ff ff       	call   802338 <memmove>
		sys_cputs(buf, m);
  8039ae:	83 c4 08             	add    $0x8,%esp
  8039b1:	53                   	push   %ebx
  8039b2:	57                   	push   %edi
  8039b3:	e8 2a eb ff ff       	call   8024e2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8039b8:	01 de                	add    %ebx,%esi
  8039ba:	83 c4 10             	add    $0x10,%esp
  8039bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8039c0:	72 cd                	jb     80398f <devcons_write+0x19>
}
  8039c2:	89 f0                	mov    %esi,%eax
  8039c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8039c7:	5b                   	pop    %ebx
  8039c8:	5e                   	pop    %esi
  8039c9:	5f                   	pop    %edi
  8039ca:	5d                   	pop    %ebp
  8039cb:	c3                   	ret    

008039cc <devcons_read>:
{
  8039cc:	55                   	push   %ebp
  8039cd:	89 e5                	mov    %esp,%ebp
  8039cf:	83 ec 08             	sub    $0x8,%esp
  8039d2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8039d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8039db:	75 07                	jne    8039e4 <devcons_read+0x18>
  8039dd:	eb 1f                	jmp    8039fe <devcons_read+0x32>
		sys_yield();
  8039df:	e8 9b eb ff ff       	call   80257f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8039e4:	e8 17 eb ff ff       	call   802500 <sys_cgetc>
  8039e9:	85 c0                	test   %eax,%eax
  8039eb:	74 f2                	je     8039df <devcons_read+0x13>
	if (c < 0)
  8039ed:	78 0f                	js     8039fe <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8039ef:	83 f8 04             	cmp    $0x4,%eax
  8039f2:	74 0c                	je     803a00 <devcons_read+0x34>
	*(char*)vbuf = c;
  8039f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8039f7:	88 02                	mov    %al,(%edx)
	return 1;
  8039f9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8039fe:	c9                   	leave  
  8039ff:	c3                   	ret    
		return 0;
  803a00:	b8 00 00 00 00       	mov    $0x0,%eax
  803a05:	eb f7                	jmp    8039fe <devcons_read+0x32>

00803a07 <cputchar>:
{
  803a07:	55                   	push   %ebp
  803a08:	89 e5                	mov    %esp,%ebp
  803a0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  803a10:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  803a13:	6a 01                	push   $0x1
  803a15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a18:	50                   	push   %eax
  803a19:	e8 c4 ea ff ff       	call   8024e2 <sys_cputs>
}
  803a1e:	83 c4 10             	add    $0x10,%esp
  803a21:	c9                   	leave  
  803a22:	c3                   	ret    

00803a23 <getchar>:
{
  803a23:	55                   	push   %ebp
  803a24:	89 e5                	mov    %esp,%ebp
  803a26:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  803a29:	6a 01                	push   $0x1
  803a2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a2e:	50                   	push   %eax
  803a2f:	6a 00                	push   $0x0
  803a31:	e8 2a f2 ff ff       	call   802c60 <read>
	if (r < 0)
  803a36:	83 c4 10             	add    $0x10,%esp
  803a39:	85 c0                	test   %eax,%eax
  803a3b:	78 06                	js     803a43 <getchar+0x20>
	if (r < 1)
  803a3d:	74 06                	je     803a45 <getchar+0x22>
	return c;
  803a3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  803a43:	c9                   	leave  
  803a44:	c3                   	ret    
		return -E_EOF;
  803a45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  803a4a:	eb f7                	jmp    803a43 <getchar+0x20>

00803a4c <iscons>:
{
  803a4c:	55                   	push   %ebp
  803a4d:	89 e5                	mov    %esp,%ebp
  803a4f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a55:	50                   	push   %eax
  803a56:	ff 75 08             	push   0x8(%ebp)
  803a59:	e8 99 ef ff ff       	call   8029f7 <fd_lookup>
  803a5e:	83 c4 10             	add    $0x10,%esp
  803a61:	85 c0                	test   %eax,%eax
  803a63:	78 11                	js     803a76 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  803a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a68:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803a6e:	39 10                	cmp    %edx,(%eax)
  803a70:	0f 94 c0             	sete   %al
  803a73:	0f b6 c0             	movzbl %al,%eax
}
  803a76:	c9                   	leave  
  803a77:	c3                   	ret    

00803a78 <opencons>:
{
  803a78:	55                   	push   %ebp
  803a79:	89 e5                	mov    %esp,%ebp
  803a7b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  803a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a81:	50                   	push   %eax
  803a82:	e8 20 ef ff ff       	call   8029a7 <fd_alloc>
  803a87:	83 c4 10             	add    $0x10,%esp
  803a8a:	85 c0                	test   %eax,%eax
  803a8c:	78 3a                	js     803ac8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a8e:	83 ec 04             	sub    $0x4,%esp
  803a91:	68 07 04 00 00       	push   $0x407
  803a96:	ff 75 f4             	push   -0xc(%ebp)
  803a99:	6a 00                	push   $0x0
  803a9b:	e8 fe ea ff ff       	call   80259e <sys_page_alloc>
  803aa0:	83 c4 10             	add    $0x10,%esp
  803aa3:	85 c0                	test   %eax,%eax
  803aa5:	78 21                	js     803ac8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  803aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803aaa:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803ab0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803ab5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803abc:	83 ec 0c             	sub    $0xc,%esp
  803abf:	50                   	push   %eax
  803ac0:	e8 bb ee ff ff       	call   802980 <fd2num>
  803ac5:	83 c4 10             	add    $0x10,%esp
}
  803ac8:	c9                   	leave  
  803ac9:	c3                   	ret    
  803aca:	66 90                	xchg   %ax,%ax
  803acc:	66 90                	xchg   %ax,%ax
  803ace:	66 90                	xchg   %ax,%ax

00803ad0 <__udivdi3>:
  803ad0:	f3 0f 1e fb          	endbr32 
  803ad4:	55                   	push   %ebp
  803ad5:	57                   	push   %edi
  803ad6:	56                   	push   %esi
  803ad7:	53                   	push   %ebx
  803ad8:	83 ec 1c             	sub    $0x1c,%esp
  803adb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803adf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803ae3:	8b 74 24 34          	mov    0x34(%esp),%esi
  803ae7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  803aeb:	85 c0                	test   %eax,%eax
  803aed:	75 19                	jne    803b08 <__udivdi3+0x38>
  803aef:	39 f3                	cmp    %esi,%ebx
  803af1:	76 4d                	jbe    803b40 <__udivdi3+0x70>
  803af3:	31 ff                	xor    %edi,%edi
  803af5:	89 e8                	mov    %ebp,%eax
  803af7:	89 f2                	mov    %esi,%edx
  803af9:	f7 f3                	div    %ebx
  803afb:	89 fa                	mov    %edi,%edx
  803afd:	83 c4 1c             	add    $0x1c,%esp
  803b00:	5b                   	pop    %ebx
  803b01:	5e                   	pop    %esi
  803b02:	5f                   	pop    %edi
  803b03:	5d                   	pop    %ebp
  803b04:	c3                   	ret    
  803b05:	8d 76 00             	lea    0x0(%esi),%esi
  803b08:	39 f0                	cmp    %esi,%eax
  803b0a:	76 14                	jbe    803b20 <__udivdi3+0x50>
  803b0c:	31 ff                	xor    %edi,%edi
  803b0e:	31 c0                	xor    %eax,%eax
  803b10:	89 fa                	mov    %edi,%edx
  803b12:	83 c4 1c             	add    $0x1c,%esp
  803b15:	5b                   	pop    %ebx
  803b16:	5e                   	pop    %esi
  803b17:	5f                   	pop    %edi
  803b18:	5d                   	pop    %ebp
  803b19:	c3                   	ret    
  803b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803b20:	0f bd f8             	bsr    %eax,%edi
  803b23:	83 f7 1f             	xor    $0x1f,%edi
  803b26:	75 48                	jne    803b70 <__udivdi3+0xa0>
  803b28:	39 f0                	cmp    %esi,%eax
  803b2a:	72 06                	jb     803b32 <__udivdi3+0x62>
  803b2c:	31 c0                	xor    %eax,%eax
  803b2e:	39 eb                	cmp    %ebp,%ebx
  803b30:	77 de                	ja     803b10 <__udivdi3+0x40>
  803b32:	b8 01 00 00 00       	mov    $0x1,%eax
  803b37:	eb d7                	jmp    803b10 <__udivdi3+0x40>
  803b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b40:	89 d9                	mov    %ebx,%ecx
  803b42:	85 db                	test   %ebx,%ebx
  803b44:	75 0b                	jne    803b51 <__udivdi3+0x81>
  803b46:	b8 01 00 00 00       	mov    $0x1,%eax
  803b4b:	31 d2                	xor    %edx,%edx
  803b4d:	f7 f3                	div    %ebx
  803b4f:	89 c1                	mov    %eax,%ecx
  803b51:	31 d2                	xor    %edx,%edx
  803b53:	89 f0                	mov    %esi,%eax
  803b55:	f7 f1                	div    %ecx
  803b57:	89 c6                	mov    %eax,%esi
  803b59:	89 e8                	mov    %ebp,%eax
  803b5b:	89 f7                	mov    %esi,%edi
  803b5d:	f7 f1                	div    %ecx
  803b5f:	89 fa                	mov    %edi,%edx
  803b61:	83 c4 1c             	add    $0x1c,%esp
  803b64:	5b                   	pop    %ebx
  803b65:	5e                   	pop    %esi
  803b66:	5f                   	pop    %edi
  803b67:	5d                   	pop    %ebp
  803b68:	c3                   	ret    
  803b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b70:	89 f9                	mov    %edi,%ecx
  803b72:	ba 20 00 00 00       	mov    $0x20,%edx
  803b77:	29 fa                	sub    %edi,%edx
  803b79:	d3 e0                	shl    %cl,%eax
  803b7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b7f:	89 d1                	mov    %edx,%ecx
  803b81:	89 d8                	mov    %ebx,%eax
  803b83:	d3 e8                	shr    %cl,%eax
  803b85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803b89:	09 c1                	or     %eax,%ecx
  803b8b:	89 f0                	mov    %esi,%eax
  803b8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b91:	89 f9                	mov    %edi,%ecx
  803b93:	d3 e3                	shl    %cl,%ebx
  803b95:	89 d1                	mov    %edx,%ecx
  803b97:	d3 e8                	shr    %cl,%eax
  803b99:	89 f9                	mov    %edi,%ecx
  803b9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  803b9f:	89 eb                	mov    %ebp,%ebx
  803ba1:	d3 e6                	shl    %cl,%esi
  803ba3:	89 d1                	mov    %edx,%ecx
  803ba5:	d3 eb                	shr    %cl,%ebx
  803ba7:	09 f3                	or     %esi,%ebx
  803ba9:	89 c6                	mov    %eax,%esi
  803bab:	89 f2                	mov    %esi,%edx
  803bad:	89 d8                	mov    %ebx,%eax
  803baf:	f7 74 24 08          	divl   0x8(%esp)
  803bb3:	89 d6                	mov    %edx,%esi
  803bb5:	89 c3                	mov    %eax,%ebx
  803bb7:	f7 64 24 0c          	mull   0xc(%esp)
  803bbb:	39 d6                	cmp    %edx,%esi
  803bbd:	72 19                	jb     803bd8 <__udivdi3+0x108>
  803bbf:	89 f9                	mov    %edi,%ecx
  803bc1:	d3 e5                	shl    %cl,%ebp
  803bc3:	39 c5                	cmp    %eax,%ebp
  803bc5:	73 04                	jae    803bcb <__udivdi3+0xfb>
  803bc7:	39 d6                	cmp    %edx,%esi
  803bc9:	74 0d                	je     803bd8 <__udivdi3+0x108>
  803bcb:	89 d8                	mov    %ebx,%eax
  803bcd:	31 ff                	xor    %edi,%edi
  803bcf:	e9 3c ff ff ff       	jmp    803b10 <__udivdi3+0x40>
  803bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803bd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803bdb:	31 ff                	xor    %edi,%edi
  803bdd:	e9 2e ff ff ff       	jmp    803b10 <__udivdi3+0x40>
  803be2:	66 90                	xchg   %ax,%ax
  803be4:	66 90                	xchg   %ax,%ax
  803be6:	66 90                	xchg   %ax,%ax
  803be8:	66 90                	xchg   %ax,%ax
  803bea:	66 90                	xchg   %ax,%ax
  803bec:	66 90                	xchg   %ax,%ax
  803bee:	66 90                	xchg   %ax,%ax

00803bf0 <__umoddi3>:
  803bf0:	f3 0f 1e fb          	endbr32 
  803bf4:	55                   	push   %ebp
  803bf5:	57                   	push   %edi
  803bf6:	56                   	push   %esi
  803bf7:	53                   	push   %ebx
  803bf8:	83 ec 1c             	sub    $0x1c,%esp
  803bfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  803bff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803c03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  803c07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  803c0b:	89 f0                	mov    %esi,%eax
  803c0d:	89 da                	mov    %ebx,%edx
  803c0f:	85 ff                	test   %edi,%edi
  803c11:	75 15                	jne    803c28 <__umoddi3+0x38>
  803c13:	39 dd                	cmp    %ebx,%ebp
  803c15:	76 39                	jbe    803c50 <__umoddi3+0x60>
  803c17:	f7 f5                	div    %ebp
  803c19:	89 d0                	mov    %edx,%eax
  803c1b:	31 d2                	xor    %edx,%edx
  803c1d:	83 c4 1c             	add    $0x1c,%esp
  803c20:	5b                   	pop    %ebx
  803c21:	5e                   	pop    %esi
  803c22:	5f                   	pop    %edi
  803c23:	5d                   	pop    %ebp
  803c24:	c3                   	ret    
  803c25:	8d 76 00             	lea    0x0(%esi),%esi
  803c28:	39 df                	cmp    %ebx,%edi
  803c2a:	77 f1                	ja     803c1d <__umoddi3+0x2d>
  803c2c:	0f bd cf             	bsr    %edi,%ecx
  803c2f:	83 f1 1f             	xor    $0x1f,%ecx
  803c32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803c36:	75 40                	jne    803c78 <__umoddi3+0x88>
  803c38:	39 df                	cmp    %ebx,%edi
  803c3a:	72 04                	jb     803c40 <__umoddi3+0x50>
  803c3c:	39 f5                	cmp    %esi,%ebp
  803c3e:	77 dd                	ja     803c1d <__umoddi3+0x2d>
  803c40:	89 da                	mov    %ebx,%edx
  803c42:	89 f0                	mov    %esi,%eax
  803c44:	29 e8                	sub    %ebp,%eax
  803c46:	19 fa                	sbb    %edi,%edx
  803c48:	eb d3                	jmp    803c1d <__umoddi3+0x2d>
  803c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803c50:	89 e9                	mov    %ebp,%ecx
  803c52:	85 ed                	test   %ebp,%ebp
  803c54:	75 0b                	jne    803c61 <__umoddi3+0x71>
  803c56:	b8 01 00 00 00       	mov    $0x1,%eax
  803c5b:	31 d2                	xor    %edx,%edx
  803c5d:	f7 f5                	div    %ebp
  803c5f:	89 c1                	mov    %eax,%ecx
  803c61:	89 d8                	mov    %ebx,%eax
  803c63:	31 d2                	xor    %edx,%edx
  803c65:	f7 f1                	div    %ecx
  803c67:	89 f0                	mov    %esi,%eax
  803c69:	f7 f1                	div    %ecx
  803c6b:	89 d0                	mov    %edx,%eax
  803c6d:	31 d2                	xor    %edx,%edx
  803c6f:	eb ac                	jmp    803c1d <__umoddi3+0x2d>
  803c71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803c78:	8b 44 24 04          	mov    0x4(%esp),%eax
  803c7c:	ba 20 00 00 00       	mov    $0x20,%edx
  803c81:	29 c2                	sub    %eax,%edx
  803c83:	89 c1                	mov    %eax,%ecx
  803c85:	89 e8                	mov    %ebp,%eax
  803c87:	d3 e7                	shl    %cl,%edi
  803c89:	89 d1                	mov    %edx,%ecx
  803c8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803c8f:	d3 e8                	shr    %cl,%eax
  803c91:	89 c1                	mov    %eax,%ecx
  803c93:	8b 44 24 04          	mov    0x4(%esp),%eax
  803c97:	09 f9                	or     %edi,%ecx
  803c99:	89 df                	mov    %ebx,%edi
  803c9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803c9f:	89 c1                	mov    %eax,%ecx
  803ca1:	d3 e5                	shl    %cl,%ebp
  803ca3:	89 d1                	mov    %edx,%ecx
  803ca5:	d3 ef                	shr    %cl,%edi
  803ca7:	89 c1                	mov    %eax,%ecx
  803ca9:	89 f0                	mov    %esi,%eax
  803cab:	d3 e3                	shl    %cl,%ebx
  803cad:	89 d1                	mov    %edx,%ecx
  803caf:	89 fa                	mov    %edi,%edx
  803cb1:	d3 e8                	shr    %cl,%eax
  803cb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803cb8:	09 d8                	or     %ebx,%eax
  803cba:	f7 74 24 08          	divl   0x8(%esp)
  803cbe:	89 d3                	mov    %edx,%ebx
  803cc0:	d3 e6                	shl    %cl,%esi
  803cc2:	f7 e5                	mul    %ebp
  803cc4:	89 c7                	mov    %eax,%edi
  803cc6:	89 d1                	mov    %edx,%ecx
  803cc8:	39 d3                	cmp    %edx,%ebx
  803cca:	72 06                	jb     803cd2 <__umoddi3+0xe2>
  803ccc:	75 0e                	jne    803cdc <__umoddi3+0xec>
  803cce:	39 c6                	cmp    %eax,%esi
  803cd0:	73 0a                	jae    803cdc <__umoddi3+0xec>
  803cd2:	29 e8                	sub    %ebp,%eax
  803cd4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803cd8:	89 d1                	mov    %edx,%ecx
  803cda:	89 c7                	mov    %eax,%edi
  803cdc:	89 f5                	mov    %esi,%ebp
  803cde:	8b 74 24 04          	mov    0x4(%esp),%esi
  803ce2:	29 fd                	sub    %edi,%ebp
  803ce4:	19 cb                	sbb    %ecx,%ebx
  803ce6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  803ceb:	89 d8                	mov    %ebx,%eax
  803ced:	d3 e0                	shl    %cl,%eax
  803cef:	89 f1                	mov    %esi,%ecx
  803cf1:	d3 ed                	shr    %cl,%ebp
  803cf3:	d3 eb                	shr    %cl,%ebx
  803cf5:	09 e8                	or     %ebp,%eax
  803cf7:	89 da                	mov    %ebx,%edx
  803cf9:	83 c4 1c             	add    $0x1c,%esp
  803cfc:	5b                   	pop    %ebx
  803cfd:	5e                   	pop    %esi
  803cfe:	5f                   	pop    %edi
  803cff:	5d                   	pop    %ebp
  803d00:	c3                   	ret    
