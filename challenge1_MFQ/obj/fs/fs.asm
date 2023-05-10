
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
  8000b9:	e8 0d 1b 00 00       	call   801bcb <cprintf>
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
  8000e9:	e8 02 1a 00 00       	call   801af0 <_panic>

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
  8001a4:	e8 47 19 00 00       	call   801af0 <_panic>
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
  80026c:	e8 7f 18 00 00       	call   801af0 <_panic>
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
  8002c1:	e8 db 22 00 00       	call   8025a1 <sys_page_alloc>
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
  80030a:	e8 d5 22 00 00       	call   8025e4 <sys_page_map>
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
  80034c:	e8 9f 17 00 00       	call   801af0 <_panic>
		panic("reading non-existent block %08x\n", blockno);
  800351:	56                   	push   %esi
  800352:	68 a4 3d 80 00       	push   $0x803da4
  800357:	6a 2c                	push   $0x2c
  800359:	68 50 3e 80 00       	push   $0x803e50
  80035e:	e8 8d 17 00 00       	call   801af0 <_panic>
		panic("bc_pgfault, sys_page_alloc: %e", r);
  800363:	50                   	push   %eax
  800364:	68 c8 3d 80 00       	push   $0x803dc8
  800369:	6a 36                	push   $0x36
  80036b:	68 50 3e 80 00       	push   $0x803e50
  800370:	e8 7b 17 00 00       	call   801af0 <_panic>
	if( r= ide_read(blockno * BLKSECTS , addr, BLKSECTS)<0 ) panic("bc_pgfault, ide_read: %e", r);
  800375:	6a 01                	push   $0x1
  800377:	68 58 3e 80 00       	push   $0x803e58
  80037c:	6a 38                	push   $0x38
  80037e:	68 50 3e 80 00       	push   $0x803e50
  800383:	e8 68 17 00 00       	call   801af0 <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800388:	50                   	push   %eax
  800389:	68 e8 3d 80 00       	push   $0x803de8
  80038e:	6a 3d                	push   $0x3d
  800390:	68 50 3e 80 00       	push   $0x803e50
  800395:	e8 56 17 00 00       	call   801af0 <_panic>
		panic("reading free block %08x\n", blockno);
  80039a:	56                   	push   %esi
  80039b:	68 71 3e 80 00       	push   $0x803e71
  8003a0:	6a 43                	push   $0x43
  8003a2:	68 50 3e 80 00       	push   $0x803e50
  8003a7:	e8 44 17 00 00       	call   801af0 <_panic>

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
  8003df:	e8 0c 17 00 00       	call   801af0 <_panic>

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
  80046b:	e8 80 16 00 00       	call   801af0 <_panic>
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
  8004a7:	e8 38 21 00 00       	call   8025e4 <sys_page_map>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 a4                	jns    800457 <flush_block+0x2d>
			panic("flush_block, sys_page_map: %e", r);
  8004b3:	50                   	push   %eax
  8004b4:	68 c0 3e 80 00       	push   $0x803ec0
  8004b9:	6a 5e                	push   $0x5e
  8004bb:	68 50 3e 80 00       	push   $0x803e50
  8004c0:	e8 2b 16 00 00       	call   801af0 <_panic>
			panic("flush_block, ide_write: %e", r);
  8004c5:	50                   	push   %eax
  8004c6:	68 a5 3e 80 00       	push   $0x803ea5
  8004cb:	6a 5b                	push   $0x5b
  8004cd:	68 50 3e 80 00       	push   $0x803e50
  8004d2:	e8 19 16 00 00       	call   801af0 <_panic>

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
  8004e6:	e8 08 23 00 00       	call   8027f3 <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  8004eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f2:	e8 b5 fe ff ff       	call   8003ac <diskaddr>
  8004f7:	83 c4 0c             	add    $0xc,%esp
  8004fa:	68 08 01 00 00       	push   $0x108
  8004ff:	50                   	push   %eax
  800500:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800506:	50                   	push   %eax
  800507:	e8 2f 1e 00 00       	call   80233b <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80050c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800513:	e8 94 fe ff ff       	call   8003ac <diskaddr>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	68 de 3e 80 00       	push   $0x803ede
  800520:	50                   	push   %eax
  800521:	e8 7f 1c 00 00       	call   8021a5 <strcpy>
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
  800586:	e8 9b 20 00 00       	call   802626 <sys_page_unmap>
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
  8005bd:	e8 94 1c 00 00       	call   802256 <strcmp>
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
  8005e7:	e8 4f 1d 00 00       	call   80233b <memmove>
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
  800616:	e8 20 1d 00 00       	call   80233b <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80061b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800622:	e8 85 fd ff ff       	call   8003ac <diskaddr>
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	68 de 3e 80 00       	push   $0x803ede
  80062f:	50                   	push   %eax
  800630:	e8 70 1b 00 00       	call   8021a5 <strcpy>
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
  80067b:	e8 a6 1f 00 00       	call   802626 <sys_page_unmap>
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
  8006b2:	e8 9f 1b 00 00       	call   802256 <strcmp>
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
  8006dc:	e8 5a 1c 00 00       	call   80233b <memmove>
	flush_block(diskaddr(1));
  8006e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e8:	e8 bf fc ff ff       	call   8003ac <diskaddr>
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	e8 35 fd ff ff       	call   80042a <flush_block>
	cprintf("block cache is good\n");
  8006f5:	c7 04 24 1a 3f 80 00 	movl   $0x803f1a,(%esp)
  8006fc:	e8 ca 14 00 00       	call   801bcb <cprintf>
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
  80071d:	e8 19 1c 00 00       	call   80233b <memmove>
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
  80073b:	e8 b0 13 00 00       	call   801af0 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800740:	68 e5 3e 80 00       	push   $0x803ee5
  800745:	68 5d 3d 80 00       	push   $0x803d5d
  80074a:	6a 70                	push   $0x70
  80074c:	68 50 3e 80 00       	push   $0x803e50
  800751:	e8 9a 13 00 00       	call   801af0 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800756:	68 ff 3e 80 00       	push   $0x803eff
  80075b:	68 5d 3d 80 00       	push   $0x803d5d
  800760:	6a 74                	push   $0x74
  800762:	68 50 3e 80 00       	push   $0x803e50
  800767:	e8 84 13 00 00       	call   801af0 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80076c:	68 2c 3e 80 00       	push   $0x803e2c
  800771:	68 5d 3d 80 00       	push   $0x803d5d
  800776:	6a 77                	push   $0x77
  800778:	68 50 3e 80 00       	push   $0x803e50
  80077d:	e8 6e 13 00 00       	call   801af0 <_panic>
	assert(va_is_mapped(diskaddr(1)));
  800782:	68 00 3f 80 00       	push   $0x803f00
  800787:	68 5d 3d 80 00       	push   $0x803d5d
  80078c:	68 88 00 00 00       	push   $0x88
  800791:	68 50 3e 80 00       	push   $0x803e50
  800796:	e8 55 13 00 00       	call   801af0 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  80079b:	68 ff 3e 80 00       	push   $0x803eff
  8007a0:	68 5d 3d 80 00       	push   $0x803d5d
  8007a5:	68 90 00 00 00       	push   $0x90
  8007aa:	68 50 3e 80 00       	push   $0x803e50
  8007af:	e8 3c 13 00 00       	call   801af0 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007b4:	68 2c 3e 80 00       	push   $0x803e2c
  8007b9:	68 5d 3d 80 00       	push   $0x803d5d
  8007be:	68 93 00 00 00       	push   $0x93
  8007c3:	68 50 3e 80 00       	push   $0x803e50
  8007c8:	e8 23 13 00 00       	call   801af0 <_panic>

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
  8007f1:	e8 d5 13 00 00       	call   801bcb <cprintf>
}
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
		panic("bad file system magic number");
  8007fb:	83 ec 04             	sub    $0x4,%esp
  8007fe:	68 2f 3f 80 00       	push   $0x803f2f
  800803:	6a 12                	push   $0x12
  800805:	68 4c 3f 80 00       	push   $0x803f4c
  80080a:	e8 e1 12 00 00       	call   801af0 <_panic>
		panic("file system is too large");
  80080f:	83 ec 04             	sub    $0x4,%esp
  800812:	68 54 3f 80 00       	push   $0x803f54
  800817:	6a 15                	push   $0x15
  800819:	68 4c 3f 80 00       	push   $0x803f4c
  80081e:	e8 cd 12 00 00       	call   801af0 <_panic>

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
  80089a:	e8 51 12 00 00       	call   801af0 <_panic>

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
  80095e:	e8 92 19 00 00       	call   8022f5 <memset>
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
  800a05:	e8 e6 10 00 00       	call   801af0 <_panic>
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
  800a34:	e8 92 11 00 00       	call   801bcb <cprintf>
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
  800a54:	e8 97 10 00 00       	call   801af0 <_panic>
	assert(!block_is_free(1));
  800a59:	68 c2 3f 80 00       	push   $0x803fc2
  800a5e:	68 5d 3d 80 00       	push   $0x803d5d
  800a63:	6a 5e                	push   $0x5e
  800a65:	68 4c 3f 80 00       	push   $0x803f4c
  800a6a:	e8 81 10 00 00       	call   801af0 <_panic>

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
  800b1f:	e8 d1 17 00 00       	call   8022f5 <memset>
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
  800bdd:	e8 59 17 00 00       	call   80233b <memmove>
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
  800c8f:	e8 c2 15 00 00       	call   802256 <strcmp>
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
  800cc6:	e8 25 0e 00 00       	call   801af0 <_panic>
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
  800d00:	e8 a0 14 00 00       	call   8021a5 <strcpy>
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
  800e26:	e8 10 15 00 00       	call   80233b <memmove>
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
  800ed9:	e8 ed 0c 00 00       	call   801bcb <cprintf>
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
  800f94:	e8 a2 13 00 00       	call   80233b <memmove>
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
  80111c:	e8 cf 09 00 00       	call   801af0 <_panic>
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
  80115f:	e8 41 10 00 00       	call   8021a5 <strcpy>
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
  80120e:	e8 67 1f 00 00       	call   80317a <pageref>
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
  801243:	e8 59 13 00 00       	call   8025a1 <sys_page_alloc>
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
  801274:	e8 7c 10 00 00       	call   8022f5 <memset>
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
  8012ad:	e8 c8 1e 00 00       	call   80317a <pageref>
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
  8013dc:	e8 c4 0d 00 00       	call   8021a5 <strcpy>
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
  801465:	e8 d1 0e 00 00       	call   80233b <memmove>
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
  801591:	e8 35 06 00 00       	call   801bcb <cprintf>
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
  8015ab:	e8 df 12 00 00       	call   80288f <ipc_recv>
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
  80160c:	e8 ba 05 00 00       	call   801bcb <cprintf>
  801611:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801614:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801619:	ff 75 f0             	push   -0x10(%ebp)
  80161c:	ff 75 ec             	push   -0x14(%ebp)
  80161f:	50                   	push   %eax
  801620:	ff 75 f4             	push   -0xc(%ebp)
  801623:	e8 d7 12 00 00       	call   8028ff <ipc_send>
		sys_page_unmap(0, fsreq);
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	ff 35 44 50 80 00    	push   0x805044
  801631:	6a 00                	push   $0x0
  801633:	e8 ee 0f 00 00       	call   802626 <sys_page_unmap>
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
  801655:	e8 71 05 00 00       	call   801bcb <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80165a:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80165f:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801664:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801666:	c7 04 24 85 40 80 00 	movl   $0x804085,(%esp)
  80166d:	e8 59 05 00 00       	call   801bcb <cprintf>

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
  801690:	e8 0c 0f 00 00       	call   8025a1 <sys_page_alloc>
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
  8016b3:	e8 83 0c 00 00       	call   80233b <memmove>
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
  801700:	e8 c6 04 00 00       	call   801bcb <cprintf>

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
  801752:	e8 74 04 00 00       	call   801bcb <cprintf>

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
  80177e:	e8 d3 0a 00 00       	call   802256 <strcmp>
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	0f 85 05 02 00 00    	jne    801993 <fs_test+0x312>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	68 5b 41 80 00       	push   $0x80415b
  801796:	e8 30 04 00 00       	call   801bcb <cprintf>

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
  8017e6:	e8 e0 03 00 00       	call   801bcb <cprintf>

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
  80182d:	e8 99 03 00 00       	call   801bcb <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801832:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  801839:	e8 2c 09 00 00       	call   80216a <strlen>
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
  801892:	e8 0e 09 00 00       	call   8021a5 <strcpy>
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
  8018ef:	e8 d7 02 00 00       	call   801bcb <cprintf>
}
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8018f9:	50                   	push   %eax
  8018fa:	68 94 40 80 00       	push   $0x804094
  8018ff:	6a 12                	push   $0x12
  801901:	68 a7 40 80 00       	push   $0x8040a7
  801906:	e8 e5 01 00 00       	call   801af0 <_panic>
		panic("alloc_block: %e", r);
  80190b:	50                   	push   %eax
  80190c:	68 b1 40 80 00       	push   $0x8040b1
  801911:	6a 17                	push   $0x17
  801913:	68 a7 40 80 00       	push   $0x8040a7
  801918:	e8 d3 01 00 00       	call   801af0 <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  80191d:	68 c1 40 80 00       	push   $0x8040c1
  801922:	68 5d 3d 80 00       	push   $0x803d5d
  801927:	6a 19                	push   $0x19
  801929:	68 a7 40 80 00       	push   $0x8040a7
  80192e:	e8 bd 01 00 00       	call   801af0 <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801933:	68 3c 42 80 00       	push   $0x80423c
  801938:	68 5d 3d 80 00       	push   $0x803d5d
  80193d:	6a 1b                	push   $0x1b
  80193f:	68 a7 40 80 00       	push   $0x8040a7
  801944:	e8 a7 01 00 00       	call   801af0 <_panic>
		panic("file_open /not-found: %e", r);
  801949:	50                   	push   %eax
  80194a:	68 fc 40 80 00       	push   $0x8040fc
  80194f:	6a 1f                	push   $0x1f
  801951:	68 a7 40 80 00       	push   $0x8040a7
  801956:	e8 95 01 00 00       	call   801af0 <_panic>
		panic("file_open /not-found succeeded!");
  80195b:	83 ec 04             	sub    $0x4,%esp
  80195e:	68 5c 42 80 00       	push   $0x80425c
  801963:	6a 21                	push   $0x21
  801965:	68 a7 40 80 00       	push   $0x8040a7
  80196a:	e8 81 01 00 00       	call   801af0 <_panic>
		panic("file_open /newmotd: %e", r);
  80196f:	50                   	push   %eax
  801970:	68 1e 41 80 00       	push   $0x80411e
  801975:	6a 23                	push   $0x23
  801977:	68 a7 40 80 00       	push   $0x8040a7
  80197c:	e8 6f 01 00 00       	call   801af0 <_panic>
		panic("file_get_block: %e", r);
  801981:	50                   	push   %eax
  801982:	68 48 41 80 00       	push   $0x804148
  801987:	6a 27                	push   $0x27
  801989:	68 a7 40 80 00       	push   $0x8040a7
  80198e:	e8 5d 01 00 00       	call   801af0 <_panic>
		panic("file_get_block returned wrong data");
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	68 a4 42 80 00       	push   $0x8042a4
  80199b:	6a 29                	push   $0x29
  80199d:	68 a7 40 80 00       	push   $0x8040a7
  8019a2:	e8 49 01 00 00       	call   801af0 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019a7:	68 74 41 80 00       	push   $0x804174
  8019ac:	68 5d 3d 80 00       	push   $0x803d5d
  8019b1:	6a 2d                	push   $0x2d
  8019b3:	68 a7 40 80 00       	push   $0x8040a7
  8019b8:	e8 33 01 00 00       	call   801af0 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019bd:	68 73 41 80 00       	push   $0x804173
  8019c2:	68 5d 3d 80 00       	push   $0x803d5d
  8019c7:	6a 2f                	push   $0x2f
  8019c9:	68 a7 40 80 00       	push   $0x8040a7
  8019ce:	e8 1d 01 00 00       	call   801af0 <_panic>
		panic("file_set_size: %e", r);
  8019d3:	50                   	push   %eax
  8019d4:	68 a3 41 80 00       	push   $0x8041a3
  8019d9:	6a 33                	push   $0x33
  8019db:	68 a7 40 80 00       	push   $0x8040a7
  8019e0:	e8 0b 01 00 00       	call   801af0 <_panic>
	assert(f->f_direct[0] == 0);
  8019e5:	68 b5 41 80 00       	push   $0x8041b5
  8019ea:	68 5d 3d 80 00       	push   $0x803d5d
  8019ef:	6a 34                	push   $0x34
  8019f1:	68 a7 40 80 00       	push   $0x8040a7
  8019f6:	e8 f5 00 00 00       	call   801af0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019fb:	68 c9 41 80 00       	push   $0x8041c9
  801a00:	68 5d 3d 80 00       	push   $0x803d5d
  801a05:	6a 35                	push   $0x35
  801a07:	68 a7 40 80 00       	push   $0x8040a7
  801a0c:	e8 df 00 00 00       	call   801af0 <_panic>
		panic("file_set_size 2: %e", r);
  801a11:	50                   	push   %eax
  801a12:	68 fa 41 80 00       	push   $0x8041fa
  801a17:	6a 39                	push   $0x39
  801a19:	68 a7 40 80 00       	push   $0x8040a7
  801a1e:	e8 cd 00 00 00       	call   801af0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a23:	68 c9 41 80 00       	push   $0x8041c9
  801a28:	68 5d 3d 80 00       	push   $0x803d5d
  801a2d:	6a 3a                	push   $0x3a
  801a2f:	68 a7 40 80 00       	push   $0x8040a7
  801a34:	e8 b7 00 00 00       	call   801af0 <_panic>
		panic("file_get_block 2: %e", r);
  801a39:	50                   	push   %eax
  801a3a:	68 0e 42 80 00       	push   $0x80420e
  801a3f:	6a 3c                	push   $0x3c
  801a41:	68 a7 40 80 00       	push   $0x8040a7
  801a46:	e8 a5 00 00 00       	call   801af0 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a4b:	68 74 41 80 00       	push   $0x804174
  801a50:	68 5d 3d 80 00       	push   $0x803d5d
  801a55:	6a 3e                	push   $0x3e
  801a57:	68 a7 40 80 00       	push   $0x8040a7
  801a5c:	e8 8f 00 00 00       	call   801af0 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a61:	68 73 41 80 00       	push   $0x804173
  801a66:	68 5d 3d 80 00       	push   $0x803d5d
  801a6b:	6a 40                	push   $0x40
  801a6d:	68 a7 40 80 00       	push   $0x8040a7
  801a72:	e8 79 00 00 00       	call   801af0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a77:	68 c9 41 80 00       	push   $0x8041c9
  801a7c:	68 5d 3d 80 00       	push   $0x803d5d
  801a81:	6a 41                	push   $0x41
  801a83:	68 a7 40 80 00       	push   $0x8040a7
  801a88:	e8 63 00 00 00       	call   801af0 <_panic>

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
  801a98:	e8 c6 0a 00 00       	call   802563 <sys_getenvid>
  801a9d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801aa2:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801aa8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aad:	a3 08 a0 80 00       	mov    %eax,0x80a008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	7e 07                	jle    801abd <libmain+0x30>
		binaryname = argv[0];
  801ab6:	8b 06                	mov    (%esi),%eax
  801ab8:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	e8 79 fb ff ff       	call   801640 <umain>

	// exit gracefully
	exit();
  801ac7:	e8 0a 00 00 00       	call   801ad6 <exit>
}
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801adc:	e8 82 10 00 00       	call   802b63 <close_all>
	sys_env_destroy(0);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 37 0a 00 00       	call   802522 <sys_env_destroy>
}
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801af5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801af8:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801afe:	e8 60 0a 00 00       	call   802563 <sys_getenvid>
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 75 0c             	push   0xc(%ebp)
  801b09:	ff 75 08             	push   0x8(%ebp)
  801b0c:	56                   	push   %esi
  801b0d:	50                   	push   %eax
  801b0e:	68 d4 42 80 00       	push   $0x8042d4
  801b13:	e8 b3 00 00 00       	call   801bcb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b18:	83 c4 18             	add    $0x18,%esp
  801b1b:	53                   	push   %ebx
  801b1c:	ff 75 10             	push   0x10(%ebp)
  801b1f:	e8 56 00 00 00       	call   801b7a <vcprintf>
	cprintf("\n");
  801b24:	c7 04 24 e3 3e 80 00 	movl   $0x803ee3,(%esp)
  801b2b:	e8 9b 00 00 00       	call   801bcb <cprintf>
  801b30:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b33:	cc                   	int3   
  801b34:	eb fd                	jmp    801b33 <_panic+0x43>

00801b36 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	53                   	push   %ebx
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b40:	8b 13                	mov    (%ebx),%edx
  801b42:	8d 42 01             	lea    0x1(%edx),%eax
  801b45:	89 03                	mov    %eax,(%ebx)
  801b47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b4e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b53:	74 09                	je     801b5e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801b55:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801b5e:	83 ec 08             	sub    $0x8,%esp
  801b61:	68 ff 00 00 00       	push   $0xff
  801b66:	8d 43 08             	lea    0x8(%ebx),%eax
  801b69:	50                   	push   %eax
  801b6a:	e8 76 09 00 00       	call   8024e5 <sys_cputs>
		b->idx = 0;
  801b6f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	eb db                	jmp    801b55 <putch+0x1f>

00801b7a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b83:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b8a:	00 00 00 
	b.cnt = 0;
  801b8d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b94:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b97:	ff 75 0c             	push   0xc(%ebp)
  801b9a:	ff 75 08             	push   0x8(%ebp)
  801b9d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	68 36 1b 80 00       	push   $0x801b36
  801ba9:	e8 14 01 00 00       	call   801cc2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bae:	83 c4 08             	add    $0x8,%esp
  801bb1:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801bb7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bbd:	50                   	push   %eax
  801bbe:	e8 22 09 00 00       	call   8024e5 <sys_cputs>

	return b.cnt;
}
  801bc3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bd1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bd4:	50                   	push   %eax
  801bd5:	ff 75 08             	push   0x8(%ebp)
  801bd8:	e8 9d ff ff ff       	call   801b7a <vcprintf>
	va_end(ap);

	return cnt;
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	57                   	push   %edi
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 1c             	sub    $0x1c,%esp
  801be8:	89 c7                	mov    %eax,%edi
  801bea:	89 d6                	mov    %edx,%esi
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf2:	89 d1                	mov    %edx,%ecx
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bf9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801bfc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bff:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c02:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c05:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801c0c:	39 c2                	cmp    %eax,%edx
  801c0e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801c11:	72 3e                	jb     801c51 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	ff 75 18             	push   0x18(%ebp)
  801c19:	83 eb 01             	sub    $0x1,%ebx
  801c1c:	53                   	push   %ebx
  801c1d:	50                   	push   %eax
  801c1e:	83 ec 08             	sub    $0x8,%esp
  801c21:	ff 75 e4             	push   -0x1c(%ebp)
  801c24:	ff 75 e0             	push   -0x20(%ebp)
  801c27:	ff 75 dc             	push   -0x24(%ebp)
  801c2a:	ff 75 d8             	push   -0x28(%ebp)
  801c2d:	e8 ae 1e 00 00       	call   803ae0 <__udivdi3>
  801c32:	83 c4 18             	add    $0x18,%esp
  801c35:	52                   	push   %edx
  801c36:	50                   	push   %eax
  801c37:	89 f2                	mov    %esi,%edx
  801c39:	89 f8                	mov    %edi,%eax
  801c3b:	e8 9f ff ff ff       	call   801bdf <printnum>
  801c40:	83 c4 20             	add    $0x20,%esp
  801c43:	eb 13                	jmp    801c58 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	56                   	push   %esi
  801c49:	ff 75 18             	push   0x18(%ebp)
  801c4c:	ff d7                	call   *%edi
  801c4e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	85 db                	test   %ebx,%ebx
  801c56:	7f ed                	jg     801c45 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	56                   	push   %esi
  801c5c:	83 ec 04             	sub    $0x4,%esp
  801c5f:	ff 75 e4             	push   -0x1c(%ebp)
  801c62:	ff 75 e0             	push   -0x20(%ebp)
  801c65:	ff 75 dc             	push   -0x24(%ebp)
  801c68:	ff 75 d8             	push   -0x28(%ebp)
  801c6b:	e8 90 1f 00 00       	call   803c00 <__umoddi3>
  801c70:	83 c4 14             	add    $0x14,%esp
  801c73:	0f be 80 f7 42 80 00 	movsbl 0x8042f7(%eax),%eax
  801c7a:	50                   	push   %eax
  801c7b:	ff d7                	call   *%edi
}
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c8e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c92:	8b 10                	mov    (%eax),%edx
  801c94:	3b 50 04             	cmp    0x4(%eax),%edx
  801c97:	73 0a                	jae    801ca3 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c99:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c9c:	89 08                	mov    %ecx,(%eax)
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	88 02                	mov    %al,(%edx)
}
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <printfmt>:
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801cab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801cae:	50                   	push   %eax
  801caf:	ff 75 10             	push   0x10(%ebp)
  801cb2:	ff 75 0c             	push   0xc(%ebp)
  801cb5:	ff 75 08             	push   0x8(%ebp)
  801cb8:	e8 05 00 00 00       	call   801cc2 <vprintfmt>
}
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <vprintfmt>:
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	57                   	push   %edi
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	83 ec 3c             	sub    $0x3c,%esp
  801ccb:	8b 75 08             	mov    0x8(%ebp),%esi
  801cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cd1:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cd4:	eb 0a                	jmp    801ce0 <vprintfmt+0x1e>
			putch(ch, putdat);
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	53                   	push   %ebx
  801cda:	50                   	push   %eax
  801cdb:	ff d6                	call   *%esi
  801cdd:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ce0:	83 c7 01             	add    $0x1,%edi
  801ce3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ce7:	83 f8 25             	cmp    $0x25,%eax
  801cea:	74 0c                	je     801cf8 <vprintfmt+0x36>
			if (ch == '\0')
  801cec:	85 c0                	test   %eax,%eax
  801cee:	75 e6                	jne    801cd6 <vprintfmt+0x14>
}
  801cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
		padc = ' ';
  801cf8:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801cfc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801d03:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801d0a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801d11:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801d16:	8d 47 01             	lea    0x1(%edi),%eax
  801d19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d1c:	0f b6 17             	movzbl (%edi),%edx
  801d1f:	8d 42 dd             	lea    -0x23(%edx),%eax
  801d22:	3c 55                	cmp    $0x55,%al
  801d24:	0f 87 bb 03 00 00    	ja     8020e5 <vprintfmt+0x423>
  801d2a:	0f b6 c0             	movzbl %al,%eax
  801d2d:	ff 24 85 40 44 80 00 	jmp    *0x804440(,%eax,4)
  801d34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801d37:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801d3b:	eb d9                	jmp    801d16 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801d3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d40:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801d44:	eb d0                	jmp    801d16 <vprintfmt+0x54>
  801d46:	0f b6 d2             	movzbl %dl,%edx
  801d49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801d4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801d54:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d57:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d5b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d5e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801d61:	83 f9 09             	cmp    $0x9,%ecx
  801d64:	77 55                	ja     801dbb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801d66:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801d69:	eb e9                	jmp    801d54 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801d6b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6e:	8b 00                	mov    (%eax),%eax
  801d70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d73:	8b 45 14             	mov    0x14(%ebp),%eax
  801d76:	8d 40 04             	lea    0x4(%eax),%eax
  801d79:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801d7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801d7f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d83:	79 91                	jns    801d16 <vprintfmt+0x54>
				width = precision, precision = -1;
  801d85:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d8b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801d92:	eb 82                	jmp    801d16 <vprintfmt+0x54>
  801d94:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d97:	85 d2                	test   %edx,%edx
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9e:	0f 49 c2             	cmovns %edx,%eax
  801da1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801da4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801da7:	e9 6a ff ff ff       	jmp    801d16 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801dac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801daf:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801db6:	e9 5b ff ff ff       	jmp    801d16 <vprintfmt+0x54>
  801dbb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801dbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dc1:	eb bc                	jmp    801d7f <vprintfmt+0xbd>
			lflag++;
  801dc3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801dc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801dc9:	e9 48 ff ff ff       	jmp    801d16 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801dce:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd1:	8d 78 04             	lea    0x4(%eax),%edi
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	53                   	push   %ebx
  801dd8:	ff 30                	push   (%eax)
  801dda:	ff d6                	call   *%esi
			break;
  801ddc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801ddf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801de2:	e9 9d 02 00 00       	jmp    802084 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  801de7:	8b 45 14             	mov    0x14(%ebp),%eax
  801dea:	8d 78 04             	lea    0x4(%eax),%edi
  801ded:	8b 10                	mov    (%eax),%edx
  801def:	89 d0                	mov    %edx,%eax
  801df1:	f7 d8                	neg    %eax
  801df3:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801df6:	83 f8 0f             	cmp    $0xf,%eax
  801df9:	7f 23                	jg     801e1e <vprintfmt+0x15c>
  801dfb:	8b 14 85 a0 45 80 00 	mov    0x8045a0(,%eax,4),%edx
  801e02:	85 d2                	test   %edx,%edx
  801e04:	74 18                	je     801e1e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801e06:	52                   	push   %edx
  801e07:	68 6f 3d 80 00       	push   $0x803d6f
  801e0c:	53                   	push   %ebx
  801e0d:	56                   	push   %esi
  801e0e:	e8 92 fe ff ff       	call   801ca5 <printfmt>
  801e13:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e16:	89 7d 14             	mov    %edi,0x14(%ebp)
  801e19:	e9 66 02 00 00       	jmp    802084 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801e1e:	50                   	push   %eax
  801e1f:	68 0f 43 80 00       	push   $0x80430f
  801e24:	53                   	push   %ebx
  801e25:	56                   	push   %esi
  801e26:	e8 7a fe ff ff       	call   801ca5 <printfmt>
  801e2b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e2e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801e31:	e9 4e 02 00 00       	jmp    802084 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801e36:	8b 45 14             	mov    0x14(%ebp),%eax
  801e39:	83 c0 04             	add    $0x4,%eax
  801e3c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801e3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e42:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801e44:	85 d2                	test   %edx,%edx
  801e46:	b8 08 43 80 00       	mov    $0x804308,%eax
  801e4b:	0f 45 c2             	cmovne %edx,%eax
  801e4e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801e51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e55:	7e 06                	jle    801e5d <vprintfmt+0x19b>
  801e57:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801e5b:	75 0d                	jne    801e6a <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e5d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e60:	89 c7                	mov    %eax,%edi
  801e62:	03 45 e0             	add    -0x20(%ebp),%eax
  801e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e68:	eb 55                	jmp    801ebf <vprintfmt+0x1fd>
  801e6a:	83 ec 08             	sub    $0x8,%esp
  801e6d:	ff 75 d8             	push   -0x28(%ebp)
  801e70:	ff 75 cc             	push   -0x34(%ebp)
  801e73:	e8 0a 03 00 00       	call   802182 <strnlen>
  801e78:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e7b:	29 c1                	sub    %eax,%ecx
  801e7d:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801e85:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801e89:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801e8c:	eb 0f                	jmp    801e9d <vprintfmt+0x1db>
					putch(padc, putdat);
  801e8e:	83 ec 08             	sub    $0x8,%esp
  801e91:	53                   	push   %ebx
  801e92:	ff 75 e0             	push   -0x20(%ebp)
  801e95:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801e97:	83 ef 01             	sub    $0x1,%edi
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 ff                	test   %edi,%edi
  801e9f:	7f ed                	jg     801e8e <vprintfmt+0x1cc>
  801ea1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801ea4:	85 d2                	test   %edx,%edx
  801ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  801eab:	0f 49 c2             	cmovns %edx,%eax
  801eae:	29 c2                	sub    %eax,%edx
  801eb0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801eb3:	eb a8                	jmp    801e5d <vprintfmt+0x19b>
					putch(ch, putdat);
  801eb5:	83 ec 08             	sub    $0x8,%esp
  801eb8:	53                   	push   %ebx
  801eb9:	52                   	push   %edx
  801eba:	ff d6                	call   *%esi
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ec2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ec4:	83 c7 01             	add    $0x1,%edi
  801ec7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ecb:	0f be d0             	movsbl %al,%edx
  801ece:	85 d2                	test   %edx,%edx
  801ed0:	74 4b                	je     801f1d <vprintfmt+0x25b>
  801ed2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ed6:	78 06                	js     801ede <vprintfmt+0x21c>
  801ed8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801edc:	78 1e                	js     801efc <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801ede:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801ee2:	74 d1                	je     801eb5 <vprintfmt+0x1f3>
  801ee4:	0f be c0             	movsbl %al,%eax
  801ee7:	83 e8 20             	sub    $0x20,%eax
  801eea:	83 f8 5e             	cmp    $0x5e,%eax
  801eed:	76 c6                	jbe    801eb5 <vprintfmt+0x1f3>
					putch('?', putdat);
  801eef:	83 ec 08             	sub    $0x8,%esp
  801ef2:	53                   	push   %ebx
  801ef3:	6a 3f                	push   $0x3f
  801ef5:	ff d6                	call   *%esi
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	eb c3                	jmp    801ebf <vprintfmt+0x1fd>
  801efc:	89 cf                	mov    %ecx,%edi
  801efe:	eb 0e                	jmp    801f0e <vprintfmt+0x24c>
				putch(' ', putdat);
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	53                   	push   %ebx
  801f04:	6a 20                	push   $0x20
  801f06:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801f08:	83 ef 01             	sub    $0x1,%edi
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 ff                	test   %edi,%edi
  801f10:	7f ee                	jg     801f00 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801f12:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801f15:	89 45 14             	mov    %eax,0x14(%ebp)
  801f18:	e9 67 01 00 00       	jmp    802084 <vprintfmt+0x3c2>
  801f1d:	89 cf                	mov    %ecx,%edi
  801f1f:	eb ed                	jmp    801f0e <vprintfmt+0x24c>
	if (lflag >= 2)
  801f21:	83 f9 01             	cmp    $0x1,%ecx
  801f24:	7f 1b                	jg     801f41 <vprintfmt+0x27f>
	else if (lflag)
  801f26:	85 c9                	test   %ecx,%ecx
  801f28:	74 63                	je     801f8d <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801f2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2d:	8b 00                	mov    (%eax),%eax
  801f2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f32:	99                   	cltd   
  801f33:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f36:	8b 45 14             	mov    0x14(%ebp),%eax
  801f39:	8d 40 04             	lea    0x4(%eax),%eax
  801f3c:	89 45 14             	mov    %eax,0x14(%ebp)
  801f3f:	eb 17                	jmp    801f58 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801f41:	8b 45 14             	mov    0x14(%ebp),%eax
  801f44:	8b 50 04             	mov    0x4(%eax),%edx
  801f47:	8b 00                	mov    (%eax),%eax
  801f49:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f4c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f4f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f52:	8d 40 08             	lea    0x8(%eax),%eax
  801f55:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801f58:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f5b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801f5e:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801f63:	85 c9                	test   %ecx,%ecx
  801f65:	0f 89 ff 00 00 00    	jns    80206a <vprintfmt+0x3a8>
				putch('-', putdat);
  801f6b:	83 ec 08             	sub    $0x8,%esp
  801f6e:	53                   	push   %ebx
  801f6f:	6a 2d                	push   $0x2d
  801f71:	ff d6                	call   *%esi
				num = -(long long) num;
  801f73:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f76:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801f79:	f7 da                	neg    %edx
  801f7b:	83 d1 00             	adc    $0x0,%ecx
  801f7e:	f7 d9                	neg    %ecx
  801f80:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801f83:	bf 0a 00 00 00       	mov    $0xa,%edi
  801f88:	e9 dd 00 00 00       	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801f8d:	8b 45 14             	mov    0x14(%ebp),%eax
  801f90:	8b 00                	mov    (%eax),%eax
  801f92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f95:	99                   	cltd   
  801f96:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f99:	8b 45 14             	mov    0x14(%ebp),%eax
  801f9c:	8d 40 04             	lea    0x4(%eax),%eax
  801f9f:	89 45 14             	mov    %eax,0x14(%ebp)
  801fa2:	eb b4                	jmp    801f58 <vprintfmt+0x296>
	if (lflag >= 2)
  801fa4:	83 f9 01             	cmp    $0x1,%ecx
  801fa7:	7f 1e                	jg     801fc7 <vprintfmt+0x305>
	else if (lflag)
  801fa9:	85 c9                	test   %ecx,%ecx
  801fab:	74 32                	je     801fdf <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801fad:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb0:	8b 10                	mov    (%eax),%edx
  801fb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fb7:	8d 40 04             	lea    0x4(%eax),%eax
  801fba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fbd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801fc2:	e9 a3 00 00 00       	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801fc7:	8b 45 14             	mov    0x14(%ebp),%eax
  801fca:	8b 10                	mov    (%eax),%edx
  801fcc:	8b 48 04             	mov    0x4(%eax),%ecx
  801fcf:	8d 40 08             	lea    0x8(%eax),%eax
  801fd2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fd5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  801fda:	e9 8b 00 00 00       	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801fdf:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe2:	8b 10                	mov    (%eax),%edx
  801fe4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fe9:	8d 40 04             	lea    0x4(%eax),%eax
  801fec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801fef:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801ff4:	eb 74                	jmp    80206a <vprintfmt+0x3a8>
	if (lflag >= 2)
  801ff6:	83 f9 01             	cmp    $0x1,%ecx
  801ff9:	7f 1b                	jg     802016 <vprintfmt+0x354>
	else if (lflag)
  801ffb:	85 c9                	test   %ecx,%ecx
  801ffd:	74 2c                	je     80202b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801fff:	8b 45 14             	mov    0x14(%ebp),%eax
  802002:	8b 10                	mov    (%eax),%edx
  802004:	b9 00 00 00 00       	mov    $0x0,%ecx
  802009:	8d 40 04             	lea    0x4(%eax),%eax
  80200c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80200f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  802014:	eb 54                	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  802016:	8b 45 14             	mov    0x14(%ebp),%eax
  802019:	8b 10                	mov    (%eax),%edx
  80201b:	8b 48 04             	mov    0x4(%eax),%ecx
  80201e:	8d 40 08             	lea    0x8(%eax),%eax
  802021:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  802024:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  802029:	eb 3f                	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80202b:	8b 45 14             	mov    0x14(%ebp),%eax
  80202e:	8b 10                	mov    (%eax),%edx
  802030:	b9 00 00 00 00       	mov    $0x0,%ecx
  802035:	8d 40 04             	lea    0x4(%eax),%eax
  802038:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80203b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  802040:	eb 28                	jmp    80206a <vprintfmt+0x3a8>
			putch('0', putdat);
  802042:	83 ec 08             	sub    $0x8,%esp
  802045:	53                   	push   %ebx
  802046:	6a 30                	push   $0x30
  802048:	ff d6                	call   *%esi
			putch('x', putdat);
  80204a:	83 c4 08             	add    $0x8,%esp
  80204d:	53                   	push   %ebx
  80204e:	6a 78                	push   $0x78
  802050:	ff d6                	call   *%esi
			num = (unsigned long long)
  802052:	8b 45 14             	mov    0x14(%ebp),%eax
  802055:	8b 10                	mov    (%eax),%edx
  802057:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80205c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80205f:	8d 40 04             	lea    0x4(%eax),%eax
  802062:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802065:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80206a:	83 ec 0c             	sub    $0xc,%esp
  80206d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  802071:	50                   	push   %eax
  802072:	ff 75 e0             	push   -0x20(%ebp)
  802075:	57                   	push   %edi
  802076:	51                   	push   %ecx
  802077:	52                   	push   %edx
  802078:	89 da                	mov    %ebx,%edx
  80207a:	89 f0                	mov    %esi,%eax
  80207c:	e8 5e fb ff ff       	call   801bdf <printnum>
			break;
  802081:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  802084:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802087:	e9 54 fc ff ff       	jmp    801ce0 <vprintfmt+0x1e>
	if (lflag >= 2)
  80208c:	83 f9 01             	cmp    $0x1,%ecx
  80208f:	7f 1b                	jg     8020ac <vprintfmt+0x3ea>
	else if (lflag)
  802091:	85 c9                	test   %ecx,%ecx
  802093:	74 2c                	je     8020c1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  802095:	8b 45 14             	mov    0x14(%ebp),%eax
  802098:	8b 10                	mov    (%eax),%edx
  80209a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80209f:	8d 40 04             	lea    0x4(%eax),%eax
  8020a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020a5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8020aa:	eb be                	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8020ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8020af:	8b 10                	mov    (%eax),%edx
  8020b1:	8b 48 04             	mov    0x4(%eax),%ecx
  8020b4:	8d 40 08             	lea    0x8(%eax),%eax
  8020b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020ba:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8020bf:	eb a9                	jmp    80206a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8020c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c4:	8b 10                	mov    (%eax),%edx
  8020c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020cb:	8d 40 04             	lea    0x4(%eax),%eax
  8020ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020d1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8020d6:	eb 92                	jmp    80206a <vprintfmt+0x3a8>
			putch(ch, putdat);
  8020d8:	83 ec 08             	sub    $0x8,%esp
  8020db:	53                   	push   %ebx
  8020dc:	6a 25                	push   $0x25
  8020de:	ff d6                	call   *%esi
			break;
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	eb 9f                	jmp    802084 <vprintfmt+0x3c2>
			putch('%', putdat);
  8020e5:	83 ec 08             	sub    $0x8,%esp
  8020e8:	53                   	push   %ebx
  8020e9:	6a 25                	push   $0x25
  8020eb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	89 f8                	mov    %edi,%eax
  8020f2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8020f6:	74 05                	je     8020fd <vprintfmt+0x43b>
  8020f8:	83 e8 01             	sub    $0x1,%eax
  8020fb:	eb f5                	jmp    8020f2 <vprintfmt+0x430>
  8020fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802100:	eb 82                	jmp    802084 <vprintfmt+0x3c2>

00802102 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 18             	sub    $0x18,%esp
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80210e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802111:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802115:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802118:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80211f:	85 c0                	test   %eax,%eax
  802121:	74 26                	je     802149 <vsnprintf+0x47>
  802123:	85 d2                	test   %edx,%edx
  802125:	7e 22                	jle    802149 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802127:	ff 75 14             	push   0x14(%ebp)
  80212a:	ff 75 10             	push   0x10(%ebp)
  80212d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802130:	50                   	push   %eax
  802131:	68 88 1c 80 00       	push   $0x801c88
  802136:	e8 87 fb ff ff       	call   801cc2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80213b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80213e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802144:	83 c4 10             	add    $0x10,%esp
}
  802147:	c9                   	leave  
  802148:	c3                   	ret    
		return -E_INVAL;
  802149:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80214e:	eb f7                	jmp    802147 <vsnprintf+0x45>

00802150 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802156:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802159:	50                   	push   %eax
  80215a:	ff 75 10             	push   0x10(%ebp)
  80215d:	ff 75 0c             	push   0xc(%ebp)
  802160:	ff 75 08             	push   0x8(%ebp)
  802163:	e8 9a ff ff ff       	call   802102 <vsnprintf>
	va_end(ap);

	return rc;
}
  802168:	c9                   	leave  
  802169:	c3                   	ret    

0080216a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
  802175:	eb 03                	jmp    80217a <strlen+0x10>
		n++;
  802177:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80217a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80217e:	75 f7                	jne    802177 <strlen+0xd>
	return n;
}
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802188:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80218b:	b8 00 00 00 00       	mov    $0x0,%eax
  802190:	eb 03                	jmp    802195 <strnlen+0x13>
		n++;
  802192:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802195:	39 d0                	cmp    %edx,%eax
  802197:	74 08                	je     8021a1 <strnlen+0x1f>
  802199:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80219d:	75 f3                	jne    802192 <strnlen+0x10>
  80219f:	89 c2                	mov    %eax,%edx
	return n;
}
  8021a1:	89 d0                	mov    %edx,%eax
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	53                   	push   %ebx
  8021a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8021b8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8021bb:	83 c0 01             	add    $0x1,%eax
  8021be:	84 d2                	test   %dl,%dl
  8021c0:	75 f2                	jne    8021b4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8021c2:	89 c8                	mov    %ecx,%eax
  8021c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c7:	c9                   	leave  
  8021c8:	c3                   	ret    

008021c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	53                   	push   %ebx
  8021cd:	83 ec 10             	sub    $0x10,%esp
  8021d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021d3:	53                   	push   %ebx
  8021d4:	e8 91 ff ff ff       	call   80216a <strlen>
  8021d9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8021dc:	ff 75 0c             	push   0xc(%ebp)
  8021df:	01 d8                	add    %ebx,%eax
  8021e1:	50                   	push   %eax
  8021e2:	e8 be ff ff ff       	call   8021a5 <strcpy>
	return dst;
}
  8021e7:	89 d8                	mov    %ebx,%eax
  8021e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ec:	c9                   	leave  
  8021ed:	c3                   	ret    

008021ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021ee:	55                   	push   %ebp
  8021ef:	89 e5                	mov    %esp,%ebp
  8021f1:	56                   	push   %esi
  8021f2:	53                   	push   %ebx
  8021f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f9:	89 f3                	mov    %esi,%ebx
  8021fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021fe:	89 f0                	mov    %esi,%eax
  802200:	eb 0f                	jmp    802211 <strncpy+0x23>
		*dst++ = *src;
  802202:	83 c0 01             	add    $0x1,%eax
  802205:	0f b6 0a             	movzbl (%edx),%ecx
  802208:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80220b:	80 f9 01             	cmp    $0x1,%cl
  80220e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  802211:	39 d8                	cmp    %ebx,%eax
  802213:	75 ed                	jne    802202 <strncpy+0x14>
	}
	return ret;
}
  802215:	89 f0                	mov    %esi,%eax
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	56                   	push   %esi
  80221f:	53                   	push   %ebx
  802220:	8b 75 08             	mov    0x8(%ebp),%esi
  802223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802226:	8b 55 10             	mov    0x10(%ebp),%edx
  802229:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80222b:	85 d2                	test   %edx,%edx
  80222d:	74 21                	je     802250 <strlcpy+0x35>
  80222f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	eb 09                	jmp    802240 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802237:	83 c1 01             	add    $0x1,%ecx
  80223a:	83 c2 01             	add    $0x1,%edx
  80223d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  802240:	39 c2                	cmp    %eax,%edx
  802242:	74 09                	je     80224d <strlcpy+0x32>
  802244:	0f b6 19             	movzbl (%ecx),%ebx
  802247:	84 db                	test   %bl,%bl
  802249:	75 ec                	jne    802237 <strlcpy+0x1c>
  80224b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80224d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802250:	29 f0                	sub    %esi,%eax
}
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    

00802256 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80225f:	eb 06                	jmp    802267 <strcmp+0x11>
		p++, q++;
  802261:	83 c1 01             	add    $0x1,%ecx
  802264:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  802267:	0f b6 01             	movzbl (%ecx),%eax
  80226a:	84 c0                	test   %al,%al
  80226c:	74 04                	je     802272 <strcmp+0x1c>
  80226e:	3a 02                	cmp    (%edx),%al
  802270:	74 ef                	je     802261 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802272:	0f b6 c0             	movzbl %al,%eax
  802275:	0f b6 12             	movzbl (%edx),%edx
  802278:	29 d0                	sub    %edx,%eax
}
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    

0080227c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	53                   	push   %ebx
  802280:	8b 45 08             	mov    0x8(%ebp),%eax
  802283:	8b 55 0c             	mov    0xc(%ebp),%edx
  802286:	89 c3                	mov    %eax,%ebx
  802288:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80228b:	eb 06                	jmp    802293 <strncmp+0x17>
		n--, p++, q++;
  80228d:	83 c0 01             	add    $0x1,%eax
  802290:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  802293:	39 d8                	cmp    %ebx,%eax
  802295:	74 18                	je     8022af <strncmp+0x33>
  802297:	0f b6 08             	movzbl (%eax),%ecx
  80229a:	84 c9                	test   %cl,%cl
  80229c:	74 04                	je     8022a2 <strncmp+0x26>
  80229e:	3a 0a                	cmp    (%edx),%cl
  8022a0:	74 eb                	je     80228d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8022a2:	0f b6 00             	movzbl (%eax),%eax
  8022a5:	0f b6 12             	movzbl (%edx),%edx
  8022a8:	29 d0                	sub    %edx,%eax
}
  8022aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ad:	c9                   	leave  
  8022ae:	c3                   	ret    
		return 0;
  8022af:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b4:	eb f4                	jmp    8022aa <strncmp+0x2e>

008022b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022c0:	eb 03                	jmp    8022c5 <strchr+0xf>
  8022c2:	83 c0 01             	add    $0x1,%eax
  8022c5:	0f b6 10             	movzbl (%eax),%edx
  8022c8:	84 d2                	test   %dl,%dl
  8022ca:	74 06                	je     8022d2 <strchr+0x1c>
		if (*s == c)
  8022cc:	38 ca                	cmp    %cl,%dl
  8022ce:	75 f2                	jne    8022c2 <strchr+0xc>
  8022d0:	eb 05                	jmp    8022d7 <strchr+0x21>
			return (char *) s;
	return 0;
  8022d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022e6:	38 ca                	cmp    %cl,%dl
  8022e8:	74 09                	je     8022f3 <strfind+0x1a>
  8022ea:	84 d2                	test   %dl,%dl
  8022ec:	74 05                	je     8022f3 <strfind+0x1a>
	for (; *s; s++)
  8022ee:	83 c0 01             	add    $0x1,%eax
  8022f1:	eb f0                	jmp    8022e3 <strfind+0xa>
			break;
	return (char *) s;
}
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    

008022f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	57                   	push   %edi
  8022f9:	56                   	push   %esi
  8022fa:	53                   	push   %ebx
  8022fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802301:	85 c9                	test   %ecx,%ecx
  802303:	74 2f                	je     802334 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802305:	89 f8                	mov    %edi,%eax
  802307:	09 c8                	or     %ecx,%eax
  802309:	a8 03                	test   $0x3,%al
  80230b:	75 21                	jne    80232e <memset+0x39>
		c &= 0xFF;
  80230d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802311:	89 d0                	mov    %edx,%eax
  802313:	c1 e0 08             	shl    $0x8,%eax
  802316:	89 d3                	mov    %edx,%ebx
  802318:	c1 e3 18             	shl    $0x18,%ebx
  80231b:	89 d6                	mov    %edx,%esi
  80231d:	c1 e6 10             	shl    $0x10,%esi
  802320:	09 f3                	or     %esi,%ebx
  802322:	09 da                	or     %ebx,%edx
  802324:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802326:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  802329:	fc                   	cld    
  80232a:	f3 ab                	rep stos %eax,%es:(%edi)
  80232c:	eb 06                	jmp    802334 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	fc                   	cld    
  802332:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802334:	89 f8                	mov    %edi,%eax
  802336:	5b                   	pop    %ebx
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	57                   	push   %edi
  80233f:	56                   	push   %esi
  802340:	8b 45 08             	mov    0x8(%ebp),%eax
  802343:	8b 75 0c             	mov    0xc(%ebp),%esi
  802346:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802349:	39 c6                	cmp    %eax,%esi
  80234b:	73 32                	jae    80237f <memmove+0x44>
  80234d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802350:	39 c2                	cmp    %eax,%edx
  802352:	76 2b                	jbe    80237f <memmove+0x44>
		s += n;
		d += n;
  802354:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802357:	89 d6                	mov    %edx,%esi
  802359:	09 fe                	or     %edi,%esi
  80235b:	09 ce                	or     %ecx,%esi
  80235d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802363:	75 0e                	jne    802373 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802365:	83 ef 04             	sub    $0x4,%edi
  802368:	8d 72 fc             	lea    -0x4(%edx),%esi
  80236b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80236e:	fd                   	std    
  80236f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802371:	eb 09                	jmp    80237c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802373:	83 ef 01             	sub    $0x1,%edi
  802376:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  802379:	fd                   	std    
  80237a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80237c:	fc                   	cld    
  80237d:	eb 1a                	jmp    802399 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80237f:	89 f2                	mov    %esi,%edx
  802381:	09 c2                	or     %eax,%edx
  802383:	09 ca                	or     %ecx,%edx
  802385:	f6 c2 03             	test   $0x3,%dl
  802388:	75 0a                	jne    802394 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80238a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80238d:	89 c7                	mov    %eax,%edi
  80238f:	fc                   	cld    
  802390:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802392:	eb 05                	jmp    802399 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  802394:	89 c7                	mov    %eax,%edi
  802396:	fc                   	cld    
  802397:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    

0080239d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8023a3:	ff 75 10             	push   0x10(%ebp)
  8023a6:	ff 75 0c             	push   0xc(%ebp)
  8023a9:	ff 75 08             	push   0x8(%ebp)
  8023ac:	e8 8a ff ff ff       	call   80233b <memmove>
}
  8023b1:	c9                   	leave  
  8023b2:	c3                   	ret    

008023b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8023b3:	55                   	push   %ebp
  8023b4:	89 e5                	mov    %esp,%ebp
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023be:	89 c6                	mov    %eax,%esi
  8023c0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023c3:	eb 06                	jmp    8023cb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8023c5:	83 c0 01             	add    $0x1,%eax
  8023c8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8023cb:	39 f0                	cmp    %esi,%eax
  8023cd:	74 14                	je     8023e3 <memcmp+0x30>
		if (*s1 != *s2)
  8023cf:	0f b6 08             	movzbl (%eax),%ecx
  8023d2:	0f b6 1a             	movzbl (%edx),%ebx
  8023d5:	38 d9                	cmp    %bl,%cl
  8023d7:	74 ec                	je     8023c5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8023d9:	0f b6 c1             	movzbl %cl,%eax
  8023dc:	0f b6 db             	movzbl %bl,%ebx
  8023df:	29 d8                	sub    %ebx,%eax
  8023e1:	eb 05                	jmp    8023e8 <memcmp+0x35>
	}

	return 0;
  8023e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8023f5:	89 c2                	mov    %eax,%edx
  8023f7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8023fa:	eb 03                	jmp    8023ff <memfind+0x13>
  8023fc:	83 c0 01             	add    $0x1,%eax
  8023ff:	39 d0                	cmp    %edx,%eax
  802401:	73 04                	jae    802407 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  802403:	38 08                	cmp    %cl,(%eax)
  802405:	75 f5                	jne    8023fc <memfind+0x10>
			break;
	return (void *) s;
}
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    

00802409 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	57                   	push   %edi
  80240d:	56                   	push   %esi
  80240e:	53                   	push   %ebx
  80240f:	8b 55 08             	mov    0x8(%ebp),%edx
  802412:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802415:	eb 03                	jmp    80241a <strtol+0x11>
		s++;
  802417:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80241a:	0f b6 02             	movzbl (%edx),%eax
  80241d:	3c 20                	cmp    $0x20,%al
  80241f:	74 f6                	je     802417 <strtol+0xe>
  802421:	3c 09                	cmp    $0x9,%al
  802423:	74 f2                	je     802417 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  802425:	3c 2b                	cmp    $0x2b,%al
  802427:	74 2a                	je     802453 <strtol+0x4a>
	int neg = 0;
  802429:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80242e:	3c 2d                	cmp    $0x2d,%al
  802430:	74 2b                	je     80245d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802432:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802438:	75 0f                	jne    802449 <strtol+0x40>
  80243a:	80 3a 30             	cmpb   $0x30,(%edx)
  80243d:	74 28                	je     802467 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80243f:	85 db                	test   %ebx,%ebx
  802441:	b8 0a 00 00 00       	mov    $0xa,%eax
  802446:	0f 44 d8             	cmove  %eax,%ebx
  802449:	b9 00 00 00 00       	mov    $0x0,%ecx
  80244e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802451:	eb 46                	jmp    802499 <strtol+0x90>
		s++;
  802453:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  802456:	bf 00 00 00 00       	mov    $0x0,%edi
  80245b:	eb d5                	jmp    802432 <strtol+0x29>
		s++, neg = 1;
  80245d:	83 c2 01             	add    $0x1,%edx
  802460:	bf 01 00 00 00       	mov    $0x1,%edi
  802465:	eb cb                	jmp    802432 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802467:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80246b:	74 0e                	je     80247b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80246d:	85 db                	test   %ebx,%ebx
  80246f:	75 d8                	jne    802449 <strtol+0x40>
		s++, base = 8;
  802471:	83 c2 01             	add    $0x1,%edx
  802474:	bb 08 00 00 00       	mov    $0x8,%ebx
  802479:	eb ce                	jmp    802449 <strtol+0x40>
		s += 2, base = 16;
  80247b:	83 c2 02             	add    $0x2,%edx
  80247e:	bb 10 00 00 00       	mov    $0x10,%ebx
  802483:	eb c4                	jmp    802449 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  802485:	0f be c0             	movsbl %al,%eax
  802488:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80248b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80248e:	7d 3a                	jge    8024ca <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  802490:	83 c2 01             	add    $0x1,%edx
  802493:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  802497:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  802499:	0f b6 02             	movzbl (%edx),%eax
  80249c:	8d 70 d0             	lea    -0x30(%eax),%esi
  80249f:	89 f3                	mov    %esi,%ebx
  8024a1:	80 fb 09             	cmp    $0x9,%bl
  8024a4:	76 df                	jbe    802485 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8024a6:	8d 70 9f             	lea    -0x61(%eax),%esi
  8024a9:	89 f3                	mov    %esi,%ebx
  8024ab:	80 fb 19             	cmp    $0x19,%bl
  8024ae:	77 08                	ja     8024b8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8024b0:	0f be c0             	movsbl %al,%eax
  8024b3:	83 e8 57             	sub    $0x57,%eax
  8024b6:	eb d3                	jmp    80248b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8024b8:	8d 70 bf             	lea    -0x41(%eax),%esi
  8024bb:	89 f3                	mov    %esi,%ebx
  8024bd:	80 fb 19             	cmp    $0x19,%bl
  8024c0:	77 08                	ja     8024ca <strtol+0xc1>
			dig = *s - 'A' + 10;
  8024c2:	0f be c0             	movsbl %al,%eax
  8024c5:	83 e8 37             	sub    $0x37,%eax
  8024c8:	eb c1                	jmp    80248b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8024ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024ce:	74 05                	je     8024d5 <strtol+0xcc>
		*endptr = (char *) s;
  8024d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8024d5:	89 c8                	mov    %ecx,%eax
  8024d7:	f7 d8                	neg    %eax
  8024d9:	85 ff                	test   %edi,%edi
  8024db:	0f 45 c8             	cmovne %eax,%ecx
}
  8024de:	89 c8                	mov    %ecx,%eax
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    

008024e5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
  8024e8:	57                   	push   %edi
  8024e9:	56                   	push   %esi
  8024ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8024eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f6:	89 c3                	mov    %eax,%ebx
  8024f8:	89 c7                	mov    %eax,%edi
  8024fa:	89 c6                	mov    %eax,%esi
  8024fc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024fe:	5b                   	pop    %ebx
  8024ff:	5e                   	pop    %esi
  802500:	5f                   	pop    %edi
  802501:	5d                   	pop    %ebp
  802502:	c3                   	ret    

00802503 <sys_cgetc>:

int
sys_cgetc(void)
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	57                   	push   %edi
  802507:	56                   	push   %esi
  802508:	53                   	push   %ebx
	asm volatile("int %1\n"
  802509:	ba 00 00 00 00       	mov    $0x0,%edx
  80250e:	b8 01 00 00 00       	mov    $0x1,%eax
  802513:	89 d1                	mov    %edx,%ecx
  802515:	89 d3                	mov    %edx,%ebx
  802517:	89 d7                	mov    %edx,%edi
  802519:	89 d6                	mov    %edx,%esi
  80251b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    

00802522 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802522:	55                   	push   %ebp
  802523:	89 e5                	mov    %esp,%ebp
  802525:	57                   	push   %edi
  802526:	56                   	push   %esi
  802527:	53                   	push   %ebx
  802528:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80252b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802530:	8b 55 08             	mov    0x8(%ebp),%edx
  802533:	b8 03 00 00 00       	mov    $0x3,%eax
  802538:	89 cb                	mov    %ecx,%ebx
  80253a:	89 cf                	mov    %ecx,%edi
  80253c:	89 ce                	mov    %ecx,%esi
  80253e:	cd 30                	int    $0x30
	if(check && ret > 0)
  802540:	85 c0                	test   %eax,%eax
  802542:	7f 08                	jg     80254c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802544:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802547:	5b                   	pop    %ebx
  802548:	5e                   	pop    %esi
  802549:	5f                   	pop    %edi
  80254a:	5d                   	pop    %ebp
  80254b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80254c:	83 ec 0c             	sub    $0xc,%esp
  80254f:	50                   	push   %eax
  802550:	6a 03                	push   $0x3
  802552:	68 ff 45 80 00       	push   $0x8045ff
  802557:	6a 2a                	push   $0x2a
  802559:	68 1c 46 80 00       	push   $0x80461c
  80255e:	e8 8d f5 ff ff       	call   801af0 <_panic>

00802563 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802563:	55                   	push   %ebp
  802564:	89 e5                	mov    %esp,%ebp
  802566:	57                   	push   %edi
  802567:	56                   	push   %esi
  802568:	53                   	push   %ebx
	asm volatile("int %1\n"
  802569:	ba 00 00 00 00       	mov    $0x0,%edx
  80256e:	b8 02 00 00 00       	mov    $0x2,%eax
  802573:	89 d1                	mov    %edx,%ecx
  802575:	89 d3                	mov    %edx,%ebx
  802577:	89 d7                	mov    %edx,%edi
  802579:	89 d6                	mov    %edx,%esi
  80257b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    

00802582 <sys_yield>:

void
sys_yield(void)
{
  802582:	55                   	push   %ebp
  802583:	89 e5                	mov    %esp,%ebp
  802585:	57                   	push   %edi
  802586:	56                   	push   %esi
  802587:	53                   	push   %ebx
	asm volatile("int %1\n"
  802588:	ba 00 00 00 00       	mov    $0x0,%edx
  80258d:	b8 0b 00 00 00       	mov    $0xb,%eax
  802592:	89 d1                	mov    %edx,%ecx
  802594:	89 d3                	mov    %edx,%ebx
  802596:	89 d7                	mov    %edx,%edi
  802598:	89 d6                	mov    %edx,%esi
  80259a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5f                   	pop    %edi
  80259f:	5d                   	pop    %ebp
  8025a0:	c3                   	ret    

008025a1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8025a1:	55                   	push   %ebp
  8025a2:	89 e5                	mov    %esp,%ebp
  8025a4:	57                   	push   %edi
  8025a5:	56                   	push   %esi
  8025a6:	53                   	push   %ebx
  8025a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025aa:	be 00 00 00 00       	mov    $0x0,%esi
  8025af:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8025ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025bd:	89 f7                	mov    %esi,%edi
  8025bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8025c1:	85 c0                	test   %eax,%eax
  8025c3:	7f 08                	jg     8025cd <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8025cd:	83 ec 0c             	sub    $0xc,%esp
  8025d0:	50                   	push   %eax
  8025d1:	6a 04                	push   $0x4
  8025d3:	68 ff 45 80 00       	push   $0x8045ff
  8025d8:	6a 2a                	push   $0x2a
  8025da:	68 1c 46 80 00       	push   $0x80461c
  8025df:	e8 0c f5 ff ff       	call   801af0 <_panic>

008025e4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	57                   	push   %edi
  8025e8:	56                   	push   %esi
  8025e9:	53                   	push   %ebx
  8025ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8025f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8025f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025fe:	8b 75 18             	mov    0x18(%ebp),%esi
  802601:	cd 30                	int    $0x30
	if(check && ret > 0)
  802603:	85 c0                	test   %eax,%eax
  802605:	7f 08                	jg     80260f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802607:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260a:	5b                   	pop    %ebx
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80260f:	83 ec 0c             	sub    $0xc,%esp
  802612:	50                   	push   %eax
  802613:	6a 05                	push   $0x5
  802615:	68 ff 45 80 00       	push   $0x8045ff
  80261a:	6a 2a                	push   $0x2a
  80261c:	68 1c 46 80 00       	push   $0x80461c
  802621:	e8 ca f4 ff ff       	call   801af0 <_panic>

00802626 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802626:	55                   	push   %ebp
  802627:	89 e5                	mov    %esp,%ebp
  802629:	57                   	push   %edi
  80262a:	56                   	push   %esi
  80262b:	53                   	push   %ebx
  80262c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80262f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802634:	8b 55 08             	mov    0x8(%ebp),%edx
  802637:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80263a:	b8 06 00 00 00       	mov    $0x6,%eax
  80263f:	89 df                	mov    %ebx,%edi
  802641:	89 de                	mov    %ebx,%esi
  802643:	cd 30                	int    $0x30
	if(check && ret > 0)
  802645:	85 c0                	test   %eax,%eax
  802647:	7f 08                	jg     802651 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264c:	5b                   	pop    %ebx
  80264d:	5e                   	pop    %esi
  80264e:	5f                   	pop    %edi
  80264f:	5d                   	pop    %ebp
  802650:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802651:	83 ec 0c             	sub    $0xc,%esp
  802654:	50                   	push   %eax
  802655:	6a 06                	push   $0x6
  802657:	68 ff 45 80 00       	push   $0x8045ff
  80265c:	6a 2a                	push   $0x2a
  80265e:	68 1c 46 80 00       	push   $0x80461c
  802663:	e8 88 f4 ff ff       	call   801af0 <_panic>

00802668 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802668:	55                   	push   %ebp
  802669:	89 e5                	mov    %esp,%ebp
  80266b:	57                   	push   %edi
  80266c:	56                   	push   %esi
  80266d:	53                   	push   %ebx
  80266e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802671:	bb 00 00 00 00       	mov    $0x0,%ebx
  802676:	8b 55 08             	mov    0x8(%ebp),%edx
  802679:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80267c:	b8 08 00 00 00       	mov    $0x8,%eax
  802681:	89 df                	mov    %ebx,%edi
  802683:	89 de                	mov    %ebx,%esi
  802685:	cd 30                	int    $0x30
	if(check && ret > 0)
  802687:	85 c0                	test   %eax,%eax
  802689:	7f 08                	jg     802693 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80268b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268e:	5b                   	pop    %ebx
  80268f:	5e                   	pop    %esi
  802690:	5f                   	pop    %edi
  802691:	5d                   	pop    %ebp
  802692:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802693:	83 ec 0c             	sub    $0xc,%esp
  802696:	50                   	push   %eax
  802697:	6a 08                	push   $0x8
  802699:	68 ff 45 80 00       	push   $0x8045ff
  80269e:	6a 2a                	push   $0x2a
  8026a0:	68 1c 46 80 00       	push   $0x80461c
  8026a5:	e8 46 f4 ff ff       	call   801af0 <_panic>

008026aa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	57                   	push   %edi
  8026ae:	56                   	push   %esi
  8026af:	53                   	push   %ebx
  8026b0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8026bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026be:	b8 09 00 00 00       	mov    $0x9,%eax
  8026c3:	89 df                	mov    %ebx,%edi
  8026c5:	89 de                	mov    %ebx,%esi
  8026c7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026c9:	85 c0                	test   %eax,%eax
  8026cb:	7f 08                	jg     8026d5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026d0:	5b                   	pop    %ebx
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8026d5:	83 ec 0c             	sub    $0xc,%esp
  8026d8:	50                   	push   %eax
  8026d9:	6a 09                	push   $0x9
  8026db:	68 ff 45 80 00       	push   $0x8045ff
  8026e0:	6a 2a                	push   $0x2a
  8026e2:	68 1c 46 80 00       	push   $0x80461c
  8026e7:	e8 04 f4 ff ff       	call   801af0 <_panic>

008026ec <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
  8026ef:	57                   	push   %edi
  8026f0:	56                   	push   %esi
  8026f1:	53                   	push   %ebx
  8026f2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8026fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802700:	b8 0a 00 00 00       	mov    $0xa,%eax
  802705:	89 df                	mov    %ebx,%edi
  802707:	89 de                	mov    %ebx,%esi
  802709:	cd 30                	int    $0x30
	if(check && ret > 0)
  80270b:	85 c0                	test   %eax,%eax
  80270d:	7f 08                	jg     802717 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80270f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802712:	5b                   	pop    %ebx
  802713:	5e                   	pop    %esi
  802714:	5f                   	pop    %edi
  802715:	5d                   	pop    %ebp
  802716:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802717:	83 ec 0c             	sub    $0xc,%esp
  80271a:	50                   	push   %eax
  80271b:	6a 0a                	push   $0xa
  80271d:	68 ff 45 80 00       	push   $0x8045ff
  802722:	6a 2a                	push   $0x2a
  802724:	68 1c 46 80 00       	push   $0x80461c
  802729:	e8 c2 f3 ff ff       	call   801af0 <_panic>

0080272e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80272e:	55                   	push   %ebp
  80272f:	89 e5                	mov    %esp,%ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
	asm volatile("int %1\n"
  802734:	8b 55 08             	mov    0x8(%ebp),%edx
  802737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80273a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80273f:	be 00 00 00 00       	mov    $0x0,%esi
  802744:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802747:	8b 7d 14             	mov    0x14(%ebp),%edi
  80274a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80274c:	5b                   	pop    %ebx
  80274d:	5e                   	pop    %esi
  80274e:	5f                   	pop    %edi
  80274f:	5d                   	pop    %ebp
  802750:	c3                   	ret    

00802751 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802751:	55                   	push   %ebp
  802752:	89 e5                	mov    %esp,%ebp
  802754:	57                   	push   %edi
  802755:	56                   	push   %esi
  802756:	53                   	push   %ebx
  802757:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80275a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80275f:	8b 55 08             	mov    0x8(%ebp),%edx
  802762:	b8 0d 00 00 00       	mov    $0xd,%eax
  802767:	89 cb                	mov    %ecx,%ebx
  802769:	89 cf                	mov    %ecx,%edi
  80276b:	89 ce                	mov    %ecx,%esi
  80276d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80276f:	85 c0                	test   %eax,%eax
  802771:	7f 08                	jg     80277b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802773:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802776:	5b                   	pop    %ebx
  802777:	5e                   	pop    %esi
  802778:	5f                   	pop    %edi
  802779:	5d                   	pop    %ebp
  80277a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80277b:	83 ec 0c             	sub    $0xc,%esp
  80277e:	50                   	push   %eax
  80277f:	6a 0d                	push   $0xd
  802781:	68 ff 45 80 00       	push   $0x8045ff
  802786:	6a 2a                	push   $0x2a
  802788:	68 1c 46 80 00       	push   $0x80461c
  80278d:	e8 5e f3 ff ff       	call   801af0 <_panic>

00802792 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  802792:	55                   	push   %ebp
  802793:	89 e5                	mov    %esp,%ebp
  802795:	57                   	push   %edi
  802796:	56                   	push   %esi
  802797:	53                   	push   %ebx
	asm volatile("int %1\n"
  802798:	ba 00 00 00 00       	mov    $0x0,%edx
  80279d:	b8 0e 00 00 00       	mov    $0xe,%eax
  8027a2:	89 d1                	mov    %edx,%ecx
  8027a4:	89 d3                	mov    %edx,%ebx
  8027a6:	89 d7                	mov    %edx,%edi
  8027a8:	89 d6                	mov    %edx,%esi
  8027aa:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8027ac:	5b                   	pop    %ebx
  8027ad:	5e                   	pop    %esi
  8027ae:	5f                   	pop    %edi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    

008027b1 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8027b1:	55                   	push   %ebp
  8027b2:	89 e5                	mov    %esp,%ebp
  8027b4:	57                   	push   %edi
  8027b5:	56                   	push   %esi
  8027b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8027bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027c2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8027c7:	89 df                	mov    %ebx,%edi
  8027c9:	89 de                	mov    %ebx,%esi
  8027cb:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8027cd:	5b                   	pop    %ebx
  8027ce:	5e                   	pop    %esi
  8027cf:	5f                   	pop    %edi
  8027d0:	5d                   	pop    %ebp
  8027d1:	c3                   	ret    

008027d2 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8027d2:	55                   	push   %ebp
  8027d3:	89 e5                	mov    %esp,%ebp
  8027d5:	57                   	push   %edi
  8027d6:	56                   	push   %esi
  8027d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8027e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8027e8:	89 df                	mov    %ebx,%edi
  8027ea:	89 de                	mov    %ebx,%esi
  8027ec:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8027ee:	5b                   	pop    %ebx
  8027ef:	5e                   	pop    %esi
  8027f0:	5f                   	pop    %edi
  8027f1:	5d                   	pop    %ebp
  8027f2:	c3                   	ret    

008027f3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027f3:	55                   	push   %ebp
  8027f4:	89 e5                	mov    %esp,%ebp
  8027f6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8027f9:	83 3d 0c a0 80 00 00 	cmpl   $0x0,0x80a00c
  802800:	74 0a                	je     80280c <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802802:	8b 45 08             	mov    0x8(%ebp),%eax
  802805:	a3 0c a0 80 00       	mov    %eax,0x80a00c
}
  80280a:	c9                   	leave  
  80280b:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80280c:	e8 52 fd ff ff       	call   802563 <sys_getenvid>
  802811:	83 ec 04             	sub    $0x4,%esp
  802814:	68 07 0e 00 00       	push   $0xe07
  802819:	68 00 f0 bf ee       	push   $0xeebff000
  80281e:	50                   	push   %eax
  80281f:	e8 7d fd ff ff       	call   8025a1 <sys_page_alloc>
		if (r < 0) {
  802824:	83 c4 10             	add    $0x10,%esp
  802827:	85 c0                	test   %eax,%eax
  802829:	78 2c                	js     802857 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80282b:	e8 33 fd ff ff       	call   802563 <sys_getenvid>
  802830:	83 ec 08             	sub    $0x8,%esp
  802833:	68 69 28 80 00       	push   $0x802869
  802838:	50                   	push   %eax
  802839:	e8 ae fe ff ff       	call   8026ec <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80283e:	83 c4 10             	add    $0x10,%esp
  802841:	85 c0                	test   %eax,%eax
  802843:	79 bd                	jns    802802 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802845:	50                   	push   %eax
  802846:	68 6c 46 80 00       	push   $0x80466c
  80284b:	6a 28                	push   $0x28
  80284d:	68 a2 46 80 00       	push   $0x8046a2
  802852:	e8 99 f2 ff ff       	call   801af0 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802857:	50                   	push   %eax
  802858:	68 2c 46 80 00       	push   $0x80462c
  80285d:	6a 23                	push   $0x23
  80285f:	68 a2 46 80 00       	push   $0x8046a2
  802864:	e8 87 f2 ff ff       	call   801af0 <_panic>

00802869 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802869:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80286a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	call *%eax
  80286f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802871:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802874:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802878:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80287b:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80287f:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802883:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802885:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802888:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802889:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80288c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80288d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80288e:	c3                   	ret    

0080288f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80288f:	55                   	push   %ebp
  802890:	89 e5                	mov    %esp,%ebp
  802892:	56                   	push   %esi
  802893:	53                   	push   %ebx
  802894:	8b 75 08             	mov    0x8(%ebp),%esi
  802897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80289a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80289d:	85 c0                	test   %eax,%eax
  80289f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028a4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8028a7:	83 ec 0c             	sub    $0xc,%esp
  8028aa:	50                   	push   %eax
  8028ab:	e8 a1 fe ff ff       	call   802751 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8028b0:	83 c4 10             	add    $0x10,%esp
  8028b3:	85 f6                	test   %esi,%esi
  8028b5:	74 17                	je     8028ce <ipc_recv+0x3f>
  8028b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8028bc:	85 c0                	test   %eax,%eax
  8028be:	78 0c                	js     8028cc <ipc_recv+0x3d>
  8028c0:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8028c6:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8028cc:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8028ce:	85 db                	test   %ebx,%ebx
  8028d0:	74 17                	je     8028e9 <ipc_recv+0x5a>
  8028d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8028d7:	85 c0                	test   %eax,%eax
  8028d9:	78 0c                	js     8028e7 <ipc_recv+0x58>
  8028db:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8028e1:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8028e7:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8028e9:	85 c0                	test   %eax,%eax
  8028eb:	78 0b                	js     8028f8 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8028ed:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8028f2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8028f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028fb:	5b                   	pop    %ebx
  8028fc:	5e                   	pop    %esi
  8028fd:	5d                   	pop    %ebp
  8028fe:	c3                   	ret    

008028ff <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028ff:	55                   	push   %ebp
  802900:	89 e5                	mov    %esp,%ebp
  802902:	57                   	push   %edi
  802903:	56                   	push   %esi
  802904:	53                   	push   %ebx
  802905:	83 ec 0c             	sub    $0xc,%esp
  802908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80290b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80290e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802911:	85 db                	test   %ebx,%ebx
  802913:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802918:	0f 44 d8             	cmove  %eax,%ebx
  80291b:	eb 05                	jmp    802922 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80291d:	e8 60 fc ff ff       	call   802582 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802922:	ff 75 14             	push   0x14(%ebp)
  802925:	53                   	push   %ebx
  802926:	56                   	push   %esi
  802927:	57                   	push   %edi
  802928:	e8 01 fe ff ff       	call   80272e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80292d:	83 c4 10             	add    $0x10,%esp
  802930:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802933:	74 e8                	je     80291d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802935:	85 c0                	test   %eax,%eax
  802937:	78 08                	js     802941 <ipc_send+0x42>
	}while (r<0);

}
  802939:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80293c:	5b                   	pop    %ebx
  80293d:	5e                   	pop    %esi
  80293e:	5f                   	pop    %edi
  80293f:	5d                   	pop    %ebp
  802940:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802941:	50                   	push   %eax
  802942:	68 b0 46 80 00       	push   $0x8046b0
  802947:	6a 3d                	push   $0x3d
  802949:	68 c4 46 80 00       	push   $0x8046c4
  80294e:	e8 9d f1 ff ff       	call   801af0 <_panic>

00802953 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802953:	55                   	push   %ebp
  802954:	89 e5                	mov    %esp,%ebp
  802956:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802959:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80295e:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802964:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80296a:	8b 52 60             	mov    0x60(%edx),%edx
  80296d:	39 ca                	cmp    %ecx,%edx
  80296f:	74 11                	je     802982 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802971:	83 c0 01             	add    $0x1,%eax
  802974:	3d 00 04 00 00       	cmp    $0x400,%eax
  802979:	75 e3                	jne    80295e <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80297b:	b8 00 00 00 00       	mov    $0x0,%eax
  802980:	eb 0e                	jmp    802990 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802982:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802988:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80298d:	8b 40 58             	mov    0x58(%eax),%eax
}
  802990:	5d                   	pop    %ebp
  802991:	c3                   	ret    

00802992 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802992:	55                   	push   %ebp
  802993:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802995:	8b 45 08             	mov    0x8(%ebp),%eax
  802998:	05 00 00 00 30       	add    $0x30000000,%eax
  80299d:	c1 e8 0c             	shr    $0xc,%eax
}
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    

008029a2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8029a2:	55                   	push   %ebp
  8029a3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8029a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8029ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8029b2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8029b7:	5d                   	pop    %ebp
  8029b8:	c3                   	ret    

008029b9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8029b9:	55                   	push   %ebp
  8029ba:	89 e5                	mov    %esp,%ebp
  8029bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8029c1:	89 c2                	mov    %eax,%edx
  8029c3:	c1 ea 16             	shr    $0x16,%edx
  8029c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029cd:	f6 c2 01             	test   $0x1,%dl
  8029d0:	74 29                	je     8029fb <fd_alloc+0x42>
  8029d2:	89 c2                	mov    %eax,%edx
  8029d4:	c1 ea 0c             	shr    $0xc,%edx
  8029d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029de:	f6 c2 01             	test   $0x1,%dl
  8029e1:	74 18                	je     8029fb <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8029e3:	05 00 10 00 00       	add    $0x1000,%eax
  8029e8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8029ed:	75 d2                	jne    8029c1 <fd_alloc+0x8>
  8029ef:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8029f4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8029f9:	eb 05                	jmp    802a00 <fd_alloc+0x47>
			return 0;
  8029fb:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  802a00:	8b 55 08             	mov    0x8(%ebp),%edx
  802a03:	89 02                	mov    %eax,(%edx)
}
  802a05:	89 c8                	mov    %ecx,%eax
  802a07:	5d                   	pop    %ebp
  802a08:	c3                   	ret    

00802a09 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802a09:	55                   	push   %ebp
  802a0a:	89 e5                	mov    %esp,%ebp
  802a0c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802a0f:	83 f8 1f             	cmp    $0x1f,%eax
  802a12:	77 30                	ja     802a44 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802a14:	c1 e0 0c             	shl    $0xc,%eax
  802a17:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802a1c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  802a22:	f6 c2 01             	test   $0x1,%dl
  802a25:	74 24                	je     802a4b <fd_lookup+0x42>
  802a27:	89 c2                	mov    %eax,%edx
  802a29:	c1 ea 0c             	shr    $0xc,%edx
  802a2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a33:	f6 c2 01             	test   $0x1,%dl
  802a36:	74 1a                	je     802a52 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a3b:	89 02                	mov    %eax,(%edx)
	return 0;
  802a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a42:	5d                   	pop    %ebp
  802a43:	c3                   	ret    
		return -E_INVAL;
  802a44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a49:	eb f7                	jmp    802a42 <fd_lookup+0x39>
		return -E_INVAL;
  802a4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a50:	eb f0                	jmp    802a42 <fd_lookup+0x39>
  802a52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a57:	eb e9                	jmp    802a42 <fd_lookup+0x39>

00802a59 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802a59:	55                   	push   %ebp
  802a5a:	89 e5                	mov    %esp,%ebp
  802a5c:	53                   	push   %ebx
  802a5d:	83 ec 04             	sub    $0x4,%esp
  802a60:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802a63:	b8 00 00 00 00       	mov    $0x0,%eax
  802a68:	bb 64 90 80 00       	mov    $0x809064,%ebx
		if (devtab[i]->dev_id == dev_id) {
  802a6d:	39 13                	cmp    %edx,(%ebx)
  802a6f:	74 37                	je     802aa8 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  802a71:	83 c0 01             	add    $0x1,%eax
  802a74:	8b 1c 85 4c 47 80 00 	mov    0x80474c(,%eax,4),%ebx
  802a7b:	85 db                	test   %ebx,%ebx
  802a7d:	75 ee                	jne    802a6d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a7f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802a84:	8b 40 58             	mov    0x58(%eax),%eax
  802a87:	83 ec 04             	sub    $0x4,%esp
  802a8a:	52                   	push   %edx
  802a8b:	50                   	push   %eax
  802a8c:	68 d0 46 80 00       	push   $0x8046d0
  802a91:	e8 35 f1 ff ff       	call   801bcb <cprintf>
	*dev = 0;
	return -E_INVAL;
  802a96:	83 c4 10             	add    $0x10,%esp
  802a99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  802a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802aa1:	89 1a                	mov    %ebx,(%edx)
}
  802aa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802aa6:	c9                   	leave  
  802aa7:	c3                   	ret    
			return 0;
  802aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  802aad:	eb ef                	jmp    802a9e <dev_lookup+0x45>

00802aaf <fd_close>:
{
  802aaf:	55                   	push   %ebp
  802ab0:	89 e5                	mov    %esp,%ebp
  802ab2:	57                   	push   %edi
  802ab3:	56                   	push   %esi
  802ab4:	53                   	push   %ebx
  802ab5:	83 ec 24             	sub    $0x24,%esp
  802ab8:	8b 75 08             	mov    0x8(%ebp),%esi
  802abb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802abe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ac1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802ac2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802ac8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802acb:	50                   	push   %eax
  802acc:	e8 38 ff ff ff       	call   802a09 <fd_lookup>
  802ad1:	89 c3                	mov    %eax,%ebx
  802ad3:	83 c4 10             	add    $0x10,%esp
  802ad6:	85 c0                	test   %eax,%eax
  802ad8:	78 05                	js     802adf <fd_close+0x30>
	    || fd != fd2)
  802ada:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802add:	74 16                	je     802af5 <fd_close+0x46>
		return (must_exist ? r : 0);
  802adf:	89 f8                	mov    %edi,%eax
  802ae1:	84 c0                	test   %al,%al
  802ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ae8:	0f 44 d8             	cmove  %eax,%ebx
}
  802aeb:	89 d8                	mov    %ebx,%eax
  802aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802af0:	5b                   	pop    %ebx
  802af1:	5e                   	pop    %esi
  802af2:	5f                   	pop    %edi
  802af3:	5d                   	pop    %ebp
  802af4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802af5:	83 ec 08             	sub    $0x8,%esp
  802af8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802afb:	50                   	push   %eax
  802afc:	ff 36                	push   (%esi)
  802afe:	e8 56 ff ff ff       	call   802a59 <dev_lookup>
  802b03:	89 c3                	mov    %eax,%ebx
  802b05:	83 c4 10             	add    $0x10,%esp
  802b08:	85 c0                	test   %eax,%eax
  802b0a:	78 1a                	js     802b26 <fd_close+0x77>
		if (dev->dev_close)
  802b0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b0f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802b12:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802b17:	85 c0                	test   %eax,%eax
  802b19:	74 0b                	je     802b26 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  802b1b:	83 ec 0c             	sub    $0xc,%esp
  802b1e:	56                   	push   %esi
  802b1f:	ff d0                	call   *%eax
  802b21:	89 c3                	mov    %eax,%ebx
  802b23:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802b26:	83 ec 08             	sub    $0x8,%esp
  802b29:	56                   	push   %esi
  802b2a:	6a 00                	push   $0x0
  802b2c:	e8 f5 fa ff ff       	call   802626 <sys_page_unmap>
	return r;
  802b31:	83 c4 10             	add    $0x10,%esp
  802b34:	eb b5                	jmp    802aeb <fd_close+0x3c>

00802b36 <close>:

int
close(int fdnum)
{
  802b36:	55                   	push   %ebp
  802b37:	89 e5                	mov    %esp,%ebp
  802b39:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b3f:	50                   	push   %eax
  802b40:	ff 75 08             	push   0x8(%ebp)
  802b43:	e8 c1 fe ff ff       	call   802a09 <fd_lookup>
  802b48:	83 c4 10             	add    $0x10,%esp
  802b4b:	85 c0                	test   %eax,%eax
  802b4d:	79 02                	jns    802b51 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  802b4f:	c9                   	leave  
  802b50:	c3                   	ret    
		return fd_close(fd, 1);
  802b51:	83 ec 08             	sub    $0x8,%esp
  802b54:	6a 01                	push   $0x1
  802b56:	ff 75 f4             	push   -0xc(%ebp)
  802b59:	e8 51 ff ff ff       	call   802aaf <fd_close>
  802b5e:	83 c4 10             	add    $0x10,%esp
  802b61:	eb ec                	jmp    802b4f <close+0x19>

00802b63 <close_all>:

void
close_all(void)
{
  802b63:	55                   	push   %ebp
  802b64:	89 e5                	mov    %esp,%ebp
  802b66:	53                   	push   %ebx
  802b67:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802b6a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802b6f:	83 ec 0c             	sub    $0xc,%esp
  802b72:	53                   	push   %ebx
  802b73:	e8 be ff ff ff       	call   802b36 <close>
	for (i = 0; i < MAXFD; i++)
  802b78:	83 c3 01             	add    $0x1,%ebx
  802b7b:	83 c4 10             	add    $0x10,%esp
  802b7e:	83 fb 20             	cmp    $0x20,%ebx
  802b81:	75 ec                	jne    802b6f <close_all+0xc>
}
  802b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b86:	c9                   	leave  
  802b87:	c3                   	ret    

00802b88 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b88:	55                   	push   %ebp
  802b89:	89 e5                	mov    %esp,%ebp
  802b8b:	57                   	push   %edi
  802b8c:	56                   	push   %esi
  802b8d:	53                   	push   %ebx
  802b8e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b94:	50                   	push   %eax
  802b95:	ff 75 08             	push   0x8(%ebp)
  802b98:	e8 6c fe ff ff       	call   802a09 <fd_lookup>
  802b9d:	89 c3                	mov    %eax,%ebx
  802b9f:	83 c4 10             	add    $0x10,%esp
  802ba2:	85 c0                	test   %eax,%eax
  802ba4:	78 7f                	js     802c25 <dup+0x9d>
		return r;
	close(newfdnum);
  802ba6:	83 ec 0c             	sub    $0xc,%esp
  802ba9:	ff 75 0c             	push   0xc(%ebp)
  802bac:	e8 85 ff ff ff       	call   802b36 <close>

	newfd = INDEX2FD(newfdnum);
  802bb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802bb4:	c1 e6 0c             	shl    $0xc,%esi
  802bb7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802bbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802bc0:	89 3c 24             	mov    %edi,(%esp)
  802bc3:	e8 da fd ff ff       	call   8029a2 <fd2data>
  802bc8:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802bca:	89 34 24             	mov    %esi,(%esp)
  802bcd:	e8 d0 fd ff ff       	call   8029a2 <fd2data>
  802bd2:	83 c4 10             	add    $0x10,%esp
  802bd5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802bd8:	89 d8                	mov    %ebx,%eax
  802bda:	c1 e8 16             	shr    $0x16,%eax
  802bdd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802be4:	a8 01                	test   $0x1,%al
  802be6:	74 11                	je     802bf9 <dup+0x71>
  802be8:	89 d8                	mov    %ebx,%eax
  802bea:	c1 e8 0c             	shr    $0xc,%eax
  802bed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802bf4:	f6 c2 01             	test   $0x1,%dl
  802bf7:	75 36                	jne    802c2f <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bf9:	89 f8                	mov    %edi,%eax
  802bfb:	c1 e8 0c             	shr    $0xc,%eax
  802bfe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c05:	83 ec 0c             	sub    $0xc,%esp
  802c08:	25 07 0e 00 00       	and    $0xe07,%eax
  802c0d:	50                   	push   %eax
  802c0e:	56                   	push   %esi
  802c0f:	6a 00                	push   $0x0
  802c11:	57                   	push   %edi
  802c12:	6a 00                	push   $0x0
  802c14:	e8 cb f9 ff ff       	call   8025e4 <sys_page_map>
  802c19:	89 c3                	mov    %eax,%ebx
  802c1b:	83 c4 20             	add    $0x20,%esp
  802c1e:	85 c0                	test   %eax,%eax
  802c20:	78 33                	js     802c55 <dup+0xcd>
		goto err;

	return newfdnum;
  802c22:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802c25:	89 d8                	mov    %ebx,%eax
  802c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c2a:	5b                   	pop    %ebx
  802c2b:	5e                   	pop    %esi
  802c2c:	5f                   	pop    %edi
  802c2d:	5d                   	pop    %ebp
  802c2e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802c2f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c36:	83 ec 0c             	sub    $0xc,%esp
  802c39:	25 07 0e 00 00       	and    $0xe07,%eax
  802c3e:	50                   	push   %eax
  802c3f:	ff 75 d4             	push   -0x2c(%ebp)
  802c42:	6a 00                	push   $0x0
  802c44:	53                   	push   %ebx
  802c45:	6a 00                	push   $0x0
  802c47:	e8 98 f9 ff ff       	call   8025e4 <sys_page_map>
  802c4c:	89 c3                	mov    %eax,%ebx
  802c4e:	83 c4 20             	add    $0x20,%esp
  802c51:	85 c0                	test   %eax,%eax
  802c53:	79 a4                	jns    802bf9 <dup+0x71>
	sys_page_unmap(0, newfd);
  802c55:	83 ec 08             	sub    $0x8,%esp
  802c58:	56                   	push   %esi
  802c59:	6a 00                	push   $0x0
  802c5b:	e8 c6 f9 ff ff       	call   802626 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802c60:	83 c4 08             	add    $0x8,%esp
  802c63:	ff 75 d4             	push   -0x2c(%ebp)
  802c66:	6a 00                	push   $0x0
  802c68:	e8 b9 f9 ff ff       	call   802626 <sys_page_unmap>
	return r;
  802c6d:	83 c4 10             	add    $0x10,%esp
  802c70:	eb b3                	jmp    802c25 <dup+0x9d>

00802c72 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802c72:	55                   	push   %ebp
  802c73:	89 e5                	mov    %esp,%ebp
  802c75:	56                   	push   %esi
  802c76:	53                   	push   %ebx
  802c77:	83 ec 18             	sub    $0x18,%esp
  802c7a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c80:	50                   	push   %eax
  802c81:	56                   	push   %esi
  802c82:	e8 82 fd ff ff       	call   802a09 <fd_lookup>
  802c87:	83 c4 10             	add    $0x10,%esp
  802c8a:	85 c0                	test   %eax,%eax
  802c8c:	78 3c                	js     802cca <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c8e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  802c91:	83 ec 08             	sub    $0x8,%esp
  802c94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c97:	50                   	push   %eax
  802c98:	ff 33                	push   (%ebx)
  802c9a:	e8 ba fd ff ff       	call   802a59 <dev_lookup>
  802c9f:	83 c4 10             	add    $0x10,%esp
  802ca2:	85 c0                	test   %eax,%eax
  802ca4:	78 24                	js     802cca <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802ca6:	8b 43 08             	mov    0x8(%ebx),%eax
  802ca9:	83 e0 03             	and    $0x3,%eax
  802cac:	83 f8 01             	cmp    $0x1,%eax
  802caf:	74 20                	je     802cd1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cb4:	8b 40 08             	mov    0x8(%eax),%eax
  802cb7:	85 c0                	test   %eax,%eax
  802cb9:	74 37                	je     802cf2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802cbb:	83 ec 04             	sub    $0x4,%esp
  802cbe:	ff 75 10             	push   0x10(%ebp)
  802cc1:	ff 75 0c             	push   0xc(%ebp)
  802cc4:	53                   	push   %ebx
  802cc5:	ff d0                	call   *%eax
  802cc7:	83 c4 10             	add    $0x10,%esp
}
  802cca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ccd:	5b                   	pop    %ebx
  802cce:	5e                   	pop    %esi
  802ccf:	5d                   	pop    %ebp
  802cd0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802cd1:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802cd6:	8b 40 58             	mov    0x58(%eax),%eax
  802cd9:	83 ec 04             	sub    $0x4,%esp
  802cdc:	56                   	push   %esi
  802cdd:	50                   	push   %eax
  802cde:	68 11 47 80 00       	push   $0x804711
  802ce3:	e8 e3 ee ff ff       	call   801bcb <cprintf>
		return -E_INVAL;
  802ce8:	83 c4 10             	add    $0x10,%esp
  802ceb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802cf0:	eb d8                	jmp    802cca <read+0x58>
		return -E_NOT_SUPP;
  802cf2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802cf7:	eb d1                	jmp    802cca <read+0x58>

00802cf9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802cf9:	55                   	push   %ebp
  802cfa:	89 e5                	mov    %esp,%ebp
  802cfc:	57                   	push   %edi
  802cfd:	56                   	push   %esi
  802cfe:	53                   	push   %ebx
  802cff:	83 ec 0c             	sub    $0xc,%esp
  802d02:	8b 7d 08             	mov    0x8(%ebp),%edi
  802d05:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d0d:	eb 02                	jmp    802d11 <readn+0x18>
  802d0f:	01 c3                	add    %eax,%ebx
  802d11:	39 f3                	cmp    %esi,%ebx
  802d13:	73 21                	jae    802d36 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d15:	83 ec 04             	sub    $0x4,%esp
  802d18:	89 f0                	mov    %esi,%eax
  802d1a:	29 d8                	sub    %ebx,%eax
  802d1c:	50                   	push   %eax
  802d1d:	89 d8                	mov    %ebx,%eax
  802d1f:	03 45 0c             	add    0xc(%ebp),%eax
  802d22:	50                   	push   %eax
  802d23:	57                   	push   %edi
  802d24:	e8 49 ff ff ff       	call   802c72 <read>
		if (m < 0)
  802d29:	83 c4 10             	add    $0x10,%esp
  802d2c:	85 c0                	test   %eax,%eax
  802d2e:	78 04                	js     802d34 <readn+0x3b>
			return m;
		if (m == 0)
  802d30:	75 dd                	jne    802d0f <readn+0x16>
  802d32:	eb 02                	jmp    802d36 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d34:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802d36:	89 d8                	mov    %ebx,%eax
  802d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d3b:	5b                   	pop    %ebx
  802d3c:	5e                   	pop    %esi
  802d3d:	5f                   	pop    %edi
  802d3e:	5d                   	pop    %ebp
  802d3f:	c3                   	ret    

00802d40 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802d40:	55                   	push   %ebp
  802d41:	89 e5                	mov    %esp,%ebp
  802d43:	56                   	push   %esi
  802d44:	53                   	push   %ebx
  802d45:	83 ec 18             	sub    $0x18,%esp
  802d48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d4e:	50                   	push   %eax
  802d4f:	53                   	push   %ebx
  802d50:	e8 b4 fc ff ff       	call   802a09 <fd_lookup>
  802d55:	83 c4 10             	add    $0x10,%esp
  802d58:	85 c0                	test   %eax,%eax
  802d5a:	78 37                	js     802d93 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d5c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802d5f:	83 ec 08             	sub    $0x8,%esp
  802d62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d65:	50                   	push   %eax
  802d66:	ff 36                	push   (%esi)
  802d68:	e8 ec fc ff ff       	call   802a59 <dev_lookup>
  802d6d:	83 c4 10             	add    $0x10,%esp
  802d70:	85 c0                	test   %eax,%eax
  802d72:	78 1f                	js     802d93 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d74:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802d78:	74 20                	je     802d9a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d7d:	8b 40 0c             	mov    0xc(%eax),%eax
  802d80:	85 c0                	test   %eax,%eax
  802d82:	74 37                	je     802dbb <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d84:	83 ec 04             	sub    $0x4,%esp
  802d87:	ff 75 10             	push   0x10(%ebp)
  802d8a:	ff 75 0c             	push   0xc(%ebp)
  802d8d:	56                   	push   %esi
  802d8e:	ff d0                	call   *%eax
  802d90:	83 c4 10             	add    $0x10,%esp
}
  802d93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d96:	5b                   	pop    %ebx
  802d97:	5e                   	pop    %esi
  802d98:	5d                   	pop    %ebp
  802d99:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d9a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802d9f:	8b 40 58             	mov    0x58(%eax),%eax
  802da2:	83 ec 04             	sub    $0x4,%esp
  802da5:	53                   	push   %ebx
  802da6:	50                   	push   %eax
  802da7:	68 2d 47 80 00       	push   $0x80472d
  802dac:	e8 1a ee ff ff       	call   801bcb <cprintf>
		return -E_INVAL;
  802db1:	83 c4 10             	add    $0x10,%esp
  802db4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802db9:	eb d8                	jmp    802d93 <write+0x53>
		return -E_NOT_SUPP;
  802dbb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802dc0:	eb d1                	jmp    802d93 <write+0x53>

00802dc2 <seek>:

int
seek(int fdnum, off_t offset)
{
  802dc2:	55                   	push   %ebp
  802dc3:	89 e5                	mov    %esp,%ebp
  802dc5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dcb:	50                   	push   %eax
  802dcc:	ff 75 08             	push   0x8(%ebp)
  802dcf:	e8 35 fc ff ff       	call   802a09 <fd_lookup>
  802dd4:	83 c4 10             	add    $0x10,%esp
  802dd7:	85 c0                	test   %eax,%eax
  802dd9:	78 0e                	js     802de9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
  802dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802de1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802de4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802de9:	c9                   	leave  
  802dea:	c3                   	ret    

00802deb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802deb:	55                   	push   %ebp
  802dec:	89 e5                	mov    %esp,%ebp
  802dee:	56                   	push   %esi
  802def:	53                   	push   %ebx
  802df0:	83 ec 18             	sub    $0x18,%esp
  802df3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802df6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802df9:	50                   	push   %eax
  802dfa:	53                   	push   %ebx
  802dfb:	e8 09 fc ff ff       	call   802a09 <fd_lookup>
  802e00:	83 c4 10             	add    $0x10,%esp
  802e03:	85 c0                	test   %eax,%eax
  802e05:	78 34                	js     802e3b <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e07:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802e0a:	83 ec 08             	sub    $0x8,%esp
  802e0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e10:	50                   	push   %eax
  802e11:	ff 36                	push   (%esi)
  802e13:	e8 41 fc ff ff       	call   802a59 <dev_lookup>
  802e18:	83 c4 10             	add    $0x10,%esp
  802e1b:	85 c0                	test   %eax,%eax
  802e1d:	78 1c                	js     802e3b <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e1f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  802e23:	74 1d                	je     802e42 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e28:	8b 40 18             	mov    0x18(%eax),%eax
  802e2b:	85 c0                	test   %eax,%eax
  802e2d:	74 34                	je     802e63 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802e2f:	83 ec 08             	sub    $0x8,%esp
  802e32:	ff 75 0c             	push   0xc(%ebp)
  802e35:	56                   	push   %esi
  802e36:	ff d0                	call   *%eax
  802e38:	83 c4 10             	add    $0x10,%esp
}
  802e3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e3e:	5b                   	pop    %ebx
  802e3f:	5e                   	pop    %esi
  802e40:	5d                   	pop    %ebp
  802e41:	c3                   	ret    
			thisenv->env_id, fdnum);
  802e42:	a1 08 a0 80 00       	mov    0x80a008,%eax
  802e47:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802e4a:	83 ec 04             	sub    $0x4,%esp
  802e4d:	53                   	push   %ebx
  802e4e:	50                   	push   %eax
  802e4f:	68 f0 46 80 00       	push   $0x8046f0
  802e54:	e8 72 ed ff ff       	call   801bcb <cprintf>
		return -E_INVAL;
  802e59:	83 c4 10             	add    $0x10,%esp
  802e5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e61:	eb d8                	jmp    802e3b <ftruncate+0x50>
		return -E_NOT_SUPP;
  802e63:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e68:	eb d1                	jmp    802e3b <ftruncate+0x50>

00802e6a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802e6a:	55                   	push   %ebp
  802e6b:	89 e5                	mov    %esp,%ebp
  802e6d:	56                   	push   %esi
  802e6e:	53                   	push   %ebx
  802e6f:	83 ec 18             	sub    $0x18,%esp
  802e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e78:	50                   	push   %eax
  802e79:	ff 75 08             	push   0x8(%ebp)
  802e7c:	e8 88 fb ff ff       	call   802a09 <fd_lookup>
  802e81:	83 c4 10             	add    $0x10,%esp
  802e84:	85 c0                	test   %eax,%eax
  802e86:	78 49                	js     802ed1 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e88:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802e8b:	83 ec 08             	sub    $0x8,%esp
  802e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e91:	50                   	push   %eax
  802e92:	ff 36                	push   (%esi)
  802e94:	e8 c0 fb ff ff       	call   802a59 <dev_lookup>
  802e99:	83 c4 10             	add    $0x10,%esp
  802e9c:	85 c0                	test   %eax,%eax
  802e9e:	78 31                	js     802ed1 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  802ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ea3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802ea7:	74 2f                	je     802ed8 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ea9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802eac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802eb3:	00 00 00 
	stat->st_isdir = 0;
  802eb6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ebd:	00 00 00 
	stat->st_dev = dev;
  802ec0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802ec6:	83 ec 08             	sub    $0x8,%esp
  802ec9:	53                   	push   %ebx
  802eca:	56                   	push   %esi
  802ecb:	ff 50 14             	call   *0x14(%eax)
  802ece:	83 c4 10             	add    $0x10,%esp
}
  802ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ed4:	5b                   	pop    %ebx
  802ed5:	5e                   	pop    %esi
  802ed6:	5d                   	pop    %ebp
  802ed7:	c3                   	ret    
		return -E_NOT_SUPP;
  802ed8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802edd:	eb f2                	jmp    802ed1 <fstat+0x67>

00802edf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802edf:	55                   	push   %ebp
  802ee0:	89 e5                	mov    %esp,%ebp
  802ee2:	56                   	push   %esi
  802ee3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ee4:	83 ec 08             	sub    $0x8,%esp
  802ee7:	6a 00                	push   $0x0
  802ee9:	ff 75 08             	push   0x8(%ebp)
  802eec:	e8 e4 01 00 00       	call   8030d5 <open>
  802ef1:	89 c3                	mov    %eax,%ebx
  802ef3:	83 c4 10             	add    $0x10,%esp
  802ef6:	85 c0                	test   %eax,%eax
  802ef8:	78 1b                	js     802f15 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802efa:	83 ec 08             	sub    $0x8,%esp
  802efd:	ff 75 0c             	push   0xc(%ebp)
  802f00:	50                   	push   %eax
  802f01:	e8 64 ff ff ff       	call   802e6a <fstat>
  802f06:	89 c6                	mov    %eax,%esi
	close(fd);
  802f08:	89 1c 24             	mov    %ebx,(%esp)
  802f0b:	e8 26 fc ff ff       	call   802b36 <close>
	return r;
  802f10:	83 c4 10             	add    $0x10,%esp
  802f13:	89 f3                	mov    %esi,%ebx
}
  802f15:	89 d8                	mov    %ebx,%eax
  802f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f1a:	5b                   	pop    %ebx
  802f1b:	5e                   	pop    %esi
  802f1c:	5d                   	pop    %ebp
  802f1d:	c3                   	ret    

00802f1e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802f1e:	55                   	push   %ebp
  802f1f:	89 e5                	mov    %esp,%ebp
  802f21:	56                   	push   %esi
  802f22:	53                   	push   %ebx
  802f23:	89 c6                	mov    %eax,%esi
  802f25:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802f27:	83 3d 00 c0 80 00 00 	cmpl   $0x0,0x80c000
  802f2e:	74 27                	je     802f57 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802f30:	6a 07                	push   $0x7
  802f32:	68 00 b0 80 00       	push   $0x80b000
  802f37:	56                   	push   %esi
  802f38:	ff 35 00 c0 80 00    	push   0x80c000
  802f3e:	e8 bc f9 ff ff       	call   8028ff <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802f43:	83 c4 0c             	add    $0xc,%esp
  802f46:	6a 00                	push   $0x0
  802f48:	53                   	push   %ebx
  802f49:	6a 00                	push   $0x0
  802f4b:	e8 3f f9 ff ff       	call   80288f <ipc_recv>
}
  802f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f53:	5b                   	pop    %ebx
  802f54:	5e                   	pop    %esi
  802f55:	5d                   	pop    %ebp
  802f56:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802f57:	83 ec 0c             	sub    $0xc,%esp
  802f5a:	6a 01                	push   $0x1
  802f5c:	e8 f2 f9 ff ff       	call   802953 <ipc_find_env>
  802f61:	a3 00 c0 80 00       	mov    %eax,0x80c000
  802f66:	83 c4 10             	add    $0x10,%esp
  802f69:	eb c5                	jmp    802f30 <fsipc+0x12>

00802f6b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802f6b:	55                   	push   %ebp
  802f6c:	89 e5                	mov    %esp,%ebp
  802f6e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802f71:	8b 45 08             	mov    0x8(%ebp),%eax
  802f74:	8b 40 0c             	mov    0xc(%eax),%eax
  802f77:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f7f:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f84:	ba 00 00 00 00       	mov    $0x0,%edx
  802f89:	b8 02 00 00 00       	mov    $0x2,%eax
  802f8e:	e8 8b ff ff ff       	call   802f1e <fsipc>
}
  802f93:	c9                   	leave  
  802f94:	c3                   	ret    

00802f95 <devfile_flush>:
{
  802f95:	55                   	push   %ebp
  802f96:	89 e5                	mov    %esp,%ebp
  802f98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f9e:	8b 40 0c             	mov    0xc(%eax),%eax
  802fa1:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802fa6:	ba 00 00 00 00       	mov    $0x0,%edx
  802fab:	b8 06 00 00 00       	mov    $0x6,%eax
  802fb0:	e8 69 ff ff ff       	call   802f1e <fsipc>
}
  802fb5:	c9                   	leave  
  802fb6:	c3                   	ret    

00802fb7 <devfile_stat>:
{
  802fb7:	55                   	push   %ebp
  802fb8:	89 e5                	mov    %esp,%ebp
  802fba:	53                   	push   %ebx
  802fbb:	83 ec 04             	sub    $0x4,%esp
  802fbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  802fc4:	8b 40 0c             	mov    0xc(%eax),%eax
  802fc7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802fcc:	ba 00 00 00 00       	mov    $0x0,%edx
  802fd1:	b8 05 00 00 00       	mov    $0x5,%eax
  802fd6:	e8 43 ff ff ff       	call   802f1e <fsipc>
  802fdb:	85 c0                	test   %eax,%eax
  802fdd:	78 2c                	js     80300b <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802fdf:	83 ec 08             	sub    $0x8,%esp
  802fe2:	68 00 b0 80 00       	push   $0x80b000
  802fe7:	53                   	push   %ebx
  802fe8:	e8 b8 f1 ff ff       	call   8021a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802fed:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802ff2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802ff8:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802ffd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  803003:	83 c4 10             	add    $0x10,%esp
  803006:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80300b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80300e:	c9                   	leave  
  80300f:	c3                   	ret    

00803010 <devfile_write>:
{
  803010:	55                   	push   %ebp
  803011:	89 e5                	mov    %esp,%ebp
  803013:	83 ec 0c             	sub    $0xc,%esp
  803016:	8b 45 10             	mov    0x10(%ebp),%eax
  803019:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80301e:	39 d0                	cmp    %edx,%eax
  803020:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803023:	8b 55 08             	mov    0x8(%ebp),%edx
  803026:	8b 52 0c             	mov    0xc(%edx),%edx
  803029:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  80302f:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  803034:	50                   	push   %eax
  803035:	ff 75 0c             	push   0xc(%ebp)
  803038:	68 08 b0 80 00       	push   $0x80b008
  80303d:	e8 f9 f2 ff ff       	call   80233b <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  803042:	ba 00 00 00 00       	mov    $0x0,%edx
  803047:	b8 04 00 00 00       	mov    $0x4,%eax
  80304c:	e8 cd fe ff ff       	call   802f1e <fsipc>
}
  803051:	c9                   	leave  
  803052:	c3                   	ret    

00803053 <devfile_read>:
{
  803053:	55                   	push   %ebp
  803054:	89 e5                	mov    %esp,%ebp
  803056:	56                   	push   %esi
  803057:	53                   	push   %ebx
  803058:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80305b:	8b 45 08             	mov    0x8(%ebp),%eax
  80305e:	8b 40 0c             	mov    0xc(%eax),%eax
  803061:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803066:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80306c:	ba 00 00 00 00       	mov    $0x0,%edx
  803071:	b8 03 00 00 00       	mov    $0x3,%eax
  803076:	e8 a3 fe ff ff       	call   802f1e <fsipc>
  80307b:	89 c3                	mov    %eax,%ebx
  80307d:	85 c0                	test   %eax,%eax
  80307f:	78 1f                	js     8030a0 <devfile_read+0x4d>
	assert(r <= n);
  803081:	39 f0                	cmp    %esi,%eax
  803083:	77 24                	ja     8030a9 <devfile_read+0x56>
	assert(r <= PGSIZE);
  803085:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80308a:	7f 33                	jg     8030bf <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80308c:	83 ec 04             	sub    $0x4,%esp
  80308f:	50                   	push   %eax
  803090:	68 00 b0 80 00       	push   $0x80b000
  803095:	ff 75 0c             	push   0xc(%ebp)
  803098:	e8 9e f2 ff ff       	call   80233b <memmove>
	return r;
  80309d:	83 c4 10             	add    $0x10,%esp
}
  8030a0:	89 d8                	mov    %ebx,%eax
  8030a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030a5:	5b                   	pop    %ebx
  8030a6:	5e                   	pop    %esi
  8030a7:	5d                   	pop    %ebp
  8030a8:	c3                   	ret    
	assert(r <= n);
  8030a9:	68 60 47 80 00       	push   $0x804760
  8030ae:	68 5d 3d 80 00       	push   $0x803d5d
  8030b3:	6a 7c                	push   $0x7c
  8030b5:	68 67 47 80 00       	push   $0x804767
  8030ba:	e8 31 ea ff ff       	call   801af0 <_panic>
	assert(r <= PGSIZE);
  8030bf:	68 72 47 80 00       	push   $0x804772
  8030c4:	68 5d 3d 80 00       	push   $0x803d5d
  8030c9:	6a 7d                	push   $0x7d
  8030cb:	68 67 47 80 00       	push   $0x804767
  8030d0:	e8 1b ea ff ff       	call   801af0 <_panic>

008030d5 <open>:
{
  8030d5:	55                   	push   %ebp
  8030d6:	89 e5                	mov    %esp,%ebp
  8030d8:	56                   	push   %esi
  8030d9:	53                   	push   %ebx
  8030da:	83 ec 1c             	sub    $0x1c,%esp
  8030dd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8030e0:	56                   	push   %esi
  8030e1:	e8 84 f0 ff ff       	call   80216a <strlen>
  8030e6:	83 c4 10             	add    $0x10,%esp
  8030e9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8030ee:	7f 6c                	jg     80315c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8030f0:	83 ec 0c             	sub    $0xc,%esp
  8030f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030f6:	50                   	push   %eax
  8030f7:	e8 bd f8 ff ff       	call   8029b9 <fd_alloc>
  8030fc:	89 c3                	mov    %eax,%ebx
  8030fe:	83 c4 10             	add    $0x10,%esp
  803101:	85 c0                	test   %eax,%eax
  803103:	78 3c                	js     803141 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  803105:	83 ec 08             	sub    $0x8,%esp
  803108:	56                   	push   %esi
  803109:	68 00 b0 80 00       	push   $0x80b000
  80310e:	e8 92 f0 ff ff       	call   8021a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803113:	8b 45 0c             	mov    0xc(%ebp),%eax
  803116:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80311b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80311e:	b8 01 00 00 00       	mov    $0x1,%eax
  803123:	e8 f6 fd ff ff       	call   802f1e <fsipc>
  803128:	89 c3                	mov    %eax,%ebx
  80312a:	83 c4 10             	add    $0x10,%esp
  80312d:	85 c0                	test   %eax,%eax
  80312f:	78 19                	js     80314a <open+0x75>
	return fd2num(fd);
  803131:	83 ec 0c             	sub    $0xc,%esp
  803134:	ff 75 f4             	push   -0xc(%ebp)
  803137:	e8 56 f8 ff ff       	call   802992 <fd2num>
  80313c:	89 c3                	mov    %eax,%ebx
  80313e:	83 c4 10             	add    $0x10,%esp
}
  803141:	89 d8                	mov    %ebx,%eax
  803143:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803146:	5b                   	pop    %ebx
  803147:	5e                   	pop    %esi
  803148:	5d                   	pop    %ebp
  803149:	c3                   	ret    
		fd_close(fd, 0);
  80314a:	83 ec 08             	sub    $0x8,%esp
  80314d:	6a 00                	push   $0x0
  80314f:	ff 75 f4             	push   -0xc(%ebp)
  803152:	e8 58 f9 ff ff       	call   802aaf <fd_close>
		return r;
  803157:	83 c4 10             	add    $0x10,%esp
  80315a:	eb e5                	jmp    803141 <open+0x6c>
		return -E_BAD_PATH;
  80315c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  803161:	eb de                	jmp    803141 <open+0x6c>

00803163 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803163:	55                   	push   %ebp
  803164:	89 e5                	mov    %esp,%ebp
  803166:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803169:	ba 00 00 00 00       	mov    $0x0,%edx
  80316e:	b8 08 00 00 00       	mov    $0x8,%eax
  803173:	e8 a6 fd ff ff       	call   802f1e <fsipc>
}
  803178:	c9                   	leave  
  803179:	c3                   	ret    

0080317a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80317a:	55                   	push   %ebp
  80317b:	89 e5                	mov    %esp,%ebp
  80317d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803180:	89 c2                	mov    %eax,%edx
  803182:	c1 ea 16             	shr    $0x16,%edx
  803185:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80318c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  803191:	f6 c1 01             	test   $0x1,%cl
  803194:	74 1c                	je     8031b2 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  803196:	c1 e8 0c             	shr    $0xc,%eax
  803199:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8031a0:	a8 01                	test   $0x1,%al
  8031a2:	74 0e                	je     8031b2 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8031a4:	c1 e8 0c             	shr    $0xc,%eax
  8031a7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8031ae:	ef 
  8031af:	0f b7 d2             	movzwl %dx,%edx
}
  8031b2:	89 d0                	mov    %edx,%eax
  8031b4:	5d                   	pop    %ebp
  8031b5:	c3                   	ret    

008031b6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8031b6:	55                   	push   %ebp
  8031b7:	89 e5                	mov    %esp,%ebp
  8031b9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8031bc:	68 7e 47 80 00       	push   $0x80477e
  8031c1:	ff 75 0c             	push   0xc(%ebp)
  8031c4:	e8 dc ef ff ff       	call   8021a5 <strcpy>
	return 0;
}
  8031c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8031ce:	c9                   	leave  
  8031cf:	c3                   	ret    

008031d0 <devsock_close>:
{
  8031d0:	55                   	push   %ebp
  8031d1:	89 e5                	mov    %esp,%ebp
  8031d3:	53                   	push   %ebx
  8031d4:	83 ec 10             	sub    $0x10,%esp
  8031d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8031da:	53                   	push   %ebx
  8031db:	e8 9a ff ff ff       	call   80317a <pageref>
  8031e0:	89 c2                	mov    %eax,%edx
  8031e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8031e5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8031ea:	83 fa 01             	cmp    $0x1,%edx
  8031ed:	74 05                	je     8031f4 <devsock_close+0x24>
}
  8031ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031f2:	c9                   	leave  
  8031f3:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8031f4:	83 ec 0c             	sub    $0xc,%esp
  8031f7:	ff 73 0c             	push   0xc(%ebx)
  8031fa:	e8 b7 02 00 00       	call   8034b6 <nsipc_close>
  8031ff:	83 c4 10             	add    $0x10,%esp
  803202:	eb eb                	jmp    8031ef <devsock_close+0x1f>

00803204 <devsock_write>:
{
  803204:	55                   	push   %ebp
  803205:	89 e5                	mov    %esp,%ebp
  803207:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80320a:	6a 00                	push   $0x0
  80320c:	ff 75 10             	push   0x10(%ebp)
  80320f:	ff 75 0c             	push   0xc(%ebp)
  803212:	8b 45 08             	mov    0x8(%ebp),%eax
  803215:	ff 70 0c             	push   0xc(%eax)
  803218:	e8 79 03 00 00       	call   803596 <nsipc_send>
}
  80321d:	c9                   	leave  
  80321e:	c3                   	ret    

0080321f <devsock_read>:
{
  80321f:	55                   	push   %ebp
  803220:	89 e5                	mov    %esp,%ebp
  803222:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803225:	6a 00                	push   $0x0
  803227:	ff 75 10             	push   0x10(%ebp)
  80322a:	ff 75 0c             	push   0xc(%ebp)
  80322d:	8b 45 08             	mov    0x8(%ebp),%eax
  803230:	ff 70 0c             	push   0xc(%eax)
  803233:	e8 ef 02 00 00       	call   803527 <nsipc_recv>
}
  803238:	c9                   	leave  
  803239:	c3                   	ret    

0080323a <fd2sockid>:
{
  80323a:	55                   	push   %ebp
  80323b:	89 e5                	mov    %esp,%ebp
  80323d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  803240:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803243:	52                   	push   %edx
  803244:	50                   	push   %eax
  803245:	e8 bf f7 ff ff       	call   802a09 <fd_lookup>
  80324a:	83 c4 10             	add    $0x10,%esp
  80324d:	85 c0                	test   %eax,%eax
  80324f:	78 10                	js     803261 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  803251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803254:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  80325a:	39 08                	cmp    %ecx,(%eax)
  80325c:	75 05                	jne    803263 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80325e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  803261:	c9                   	leave  
  803262:	c3                   	ret    
		return -E_NOT_SUPP;
  803263:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803268:	eb f7                	jmp    803261 <fd2sockid+0x27>

0080326a <alloc_sockfd>:
{
  80326a:	55                   	push   %ebp
  80326b:	89 e5                	mov    %esp,%ebp
  80326d:	56                   	push   %esi
  80326e:	53                   	push   %ebx
  80326f:	83 ec 1c             	sub    $0x1c,%esp
  803272:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  803274:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803277:	50                   	push   %eax
  803278:	e8 3c f7 ff ff       	call   8029b9 <fd_alloc>
  80327d:	89 c3                	mov    %eax,%ebx
  80327f:	83 c4 10             	add    $0x10,%esp
  803282:	85 c0                	test   %eax,%eax
  803284:	78 43                	js     8032c9 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  803286:	83 ec 04             	sub    $0x4,%esp
  803289:	68 07 04 00 00       	push   $0x407
  80328e:	ff 75 f4             	push   -0xc(%ebp)
  803291:	6a 00                	push   $0x0
  803293:	e8 09 f3 ff ff       	call   8025a1 <sys_page_alloc>
  803298:	89 c3                	mov    %eax,%ebx
  80329a:	83 c4 10             	add    $0x10,%esp
  80329d:	85 c0                	test   %eax,%eax
  80329f:	78 28                	js     8032c9 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8032a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032a4:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8032aa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8032ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8032b6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8032b9:	83 ec 0c             	sub    $0xc,%esp
  8032bc:	50                   	push   %eax
  8032bd:	e8 d0 f6 ff ff       	call   802992 <fd2num>
  8032c2:	89 c3                	mov    %eax,%ebx
  8032c4:	83 c4 10             	add    $0x10,%esp
  8032c7:	eb 0c                	jmp    8032d5 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8032c9:	83 ec 0c             	sub    $0xc,%esp
  8032cc:	56                   	push   %esi
  8032cd:	e8 e4 01 00 00       	call   8034b6 <nsipc_close>
		return r;
  8032d2:	83 c4 10             	add    $0x10,%esp
}
  8032d5:	89 d8                	mov    %ebx,%eax
  8032d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032da:	5b                   	pop    %ebx
  8032db:	5e                   	pop    %esi
  8032dc:	5d                   	pop    %ebp
  8032dd:	c3                   	ret    

008032de <accept>:
{
  8032de:	55                   	push   %ebp
  8032df:	89 e5                	mov    %esp,%ebp
  8032e1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8032e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8032e7:	e8 4e ff ff ff       	call   80323a <fd2sockid>
  8032ec:	85 c0                	test   %eax,%eax
  8032ee:	78 1b                	js     80330b <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8032f0:	83 ec 04             	sub    $0x4,%esp
  8032f3:	ff 75 10             	push   0x10(%ebp)
  8032f6:	ff 75 0c             	push   0xc(%ebp)
  8032f9:	50                   	push   %eax
  8032fa:	e8 0e 01 00 00       	call   80340d <nsipc_accept>
  8032ff:	83 c4 10             	add    $0x10,%esp
  803302:	85 c0                	test   %eax,%eax
  803304:	78 05                	js     80330b <accept+0x2d>
	return alloc_sockfd(r);
  803306:	e8 5f ff ff ff       	call   80326a <alloc_sockfd>
}
  80330b:	c9                   	leave  
  80330c:	c3                   	ret    

0080330d <bind>:
{
  80330d:	55                   	push   %ebp
  80330e:	89 e5                	mov    %esp,%ebp
  803310:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803313:	8b 45 08             	mov    0x8(%ebp),%eax
  803316:	e8 1f ff ff ff       	call   80323a <fd2sockid>
  80331b:	85 c0                	test   %eax,%eax
  80331d:	78 12                	js     803331 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80331f:	83 ec 04             	sub    $0x4,%esp
  803322:	ff 75 10             	push   0x10(%ebp)
  803325:	ff 75 0c             	push   0xc(%ebp)
  803328:	50                   	push   %eax
  803329:	e8 31 01 00 00       	call   80345f <nsipc_bind>
  80332e:	83 c4 10             	add    $0x10,%esp
}
  803331:	c9                   	leave  
  803332:	c3                   	ret    

00803333 <shutdown>:
{
  803333:	55                   	push   %ebp
  803334:	89 e5                	mov    %esp,%ebp
  803336:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803339:	8b 45 08             	mov    0x8(%ebp),%eax
  80333c:	e8 f9 fe ff ff       	call   80323a <fd2sockid>
  803341:	85 c0                	test   %eax,%eax
  803343:	78 0f                	js     803354 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  803345:	83 ec 08             	sub    $0x8,%esp
  803348:	ff 75 0c             	push   0xc(%ebp)
  80334b:	50                   	push   %eax
  80334c:	e8 43 01 00 00       	call   803494 <nsipc_shutdown>
  803351:	83 c4 10             	add    $0x10,%esp
}
  803354:	c9                   	leave  
  803355:	c3                   	ret    

00803356 <connect>:
{
  803356:	55                   	push   %ebp
  803357:	89 e5                	mov    %esp,%ebp
  803359:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80335c:	8b 45 08             	mov    0x8(%ebp),%eax
  80335f:	e8 d6 fe ff ff       	call   80323a <fd2sockid>
  803364:	85 c0                	test   %eax,%eax
  803366:	78 12                	js     80337a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  803368:	83 ec 04             	sub    $0x4,%esp
  80336b:	ff 75 10             	push   0x10(%ebp)
  80336e:	ff 75 0c             	push   0xc(%ebp)
  803371:	50                   	push   %eax
  803372:	e8 59 01 00 00       	call   8034d0 <nsipc_connect>
  803377:	83 c4 10             	add    $0x10,%esp
}
  80337a:	c9                   	leave  
  80337b:	c3                   	ret    

0080337c <listen>:
{
  80337c:	55                   	push   %ebp
  80337d:	89 e5                	mov    %esp,%ebp
  80337f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  803382:	8b 45 08             	mov    0x8(%ebp),%eax
  803385:	e8 b0 fe ff ff       	call   80323a <fd2sockid>
  80338a:	85 c0                	test   %eax,%eax
  80338c:	78 0f                	js     80339d <listen+0x21>
	return nsipc_listen(r, backlog);
  80338e:	83 ec 08             	sub    $0x8,%esp
  803391:	ff 75 0c             	push   0xc(%ebp)
  803394:	50                   	push   %eax
  803395:	e8 6b 01 00 00       	call   803505 <nsipc_listen>
  80339a:	83 c4 10             	add    $0x10,%esp
}
  80339d:	c9                   	leave  
  80339e:	c3                   	ret    

0080339f <socket>:

int
socket(int domain, int type, int protocol)
{
  80339f:	55                   	push   %ebp
  8033a0:	89 e5                	mov    %esp,%ebp
  8033a2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8033a5:	ff 75 10             	push   0x10(%ebp)
  8033a8:	ff 75 0c             	push   0xc(%ebp)
  8033ab:	ff 75 08             	push   0x8(%ebp)
  8033ae:	e8 41 02 00 00       	call   8035f4 <nsipc_socket>
  8033b3:	83 c4 10             	add    $0x10,%esp
  8033b6:	85 c0                	test   %eax,%eax
  8033b8:	78 05                	js     8033bf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8033ba:	e8 ab fe ff ff       	call   80326a <alloc_sockfd>
}
  8033bf:	c9                   	leave  
  8033c0:	c3                   	ret    

008033c1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8033c1:	55                   	push   %ebp
  8033c2:	89 e5                	mov    %esp,%ebp
  8033c4:	53                   	push   %ebx
  8033c5:	83 ec 04             	sub    $0x4,%esp
  8033c8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8033ca:	83 3d 00 e0 80 00 00 	cmpl   $0x0,0x80e000
  8033d1:	74 26                	je     8033f9 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8033d3:	6a 07                	push   $0x7
  8033d5:	68 00 d0 80 00       	push   $0x80d000
  8033da:	53                   	push   %ebx
  8033db:	ff 35 00 e0 80 00    	push   0x80e000
  8033e1:	e8 19 f5 ff ff       	call   8028ff <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8033e6:	83 c4 0c             	add    $0xc,%esp
  8033e9:	6a 00                	push   $0x0
  8033eb:	6a 00                	push   $0x0
  8033ed:	6a 00                	push   $0x0
  8033ef:	e8 9b f4 ff ff       	call   80288f <ipc_recv>
}
  8033f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033f7:	c9                   	leave  
  8033f8:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8033f9:	83 ec 0c             	sub    $0xc,%esp
  8033fc:	6a 02                	push   $0x2
  8033fe:	e8 50 f5 ff ff       	call   802953 <ipc_find_env>
  803403:	a3 00 e0 80 00       	mov    %eax,0x80e000
  803408:	83 c4 10             	add    $0x10,%esp
  80340b:	eb c6                	jmp    8033d3 <nsipc+0x12>

0080340d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80340d:	55                   	push   %ebp
  80340e:	89 e5                	mov    %esp,%ebp
  803410:	56                   	push   %esi
  803411:	53                   	push   %ebx
  803412:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803415:	8b 45 08             	mov    0x8(%ebp),%eax
  803418:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80341d:	8b 06                	mov    (%esi),%eax
  80341f:	a3 04 d0 80 00       	mov    %eax,0x80d004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803424:	b8 01 00 00 00       	mov    $0x1,%eax
  803429:	e8 93 ff ff ff       	call   8033c1 <nsipc>
  80342e:	89 c3                	mov    %eax,%ebx
  803430:	85 c0                	test   %eax,%eax
  803432:	79 09                	jns    80343d <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  803434:	89 d8                	mov    %ebx,%eax
  803436:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803439:	5b                   	pop    %ebx
  80343a:	5e                   	pop    %esi
  80343b:	5d                   	pop    %ebp
  80343c:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80343d:	83 ec 04             	sub    $0x4,%esp
  803440:	ff 35 10 d0 80 00    	push   0x80d010
  803446:	68 00 d0 80 00       	push   $0x80d000
  80344b:	ff 75 0c             	push   0xc(%ebp)
  80344e:	e8 e8 ee ff ff       	call   80233b <memmove>
		*addrlen = ret->ret_addrlen;
  803453:	a1 10 d0 80 00       	mov    0x80d010,%eax
  803458:	89 06                	mov    %eax,(%esi)
  80345a:	83 c4 10             	add    $0x10,%esp
	return r;
  80345d:	eb d5                	jmp    803434 <nsipc_accept+0x27>

0080345f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80345f:	55                   	push   %ebp
  803460:	89 e5                	mov    %esp,%ebp
  803462:	53                   	push   %ebx
  803463:	83 ec 08             	sub    $0x8,%esp
  803466:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803469:	8b 45 08             	mov    0x8(%ebp),%eax
  80346c:	a3 00 d0 80 00       	mov    %eax,0x80d000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803471:	53                   	push   %ebx
  803472:	ff 75 0c             	push   0xc(%ebp)
  803475:	68 04 d0 80 00       	push   $0x80d004
  80347a:	e8 bc ee ff ff       	call   80233b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80347f:	89 1d 14 d0 80 00    	mov    %ebx,0x80d014
	return nsipc(NSREQ_BIND);
  803485:	b8 02 00 00 00       	mov    $0x2,%eax
  80348a:	e8 32 ff ff ff       	call   8033c1 <nsipc>
}
  80348f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803492:	c9                   	leave  
  803493:	c3                   	ret    

00803494 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  803494:	55                   	push   %ebp
  803495:	89 e5                	mov    %esp,%ebp
  803497:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80349a:	8b 45 08             	mov    0x8(%ebp),%eax
  80349d:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.shutdown.req_how = how;
  8034a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034a5:	a3 04 d0 80 00       	mov    %eax,0x80d004
	return nsipc(NSREQ_SHUTDOWN);
  8034aa:	b8 03 00 00 00       	mov    $0x3,%eax
  8034af:	e8 0d ff ff ff       	call   8033c1 <nsipc>
}
  8034b4:	c9                   	leave  
  8034b5:	c3                   	ret    

008034b6 <nsipc_close>:

int
nsipc_close(int s)
{
  8034b6:	55                   	push   %ebp
  8034b7:	89 e5                	mov    %esp,%ebp
  8034b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8034bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8034bf:	a3 00 d0 80 00       	mov    %eax,0x80d000
	return nsipc(NSREQ_CLOSE);
  8034c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8034c9:	e8 f3 fe ff ff       	call   8033c1 <nsipc>
}
  8034ce:	c9                   	leave  
  8034cf:	c3                   	ret    

008034d0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8034d0:	55                   	push   %ebp
  8034d1:	89 e5                	mov    %esp,%ebp
  8034d3:	53                   	push   %ebx
  8034d4:	83 ec 08             	sub    $0x8,%esp
  8034d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8034da:	8b 45 08             	mov    0x8(%ebp),%eax
  8034dd:	a3 00 d0 80 00       	mov    %eax,0x80d000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8034e2:	53                   	push   %ebx
  8034e3:	ff 75 0c             	push   0xc(%ebp)
  8034e6:	68 04 d0 80 00       	push   $0x80d004
  8034eb:	e8 4b ee ff ff       	call   80233b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8034f0:	89 1d 14 d0 80 00    	mov    %ebx,0x80d014
	return nsipc(NSREQ_CONNECT);
  8034f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8034fb:	e8 c1 fe ff ff       	call   8033c1 <nsipc>
}
  803500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803503:	c9                   	leave  
  803504:	c3                   	ret    

00803505 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803505:	55                   	push   %ebp
  803506:	89 e5                	mov    %esp,%ebp
  803508:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80350b:	8b 45 08             	mov    0x8(%ebp),%eax
  80350e:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.listen.req_backlog = backlog;
  803513:	8b 45 0c             	mov    0xc(%ebp),%eax
  803516:	a3 04 d0 80 00       	mov    %eax,0x80d004
	return nsipc(NSREQ_LISTEN);
  80351b:	b8 06 00 00 00       	mov    $0x6,%eax
  803520:	e8 9c fe ff ff       	call   8033c1 <nsipc>
}
  803525:	c9                   	leave  
  803526:	c3                   	ret    

00803527 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803527:	55                   	push   %ebp
  803528:	89 e5                	mov    %esp,%ebp
  80352a:	56                   	push   %esi
  80352b:	53                   	push   %ebx
  80352c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80352f:	8b 45 08             	mov    0x8(%ebp),%eax
  803532:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.recv.req_len = len;
  803537:	89 35 04 d0 80 00    	mov    %esi,0x80d004
	nsipcbuf.recv.req_flags = flags;
  80353d:	8b 45 14             	mov    0x14(%ebp),%eax
  803540:	a3 08 d0 80 00       	mov    %eax,0x80d008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803545:	b8 07 00 00 00       	mov    $0x7,%eax
  80354a:	e8 72 fe ff ff       	call   8033c1 <nsipc>
  80354f:	89 c3                	mov    %eax,%ebx
  803551:	85 c0                	test   %eax,%eax
  803553:	78 22                	js     803577 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  803555:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80355a:	39 c6                	cmp    %eax,%esi
  80355c:	0f 4e c6             	cmovle %esi,%eax
  80355f:	39 c3                	cmp    %eax,%ebx
  803561:	7f 1d                	jg     803580 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803563:	83 ec 04             	sub    $0x4,%esp
  803566:	53                   	push   %ebx
  803567:	68 00 d0 80 00       	push   $0x80d000
  80356c:	ff 75 0c             	push   0xc(%ebp)
  80356f:	e8 c7 ed ff ff       	call   80233b <memmove>
  803574:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803577:	89 d8                	mov    %ebx,%eax
  803579:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80357c:	5b                   	pop    %ebx
  80357d:	5e                   	pop    %esi
  80357e:	5d                   	pop    %ebp
  80357f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  803580:	68 8a 47 80 00       	push   $0x80478a
  803585:	68 5d 3d 80 00       	push   $0x803d5d
  80358a:	6a 62                	push   $0x62
  80358c:	68 9f 47 80 00       	push   $0x80479f
  803591:	e8 5a e5 ff ff       	call   801af0 <_panic>

00803596 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803596:	55                   	push   %ebp
  803597:	89 e5                	mov    %esp,%ebp
  803599:	53                   	push   %ebx
  80359a:	83 ec 04             	sub    $0x4,%esp
  80359d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8035a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8035a3:	a3 00 d0 80 00       	mov    %eax,0x80d000
	assert(size < 1600);
  8035a8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8035ae:	7f 2e                	jg     8035de <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8035b0:	83 ec 04             	sub    $0x4,%esp
  8035b3:	53                   	push   %ebx
  8035b4:	ff 75 0c             	push   0xc(%ebp)
  8035b7:	68 0c d0 80 00       	push   $0x80d00c
  8035bc:	e8 7a ed ff ff       	call   80233b <memmove>
	nsipcbuf.send.req_size = size;
  8035c1:	89 1d 04 d0 80 00    	mov    %ebx,0x80d004
	nsipcbuf.send.req_flags = flags;
  8035c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8035ca:	a3 08 d0 80 00       	mov    %eax,0x80d008
	return nsipc(NSREQ_SEND);
  8035cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8035d4:	e8 e8 fd ff ff       	call   8033c1 <nsipc>
}
  8035d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035dc:	c9                   	leave  
  8035dd:	c3                   	ret    
	assert(size < 1600);
  8035de:	68 ab 47 80 00       	push   $0x8047ab
  8035e3:	68 5d 3d 80 00       	push   $0x803d5d
  8035e8:	6a 6d                	push   $0x6d
  8035ea:	68 9f 47 80 00       	push   $0x80479f
  8035ef:	e8 fc e4 ff ff       	call   801af0 <_panic>

008035f4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8035f4:	55                   	push   %ebp
  8035f5:	89 e5                	mov    %esp,%ebp
  8035f7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8035fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8035fd:	a3 00 d0 80 00       	mov    %eax,0x80d000
	nsipcbuf.socket.req_type = type;
  803602:	8b 45 0c             	mov    0xc(%ebp),%eax
  803605:	a3 04 d0 80 00       	mov    %eax,0x80d004
	nsipcbuf.socket.req_protocol = protocol;
  80360a:	8b 45 10             	mov    0x10(%ebp),%eax
  80360d:	a3 08 d0 80 00       	mov    %eax,0x80d008
	return nsipc(NSREQ_SOCKET);
  803612:	b8 09 00 00 00       	mov    $0x9,%eax
  803617:	e8 a5 fd ff ff       	call   8033c1 <nsipc>
}
  80361c:	c9                   	leave  
  80361d:	c3                   	ret    

0080361e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80361e:	55                   	push   %ebp
  80361f:	89 e5                	mov    %esp,%ebp
  803621:	56                   	push   %esi
  803622:	53                   	push   %ebx
  803623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803626:	83 ec 0c             	sub    $0xc,%esp
  803629:	ff 75 08             	push   0x8(%ebp)
  80362c:	e8 71 f3 ff ff       	call   8029a2 <fd2data>
  803631:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803633:	83 c4 08             	add    $0x8,%esp
  803636:	68 b7 47 80 00       	push   $0x8047b7
  80363b:	53                   	push   %ebx
  80363c:	e8 64 eb ff ff       	call   8021a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803641:	8b 46 04             	mov    0x4(%esi),%eax
  803644:	2b 06                	sub    (%esi),%eax
  803646:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80364c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803653:	00 00 00 
	stat->st_dev = &devpipe;
  803656:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  80365d:	90 80 00 
	return 0;
}
  803660:	b8 00 00 00 00       	mov    $0x0,%eax
  803665:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803668:	5b                   	pop    %ebx
  803669:	5e                   	pop    %esi
  80366a:	5d                   	pop    %ebp
  80366b:	c3                   	ret    

0080366c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80366c:	55                   	push   %ebp
  80366d:	89 e5                	mov    %esp,%ebp
  80366f:	53                   	push   %ebx
  803670:	83 ec 0c             	sub    $0xc,%esp
  803673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803676:	53                   	push   %ebx
  803677:	6a 00                	push   $0x0
  803679:	e8 a8 ef ff ff       	call   802626 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80367e:	89 1c 24             	mov    %ebx,(%esp)
  803681:	e8 1c f3 ff ff       	call   8029a2 <fd2data>
  803686:	83 c4 08             	add    $0x8,%esp
  803689:	50                   	push   %eax
  80368a:	6a 00                	push   $0x0
  80368c:	e8 95 ef ff ff       	call   802626 <sys_page_unmap>
}
  803691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803694:	c9                   	leave  
  803695:	c3                   	ret    

00803696 <_pipeisclosed>:
{
  803696:	55                   	push   %ebp
  803697:	89 e5                	mov    %esp,%ebp
  803699:	57                   	push   %edi
  80369a:	56                   	push   %esi
  80369b:	53                   	push   %ebx
  80369c:	83 ec 1c             	sub    $0x1c,%esp
  80369f:	89 c7                	mov    %eax,%edi
  8036a1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8036a3:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8036a8:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8036ab:	83 ec 0c             	sub    $0xc,%esp
  8036ae:	57                   	push   %edi
  8036af:	e8 c6 fa ff ff       	call   80317a <pageref>
  8036b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8036b7:	89 34 24             	mov    %esi,(%esp)
  8036ba:	e8 bb fa ff ff       	call   80317a <pageref>
		nn = thisenv->env_runs;
  8036bf:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8036c5:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8036c8:	83 c4 10             	add    $0x10,%esp
  8036cb:	39 cb                	cmp    %ecx,%ebx
  8036cd:	74 1b                	je     8036ea <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8036cf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8036d2:	75 cf                	jne    8036a3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8036d4:	8b 42 68             	mov    0x68(%edx),%eax
  8036d7:	6a 01                	push   $0x1
  8036d9:	50                   	push   %eax
  8036da:	53                   	push   %ebx
  8036db:	68 be 47 80 00       	push   $0x8047be
  8036e0:	e8 e6 e4 ff ff       	call   801bcb <cprintf>
  8036e5:	83 c4 10             	add    $0x10,%esp
  8036e8:	eb b9                	jmp    8036a3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8036ea:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8036ed:	0f 94 c0             	sete   %al
  8036f0:	0f b6 c0             	movzbl %al,%eax
}
  8036f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036f6:	5b                   	pop    %ebx
  8036f7:	5e                   	pop    %esi
  8036f8:	5f                   	pop    %edi
  8036f9:	5d                   	pop    %ebp
  8036fa:	c3                   	ret    

008036fb <devpipe_write>:
{
  8036fb:	55                   	push   %ebp
  8036fc:	89 e5                	mov    %esp,%ebp
  8036fe:	57                   	push   %edi
  8036ff:	56                   	push   %esi
  803700:	53                   	push   %ebx
  803701:	83 ec 28             	sub    $0x28,%esp
  803704:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803707:	56                   	push   %esi
  803708:	e8 95 f2 ff ff       	call   8029a2 <fd2data>
  80370d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80370f:	83 c4 10             	add    $0x10,%esp
  803712:	bf 00 00 00 00       	mov    $0x0,%edi
  803717:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80371a:	75 09                	jne    803725 <devpipe_write+0x2a>
	return i;
  80371c:	89 f8                	mov    %edi,%eax
  80371e:	eb 23                	jmp    803743 <devpipe_write+0x48>
			sys_yield();
  803720:	e8 5d ee ff ff       	call   802582 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803725:	8b 43 04             	mov    0x4(%ebx),%eax
  803728:	8b 0b                	mov    (%ebx),%ecx
  80372a:	8d 51 20             	lea    0x20(%ecx),%edx
  80372d:	39 d0                	cmp    %edx,%eax
  80372f:	72 1a                	jb     80374b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  803731:	89 da                	mov    %ebx,%edx
  803733:	89 f0                	mov    %esi,%eax
  803735:	e8 5c ff ff ff       	call   803696 <_pipeisclosed>
  80373a:	85 c0                	test   %eax,%eax
  80373c:	74 e2                	je     803720 <devpipe_write+0x25>
				return 0;
  80373e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803746:	5b                   	pop    %ebx
  803747:	5e                   	pop    %esi
  803748:	5f                   	pop    %edi
  803749:	5d                   	pop    %ebp
  80374a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80374b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80374e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803752:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803755:	89 c2                	mov    %eax,%edx
  803757:	c1 fa 1f             	sar    $0x1f,%edx
  80375a:	89 d1                	mov    %edx,%ecx
  80375c:	c1 e9 1b             	shr    $0x1b,%ecx
  80375f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803762:	83 e2 1f             	and    $0x1f,%edx
  803765:	29 ca                	sub    %ecx,%edx
  803767:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80376b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80376f:	83 c0 01             	add    $0x1,%eax
  803772:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  803775:	83 c7 01             	add    $0x1,%edi
  803778:	eb 9d                	jmp    803717 <devpipe_write+0x1c>

0080377a <devpipe_read>:
{
  80377a:	55                   	push   %ebp
  80377b:	89 e5                	mov    %esp,%ebp
  80377d:	57                   	push   %edi
  80377e:	56                   	push   %esi
  80377f:	53                   	push   %ebx
  803780:	83 ec 18             	sub    $0x18,%esp
  803783:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803786:	57                   	push   %edi
  803787:	e8 16 f2 ff ff       	call   8029a2 <fd2data>
  80378c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80378e:	83 c4 10             	add    $0x10,%esp
  803791:	be 00 00 00 00       	mov    $0x0,%esi
  803796:	3b 75 10             	cmp    0x10(%ebp),%esi
  803799:	75 13                	jne    8037ae <devpipe_read+0x34>
	return i;
  80379b:	89 f0                	mov    %esi,%eax
  80379d:	eb 02                	jmp    8037a1 <devpipe_read+0x27>
				return i;
  80379f:	89 f0                	mov    %esi,%eax
}
  8037a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8037a4:	5b                   	pop    %ebx
  8037a5:	5e                   	pop    %esi
  8037a6:	5f                   	pop    %edi
  8037a7:	5d                   	pop    %ebp
  8037a8:	c3                   	ret    
			sys_yield();
  8037a9:	e8 d4 ed ff ff       	call   802582 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8037ae:	8b 03                	mov    (%ebx),%eax
  8037b0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8037b3:	75 18                	jne    8037cd <devpipe_read+0x53>
			if (i > 0)
  8037b5:	85 f6                	test   %esi,%esi
  8037b7:	75 e6                	jne    80379f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8037b9:	89 da                	mov    %ebx,%edx
  8037bb:	89 f8                	mov    %edi,%eax
  8037bd:	e8 d4 fe ff ff       	call   803696 <_pipeisclosed>
  8037c2:	85 c0                	test   %eax,%eax
  8037c4:	74 e3                	je     8037a9 <devpipe_read+0x2f>
				return 0;
  8037c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8037cb:	eb d4                	jmp    8037a1 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8037cd:	99                   	cltd   
  8037ce:	c1 ea 1b             	shr    $0x1b,%edx
  8037d1:	01 d0                	add    %edx,%eax
  8037d3:	83 e0 1f             	and    $0x1f,%eax
  8037d6:	29 d0                	sub    %edx,%eax
  8037d8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8037dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8037e0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8037e3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8037e6:	83 c6 01             	add    $0x1,%esi
  8037e9:	eb ab                	jmp    803796 <devpipe_read+0x1c>

008037eb <pipe>:
{
  8037eb:	55                   	push   %ebp
  8037ec:	89 e5                	mov    %esp,%ebp
  8037ee:	56                   	push   %esi
  8037ef:	53                   	push   %ebx
  8037f0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8037f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037f6:	50                   	push   %eax
  8037f7:	e8 bd f1 ff ff       	call   8029b9 <fd_alloc>
  8037fc:	89 c3                	mov    %eax,%ebx
  8037fe:	83 c4 10             	add    $0x10,%esp
  803801:	85 c0                	test   %eax,%eax
  803803:	0f 88 23 01 00 00    	js     80392c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803809:	83 ec 04             	sub    $0x4,%esp
  80380c:	68 07 04 00 00       	push   $0x407
  803811:	ff 75 f4             	push   -0xc(%ebp)
  803814:	6a 00                	push   $0x0
  803816:	e8 86 ed ff ff       	call   8025a1 <sys_page_alloc>
  80381b:	89 c3                	mov    %eax,%ebx
  80381d:	83 c4 10             	add    $0x10,%esp
  803820:	85 c0                	test   %eax,%eax
  803822:	0f 88 04 01 00 00    	js     80392c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  803828:	83 ec 0c             	sub    $0xc,%esp
  80382b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80382e:	50                   	push   %eax
  80382f:	e8 85 f1 ff ff       	call   8029b9 <fd_alloc>
  803834:	89 c3                	mov    %eax,%ebx
  803836:	83 c4 10             	add    $0x10,%esp
  803839:	85 c0                	test   %eax,%eax
  80383b:	0f 88 db 00 00 00    	js     80391c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803841:	83 ec 04             	sub    $0x4,%esp
  803844:	68 07 04 00 00       	push   $0x407
  803849:	ff 75 f0             	push   -0x10(%ebp)
  80384c:	6a 00                	push   $0x0
  80384e:	e8 4e ed ff ff       	call   8025a1 <sys_page_alloc>
  803853:	89 c3                	mov    %eax,%ebx
  803855:	83 c4 10             	add    $0x10,%esp
  803858:	85 c0                	test   %eax,%eax
  80385a:	0f 88 bc 00 00 00    	js     80391c <pipe+0x131>
	va = fd2data(fd0);
  803860:	83 ec 0c             	sub    $0xc,%esp
  803863:	ff 75 f4             	push   -0xc(%ebp)
  803866:	e8 37 f1 ff ff       	call   8029a2 <fd2data>
  80386b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80386d:	83 c4 0c             	add    $0xc,%esp
  803870:	68 07 04 00 00       	push   $0x407
  803875:	50                   	push   %eax
  803876:	6a 00                	push   $0x0
  803878:	e8 24 ed ff ff       	call   8025a1 <sys_page_alloc>
  80387d:	89 c3                	mov    %eax,%ebx
  80387f:	83 c4 10             	add    $0x10,%esp
  803882:	85 c0                	test   %eax,%eax
  803884:	0f 88 82 00 00 00    	js     80390c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80388a:	83 ec 0c             	sub    $0xc,%esp
  80388d:	ff 75 f0             	push   -0x10(%ebp)
  803890:	e8 0d f1 ff ff       	call   8029a2 <fd2data>
  803895:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80389c:	50                   	push   %eax
  80389d:	6a 00                	push   $0x0
  80389f:	56                   	push   %esi
  8038a0:	6a 00                	push   $0x0
  8038a2:	e8 3d ed ff ff       	call   8025e4 <sys_page_map>
  8038a7:	89 c3                	mov    %eax,%ebx
  8038a9:	83 c4 20             	add    $0x20,%esp
  8038ac:	85 c0                	test   %eax,%eax
  8038ae:	78 4e                	js     8038fe <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8038b0:	a1 9c 90 80 00       	mov    0x80909c,%eax
  8038b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8038b8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8038ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8038bd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8038c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8038c7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8038c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8038cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8038d3:	83 ec 0c             	sub    $0xc,%esp
  8038d6:	ff 75 f4             	push   -0xc(%ebp)
  8038d9:	e8 b4 f0 ff ff       	call   802992 <fd2num>
  8038de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038e1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8038e3:	83 c4 04             	add    $0x4,%esp
  8038e6:	ff 75 f0             	push   -0x10(%ebp)
  8038e9:	e8 a4 f0 ff ff       	call   802992 <fd2num>
  8038ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038f1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8038f4:	83 c4 10             	add    $0x10,%esp
  8038f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8038fc:	eb 2e                	jmp    80392c <pipe+0x141>
	sys_page_unmap(0, va);
  8038fe:	83 ec 08             	sub    $0x8,%esp
  803901:	56                   	push   %esi
  803902:	6a 00                	push   $0x0
  803904:	e8 1d ed ff ff       	call   802626 <sys_page_unmap>
  803909:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80390c:	83 ec 08             	sub    $0x8,%esp
  80390f:	ff 75 f0             	push   -0x10(%ebp)
  803912:	6a 00                	push   $0x0
  803914:	e8 0d ed ff ff       	call   802626 <sys_page_unmap>
  803919:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80391c:	83 ec 08             	sub    $0x8,%esp
  80391f:	ff 75 f4             	push   -0xc(%ebp)
  803922:	6a 00                	push   $0x0
  803924:	e8 fd ec ff ff       	call   802626 <sys_page_unmap>
  803929:	83 c4 10             	add    $0x10,%esp
}
  80392c:	89 d8                	mov    %ebx,%eax
  80392e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803931:	5b                   	pop    %ebx
  803932:	5e                   	pop    %esi
  803933:	5d                   	pop    %ebp
  803934:	c3                   	ret    

00803935 <pipeisclosed>:
{
  803935:	55                   	push   %ebp
  803936:	89 e5                	mov    %esp,%ebp
  803938:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80393b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80393e:	50                   	push   %eax
  80393f:	ff 75 08             	push   0x8(%ebp)
  803942:	e8 c2 f0 ff ff       	call   802a09 <fd_lookup>
  803947:	83 c4 10             	add    $0x10,%esp
  80394a:	85 c0                	test   %eax,%eax
  80394c:	78 18                	js     803966 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80394e:	83 ec 0c             	sub    $0xc,%esp
  803951:	ff 75 f4             	push   -0xc(%ebp)
  803954:	e8 49 f0 ff ff       	call   8029a2 <fd2data>
  803959:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80395b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80395e:	e8 33 fd ff ff       	call   803696 <_pipeisclosed>
  803963:	83 c4 10             	add    $0x10,%esp
}
  803966:	c9                   	leave  
  803967:	c3                   	ret    

00803968 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  803968:	b8 00 00 00 00       	mov    $0x0,%eax
  80396d:	c3                   	ret    

0080396e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80396e:	55                   	push   %ebp
  80396f:	89 e5                	mov    %esp,%ebp
  803971:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803974:	68 d6 47 80 00       	push   $0x8047d6
  803979:	ff 75 0c             	push   0xc(%ebp)
  80397c:	e8 24 e8 ff ff       	call   8021a5 <strcpy>
	return 0;
}
  803981:	b8 00 00 00 00       	mov    $0x0,%eax
  803986:	c9                   	leave  
  803987:	c3                   	ret    

00803988 <devcons_write>:
{
  803988:	55                   	push   %ebp
  803989:	89 e5                	mov    %esp,%ebp
  80398b:	57                   	push   %edi
  80398c:	56                   	push   %esi
  80398d:	53                   	push   %ebx
  80398e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  803994:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803999:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80399f:	eb 2e                	jmp    8039cf <devcons_write+0x47>
		m = n - tot;
  8039a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8039a4:	29 f3                	sub    %esi,%ebx
  8039a6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8039ab:	39 c3                	cmp    %eax,%ebx
  8039ad:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8039b0:	83 ec 04             	sub    $0x4,%esp
  8039b3:	53                   	push   %ebx
  8039b4:	89 f0                	mov    %esi,%eax
  8039b6:	03 45 0c             	add    0xc(%ebp),%eax
  8039b9:	50                   	push   %eax
  8039ba:	57                   	push   %edi
  8039bb:	e8 7b e9 ff ff       	call   80233b <memmove>
		sys_cputs(buf, m);
  8039c0:	83 c4 08             	add    $0x8,%esp
  8039c3:	53                   	push   %ebx
  8039c4:	57                   	push   %edi
  8039c5:	e8 1b eb ff ff       	call   8024e5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8039ca:	01 de                	add    %ebx,%esi
  8039cc:	83 c4 10             	add    $0x10,%esp
  8039cf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8039d2:	72 cd                	jb     8039a1 <devcons_write+0x19>
}
  8039d4:	89 f0                	mov    %esi,%eax
  8039d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8039d9:	5b                   	pop    %ebx
  8039da:	5e                   	pop    %esi
  8039db:	5f                   	pop    %edi
  8039dc:	5d                   	pop    %ebp
  8039dd:	c3                   	ret    

008039de <devcons_read>:
{
  8039de:	55                   	push   %ebp
  8039df:	89 e5                	mov    %esp,%ebp
  8039e1:	83 ec 08             	sub    $0x8,%esp
  8039e4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8039e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8039ed:	75 07                	jne    8039f6 <devcons_read+0x18>
  8039ef:	eb 1f                	jmp    803a10 <devcons_read+0x32>
		sys_yield();
  8039f1:	e8 8c eb ff ff       	call   802582 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8039f6:	e8 08 eb ff ff       	call   802503 <sys_cgetc>
  8039fb:	85 c0                	test   %eax,%eax
  8039fd:	74 f2                	je     8039f1 <devcons_read+0x13>
	if (c < 0)
  8039ff:	78 0f                	js     803a10 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  803a01:	83 f8 04             	cmp    $0x4,%eax
  803a04:	74 0c                	je     803a12 <devcons_read+0x34>
	*(char*)vbuf = c;
  803a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  803a09:	88 02                	mov    %al,(%edx)
	return 1;
  803a0b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  803a10:	c9                   	leave  
  803a11:	c3                   	ret    
		return 0;
  803a12:	b8 00 00 00 00       	mov    $0x0,%eax
  803a17:	eb f7                	jmp    803a10 <devcons_read+0x32>

00803a19 <cputchar>:
{
  803a19:	55                   	push   %ebp
  803a1a:	89 e5                	mov    %esp,%ebp
  803a1c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  803a22:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  803a25:	6a 01                	push   $0x1
  803a27:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a2a:	50                   	push   %eax
  803a2b:	e8 b5 ea ff ff       	call   8024e5 <sys_cputs>
}
  803a30:	83 c4 10             	add    $0x10,%esp
  803a33:	c9                   	leave  
  803a34:	c3                   	ret    

00803a35 <getchar>:
{
  803a35:	55                   	push   %ebp
  803a36:	89 e5                	mov    %esp,%ebp
  803a38:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  803a3b:	6a 01                	push   $0x1
  803a3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a40:	50                   	push   %eax
  803a41:	6a 00                	push   $0x0
  803a43:	e8 2a f2 ff ff       	call   802c72 <read>
	if (r < 0)
  803a48:	83 c4 10             	add    $0x10,%esp
  803a4b:	85 c0                	test   %eax,%eax
  803a4d:	78 06                	js     803a55 <getchar+0x20>
	if (r < 1)
  803a4f:	74 06                	je     803a57 <getchar+0x22>
	return c;
  803a51:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  803a55:	c9                   	leave  
  803a56:	c3                   	ret    
		return -E_EOF;
  803a57:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  803a5c:	eb f7                	jmp    803a55 <getchar+0x20>

00803a5e <iscons>:
{
  803a5e:	55                   	push   %ebp
  803a5f:	89 e5                	mov    %esp,%ebp
  803a61:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803a64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a67:	50                   	push   %eax
  803a68:	ff 75 08             	push   0x8(%ebp)
  803a6b:	e8 99 ef ff ff       	call   802a09 <fd_lookup>
  803a70:	83 c4 10             	add    $0x10,%esp
  803a73:	85 c0                	test   %eax,%eax
  803a75:	78 11                	js     803a88 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  803a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a7a:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803a80:	39 10                	cmp    %edx,(%eax)
  803a82:	0f 94 c0             	sete   %al
  803a85:	0f b6 c0             	movzbl %al,%eax
}
  803a88:	c9                   	leave  
  803a89:	c3                   	ret    

00803a8a <opencons>:
{
  803a8a:	55                   	push   %ebp
  803a8b:	89 e5                	mov    %esp,%ebp
  803a8d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  803a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a93:	50                   	push   %eax
  803a94:	e8 20 ef ff ff       	call   8029b9 <fd_alloc>
  803a99:	83 c4 10             	add    $0x10,%esp
  803a9c:	85 c0                	test   %eax,%eax
  803a9e:	78 3a                	js     803ada <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803aa0:	83 ec 04             	sub    $0x4,%esp
  803aa3:	68 07 04 00 00       	push   $0x407
  803aa8:	ff 75 f4             	push   -0xc(%ebp)
  803aab:	6a 00                	push   $0x0
  803aad:	e8 ef ea ff ff       	call   8025a1 <sys_page_alloc>
  803ab2:	83 c4 10             	add    $0x10,%esp
  803ab5:	85 c0                	test   %eax,%eax
  803ab7:	78 21                	js     803ada <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  803ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803abc:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803ac2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803ac7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803ace:	83 ec 0c             	sub    $0xc,%esp
  803ad1:	50                   	push   %eax
  803ad2:	e8 bb ee ff ff       	call   802992 <fd2num>
  803ad7:	83 c4 10             	add    $0x10,%esp
}
  803ada:	c9                   	leave  
  803adb:	c3                   	ret    
  803adc:	66 90                	xchg   %ax,%ax
  803ade:	66 90                	xchg   %ax,%ax

00803ae0 <__udivdi3>:
  803ae0:	f3 0f 1e fb          	endbr32 
  803ae4:	55                   	push   %ebp
  803ae5:	57                   	push   %edi
  803ae6:	56                   	push   %esi
  803ae7:	53                   	push   %ebx
  803ae8:	83 ec 1c             	sub    $0x1c,%esp
  803aeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803aef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803af3:	8b 74 24 34          	mov    0x34(%esp),%esi
  803af7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  803afb:	85 c0                	test   %eax,%eax
  803afd:	75 19                	jne    803b18 <__udivdi3+0x38>
  803aff:	39 f3                	cmp    %esi,%ebx
  803b01:	76 4d                	jbe    803b50 <__udivdi3+0x70>
  803b03:	31 ff                	xor    %edi,%edi
  803b05:	89 e8                	mov    %ebp,%eax
  803b07:	89 f2                	mov    %esi,%edx
  803b09:	f7 f3                	div    %ebx
  803b0b:	89 fa                	mov    %edi,%edx
  803b0d:	83 c4 1c             	add    $0x1c,%esp
  803b10:	5b                   	pop    %ebx
  803b11:	5e                   	pop    %esi
  803b12:	5f                   	pop    %edi
  803b13:	5d                   	pop    %ebp
  803b14:	c3                   	ret    
  803b15:	8d 76 00             	lea    0x0(%esi),%esi
  803b18:	39 f0                	cmp    %esi,%eax
  803b1a:	76 14                	jbe    803b30 <__udivdi3+0x50>
  803b1c:	31 ff                	xor    %edi,%edi
  803b1e:	31 c0                	xor    %eax,%eax
  803b20:	89 fa                	mov    %edi,%edx
  803b22:	83 c4 1c             	add    $0x1c,%esp
  803b25:	5b                   	pop    %ebx
  803b26:	5e                   	pop    %esi
  803b27:	5f                   	pop    %edi
  803b28:	5d                   	pop    %ebp
  803b29:	c3                   	ret    
  803b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803b30:	0f bd f8             	bsr    %eax,%edi
  803b33:	83 f7 1f             	xor    $0x1f,%edi
  803b36:	75 48                	jne    803b80 <__udivdi3+0xa0>
  803b38:	39 f0                	cmp    %esi,%eax
  803b3a:	72 06                	jb     803b42 <__udivdi3+0x62>
  803b3c:	31 c0                	xor    %eax,%eax
  803b3e:	39 eb                	cmp    %ebp,%ebx
  803b40:	77 de                	ja     803b20 <__udivdi3+0x40>
  803b42:	b8 01 00 00 00       	mov    $0x1,%eax
  803b47:	eb d7                	jmp    803b20 <__udivdi3+0x40>
  803b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b50:	89 d9                	mov    %ebx,%ecx
  803b52:	85 db                	test   %ebx,%ebx
  803b54:	75 0b                	jne    803b61 <__udivdi3+0x81>
  803b56:	b8 01 00 00 00       	mov    $0x1,%eax
  803b5b:	31 d2                	xor    %edx,%edx
  803b5d:	f7 f3                	div    %ebx
  803b5f:	89 c1                	mov    %eax,%ecx
  803b61:	31 d2                	xor    %edx,%edx
  803b63:	89 f0                	mov    %esi,%eax
  803b65:	f7 f1                	div    %ecx
  803b67:	89 c6                	mov    %eax,%esi
  803b69:	89 e8                	mov    %ebp,%eax
  803b6b:	89 f7                	mov    %esi,%edi
  803b6d:	f7 f1                	div    %ecx
  803b6f:	89 fa                	mov    %edi,%edx
  803b71:	83 c4 1c             	add    $0x1c,%esp
  803b74:	5b                   	pop    %ebx
  803b75:	5e                   	pop    %esi
  803b76:	5f                   	pop    %edi
  803b77:	5d                   	pop    %ebp
  803b78:	c3                   	ret    
  803b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b80:	89 f9                	mov    %edi,%ecx
  803b82:	ba 20 00 00 00       	mov    $0x20,%edx
  803b87:	29 fa                	sub    %edi,%edx
  803b89:	d3 e0                	shl    %cl,%eax
  803b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b8f:	89 d1                	mov    %edx,%ecx
  803b91:	89 d8                	mov    %ebx,%eax
  803b93:	d3 e8                	shr    %cl,%eax
  803b95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803b99:	09 c1                	or     %eax,%ecx
  803b9b:	89 f0                	mov    %esi,%eax
  803b9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803ba1:	89 f9                	mov    %edi,%ecx
  803ba3:	d3 e3                	shl    %cl,%ebx
  803ba5:	89 d1                	mov    %edx,%ecx
  803ba7:	d3 e8                	shr    %cl,%eax
  803ba9:	89 f9                	mov    %edi,%ecx
  803bab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  803baf:	89 eb                	mov    %ebp,%ebx
  803bb1:	d3 e6                	shl    %cl,%esi
  803bb3:	89 d1                	mov    %edx,%ecx
  803bb5:	d3 eb                	shr    %cl,%ebx
  803bb7:	09 f3                	or     %esi,%ebx
  803bb9:	89 c6                	mov    %eax,%esi
  803bbb:	89 f2                	mov    %esi,%edx
  803bbd:	89 d8                	mov    %ebx,%eax
  803bbf:	f7 74 24 08          	divl   0x8(%esp)
  803bc3:	89 d6                	mov    %edx,%esi
  803bc5:	89 c3                	mov    %eax,%ebx
  803bc7:	f7 64 24 0c          	mull   0xc(%esp)
  803bcb:	39 d6                	cmp    %edx,%esi
  803bcd:	72 19                	jb     803be8 <__udivdi3+0x108>
  803bcf:	89 f9                	mov    %edi,%ecx
  803bd1:	d3 e5                	shl    %cl,%ebp
  803bd3:	39 c5                	cmp    %eax,%ebp
  803bd5:	73 04                	jae    803bdb <__udivdi3+0xfb>
  803bd7:	39 d6                	cmp    %edx,%esi
  803bd9:	74 0d                	je     803be8 <__udivdi3+0x108>
  803bdb:	89 d8                	mov    %ebx,%eax
  803bdd:	31 ff                	xor    %edi,%edi
  803bdf:	e9 3c ff ff ff       	jmp    803b20 <__udivdi3+0x40>
  803be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803be8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803beb:	31 ff                	xor    %edi,%edi
  803bed:	e9 2e ff ff ff       	jmp    803b20 <__udivdi3+0x40>
  803bf2:	66 90                	xchg   %ax,%ax
  803bf4:	66 90                	xchg   %ax,%ax
  803bf6:	66 90                	xchg   %ax,%ax
  803bf8:	66 90                	xchg   %ax,%ax
  803bfa:	66 90                	xchg   %ax,%ax
  803bfc:	66 90                	xchg   %ax,%ax
  803bfe:	66 90                	xchg   %ax,%ax

00803c00 <__umoddi3>:
  803c00:	f3 0f 1e fb          	endbr32 
  803c04:	55                   	push   %ebp
  803c05:	57                   	push   %edi
  803c06:	56                   	push   %esi
  803c07:	53                   	push   %ebx
  803c08:	83 ec 1c             	sub    $0x1c,%esp
  803c0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  803c0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803c13:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  803c17:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  803c1b:	89 f0                	mov    %esi,%eax
  803c1d:	89 da                	mov    %ebx,%edx
  803c1f:	85 ff                	test   %edi,%edi
  803c21:	75 15                	jne    803c38 <__umoddi3+0x38>
  803c23:	39 dd                	cmp    %ebx,%ebp
  803c25:	76 39                	jbe    803c60 <__umoddi3+0x60>
  803c27:	f7 f5                	div    %ebp
  803c29:	89 d0                	mov    %edx,%eax
  803c2b:	31 d2                	xor    %edx,%edx
  803c2d:	83 c4 1c             	add    $0x1c,%esp
  803c30:	5b                   	pop    %ebx
  803c31:	5e                   	pop    %esi
  803c32:	5f                   	pop    %edi
  803c33:	5d                   	pop    %ebp
  803c34:	c3                   	ret    
  803c35:	8d 76 00             	lea    0x0(%esi),%esi
  803c38:	39 df                	cmp    %ebx,%edi
  803c3a:	77 f1                	ja     803c2d <__umoddi3+0x2d>
  803c3c:	0f bd cf             	bsr    %edi,%ecx
  803c3f:	83 f1 1f             	xor    $0x1f,%ecx
  803c42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803c46:	75 40                	jne    803c88 <__umoddi3+0x88>
  803c48:	39 df                	cmp    %ebx,%edi
  803c4a:	72 04                	jb     803c50 <__umoddi3+0x50>
  803c4c:	39 f5                	cmp    %esi,%ebp
  803c4e:	77 dd                	ja     803c2d <__umoddi3+0x2d>
  803c50:	89 da                	mov    %ebx,%edx
  803c52:	89 f0                	mov    %esi,%eax
  803c54:	29 e8                	sub    %ebp,%eax
  803c56:	19 fa                	sbb    %edi,%edx
  803c58:	eb d3                	jmp    803c2d <__umoddi3+0x2d>
  803c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803c60:	89 e9                	mov    %ebp,%ecx
  803c62:	85 ed                	test   %ebp,%ebp
  803c64:	75 0b                	jne    803c71 <__umoddi3+0x71>
  803c66:	b8 01 00 00 00       	mov    $0x1,%eax
  803c6b:	31 d2                	xor    %edx,%edx
  803c6d:	f7 f5                	div    %ebp
  803c6f:	89 c1                	mov    %eax,%ecx
  803c71:	89 d8                	mov    %ebx,%eax
  803c73:	31 d2                	xor    %edx,%edx
  803c75:	f7 f1                	div    %ecx
  803c77:	89 f0                	mov    %esi,%eax
  803c79:	f7 f1                	div    %ecx
  803c7b:	89 d0                	mov    %edx,%eax
  803c7d:	31 d2                	xor    %edx,%edx
  803c7f:	eb ac                	jmp    803c2d <__umoddi3+0x2d>
  803c81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803c88:	8b 44 24 04          	mov    0x4(%esp),%eax
  803c8c:	ba 20 00 00 00       	mov    $0x20,%edx
  803c91:	29 c2                	sub    %eax,%edx
  803c93:	89 c1                	mov    %eax,%ecx
  803c95:	89 e8                	mov    %ebp,%eax
  803c97:	d3 e7                	shl    %cl,%edi
  803c99:	89 d1                	mov    %edx,%ecx
  803c9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803c9f:	d3 e8                	shr    %cl,%eax
  803ca1:	89 c1                	mov    %eax,%ecx
  803ca3:	8b 44 24 04          	mov    0x4(%esp),%eax
  803ca7:	09 f9                	or     %edi,%ecx
  803ca9:	89 df                	mov    %ebx,%edi
  803cab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803caf:	89 c1                	mov    %eax,%ecx
  803cb1:	d3 e5                	shl    %cl,%ebp
  803cb3:	89 d1                	mov    %edx,%ecx
  803cb5:	d3 ef                	shr    %cl,%edi
  803cb7:	89 c1                	mov    %eax,%ecx
  803cb9:	89 f0                	mov    %esi,%eax
  803cbb:	d3 e3                	shl    %cl,%ebx
  803cbd:	89 d1                	mov    %edx,%ecx
  803cbf:	89 fa                	mov    %edi,%edx
  803cc1:	d3 e8                	shr    %cl,%eax
  803cc3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803cc8:	09 d8                	or     %ebx,%eax
  803cca:	f7 74 24 08          	divl   0x8(%esp)
  803cce:	89 d3                	mov    %edx,%ebx
  803cd0:	d3 e6                	shl    %cl,%esi
  803cd2:	f7 e5                	mul    %ebp
  803cd4:	89 c7                	mov    %eax,%edi
  803cd6:	89 d1                	mov    %edx,%ecx
  803cd8:	39 d3                	cmp    %edx,%ebx
  803cda:	72 06                	jb     803ce2 <__umoddi3+0xe2>
  803cdc:	75 0e                	jne    803cec <__umoddi3+0xec>
  803cde:	39 c6                	cmp    %eax,%esi
  803ce0:	73 0a                	jae    803cec <__umoddi3+0xec>
  803ce2:	29 e8                	sub    %ebp,%eax
  803ce4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803ce8:	89 d1                	mov    %edx,%ecx
  803cea:	89 c7                	mov    %eax,%edi
  803cec:	89 f5                	mov    %esi,%ebp
  803cee:	8b 74 24 04          	mov    0x4(%esp),%esi
  803cf2:	29 fd                	sub    %edi,%ebp
  803cf4:	19 cb                	sbb    %ecx,%ebx
  803cf6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  803cfb:	89 d8                	mov    %ebx,%eax
  803cfd:	d3 e0                	shl    %cl,%eax
  803cff:	89 f1                	mov    %esi,%ecx
  803d01:	d3 ed                	shr    %cl,%ebp
  803d03:	d3 eb                	shr    %cl,%ebx
  803d05:	09 e8                	or     %ebp,%eax
  803d07:	89 da                	mov    %ebx,%edx
  803d09:	83 c4 1c             	add    $0x1c,%esp
  803d0c:	5b                   	pop    %ebx
  803d0d:	5e                   	pop    %esi
  803d0e:	5f                   	pop    %edi
  803d0f:	5d                   	pop    %ebp
  803d10:	c3                   	ret    
