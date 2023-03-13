
obj/user/testfile.debug：     文件格式 elf32-i386


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
  80002c:	e8 54 06 00 00       	call   800685 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 53 0d 00 00       	call   800d9a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 e9 13 00 00       	call   801442 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 86 13 00 00       	call   8013ee <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 0e 13 00 00       	call   801387 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 a0 23 80 00       	mov    $0x8023a0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 08                	je     8000a6 <umain+0x28>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	0f 88 e9 03 00 00    	js     80048f <umain+0x411>
		panic("serve_open /not-found: %e", r);
	else if (r >= 0)
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	0f 89 f3 03 00 00    	jns    8004a1 <umain+0x423>
		panic("serve_open /not-found succeeded!");

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b3:	b8 d5 23 80 00       	mov    $0x8023d5,%eax
  8000b8:	e8 76 ff ff ff       	call   800033 <xopen>
  8000bd:	85 c0                	test   %eax,%eax
  8000bf:	0f 88 f0 03 00 00    	js     8004b5 <umain+0x437>
		panic("serve_open /newmotd: %e", r);
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000c5:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000cc:	0f 85 f5 03 00 00    	jne    8004c7 <umain+0x449>
  8000d2:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000d9:	0f 85 e8 03 00 00    	jne    8004c7 <umain+0x449>
  8000df:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  8000e6:	0f 85 db 03 00 00    	jne    8004c7 <umain+0x449>
		panic("serve_open did not fill struct Fd correctly\n");
	cprintf("serve_open is good\n");
  8000ec:	83 ec 0c             	sub    $0xc,%esp
  8000ef:	68 f6 23 80 00       	push   $0x8023f6
  8000f4:	e8 c7 06 00 00       	call   8007c0 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000f9:	83 c4 08             	add    $0x8,%esp
  8000fc:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800102:	50                   	push   %eax
  800103:	68 00 c0 cc cc       	push   $0xccccc000
  800108:	ff 15 1c 30 80 00    	call   *0x80301c
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	0f 88 c2 03 00 00    	js     8004db <umain+0x45d>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	ff 35 00 30 80 00    	push   0x803000
  800122:	e8 38 0c 00 00       	call   800d5f <strlen>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80012d:	0f 85 ba 03 00 00    	jne    8004ed <umain+0x46f>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 18 24 80 00       	push   $0x802418
  80013b:	e8 80 06 00 00       	call   8007c0 <cprintf>

	memset(buf, 0, sizeof buf);
  800140:	83 c4 0c             	add    $0xc,%esp
  800143:	68 00 02 00 00       	push   $0x200
  800148:	6a 00                	push   $0x0
  80014a:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800150:	53                   	push   %ebx
  800151:	e8 94 0d 00 00       	call   800eea <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800156:	83 c4 0c             	add    $0xc,%esp
  800159:	68 00 02 00 00       	push   $0x200
  80015e:	53                   	push   %ebx
  80015f:	68 00 c0 cc cc       	push   $0xccccc000
  800164:	ff 15 10 30 80 00    	call   *0x803010
  80016a:	83 c4 10             	add    $0x10,%esp
  80016d:	85 c0                	test   %eax,%eax
  80016f:	0f 88 9d 03 00 00    	js     800512 <umain+0x494>
		panic("file_read: %e", r);
	if (strcmp(buf, msg) != 0)
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	ff 35 00 30 80 00    	push   0x803000
  80017e:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	e8 c1 0c 00 00       	call   800e4b <strcmp>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	85 c0                	test   %eax,%eax
  80018f:	0f 85 8f 03 00 00    	jne    800524 <umain+0x4a6>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	68 57 24 80 00       	push   $0x802457
  80019d:	e8 1e 06 00 00       	call   8007c0 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001a9:	ff 15 18 30 80 00    	call   *0x803018
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	85 c0                	test   %eax,%eax
  8001b4:	0f 88 7e 03 00 00    	js     800538 <umain+0x4ba>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	68 79 24 80 00       	push   $0x802479
  8001c2:	e8 f9 05 00 00       	call   8007c0 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8001c7:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8001cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cf:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8001d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d7:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8001dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001df:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8001e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	68 00 c0 cc cc       	push   $0xccccc000
  8001ef:	6a 00                	push   $0x0
  8001f1:	e8 25 10 00 00       	call   80121b <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	68 00 02 00 00       	push   $0x200
  8001fe:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800204:	50                   	push   %eax
  800205:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	ff 15 10 30 80 00    	call   *0x803010
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800215:	0f 85 2f 03 00 00    	jne    80054a <umain+0x4cc>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 8d 24 80 00       	push   $0x80248d
  800223:	e8 98 05 00 00       	call   8007c0 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800228:	ba 02 01 00 00       	mov    $0x102,%edx
  80022d:	b8 a3 24 80 00       	mov    $0x8024a3,%eax
  800232:	e8 fc fd ff ff       	call   800033 <xopen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	0f 88 1a 03 00 00    	js     80055c <umain+0x4de>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800242:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	ff 35 00 30 80 00    	push   0x803000
  800251:	e8 09 0b 00 00       	call   800d5f <strlen>
  800256:	83 c4 0c             	add    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	ff 35 00 30 80 00    	push   0x803000
  800260:	68 00 c0 cc cc       	push   $0xccccc000
  800265:	ff d3                	call   *%ebx
  800267:	89 c3                	mov    %eax,%ebx
  800269:	83 c4 04             	add    $0x4,%esp
  80026c:	ff 35 00 30 80 00    	push   0x803000
  800272:	e8 e8 0a 00 00       	call   800d5f <strlen>
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	39 d8                	cmp    %ebx,%eax
  80027c:	0f 85 ec 02 00 00    	jne    80056e <umain+0x4f0>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	68 d5 24 80 00       	push   $0x8024d5
  80028a:	e8 31 05 00 00       	call   8007c0 <cprintf>

	FVA->fd_offset = 0;
  80028f:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800296:	00 00 00 
	memset(buf, 0, sizeof buf);
  800299:	83 c4 0c             	add    $0xc,%esp
  80029c:	68 00 02 00 00       	push   $0x200
  8002a1:	6a 00                	push   $0x0
  8002a3:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002a9:	53                   	push   %ebx
  8002aa:	e8 3b 0c 00 00       	call   800eea <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002af:	83 c4 0c             	add    $0xc,%esp
  8002b2:	68 00 02 00 00       	push   $0x200
  8002b7:	53                   	push   %ebx
  8002b8:	68 00 c0 cc cc       	push   $0xccccc000
  8002bd:	ff 15 10 30 80 00    	call   *0x803010
  8002c3:	89 c3                	mov    %eax,%ebx
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	0f 88 b0 02 00 00    	js     800580 <umain+0x502>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 35 00 30 80 00    	push   0x803000
  8002d9:	e8 81 0a 00 00       	call   800d5f <strlen>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	39 d8                	cmp    %ebx,%eax
  8002e3:	0f 85 a9 02 00 00    	jne    800592 <umain+0x514>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 35 00 30 80 00    	push   0x803000
  8002f2:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002f8:	50                   	push   %eax
  8002f9:	e8 4d 0b 00 00       	call   800e4b <strcmp>
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	85 c0                	test   %eax,%eax
  800303:	0f 85 9b 02 00 00    	jne    8005a4 <umain+0x526>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	68 9c 26 80 00       	push   $0x80269c
  800311:	e8 aa 04 00 00       	call   8007c0 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800316:	83 c4 08             	add    $0x8,%esp
  800319:	6a 00                	push   $0x0
  80031b:	68 a0 23 80 00       	push   $0x8023a0
  800320:	e8 94 18 00 00       	call   801bb9 <open>
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80032b:	74 08                	je     800335 <umain+0x2b7>
  80032d:	85 c0                	test   %eax,%eax
  80032f:	0f 88 83 02 00 00    	js     8005b8 <umain+0x53a>
		panic("open /not-found: %e", r);
	else if (r >= 0)
  800335:	85 c0                	test   %eax,%eax
  800337:	0f 89 8d 02 00 00    	jns    8005ca <umain+0x54c>
		panic("open /not-found succeeded!");

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	6a 00                	push   $0x0
  800342:	68 d5 23 80 00       	push   $0x8023d5
  800347:	e8 6d 18 00 00       	call   801bb9 <open>
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	85 c0                	test   %eax,%eax
  800351:	0f 88 87 02 00 00    	js     8005de <umain+0x560>
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800357:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80035a:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800361:	0f 85 89 02 00 00    	jne    8005f0 <umain+0x572>
  800367:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  80036e:	0f 85 7c 02 00 00    	jne    8005f0 <umain+0x572>
  800374:	8b 98 08 00 00 d0    	mov    -0x2ffffff8(%eax),%ebx
  80037a:	85 db                	test   %ebx,%ebx
  80037c:	0f 85 6e 02 00 00    	jne    8005f0 <umain+0x572>
		panic("open did not fill struct Fd correctly\n");
	cprintf("open is good\n");
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 fc 23 80 00       	push   $0x8023fc
  80038a:	e8 31 04 00 00       	call   8007c0 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	68 01 01 00 00       	push   $0x101
  800397:	68 04 25 80 00       	push   $0x802504
  80039c:	e8 18 18 00 00       	call   801bb9 <open>
  8003a1:	89 c7                	mov    %eax,%edi
  8003a3:	83 c4 10             	add    $0x10,%esp
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	0f 88 56 02 00 00    	js     800604 <umain+0x586>
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
  8003ae:	83 ec 04             	sub    $0x4,%esp
  8003b1:	68 00 02 00 00       	push   $0x200
  8003b6:	6a 00                	push   $0x0
  8003b8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	e8 26 0b 00 00       	call   800eea <memset>
  8003c4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003c7:	89 de                	mov    %ebx,%esi
		*(int*)buf = i;
  8003c9:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8003cf:	83 ec 04             	sub    $0x4,%esp
  8003d2:	68 00 02 00 00       	push   $0x200
  8003d7:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	57                   	push   %edi
  8003df:	e8 40 14 00 00       	call   801824 <write>
  8003e4:	83 c4 10             	add    $0x10,%esp
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	0f 88 27 02 00 00    	js     800616 <umain+0x598>
  8003ef:	81 c6 00 02 00 00    	add    $0x200,%esi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003f5:	81 fe 00 e0 01 00    	cmp    $0x1e000,%esi
  8003fb:	75 cc                	jne    8003c9 <umain+0x34b>
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  8003fd:	83 ec 0c             	sub    $0xc,%esp
  800400:	57                   	push   %edi
  800401:	e8 14 12 00 00       	call   80161a <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800406:	83 c4 08             	add    $0x8,%esp
  800409:	6a 00                	push   $0x0
  80040b:	68 04 25 80 00       	push   $0x802504
  800410:	e8 a4 17 00 00       	call   801bb9 <open>
  800415:	89 c6                	mov    %eax,%esi
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	85 c0                	test   %eax,%eax
  80041c:	0f 88 0a 02 00 00    	js     80062c <umain+0x5ae>
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800422:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  800428:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80042e:	83 ec 04             	sub    $0x4,%esp
  800431:	68 00 02 00 00       	push   $0x200
  800436:	57                   	push   %edi
  800437:	56                   	push   %esi
  800438:	e8 a0 13 00 00       	call   8017dd <readn>
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	85 c0                	test   %eax,%eax
  800442:	0f 88 f6 01 00 00    	js     80063e <umain+0x5c0>
			panic("read /big@%d: %e", i, r);
		if (r != sizeof(buf))
  800448:	3d 00 02 00 00       	cmp    $0x200,%eax
  80044d:	0f 85 01 02 00 00    	jne    800654 <umain+0x5d6>
			panic("read /big from %d returned %d < %d bytes",
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800453:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  800459:	39 d8                	cmp    %ebx,%eax
  80045b:	0f 85 0e 02 00 00    	jne    80066f <umain+0x5f1>
  800461:	81 c3 00 02 00 00    	add    $0x200,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800467:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  80046d:	75 b9                	jne    800428 <umain+0x3aa>
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80046f:	83 ec 0c             	sub    $0xc,%esp
  800472:	56                   	push   %esi
  800473:	e8 a2 11 00 00       	call   80161a <close>
	cprintf("large file is good\n");
  800478:	c7 04 24 49 25 80 00 	movl   $0x802549,(%esp)
  80047f:	e8 3c 03 00 00       	call   8007c0 <cprintf>
}
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048a:	5b                   	pop    %ebx
  80048b:	5e                   	pop    %esi
  80048c:	5f                   	pop    %edi
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    
		panic("serve_open /not-found: %e", r);
  80048f:	50                   	push   %eax
  800490:	68 ab 23 80 00       	push   $0x8023ab
  800495:	6a 20                	push   $0x20
  800497:	68 c5 23 80 00       	push   $0x8023c5
  80049c:	e8 44 02 00 00       	call   8006e5 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	68 60 25 80 00       	push   $0x802560
  8004a9:	6a 22                	push   $0x22
  8004ab:	68 c5 23 80 00       	push   $0x8023c5
  8004b0:	e8 30 02 00 00       	call   8006e5 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b5:	50                   	push   %eax
  8004b6:	68 de 23 80 00       	push   $0x8023de
  8004bb:	6a 25                	push   $0x25
  8004bd:	68 c5 23 80 00       	push   $0x8023c5
  8004c2:	e8 1e 02 00 00       	call   8006e5 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004c7:	83 ec 04             	sub    $0x4,%esp
  8004ca:	68 84 25 80 00       	push   $0x802584
  8004cf:	6a 27                	push   $0x27
  8004d1:	68 c5 23 80 00       	push   $0x8023c5
  8004d6:	e8 0a 02 00 00       	call   8006e5 <_panic>
		panic("file_stat: %e", r);
  8004db:	50                   	push   %eax
  8004dc:	68 0a 24 80 00       	push   $0x80240a
  8004e1:	6a 2b                	push   $0x2b
  8004e3:	68 c5 23 80 00       	push   $0x8023c5
  8004e8:	e8 f8 01 00 00       	call   8006e5 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004ed:	83 ec 0c             	sub    $0xc,%esp
  8004f0:	ff 35 00 30 80 00    	push   0x803000
  8004f6:	e8 64 08 00 00       	call   800d5f <strlen>
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 75 cc             	push   -0x34(%ebp)
  800501:	68 b4 25 80 00       	push   $0x8025b4
  800506:	6a 2d                	push   $0x2d
  800508:	68 c5 23 80 00       	push   $0x8023c5
  80050d:	e8 d3 01 00 00       	call   8006e5 <_panic>
		panic("file_read: %e", r);
  800512:	50                   	push   %eax
  800513:	68 2b 24 80 00       	push   $0x80242b
  800518:	6a 32                	push   $0x32
  80051a:	68 c5 23 80 00       	push   $0x8023c5
  80051f:	e8 c1 01 00 00       	call   8006e5 <_panic>
		panic("file_read returned wrong data");
  800524:	83 ec 04             	sub    $0x4,%esp
  800527:	68 39 24 80 00       	push   $0x802439
  80052c:	6a 34                	push   $0x34
  80052e:	68 c5 23 80 00       	push   $0x8023c5
  800533:	e8 ad 01 00 00       	call   8006e5 <_panic>
		panic("file_close: %e", r);
  800538:	50                   	push   %eax
  800539:	68 6a 24 80 00       	push   $0x80246a
  80053e:	6a 38                	push   $0x38
  800540:	68 c5 23 80 00       	push   $0x8023c5
  800545:	e8 9b 01 00 00       	call   8006e5 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054a:	50                   	push   %eax
  80054b:	68 dc 25 80 00       	push   $0x8025dc
  800550:	6a 43                	push   $0x43
  800552:	68 c5 23 80 00       	push   $0x8023c5
  800557:	e8 89 01 00 00       	call   8006e5 <_panic>
		panic("serve_open /new-file: %e", r);
  80055c:	50                   	push   %eax
  80055d:	68 ad 24 80 00       	push   $0x8024ad
  800562:	6a 48                	push   $0x48
  800564:	68 c5 23 80 00       	push   $0x8023c5
  800569:	e8 77 01 00 00       	call   8006e5 <_panic>
		panic("file_write: %e", r);
  80056e:	53                   	push   %ebx
  80056f:	68 c6 24 80 00       	push   $0x8024c6
  800574:	6a 4b                	push   $0x4b
  800576:	68 c5 23 80 00       	push   $0x8023c5
  80057b:	e8 65 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write: %e", r);
  800580:	50                   	push   %eax
  800581:	68 14 26 80 00       	push   $0x802614
  800586:	6a 51                	push   $0x51
  800588:	68 c5 23 80 00       	push   $0x8023c5
  80058d:	e8 53 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800592:	53                   	push   %ebx
  800593:	68 34 26 80 00       	push   $0x802634
  800598:	6a 53                	push   $0x53
  80059a:	68 c5 23 80 00       	push   $0x8023c5
  80059f:	e8 41 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	68 6c 26 80 00       	push   $0x80266c
  8005ac:	6a 55                	push   $0x55
  8005ae:	68 c5 23 80 00       	push   $0x8023c5
  8005b3:	e8 2d 01 00 00       	call   8006e5 <_panic>
		panic("open /not-found: %e", r);
  8005b8:	50                   	push   %eax
  8005b9:	68 b1 23 80 00       	push   $0x8023b1
  8005be:	6a 5a                	push   $0x5a
  8005c0:	68 c5 23 80 00       	push   $0x8023c5
  8005c5:	e8 1b 01 00 00       	call   8006e5 <_panic>
		panic("open /not-found succeeded!");
  8005ca:	83 ec 04             	sub    $0x4,%esp
  8005cd:	68 e9 24 80 00       	push   $0x8024e9
  8005d2:	6a 5c                	push   $0x5c
  8005d4:	68 c5 23 80 00       	push   $0x8023c5
  8005d9:	e8 07 01 00 00       	call   8006e5 <_panic>
		panic("open /newmotd: %e", r);
  8005de:	50                   	push   %eax
  8005df:	68 e4 23 80 00       	push   $0x8023e4
  8005e4:	6a 5f                	push   $0x5f
  8005e6:	68 c5 23 80 00       	push   $0x8023c5
  8005eb:	e8 f5 00 00 00       	call   8006e5 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f0:	83 ec 04             	sub    $0x4,%esp
  8005f3:	68 c0 26 80 00       	push   $0x8026c0
  8005f8:	6a 62                	push   $0x62
  8005fa:	68 c5 23 80 00       	push   $0x8023c5
  8005ff:	e8 e1 00 00 00       	call   8006e5 <_panic>
		panic("creat /big: %e", f);
  800604:	50                   	push   %eax
  800605:	68 09 25 80 00       	push   $0x802509
  80060a:	6a 67                	push   $0x67
  80060c:	68 c5 23 80 00       	push   $0x8023c5
  800611:	e8 cf 00 00 00       	call   8006e5 <_panic>
			panic("write /big@%d: %e", i, r);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	50                   	push   %eax
  80061a:	56                   	push   %esi
  80061b:	68 18 25 80 00       	push   $0x802518
  800620:	6a 6c                	push   $0x6c
  800622:	68 c5 23 80 00       	push   $0x8023c5
  800627:	e8 b9 00 00 00       	call   8006e5 <_panic>
		panic("open /big: %e", f);
  80062c:	50                   	push   %eax
  80062d:	68 2a 25 80 00       	push   $0x80252a
  800632:	6a 71                	push   $0x71
  800634:	68 c5 23 80 00       	push   $0x8023c5
  800639:	e8 a7 00 00 00       	call   8006e5 <_panic>
			panic("read /big@%d: %e", i, r);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	68 38 25 80 00       	push   $0x802538
  800648:	6a 75                	push   $0x75
  80064a:	68 c5 23 80 00       	push   $0x8023c5
  80064f:	e8 91 00 00 00       	call   8006e5 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	68 00 02 00 00       	push   $0x200
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	68 e8 26 80 00       	push   $0x8026e8
  800663:	6a 77                	push   $0x77
  800665:	68 c5 23 80 00       	push   $0x8023c5
  80066a:	e8 76 00 00 00       	call   8006e5 <_panic>
			panic("read /big from %d returned bad data %d",
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	50                   	push   %eax
  800673:	53                   	push   %ebx
  800674:	68 14 27 80 00       	push   $0x802714
  800679:	6a 7a                	push   $0x7a
  80067b:	68 c5 23 80 00       	push   $0x8023c5
  800680:	e8 60 00 00 00       	call   8006e5 <_panic>

00800685 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80068d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800690:	e8 c3 0a 00 00       	call   801158 <sys_getenvid>
  800695:	25 ff 03 00 00       	and    $0x3ff,%eax
  80069a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80069d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006a2:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006a7:	85 db                	test   %ebx,%ebx
  8006a9:	7e 07                	jle    8006b2 <libmain+0x2d>
		binaryname = argv[0];
  8006ab:	8b 06                	mov    (%esi),%eax
  8006ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	56                   	push   %esi
  8006b6:	53                   	push   %ebx
  8006b7:	e8 c2 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006bc:	e8 0a 00 00 00       	call   8006cb <exit>
}
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006d1:	e8 71 0f 00 00       	call   801647 <close_all>
	sys_env_destroy(0);
  8006d6:	83 ec 0c             	sub    $0xc,%esp
  8006d9:	6a 00                	push   $0x0
  8006db:	e8 37 0a 00 00       	call   801117 <sys_env_destroy>
}
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8006f3:	e8 60 0a 00 00       	call   801158 <sys_getenvid>
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	ff 75 0c             	push   0xc(%ebp)
  8006fe:	ff 75 08             	push   0x8(%ebp)
  800701:	56                   	push   %esi
  800702:	50                   	push   %eax
  800703:	68 6c 27 80 00       	push   $0x80276c
  800708:	e8 b3 00 00 00       	call   8007c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80070d:	83 c4 18             	add    $0x18,%esp
  800710:	53                   	push   %ebx
  800711:	ff 75 10             	push   0x10(%ebp)
  800714:	e8 56 00 00 00       	call   80076f <vcprintf>
	cprintf("\n");
  800719:	c7 04 24 bf 2b 80 00 	movl   $0x802bbf,(%esp)
  800720:	e8 9b 00 00 00       	call   8007c0 <cprintf>
  800725:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800728:	cc                   	int3   
  800729:	eb fd                	jmp    800728 <_panic+0x43>

0080072b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	83 ec 04             	sub    $0x4,%esp
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800735:	8b 13                	mov    (%ebx),%edx
  800737:	8d 42 01             	lea    0x1(%edx),%eax
  80073a:	89 03                	mov    %eax,(%ebx)
  80073c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800743:	3d ff 00 00 00       	cmp    $0xff,%eax
  800748:	74 09                	je     800753 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80074a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	68 ff 00 00 00       	push   $0xff
  80075b:	8d 43 08             	lea    0x8(%ebx),%eax
  80075e:	50                   	push   %eax
  80075f:	e8 76 09 00 00       	call   8010da <sys_cputs>
		b->idx = 0;
  800764:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb db                	jmp    80074a <putch+0x1f>

0080076f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800778:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80077f:	00 00 00 
	b.cnt = 0;
  800782:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800789:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80078c:	ff 75 0c             	push   0xc(%ebp)
  80078f:	ff 75 08             	push   0x8(%ebp)
  800792:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800798:	50                   	push   %eax
  800799:	68 2b 07 80 00       	push   $0x80072b
  80079e:	e8 14 01 00 00       	call   8008b7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8007ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	e8 22 09 00 00       	call   8010da <sys_cputs>

	return b.cnt;
}
  8007b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 08             	push   0x8(%ebp)
  8007cd:	e8 9d ff ff ff       	call   80076f <vcprintf>
	va_end(ap);

	return cnt;
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	57                   	push   %edi
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	83 ec 1c             	sub    $0x1c,%esp
  8007dd:	89 c7                	mov    %eax,%edi
  8007df:	89 d6                	mov    %edx,%esi
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e7:	89 d1                	mov    %edx,%ecx
  8007e9:	89 c2                	mov    %eax,%edx
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800801:	39 c2                	cmp    %eax,%edx
  800803:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800806:	72 3e                	jb     800846 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800808:	83 ec 0c             	sub    $0xc,%esp
  80080b:	ff 75 18             	push   0x18(%ebp)
  80080e:	83 eb 01             	sub    $0x1,%ebx
  800811:	53                   	push   %ebx
  800812:	50                   	push   %eax
  800813:	83 ec 08             	sub    $0x8,%esp
  800816:	ff 75 e4             	push   -0x1c(%ebp)
  800819:	ff 75 e0             	push   -0x20(%ebp)
  80081c:	ff 75 dc             	push   -0x24(%ebp)
  80081f:	ff 75 d8             	push   -0x28(%ebp)
  800822:	e8 39 19 00 00       	call   802160 <__udivdi3>
  800827:	83 c4 18             	add    $0x18,%esp
  80082a:	52                   	push   %edx
  80082b:	50                   	push   %eax
  80082c:	89 f2                	mov    %esi,%edx
  80082e:	89 f8                	mov    %edi,%eax
  800830:	e8 9f ff ff ff       	call   8007d4 <printnum>
  800835:	83 c4 20             	add    $0x20,%esp
  800838:	eb 13                	jmp    80084d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	56                   	push   %esi
  80083e:	ff 75 18             	push   0x18(%ebp)
  800841:	ff d7                	call   *%edi
  800843:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800846:	83 eb 01             	sub    $0x1,%ebx
  800849:	85 db                	test   %ebx,%ebx
  80084b:	7f ed                	jg     80083a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	56                   	push   %esi
  800851:	83 ec 04             	sub    $0x4,%esp
  800854:	ff 75 e4             	push   -0x1c(%ebp)
  800857:	ff 75 e0             	push   -0x20(%ebp)
  80085a:	ff 75 dc             	push   -0x24(%ebp)
  80085d:	ff 75 d8             	push   -0x28(%ebp)
  800860:	e8 1b 1a 00 00       	call   802280 <__umoddi3>
  800865:	83 c4 14             	add    $0x14,%esp
  800868:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
  80086f:	50                   	push   %eax
  800870:	ff d7                	call   *%edi
}
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5f                   	pop    %edi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800883:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800887:	8b 10                	mov    (%eax),%edx
  800889:	3b 50 04             	cmp    0x4(%eax),%edx
  80088c:	73 0a                	jae    800898 <sprintputch+0x1b>
		*b->buf++ = ch;
  80088e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800891:	89 08                	mov    %ecx,(%eax)
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	88 02                	mov    %al,(%edx)
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <printfmt>:
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a3:	50                   	push   %eax
  8008a4:	ff 75 10             	push   0x10(%ebp)
  8008a7:	ff 75 0c             	push   0xc(%ebp)
  8008aa:	ff 75 08             	push   0x8(%ebp)
  8008ad:	e8 05 00 00 00       	call   8008b7 <vprintfmt>
}
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <vprintfmt>:
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 3c             	sub    $0x3c,%esp
  8008c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008c9:	eb 0a                	jmp    8008d5 <vprintfmt+0x1e>
			putch(ch, putdat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	50                   	push   %eax
  8008d0:	ff d6                	call   *%esi
  8008d2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d5:	83 c7 01             	add    $0x1,%edi
  8008d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008dc:	83 f8 25             	cmp    $0x25,%eax
  8008df:	74 0c                	je     8008ed <vprintfmt+0x36>
			if (ch == '\0')
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	75 e6                	jne    8008cb <vprintfmt+0x14>
}
  8008e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5f                   	pop    %edi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    
		padc = ' ';
  8008ed:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8008f1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8008f8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8008ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800906:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8d 47 01             	lea    0x1(%edi),%eax
  80090e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800911:	0f b6 17             	movzbl (%edi),%edx
  800914:	8d 42 dd             	lea    -0x23(%edx),%eax
  800917:	3c 55                	cmp    $0x55,%al
  800919:	0f 87 bb 03 00 00    	ja     800cda <vprintfmt+0x423>
  80091f:	0f b6 c0             	movzbl %al,%eax
  800922:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80092c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800930:	eb d9                	jmp    80090b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800932:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800935:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800939:	eb d0                	jmp    80090b <vprintfmt+0x54>
  80093b:	0f b6 d2             	movzbl %dl,%edx
  80093e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
  800946:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800949:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80094c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800950:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800953:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800956:	83 f9 09             	cmp    $0x9,%ecx
  800959:	77 55                	ja     8009b0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80095b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80095e:	eb e9                	jmp    800949 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8b 00                	mov    (%eax),%eax
  800965:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	8d 40 04             	lea    0x4(%eax),%eax
  80096e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800971:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800974:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800978:	79 91                	jns    80090b <vprintfmt+0x54>
				width = precision, precision = -1;
  80097a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80097d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800980:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800987:	eb 82                	jmp    80090b <vprintfmt+0x54>
  800989:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80098c:	85 d2                	test   %edx,%edx
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
  800993:	0f 49 c2             	cmovns %edx,%eax
  800996:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800999:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80099c:	e9 6a ff ff ff       	jmp    80090b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8009a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8009a4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8009ab:	e9 5b ff ff ff       	jmp    80090b <vprintfmt+0x54>
  8009b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b6:	eb bc                	jmp    800974 <vprintfmt+0xbd>
			lflag++;
  8009b8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8009bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8009be:	e9 48 ff ff ff       	jmp    80090b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 78 04             	lea    0x4(%eax),%edi
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	53                   	push   %ebx
  8009cd:	ff 30                	push   (%eax)
  8009cf:	ff d6                	call   *%esi
			break;
  8009d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8009d4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8009d7:	e9 9d 02 00 00       	jmp    800c79 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8009dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009df:	8d 78 04             	lea    0x4(%eax),%edi
  8009e2:	8b 10                	mov    (%eax),%edx
  8009e4:	89 d0                	mov    %edx,%eax
  8009e6:	f7 d8                	neg    %eax
  8009e8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009eb:	83 f8 0f             	cmp    $0xf,%eax
  8009ee:	7f 23                	jg     800a13 <vprintfmt+0x15c>
  8009f0:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  8009f7:	85 d2                	test   %edx,%edx
  8009f9:	74 18                	je     800a13 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8009fb:	52                   	push   %edx
  8009fc:	68 8d 2b 80 00       	push   $0x802b8d
  800a01:	53                   	push   %ebx
  800a02:	56                   	push   %esi
  800a03:	e8 92 fe ff ff       	call   80089a <printfmt>
  800a08:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a0b:	89 7d 14             	mov    %edi,0x14(%ebp)
  800a0e:	e9 66 02 00 00       	jmp    800c79 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800a13:	50                   	push   %eax
  800a14:	68 a7 27 80 00       	push   $0x8027a7
  800a19:	53                   	push   %ebx
  800a1a:	56                   	push   %esi
  800a1b:	e8 7a fe ff ff       	call   80089a <printfmt>
  800a20:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a23:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800a26:	e9 4e 02 00 00       	jmp    800c79 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2e:	83 c0 04             	add    $0x4,%eax
  800a31:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800a34:	8b 45 14             	mov    0x14(%ebp),%eax
  800a37:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800a39:	85 d2                	test   %edx,%edx
  800a3b:	b8 a0 27 80 00       	mov    $0x8027a0,%eax
  800a40:	0f 45 c2             	cmovne %edx,%eax
  800a43:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800a46:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a4a:	7e 06                	jle    800a52 <vprintfmt+0x19b>
  800a4c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800a50:	75 0d                	jne    800a5f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a52:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	03 45 e0             	add    -0x20(%ebp),%eax
  800a5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a5d:	eb 55                	jmp    800ab4 <vprintfmt+0x1fd>
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	ff 75 d8             	push   -0x28(%ebp)
  800a65:	ff 75 cc             	push   -0x34(%ebp)
  800a68:	e8 0a 03 00 00       	call   800d77 <strnlen>
  800a6d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a70:	29 c1                	sub    %eax,%ecx
  800a72:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800a7a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800a81:	eb 0f                	jmp    800a92 <vprintfmt+0x1db>
					putch(padc, putdat);
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	53                   	push   %ebx
  800a87:	ff 75 e0             	push   -0x20(%ebp)
  800a8a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a8c:	83 ef 01             	sub    $0x1,%edi
  800a8f:	83 c4 10             	add    $0x10,%esp
  800a92:	85 ff                	test   %edi,%edi
  800a94:	7f ed                	jg     800a83 <vprintfmt+0x1cc>
  800a96:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a99:	85 d2                	test   %edx,%edx
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	0f 49 c2             	cmovns %edx,%eax
  800aa3:	29 c2                	sub    %eax,%edx
  800aa5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aa8:	eb a8                	jmp    800a52 <vprintfmt+0x19b>
					putch(ch, putdat);
  800aaa:	83 ec 08             	sub    $0x8,%esp
  800aad:	53                   	push   %ebx
  800aae:	52                   	push   %edx
  800aaf:	ff d6                	call   *%esi
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ab7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab9:	83 c7 01             	add    $0x1,%edi
  800abc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ac0:	0f be d0             	movsbl %al,%edx
  800ac3:	85 d2                	test   %edx,%edx
  800ac5:	74 4b                	je     800b12 <vprintfmt+0x25b>
  800ac7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800acb:	78 06                	js     800ad3 <vprintfmt+0x21c>
  800acd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800ad1:	78 1e                	js     800af1 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800ad3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ad7:	74 d1                	je     800aaa <vprintfmt+0x1f3>
  800ad9:	0f be c0             	movsbl %al,%eax
  800adc:	83 e8 20             	sub    $0x20,%eax
  800adf:	83 f8 5e             	cmp    $0x5e,%eax
  800ae2:	76 c6                	jbe    800aaa <vprintfmt+0x1f3>
					putch('?', putdat);
  800ae4:	83 ec 08             	sub    $0x8,%esp
  800ae7:	53                   	push   %ebx
  800ae8:	6a 3f                	push   $0x3f
  800aea:	ff d6                	call   *%esi
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	eb c3                	jmp    800ab4 <vprintfmt+0x1fd>
  800af1:	89 cf                	mov    %ecx,%edi
  800af3:	eb 0e                	jmp    800b03 <vprintfmt+0x24c>
				putch(' ', putdat);
  800af5:	83 ec 08             	sub    $0x8,%esp
  800af8:	53                   	push   %ebx
  800af9:	6a 20                	push   $0x20
  800afb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800afd:	83 ef 01             	sub    $0x1,%edi
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	85 ff                	test   %edi,%edi
  800b05:	7f ee                	jg     800af5 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800b07:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800b0a:	89 45 14             	mov    %eax,0x14(%ebp)
  800b0d:	e9 67 01 00 00       	jmp    800c79 <vprintfmt+0x3c2>
  800b12:	89 cf                	mov    %ecx,%edi
  800b14:	eb ed                	jmp    800b03 <vprintfmt+0x24c>
	if (lflag >= 2)
  800b16:	83 f9 01             	cmp    $0x1,%ecx
  800b19:	7f 1b                	jg     800b36 <vprintfmt+0x27f>
	else if (lflag)
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	74 63                	je     800b82 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	8b 00                	mov    (%eax),%eax
  800b24:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b27:	99                   	cltd   
  800b28:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8d 40 04             	lea    0x4(%eax),%eax
  800b31:	89 45 14             	mov    %eax,0x14(%ebp)
  800b34:	eb 17                	jmp    800b4d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8b 50 04             	mov    0x4(%eax),%edx
  800b3c:	8b 00                	mov    (%eax),%eax
  800b3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b41:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b44:	8b 45 14             	mov    0x14(%ebp),%eax
  800b47:	8d 40 08             	lea    0x8(%eax),%eax
  800b4a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800b4d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b50:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800b53:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800b58:	85 c9                	test   %ecx,%ecx
  800b5a:	0f 89 ff 00 00 00    	jns    800c5f <vprintfmt+0x3a8>
				putch('-', putdat);
  800b60:	83 ec 08             	sub    $0x8,%esp
  800b63:	53                   	push   %ebx
  800b64:	6a 2d                	push   $0x2d
  800b66:	ff d6                	call   *%esi
				num = -(long long) num;
  800b68:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b6e:	f7 da                	neg    %edx
  800b70:	83 d1 00             	adc    $0x0,%ecx
  800b73:	f7 d9                	neg    %ecx
  800b75:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b78:	bf 0a 00 00 00       	mov    $0xa,%edi
  800b7d:	e9 dd 00 00 00       	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800b82:	8b 45 14             	mov    0x14(%ebp),%eax
  800b85:	8b 00                	mov    (%eax),%eax
  800b87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8a:	99                   	cltd   
  800b8b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b91:	8d 40 04             	lea    0x4(%eax),%eax
  800b94:	89 45 14             	mov    %eax,0x14(%ebp)
  800b97:	eb b4                	jmp    800b4d <vprintfmt+0x296>
	if (lflag >= 2)
  800b99:	83 f9 01             	cmp    $0x1,%ecx
  800b9c:	7f 1e                	jg     800bbc <vprintfmt+0x305>
	else if (lflag)
  800b9e:	85 c9                	test   %ecx,%ecx
  800ba0:	74 32                	je     800bd4 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800ba2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba5:	8b 10                	mov    (%eax),%edx
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8d 40 04             	lea    0x4(%eax),%eax
  800baf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bb2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800bb7:	e9 a3 00 00 00       	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	8b 48 04             	mov    0x4(%eax),%ecx
  800bc4:	8d 40 08             	lea    0x8(%eax),%eax
  800bc7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bca:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800bcf:	e9 8b 00 00 00       	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800bd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd7:	8b 10                	mov    (%eax),%edx
  800bd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bde:	8d 40 04             	lea    0x4(%eax),%eax
  800be1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800be4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800be9:	eb 74                	jmp    800c5f <vprintfmt+0x3a8>
	if (lflag >= 2)
  800beb:	83 f9 01             	cmp    $0x1,%ecx
  800bee:	7f 1b                	jg     800c0b <vprintfmt+0x354>
	else if (lflag)
  800bf0:	85 c9                	test   %ecx,%ecx
  800bf2:	74 2c                	je     800c20 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800bf4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf7:	8b 10                	mov    (%eax),%edx
  800bf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfe:	8d 40 04             	lea    0x4(%eax),%eax
  800c01:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c04:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800c09:	eb 54                	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800c0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0e:	8b 10                	mov    (%eax),%edx
  800c10:	8b 48 04             	mov    0x4(%eax),%ecx
  800c13:	8d 40 08             	lea    0x8(%eax),%eax
  800c16:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c19:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800c1e:	eb 3f                	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800c20:	8b 45 14             	mov    0x14(%ebp),%eax
  800c23:	8b 10                	mov    (%eax),%edx
  800c25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2a:	8d 40 04             	lea    0x4(%eax),%eax
  800c2d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c30:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800c35:	eb 28                	jmp    800c5f <vprintfmt+0x3a8>
			putch('0', putdat);
  800c37:	83 ec 08             	sub    $0x8,%esp
  800c3a:	53                   	push   %ebx
  800c3b:	6a 30                	push   $0x30
  800c3d:	ff d6                	call   *%esi
			putch('x', putdat);
  800c3f:	83 c4 08             	add    $0x8,%esp
  800c42:	53                   	push   %ebx
  800c43:	6a 78                	push   $0x78
  800c45:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c47:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4a:	8b 10                	mov    (%eax),%edx
  800c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c51:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800c54:	8d 40 04             	lea    0x4(%eax),%eax
  800c57:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c5a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800c66:	50                   	push   %eax
  800c67:	ff 75 e0             	push   -0x20(%ebp)
  800c6a:	57                   	push   %edi
  800c6b:	51                   	push   %ecx
  800c6c:	52                   	push   %edx
  800c6d:	89 da                	mov    %ebx,%edx
  800c6f:	89 f0                	mov    %esi,%eax
  800c71:	e8 5e fb ff ff       	call   8007d4 <printnum>
			break;
  800c76:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800c79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c7c:	e9 54 fc ff ff       	jmp    8008d5 <vprintfmt+0x1e>
	if (lflag >= 2)
  800c81:	83 f9 01             	cmp    $0x1,%ecx
  800c84:	7f 1b                	jg     800ca1 <vprintfmt+0x3ea>
	else if (lflag)
  800c86:	85 c9                	test   %ecx,%ecx
  800c88:	74 2c                	je     800cb6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800c8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8d:	8b 10                	mov    (%eax),%edx
  800c8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c94:	8d 40 04             	lea    0x4(%eax),%eax
  800c97:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c9a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800c9f:	eb be                	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800ca1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca4:	8b 10                	mov    (%eax),%edx
  800ca6:	8b 48 04             	mov    0x4(%eax),%ecx
  800ca9:	8d 40 08             	lea    0x8(%eax),%eax
  800cac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800caf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800cb4:	eb a9                	jmp    800c5f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800cb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb9:	8b 10                	mov    (%eax),%edx
  800cbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc0:	8d 40 04             	lea    0x4(%eax),%eax
  800cc3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cc6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800ccb:	eb 92                	jmp    800c5f <vprintfmt+0x3a8>
			putch(ch, putdat);
  800ccd:	83 ec 08             	sub    $0x8,%esp
  800cd0:	53                   	push   %ebx
  800cd1:	6a 25                	push   $0x25
  800cd3:	ff d6                	call   *%esi
			break;
  800cd5:	83 c4 10             	add    $0x10,%esp
  800cd8:	eb 9f                	jmp    800c79 <vprintfmt+0x3c2>
			putch('%', putdat);
  800cda:	83 ec 08             	sub    $0x8,%esp
  800cdd:	53                   	push   %ebx
  800cde:	6a 25                	push   $0x25
  800ce0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ce2:	83 c4 10             	add    $0x10,%esp
  800ce5:	89 f8                	mov    %edi,%eax
  800ce7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800ceb:	74 05                	je     800cf2 <vprintfmt+0x43b>
  800ced:	83 e8 01             	sub    $0x1,%eax
  800cf0:	eb f5                	jmp    800ce7 <vprintfmt+0x430>
  800cf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cf5:	eb 82                	jmp    800c79 <vprintfmt+0x3c2>

00800cf7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 18             	sub    $0x18,%esp
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d03:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d06:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	74 26                	je     800d3e <vsnprintf+0x47>
  800d18:	85 d2                	test   %edx,%edx
  800d1a:	7e 22                	jle    800d3e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d1c:	ff 75 14             	push   0x14(%ebp)
  800d1f:	ff 75 10             	push   0x10(%ebp)
  800d22:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	68 7d 08 80 00       	push   $0x80087d
  800d2b:	e8 87 fb ff ff       	call   8008b7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d33:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d39:	83 c4 10             	add    $0x10,%esp
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    
		return -E_INVAL;
  800d3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d43:	eb f7                	jmp    800d3c <vsnprintf+0x45>

00800d45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d4b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d4e:	50                   	push   %eax
  800d4f:	ff 75 10             	push   0x10(%ebp)
  800d52:	ff 75 0c             	push   0xc(%ebp)
  800d55:	ff 75 08             	push   0x8(%ebp)
  800d58:	e8 9a ff ff ff       	call   800cf7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d65:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6a:	eb 03                	jmp    800d6f <strlen+0x10>
		n++;
  800d6c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800d6f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d73:	75 f7                	jne    800d6c <strlen+0xd>
	return n;
}
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d80:	b8 00 00 00 00       	mov    $0x0,%eax
  800d85:	eb 03                	jmp    800d8a <strnlen+0x13>
		n++;
  800d87:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d8a:	39 d0                	cmp    %edx,%eax
  800d8c:	74 08                	je     800d96 <strnlen+0x1f>
  800d8e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d92:	75 f3                	jne    800d87 <strnlen+0x10>
  800d94:	89 c2                	mov    %eax,%edx
	return n;
}
  800d96:	89 d0                	mov    %edx,%eax
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	53                   	push   %ebx
  800d9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
  800da9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800dad:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800db0:	83 c0 01             	add    $0x1,%eax
  800db3:	84 d2                	test   %dl,%dl
  800db5:	75 f2                	jne    800da9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800db7:	89 c8                	mov    %ecx,%eax
  800db9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbc:	c9                   	leave  
  800dbd:	c3                   	ret    

00800dbe <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 10             	sub    $0x10,%esp
  800dc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dc8:	53                   	push   %ebx
  800dc9:	e8 91 ff ff ff       	call   800d5f <strlen>
  800dce:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800dd1:	ff 75 0c             	push   0xc(%ebp)
  800dd4:	01 d8                	add    %ebx,%eax
  800dd6:	50                   	push   %eax
  800dd7:	e8 be ff ff ff       	call   800d9a <strcpy>
	return dst;
}
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    

00800de3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	8b 75 08             	mov    0x8(%ebp),%esi
  800deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dee:	89 f3                	mov    %esi,%ebx
  800df0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df3:	89 f0                	mov    %esi,%eax
  800df5:	eb 0f                	jmp    800e06 <strncpy+0x23>
		*dst++ = *src;
  800df7:	83 c0 01             	add    $0x1,%eax
  800dfa:	0f b6 0a             	movzbl (%edx),%ecx
  800dfd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e00:	80 f9 01             	cmp    $0x1,%cl
  800e03:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800e06:	39 d8                	cmp    %ebx,%eax
  800e08:	75 ed                	jne    800df7 <strncpy+0x14>
	}
	return ret;
}
  800e0a:	89 f0                	mov    %esi,%eax
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	8b 75 08             	mov    0x8(%ebp),%esi
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 10             	mov    0x10(%ebp),%edx
  800e1e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e20:	85 d2                	test   %edx,%edx
  800e22:	74 21                	je     800e45 <strlcpy+0x35>
  800e24:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e28:	89 f2                	mov    %esi,%edx
  800e2a:	eb 09                	jmp    800e35 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e2c:	83 c1 01             	add    $0x1,%ecx
  800e2f:	83 c2 01             	add    $0x1,%edx
  800e32:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800e35:	39 c2                	cmp    %eax,%edx
  800e37:	74 09                	je     800e42 <strlcpy+0x32>
  800e39:	0f b6 19             	movzbl (%ecx),%ebx
  800e3c:	84 db                	test   %bl,%bl
  800e3e:	75 ec                	jne    800e2c <strlcpy+0x1c>
  800e40:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800e42:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e45:	29 f0                	sub    %esi,%eax
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e51:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e54:	eb 06                	jmp    800e5c <strcmp+0x11>
		p++, q++;
  800e56:	83 c1 01             	add    $0x1,%ecx
  800e59:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800e5c:	0f b6 01             	movzbl (%ecx),%eax
  800e5f:	84 c0                	test   %al,%al
  800e61:	74 04                	je     800e67 <strcmp+0x1c>
  800e63:	3a 02                	cmp    (%edx),%al
  800e65:	74 ef                	je     800e56 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e67:	0f b6 c0             	movzbl %al,%eax
  800e6a:	0f b6 12             	movzbl (%edx),%edx
  800e6d:	29 d0                	sub    %edx,%eax
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	53                   	push   %ebx
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7b:	89 c3                	mov    %eax,%ebx
  800e7d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e80:	eb 06                	jmp    800e88 <strncmp+0x17>
		n--, p++, q++;
  800e82:	83 c0 01             	add    $0x1,%eax
  800e85:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e88:	39 d8                	cmp    %ebx,%eax
  800e8a:	74 18                	je     800ea4 <strncmp+0x33>
  800e8c:	0f b6 08             	movzbl (%eax),%ecx
  800e8f:	84 c9                	test   %cl,%cl
  800e91:	74 04                	je     800e97 <strncmp+0x26>
  800e93:	3a 0a                	cmp    (%edx),%cl
  800e95:	74 eb                	je     800e82 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e97:	0f b6 00             	movzbl (%eax),%eax
  800e9a:	0f b6 12             	movzbl (%edx),%edx
  800e9d:	29 d0                	sub    %edx,%eax
}
  800e9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    
		return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	eb f4                	jmp    800e9f <strncmp+0x2e>

00800eab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eb5:	eb 03                	jmp    800eba <strchr+0xf>
  800eb7:	83 c0 01             	add    $0x1,%eax
  800eba:	0f b6 10             	movzbl (%eax),%edx
  800ebd:	84 d2                	test   %dl,%dl
  800ebf:	74 06                	je     800ec7 <strchr+0x1c>
		if (*s == c)
  800ec1:	38 ca                	cmp    %cl,%dl
  800ec3:	75 f2                	jne    800eb7 <strchr+0xc>
  800ec5:	eb 05                	jmp    800ecc <strchr+0x21>
			return (char *) s;
	return 0;
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ed8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800edb:	38 ca                	cmp    %cl,%dl
  800edd:	74 09                	je     800ee8 <strfind+0x1a>
  800edf:	84 d2                	test   %dl,%dl
  800ee1:	74 05                	je     800ee8 <strfind+0x1a>
	for (; *s; s++)
  800ee3:	83 c0 01             	add    $0x1,%eax
  800ee6:	eb f0                	jmp    800ed8 <strfind+0xa>
			break;
	return (char *) s;
}
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ef3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ef6:	85 c9                	test   %ecx,%ecx
  800ef8:	74 2f                	je     800f29 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800efa:	89 f8                	mov    %edi,%eax
  800efc:	09 c8                	or     %ecx,%eax
  800efe:	a8 03                	test   $0x3,%al
  800f00:	75 21                	jne    800f23 <memset+0x39>
		c &= 0xFF;
  800f02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	c1 e0 08             	shl    $0x8,%eax
  800f0b:	89 d3                	mov    %edx,%ebx
  800f0d:	c1 e3 18             	shl    $0x18,%ebx
  800f10:	89 d6                	mov    %edx,%esi
  800f12:	c1 e6 10             	shl    $0x10,%esi
  800f15:	09 f3                	or     %esi,%ebx
  800f17:	09 da                	or     %ebx,%edx
  800f19:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f1b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f1e:	fc                   	cld    
  800f1f:	f3 ab                	rep stos %eax,%es:(%edi)
  800f21:	eb 06                	jmp    800f29 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f26:	fc                   	cld    
  800f27:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f29:	89 f8                	mov    %edi,%eax
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f3e:	39 c6                	cmp    %eax,%esi
  800f40:	73 32                	jae    800f74 <memmove+0x44>
  800f42:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f45:	39 c2                	cmp    %eax,%edx
  800f47:	76 2b                	jbe    800f74 <memmove+0x44>
		s += n;
		d += n;
  800f49:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4c:	89 d6                	mov    %edx,%esi
  800f4e:	09 fe                	or     %edi,%esi
  800f50:	09 ce                	or     %ecx,%esi
  800f52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f58:	75 0e                	jne    800f68 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f5a:	83 ef 04             	sub    $0x4,%edi
  800f5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f60:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f63:	fd                   	std    
  800f64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f66:	eb 09                	jmp    800f71 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f68:	83 ef 01             	sub    $0x1,%edi
  800f6b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f6e:	fd                   	std    
  800f6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f71:	fc                   	cld    
  800f72:	eb 1a                	jmp    800f8e <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f74:	89 f2                	mov    %esi,%edx
  800f76:	09 c2                	or     %eax,%edx
  800f78:	09 ca                	or     %ecx,%edx
  800f7a:	f6 c2 03             	test   $0x3,%dl
  800f7d:	75 0a                	jne    800f89 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	fc                   	cld    
  800f85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f87:	eb 05                	jmp    800f8e <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800f89:	89 c7                	mov    %eax,%edi
  800f8b:	fc                   	cld    
  800f8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f98:	ff 75 10             	push   0x10(%ebp)
  800f9b:	ff 75 0c             	push   0xc(%ebp)
  800f9e:	ff 75 08             	push   0x8(%ebp)
  800fa1:	e8 8a ff ff ff       	call   800f30 <memmove>
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb3:	89 c6                	mov    %eax,%esi
  800fb5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb8:	eb 06                	jmp    800fc0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fba:	83 c0 01             	add    $0x1,%eax
  800fbd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800fc0:	39 f0                	cmp    %esi,%eax
  800fc2:	74 14                	je     800fd8 <memcmp+0x30>
		if (*s1 != *s2)
  800fc4:	0f b6 08             	movzbl (%eax),%ecx
  800fc7:	0f b6 1a             	movzbl (%edx),%ebx
  800fca:	38 d9                	cmp    %bl,%cl
  800fcc:	74 ec                	je     800fba <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800fce:	0f b6 c1             	movzbl %cl,%eax
  800fd1:	0f b6 db             	movzbl %bl,%ebx
  800fd4:	29 d8                	sub    %ebx,%eax
  800fd6:	eb 05                	jmp    800fdd <memcmp+0x35>
	}

	return 0;
  800fd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fea:	89 c2                	mov    %eax,%edx
  800fec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fef:	eb 03                	jmp    800ff4 <memfind+0x13>
  800ff1:	83 c0 01             	add    $0x1,%eax
  800ff4:	39 d0                	cmp    %edx,%eax
  800ff6:	73 04                	jae    800ffc <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ff8:	38 08                	cmp    %cl,(%eax)
  800ffa:	75 f5                	jne    800ff1 <memfind+0x10>
			break;
	return (void *) s;
}
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	8b 55 08             	mov    0x8(%ebp),%edx
  801007:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100a:	eb 03                	jmp    80100f <strtol+0x11>
		s++;
  80100c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80100f:	0f b6 02             	movzbl (%edx),%eax
  801012:	3c 20                	cmp    $0x20,%al
  801014:	74 f6                	je     80100c <strtol+0xe>
  801016:	3c 09                	cmp    $0x9,%al
  801018:	74 f2                	je     80100c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80101a:	3c 2b                	cmp    $0x2b,%al
  80101c:	74 2a                	je     801048 <strtol+0x4a>
	int neg = 0;
  80101e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801023:	3c 2d                	cmp    $0x2d,%al
  801025:	74 2b                	je     801052 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801027:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80102d:	75 0f                	jne    80103e <strtol+0x40>
  80102f:	80 3a 30             	cmpb   $0x30,(%edx)
  801032:	74 28                	je     80105c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801034:	85 db                	test   %ebx,%ebx
  801036:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103b:	0f 44 d8             	cmove  %eax,%ebx
  80103e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801043:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801046:	eb 46                	jmp    80108e <strtol+0x90>
		s++;
  801048:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80104b:	bf 00 00 00 00       	mov    $0x0,%edi
  801050:	eb d5                	jmp    801027 <strtol+0x29>
		s++, neg = 1;
  801052:	83 c2 01             	add    $0x1,%edx
  801055:	bf 01 00 00 00       	mov    $0x1,%edi
  80105a:	eb cb                	jmp    801027 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80105c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801060:	74 0e                	je     801070 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801062:	85 db                	test   %ebx,%ebx
  801064:	75 d8                	jne    80103e <strtol+0x40>
		s++, base = 8;
  801066:	83 c2 01             	add    $0x1,%edx
  801069:	bb 08 00 00 00       	mov    $0x8,%ebx
  80106e:	eb ce                	jmp    80103e <strtol+0x40>
		s += 2, base = 16;
  801070:	83 c2 02             	add    $0x2,%edx
  801073:	bb 10 00 00 00       	mov    $0x10,%ebx
  801078:	eb c4                	jmp    80103e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80107a:	0f be c0             	movsbl %al,%eax
  80107d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801080:	3b 45 10             	cmp    0x10(%ebp),%eax
  801083:	7d 3a                	jge    8010bf <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801085:	83 c2 01             	add    $0x1,%edx
  801088:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80108c:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  80108e:	0f b6 02             	movzbl (%edx),%eax
  801091:	8d 70 d0             	lea    -0x30(%eax),%esi
  801094:	89 f3                	mov    %esi,%ebx
  801096:	80 fb 09             	cmp    $0x9,%bl
  801099:	76 df                	jbe    80107a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  80109b:	8d 70 9f             	lea    -0x61(%eax),%esi
  80109e:	89 f3                	mov    %esi,%ebx
  8010a0:	80 fb 19             	cmp    $0x19,%bl
  8010a3:	77 08                	ja     8010ad <strtol+0xaf>
			dig = *s - 'a' + 10;
  8010a5:	0f be c0             	movsbl %al,%eax
  8010a8:	83 e8 57             	sub    $0x57,%eax
  8010ab:	eb d3                	jmp    801080 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8010ad:	8d 70 bf             	lea    -0x41(%eax),%esi
  8010b0:	89 f3                	mov    %esi,%ebx
  8010b2:	80 fb 19             	cmp    $0x19,%bl
  8010b5:	77 08                	ja     8010bf <strtol+0xc1>
			dig = *s - 'A' + 10;
  8010b7:	0f be c0             	movsbl %al,%eax
  8010ba:	83 e8 37             	sub    $0x37,%eax
  8010bd:	eb c1                	jmp    801080 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010c3:	74 05                	je     8010ca <strtol+0xcc>
		*endptr = (char *) s;
  8010c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8010ca:	89 c8                	mov    %ecx,%eax
  8010cc:	f7 d8                	neg    %eax
  8010ce:	85 ff                	test   %edi,%edi
  8010d0:	0f 45 c8             	cmovne %eax,%ecx
}
  8010d3:	89 c8                	mov    %ecx,%eax
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010eb:	89 c3                	mov    %eax,%ebx
  8010ed:	89 c7                	mov    %eax,%edi
  8010ef:	89 c6                	mov    %eax,%esi
  8010f1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801103:	b8 01 00 00 00       	mov    $0x1,%eax
  801108:	89 d1                	mov    %edx,%ecx
  80110a:	89 d3                	mov    %edx,%ebx
  80110c:	89 d7                	mov    %edx,%edi
  80110e:	89 d6                	mov    %edx,%esi
  801110:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801120:	b9 00 00 00 00       	mov    $0x0,%ecx
  801125:	8b 55 08             	mov    0x8(%ebp),%edx
  801128:	b8 03 00 00 00       	mov    $0x3,%eax
  80112d:	89 cb                	mov    %ecx,%ebx
  80112f:	89 cf                	mov    %ecx,%edi
  801131:	89 ce                	mov    %ecx,%esi
  801133:	cd 30                	int    $0x30
	if(check && ret > 0)
  801135:	85 c0                	test   %eax,%eax
  801137:	7f 08                	jg     801141 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	50                   	push   %eax
  801145:	6a 03                	push   $0x3
  801147:	68 9f 2a 80 00       	push   $0x802a9f
  80114c:	6a 2a                	push   $0x2a
  80114e:	68 bc 2a 80 00       	push   $0x802abc
  801153:	e8 8d f5 ff ff       	call   8006e5 <_panic>

00801158 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	57                   	push   %edi
  80115c:	56                   	push   %esi
  80115d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80115e:	ba 00 00 00 00       	mov    $0x0,%edx
  801163:	b8 02 00 00 00       	mov    $0x2,%eax
  801168:	89 d1                	mov    %edx,%ecx
  80116a:	89 d3                	mov    %edx,%ebx
  80116c:	89 d7                	mov    %edx,%edi
  80116e:	89 d6                	mov    %edx,%esi
  801170:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <sys_yield>:

void
sys_yield(void)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80117d:	ba 00 00 00 00       	mov    $0x0,%edx
  801182:	b8 0b 00 00 00       	mov    $0xb,%eax
  801187:	89 d1                	mov    %edx,%ecx
  801189:	89 d3                	mov    %edx,%ebx
  80118b:	89 d7                	mov    %edx,%edi
  80118d:	89 d6                	mov    %edx,%esi
  80118f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80119f:	be 00 00 00 00       	mov    $0x0,%esi
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8011af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b2:	89 f7                	mov    %esi,%edi
  8011b4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7f 08                	jg     8011c2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	50                   	push   %eax
  8011c6:	6a 04                	push   $0x4
  8011c8:	68 9f 2a 80 00       	push   $0x802a9f
  8011cd:	6a 2a                	push   $0x2a
  8011cf:	68 bc 2a 80 00       	push   $0x802abc
  8011d4:	e8 0c f5 ff ff       	call   8006e5 <_panic>

008011d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8011ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	7f 08                	jg     801204 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	50                   	push   %eax
  801208:	6a 05                	push   $0x5
  80120a:	68 9f 2a 80 00       	push   $0x802a9f
  80120f:	6a 2a                	push   $0x2a
  801211:	68 bc 2a 80 00       	push   $0x802abc
  801216:	e8 ca f4 ff ff       	call   8006e5 <_panic>

0080121b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801224:	bb 00 00 00 00       	mov    $0x0,%ebx
  801229:	8b 55 08             	mov    0x8(%ebp),%edx
  80122c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122f:	b8 06 00 00 00       	mov    $0x6,%eax
  801234:	89 df                	mov    %ebx,%edi
  801236:	89 de                	mov    %ebx,%esi
  801238:	cd 30                	int    $0x30
	if(check && ret > 0)
  80123a:	85 c0                	test   %eax,%eax
  80123c:	7f 08                	jg     801246 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80123e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801241:	5b                   	pop    %ebx
  801242:	5e                   	pop    %esi
  801243:	5f                   	pop    %edi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	50                   	push   %eax
  80124a:	6a 06                	push   $0x6
  80124c:	68 9f 2a 80 00       	push   $0x802a9f
  801251:	6a 2a                	push   $0x2a
  801253:	68 bc 2a 80 00       	push   $0x802abc
  801258:	e8 88 f4 ff ff       	call   8006e5 <_panic>

0080125d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126b:	8b 55 08             	mov    0x8(%ebp),%edx
  80126e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801271:	b8 08 00 00 00       	mov    $0x8,%eax
  801276:	89 df                	mov    %ebx,%edi
  801278:	89 de                	mov    %ebx,%esi
  80127a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	7f 08                	jg     801288 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801288:	83 ec 0c             	sub    $0xc,%esp
  80128b:	50                   	push   %eax
  80128c:	6a 08                	push   $0x8
  80128e:	68 9f 2a 80 00       	push   $0x802a9f
  801293:	6a 2a                	push   $0x2a
  801295:	68 bc 2a 80 00       	push   $0x802abc
  80129a:	e8 46 f4 ff ff       	call   8006e5 <_panic>

0080129f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b8:	89 df                	mov    %ebx,%edi
  8012ba:	89 de                	mov    %ebx,%esi
  8012bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	7f 08                	jg     8012ca <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	50                   	push   %eax
  8012ce:	6a 09                	push   $0x9
  8012d0:	68 9f 2a 80 00       	push   $0x802a9f
  8012d5:	6a 2a                	push   $0x2a
  8012d7:	68 bc 2a 80 00       	push   $0x802abc
  8012dc:	e8 04 f4 ff ff       	call   8006e5 <_panic>

008012e1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012fa:	89 df                	mov    %ebx,%edi
  8012fc:	89 de                	mov    %ebx,%esi
  8012fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  801300:	85 c0                	test   %eax,%eax
  801302:	7f 08                	jg     80130c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	50                   	push   %eax
  801310:	6a 0a                	push   $0xa
  801312:	68 9f 2a 80 00       	push   $0x802a9f
  801317:	6a 2a                	push   $0x2a
  801319:	68 bc 2a 80 00       	push   $0x802abc
  80131e:	e8 c2 f3 ff ff       	call   8006e5 <_panic>

00801323 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
	asm volatile("int %1\n"
  801329:	8b 55 08             	mov    0x8(%ebp),%edx
  80132c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801334:	be 00 00 00 00       	mov    $0x0,%esi
  801339:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80133f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80134f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801354:	8b 55 08             	mov    0x8(%ebp),%edx
  801357:	b8 0d 00 00 00       	mov    $0xd,%eax
  80135c:	89 cb                	mov    %ecx,%ebx
  80135e:	89 cf                	mov    %ecx,%edi
  801360:	89 ce                	mov    %ecx,%esi
  801362:	cd 30                	int    $0x30
	if(check && ret > 0)
  801364:	85 c0                	test   %eax,%eax
  801366:	7f 08                	jg     801370 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801368:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	50                   	push   %eax
  801374:	6a 0d                	push   $0xd
  801376:	68 9f 2a 80 00       	push   $0x802a9f
  80137b:	6a 2a                	push   $0x2a
  80137d:	68 bc 2a 80 00       	push   $0x802abc
  801382:	e8 5e f3 ff ff       	call   8006e5 <_panic>

00801387 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	8b 75 08             	mov    0x8(%ebp),%esi
  80138f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801392:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801395:	85 c0                	test   %eax,%eax
  801397:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80139c:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	50                   	push   %eax
  8013a3:	e8 9e ff ff ff       	call   801346 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 f6                	test   %esi,%esi
  8013ad:	74 14                	je     8013c3 <ipc_recv+0x3c>
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 09                	js     8013c1 <ipc_recv+0x3a>
  8013b8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8013be:	8b 52 74             	mov    0x74(%edx),%edx
  8013c1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8013c3:	85 db                	test   %ebx,%ebx
  8013c5:	74 14                	je     8013db <ipc_recv+0x54>
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 09                	js     8013d9 <ipc_recv+0x52>
  8013d0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8013d6:	8b 52 78             	mov    0x78(%edx),%edx
  8013d9:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 08                	js     8013e7 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8013df:	a1 00 40 80 00       	mov    0x804000,%eax
  8013e4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801400:	85 db                	test   %ebx,%ebx
  801402:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801407:	0f 44 d8             	cmove  %eax,%ebx
  80140a:	eb 05                	jmp    801411 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80140c:	e8 66 fd ff ff       	call   801177 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801411:	ff 75 14             	push   0x14(%ebp)
  801414:	53                   	push   %ebx
  801415:	56                   	push   %esi
  801416:	57                   	push   %edi
  801417:	e8 07 ff ff ff       	call   801323 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801422:	74 e8                	je     80140c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801424:	85 c0                	test   %eax,%eax
  801426:	78 08                	js     801430 <ipc_send+0x42>
	}while (r<0);

}
  801428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801430:	50                   	push   %eax
  801431:	68 ca 2a 80 00       	push   $0x802aca
  801436:	6a 3d                	push   $0x3d
  801438:	68 de 2a 80 00       	push   $0x802ade
  80143d:	e8 a3 f2 ff ff       	call   8006e5 <_panic>

00801442 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801448:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80144d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801450:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801456:	8b 52 50             	mov    0x50(%edx),%edx
  801459:	39 ca                	cmp    %ecx,%edx
  80145b:	74 11                	je     80146e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80145d:	83 c0 01             	add    $0x1,%eax
  801460:	3d 00 04 00 00       	cmp    $0x400,%eax
  801465:	75 e6                	jne    80144d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801467:	b8 00 00 00 00       	mov    $0x0,%eax
  80146c:	eb 0b                	jmp    801479 <ipc_find_env+0x37>
			return envs[i].env_id;
  80146e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801471:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801476:	8b 40 48             	mov    0x48(%eax),%eax
}
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80147e:	8b 45 08             	mov    0x8(%ebp),%eax
  801481:	05 00 00 00 30       	add    $0x30000000,%eax
  801486:	c1 e8 0c             	shr    $0xc,%eax
}
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80148e:	8b 45 08             	mov    0x8(%ebp),%eax
  801491:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801496:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80149b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 16             	shr    $0x16,%edx
  8014af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	74 29                	je     8014e4 <fd_alloc+0x42>
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	c1 ea 0c             	shr    $0xc,%edx
  8014c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c7:	f6 c2 01             	test   $0x1,%dl
  8014ca:	74 18                	je     8014e4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8014cc:	05 00 10 00 00       	add    $0x1000,%eax
  8014d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014d6:	75 d2                	jne    8014aa <fd_alloc+0x8>
  8014d8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8014dd:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8014e2:	eb 05                	jmp    8014e9 <fd_alloc+0x47>
			return 0;
  8014e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8014e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ec:	89 02                	mov    %eax,(%edx)
}
  8014ee:	89 c8                	mov    %ecx,%eax
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014f8:	83 f8 1f             	cmp    $0x1f,%eax
  8014fb:	77 30                	ja     80152d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014fd:	c1 e0 0c             	shl    $0xc,%eax
  801500:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801505:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80150b:	f6 c2 01             	test   $0x1,%dl
  80150e:	74 24                	je     801534 <fd_lookup+0x42>
  801510:	89 c2                	mov    %eax,%edx
  801512:	c1 ea 0c             	shr    $0xc,%edx
  801515:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151c:	f6 c2 01             	test   $0x1,%dl
  80151f:	74 1a                	je     80153b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801521:	8b 55 0c             	mov    0xc(%ebp),%edx
  801524:	89 02                	mov    %eax,(%edx)
	return 0;
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    
		return -E_INVAL;
  80152d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801532:	eb f7                	jmp    80152b <fd_lookup+0x39>
		return -E_INVAL;
  801534:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801539:	eb f0                	jmp    80152b <fd_lookup+0x39>
  80153b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801540:	eb e9                	jmp    80152b <fd_lookup+0x39>

00801542 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	53                   	push   %ebx
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	8b 55 08             	mov    0x8(%ebp),%edx
  80154c:	b8 64 2b 80 00       	mov    $0x802b64,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801551:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801556:	39 13                	cmp    %edx,(%ebx)
  801558:	74 32                	je     80158c <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80155a:	83 c0 04             	add    $0x4,%eax
  80155d:	8b 18                	mov    (%eax),%ebx
  80155f:	85 db                	test   %ebx,%ebx
  801561:	75 f3                	jne    801556 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801563:	a1 00 40 80 00       	mov    0x804000,%eax
  801568:	8b 40 48             	mov    0x48(%eax),%eax
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	52                   	push   %edx
  80156f:	50                   	push   %eax
  801570:	68 e8 2a 80 00       	push   $0x802ae8
  801575:	e8 46 f2 ff ff       	call   8007c0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801582:	8b 55 0c             	mov    0xc(%ebp),%edx
  801585:	89 1a                	mov    %ebx,(%edx)
}
  801587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    
			return 0;
  80158c:	b8 00 00 00 00       	mov    $0x0,%eax
  801591:	eb ef                	jmp    801582 <dev_lookup+0x40>

00801593 <fd_close>:
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	57                   	push   %edi
  801597:	56                   	push   %esi
  801598:	53                   	push   %ebx
  801599:	83 ec 24             	sub    $0x24,%esp
  80159c:	8b 75 08             	mov    0x8(%ebp),%esi
  80159f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a5:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015ac:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015af:	50                   	push   %eax
  8015b0:	e8 3d ff ff ff       	call   8014f2 <fd_lookup>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 05                	js     8015c3 <fd_close+0x30>
	    || fd != fd2)
  8015be:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015c1:	74 16                	je     8015d9 <fd_close+0x46>
		return (must_exist ? r : 0);
  8015c3:	89 f8                	mov    %edi,%eax
  8015c5:	84 c0                	test   %al,%al
  8015c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cc:	0f 44 d8             	cmove  %eax,%ebx
}
  8015cf:	89 d8                	mov    %ebx,%eax
  8015d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5e                   	pop    %esi
  8015d6:	5f                   	pop    %edi
  8015d7:	5d                   	pop    %ebp
  8015d8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	ff 36                	push   (%esi)
  8015e2:	e8 5b ff ff ff       	call   801542 <dev_lookup>
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 1a                	js     80160a <fd_close+0x77>
		if (dev->dev_close)
  8015f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015f3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	74 0b                	je     80160a <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	56                   	push   %esi
  801603:	ff d0                	call   *%eax
  801605:	89 c3                	mov    %eax,%ebx
  801607:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	6a 00                	push   $0x0
  801610:	e8 06 fc ff ff       	call   80121b <sys_page_unmap>
	return r;
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb b5                	jmp    8015cf <fd_close+0x3c>

0080161a <close>:

int
close(int fdnum)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801620:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	ff 75 08             	push   0x8(%ebp)
  801627:	e8 c6 fe ff ff       	call   8014f2 <fd_lookup>
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	79 02                	jns    801635 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801633:	c9                   	leave  
  801634:	c3                   	ret    
		return fd_close(fd, 1);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	6a 01                	push   $0x1
  80163a:	ff 75 f4             	push   -0xc(%ebp)
  80163d:	e8 51 ff ff ff       	call   801593 <fd_close>
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	eb ec                	jmp    801633 <close+0x19>

00801647 <close_all>:

void
close_all(void)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80164e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	53                   	push   %ebx
  801657:	e8 be ff ff ff       	call   80161a <close>
	for (i = 0; i < MAXFD; i++)
  80165c:	83 c3 01             	add    $0x1,%ebx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	83 fb 20             	cmp    $0x20,%ebx
  801665:	75 ec                	jne    801653 <close_all+0xc>
}
  801667:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801675:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	push   0x8(%ebp)
  80167c:	e8 71 fe ff ff       	call   8014f2 <fd_lookup>
  801681:	89 c3                	mov    %eax,%ebx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 7f                	js     801709 <dup+0x9d>
		return r;
	close(newfdnum);
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	ff 75 0c             	push   0xc(%ebp)
  801690:	e8 85 ff ff ff       	call   80161a <close>

	newfd = INDEX2FD(newfdnum);
  801695:	8b 75 0c             	mov    0xc(%ebp),%esi
  801698:	c1 e6 0c             	shl    $0xc,%esi
  80169b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016a4:	89 3c 24             	mov    %edi,(%esp)
  8016a7:	e8 df fd ff ff       	call   80148b <fd2data>
  8016ac:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016ae:	89 34 24             	mov    %esi,(%esp)
  8016b1:	e8 d5 fd ff ff       	call   80148b <fd2data>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	c1 e8 16             	shr    $0x16,%eax
  8016c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c8:	a8 01                	test   $0x1,%al
  8016ca:	74 11                	je     8016dd <dup+0x71>
  8016cc:	89 d8                	mov    %ebx,%eax
  8016ce:	c1 e8 0c             	shr    $0xc,%eax
  8016d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d8:	f6 c2 01             	test   $0x1,%dl
  8016db:	75 36                	jne    801713 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016dd:	89 f8                	mov    %edi,%eax
  8016df:	c1 e8 0c             	shr    $0xc,%eax
  8016e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e9:	83 ec 0c             	sub    $0xc,%esp
  8016ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f1:	50                   	push   %eax
  8016f2:	56                   	push   %esi
  8016f3:	6a 00                	push   $0x0
  8016f5:	57                   	push   %edi
  8016f6:	6a 00                	push   $0x0
  8016f8:	e8 dc fa ff ff       	call   8011d9 <sys_page_map>
  8016fd:	89 c3                	mov    %eax,%ebx
  8016ff:	83 c4 20             	add    $0x20,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 33                	js     801739 <dup+0xcd>
		goto err;

	return newfdnum;
  801706:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801709:	89 d8                	mov    %ebx,%eax
  80170b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170e:	5b                   	pop    %ebx
  80170f:	5e                   	pop    %esi
  801710:	5f                   	pop    %edi
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801713:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	25 07 0e 00 00       	and    $0xe07,%eax
  801722:	50                   	push   %eax
  801723:	ff 75 d4             	push   -0x2c(%ebp)
  801726:	6a 00                	push   $0x0
  801728:	53                   	push   %ebx
  801729:	6a 00                	push   $0x0
  80172b:	e8 a9 fa ff ff       	call   8011d9 <sys_page_map>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	83 c4 20             	add    $0x20,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	79 a4                	jns    8016dd <dup+0x71>
	sys_page_unmap(0, newfd);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	56                   	push   %esi
  80173d:	6a 00                	push   $0x0
  80173f:	e8 d7 fa ff ff       	call   80121b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	ff 75 d4             	push   -0x2c(%ebp)
  80174a:	6a 00                	push   $0x0
  80174c:	e8 ca fa ff ff       	call   80121b <sys_page_unmap>
	return r;
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	eb b3                	jmp    801709 <dup+0x9d>

00801756 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 18             	sub    $0x18,%esp
  80175e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801761:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801764:	50                   	push   %eax
  801765:	56                   	push   %esi
  801766:	e8 87 fd ff ff       	call   8014f2 <fd_lookup>
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 3c                	js     8017ae <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801772:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	ff 33                	push   (%ebx)
  80177e:	e8 bf fd ff ff       	call   801542 <dev_lookup>
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 24                	js     8017ae <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80178a:	8b 43 08             	mov    0x8(%ebx),%eax
  80178d:	83 e0 03             	and    $0x3,%eax
  801790:	83 f8 01             	cmp    $0x1,%eax
  801793:	74 20                	je     8017b5 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801798:	8b 40 08             	mov    0x8(%eax),%eax
  80179b:	85 c0                	test   %eax,%eax
  80179d:	74 37                	je     8017d6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	ff 75 10             	push   0x10(%ebp)
  8017a5:	ff 75 0c             	push   0xc(%ebp)
  8017a8:	53                   	push   %ebx
  8017a9:	ff d0                	call   *%eax
  8017ab:	83 c4 10             	add    $0x10,%esp
}
  8017ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b5:	a1 00 40 80 00       	mov    0x804000,%eax
  8017ba:	8b 40 48             	mov    0x48(%eax),%eax
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	56                   	push   %esi
  8017c1:	50                   	push   %eax
  8017c2:	68 29 2b 80 00       	push   $0x802b29
  8017c7:	e8 f4 ef ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb d8                	jmp    8017ae <read+0x58>
		return -E_NOT_SUPP;
  8017d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017db:	eb d1                	jmp    8017ae <read+0x58>

008017dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	57                   	push   %edi
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f1:	eb 02                	jmp    8017f5 <readn+0x18>
  8017f3:	01 c3                	add    %eax,%ebx
  8017f5:	39 f3                	cmp    %esi,%ebx
  8017f7:	73 21                	jae    80181a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	89 f0                	mov    %esi,%eax
  8017fe:	29 d8                	sub    %ebx,%eax
  801800:	50                   	push   %eax
  801801:	89 d8                	mov    %ebx,%eax
  801803:	03 45 0c             	add    0xc(%ebp),%eax
  801806:	50                   	push   %eax
  801807:	57                   	push   %edi
  801808:	e8 49 ff ff ff       	call   801756 <read>
		if (m < 0)
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 04                	js     801818 <readn+0x3b>
			return m;
		if (m == 0)
  801814:	75 dd                	jne    8017f3 <readn+0x16>
  801816:	eb 02                	jmp    80181a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801818:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5f                   	pop    %edi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	83 ec 18             	sub    $0x18,%esp
  80182c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	53                   	push   %ebx
  801834:	e8 b9 fc ff ff       	call   8014f2 <fd_lookup>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 37                	js     801877 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	ff 36                	push   (%esi)
  80184c:	e8 f1 fc ff ff       	call   801542 <dev_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 1f                	js     801877 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801858:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80185c:	74 20                	je     80187e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80185e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801861:	8b 40 0c             	mov    0xc(%eax),%eax
  801864:	85 c0                	test   %eax,%eax
  801866:	74 37                	je     80189f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801868:	83 ec 04             	sub    $0x4,%esp
  80186b:	ff 75 10             	push   0x10(%ebp)
  80186e:	ff 75 0c             	push   0xc(%ebp)
  801871:	56                   	push   %esi
  801872:	ff d0                	call   *%eax
  801874:	83 c4 10             	add    $0x10,%esp
}
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80187e:	a1 00 40 80 00       	mov    0x804000,%eax
  801883:	8b 40 48             	mov    0x48(%eax),%eax
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	53                   	push   %ebx
  80188a:	50                   	push   %eax
  80188b:	68 45 2b 80 00       	push   $0x802b45
  801890:	e8 2b ef ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80189d:	eb d8                	jmp    801877 <write+0x53>
		return -E_NOT_SUPP;
  80189f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018a4:	eb d1                	jmp    801877 <write+0x53>

008018a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	ff 75 08             	push   0x8(%ebp)
  8018b3:	e8 3a fc ff ff       	call   8014f2 <fd_lookup>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 0e                	js     8018cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 18             	sub    $0x18,%esp
  8018d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	53                   	push   %ebx
  8018df:	e8 0e fc ff ff       	call   8014f2 <fd_lookup>
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 34                	js     80191f <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018eb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	ff 36                	push   (%esi)
  8018f7:	e8 46 fc ff ff       	call   801542 <dev_lookup>
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 1c                	js     80191f <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801903:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801907:	74 1d                	je     801926 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190c:	8b 40 18             	mov    0x18(%eax),%eax
  80190f:	85 c0                	test   %eax,%eax
  801911:	74 34                	je     801947 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	ff 75 0c             	push   0xc(%ebp)
  801919:	56                   	push   %esi
  80191a:	ff d0                	call   *%eax
  80191c:	83 c4 10             	add    $0x10,%esp
}
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    
			thisenv->env_id, fdnum);
  801926:	a1 00 40 80 00       	mov    0x804000,%eax
  80192b:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80192e:	83 ec 04             	sub    $0x4,%esp
  801931:	53                   	push   %ebx
  801932:	50                   	push   %eax
  801933:	68 08 2b 80 00       	push   $0x802b08
  801938:	e8 83 ee ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801945:	eb d8                	jmp    80191f <ftruncate+0x50>
		return -E_NOT_SUPP;
  801947:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194c:	eb d1                	jmp    80191f <ftruncate+0x50>

0080194e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	83 ec 18             	sub    $0x18,%esp
  801956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801959:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	ff 75 08             	push   0x8(%ebp)
  801960:	e8 8d fb ff ff       	call   8014f2 <fd_lookup>
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 49                	js     8019b5 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	ff 36                	push   (%esi)
  801978:	e8 c5 fb ff ff       	call   801542 <dev_lookup>
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	85 c0                	test   %eax,%eax
  801982:	78 31                	js     8019b5 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801987:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80198b:	74 2f                	je     8019bc <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80198d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801990:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801997:	00 00 00 
	stat->st_isdir = 0;
  80199a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a1:	00 00 00 
	stat->st_dev = dev;
  8019a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	53                   	push   %ebx
  8019ae:	56                   	push   %esi
  8019af:	ff 50 14             	call   *0x14(%eax)
  8019b2:	83 c4 10             	add    $0x10,%esp
}
  8019b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    
		return -E_NOT_SUPP;
  8019bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c1:	eb f2                	jmp    8019b5 <fstat+0x67>

008019c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	6a 00                	push   $0x0
  8019cd:	ff 75 08             	push   0x8(%ebp)
  8019d0:	e8 e4 01 00 00       	call   801bb9 <open>
  8019d5:	89 c3                	mov    %eax,%ebx
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 1b                	js     8019f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	ff 75 0c             	push   0xc(%ebp)
  8019e4:	50                   	push   %eax
  8019e5:	e8 64 ff ff ff       	call   80194e <fstat>
  8019ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ec:	89 1c 24             	mov    %ebx,(%esp)
  8019ef:	e8 26 fc ff ff       	call   80161a <close>
	return r;
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	89 f3                	mov    %esi,%ebx
}
  8019f9:	89 d8                	mov    %ebx,%eax
  8019fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	89 c6                	mov    %eax,%esi
  801a09:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a0b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a12:	74 27                	je     801a3b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a14:	6a 07                	push   $0x7
  801a16:	68 00 50 80 00       	push   $0x805000
  801a1b:	56                   	push   %esi
  801a1c:	ff 35 00 60 80 00    	push   0x806000
  801a22:	e8 c7 f9 ff ff       	call   8013ee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a27:	83 c4 0c             	add    $0xc,%esp
  801a2a:	6a 00                	push   $0x0
  801a2c:	53                   	push   %ebx
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 53 f9 ff ff       	call   801387 <ipc_recv>
}
  801a34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	6a 01                	push   $0x1
  801a40:	e8 fd f9 ff ff       	call   801442 <ipc_find_env>
  801a45:	a3 00 60 80 00       	mov    %eax,0x806000
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	eb c5                	jmp    801a14 <fsipc+0x12>

00801a4f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a63:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a68:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6d:	b8 02 00 00 00       	mov    $0x2,%eax
  801a72:	e8 8b ff ff ff       	call   801a02 <fsipc>
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <devfile_flush>:
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	8b 40 0c             	mov    0xc(%eax),%eax
  801a85:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a94:	e8 69 ff ff ff       	call   801a02 <fsipc>
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <devfile_stat>:
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	53                   	push   %ebx
  801a9f:	83 ec 04             	sub    $0x4,%esp
  801aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	8b 40 0c             	mov    0xc(%eax),%eax
  801aab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab5:	b8 05 00 00 00       	mov    $0x5,%eax
  801aba:	e8 43 ff ff ff       	call   801a02 <fsipc>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	78 2c                	js     801aef <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac3:	83 ec 08             	sub    $0x8,%esp
  801ac6:	68 00 50 80 00       	push   $0x805000
  801acb:	53                   	push   %ebx
  801acc:	e8 c9 f2 ff ff       	call   800d9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad1:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801adc:	a1 84 50 80 00       	mov    0x805084,%eax
  801ae1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <devfile_write>:
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 45 10             	mov    0x10(%ebp),%eax
  801afd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b02:	39 d0                	cmp    %edx,%eax
  801b04:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b07:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0a:	8b 52 0c             	mov    0xc(%edx),%edx
  801b0d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b13:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b18:	50                   	push   %eax
  801b19:	ff 75 0c             	push   0xc(%ebp)
  801b1c:	68 08 50 80 00       	push   $0x805008
  801b21:	e8 0a f4 ff ff       	call   800f30 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801b26:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b30:	e8 cd fe ff ff       	call   801a02 <fsipc>
}
  801b35:	c9                   	leave  
  801b36:	c3                   	ret    

00801b37 <devfile_read>:
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	8b 40 0c             	mov    0xc(%eax),%eax
  801b45:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b4a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b50:	ba 00 00 00 00       	mov    $0x0,%edx
  801b55:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5a:	e8 a3 fe ff ff       	call   801a02 <fsipc>
  801b5f:	89 c3                	mov    %eax,%ebx
  801b61:	85 c0                	test   %eax,%eax
  801b63:	78 1f                	js     801b84 <devfile_read+0x4d>
	assert(r <= n);
  801b65:	39 f0                	cmp    %esi,%eax
  801b67:	77 24                	ja     801b8d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801b69:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b6e:	7f 33                	jg     801ba3 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b70:	83 ec 04             	sub    $0x4,%esp
  801b73:	50                   	push   %eax
  801b74:	68 00 50 80 00       	push   $0x805000
  801b79:	ff 75 0c             	push   0xc(%ebp)
  801b7c:	e8 af f3 ff ff       	call   800f30 <memmove>
	return r;
  801b81:	83 c4 10             	add    $0x10,%esp
}
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    
	assert(r <= n);
  801b8d:	68 74 2b 80 00       	push   $0x802b74
  801b92:	68 7b 2b 80 00       	push   $0x802b7b
  801b97:	6a 7c                	push   $0x7c
  801b99:	68 90 2b 80 00       	push   $0x802b90
  801b9e:	e8 42 eb ff ff       	call   8006e5 <_panic>
	assert(r <= PGSIZE);
  801ba3:	68 9b 2b 80 00       	push   $0x802b9b
  801ba8:	68 7b 2b 80 00       	push   $0x802b7b
  801bad:	6a 7d                	push   $0x7d
  801baf:	68 90 2b 80 00       	push   $0x802b90
  801bb4:	e8 2c eb ff ff       	call   8006e5 <_panic>

00801bb9 <open>:
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 1c             	sub    $0x1c,%esp
  801bc1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bc4:	56                   	push   %esi
  801bc5:	e8 95 f1 ff ff       	call   800d5f <strlen>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd2:	7f 6c                	jg     801c40 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	e8 c2 f8 ff ff       	call   8014a2 <fd_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 3c                	js     801c25 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	56                   	push   %esi
  801bed:	68 00 50 80 00       	push   $0x805000
  801bf2:	e8 a3 f1 ff ff       	call   800d9a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfa:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c02:	b8 01 00 00 00       	mov    $0x1,%eax
  801c07:	e8 f6 fd ff ff       	call   801a02 <fsipc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 19                	js     801c2e <open+0x75>
	return fd2num(fd);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 f4             	push   -0xc(%ebp)
  801c1b:	e8 5b f8 ff ff       	call   80147b <fd2num>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 10             	add    $0x10,%esp
}
  801c25:	89 d8                	mov    %ebx,%eax
  801c27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
		fd_close(fd, 0);
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	6a 00                	push   $0x0
  801c33:	ff 75 f4             	push   -0xc(%ebp)
  801c36:	e8 58 f9 ff ff       	call   801593 <fd_close>
		return r;
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	eb e5                	jmp    801c25 <open+0x6c>
		return -E_BAD_PATH;
  801c40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c45:	eb de                	jmp    801c25 <open+0x6c>

00801c47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c52:	b8 08 00 00 00       	mov    $0x8,%eax
  801c57:	e8 a6 fd ff ff       	call   801a02 <fsipc>
}
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c66:	83 ec 0c             	sub    $0xc,%esp
  801c69:	ff 75 08             	push   0x8(%ebp)
  801c6c:	e8 1a f8 ff ff       	call   80148b <fd2data>
  801c71:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c73:	83 c4 08             	add    $0x8,%esp
  801c76:	68 a7 2b 80 00       	push   $0x802ba7
  801c7b:	53                   	push   %ebx
  801c7c:	e8 19 f1 ff ff       	call   800d9a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c81:	8b 46 04             	mov    0x4(%esi),%eax
  801c84:	2b 06                	sub    (%esi),%eax
  801c86:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c8c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c93:	00 00 00 
	stat->st_dev = &devpipe;
  801c96:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c9d:	30 80 00 
	return 0;
}
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	53                   	push   %ebx
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cb6:	53                   	push   %ebx
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 5d f5 ff ff       	call   80121b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cbe:	89 1c 24             	mov    %ebx,(%esp)
  801cc1:	e8 c5 f7 ff ff       	call   80148b <fd2data>
  801cc6:	83 c4 08             	add    $0x8,%esp
  801cc9:	50                   	push   %eax
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 4a f5 ff ff       	call   80121b <sys_page_unmap>
}
  801cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <_pipeisclosed>:
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	57                   	push   %edi
  801cda:	56                   	push   %esi
  801cdb:	53                   	push   %ebx
  801cdc:	83 ec 1c             	sub    $0x1c,%esp
  801cdf:	89 c7                	mov    %eax,%edi
  801ce1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ce3:	a1 00 40 80 00       	mov    0x804000,%eax
  801ce8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	57                   	push   %edi
  801cef:	e8 28 04 00 00       	call   80211c <pageref>
  801cf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cf7:	89 34 24             	mov    %esi,(%esp)
  801cfa:	e8 1d 04 00 00       	call   80211c <pageref>
		nn = thisenv->env_runs;
  801cff:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d05:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	39 cb                	cmp    %ecx,%ebx
  801d0d:	74 1b                	je     801d2a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d0f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d12:	75 cf                	jne    801ce3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d14:	8b 42 58             	mov    0x58(%edx),%eax
  801d17:	6a 01                	push   $0x1
  801d19:	50                   	push   %eax
  801d1a:	53                   	push   %ebx
  801d1b:	68 ae 2b 80 00       	push   $0x802bae
  801d20:	e8 9b ea ff ff       	call   8007c0 <cprintf>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	eb b9                	jmp    801ce3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d2a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d2d:	0f 94 c0             	sete   %al
  801d30:	0f b6 c0             	movzbl %al,%eax
}
  801d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d36:	5b                   	pop    %ebx
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <devpipe_write>:
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	57                   	push   %edi
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 28             	sub    $0x28,%esp
  801d44:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d47:	56                   	push   %esi
  801d48:	e8 3e f7 ff ff       	call   80148b <fd2data>
  801d4d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	bf 00 00 00 00       	mov    $0x0,%edi
  801d57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d5a:	75 09                	jne    801d65 <devpipe_write+0x2a>
	return i;
  801d5c:	89 f8                	mov    %edi,%eax
  801d5e:	eb 23                	jmp    801d83 <devpipe_write+0x48>
			sys_yield();
  801d60:	e8 12 f4 ff ff       	call   801177 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d65:	8b 43 04             	mov    0x4(%ebx),%eax
  801d68:	8b 0b                	mov    (%ebx),%ecx
  801d6a:	8d 51 20             	lea    0x20(%ecx),%edx
  801d6d:	39 d0                	cmp    %edx,%eax
  801d6f:	72 1a                	jb     801d8b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801d71:	89 da                	mov    %ebx,%edx
  801d73:	89 f0                	mov    %esi,%eax
  801d75:	e8 5c ff ff ff       	call   801cd6 <_pipeisclosed>
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	74 e2                	je     801d60 <devpipe_write+0x25>
				return 0;
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5f                   	pop    %edi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d95:	89 c2                	mov    %eax,%edx
  801d97:	c1 fa 1f             	sar    $0x1f,%edx
  801d9a:	89 d1                	mov    %edx,%ecx
  801d9c:	c1 e9 1b             	shr    $0x1b,%ecx
  801d9f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801da2:	83 e2 1f             	and    $0x1f,%edx
  801da5:	29 ca                	sub    %ecx,%edx
  801da7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801daf:	83 c0 01             	add    $0x1,%eax
  801db2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801db5:	83 c7 01             	add    $0x1,%edi
  801db8:	eb 9d                	jmp    801d57 <devpipe_write+0x1c>

00801dba <devpipe_read>:
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	57                   	push   %edi
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
  801dc0:	83 ec 18             	sub    $0x18,%esp
  801dc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801dc6:	57                   	push   %edi
  801dc7:	e8 bf f6 ff ff       	call   80148b <fd2data>
  801dcc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	be 00 00 00 00       	mov    $0x0,%esi
  801dd6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd9:	75 13                	jne    801dee <devpipe_read+0x34>
	return i;
  801ddb:	89 f0                	mov    %esi,%eax
  801ddd:	eb 02                	jmp    801de1 <devpipe_read+0x27>
				return i;
  801ddf:	89 f0                	mov    %esi,%eax
}
  801de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
			sys_yield();
  801de9:	e8 89 f3 ff ff       	call   801177 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dee:	8b 03                	mov    (%ebx),%eax
  801df0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801df3:	75 18                	jne    801e0d <devpipe_read+0x53>
			if (i > 0)
  801df5:	85 f6                	test   %esi,%esi
  801df7:	75 e6                	jne    801ddf <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801df9:	89 da                	mov    %ebx,%edx
  801dfb:	89 f8                	mov    %edi,%eax
  801dfd:	e8 d4 fe ff ff       	call   801cd6 <_pipeisclosed>
  801e02:	85 c0                	test   %eax,%eax
  801e04:	74 e3                	je     801de9 <devpipe_read+0x2f>
				return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0b:	eb d4                	jmp    801de1 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e0d:	99                   	cltd   
  801e0e:	c1 ea 1b             	shr    $0x1b,%edx
  801e11:	01 d0                	add    %edx,%eax
  801e13:	83 e0 1f             	and    $0x1f,%eax
  801e16:	29 d0                	sub    %edx,%eax
  801e18:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e20:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e23:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e26:	83 c6 01             	add    $0x1,%esi
  801e29:	eb ab                	jmp    801dd6 <devpipe_read+0x1c>

00801e2b <pipe>:
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	e8 66 f6 ff ff       	call   8014a2 <fd_alloc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	85 c0                	test   %eax,%eax
  801e43:	0f 88 23 01 00 00    	js     801f6c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e49:	83 ec 04             	sub    $0x4,%esp
  801e4c:	68 07 04 00 00       	push   $0x407
  801e51:	ff 75 f4             	push   -0xc(%ebp)
  801e54:	6a 00                	push   $0x0
  801e56:	e8 3b f3 ff ff       	call   801196 <sys_page_alloc>
  801e5b:	89 c3                	mov    %eax,%ebx
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	0f 88 04 01 00 00    	js     801f6c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801e68:	83 ec 0c             	sub    $0xc,%esp
  801e6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e6e:	50                   	push   %eax
  801e6f:	e8 2e f6 ff ff       	call   8014a2 <fd_alloc>
  801e74:	89 c3                	mov    %eax,%ebx
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	0f 88 db 00 00 00    	js     801f5c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	68 07 04 00 00       	push   $0x407
  801e89:	ff 75 f0             	push   -0x10(%ebp)
  801e8c:	6a 00                	push   $0x0
  801e8e:	e8 03 f3 ff ff       	call   801196 <sys_page_alloc>
  801e93:	89 c3                	mov    %eax,%ebx
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 bc 00 00 00    	js     801f5c <pipe+0x131>
	va = fd2data(fd0);
  801ea0:	83 ec 0c             	sub    $0xc,%esp
  801ea3:	ff 75 f4             	push   -0xc(%ebp)
  801ea6:	e8 e0 f5 ff ff       	call   80148b <fd2data>
  801eab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ead:	83 c4 0c             	add    $0xc,%esp
  801eb0:	68 07 04 00 00       	push   $0x407
  801eb5:	50                   	push   %eax
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 d9 f2 ff ff       	call   801196 <sys_page_alloc>
  801ebd:	89 c3                	mov    %eax,%ebx
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	0f 88 82 00 00 00    	js     801f4c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	ff 75 f0             	push   -0x10(%ebp)
  801ed0:	e8 b6 f5 ff ff       	call   80148b <fd2data>
  801ed5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	56                   	push   %esi
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 f2 f2 ff ff       	call   8011d9 <sys_page_map>
  801ee7:	89 c3                	mov    %eax,%ebx
  801ee9:	83 c4 20             	add    $0x20,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 4e                	js     801f3e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801ef0:	a1 24 30 80 00       	mov    0x803024,%eax
  801ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ef8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801efa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801efd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f07:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	ff 75 f4             	push   -0xc(%ebp)
  801f19:	e8 5d f5 ff ff       	call   80147b <fd2num>
  801f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f21:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f23:	83 c4 04             	add    $0x4,%esp
  801f26:	ff 75 f0             	push   -0x10(%ebp)
  801f29:	e8 4d f5 ff ff       	call   80147b <fd2num>
  801f2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f31:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f3c:	eb 2e                	jmp    801f6c <pipe+0x141>
	sys_page_unmap(0, va);
  801f3e:	83 ec 08             	sub    $0x8,%esp
  801f41:	56                   	push   %esi
  801f42:	6a 00                	push   $0x0
  801f44:	e8 d2 f2 ff ff       	call   80121b <sys_page_unmap>
  801f49:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f4c:	83 ec 08             	sub    $0x8,%esp
  801f4f:	ff 75 f0             	push   -0x10(%ebp)
  801f52:	6a 00                	push   $0x0
  801f54:	e8 c2 f2 ff ff       	call   80121b <sys_page_unmap>
  801f59:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f5c:	83 ec 08             	sub    $0x8,%esp
  801f5f:	ff 75 f4             	push   -0xc(%ebp)
  801f62:	6a 00                	push   $0x0
  801f64:	e8 b2 f2 ff ff       	call   80121b <sys_page_unmap>
  801f69:	83 c4 10             	add    $0x10,%esp
}
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5e                   	pop    %esi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <pipeisclosed>:
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7e:	50                   	push   %eax
  801f7f:	ff 75 08             	push   0x8(%ebp)
  801f82:	e8 6b f5 ff ff       	call   8014f2 <fd_lookup>
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	78 18                	js     801fa6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	ff 75 f4             	push   -0xc(%ebp)
  801f94:	e8 f2 f4 ff ff       	call   80148b <fd2data>
  801f99:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9e:	e8 33 fd ff ff       	call   801cd6 <_pipeisclosed>
  801fa3:	83 c4 10             	add    $0x10,%esp
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fad:	c3                   	ret    

00801fae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fb4:	68 c6 2b 80 00       	push   $0x802bc6
  801fb9:	ff 75 0c             	push   0xc(%ebp)
  801fbc:	e8 d9 ed ff ff       	call   800d9a <strcpy>
	return 0;
}
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devcons_write>:
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	57                   	push   %edi
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fd4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fd9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fdf:	eb 2e                	jmp    80200f <devcons_write+0x47>
		m = n - tot;
  801fe1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fe4:	29 f3                	sub    %esi,%ebx
  801fe6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801feb:	39 c3                	cmp    %eax,%ebx
  801fed:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ff0:	83 ec 04             	sub    $0x4,%esp
  801ff3:	53                   	push   %ebx
  801ff4:	89 f0                	mov    %esi,%eax
  801ff6:	03 45 0c             	add    0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	57                   	push   %edi
  801ffb:	e8 30 ef ff ff       	call   800f30 <memmove>
		sys_cputs(buf, m);
  802000:	83 c4 08             	add    $0x8,%esp
  802003:	53                   	push   %ebx
  802004:	57                   	push   %edi
  802005:	e8 d0 f0 ff ff       	call   8010da <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80200a:	01 de                	add    %ebx,%esi
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802012:	72 cd                	jb     801fe1 <devcons_write+0x19>
}
  802014:	89 f0                	mov    %esi,%eax
  802016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5f                   	pop    %edi
  80201c:	5d                   	pop    %ebp
  80201d:	c3                   	ret    

0080201e <devcons_read>:
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	83 ec 08             	sub    $0x8,%esp
  802024:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802029:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80202d:	75 07                	jne    802036 <devcons_read+0x18>
  80202f:	eb 1f                	jmp    802050 <devcons_read+0x32>
		sys_yield();
  802031:	e8 41 f1 ff ff       	call   801177 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802036:	e8 bd f0 ff ff       	call   8010f8 <sys_cgetc>
  80203b:	85 c0                	test   %eax,%eax
  80203d:	74 f2                	je     802031 <devcons_read+0x13>
	if (c < 0)
  80203f:	78 0f                	js     802050 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802041:	83 f8 04             	cmp    $0x4,%eax
  802044:	74 0c                	je     802052 <devcons_read+0x34>
	*(char*)vbuf = c;
  802046:	8b 55 0c             	mov    0xc(%ebp),%edx
  802049:	88 02                	mov    %al,(%edx)
	return 1;
  80204b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802050:	c9                   	leave  
  802051:	c3                   	ret    
		return 0;
  802052:	b8 00 00 00 00       	mov    $0x0,%eax
  802057:	eb f7                	jmp    802050 <devcons_read+0x32>

00802059 <cputchar>:
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80205f:	8b 45 08             	mov    0x8(%ebp),%eax
  802062:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802065:	6a 01                	push   $0x1
  802067:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	e8 6a f0 ff ff       	call   8010da <sys_cputs>
}
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <getchar>:
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80207b:	6a 01                	push   $0x1
  80207d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802080:	50                   	push   %eax
  802081:	6a 00                	push   $0x0
  802083:	e8 ce f6 ff ff       	call   801756 <read>
	if (r < 0)
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	85 c0                	test   %eax,%eax
  80208d:	78 06                	js     802095 <getchar+0x20>
	if (r < 1)
  80208f:	74 06                	je     802097 <getchar+0x22>
	return c;
  802091:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802095:	c9                   	leave  
  802096:	c3                   	ret    
		return -E_EOF;
  802097:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80209c:	eb f7                	jmp    802095 <getchar+0x20>

0080209e <iscons>:
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a7:	50                   	push   %eax
  8020a8:	ff 75 08             	push   0x8(%ebp)
  8020ab:	e8 42 f4 ff ff       	call   8014f2 <fd_lookup>
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	78 11                	js     8020c8 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8020b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ba:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020c0:	39 10                	cmp    %edx,(%eax)
  8020c2:	0f 94 c0             	sete   %al
  8020c5:	0f b6 c0             	movzbl %al,%eax
}
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <opencons>:
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	e8 c9 f3 ff ff       	call   8014a2 <fd_alloc>
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	78 3a                	js     80211a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e0:	83 ec 04             	sub    $0x4,%esp
  8020e3:	68 07 04 00 00       	push   $0x407
  8020e8:	ff 75 f4             	push   -0xc(%ebp)
  8020eb:	6a 00                	push   $0x0
  8020ed:	e8 a4 f0 ff ff       	call   801196 <sys_page_alloc>
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 21                	js     80211a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802102:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802107:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80210e:	83 ec 0c             	sub    $0xc,%esp
  802111:	50                   	push   %eax
  802112:	e8 64 f3 ff ff       	call   80147b <fd2num>
  802117:	83 c4 10             	add    $0x10,%esp
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802122:	89 c2                	mov    %eax,%edx
  802124:	c1 ea 16             	shr    $0x16,%edx
  802127:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80212e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802133:	f6 c1 01             	test   $0x1,%cl
  802136:	74 1c                	je     802154 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802138:	c1 e8 0c             	shr    $0xc,%eax
  80213b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802142:	a8 01                	test   $0x1,%al
  802144:	74 0e                	je     802154 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802146:	c1 e8 0c             	shr    $0xc,%eax
  802149:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802150:	ef 
  802151:	0f b7 d2             	movzwl %dx,%edx
}
  802154:	89 d0                	mov    %edx,%eax
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	f3 0f 1e fb          	endbr32 
  802164:	55                   	push   %ebp
  802165:	57                   	push   %edi
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	83 ec 1c             	sub    $0x1c,%esp
  80216b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80216f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802173:	8b 74 24 34          	mov    0x34(%esp),%esi
  802177:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80217b:	85 c0                	test   %eax,%eax
  80217d:	75 19                	jne    802198 <__udivdi3+0x38>
  80217f:	39 f3                	cmp    %esi,%ebx
  802181:	76 4d                	jbe    8021d0 <__udivdi3+0x70>
  802183:	31 ff                	xor    %edi,%edi
  802185:	89 e8                	mov    %ebp,%eax
  802187:	89 f2                	mov    %esi,%edx
  802189:	f7 f3                	div    %ebx
  80218b:	89 fa                	mov    %edi,%edx
  80218d:	83 c4 1c             	add    $0x1c,%esp
  802190:	5b                   	pop    %ebx
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	39 f0                	cmp    %esi,%eax
  80219a:	76 14                	jbe    8021b0 <__udivdi3+0x50>
  80219c:	31 ff                	xor    %edi,%edi
  80219e:	31 c0                	xor    %eax,%eax
  8021a0:	89 fa                	mov    %edi,%edx
  8021a2:	83 c4 1c             	add    $0x1c,%esp
  8021a5:	5b                   	pop    %ebx
  8021a6:	5e                   	pop    %esi
  8021a7:	5f                   	pop    %edi
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    
  8021aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b0:	0f bd f8             	bsr    %eax,%edi
  8021b3:	83 f7 1f             	xor    $0x1f,%edi
  8021b6:	75 48                	jne    802200 <__udivdi3+0xa0>
  8021b8:	39 f0                	cmp    %esi,%eax
  8021ba:	72 06                	jb     8021c2 <__udivdi3+0x62>
  8021bc:	31 c0                	xor    %eax,%eax
  8021be:	39 eb                	cmp    %ebp,%ebx
  8021c0:	77 de                	ja     8021a0 <__udivdi3+0x40>
  8021c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c7:	eb d7                	jmp    8021a0 <__udivdi3+0x40>
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d9                	mov    %ebx,%ecx
  8021d2:	85 db                	test   %ebx,%ebx
  8021d4:	75 0b                	jne    8021e1 <__udivdi3+0x81>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f3                	div    %ebx
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	31 d2                	xor    %edx,%edx
  8021e3:	89 f0                	mov    %esi,%eax
  8021e5:	f7 f1                	div    %ecx
  8021e7:	89 c6                	mov    %eax,%esi
  8021e9:	89 e8                	mov    %ebp,%eax
  8021eb:	89 f7                	mov    %esi,%edi
  8021ed:	f7 f1                	div    %ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 f9                	mov    %edi,%ecx
  802202:	ba 20 00 00 00       	mov    $0x20,%edx
  802207:	29 fa                	sub    %edi,%edx
  802209:	d3 e0                	shl    %cl,%eax
  80220b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80220f:	89 d1                	mov    %edx,%ecx
  802211:	89 d8                	mov    %ebx,%eax
  802213:	d3 e8                	shr    %cl,%eax
  802215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802219:	09 c1                	or     %eax,%ecx
  80221b:	89 f0                	mov    %esi,%eax
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e3                	shl    %cl,%ebx
  802225:	89 d1                	mov    %edx,%ecx
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 f9                	mov    %edi,%ecx
  80222b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80222f:	89 eb                	mov    %ebp,%ebx
  802231:	d3 e6                	shl    %cl,%esi
  802233:	89 d1                	mov    %edx,%ecx
  802235:	d3 eb                	shr    %cl,%ebx
  802237:	09 f3                	or     %esi,%ebx
  802239:	89 c6                	mov    %eax,%esi
  80223b:	89 f2                	mov    %esi,%edx
  80223d:	89 d8                	mov    %ebx,%eax
  80223f:	f7 74 24 08          	divl   0x8(%esp)
  802243:	89 d6                	mov    %edx,%esi
  802245:	89 c3                	mov    %eax,%ebx
  802247:	f7 64 24 0c          	mull   0xc(%esp)
  80224b:	39 d6                	cmp    %edx,%esi
  80224d:	72 19                	jb     802268 <__udivdi3+0x108>
  80224f:	89 f9                	mov    %edi,%ecx
  802251:	d3 e5                	shl    %cl,%ebp
  802253:	39 c5                	cmp    %eax,%ebp
  802255:	73 04                	jae    80225b <__udivdi3+0xfb>
  802257:	39 d6                	cmp    %edx,%esi
  802259:	74 0d                	je     802268 <__udivdi3+0x108>
  80225b:	89 d8                	mov    %ebx,%eax
  80225d:	31 ff                	xor    %edi,%edi
  80225f:	e9 3c ff ff ff       	jmp    8021a0 <__udivdi3+0x40>
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80226b:	31 ff                	xor    %edi,%edi
  80226d:	e9 2e ff ff ff       	jmp    8021a0 <__udivdi3+0x40>
  802272:	66 90                	xchg   %ax,%ax
  802274:	66 90                	xchg   %ax,%ax
  802276:	66 90                	xchg   %ax,%ax
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__umoddi3>:
  802280:	f3 0f 1e fb          	endbr32 
  802284:	55                   	push   %ebp
  802285:	57                   	push   %edi
  802286:	56                   	push   %esi
  802287:	53                   	push   %ebx
  802288:	83 ec 1c             	sub    $0x1c,%esp
  80228b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80228f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802293:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802297:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80229b:	89 f0                	mov    %esi,%eax
  80229d:	89 da                	mov    %ebx,%edx
  80229f:	85 ff                	test   %edi,%edi
  8022a1:	75 15                	jne    8022b8 <__umoddi3+0x38>
  8022a3:	39 dd                	cmp    %ebx,%ebp
  8022a5:	76 39                	jbe    8022e0 <__umoddi3+0x60>
  8022a7:	f7 f5                	div    %ebp
  8022a9:	89 d0                	mov    %edx,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	83 c4 1c             	add    $0x1c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
  8022b5:	8d 76 00             	lea    0x0(%esi),%esi
  8022b8:	39 df                	cmp    %ebx,%edi
  8022ba:	77 f1                	ja     8022ad <__umoddi3+0x2d>
  8022bc:	0f bd cf             	bsr    %edi,%ecx
  8022bf:	83 f1 1f             	xor    $0x1f,%ecx
  8022c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022c6:	75 40                	jne    802308 <__umoddi3+0x88>
  8022c8:	39 df                	cmp    %ebx,%edi
  8022ca:	72 04                	jb     8022d0 <__umoddi3+0x50>
  8022cc:	39 f5                	cmp    %esi,%ebp
  8022ce:	77 dd                	ja     8022ad <__umoddi3+0x2d>
  8022d0:	89 da                	mov    %ebx,%edx
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	29 e8                	sub    %ebp,%eax
  8022d6:	19 fa                	sbb    %edi,%edx
  8022d8:	eb d3                	jmp    8022ad <__umoddi3+0x2d>
  8022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e0:	89 e9                	mov    %ebp,%ecx
  8022e2:	85 ed                	test   %ebp,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x71>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f5                	div    %ebp
  8022ef:	89 c1                	mov    %eax,%ecx
  8022f1:	89 d8                	mov    %ebx,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f1                	div    %ecx
  8022f7:	89 f0                	mov    %esi,%eax
  8022f9:	f7 f1                	div    %ecx
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	eb ac                	jmp    8022ad <__umoddi3+0x2d>
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	8b 44 24 04          	mov    0x4(%esp),%eax
  80230c:	ba 20 00 00 00       	mov    $0x20,%edx
  802311:	29 c2                	sub    %eax,%edx
  802313:	89 c1                	mov    %eax,%ecx
  802315:	89 e8                	mov    %ebp,%eax
  802317:	d3 e7                	shl    %cl,%edi
  802319:	89 d1                	mov    %edx,%ecx
  80231b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80231f:	d3 e8                	shr    %cl,%eax
  802321:	89 c1                	mov    %eax,%ecx
  802323:	8b 44 24 04          	mov    0x4(%esp),%eax
  802327:	09 f9                	or     %edi,%ecx
  802329:	89 df                	mov    %ebx,%edi
  80232b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232f:	89 c1                	mov    %eax,%ecx
  802331:	d3 e5                	shl    %cl,%ebp
  802333:	89 d1                	mov    %edx,%ecx
  802335:	d3 ef                	shr    %cl,%edi
  802337:	89 c1                	mov    %eax,%ecx
  802339:	89 f0                	mov    %esi,%eax
  80233b:	d3 e3                	shl    %cl,%ebx
  80233d:	89 d1                	mov    %edx,%ecx
  80233f:	89 fa                	mov    %edi,%edx
  802341:	d3 e8                	shr    %cl,%eax
  802343:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802348:	09 d8                	or     %ebx,%eax
  80234a:	f7 74 24 08          	divl   0x8(%esp)
  80234e:	89 d3                	mov    %edx,%ebx
  802350:	d3 e6                	shl    %cl,%esi
  802352:	f7 e5                	mul    %ebp
  802354:	89 c7                	mov    %eax,%edi
  802356:	89 d1                	mov    %edx,%ecx
  802358:	39 d3                	cmp    %edx,%ebx
  80235a:	72 06                	jb     802362 <__umoddi3+0xe2>
  80235c:	75 0e                	jne    80236c <__umoddi3+0xec>
  80235e:	39 c6                	cmp    %eax,%esi
  802360:	73 0a                	jae    80236c <__umoddi3+0xec>
  802362:	29 e8                	sub    %ebp,%eax
  802364:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802368:	89 d1                	mov    %edx,%ecx
  80236a:	89 c7                	mov    %eax,%edi
  80236c:	89 f5                	mov    %esi,%ebp
  80236e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802372:	29 fd                	sub    %edi,%ebp
  802374:	19 cb                	sbb    %ecx,%ebx
  802376:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	d3 e0                	shl    %cl,%eax
  80237f:	89 f1                	mov    %esi,%ecx
  802381:	d3 ed                	shr    %cl,%ebp
  802383:	d3 eb                	shr    %cl,%ebx
  802385:	09 e8                	or     %ebp,%eax
  802387:	89 da                	mov    %ebx,%edx
  802389:	83 c4 1c             	add    $0x1c,%esp
  80238c:	5b                   	pop    %ebx
  80238d:	5e                   	pop    %esi
  80238e:	5f                   	pop    %edi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    
