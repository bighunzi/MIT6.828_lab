
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
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 56 0d 00 00       	call   800d9d <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 56 14 00 00       	call   8014af <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 f3 13 00 00       	call   80145b <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 72 13 00 00       	call   8013eb <ipc_recv>
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
  80008f:	b8 80 28 80 00       	mov    $0x802880,%eax
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
  8000b3:	b8 b5 28 80 00       	mov    $0x8028b5,%eax
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
  8000ef:	68 d6 28 80 00       	push   $0x8028d6
  8000f4:	e8 ca 06 00 00       	call   8007c3 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000f9:	83 c4 08             	add    $0x8,%esp
  8000fc:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800102:	50                   	push   %eax
  800103:	68 00 c0 cc cc       	push   $0xccccc000
  800108:	ff 15 1c 40 80 00    	call   *0x80401c
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	0f 88 c2 03 00 00    	js     8004db <umain+0x45d>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	ff 35 00 40 80 00    	push   0x804000
  800122:	e8 3b 0c 00 00       	call   800d62 <strlen>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80012d:	0f 85 ba 03 00 00    	jne    8004ed <umain+0x46f>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 f8 28 80 00       	push   $0x8028f8
  80013b:	e8 83 06 00 00       	call   8007c3 <cprintf>

	memset(buf, 0, sizeof buf);
  800140:	83 c4 0c             	add    $0xc,%esp
  800143:	68 00 02 00 00       	push   $0x200
  800148:	6a 00                	push   $0x0
  80014a:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800150:	53                   	push   %ebx
  800151:	e8 97 0d 00 00       	call   800eed <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800156:	83 c4 0c             	add    $0xc,%esp
  800159:	68 00 02 00 00       	push   $0x200
  80015e:	53                   	push   %ebx
  80015f:	68 00 c0 cc cc       	push   $0xccccc000
  800164:	ff 15 10 40 80 00    	call   *0x804010
  80016a:	83 c4 10             	add    $0x10,%esp
  80016d:	85 c0                	test   %eax,%eax
  80016f:	0f 88 9d 03 00 00    	js     800512 <umain+0x494>
		panic("file_read: %e", r);
	if (strcmp(buf, msg) != 0)
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	ff 35 00 40 80 00    	push   0x804000
  80017e:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	e8 c4 0c 00 00       	call   800e4e <strcmp>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	85 c0                	test   %eax,%eax
  80018f:	0f 85 8f 03 00 00    	jne    800524 <umain+0x4a6>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	68 37 29 80 00       	push   $0x802937
  80019d:	e8 21 06 00 00       	call   8007c3 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001a9:	ff 15 18 40 80 00    	call   *0x804018
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	85 c0                	test   %eax,%eax
  8001b4:	0f 88 7e 03 00 00    	js     800538 <umain+0x4ba>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	68 59 29 80 00       	push   $0x802959
  8001c2:	e8 fc 05 00 00       	call   8007c3 <cprintf>

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
  8001f1:	e8 28 10 00 00       	call   80121e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	68 00 02 00 00       	push   $0x200
  8001fe:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800204:	50                   	push   %eax
  800205:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	ff 15 10 40 80 00    	call   *0x804010
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800215:	0f 85 2f 03 00 00    	jne    80054a <umain+0x4cc>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 6d 29 80 00       	push   $0x80296d
  800223:	e8 9b 05 00 00       	call   8007c3 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800228:	ba 02 01 00 00       	mov    $0x102,%edx
  80022d:	b8 83 29 80 00       	mov    $0x802983,%eax
  800232:	e8 fc fd ff ff       	call   800033 <xopen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	0f 88 1a 03 00 00    	js     80055c <umain+0x4de>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800242:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	ff 35 00 40 80 00    	push   0x804000
  800251:	e8 0c 0b 00 00       	call   800d62 <strlen>
  800256:	83 c4 0c             	add    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	ff 35 00 40 80 00    	push   0x804000
  800260:	68 00 c0 cc cc       	push   $0xccccc000
  800265:	ff d3                	call   *%ebx
  800267:	89 c3                	mov    %eax,%ebx
  800269:	83 c4 04             	add    $0x4,%esp
  80026c:	ff 35 00 40 80 00    	push   0x804000
  800272:	e8 eb 0a 00 00       	call   800d62 <strlen>
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	39 d8                	cmp    %ebx,%eax
  80027c:	0f 85 ec 02 00 00    	jne    80056e <umain+0x4f0>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	68 b5 29 80 00       	push   $0x8029b5
  80028a:	e8 34 05 00 00       	call   8007c3 <cprintf>

	FVA->fd_offset = 0;
  80028f:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800296:	00 00 00 
	memset(buf, 0, sizeof buf);
  800299:	83 c4 0c             	add    $0xc,%esp
  80029c:	68 00 02 00 00       	push   $0x200
  8002a1:	6a 00                	push   $0x0
  8002a3:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002a9:	53                   	push   %ebx
  8002aa:	e8 3e 0c 00 00       	call   800eed <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002af:	83 c4 0c             	add    $0xc,%esp
  8002b2:	68 00 02 00 00       	push   $0x200
  8002b7:	53                   	push   %ebx
  8002b8:	68 00 c0 cc cc       	push   $0xccccc000
  8002bd:	ff 15 10 40 80 00    	call   *0x804010
  8002c3:	89 c3                	mov    %eax,%ebx
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	0f 88 b0 02 00 00    	js     800580 <umain+0x502>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 35 00 40 80 00    	push   0x804000
  8002d9:	e8 84 0a 00 00       	call   800d62 <strlen>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	39 d8                	cmp    %ebx,%eax
  8002e3:	0f 85 a9 02 00 00    	jne    800592 <umain+0x514>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 35 00 40 80 00    	push   0x804000
  8002f2:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002f8:	50                   	push   %eax
  8002f9:	e8 50 0b 00 00       	call   800e4e <strcmp>
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	85 c0                	test   %eax,%eax
  800303:	0f 85 9b 02 00 00    	jne    8005a4 <umain+0x526>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	68 7c 2b 80 00       	push   $0x802b7c
  800311:	e8 ad 04 00 00       	call   8007c3 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800316:	83 c4 08             	add    $0x8,%esp
  800319:	6a 00                	push   $0x0
  80031b:	68 80 28 80 00       	push   $0x802880
  800320:	e8 0c 19 00 00       	call   801c31 <open>
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
  800342:	68 b5 28 80 00       	push   $0x8028b5
  800347:	e8 e5 18 00 00       	call   801c31 <open>
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
  800385:	68 dc 28 80 00       	push   $0x8028dc
  80038a:	e8 34 04 00 00       	call   8007c3 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	68 01 01 00 00       	push   $0x101
  800397:	68 e4 29 80 00       	push   $0x8029e4
  80039c:	e8 90 18 00 00       	call   801c31 <open>
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
  8003bf:	e8 29 0b 00 00       	call   800eed <memset>
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
  8003df:	e8 b8 14 00 00       	call   80189c <write>
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
  800401:	e8 8c 12 00 00       	call   801692 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800406:	83 c4 08             	add    $0x8,%esp
  800409:	6a 00                	push   $0x0
  80040b:	68 e4 29 80 00       	push   $0x8029e4
  800410:	e8 1c 18 00 00       	call   801c31 <open>
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
  800438:	e8 18 14 00 00       	call   801855 <readn>
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
  800473:	e8 1a 12 00 00       	call   801692 <close>
	cprintf("large file is good\n");
  800478:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
  80047f:	e8 3f 03 00 00       	call   8007c3 <cprintf>
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
  800490:	68 8b 28 80 00       	push   $0x80288b
  800495:	6a 20                	push   $0x20
  800497:	68 a5 28 80 00       	push   $0x8028a5
  80049c:	e8 47 02 00 00       	call   8006e8 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	68 40 2a 80 00       	push   $0x802a40
  8004a9:	6a 22                	push   $0x22
  8004ab:	68 a5 28 80 00       	push   $0x8028a5
  8004b0:	e8 33 02 00 00       	call   8006e8 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b5:	50                   	push   %eax
  8004b6:	68 be 28 80 00       	push   $0x8028be
  8004bb:	6a 25                	push   $0x25
  8004bd:	68 a5 28 80 00       	push   $0x8028a5
  8004c2:	e8 21 02 00 00       	call   8006e8 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004c7:	83 ec 04             	sub    $0x4,%esp
  8004ca:	68 64 2a 80 00       	push   $0x802a64
  8004cf:	6a 27                	push   $0x27
  8004d1:	68 a5 28 80 00       	push   $0x8028a5
  8004d6:	e8 0d 02 00 00       	call   8006e8 <_panic>
		panic("file_stat: %e", r);
  8004db:	50                   	push   %eax
  8004dc:	68 ea 28 80 00       	push   $0x8028ea
  8004e1:	6a 2b                	push   $0x2b
  8004e3:	68 a5 28 80 00       	push   $0x8028a5
  8004e8:	e8 fb 01 00 00       	call   8006e8 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004ed:	83 ec 0c             	sub    $0xc,%esp
  8004f0:	ff 35 00 40 80 00    	push   0x804000
  8004f6:	e8 67 08 00 00       	call   800d62 <strlen>
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 75 cc             	push   -0x34(%ebp)
  800501:	68 94 2a 80 00       	push   $0x802a94
  800506:	6a 2d                	push   $0x2d
  800508:	68 a5 28 80 00       	push   $0x8028a5
  80050d:	e8 d6 01 00 00       	call   8006e8 <_panic>
		panic("file_read: %e", r);
  800512:	50                   	push   %eax
  800513:	68 0b 29 80 00       	push   $0x80290b
  800518:	6a 32                	push   $0x32
  80051a:	68 a5 28 80 00       	push   $0x8028a5
  80051f:	e8 c4 01 00 00       	call   8006e8 <_panic>
		panic("file_read returned wrong data");
  800524:	83 ec 04             	sub    $0x4,%esp
  800527:	68 19 29 80 00       	push   $0x802919
  80052c:	6a 34                	push   $0x34
  80052e:	68 a5 28 80 00       	push   $0x8028a5
  800533:	e8 b0 01 00 00       	call   8006e8 <_panic>
		panic("file_close: %e", r);
  800538:	50                   	push   %eax
  800539:	68 4a 29 80 00       	push   $0x80294a
  80053e:	6a 38                	push   $0x38
  800540:	68 a5 28 80 00       	push   $0x8028a5
  800545:	e8 9e 01 00 00       	call   8006e8 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054a:	50                   	push   %eax
  80054b:	68 bc 2a 80 00       	push   $0x802abc
  800550:	6a 43                	push   $0x43
  800552:	68 a5 28 80 00       	push   $0x8028a5
  800557:	e8 8c 01 00 00       	call   8006e8 <_panic>
		panic("serve_open /new-file: %e", r);
  80055c:	50                   	push   %eax
  80055d:	68 8d 29 80 00       	push   $0x80298d
  800562:	6a 48                	push   $0x48
  800564:	68 a5 28 80 00       	push   $0x8028a5
  800569:	e8 7a 01 00 00       	call   8006e8 <_panic>
		panic("file_write: %e", r);
  80056e:	53                   	push   %ebx
  80056f:	68 a6 29 80 00       	push   $0x8029a6
  800574:	6a 4b                	push   $0x4b
  800576:	68 a5 28 80 00       	push   $0x8028a5
  80057b:	e8 68 01 00 00       	call   8006e8 <_panic>
		panic("file_read after file_write: %e", r);
  800580:	50                   	push   %eax
  800581:	68 f4 2a 80 00       	push   $0x802af4
  800586:	6a 51                	push   $0x51
  800588:	68 a5 28 80 00       	push   $0x8028a5
  80058d:	e8 56 01 00 00       	call   8006e8 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800592:	53                   	push   %ebx
  800593:	68 14 2b 80 00       	push   $0x802b14
  800598:	6a 53                	push   $0x53
  80059a:	68 a5 28 80 00       	push   $0x8028a5
  80059f:	e8 44 01 00 00       	call   8006e8 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	68 4c 2b 80 00       	push   $0x802b4c
  8005ac:	6a 55                	push   $0x55
  8005ae:	68 a5 28 80 00       	push   $0x8028a5
  8005b3:	e8 30 01 00 00       	call   8006e8 <_panic>
		panic("open /not-found: %e", r);
  8005b8:	50                   	push   %eax
  8005b9:	68 91 28 80 00       	push   $0x802891
  8005be:	6a 5a                	push   $0x5a
  8005c0:	68 a5 28 80 00       	push   $0x8028a5
  8005c5:	e8 1e 01 00 00       	call   8006e8 <_panic>
		panic("open /not-found succeeded!");
  8005ca:	83 ec 04             	sub    $0x4,%esp
  8005cd:	68 c9 29 80 00       	push   $0x8029c9
  8005d2:	6a 5c                	push   $0x5c
  8005d4:	68 a5 28 80 00       	push   $0x8028a5
  8005d9:	e8 0a 01 00 00       	call   8006e8 <_panic>
		panic("open /newmotd: %e", r);
  8005de:	50                   	push   %eax
  8005df:	68 c4 28 80 00       	push   $0x8028c4
  8005e4:	6a 5f                	push   $0x5f
  8005e6:	68 a5 28 80 00       	push   $0x8028a5
  8005eb:	e8 f8 00 00 00       	call   8006e8 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f0:	83 ec 04             	sub    $0x4,%esp
  8005f3:	68 a0 2b 80 00       	push   $0x802ba0
  8005f8:	6a 62                	push   $0x62
  8005fa:	68 a5 28 80 00       	push   $0x8028a5
  8005ff:	e8 e4 00 00 00       	call   8006e8 <_panic>
		panic("creat /big: %e", f);
  800604:	50                   	push   %eax
  800605:	68 e9 29 80 00       	push   $0x8029e9
  80060a:	6a 67                	push   $0x67
  80060c:	68 a5 28 80 00       	push   $0x8028a5
  800611:	e8 d2 00 00 00       	call   8006e8 <_panic>
			panic("write /big@%d: %e", i, r);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	50                   	push   %eax
  80061a:	56                   	push   %esi
  80061b:	68 f8 29 80 00       	push   $0x8029f8
  800620:	6a 6c                	push   $0x6c
  800622:	68 a5 28 80 00       	push   $0x8028a5
  800627:	e8 bc 00 00 00       	call   8006e8 <_panic>
		panic("open /big: %e", f);
  80062c:	50                   	push   %eax
  80062d:	68 0a 2a 80 00       	push   $0x802a0a
  800632:	6a 71                	push   $0x71
  800634:	68 a5 28 80 00       	push   $0x8028a5
  800639:	e8 aa 00 00 00       	call   8006e8 <_panic>
			panic("read /big@%d: %e", i, r);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	68 18 2a 80 00       	push   $0x802a18
  800648:	6a 75                	push   $0x75
  80064a:	68 a5 28 80 00       	push   $0x8028a5
  80064f:	e8 94 00 00 00       	call   8006e8 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	68 00 02 00 00       	push   $0x200
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	68 c8 2b 80 00       	push   $0x802bc8
  800663:	6a 77                	push   $0x77
  800665:	68 a5 28 80 00       	push   $0x8028a5
  80066a:	e8 79 00 00 00       	call   8006e8 <_panic>
			panic("read /big from %d returned bad data %d",
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	50                   	push   %eax
  800673:	53                   	push   %ebx
  800674:	68 f4 2b 80 00       	push   $0x802bf4
  800679:	6a 7a                	push   $0x7a
  80067b:	68 a5 28 80 00       	push   $0x8028a5
  800680:	e8 63 00 00 00       	call   8006e8 <_panic>

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
  800690:	e8 c6 0a 00 00       	call   80115b <sys_getenvid>
  800695:	25 ff 03 00 00       	and    $0x3ff,%eax
  80069a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8006a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006a5:	a3 00 50 80 00       	mov    %eax,0x805000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006aa:	85 db                	test   %ebx,%ebx
  8006ac:	7e 07                	jle    8006b5 <libmain+0x30>
		binaryname = argv[0];
  8006ae:	8b 06                	mov    (%esi),%eax
  8006b0:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	e8 bf f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006bf:	e8 0a 00 00 00       	call   8006ce <exit>
}
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006d4:	e8 e6 0f 00 00       	call   8016bf <close_all>
	sys_env_destroy(0);
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	6a 00                	push   $0x0
  8006de:	e8 37 0a 00 00       	call   80111a <sys_env_destroy>
}
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006ed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006f0:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8006f6:	e8 60 0a 00 00       	call   80115b <sys_getenvid>
  8006fb:	83 ec 0c             	sub    $0xc,%esp
  8006fe:	ff 75 0c             	push   0xc(%ebp)
  800701:	ff 75 08             	push   0x8(%ebp)
  800704:	56                   	push   %esi
  800705:	50                   	push   %eax
  800706:	68 4c 2c 80 00       	push   $0x802c4c
  80070b:	e8 b3 00 00 00       	call   8007c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800710:	83 c4 18             	add    $0x18,%esp
  800713:	53                   	push   %ebx
  800714:	ff 75 10             	push   0x10(%ebp)
  800717:	e8 56 00 00 00       	call   800772 <vcprintf>
	cprintf("\n");
  80071c:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  800723:	e8 9b 00 00 00       	call   8007c3 <cprintf>
  800728:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80072b:	cc                   	int3   
  80072c:	eb fd                	jmp    80072b <_panic+0x43>

0080072e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	83 ec 04             	sub    $0x4,%esp
  800735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800738:	8b 13                	mov    (%ebx),%edx
  80073a:	8d 42 01             	lea    0x1(%edx),%eax
  80073d:	89 03                	mov    %eax,(%ebx)
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800746:	3d ff 00 00 00       	cmp    $0xff,%eax
  80074b:	74 09                	je     800756 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80074d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	68 ff 00 00 00       	push   $0xff
  80075e:	8d 43 08             	lea    0x8(%ebx),%eax
  800761:	50                   	push   %eax
  800762:	e8 76 09 00 00       	call   8010dd <sys_cputs>
		b->idx = 0;
  800767:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	eb db                	jmp    80074d <putch+0x1f>

00800772 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80077b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800782:	00 00 00 
	b.cnt = 0;
  800785:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80078c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80078f:	ff 75 0c             	push   0xc(%ebp)
  800792:	ff 75 08             	push   0x8(%ebp)
  800795:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	68 2e 07 80 00       	push   $0x80072e
  8007a1:	e8 14 01 00 00       	call   8008ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007a6:	83 c4 08             	add    $0x8,%esp
  8007a9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8007af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 22 09 00 00       	call   8010dd <sys_cputs>

	return b.cnt;
}
  8007bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007cc:	50                   	push   %eax
  8007cd:	ff 75 08             	push   0x8(%ebp)
  8007d0:	e8 9d ff ff ff       	call   800772 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	57                   	push   %edi
  8007db:	56                   	push   %esi
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 1c             	sub    $0x1c,%esp
  8007e0:	89 c7                	mov    %eax,%edi
  8007e2:	89 d6                	mov    %edx,%esi
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	89 d1                	mov    %edx,%ecx
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800804:	39 c2                	cmp    %eax,%edx
  800806:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800809:	72 3e                	jb     800849 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	ff 75 18             	push   0x18(%ebp)
  800811:	83 eb 01             	sub    $0x1,%ebx
  800814:	53                   	push   %ebx
  800815:	50                   	push   %eax
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	ff 75 e4             	push   -0x1c(%ebp)
  80081c:	ff 75 e0             	push   -0x20(%ebp)
  80081f:	ff 75 dc             	push   -0x24(%ebp)
  800822:	ff 75 d8             	push   -0x28(%ebp)
  800825:	e8 16 1e 00 00       	call   802640 <__udivdi3>
  80082a:	83 c4 18             	add    $0x18,%esp
  80082d:	52                   	push   %edx
  80082e:	50                   	push   %eax
  80082f:	89 f2                	mov    %esi,%edx
  800831:	89 f8                	mov    %edi,%eax
  800833:	e8 9f ff ff ff       	call   8007d7 <printnum>
  800838:	83 c4 20             	add    $0x20,%esp
  80083b:	eb 13                	jmp    800850 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	56                   	push   %esi
  800841:	ff 75 18             	push   0x18(%ebp)
  800844:	ff d7                	call   *%edi
  800846:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800849:	83 eb 01             	sub    $0x1,%ebx
  80084c:	85 db                	test   %ebx,%ebx
  80084e:	7f ed                	jg     80083d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	56                   	push   %esi
  800854:	83 ec 04             	sub    $0x4,%esp
  800857:	ff 75 e4             	push   -0x1c(%ebp)
  80085a:	ff 75 e0             	push   -0x20(%ebp)
  80085d:	ff 75 dc             	push   -0x24(%ebp)
  800860:	ff 75 d8             	push   -0x28(%ebp)
  800863:	e8 f8 1e 00 00       	call   802760 <__umoddi3>
  800868:	83 c4 14             	add    $0x14,%esp
  80086b:	0f be 80 6f 2c 80 00 	movsbl 0x802c6f(%eax),%eax
  800872:	50                   	push   %eax
  800873:	ff d7                	call   *%edi
}
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800886:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80088a:	8b 10                	mov    (%eax),%edx
  80088c:	3b 50 04             	cmp    0x4(%eax),%edx
  80088f:	73 0a                	jae    80089b <sprintputch+0x1b>
		*b->buf++ = ch;
  800891:	8d 4a 01             	lea    0x1(%edx),%ecx
  800894:	89 08                	mov    %ecx,(%eax)
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	88 02                	mov    %al,(%edx)
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <printfmt>:
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8008a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a6:	50                   	push   %eax
  8008a7:	ff 75 10             	push   0x10(%ebp)
  8008aa:	ff 75 0c             	push   0xc(%ebp)
  8008ad:	ff 75 08             	push   0x8(%ebp)
  8008b0:	e8 05 00 00 00       	call   8008ba <vprintfmt>
}
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <vprintfmt>:
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	83 ec 3c             	sub    $0x3c,%esp
  8008c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008cc:	eb 0a                	jmp    8008d8 <vprintfmt+0x1e>
			putch(ch, putdat);
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	53                   	push   %ebx
  8008d2:	50                   	push   %eax
  8008d3:	ff d6                	call   *%esi
  8008d5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d8:	83 c7 01             	add    $0x1,%edi
  8008db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008df:	83 f8 25             	cmp    $0x25,%eax
  8008e2:	74 0c                	je     8008f0 <vprintfmt+0x36>
			if (ch == '\0')
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	75 e6                	jne    8008ce <vprintfmt+0x14>
}
  8008e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    
		padc = ' ';
  8008f0:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8008f4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8008fb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800902:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800909:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8d 47 01             	lea    0x1(%edi),%eax
  800911:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800914:	0f b6 17             	movzbl (%edi),%edx
  800917:	8d 42 dd             	lea    -0x23(%edx),%eax
  80091a:	3c 55                	cmp    $0x55,%al
  80091c:	0f 87 bb 03 00 00    	ja     800cdd <vprintfmt+0x423>
  800922:	0f b6 c0             	movzbl %al,%eax
  800925:	ff 24 85 c0 2d 80 00 	jmp    *0x802dc0(,%eax,4)
  80092c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80092f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800933:	eb d9                	jmp    80090e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800935:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800938:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80093c:	eb d0                	jmp    80090e <vprintfmt+0x54>
  80093e:	0f b6 d2             	movzbl %dl,%edx
  800941:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
  800949:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80094c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80094f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800953:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800956:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800959:	83 f9 09             	cmp    $0x9,%ecx
  80095c:	77 55                	ja     8009b3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80095e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800961:	eb e9                	jmp    80094c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8b 00                	mov    (%eax),%eax
  800968:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096b:	8b 45 14             	mov    0x14(%ebp),%eax
  80096e:	8d 40 04             	lea    0x4(%eax),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	79 91                	jns    80090e <vprintfmt+0x54>
				width = precision, precision = -1;
  80097d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800980:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800983:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80098a:	eb 82                	jmp    80090e <vprintfmt+0x54>
  80098c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80098f:	85 d2                	test   %edx,%edx
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
  800996:	0f 49 c2             	cmovns %edx,%eax
  800999:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80099c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80099f:	e9 6a ff ff ff       	jmp    80090e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8009a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8009a7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8009ae:	e9 5b ff ff ff       	jmp    80090e <vprintfmt+0x54>
  8009b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b9:	eb bc                	jmp    800977 <vprintfmt+0xbd>
			lflag++;
  8009bb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8009be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8009c1:	e9 48 ff ff ff       	jmp    80090e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8009c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c9:	8d 78 04             	lea    0x4(%eax),%edi
  8009cc:	83 ec 08             	sub    $0x8,%esp
  8009cf:	53                   	push   %ebx
  8009d0:	ff 30                	push   (%eax)
  8009d2:	ff d6                	call   *%esi
			break;
  8009d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8009d7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8009da:	e9 9d 02 00 00       	jmp    800c7c <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8009df:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e2:	8d 78 04             	lea    0x4(%eax),%edi
  8009e5:	8b 10                	mov    (%eax),%edx
  8009e7:	89 d0                	mov    %edx,%eax
  8009e9:	f7 d8                	neg    %eax
  8009eb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ee:	83 f8 0f             	cmp    $0xf,%eax
  8009f1:	7f 23                	jg     800a16 <vprintfmt+0x15c>
  8009f3:	8b 14 85 20 2f 80 00 	mov    0x802f20(,%eax,4),%edx
  8009fa:	85 d2                	test   %edx,%edx
  8009fc:	74 18                	je     800a16 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8009fe:	52                   	push   %edx
  8009ff:	68 71 30 80 00       	push   $0x803071
  800a04:	53                   	push   %ebx
  800a05:	56                   	push   %esi
  800a06:	e8 92 fe ff ff       	call   80089d <printfmt>
  800a0b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a0e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800a11:	e9 66 02 00 00       	jmp    800c7c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800a16:	50                   	push   %eax
  800a17:	68 87 2c 80 00       	push   $0x802c87
  800a1c:	53                   	push   %ebx
  800a1d:	56                   	push   %esi
  800a1e:	e8 7a fe ff ff       	call   80089d <printfmt>
  800a23:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a26:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800a29:	e9 4e 02 00 00       	jmp    800c7c <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a31:	83 c0 04             	add    $0x4,%eax
  800a34:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800a37:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800a3c:	85 d2                	test   %edx,%edx
  800a3e:	b8 80 2c 80 00       	mov    $0x802c80,%eax
  800a43:	0f 45 c2             	cmovne %edx,%eax
  800a46:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a4d:	7e 06                	jle    800a55 <vprintfmt+0x19b>
  800a4f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800a53:	75 0d                	jne    800a62 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a55:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	03 45 e0             	add    -0x20(%ebp),%eax
  800a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a60:	eb 55                	jmp    800ab7 <vprintfmt+0x1fd>
  800a62:	83 ec 08             	sub    $0x8,%esp
  800a65:	ff 75 d8             	push   -0x28(%ebp)
  800a68:	ff 75 cc             	push   -0x34(%ebp)
  800a6b:	e8 0a 03 00 00       	call   800d7a <strnlen>
  800a70:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a73:	29 c1                	sub    %eax,%ecx
  800a75:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800a7d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a81:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800a84:	eb 0f                	jmp    800a95 <vprintfmt+0x1db>
					putch(padc, putdat);
  800a86:	83 ec 08             	sub    $0x8,%esp
  800a89:	53                   	push   %ebx
  800a8a:	ff 75 e0             	push   -0x20(%ebp)
  800a8d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	85 ff                	test   %edi,%edi
  800a97:	7f ed                	jg     800a86 <vprintfmt+0x1cc>
  800a99:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a9c:	85 d2                	test   %edx,%edx
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa3:	0f 49 c2             	cmovns %edx,%eax
  800aa6:	29 c2                	sub    %eax,%edx
  800aa8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aab:	eb a8                	jmp    800a55 <vprintfmt+0x19b>
					putch(ch, putdat);
  800aad:	83 ec 08             	sub    $0x8,%esp
  800ab0:	53                   	push   %ebx
  800ab1:	52                   	push   %edx
  800ab2:	ff d6                	call   *%esi
  800ab4:	83 c4 10             	add    $0x10,%esp
  800ab7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800aba:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800abc:	83 c7 01             	add    $0x1,%edi
  800abf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ac3:	0f be d0             	movsbl %al,%edx
  800ac6:	85 d2                	test   %edx,%edx
  800ac8:	74 4b                	je     800b15 <vprintfmt+0x25b>
  800aca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ace:	78 06                	js     800ad6 <vprintfmt+0x21c>
  800ad0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800ad4:	78 1e                	js     800af4 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800ad6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ada:	74 d1                	je     800aad <vprintfmt+0x1f3>
  800adc:	0f be c0             	movsbl %al,%eax
  800adf:	83 e8 20             	sub    $0x20,%eax
  800ae2:	83 f8 5e             	cmp    $0x5e,%eax
  800ae5:	76 c6                	jbe    800aad <vprintfmt+0x1f3>
					putch('?', putdat);
  800ae7:	83 ec 08             	sub    $0x8,%esp
  800aea:	53                   	push   %ebx
  800aeb:	6a 3f                	push   $0x3f
  800aed:	ff d6                	call   *%esi
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	eb c3                	jmp    800ab7 <vprintfmt+0x1fd>
  800af4:	89 cf                	mov    %ecx,%edi
  800af6:	eb 0e                	jmp    800b06 <vprintfmt+0x24c>
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	85 ff                	test   %edi,%edi
  800b08:	7f ee                	jg     800af8 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800b0a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800b0d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b10:	e9 67 01 00 00       	jmp    800c7c <vprintfmt+0x3c2>
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	eb ed                	jmp    800b06 <vprintfmt+0x24c>
	if (lflag >= 2)
  800b19:	83 f9 01             	cmp    $0x1,%ecx
  800b1c:	7f 1b                	jg     800b39 <vprintfmt+0x27f>
	else if (lflag)
  800b1e:	85 c9                	test   %ecx,%ecx
  800b20:	74 63                	je     800b85 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	8b 00                	mov    (%eax),%eax
  800b27:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b2a:	99                   	cltd   
  800b2b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b31:	8d 40 04             	lea    0x4(%eax),%eax
  800b34:	89 45 14             	mov    %eax,0x14(%ebp)
  800b37:	eb 17                	jmp    800b50 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800b39:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3c:	8b 50 04             	mov    0x4(%eax),%edx
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b44:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8d 40 08             	lea    0x8(%eax),%eax
  800b4d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800b50:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b53:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800b56:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800b5b:	85 c9                	test   %ecx,%ecx
  800b5d:	0f 89 ff 00 00 00    	jns    800c62 <vprintfmt+0x3a8>
				putch('-', putdat);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	53                   	push   %ebx
  800b67:	6a 2d                	push   $0x2d
  800b69:	ff d6                	call   *%esi
				num = -(long long) num;
  800b6b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b71:	f7 da                	neg    %edx
  800b73:	83 d1 00             	adc    $0x0,%ecx
  800b76:	f7 d9                	neg    %ecx
  800b78:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b7b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800b80:	e9 dd 00 00 00       	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800b85:	8b 45 14             	mov    0x14(%ebp),%eax
  800b88:	8b 00                	mov    (%eax),%eax
  800b8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8d:	99                   	cltd   
  800b8e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b91:	8b 45 14             	mov    0x14(%ebp),%eax
  800b94:	8d 40 04             	lea    0x4(%eax),%eax
  800b97:	89 45 14             	mov    %eax,0x14(%ebp)
  800b9a:	eb b4                	jmp    800b50 <vprintfmt+0x296>
	if (lflag >= 2)
  800b9c:	83 f9 01             	cmp    $0x1,%ecx
  800b9f:	7f 1e                	jg     800bbf <vprintfmt+0x305>
	else if (lflag)
  800ba1:	85 c9                	test   %ecx,%ecx
  800ba3:	74 32                	je     800bd7 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800ba5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba8:	8b 10                	mov    (%eax),%edx
  800baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baf:	8d 40 04             	lea    0x4(%eax),%eax
  800bb2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bb5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800bba:	e9 a3 00 00 00       	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc2:	8b 10                	mov    (%eax),%edx
  800bc4:	8b 48 04             	mov    0x4(%eax),%ecx
  800bc7:	8d 40 08             	lea    0x8(%eax),%eax
  800bca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bcd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800bd2:	e9 8b 00 00 00       	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800bd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bda:	8b 10                	mov    (%eax),%edx
  800bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be1:	8d 40 04             	lea    0x4(%eax),%eax
  800be4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800be7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800bec:	eb 74                	jmp    800c62 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800bee:	83 f9 01             	cmp    $0x1,%ecx
  800bf1:	7f 1b                	jg     800c0e <vprintfmt+0x354>
	else if (lflag)
  800bf3:	85 c9                	test   %ecx,%ecx
  800bf5:	74 2c                	je     800c23 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800bf7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfa:	8b 10                	mov    (%eax),%edx
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	8d 40 04             	lea    0x4(%eax),%eax
  800c04:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c07:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800c0c:	eb 54                	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800c0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c11:	8b 10                	mov    (%eax),%edx
  800c13:	8b 48 04             	mov    0x4(%eax),%ecx
  800c16:	8d 40 08             	lea    0x8(%eax),%eax
  800c19:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c1c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800c21:	eb 3f                	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800c23:	8b 45 14             	mov    0x14(%ebp),%eax
  800c26:	8b 10                	mov    (%eax),%edx
  800c28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2d:	8d 40 04             	lea    0x4(%eax),%eax
  800c30:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c33:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800c38:	eb 28                	jmp    800c62 <vprintfmt+0x3a8>
			putch('0', putdat);
  800c3a:	83 ec 08             	sub    $0x8,%esp
  800c3d:	53                   	push   %ebx
  800c3e:	6a 30                	push   $0x30
  800c40:	ff d6                	call   *%esi
			putch('x', putdat);
  800c42:	83 c4 08             	add    $0x8,%esp
  800c45:	53                   	push   %ebx
  800c46:	6a 78                	push   $0x78
  800c48:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4d:	8b 10                	mov    (%eax),%edx
  800c4f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c54:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800c57:	8d 40 04             	lea    0x4(%eax),%eax
  800c5a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c5d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800c69:	50                   	push   %eax
  800c6a:	ff 75 e0             	push   -0x20(%ebp)
  800c6d:	57                   	push   %edi
  800c6e:	51                   	push   %ecx
  800c6f:	52                   	push   %edx
  800c70:	89 da                	mov    %ebx,%edx
  800c72:	89 f0                	mov    %esi,%eax
  800c74:	e8 5e fb ff ff       	call   8007d7 <printnum>
			break;
  800c79:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800c7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c7f:	e9 54 fc ff ff       	jmp    8008d8 <vprintfmt+0x1e>
	if (lflag >= 2)
  800c84:	83 f9 01             	cmp    $0x1,%ecx
  800c87:	7f 1b                	jg     800ca4 <vprintfmt+0x3ea>
	else if (lflag)
  800c89:	85 c9                	test   %ecx,%ecx
  800c8b:	74 2c                	je     800cb9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c90:	8b 10                	mov    (%eax),%edx
  800c92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c97:	8d 40 04             	lea    0x4(%eax),%eax
  800c9a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c9d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800ca2:	eb be                	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca7:	8b 10                	mov    (%eax),%edx
  800ca9:	8b 48 04             	mov    0x4(%eax),%ecx
  800cac:	8d 40 08             	lea    0x8(%eax),%eax
  800caf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cb2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800cb7:	eb a9                	jmp    800c62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800cb9:	8b 45 14             	mov    0x14(%ebp),%eax
  800cbc:	8b 10                	mov    (%eax),%edx
  800cbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc3:	8d 40 04             	lea    0x4(%eax),%eax
  800cc6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cc9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800cce:	eb 92                	jmp    800c62 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800cd0:	83 ec 08             	sub    $0x8,%esp
  800cd3:	53                   	push   %ebx
  800cd4:	6a 25                	push   $0x25
  800cd6:	ff d6                	call   *%esi
			break;
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	eb 9f                	jmp    800c7c <vprintfmt+0x3c2>
			putch('%', putdat);
  800cdd:	83 ec 08             	sub    $0x8,%esp
  800ce0:	53                   	push   %ebx
  800ce1:	6a 25                	push   $0x25
  800ce3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	89 f8                	mov    %edi,%eax
  800cea:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800cee:	74 05                	je     800cf5 <vprintfmt+0x43b>
  800cf0:	83 e8 01             	sub    $0x1,%eax
  800cf3:	eb f5                	jmp    800cea <vprintfmt+0x430>
  800cf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cf8:	eb 82                	jmp    800c7c <vprintfmt+0x3c2>

00800cfa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 18             	sub    $0x18,%esp
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d09:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d0d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	74 26                	je     800d41 <vsnprintf+0x47>
  800d1b:	85 d2                	test   %edx,%edx
  800d1d:	7e 22                	jle    800d41 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d1f:	ff 75 14             	push   0x14(%ebp)
  800d22:	ff 75 10             	push   0x10(%ebp)
  800d25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d28:	50                   	push   %eax
  800d29:	68 80 08 80 00       	push   $0x800880
  800d2e:	e8 87 fb ff ff       	call   8008ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d36:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3c:	83 c4 10             	add    $0x10,%esp
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    
		return -E_INVAL;
  800d41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d46:	eb f7                	jmp    800d3f <vsnprintf+0x45>

00800d48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d4e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d51:	50                   	push   %eax
  800d52:	ff 75 10             	push   0x10(%ebp)
  800d55:	ff 75 0c             	push   0xc(%ebp)
  800d58:	ff 75 08             	push   0x8(%ebp)
  800d5b:	e8 9a ff ff ff       	call   800cfa <vsnprintf>
	va_end(ap);

	return rc;
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d68:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6d:	eb 03                	jmp    800d72 <strlen+0x10>
		n++;
  800d6f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800d72:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d76:	75 f7                	jne    800d6f <strlen+0xd>
	return n;
}
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d80:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d83:	b8 00 00 00 00       	mov    $0x0,%eax
  800d88:	eb 03                	jmp    800d8d <strnlen+0x13>
		n++;
  800d8a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d8d:	39 d0                	cmp    %edx,%eax
  800d8f:	74 08                	je     800d99 <strnlen+0x1f>
  800d91:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d95:	75 f3                	jne    800d8a <strnlen+0x10>
  800d97:	89 c2                	mov    %eax,%edx
	return n;
}
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	53                   	push   %ebx
  800da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800db0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800db3:	83 c0 01             	add    $0x1,%eax
  800db6:	84 d2                	test   %dl,%dl
  800db8:	75 f2                	jne    800dac <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800dba:	89 c8                	mov    %ecx,%eax
  800dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 10             	sub    $0x10,%esp
  800dc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dcb:	53                   	push   %ebx
  800dcc:	e8 91 ff ff ff       	call   800d62 <strlen>
  800dd1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800dd4:	ff 75 0c             	push   0xc(%ebp)
  800dd7:	01 d8                	add    %ebx,%eax
  800dd9:	50                   	push   %eax
  800dda:	e8 be ff ff ff       	call   800d9d <strcpy>
	return dst;
}
  800ddf:	89 d8                	mov    %ebx,%eax
  800de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de4:	c9                   	leave  
  800de5:	c3                   	ret    

00800de6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df1:	89 f3                	mov    %esi,%ebx
  800df3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df6:	89 f0                	mov    %esi,%eax
  800df8:	eb 0f                	jmp    800e09 <strncpy+0x23>
		*dst++ = *src;
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	0f b6 0a             	movzbl (%edx),%ecx
  800e00:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e03:	80 f9 01             	cmp    $0x1,%cl
  800e06:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800e09:	39 d8                	cmp    %ebx,%eax
  800e0b:	75 ed                	jne    800dfa <strncpy+0x14>
	}
	return ret;
}
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 10             	mov    0x10(%ebp),%edx
  800e21:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e23:	85 d2                	test   %edx,%edx
  800e25:	74 21                	je     800e48 <strlcpy+0x35>
  800e27:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e2b:	89 f2                	mov    %esi,%edx
  800e2d:	eb 09                	jmp    800e38 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e2f:	83 c1 01             	add    $0x1,%ecx
  800e32:	83 c2 01             	add    $0x1,%edx
  800e35:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800e38:	39 c2                	cmp    %eax,%edx
  800e3a:	74 09                	je     800e45 <strlcpy+0x32>
  800e3c:	0f b6 19             	movzbl (%ecx),%ebx
  800e3f:	84 db                	test   %bl,%bl
  800e41:	75 ec                	jne    800e2f <strlcpy+0x1c>
  800e43:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800e45:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e48:	29 f0                	sub    %esi,%eax
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e57:	eb 06                	jmp    800e5f <strcmp+0x11>
		p++, q++;
  800e59:	83 c1 01             	add    $0x1,%ecx
  800e5c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800e5f:	0f b6 01             	movzbl (%ecx),%eax
  800e62:	84 c0                	test   %al,%al
  800e64:	74 04                	je     800e6a <strcmp+0x1c>
  800e66:	3a 02                	cmp    (%edx),%al
  800e68:	74 ef                	je     800e59 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e6a:	0f b6 c0             	movzbl %al,%eax
  800e6d:	0f b6 12             	movzbl (%edx),%edx
  800e70:	29 d0                	sub    %edx,%eax
}
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	53                   	push   %ebx
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7e:	89 c3                	mov    %eax,%ebx
  800e80:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e83:	eb 06                	jmp    800e8b <strncmp+0x17>
		n--, p++, q++;
  800e85:	83 c0 01             	add    $0x1,%eax
  800e88:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e8b:	39 d8                	cmp    %ebx,%eax
  800e8d:	74 18                	je     800ea7 <strncmp+0x33>
  800e8f:	0f b6 08             	movzbl (%eax),%ecx
  800e92:	84 c9                	test   %cl,%cl
  800e94:	74 04                	je     800e9a <strncmp+0x26>
  800e96:	3a 0a                	cmp    (%edx),%cl
  800e98:	74 eb                	je     800e85 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e9a:	0f b6 00             	movzbl (%eax),%eax
  800e9d:	0f b6 12             	movzbl (%edx),%edx
  800ea0:	29 d0                	sub    %edx,%eax
}
  800ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    
		return 0;
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	eb f4                	jmp    800ea2 <strncmp+0x2e>

00800eae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eb8:	eb 03                	jmp    800ebd <strchr+0xf>
  800eba:	83 c0 01             	add    $0x1,%eax
  800ebd:	0f b6 10             	movzbl (%eax),%edx
  800ec0:	84 d2                	test   %dl,%dl
  800ec2:	74 06                	je     800eca <strchr+0x1c>
		if (*s == c)
  800ec4:	38 ca                	cmp    %cl,%dl
  800ec6:	75 f2                	jne    800eba <strchr+0xc>
  800ec8:	eb 05                	jmp    800ecf <strchr+0x21>
			return (char *) s;
	return 0;
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800edb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ede:	38 ca                	cmp    %cl,%dl
  800ee0:	74 09                	je     800eeb <strfind+0x1a>
  800ee2:	84 d2                	test   %dl,%dl
  800ee4:	74 05                	je     800eeb <strfind+0x1a>
	for (; *s; s++)
  800ee6:	83 c0 01             	add    $0x1,%eax
  800ee9:	eb f0                	jmp    800edb <strfind+0xa>
			break;
	return (char *) s;
}
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ef6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ef9:	85 c9                	test   %ecx,%ecx
  800efb:	74 2f                	je     800f2c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	09 c8                	or     %ecx,%eax
  800f01:	a8 03                	test   $0x3,%al
  800f03:	75 21                	jne    800f26 <memset+0x39>
		c &= 0xFF;
  800f05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	c1 e0 08             	shl    $0x8,%eax
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	c1 e3 18             	shl    $0x18,%ebx
  800f13:	89 d6                	mov    %edx,%esi
  800f15:	c1 e6 10             	shl    $0x10,%esi
  800f18:	09 f3                	or     %esi,%ebx
  800f1a:	09 da                	or     %ebx,%edx
  800f1c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f1e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f21:	fc                   	cld    
  800f22:	f3 ab                	rep stos %eax,%es:(%edi)
  800f24:	eb 06                	jmp    800f2c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f29:	fc                   	cld    
  800f2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f2c:	89 f8                	mov    %edi,%eax
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f41:	39 c6                	cmp    %eax,%esi
  800f43:	73 32                	jae    800f77 <memmove+0x44>
  800f45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f48:	39 c2                	cmp    %eax,%edx
  800f4a:	76 2b                	jbe    800f77 <memmove+0x44>
		s += n;
		d += n;
  800f4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4f:	89 d6                	mov    %edx,%esi
  800f51:	09 fe                	or     %edi,%esi
  800f53:	09 ce                	or     %ecx,%esi
  800f55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f5b:	75 0e                	jne    800f6b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f5d:	83 ef 04             	sub    $0x4,%edi
  800f60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f66:	fd                   	std    
  800f67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f69:	eb 09                	jmp    800f74 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f6b:	83 ef 01             	sub    $0x1,%edi
  800f6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f71:	fd                   	std    
  800f72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f74:	fc                   	cld    
  800f75:	eb 1a                	jmp    800f91 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f77:	89 f2                	mov    %esi,%edx
  800f79:	09 c2                	or     %eax,%edx
  800f7b:	09 ca                	or     %ecx,%edx
  800f7d:	f6 c2 03             	test   $0x3,%dl
  800f80:	75 0a                	jne    800f8c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f85:	89 c7                	mov    %eax,%edi
  800f87:	fc                   	cld    
  800f88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f8a:	eb 05                	jmp    800f91 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800f8c:	89 c7                	mov    %eax,%edi
  800f8e:	fc                   	cld    
  800f8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f9b:	ff 75 10             	push   0x10(%ebp)
  800f9e:	ff 75 0c             	push   0xc(%ebp)
  800fa1:	ff 75 08             	push   0x8(%ebp)
  800fa4:	e8 8a ff ff ff       	call   800f33 <memmove>
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fbb:	eb 06                	jmp    800fc3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fbd:	83 c0 01             	add    $0x1,%eax
  800fc0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800fc3:	39 f0                	cmp    %esi,%eax
  800fc5:	74 14                	je     800fdb <memcmp+0x30>
		if (*s1 != *s2)
  800fc7:	0f b6 08             	movzbl (%eax),%ecx
  800fca:	0f b6 1a             	movzbl (%edx),%ebx
  800fcd:	38 d9                	cmp    %bl,%cl
  800fcf:	74 ec                	je     800fbd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800fd1:	0f b6 c1             	movzbl %cl,%eax
  800fd4:	0f b6 db             	movzbl %bl,%ebx
  800fd7:	29 d8                	sub    %ebx,%eax
  800fd9:	eb 05                	jmp    800fe0 <memcmp+0x35>
	}

	return 0;
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fed:	89 c2                	mov    %eax,%edx
  800fef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ff2:	eb 03                	jmp    800ff7 <memfind+0x13>
  800ff4:	83 c0 01             	add    $0x1,%eax
  800ff7:	39 d0                	cmp    %edx,%eax
  800ff9:	73 04                	jae    800fff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ffb:	38 08                	cmp    %cl,(%eax)
  800ffd:	75 f5                	jne    800ff4 <memfind+0x10>
			break;
	return (void *) s;
}
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	8b 55 08             	mov    0x8(%ebp),%edx
  80100a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100d:	eb 03                	jmp    801012 <strtol+0x11>
		s++;
  80100f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801012:	0f b6 02             	movzbl (%edx),%eax
  801015:	3c 20                	cmp    $0x20,%al
  801017:	74 f6                	je     80100f <strtol+0xe>
  801019:	3c 09                	cmp    $0x9,%al
  80101b:	74 f2                	je     80100f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80101d:	3c 2b                	cmp    $0x2b,%al
  80101f:	74 2a                	je     80104b <strtol+0x4a>
	int neg = 0;
  801021:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801026:	3c 2d                	cmp    $0x2d,%al
  801028:	74 2b                	je     801055 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80102a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801030:	75 0f                	jne    801041 <strtol+0x40>
  801032:	80 3a 30             	cmpb   $0x30,(%edx)
  801035:	74 28                	je     80105f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801037:	85 db                	test   %ebx,%ebx
  801039:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103e:	0f 44 d8             	cmove  %eax,%ebx
  801041:	b9 00 00 00 00       	mov    $0x0,%ecx
  801046:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801049:	eb 46                	jmp    801091 <strtol+0x90>
		s++;
  80104b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80104e:	bf 00 00 00 00       	mov    $0x0,%edi
  801053:	eb d5                	jmp    80102a <strtol+0x29>
		s++, neg = 1;
  801055:	83 c2 01             	add    $0x1,%edx
  801058:	bf 01 00 00 00       	mov    $0x1,%edi
  80105d:	eb cb                	jmp    80102a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80105f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801063:	74 0e                	je     801073 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801065:	85 db                	test   %ebx,%ebx
  801067:	75 d8                	jne    801041 <strtol+0x40>
		s++, base = 8;
  801069:	83 c2 01             	add    $0x1,%edx
  80106c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801071:	eb ce                	jmp    801041 <strtol+0x40>
		s += 2, base = 16;
  801073:	83 c2 02             	add    $0x2,%edx
  801076:	bb 10 00 00 00       	mov    $0x10,%ebx
  80107b:	eb c4                	jmp    801041 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80107d:	0f be c0             	movsbl %al,%eax
  801080:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801083:	3b 45 10             	cmp    0x10(%ebp),%eax
  801086:	7d 3a                	jge    8010c2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801088:	83 c2 01             	add    $0x1,%edx
  80108b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80108f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801091:	0f b6 02             	movzbl (%edx),%eax
  801094:	8d 70 d0             	lea    -0x30(%eax),%esi
  801097:	89 f3                	mov    %esi,%ebx
  801099:	80 fb 09             	cmp    $0x9,%bl
  80109c:	76 df                	jbe    80107d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  80109e:	8d 70 9f             	lea    -0x61(%eax),%esi
  8010a1:	89 f3                	mov    %esi,%ebx
  8010a3:	80 fb 19             	cmp    $0x19,%bl
  8010a6:	77 08                	ja     8010b0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8010a8:	0f be c0             	movsbl %al,%eax
  8010ab:	83 e8 57             	sub    $0x57,%eax
  8010ae:	eb d3                	jmp    801083 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8010b0:	8d 70 bf             	lea    -0x41(%eax),%esi
  8010b3:	89 f3                	mov    %esi,%ebx
  8010b5:	80 fb 19             	cmp    $0x19,%bl
  8010b8:	77 08                	ja     8010c2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8010ba:	0f be c0             	movsbl %al,%eax
  8010bd:	83 e8 37             	sub    $0x37,%eax
  8010c0:	eb c1                	jmp    801083 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010c6:	74 05                	je     8010cd <strtol+0xcc>
		*endptr = (char *) s;
  8010c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8010cd:	89 c8                	mov    %ecx,%eax
  8010cf:	f7 d8                	neg    %eax
  8010d1:	85 ff                	test   %edi,%edi
  8010d3:	0f 45 c8             	cmovne %eax,%ecx
}
  8010d6:	89 c8                	mov    %ecx,%eax
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	89 c3                	mov    %eax,%ebx
  8010f0:	89 c7                	mov    %eax,%edi
  8010f2:	89 c6                	mov    %eax,%esi
  8010f4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <sys_cgetc>:

int
sys_cgetc(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
	asm volatile("int %1\n"
  801101:	ba 00 00 00 00       	mov    $0x0,%edx
  801106:	b8 01 00 00 00       	mov    $0x1,%eax
  80110b:	89 d1                	mov    %edx,%ecx
  80110d:	89 d3                	mov    %edx,%ebx
  80110f:	89 d7                	mov    %edx,%edi
  801111:	89 d6                	mov    %edx,%esi
  801113:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801123:	b9 00 00 00 00       	mov    $0x0,%ecx
  801128:	8b 55 08             	mov    0x8(%ebp),%edx
  80112b:	b8 03 00 00 00       	mov    $0x3,%eax
  801130:	89 cb                	mov    %ecx,%ebx
  801132:	89 cf                	mov    %ecx,%edi
  801134:	89 ce                	mov    %ecx,%esi
  801136:	cd 30                	int    $0x30
	if(check && ret > 0)
  801138:	85 c0                	test   %eax,%eax
  80113a:	7f 08                	jg     801144 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80113c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	50                   	push   %eax
  801148:	6a 03                	push   $0x3
  80114a:	68 7f 2f 80 00       	push   $0x802f7f
  80114f:	6a 2a                	push   $0x2a
  801151:	68 9c 2f 80 00       	push   $0x802f9c
  801156:	e8 8d f5 ff ff       	call   8006e8 <_panic>

0080115b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
	asm volatile("int %1\n"
  801161:	ba 00 00 00 00       	mov    $0x0,%edx
  801166:	b8 02 00 00 00       	mov    $0x2,%eax
  80116b:	89 d1                	mov    %edx,%ecx
  80116d:	89 d3                	mov    %edx,%ebx
  80116f:	89 d7                	mov    %edx,%edi
  801171:	89 d6                	mov    %edx,%esi
  801173:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <sys_yield>:

void
sys_yield(void)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801180:	ba 00 00 00 00       	mov    $0x0,%edx
  801185:	b8 0b 00 00 00       	mov    $0xb,%eax
  80118a:	89 d1                	mov    %edx,%ecx
  80118c:	89 d3                	mov    %edx,%ebx
  80118e:	89 d7                	mov    %edx,%edi
  801190:	89 d6                	mov    %edx,%esi
  801192:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011a2:	be 00 00 00 00       	mov    $0x0,%esi
  8011a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8011b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b5:	89 f7                	mov    %esi,%edi
  8011b7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	7f 08                	jg     8011c5 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5f                   	pop    %edi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c5:	83 ec 0c             	sub    $0xc,%esp
  8011c8:	50                   	push   %eax
  8011c9:	6a 04                	push   $0x4
  8011cb:	68 7f 2f 80 00       	push   $0x802f7f
  8011d0:	6a 2a                	push   $0x2a
  8011d2:	68 9c 2f 80 00       	push   $0x802f9c
  8011d7:	e8 0c f5 ff ff       	call   8006e8 <_panic>

008011dc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	57                   	push   %edi
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8011f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f6:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	7f 08                	jg     801207 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	50                   	push   %eax
  80120b:	6a 05                	push   $0x5
  80120d:	68 7f 2f 80 00       	push   $0x802f7f
  801212:	6a 2a                	push   $0x2a
  801214:	68 9c 2f 80 00       	push   $0x802f9c
  801219:	e8 ca f4 ff ff       	call   8006e8 <_panic>

0080121e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122c:	8b 55 08             	mov    0x8(%ebp),%edx
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	b8 06 00 00 00       	mov    $0x6,%eax
  801237:	89 df                	mov    %ebx,%edi
  801239:	89 de                	mov    %ebx,%esi
  80123b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	7f 08                	jg     801249 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	50                   	push   %eax
  80124d:	6a 06                	push   $0x6
  80124f:	68 7f 2f 80 00       	push   $0x802f7f
  801254:	6a 2a                	push   $0x2a
  801256:	68 9c 2f 80 00       	push   $0x802f9c
  80125b:	e8 88 f4 ff ff       	call   8006e8 <_panic>

00801260 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126e:	8b 55 08             	mov    0x8(%ebp),%edx
  801271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801274:	b8 08 00 00 00       	mov    $0x8,%eax
  801279:	89 df                	mov    %ebx,%edi
  80127b:	89 de                	mov    %ebx,%esi
  80127d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80127f:	85 c0                	test   %eax,%eax
  801281:	7f 08                	jg     80128b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	50                   	push   %eax
  80128f:	6a 08                	push   $0x8
  801291:	68 7f 2f 80 00       	push   $0x802f7f
  801296:	6a 2a                	push   $0x2a
  801298:	68 9c 2f 80 00       	push   $0x802f9c
  80129d:	e8 46 f4 ff ff       	call   8006e8 <_panic>

008012a2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8012bb:	89 df                	mov    %ebx,%edi
  8012bd:	89 de                	mov    %ebx,%esi
  8012bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	7f 08                	jg     8012cd <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	50                   	push   %eax
  8012d1:	6a 09                	push   $0x9
  8012d3:	68 7f 2f 80 00       	push   $0x802f7f
  8012d8:	6a 2a                	push   $0x2a
  8012da:	68 9c 2f 80 00       	push   $0x802f9c
  8012df:	e8 04 f4 ff ff       	call   8006e8 <_panic>

008012e4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012fd:	89 df                	mov    %ebx,%edi
  8012ff:	89 de                	mov    %ebx,%esi
  801301:	cd 30                	int    $0x30
	if(check && ret > 0)
  801303:	85 c0                	test   %eax,%eax
  801305:	7f 08                	jg     80130f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	50                   	push   %eax
  801313:	6a 0a                	push   $0xa
  801315:	68 7f 2f 80 00       	push   $0x802f7f
  80131a:	6a 2a                	push   $0x2a
  80131c:	68 9c 2f 80 00       	push   $0x802f9c
  801321:	e8 c2 f3 ff ff       	call   8006e8 <_panic>

00801326 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80132c:	8b 55 08             	mov    0x8(%ebp),%edx
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	b8 0c 00 00 00       	mov    $0xc,%eax
  801337:	be 00 00 00 00       	mov    $0x0,%esi
  80133c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801342:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801352:	b9 00 00 00 00       	mov    $0x0,%ecx
  801357:	8b 55 08             	mov    0x8(%ebp),%edx
  80135a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80135f:	89 cb                	mov    %ecx,%ebx
  801361:	89 cf                	mov    %ecx,%edi
  801363:	89 ce                	mov    %ecx,%esi
  801365:	cd 30                	int    $0x30
	if(check && ret > 0)
  801367:	85 c0                	test   %eax,%eax
  801369:	7f 08                	jg     801373 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80136b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	50                   	push   %eax
  801377:	6a 0d                	push   $0xd
  801379:	68 7f 2f 80 00       	push   $0x802f7f
  80137e:	6a 2a                	push   $0x2a
  801380:	68 9c 2f 80 00       	push   $0x802f9c
  801385:	e8 5e f3 ff ff       	call   8006e8 <_panic>

0080138a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	57                   	push   %edi
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801390:	ba 00 00 00 00       	mov    $0x0,%edx
  801395:	b8 0e 00 00 00       	mov    $0xe,%eax
  80139a:	89 d1                	mov    %edx,%ecx
  80139c:	89 d3                	mov    %edx,%ebx
  80139e:	89 d7                	mov    %edx,%edi
  8013a0:	89 d6                	mov    %edx,%esi
  8013a2:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	57                   	push   %edi
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ba:	b8 0f 00 00 00       	mov    $0xf,%eax
  8013bf:	89 df                	mov    %ebx,%edi
  8013c1:	89 de                	mov    %ebx,%esi
  8013c3:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013db:	b8 10 00 00 00       	mov    $0x10,%eax
  8013e0:	89 df                	mov    %ebx,%edi
  8013e2:	89 de                	mov    %ebx,%esi
  8013e4:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8013e6:	5b                   	pop    %ebx
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801400:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	50                   	push   %eax
  801407:	e8 3d ff ff ff       	call   801349 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	85 f6                	test   %esi,%esi
  801411:	74 17                	je     80142a <ipc_recv+0x3f>
  801413:	ba 00 00 00 00       	mov    $0x0,%edx
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 0c                	js     801428 <ipc_recv+0x3d>
  80141c:	8b 15 00 50 80 00    	mov    0x805000,%edx
  801422:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801428:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80142a:	85 db                	test   %ebx,%ebx
  80142c:	74 17                	je     801445 <ipc_recv+0x5a>
  80142e:	ba 00 00 00 00       	mov    $0x0,%edx
  801433:	85 c0                	test   %eax,%eax
  801435:	78 0c                	js     801443 <ipc_recv+0x58>
  801437:	8b 15 00 50 80 00    	mov    0x805000,%edx
  80143d:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801443:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801445:	85 c0                	test   %eax,%eax
  801447:	78 0b                	js     801454 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801449:	a1 00 50 80 00       	mov    0x805000,%eax
  80144e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	57                   	push   %edi
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	8b 7d 08             	mov    0x8(%ebp),%edi
  801467:	8b 75 0c             	mov    0xc(%ebp),%esi
  80146a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80146d:	85 db                	test   %ebx,%ebx
  80146f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801474:	0f 44 d8             	cmove  %eax,%ebx
  801477:	eb 05                	jmp    80147e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801479:	e8 fc fc ff ff       	call   80117a <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80147e:	ff 75 14             	push   0x14(%ebp)
  801481:	53                   	push   %ebx
  801482:	56                   	push   %esi
  801483:	57                   	push   %edi
  801484:	e8 9d fe ff ff       	call   801326 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80148f:	74 e8                	je     801479 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801491:	85 c0                	test   %eax,%eax
  801493:	78 08                	js     80149d <ipc_send+0x42>
	}while (r<0);

}
  801495:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	5f                   	pop    %edi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80149d:	50                   	push   %eax
  80149e:	68 aa 2f 80 00       	push   $0x802faa
  8014a3:	6a 3d                	push   $0x3d
  8014a5:	68 be 2f 80 00       	push   $0x802fbe
  8014aa:	e8 39 f2 ff ff       	call   8006e8 <_panic>

008014af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014ba:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8014c0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014c6:	8b 52 60             	mov    0x60(%edx),%edx
  8014c9:	39 ca                	cmp    %ecx,%edx
  8014cb:	74 11                	je     8014de <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8014cd:	83 c0 01             	add    $0x1,%eax
  8014d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014d5:	75 e3                	jne    8014ba <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dc:	eb 0e                	jmp    8014ec <ipc_find_env+0x3d>
			return envs[i].env_id;
  8014de:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8014e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014e9:	8b 40 58             	mov    0x58(%eax),%eax
}
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8014f9:	c1 e8 0c             	shr    $0xc,%eax
}
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801501:	8b 45 08             	mov    0x8(%ebp),%eax
  801504:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801509:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80150e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	c1 ea 16             	shr    $0x16,%edx
  801522:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801529:	f6 c2 01             	test   $0x1,%dl
  80152c:	74 29                	je     801557 <fd_alloc+0x42>
  80152e:	89 c2                	mov    %eax,%edx
  801530:	c1 ea 0c             	shr    $0xc,%edx
  801533:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80153a:	f6 c2 01             	test   $0x1,%dl
  80153d:	74 18                	je     801557 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80153f:	05 00 10 00 00       	add    $0x1000,%eax
  801544:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801549:	75 d2                	jne    80151d <fd_alloc+0x8>
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801550:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801555:	eb 05                	jmp    80155c <fd_alloc+0x47>
			return 0;
  801557:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80155c:	8b 55 08             	mov    0x8(%ebp),%edx
  80155f:	89 02                	mov    %eax,(%edx)
}
  801561:	89 c8                	mov    %ecx,%eax
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80156b:	83 f8 1f             	cmp    $0x1f,%eax
  80156e:	77 30                	ja     8015a0 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801570:	c1 e0 0c             	shl    $0xc,%eax
  801573:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801578:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80157e:	f6 c2 01             	test   $0x1,%dl
  801581:	74 24                	je     8015a7 <fd_lookup+0x42>
  801583:	89 c2                	mov    %eax,%edx
  801585:	c1 ea 0c             	shr    $0xc,%edx
  801588:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158f:	f6 c2 01             	test   $0x1,%dl
  801592:	74 1a                	je     8015ae <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
  801597:	89 02                	mov    %eax,(%edx)
	return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    
		return -E_INVAL;
  8015a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a5:	eb f7                	jmp    80159e <fd_lookup+0x39>
		return -E_INVAL;
  8015a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ac:	eb f0                	jmp    80159e <fd_lookup+0x39>
  8015ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b3:	eb e9                	jmp    80159e <fd_lookup+0x39>

008015b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c4:	bb 08 40 80 00       	mov    $0x804008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8015c9:	39 13                	cmp    %edx,(%ebx)
  8015cb:	74 37                	je     801604 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8015cd:	83 c0 01             	add    $0x1,%eax
  8015d0:	8b 1c 85 44 30 80 00 	mov    0x803044(,%eax,4),%ebx
  8015d7:	85 db                	test   %ebx,%ebx
  8015d9:	75 ee                	jne    8015c9 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015db:	a1 00 50 80 00       	mov    0x805000,%eax
  8015e0:	8b 40 58             	mov    0x58(%eax),%eax
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	52                   	push   %edx
  8015e7:	50                   	push   %eax
  8015e8:	68 c8 2f 80 00       	push   $0x802fc8
  8015ed:	e8 d1 f1 ff ff       	call   8007c3 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8015fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fd:	89 1a                	mov    %ebx,(%edx)
}
  8015ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801602:	c9                   	leave  
  801603:	c3                   	ret    
			return 0;
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
  801609:	eb ef                	jmp    8015fa <dev_lookup+0x45>

0080160b <fd_close>:
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	57                   	push   %edi
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	83 ec 24             	sub    $0x24,%esp
  801614:	8b 75 08             	mov    0x8(%ebp),%esi
  801617:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80161a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80161d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80161e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801624:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801627:	50                   	push   %eax
  801628:	e8 38 ff ff ff       	call   801565 <fd_lookup>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 05                	js     80163b <fd_close+0x30>
	    || fd != fd2)
  801636:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801639:	74 16                	je     801651 <fd_close+0x46>
		return (must_exist ? r : 0);
  80163b:	89 f8                	mov    %edi,%eax
  80163d:	84 c0                	test   %al,%al
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
  801644:	0f 44 d8             	cmove  %eax,%ebx
}
  801647:	89 d8                	mov    %ebx,%eax
  801649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	ff 36                	push   (%esi)
  80165a:	e8 56 ff ff ff       	call   8015b5 <dev_lookup>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 1a                	js     801682 <fd_close+0x77>
		if (dev->dev_close)
  801668:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80166b:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80166e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801673:	85 c0                	test   %eax,%eax
  801675:	74 0b                	je     801682 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	56                   	push   %esi
  80167b:	ff d0                	call   *%eax
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	56                   	push   %esi
  801686:	6a 00                	push   $0x0
  801688:	e8 91 fb ff ff       	call   80121e <sys_page_unmap>
	return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	eb b5                	jmp    801647 <fd_close+0x3c>

00801692 <close>:

int
close(int fdnum)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801698:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	ff 75 08             	push   0x8(%ebp)
  80169f:	e8 c1 fe ff ff       	call   801565 <fd_lookup>
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	79 02                	jns    8016ad <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    
		return fd_close(fd, 1);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	6a 01                	push   $0x1
  8016b2:	ff 75 f4             	push   -0xc(%ebp)
  8016b5:	e8 51 ff ff ff       	call   80160b <fd_close>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	eb ec                	jmp    8016ab <close+0x19>

008016bf <close_all>:

void
close_all(void)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	e8 be ff ff ff       	call   801692 <close>
	for (i = 0; i < MAXFD; i++)
  8016d4:	83 c3 01             	add    $0x1,%ebx
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	83 fb 20             	cmp    $0x20,%ebx
  8016dd:	75 ec                	jne    8016cb <close_all+0xc>
}
  8016df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	57                   	push   %edi
  8016e8:	56                   	push   %esi
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	ff 75 08             	push   0x8(%ebp)
  8016f4:	e8 6c fe ff ff       	call   801565 <fd_lookup>
  8016f9:	89 c3                	mov    %eax,%ebx
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 7f                	js     801781 <dup+0x9d>
		return r;
	close(newfdnum);
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	ff 75 0c             	push   0xc(%ebp)
  801708:	e8 85 ff ff ff       	call   801692 <close>

	newfd = INDEX2FD(newfdnum);
  80170d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801710:	c1 e6 0c             	shl    $0xc,%esi
  801713:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801719:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80171c:	89 3c 24             	mov    %edi,(%esp)
  80171f:	e8 da fd ff ff       	call   8014fe <fd2data>
  801724:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801726:	89 34 24             	mov    %esi,(%esp)
  801729:	e8 d0 fd ff ff       	call   8014fe <fd2data>
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801734:	89 d8                	mov    %ebx,%eax
  801736:	c1 e8 16             	shr    $0x16,%eax
  801739:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801740:	a8 01                	test   $0x1,%al
  801742:	74 11                	je     801755 <dup+0x71>
  801744:	89 d8                	mov    %ebx,%eax
  801746:	c1 e8 0c             	shr    $0xc,%eax
  801749:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801750:	f6 c2 01             	test   $0x1,%dl
  801753:	75 36                	jne    80178b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801755:	89 f8                	mov    %edi,%eax
  801757:	c1 e8 0c             	shr    $0xc,%eax
  80175a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801761:	83 ec 0c             	sub    $0xc,%esp
  801764:	25 07 0e 00 00       	and    $0xe07,%eax
  801769:	50                   	push   %eax
  80176a:	56                   	push   %esi
  80176b:	6a 00                	push   $0x0
  80176d:	57                   	push   %edi
  80176e:	6a 00                	push   $0x0
  801770:	e8 67 fa ff ff       	call   8011dc <sys_page_map>
  801775:	89 c3                	mov    %eax,%ebx
  801777:	83 c4 20             	add    $0x20,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 33                	js     8017b1 <dup+0xcd>
		goto err;

	return newfdnum;
  80177e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801781:	89 d8                	mov    %ebx,%eax
  801783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5f                   	pop    %edi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80178b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	25 07 0e 00 00       	and    $0xe07,%eax
  80179a:	50                   	push   %eax
  80179b:	ff 75 d4             	push   -0x2c(%ebp)
  80179e:	6a 00                	push   $0x0
  8017a0:	53                   	push   %ebx
  8017a1:	6a 00                	push   $0x0
  8017a3:	e8 34 fa ff ff       	call   8011dc <sys_page_map>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	83 c4 20             	add    $0x20,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	79 a4                	jns    801755 <dup+0x71>
	sys_page_unmap(0, newfd);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	56                   	push   %esi
  8017b5:	6a 00                	push   $0x0
  8017b7:	e8 62 fa ff ff       	call   80121e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017bc:	83 c4 08             	add    $0x8,%esp
  8017bf:	ff 75 d4             	push   -0x2c(%ebp)
  8017c2:	6a 00                	push   $0x0
  8017c4:	e8 55 fa ff ff       	call   80121e <sys_page_unmap>
	return r;
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	eb b3                	jmp    801781 <dup+0x9d>

008017ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 18             	sub    $0x18,%esp
  8017d6:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	56                   	push   %esi
  8017de:	e8 82 fd ff ff       	call   801565 <fd_lookup>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 3c                	js     801826 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	50                   	push   %eax
  8017f4:	ff 33                	push   (%ebx)
  8017f6:	e8 ba fd ff ff       	call   8015b5 <dev_lookup>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 24                	js     801826 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801802:	8b 43 08             	mov    0x8(%ebx),%eax
  801805:	83 e0 03             	and    $0x3,%eax
  801808:	83 f8 01             	cmp    $0x1,%eax
  80180b:	74 20                	je     80182d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801810:	8b 40 08             	mov    0x8(%eax),%eax
  801813:	85 c0                	test   %eax,%eax
  801815:	74 37                	je     80184e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	ff 75 10             	push   0x10(%ebp)
  80181d:	ff 75 0c             	push   0xc(%ebp)
  801820:	53                   	push   %ebx
  801821:	ff d0                	call   *%eax
  801823:	83 c4 10             	add    $0x10,%esp
}
  801826:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801829:	5b                   	pop    %ebx
  80182a:	5e                   	pop    %esi
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80182d:	a1 00 50 80 00       	mov    0x805000,%eax
  801832:	8b 40 58             	mov    0x58(%eax),%eax
  801835:	83 ec 04             	sub    $0x4,%esp
  801838:	56                   	push   %esi
  801839:	50                   	push   %eax
  80183a:	68 09 30 80 00       	push   $0x803009
  80183f:	e8 7f ef ff ff       	call   8007c3 <cprintf>
		return -E_INVAL;
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184c:	eb d8                	jmp    801826 <read+0x58>
		return -E_NOT_SUPP;
  80184e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801853:	eb d1                	jmp    801826 <read+0x58>

00801855 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	57                   	push   %edi
  801859:	56                   	push   %esi
  80185a:	53                   	push   %ebx
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801861:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801864:	bb 00 00 00 00       	mov    $0x0,%ebx
  801869:	eb 02                	jmp    80186d <readn+0x18>
  80186b:	01 c3                	add    %eax,%ebx
  80186d:	39 f3                	cmp    %esi,%ebx
  80186f:	73 21                	jae    801892 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	89 f0                	mov    %esi,%eax
  801876:	29 d8                	sub    %ebx,%eax
  801878:	50                   	push   %eax
  801879:	89 d8                	mov    %ebx,%eax
  80187b:	03 45 0c             	add    0xc(%ebp),%eax
  80187e:	50                   	push   %eax
  80187f:	57                   	push   %edi
  801880:	e8 49 ff ff ff       	call   8017ce <read>
		if (m < 0)
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 04                	js     801890 <readn+0x3b>
			return m;
		if (m == 0)
  80188c:	75 dd                	jne    80186b <readn+0x16>
  80188e:	eb 02                	jmp    801892 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801890:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801892:	89 d8                	mov    %ebx,%eax
  801894:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801897:	5b                   	pop    %ebx
  801898:	5e                   	pop    %esi
  801899:	5f                   	pop    %edi
  80189a:	5d                   	pop    %ebp
  80189b:	c3                   	ret    

0080189c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 18             	sub    $0x18,%esp
  8018a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018aa:	50                   	push   %eax
  8018ab:	53                   	push   %ebx
  8018ac:	e8 b4 fc ff ff       	call   801565 <fd_lookup>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 37                	js     8018ef <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	ff 36                	push   (%esi)
  8018c4:	e8 ec fc ff ff       	call   8015b5 <dev_lookup>
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 1f                	js     8018ef <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8018d4:	74 20                	je     8018f6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	74 37                	je     801917 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	ff 75 10             	push   0x10(%ebp)
  8018e6:	ff 75 0c             	push   0xc(%ebp)
  8018e9:	56                   	push   %esi
  8018ea:	ff d0                	call   *%eax
  8018ec:	83 c4 10             	add    $0x10,%esp
}
  8018ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018f6:	a1 00 50 80 00       	mov    0x805000,%eax
  8018fb:	8b 40 58             	mov    0x58(%eax),%eax
  8018fe:	83 ec 04             	sub    $0x4,%esp
  801901:	53                   	push   %ebx
  801902:	50                   	push   %eax
  801903:	68 25 30 80 00       	push   $0x803025
  801908:	e8 b6 ee ff ff       	call   8007c3 <cprintf>
		return -E_INVAL;
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801915:	eb d8                	jmp    8018ef <write+0x53>
		return -E_NOT_SUPP;
  801917:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80191c:	eb d1                	jmp    8018ef <write+0x53>

0080191e <seek>:

int
seek(int fdnum, off_t offset)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	ff 75 08             	push   0x8(%ebp)
  80192b:	e8 35 fc ff ff       	call   801565 <fd_lookup>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 0e                	js     801945 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	83 ec 18             	sub    $0x18,%esp
  80194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801952:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	53                   	push   %ebx
  801957:	e8 09 fc ff ff       	call   801565 <fd_lookup>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 34                	js     801997 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801963:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196c:	50                   	push   %eax
  80196d:	ff 36                	push   (%esi)
  80196f:	e8 41 fc ff ff       	call   8015b5 <dev_lookup>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 1c                	js     801997 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80197b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80197f:	74 1d                	je     80199e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801981:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801984:	8b 40 18             	mov    0x18(%eax),%eax
  801987:	85 c0                	test   %eax,%eax
  801989:	74 34                	je     8019bf <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	ff 75 0c             	push   0xc(%ebp)
  801991:	56                   	push   %esi
  801992:	ff d0                	call   *%eax
  801994:	83 c4 10             	add    $0x10,%esp
}
  801997:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80199e:	a1 00 50 80 00       	mov    0x805000,%eax
  8019a3:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	53                   	push   %ebx
  8019aa:	50                   	push   %eax
  8019ab:	68 e8 2f 80 00       	push   $0x802fe8
  8019b0:	e8 0e ee ff ff       	call   8007c3 <cprintf>
		return -E_INVAL;
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019bd:	eb d8                	jmp    801997 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8019bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c4:	eb d1                	jmp    801997 <ftruncate+0x50>

008019c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 18             	sub    $0x18,%esp
  8019ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d4:	50                   	push   %eax
  8019d5:	ff 75 08             	push   0x8(%ebp)
  8019d8:	e8 88 fb ff ff       	call   801565 <fd_lookup>
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 49                	js     801a2d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8019e7:	83 ec 08             	sub    $0x8,%esp
  8019ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ed:	50                   	push   %eax
  8019ee:	ff 36                	push   (%esi)
  8019f0:	e8 c0 fb ff ff       	call   8015b5 <dev_lookup>
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 31                	js     801a2d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a03:	74 2f                	je     801a34 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a05:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a08:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a0f:	00 00 00 
	stat->st_isdir = 0;
  801a12:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a19:	00 00 00 
	stat->st_dev = dev;
  801a1c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	56                   	push   %esi
  801a27:	ff 50 14             	call   *0x14(%eax)
  801a2a:	83 c4 10             	add    $0x10,%esp
}
  801a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    
		return -E_NOT_SUPP;
  801a34:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a39:	eb f2                	jmp    801a2d <fstat+0x67>

00801a3b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	6a 00                	push   $0x0
  801a45:	ff 75 08             	push   0x8(%ebp)
  801a48:	e8 e4 01 00 00       	call   801c31 <open>
  801a4d:	89 c3                	mov    %eax,%ebx
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 1b                	js     801a71 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a56:	83 ec 08             	sub    $0x8,%esp
  801a59:	ff 75 0c             	push   0xc(%ebp)
  801a5c:	50                   	push   %eax
  801a5d:	e8 64 ff ff ff       	call   8019c6 <fstat>
  801a62:	89 c6                	mov    %eax,%esi
	close(fd);
  801a64:	89 1c 24             	mov    %ebx,(%esp)
  801a67:	e8 26 fc ff ff       	call   801692 <close>
	return r;
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	89 f3                	mov    %esi,%ebx
}
  801a71:	89 d8                	mov    %ebx,%eax
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	89 c6                	mov    %eax,%esi
  801a81:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a83:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801a8a:	74 27                	je     801ab3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a8c:	6a 07                	push   $0x7
  801a8e:	68 00 60 80 00       	push   $0x806000
  801a93:	56                   	push   %esi
  801a94:	ff 35 00 70 80 00    	push   0x807000
  801a9a:	e8 bc f9 ff ff       	call   80145b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a9f:	83 c4 0c             	add    $0xc,%esp
  801aa2:	6a 00                	push   $0x0
  801aa4:	53                   	push   %ebx
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 3f f9 ff ff       	call   8013eb <ipc_recv>
}
  801aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	6a 01                	push   $0x1
  801ab8:	e8 f2 f9 ff ff       	call   8014af <ipc_find_env>
  801abd:	a3 00 70 80 00       	mov    %eax,0x807000
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	eb c5                	jmp    801a8c <fsipc+0x12>

00801ac7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae5:	b8 02 00 00 00       	mov    $0x2,%eax
  801aea:	e8 8b ff ff ff       	call   801a7a <fsipc>
}
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <devfile_flush>:
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801af7:	8b 45 08             	mov    0x8(%ebp),%eax
  801afa:	8b 40 0c             	mov    0xc(%eax),%eax
  801afd:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b02:	ba 00 00 00 00       	mov    $0x0,%edx
  801b07:	b8 06 00 00 00       	mov    $0x6,%eax
  801b0c:	e8 69 ff ff ff       	call   801a7a <fsipc>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <devfile_stat>:
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 04             	sub    $0x4,%esp
  801b1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 40 0c             	mov    0xc(%eax),%eax
  801b23:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b28:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b32:	e8 43 ff ff ff       	call   801a7a <fsipc>
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 2c                	js     801b67 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	68 00 60 80 00       	push   $0x806000
  801b43:	53                   	push   %ebx
  801b44:	e8 54 f2 ff ff       	call   800d9d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b49:	a1 80 60 80 00       	mov    0x806080,%eax
  801b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b54:	a1 84 60 80 00       	mov    0x806084,%eax
  801b59:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <devfile_write>:
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	8b 45 10             	mov    0x10(%ebp),%eax
  801b75:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b7a:	39 d0                	cmp    %edx,%eax
  801b7c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  801b82:	8b 52 0c             	mov    0xc(%edx),%edx
  801b85:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b8b:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b90:	50                   	push   %eax
  801b91:	ff 75 0c             	push   0xc(%ebp)
  801b94:	68 08 60 80 00       	push   $0x806008
  801b99:	e8 95 f3 ff ff       	call   800f33 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ba8:	e8 cd fe ff ff       	call   801a7a <fsipc>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <devfile_read>:
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	8b 40 0c             	mov    0xc(%eax),%eax
  801bbd:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bc2:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  801bd2:	e8 a3 fe ff ff       	call   801a7a <fsipc>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 1f                	js     801bfc <devfile_read+0x4d>
	assert(r <= n);
  801bdd:	39 f0                	cmp    %esi,%eax
  801bdf:	77 24                	ja     801c05 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801be1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be6:	7f 33                	jg     801c1b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	50                   	push   %eax
  801bec:	68 00 60 80 00       	push   $0x806000
  801bf1:	ff 75 0c             	push   0xc(%ebp)
  801bf4:	e8 3a f3 ff ff       	call   800f33 <memmove>
	return r;
  801bf9:	83 c4 10             	add    $0x10,%esp
}
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
	assert(r <= n);
  801c05:	68 58 30 80 00       	push   $0x803058
  801c0a:	68 5f 30 80 00       	push   $0x80305f
  801c0f:	6a 7c                	push   $0x7c
  801c11:	68 74 30 80 00       	push   $0x803074
  801c16:	e8 cd ea ff ff       	call   8006e8 <_panic>
	assert(r <= PGSIZE);
  801c1b:	68 7f 30 80 00       	push   $0x80307f
  801c20:	68 5f 30 80 00       	push   $0x80305f
  801c25:	6a 7d                	push   $0x7d
  801c27:	68 74 30 80 00       	push   $0x803074
  801c2c:	e8 b7 ea ff ff       	call   8006e8 <_panic>

00801c31 <open>:
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	56                   	push   %esi
  801c35:	53                   	push   %ebx
  801c36:	83 ec 1c             	sub    $0x1c,%esp
  801c39:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c3c:	56                   	push   %esi
  801c3d:	e8 20 f1 ff ff       	call   800d62 <strlen>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c4a:	7f 6c                	jg     801cb8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c52:	50                   	push   %eax
  801c53:	e8 bd f8 ff ff       	call   801515 <fd_alloc>
  801c58:	89 c3                	mov    %eax,%ebx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 3c                	js     801c9d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801c61:	83 ec 08             	sub    $0x8,%esp
  801c64:	56                   	push   %esi
  801c65:	68 00 60 80 00       	push   $0x806000
  801c6a:	e8 2e f1 ff ff       	call   800d9d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c72:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7f:	e8 f6 fd ff ff       	call   801a7a <fsipc>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 19                	js     801ca6 <open+0x75>
	return fd2num(fd);
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff 75 f4             	push   -0xc(%ebp)
  801c93:	e8 56 f8 ff ff       	call   8014ee <fd2num>
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	83 c4 10             	add    $0x10,%esp
}
  801c9d:	89 d8                	mov    %ebx,%eax
  801c9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    
		fd_close(fd, 0);
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	6a 00                	push   $0x0
  801cab:	ff 75 f4             	push   -0xc(%ebp)
  801cae:	e8 58 f9 ff ff       	call   80160b <fd_close>
		return r;
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	eb e5                	jmp    801c9d <open+0x6c>
		return -E_BAD_PATH;
  801cb8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cbd:	eb de                	jmp    801c9d <open+0x6c>

00801cbf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cca:	b8 08 00 00 00       	mov    $0x8,%eax
  801ccf:	e8 a6 fd ff ff       	call   801a7a <fsipc>
}
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cdc:	68 8b 30 80 00       	push   $0x80308b
  801ce1:	ff 75 0c             	push   0xc(%ebp)
  801ce4:	e8 b4 f0 ff ff       	call   800d9d <strcpy>
	return 0;
}
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <devsock_close>:
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 10             	sub    $0x10,%esp
  801cf7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cfa:	53                   	push   %ebx
  801cfb:	e8 fc 08 00 00       	call   8025fc <pageref>
  801d00:	89 c2                	mov    %eax,%edx
  801d02:	83 c4 10             	add    $0x10,%esp
		return 0;
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801d0a:	83 fa 01             	cmp    $0x1,%edx
  801d0d:	74 05                	je     801d14 <devsock_close+0x24>
}
  801d0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801d14:	83 ec 0c             	sub    $0xc,%esp
  801d17:	ff 73 0c             	push   0xc(%ebx)
  801d1a:	e8 b7 02 00 00       	call   801fd6 <nsipc_close>
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	eb eb                	jmp    801d0f <devsock_close+0x1f>

00801d24 <devsock_write>:
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d2a:	6a 00                	push   $0x0
  801d2c:	ff 75 10             	push   0x10(%ebp)
  801d2f:	ff 75 0c             	push   0xc(%ebp)
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	ff 70 0c             	push   0xc(%eax)
  801d38:	e8 79 03 00 00       	call   8020b6 <nsipc_send>
}
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <devsock_read>:
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d45:	6a 00                	push   $0x0
  801d47:	ff 75 10             	push   0x10(%ebp)
  801d4a:	ff 75 0c             	push   0xc(%ebp)
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	ff 70 0c             	push   0xc(%eax)
  801d53:	e8 ef 02 00 00       	call   802047 <nsipc_recv>
}
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <fd2sockid>:
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d60:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d63:	52                   	push   %edx
  801d64:	50                   	push   %eax
  801d65:	e8 fb f7 ff ff       	call   801565 <fd_lookup>
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 10                	js     801d81 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d74:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801d7a:	39 08                	cmp    %ecx,(%eax)
  801d7c:	75 05                	jne    801d83 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801d7e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    
		return -E_NOT_SUPP;
  801d83:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d88:	eb f7                	jmp    801d81 <fd2sockid+0x27>

00801d8a <alloc_sockfd>:
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	56                   	push   %esi
  801d8e:	53                   	push   %ebx
  801d8f:	83 ec 1c             	sub    $0x1c,%esp
  801d92:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	e8 78 f7 ff ff       	call   801515 <fd_alloc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	78 43                	js     801de9 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	68 07 04 00 00       	push   $0x407
  801dae:	ff 75 f4             	push   -0xc(%ebp)
  801db1:	6a 00                	push   $0x0
  801db3:	e8 e1 f3 ff ff       	call   801199 <sys_page_alloc>
  801db8:	89 c3                	mov    %eax,%ebx
  801dba:	83 c4 10             	add    $0x10,%esp
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	78 28                	js     801de9 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc4:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801dca:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801dd6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dd9:	83 ec 0c             	sub    $0xc,%esp
  801ddc:	50                   	push   %eax
  801ddd:	e8 0c f7 ff ff       	call   8014ee <fd2num>
  801de2:	89 c3                	mov    %eax,%ebx
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	eb 0c                	jmp    801df5 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801de9:	83 ec 0c             	sub    $0xc,%esp
  801dec:	56                   	push   %esi
  801ded:	e8 e4 01 00 00       	call   801fd6 <nsipc_close>
		return r;
  801df2:	83 c4 10             	add    $0x10,%esp
}
  801df5:	89 d8                	mov    %ebx,%eax
  801df7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfa:	5b                   	pop    %ebx
  801dfb:	5e                   	pop    %esi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <accept>:
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	e8 4e ff ff ff       	call   801d5a <fd2sockid>
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	78 1b                	js     801e2b <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e10:	83 ec 04             	sub    $0x4,%esp
  801e13:	ff 75 10             	push   0x10(%ebp)
  801e16:	ff 75 0c             	push   0xc(%ebp)
  801e19:	50                   	push   %eax
  801e1a:	e8 0e 01 00 00       	call   801f2d <nsipc_accept>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 05                	js     801e2b <accept+0x2d>
	return alloc_sockfd(r);
  801e26:	e8 5f ff ff ff       	call   801d8a <alloc_sockfd>
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <bind>:
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	e8 1f ff ff ff       	call   801d5a <fd2sockid>
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 12                	js     801e51 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	ff 75 10             	push   0x10(%ebp)
  801e45:	ff 75 0c             	push   0xc(%ebp)
  801e48:	50                   	push   %eax
  801e49:	e8 31 01 00 00       	call   801f7f <nsipc_bind>
  801e4e:	83 c4 10             	add    $0x10,%esp
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <shutdown>:
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	e8 f9 fe ff ff       	call   801d5a <fd2sockid>
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 0f                	js     801e74 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801e65:	83 ec 08             	sub    $0x8,%esp
  801e68:	ff 75 0c             	push   0xc(%ebp)
  801e6b:	50                   	push   %eax
  801e6c:	e8 43 01 00 00       	call   801fb4 <nsipc_shutdown>
  801e71:	83 c4 10             	add    $0x10,%esp
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <connect>:
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7f:	e8 d6 fe ff ff       	call   801d5a <fd2sockid>
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 12                	js     801e9a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801e88:	83 ec 04             	sub    $0x4,%esp
  801e8b:	ff 75 10             	push   0x10(%ebp)
  801e8e:	ff 75 0c             	push   0xc(%ebp)
  801e91:	50                   	push   %eax
  801e92:	e8 59 01 00 00       	call   801ff0 <nsipc_connect>
  801e97:	83 c4 10             	add    $0x10,%esp
}
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <listen>:
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea5:	e8 b0 fe ff ff       	call   801d5a <fd2sockid>
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 0f                	js     801ebd <listen+0x21>
	return nsipc_listen(r, backlog);
  801eae:	83 ec 08             	sub    $0x8,%esp
  801eb1:	ff 75 0c             	push   0xc(%ebp)
  801eb4:	50                   	push   %eax
  801eb5:	e8 6b 01 00 00       	call   802025 <nsipc_listen>
  801eba:	83 c4 10             	add    $0x10,%esp
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <socket>:

int
socket(int domain, int type, int protocol)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ec5:	ff 75 10             	push   0x10(%ebp)
  801ec8:	ff 75 0c             	push   0xc(%ebp)
  801ecb:	ff 75 08             	push   0x8(%ebp)
  801ece:	e8 41 02 00 00       	call   802114 <nsipc_socket>
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 05                	js     801edf <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801eda:	e8 ab fe ff ff       	call   801d8a <alloc_sockfd>
}
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 04             	sub    $0x4,%esp
  801ee8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801eea:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  801ef1:	74 26                	je     801f19 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ef3:	6a 07                	push   $0x7
  801ef5:	68 00 80 80 00       	push   $0x808000
  801efa:	53                   	push   %ebx
  801efb:	ff 35 00 90 80 00    	push   0x809000
  801f01:	e8 55 f5 ff ff       	call   80145b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f06:	83 c4 0c             	add    $0xc,%esp
  801f09:	6a 00                	push   $0x0
  801f0b:	6a 00                	push   $0x0
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 d7 f4 ff ff       	call   8013eb <ipc_recv>
}
  801f14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	6a 02                	push   $0x2
  801f1e:	e8 8c f5 ff ff       	call   8014af <ipc_find_env>
  801f23:	a3 00 90 80 00       	mov    %eax,0x809000
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	eb c6                	jmp    801ef3 <nsipc+0x12>

00801f2d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f3d:	8b 06                	mov    (%esi),%eax
  801f3f:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f44:	b8 01 00 00 00       	mov    $0x1,%eax
  801f49:	e8 93 ff ff ff       	call   801ee1 <nsipc>
  801f4e:	89 c3                	mov    %eax,%ebx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	79 09                	jns    801f5d <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f59:	5b                   	pop    %ebx
  801f5a:	5e                   	pop    %esi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f5d:	83 ec 04             	sub    $0x4,%esp
  801f60:	ff 35 10 80 80 00    	push   0x808010
  801f66:	68 00 80 80 00       	push   $0x808000
  801f6b:	ff 75 0c             	push   0xc(%ebp)
  801f6e:	e8 c0 ef ff ff       	call   800f33 <memmove>
		*addrlen = ret->ret_addrlen;
  801f73:	a1 10 80 80 00       	mov    0x808010,%eax
  801f78:	89 06                	mov    %eax,(%esi)
  801f7a:	83 c4 10             	add    $0x10,%esp
	return r;
  801f7d:	eb d5                	jmp    801f54 <nsipc_accept+0x27>

00801f7f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	53                   	push   %ebx
  801f83:	83 ec 08             	sub    $0x8,%esp
  801f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f91:	53                   	push   %ebx
  801f92:	ff 75 0c             	push   0xc(%ebp)
  801f95:	68 04 80 80 00       	push   $0x808004
  801f9a:	e8 94 ef ff ff       	call   800f33 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f9f:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801fa5:	b8 02 00 00 00       	mov    $0x2,%eax
  801faa:	e8 32 ff ff ff       	call   801ee1 <nsipc>
}
  801faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fba:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbd:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc5:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801fca:	b8 03 00 00 00       	mov    $0x3,%eax
  801fcf:	e8 0d ff ff ff       	call   801ee1 <nsipc>
}
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <nsipc_close>:

int
nsipc_close(int s)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdf:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801fe4:	b8 04 00 00 00       	mov    $0x4,%eax
  801fe9:	e8 f3 fe ff ff       	call   801ee1 <nsipc>
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 08             	sub    $0x8,%esp
  801ff7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffd:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802002:	53                   	push   %ebx
  802003:	ff 75 0c             	push   0xc(%ebp)
  802006:	68 04 80 80 00       	push   $0x808004
  80200b:	e8 23 ef ff ff       	call   800f33 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802010:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802016:	b8 05 00 00 00       	mov    $0x5,%eax
  80201b:	e8 c1 fe ff ff       	call   801ee1 <nsipc>
}
  802020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802033:	8b 45 0c             	mov    0xc(%ebp),%eax
  802036:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  80203b:	b8 06 00 00 00       	mov    $0x6,%eax
  802040:	e8 9c fe ff ff       	call   801ee1 <nsipc>
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80204f:	8b 45 08             	mov    0x8(%ebp),%eax
  802052:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802057:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  80205d:	8b 45 14             	mov    0x14(%ebp),%eax
  802060:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802065:	b8 07 00 00 00       	mov    $0x7,%eax
  80206a:	e8 72 fe ff ff       	call   801ee1 <nsipc>
  80206f:	89 c3                	mov    %eax,%ebx
  802071:	85 c0                	test   %eax,%eax
  802073:	78 22                	js     802097 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802075:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80207a:	39 c6                	cmp    %eax,%esi
  80207c:	0f 4e c6             	cmovle %esi,%eax
  80207f:	39 c3                	cmp    %eax,%ebx
  802081:	7f 1d                	jg     8020a0 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802083:	83 ec 04             	sub    $0x4,%esp
  802086:	53                   	push   %ebx
  802087:	68 00 80 80 00       	push   $0x808000
  80208c:	ff 75 0c             	push   0xc(%ebp)
  80208f:	e8 9f ee ff ff       	call   800f33 <memmove>
  802094:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802097:	89 d8                	mov    %ebx,%eax
  802099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5e                   	pop    %esi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8020a0:	68 97 30 80 00       	push   $0x803097
  8020a5:	68 5f 30 80 00       	push   $0x80305f
  8020aa:	6a 62                	push   $0x62
  8020ac:	68 ac 30 80 00       	push   $0x8030ac
  8020b1:	e8 32 e6 ff ff       	call   8006e8 <_panic>

008020b6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	53                   	push   %ebx
  8020ba:	83 ec 04             	sub    $0x4,%esp
  8020bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c3:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  8020c8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020ce:	7f 2e                	jg     8020fe <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020d0:	83 ec 04             	sub    $0x4,%esp
  8020d3:	53                   	push   %ebx
  8020d4:	ff 75 0c             	push   0xc(%ebp)
  8020d7:	68 0c 80 80 00       	push   $0x80800c
  8020dc:	e8 52 ee ff ff       	call   800f33 <memmove>
	nsipcbuf.send.req_size = size;
  8020e1:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  8020e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ea:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  8020ef:	b8 08 00 00 00       	mov    $0x8,%eax
  8020f4:	e8 e8 fd ff ff       	call   801ee1 <nsipc>
}
  8020f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    
	assert(size < 1600);
  8020fe:	68 b8 30 80 00       	push   $0x8030b8
  802103:	68 5f 30 80 00       	push   $0x80305f
  802108:	6a 6d                	push   $0x6d
  80210a:	68 ac 30 80 00       	push   $0x8030ac
  80210f:	e8 d4 e5 ff ff       	call   8006e8 <_panic>

00802114 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80211a:	8b 45 08             	mov    0x8(%ebp),%eax
  80211d:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802122:	8b 45 0c             	mov    0xc(%ebp),%eax
  802125:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  80212a:	8b 45 10             	mov    0x10(%ebp),%eax
  80212d:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802132:	b8 09 00 00 00       	mov    $0x9,%eax
  802137:	e8 a5 fd ff ff       	call   801ee1 <nsipc>
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	56                   	push   %esi
  802142:	53                   	push   %ebx
  802143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802146:	83 ec 0c             	sub    $0xc,%esp
  802149:	ff 75 08             	push   0x8(%ebp)
  80214c:	e8 ad f3 ff ff       	call   8014fe <fd2data>
  802151:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802153:	83 c4 08             	add    $0x8,%esp
  802156:	68 c4 30 80 00       	push   $0x8030c4
  80215b:	53                   	push   %ebx
  80215c:	e8 3c ec ff ff       	call   800d9d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802161:	8b 46 04             	mov    0x4(%esi),%eax
  802164:	2b 06                	sub    (%esi),%eax
  802166:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80216c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802173:	00 00 00 
	stat->st_dev = &devpipe;
  802176:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  80217d:	40 80 00 
	return 0;
}
  802180:	b8 00 00 00 00       	mov    $0x0,%eax
  802185:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    

0080218c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	53                   	push   %ebx
  802190:	83 ec 0c             	sub    $0xc,%esp
  802193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802196:	53                   	push   %ebx
  802197:	6a 00                	push   $0x0
  802199:	e8 80 f0 ff ff       	call   80121e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80219e:	89 1c 24             	mov    %ebx,(%esp)
  8021a1:	e8 58 f3 ff ff       	call   8014fe <fd2data>
  8021a6:	83 c4 08             	add    $0x8,%esp
  8021a9:	50                   	push   %eax
  8021aa:	6a 00                	push   $0x0
  8021ac:	e8 6d f0 ff ff       	call   80121e <sys_page_unmap>
}
  8021b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    

008021b6 <_pipeisclosed>:
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	57                   	push   %edi
  8021ba:	56                   	push   %esi
  8021bb:	53                   	push   %ebx
  8021bc:	83 ec 1c             	sub    $0x1c,%esp
  8021bf:	89 c7                	mov    %eax,%edi
  8021c1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8021c3:	a1 00 50 80 00       	mov    0x805000,%eax
  8021c8:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021cb:	83 ec 0c             	sub    $0xc,%esp
  8021ce:	57                   	push   %edi
  8021cf:	e8 28 04 00 00       	call   8025fc <pageref>
  8021d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021d7:	89 34 24             	mov    %esi,(%esp)
  8021da:	e8 1d 04 00 00       	call   8025fc <pageref>
		nn = thisenv->env_runs;
  8021df:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8021e5:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8021e8:	83 c4 10             	add    $0x10,%esp
  8021eb:	39 cb                	cmp    %ecx,%ebx
  8021ed:	74 1b                	je     80220a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8021ef:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021f2:	75 cf                	jne    8021c3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021f4:	8b 42 68             	mov    0x68(%edx),%eax
  8021f7:	6a 01                	push   $0x1
  8021f9:	50                   	push   %eax
  8021fa:	53                   	push   %ebx
  8021fb:	68 cb 30 80 00       	push   $0x8030cb
  802200:	e8 be e5 ff ff       	call   8007c3 <cprintf>
  802205:	83 c4 10             	add    $0x10,%esp
  802208:	eb b9                	jmp    8021c3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80220a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80220d:	0f 94 c0             	sete   %al
  802210:	0f b6 c0             	movzbl %al,%eax
}
  802213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802216:	5b                   	pop    %ebx
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <devpipe_write>:
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	57                   	push   %edi
  80221f:	56                   	push   %esi
  802220:	53                   	push   %ebx
  802221:	83 ec 28             	sub    $0x28,%esp
  802224:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802227:	56                   	push   %esi
  802228:	e8 d1 f2 ff ff       	call   8014fe <fd2data>
  80222d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	bf 00 00 00 00       	mov    $0x0,%edi
  802237:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80223a:	75 09                	jne    802245 <devpipe_write+0x2a>
	return i;
  80223c:	89 f8                	mov    %edi,%eax
  80223e:	eb 23                	jmp    802263 <devpipe_write+0x48>
			sys_yield();
  802240:	e8 35 ef ff ff       	call   80117a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802245:	8b 43 04             	mov    0x4(%ebx),%eax
  802248:	8b 0b                	mov    (%ebx),%ecx
  80224a:	8d 51 20             	lea    0x20(%ecx),%edx
  80224d:	39 d0                	cmp    %edx,%eax
  80224f:	72 1a                	jb     80226b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802251:	89 da                	mov    %ebx,%edx
  802253:	89 f0                	mov    %esi,%eax
  802255:	e8 5c ff ff ff       	call   8021b6 <_pipeisclosed>
  80225a:	85 c0                	test   %eax,%eax
  80225c:	74 e2                	je     802240 <devpipe_write+0x25>
				return 0;
  80225e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802266:	5b                   	pop    %ebx
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80226b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80226e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802272:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802275:	89 c2                	mov    %eax,%edx
  802277:	c1 fa 1f             	sar    $0x1f,%edx
  80227a:	89 d1                	mov    %edx,%ecx
  80227c:	c1 e9 1b             	shr    $0x1b,%ecx
  80227f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802282:	83 e2 1f             	and    $0x1f,%edx
  802285:	29 ca                	sub    %ecx,%edx
  802287:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80228b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80228f:	83 c0 01             	add    $0x1,%eax
  802292:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802295:	83 c7 01             	add    $0x1,%edi
  802298:	eb 9d                	jmp    802237 <devpipe_write+0x1c>

0080229a <devpipe_read>:
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	57                   	push   %edi
  80229e:	56                   	push   %esi
  80229f:	53                   	push   %ebx
  8022a0:	83 ec 18             	sub    $0x18,%esp
  8022a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8022a6:	57                   	push   %edi
  8022a7:	e8 52 f2 ff ff       	call   8014fe <fd2data>
  8022ac:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8022ae:	83 c4 10             	add    $0x10,%esp
  8022b1:	be 00 00 00 00       	mov    $0x0,%esi
  8022b6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b9:	75 13                	jne    8022ce <devpipe_read+0x34>
	return i;
  8022bb:	89 f0                	mov    %esi,%eax
  8022bd:	eb 02                	jmp    8022c1 <devpipe_read+0x27>
				return i;
  8022bf:	89 f0                	mov    %esi,%eax
}
  8022c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
			sys_yield();
  8022c9:	e8 ac ee ff ff       	call   80117a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8022ce:	8b 03                	mov    (%ebx),%eax
  8022d0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022d3:	75 18                	jne    8022ed <devpipe_read+0x53>
			if (i > 0)
  8022d5:	85 f6                	test   %esi,%esi
  8022d7:	75 e6                	jne    8022bf <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8022d9:	89 da                	mov    %ebx,%edx
  8022db:	89 f8                	mov    %edi,%eax
  8022dd:	e8 d4 fe ff ff       	call   8021b6 <_pipeisclosed>
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	74 e3                	je     8022c9 <devpipe_read+0x2f>
				return 0;
  8022e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022eb:	eb d4                	jmp    8022c1 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022ed:	99                   	cltd   
  8022ee:	c1 ea 1b             	shr    $0x1b,%edx
  8022f1:	01 d0                	add    %edx,%eax
  8022f3:	83 e0 1f             	and    $0x1f,%eax
  8022f6:	29 d0                	sub    %edx,%eax
  8022f8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802300:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802303:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802306:	83 c6 01             	add    $0x1,%esi
  802309:	eb ab                	jmp    8022b6 <devpipe_read+0x1c>

0080230b <pipe>:
{
  80230b:	55                   	push   %ebp
  80230c:	89 e5                	mov    %esp,%ebp
  80230e:	56                   	push   %esi
  80230f:	53                   	push   %ebx
  802310:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802316:	50                   	push   %eax
  802317:	e8 f9 f1 ff ff       	call   801515 <fd_alloc>
  80231c:	89 c3                	mov    %eax,%ebx
  80231e:	83 c4 10             	add    $0x10,%esp
  802321:	85 c0                	test   %eax,%eax
  802323:	0f 88 23 01 00 00    	js     80244c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802329:	83 ec 04             	sub    $0x4,%esp
  80232c:	68 07 04 00 00       	push   $0x407
  802331:	ff 75 f4             	push   -0xc(%ebp)
  802334:	6a 00                	push   $0x0
  802336:	e8 5e ee ff ff       	call   801199 <sys_page_alloc>
  80233b:	89 c3                	mov    %eax,%ebx
  80233d:	83 c4 10             	add    $0x10,%esp
  802340:	85 c0                	test   %eax,%eax
  802342:	0f 88 04 01 00 00    	js     80244c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802348:	83 ec 0c             	sub    $0xc,%esp
  80234b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80234e:	50                   	push   %eax
  80234f:	e8 c1 f1 ff ff       	call   801515 <fd_alloc>
  802354:	89 c3                	mov    %eax,%ebx
  802356:	83 c4 10             	add    $0x10,%esp
  802359:	85 c0                	test   %eax,%eax
  80235b:	0f 88 db 00 00 00    	js     80243c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802361:	83 ec 04             	sub    $0x4,%esp
  802364:	68 07 04 00 00       	push   $0x407
  802369:	ff 75 f0             	push   -0x10(%ebp)
  80236c:	6a 00                	push   $0x0
  80236e:	e8 26 ee ff ff       	call   801199 <sys_page_alloc>
  802373:	89 c3                	mov    %eax,%ebx
  802375:	83 c4 10             	add    $0x10,%esp
  802378:	85 c0                	test   %eax,%eax
  80237a:	0f 88 bc 00 00 00    	js     80243c <pipe+0x131>
	va = fd2data(fd0);
  802380:	83 ec 0c             	sub    $0xc,%esp
  802383:	ff 75 f4             	push   -0xc(%ebp)
  802386:	e8 73 f1 ff ff       	call   8014fe <fd2data>
  80238b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80238d:	83 c4 0c             	add    $0xc,%esp
  802390:	68 07 04 00 00       	push   $0x407
  802395:	50                   	push   %eax
  802396:	6a 00                	push   $0x0
  802398:	e8 fc ed ff ff       	call   801199 <sys_page_alloc>
  80239d:	89 c3                	mov    %eax,%ebx
  80239f:	83 c4 10             	add    $0x10,%esp
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	0f 88 82 00 00 00    	js     80242c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023aa:	83 ec 0c             	sub    $0xc,%esp
  8023ad:	ff 75 f0             	push   -0x10(%ebp)
  8023b0:	e8 49 f1 ff ff       	call   8014fe <fd2data>
  8023b5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023bc:	50                   	push   %eax
  8023bd:	6a 00                	push   $0x0
  8023bf:	56                   	push   %esi
  8023c0:	6a 00                	push   $0x0
  8023c2:	e8 15 ee ff ff       	call   8011dc <sys_page_map>
  8023c7:	89 c3                	mov    %eax,%ebx
  8023c9:	83 c4 20             	add    $0x20,%esp
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	78 4e                	js     80241e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8023d0:	a1 40 40 80 00       	mov    0x804040,%eax
  8023d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023d8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8023da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023dd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8023e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023e7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8023e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023f3:	83 ec 0c             	sub    $0xc,%esp
  8023f6:	ff 75 f4             	push   -0xc(%ebp)
  8023f9:	e8 f0 f0 ff ff       	call   8014ee <fd2num>
  8023fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802401:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802403:	83 c4 04             	add    $0x4,%esp
  802406:	ff 75 f0             	push   -0x10(%ebp)
  802409:	e8 e0 f0 ff ff       	call   8014ee <fd2num>
  80240e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802411:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802414:	83 c4 10             	add    $0x10,%esp
  802417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80241c:	eb 2e                	jmp    80244c <pipe+0x141>
	sys_page_unmap(0, va);
  80241e:	83 ec 08             	sub    $0x8,%esp
  802421:	56                   	push   %esi
  802422:	6a 00                	push   $0x0
  802424:	e8 f5 ed ff ff       	call   80121e <sys_page_unmap>
  802429:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80242c:	83 ec 08             	sub    $0x8,%esp
  80242f:	ff 75 f0             	push   -0x10(%ebp)
  802432:	6a 00                	push   $0x0
  802434:	e8 e5 ed ff ff       	call   80121e <sys_page_unmap>
  802439:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80243c:	83 ec 08             	sub    $0x8,%esp
  80243f:	ff 75 f4             	push   -0xc(%ebp)
  802442:	6a 00                	push   $0x0
  802444:	e8 d5 ed ff ff       	call   80121e <sys_page_unmap>
  802449:	83 c4 10             	add    $0x10,%esp
}
  80244c:	89 d8                	mov    %ebx,%eax
  80244e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802451:	5b                   	pop    %ebx
  802452:	5e                   	pop    %esi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    

00802455 <pipeisclosed>:
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80245b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245e:	50                   	push   %eax
  80245f:	ff 75 08             	push   0x8(%ebp)
  802462:	e8 fe f0 ff ff       	call   801565 <fd_lookup>
  802467:	83 c4 10             	add    $0x10,%esp
  80246a:	85 c0                	test   %eax,%eax
  80246c:	78 18                	js     802486 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80246e:	83 ec 0c             	sub    $0xc,%esp
  802471:	ff 75 f4             	push   -0xc(%ebp)
  802474:	e8 85 f0 ff ff       	call   8014fe <fd2data>
  802479:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80247b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247e:	e8 33 fd ff ff       	call   8021b6 <_pipeisclosed>
  802483:	83 c4 10             	add    $0x10,%esp
}
  802486:	c9                   	leave  
  802487:	c3                   	ret    

00802488 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802488:	b8 00 00 00 00       	mov    $0x0,%eax
  80248d:	c3                   	ret    

0080248e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80248e:	55                   	push   %ebp
  80248f:	89 e5                	mov    %esp,%ebp
  802491:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802494:	68 e3 30 80 00       	push   $0x8030e3
  802499:	ff 75 0c             	push   0xc(%ebp)
  80249c:	e8 fc e8 ff ff       	call   800d9d <strcpy>
	return 0;
}
  8024a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024a6:	c9                   	leave  
  8024a7:	c3                   	ret    

008024a8 <devcons_write>:
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	57                   	push   %edi
  8024ac:	56                   	push   %esi
  8024ad:	53                   	push   %ebx
  8024ae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8024b4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024b9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8024bf:	eb 2e                	jmp    8024ef <devcons_write+0x47>
		m = n - tot;
  8024c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024c4:	29 f3                	sub    %esi,%ebx
  8024c6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8024cb:	39 c3                	cmp    %eax,%ebx
  8024cd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8024d0:	83 ec 04             	sub    $0x4,%esp
  8024d3:	53                   	push   %ebx
  8024d4:	89 f0                	mov    %esi,%eax
  8024d6:	03 45 0c             	add    0xc(%ebp),%eax
  8024d9:	50                   	push   %eax
  8024da:	57                   	push   %edi
  8024db:	e8 53 ea ff ff       	call   800f33 <memmove>
		sys_cputs(buf, m);
  8024e0:	83 c4 08             	add    $0x8,%esp
  8024e3:	53                   	push   %ebx
  8024e4:	57                   	push   %edi
  8024e5:	e8 f3 eb ff ff       	call   8010dd <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024ea:	01 de                	add    %ebx,%esi
  8024ec:	83 c4 10             	add    $0x10,%esp
  8024ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024f2:	72 cd                	jb     8024c1 <devcons_write+0x19>
}
  8024f4:	89 f0                	mov    %esi,%eax
  8024f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024f9:	5b                   	pop    %ebx
  8024fa:	5e                   	pop    %esi
  8024fb:	5f                   	pop    %edi
  8024fc:	5d                   	pop    %ebp
  8024fd:	c3                   	ret    

008024fe <devcons_read>:
{
  8024fe:	55                   	push   %ebp
  8024ff:	89 e5                	mov    %esp,%ebp
  802501:	83 ec 08             	sub    $0x8,%esp
  802504:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802509:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80250d:	75 07                	jne    802516 <devcons_read+0x18>
  80250f:	eb 1f                	jmp    802530 <devcons_read+0x32>
		sys_yield();
  802511:	e8 64 ec ff ff       	call   80117a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802516:	e8 e0 eb ff ff       	call   8010fb <sys_cgetc>
  80251b:	85 c0                	test   %eax,%eax
  80251d:	74 f2                	je     802511 <devcons_read+0x13>
	if (c < 0)
  80251f:	78 0f                	js     802530 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802521:	83 f8 04             	cmp    $0x4,%eax
  802524:	74 0c                	je     802532 <devcons_read+0x34>
	*(char*)vbuf = c;
  802526:	8b 55 0c             	mov    0xc(%ebp),%edx
  802529:	88 02                	mov    %al,(%edx)
	return 1;
  80252b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802530:	c9                   	leave  
  802531:	c3                   	ret    
		return 0;
  802532:	b8 00 00 00 00       	mov    $0x0,%eax
  802537:	eb f7                	jmp    802530 <devcons_read+0x32>

00802539 <cputchar>:
{
  802539:	55                   	push   %ebp
  80253a:	89 e5                	mov    %esp,%ebp
  80253c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80253f:	8b 45 08             	mov    0x8(%ebp),%eax
  802542:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802545:	6a 01                	push   $0x1
  802547:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80254a:	50                   	push   %eax
  80254b:	e8 8d eb ff ff       	call   8010dd <sys_cputs>
}
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	c9                   	leave  
  802554:	c3                   	ret    

00802555 <getchar>:
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80255b:	6a 01                	push   $0x1
  80255d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802560:	50                   	push   %eax
  802561:	6a 00                	push   $0x0
  802563:	e8 66 f2 ff ff       	call   8017ce <read>
	if (r < 0)
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	85 c0                	test   %eax,%eax
  80256d:	78 06                	js     802575 <getchar+0x20>
	if (r < 1)
  80256f:	74 06                	je     802577 <getchar+0x22>
	return c;
  802571:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802575:	c9                   	leave  
  802576:	c3                   	ret    
		return -E_EOF;
  802577:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80257c:	eb f7                	jmp    802575 <getchar+0x20>

0080257e <iscons>:
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802587:	50                   	push   %eax
  802588:	ff 75 08             	push   0x8(%ebp)
  80258b:	e8 d5 ef ff ff       	call   801565 <fd_lookup>
  802590:	83 c4 10             	add    $0x10,%esp
  802593:	85 c0                	test   %eax,%eax
  802595:	78 11                	js     8025a8 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80259a:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025a0:	39 10                	cmp    %edx,(%eax)
  8025a2:	0f 94 c0             	sete   %al
  8025a5:	0f b6 c0             	movzbl %al,%eax
}
  8025a8:	c9                   	leave  
  8025a9:	c3                   	ret    

008025aa <opencons>:
{
  8025aa:	55                   	push   %ebp
  8025ab:	89 e5                	mov    %esp,%ebp
  8025ad:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8025b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b3:	50                   	push   %eax
  8025b4:	e8 5c ef ff ff       	call   801515 <fd_alloc>
  8025b9:	83 c4 10             	add    $0x10,%esp
  8025bc:	85 c0                	test   %eax,%eax
  8025be:	78 3a                	js     8025fa <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025c0:	83 ec 04             	sub    $0x4,%esp
  8025c3:	68 07 04 00 00       	push   $0x407
  8025c8:	ff 75 f4             	push   -0xc(%ebp)
  8025cb:	6a 00                	push   $0x0
  8025cd:	e8 c7 eb ff ff       	call   801199 <sys_page_alloc>
  8025d2:	83 c4 10             	add    $0x10,%esp
  8025d5:	85 c0                	test   %eax,%eax
  8025d7:	78 21                	js     8025fa <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8025d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025dc:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025e2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025ee:	83 ec 0c             	sub    $0xc,%esp
  8025f1:	50                   	push   %eax
  8025f2:	e8 f7 ee ff ff       	call   8014ee <fd2num>
  8025f7:	83 c4 10             	add    $0x10,%esp
}
  8025fa:	c9                   	leave  
  8025fb:	c3                   	ret    

008025fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802602:	89 c2                	mov    %eax,%edx
  802604:	c1 ea 16             	shr    $0x16,%edx
  802607:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80260e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802613:	f6 c1 01             	test   $0x1,%cl
  802616:	74 1c                	je     802634 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802618:	c1 e8 0c             	shr    $0xc,%eax
  80261b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802622:	a8 01                	test   $0x1,%al
  802624:	74 0e                	je     802634 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802626:	c1 e8 0c             	shr    $0xc,%eax
  802629:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802630:	ef 
  802631:	0f b7 d2             	movzwl %dx,%edx
}
  802634:	89 d0                	mov    %edx,%eax
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	66 90                	xchg   %ax,%ax
  80263a:	66 90                	xchg   %ax,%ax
  80263c:	66 90                	xchg   %ax,%ax
  80263e:	66 90                	xchg   %ax,%ax

00802640 <__udivdi3>:
  802640:	f3 0f 1e fb          	endbr32 
  802644:	55                   	push   %ebp
  802645:	57                   	push   %edi
  802646:	56                   	push   %esi
  802647:	53                   	push   %ebx
  802648:	83 ec 1c             	sub    $0x1c,%esp
  80264b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80264f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802653:	8b 74 24 34          	mov    0x34(%esp),%esi
  802657:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80265b:	85 c0                	test   %eax,%eax
  80265d:	75 19                	jne    802678 <__udivdi3+0x38>
  80265f:	39 f3                	cmp    %esi,%ebx
  802661:	76 4d                	jbe    8026b0 <__udivdi3+0x70>
  802663:	31 ff                	xor    %edi,%edi
  802665:	89 e8                	mov    %ebp,%eax
  802667:	89 f2                	mov    %esi,%edx
  802669:	f7 f3                	div    %ebx
  80266b:	89 fa                	mov    %edi,%edx
  80266d:	83 c4 1c             	add    $0x1c,%esp
  802670:	5b                   	pop    %ebx
  802671:	5e                   	pop    %esi
  802672:	5f                   	pop    %edi
  802673:	5d                   	pop    %ebp
  802674:	c3                   	ret    
  802675:	8d 76 00             	lea    0x0(%esi),%esi
  802678:	39 f0                	cmp    %esi,%eax
  80267a:	76 14                	jbe    802690 <__udivdi3+0x50>
  80267c:	31 ff                	xor    %edi,%edi
  80267e:	31 c0                	xor    %eax,%eax
  802680:	89 fa                	mov    %edi,%edx
  802682:	83 c4 1c             	add    $0x1c,%esp
  802685:	5b                   	pop    %ebx
  802686:	5e                   	pop    %esi
  802687:	5f                   	pop    %edi
  802688:	5d                   	pop    %ebp
  802689:	c3                   	ret    
  80268a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802690:	0f bd f8             	bsr    %eax,%edi
  802693:	83 f7 1f             	xor    $0x1f,%edi
  802696:	75 48                	jne    8026e0 <__udivdi3+0xa0>
  802698:	39 f0                	cmp    %esi,%eax
  80269a:	72 06                	jb     8026a2 <__udivdi3+0x62>
  80269c:	31 c0                	xor    %eax,%eax
  80269e:	39 eb                	cmp    %ebp,%ebx
  8026a0:	77 de                	ja     802680 <__udivdi3+0x40>
  8026a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a7:	eb d7                	jmp    802680 <__udivdi3+0x40>
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	89 d9                	mov    %ebx,%ecx
  8026b2:	85 db                	test   %ebx,%ebx
  8026b4:	75 0b                	jne    8026c1 <__udivdi3+0x81>
  8026b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bb:	31 d2                	xor    %edx,%edx
  8026bd:	f7 f3                	div    %ebx
  8026bf:	89 c1                	mov    %eax,%ecx
  8026c1:	31 d2                	xor    %edx,%edx
  8026c3:	89 f0                	mov    %esi,%eax
  8026c5:	f7 f1                	div    %ecx
  8026c7:	89 c6                	mov    %eax,%esi
  8026c9:	89 e8                	mov    %ebp,%eax
  8026cb:	89 f7                	mov    %esi,%edi
  8026cd:	f7 f1                	div    %ecx
  8026cf:	89 fa                	mov    %edi,%edx
  8026d1:	83 c4 1c             	add    $0x1c,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	89 f9                	mov    %edi,%ecx
  8026e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026e7:	29 fa                	sub    %edi,%edx
  8026e9:	d3 e0                	shl    %cl,%eax
  8026eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026ef:	89 d1                	mov    %edx,%ecx
  8026f1:	89 d8                	mov    %ebx,%eax
  8026f3:	d3 e8                	shr    %cl,%eax
  8026f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026f9:	09 c1                	or     %eax,%ecx
  8026fb:	89 f0                	mov    %esi,%eax
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f9                	mov    %edi,%ecx
  802703:	d3 e3                	shl    %cl,%ebx
  802705:	89 d1                	mov    %edx,%ecx
  802707:	d3 e8                	shr    %cl,%eax
  802709:	89 f9                	mov    %edi,%ecx
  80270b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80270f:	89 eb                	mov    %ebp,%ebx
  802711:	d3 e6                	shl    %cl,%esi
  802713:	89 d1                	mov    %edx,%ecx
  802715:	d3 eb                	shr    %cl,%ebx
  802717:	09 f3                	or     %esi,%ebx
  802719:	89 c6                	mov    %eax,%esi
  80271b:	89 f2                	mov    %esi,%edx
  80271d:	89 d8                	mov    %ebx,%eax
  80271f:	f7 74 24 08          	divl   0x8(%esp)
  802723:	89 d6                	mov    %edx,%esi
  802725:	89 c3                	mov    %eax,%ebx
  802727:	f7 64 24 0c          	mull   0xc(%esp)
  80272b:	39 d6                	cmp    %edx,%esi
  80272d:	72 19                	jb     802748 <__udivdi3+0x108>
  80272f:	89 f9                	mov    %edi,%ecx
  802731:	d3 e5                	shl    %cl,%ebp
  802733:	39 c5                	cmp    %eax,%ebp
  802735:	73 04                	jae    80273b <__udivdi3+0xfb>
  802737:	39 d6                	cmp    %edx,%esi
  802739:	74 0d                	je     802748 <__udivdi3+0x108>
  80273b:	89 d8                	mov    %ebx,%eax
  80273d:	31 ff                	xor    %edi,%edi
  80273f:	e9 3c ff ff ff       	jmp    802680 <__udivdi3+0x40>
  802744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802748:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80274b:	31 ff                	xor    %edi,%edi
  80274d:	e9 2e ff ff ff       	jmp    802680 <__udivdi3+0x40>
  802752:	66 90                	xchg   %ax,%ax
  802754:	66 90                	xchg   %ax,%ax
  802756:	66 90                	xchg   %ax,%ax
  802758:	66 90                	xchg   %ax,%ax
  80275a:	66 90                	xchg   %ax,%ax
  80275c:	66 90                	xchg   %ax,%ax
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__umoddi3>:
  802760:	f3 0f 1e fb          	endbr32 
  802764:	55                   	push   %ebp
  802765:	57                   	push   %edi
  802766:	56                   	push   %esi
  802767:	53                   	push   %ebx
  802768:	83 ec 1c             	sub    $0x1c,%esp
  80276b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80276f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802773:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802777:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80277b:	89 f0                	mov    %esi,%eax
  80277d:	89 da                	mov    %ebx,%edx
  80277f:	85 ff                	test   %edi,%edi
  802781:	75 15                	jne    802798 <__umoddi3+0x38>
  802783:	39 dd                	cmp    %ebx,%ebp
  802785:	76 39                	jbe    8027c0 <__umoddi3+0x60>
  802787:	f7 f5                	div    %ebp
  802789:	89 d0                	mov    %edx,%eax
  80278b:	31 d2                	xor    %edx,%edx
  80278d:	83 c4 1c             	add    $0x1c,%esp
  802790:	5b                   	pop    %ebx
  802791:	5e                   	pop    %esi
  802792:	5f                   	pop    %edi
  802793:	5d                   	pop    %ebp
  802794:	c3                   	ret    
  802795:	8d 76 00             	lea    0x0(%esi),%esi
  802798:	39 df                	cmp    %ebx,%edi
  80279a:	77 f1                	ja     80278d <__umoddi3+0x2d>
  80279c:	0f bd cf             	bsr    %edi,%ecx
  80279f:	83 f1 1f             	xor    $0x1f,%ecx
  8027a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027a6:	75 40                	jne    8027e8 <__umoddi3+0x88>
  8027a8:	39 df                	cmp    %ebx,%edi
  8027aa:	72 04                	jb     8027b0 <__umoddi3+0x50>
  8027ac:	39 f5                	cmp    %esi,%ebp
  8027ae:	77 dd                	ja     80278d <__umoddi3+0x2d>
  8027b0:	89 da                	mov    %ebx,%edx
  8027b2:	89 f0                	mov    %esi,%eax
  8027b4:	29 e8                	sub    %ebp,%eax
  8027b6:	19 fa                	sbb    %edi,%edx
  8027b8:	eb d3                	jmp    80278d <__umoddi3+0x2d>
  8027ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c0:	89 e9                	mov    %ebp,%ecx
  8027c2:	85 ed                	test   %ebp,%ebp
  8027c4:	75 0b                	jne    8027d1 <__umoddi3+0x71>
  8027c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027cb:	31 d2                	xor    %edx,%edx
  8027cd:	f7 f5                	div    %ebp
  8027cf:	89 c1                	mov    %eax,%ecx
  8027d1:	89 d8                	mov    %ebx,%eax
  8027d3:	31 d2                	xor    %edx,%edx
  8027d5:	f7 f1                	div    %ecx
  8027d7:	89 f0                	mov    %esi,%eax
  8027d9:	f7 f1                	div    %ecx
  8027db:	89 d0                	mov    %edx,%eax
  8027dd:	31 d2                	xor    %edx,%edx
  8027df:	eb ac                	jmp    80278d <__umoddi3+0x2d>
  8027e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8027f1:	29 c2                	sub    %eax,%edx
  8027f3:	89 c1                	mov    %eax,%ecx
  8027f5:	89 e8                	mov    %ebp,%eax
  8027f7:	d3 e7                	shl    %cl,%edi
  8027f9:	89 d1                	mov    %edx,%ecx
  8027fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027ff:	d3 e8                	shr    %cl,%eax
  802801:	89 c1                	mov    %eax,%ecx
  802803:	8b 44 24 04          	mov    0x4(%esp),%eax
  802807:	09 f9                	or     %edi,%ecx
  802809:	89 df                	mov    %ebx,%edi
  80280b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80280f:	89 c1                	mov    %eax,%ecx
  802811:	d3 e5                	shl    %cl,%ebp
  802813:	89 d1                	mov    %edx,%ecx
  802815:	d3 ef                	shr    %cl,%edi
  802817:	89 c1                	mov    %eax,%ecx
  802819:	89 f0                	mov    %esi,%eax
  80281b:	d3 e3                	shl    %cl,%ebx
  80281d:	89 d1                	mov    %edx,%ecx
  80281f:	89 fa                	mov    %edi,%edx
  802821:	d3 e8                	shr    %cl,%eax
  802823:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802828:	09 d8                	or     %ebx,%eax
  80282a:	f7 74 24 08          	divl   0x8(%esp)
  80282e:	89 d3                	mov    %edx,%ebx
  802830:	d3 e6                	shl    %cl,%esi
  802832:	f7 e5                	mul    %ebp
  802834:	89 c7                	mov    %eax,%edi
  802836:	89 d1                	mov    %edx,%ecx
  802838:	39 d3                	cmp    %edx,%ebx
  80283a:	72 06                	jb     802842 <__umoddi3+0xe2>
  80283c:	75 0e                	jne    80284c <__umoddi3+0xec>
  80283e:	39 c6                	cmp    %eax,%esi
  802840:	73 0a                	jae    80284c <__umoddi3+0xec>
  802842:	29 e8                	sub    %ebp,%eax
  802844:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802848:	89 d1                	mov    %edx,%ecx
  80284a:	89 c7                	mov    %eax,%edi
  80284c:	89 f5                	mov    %esi,%ebp
  80284e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802852:	29 fd                	sub    %edi,%ebp
  802854:	19 cb                	sbb    %ecx,%ebx
  802856:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80285b:	89 d8                	mov    %ebx,%eax
  80285d:	d3 e0                	shl    %cl,%eax
  80285f:	89 f1                	mov    %esi,%ecx
  802861:	d3 ed                	shr    %cl,%ebp
  802863:	d3 eb                	shr    %cl,%ebx
  802865:	09 e8                	or     %ebp,%eax
  802867:	89 da                	mov    %ebx,%edx
  802869:	83 c4 1c             	add    $0x1c,%esp
  80286c:	5b                   	pop    %ebx
  80286d:	5e                   	pop    %esi
  80286e:	5f                   	pop    %edi
  80286f:	5d                   	pop    %ebp
  802870:	c3                   	ret    
