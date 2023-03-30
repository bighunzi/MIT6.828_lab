
obj/user/init.debug：     文件格式 elf32-i386


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
  80002c:	e8 5d 03 00 00       	call   80038e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = 0; i < n; i++)
  800043:	b8 00 00 00 00       	mov    $0x0,%eax
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 14 06          	movsbl (%esi,%eax,1),%edx
  80004e:	0f af d0             	imul   %eax,%edx
  800051:	31 d1                	xor    %edx,%ecx
	for (i = 0; i < n; i++)
  800053:	83 c0 01             	add    $0x1,%eax
  800056:	39 d8                	cmp    %ebx,%eax
  800058:	7c f0                	jl     80004a <sum+0x17>
	return tot;
}
  80005a:	89 c8                	mov    %ecx,%eax
  80005c:	5b                   	pop    %ebx
  80005d:	5e                   	pop    %esi
  80005e:	5d                   	pop    %ebp
  80005f:	c3                   	ret    

00800060 <umain>:

void
umain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	57                   	push   %edi
  800064:	56                   	push   %esi
  800065:	53                   	push   %ebx
  800066:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006f:	68 60 2a 80 00       	push   $0x802a60
  800074:	e8 50 04 00 00       	call   8004c9 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800079:	83 c4 08             	add    $0x8,%esp
  80007c:	68 70 17 00 00       	push   $0x1770
  800081:	68 00 40 80 00       	push   $0x804000
  800086:	e8 a8 ff ff ff       	call   800033 <sum>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800093:	74 64                	je     8000f9 <umain+0x99>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800095:	83 ec 04             	sub    $0x4,%esp
  800098:	68 9e 98 0f 00       	push   $0xf989e
  80009d:	50                   	push   %eax
  80009e:	68 28 2b 80 00       	push   $0x802b28
  8000a3:	e8 21 04 00 00       	call   8004c9 <cprintf>
  8000a8:	83 c4 10             	add    $0x10,%esp
			x, want);
	else
		cprintf("init: data seems okay\n");
	if ((x = sum(bss, sizeof bss)) != 0)
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	68 70 17 00 00       	push   $0x1770
  8000b3:	68 00 60 80 00       	push   $0x806000
  8000b8:	e8 76 ff ff ff       	call   800033 <sum>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	74 47                	je     80010b <umain+0xab>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000c4:	83 ec 08             	sub    $0x8,%esp
  8000c7:	50                   	push   %eax
  8000c8:	68 64 2b 80 00       	push   $0x802b64
  8000cd:	e8 f7 03 00 00       	call   8004c9 <cprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 9c 2a 80 00       	push   $0x802a9c
  8000dd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 de 09 00 00       	call   800ac7 <strcat>
	for (i = 0; i < argc; i++) {
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  8000f1:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	for (i = 0; i < argc; i++) {
  8000f7:	eb 52                	jmp    80014b <umain+0xeb>
		cprintf("init: data seems okay\n");
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	68 6f 2a 80 00       	push   $0x802a6f
  800101:	e8 c3 03 00 00       	call   8004c9 <cprintf>
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	eb a0                	jmp    8000ab <umain+0x4b>
		cprintf("init: bss seems okay\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 86 2a 80 00       	push   $0x802a86
  800113:	e8 b1 03 00 00       	call   8004c9 <cprintf>
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	eb b8                	jmp    8000d5 <umain+0x75>
		strcat(args, " '");
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 a8 2a 80 00       	push   $0x802aa8
  800125:	56                   	push   %esi
  800126:	e8 9c 09 00 00       	call   800ac7 <strcat>
		strcat(args, argv[i]);
  80012b:	83 c4 08             	add    $0x8,%esp
  80012e:	ff 34 9f             	push   (%edi,%ebx,4)
  800131:	56                   	push   %esi
  800132:	e8 90 09 00 00       	call   800ac7 <strcat>
		strcat(args, "'");
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	68 a9 2a 80 00       	push   $0x802aa9
  80013f:	56                   	push   %esi
  800140:	e8 82 09 00 00       	call   800ac7 <strcat>
	for (i = 0; i < argc; i++) {
  800145:	83 c3 01             	add    $0x1,%ebx
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014e:	7c cd                	jl     80011d <umain+0xbd>
	}
	cprintf("%s\n", args);
  800150:	83 ec 08             	sub    $0x8,%esp
  800153:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800159:	50                   	push   %eax
  80015a:	68 ab 2a 80 00       	push   $0x802aab
  80015f:	e8 65 03 00 00       	call   8004c9 <cprintf>

	cprintf("init: running sh\n");
  800164:	c7 04 24 af 2a 80 00 	movl   $0x802aaf,(%esp)
  80016b:	e8 59 03 00 00       	call   8004c9 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800177:	e8 19 11 00 00       	call   801295 <close>
	if ((r = opencons()) < 0)
  80017c:	e8 bb 01 00 00       	call   80033c <opencons>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	85 c0                	test   %eax,%eax
  800186:	78 14                	js     80019c <umain+0x13c>
		panic("opencons: %e", r);
	if (r != 0)
  800188:	74 24                	je     8001ae <umain+0x14e>
		panic("first opencons used fd %d", r);
  80018a:	50                   	push   %eax
  80018b:	68 da 2a 80 00       	push   $0x802ada
  800190:	6a 39                	push   $0x39
  800192:	68 ce 2a 80 00       	push   $0x802ace
  800197:	e8 52 02 00 00       	call   8003ee <_panic>
		panic("opencons: %e", r);
  80019c:	50                   	push   %eax
  80019d:	68 c1 2a 80 00       	push   $0x802ac1
  8001a2:	6a 37                	push   $0x37
  8001a4:	68 ce 2a 80 00       	push   $0x802ace
  8001a9:	e8 40 02 00 00       	call   8003ee <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 2d 11 00 00       	call   8012e7 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 23                	jns    8001e4 <umain+0x184>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 f4 2a 80 00       	push   $0x802af4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ce 2a 80 00       	push   $0x802ace
  8001ce:	e8 1b 02 00 00       	call   8003ee <_panic>
	while (1) {
		cprintf("init: starting sh\n");
		r = spawnl("/sh", "sh", (char*)0);
		if (r < 0) {
			cprintf("init: spawn sh: %e\n", r);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	50                   	push   %eax
  8001d7:	68 13 2b 80 00       	push   $0x802b13
  8001dc:	e8 e8 02 00 00       	call   8004c9 <cprintf>
			continue;
  8001e1:	83 c4 10             	add    $0x10,%esp
		cprintf("init: starting sh\n");
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	68 fc 2a 80 00       	push   $0x802afc
  8001ec:	e8 d8 02 00 00       	call   8004c9 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001f1:	83 c4 0c             	add    $0xc,%esp
  8001f4:	6a 00                	push   $0x0
  8001f6:	68 10 2b 80 00       	push   $0x802b10
  8001fb:	68 0f 2b 80 00       	push   $0x802b0f
  800200:	e8 41 1c 00 00       	call   801e46 <spawnl>
		if (r < 0) {
  800205:	83 c4 10             	add    $0x10,%esp
  800208:	85 c0                	test   %eax,%eax
  80020a:	78 c7                	js     8001d3 <umain+0x173>
		}
		wait(r);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	e8 88 24 00 00       	call   80269d <wait>
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb ca                	jmp    8001e4 <umain+0x184>

0080021a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80021a:	b8 00 00 00 00       	mov    $0x0,%eax
  80021f:	c3                   	ret    

00800220 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800226:	68 93 2b 80 00       	push   $0x802b93
  80022b:	ff 75 0c             	push   0xc(%ebp)
  80022e:	e8 70 08 00 00       	call   800aa3 <strcpy>
	return 0;
}
  800233:	b8 00 00 00 00       	mov    $0x0,%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <devcons_write>:
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800246:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80024b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800251:	eb 2e                	jmp    800281 <devcons_write+0x47>
		m = n - tot;
  800253:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800256:	29 f3                	sub    %esi,%ebx
  800258:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80025d:	39 c3                	cmp    %eax,%ebx
  80025f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	53                   	push   %ebx
  800266:	89 f0                	mov    %esi,%eax
  800268:	03 45 0c             	add    0xc(%ebp),%eax
  80026b:	50                   	push   %eax
  80026c:	57                   	push   %edi
  80026d:	e8 c7 09 00 00       	call   800c39 <memmove>
		sys_cputs(buf, m);
  800272:	83 c4 08             	add    $0x8,%esp
  800275:	53                   	push   %ebx
  800276:	57                   	push   %edi
  800277:	e8 67 0b 00 00       	call   800de3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80027c:	01 de                	add    %ebx,%esi
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	3b 75 10             	cmp    0x10(%ebp),%esi
  800284:	72 cd                	jb     800253 <devcons_write+0x19>
}
  800286:	89 f0                	mov    %esi,%eax
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <devcons_read>:
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80029b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80029f:	75 07                	jne    8002a8 <devcons_read+0x18>
  8002a1:	eb 1f                	jmp    8002c2 <devcons_read+0x32>
		sys_yield();
  8002a3:	e8 d8 0b 00 00       	call   800e80 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8002a8:	e8 54 0b 00 00       	call   800e01 <sys_cgetc>
  8002ad:	85 c0                	test   %eax,%eax
  8002af:	74 f2                	je     8002a3 <devcons_read+0x13>
	if (c < 0)
  8002b1:	78 0f                	js     8002c2 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8002b3:	83 f8 04             	cmp    $0x4,%eax
  8002b6:	74 0c                	je     8002c4 <devcons_read+0x34>
	*(char*)vbuf = c;
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	88 02                	mov    %al,(%edx)
	return 1;
  8002bd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    
		return 0;
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c9:	eb f7                	jmp    8002c2 <devcons_read+0x32>

008002cb <cputchar>:
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8002d7:	6a 01                	push   $0x1
  8002d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002dc:	50                   	push   %eax
  8002dd:	e8 01 0b 00 00       	call   800de3 <sys_cputs>
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <getchar>:
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8002ed:	6a 01                	push   $0x1
  8002ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f2:	50                   	push   %eax
  8002f3:	6a 00                	push   $0x0
  8002f5:	e8 d7 10 00 00       	call   8013d1 <read>
	if (r < 0)
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	78 06                	js     800307 <getchar+0x20>
	if (r < 1)
  800301:	74 06                	je     800309 <getchar+0x22>
	return c;
  800303:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800307:	c9                   	leave  
  800308:	c3                   	ret    
		return -E_EOF;
  800309:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80030e:	eb f7                	jmp    800307 <getchar+0x20>

00800310 <iscons>:
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800319:	50                   	push   %eax
  80031a:	ff 75 08             	push   0x8(%ebp)
  80031d:	e8 46 0e 00 00       	call   801168 <fd_lookup>
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	85 c0                	test   %eax,%eax
  800327:	78 11                	js     80033a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80032c:	8b 15 70 57 80 00    	mov    0x805770,%edx
  800332:	39 10                	cmp    %edx,(%eax)
  800334:	0f 94 c0             	sete   %al
  800337:	0f b6 c0             	movzbl %al,%eax
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <opencons>:
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800342:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800345:	50                   	push   %eax
  800346:	e8 cd 0d 00 00       	call   801118 <fd_alloc>
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	85 c0                	test   %eax,%eax
  800350:	78 3a                	js     80038c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800352:	83 ec 04             	sub    $0x4,%esp
  800355:	68 07 04 00 00       	push   $0x407
  80035a:	ff 75 f4             	push   -0xc(%ebp)
  80035d:	6a 00                	push   $0x0
  80035f:	e8 3b 0b 00 00       	call   800e9f <sys_page_alloc>
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	85 c0                	test   %eax,%eax
  800369:	78 21                	js     80038c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80036b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80036e:	8b 15 70 57 80 00    	mov    0x805770,%edx
  800374:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800379:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	50                   	push   %eax
  800384:	e8 68 0d 00 00       	call   8010f1 <fd2num>
  800389:	83 c4 10             	add    $0x10,%esp
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800396:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800399:	e8 c3 0a 00 00       	call   800e61 <sys_getenvid>
  80039e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003a3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003ab:	a3 70 77 80 00       	mov    %eax,0x807770

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003b0:	85 db                	test   %ebx,%ebx
  8003b2:	7e 07                	jle    8003bb <libmain+0x2d>
		binaryname = argv[0];
  8003b4:	8b 06                	mov    (%esi),%eax
  8003b6:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	e8 9b fc ff ff       	call   800060 <umain>

	// exit gracefully
	exit();
  8003c5:	e8 0a 00 00 00       	call   8003d4 <exit>
}
  8003ca:	83 c4 10             	add    $0x10,%esp
  8003cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003d0:	5b                   	pop    %ebx
  8003d1:	5e                   	pop    %esi
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    

008003d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003da:	e8 e3 0e 00 00       	call   8012c2 <close_all>
	sys_env_destroy(0);
  8003df:	83 ec 0c             	sub    $0xc,%esp
  8003e2:	6a 00                	push   $0x0
  8003e4:	e8 37 0a 00 00       	call   800e20 <sys_env_destroy>
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003f6:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  8003fc:	e8 60 0a 00 00       	call   800e61 <sys_getenvid>
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	ff 75 0c             	push   0xc(%ebp)
  800407:	ff 75 08             	push   0x8(%ebp)
  80040a:	56                   	push   %esi
  80040b:	50                   	push   %eax
  80040c:	68 ac 2b 80 00       	push   $0x802bac
  800411:	e8 b3 00 00 00       	call   8004c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800416:	83 c4 18             	add    $0x18,%esp
  800419:	53                   	push   %ebx
  80041a:	ff 75 10             	push   0x10(%ebp)
  80041d:	e8 56 00 00 00       	call   800478 <vcprintf>
	cprintf("\n");
  800422:	c7 04 24 d3 30 80 00 	movl   $0x8030d3,(%esp)
  800429:	e8 9b 00 00 00       	call   8004c9 <cprintf>
  80042e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800431:	cc                   	int3   
  800432:	eb fd                	jmp    800431 <_panic+0x43>

00800434 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	53                   	push   %ebx
  800438:	83 ec 04             	sub    $0x4,%esp
  80043b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80043e:	8b 13                	mov    (%ebx),%edx
  800440:	8d 42 01             	lea    0x1(%edx),%eax
  800443:	89 03                	mov    %eax,(%ebx)
  800445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800448:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80044c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800451:	74 09                	je     80045c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800453:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800457:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80045a:	c9                   	leave  
  80045b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	68 ff 00 00 00       	push   $0xff
  800464:	8d 43 08             	lea    0x8(%ebx),%eax
  800467:	50                   	push   %eax
  800468:	e8 76 09 00 00       	call   800de3 <sys_cputs>
		b->idx = 0;
  80046d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	eb db                	jmp    800453 <putch+0x1f>

00800478 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800481:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800488:	00 00 00 
	b.cnt = 0;
  80048b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800492:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800495:	ff 75 0c             	push   0xc(%ebp)
  800498:	ff 75 08             	push   0x8(%ebp)
  80049b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a1:	50                   	push   %eax
  8004a2:	68 34 04 80 00       	push   $0x800434
  8004a7:	e8 14 01 00 00       	call   8005c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ac:	83 c4 08             	add    $0x8,%esp
  8004af:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8004b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004bb:	50                   	push   %eax
  8004bc:	e8 22 09 00 00       	call   800de3 <sys_cputs>

	return b.cnt;
}
  8004c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c7:	c9                   	leave  
  8004c8:	c3                   	ret    

008004c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004cf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d2:	50                   	push   %eax
  8004d3:	ff 75 08             	push   0x8(%ebp)
  8004d6:	e8 9d ff ff ff       	call   800478 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004db:	c9                   	leave  
  8004dc:	c3                   	ret    

008004dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	57                   	push   %edi
  8004e1:	56                   	push   %esi
  8004e2:	53                   	push   %ebx
  8004e3:	83 ec 1c             	sub    $0x1c,%esp
  8004e6:	89 c7                	mov    %eax,%edi
  8004e8:	89 d6                	mov    %edx,%esi
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f0:	89 d1                	mov    %edx,%ecx
  8004f2:	89 c2                	mov    %eax,%edx
  8004f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800500:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800503:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80050a:	39 c2                	cmp    %eax,%edx
  80050c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80050f:	72 3e                	jb     80054f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800511:	83 ec 0c             	sub    $0xc,%esp
  800514:	ff 75 18             	push   0x18(%ebp)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	53                   	push   %ebx
  80051b:	50                   	push   %eax
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 e4             	push   -0x1c(%ebp)
  800522:	ff 75 e0             	push   -0x20(%ebp)
  800525:	ff 75 dc             	push   -0x24(%ebp)
  800528:	ff 75 d8             	push   -0x28(%ebp)
  80052b:	e8 f0 22 00 00       	call   802820 <__udivdi3>
  800530:	83 c4 18             	add    $0x18,%esp
  800533:	52                   	push   %edx
  800534:	50                   	push   %eax
  800535:	89 f2                	mov    %esi,%edx
  800537:	89 f8                	mov    %edi,%eax
  800539:	e8 9f ff ff ff       	call   8004dd <printnum>
  80053e:	83 c4 20             	add    $0x20,%esp
  800541:	eb 13                	jmp    800556 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	ff 75 18             	push   0x18(%ebp)
  80054a:	ff d7                	call   *%edi
  80054c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	85 db                	test   %ebx,%ebx
  800554:	7f ed                	jg     800543 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	56                   	push   %esi
  80055a:	83 ec 04             	sub    $0x4,%esp
  80055d:	ff 75 e4             	push   -0x1c(%ebp)
  800560:	ff 75 e0             	push   -0x20(%ebp)
  800563:	ff 75 dc             	push   -0x24(%ebp)
  800566:	ff 75 d8             	push   -0x28(%ebp)
  800569:	e8 d2 23 00 00       	call   802940 <__umoddi3>
  80056e:	83 c4 14             	add    $0x14,%esp
  800571:	0f be 80 cf 2b 80 00 	movsbl 0x802bcf(%eax),%eax
  800578:	50                   	push   %eax
  800579:	ff d7                	call   *%edi
}
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800581:	5b                   	pop    %ebx
  800582:	5e                   	pop    %esi
  800583:	5f                   	pop    %edi
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80058c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800590:	8b 10                	mov    (%eax),%edx
  800592:	3b 50 04             	cmp    0x4(%eax),%edx
  800595:	73 0a                	jae    8005a1 <sprintputch+0x1b>
		*b->buf++ = ch;
  800597:	8d 4a 01             	lea    0x1(%edx),%ecx
  80059a:	89 08                	mov    %ecx,(%eax)
  80059c:	8b 45 08             	mov    0x8(%ebp),%eax
  80059f:	88 02                	mov    %al,(%edx)
}
  8005a1:	5d                   	pop    %ebp
  8005a2:	c3                   	ret    

008005a3 <printfmt>:
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005ac:	50                   	push   %eax
  8005ad:	ff 75 10             	push   0x10(%ebp)
  8005b0:	ff 75 0c             	push   0xc(%ebp)
  8005b3:	ff 75 08             	push   0x8(%ebp)
  8005b6:	e8 05 00 00 00       	call   8005c0 <vprintfmt>
}
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	c9                   	leave  
  8005bf:	c3                   	ret    

008005c0 <vprintfmt>:
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	57                   	push   %edi
  8005c4:	56                   	push   %esi
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 3c             	sub    $0x3c,%esp
  8005c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005d2:	eb 0a                	jmp    8005de <vprintfmt+0x1e>
			putch(ch, putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	50                   	push   %eax
  8005d9:	ff d6                	call   *%esi
  8005db:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005de:	83 c7 01             	add    $0x1,%edi
  8005e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e5:	83 f8 25             	cmp    $0x25,%eax
  8005e8:	74 0c                	je     8005f6 <vprintfmt+0x36>
			if (ch == '\0')
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	75 e6                	jne    8005d4 <vprintfmt+0x14>
}
  8005ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f1:	5b                   	pop    %ebx
  8005f2:	5e                   	pop    %esi
  8005f3:	5f                   	pop    %edi
  8005f4:	5d                   	pop    %ebp
  8005f5:	c3                   	ret    
		padc = ' ';
  8005f6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005fa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800601:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800608:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80060f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8d 47 01             	lea    0x1(%edi),%eax
  800617:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80061a:	0f b6 17             	movzbl (%edi),%edx
  80061d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800620:	3c 55                	cmp    $0x55,%al
  800622:	0f 87 bb 03 00 00    	ja     8009e3 <vprintfmt+0x423>
  800628:	0f b6 c0             	movzbl %al,%eax
  80062b:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800635:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800639:	eb d9                	jmp    800614 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800642:	eb d0                	jmp    800614 <vprintfmt+0x54>
  800644:	0f b6 d2             	movzbl %dl,%edx
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80064a:	b8 00 00 00 00       	mov    $0x0,%eax
  80064f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800652:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800655:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800659:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80065c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80065f:	83 f9 09             	cmp    $0x9,%ecx
  800662:	77 55                	ja     8006b9 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800664:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800667:	eb e9                	jmp    800652 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80067d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800681:	79 91                	jns    800614 <vprintfmt+0x54>
				width = precision, precision = -1;
  800683:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800686:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800689:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800690:	eb 82                	jmp    800614 <vprintfmt+0x54>
  800692:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	b8 00 00 00 00       	mov    $0x0,%eax
  80069c:	0f 49 c2             	cmovns %edx,%eax
  80069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006a5:	e9 6a ff ff ff       	jmp    800614 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006ad:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8006b4:	e9 5b ff ff ff       	jmp    800614 <vprintfmt+0x54>
  8006b9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bf:	eb bc                	jmp    80067d <vprintfmt+0xbd>
			lflag++;
  8006c1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006c7:	e9 48 ff ff ff       	jmp    800614 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 78 04             	lea    0x4(%eax),%edi
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	ff 30                	push   (%eax)
  8006d8:	ff d6                	call   *%esi
			break;
  8006da:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006dd:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006e0:	e9 9d 02 00 00       	jmp    800982 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 78 04             	lea    0x4(%eax),%edi
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	89 d0                	mov    %edx,%eax
  8006ef:	f7 d8                	neg    %eax
  8006f1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f4:	83 f8 0f             	cmp    $0xf,%eax
  8006f7:	7f 23                	jg     80071c <vprintfmt+0x15c>
  8006f9:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	74 18                	je     80071c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800704:	52                   	push   %edx
  800705:	68 b5 2f 80 00       	push   $0x802fb5
  80070a:	53                   	push   %ebx
  80070b:	56                   	push   %esi
  80070c:	e8 92 fe ff ff       	call   8005a3 <printfmt>
  800711:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800714:	89 7d 14             	mov    %edi,0x14(%ebp)
  800717:	e9 66 02 00 00       	jmp    800982 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80071c:	50                   	push   %eax
  80071d:	68 e7 2b 80 00       	push   $0x802be7
  800722:	53                   	push   %ebx
  800723:	56                   	push   %esi
  800724:	e8 7a fe ff ff       	call   8005a3 <printfmt>
  800729:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80072c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80072f:	e9 4e 02 00 00       	jmp    800982 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	83 c0 04             	add    $0x4,%eax
  80073a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800742:	85 d2                	test   %edx,%edx
  800744:	b8 e0 2b 80 00       	mov    $0x802be0,%eax
  800749:	0f 45 c2             	cmovne %edx,%eax
  80074c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80074f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800753:	7e 06                	jle    80075b <vprintfmt+0x19b>
  800755:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800759:	75 0d                	jne    800768 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80075b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80075e:	89 c7                	mov    %eax,%edi
  800760:	03 45 e0             	add    -0x20(%ebp),%eax
  800763:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800766:	eb 55                	jmp    8007bd <vprintfmt+0x1fd>
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	ff 75 d8             	push   -0x28(%ebp)
  80076e:	ff 75 cc             	push   -0x34(%ebp)
  800771:	e8 0a 03 00 00       	call   800a80 <strnlen>
  800776:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800779:	29 c1                	sub    %eax,%ecx
  80077b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800783:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800787:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80078a:	eb 0f                	jmp    80079b <vprintfmt+0x1db>
					putch(padc, putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	ff 75 e0             	push   -0x20(%ebp)
  800793:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800795:	83 ef 01             	sub    $0x1,%edi
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	85 ff                	test   %edi,%edi
  80079d:	7f ed                	jg     80078c <vprintfmt+0x1cc>
  80079f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	0f 49 c2             	cmovns %edx,%eax
  8007ac:	29 c2                	sub    %eax,%edx
  8007ae:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007b1:	eb a8                	jmp    80075b <vprintfmt+0x19b>
					putch(ch, putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	52                   	push   %edx
  8007b8:	ff d6                	call   *%esi
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007c0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c2:	83 c7 01             	add    $0x1,%edi
  8007c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c9:	0f be d0             	movsbl %al,%edx
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 4b                	je     80081b <vprintfmt+0x25b>
  8007d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d4:	78 06                	js     8007dc <vprintfmt+0x21c>
  8007d6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8007da:	78 1e                	js     8007fa <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8007dc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007e0:	74 d1                	je     8007b3 <vprintfmt+0x1f3>
  8007e2:	0f be c0             	movsbl %al,%eax
  8007e5:	83 e8 20             	sub    $0x20,%eax
  8007e8:	83 f8 5e             	cmp    $0x5e,%eax
  8007eb:	76 c6                	jbe    8007b3 <vprintfmt+0x1f3>
					putch('?', putdat);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	53                   	push   %ebx
  8007f1:	6a 3f                	push   $0x3f
  8007f3:	ff d6                	call   *%esi
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	eb c3                	jmp    8007bd <vprintfmt+0x1fd>
  8007fa:	89 cf                	mov    %ecx,%edi
  8007fc:	eb 0e                	jmp    80080c <vprintfmt+0x24c>
				putch(' ', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	6a 20                	push   $0x20
  800804:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800806:	83 ef 01             	sub    $0x1,%edi
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	85 ff                	test   %edi,%edi
  80080e:	7f ee                	jg     8007fe <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800810:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
  800816:	e9 67 01 00 00       	jmp    800982 <vprintfmt+0x3c2>
  80081b:	89 cf                	mov    %ecx,%edi
  80081d:	eb ed                	jmp    80080c <vprintfmt+0x24c>
	if (lflag >= 2)
  80081f:	83 f9 01             	cmp    $0x1,%ecx
  800822:	7f 1b                	jg     80083f <vprintfmt+0x27f>
	else if (lflag)
  800824:	85 c9                	test   %ecx,%ecx
  800826:	74 63                	je     80088b <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 00                	mov    (%eax),%eax
  80082d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800830:	99                   	cltd   
  800831:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8d 40 04             	lea    0x4(%eax),%eax
  80083a:	89 45 14             	mov    %eax,0x14(%ebp)
  80083d:	eb 17                	jmp    800856 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8b 50 04             	mov    0x4(%eax),%edx
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8d 40 08             	lea    0x8(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800856:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800859:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80085c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800861:	85 c9                	test   %ecx,%ecx
  800863:	0f 89 ff 00 00 00    	jns    800968 <vprintfmt+0x3a8>
				putch('-', putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	6a 2d                	push   $0x2d
  80086f:	ff d6                	call   *%esi
				num = -(long long) num;
  800871:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800874:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800877:	f7 da                	neg    %edx
  800879:	83 d1 00             	adc    $0x0,%ecx
  80087c:	f7 d9                	neg    %ecx
  80087e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800881:	bf 0a 00 00 00       	mov    $0xa,%edi
  800886:	e9 dd 00 00 00       	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80088b:	8b 45 14             	mov    0x14(%ebp),%eax
  80088e:	8b 00                	mov    (%eax),%eax
  800890:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800893:	99                   	cltd   
  800894:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	8d 40 04             	lea    0x4(%eax),%eax
  80089d:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a0:	eb b4                	jmp    800856 <vprintfmt+0x296>
	if (lflag >= 2)
  8008a2:	83 f9 01             	cmp    $0x1,%ecx
  8008a5:	7f 1e                	jg     8008c5 <vprintfmt+0x305>
	else if (lflag)
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	74 32                	je     8008dd <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8b 10                	mov    (%eax),%edx
  8008b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b5:	8d 40 04             	lea    0x4(%eax),%eax
  8008b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008bb:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8008c0:	e9 a3 00 00 00       	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 10                	mov    (%eax),%edx
  8008ca:	8b 48 04             	mov    0x4(%eax),%ecx
  8008cd:	8d 40 08             	lea    0x8(%eax),%eax
  8008d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008d3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8008d8:	e9 8b 00 00 00       	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8b 10                	mov    (%eax),%edx
  8008e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008ed:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8008f2:	eb 74                	jmp    800968 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8008f4:	83 f9 01             	cmp    $0x1,%ecx
  8008f7:	7f 1b                	jg     800914 <vprintfmt+0x354>
	else if (lflag)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	74 2c                	je     800929 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8b 10                	mov    (%eax),%edx
  800902:	b9 00 00 00 00       	mov    $0x0,%ecx
  800907:	8d 40 04             	lea    0x4(%eax),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80090d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800912:	eb 54                	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	8b 10                	mov    (%eax),%edx
  800919:	8b 48 04             	mov    0x4(%eax),%ecx
  80091c:	8d 40 08             	lea    0x8(%eax),%eax
  80091f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800922:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800927:	eb 3f                	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8b 10                	mov    (%eax),%edx
  80092e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800933:	8d 40 04             	lea    0x4(%eax),%eax
  800936:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800939:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80093e:	eb 28                	jmp    800968 <vprintfmt+0x3a8>
			putch('0', putdat);
  800940:	83 ec 08             	sub    $0x8,%esp
  800943:	53                   	push   %ebx
  800944:	6a 30                	push   $0x30
  800946:	ff d6                	call   *%esi
			putch('x', putdat);
  800948:	83 c4 08             	add    $0x8,%esp
  80094b:	53                   	push   %ebx
  80094c:	6a 78                	push   $0x78
  80094e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800950:	8b 45 14             	mov    0x14(%ebp),%eax
  800953:	8b 10                	mov    (%eax),%edx
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80095a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80095d:	8d 40 04             	lea    0x4(%eax),%eax
  800960:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800963:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80096f:	50                   	push   %eax
  800970:	ff 75 e0             	push   -0x20(%ebp)
  800973:	57                   	push   %edi
  800974:	51                   	push   %ecx
  800975:	52                   	push   %edx
  800976:	89 da                	mov    %ebx,%edx
  800978:	89 f0                	mov    %esi,%eax
  80097a:	e8 5e fb ff ff       	call   8004dd <printnum>
			break;
  80097f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800982:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800985:	e9 54 fc ff ff       	jmp    8005de <vprintfmt+0x1e>
	if (lflag >= 2)
  80098a:	83 f9 01             	cmp    $0x1,%ecx
  80098d:	7f 1b                	jg     8009aa <vprintfmt+0x3ea>
	else if (lflag)
  80098f:	85 c9                	test   %ecx,%ecx
  800991:	74 2c                	je     8009bf <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8b 10                	mov    (%eax),%edx
  800998:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099d:	8d 40 04             	lea    0x4(%eax),%eax
  8009a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8009a8:	eb be                	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8b 10                	mov    (%eax),%edx
  8009af:	8b 48 04             	mov    0x4(%eax),%ecx
  8009b2:	8d 40 08             	lea    0x8(%eax),%eax
  8009b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8009bd:	eb a9                	jmp    800968 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c2:	8b 10                	mov    (%eax),%edx
  8009c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c9:	8d 40 04             	lea    0x4(%eax),%eax
  8009cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009cf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8009d4:	eb 92                	jmp    800968 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 25                	push   $0x25
  8009dc:	ff d6                	call   *%esi
			break;
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	eb 9f                	jmp    800982 <vprintfmt+0x3c2>
			putch('%', putdat);
  8009e3:	83 ec 08             	sub    $0x8,%esp
  8009e6:	53                   	push   %ebx
  8009e7:	6a 25                	push   $0x25
  8009e9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009eb:	83 c4 10             	add    $0x10,%esp
  8009ee:	89 f8                	mov    %edi,%eax
  8009f0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009f4:	74 05                	je     8009fb <vprintfmt+0x43b>
  8009f6:	83 e8 01             	sub    $0x1,%eax
  8009f9:	eb f5                	jmp    8009f0 <vprintfmt+0x430>
  8009fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009fe:	eb 82                	jmp    800982 <vprintfmt+0x3c2>

00800a00 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 18             	sub    $0x18,%esp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a0f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a13:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a1d:	85 c0                	test   %eax,%eax
  800a1f:	74 26                	je     800a47 <vsnprintf+0x47>
  800a21:	85 d2                	test   %edx,%edx
  800a23:	7e 22                	jle    800a47 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a25:	ff 75 14             	push   0x14(%ebp)
  800a28:	ff 75 10             	push   0x10(%ebp)
  800a2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a2e:	50                   	push   %eax
  800a2f:	68 86 05 80 00       	push   $0x800586
  800a34:	e8 87 fb ff ff       	call   8005c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a3c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a42:	83 c4 10             	add    $0x10,%esp
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    
		return -E_INVAL;
  800a47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a4c:	eb f7                	jmp    800a45 <vsnprintf+0x45>

00800a4e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a54:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a57:	50                   	push   %eax
  800a58:	ff 75 10             	push   0x10(%ebp)
  800a5b:	ff 75 0c             	push   0xc(%ebp)
  800a5e:	ff 75 08             	push   0x8(%ebp)
  800a61:	e8 9a ff ff ff       	call   800a00 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	eb 03                	jmp    800a78 <strlen+0x10>
		n++;
  800a75:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a78:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a7c:	75 f7                	jne    800a75 <strlen+0xd>
	return n;
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	eb 03                	jmp    800a93 <strnlen+0x13>
		n++;
  800a90:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a93:	39 d0                	cmp    %edx,%eax
  800a95:	74 08                	je     800a9f <strnlen+0x1f>
  800a97:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a9b:	75 f3                	jne    800a90 <strnlen+0x10>
  800a9d:	89 c2                	mov    %eax,%edx
	return n;
}
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800ab6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	84 d2                	test   %dl,%dl
  800abe:	75 f2                	jne    800ab2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac0:	89 c8                	mov    %ecx,%eax
  800ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	83 ec 10             	sub    $0x10,%esp
  800ace:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad1:	53                   	push   %ebx
  800ad2:	e8 91 ff ff ff       	call   800a68 <strlen>
  800ad7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ada:	ff 75 0c             	push   0xc(%ebp)
  800add:	01 d8                	add    %ebx,%eax
  800adf:	50                   	push   %eax
  800ae0:	e8 be ff ff ff       	call   800aa3 <strcpy>
	return dst;
}
  800ae5:	89 d8                	mov    %ebx,%eax
  800ae7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 75 08             	mov    0x8(%ebp),%esi
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800afc:	89 f0                	mov    %esi,%eax
  800afe:	eb 0f                	jmp    800b0f <strncpy+0x23>
		*dst++ = *src;
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	0f b6 0a             	movzbl (%edx),%ecx
  800b06:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b09:	80 f9 01             	cmp    $0x1,%cl
  800b0c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800b0f:	39 d8                	cmp    %ebx,%eax
  800b11:	75 ed                	jne    800b00 <strncpy+0x14>
	}
	return ret;
}
  800b13:	89 f0                	mov    %esi,%eax
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	8b 75 08             	mov    0x8(%ebp),%esi
  800b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b24:	8b 55 10             	mov    0x10(%ebp),%edx
  800b27:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b29:	85 d2                	test   %edx,%edx
  800b2b:	74 21                	je     800b4e <strlcpy+0x35>
  800b2d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b31:	89 f2                	mov    %esi,%edx
  800b33:	eb 09                	jmp    800b3e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	83 c2 01             	add    $0x1,%edx
  800b3b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800b3e:	39 c2                	cmp    %eax,%edx
  800b40:	74 09                	je     800b4b <strlcpy+0x32>
  800b42:	0f b6 19             	movzbl (%ecx),%ebx
  800b45:	84 db                	test   %bl,%bl
  800b47:	75 ec                	jne    800b35 <strlcpy+0x1c>
  800b49:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b4b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b4e:	29 f0                	sub    %esi,%eax
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5d:	eb 06                	jmp    800b65 <strcmp+0x11>
		p++, q++;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b65:	0f b6 01             	movzbl (%ecx),%eax
  800b68:	84 c0                	test   %al,%al
  800b6a:	74 04                	je     800b70 <strcmp+0x1c>
  800b6c:	3a 02                	cmp    (%edx),%al
  800b6e:	74 ef                	je     800b5f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b70:	0f b6 c0             	movzbl %al,%eax
  800b73:	0f b6 12             	movzbl (%edx),%edx
  800b76:	29 d0                	sub    %edx,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b89:	eb 06                	jmp    800b91 <strncmp+0x17>
		n--, p++, q++;
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b91:	39 d8                	cmp    %ebx,%eax
  800b93:	74 18                	je     800bad <strncmp+0x33>
  800b95:	0f b6 08             	movzbl (%eax),%ecx
  800b98:	84 c9                	test   %cl,%cl
  800b9a:	74 04                	je     800ba0 <strncmp+0x26>
  800b9c:	3a 0a                	cmp    (%edx),%cl
  800b9e:	74 eb                	je     800b8b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba0:	0f b6 00             	movzbl (%eax),%eax
  800ba3:	0f b6 12             	movzbl (%edx),%edx
  800ba6:	29 d0                	sub    %edx,%eax
}
  800ba8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    
		return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb2:	eb f4                	jmp    800ba8 <strncmp+0x2e>

00800bb4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bbe:	eb 03                	jmp    800bc3 <strchr+0xf>
  800bc0:	83 c0 01             	add    $0x1,%eax
  800bc3:	0f b6 10             	movzbl (%eax),%edx
  800bc6:	84 d2                	test   %dl,%dl
  800bc8:	74 06                	je     800bd0 <strchr+0x1c>
		if (*s == c)
  800bca:	38 ca                	cmp    %cl,%dl
  800bcc:	75 f2                	jne    800bc0 <strchr+0xc>
  800bce:	eb 05                	jmp    800bd5 <strchr+0x21>
			return (char *) s;
	return 0;
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be4:	38 ca                	cmp    %cl,%dl
  800be6:	74 09                	je     800bf1 <strfind+0x1a>
  800be8:	84 d2                	test   %dl,%dl
  800bea:	74 05                	je     800bf1 <strfind+0x1a>
	for (; *s; s++)
  800bec:	83 c0 01             	add    $0x1,%eax
  800bef:	eb f0                	jmp    800be1 <strfind+0xa>
			break;
	return (char *) s;
}
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bff:	85 c9                	test   %ecx,%ecx
  800c01:	74 2f                	je     800c32 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c03:	89 f8                	mov    %edi,%eax
  800c05:	09 c8                	or     %ecx,%eax
  800c07:	a8 03                	test   $0x3,%al
  800c09:	75 21                	jne    800c2c <memset+0x39>
		c &= 0xFF;
  800c0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0f:	89 d0                	mov    %edx,%eax
  800c11:	c1 e0 08             	shl    $0x8,%eax
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	c1 e3 18             	shl    $0x18,%ebx
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	c1 e6 10             	shl    $0x10,%esi
  800c1e:	09 f3                	or     %esi,%ebx
  800c20:	09 da                	or     %ebx,%edx
  800c22:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c24:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c27:	fc                   	cld    
  800c28:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2a:	eb 06                	jmp    800c32 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	fc                   	cld    
  800c30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c32:	89 f8                	mov    %edi,%eax
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c47:	39 c6                	cmp    %eax,%esi
  800c49:	73 32                	jae    800c7d <memmove+0x44>
  800c4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4e:	39 c2                	cmp    %eax,%edx
  800c50:	76 2b                	jbe    800c7d <memmove+0x44>
		s += n;
		d += n;
  800c52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c55:	89 d6                	mov    %edx,%esi
  800c57:	09 fe                	or     %edi,%esi
  800c59:	09 ce                	or     %ecx,%esi
  800c5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c61:	75 0e                	jne    800c71 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c63:	83 ef 04             	sub    $0x4,%edi
  800c66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c6c:	fd                   	std    
  800c6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6f:	eb 09                	jmp    800c7a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c71:	83 ef 01             	sub    $0x1,%edi
  800c74:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c77:	fd                   	std    
  800c78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7a:	fc                   	cld    
  800c7b:	eb 1a                	jmp    800c97 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7d:	89 f2                	mov    %esi,%edx
  800c7f:	09 c2                	or     %eax,%edx
  800c81:	09 ca                	or     %ecx,%edx
  800c83:	f6 c2 03             	test   $0x3,%dl
  800c86:	75 0a                	jne    800c92 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c88:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c8b:	89 c7                	mov    %eax,%edi
  800c8d:	fc                   	cld    
  800c8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c90:	eb 05                	jmp    800c97 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800c92:	89 c7                	mov    %eax,%edi
  800c94:	fc                   	cld    
  800c95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca1:	ff 75 10             	push   0x10(%ebp)
  800ca4:	ff 75 0c             	push   0xc(%ebp)
  800ca7:	ff 75 08             	push   0x8(%ebp)
  800caa:	e8 8a ff ff ff       	call   800c39 <memmove>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbc:	89 c6                	mov    %eax,%esi
  800cbe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc1:	eb 06                	jmp    800cc9 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800cc9:	39 f0                	cmp    %esi,%eax
  800ccb:	74 14                	je     800ce1 <memcmp+0x30>
		if (*s1 != *s2)
  800ccd:	0f b6 08             	movzbl (%eax),%ecx
  800cd0:	0f b6 1a             	movzbl (%edx),%ebx
  800cd3:	38 d9                	cmp    %bl,%cl
  800cd5:	74 ec                	je     800cc3 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800cd7:	0f b6 c1             	movzbl %cl,%eax
  800cda:	0f b6 db             	movzbl %bl,%ebx
  800cdd:	29 d8                	sub    %ebx,%eax
  800cdf:	eb 05                	jmp    800ce6 <memcmp+0x35>
	}

	return 0;
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf3:	89 c2                	mov    %eax,%edx
  800cf5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf8:	eb 03                	jmp    800cfd <memfind+0x13>
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	39 d0                	cmp    %edx,%eax
  800cff:	73 04                	jae    800d05 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d01:	38 08                	cmp    %cl,(%eax)
  800d03:	75 f5                	jne    800cfa <memfind+0x10>
			break;
	return (void *) s;
}
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d13:	eb 03                	jmp    800d18 <strtol+0x11>
		s++;
  800d15:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d18:	0f b6 02             	movzbl (%edx),%eax
  800d1b:	3c 20                	cmp    $0x20,%al
  800d1d:	74 f6                	je     800d15 <strtol+0xe>
  800d1f:	3c 09                	cmp    $0x9,%al
  800d21:	74 f2                	je     800d15 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d23:	3c 2b                	cmp    $0x2b,%al
  800d25:	74 2a                	je     800d51 <strtol+0x4a>
	int neg = 0;
  800d27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d2c:	3c 2d                	cmp    $0x2d,%al
  800d2e:	74 2b                	je     800d5b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d36:	75 0f                	jne    800d47 <strtol+0x40>
  800d38:	80 3a 30             	cmpb   $0x30,(%edx)
  800d3b:	74 28                	je     800d65 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3d:	85 db                	test   %ebx,%ebx
  800d3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d44:	0f 44 d8             	cmove  %eax,%ebx
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d4f:	eb 46                	jmp    800d97 <strtol+0x90>
		s++;
  800d51:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d54:	bf 00 00 00 00       	mov    $0x0,%edi
  800d59:	eb d5                	jmp    800d30 <strtol+0x29>
		s++, neg = 1;
  800d5b:	83 c2 01             	add    $0x1,%edx
  800d5e:	bf 01 00 00 00       	mov    $0x1,%edi
  800d63:	eb cb                	jmp    800d30 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d65:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d69:	74 0e                	je     800d79 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800d6b:	85 db                	test   %ebx,%ebx
  800d6d:	75 d8                	jne    800d47 <strtol+0x40>
		s++, base = 8;
  800d6f:	83 c2 01             	add    $0x1,%edx
  800d72:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d77:	eb ce                	jmp    800d47 <strtol+0x40>
		s += 2, base = 16;
  800d79:	83 c2 02             	add    $0x2,%edx
  800d7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d81:	eb c4                	jmp    800d47 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d83:	0f be c0             	movsbl %al,%eax
  800d86:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d89:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d8c:	7d 3a                	jge    800dc8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d8e:	83 c2 01             	add    $0x1,%edx
  800d91:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800d95:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800d97:	0f b6 02             	movzbl (%edx),%eax
  800d9a:	8d 70 d0             	lea    -0x30(%eax),%esi
  800d9d:	89 f3                	mov    %esi,%ebx
  800d9f:	80 fb 09             	cmp    $0x9,%bl
  800da2:	76 df                	jbe    800d83 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800da4:	8d 70 9f             	lea    -0x61(%eax),%esi
  800da7:	89 f3                	mov    %esi,%ebx
  800da9:	80 fb 19             	cmp    $0x19,%bl
  800dac:	77 08                	ja     800db6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800dae:	0f be c0             	movsbl %al,%eax
  800db1:	83 e8 57             	sub    $0x57,%eax
  800db4:	eb d3                	jmp    800d89 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800db6:	8d 70 bf             	lea    -0x41(%eax),%esi
  800db9:	89 f3                	mov    %esi,%ebx
  800dbb:	80 fb 19             	cmp    $0x19,%bl
  800dbe:	77 08                	ja     800dc8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800dc0:	0f be c0             	movsbl %al,%eax
  800dc3:	83 e8 37             	sub    $0x37,%eax
  800dc6:	eb c1                	jmp    800d89 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcc:	74 05                	je     800dd3 <strtol+0xcc>
		*endptr = (char *) s;
  800dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dd3:	89 c8                	mov    %ecx,%eax
  800dd5:	f7 d8                	neg    %eax
  800dd7:	85 ff                	test   %edi,%edi
  800dd9:	0f 45 c8             	cmovne %eax,%ecx
}
  800ddc:	89 c8                	mov    %ecx,%eax
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	89 c7                	mov    %eax,%edi
  800df8:	89 c6                	mov    %eax,%esi
  800dfa:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 d7                	mov    %edx,%edi
  800e17:	89 d6                	mov    %edx,%esi
  800e19:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	b8 03 00 00 00       	mov    $0x3,%eax
  800e36:	89 cb                	mov    %ecx,%ebx
  800e38:	89 cf                	mov    %ecx,%edi
  800e3a:	89 ce                	mov    %ecx,%esi
  800e3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7f 08                	jg     800e4a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	50                   	push   %eax
  800e4e:	6a 03                	push   $0x3
  800e50:	68 df 2e 80 00       	push   $0x802edf
  800e55:	6a 2a                	push   $0x2a
  800e57:	68 fc 2e 80 00       	push   $0x802efc
  800e5c:	e8 8d f5 ff ff       	call   8003ee <_panic>

00800e61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 d3                	mov    %edx,%ebx
  800e75:	89 d7                	mov    %edx,%edi
  800e77:	89 d6                	mov    %edx,%esi
  800e79:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_yield>:

void
sys_yield(void)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e86:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e90:	89 d1                	mov    %edx,%ecx
  800e92:	89 d3                	mov    %edx,%ebx
  800e94:	89 d7                	mov    %edx,%edi
  800e96:	89 d6                	mov    %edx,%esi
  800e98:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea8:	be 00 00 00 00       	mov    $0x0,%esi
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebb:	89 f7                	mov    %esi,%edi
  800ebd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7f 08                	jg     800ecb <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 04                	push   $0x4
  800ed1:	68 df 2e 80 00       	push   $0x802edf
  800ed6:	6a 2a                	push   $0x2a
  800ed8:	68 fc 2e 80 00       	push   $0x802efc
  800edd:	e8 0c f5 ff ff       	call   8003ee <_panic>

00800ee2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800efc:	8b 75 18             	mov    0x18(%ebp),%esi
  800eff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7f 08                	jg     800f0d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	50                   	push   %eax
  800f11:	6a 05                	push   $0x5
  800f13:	68 df 2e 80 00       	push   $0x802edf
  800f18:	6a 2a                	push   $0x2a
  800f1a:	68 fc 2e 80 00       	push   $0x802efc
  800f1f:	e8 ca f4 ff ff       	call   8003ee <_panic>

00800f24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	53                   	push   %ebx
  800f2a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f38:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3d:	89 df                	mov    %ebx,%edi
  800f3f:	89 de                	mov    %ebx,%esi
  800f41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7f 08                	jg     800f4f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	50                   	push   %eax
  800f53:	6a 06                	push   $0x6
  800f55:	68 df 2e 80 00       	push   $0x802edf
  800f5a:	6a 2a                	push   $0x2a
  800f5c:	68 fc 2e 80 00       	push   $0x802efc
  800f61:	e8 88 f4 ff ff       	call   8003ee <_panic>

00800f66 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f74:	8b 55 08             	mov    0x8(%ebp),%edx
  800f77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800f7f:	89 df                	mov    %ebx,%edi
  800f81:	89 de                	mov    %ebx,%esi
  800f83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7f 08                	jg     800f91 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	50                   	push   %eax
  800f95:	6a 08                	push   $0x8
  800f97:	68 df 2e 80 00       	push   $0x802edf
  800f9c:	6a 2a                	push   $0x2a
  800f9e:	68 fc 2e 80 00       	push   $0x802efc
  800fa3:	e8 46 f4 ff ff       	call   8003ee <_panic>

00800fa8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc1:	89 df                	mov    %ebx,%edi
  800fc3:	89 de                	mov    %ebx,%esi
  800fc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7f 08                	jg     800fd3 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	50                   	push   %eax
  800fd7:	6a 09                	push   $0x9
  800fd9:	68 df 2e 80 00       	push   $0x802edf
  800fde:	6a 2a                	push   $0x2a
  800fe0:	68 fc 2e 80 00       	push   $0x802efc
  800fe5:	e8 04 f4 ff ff       	call   8003ee <_panic>

00800fea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801003:	89 df                	mov    %ebx,%edi
  801005:	89 de                	mov    %ebx,%esi
  801007:	cd 30                	int    $0x30
	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7f 08                	jg     801015 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	50                   	push   %eax
  801019:	6a 0a                	push   $0xa
  80101b:	68 df 2e 80 00       	push   $0x802edf
  801020:	6a 2a                	push   $0x2a
  801022:	68 fc 2e 80 00       	push   $0x802efc
  801027:	e8 c2 f3 ff ff       	call   8003ee <_panic>

0080102c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
	asm volatile("int %1\n"
  801032:	8b 55 08             	mov    0x8(%ebp),%edx
  801035:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801038:	b8 0c 00 00 00       	mov    $0xc,%eax
  80103d:	be 00 00 00 00       	mov    $0x0,%esi
  801042:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801045:	8b 7d 14             	mov    0x14(%ebp),%edi
  801048:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801058:	b9 00 00 00 00       	mov    $0x0,%ecx
  80105d:	8b 55 08             	mov    0x8(%ebp),%edx
  801060:	b8 0d 00 00 00       	mov    $0xd,%eax
  801065:	89 cb                	mov    %ecx,%ebx
  801067:	89 cf                	mov    %ecx,%edi
  801069:	89 ce                	mov    %ecx,%esi
  80106b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7f 08                	jg     801079 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801071:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 0d                	push   $0xd
  80107f:	68 df 2e 80 00       	push   $0x802edf
  801084:	6a 2a                	push   $0x2a
  801086:	68 fc 2e 80 00       	push   $0x802efc
  80108b:	e8 5e f3 ff ff       	call   8003ee <_panic>

00801090 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
	asm volatile("int %1\n"
  801096:	ba 00 00 00 00       	mov    $0x0,%edx
  80109b:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010a0:	89 d1                	mov    %edx,%ecx
  8010a2:	89 d3                	mov    %edx,%ebx
  8010a4:	89 d7                	mov    %edx,%edi
  8010a6:	89 d6                	mov    %edx,%esi
  8010a8:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c0:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010c5:	89 df                	mov    %ebx,%edi
  8010c7:	89 de                	mov    %ebx,%esi
  8010c9:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8010e6:	89 df                	mov    %ebx,%edi
  8010e8:	89 de                	mov    %ebx,%esi
  8010ea:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80110c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801111:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801120:	89 c2                	mov    %eax,%edx
  801122:	c1 ea 16             	shr    $0x16,%edx
  801125:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112c:	f6 c2 01             	test   $0x1,%dl
  80112f:	74 29                	je     80115a <fd_alloc+0x42>
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 ea 0c             	shr    $0xc,%edx
  801136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	74 18                	je     80115a <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801142:	05 00 10 00 00       	add    $0x1000,%eax
  801147:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114c:	75 d2                	jne    801120 <fd_alloc+0x8>
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801153:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801158:	eb 05                	jmp    80115f <fd_alloc+0x47>
			return 0;
  80115a:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80115f:	8b 55 08             	mov    0x8(%ebp),%edx
  801162:	89 02                	mov    %eax,(%edx)
}
  801164:	89 c8                	mov    %ecx,%eax
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116e:	83 f8 1f             	cmp    $0x1f,%eax
  801171:	77 30                	ja     8011a3 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801173:	c1 e0 0c             	shl    $0xc,%eax
  801176:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80117b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801181:	f6 c2 01             	test   $0x1,%dl
  801184:	74 24                	je     8011aa <fd_lookup+0x42>
  801186:	89 c2                	mov    %eax,%edx
  801188:	c1 ea 0c             	shr    $0xc,%edx
  80118b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801192:	f6 c2 01             	test   $0x1,%dl
  801195:	74 1a                	je     8011b1 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119a:	89 02                	mov    %eax,(%edx)
	return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    
		return -E_INVAL;
  8011a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a8:	eb f7                	jmp    8011a1 <fd_lookup+0x39>
		return -E_INVAL;
  8011aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011af:	eb f0                	jmp    8011a1 <fd_lookup+0x39>
  8011b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b6:	eb e9                	jmp    8011a1 <fd_lookup+0x39>

008011b8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c7:	bb 90 57 80 00       	mov    $0x805790,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011cc:	39 13                	cmp    %edx,(%ebx)
  8011ce:	74 37                	je     801207 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8011d0:	83 c0 01             	add    $0x1,%eax
  8011d3:	8b 1c 85 88 2f 80 00 	mov    0x802f88(,%eax,4),%ebx
  8011da:	85 db                	test   %ebx,%ebx
  8011dc:	75 ee                	jne    8011cc <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011de:	a1 70 77 80 00       	mov    0x807770,%eax
  8011e3:	8b 40 48             	mov    0x48(%eax),%eax
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	52                   	push   %edx
  8011ea:	50                   	push   %eax
  8011eb:	68 0c 2f 80 00       	push   $0x802f0c
  8011f0:	e8 d4 f2 ff ff       	call   8004c9 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801200:	89 1a                	mov    %ebx,(%edx)
}
  801202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801205:	c9                   	leave  
  801206:	c3                   	ret    
			return 0;
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
  80120c:	eb ef                	jmp    8011fd <dev_lookup+0x45>

0080120e <fd_close>:
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	83 ec 24             	sub    $0x24,%esp
  801217:	8b 75 08             	mov    0x8(%ebp),%esi
  80121a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80121d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801220:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801221:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801227:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122a:	50                   	push   %eax
  80122b:	e8 38 ff ff ff       	call   801168 <fd_lookup>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 05                	js     80123e <fd_close+0x30>
	    || fd != fd2)
  801239:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80123c:	74 16                	je     801254 <fd_close+0x46>
		return (must_exist ? r : 0);
  80123e:	89 f8                	mov    %edi,%eax
  801240:	84 c0                	test   %al,%al
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
  801247:	0f 44 d8             	cmove  %eax,%ebx
}
  80124a:	89 d8                	mov    %ebx,%eax
  80124c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 36                	push   (%esi)
  80125d:	e8 56 ff ff ff       	call   8011b8 <dev_lookup>
  801262:	89 c3                	mov    %eax,%ebx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 1a                	js     801285 <fd_close+0x77>
		if (dev->dev_close)
  80126b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80126e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801271:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801276:	85 c0                	test   %eax,%eax
  801278:	74 0b                	je     801285 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	56                   	push   %esi
  80127e:	ff d0                	call   *%eax
  801280:	89 c3                	mov    %eax,%ebx
  801282:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	56                   	push   %esi
  801289:	6a 00                	push   $0x0
  80128b:	e8 94 fc ff ff       	call   800f24 <sys_page_unmap>
	return r;
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	eb b5                	jmp    80124a <fd_close+0x3c>

00801295 <close>:

int
close(int fdnum)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129e:	50                   	push   %eax
  80129f:	ff 75 08             	push   0x8(%ebp)
  8012a2:	e8 c1 fe ff ff       	call   801168 <fd_lookup>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	79 02                	jns    8012b0 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    
		return fd_close(fd, 1);
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	6a 01                	push   $0x1
  8012b5:	ff 75 f4             	push   -0xc(%ebp)
  8012b8:	e8 51 ff ff ff       	call   80120e <fd_close>
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	eb ec                	jmp    8012ae <close+0x19>

008012c2 <close_all>:

void
close_all(void)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	53                   	push   %ebx
  8012d2:	e8 be ff ff ff       	call   801295 <close>
	for (i = 0; i < MAXFD; i++)
  8012d7:	83 c3 01             	add    $0x1,%ebx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	83 fb 20             	cmp    $0x20,%ebx
  8012e0:	75 ec                	jne    8012ce <close_all+0xc>
}
  8012e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	57                   	push   %edi
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	push   0x8(%ebp)
  8012f7:	e8 6c fe ff ff       	call   801168 <fd_lookup>
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 7f                	js     801384 <dup+0x9d>
		return r;
	close(newfdnum);
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	ff 75 0c             	push   0xc(%ebp)
  80130b:	e8 85 ff ff ff       	call   801295 <close>

	newfd = INDEX2FD(newfdnum);
  801310:	8b 75 0c             	mov    0xc(%ebp),%esi
  801313:	c1 e6 0c             	shl    $0xc,%esi
  801316:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131f:	89 3c 24             	mov    %edi,(%esp)
  801322:	e8 da fd ff ff       	call   801101 <fd2data>
  801327:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801329:	89 34 24             	mov    %esi,(%esp)
  80132c:	e8 d0 fd ff ff       	call   801101 <fd2data>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801337:	89 d8                	mov    %ebx,%eax
  801339:	c1 e8 16             	shr    $0x16,%eax
  80133c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801343:	a8 01                	test   $0x1,%al
  801345:	74 11                	je     801358 <dup+0x71>
  801347:	89 d8                	mov    %ebx,%eax
  801349:	c1 e8 0c             	shr    $0xc,%eax
  80134c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801353:	f6 c2 01             	test   $0x1,%dl
  801356:	75 36                	jne    80138e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801358:	89 f8                	mov    %edi,%eax
  80135a:	c1 e8 0c             	shr    $0xc,%eax
  80135d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	25 07 0e 00 00       	and    $0xe07,%eax
  80136c:	50                   	push   %eax
  80136d:	56                   	push   %esi
  80136e:	6a 00                	push   $0x0
  801370:	57                   	push   %edi
  801371:	6a 00                	push   $0x0
  801373:	e8 6a fb ff ff       	call   800ee2 <sys_page_map>
  801378:	89 c3                	mov    %eax,%ebx
  80137a:	83 c4 20             	add    $0x20,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 33                	js     8013b4 <dup+0xcd>
		goto err;

	return newfdnum;
  801381:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801384:	89 d8                	mov    %ebx,%eax
  801386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5f                   	pop    %edi
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80138e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	25 07 0e 00 00       	and    $0xe07,%eax
  80139d:	50                   	push   %eax
  80139e:	ff 75 d4             	push   -0x2c(%ebp)
  8013a1:	6a 00                	push   $0x0
  8013a3:	53                   	push   %ebx
  8013a4:	6a 00                	push   $0x0
  8013a6:	e8 37 fb ff ff       	call   800ee2 <sys_page_map>
  8013ab:	89 c3                	mov    %eax,%ebx
  8013ad:	83 c4 20             	add    $0x20,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	79 a4                	jns    801358 <dup+0x71>
	sys_page_unmap(0, newfd);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	56                   	push   %esi
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 65 fb ff ff       	call   800f24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	ff 75 d4             	push   -0x2c(%ebp)
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 58 fb ff ff       	call   800f24 <sys_page_unmap>
	return r;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	eb b3                	jmp    801384 <dup+0x9d>

008013d1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 18             	sub    $0x18,%esp
  8013d9:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	56                   	push   %esi
  8013e1:	e8 82 fd ff ff       	call   801168 <fd_lookup>
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 3c                	js     801429 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f6:	50                   	push   %eax
  8013f7:	ff 33                	push   (%ebx)
  8013f9:	e8 ba fd ff ff       	call   8011b8 <dev_lookup>
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 24                	js     801429 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801405:	8b 43 08             	mov    0x8(%ebx),%eax
  801408:	83 e0 03             	and    $0x3,%eax
  80140b:	83 f8 01             	cmp    $0x1,%eax
  80140e:	74 20                	je     801430 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801413:	8b 40 08             	mov    0x8(%eax),%eax
  801416:	85 c0                	test   %eax,%eax
  801418:	74 37                	je     801451 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141a:	83 ec 04             	sub    $0x4,%esp
  80141d:	ff 75 10             	push   0x10(%ebp)
  801420:	ff 75 0c             	push   0xc(%ebp)
  801423:	53                   	push   %ebx
  801424:	ff d0                	call   *%eax
  801426:	83 c4 10             	add    $0x10,%esp
}
  801429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801430:	a1 70 77 80 00       	mov    0x807770,%eax
  801435:	8b 40 48             	mov    0x48(%eax),%eax
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	56                   	push   %esi
  80143c:	50                   	push   %eax
  80143d:	68 4d 2f 80 00       	push   $0x802f4d
  801442:	e8 82 f0 ff ff       	call   8004c9 <cprintf>
		return -E_INVAL;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144f:	eb d8                	jmp    801429 <read+0x58>
		return -E_NOT_SUPP;
  801451:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801456:	eb d1                	jmp    801429 <read+0x58>

00801458 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	57                   	push   %edi
  80145c:	56                   	push   %esi
  80145d:	53                   	push   %ebx
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	8b 7d 08             	mov    0x8(%ebp),%edi
  801464:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801467:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146c:	eb 02                	jmp    801470 <readn+0x18>
  80146e:	01 c3                	add    %eax,%ebx
  801470:	39 f3                	cmp    %esi,%ebx
  801472:	73 21                	jae    801495 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	89 f0                	mov    %esi,%eax
  801479:	29 d8                	sub    %ebx,%eax
  80147b:	50                   	push   %eax
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	03 45 0c             	add    0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	57                   	push   %edi
  801483:	e8 49 ff ff ff       	call   8013d1 <read>
		if (m < 0)
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 04                	js     801493 <readn+0x3b>
			return m;
		if (m == 0)
  80148f:	75 dd                	jne    80146e <readn+0x16>
  801491:	eb 02                	jmp    801495 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801493:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801495:	89 d8                	mov    %ebx,%eax
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 18             	sub    $0x18,%esp
  8014a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	53                   	push   %ebx
  8014af:	e8 b4 fc ff ff       	call   801168 <fd_lookup>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 37                	js     8014f2 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	ff 36                	push   (%esi)
  8014c7:	e8 ec fc ff ff       	call   8011b8 <dev_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 1f                	js     8014f2 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014d7:	74 20                	je     8014f9 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	74 37                	je     80151a <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	ff 75 10             	push   0x10(%ebp)
  8014e9:	ff 75 0c             	push   0xc(%ebp)
  8014ec:	56                   	push   %esi
  8014ed:	ff d0                	call   *%eax
  8014ef:	83 c4 10             	add    $0x10,%esp
}
  8014f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f9:	a1 70 77 80 00       	mov    0x807770,%eax
  8014fe:	8b 40 48             	mov    0x48(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 69 2f 80 00       	push   $0x802f69
  80150b:	e8 b9 ef ff ff       	call   8004c9 <cprintf>
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801518:	eb d8                	jmp    8014f2 <write+0x53>
		return -E_NOT_SUPP;
  80151a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80151f:	eb d1                	jmp    8014f2 <write+0x53>

00801521 <seek>:

int
seek(int fdnum, off_t offset)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	ff 75 08             	push   0x8(%ebp)
  80152e:	e8 35 fc ff ff       	call   801168 <fd_lookup>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	78 0e                	js     801548 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80153a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801540:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801543:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	83 ec 18             	sub    $0x18,%esp
  801552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801555:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	53                   	push   %ebx
  80155a:	e8 09 fc ff ff       	call   801168 <fd_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 34                	js     80159a <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801566:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	ff 36                	push   (%esi)
  801572:	e8 41 fc ff ff       	call   8011b8 <dev_lookup>
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 1c                	js     80159a <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801582:	74 1d                	je     8015a1 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801587:	8b 40 18             	mov    0x18(%eax),%eax
  80158a:	85 c0                	test   %eax,%eax
  80158c:	74 34                	je     8015c2 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	ff 75 0c             	push   0xc(%ebp)
  801594:	56                   	push   %esi
  801595:	ff d0                	call   *%eax
  801597:	83 c4 10             	add    $0x10,%esp
}
  80159a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015a1:	a1 70 77 80 00       	mov    0x807770,%eax
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	50                   	push   %eax
  8015ae:	68 2c 2f 80 00       	push   $0x802f2c
  8015b3:	e8 11 ef ff ff       	call   8004c9 <cprintf>
		return -E_INVAL;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c0:	eb d8                	jmp    80159a <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c7:	eb d1                	jmp    80159a <ftruncate+0x50>

008015c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 18             	sub    $0x18,%esp
  8015d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 08             	push   0x8(%ebp)
  8015db:	e8 88 fb ff ff       	call   801168 <fd_lookup>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 49                	js     801630 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 36                	push   (%esi)
  8015f3:	e8 c0 fb ff ff       	call   8011b8 <dev_lookup>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 31                	js     801630 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801602:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801606:	74 2f                	je     801637 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801608:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80160b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801612:	00 00 00 
	stat->st_isdir = 0;
  801615:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161c:	00 00 00 
	stat->st_dev = dev;
  80161f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	53                   	push   %ebx
  801629:	56                   	push   %esi
  80162a:	ff 50 14             	call   *0x14(%eax)
  80162d:	83 c4 10             	add    $0x10,%esp
}
  801630:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    
		return -E_NOT_SUPP;
  801637:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80163c:	eb f2                	jmp    801630 <fstat+0x67>

0080163e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	6a 00                	push   $0x0
  801648:	ff 75 08             	push   0x8(%ebp)
  80164b:	e8 e4 01 00 00       	call   801834 <open>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 1b                	js     801674 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	ff 75 0c             	push   0xc(%ebp)
  80165f:	50                   	push   %eax
  801660:	e8 64 ff ff ff       	call   8015c9 <fstat>
  801665:	89 c6                	mov    %eax,%esi
	close(fd);
  801667:	89 1c 24             	mov    %ebx,(%esp)
  80166a:	e8 26 fc ff ff       	call   801295 <close>
	return r;
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	89 f3                	mov    %esi,%ebx
}
  801674:	89 d8                	mov    %ebx,%eax
  801676:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	89 c6                	mov    %eax,%esi
  801684:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801686:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80168d:	74 27                	je     8016b6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80168f:	6a 07                	push   $0x7
  801691:	68 00 80 80 00       	push   $0x808000
  801696:	56                   	push   %esi
  801697:	ff 35 00 90 80 00    	push   0x809000
  80169d:	e8 b1 10 00 00       	call   802753 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016a2:	83 c4 0c             	add    $0xc,%esp
  8016a5:	6a 00                	push   $0x0
  8016a7:	53                   	push   %ebx
  8016a8:	6a 00                	push   $0x0
  8016aa:	e8 3d 10 00 00       	call   8026ec <ipc_recv>
}
  8016af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5e                   	pop    %esi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b6:	83 ec 0c             	sub    $0xc,%esp
  8016b9:	6a 01                	push   $0x1
  8016bb:	e8 e7 10 00 00       	call   8027a7 <ipc_find_env>
  8016c0:	a3 00 90 80 00       	mov    %eax,0x809000
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	eb c5                	jmp    80168f <fsipc+0x12>

008016ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d6:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8016db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016de:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ed:	e8 8b ff ff ff       	call   80167d <fsipc>
}
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <devfile_flush>:
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 06 00 00 00       	mov    $0x6,%eax
  80170f:	e8 69 ff ff ff       	call   80167d <fsipc>
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devfile_stat>:
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	53                   	push   %ebx
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	8b 40 0c             	mov    0xc(%eax),%eax
  801726:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 05 00 00 00       	mov    $0x5,%eax
  801735:	e8 43 ff ff ff       	call   80167d <fsipc>
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 2c                	js     80176a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	68 00 80 80 00       	push   $0x808000
  801746:	53                   	push   %ebx
  801747:	e8 57 f3 ff ff       	call   800aa3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174c:	a1 80 80 80 00       	mov    0x808080,%eax
  801751:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801757:	a1 84 80 80 00       	mov    0x808084,%eax
  80175c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devfile_write>:
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	8b 45 10             	mov    0x10(%ebp),%eax
  801778:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80177d:	39 d0                	cmp    %edx,%eax
  80177f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801782:	8b 55 08             	mov    0x8(%ebp),%edx
  801785:	8b 52 0c             	mov    0xc(%edx),%edx
  801788:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  80178e:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801793:	50                   	push   %eax
  801794:	ff 75 0c             	push   0xc(%ebp)
  801797:	68 08 80 80 00       	push   $0x808008
  80179c:	e8 98 f4 ff ff       	call   800c39 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ab:	e8 cd fe ff ff       	call   80167d <fsipc>
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devfile_read>:
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c0:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  8017c5:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d5:	e8 a3 fe ff ff       	call   80167d <fsipc>
  8017da:	89 c3                	mov    %eax,%ebx
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 1f                	js     8017ff <devfile_read+0x4d>
	assert(r <= n);
  8017e0:	39 f0                	cmp    %esi,%eax
  8017e2:	77 24                	ja     801808 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017e4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e9:	7f 33                	jg     80181e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	50                   	push   %eax
  8017ef:	68 00 80 80 00       	push   $0x808000
  8017f4:	ff 75 0c             	push   0xc(%ebp)
  8017f7:	e8 3d f4 ff ff       	call   800c39 <memmove>
	return r;
  8017fc:	83 c4 10             	add    $0x10,%esp
}
  8017ff:	89 d8                	mov    %ebx,%eax
  801801:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    
	assert(r <= n);
  801808:	68 9c 2f 80 00       	push   $0x802f9c
  80180d:	68 a3 2f 80 00       	push   $0x802fa3
  801812:	6a 7c                	push   $0x7c
  801814:	68 b8 2f 80 00       	push   $0x802fb8
  801819:	e8 d0 eb ff ff       	call   8003ee <_panic>
	assert(r <= PGSIZE);
  80181e:	68 c3 2f 80 00       	push   $0x802fc3
  801823:	68 a3 2f 80 00       	push   $0x802fa3
  801828:	6a 7d                	push   $0x7d
  80182a:	68 b8 2f 80 00       	push   $0x802fb8
  80182f:	e8 ba eb ff ff       	call   8003ee <_panic>

00801834 <open>:
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	56                   	push   %esi
  801838:	53                   	push   %ebx
  801839:	83 ec 1c             	sub    $0x1c,%esp
  80183c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80183f:	56                   	push   %esi
  801840:	e8 23 f2 ff ff       	call   800a68 <strlen>
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184d:	7f 6c                	jg     8018bb <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	e8 bd f8 ff ff       	call   801118 <fd_alloc>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	78 3c                	js     8018a0 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	56                   	push   %esi
  801868:	68 00 80 80 00       	push   $0x808000
  80186d:	e8 31 f2 ff ff       	call   800aa3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	a3 00 84 80 00       	mov    %eax,0x808400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187d:	b8 01 00 00 00       	mov    $0x1,%eax
  801882:	e8 f6 fd ff ff       	call   80167d <fsipc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 19                	js     8018a9 <open+0x75>
	return fd2num(fd);
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff 75 f4             	push   -0xc(%ebp)
  801896:	e8 56 f8 ff ff       	call   8010f1 <fd2num>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    
		fd_close(fd, 0);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	6a 00                	push   $0x0
  8018ae:	ff 75 f4             	push   -0xc(%ebp)
  8018b1:	e8 58 f9 ff ff       	call   80120e <fd_close>
		return r;
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	eb e5                	jmp    8018a0 <open+0x6c>
		return -E_BAD_PATH;
  8018bb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018c0:	eb de                	jmp    8018a0 <open+0x6c>

008018c2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d2:	e8 a6 fd ff ff       	call   80167d <fsipc>
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	57                   	push   %edi
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018e5:	6a 00                	push   $0x0
  8018e7:	ff 75 08             	push   0x8(%ebp)
  8018ea:	e8 45 ff ff ff       	call   801834 <open>
  8018ef:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	0f 88 aa 04 00 00    	js     801daa <spawn+0x4d1>
  801900:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801902:	83 ec 04             	sub    $0x4,%esp
  801905:	68 00 02 00 00       	push   $0x200
  80190a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801910:	50                   	push   %eax
  801911:	57                   	push   %edi
  801912:	e8 41 fb ff ff       	call   801458 <readn>
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80191f:	75 57                	jne    801978 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  801921:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801928:	45 4c 46 
  80192b:	75 4b                	jne    801978 <spawn+0x9f>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80192d:	b8 07 00 00 00       	mov    $0x7,%eax
  801932:	cd 30                	int    $0x30
  801934:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80193a:	85 c0                	test   %eax,%eax
  80193c:	0f 88 5c 04 00 00    	js     801d9e <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801942:	25 ff 03 00 00       	and    $0x3ff,%eax
  801947:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80194a:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801950:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801956:	b9 11 00 00 00       	mov    $0x11,%ecx
  80195b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80195d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801963:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801969:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80196e:	be 00 00 00 00       	mov    $0x0,%esi
  801973:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801976:	eb 4b                	jmp    8019c3 <spawn+0xea>
		close(fd);
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801981:	e8 0f f9 ff ff       	call   801295 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801986:	83 c4 0c             	add    $0xc,%esp
  801989:	68 7f 45 4c 46       	push   $0x464c457f
  80198e:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801994:	68 cf 2f 80 00       	push   $0x802fcf
  801999:	e8 2b eb ff ff       	call   8004c9 <cprintf>
		return -E_NOT_EXEC;
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  8019a8:	ff ff ff 
  8019ab:	e9 fa 03 00 00       	jmp    801daa <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	50                   	push   %eax
  8019b4:	e8 af f0 ff ff       	call   800a68 <strlen>
  8019b9:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8019bd:	83 c3 01             	add    $0x1,%ebx
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019ca:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	75 df                	jne    8019b0 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019d1:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8019d7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8019dd:	b8 00 10 40 00       	mov    $0x401000,%eax
  8019e2:	29 f0                	sub    %esi,%eax
  8019e4:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019e6:	89 c2                	mov    %eax,%edx
  8019e8:	83 e2 fc             	and    $0xfffffffc,%edx
  8019eb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019f2:	29 c2                	sub    %eax,%edx
  8019f4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019fa:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019fd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a02:	0f 86 14 04 00 00    	jbe    801e1c <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	6a 07                	push   $0x7
  801a0d:	68 00 00 40 00       	push   $0x400000
  801a12:	6a 00                	push   $0x0
  801a14:	e8 86 f4 ff ff       	call   800e9f <sys_page_alloc>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 fd 03 00 00    	js     801e21 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a24:	be 00 00 00 00       	mov    $0x0,%esi
  801a29:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a32:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a38:	7e 32                	jle    801a6c <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  801a3a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a40:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a46:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	ff 34 b3             	push   (%ebx,%esi,4)
  801a4f:	57                   	push   %edi
  801a50:	e8 4e f0 ff ff       	call   800aa3 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a55:	83 c4 04             	add    $0x4,%esp
  801a58:	ff 34 b3             	push   (%ebx,%esi,4)
  801a5b:	e8 08 f0 ff ff       	call   800a68 <strlen>
  801a60:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801a64:	83 c6 01             	add    $0x1,%esi
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	eb c6                	jmp    801a32 <spawn+0x159>
	}
	argv_store[argc] = 0;
  801a6c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a72:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a78:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a7f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a85:	0f 85 8c 00 00 00    	jne    801b17 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a8b:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a91:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801a97:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801a9a:	89 c8                	mov    %ecx,%eax
  801a9c:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801aa2:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801aa5:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801aaa:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	6a 07                	push   $0x7
  801ab5:	68 00 d0 bf ee       	push   $0xeebfd000
  801aba:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ac0:	68 00 00 40 00       	push   $0x400000
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 16 f4 ff ff       	call   800ee2 <sys_page_map>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	83 c4 20             	add    $0x20,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	0f 88 50 03 00 00    	js     801e29 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	68 00 00 40 00       	push   $0x400000
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 3c f4 ff ff       	call   800f24 <sys_page_unmap>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	85 c0                	test   %eax,%eax
  801aef:	0f 88 34 03 00 00    	js     801e29 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801af5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801afb:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b02:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b08:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b0f:	00 00 00 
  801b12:	e9 4e 01 00 00       	jmp    801c65 <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b17:	68 5c 30 80 00       	push   $0x80305c
  801b1c:	68 a3 2f 80 00       	push   $0x802fa3
  801b21:	68 f2 00 00 00       	push   $0xf2
  801b26:	68 e9 2f 80 00       	push   $0x802fe9
  801b2b:	e8 be e8 ff ff       	call   8003ee <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	6a 07                	push   $0x7
  801b35:	68 00 00 40 00       	push   $0x400000
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 5e f3 ff ff       	call   800e9f <sys_page_alloc>
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 6c 02 00 00    	js     801db8 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b4c:	83 ec 08             	sub    $0x8,%esp
  801b4f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b55:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b5b:	50                   	push   %eax
  801b5c:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801b62:	e8 ba f9 ff ff       	call   801521 <seek>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	0f 88 4d 02 00 00    	js     801dbf <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b72:	83 ec 04             	sub    $0x4,%esp
  801b75:	89 f8                	mov    %edi,%eax
  801b77:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801b7d:	ba 00 10 00 00       	mov    $0x1000,%edx
  801b82:	39 d0                	cmp    %edx,%eax
  801b84:	0f 47 c2             	cmova  %edx,%eax
  801b87:	50                   	push   %eax
  801b88:	68 00 00 40 00       	push   $0x400000
  801b8d:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801b93:	e8 c0 f8 ff ff       	call   801458 <readn>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 23 02 00 00    	js     801dc6 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801bac:	56                   	push   %esi
  801bad:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801bb3:	68 00 00 40 00       	push   $0x400000
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 23 f3 ff ff       	call   800ee2 <sys_page_map>
  801bbf:	83 c4 20             	add    $0x20,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 7c                	js     801c42 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801bc6:	83 ec 08             	sub    $0x8,%esp
  801bc9:	68 00 00 40 00       	push   $0x400000
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 4f f3 ff ff       	call   800f24 <sys_page_unmap>
  801bd5:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801bd8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801bde:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801be4:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801bea:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801bf0:	76 65                	jbe    801c57 <spawn+0x37e>
		if (i >= filesz) {
  801bf2:	39 df                	cmp    %ebx,%edi
  801bf4:	0f 87 36 ff ff ff    	ja     801b30 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c03:	56                   	push   %esi
  801c04:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c0a:	e8 90 f2 ff ff       	call   800e9f <sys_page_alloc>
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	85 c0                	test   %eax,%eax
  801c14:	79 c2                	jns    801bd8 <spawn+0x2ff>
  801c16:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c21:	e8 fa f1 ff ff       	call   800e20 <sys_env_destroy>
	close(fd);
  801c26:	83 c4 04             	add    $0x4,%esp
  801c29:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c2f:	e8 61 f6 ff ff       	call   801295 <close>
	return r;
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801c3d:	e9 68 01 00 00       	jmp    801daa <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801c42:	50                   	push   %eax
  801c43:	68 f5 2f 80 00       	push   $0x802ff5
  801c48:	68 25 01 00 00       	push   $0x125
  801c4d:	68 e9 2f 80 00       	push   $0x802fe9
  801c52:	e8 97 e7 ff ff       	call   8003ee <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c57:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801c5e:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801c65:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c6c:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801c72:	7e 67                	jle    801cdb <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801c74:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801c7a:	83 39 01             	cmpl   $0x1,(%ecx)
  801c7d:	75 d8                	jne    801c57 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c7f:	8b 41 18             	mov    0x18(%ecx),%eax
  801c82:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c88:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c8b:	83 f8 01             	cmp    $0x1,%eax
  801c8e:	19 c0                	sbb    %eax,%eax
  801c90:	83 e0 fe             	and    $0xfffffffe,%eax
  801c93:	83 c0 07             	add    $0x7,%eax
  801c96:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c9c:	8b 51 04             	mov    0x4(%ecx),%edx
  801c9f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801ca5:	8b 79 10             	mov    0x10(%ecx),%edi
  801ca8:	8b 59 14             	mov    0x14(%ecx),%ebx
  801cab:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801cb1:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801cb4:	89 f0                	mov    %esi,%eax
  801cb6:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cbb:	74 14                	je     801cd1 <spawn+0x3f8>
		va -= i;
  801cbd:	29 c6                	sub    %eax,%esi
		memsz += i;
  801cbf:	01 c3                	add    %eax,%ebx
  801cc1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801cc7:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801cc9:	29 c2                	sub    %eax,%edx
  801ccb:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd6:	e9 09 ff ff ff       	jmp    801be4 <spawn+0x30b>
	close(fd);
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801ce4:	e8 ac f5 ff ff       	call   801295 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801ce9:	e8 73 f1 ff ff       	call   800e61 <sys_getenvid>
  801cee:	89 c6                	mov    %eax,%esi
  801cf0:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801cf3:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801cf8:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801cfe:	eb 12                	jmp    801d12 <spawn+0x439>
  801d00:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d06:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d0c:	0f 84 bb 00 00 00    	je     801dcd <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	c1 e8 16             	shr    $0x16,%eax
  801d17:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d1e:	a8 01                	test   $0x1,%al
  801d20:	74 de                	je     801d00 <spawn+0x427>
  801d22:	89 d8                	mov    %ebx,%eax
  801d24:	c1 e8 0c             	shr    $0xc,%eax
  801d27:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d2e:	f6 c2 01             	test   $0x1,%dl
  801d31:	74 cd                	je     801d00 <spawn+0x427>
  801d33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d3a:	f6 c6 04             	test   $0x4,%dh
  801d3d:	74 c1                	je     801d00 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801d3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d46:	83 ec 0c             	sub    $0xc,%esp
  801d49:	25 07 0e 00 00       	and    $0xe07,%eax
  801d4e:	50                   	push   %eax
  801d4f:	53                   	push   %ebx
  801d50:	57                   	push   %edi
  801d51:	53                   	push   %ebx
  801d52:	56                   	push   %esi
  801d53:	e8 8a f1 ff ff       	call   800ee2 <sys_page_map>
  801d58:	83 c4 20             	add    $0x20,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	79 a1                	jns    801d00 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801d5f:	50                   	push   %eax
  801d60:	68 43 30 80 00       	push   $0x803043
  801d65:	68 82 00 00 00       	push   $0x82
  801d6a:	68 e9 2f 80 00       	push   $0x802fe9
  801d6f:	e8 7a e6 ff ff       	call   8003ee <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801d74:	50                   	push   %eax
  801d75:	68 12 30 80 00       	push   $0x803012
  801d7a:	68 86 00 00 00       	push   $0x86
  801d7f:	68 e9 2f 80 00       	push   $0x802fe9
  801d84:	e8 65 e6 ff ff       	call   8003ee <_panic>
		panic("sys_env_set_status: %e", r);
  801d89:	50                   	push   %eax
  801d8a:	68 2c 30 80 00       	push   $0x80302c
  801d8f:	68 89 00 00 00       	push   $0x89
  801d94:	68 e9 2f 80 00       	push   $0x802fe9
  801d99:	e8 50 e6 ff ff       	call   8003ee <_panic>
		return r;
  801d9e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801da4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801daa:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    
  801db8:	89 c7                	mov    %eax,%edi
  801dba:	e9 59 fe ff ff       	jmp    801c18 <spawn+0x33f>
  801dbf:	89 c7                	mov    %eax,%edi
  801dc1:	e9 52 fe ff ff       	jmp    801c18 <spawn+0x33f>
  801dc6:	89 c7                	mov    %eax,%edi
  801dc8:	e9 4b fe ff ff       	jmp    801c18 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801dcd:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801dd4:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801de7:	e8 bc f1 ff ff       	call   800fa8 <sys_env_set_trapframe>
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	85 c0                	test   %eax,%eax
  801df1:	78 81                	js     801d74 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801df3:	83 ec 08             	sub    $0x8,%esp
  801df6:	6a 02                	push   $0x2
  801df8:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801dfe:	e8 63 f1 ff ff       	call   800f66 <sys_env_set_status>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	0f 88 7b ff ff ff    	js     801d89 <spawn+0x4b0>
	return child;
  801e0e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e14:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e1a:	eb 8e                	jmp    801daa <spawn+0x4d1>
		return -E_NO_MEM;
  801e1c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801e21:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e27:	eb 81                	jmp    801daa <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801e29:	83 ec 08             	sub    $0x8,%esp
  801e2c:	68 00 00 40 00       	push   $0x400000
  801e31:	6a 00                	push   $0x0
  801e33:	e8 ec f0 ff ff       	call   800f24 <sys_page_unmap>
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801e41:	e9 64 ff ff ff       	jmp    801daa <spawn+0x4d1>

00801e46 <spawnl>:
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
	va_start(vl, arg0);
  801e4b:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801e53:	eb 05                	jmp    801e5a <spawnl+0x14>
		argc++;
  801e55:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801e58:	89 ca                	mov    %ecx,%edx
  801e5a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e5d:	83 3a 00             	cmpl   $0x0,(%edx)
  801e60:	75 f3                	jne    801e55 <spawnl+0xf>
	const char *argv[argc+2];
  801e62:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801e69:	89 d3                	mov    %edx,%ebx
  801e6b:	83 e3 f0             	and    $0xfffffff0,%ebx
  801e6e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801e74:	89 e1                	mov    %esp,%ecx
  801e76:	29 d1                	sub    %edx,%ecx
  801e78:	39 cc                	cmp    %ecx,%esp
  801e7a:	74 10                	je     801e8c <spawnl+0x46>
  801e7c:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801e82:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801e89:	00 
  801e8a:	eb ec                	jmp    801e78 <spawnl+0x32>
  801e8c:	89 da                	mov    %ebx,%edx
  801e8e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801e94:	29 d4                	sub    %edx,%esp
  801e96:	85 d2                	test   %edx,%edx
  801e98:	74 05                	je     801e9f <spawnl+0x59>
  801e9a:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801e9f:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801ea3:	89 da                	mov    %ebx,%edx
  801ea5:	c1 ea 02             	shr    $0x2,%edx
  801ea8:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eae:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801eb5:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801ebc:	00 
	va_start(vl, arg0);
  801ebd:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801ec0:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec7:	eb 0b                	jmp    801ed4 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801ec9:	83 c0 01             	add    $0x1,%eax
  801ecc:	8b 31                	mov    (%ecx),%esi
  801ece:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801ed1:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801ed4:	39 d0                	cmp    %edx,%eax
  801ed6:	75 f1                	jne    801ec9 <spawnl+0x83>
	return spawn(prog, argv);
  801ed8:	83 ec 08             	sub    $0x8,%esp
  801edb:	53                   	push   %ebx
  801edc:	ff 75 08             	push   0x8(%ebp)
  801edf:	e8 f5 f9 ff ff       	call   8018d9 <spawn>
}
  801ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ef1:	68 82 30 80 00       	push   $0x803082
  801ef6:	ff 75 0c             	push   0xc(%ebp)
  801ef9:	e8 a5 eb ff ff       	call   800aa3 <strcpy>
	return 0;
}
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <devsock_close>:
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	53                   	push   %ebx
  801f09:	83 ec 10             	sub    $0x10,%esp
  801f0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f0f:	53                   	push   %ebx
  801f10:	e8 cb 08 00 00       	call   8027e0 <pageref>
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	83 c4 10             	add    $0x10,%esp
		return 0;
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801f1f:	83 fa 01             	cmp    $0x1,%edx
  801f22:	74 05                	je     801f29 <devsock_close+0x24>
}
  801f24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f27:	c9                   	leave  
  801f28:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	ff 73 0c             	push   0xc(%ebx)
  801f2f:	e8 b7 02 00 00       	call   8021eb <nsipc_close>
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	eb eb                	jmp    801f24 <devsock_close+0x1f>

00801f39 <devsock_write>:
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f3f:	6a 00                	push   $0x0
  801f41:	ff 75 10             	push   0x10(%ebp)
  801f44:	ff 75 0c             	push   0xc(%ebp)
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	ff 70 0c             	push   0xc(%eax)
  801f4d:	e8 79 03 00 00       	call   8022cb <nsipc_send>
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <devsock_read>:
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f5a:	6a 00                	push   $0x0
  801f5c:	ff 75 10             	push   0x10(%ebp)
  801f5f:	ff 75 0c             	push   0xc(%ebp)
  801f62:	8b 45 08             	mov    0x8(%ebp),%eax
  801f65:	ff 70 0c             	push   0xc(%eax)
  801f68:	e8 ef 02 00 00       	call   80225c <nsipc_recv>
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <fd2sockid>:
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f75:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f78:	52                   	push   %edx
  801f79:	50                   	push   %eax
  801f7a:	e8 e9 f1 ff ff       	call   801168 <fd_lookup>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 10                	js     801f96 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f89:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801f8f:	39 08                	cmp    %ecx,(%eax)
  801f91:	75 05                	jne    801f98 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801f93:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    
		return -E_NOT_SUPP;
  801f98:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f9d:	eb f7                	jmp    801f96 <fd2sockid+0x27>

00801f9f <alloc_sockfd>:
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fac:	50                   	push   %eax
  801fad:	e8 66 f1 ff ff       	call   801118 <fd_alloc>
  801fb2:	89 c3                	mov    %eax,%ebx
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	78 43                	js     801ffe <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fbb:	83 ec 04             	sub    $0x4,%esp
  801fbe:	68 07 04 00 00       	push   $0x407
  801fc3:	ff 75 f4             	push   -0xc(%ebp)
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 d2 ee ff ff       	call   800e9f <sys_page_alloc>
  801fcd:	89 c3                	mov    %eax,%ebx
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 28                	js     801ffe <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd9:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801fdf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801feb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fee:	83 ec 0c             	sub    $0xc,%esp
  801ff1:	50                   	push   %eax
  801ff2:	e8 fa f0 ff ff       	call   8010f1 <fd2num>
  801ff7:	89 c3                	mov    %eax,%ebx
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	eb 0c                	jmp    80200a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ffe:	83 ec 0c             	sub    $0xc,%esp
  802001:	56                   	push   %esi
  802002:	e8 e4 01 00 00       	call   8021eb <nsipc_close>
		return r;
  802007:	83 c4 10             	add    $0x10,%esp
}
  80200a:	89 d8                	mov    %ebx,%eax
  80200c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    

00802013 <accept>:
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	e8 4e ff ff ff       	call   801f6f <fd2sockid>
  802021:	85 c0                	test   %eax,%eax
  802023:	78 1b                	js     802040 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802025:	83 ec 04             	sub    $0x4,%esp
  802028:	ff 75 10             	push   0x10(%ebp)
  80202b:	ff 75 0c             	push   0xc(%ebp)
  80202e:	50                   	push   %eax
  80202f:	e8 0e 01 00 00       	call   802142 <nsipc_accept>
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	85 c0                	test   %eax,%eax
  802039:	78 05                	js     802040 <accept+0x2d>
	return alloc_sockfd(r);
  80203b:	e8 5f ff ff ff       	call   801f9f <alloc_sockfd>
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <bind>:
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802048:	8b 45 08             	mov    0x8(%ebp),%eax
  80204b:	e8 1f ff ff ff       	call   801f6f <fd2sockid>
  802050:	85 c0                	test   %eax,%eax
  802052:	78 12                	js     802066 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  802054:	83 ec 04             	sub    $0x4,%esp
  802057:	ff 75 10             	push   0x10(%ebp)
  80205a:	ff 75 0c             	push   0xc(%ebp)
  80205d:	50                   	push   %eax
  80205e:	e8 31 01 00 00       	call   802194 <nsipc_bind>
  802063:	83 c4 10             	add    $0x10,%esp
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <shutdown>:
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80206e:	8b 45 08             	mov    0x8(%ebp),%eax
  802071:	e8 f9 fe ff ff       	call   801f6f <fd2sockid>
  802076:	85 c0                	test   %eax,%eax
  802078:	78 0f                	js     802089 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80207a:	83 ec 08             	sub    $0x8,%esp
  80207d:	ff 75 0c             	push   0xc(%ebp)
  802080:	50                   	push   %eax
  802081:	e8 43 01 00 00       	call   8021c9 <nsipc_shutdown>
  802086:	83 c4 10             	add    $0x10,%esp
}
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <connect>:
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802091:	8b 45 08             	mov    0x8(%ebp),%eax
  802094:	e8 d6 fe ff ff       	call   801f6f <fd2sockid>
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 12                	js     8020af <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80209d:	83 ec 04             	sub    $0x4,%esp
  8020a0:	ff 75 10             	push   0x10(%ebp)
  8020a3:	ff 75 0c             	push   0xc(%ebp)
  8020a6:	50                   	push   %eax
  8020a7:	e8 59 01 00 00       	call   802205 <nsipc_connect>
  8020ac:	83 c4 10             	add    $0x10,%esp
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <listen>:
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ba:	e8 b0 fe ff ff       	call   801f6f <fd2sockid>
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	78 0f                	js     8020d2 <listen+0x21>
	return nsipc_listen(r, backlog);
  8020c3:	83 ec 08             	sub    $0x8,%esp
  8020c6:	ff 75 0c             	push   0xc(%ebp)
  8020c9:	50                   	push   %eax
  8020ca:	e8 6b 01 00 00       	call   80223a <nsipc_listen>
  8020cf:	83 c4 10             	add    $0x10,%esp
}
  8020d2:	c9                   	leave  
  8020d3:	c3                   	ret    

008020d4 <socket>:

int
socket(int domain, int type, int protocol)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020da:	ff 75 10             	push   0x10(%ebp)
  8020dd:	ff 75 0c             	push   0xc(%ebp)
  8020e0:	ff 75 08             	push   0x8(%ebp)
  8020e3:	e8 41 02 00 00       	call   802329 <nsipc_socket>
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	78 05                	js     8020f4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020ef:	e8 ab fe ff ff       	call   801f9f <alloc_sockfd>
}
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	53                   	push   %ebx
  8020fa:	83 ec 04             	sub    $0x4,%esp
  8020fd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020ff:	83 3d 00 b0 80 00 00 	cmpl   $0x0,0x80b000
  802106:	74 26                	je     80212e <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802108:	6a 07                	push   $0x7
  80210a:	68 00 a0 80 00       	push   $0x80a000
  80210f:	53                   	push   %ebx
  802110:	ff 35 00 b0 80 00    	push   0x80b000
  802116:	e8 38 06 00 00       	call   802753 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80211b:	83 c4 0c             	add    $0xc,%esp
  80211e:	6a 00                	push   $0x0
  802120:	6a 00                	push   $0x0
  802122:	6a 00                	push   $0x0
  802124:	e8 c3 05 00 00       	call   8026ec <ipc_recv>
}
  802129:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80212e:	83 ec 0c             	sub    $0xc,%esp
  802131:	6a 02                	push   $0x2
  802133:	e8 6f 06 00 00       	call   8027a7 <ipc_find_env>
  802138:	a3 00 b0 80 00       	mov    %eax,0x80b000
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	eb c6                	jmp    802108 <nsipc+0x12>

00802142 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	56                   	push   %esi
  802146:	53                   	push   %ebx
  802147:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80214a:	8b 45 08             	mov    0x8(%ebp),%eax
  80214d:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802152:	8b 06                	mov    (%esi),%eax
  802154:	a3 04 a0 80 00       	mov    %eax,0x80a004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802159:	b8 01 00 00 00       	mov    $0x1,%eax
  80215e:	e8 93 ff ff ff       	call   8020f6 <nsipc>
  802163:	89 c3                	mov    %eax,%ebx
  802165:	85 c0                	test   %eax,%eax
  802167:	79 09                	jns    802172 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  802169:	89 d8                	mov    %ebx,%eax
  80216b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802172:	83 ec 04             	sub    $0x4,%esp
  802175:	ff 35 10 a0 80 00    	push   0x80a010
  80217b:	68 00 a0 80 00       	push   $0x80a000
  802180:	ff 75 0c             	push   0xc(%ebp)
  802183:	e8 b1 ea ff ff       	call   800c39 <memmove>
		*addrlen = ret->ret_addrlen;
  802188:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80218d:	89 06                	mov    %eax,(%esi)
  80218f:	83 c4 10             	add    $0x10,%esp
	return r;
  802192:	eb d5                	jmp    802169 <nsipc_accept+0x27>

00802194 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	53                   	push   %ebx
  802198:	83 ec 08             	sub    $0x8,%esp
  80219b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80219e:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a1:	a3 00 a0 80 00       	mov    %eax,0x80a000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021a6:	53                   	push   %ebx
  8021a7:	ff 75 0c             	push   0xc(%ebp)
  8021aa:	68 04 a0 80 00       	push   $0x80a004
  8021af:	e8 85 ea ff ff       	call   800c39 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021b4:	89 1d 14 a0 80 00    	mov    %ebx,0x80a014
	return nsipc(NSREQ_BIND);
  8021ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8021bf:	e8 32 ff ff ff       	call   8020f6 <nsipc>
}
  8021c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c7:	c9                   	leave  
  8021c8:	c3                   	ret    

008021c9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.shutdown.req_how = how;
  8021d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021da:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return nsipc(NSREQ_SHUTDOWN);
  8021df:	b8 03 00 00 00       	mov    $0x3,%eax
  8021e4:	e8 0d ff ff ff       	call   8020f6 <nsipc>
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <nsipc_close>:

int
nsipc_close(int s)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f4:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return nsipc(NSREQ_CLOSE);
  8021f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8021fe:	e8 f3 fe ff ff       	call   8020f6 <nsipc>
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	53                   	push   %ebx
  802209:	83 ec 08             	sub    $0x8,%esp
  80220c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80220f:	8b 45 08             	mov    0x8(%ebp),%eax
  802212:	a3 00 a0 80 00       	mov    %eax,0x80a000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802217:	53                   	push   %ebx
  802218:	ff 75 0c             	push   0xc(%ebp)
  80221b:	68 04 a0 80 00       	push   $0x80a004
  802220:	e8 14 ea ff ff       	call   800c39 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802225:	89 1d 14 a0 80 00    	mov    %ebx,0x80a014
	return nsipc(NSREQ_CONNECT);
  80222b:	b8 05 00 00 00       	mov    $0x5,%eax
  802230:	e8 c1 fe ff ff       	call   8020f6 <nsipc>
}
  802235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802238:	c9                   	leave  
  802239:	c3                   	ret    

0080223a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802240:	8b 45 08             	mov    0x8(%ebp),%eax
  802243:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.listen.req_backlog = backlog;
  802248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224b:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return nsipc(NSREQ_LISTEN);
  802250:	b8 06 00 00 00       	mov    $0x6,%eax
  802255:	e8 9c fe ff ff       	call   8020f6 <nsipc>
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802264:	8b 45 08             	mov    0x8(%ebp),%eax
  802267:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.recv.req_len = len;
  80226c:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	nsipcbuf.recv.req_flags = flags;
  802272:	8b 45 14             	mov    0x14(%ebp),%eax
  802275:	a3 08 a0 80 00       	mov    %eax,0x80a008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80227a:	b8 07 00 00 00       	mov    $0x7,%eax
  80227f:	e8 72 fe ff ff       	call   8020f6 <nsipc>
  802284:	89 c3                	mov    %eax,%ebx
  802286:	85 c0                	test   %eax,%eax
  802288:	78 22                	js     8022ac <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  80228a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80228f:	39 c6                	cmp    %eax,%esi
  802291:	0f 4e c6             	cmovle %esi,%eax
  802294:	39 c3                	cmp    %eax,%ebx
  802296:	7f 1d                	jg     8022b5 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802298:	83 ec 04             	sub    $0x4,%esp
  80229b:	53                   	push   %ebx
  80229c:	68 00 a0 80 00       	push   $0x80a000
  8022a1:	ff 75 0c             	push   0xc(%ebp)
  8022a4:	e8 90 e9 ff ff       	call   800c39 <memmove>
  8022a9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8022b5:	68 8e 30 80 00       	push   $0x80308e
  8022ba:	68 a3 2f 80 00       	push   $0x802fa3
  8022bf:	6a 62                	push   $0x62
  8022c1:	68 a3 30 80 00       	push   $0x8030a3
  8022c6:	e8 23 e1 ff ff       	call   8003ee <_panic>

008022cb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	53                   	push   %ebx
  8022cf:	83 ec 04             	sub    $0x4,%esp
  8022d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d8:	a3 00 a0 80 00       	mov    %eax,0x80a000
	assert(size < 1600);
  8022dd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022e3:	7f 2e                	jg     802313 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022e5:	83 ec 04             	sub    $0x4,%esp
  8022e8:	53                   	push   %ebx
  8022e9:	ff 75 0c             	push   0xc(%ebp)
  8022ec:	68 0c a0 80 00       	push   $0x80a00c
  8022f1:	e8 43 e9 ff ff       	call   800c39 <memmove>
	nsipcbuf.send.req_size = size;
  8022f6:	89 1d 04 a0 80 00    	mov    %ebx,0x80a004
	nsipcbuf.send.req_flags = flags;
  8022fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ff:	a3 08 a0 80 00       	mov    %eax,0x80a008
	return nsipc(NSREQ_SEND);
  802304:	b8 08 00 00 00       	mov    $0x8,%eax
  802309:	e8 e8 fd ff ff       	call   8020f6 <nsipc>
}
  80230e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802311:	c9                   	leave  
  802312:	c3                   	ret    
	assert(size < 1600);
  802313:	68 af 30 80 00       	push   $0x8030af
  802318:	68 a3 2f 80 00       	push   $0x802fa3
  80231d:	6a 6d                	push   $0x6d
  80231f:	68 a3 30 80 00       	push   $0x8030a3
  802324:	e8 c5 e0 ff ff       	call   8003ee <_panic>

00802329 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80232f:	8b 45 08             	mov    0x8(%ebp),%eax
  802332:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.socket.req_type = type;
  802337:	8b 45 0c             	mov    0xc(%ebp),%eax
  80233a:	a3 04 a0 80 00       	mov    %eax,0x80a004
	nsipcbuf.socket.req_protocol = protocol;
  80233f:	8b 45 10             	mov    0x10(%ebp),%eax
  802342:	a3 08 a0 80 00       	mov    %eax,0x80a008
	return nsipc(NSREQ_SOCKET);
  802347:	b8 09 00 00 00       	mov    $0x9,%eax
  80234c:	e8 a5 fd ff ff       	call   8020f6 <nsipc>
}
  802351:	c9                   	leave  
  802352:	c3                   	ret    

00802353 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	56                   	push   %esi
  802357:	53                   	push   %ebx
  802358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80235b:	83 ec 0c             	sub    $0xc,%esp
  80235e:	ff 75 08             	push   0x8(%ebp)
  802361:	e8 9b ed ff ff       	call   801101 <fd2data>
  802366:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802368:	83 c4 08             	add    $0x8,%esp
  80236b:	68 bb 30 80 00       	push   $0x8030bb
  802370:	53                   	push   %ebx
  802371:	e8 2d e7 ff ff       	call   800aa3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802376:	8b 46 04             	mov    0x4(%esi),%eax
  802379:	2b 06                	sub    (%esi),%eax
  80237b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802381:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802388:	00 00 00 
	stat->st_dev = &devpipe;
  80238b:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  802392:	57 80 00 
	return 0;
}
  802395:	b8 00 00 00 00       	mov    $0x0,%eax
  80239a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80239d:	5b                   	pop    %ebx
  80239e:	5e                   	pop    %esi
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    

008023a1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	53                   	push   %ebx
  8023a5:	83 ec 0c             	sub    $0xc,%esp
  8023a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023ab:	53                   	push   %ebx
  8023ac:	6a 00                	push   $0x0
  8023ae:	e8 71 eb ff ff       	call   800f24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023b3:	89 1c 24             	mov    %ebx,(%esp)
  8023b6:	e8 46 ed ff ff       	call   801101 <fd2data>
  8023bb:	83 c4 08             	add    $0x8,%esp
  8023be:	50                   	push   %eax
  8023bf:	6a 00                	push   $0x0
  8023c1:	e8 5e eb ff ff       	call   800f24 <sys_page_unmap>
}
  8023c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c9:	c9                   	leave  
  8023ca:	c3                   	ret    

008023cb <_pipeisclosed>:
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	57                   	push   %edi
  8023cf:	56                   	push   %esi
  8023d0:	53                   	push   %ebx
  8023d1:	83 ec 1c             	sub    $0x1c,%esp
  8023d4:	89 c7                	mov    %eax,%edi
  8023d6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8023d8:	a1 70 77 80 00       	mov    0x807770,%eax
  8023dd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023e0:	83 ec 0c             	sub    $0xc,%esp
  8023e3:	57                   	push   %edi
  8023e4:	e8 f7 03 00 00       	call   8027e0 <pageref>
  8023e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8023ec:	89 34 24             	mov    %esi,(%esp)
  8023ef:	e8 ec 03 00 00       	call   8027e0 <pageref>
		nn = thisenv->env_runs;
  8023f4:	8b 15 70 77 80 00    	mov    0x807770,%edx
  8023fa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	39 cb                	cmp    %ecx,%ebx
  802402:	74 1b                	je     80241f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802404:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802407:	75 cf                	jne    8023d8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802409:	8b 42 58             	mov    0x58(%edx),%eax
  80240c:	6a 01                	push   $0x1
  80240e:	50                   	push   %eax
  80240f:	53                   	push   %ebx
  802410:	68 c2 30 80 00       	push   $0x8030c2
  802415:	e8 af e0 ff ff       	call   8004c9 <cprintf>
  80241a:	83 c4 10             	add    $0x10,%esp
  80241d:	eb b9                	jmp    8023d8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80241f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802422:	0f 94 c0             	sete   %al
  802425:	0f b6 c0             	movzbl %al,%eax
}
  802428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80242b:	5b                   	pop    %ebx
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <devpipe_write>:
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	57                   	push   %edi
  802434:	56                   	push   %esi
  802435:	53                   	push   %ebx
  802436:	83 ec 28             	sub    $0x28,%esp
  802439:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80243c:	56                   	push   %esi
  80243d:	e8 bf ec ff ff       	call   801101 <fd2data>
  802442:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802444:	83 c4 10             	add    $0x10,%esp
  802447:	bf 00 00 00 00       	mov    $0x0,%edi
  80244c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80244f:	75 09                	jne    80245a <devpipe_write+0x2a>
	return i;
  802451:	89 f8                	mov    %edi,%eax
  802453:	eb 23                	jmp    802478 <devpipe_write+0x48>
			sys_yield();
  802455:	e8 26 ea ff ff       	call   800e80 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80245a:	8b 43 04             	mov    0x4(%ebx),%eax
  80245d:	8b 0b                	mov    (%ebx),%ecx
  80245f:	8d 51 20             	lea    0x20(%ecx),%edx
  802462:	39 d0                	cmp    %edx,%eax
  802464:	72 1a                	jb     802480 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802466:	89 da                	mov    %ebx,%edx
  802468:	89 f0                	mov    %esi,%eax
  80246a:	e8 5c ff ff ff       	call   8023cb <_pipeisclosed>
  80246f:	85 c0                	test   %eax,%eax
  802471:	74 e2                	je     802455 <devpipe_write+0x25>
				return 0;
  802473:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80247b:	5b                   	pop    %ebx
  80247c:	5e                   	pop    %esi
  80247d:	5f                   	pop    %edi
  80247e:	5d                   	pop    %ebp
  80247f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802480:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802483:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802487:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80248a:	89 c2                	mov    %eax,%edx
  80248c:	c1 fa 1f             	sar    $0x1f,%edx
  80248f:	89 d1                	mov    %edx,%ecx
  802491:	c1 e9 1b             	shr    $0x1b,%ecx
  802494:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802497:	83 e2 1f             	and    $0x1f,%edx
  80249a:	29 ca                	sub    %ecx,%edx
  80249c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8024a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024a4:	83 c0 01             	add    $0x1,%eax
  8024a7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8024aa:	83 c7 01             	add    $0x1,%edi
  8024ad:	eb 9d                	jmp    80244c <devpipe_write+0x1c>

008024af <devpipe_read>:
{
  8024af:	55                   	push   %ebp
  8024b0:	89 e5                	mov    %esp,%ebp
  8024b2:	57                   	push   %edi
  8024b3:	56                   	push   %esi
  8024b4:	53                   	push   %ebx
  8024b5:	83 ec 18             	sub    $0x18,%esp
  8024b8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8024bb:	57                   	push   %edi
  8024bc:	e8 40 ec ff ff       	call   801101 <fd2data>
  8024c1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8024c3:	83 c4 10             	add    $0x10,%esp
  8024c6:	be 00 00 00 00       	mov    $0x0,%esi
  8024cb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024ce:	75 13                	jne    8024e3 <devpipe_read+0x34>
	return i;
  8024d0:	89 f0                	mov    %esi,%eax
  8024d2:	eb 02                	jmp    8024d6 <devpipe_read+0x27>
				return i;
  8024d4:	89 f0                	mov    %esi,%eax
}
  8024d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d9:	5b                   	pop    %ebx
  8024da:	5e                   	pop    %esi
  8024db:	5f                   	pop    %edi
  8024dc:	5d                   	pop    %ebp
  8024dd:	c3                   	ret    
			sys_yield();
  8024de:	e8 9d e9 ff ff       	call   800e80 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8024e3:	8b 03                	mov    (%ebx),%eax
  8024e5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024e8:	75 18                	jne    802502 <devpipe_read+0x53>
			if (i > 0)
  8024ea:	85 f6                	test   %esi,%esi
  8024ec:	75 e6                	jne    8024d4 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8024ee:	89 da                	mov    %ebx,%edx
  8024f0:	89 f8                	mov    %edi,%eax
  8024f2:	e8 d4 fe ff ff       	call   8023cb <_pipeisclosed>
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	74 e3                	je     8024de <devpipe_read+0x2f>
				return 0;
  8024fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802500:	eb d4                	jmp    8024d6 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802502:	99                   	cltd   
  802503:	c1 ea 1b             	shr    $0x1b,%edx
  802506:	01 d0                	add    %edx,%eax
  802508:	83 e0 1f             	and    $0x1f,%eax
  80250b:	29 d0                	sub    %edx,%eax
  80250d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802515:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802518:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80251b:	83 c6 01             	add    $0x1,%esi
  80251e:	eb ab                	jmp    8024cb <devpipe_read+0x1c>

00802520 <pipe>:
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	56                   	push   %esi
  802524:	53                   	push   %ebx
  802525:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80252b:	50                   	push   %eax
  80252c:	e8 e7 eb ff ff       	call   801118 <fd_alloc>
  802531:	89 c3                	mov    %eax,%ebx
  802533:	83 c4 10             	add    $0x10,%esp
  802536:	85 c0                	test   %eax,%eax
  802538:	0f 88 23 01 00 00    	js     802661 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80253e:	83 ec 04             	sub    $0x4,%esp
  802541:	68 07 04 00 00       	push   $0x407
  802546:	ff 75 f4             	push   -0xc(%ebp)
  802549:	6a 00                	push   $0x0
  80254b:	e8 4f e9 ff ff       	call   800e9f <sys_page_alloc>
  802550:	89 c3                	mov    %eax,%ebx
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	85 c0                	test   %eax,%eax
  802557:	0f 88 04 01 00 00    	js     802661 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80255d:	83 ec 0c             	sub    $0xc,%esp
  802560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802563:	50                   	push   %eax
  802564:	e8 af eb ff ff       	call   801118 <fd_alloc>
  802569:	89 c3                	mov    %eax,%ebx
  80256b:	83 c4 10             	add    $0x10,%esp
  80256e:	85 c0                	test   %eax,%eax
  802570:	0f 88 db 00 00 00    	js     802651 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802576:	83 ec 04             	sub    $0x4,%esp
  802579:	68 07 04 00 00       	push   $0x407
  80257e:	ff 75 f0             	push   -0x10(%ebp)
  802581:	6a 00                	push   $0x0
  802583:	e8 17 e9 ff ff       	call   800e9f <sys_page_alloc>
  802588:	89 c3                	mov    %eax,%ebx
  80258a:	83 c4 10             	add    $0x10,%esp
  80258d:	85 c0                	test   %eax,%eax
  80258f:	0f 88 bc 00 00 00    	js     802651 <pipe+0x131>
	va = fd2data(fd0);
  802595:	83 ec 0c             	sub    $0xc,%esp
  802598:	ff 75 f4             	push   -0xc(%ebp)
  80259b:	e8 61 eb ff ff       	call   801101 <fd2data>
  8025a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025a2:	83 c4 0c             	add    $0xc,%esp
  8025a5:	68 07 04 00 00       	push   $0x407
  8025aa:	50                   	push   %eax
  8025ab:	6a 00                	push   $0x0
  8025ad:	e8 ed e8 ff ff       	call   800e9f <sys_page_alloc>
  8025b2:	89 c3                	mov    %eax,%ebx
  8025b4:	83 c4 10             	add    $0x10,%esp
  8025b7:	85 c0                	test   %eax,%eax
  8025b9:	0f 88 82 00 00 00    	js     802641 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025bf:	83 ec 0c             	sub    $0xc,%esp
  8025c2:	ff 75 f0             	push   -0x10(%ebp)
  8025c5:	e8 37 eb ff ff       	call   801101 <fd2data>
  8025ca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025d1:	50                   	push   %eax
  8025d2:	6a 00                	push   $0x0
  8025d4:	56                   	push   %esi
  8025d5:	6a 00                	push   $0x0
  8025d7:	e8 06 e9 ff ff       	call   800ee2 <sys_page_map>
  8025dc:	89 c3                	mov    %eax,%ebx
  8025de:	83 c4 20             	add    $0x20,%esp
  8025e1:	85 c0                	test   %eax,%eax
  8025e3:	78 4e                	js     802633 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8025e5:	a1 c8 57 80 00       	mov    0x8057c8,%eax
  8025ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025ed:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8025ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8025f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025fc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8025fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802601:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802608:	83 ec 0c             	sub    $0xc,%esp
  80260b:	ff 75 f4             	push   -0xc(%ebp)
  80260e:	e8 de ea ff ff       	call   8010f1 <fd2num>
  802613:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802616:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802618:	83 c4 04             	add    $0x4,%esp
  80261b:	ff 75 f0             	push   -0x10(%ebp)
  80261e:	e8 ce ea ff ff       	call   8010f1 <fd2num>
  802623:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802626:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802629:	83 c4 10             	add    $0x10,%esp
  80262c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802631:	eb 2e                	jmp    802661 <pipe+0x141>
	sys_page_unmap(0, va);
  802633:	83 ec 08             	sub    $0x8,%esp
  802636:	56                   	push   %esi
  802637:	6a 00                	push   $0x0
  802639:	e8 e6 e8 ff ff       	call   800f24 <sys_page_unmap>
  80263e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802641:	83 ec 08             	sub    $0x8,%esp
  802644:	ff 75 f0             	push   -0x10(%ebp)
  802647:	6a 00                	push   $0x0
  802649:	e8 d6 e8 ff ff       	call   800f24 <sys_page_unmap>
  80264e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802651:	83 ec 08             	sub    $0x8,%esp
  802654:	ff 75 f4             	push   -0xc(%ebp)
  802657:	6a 00                	push   $0x0
  802659:	e8 c6 e8 ff ff       	call   800f24 <sys_page_unmap>
  80265e:	83 c4 10             	add    $0x10,%esp
}
  802661:	89 d8                	mov    %ebx,%eax
  802663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802666:	5b                   	pop    %ebx
  802667:	5e                   	pop    %esi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    

0080266a <pipeisclosed>:
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802673:	50                   	push   %eax
  802674:	ff 75 08             	push   0x8(%ebp)
  802677:	e8 ec ea ff ff       	call   801168 <fd_lookup>
  80267c:	83 c4 10             	add    $0x10,%esp
  80267f:	85 c0                	test   %eax,%eax
  802681:	78 18                	js     80269b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802683:	83 ec 0c             	sub    $0xc,%esp
  802686:	ff 75 f4             	push   -0xc(%ebp)
  802689:	e8 73 ea ff ff       	call   801101 <fd2data>
  80268e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802690:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802693:	e8 33 fd ff ff       	call   8023cb <_pipeisclosed>
  802698:	83 c4 10             	add    $0x10,%esp
}
  80269b:	c9                   	leave  
  80269c:	c3                   	ret    

0080269d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80269d:	55                   	push   %ebp
  80269e:	89 e5                	mov    %esp,%ebp
  8026a0:	56                   	push   %esi
  8026a1:	53                   	push   %ebx
  8026a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026a5:	85 f6                	test   %esi,%esi
  8026a7:	74 13                	je     8026bc <wait+0x1f>
	e = &envs[ENVX(envid)];
  8026a9:	89 f3                	mov    %esi,%ebx
  8026ab:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026b1:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026b4:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026ba:	eb 1b                	jmp    8026d7 <wait+0x3a>
	assert(envid != 0);
  8026bc:	68 da 30 80 00       	push   $0x8030da
  8026c1:	68 a3 2f 80 00       	push   $0x802fa3
  8026c6:	6a 09                	push   $0x9
  8026c8:	68 e5 30 80 00       	push   $0x8030e5
  8026cd:	e8 1c dd ff ff       	call   8003ee <_panic>
		sys_yield();
  8026d2:	e8 a9 e7 ff ff       	call   800e80 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026d7:	8b 43 48             	mov    0x48(%ebx),%eax
  8026da:	39 f0                	cmp    %esi,%eax
  8026dc:	75 07                	jne    8026e5 <wait+0x48>
  8026de:	8b 43 54             	mov    0x54(%ebx),%eax
  8026e1:	85 c0                	test   %eax,%eax
  8026e3:	75 ed                	jne    8026d2 <wait+0x35>
}
  8026e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026e8:	5b                   	pop    %ebx
  8026e9:	5e                   	pop    %esi
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    

008026ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
  8026ef:	56                   	push   %esi
  8026f0:	53                   	push   %ebx
  8026f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8026f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8026fa:	85 c0                	test   %eax,%eax
  8026fc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802701:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802704:	83 ec 0c             	sub    $0xc,%esp
  802707:	50                   	push   %eax
  802708:	e8 42 e9 ff ff       	call   80104f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80270d:	83 c4 10             	add    $0x10,%esp
  802710:	85 f6                	test   %esi,%esi
  802712:	74 14                	je     802728 <ipc_recv+0x3c>
  802714:	ba 00 00 00 00       	mov    $0x0,%edx
  802719:	85 c0                	test   %eax,%eax
  80271b:	78 09                	js     802726 <ipc_recv+0x3a>
  80271d:	8b 15 70 77 80 00    	mov    0x807770,%edx
  802723:	8b 52 74             	mov    0x74(%edx),%edx
  802726:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802728:	85 db                	test   %ebx,%ebx
  80272a:	74 14                	je     802740 <ipc_recv+0x54>
  80272c:	ba 00 00 00 00       	mov    $0x0,%edx
  802731:	85 c0                	test   %eax,%eax
  802733:	78 09                	js     80273e <ipc_recv+0x52>
  802735:	8b 15 70 77 80 00    	mov    0x807770,%edx
  80273b:	8b 52 78             	mov    0x78(%edx),%edx
  80273e:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802740:	85 c0                	test   %eax,%eax
  802742:	78 08                	js     80274c <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802744:	a1 70 77 80 00       	mov    0x807770,%eax
  802749:	8b 40 70             	mov    0x70(%eax),%eax
}
  80274c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5d                   	pop    %ebp
  802752:	c3                   	ret    

00802753 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802753:	55                   	push   %ebp
  802754:	89 e5                	mov    %esp,%ebp
  802756:	57                   	push   %edi
  802757:	56                   	push   %esi
  802758:	53                   	push   %ebx
  802759:	83 ec 0c             	sub    $0xc,%esp
  80275c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80275f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802762:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802765:	85 db                	test   %ebx,%ebx
  802767:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80276c:	0f 44 d8             	cmove  %eax,%ebx
  80276f:	eb 05                	jmp    802776 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802771:	e8 0a e7 ff ff       	call   800e80 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802776:	ff 75 14             	push   0x14(%ebp)
  802779:	53                   	push   %ebx
  80277a:	56                   	push   %esi
  80277b:	57                   	push   %edi
  80277c:	e8 ab e8 ff ff       	call   80102c <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802781:	83 c4 10             	add    $0x10,%esp
  802784:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802787:	74 e8                	je     802771 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802789:	85 c0                	test   %eax,%eax
  80278b:	78 08                	js     802795 <ipc_send+0x42>
	}while (r<0);

}
  80278d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802790:	5b                   	pop    %ebx
  802791:	5e                   	pop    %esi
  802792:	5f                   	pop    %edi
  802793:	5d                   	pop    %ebp
  802794:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802795:	50                   	push   %eax
  802796:	68 f0 30 80 00       	push   $0x8030f0
  80279b:	6a 3d                	push   $0x3d
  80279d:	68 04 31 80 00       	push   $0x803104
  8027a2:	e8 47 dc ff ff       	call   8003ee <_panic>

008027a7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027a7:	55                   	push   %ebp
  8027a8:	89 e5                	mov    %esp,%ebp
  8027aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027ad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027b2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027b5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027bb:	8b 52 50             	mov    0x50(%edx),%edx
  8027be:	39 ca                	cmp    %ecx,%edx
  8027c0:	74 11                	je     8027d3 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8027c2:	83 c0 01             	add    $0x1,%eax
  8027c5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027ca:	75 e6                	jne    8027b2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8027cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8027d1:	eb 0b                	jmp    8027de <ipc_find_env+0x37>
			return envs[i].env_id;
  8027d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027db:	8b 40 48             	mov    0x48(%eax),%eax
}
  8027de:	5d                   	pop    %ebp
  8027df:	c3                   	ret    

008027e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027e0:	55                   	push   %ebp
  8027e1:	89 e5                	mov    %esp,%ebp
  8027e3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027e6:	89 c2                	mov    %eax,%edx
  8027e8:	c1 ea 16             	shr    $0x16,%edx
  8027eb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8027f2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8027f7:	f6 c1 01             	test   $0x1,%cl
  8027fa:	74 1c                	je     802818 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8027fc:	c1 e8 0c             	shr    $0xc,%eax
  8027ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802806:	a8 01                	test   $0x1,%al
  802808:	74 0e                	je     802818 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80280a:	c1 e8 0c             	shr    $0xc,%eax
  80280d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802814:	ef 
  802815:	0f b7 d2             	movzwl %dx,%edx
}
  802818:	89 d0                	mov    %edx,%eax
  80281a:	5d                   	pop    %ebp
  80281b:	c3                   	ret    
  80281c:	66 90                	xchg   %ax,%ax
  80281e:	66 90                	xchg   %ax,%ax

00802820 <__udivdi3>:
  802820:	f3 0f 1e fb          	endbr32 
  802824:	55                   	push   %ebp
  802825:	57                   	push   %edi
  802826:	56                   	push   %esi
  802827:	53                   	push   %ebx
  802828:	83 ec 1c             	sub    $0x1c,%esp
  80282b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80282f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802833:	8b 74 24 34          	mov    0x34(%esp),%esi
  802837:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80283b:	85 c0                	test   %eax,%eax
  80283d:	75 19                	jne    802858 <__udivdi3+0x38>
  80283f:	39 f3                	cmp    %esi,%ebx
  802841:	76 4d                	jbe    802890 <__udivdi3+0x70>
  802843:	31 ff                	xor    %edi,%edi
  802845:	89 e8                	mov    %ebp,%eax
  802847:	89 f2                	mov    %esi,%edx
  802849:	f7 f3                	div    %ebx
  80284b:	89 fa                	mov    %edi,%edx
  80284d:	83 c4 1c             	add    $0x1c,%esp
  802850:	5b                   	pop    %ebx
  802851:	5e                   	pop    %esi
  802852:	5f                   	pop    %edi
  802853:	5d                   	pop    %ebp
  802854:	c3                   	ret    
  802855:	8d 76 00             	lea    0x0(%esi),%esi
  802858:	39 f0                	cmp    %esi,%eax
  80285a:	76 14                	jbe    802870 <__udivdi3+0x50>
  80285c:	31 ff                	xor    %edi,%edi
  80285e:	31 c0                	xor    %eax,%eax
  802860:	89 fa                	mov    %edi,%edx
  802862:	83 c4 1c             	add    $0x1c,%esp
  802865:	5b                   	pop    %ebx
  802866:	5e                   	pop    %esi
  802867:	5f                   	pop    %edi
  802868:	5d                   	pop    %ebp
  802869:	c3                   	ret    
  80286a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802870:	0f bd f8             	bsr    %eax,%edi
  802873:	83 f7 1f             	xor    $0x1f,%edi
  802876:	75 48                	jne    8028c0 <__udivdi3+0xa0>
  802878:	39 f0                	cmp    %esi,%eax
  80287a:	72 06                	jb     802882 <__udivdi3+0x62>
  80287c:	31 c0                	xor    %eax,%eax
  80287e:	39 eb                	cmp    %ebp,%ebx
  802880:	77 de                	ja     802860 <__udivdi3+0x40>
  802882:	b8 01 00 00 00       	mov    $0x1,%eax
  802887:	eb d7                	jmp    802860 <__udivdi3+0x40>
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d9                	mov    %ebx,%ecx
  802892:	85 db                	test   %ebx,%ebx
  802894:	75 0b                	jne    8028a1 <__udivdi3+0x81>
  802896:	b8 01 00 00 00       	mov    $0x1,%eax
  80289b:	31 d2                	xor    %edx,%edx
  80289d:	f7 f3                	div    %ebx
  80289f:	89 c1                	mov    %eax,%ecx
  8028a1:	31 d2                	xor    %edx,%edx
  8028a3:	89 f0                	mov    %esi,%eax
  8028a5:	f7 f1                	div    %ecx
  8028a7:	89 c6                	mov    %eax,%esi
  8028a9:	89 e8                	mov    %ebp,%eax
  8028ab:	89 f7                	mov    %esi,%edi
  8028ad:	f7 f1                	div    %ecx
  8028af:	89 fa                	mov    %edi,%edx
  8028b1:	83 c4 1c             	add    $0x1c,%esp
  8028b4:	5b                   	pop    %ebx
  8028b5:	5e                   	pop    %esi
  8028b6:	5f                   	pop    %edi
  8028b7:	5d                   	pop    %ebp
  8028b8:	c3                   	ret    
  8028b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028c0:	89 f9                	mov    %edi,%ecx
  8028c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8028c7:	29 fa                	sub    %edi,%edx
  8028c9:	d3 e0                	shl    %cl,%eax
  8028cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028cf:	89 d1                	mov    %edx,%ecx
  8028d1:	89 d8                	mov    %ebx,%eax
  8028d3:	d3 e8                	shr    %cl,%eax
  8028d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8028d9:	09 c1                	or     %eax,%ecx
  8028db:	89 f0                	mov    %esi,%eax
  8028dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028e1:	89 f9                	mov    %edi,%ecx
  8028e3:	d3 e3                	shl    %cl,%ebx
  8028e5:	89 d1                	mov    %edx,%ecx
  8028e7:	d3 e8                	shr    %cl,%eax
  8028e9:	89 f9                	mov    %edi,%ecx
  8028eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8028ef:	89 eb                	mov    %ebp,%ebx
  8028f1:	d3 e6                	shl    %cl,%esi
  8028f3:	89 d1                	mov    %edx,%ecx
  8028f5:	d3 eb                	shr    %cl,%ebx
  8028f7:	09 f3                	or     %esi,%ebx
  8028f9:	89 c6                	mov    %eax,%esi
  8028fb:	89 f2                	mov    %esi,%edx
  8028fd:	89 d8                	mov    %ebx,%eax
  8028ff:	f7 74 24 08          	divl   0x8(%esp)
  802903:	89 d6                	mov    %edx,%esi
  802905:	89 c3                	mov    %eax,%ebx
  802907:	f7 64 24 0c          	mull   0xc(%esp)
  80290b:	39 d6                	cmp    %edx,%esi
  80290d:	72 19                	jb     802928 <__udivdi3+0x108>
  80290f:	89 f9                	mov    %edi,%ecx
  802911:	d3 e5                	shl    %cl,%ebp
  802913:	39 c5                	cmp    %eax,%ebp
  802915:	73 04                	jae    80291b <__udivdi3+0xfb>
  802917:	39 d6                	cmp    %edx,%esi
  802919:	74 0d                	je     802928 <__udivdi3+0x108>
  80291b:	89 d8                	mov    %ebx,%eax
  80291d:	31 ff                	xor    %edi,%edi
  80291f:	e9 3c ff ff ff       	jmp    802860 <__udivdi3+0x40>
  802924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802928:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80292b:	31 ff                	xor    %edi,%edi
  80292d:	e9 2e ff ff ff       	jmp    802860 <__udivdi3+0x40>
  802932:	66 90                	xchg   %ax,%ax
  802934:	66 90                	xchg   %ax,%ax
  802936:	66 90                	xchg   %ax,%ax
  802938:	66 90                	xchg   %ax,%ax
  80293a:	66 90                	xchg   %ax,%ax
  80293c:	66 90                	xchg   %ax,%ax
  80293e:	66 90                	xchg   %ax,%ax

00802940 <__umoddi3>:
  802940:	f3 0f 1e fb          	endbr32 
  802944:	55                   	push   %ebp
  802945:	57                   	push   %edi
  802946:	56                   	push   %esi
  802947:	53                   	push   %ebx
  802948:	83 ec 1c             	sub    $0x1c,%esp
  80294b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80294f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802953:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802957:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80295b:	89 f0                	mov    %esi,%eax
  80295d:	89 da                	mov    %ebx,%edx
  80295f:	85 ff                	test   %edi,%edi
  802961:	75 15                	jne    802978 <__umoddi3+0x38>
  802963:	39 dd                	cmp    %ebx,%ebp
  802965:	76 39                	jbe    8029a0 <__umoddi3+0x60>
  802967:	f7 f5                	div    %ebp
  802969:	89 d0                	mov    %edx,%eax
  80296b:	31 d2                	xor    %edx,%edx
  80296d:	83 c4 1c             	add    $0x1c,%esp
  802970:	5b                   	pop    %ebx
  802971:	5e                   	pop    %esi
  802972:	5f                   	pop    %edi
  802973:	5d                   	pop    %ebp
  802974:	c3                   	ret    
  802975:	8d 76 00             	lea    0x0(%esi),%esi
  802978:	39 df                	cmp    %ebx,%edi
  80297a:	77 f1                	ja     80296d <__umoddi3+0x2d>
  80297c:	0f bd cf             	bsr    %edi,%ecx
  80297f:	83 f1 1f             	xor    $0x1f,%ecx
  802982:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802986:	75 40                	jne    8029c8 <__umoddi3+0x88>
  802988:	39 df                	cmp    %ebx,%edi
  80298a:	72 04                	jb     802990 <__umoddi3+0x50>
  80298c:	39 f5                	cmp    %esi,%ebp
  80298e:	77 dd                	ja     80296d <__umoddi3+0x2d>
  802990:	89 da                	mov    %ebx,%edx
  802992:	89 f0                	mov    %esi,%eax
  802994:	29 e8                	sub    %ebp,%eax
  802996:	19 fa                	sbb    %edi,%edx
  802998:	eb d3                	jmp    80296d <__umoddi3+0x2d>
  80299a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a0:	89 e9                	mov    %ebp,%ecx
  8029a2:	85 ed                	test   %ebp,%ebp
  8029a4:	75 0b                	jne    8029b1 <__umoddi3+0x71>
  8029a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029ab:	31 d2                	xor    %edx,%edx
  8029ad:	f7 f5                	div    %ebp
  8029af:	89 c1                	mov    %eax,%ecx
  8029b1:	89 d8                	mov    %ebx,%eax
  8029b3:	31 d2                	xor    %edx,%edx
  8029b5:	f7 f1                	div    %ecx
  8029b7:	89 f0                	mov    %esi,%eax
  8029b9:	f7 f1                	div    %ecx
  8029bb:	89 d0                	mov    %edx,%eax
  8029bd:	31 d2                	xor    %edx,%edx
  8029bf:	eb ac                	jmp    80296d <__umoddi3+0x2d>
  8029c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8029d1:	29 c2                	sub    %eax,%edx
  8029d3:	89 c1                	mov    %eax,%ecx
  8029d5:	89 e8                	mov    %ebp,%eax
  8029d7:	d3 e7                	shl    %cl,%edi
  8029d9:	89 d1                	mov    %edx,%ecx
  8029db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8029df:	d3 e8                	shr    %cl,%eax
  8029e1:	89 c1                	mov    %eax,%ecx
  8029e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029e7:	09 f9                	or     %edi,%ecx
  8029e9:	89 df                	mov    %ebx,%edi
  8029eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029ef:	89 c1                	mov    %eax,%ecx
  8029f1:	d3 e5                	shl    %cl,%ebp
  8029f3:	89 d1                	mov    %edx,%ecx
  8029f5:	d3 ef                	shr    %cl,%edi
  8029f7:	89 c1                	mov    %eax,%ecx
  8029f9:	89 f0                	mov    %esi,%eax
  8029fb:	d3 e3                	shl    %cl,%ebx
  8029fd:	89 d1                	mov    %edx,%ecx
  8029ff:	89 fa                	mov    %edi,%edx
  802a01:	d3 e8                	shr    %cl,%eax
  802a03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a08:	09 d8                	or     %ebx,%eax
  802a0a:	f7 74 24 08          	divl   0x8(%esp)
  802a0e:	89 d3                	mov    %edx,%ebx
  802a10:	d3 e6                	shl    %cl,%esi
  802a12:	f7 e5                	mul    %ebp
  802a14:	89 c7                	mov    %eax,%edi
  802a16:	89 d1                	mov    %edx,%ecx
  802a18:	39 d3                	cmp    %edx,%ebx
  802a1a:	72 06                	jb     802a22 <__umoddi3+0xe2>
  802a1c:	75 0e                	jne    802a2c <__umoddi3+0xec>
  802a1e:	39 c6                	cmp    %eax,%esi
  802a20:	73 0a                	jae    802a2c <__umoddi3+0xec>
  802a22:	29 e8                	sub    %ebp,%eax
  802a24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802a28:	89 d1                	mov    %edx,%ecx
  802a2a:	89 c7                	mov    %eax,%edi
  802a2c:	89 f5                	mov    %esi,%ebp
  802a2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a32:	29 fd                	sub    %edi,%ebp
  802a34:	19 cb                	sbb    %ecx,%ebx
  802a36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802a3b:	89 d8                	mov    %ebx,%eax
  802a3d:	d3 e0                	shl    %cl,%eax
  802a3f:	89 f1                	mov    %esi,%ecx
  802a41:	d3 ed                	shr    %cl,%ebp
  802a43:	d3 eb                	shr    %cl,%ebx
  802a45:	09 e8                	or     %ebp,%eax
  802a47:	89 da                	mov    %ebx,%edx
  802a49:	83 c4 1c             	add    $0x1c,%esp
  802a4c:	5b                   	pop    %ebx
  802a4d:	5e                   	pop    %esi
  802a4e:	5f                   	pop    %edi
  802a4f:	5d                   	pop    %ebp
  802a50:	c3                   	ret    
