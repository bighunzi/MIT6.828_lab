
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
  800042:	e8 53 0d 00 00       	call   800d9a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 4a 14 00 00       	call   8014a3 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 e7 13 00 00       	call   80144f <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 6f 13 00 00       	call   8013e8 <ipc_recv>
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
  8000f4:	e8 c7 06 00 00       	call   8007c0 <cprintf>

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
  800122:	e8 38 0c 00 00       	call   800d5f <strlen>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80012d:	0f 85 ba 03 00 00    	jne    8004ed <umain+0x46f>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 f8 28 80 00       	push   $0x8028f8
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
  800185:	e8 c1 0c 00 00       	call   800e4b <strcmp>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	85 c0                	test   %eax,%eax
  80018f:	0f 85 8f 03 00 00    	jne    800524 <umain+0x4a6>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	68 37 29 80 00       	push   $0x802937
  80019d:	e8 1e 06 00 00       	call   8007c0 <cprintf>

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
  800209:	ff 15 10 40 80 00    	call   *0x804010
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800215:	0f 85 2f 03 00 00    	jne    80054a <umain+0x4cc>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 6d 29 80 00       	push   $0x80296d
  800223:	e8 98 05 00 00       	call   8007c0 <cprintf>

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
  800251:	e8 09 0b 00 00       	call   800d5f <strlen>
  800256:	83 c4 0c             	add    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	ff 35 00 40 80 00    	push   0x804000
  800260:	68 00 c0 cc cc       	push   $0xccccc000
  800265:	ff d3                	call   *%ebx
  800267:	89 c3                	mov    %eax,%ebx
  800269:	83 c4 04             	add    $0x4,%esp
  80026c:	ff 35 00 40 80 00    	push   0x804000
  800272:	e8 e8 0a 00 00       	call   800d5f <strlen>
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	39 d8                	cmp    %ebx,%eax
  80027c:	0f 85 ec 02 00 00    	jne    80056e <umain+0x4f0>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	68 b5 29 80 00       	push   $0x8029b5
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
  8002bd:	ff 15 10 40 80 00    	call   *0x804010
  8002c3:	89 c3                	mov    %eax,%ebx
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	0f 88 b0 02 00 00    	js     800580 <umain+0x502>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 35 00 40 80 00    	push   0x804000
  8002d9:	e8 81 0a 00 00       	call   800d5f <strlen>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	39 d8                	cmp    %ebx,%eax
  8002e3:	0f 85 a9 02 00 00    	jne    800592 <umain+0x514>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 35 00 40 80 00    	push   0x804000
  8002f2:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002f8:	50                   	push   %eax
  8002f9:	e8 4d 0b 00 00       	call   800e4b <strcmp>
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	85 c0                	test   %eax,%eax
  800303:	0f 85 9b 02 00 00    	jne    8005a4 <umain+0x526>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	68 7c 2b 80 00       	push   $0x802b7c
  800311:	e8 aa 04 00 00       	call   8007c0 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800316:	83 c4 08             	add    $0x8,%esp
  800319:	6a 00                	push   $0x0
  80031b:	68 80 28 80 00       	push   $0x802880
  800320:	e8 fa 18 00 00       	call   801c1f <open>
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
  800347:	e8 d3 18 00 00       	call   801c1f <open>
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
  80038a:	e8 31 04 00 00       	call   8007c0 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	68 01 01 00 00       	push   $0x101
  800397:	68 e4 29 80 00       	push   $0x8029e4
  80039c:	e8 7e 18 00 00       	call   801c1f <open>
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
  8003df:	e8 a6 14 00 00       	call   80188a <write>
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
  800401:	e8 7a 12 00 00       	call   801680 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800406:	83 c4 08             	add    $0x8,%esp
  800409:	6a 00                	push   $0x0
  80040b:	68 e4 29 80 00       	push   $0x8029e4
  800410:	e8 0a 18 00 00       	call   801c1f <open>
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
  800438:	e8 06 14 00 00       	call   801843 <readn>
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
  800473:	e8 08 12 00 00       	call   801680 <close>
	cprintf("large file is good\n");
  800478:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
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
  800490:	68 8b 28 80 00       	push   $0x80288b
  800495:	6a 20                	push   $0x20
  800497:	68 a5 28 80 00       	push   $0x8028a5
  80049c:	e8 44 02 00 00       	call   8006e5 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	68 40 2a 80 00       	push   $0x802a40
  8004a9:	6a 22                	push   $0x22
  8004ab:	68 a5 28 80 00       	push   $0x8028a5
  8004b0:	e8 30 02 00 00       	call   8006e5 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b5:	50                   	push   %eax
  8004b6:	68 be 28 80 00       	push   $0x8028be
  8004bb:	6a 25                	push   $0x25
  8004bd:	68 a5 28 80 00       	push   $0x8028a5
  8004c2:	e8 1e 02 00 00       	call   8006e5 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004c7:	83 ec 04             	sub    $0x4,%esp
  8004ca:	68 64 2a 80 00       	push   $0x802a64
  8004cf:	6a 27                	push   $0x27
  8004d1:	68 a5 28 80 00       	push   $0x8028a5
  8004d6:	e8 0a 02 00 00       	call   8006e5 <_panic>
		panic("file_stat: %e", r);
  8004db:	50                   	push   %eax
  8004dc:	68 ea 28 80 00       	push   $0x8028ea
  8004e1:	6a 2b                	push   $0x2b
  8004e3:	68 a5 28 80 00       	push   $0x8028a5
  8004e8:	e8 f8 01 00 00       	call   8006e5 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004ed:	83 ec 0c             	sub    $0xc,%esp
  8004f0:	ff 35 00 40 80 00    	push   0x804000
  8004f6:	e8 64 08 00 00       	call   800d5f <strlen>
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 75 cc             	push   -0x34(%ebp)
  800501:	68 94 2a 80 00       	push   $0x802a94
  800506:	6a 2d                	push   $0x2d
  800508:	68 a5 28 80 00       	push   $0x8028a5
  80050d:	e8 d3 01 00 00       	call   8006e5 <_panic>
		panic("file_read: %e", r);
  800512:	50                   	push   %eax
  800513:	68 0b 29 80 00       	push   $0x80290b
  800518:	6a 32                	push   $0x32
  80051a:	68 a5 28 80 00       	push   $0x8028a5
  80051f:	e8 c1 01 00 00       	call   8006e5 <_panic>
		panic("file_read returned wrong data");
  800524:	83 ec 04             	sub    $0x4,%esp
  800527:	68 19 29 80 00       	push   $0x802919
  80052c:	6a 34                	push   $0x34
  80052e:	68 a5 28 80 00       	push   $0x8028a5
  800533:	e8 ad 01 00 00       	call   8006e5 <_panic>
		panic("file_close: %e", r);
  800538:	50                   	push   %eax
  800539:	68 4a 29 80 00       	push   $0x80294a
  80053e:	6a 38                	push   $0x38
  800540:	68 a5 28 80 00       	push   $0x8028a5
  800545:	e8 9b 01 00 00       	call   8006e5 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054a:	50                   	push   %eax
  80054b:	68 bc 2a 80 00       	push   $0x802abc
  800550:	6a 43                	push   $0x43
  800552:	68 a5 28 80 00       	push   $0x8028a5
  800557:	e8 89 01 00 00       	call   8006e5 <_panic>
		panic("serve_open /new-file: %e", r);
  80055c:	50                   	push   %eax
  80055d:	68 8d 29 80 00       	push   $0x80298d
  800562:	6a 48                	push   $0x48
  800564:	68 a5 28 80 00       	push   $0x8028a5
  800569:	e8 77 01 00 00       	call   8006e5 <_panic>
		panic("file_write: %e", r);
  80056e:	53                   	push   %ebx
  80056f:	68 a6 29 80 00       	push   $0x8029a6
  800574:	6a 4b                	push   $0x4b
  800576:	68 a5 28 80 00       	push   $0x8028a5
  80057b:	e8 65 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write: %e", r);
  800580:	50                   	push   %eax
  800581:	68 f4 2a 80 00       	push   $0x802af4
  800586:	6a 51                	push   $0x51
  800588:	68 a5 28 80 00       	push   $0x8028a5
  80058d:	e8 53 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800592:	53                   	push   %ebx
  800593:	68 14 2b 80 00       	push   $0x802b14
  800598:	6a 53                	push   $0x53
  80059a:	68 a5 28 80 00       	push   $0x8028a5
  80059f:	e8 41 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	68 4c 2b 80 00       	push   $0x802b4c
  8005ac:	6a 55                	push   $0x55
  8005ae:	68 a5 28 80 00       	push   $0x8028a5
  8005b3:	e8 2d 01 00 00       	call   8006e5 <_panic>
		panic("open /not-found: %e", r);
  8005b8:	50                   	push   %eax
  8005b9:	68 91 28 80 00       	push   $0x802891
  8005be:	6a 5a                	push   $0x5a
  8005c0:	68 a5 28 80 00       	push   $0x8028a5
  8005c5:	e8 1b 01 00 00       	call   8006e5 <_panic>
		panic("open /not-found succeeded!");
  8005ca:	83 ec 04             	sub    $0x4,%esp
  8005cd:	68 c9 29 80 00       	push   $0x8029c9
  8005d2:	6a 5c                	push   $0x5c
  8005d4:	68 a5 28 80 00       	push   $0x8028a5
  8005d9:	e8 07 01 00 00       	call   8006e5 <_panic>
		panic("open /newmotd: %e", r);
  8005de:	50                   	push   %eax
  8005df:	68 c4 28 80 00       	push   $0x8028c4
  8005e4:	6a 5f                	push   $0x5f
  8005e6:	68 a5 28 80 00       	push   $0x8028a5
  8005eb:	e8 f5 00 00 00       	call   8006e5 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f0:	83 ec 04             	sub    $0x4,%esp
  8005f3:	68 a0 2b 80 00       	push   $0x802ba0
  8005f8:	6a 62                	push   $0x62
  8005fa:	68 a5 28 80 00       	push   $0x8028a5
  8005ff:	e8 e1 00 00 00       	call   8006e5 <_panic>
		panic("creat /big: %e", f);
  800604:	50                   	push   %eax
  800605:	68 e9 29 80 00       	push   $0x8029e9
  80060a:	6a 67                	push   $0x67
  80060c:	68 a5 28 80 00       	push   $0x8028a5
  800611:	e8 cf 00 00 00       	call   8006e5 <_panic>
			panic("write /big@%d: %e", i, r);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	50                   	push   %eax
  80061a:	56                   	push   %esi
  80061b:	68 f8 29 80 00       	push   $0x8029f8
  800620:	6a 6c                	push   $0x6c
  800622:	68 a5 28 80 00       	push   $0x8028a5
  800627:	e8 b9 00 00 00       	call   8006e5 <_panic>
		panic("open /big: %e", f);
  80062c:	50                   	push   %eax
  80062d:	68 0a 2a 80 00       	push   $0x802a0a
  800632:	6a 71                	push   $0x71
  800634:	68 a5 28 80 00       	push   $0x8028a5
  800639:	e8 a7 00 00 00       	call   8006e5 <_panic>
			panic("read /big@%d: %e", i, r);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	68 18 2a 80 00       	push   $0x802a18
  800648:	6a 75                	push   $0x75
  80064a:	68 a5 28 80 00       	push   $0x8028a5
  80064f:	e8 91 00 00 00       	call   8006e5 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	68 00 02 00 00       	push   $0x200
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	68 c8 2b 80 00       	push   $0x802bc8
  800663:	6a 77                	push   $0x77
  800665:	68 a5 28 80 00       	push   $0x8028a5
  80066a:	e8 76 00 00 00       	call   8006e5 <_panic>
			panic("read /big from %d returned bad data %d",
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	50                   	push   %eax
  800673:	53                   	push   %ebx
  800674:	68 f4 2b 80 00       	push   $0x802bf4
  800679:	6a 7a                	push   $0x7a
  80067b:	68 a5 28 80 00       	push   $0x8028a5
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
  8006a2:	a3 00 50 80 00       	mov    %eax,0x805000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006a7:	85 db                	test   %ebx,%ebx
  8006a9:	7e 07                	jle    8006b2 <libmain+0x2d>
		binaryname = argv[0];
  8006ab:	8b 06                	mov    (%esi),%eax
  8006ad:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8006d1:	e8 d7 0f 00 00       	call   8016ad <close_all>
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
  8006ed:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8006f3:	e8 60 0a 00 00       	call   801158 <sys_getenvid>
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	ff 75 0c             	push   0xc(%ebp)
  8006fe:	ff 75 08             	push   0x8(%ebp)
  800701:	56                   	push   %esi
  800702:	50                   	push   %eax
  800703:	68 4c 2c 80 00       	push   $0x802c4c
  800708:	e8 b3 00 00 00       	call   8007c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80070d:	83 c4 18             	add    $0x18,%esp
  800710:	53                   	push   %ebx
  800711:	ff 75 10             	push   0x10(%ebp)
  800714:	e8 56 00 00 00       	call   80076f <vcprintf>
	cprintf("\n");
  800719:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
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
  800822:	e8 09 1e 00 00       	call   802630 <__udivdi3>
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
  800860:	e8 eb 1e 00 00       	call   802750 <__umoddi3>
  800865:	83 c4 14             	add    $0x14,%esp
  800868:	0f be 80 6f 2c 80 00 	movsbl 0x802c6f(%eax),%eax
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
  800922:	ff 24 85 c0 2d 80 00 	jmp    *0x802dc0(,%eax,4)
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
  8009f0:	8b 14 85 20 2f 80 00 	mov    0x802f20(,%eax,4),%edx
  8009f7:	85 d2                	test   %edx,%edx
  8009f9:	74 18                	je     800a13 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8009fb:	52                   	push   %edx
  8009fc:	68 71 30 80 00       	push   $0x803071
  800a01:	53                   	push   %ebx
  800a02:	56                   	push   %esi
  800a03:	e8 92 fe ff ff       	call   80089a <printfmt>
  800a08:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a0b:	89 7d 14             	mov    %edi,0x14(%ebp)
  800a0e:	e9 66 02 00 00       	jmp    800c79 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800a13:	50                   	push   %eax
  800a14:	68 87 2c 80 00       	push   $0x802c87
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
  800a3b:	b8 80 2c 80 00       	mov    $0x802c80,%eax
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
  801147:	68 7f 2f 80 00       	push   $0x802f7f
  80114c:	6a 2a                	push   $0x2a
  80114e:	68 9c 2f 80 00       	push   $0x802f9c
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
  8011c8:	68 7f 2f 80 00       	push   $0x802f7f
  8011cd:	6a 2a                	push   $0x2a
  8011cf:	68 9c 2f 80 00       	push   $0x802f9c
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
  80120a:	68 7f 2f 80 00       	push   $0x802f7f
  80120f:	6a 2a                	push   $0x2a
  801211:	68 9c 2f 80 00       	push   $0x802f9c
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
  80124c:	68 7f 2f 80 00       	push   $0x802f7f
  801251:	6a 2a                	push   $0x2a
  801253:	68 9c 2f 80 00       	push   $0x802f9c
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
  80128e:	68 7f 2f 80 00       	push   $0x802f7f
  801293:	6a 2a                	push   $0x2a
  801295:	68 9c 2f 80 00       	push   $0x802f9c
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
  8012d0:	68 7f 2f 80 00       	push   $0x802f7f
  8012d5:	6a 2a                	push   $0x2a
  8012d7:	68 9c 2f 80 00       	push   $0x802f9c
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
  801312:	68 7f 2f 80 00       	push   $0x802f7f
  801317:	6a 2a                	push   $0x2a
  801319:	68 9c 2f 80 00       	push   $0x802f9c
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
  801376:	68 7f 2f 80 00       	push   $0x802f7f
  80137b:	6a 2a                	push   $0x2a
  80137d:	68 9c 2f 80 00       	push   $0x802f9c
  801382:	e8 5e f3 ff ff       	call   8006e5 <_panic>

00801387 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80138d:	ba 00 00 00 00       	mov    $0x0,%edx
  801392:	b8 0e 00 00 00       	mov    $0xe,%eax
  801397:	89 d1                	mov    %edx,%ecx
  801399:	89 d3                	mov    %edx,%ebx
  80139b:	89 d7                	mov    %edx,%edi
  80139d:	89 d6                	mov    %edx,%esi
  80139f:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8013bc:	89 df                	mov    %ebx,%edi
  8013be:	89 de                	mov    %ebx,%esi
  8013c0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5f                   	pop    %edi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8013dd:	89 df                	mov    %ebx,%edi
  8013df:	89 de                	mov    %ebx,%esi
  8013e1:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8013fd:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	50                   	push   %eax
  801404:	e8 3d ff ff ff       	call   801346 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 f6                	test   %esi,%esi
  80140e:	74 14                	je     801424 <ipc_recv+0x3c>
  801410:	ba 00 00 00 00       	mov    $0x0,%edx
  801415:	85 c0                	test   %eax,%eax
  801417:	78 09                	js     801422 <ipc_recv+0x3a>
  801419:	8b 15 00 50 80 00    	mov    0x805000,%edx
  80141f:	8b 52 74             	mov    0x74(%edx),%edx
  801422:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801424:	85 db                	test   %ebx,%ebx
  801426:	74 14                	je     80143c <ipc_recv+0x54>
  801428:	ba 00 00 00 00       	mov    $0x0,%edx
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 09                	js     80143a <ipc_recv+0x52>
  801431:	8b 15 00 50 80 00    	mov    0x805000,%edx
  801437:	8b 52 78             	mov    0x78(%edx),%edx
  80143a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 08                	js     801448 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801440:	a1 00 50 80 00       	mov    0x805000,%eax
  801445:	8b 40 70             	mov    0x70(%eax),%eax
}
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	57                   	push   %edi
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80145e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801461:	85 db                	test   %ebx,%ebx
  801463:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801468:	0f 44 d8             	cmove  %eax,%ebx
  80146b:	eb 05                	jmp    801472 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80146d:	e8 05 fd ff ff       	call   801177 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801472:	ff 75 14             	push   0x14(%ebp)
  801475:	53                   	push   %ebx
  801476:	56                   	push   %esi
  801477:	57                   	push   %edi
  801478:	e8 a6 fe ff ff       	call   801323 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801483:	74 e8                	je     80146d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801485:	85 c0                	test   %eax,%eax
  801487:	78 08                	js     801491 <ipc_send+0x42>
	}while (r<0);

}
  801489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148c:	5b                   	pop    %ebx
  80148d:	5e                   	pop    %esi
  80148e:	5f                   	pop    %edi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801491:	50                   	push   %eax
  801492:	68 aa 2f 80 00       	push   $0x802faa
  801497:	6a 3d                	push   $0x3d
  801499:	68 be 2f 80 00       	push   $0x802fbe
  80149e:	e8 42 f2 ff ff       	call   8006e5 <_panic>

008014a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014ae:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014b1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014b7:	8b 52 50             	mov    0x50(%edx),%edx
  8014ba:	39 ca                	cmp    %ecx,%edx
  8014bc:	74 11                	je     8014cf <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8014be:	83 c0 01             	add    $0x1,%eax
  8014c1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014c6:	75 e6                	jne    8014ae <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8014c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cd:	eb 0b                	jmp    8014da <ipc_find_env+0x37>
			return envs[i].env_id;
  8014cf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014d7:	8b 40 48             	mov    0x48(%eax),%eax
}
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014df:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8014e7:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    

008014ec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014fc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	c1 ea 16             	shr    $0x16,%edx
  801510:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801517:	f6 c2 01             	test   $0x1,%dl
  80151a:	74 29                	je     801545 <fd_alloc+0x42>
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	c1 ea 0c             	shr    $0xc,%edx
  801521:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801528:	f6 c2 01             	test   $0x1,%dl
  80152b:	74 18                	je     801545 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80152d:	05 00 10 00 00       	add    $0x1000,%eax
  801532:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801537:	75 d2                	jne    80150b <fd_alloc+0x8>
  801539:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80153e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801543:	eb 05                	jmp    80154a <fd_alloc+0x47>
			return 0;
  801545:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80154a:	8b 55 08             	mov    0x8(%ebp),%edx
  80154d:	89 02                	mov    %eax,(%edx)
}
  80154f:	89 c8                	mov    %ecx,%eax
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801559:	83 f8 1f             	cmp    $0x1f,%eax
  80155c:	77 30                	ja     80158e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80155e:	c1 e0 0c             	shl    $0xc,%eax
  801561:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801566:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80156c:	f6 c2 01             	test   $0x1,%dl
  80156f:	74 24                	je     801595 <fd_lookup+0x42>
  801571:	89 c2                	mov    %eax,%edx
  801573:	c1 ea 0c             	shr    $0xc,%edx
  801576:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80157d:	f6 c2 01             	test   $0x1,%dl
  801580:	74 1a                	je     80159c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801582:	8b 55 0c             	mov    0xc(%ebp),%edx
  801585:	89 02                	mov    %eax,(%edx)
	return 0;
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    
		return -E_INVAL;
  80158e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801593:	eb f7                	jmp    80158c <fd_lookup+0x39>
		return -E_INVAL;
  801595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159a:	eb f0                	jmp    80158c <fd_lookup+0x39>
  80159c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a1:	eb e9                	jmp    80158c <fd_lookup+0x39>

008015a3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b2:	bb 08 40 80 00       	mov    $0x804008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8015b7:	39 13                	cmp    %edx,(%ebx)
  8015b9:	74 37                	je     8015f2 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8015bb:	83 c0 01             	add    $0x1,%eax
  8015be:	8b 1c 85 44 30 80 00 	mov    0x803044(,%eax,4),%ebx
  8015c5:	85 db                	test   %ebx,%ebx
  8015c7:	75 ee                	jne    8015b7 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c9:	a1 00 50 80 00       	mov    0x805000,%eax
  8015ce:	8b 40 48             	mov    0x48(%eax),%eax
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	52                   	push   %edx
  8015d5:	50                   	push   %eax
  8015d6:	68 c8 2f 80 00       	push   $0x802fc8
  8015db:	e8 e0 f1 ff ff       	call   8007c0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015eb:	89 1a                	mov    %ebx,(%edx)
}
  8015ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    
			return 0;
  8015f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f7:	eb ef                	jmp    8015e8 <dev_lookup+0x45>

008015f9 <fd_close>:
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	57                   	push   %edi
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 24             	sub    $0x24,%esp
  801602:	8b 75 08             	mov    0x8(%ebp),%esi
  801605:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801608:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80160b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80160c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801612:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801615:	50                   	push   %eax
  801616:	e8 38 ff ff ff       	call   801553 <fd_lookup>
  80161b:	89 c3                	mov    %eax,%ebx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 05                	js     801629 <fd_close+0x30>
	    || fd != fd2)
  801624:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801627:	74 16                	je     80163f <fd_close+0x46>
		return (must_exist ? r : 0);
  801629:	89 f8                	mov    %edi,%eax
  80162b:	84 c0                	test   %al,%al
  80162d:	b8 00 00 00 00       	mov    $0x0,%eax
  801632:	0f 44 d8             	cmove  %eax,%ebx
}
  801635:	89 d8                	mov    %ebx,%eax
  801637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5f                   	pop    %edi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	ff 36                	push   (%esi)
  801648:	e8 56 ff ff ff       	call   8015a3 <dev_lookup>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 1a                	js     801670 <fd_close+0x77>
		if (dev->dev_close)
  801656:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801659:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80165c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801661:	85 c0                	test   %eax,%eax
  801663:	74 0b                	je     801670 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	56                   	push   %esi
  801669:	ff d0                	call   *%eax
  80166b:	89 c3                	mov    %eax,%ebx
  80166d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	56                   	push   %esi
  801674:	6a 00                	push   $0x0
  801676:	e8 a0 fb ff ff       	call   80121b <sys_page_unmap>
	return r;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	eb b5                	jmp    801635 <fd_close+0x3c>

00801680 <close>:

int
close(int fdnum)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	ff 75 08             	push   0x8(%ebp)
  80168d:	e8 c1 fe ff ff       	call   801553 <fd_lookup>
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	85 c0                	test   %eax,%eax
  801697:	79 02                	jns    80169b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    
		return fd_close(fd, 1);
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	6a 01                	push   $0x1
  8016a0:	ff 75 f4             	push   -0xc(%ebp)
  8016a3:	e8 51 ff ff ff       	call   8015f9 <fd_close>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	eb ec                	jmp    801699 <close+0x19>

008016ad <close_all>:

void
close_all(void)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	e8 be ff ff ff       	call   801680 <close>
	for (i = 0; i < MAXFD; i++)
  8016c2:	83 c3 01             	add    $0x1,%ebx
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	83 fb 20             	cmp    $0x20,%ebx
  8016cb:	75 ec                	jne    8016b9 <close_all+0xc>
}
  8016cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	57                   	push   %edi
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	ff 75 08             	push   0x8(%ebp)
  8016e2:	e8 6c fe ff ff       	call   801553 <fd_lookup>
  8016e7:	89 c3                	mov    %eax,%ebx
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 7f                	js     80176f <dup+0x9d>
		return r;
	close(newfdnum);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	ff 75 0c             	push   0xc(%ebp)
  8016f6:	e8 85 ff ff ff       	call   801680 <close>

	newfd = INDEX2FD(newfdnum);
  8016fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016fe:	c1 e6 0c             	shl    $0xc,%esi
  801701:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170a:	89 3c 24             	mov    %edi,(%esp)
  80170d:	e8 da fd ff ff       	call   8014ec <fd2data>
  801712:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801714:	89 34 24             	mov    %esi,(%esp)
  801717:	e8 d0 fd ff ff       	call   8014ec <fd2data>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801722:	89 d8                	mov    %ebx,%eax
  801724:	c1 e8 16             	shr    $0x16,%eax
  801727:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80172e:	a8 01                	test   $0x1,%al
  801730:	74 11                	je     801743 <dup+0x71>
  801732:	89 d8                	mov    %ebx,%eax
  801734:	c1 e8 0c             	shr    $0xc,%eax
  801737:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80173e:	f6 c2 01             	test   $0x1,%dl
  801741:	75 36                	jne    801779 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801743:	89 f8                	mov    %edi,%eax
  801745:	c1 e8 0c             	shr    $0xc,%eax
  801748:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	25 07 0e 00 00       	and    $0xe07,%eax
  801757:	50                   	push   %eax
  801758:	56                   	push   %esi
  801759:	6a 00                	push   $0x0
  80175b:	57                   	push   %edi
  80175c:	6a 00                	push   $0x0
  80175e:	e8 76 fa ff ff       	call   8011d9 <sys_page_map>
  801763:	89 c3                	mov    %eax,%ebx
  801765:	83 c4 20             	add    $0x20,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 33                	js     80179f <dup+0xcd>
		goto err;

	return newfdnum;
  80176c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80176f:	89 d8                	mov    %ebx,%eax
  801771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801779:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801780:	83 ec 0c             	sub    $0xc,%esp
  801783:	25 07 0e 00 00       	and    $0xe07,%eax
  801788:	50                   	push   %eax
  801789:	ff 75 d4             	push   -0x2c(%ebp)
  80178c:	6a 00                	push   $0x0
  80178e:	53                   	push   %ebx
  80178f:	6a 00                	push   $0x0
  801791:	e8 43 fa ff ff       	call   8011d9 <sys_page_map>
  801796:	89 c3                	mov    %eax,%ebx
  801798:	83 c4 20             	add    $0x20,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	79 a4                	jns    801743 <dup+0x71>
	sys_page_unmap(0, newfd);
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	56                   	push   %esi
  8017a3:	6a 00                	push   $0x0
  8017a5:	e8 71 fa ff ff       	call   80121b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017aa:	83 c4 08             	add    $0x8,%esp
  8017ad:	ff 75 d4             	push   -0x2c(%ebp)
  8017b0:	6a 00                	push   $0x0
  8017b2:	e8 64 fa ff ff       	call   80121b <sys_page_unmap>
	return r;
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb b3                	jmp    80176f <dup+0x9d>

008017bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 18             	sub    $0x18,%esp
  8017c4:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ca:	50                   	push   %eax
  8017cb:	56                   	push   %esi
  8017cc:	e8 82 fd ff ff       	call   801553 <fd_lookup>
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 3c                	js     801814 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	ff 33                	push   (%ebx)
  8017e4:	e8 ba fd ff ff       	call   8015a3 <dev_lookup>
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 24                	js     801814 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017f0:	8b 43 08             	mov    0x8(%ebx),%eax
  8017f3:	83 e0 03             	and    $0x3,%eax
  8017f6:	83 f8 01             	cmp    $0x1,%eax
  8017f9:	74 20                	je     80181b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fe:	8b 40 08             	mov    0x8(%eax),%eax
  801801:	85 c0                	test   %eax,%eax
  801803:	74 37                	je     80183c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	ff 75 10             	push   0x10(%ebp)
  80180b:	ff 75 0c             	push   0xc(%ebp)
  80180e:	53                   	push   %ebx
  80180f:	ff d0                	call   *%eax
  801811:	83 c4 10             	add    $0x10,%esp
}
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80181b:	a1 00 50 80 00       	mov    0x805000,%eax
  801820:	8b 40 48             	mov    0x48(%eax),%eax
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	56                   	push   %esi
  801827:	50                   	push   %eax
  801828:	68 09 30 80 00       	push   $0x803009
  80182d:	e8 8e ef ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183a:	eb d8                	jmp    801814 <read+0x58>
		return -E_NOT_SUPP;
  80183c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801841:	eb d1                	jmp    801814 <read+0x58>

00801843 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801852:	bb 00 00 00 00       	mov    $0x0,%ebx
  801857:	eb 02                	jmp    80185b <readn+0x18>
  801859:	01 c3                	add    %eax,%ebx
  80185b:	39 f3                	cmp    %esi,%ebx
  80185d:	73 21                	jae    801880 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	89 f0                	mov    %esi,%eax
  801864:	29 d8                	sub    %ebx,%eax
  801866:	50                   	push   %eax
  801867:	89 d8                	mov    %ebx,%eax
  801869:	03 45 0c             	add    0xc(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	57                   	push   %edi
  80186e:	e8 49 ff ff ff       	call   8017bc <read>
		if (m < 0)
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	78 04                	js     80187e <readn+0x3b>
			return m;
		if (m == 0)
  80187a:	75 dd                	jne    801859 <readn+0x16>
  80187c:	eb 02                	jmp    801880 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801880:	89 d8                	mov    %ebx,%eax
  801882:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5f                   	pop    %edi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	83 ec 18             	sub    $0x18,%esp
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	53                   	push   %ebx
  80189a:	e8 b4 fc ff ff       	call   801553 <fd_lookup>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 37                	js     8018dd <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	ff 36                	push   (%esi)
  8018b2:	e8 ec fc ff ff       	call   8015a3 <dev_lookup>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 1f                	js     8018dd <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018be:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8018c2:	74 20                	je     8018e4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	74 37                	je     801905 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	ff 75 10             	push   0x10(%ebp)
  8018d4:	ff 75 0c             	push   0xc(%ebp)
  8018d7:	56                   	push   %esi
  8018d8:	ff d0                	call   *%eax
  8018da:	83 c4 10             	add    $0x10,%esp
}
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e4:	a1 00 50 80 00       	mov    0x805000,%eax
  8018e9:	8b 40 48             	mov    0x48(%eax),%eax
  8018ec:	83 ec 04             	sub    $0x4,%esp
  8018ef:	53                   	push   %ebx
  8018f0:	50                   	push   %eax
  8018f1:	68 25 30 80 00       	push   $0x803025
  8018f6:	e8 c5 ee ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801903:	eb d8                	jmp    8018dd <write+0x53>
		return -E_NOT_SUPP;
  801905:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80190a:	eb d1                	jmp    8018dd <write+0x53>

0080190c <seek>:

int
seek(int fdnum, off_t offset)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	ff 75 08             	push   0x8(%ebp)
  801919:	e8 35 fc ff ff       	call   801553 <fd_lookup>
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	78 0e                	js     801933 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801925:	8b 55 0c             	mov    0xc(%ebp),%edx
  801928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	83 ec 18             	sub    $0x18,%esp
  80193d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801940:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	53                   	push   %ebx
  801945:	e8 09 fc ff ff       	call   801553 <fd_lookup>
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 34                	js     801985 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801951:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195a:	50                   	push   %eax
  80195b:	ff 36                	push   (%esi)
  80195d:	e8 41 fc ff ff       	call   8015a3 <dev_lookup>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	78 1c                	js     801985 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801969:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80196d:	74 1d                	je     80198c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801972:	8b 40 18             	mov    0x18(%eax),%eax
  801975:	85 c0                	test   %eax,%eax
  801977:	74 34                	je     8019ad <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	ff 75 0c             	push   0xc(%ebp)
  80197f:	56                   	push   %esi
  801980:	ff d0                	call   *%eax
  801982:	83 c4 10             	add    $0x10,%esp
}
  801985:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80198c:	a1 00 50 80 00       	mov    0x805000,%eax
  801991:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	53                   	push   %ebx
  801998:	50                   	push   %eax
  801999:	68 e8 2f 80 00       	push   $0x802fe8
  80199e:	e8 1d ee ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ab:	eb d8                	jmp    801985 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8019ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b2:	eb d1                	jmp    801985 <ftruncate+0x50>

008019b4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	83 ec 18             	sub    $0x18,%esp
  8019bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	ff 75 08             	push   0x8(%ebp)
  8019c6:	e8 88 fb ff ff       	call   801553 <fd_lookup>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 49                	js     801a1b <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019db:	50                   	push   %eax
  8019dc:	ff 36                	push   (%esi)
  8019de:	e8 c0 fb ff ff       	call   8015a3 <dev_lookup>
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 31                	js     801a1b <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8019ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ed:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019f1:	74 2f                	je     801a22 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019fd:	00 00 00 
	stat->st_isdir = 0;
  801a00:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a07:	00 00 00 
	stat->st_dev = dev;
  801a0a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	53                   	push   %ebx
  801a14:	56                   	push   %esi
  801a15:	ff 50 14             	call   *0x14(%eax)
  801a18:	83 c4 10             	add    $0x10,%esp
}
  801a1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    
		return -E_NOT_SUPP;
  801a22:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a27:	eb f2                	jmp    801a1b <fstat+0x67>

00801a29 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	6a 00                	push   $0x0
  801a33:	ff 75 08             	push   0x8(%ebp)
  801a36:	e8 e4 01 00 00       	call   801c1f <open>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 1b                	js     801a5f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	ff 75 0c             	push   0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 64 ff ff ff       	call   8019b4 <fstat>
  801a50:	89 c6                	mov    %eax,%esi
	close(fd);
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 26 fc ff ff       	call   801680 <close>
	return r;
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	89 f3                	mov    %esi,%ebx
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	89 c6                	mov    %eax,%esi
  801a6f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a71:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801a78:	74 27                	je     801aa1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a7a:	6a 07                	push   $0x7
  801a7c:	68 00 60 80 00       	push   $0x806000
  801a81:	56                   	push   %esi
  801a82:	ff 35 00 70 80 00    	push   0x807000
  801a88:	e8 c2 f9 ff ff       	call   80144f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a8d:	83 c4 0c             	add    $0xc,%esp
  801a90:	6a 00                	push   $0x0
  801a92:	53                   	push   %ebx
  801a93:	6a 00                	push   $0x0
  801a95:	e8 4e f9 ff ff       	call   8013e8 <ipc_recv>
}
  801a9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	6a 01                	push   $0x1
  801aa6:	e8 f8 f9 ff ff       	call   8014a3 <ipc_find_env>
  801aab:	a3 00 70 80 00       	mov    %eax,0x807000
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	eb c5                	jmp    801a7a <fsipc+0x12>

00801ab5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad3:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad8:	e8 8b ff ff ff       	call   801a68 <fsipc>
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <devfile_flush>:
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	8b 40 0c             	mov    0xc(%eax),%eax
  801aeb:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	b8 06 00 00 00       	mov    $0x6,%eax
  801afa:	e8 69 ff ff ff       	call   801a68 <fsipc>
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <devfile_stat>:
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	53                   	push   %ebx
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b11:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b16:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1b:	b8 05 00 00 00       	mov    $0x5,%eax
  801b20:	e8 43 ff ff ff       	call   801a68 <fsipc>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 2c                	js     801b55 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	68 00 60 80 00       	push   $0x806000
  801b31:	53                   	push   %ebx
  801b32:	e8 63 f2 ff ff       	call   800d9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b37:	a1 80 60 80 00       	mov    0x806080,%eax
  801b3c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b42:	a1 84 60 80 00       	mov    0x806084,%eax
  801b47:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <devfile_write>:
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	8b 45 10             	mov    0x10(%ebp),%eax
  801b63:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b68:	39 d0                	cmp    %edx,%eax
  801b6a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b70:	8b 52 0c             	mov    0xc(%edx),%edx
  801b73:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b79:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b7e:	50                   	push   %eax
  801b7f:	ff 75 0c             	push   0xc(%ebp)
  801b82:	68 08 60 80 00       	push   $0x806008
  801b87:	e8 a4 f3 ff ff       	call   800f30 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b91:	b8 04 00 00 00       	mov    $0x4,%eax
  801b96:	e8 cd fe ff ff       	call   801a68 <fsipc>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <devfile_read>:
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba8:	8b 40 0c             	mov    0xc(%eax),%eax
  801bab:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bb0:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbb:	b8 03 00 00 00       	mov    $0x3,%eax
  801bc0:	e8 a3 fe ff ff       	call   801a68 <fsipc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 1f                	js     801bea <devfile_read+0x4d>
	assert(r <= n);
  801bcb:	39 f0                	cmp    %esi,%eax
  801bcd:	77 24                	ja     801bf3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801bcf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bd4:	7f 33                	jg     801c09 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd6:	83 ec 04             	sub    $0x4,%esp
  801bd9:	50                   	push   %eax
  801bda:	68 00 60 80 00       	push   $0x806000
  801bdf:	ff 75 0c             	push   0xc(%ebp)
  801be2:	e8 49 f3 ff ff       	call   800f30 <memmove>
	return r;
  801be7:	83 c4 10             	add    $0x10,%esp
}
  801bea:	89 d8                	mov    %ebx,%eax
  801bec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    
	assert(r <= n);
  801bf3:	68 58 30 80 00       	push   $0x803058
  801bf8:	68 5f 30 80 00       	push   $0x80305f
  801bfd:	6a 7c                	push   $0x7c
  801bff:	68 74 30 80 00       	push   $0x803074
  801c04:	e8 dc ea ff ff       	call   8006e5 <_panic>
	assert(r <= PGSIZE);
  801c09:	68 7f 30 80 00       	push   $0x80307f
  801c0e:	68 5f 30 80 00       	push   $0x80305f
  801c13:	6a 7d                	push   $0x7d
  801c15:	68 74 30 80 00       	push   $0x803074
  801c1a:	e8 c6 ea ff ff       	call   8006e5 <_panic>

00801c1f <open>:
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c2a:	56                   	push   %esi
  801c2b:	e8 2f f1 ff ff       	call   800d5f <strlen>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c38:	7f 6c                	jg     801ca6 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c40:	50                   	push   %eax
  801c41:	e8 bd f8 ff ff       	call   801503 <fd_alloc>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 3c                	js     801c8b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801c4f:	83 ec 08             	sub    $0x8,%esp
  801c52:	56                   	push   %esi
  801c53:	68 00 60 80 00       	push   $0x806000
  801c58:	e8 3d f1 ff ff       	call   800d9a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c60:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c68:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6d:	e8 f6 fd ff ff       	call   801a68 <fsipc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 19                	js     801c94 <open+0x75>
	return fd2num(fd);
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	ff 75 f4             	push   -0xc(%ebp)
  801c81:	e8 56 f8 ff ff       	call   8014dc <fd2num>
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	83 c4 10             	add    $0x10,%esp
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
		fd_close(fd, 0);
  801c94:	83 ec 08             	sub    $0x8,%esp
  801c97:	6a 00                	push   $0x0
  801c99:	ff 75 f4             	push   -0xc(%ebp)
  801c9c:	e8 58 f9 ff ff       	call   8015f9 <fd_close>
		return r;
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	eb e5                	jmp    801c8b <open+0x6c>
		return -E_BAD_PATH;
  801ca6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cab:	eb de                	jmp    801c8b <open+0x6c>

00801cad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cb3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb8:	b8 08 00 00 00       	mov    $0x8,%eax
  801cbd:	e8 a6 fd ff ff       	call   801a68 <fsipc>
}
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cca:	68 8b 30 80 00       	push   $0x80308b
  801ccf:	ff 75 0c             	push   0xc(%ebp)
  801cd2:	e8 c3 f0 ff ff       	call   800d9a <strcpy>
	return 0;
}
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <devsock_close>:
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	53                   	push   %ebx
  801ce2:	83 ec 10             	sub    $0x10,%esp
  801ce5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ce8:	53                   	push   %ebx
  801ce9:	e8 fc 08 00 00       	call   8025ea <pageref>
  801cee:	89 c2                	mov    %eax,%edx
  801cf0:	83 c4 10             	add    $0x10,%esp
		return 0;
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801cf8:	83 fa 01             	cmp    $0x1,%edx
  801cfb:	74 05                	je     801d02 <devsock_close+0x24>
}
  801cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	ff 73 0c             	push   0xc(%ebx)
  801d08:	e8 b7 02 00 00       	call   801fc4 <nsipc_close>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	eb eb                	jmp    801cfd <devsock_close+0x1f>

00801d12 <devsock_write>:
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d18:	6a 00                	push   $0x0
  801d1a:	ff 75 10             	push   0x10(%ebp)
  801d1d:	ff 75 0c             	push   0xc(%ebp)
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	ff 70 0c             	push   0xc(%eax)
  801d26:	e8 79 03 00 00       	call   8020a4 <nsipc_send>
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    

00801d2d <devsock_read>:
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d33:	6a 00                	push   $0x0
  801d35:	ff 75 10             	push   0x10(%ebp)
  801d38:	ff 75 0c             	push   0xc(%ebp)
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	ff 70 0c             	push   0xc(%eax)
  801d41:	e8 ef 02 00 00       	call   802035 <nsipc_recv>
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <fd2sockid>:
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d4e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d51:	52                   	push   %edx
  801d52:	50                   	push   %eax
  801d53:	e8 fb f7 ff ff       	call   801553 <fd_lookup>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 10                	js     801d6f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d62:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801d68:	39 08                	cmp    %ecx,(%eax)
  801d6a:	75 05                	jne    801d71 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801d6c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    
		return -E_NOT_SUPP;
  801d71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d76:	eb f7                	jmp    801d6f <fd2sockid+0x27>

00801d78 <alloc_sockfd>:
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 1c             	sub    $0x1c,%esp
  801d80:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801d82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d85:	50                   	push   %eax
  801d86:	e8 78 f7 ff ff       	call   801503 <fd_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 43                	js     801dd7 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	68 07 04 00 00       	push   $0x407
  801d9c:	ff 75 f4             	push   -0xc(%ebp)
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 f0 f3 ff ff       	call   801196 <sys_page_alloc>
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 28                	js     801dd7 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801db8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801dc4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	50                   	push   %eax
  801dcb:	e8 0c f7 ff ff       	call   8014dc <fd2num>
  801dd0:	89 c3                	mov    %eax,%ebx
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	eb 0c                	jmp    801de3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	56                   	push   %esi
  801ddb:	e8 e4 01 00 00       	call   801fc4 <nsipc_close>
		return r;
  801de0:	83 c4 10             	add    $0x10,%esp
}
  801de3:	89 d8                	mov    %ebx,%eax
  801de5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <accept>:
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	e8 4e ff ff ff       	call   801d48 <fd2sockid>
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 1b                	js     801e19 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	ff 75 10             	push   0x10(%ebp)
  801e04:	ff 75 0c             	push   0xc(%ebp)
  801e07:	50                   	push   %eax
  801e08:	e8 0e 01 00 00       	call   801f1b <nsipc_accept>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 05                	js     801e19 <accept+0x2d>
	return alloc_sockfd(r);
  801e14:	e8 5f ff ff ff       	call   801d78 <alloc_sockfd>
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <bind>:
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e21:	8b 45 08             	mov    0x8(%ebp),%eax
  801e24:	e8 1f ff ff ff       	call   801d48 <fd2sockid>
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 12                	js     801e3f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801e2d:	83 ec 04             	sub    $0x4,%esp
  801e30:	ff 75 10             	push   0x10(%ebp)
  801e33:	ff 75 0c             	push   0xc(%ebp)
  801e36:	50                   	push   %eax
  801e37:	e8 31 01 00 00       	call   801f6d <nsipc_bind>
  801e3c:	83 c4 10             	add    $0x10,%esp
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <shutdown>:
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	e8 f9 fe ff ff       	call   801d48 <fd2sockid>
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 0f                	js     801e62 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	ff 75 0c             	push   0xc(%ebp)
  801e59:	50                   	push   %eax
  801e5a:	e8 43 01 00 00       	call   801fa2 <nsipc_shutdown>
  801e5f:	83 c4 10             	add    $0x10,%esp
}
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <connect>:
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6d:	e8 d6 fe ff ff       	call   801d48 <fd2sockid>
  801e72:	85 c0                	test   %eax,%eax
  801e74:	78 12                	js     801e88 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	ff 75 10             	push   0x10(%ebp)
  801e7c:	ff 75 0c             	push   0xc(%ebp)
  801e7f:	50                   	push   %eax
  801e80:	e8 59 01 00 00       	call   801fde <nsipc_connect>
  801e85:	83 c4 10             	add    $0x10,%esp
}
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <listen>:
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	e8 b0 fe ff ff       	call   801d48 <fd2sockid>
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	78 0f                	js     801eab <listen+0x21>
	return nsipc_listen(r, backlog);
  801e9c:	83 ec 08             	sub    $0x8,%esp
  801e9f:	ff 75 0c             	push   0xc(%ebp)
  801ea2:	50                   	push   %eax
  801ea3:	e8 6b 01 00 00       	call   802013 <nsipc_listen>
  801ea8:	83 c4 10             	add    $0x10,%esp
}
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <socket>:

int
socket(int domain, int type, int protocol)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801eb3:	ff 75 10             	push   0x10(%ebp)
  801eb6:	ff 75 0c             	push   0xc(%ebp)
  801eb9:	ff 75 08             	push   0x8(%ebp)
  801ebc:	e8 41 02 00 00       	call   802102 <nsipc_socket>
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 05                	js     801ecd <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ec8:	e8 ab fe ff ff       	call   801d78 <alloc_sockfd>
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	53                   	push   %ebx
  801ed3:	83 ec 04             	sub    $0x4,%esp
  801ed6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ed8:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  801edf:	74 26                	je     801f07 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ee1:	6a 07                	push   $0x7
  801ee3:	68 00 80 80 00       	push   $0x808000
  801ee8:	53                   	push   %ebx
  801ee9:	ff 35 00 90 80 00    	push   0x809000
  801eef:	e8 5b f5 ff ff       	call   80144f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ef4:	83 c4 0c             	add    $0xc,%esp
  801ef7:	6a 00                	push   $0x0
  801ef9:	6a 00                	push   $0x0
  801efb:	6a 00                	push   $0x0
  801efd:	e8 e6 f4 ff ff       	call   8013e8 <ipc_recv>
}
  801f02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	6a 02                	push   $0x2
  801f0c:	e8 92 f5 ff ff       	call   8014a3 <ipc_find_env>
  801f11:	a3 00 90 80 00       	mov    %eax,0x809000
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	eb c6                	jmp    801ee1 <nsipc+0x12>

00801f1b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f2b:	8b 06                	mov    (%esi),%eax
  801f2d:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	e8 93 ff ff ff       	call   801ecf <nsipc>
  801f3c:	89 c3                	mov    %eax,%ebx
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	79 09                	jns    801f4b <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f42:	89 d8                	mov    %ebx,%eax
  801f44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f4b:	83 ec 04             	sub    $0x4,%esp
  801f4e:	ff 35 10 80 80 00    	push   0x808010
  801f54:	68 00 80 80 00       	push   $0x808000
  801f59:	ff 75 0c             	push   0xc(%ebp)
  801f5c:	e8 cf ef ff ff       	call   800f30 <memmove>
		*addrlen = ret->ret_addrlen;
  801f61:	a1 10 80 80 00       	mov    0x808010,%eax
  801f66:	89 06                	mov    %eax,(%esi)
  801f68:	83 c4 10             	add    $0x10,%esp
	return r;
  801f6b:	eb d5                	jmp    801f42 <nsipc_accept+0x27>

00801f6d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	53                   	push   %ebx
  801f71:	83 ec 08             	sub    $0x8,%esp
  801f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f7f:	53                   	push   %ebx
  801f80:	ff 75 0c             	push   0xc(%ebp)
  801f83:	68 04 80 80 00       	push   $0x808004
  801f88:	e8 a3 ef ff ff       	call   800f30 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f8d:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801f93:	b8 02 00 00 00       	mov    $0x2,%eax
  801f98:	e8 32 ff ff ff       	call   801ecf <nsipc>
}
  801f9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb3:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801fb8:	b8 03 00 00 00       	mov    $0x3,%eax
  801fbd:	e8 0d ff ff ff       	call   801ecf <nsipc>
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <nsipc_close>:

int
nsipc_close(int s)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801fd2:	b8 04 00 00 00       	mov    $0x4,%eax
  801fd7:	e8 f3 fe ff ff       	call   801ecf <nsipc>
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 08             	sub    $0x8,%esp
  801fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ff0:	53                   	push   %ebx
  801ff1:	ff 75 0c             	push   0xc(%ebp)
  801ff4:	68 04 80 80 00       	push   $0x808004
  801ff9:	e8 32 ef ff ff       	call   800f30 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ffe:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802004:	b8 05 00 00 00       	mov    $0x5,%eax
  802009:	e8 c1 fe ff ff       	call   801ecf <nsipc>
}
  80200e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  802021:	8b 45 0c             	mov    0xc(%ebp),%eax
  802024:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802029:	b8 06 00 00 00       	mov    $0x6,%eax
  80202e:	e8 9c fe ff ff       	call   801ecf <nsipc>
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	56                   	push   %esi
  802039:	53                   	push   %ebx
  80203a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80203d:	8b 45 08             	mov    0x8(%ebp),%eax
  802040:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  802045:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  80204b:	8b 45 14             	mov    0x14(%ebp),%eax
  80204e:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802053:	b8 07 00 00 00       	mov    $0x7,%eax
  802058:	e8 72 fe ff ff       	call   801ecf <nsipc>
  80205d:	89 c3                	mov    %eax,%ebx
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 22                	js     802085 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802063:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802068:	39 c6                	cmp    %eax,%esi
  80206a:	0f 4e c6             	cmovle %esi,%eax
  80206d:	39 c3                	cmp    %eax,%ebx
  80206f:	7f 1d                	jg     80208e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802071:	83 ec 04             	sub    $0x4,%esp
  802074:	53                   	push   %ebx
  802075:	68 00 80 80 00       	push   $0x808000
  80207a:	ff 75 0c             	push   0xc(%ebp)
  80207d:	e8 ae ee ff ff       	call   800f30 <memmove>
  802082:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802085:	89 d8                	mov    %ebx,%eax
  802087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80208e:	68 97 30 80 00       	push   $0x803097
  802093:	68 5f 30 80 00       	push   $0x80305f
  802098:	6a 62                	push   $0x62
  80209a:	68 ac 30 80 00       	push   $0x8030ac
  80209f:	e8 41 e6 ff ff       	call   8006e5 <_panic>

008020a4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	53                   	push   %ebx
  8020a8:	83 ec 04             	sub    $0x4,%esp
  8020ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  8020b6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020bc:	7f 2e                	jg     8020ec <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020be:	83 ec 04             	sub    $0x4,%esp
  8020c1:	53                   	push   %ebx
  8020c2:	ff 75 0c             	push   0xc(%ebp)
  8020c5:	68 0c 80 80 00       	push   $0x80800c
  8020ca:	e8 61 ee ff ff       	call   800f30 <memmove>
	nsipcbuf.send.req_size = size;
  8020cf:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  8020d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d8:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  8020dd:	b8 08 00 00 00       	mov    $0x8,%eax
  8020e2:	e8 e8 fd ff ff       	call   801ecf <nsipc>
}
  8020e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    
	assert(size < 1600);
  8020ec:	68 b8 30 80 00       	push   $0x8030b8
  8020f1:	68 5f 30 80 00       	push   $0x80305f
  8020f6:	6a 6d                	push   $0x6d
  8020f8:	68 ac 30 80 00       	push   $0x8030ac
  8020fd:	e8 e3 e5 ff ff       	call   8006e5 <_panic>

00802102 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  802110:	8b 45 0c             	mov    0xc(%ebp),%eax
  802113:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  802118:	8b 45 10             	mov    0x10(%ebp),%eax
  80211b:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  802120:	b8 09 00 00 00       	mov    $0x9,%eax
  802125:	e8 a5 fd ff ff       	call   801ecf <nsipc>
}
  80212a:	c9                   	leave  
  80212b:	c3                   	ret    

0080212c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	56                   	push   %esi
  802130:	53                   	push   %ebx
  802131:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802134:	83 ec 0c             	sub    $0xc,%esp
  802137:	ff 75 08             	push   0x8(%ebp)
  80213a:	e8 ad f3 ff ff       	call   8014ec <fd2data>
  80213f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802141:	83 c4 08             	add    $0x8,%esp
  802144:	68 c4 30 80 00       	push   $0x8030c4
  802149:	53                   	push   %ebx
  80214a:	e8 4b ec ff ff       	call   800d9a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80214f:	8b 46 04             	mov    0x4(%esi),%eax
  802152:	2b 06                	sub    (%esi),%eax
  802154:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80215a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802161:	00 00 00 
	stat->st_dev = &devpipe;
  802164:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  80216b:	40 80 00 
	return 0;
}
  80216e:	b8 00 00 00 00       	mov    $0x0,%eax
  802173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802176:	5b                   	pop    %ebx
  802177:	5e                   	pop    %esi
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    

0080217a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	53                   	push   %ebx
  80217e:	83 ec 0c             	sub    $0xc,%esp
  802181:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802184:	53                   	push   %ebx
  802185:	6a 00                	push   $0x0
  802187:	e8 8f f0 ff ff       	call   80121b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80218c:	89 1c 24             	mov    %ebx,(%esp)
  80218f:	e8 58 f3 ff ff       	call   8014ec <fd2data>
  802194:	83 c4 08             	add    $0x8,%esp
  802197:	50                   	push   %eax
  802198:	6a 00                	push   $0x0
  80219a:	e8 7c f0 ff ff       	call   80121b <sys_page_unmap>
}
  80219f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a2:	c9                   	leave  
  8021a3:	c3                   	ret    

008021a4 <_pipeisclosed>:
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	57                   	push   %edi
  8021a8:	56                   	push   %esi
  8021a9:	53                   	push   %ebx
  8021aa:	83 ec 1c             	sub    $0x1c,%esp
  8021ad:	89 c7                	mov    %eax,%edi
  8021af:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8021b1:	a1 00 50 80 00       	mov    0x805000,%eax
  8021b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021b9:	83 ec 0c             	sub    $0xc,%esp
  8021bc:	57                   	push   %edi
  8021bd:	e8 28 04 00 00       	call   8025ea <pageref>
  8021c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021c5:	89 34 24             	mov    %esi,(%esp)
  8021c8:	e8 1d 04 00 00       	call   8025ea <pageref>
		nn = thisenv->env_runs;
  8021cd:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8021d3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	39 cb                	cmp    %ecx,%ebx
  8021db:	74 1b                	je     8021f8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8021dd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021e0:	75 cf                	jne    8021b1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021e2:	8b 42 58             	mov    0x58(%edx),%eax
  8021e5:	6a 01                	push   $0x1
  8021e7:	50                   	push   %eax
  8021e8:	53                   	push   %ebx
  8021e9:	68 cb 30 80 00       	push   $0x8030cb
  8021ee:	e8 cd e5 ff ff       	call   8007c0 <cprintf>
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	eb b9                	jmp    8021b1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8021f8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021fb:	0f 94 c0             	sete   %al
  8021fe:	0f b6 c0             	movzbl %al,%eax
}
  802201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    

00802209 <devpipe_write>:
{
  802209:	55                   	push   %ebp
  80220a:	89 e5                	mov    %esp,%ebp
  80220c:	57                   	push   %edi
  80220d:	56                   	push   %esi
  80220e:	53                   	push   %ebx
  80220f:	83 ec 28             	sub    $0x28,%esp
  802212:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802215:	56                   	push   %esi
  802216:	e8 d1 f2 ff ff       	call   8014ec <fd2data>
  80221b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	bf 00 00 00 00       	mov    $0x0,%edi
  802225:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802228:	75 09                	jne    802233 <devpipe_write+0x2a>
	return i;
  80222a:	89 f8                	mov    %edi,%eax
  80222c:	eb 23                	jmp    802251 <devpipe_write+0x48>
			sys_yield();
  80222e:	e8 44 ef ff ff       	call   801177 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802233:	8b 43 04             	mov    0x4(%ebx),%eax
  802236:	8b 0b                	mov    (%ebx),%ecx
  802238:	8d 51 20             	lea    0x20(%ecx),%edx
  80223b:	39 d0                	cmp    %edx,%eax
  80223d:	72 1a                	jb     802259 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80223f:	89 da                	mov    %ebx,%edx
  802241:	89 f0                	mov    %esi,%eax
  802243:	e8 5c ff ff ff       	call   8021a4 <_pipeisclosed>
  802248:	85 c0                	test   %eax,%eax
  80224a:	74 e2                	je     80222e <devpipe_write+0x25>
				return 0;
  80224c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802251:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80225c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802260:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802263:	89 c2                	mov    %eax,%edx
  802265:	c1 fa 1f             	sar    $0x1f,%edx
  802268:	89 d1                	mov    %edx,%ecx
  80226a:	c1 e9 1b             	shr    $0x1b,%ecx
  80226d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802270:	83 e2 1f             	and    $0x1f,%edx
  802273:	29 ca                	sub    %ecx,%edx
  802275:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802279:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80227d:	83 c0 01             	add    $0x1,%eax
  802280:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802283:	83 c7 01             	add    $0x1,%edi
  802286:	eb 9d                	jmp    802225 <devpipe_write+0x1c>

00802288 <devpipe_read>:
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
  80228e:	83 ec 18             	sub    $0x18,%esp
  802291:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802294:	57                   	push   %edi
  802295:	e8 52 f2 ff ff       	call   8014ec <fd2data>
  80229a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	be 00 00 00 00       	mov    $0x0,%esi
  8022a4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022a7:	75 13                	jne    8022bc <devpipe_read+0x34>
	return i;
  8022a9:	89 f0                	mov    %esi,%eax
  8022ab:	eb 02                	jmp    8022af <devpipe_read+0x27>
				return i;
  8022ad:	89 f0                	mov    %esi,%eax
}
  8022af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022b2:	5b                   	pop    %ebx
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    
			sys_yield();
  8022b7:	e8 bb ee ff ff       	call   801177 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8022bc:	8b 03                	mov    (%ebx),%eax
  8022be:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022c1:	75 18                	jne    8022db <devpipe_read+0x53>
			if (i > 0)
  8022c3:	85 f6                	test   %esi,%esi
  8022c5:	75 e6                	jne    8022ad <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8022c7:	89 da                	mov    %ebx,%edx
  8022c9:	89 f8                	mov    %edi,%eax
  8022cb:	e8 d4 fe ff ff       	call   8021a4 <_pipeisclosed>
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	74 e3                	je     8022b7 <devpipe_read+0x2f>
				return 0;
  8022d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d9:	eb d4                	jmp    8022af <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022db:	99                   	cltd   
  8022dc:	c1 ea 1b             	shr    $0x1b,%edx
  8022df:	01 d0                	add    %edx,%eax
  8022e1:	83 e0 1f             	and    $0x1f,%eax
  8022e4:	29 d0                	sub    %edx,%eax
  8022e6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022ee:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022f1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8022f4:	83 c6 01             	add    $0x1,%esi
  8022f7:	eb ab                	jmp    8022a4 <devpipe_read+0x1c>

008022f9 <pipe>:
{
  8022f9:	55                   	push   %ebp
  8022fa:	89 e5                	mov    %esp,%ebp
  8022fc:	56                   	push   %esi
  8022fd:	53                   	push   %ebx
  8022fe:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802304:	50                   	push   %eax
  802305:	e8 f9 f1 ff ff       	call   801503 <fd_alloc>
  80230a:	89 c3                	mov    %eax,%ebx
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	85 c0                	test   %eax,%eax
  802311:	0f 88 23 01 00 00    	js     80243a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802317:	83 ec 04             	sub    $0x4,%esp
  80231a:	68 07 04 00 00       	push   $0x407
  80231f:	ff 75 f4             	push   -0xc(%ebp)
  802322:	6a 00                	push   $0x0
  802324:	e8 6d ee ff ff       	call   801196 <sys_page_alloc>
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	83 c4 10             	add    $0x10,%esp
  80232e:	85 c0                	test   %eax,%eax
  802330:	0f 88 04 01 00 00    	js     80243a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802336:	83 ec 0c             	sub    $0xc,%esp
  802339:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80233c:	50                   	push   %eax
  80233d:	e8 c1 f1 ff ff       	call   801503 <fd_alloc>
  802342:	89 c3                	mov    %eax,%ebx
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	85 c0                	test   %eax,%eax
  802349:	0f 88 db 00 00 00    	js     80242a <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234f:	83 ec 04             	sub    $0x4,%esp
  802352:	68 07 04 00 00       	push   $0x407
  802357:	ff 75 f0             	push   -0x10(%ebp)
  80235a:	6a 00                	push   $0x0
  80235c:	e8 35 ee ff ff       	call   801196 <sys_page_alloc>
  802361:	89 c3                	mov    %eax,%ebx
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	85 c0                	test   %eax,%eax
  802368:	0f 88 bc 00 00 00    	js     80242a <pipe+0x131>
	va = fd2data(fd0);
  80236e:	83 ec 0c             	sub    $0xc,%esp
  802371:	ff 75 f4             	push   -0xc(%ebp)
  802374:	e8 73 f1 ff ff       	call   8014ec <fd2data>
  802379:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80237b:	83 c4 0c             	add    $0xc,%esp
  80237e:	68 07 04 00 00       	push   $0x407
  802383:	50                   	push   %eax
  802384:	6a 00                	push   $0x0
  802386:	e8 0b ee ff ff       	call   801196 <sys_page_alloc>
  80238b:	89 c3                	mov    %eax,%ebx
  80238d:	83 c4 10             	add    $0x10,%esp
  802390:	85 c0                	test   %eax,%eax
  802392:	0f 88 82 00 00 00    	js     80241a <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802398:	83 ec 0c             	sub    $0xc,%esp
  80239b:	ff 75 f0             	push   -0x10(%ebp)
  80239e:	e8 49 f1 ff ff       	call   8014ec <fd2data>
  8023a3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023aa:	50                   	push   %eax
  8023ab:	6a 00                	push   $0x0
  8023ad:	56                   	push   %esi
  8023ae:	6a 00                	push   $0x0
  8023b0:	e8 24 ee ff ff       	call   8011d9 <sys_page_map>
  8023b5:	89 c3                	mov    %eax,%ebx
  8023b7:	83 c4 20             	add    $0x20,%esp
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	78 4e                	js     80240c <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8023be:	a1 40 40 80 00       	mov    0x804040,%eax
  8023c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023c6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8023c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023cb:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8023d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023d5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8023d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023da:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023e1:	83 ec 0c             	sub    $0xc,%esp
  8023e4:	ff 75 f4             	push   -0xc(%ebp)
  8023e7:	e8 f0 f0 ff ff       	call   8014dc <fd2num>
  8023ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023f1:	83 c4 04             	add    $0x4,%esp
  8023f4:	ff 75 f0             	push   -0x10(%ebp)
  8023f7:	e8 e0 f0 ff ff       	call   8014dc <fd2num>
  8023fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802402:	83 c4 10             	add    $0x10,%esp
  802405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80240a:	eb 2e                	jmp    80243a <pipe+0x141>
	sys_page_unmap(0, va);
  80240c:	83 ec 08             	sub    $0x8,%esp
  80240f:	56                   	push   %esi
  802410:	6a 00                	push   $0x0
  802412:	e8 04 ee ff ff       	call   80121b <sys_page_unmap>
  802417:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80241a:	83 ec 08             	sub    $0x8,%esp
  80241d:	ff 75 f0             	push   -0x10(%ebp)
  802420:	6a 00                	push   $0x0
  802422:	e8 f4 ed ff ff       	call   80121b <sys_page_unmap>
  802427:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80242a:	83 ec 08             	sub    $0x8,%esp
  80242d:	ff 75 f4             	push   -0xc(%ebp)
  802430:	6a 00                	push   $0x0
  802432:	e8 e4 ed ff ff       	call   80121b <sys_page_unmap>
  802437:	83 c4 10             	add    $0x10,%esp
}
  80243a:	89 d8                	mov    %ebx,%eax
  80243c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    

00802443 <pipeisclosed>:
{
  802443:	55                   	push   %ebp
  802444:	89 e5                	mov    %esp,%ebp
  802446:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244c:	50                   	push   %eax
  80244d:	ff 75 08             	push   0x8(%ebp)
  802450:	e8 fe f0 ff ff       	call   801553 <fd_lookup>
  802455:	83 c4 10             	add    $0x10,%esp
  802458:	85 c0                	test   %eax,%eax
  80245a:	78 18                	js     802474 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80245c:	83 ec 0c             	sub    $0xc,%esp
  80245f:	ff 75 f4             	push   -0xc(%ebp)
  802462:	e8 85 f0 ff ff       	call   8014ec <fd2data>
  802467:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246c:	e8 33 fd ff ff       	call   8021a4 <_pipeisclosed>
  802471:	83 c4 10             	add    $0x10,%esp
}
  802474:	c9                   	leave  
  802475:	c3                   	ret    

00802476 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802476:	b8 00 00 00 00       	mov    $0x0,%eax
  80247b:	c3                   	ret    

0080247c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802482:	68 e3 30 80 00       	push   $0x8030e3
  802487:	ff 75 0c             	push   0xc(%ebp)
  80248a:	e8 0b e9 ff ff       	call   800d9a <strcpy>
	return 0;
}
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
  802494:	c9                   	leave  
  802495:	c3                   	ret    

00802496 <devcons_write>:
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	57                   	push   %edi
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8024a2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024a7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8024ad:	eb 2e                	jmp    8024dd <devcons_write+0x47>
		m = n - tot;
  8024af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024b2:	29 f3                	sub    %esi,%ebx
  8024b4:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8024b9:	39 c3                	cmp    %eax,%ebx
  8024bb:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8024be:	83 ec 04             	sub    $0x4,%esp
  8024c1:	53                   	push   %ebx
  8024c2:	89 f0                	mov    %esi,%eax
  8024c4:	03 45 0c             	add    0xc(%ebp),%eax
  8024c7:	50                   	push   %eax
  8024c8:	57                   	push   %edi
  8024c9:	e8 62 ea ff ff       	call   800f30 <memmove>
		sys_cputs(buf, m);
  8024ce:	83 c4 08             	add    $0x8,%esp
  8024d1:	53                   	push   %ebx
  8024d2:	57                   	push   %edi
  8024d3:	e8 02 ec ff ff       	call   8010da <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024d8:	01 de                	add    %ebx,%esi
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024e0:	72 cd                	jb     8024af <devcons_write+0x19>
}
  8024e2:	89 f0                	mov    %esi,%eax
  8024e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e7:	5b                   	pop    %ebx
  8024e8:	5e                   	pop    %esi
  8024e9:	5f                   	pop    %edi
  8024ea:	5d                   	pop    %ebp
  8024eb:	c3                   	ret    

008024ec <devcons_read>:
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	83 ec 08             	sub    $0x8,%esp
  8024f2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8024f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024fb:	75 07                	jne    802504 <devcons_read+0x18>
  8024fd:	eb 1f                	jmp    80251e <devcons_read+0x32>
		sys_yield();
  8024ff:	e8 73 ec ff ff       	call   801177 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802504:	e8 ef eb ff ff       	call   8010f8 <sys_cgetc>
  802509:	85 c0                	test   %eax,%eax
  80250b:	74 f2                	je     8024ff <devcons_read+0x13>
	if (c < 0)
  80250d:	78 0f                	js     80251e <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80250f:	83 f8 04             	cmp    $0x4,%eax
  802512:	74 0c                	je     802520 <devcons_read+0x34>
	*(char*)vbuf = c;
  802514:	8b 55 0c             	mov    0xc(%ebp),%edx
  802517:	88 02                	mov    %al,(%edx)
	return 1;
  802519:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80251e:	c9                   	leave  
  80251f:	c3                   	ret    
		return 0;
  802520:	b8 00 00 00 00       	mov    $0x0,%eax
  802525:	eb f7                	jmp    80251e <devcons_read+0x32>

00802527 <cputchar>:
{
  802527:	55                   	push   %ebp
  802528:	89 e5                	mov    %esp,%ebp
  80252a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80252d:	8b 45 08             	mov    0x8(%ebp),%eax
  802530:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802533:	6a 01                	push   $0x1
  802535:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802538:	50                   	push   %eax
  802539:	e8 9c eb ff ff       	call   8010da <sys_cputs>
}
  80253e:	83 c4 10             	add    $0x10,%esp
  802541:	c9                   	leave  
  802542:	c3                   	ret    

00802543 <getchar>:
{
  802543:	55                   	push   %ebp
  802544:	89 e5                	mov    %esp,%ebp
  802546:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802549:	6a 01                	push   $0x1
  80254b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80254e:	50                   	push   %eax
  80254f:	6a 00                	push   $0x0
  802551:	e8 66 f2 ff ff       	call   8017bc <read>
	if (r < 0)
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	85 c0                	test   %eax,%eax
  80255b:	78 06                	js     802563 <getchar+0x20>
	if (r < 1)
  80255d:	74 06                	je     802565 <getchar+0x22>
	return c;
  80255f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802563:	c9                   	leave  
  802564:	c3                   	ret    
		return -E_EOF;
  802565:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80256a:	eb f7                	jmp    802563 <getchar+0x20>

0080256c <iscons>:
{
  80256c:	55                   	push   %ebp
  80256d:	89 e5                	mov    %esp,%ebp
  80256f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802575:	50                   	push   %eax
  802576:	ff 75 08             	push   0x8(%ebp)
  802579:	e8 d5 ef ff ff       	call   801553 <fd_lookup>
  80257e:	83 c4 10             	add    $0x10,%esp
  802581:	85 c0                	test   %eax,%eax
  802583:	78 11                	js     802596 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802585:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802588:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80258e:	39 10                	cmp    %edx,(%eax)
  802590:	0f 94 c0             	sete   %al
  802593:	0f b6 c0             	movzbl %al,%eax
}
  802596:	c9                   	leave  
  802597:	c3                   	ret    

00802598 <opencons>:
{
  802598:	55                   	push   %ebp
  802599:	89 e5                	mov    %esp,%ebp
  80259b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80259e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025a1:	50                   	push   %eax
  8025a2:	e8 5c ef ff ff       	call   801503 <fd_alloc>
  8025a7:	83 c4 10             	add    $0x10,%esp
  8025aa:	85 c0                	test   %eax,%eax
  8025ac:	78 3a                	js     8025e8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025ae:	83 ec 04             	sub    $0x4,%esp
  8025b1:	68 07 04 00 00       	push   $0x407
  8025b6:	ff 75 f4             	push   -0xc(%ebp)
  8025b9:	6a 00                	push   $0x0
  8025bb:	e8 d6 eb ff ff       	call   801196 <sys_page_alloc>
  8025c0:	83 c4 10             	add    $0x10,%esp
  8025c3:	85 c0                	test   %eax,%eax
  8025c5:	78 21                	js     8025e8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8025c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ca:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025dc:	83 ec 0c             	sub    $0xc,%esp
  8025df:	50                   	push   %eax
  8025e0:	e8 f7 ee ff ff       	call   8014dc <fd2num>
  8025e5:	83 c4 10             	add    $0x10,%esp
}
  8025e8:	c9                   	leave  
  8025e9:	c3                   	ret    

008025ea <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025ea:	55                   	push   %ebp
  8025eb:	89 e5                	mov    %esp,%ebp
  8025ed:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f0:	89 c2                	mov    %eax,%edx
  8025f2:	c1 ea 16             	shr    $0x16,%edx
  8025f5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025fc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802601:	f6 c1 01             	test   $0x1,%cl
  802604:	74 1c                	je     802622 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802606:	c1 e8 0c             	shr    $0xc,%eax
  802609:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802610:	a8 01                	test   $0x1,%al
  802612:	74 0e                	je     802622 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802614:	c1 e8 0c             	shr    $0xc,%eax
  802617:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80261e:	ef 
  80261f:	0f b7 d2             	movzwl %dx,%edx
}
  802622:	89 d0                	mov    %edx,%eax
  802624:	5d                   	pop    %ebp
  802625:	c3                   	ret    
  802626:	66 90                	xchg   %ax,%ax
  802628:	66 90                	xchg   %ax,%ax
  80262a:	66 90                	xchg   %ax,%ax
  80262c:	66 90                	xchg   %ax,%ax
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__udivdi3>:
  802630:	f3 0f 1e fb          	endbr32 
  802634:	55                   	push   %ebp
  802635:	57                   	push   %edi
  802636:	56                   	push   %esi
  802637:	53                   	push   %ebx
  802638:	83 ec 1c             	sub    $0x1c,%esp
  80263b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80263f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802643:	8b 74 24 34          	mov    0x34(%esp),%esi
  802647:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80264b:	85 c0                	test   %eax,%eax
  80264d:	75 19                	jne    802668 <__udivdi3+0x38>
  80264f:	39 f3                	cmp    %esi,%ebx
  802651:	76 4d                	jbe    8026a0 <__udivdi3+0x70>
  802653:	31 ff                	xor    %edi,%edi
  802655:	89 e8                	mov    %ebp,%eax
  802657:	89 f2                	mov    %esi,%edx
  802659:	f7 f3                	div    %ebx
  80265b:	89 fa                	mov    %edi,%edx
  80265d:	83 c4 1c             	add    $0x1c,%esp
  802660:	5b                   	pop    %ebx
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi
  802668:	39 f0                	cmp    %esi,%eax
  80266a:	76 14                	jbe    802680 <__udivdi3+0x50>
  80266c:	31 ff                	xor    %edi,%edi
  80266e:	31 c0                	xor    %eax,%eax
  802670:	89 fa                	mov    %edi,%edx
  802672:	83 c4 1c             	add    $0x1c,%esp
  802675:	5b                   	pop    %ebx
  802676:	5e                   	pop    %esi
  802677:	5f                   	pop    %edi
  802678:	5d                   	pop    %ebp
  802679:	c3                   	ret    
  80267a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802680:	0f bd f8             	bsr    %eax,%edi
  802683:	83 f7 1f             	xor    $0x1f,%edi
  802686:	75 48                	jne    8026d0 <__udivdi3+0xa0>
  802688:	39 f0                	cmp    %esi,%eax
  80268a:	72 06                	jb     802692 <__udivdi3+0x62>
  80268c:	31 c0                	xor    %eax,%eax
  80268e:	39 eb                	cmp    %ebp,%ebx
  802690:	77 de                	ja     802670 <__udivdi3+0x40>
  802692:	b8 01 00 00 00       	mov    $0x1,%eax
  802697:	eb d7                	jmp    802670 <__udivdi3+0x40>
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d9                	mov    %ebx,%ecx
  8026a2:	85 db                	test   %ebx,%ebx
  8026a4:	75 0b                	jne    8026b1 <__udivdi3+0x81>
  8026a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	f7 f3                	div    %ebx
  8026af:	89 c1                	mov    %eax,%ecx
  8026b1:	31 d2                	xor    %edx,%edx
  8026b3:	89 f0                	mov    %esi,%eax
  8026b5:	f7 f1                	div    %ecx
  8026b7:	89 c6                	mov    %eax,%esi
  8026b9:	89 e8                	mov    %ebp,%eax
  8026bb:	89 f7                	mov    %esi,%edi
  8026bd:	f7 f1                	div    %ecx
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	83 c4 1c             	add    $0x1c,%esp
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	89 f9                	mov    %edi,%ecx
  8026d2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026d7:	29 fa                	sub    %edi,%edx
  8026d9:	d3 e0                	shl    %cl,%eax
  8026db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026df:	89 d1                	mov    %edx,%ecx
  8026e1:	89 d8                	mov    %ebx,%eax
  8026e3:	d3 e8                	shr    %cl,%eax
  8026e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026e9:	09 c1                	or     %eax,%ecx
  8026eb:	89 f0                	mov    %esi,%eax
  8026ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e3                	shl    %cl,%ebx
  8026f5:	89 d1                	mov    %edx,%ecx
  8026f7:	d3 e8                	shr    %cl,%eax
  8026f9:	89 f9                	mov    %edi,%ecx
  8026fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026ff:	89 eb                	mov    %ebp,%ebx
  802701:	d3 e6                	shl    %cl,%esi
  802703:	89 d1                	mov    %edx,%ecx
  802705:	d3 eb                	shr    %cl,%ebx
  802707:	09 f3                	or     %esi,%ebx
  802709:	89 c6                	mov    %eax,%esi
  80270b:	89 f2                	mov    %esi,%edx
  80270d:	89 d8                	mov    %ebx,%eax
  80270f:	f7 74 24 08          	divl   0x8(%esp)
  802713:	89 d6                	mov    %edx,%esi
  802715:	89 c3                	mov    %eax,%ebx
  802717:	f7 64 24 0c          	mull   0xc(%esp)
  80271b:	39 d6                	cmp    %edx,%esi
  80271d:	72 19                	jb     802738 <__udivdi3+0x108>
  80271f:	89 f9                	mov    %edi,%ecx
  802721:	d3 e5                	shl    %cl,%ebp
  802723:	39 c5                	cmp    %eax,%ebp
  802725:	73 04                	jae    80272b <__udivdi3+0xfb>
  802727:	39 d6                	cmp    %edx,%esi
  802729:	74 0d                	je     802738 <__udivdi3+0x108>
  80272b:	89 d8                	mov    %ebx,%eax
  80272d:	31 ff                	xor    %edi,%edi
  80272f:	e9 3c ff ff ff       	jmp    802670 <__udivdi3+0x40>
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80273b:	31 ff                	xor    %edi,%edi
  80273d:	e9 2e ff ff ff       	jmp    802670 <__udivdi3+0x40>
  802742:	66 90                	xchg   %ax,%ax
  802744:	66 90                	xchg   %ax,%ax
  802746:	66 90                	xchg   %ax,%ax
  802748:	66 90                	xchg   %ax,%ax
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <__umoddi3>:
  802750:	f3 0f 1e fb          	endbr32 
  802754:	55                   	push   %ebp
  802755:	57                   	push   %edi
  802756:	56                   	push   %esi
  802757:	53                   	push   %ebx
  802758:	83 ec 1c             	sub    $0x1c,%esp
  80275b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80275f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802763:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802767:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80276b:	89 f0                	mov    %esi,%eax
  80276d:	89 da                	mov    %ebx,%edx
  80276f:	85 ff                	test   %edi,%edi
  802771:	75 15                	jne    802788 <__umoddi3+0x38>
  802773:	39 dd                	cmp    %ebx,%ebp
  802775:	76 39                	jbe    8027b0 <__umoddi3+0x60>
  802777:	f7 f5                	div    %ebp
  802779:	89 d0                	mov    %edx,%eax
  80277b:	31 d2                	xor    %edx,%edx
  80277d:	83 c4 1c             	add    $0x1c,%esp
  802780:	5b                   	pop    %ebx
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    
  802785:	8d 76 00             	lea    0x0(%esi),%esi
  802788:	39 df                	cmp    %ebx,%edi
  80278a:	77 f1                	ja     80277d <__umoddi3+0x2d>
  80278c:	0f bd cf             	bsr    %edi,%ecx
  80278f:	83 f1 1f             	xor    $0x1f,%ecx
  802792:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802796:	75 40                	jne    8027d8 <__umoddi3+0x88>
  802798:	39 df                	cmp    %ebx,%edi
  80279a:	72 04                	jb     8027a0 <__umoddi3+0x50>
  80279c:	39 f5                	cmp    %esi,%ebp
  80279e:	77 dd                	ja     80277d <__umoddi3+0x2d>
  8027a0:	89 da                	mov    %ebx,%edx
  8027a2:	89 f0                	mov    %esi,%eax
  8027a4:	29 e8                	sub    %ebp,%eax
  8027a6:	19 fa                	sbb    %edi,%edx
  8027a8:	eb d3                	jmp    80277d <__umoddi3+0x2d>
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	89 e9                	mov    %ebp,%ecx
  8027b2:	85 ed                	test   %ebp,%ebp
  8027b4:	75 0b                	jne    8027c1 <__umoddi3+0x71>
  8027b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bb:	31 d2                	xor    %edx,%edx
  8027bd:	f7 f5                	div    %ebp
  8027bf:	89 c1                	mov    %eax,%ecx
  8027c1:	89 d8                	mov    %ebx,%eax
  8027c3:	31 d2                	xor    %edx,%edx
  8027c5:	f7 f1                	div    %ecx
  8027c7:	89 f0                	mov    %esi,%eax
  8027c9:	f7 f1                	div    %ecx
  8027cb:	89 d0                	mov    %edx,%eax
  8027cd:	31 d2                	xor    %edx,%edx
  8027cf:	eb ac                	jmp    80277d <__umoddi3+0x2d>
  8027d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027dc:	ba 20 00 00 00       	mov    $0x20,%edx
  8027e1:	29 c2                	sub    %eax,%edx
  8027e3:	89 c1                	mov    %eax,%ecx
  8027e5:	89 e8                	mov    %ebp,%eax
  8027e7:	d3 e7                	shl    %cl,%edi
  8027e9:	89 d1                	mov    %edx,%ecx
  8027eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027ef:	d3 e8                	shr    %cl,%eax
  8027f1:	89 c1                	mov    %eax,%ecx
  8027f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027f7:	09 f9                	or     %edi,%ecx
  8027f9:	89 df                	mov    %ebx,%edi
  8027fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ff:	89 c1                	mov    %eax,%ecx
  802801:	d3 e5                	shl    %cl,%ebp
  802803:	89 d1                	mov    %edx,%ecx
  802805:	d3 ef                	shr    %cl,%edi
  802807:	89 c1                	mov    %eax,%ecx
  802809:	89 f0                	mov    %esi,%eax
  80280b:	d3 e3                	shl    %cl,%ebx
  80280d:	89 d1                	mov    %edx,%ecx
  80280f:	89 fa                	mov    %edi,%edx
  802811:	d3 e8                	shr    %cl,%eax
  802813:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802818:	09 d8                	or     %ebx,%eax
  80281a:	f7 74 24 08          	divl   0x8(%esp)
  80281e:	89 d3                	mov    %edx,%ebx
  802820:	d3 e6                	shl    %cl,%esi
  802822:	f7 e5                	mul    %ebp
  802824:	89 c7                	mov    %eax,%edi
  802826:	89 d1                	mov    %edx,%ecx
  802828:	39 d3                	cmp    %edx,%ebx
  80282a:	72 06                	jb     802832 <__umoddi3+0xe2>
  80282c:	75 0e                	jne    80283c <__umoddi3+0xec>
  80282e:	39 c6                	cmp    %eax,%esi
  802830:	73 0a                	jae    80283c <__umoddi3+0xec>
  802832:	29 e8                	sub    %ebp,%eax
  802834:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802838:	89 d1                	mov    %edx,%ecx
  80283a:	89 c7                	mov    %eax,%edi
  80283c:	89 f5                	mov    %esi,%ebp
  80283e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802842:	29 fd                	sub    %edi,%ebp
  802844:	19 cb                	sbb    %ecx,%ebx
  802846:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80284b:	89 d8                	mov    %ebx,%eax
  80284d:	d3 e0                	shl    %cl,%eax
  80284f:	89 f1                	mov    %esi,%ecx
  802851:	d3 ed                	shr    %cl,%ebp
  802853:	d3 eb                	shr    %cl,%ebx
  802855:	09 e8                	or     %ebp,%eax
  802857:	89 da                	mov    %ebx,%edx
  802859:	83 c4 1c             	add    $0x1c,%esp
  80285c:	5b                   	pop    %ebx
  80285d:	5e                   	pop    %esi
  80285e:	5f                   	pop    %edi
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    
