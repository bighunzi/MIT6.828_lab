
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
  80006f:	68 a0 25 80 00       	push   $0x8025a0
  800074:	e8 50 04 00 00       	call   8004c9 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800079:	83 c4 08             	add    $0x8,%esp
  80007c:	68 70 17 00 00       	push   $0x1770
  800081:	68 00 30 80 00       	push   $0x803000
  800086:	e8 a8 ff ff ff       	call   800033 <sum>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800093:	74 64                	je     8000f9 <umain+0x99>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800095:	83 ec 04             	sub    $0x4,%esp
  800098:	68 9e 98 0f 00       	push   $0xf989e
  80009d:	50                   	push   %eax
  80009e:	68 68 26 80 00       	push   $0x802668
  8000a3:	e8 21 04 00 00       	call   8004c9 <cprintf>
  8000a8:	83 c4 10             	add    $0x10,%esp
			x, want);
	else
		cprintf("init: data seems okay\n");
	if ((x = sum(bss, sizeof bss)) != 0)
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	68 70 17 00 00       	push   $0x1770
  8000b3:	68 00 50 80 00       	push   $0x805000
  8000b8:	e8 76 ff ff ff       	call   800033 <sum>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	74 47                	je     80010b <umain+0xab>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000c4:	83 ec 08             	sub    $0x8,%esp
  8000c7:	50                   	push   %eax
  8000c8:	68 a4 26 80 00       	push   $0x8026a4
  8000cd:	e8 f7 03 00 00       	call   8004c9 <cprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 dc 25 80 00       	push   $0x8025dc
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
  8000fc:	68 af 25 80 00       	push   $0x8025af
  800101:	e8 c3 03 00 00       	call   8004c9 <cprintf>
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	eb a0                	jmp    8000ab <umain+0x4b>
		cprintf("init: bss seems okay\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 c6 25 80 00       	push   $0x8025c6
  800113:	e8 b1 03 00 00       	call   8004c9 <cprintf>
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	eb b8                	jmp    8000d5 <umain+0x75>
		strcat(args, " '");
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 e8 25 80 00       	push   $0x8025e8
  800125:	56                   	push   %esi
  800126:	e8 9c 09 00 00       	call   800ac7 <strcat>
		strcat(args, argv[i]);
  80012b:	83 c4 08             	add    $0x8,%esp
  80012e:	ff 34 9f             	push   (%edi,%ebx,4)
  800131:	56                   	push   %esi
  800132:	e8 90 09 00 00       	call   800ac7 <strcat>
		strcat(args, "'");
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	68 e9 25 80 00       	push   $0x8025e9
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
  80015a:	68 eb 25 80 00       	push   $0x8025eb
  80015f:	e8 65 03 00 00       	call   8004c9 <cprintf>

	cprintf("init: running sh\n");
  800164:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  80016b:	e8 59 03 00 00       	call   8004c9 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800177:	e8 b3 10 00 00       	call   80122f <close>
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
  80018b:	68 1a 26 80 00       	push   $0x80261a
  800190:	6a 39                	push   $0x39
  800192:	68 0e 26 80 00       	push   $0x80260e
  800197:	e8 52 02 00 00       	call   8003ee <_panic>
		panic("opencons: %e", r);
  80019c:	50                   	push   %eax
  80019d:	68 01 26 80 00       	push   $0x802601
  8001a2:	6a 37                	push   $0x37
  8001a4:	68 0e 26 80 00       	push   $0x80260e
  8001a9:	e8 40 02 00 00       	call   8003ee <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 c7 10 00 00       	call   801281 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 23                	jns    8001e4 <umain+0x184>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 34 26 80 00       	push   $0x802634
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 0e 26 80 00       	push   $0x80260e
  8001ce:	e8 1b 02 00 00       	call   8003ee <_panic>
	while (1) {
		cprintf("init: starting sh\n");
		r = spawnl("/sh", "sh", (char*)0);
		if (r < 0) {
			cprintf("init: spawn sh: %e\n", r);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	50                   	push   %eax
  8001d7:	68 53 26 80 00       	push   $0x802653
  8001dc:	e8 e8 02 00 00       	call   8004c9 <cprintf>
			continue;
  8001e1:	83 c4 10             	add    $0x10,%esp
		cprintf("init: starting sh\n");
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	68 3c 26 80 00       	push   $0x80263c
  8001ec:	e8 d8 02 00 00       	call   8004c9 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001f1:	83 c4 0c             	add    $0xc,%esp
  8001f4:	6a 00                	push   $0x0
  8001f6:	68 50 26 80 00       	push   $0x802650
  8001fb:	68 4f 26 80 00       	push   $0x80264f
  800200:	e8 db 1b 00 00       	call   801de0 <spawnl>
		if (r < 0) {
  800205:	83 c4 10             	add    $0x10,%esp
  800208:	85 c0                	test   %eax,%eax
  80020a:	78 c7                	js     8001d3 <umain+0x173>
		}
		wait(r);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	e8 ba 1f 00 00       	call   8021cf <wait>
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
  800226:	68 d3 26 80 00       	push   $0x8026d3
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
  8002f5:	e8 71 10 00 00       	call   80136b <read>
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
  80031d:	e8 e5 0d 00 00       	call   801107 <fd_lookup>
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	85 c0                	test   %eax,%eax
  800327:	78 11                	js     80033a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80032c:	8b 15 70 47 80 00    	mov    0x804770,%edx
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
  800346:	e8 6c 0d 00 00       	call   8010b7 <fd_alloc>
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
  80036e:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800374:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800379:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	50                   	push   %eax
  800384:	e8 07 0d 00 00       	call   801090 <fd2num>
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
  8003ab:	a3 70 67 80 00       	mov    %eax,0x806770

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003b0:	85 db                	test   %ebx,%ebx
  8003b2:	7e 07                	jle    8003bb <libmain+0x2d>
		binaryname = argv[0];
  8003b4:	8b 06                	mov    (%esi),%eax
  8003b6:	a3 8c 47 80 00       	mov    %eax,0x80478c

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
  8003da:	e8 7d 0e 00 00       	call   80125c <close_all>
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
  8003f6:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  8003fc:	e8 60 0a 00 00       	call   800e61 <sys_getenvid>
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	ff 75 0c             	push   0xc(%ebp)
  800407:	ff 75 08             	push   0x8(%ebp)
  80040a:	56                   	push   %esi
  80040b:	50                   	push   %eax
  80040c:	68 ec 26 80 00       	push   $0x8026ec
  800411:	e8 b3 00 00 00       	call   8004c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800416:	83 c4 18             	add    $0x18,%esp
  800419:	53                   	push   %ebx
  80041a:	ff 75 10             	push   0x10(%ebp)
  80041d:	e8 56 00 00 00       	call   800478 <vcprintf>
	cprintf("\n");
  800422:	c7 04 24 d6 2b 80 00 	movl   $0x802bd6,(%esp)
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
  80052b:	e8 20 1e 00 00       	call   802350 <__udivdi3>
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
  800569:	e8 02 1f 00 00       	call   802470 <__umoddi3>
  80056e:	83 c4 14             	add    $0x14,%esp
  800571:	0f be 80 0f 27 80 00 	movsbl 0x80270f(%eax),%eax
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
  80062b:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
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
  8006f9:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	74 18                	je     80071c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800704:	52                   	push   %edx
  800705:	68 f1 2a 80 00       	push   $0x802af1
  80070a:	53                   	push   %ebx
  80070b:	56                   	push   %esi
  80070c:	e8 92 fe ff ff       	call   8005a3 <printfmt>
  800711:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800714:	89 7d 14             	mov    %edi,0x14(%ebp)
  800717:	e9 66 02 00 00       	jmp    800982 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80071c:	50                   	push   %eax
  80071d:	68 27 27 80 00       	push   $0x802727
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
  800744:	b8 20 27 80 00       	mov    $0x802720,%eax
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
  800e50:	68 1f 2a 80 00       	push   $0x802a1f
  800e55:	6a 2a                	push   $0x2a
  800e57:	68 3c 2a 80 00       	push   $0x802a3c
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
  800ed1:	68 1f 2a 80 00       	push   $0x802a1f
  800ed6:	6a 2a                	push   $0x2a
  800ed8:	68 3c 2a 80 00       	push   $0x802a3c
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
  800f13:	68 1f 2a 80 00       	push   $0x802a1f
  800f18:	6a 2a                	push   $0x2a
  800f1a:	68 3c 2a 80 00       	push   $0x802a3c
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
  800f55:	68 1f 2a 80 00       	push   $0x802a1f
  800f5a:	6a 2a                	push   $0x2a
  800f5c:	68 3c 2a 80 00       	push   $0x802a3c
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
  800f97:	68 1f 2a 80 00       	push   $0x802a1f
  800f9c:	6a 2a                	push   $0x2a
  800f9e:	68 3c 2a 80 00       	push   $0x802a3c
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
  800fd9:	68 1f 2a 80 00       	push   $0x802a1f
  800fde:	6a 2a                	push   $0x2a
  800fe0:	68 3c 2a 80 00       	push   $0x802a3c
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
  80101b:	68 1f 2a 80 00       	push   $0x802a1f
  801020:	6a 2a                	push   $0x2a
  801022:	68 3c 2a 80 00       	push   $0x802a3c
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
  80107f:	68 1f 2a 80 00       	push   $0x802a1f
  801084:	6a 2a                	push   $0x2a
  801086:	68 3c 2a 80 00       	push   $0x802a3c
  80108b:	e8 5e f3 ff ff       	call   8003ee <_panic>

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	c1 ea 16             	shr    $0x16,%edx
  8010c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010cb:	f6 c2 01             	test   $0x1,%dl
  8010ce:	74 29                	je     8010f9 <fd_alloc+0x42>
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	c1 ea 0c             	shr    $0xc,%edx
  8010d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010dc:	f6 c2 01             	test   $0x1,%dl
  8010df:	74 18                	je     8010f9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010e1:	05 00 10 00 00       	add    $0x1000,%eax
  8010e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010eb:	75 d2                	jne    8010bf <fd_alloc+0x8>
  8010ed:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8010f2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8010f7:	eb 05                	jmp    8010fe <fd_alloc+0x47>
			return 0;
  8010f9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8010fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801101:	89 02                	mov    %eax,(%edx)
}
  801103:	89 c8                	mov    %ecx,%eax
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110d:	83 f8 1f             	cmp    $0x1f,%eax
  801110:	77 30                	ja     801142 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801112:	c1 e0 0c             	shl    $0xc,%eax
  801115:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80111a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	74 24                	je     801149 <fd_lookup+0x42>
  801125:	89 c2                	mov    %eax,%edx
  801127:	c1 ea 0c             	shr    $0xc,%edx
  80112a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801131:	f6 c2 01             	test   $0x1,%dl
  801134:	74 1a                	je     801150 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801136:	8b 55 0c             	mov    0xc(%ebp),%edx
  801139:	89 02                	mov    %eax,(%edx)
	return 0;
  80113b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    
		return -E_INVAL;
  801142:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801147:	eb f7                	jmp    801140 <fd_lookup+0x39>
		return -E_INVAL;
  801149:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114e:	eb f0                	jmp    801140 <fd_lookup+0x39>
  801150:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801155:	eb e9                	jmp    801140 <fd_lookup+0x39>

00801157 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	53                   	push   %ebx
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
  801161:	b8 c8 2a 80 00       	mov    $0x802ac8,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801166:	bb 90 47 80 00       	mov    $0x804790,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80116b:	39 13                	cmp    %edx,(%ebx)
  80116d:	74 32                	je     8011a1 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80116f:	83 c0 04             	add    $0x4,%eax
  801172:	8b 18                	mov    (%eax),%ebx
  801174:	85 db                	test   %ebx,%ebx
  801176:	75 f3                	jne    80116b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801178:	a1 70 67 80 00       	mov    0x806770,%eax
  80117d:	8b 40 48             	mov    0x48(%eax),%eax
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	52                   	push   %edx
  801184:	50                   	push   %eax
  801185:	68 4c 2a 80 00       	push   $0x802a4c
  80118a:	e8 3a f3 ff ff       	call   8004c9 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119a:	89 1a                	mov    %ebx,(%edx)
}
  80119c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    
			return 0;
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a6:	eb ef                	jmp    801197 <dev_lookup+0x40>

008011a8 <fd_close>:
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 24             	sub    $0x24,%esp
  8011b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ba:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c4:	50                   	push   %eax
  8011c5:	e8 3d ff ff ff       	call   801107 <fd_lookup>
  8011ca:	89 c3                	mov    %eax,%ebx
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 05                	js     8011d8 <fd_close+0x30>
	    || fd != fd2)
  8011d3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011d6:	74 16                	je     8011ee <fd_close+0x46>
		return (must_exist ? r : 0);
  8011d8:	89 f8                	mov    %edi,%eax
  8011da:	84 c0                	test   %al,%al
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e1:	0f 44 d8             	cmove  %eax,%ebx
}
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	ff 36                	push   (%esi)
  8011f7:	e8 5b ff ff ff       	call   801157 <dev_lookup>
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	78 1a                	js     80121f <fd_close+0x77>
		if (dev->dev_close)
  801205:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801208:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80120b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801210:	85 c0                	test   %eax,%eax
  801212:	74 0b                	je     80121f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801214:	83 ec 0c             	sub    $0xc,%esp
  801217:	56                   	push   %esi
  801218:	ff d0                	call   *%eax
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	56                   	push   %esi
  801223:	6a 00                	push   $0x0
  801225:	e8 fa fc ff ff       	call   800f24 <sys_page_unmap>
	return r;
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	eb b5                	jmp    8011e4 <fd_close+0x3c>

0080122f <close>:

int
close(int fdnum)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	ff 75 08             	push   0x8(%ebp)
  80123c:	e8 c6 fe ff ff       	call   801107 <fd_lookup>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	79 02                	jns    80124a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801248:	c9                   	leave  
  801249:	c3                   	ret    
		return fd_close(fd, 1);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	6a 01                	push   $0x1
  80124f:	ff 75 f4             	push   -0xc(%ebp)
  801252:	e8 51 ff ff ff       	call   8011a8 <fd_close>
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	eb ec                	jmp    801248 <close+0x19>

0080125c <close_all>:

void
close_all(void)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	53                   	push   %ebx
  801260:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801263:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	53                   	push   %ebx
  80126c:	e8 be ff ff ff       	call   80122f <close>
	for (i = 0; i < MAXFD; i++)
  801271:	83 c3 01             	add    $0x1,%ebx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	83 fb 20             	cmp    $0x20,%ebx
  80127a:	75 ec                	jne    801268 <close_all+0xc>
}
  80127c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	57                   	push   %edi
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80128a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	ff 75 08             	push   0x8(%ebp)
  801291:	e8 71 fe ff ff       	call   801107 <fd_lookup>
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 7f                	js     80131e <dup+0x9d>
		return r;
	close(newfdnum);
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	ff 75 0c             	push   0xc(%ebp)
  8012a5:	e8 85 ff ff ff       	call   80122f <close>

	newfd = INDEX2FD(newfdnum);
  8012aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ad:	c1 e6 0c             	shl    $0xc,%esi
  8012b0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b9:	89 3c 24             	mov    %edi,(%esp)
  8012bc:	e8 df fd ff ff       	call   8010a0 <fd2data>
  8012c1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012c3:	89 34 24             	mov    %esi,(%esp)
  8012c6:	e8 d5 fd ff ff       	call   8010a0 <fd2data>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012d1:	89 d8                	mov    %ebx,%eax
  8012d3:	c1 e8 16             	shr    $0x16,%eax
  8012d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012dd:	a8 01                	test   $0x1,%al
  8012df:	74 11                	je     8012f2 <dup+0x71>
  8012e1:	89 d8                	mov    %ebx,%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
  8012e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	75 36                	jne    801328 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f2:	89 f8                	mov    %edi,%eax
  8012f4:	c1 e8 0c             	shr    $0xc,%eax
  8012f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	25 07 0e 00 00       	and    $0xe07,%eax
  801306:	50                   	push   %eax
  801307:	56                   	push   %esi
  801308:	6a 00                	push   $0x0
  80130a:	57                   	push   %edi
  80130b:	6a 00                	push   $0x0
  80130d:	e8 d0 fb ff ff       	call   800ee2 <sys_page_map>
  801312:	89 c3                	mov    %eax,%ebx
  801314:	83 c4 20             	add    $0x20,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 33                	js     80134e <dup+0xcd>
		goto err;

	return newfdnum;
  80131b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80131e:	89 d8                	mov    %ebx,%eax
  801320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5f                   	pop    %edi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	25 07 0e 00 00       	and    $0xe07,%eax
  801337:	50                   	push   %eax
  801338:	ff 75 d4             	push   -0x2c(%ebp)
  80133b:	6a 00                	push   $0x0
  80133d:	53                   	push   %ebx
  80133e:	6a 00                	push   $0x0
  801340:	e8 9d fb ff ff       	call   800ee2 <sys_page_map>
  801345:	89 c3                	mov    %eax,%ebx
  801347:	83 c4 20             	add    $0x20,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	79 a4                	jns    8012f2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	56                   	push   %esi
  801352:	6a 00                	push   $0x0
  801354:	e8 cb fb ff ff       	call   800f24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801359:	83 c4 08             	add    $0x8,%esp
  80135c:	ff 75 d4             	push   -0x2c(%ebp)
  80135f:	6a 00                	push   $0x0
  801361:	e8 be fb ff ff       	call   800f24 <sys_page_unmap>
	return r;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	eb b3                	jmp    80131e <dup+0x9d>

0080136b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 18             	sub    $0x18,%esp
  801373:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801376:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	56                   	push   %esi
  80137b:	e8 87 fd ff ff       	call   801107 <fd_lookup>
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 3c                	js     8013c3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801387:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	ff 33                	push   (%ebx)
  801393:	e8 bf fd ff ff       	call   801157 <dev_lookup>
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 24                	js     8013c3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139f:	8b 43 08             	mov    0x8(%ebx),%eax
  8013a2:	83 e0 03             	and    $0x3,%eax
  8013a5:	83 f8 01             	cmp    $0x1,%eax
  8013a8:	74 20                	je     8013ca <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ad:	8b 40 08             	mov    0x8(%eax),%eax
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	74 37                	je     8013eb <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	ff 75 10             	push   0x10(%ebp)
  8013ba:	ff 75 0c             	push   0xc(%ebp)
  8013bd:	53                   	push   %ebx
  8013be:	ff d0                	call   *%eax
  8013c0:	83 c4 10             	add    $0x10,%esp
}
  8013c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ca:	a1 70 67 80 00       	mov    0x806770,%eax
  8013cf:	8b 40 48             	mov    0x48(%eax),%eax
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	56                   	push   %esi
  8013d6:	50                   	push   %eax
  8013d7:	68 8d 2a 80 00       	push   $0x802a8d
  8013dc:	e8 e8 f0 ff ff       	call   8004c9 <cprintf>
		return -E_INVAL;
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e9:	eb d8                	jmp    8013c3 <read+0x58>
		return -E_NOT_SUPP;
  8013eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f0:	eb d1                	jmp    8013c3 <read+0x58>

008013f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801401:	bb 00 00 00 00       	mov    $0x0,%ebx
  801406:	eb 02                	jmp    80140a <readn+0x18>
  801408:	01 c3                	add    %eax,%ebx
  80140a:	39 f3                	cmp    %esi,%ebx
  80140c:	73 21                	jae    80142f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	89 f0                	mov    %esi,%eax
  801413:	29 d8                	sub    %ebx,%eax
  801415:	50                   	push   %eax
  801416:	89 d8                	mov    %ebx,%eax
  801418:	03 45 0c             	add    0xc(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	57                   	push   %edi
  80141d:	e8 49 ff ff ff       	call   80136b <read>
		if (m < 0)
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 04                	js     80142d <readn+0x3b>
			return m;
		if (m == 0)
  801429:	75 dd                	jne    801408 <readn+0x16>
  80142b:	eb 02                	jmp    80142f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80142d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	83 ec 18             	sub    $0x18,%esp
  801441:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801444:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	53                   	push   %ebx
  801449:	e8 b9 fc ff ff       	call   801107 <fd_lookup>
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 37                	js     80148c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801455:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	ff 36                	push   (%esi)
  801461:	e8 f1 fc ff ff       	call   801157 <dev_lookup>
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 1f                	js     80148c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801471:	74 20                	je     801493 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801476:	8b 40 0c             	mov    0xc(%eax),%eax
  801479:	85 c0                	test   %eax,%eax
  80147b:	74 37                	je     8014b4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147d:	83 ec 04             	sub    $0x4,%esp
  801480:	ff 75 10             	push   0x10(%ebp)
  801483:	ff 75 0c             	push   0xc(%ebp)
  801486:	56                   	push   %esi
  801487:	ff d0                	call   *%eax
  801489:	83 c4 10             	add    $0x10,%esp
}
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801493:	a1 70 67 80 00       	mov    0x806770,%eax
  801498:	8b 40 48             	mov    0x48(%eax),%eax
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	53                   	push   %ebx
  80149f:	50                   	push   %eax
  8014a0:	68 a9 2a 80 00       	push   $0x802aa9
  8014a5:	e8 1f f0 ff ff       	call   8004c9 <cprintf>
		return -E_INVAL;
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b2:	eb d8                	jmp    80148c <write+0x53>
		return -E_NOT_SUPP;
  8014b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b9:	eb d1                	jmp    80148c <write+0x53>

008014bb <seek>:

int
seek(int fdnum, off_t offset)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	ff 75 08             	push   0x8(%ebp)
  8014c8:	e8 3a fc ff ff       	call   801107 <fd_lookup>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 0e                	js     8014e2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 18             	sub    $0x18,%esp
  8014ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	53                   	push   %ebx
  8014f4:	e8 0e fc ff ff       	call   801107 <fd_lookup>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 34                	js     801534 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801500:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	ff 36                	push   (%esi)
  80150c:	e8 46 fc ff ff       	call   801157 <dev_lookup>
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 1c                	js     801534 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801518:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80151c:	74 1d                	je     80153b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80151e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801521:	8b 40 18             	mov    0x18(%eax),%eax
  801524:	85 c0                	test   %eax,%eax
  801526:	74 34                	je     80155c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	ff 75 0c             	push   0xc(%ebp)
  80152e:	56                   	push   %esi
  80152f:	ff d0                	call   *%eax
  801531:	83 c4 10             	add    $0x10,%esp
}
  801534:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801537:	5b                   	pop    %ebx
  801538:	5e                   	pop    %esi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80153b:	a1 70 67 80 00       	mov    0x806770,%eax
  801540:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	53                   	push   %ebx
  801547:	50                   	push   %eax
  801548:	68 6c 2a 80 00       	push   $0x802a6c
  80154d:	e8 77 ef ff ff       	call   8004c9 <cprintf>
		return -E_INVAL;
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155a:	eb d8                	jmp    801534 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80155c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801561:	eb d1                	jmp    801534 <ftruncate+0x50>

00801563 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	56                   	push   %esi
  801567:	53                   	push   %ebx
  801568:	83 ec 18             	sub    $0x18,%esp
  80156b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 75 08             	push   0x8(%ebp)
  801575:	e8 8d fb ff ff       	call   801107 <fd_lookup>
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 49                	js     8015ca <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	ff 36                	push   (%esi)
  80158d:	e8 c5 fb ff ff       	call   801157 <dev_lookup>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 31                	js     8015ca <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a0:	74 2f                	je     8015d1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ac:	00 00 00 
	stat->st_isdir = 0;
  8015af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b6:	00 00 00 
	stat->st_dev = dev;
  8015b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	56                   	push   %esi
  8015c4:	ff 50 14             	call   *0x14(%eax)
  8015c7:	83 c4 10             	add    $0x10,%esp
}
  8015ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    
		return -E_NOT_SUPP;
  8015d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d6:	eb f2                	jmp    8015ca <fstat+0x67>

008015d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	6a 00                	push   $0x0
  8015e2:	ff 75 08             	push   0x8(%ebp)
  8015e5:	e8 e4 01 00 00       	call   8017ce <open>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 1b                	js     80160e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	ff 75 0c             	push   0xc(%ebp)
  8015f9:	50                   	push   %eax
  8015fa:	e8 64 ff ff ff       	call   801563 <fstat>
  8015ff:	89 c6                	mov    %eax,%esi
	close(fd);
  801601:	89 1c 24             	mov    %ebx,(%esp)
  801604:	e8 26 fc ff ff       	call   80122f <close>
	return r;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	89 f3                	mov    %esi,%ebx
}
  80160e:	89 d8                	mov    %ebx,%eax
  801610:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	89 c6                	mov    %eax,%esi
  80161e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801620:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801627:	74 27                	je     801650 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801629:	6a 07                	push   $0x7
  80162b:	68 00 70 80 00       	push   $0x807000
  801630:	56                   	push   %esi
  801631:	ff 35 00 80 80 00    	push   0x808000
  801637:	e8 49 0c 00 00       	call   802285 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163c:	83 c4 0c             	add    $0xc,%esp
  80163f:	6a 00                	push   $0x0
  801641:	53                   	push   %ebx
  801642:	6a 00                	push   $0x0
  801644:	e8 d5 0b 00 00       	call   80221e <ipc_recv>
}
  801649:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801650:	83 ec 0c             	sub    $0xc,%esp
  801653:	6a 01                	push   $0x1
  801655:	e8 7f 0c 00 00       	call   8022d9 <ipc_find_env>
  80165a:	a3 00 80 80 00       	mov    %eax,0x808000
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb c5                	jmp    801629 <fsipc+0x12>

00801664 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	8b 40 0c             	mov    0xc(%eax),%eax
  801670:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801675:	8b 45 0c             	mov    0xc(%ebp),%eax
  801678:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
  801682:	b8 02 00 00 00       	mov    $0x2,%eax
  801687:	e8 8b ff ff ff       	call   801617 <fsipc>
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <devfile_flush>:
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	8b 40 0c             	mov    0xc(%eax),%eax
  80169a:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a9:	e8 69 ff ff ff       	call   801617 <fsipc>
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <devfile_stat>:
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c0:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8016cf:	e8 43 ff ff ff       	call   801617 <fsipc>
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 2c                	js     801704 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	68 00 70 80 00       	push   $0x807000
  8016e0:	53                   	push   %ebx
  8016e1:	e8 bd f3 ff ff       	call   800aa3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016e6:	a1 80 70 80 00       	mov    0x807080,%eax
  8016eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f1:	a1 84 70 80 00       	mov    0x807084,%eax
  8016f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <devfile_write>:
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	83 ec 0c             	sub    $0xc,%esp
  80170f:	8b 45 10             	mov    0x10(%ebp),%eax
  801712:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801717:	39 d0                	cmp    %edx,%eax
  801719:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171c:	8b 55 08             	mov    0x8(%ebp),%edx
  80171f:	8b 52 0c             	mov    0xc(%edx),%edx
  801722:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801728:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80172d:	50                   	push   %eax
  80172e:	ff 75 0c             	push   0xc(%ebp)
  801731:	68 08 70 80 00       	push   $0x807008
  801736:	e8 fe f4 ff ff       	call   800c39 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80173b:	ba 00 00 00 00       	mov    $0x0,%edx
  801740:	b8 04 00 00 00       	mov    $0x4,%eax
  801745:	e8 cd fe ff ff       	call   801617 <fsipc>
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <devfile_read>:
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	8b 40 0c             	mov    0xc(%eax),%eax
  80175a:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80175f:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
  80176a:	b8 03 00 00 00       	mov    $0x3,%eax
  80176f:	e8 a3 fe ff ff       	call   801617 <fsipc>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	85 c0                	test   %eax,%eax
  801778:	78 1f                	js     801799 <devfile_read+0x4d>
	assert(r <= n);
  80177a:	39 f0                	cmp    %esi,%eax
  80177c:	77 24                	ja     8017a2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80177e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801783:	7f 33                	jg     8017b8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	50                   	push   %eax
  801789:	68 00 70 80 00       	push   $0x807000
  80178e:	ff 75 0c             	push   0xc(%ebp)
  801791:	e8 a3 f4 ff ff       	call   800c39 <memmove>
	return r;
  801796:	83 c4 10             	add    $0x10,%esp
}
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    
	assert(r <= n);
  8017a2:	68 d8 2a 80 00       	push   $0x802ad8
  8017a7:	68 df 2a 80 00       	push   $0x802adf
  8017ac:	6a 7c                	push   $0x7c
  8017ae:	68 f4 2a 80 00       	push   $0x802af4
  8017b3:	e8 36 ec ff ff       	call   8003ee <_panic>
	assert(r <= PGSIZE);
  8017b8:	68 ff 2a 80 00       	push   $0x802aff
  8017bd:	68 df 2a 80 00       	push   $0x802adf
  8017c2:	6a 7d                	push   $0x7d
  8017c4:	68 f4 2a 80 00       	push   $0x802af4
  8017c9:	e8 20 ec ff ff       	call   8003ee <_panic>

008017ce <open>:
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 1c             	sub    $0x1c,%esp
  8017d6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017d9:	56                   	push   %esi
  8017da:	e8 89 f2 ff ff       	call   800a68 <strlen>
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017e7:	7f 6c                	jg     801855 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017e9:	83 ec 0c             	sub    $0xc,%esp
  8017ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ef:	50                   	push   %eax
  8017f0:	e8 c2 f8 ff ff       	call   8010b7 <fd_alloc>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 3c                	js     80183a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	56                   	push   %esi
  801802:	68 00 70 80 00       	push   $0x807000
  801807:	e8 97 f2 ff ff       	call   800aa3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80180c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180f:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801814:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801817:	b8 01 00 00 00       	mov    $0x1,%eax
  80181c:	e8 f6 fd ff ff       	call   801617 <fsipc>
  801821:	89 c3                	mov    %eax,%ebx
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	85 c0                	test   %eax,%eax
  801828:	78 19                	js     801843 <open+0x75>
	return fd2num(fd);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	ff 75 f4             	push   -0xc(%ebp)
  801830:	e8 5b f8 ff ff       	call   801090 <fd2num>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    
		fd_close(fd, 0);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	6a 00                	push   $0x0
  801848:	ff 75 f4             	push   -0xc(%ebp)
  80184b:	e8 58 f9 ff ff       	call   8011a8 <fd_close>
		return r;
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	eb e5                	jmp    80183a <open+0x6c>
		return -E_BAD_PATH;
  801855:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80185a:	eb de                	jmp    80183a <open+0x6c>

0080185c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801862:	ba 00 00 00 00       	mov    $0x0,%edx
  801867:	b8 08 00 00 00       	mov    $0x8,%eax
  80186c:	e8 a6 fd ff ff       	call   801617 <fsipc>
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	57                   	push   %edi
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80187f:	6a 00                	push   $0x0
  801881:	ff 75 08             	push   0x8(%ebp)
  801884:	e8 45 ff ff ff       	call   8017ce <open>
  801889:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	0f 88 aa 04 00 00    	js     801d44 <spawn+0x4d1>
  80189a:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	68 00 02 00 00       	push   $0x200
  8018a4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018aa:	50                   	push   %eax
  8018ab:	57                   	push   %edi
  8018ac:	e8 41 fb ff ff       	call   8013f2 <readn>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018b9:	75 57                	jne    801912 <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  8018bb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018c2:	45 4c 46 
  8018c5:	75 4b                	jne    801912 <spawn+0x9f>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018c7:	b8 07 00 00 00       	mov    $0x7,%eax
  8018cc:	cd 30                	int    $0x30
  8018ce:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	0f 88 5c 04 00 00    	js     801d38 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8018dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018e1:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8018e4:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8018ea:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018f0:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018f7:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018fd:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801903:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801908:	be 00 00 00 00       	mov    $0x0,%esi
  80190d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801910:	eb 4b                	jmp    80195d <spawn+0xea>
		close(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  80191b:	e8 0f f9 ff ff       	call   80122f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801920:	83 c4 0c             	add    $0xc,%esp
  801923:	68 7f 45 4c 46       	push   $0x464c457f
  801928:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  80192e:	68 0b 2b 80 00       	push   $0x802b0b
  801933:	e8 91 eb ff ff       	call   8004c9 <cprintf>
		return -E_NOT_EXEC;
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801942:	ff ff ff 
  801945:	e9 fa 03 00 00       	jmp    801d44 <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	50                   	push   %eax
  80194e:	e8 15 f1 ff ff       	call   800a68 <strlen>
  801953:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801957:	83 c3 01             	add    $0x1,%ebx
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801964:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801967:	85 c0                	test   %eax,%eax
  801969:	75 df                	jne    80194a <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80196b:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801971:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801977:	b8 00 10 40 00       	mov    $0x401000,%eax
  80197c:	29 f0                	sub    %esi,%eax
  80197e:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801980:	89 c2                	mov    %eax,%edx
  801982:	83 e2 fc             	and    $0xfffffffc,%edx
  801985:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80198c:	29 c2                	sub    %eax,%edx
  80198e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801994:	8d 42 f8             	lea    -0x8(%edx),%eax
  801997:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80199c:	0f 86 14 04 00 00    	jbe    801db6 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	6a 07                	push   $0x7
  8019a7:	68 00 00 40 00       	push   $0x400000
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 ec f4 ff ff       	call   800e9f <sys_page_alloc>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	0f 88 fd 03 00 00    	js     801dbb <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019be:	be 00 00 00 00       	mov    $0x0,%esi
  8019c3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019cc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8019d2:	7e 32                	jle    801a06 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  8019d4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019da:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019e0:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019e3:	83 ec 08             	sub    $0x8,%esp
  8019e6:	ff 34 b3             	push   (%ebx,%esi,4)
  8019e9:	57                   	push   %edi
  8019ea:	e8 b4 f0 ff ff       	call   800aa3 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019ef:	83 c4 04             	add    $0x4,%esp
  8019f2:	ff 34 b3             	push   (%ebx,%esi,4)
  8019f5:	e8 6e f0 ff ff       	call   800a68 <strlen>
  8019fa:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8019fe:	83 c6 01             	add    $0x1,%esi
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	eb c6                	jmp    8019cc <spawn+0x159>
	}
	argv_store[argc] = 0;
  801a06:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a0c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a12:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a19:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a1f:	0f 85 8c 00 00 00    	jne    801ab1 <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a25:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a2b:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801a31:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801a34:	89 c8                	mov    %ecx,%eax
  801a36:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801a3c:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a3f:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801a44:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	6a 07                	push   $0x7
  801a4f:	68 00 d0 bf ee       	push   $0xeebfd000
  801a54:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801a5a:	68 00 00 40 00       	push   $0x400000
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 7c f4 ff ff       	call   800ee2 <sys_page_map>
  801a66:	89 c3                	mov    %eax,%ebx
  801a68:	83 c4 20             	add    $0x20,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	0f 88 50 03 00 00    	js     801dc3 <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	68 00 00 40 00       	push   $0x400000
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 a2 f4 ff ff       	call   800f24 <sys_page_unmap>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	0f 88 34 03 00 00    	js     801dc3 <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a8f:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801a95:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801a9c:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aa2:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801aa9:	00 00 00 
  801aac:	e9 4e 01 00 00       	jmp    801bff <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ab1:	68 98 2b 80 00       	push   $0x802b98
  801ab6:	68 df 2a 80 00       	push   $0x802adf
  801abb:	68 f2 00 00 00       	push   $0xf2
  801ac0:	68 25 2b 80 00       	push   $0x802b25
  801ac5:	e8 24 e9 ff ff       	call   8003ee <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aca:	83 ec 04             	sub    $0x4,%esp
  801acd:	6a 07                	push   $0x7
  801acf:	68 00 00 40 00       	push   $0x400000
  801ad4:	6a 00                	push   $0x0
  801ad6:	e8 c4 f3 ff ff       	call   800e9f <sys_page_alloc>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	0f 88 6c 02 00 00    	js     801d52 <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801aef:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801af5:	50                   	push   %eax
  801af6:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801afc:	e8 ba f9 ff ff       	call   8014bb <seek>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	0f 88 4d 02 00 00    	js     801d59 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b0c:	83 ec 04             	sub    $0x4,%esp
  801b0f:	89 f8                	mov    %edi,%eax
  801b11:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801b17:	ba 00 10 00 00       	mov    $0x1000,%edx
  801b1c:	39 d0                	cmp    %edx,%eax
  801b1e:	0f 47 c2             	cmova  %edx,%eax
  801b21:	50                   	push   %eax
  801b22:	68 00 00 40 00       	push   $0x400000
  801b27:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801b2d:	e8 c0 f8 ff ff       	call   8013f2 <readn>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	0f 88 23 02 00 00    	js     801d60 <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801b46:	56                   	push   %esi
  801b47:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801b4d:	68 00 00 40 00       	push   $0x400000
  801b52:	6a 00                	push   $0x0
  801b54:	e8 89 f3 ff ff       	call   800ee2 <sys_page_map>
  801b59:	83 c4 20             	add    $0x20,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 7c                	js     801bdc <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	68 00 00 40 00       	push   $0x400000
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 b5 f3 ff ff       	call   800f24 <sys_page_unmap>
  801b6f:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801b72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b78:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801b7e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801b84:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801b8a:	76 65                	jbe    801bf1 <spawn+0x37e>
		if (i >= filesz) {
  801b8c:	39 df                	cmp    %ebx,%edi
  801b8e:	0f 87 36 ff ff ff    	ja     801aca <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b94:	83 ec 04             	sub    $0x4,%esp
  801b97:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801b9d:	56                   	push   %esi
  801b9e:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ba4:	e8 f6 f2 ff ff       	call   800e9f <sys_page_alloc>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	79 c2                	jns    801b72 <spawn+0x2ff>
  801bb0:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801bbb:	e8 60 f2 ff ff       	call   800e20 <sys_env_destroy>
	close(fd);
  801bc0:	83 c4 04             	add    $0x4,%esp
  801bc3:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801bc9:	e8 61 f6 ff ff       	call   80122f <close>
	return r;
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801bd7:	e9 68 01 00 00       	jmp    801d44 <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801bdc:	50                   	push   %eax
  801bdd:	68 31 2b 80 00       	push   $0x802b31
  801be2:	68 25 01 00 00       	push   $0x125
  801be7:	68 25 2b 80 00       	push   $0x802b25
  801bec:	e8 fd e7 ff ff       	call   8003ee <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bf1:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801bf8:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801bff:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c06:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801c0c:	7e 67                	jle    801c75 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801c0e:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801c14:	83 39 01             	cmpl   $0x1,(%ecx)
  801c17:	75 d8                	jne    801bf1 <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c19:	8b 41 18             	mov    0x18(%ecx),%eax
  801c1c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c22:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c25:	83 f8 01             	cmp    $0x1,%eax
  801c28:	19 c0                	sbb    %eax,%eax
  801c2a:	83 e0 fe             	and    $0xfffffffe,%eax
  801c2d:	83 c0 07             	add    $0x7,%eax
  801c30:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c36:	8b 51 04             	mov    0x4(%ecx),%edx
  801c39:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801c3f:	8b 79 10             	mov    0x10(%ecx),%edi
  801c42:	8b 59 14             	mov    0x14(%ecx),%ebx
  801c45:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801c4b:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801c4e:	89 f0                	mov    %esi,%eax
  801c50:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c55:	74 14                	je     801c6b <spawn+0x3f8>
		va -= i;
  801c57:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c59:	01 c3                	add    %eax,%ebx
  801c5b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801c61:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c63:	29 c2                	sub    %eax,%edx
  801c65:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c70:	e9 09 ff ff ff       	jmp    801b7e <spawn+0x30b>
	close(fd);
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c7e:	e8 ac f5 ff ff       	call   80122f <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801c83:	e8 d9 f1 ff ff       	call   800e61 <sys_getenvid>
  801c88:	89 c6                	mov    %eax,%esi
  801c8a:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801c8d:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801c92:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801c98:	eb 12                	jmp    801cac <spawn+0x439>
  801c9a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ca0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801ca6:	0f 84 bb 00 00 00    	je     801d67 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	c1 e8 16             	shr    $0x16,%eax
  801cb1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cb8:	a8 01                	test   $0x1,%al
  801cba:	74 de                	je     801c9a <spawn+0x427>
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	c1 e8 0c             	shr    $0xc,%eax
  801cc1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cc8:	f6 c2 01             	test   $0x1,%dl
  801ccb:	74 cd                	je     801c9a <spawn+0x427>
  801ccd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cd4:	f6 c6 04             	test   $0x4,%dh
  801cd7:	74 c1                	je     801c9a <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801cd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ce0:	83 ec 0c             	sub    $0xc,%esp
  801ce3:	25 07 0e 00 00       	and    $0xe07,%eax
  801ce8:	50                   	push   %eax
  801ce9:	53                   	push   %ebx
  801cea:	57                   	push   %edi
  801ceb:	53                   	push   %ebx
  801cec:	56                   	push   %esi
  801ced:	e8 f0 f1 ff ff       	call   800ee2 <sys_page_map>
  801cf2:	83 c4 20             	add    $0x20,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	79 a1                	jns    801c9a <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  801cf9:	50                   	push   %eax
  801cfa:	68 7f 2b 80 00       	push   $0x802b7f
  801cff:	68 82 00 00 00       	push   $0x82
  801d04:	68 25 2b 80 00       	push   $0x802b25
  801d09:	e8 e0 e6 ff ff       	call   8003ee <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801d0e:	50                   	push   %eax
  801d0f:	68 4e 2b 80 00       	push   $0x802b4e
  801d14:	68 86 00 00 00       	push   $0x86
  801d19:	68 25 2b 80 00       	push   $0x802b25
  801d1e:	e8 cb e6 ff ff       	call   8003ee <_panic>
		panic("sys_env_set_status: %e", r);
  801d23:	50                   	push   %eax
  801d24:	68 68 2b 80 00       	push   $0x802b68
  801d29:	68 89 00 00 00       	push   $0x89
  801d2e:	68 25 2b 80 00       	push   $0x802b25
  801d33:	e8 b6 e6 ff ff       	call   8003ee <_panic>
		return r;
  801d38:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d3e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801d44:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	89 c7                	mov    %eax,%edi
  801d54:	e9 59 fe ff ff       	jmp    801bb2 <spawn+0x33f>
  801d59:	89 c7                	mov    %eax,%edi
  801d5b:	e9 52 fe ff ff       	jmp    801bb2 <spawn+0x33f>
  801d60:	89 c7                	mov    %eax,%edi
  801d62:	e9 4b fe ff ff       	jmp    801bb2 <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801d67:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d6e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d71:	83 ec 08             	sub    $0x8,%esp
  801d74:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d7a:	50                   	push   %eax
  801d7b:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801d81:	e8 22 f2 ff ff       	call   800fa8 <sys_env_set_trapframe>
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 81                	js     801d0e <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	6a 02                	push   $0x2
  801d92:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801d98:	e8 c9 f1 ff ff       	call   800f66 <sys_env_set_status>
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	0f 88 7b ff ff ff    	js     801d23 <spawn+0x4b0>
	return child;
  801da8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dae:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801db4:	eb 8e                	jmp    801d44 <spawn+0x4d1>
		return -E_NO_MEM;
  801db6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801dbb:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801dc1:	eb 81                	jmp    801d44 <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	68 00 00 40 00       	push   $0x400000
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 52 f1 ff ff       	call   800f24 <sys_page_unmap>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801ddb:	e9 64 ff ff ff       	jmp    801d44 <spawn+0x4d1>

00801de0 <spawnl>:
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
	va_start(vl, arg0);
  801de5:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801de8:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801ded:	eb 05                	jmp    801df4 <spawnl+0x14>
		argc++;
  801def:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801df2:	89 ca                	mov    %ecx,%edx
  801df4:	8d 4a 04             	lea    0x4(%edx),%ecx
  801df7:	83 3a 00             	cmpl   $0x0,(%edx)
  801dfa:	75 f3                	jne    801def <spawnl+0xf>
	const char *argv[argc+2];
  801dfc:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801e03:	89 d3                	mov    %edx,%ebx
  801e05:	83 e3 f0             	and    $0xfffffff0,%ebx
  801e08:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801e0e:	89 e1                	mov    %esp,%ecx
  801e10:	29 d1                	sub    %edx,%ecx
  801e12:	39 cc                	cmp    %ecx,%esp
  801e14:	74 10                	je     801e26 <spawnl+0x46>
  801e16:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801e1c:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801e23:	00 
  801e24:	eb ec                	jmp    801e12 <spawnl+0x32>
  801e26:	89 da                	mov    %ebx,%edx
  801e28:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801e2e:	29 d4                	sub    %edx,%esp
  801e30:	85 d2                	test   %edx,%edx
  801e32:	74 05                	je     801e39 <spawnl+0x59>
  801e34:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801e39:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801e3d:	89 da                	mov    %ebx,%edx
  801e3f:	c1 ea 02             	shr    $0x2,%edx
  801e42:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e48:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e4f:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801e56:	00 
	va_start(vl, arg0);
  801e57:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801e5a:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e61:	eb 0b                	jmp    801e6e <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801e63:	83 c0 01             	add    $0x1,%eax
  801e66:	8b 31                	mov    (%ecx),%esi
  801e68:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801e6b:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801e6e:	39 d0                	cmp    %edx,%eax
  801e70:	75 f1                	jne    801e63 <spawnl+0x83>
	return spawn(prog, argv);
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	53                   	push   %ebx
  801e76:	ff 75 08             	push   0x8(%ebp)
  801e79:	e8 f5 f9 ff ff       	call   801873 <spawn>
}
  801e7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5e                   	pop    %esi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e8d:	83 ec 0c             	sub    $0xc,%esp
  801e90:	ff 75 08             	push   0x8(%ebp)
  801e93:	e8 08 f2 ff ff       	call   8010a0 <fd2data>
  801e98:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e9a:	83 c4 08             	add    $0x8,%esp
  801e9d:	68 be 2b 80 00       	push   $0x802bbe
  801ea2:	53                   	push   %ebx
  801ea3:	e8 fb eb ff ff       	call   800aa3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea8:	8b 46 04             	mov    0x4(%esi),%eax
  801eab:	2b 06                	sub    (%esi),%eax
  801ead:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eb3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eba:	00 00 00 
	stat->st_dev = &devpipe;
  801ebd:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801ec4:	47 80 00 
	return 0;
}
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	53                   	push   %ebx
  801ed7:	83 ec 0c             	sub    $0xc,%esp
  801eda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801edd:	53                   	push   %ebx
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 3f f0 ff ff       	call   800f24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee5:	89 1c 24             	mov    %ebx,(%esp)
  801ee8:	e8 b3 f1 ff ff       	call   8010a0 <fd2data>
  801eed:	83 c4 08             	add    $0x8,%esp
  801ef0:	50                   	push   %eax
  801ef1:	6a 00                	push   $0x0
  801ef3:	e8 2c f0 ff ff       	call   800f24 <sys_page_unmap>
}
  801ef8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    

00801efd <_pipeisclosed>:
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	57                   	push   %edi
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	83 ec 1c             	sub    $0x1c,%esp
  801f06:	89 c7                	mov    %eax,%edi
  801f08:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f0a:	a1 70 67 80 00       	mov    0x806770,%eax
  801f0f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	57                   	push   %edi
  801f16:	e8 f7 03 00 00       	call   802312 <pageref>
  801f1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f1e:	89 34 24             	mov    %esi,(%esp)
  801f21:	e8 ec 03 00 00       	call   802312 <pageref>
		nn = thisenv->env_runs;
  801f26:	8b 15 70 67 80 00    	mov    0x806770,%edx
  801f2c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	39 cb                	cmp    %ecx,%ebx
  801f34:	74 1b                	je     801f51 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f39:	75 cf                	jne    801f0a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f3b:	8b 42 58             	mov    0x58(%edx),%eax
  801f3e:	6a 01                	push   $0x1
  801f40:	50                   	push   %eax
  801f41:	53                   	push   %ebx
  801f42:	68 c5 2b 80 00       	push   $0x802bc5
  801f47:	e8 7d e5 ff ff       	call   8004c9 <cprintf>
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	eb b9                	jmp    801f0a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f51:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f54:	0f 94 c0             	sete   %al
  801f57:	0f b6 c0             	movzbl %al,%eax
}
  801f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5d:	5b                   	pop    %ebx
  801f5e:	5e                   	pop    %esi
  801f5f:	5f                   	pop    %edi
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    

00801f62 <devpipe_write>:
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	57                   	push   %edi
  801f66:	56                   	push   %esi
  801f67:	53                   	push   %ebx
  801f68:	83 ec 28             	sub    $0x28,%esp
  801f6b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f6e:	56                   	push   %esi
  801f6f:	e8 2c f1 ff ff       	call   8010a0 <fd2data>
  801f74:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	bf 00 00 00 00       	mov    $0x0,%edi
  801f7e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f81:	75 09                	jne    801f8c <devpipe_write+0x2a>
	return i;
  801f83:	89 f8                	mov    %edi,%eax
  801f85:	eb 23                	jmp    801faa <devpipe_write+0x48>
			sys_yield();
  801f87:	e8 f4 ee ff ff       	call   800e80 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f8f:	8b 0b                	mov    (%ebx),%ecx
  801f91:	8d 51 20             	lea    0x20(%ecx),%edx
  801f94:	39 d0                	cmp    %edx,%eax
  801f96:	72 1a                	jb     801fb2 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f98:	89 da                	mov    %ebx,%edx
  801f9a:	89 f0                	mov    %esi,%eax
  801f9c:	e8 5c ff ff ff       	call   801efd <_pipeisclosed>
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	74 e2                	je     801f87 <devpipe_write+0x25>
				return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fb9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fbc:	89 c2                	mov    %eax,%edx
  801fbe:	c1 fa 1f             	sar    $0x1f,%edx
  801fc1:	89 d1                	mov    %edx,%ecx
  801fc3:	c1 e9 1b             	shr    $0x1b,%ecx
  801fc6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fc9:	83 e2 1f             	and    $0x1f,%edx
  801fcc:	29 ca                	sub    %ecx,%edx
  801fce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fd2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fd6:	83 c0 01             	add    $0x1,%eax
  801fd9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fdc:	83 c7 01             	add    $0x1,%edi
  801fdf:	eb 9d                	jmp    801f7e <devpipe_write+0x1c>

00801fe1 <devpipe_read>:
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	57                   	push   %edi
  801fe5:	56                   	push   %esi
  801fe6:	53                   	push   %ebx
  801fe7:	83 ec 18             	sub    $0x18,%esp
  801fea:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fed:	57                   	push   %edi
  801fee:	e8 ad f0 ff ff       	call   8010a0 <fd2data>
  801ff3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	be 00 00 00 00       	mov    $0x0,%esi
  801ffd:	3b 75 10             	cmp    0x10(%ebp),%esi
  802000:	75 13                	jne    802015 <devpipe_read+0x34>
	return i;
  802002:	89 f0                	mov    %esi,%eax
  802004:	eb 02                	jmp    802008 <devpipe_read+0x27>
				return i;
  802006:	89 f0                	mov    %esi,%eax
}
  802008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    
			sys_yield();
  802010:	e8 6b ee ff ff       	call   800e80 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802015:	8b 03                	mov    (%ebx),%eax
  802017:	3b 43 04             	cmp    0x4(%ebx),%eax
  80201a:	75 18                	jne    802034 <devpipe_read+0x53>
			if (i > 0)
  80201c:	85 f6                	test   %esi,%esi
  80201e:	75 e6                	jne    802006 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802020:	89 da                	mov    %ebx,%edx
  802022:	89 f8                	mov    %edi,%eax
  802024:	e8 d4 fe ff ff       	call   801efd <_pipeisclosed>
  802029:	85 c0                	test   %eax,%eax
  80202b:	74 e3                	je     802010 <devpipe_read+0x2f>
				return 0;
  80202d:	b8 00 00 00 00       	mov    $0x0,%eax
  802032:	eb d4                	jmp    802008 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802034:	99                   	cltd   
  802035:	c1 ea 1b             	shr    $0x1b,%edx
  802038:	01 d0                	add    %edx,%eax
  80203a:	83 e0 1f             	and    $0x1f,%eax
  80203d:	29 d0                	sub    %edx,%eax
  80203f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802047:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80204a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80204d:	83 c6 01             	add    $0x1,%esi
  802050:	eb ab                	jmp    801ffd <devpipe_read+0x1c>

00802052 <pipe>:
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	56                   	push   %esi
  802056:	53                   	push   %ebx
  802057:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80205a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205d:	50                   	push   %eax
  80205e:	e8 54 f0 ff ff       	call   8010b7 <fd_alloc>
  802063:	89 c3                	mov    %eax,%ebx
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 c0                	test   %eax,%eax
  80206a:	0f 88 23 01 00 00    	js     802193 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802070:	83 ec 04             	sub    $0x4,%esp
  802073:	68 07 04 00 00       	push   $0x407
  802078:	ff 75 f4             	push   -0xc(%ebp)
  80207b:	6a 00                	push   $0x0
  80207d:	e8 1d ee ff ff       	call   800e9f <sys_page_alloc>
  802082:	89 c3                	mov    %eax,%ebx
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	85 c0                	test   %eax,%eax
  802089:	0f 88 04 01 00 00    	js     802193 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80208f:	83 ec 0c             	sub    $0xc,%esp
  802092:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802095:	50                   	push   %eax
  802096:	e8 1c f0 ff ff       	call   8010b7 <fd_alloc>
  80209b:	89 c3                	mov    %eax,%ebx
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	0f 88 db 00 00 00    	js     802183 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a8:	83 ec 04             	sub    $0x4,%esp
  8020ab:	68 07 04 00 00       	push   $0x407
  8020b0:	ff 75 f0             	push   -0x10(%ebp)
  8020b3:	6a 00                	push   $0x0
  8020b5:	e8 e5 ed ff ff       	call   800e9f <sys_page_alloc>
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	0f 88 bc 00 00 00    	js     802183 <pipe+0x131>
	va = fd2data(fd0);
  8020c7:	83 ec 0c             	sub    $0xc,%esp
  8020ca:	ff 75 f4             	push   -0xc(%ebp)
  8020cd:	e8 ce ef ff ff       	call   8010a0 <fd2data>
  8020d2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d4:	83 c4 0c             	add    $0xc,%esp
  8020d7:	68 07 04 00 00       	push   $0x407
  8020dc:	50                   	push   %eax
  8020dd:	6a 00                	push   $0x0
  8020df:	e8 bb ed ff ff       	call   800e9f <sys_page_alloc>
  8020e4:	89 c3                	mov    %eax,%ebx
  8020e6:	83 c4 10             	add    $0x10,%esp
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	0f 88 82 00 00 00    	js     802173 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f1:	83 ec 0c             	sub    $0xc,%esp
  8020f4:	ff 75 f0             	push   -0x10(%ebp)
  8020f7:	e8 a4 ef ff ff       	call   8010a0 <fd2data>
  8020fc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802103:	50                   	push   %eax
  802104:	6a 00                	push   $0x0
  802106:	56                   	push   %esi
  802107:	6a 00                	push   $0x0
  802109:	e8 d4 ed ff ff       	call   800ee2 <sys_page_map>
  80210e:	89 c3                	mov    %eax,%ebx
  802110:	83 c4 20             	add    $0x20,%esp
  802113:	85 c0                	test   %eax,%eax
  802115:	78 4e                	js     802165 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802117:	a1 ac 47 80 00       	mov    0x8047ac,%eax
  80211c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80211f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802121:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802124:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80212b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80212e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802130:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802133:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80213a:	83 ec 0c             	sub    $0xc,%esp
  80213d:	ff 75 f4             	push   -0xc(%ebp)
  802140:	e8 4b ef ff ff       	call   801090 <fd2num>
  802145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802148:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80214a:	83 c4 04             	add    $0x4,%esp
  80214d:	ff 75 f0             	push   -0x10(%ebp)
  802150:	e8 3b ef ff ff       	call   801090 <fd2num>
  802155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802158:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802163:	eb 2e                	jmp    802193 <pipe+0x141>
	sys_page_unmap(0, va);
  802165:	83 ec 08             	sub    $0x8,%esp
  802168:	56                   	push   %esi
  802169:	6a 00                	push   $0x0
  80216b:	e8 b4 ed ff ff       	call   800f24 <sys_page_unmap>
  802170:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802173:	83 ec 08             	sub    $0x8,%esp
  802176:	ff 75 f0             	push   -0x10(%ebp)
  802179:	6a 00                	push   $0x0
  80217b:	e8 a4 ed ff ff       	call   800f24 <sys_page_unmap>
  802180:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802183:	83 ec 08             	sub    $0x8,%esp
  802186:	ff 75 f4             	push   -0xc(%ebp)
  802189:	6a 00                	push   $0x0
  80218b:	e8 94 ed ff ff       	call   800f24 <sys_page_unmap>
  802190:	83 c4 10             	add    $0x10,%esp
}
  802193:	89 d8                	mov    %ebx,%eax
  802195:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <pipeisclosed>:
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a5:	50                   	push   %eax
  8021a6:	ff 75 08             	push   0x8(%ebp)
  8021a9:	e8 59 ef ff ff       	call   801107 <fd_lookup>
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 18                	js     8021cd <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8021b5:	83 ec 0c             	sub    $0xc,%esp
  8021b8:	ff 75 f4             	push   -0xc(%ebp)
  8021bb:	e8 e0 ee ff ff       	call   8010a0 <fd2data>
  8021c0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	e8 33 fd ff ff       	call   801efd <_pipeisclosed>
  8021ca:	83 c4 10             	add    $0x10,%esp
}
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	74 13                	je     8021ee <wait+0x1f>
	e = &envs[ENVX(envid)];
  8021db:	89 f3                	mov    %esi,%ebx
  8021dd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021e3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021e6:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021ec:	eb 1b                	jmp    802209 <wait+0x3a>
	assert(envid != 0);
  8021ee:	68 dd 2b 80 00       	push   $0x802bdd
  8021f3:	68 df 2a 80 00       	push   $0x802adf
  8021f8:	6a 09                	push   $0x9
  8021fa:	68 e8 2b 80 00       	push   $0x802be8
  8021ff:	e8 ea e1 ff ff       	call   8003ee <_panic>
		sys_yield();
  802204:	e8 77 ec ff ff       	call   800e80 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802209:	8b 43 48             	mov    0x48(%ebx),%eax
  80220c:	39 f0                	cmp    %esi,%eax
  80220e:	75 07                	jne    802217 <wait+0x48>
  802210:	8b 43 54             	mov    0x54(%ebx),%eax
  802213:	85 c0                	test   %eax,%eax
  802215:	75 ed                	jne    802204 <wait+0x35>
}
  802217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221a:	5b                   	pop    %ebx
  80221b:	5e                   	pop    %esi
  80221c:	5d                   	pop    %ebp
  80221d:	c3                   	ret    

0080221e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	56                   	push   %esi
  802222:	53                   	push   %ebx
  802223:	8b 75 08             	mov    0x8(%ebp),%esi
  802226:	8b 45 0c             	mov    0xc(%ebp),%eax
  802229:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80222c:	85 c0                	test   %eax,%eax
  80222e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802233:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802236:	83 ec 0c             	sub    $0xc,%esp
  802239:	50                   	push   %eax
  80223a:	e8 10 ee ff ff       	call   80104f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	85 f6                	test   %esi,%esi
  802244:	74 14                	je     80225a <ipc_recv+0x3c>
  802246:	ba 00 00 00 00       	mov    $0x0,%edx
  80224b:	85 c0                	test   %eax,%eax
  80224d:	78 09                	js     802258 <ipc_recv+0x3a>
  80224f:	8b 15 70 67 80 00    	mov    0x806770,%edx
  802255:	8b 52 74             	mov    0x74(%edx),%edx
  802258:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80225a:	85 db                	test   %ebx,%ebx
  80225c:	74 14                	je     802272 <ipc_recv+0x54>
  80225e:	ba 00 00 00 00       	mov    $0x0,%edx
  802263:	85 c0                	test   %eax,%eax
  802265:	78 09                	js     802270 <ipc_recv+0x52>
  802267:	8b 15 70 67 80 00    	mov    0x806770,%edx
  80226d:	8b 52 78             	mov    0x78(%edx),%edx
  802270:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802272:	85 c0                	test   %eax,%eax
  802274:	78 08                	js     80227e <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802276:	a1 70 67 80 00       	mov    0x806770,%eax
  80227b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80227e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802281:	5b                   	pop    %ebx
  802282:	5e                   	pop    %esi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	57                   	push   %edi
  802289:	56                   	push   %esi
  80228a:	53                   	push   %ebx
  80228b:	83 ec 0c             	sub    $0xc,%esp
  80228e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802291:	8b 75 0c             	mov    0xc(%ebp),%esi
  802294:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802297:	85 db                	test   %ebx,%ebx
  802299:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80229e:	0f 44 d8             	cmove  %eax,%ebx
  8022a1:	eb 05                	jmp    8022a8 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022a3:	e8 d8 eb ff ff       	call   800e80 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8022a8:	ff 75 14             	push   0x14(%ebp)
  8022ab:	53                   	push   %ebx
  8022ac:	56                   	push   %esi
  8022ad:	57                   	push   %edi
  8022ae:	e8 79 ed ff ff       	call   80102c <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022b3:	83 c4 10             	add    $0x10,%esp
  8022b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b9:	74 e8                	je     8022a3 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	78 08                	js     8022c7 <ipc_send+0x42>
	}while (r<0);

}
  8022bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c2:	5b                   	pop    %ebx
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8022c7:	50                   	push   %eax
  8022c8:	68 f3 2b 80 00       	push   $0x802bf3
  8022cd:	6a 3d                	push   $0x3d
  8022cf:	68 07 2c 80 00       	push   $0x802c07
  8022d4:	e8 15 e1 ff ff       	call   8003ee <_panic>

008022d9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022e4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022e7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022ed:	8b 52 50             	mov    0x50(%edx),%edx
  8022f0:	39 ca                	cmp    %ecx,%edx
  8022f2:	74 11                	je     802305 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8022f4:	83 c0 01             	add    $0x1,%eax
  8022f7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022fc:	75 e6                	jne    8022e4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8022fe:	b8 00 00 00 00       	mov    $0x0,%eax
  802303:	eb 0b                	jmp    802310 <ipc_find_env+0x37>
			return envs[i].env_id;
  802305:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802308:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80230d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    

00802312 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802318:	89 c2                	mov    %eax,%edx
  80231a:	c1 ea 16             	shr    $0x16,%edx
  80231d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802324:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802329:	f6 c1 01             	test   $0x1,%cl
  80232c:	74 1c                	je     80234a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80232e:	c1 e8 0c             	shr    $0xc,%eax
  802331:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802338:	a8 01                	test   $0x1,%al
  80233a:	74 0e                	je     80234a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80233c:	c1 e8 0c             	shr    $0xc,%eax
  80233f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802346:	ef 
  802347:	0f b7 d2             	movzwl %dx,%edx
}
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__udivdi3>:
  802350:	f3 0f 1e fb          	endbr32 
  802354:	55                   	push   %ebp
  802355:	57                   	push   %edi
  802356:	56                   	push   %esi
  802357:	53                   	push   %ebx
  802358:	83 ec 1c             	sub    $0x1c,%esp
  80235b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80235f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802363:	8b 74 24 34          	mov    0x34(%esp),%esi
  802367:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80236b:	85 c0                	test   %eax,%eax
  80236d:	75 19                	jne    802388 <__udivdi3+0x38>
  80236f:	39 f3                	cmp    %esi,%ebx
  802371:	76 4d                	jbe    8023c0 <__udivdi3+0x70>
  802373:	31 ff                	xor    %edi,%edi
  802375:	89 e8                	mov    %ebp,%eax
  802377:	89 f2                	mov    %esi,%edx
  802379:	f7 f3                	div    %ebx
  80237b:	89 fa                	mov    %edi,%edx
  80237d:	83 c4 1c             	add    $0x1c,%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    
  802385:	8d 76 00             	lea    0x0(%esi),%esi
  802388:	39 f0                	cmp    %esi,%eax
  80238a:	76 14                	jbe    8023a0 <__udivdi3+0x50>
  80238c:	31 ff                	xor    %edi,%edi
  80238e:	31 c0                	xor    %eax,%eax
  802390:	89 fa                	mov    %edi,%edx
  802392:	83 c4 1c             	add    $0x1c,%esp
  802395:	5b                   	pop    %ebx
  802396:	5e                   	pop    %esi
  802397:	5f                   	pop    %edi
  802398:	5d                   	pop    %ebp
  802399:	c3                   	ret    
  80239a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a0:	0f bd f8             	bsr    %eax,%edi
  8023a3:	83 f7 1f             	xor    $0x1f,%edi
  8023a6:	75 48                	jne    8023f0 <__udivdi3+0xa0>
  8023a8:	39 f0                	cmp    %esi,%eax
  8023aa:	72 06                	jb     8023b2 <__udivdi3+0x62>
  8023ac:	31 c0                	xor    %eax,%eax
  8023ae:	39 eb                	cmp    %ebp,%ebx
  8023b0:	77 de                	ja     802390 <__udivdi3+0x40>
  8023b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b7:	eb d7                	jmp    802390 <__udivdi3+0x40>
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	89 d9                	mov    %ebx,%ecx
  8023c2:	85 db                	test   %ebx,%ebx
  8023c4:	75 0b                	jne    8023d1 <__udivdi3+0x81>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f3                	div    %ebx
  8023cf:	89 c1                	mov    %eax,%ecx
  8023d1:	31 d2                	xor    %edx,%edx
  8023d3:	89 f0                	mov    %esi,%eax
  8023d5:	f7 f1                	div    %ecx
  8023d7:	89 c6                	mov    %eax,%esi
  8023d9:	89 e8                	mov    %ebp,%eax
  8023db:	89 f7                	mov    %esi,%edi
  8023dd:	f7 f1                	div    %ecx
  8023df:	89 fa                	mov    %edi,%edx
  8023e1:	83 c4 1c             	add    $0x1c,%esp
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 f9                	mov    %edi,%ecx
  8023f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8023f7:	29 fa                	sub    %edi,%edx
  8023f9:	d3 e0                	shl    %cl,%eax
  8023fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ff:	89 d1                	mov    %edx,%ecx
  802401:	89 d8                	mov    %ebx,%eax
  802403:	d3 e8                	shr    %cl,%eax
  802405:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802409:	09 c1                	or     %eax,%ecx
  80240b:	89 f0                	mov    %esi,%eax
  80240d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802411:	89 f9                	mov    %edi,%ecx
  802413:	d3 e3                	shl    %cl,%ebx
  802415:	89 d1                	mov    %edx,%ecx
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 f9                	mov    %edi,%ecx
  80241b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80241f:	89 eb                	mov    %ebp,%ebx
  802421:	d3 e6                	shl    %cl,%esi
  802423:	89 d1                	mov    %edx,%ecx
  802425:	d3 eb                	shr    %cl,%ebx
  802427:	09 f3                	or     %esi,%ebx
  802429:	89 c6                	mov    %eax,%esi
  80242b:	89 f2                	mov    %esi,%edx
  80242d:	89 d8                	mov    %ebx,%eax
  80242f:	f7 74 24 08          	divl   0x8(%esp)
  802433:	89 d6                	mov    %edx,%esi
  802435:	89 c3                	mov    %eax,%ebx
  802437:	f7 64 24 0c          	mull   0xc(%esp)
  80243b:	39 d6                	cmp    %edx,%esi
  80243d:	72 19                	jb     802458 <__udivdi3+0x108>
  80243f:	89 f9                	mov    %edi,%ecx
  802441:	d3 e5                	shl    %cl,%ebp
  802443:	39 c5                	cmp    %eax,%ebp
  802445:	73 04                	jae    80244b <__udivdi3+0xfb>
  802447:	39 d6                	cmp    %edx,%esi
  802449:	74 0d                	je     802458 <__udivdi3+0x108>
  80244b:	89 d8                	mov    %ebx,%eax
  80244d:	31 ff                	xor    %edi,%edi
  80244f:	e9 3c ff ff ff       	jmp    802390 <__udivdi3+0x40>
  802454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802458:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80245b:	31 ff                	xor    %edi,%edi
  80245d:	e9 2e ff ff ff       	jmp    802390 <__udivdi3+0x40>
  802462:	66 90                	xchg   %ax,%ax
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	f3 0f 1e fb          	endbr32 
  802474:	55                   	push   %ebp
  802475:	57                   	push   %edi
  802476:	56                   	push   %esi
  802477:	53                   	push   %ebx
  802478:	83 ec 1c             	sub    $0x1c,%esp
  80247b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80247f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802483:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802487:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80248b:	89 f0                	mov    %esi,%eax
  80248d:	89 da                	mov    %ebx,%edx
  80248f:	85 ff                	test   %edi,%edi
  802491:	75 15                	jne    8024a8 <__umoddi3+0x38>
  802493:	39 dd                	cmp    %ebx,%ebp
  802495:	76 39                	jbe    8024d0 <__umoddi3+0x60>
  802497:	f7 f5                	div    %ebp
  802499:	89 d0                	mov    %edx,%eax
  80249b:	31 d2                	xor    %edx,%edx
  80249d:	83 c4 1c             	add    $0x1c,%esp
  8024a0:	5b                   	pop    %ebx
  8024a1:	5e                   	pop    %esi
  8024a2:	5f                   	pop    %edi
  8024a3:	5d                   	pop    %ebp
  8024a4:	c3                   	ret    
  8024a5:	8d 76 00             	lea    0x0(%esi),%esi
  8024a8:	39 df                	cmp    %ebx,%edi
  8024aa:	77 f1                	ja     80249d <__umoddi3+0x2d>
  8024ac:	0f bd cf             	bsr    %edi,%ecx
  8024af:	83 f1 1f             	xor    $0x1f,%ecx
  8024b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024b6:	75 40                	jne    8024f8 <__umoddi3+0x88>
  8024b8:	39 df                	cmp    %ebx,%edi
  8024ba:	72 04                	jb     8024c0 <__umoddi3+0x50>
  8024bc:	39 f5                	cmp    %esi,%ebp
  8024be:	77 dd                	ja     80249d <__umoddi3+0x2d>
  8024c0:	89 da                	mov    %ebx,%edx
  8024c2:	89 f0                	mov    %esi,%eax
  8024c4:	29 e8                	sub    %ebp,%eax
  8024c6:	19 fa                	sbb    %edi,%edx
  8024c8:	eb d3                	jmp    80249d <__umoddi3+0x2d>
  8024ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d0:	89 e9                	mov    %ebp,%ecx
  8024d2:	85 ed                	test   %ebp,%ebp
  8024d4:	75 0b                	jne    8024e1 <__umoddi3+0x71>
  8024d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	f7 f5                	div    %ebp
  8024df:	89 c1                	mov    %eax,%ecx
  8024e1:	89 d8                	mov    %ebx,%eax
  8024e3:	31 d2                	xor    %edx,%edx
  8024e5:	f7 f1                	div    %ecx
  8024e7:	89 f0                	mov    %esi,%eax
  8024e9:	f7 f1                	div    %ecx
  8024eb:	89 d0                	mov    %edx,%eax
  8024ed:	31 d2                	xor    %edx,%edx
  8024ef:	eb ac                	jmp    80249d <__umoddi3+0x2d>
  8024f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024fc:	ba 20 00 00 00       	mov    $0x20,%edx
  802501:	29 c2                	sub    %eax,%edx
  802503:	89 c1                	mov    %eax,%ecx
  802505:	89 e8                	mov    %ebp,%eax
  802507:	d3 e7                	shl    %cl,%edi
  802509:	89 d1                	mov    %edx,%ecx
  80250b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80250f:	d3 e8                	shr    %cl,%eax
  802511:	89 c1                	mov    %eax,%ecx
  802513:	8b 44 24 04          	mov    0x4(%esp),%eax
  802517:	09 f9                	or     %edi,%ecx
  802519:	89 df                	mov    %ebx,%edi
  80251b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80251f:	89 c1                	mov    %eax,%ecx
  802521:	d3 e5                	shl    %cl,%ebp
  802523:	89 d1                	mov    %edx,%ecx
  802525:	d3 ef                	shr    %cl,%edi
  802527:	89 c1                	mov    %eax,%ecx
  802529:	89 f0                	mov    %esi,%eax
  80252b:	d3 e3                	shl    %cl,%ebx
  80252d:	89 d1                	mov    %edx,%ecx
  80252f:	89 fa                	mov    %edi,%edx
  802531:	d3 e8                	shr    %cl,%eax
  802533:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802538:	09 d8                	or     %ebx,%eax
  80253a:	f7 74 24 08          	divl   0x8(%esp)
  80253e:	89 d3                	mov    %edx,%ebx
  802540:	d3 e6                	shl    %cl,%esi
  802542:	f7 e5                	mul    %ebp
  802544:	89 c7                	mov    %eax,%edi
  802546:	89 d1                	mov    %edx,%ecx
  802548:	39 d3                	cmp    %edx,%ebx
  80254a:	72 06                	jb     802552 <__umoddi3+0xe2>
  80254c:	75 0e                	jne    80255c <__umoddi3+0xec>
  80254e:	39 c6                	cmp    %eax,%esi
  802550:	73 0a                	jae    80255c <__umoddi3+0xec>
  802552:	29 e8                	sub    %ebp,%eax
  802554:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802558:	89 d1                	mov    %edx,%ecx
  80255a:	89 c7                	mov    %eax,%edi
  80255c:	89 f5                	mov    %esi,%ebp
  80255e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802562:	29 fd                	sub    %edi,%ebp
  802564:	19 cb                	sbb    %ecx,%ebx
  802566:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80256b:	89 d8                	mov    %ebx,%eax
  80256d:	d3 e0                	shl    %cl,%eax
  80256f:	89 f1                	mov    %esi,%ecx
  802571:	d3 ed                	shr    %cl,%ebp
  802573:	d3 eb                	shr    %cl,%ebx
  802575:	09 e8                	or     %ebp,%eax
  802577:	89 da                	mov    %ebx,%edx
  802579:	83 c4 1c             	add    $0x1c,%esp
  80257c:	5b                   	pop    %ebx
  80257d:	5e                   	pop    %esi
  80257e:	5f                   	pop    %edi
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    
