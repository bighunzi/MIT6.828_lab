
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
  80006f:	68 80 2a 80 00       	push   $0x802a80
  800074:	e8 53 04 00 00       	call   8004cc <cprintf>

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
  80009e:	68 48 2b 80 00       	push   $0x802b48
  8000a3:	e8 24 04 00 00       	call   8004cc <cprintf>
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
  8000c8:	68 84 2b 80 00       	push   $0x802b84
  8000cd:	e8 fa 03 00 00       	call   8004cc <cprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 bc 2a 80 00       	push   $0x802abc
  8000dd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 e1 09 00 00       	call   800aca <strcat>
	for (i = 0; i < argc; i++) {
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  8000f1:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	for (i = 0; i < argc; i++) {
  8000f7:	eb 52                	jmp    80014b <umain+0xeb>
		cprintf("init: data seems okay\n");
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	68 8f 2a 80 00       	push   $0x802a8f
  800101:	e8 c6 03 00 00       	call   8004cc <cprintf>
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	eb a0                	jmp    8000ab <umain+0x4b>
		cprintf("init: bss seems okay\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 a6 2a 80 00       	push   $0x802aa6
  800113:	e8 b4 03 00 00       	call   8004cc <cprintf>
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	eb b8                	jmp    8000d5 <umain+0x75>
		strcat(args, " '");
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 c8 2a 80 00       	push   $0x802ac8
  800125:	56                   	push   %esi
  800126:	e8 9f 09 00 00       	call   800aca <strcat>
		strcat(args, argv[i]);
  80012b:	83 c4 08             	add    $0x8,%esp
  80012e:	ff 34 9f             	push   (%edi,%ebx,4)
  800131:	56                   	push   %esi
  800132:	e8 93 09 00 00       	call   800aca <strcat>
		strcat(args, "'");
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	68 c9 2a 80 00       	push   $0x802ac9
  80013f:	56                   	push   %esi
  800140:	e8 85 09 00 00       	call   800aca <strcat>
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
  80015a:	68 cb 2a 80 00       	push   $0x802acb
  80015f:	e8 68 03 00 00       	call   8004cc <cprintf>

	cprintf("init: running sh\n");
  800164:	c7 04 24 cf 2a 80 00 	movl   $0x802acf,(%esp)
  80016b:	e8 5c 03 00 00       	call   8004cc <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800177:	e8 1c 11 00 00       	call   801298 <close>
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
  80018b:	68 fa 2a 80 00       	push   $0x802afa
  800190:	6a 39                	push   $0x39
  800192:	68 ee 2a 80 00       	push   $0x802aee
  800197:	e8 55 02 00 00       	call   8003f1 <_panic>
		panic("opencons: %e", r);
  80019c:	50                   	push   %eax
  80019d:	68 e1 2a 80 00       	push   $0x802ae1
  8001a2:	6a 37                	push   $0x37
  8001a4:	68 ee 2a 80 00       	push   $0x802aee
  8001a9:	e8 43 02 00 00       	call   8003f1 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 30 11 00 00       	call   8012ea <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 23                	jns    8001e4 <umain+0x184>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 14 2b 80 00       	push   $0x802b14
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ee 2a 80 00       	push   $0x802aee
  8001ce:	e8 1e 02 00 00       	call   8003f1 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
		r = spawnl("/sh", "sh", (char*)0);
		if (r < 0) {
			cprintf("init: spawn sh: %e\n", r);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	50                   	push   %eax
  8001d7:	68 33 2b 80 00       	push   $0x802b33
  8001dc:	e8 eb 02 00 00       	call   8004cc <cprintf>
			continue;
  8001e1:	83 c4 10             	add    $0x10,%esp
		cprintf("init: starting sh\n");
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	68 1c 2b 80 00       	push   $0x802b1c
  8001ec:	e8 db 02 00 00       	call   8004cc <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001f1:	83 c4 0c             	add    $0xc,%esp
  8001f4:	6a 00                	push   $0x0
  8001f6:	68 30 2b 80 00       	push   $0x802b30
  8001fb:	68 2f 2b 80 00       	push   $0x802b2f
  800200:	e8 47 1c 00 00       	call   801e4c <spawnl>
		if (r < 0) {
  800205:	83 c4 10             	add    $0x10,%esp
  800208:	85 c0                	test   %eax,%eax
  80020a:	78 c7                	js     8001d3 <umain+0x173>
		}
		wait(r);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	e8 8e 24 00 00       	call   8026a3 <wait>
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
  800226:	68 b3 2b 80 00       	push   $0x802bb3
  80022b:	ff 75 0c             	push   0xc(%ebp)
  80022e:	e8 73 08 00 00       	call   800aa6 <strcpy>
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
  80026d:	e8 ca 09 00 00       	call   800c3c <memmove>
		sys_cputs(buf, m);
  800272:	83 c4 08             	add    $0x8,%esp
  800275:	53                   	push   %ebx
  800276:	57                   	push   %edi
  800277:	e8 6a 0b 00 00       	call   800de6 <sys_cputs>
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
  8002a3:	e8 db 0b 00 00       	call   800e83 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8002a8:	e8 57 0b 00 00       	call   800e04 <sys_cgetc>
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
  8002dd:	e8 04 0b 00 00       	call   800de6 <sys_cputs>
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
  8002f5:	e8 da 10 00 00       	call   8013d4 <read>
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
  80031d:	e8 49 0e 00 00       	call   80116b <fd_lookup>
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
  800346:	e8 d0 0d 00 00       	call   80111b <fd_alloc>
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	85 c0                	test   %eax,%eax
  800350:	78 3a                	js     80038c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800352:	83 ec 04             	sub    $0x4,%esp
  800355:	68 07 04 00 00       	push   $0x407
  80035a:	ff 75 f4             	push   -0xc(%ebp)
  80035d:	6a 00                	push   $0x0
  80035f:	e8 3e 0b 00 00       	call   800ea2 <sys_page_alloc>
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
  800384:	e8 6b 0d 00 00       	call   8010f4 <fd2num>
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
  800399:	e8 c6 0a 00 00       	call   800e64 <sys_getenvid>
  80039e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003a3:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8003a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003ae:	a3 70 77 80 00       	mov    %eax,0x807770

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003b3:	85 db                	test   %ebx,%ebx
  8003b5:	7e 07                	jle    8003be <libmain+0x30>
		binaryname = argv[0];
  8003b7:	8b 06                	mov    (%esi),%eax
  8003b9:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003be:	83 ec 08             	sub    $0x8,%esp
  8003c1:	56                   	push   %esi
  8003c2:	53                   	push   %ebx
  8003c3:	e8 98 fc ff ff       	call   800060 <umain>

	// exit gracefully
	exit();
  8003c8:	e8 0a 00 00 00       	call   8003d7 <exit>
}
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003dd:	e8 e3 0e 00 00       	call   8012c5 <close_all>
	sys_env_destroy(0);
  8003e2:	83 ec 0c             	sub    $0xc,%esp
  8003e5:	6a 00                	push   $0x0
  8003e7:	e8 37 0a 00 00       	call   800e23 <sys_env_destroy>
}
  8003ec:	83 c4 10             	add    $0x10,%esp
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003f9:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  8003ff:	e8 60 0a 00 00       	call   800e64 <sys_getenvid>
  800404:	83 ec 0c             	sub    $0xc,%esp
  800407:	ff 75 0c             	push   0xc(%ebp)
  80040a:	ff 75 08             	push   0x8(%ebp)
  80040d:	56                   	push   %esi
  80040e:	50                   	push   %eax
  80040f:	68 cc 2b 80 00       	push   $0x802bcc
  800414:	e8 b3 00 00 00       	call   8004cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800419:	83 c4 18             	add    $0x18,%esp
  80041c:	53                   	push   %ebx
  80041d:	ff 75 10             	push   0x10(%ebp)
  800420:	e8 56 00 00 00       	call   80047b <vcprintf>
	cprintf("\n");
  800425:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  80042c:	e8 9b 00 00 00       	call   8004cc <cprintf>
  800431:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800434:	cc                   	int3   
  800435:	eb fd                	jmp    800434 <_panic+0x43>

00800437 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	53                   	push   %ebx
  80043b:	83 ec 04             	sub    $0x4,%esp
  80043e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800441:	8b 13                	mov    (%ebx),%edx
  800443:	8d 42 01             	lea    0x1(%edx),%eax
  800446:	89 03                	mov    %eax,(%ebx)
  800448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80044f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800454:	74 09                	je     80045f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800456:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80045a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	68 ff 00 00 00       	push   $0xff
  800467:	8d 43 08             	lea    0x8(%ebx),%eax
  80046a:	50                   	push   %eax
  80046b:	e8 76 09 00 00       	call   800de6 <sys_cputs>
		b->idx = 0;
  800470:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	eb db                	jmp    800456 <putch+0x1f>

0080047b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800484:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80048b:	00 00 00 
	b.cnt = 0;
  80048e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800495:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800498:	ff 75 0c             	push   0xc(%ebp)
  80049b:	ff 75 08             	push   0x8(%ebp)
  80049e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	68 37 04 80 00       	push   $0x800437
  8004aa:	e8 14 01 00 00       	call   8005c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004af:	83 c4 08             	add    $0x8,%esp
  8004b2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8004b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004be:	50                   	push   %eax
  8004bf:	e8 22 09 00 00       	call   800de6 <sys_cputs>

	return b.cnt;
}
  8004c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d5:	50                   	push   %eax
  8004d6:	ff 75 08             	push   0x8(%ebp)
  8004d9:	e8 9d ff ff ff       	call   80047b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 1c             	sub    $0x1c,%esp
  8004e9:	89 c7                	mov    %eax,%edi
  8004eb:	89 d6                	mov    %edx,%esi
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f3:	89 d1                	mov    %edx,%ecx
  8004f5:	89 c2                	mov    %eax,%edx
  8004f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800500:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800503:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800506:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80050d:	39 c2                	cmp    %eax,%edx
  80050f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800512:	72 3e                	jb     800552 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800514:	83 ec 0c             	sub    $0xc,%esp
  800517:	ff 75 18             	push   0x18(%ebp)
  80051a:	83 eb 01             	sub    $0x1,%ebx
  80051d:	53                   	push   %ebx
  80051e:	50                   	push   %eax
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 e4             	push   -0x1c(%ebp)
  800525:	ff 75 e0             	push   -0x20(%ebp)
  800528:	ff 75 dc             	push   -0x24(%ebp)
  80052b:	ff 75 d8             	push   -0x28(%ebp)
  80052e:	e8 0d 23 00 00       	call   802840 <__udivdi3>
  800533:	83 c4 18             	add    $0x18,%esp
  800536:	52                   	push   %edx
  800537:	50                   	push   %eax
  800538:	89 f2                	mov    %esi,%edx
  80053a:	89 f8                	mov    %edi,%eax
  80053c:	e8 9f ff ff ff       	call   8004e0 <printnum>
  800541:	83 c4 20             	add    $0x20,%esp
  800544:	eb 13                	jmp    800559 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	56                   	push   %esi
  80054a:	ff 75 18             	push   0x18(%ebp)
  80054d:	ff d7                	call   *%edi
  80054f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800552:	83 eb 01             	sub    $0x1,%ebx
  800555:	85 db                	test   %ebx,%ebx
  800557:	7f ed                	jg     800546 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	56                   	push   %esi
  80055d:	83 ec 04             	sub    $0x4,%esp
  800560:	ff 75 e4             	push   -0x1c(%ebp)
  800563:	ff 75 e0             	push   -0x20(%ebp)
  800566:	ff 75 dc             	push   -0x24(%ebp)
  800569:	ff 75 d8             	push   -0x28(%ebp)
  80056c:	e8 ef 23 00 00       	call   802960 <__umoddi3>
  800571:	83 c4 14             	add    $0x14,%esp
  800574:	0f be 80 ef 2b 80 00 	movsbl 0x802bef(%eax),%eax
  80057b:	50                   	push   %eax
  80057c:	ff d7                	call   *%edi
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800584:	5b                   	pop    %ebx
  800585:	5e                   	pop    %esi
  800586:	5f                   	pop    %edi
  800587:	5d                   	pop    %ebp
  800588:	c3                   	ret    

00800589 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80058f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800593:	8b 10                	mov    (%eax),%edx
  800595:	3b 50 04             	cmp    0x4(%eax),%edx
  800598:	73 0a                	jae    8005a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80059a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80059d:	89 08                	mov    %ecx,(%eax)
  80059f:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a2:	88 02                	mov    %al,(%edx)
}
  8005a4:	5d                   	pop    %ebp
  8005a5:	c3                   	ret    

008005a6 <printfmt>:
{
  8005a6:	55                   	push   %ebp
  8005a7:	89 e5                	mov    %esp,%ebp
  8005a9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005af:	50                   	push   %eax
  8005b0:	ff 75 10             	push   0x10(%ebp)
  8005b3:	ff 75 0c             	push   0xc(%ebp)
  8005b6:	ff 75 08             	push   0x8(%ebp)
  8005b9:	e8 05 00 00 00       	call   8005c3 <vprintfmt>
}
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	c9                   	leave  
  8005c2:	c3                   	ret    

008005c3 <vprintfmt>:
{
  8005c3:	55                   	push   %ebp
  8005c4:	89 e5                	mov    %esp,%ebp
  8005c6:	57                   	push   %edi
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	83 ec 3c             	sub    $0x3c,%esp
  8005cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005d5:	eb 0a                	jmp    8005e1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	50                   	push   %eax
  8005dc:	ff d6                	call   *%esi
  8005de:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005e1:	83 c7 01             	add    $0x1,%edi
  8005e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e8:	83 f8 25             	cmp    $0x25,%eax
  8005eb:	74 0c                	je     8005f9 <vprintfmt+0x36>
			if (ch == '\0')
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	75 e6                	jne    8005d7 <vprintfmt+0x14>
}
  8005f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f4:	5b                   	pop    %ebx
  8005f5:	5e                   	pop    %esi
  8005f6:	5f                   	pop    %edi
  8005f7:	5d                   	pop    %ebp
  8005f8:	c3                   	ret    
		padc = ' ';
  8005f9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005fd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800604:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80060b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8d 47 01             	lea    0x1(%edi),%eax
  80061a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80061d:	0f b6 17             	movzbl (%edi),%edx
  800620:	8d 42 dd             	lea    -0x23(%edx),%eax
  800623:	3c 55                	cmp    $0x55,%al
  800625:	0f 87 bb 03 00 00    	ja     8009e6 <vprintfmt+0x423>
  80062b:	0f b6 c0             	movzbl %al,%eax
  80062e:	ff 24 85 40 2d 80 00 	jmp    *0x802d40(,%eax,4)
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800638:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80063c:	eb d9                	jmp    800617 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800645:	eb d0                	jmp    800617 <vprintfmt+0x54>
  800647:	0f b6 d2             	movzbl %dl,%edx
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80064d:	b8 00 00 00 00       	mov    $0x0,%eax
  800652:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800655:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800658:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80065c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80065f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800662:	83 f9 09             	cmp    $0x9,%ecx
  800665:	77 55                	ja     8006bc <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800667:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80066a:	eb e9                	jmp    800655 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 40 04             	lea    0x4(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800680:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800684:	79 91                	jns    800617 <vprintfmt+0x54>
				width = precision, precision = -1;
  800686:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800689:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800693:	eb 82                	jmp    800617 <vprintfmt+0x54>
  800695:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800698:	85 d2                	test   %edx,%edx
  80069a:	b8 00 00 00 00       	mov    $0x0,%eax
  80069f:	0f 49 c2             	cmovns %edx,%eax
  8006a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006a8:	e9 6a ff ff ff       	jmp    800617 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006b0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8006b7:	e9 5b ff ff ff       	jmp    800617 <vprintfmt+0x54>
  8006bc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	eb bc                	jmp    800680 <vprintfmt+0xbd>
			lflag++;
  8006c4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006ca:	e9 48 ff ff ff       	jmp    800617 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 78 04             	lea    0x4(%eax),%edi
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	ff 30                	push   (%eax)
  8006db:	ff d6                	call   *%esi
			break;
  8006dd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006e0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006e3:	e9 9d 02 00 00       	jmp    800985 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 78 04             	lea    0x4(%eax),%edi
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	89 d0                	mov    %edx,%eax
  8006f2:	f7 d8                	neg    %eax
  8006f4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f7:	83 f8 0f             	cmp    $0xf,%eax
  8006fa:	7f 23                	jg     80071f <vprintfmt+0x15c>
  8006fc:	8b 14 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%edx
  800703:	85 d2                	test   %edx,%edx
  800705:	74 18                	je     80071f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800707:	52                   	push   %edx
  800708:	68 d5 2f 80 00       	push   $0x802fd5
  80070d:	53                   	push   %ebx
  80070e:	56                   	push   %esi
  80070f:	e8 92 fe ff ff       	call   8005a6 <printfmt>
  800714:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800717:	89 7d 14             	mov    %edi,0x14(%ebp)
  80071a:	e9 66 02 00 00       	jmp    800985 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80071f:	50                   	push   %eax
  800720:	68 07 2c 80 00       	push   $0x802c07
  800725:	53                   	push   %ebx
  800726:	56                   	push   %esi
  800727:	e8 7a fe ff ff       	call   8005a6 <printfmt>
  80072c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80072f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800732:	e9 4e 02 00 00       	jmp    800985 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	83 c0 04             	add    $0x4,%eax
  80073d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800745:	85 d2                	test   %edx,%edx
  800747:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  80074c:	0f 45 c2             	cmovne %edx,%eax
  80074f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800752:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800756:	7e 06                	jle    80075e <vprintfmt+0x19b>
  800758:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80075c:	75 0d                	jne    80076b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80075e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800761:	89 c7                	mov    %eax,%edi
  800763:	03 45 e0             	add    -0x20(%ebp),%eax
  800766:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800769:	eb 55                	jmp    8007c0 <vprintfmt+0x1fd>
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	ff 75 d8             	push   -0x28(%ebp)
  800771:	ff 75 cc             	push   -0x34(%ebp)
  800774:	e8 0a 03 00 00       	call   800a83 <strnlen>
  800779:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80077c:	29 c1                	sub    %eax,%ecx
  80077e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800786:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80078a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80078d:	eb 0f                	jmp    80079e <vprintfmt+0x1db>
					putch(padc, putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	53                   	push   %ebx
  800793:	ff 75 e0             	push   -0x20(%ebp)
  800796:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800798:	83 ef 01             	sub    $0x1,%edi
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	85 ff                	test   %edi,%edi
  8007a0:	7f ed                	jg     80078f <vprintfmt+0x1cc>
  8007a2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ac:	0f 49 c2             	cmovns %edx,%eax
  8007af:	29 c2                	sub    %eax,%edx
  8007b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007b4:	eb a8                	jmp    80075e <vprintfmt+0x19b>
					putch(ch, putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	52                   	push   %edx
  8007bb:	ff d6                	call   *%esi
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007c3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c5:	83 c7 01             	add    $0x1,%edi
  8007c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007cc:	0f be d0             	movsbl %al,%edx
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	74 4b                	je     80081e <vprintfmt+0x25b>
  8007d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d7:	78 06                	js     8007df <vprintfmt+0x21c>
  8007d9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8007dd:	78 1e                	js     8007fd <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8007df:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007e3:	74 d1                	je     8007b6 <vprintfmt+0x1f3>
  8007e5:	0f be c0             	movsbl %al,%eax
  8007e8:	83 e8 20             	sub    $0x20,%eax
  8007eb:	83 f8 5e             	cmp    $0x5e,%eax
  8007ee:	76 c6                	jbe    8007b6 <vprintfmt+0x1f3>
					putch('?', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	53                   	push   %ebx
  8007f4:	6a 3f                	push   $0x3f
  8007f6:	ff d6                	call   *%esi
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	eb c3                	jmp    8007c0 <vprintfmt+0x1fd>
  8007fd:	89 cf                	mov    %ecx,%edi
  8007ff:	eb 0e                	jmp    80080f <vprintfmt+0x24c>
				putch(' ', putdat);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	53                   	push   %ebx
  800805:	6a 20                	push   $0x20
  800807:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800809:	83 ef 01             	sub    $0x1,%edi
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	85 ff                	test   %edi,%edi
  800811:	7f ee                	jg     800801 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800813:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
  800819:	e9 67 01 00 00       	jmp    800985 <vprintfmt+0x3c2>
  80081e:	89 cf                	mov    %ecx,%edi
  800820:	eb ed                	jmp    80080f <vprintfmt+0x24c>
	if (lflag >= 2)
  800822:	83 f9 01             	cmp    $0x1,%ecx
  800825:	7f 1b                	jg     800842 <vprintfmt+0x27f>
	else if (lflag)
  800827:	85 c9                	test   %ecx,%ecx
  800829:	74 63                	je     80088e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800833:	99                   	cltd   
  800834:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8d 40 04             	lea    0x4(%eax),%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
  800840:	eb 17                	jmp    800859 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 50 04             	mov    0x4(%eax),%edx
  800848:	8b 00                	mov    (%eax),%eax
  80084a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 40 08             	lea    0x8(%eax),%eax
  800856:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800859:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80085c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80085f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800864:	85 c9                	test   %ecx,%ecx
  800866:	0f 89 ff 00 00 00    	jns    80096b <vprintfmt+0x3a8>
				putch('-', putdat);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 2d                	push   $0x2d
  800872:	ff d6                	call   *%esi
				num = -(long long) num;
  800874:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800877:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80087a:	f7 da                	neg    %edx
  80087c:	83 d1 00             	adc    $0x0,%ecx
  80087f:	f7 d9                	neg    %ecx
  800881:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800884:	bf 0a 00 00 00       	mov    $0xa,%edi
  800889:	e9 dd 00 00 00       	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8b 00                	mov    (%eax),%eax
  800893:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800896:	99                   	cltd   
  800897:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8d 40 04             	lea    0x4(%eax),%eax
  8008a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a3:	eb b4                	jmp    800859 <vprintfmt+0x296>
	if (lflag >= 2)
  8008a5:	83 f9 01             	cmp    $0x1,%ecx
  8008a8:	7f 1e                	jg     8008c8 <vprintfmt+0x305>
	else if (lflag)
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 32                	je     8008e0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8b 10                	mov    (%eax),%edx
  8008b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b8:	8d 40 04             	lea    0x4(%eax),%eax
  8008bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008be:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8008c3:	e9 a3 00 00 00       	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8b 10                	mov    (%eax),%edx
  8008cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d0:	8d 40 08             	lea    0x8(%eax),%eax
  8008d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008d6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8008db:	e9 8b 00 00 00       	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8b 10                	mov    (%eax),%edx
  8008e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ea:	8d 40 04             	lea    0x4(%eax),%eax
  8008ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008f0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8008f5:	eb 74                	jmp    80096b <vprintfmt+0x3a8>
	if (lflag >= 2)
  8008f7:	83 f9 01             	cmp    $0x1,%ecx
  8008fa:	7f 1b                	jg     800917 <vprintfmt+0x354>
	else if (lflag)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 2c                	je     80092c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8b 10                	mov    (%eax),%edx
  800905:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090a:	8d 40 04             	lea    0x4(%eax),%eax
  80090d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800910:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800915:	eb 54                	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8b 10                	mov    (%eax),%edx
  80091c:	8b 48 04             	mov    0x4(%eax),%ecx
  80091f:	8d 40 08             	lea    0x8(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800925:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80092a:	eb 3f                	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8b 10                	mov    (%eax),%edx
  800931:	b9 00 00 00 00       	mov    $0x0,%ecx
  800936:	8d 40 04             	lea    0x4(%eax),%eax
  800939:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80093c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800941:	eb 28                	jmp    80096b <vprintfmt+0x3a8>
			putch('0', putdat);
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	53                   	push   %ebx
  800947:	6a 30                	push   $0x30
  800949:	ff d6                	call   *%esi
			putch('x', putdat);
  80094b:	83 c4 08             	add    $0x8,%esp
  80094e:	53                   	push   %ebx
  80094f:	6a 78                	push   $0x78
  800951:	ff d6                	call   *%esi
			num = (unsigned long long)
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8b 10                	mov    (%eax),%edx
  800958:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80095d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800960:	8d 40 04             	lea    0x4(%eax),%eax
  800963:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800966:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80096b:	83 ec 0c             	sub    $0xc,%esp
  80096e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800972:	50                   	push   %eax
  800973:	ff 75 e0             	push   -0x20(%ebp)
  800976:	57                   	push   %edi
  800977:	51                   	push   %ecx
  800978:	52                   	push   %edx
  800979:	89 da                	mov    %ebx,%edx
  80097b:	89 f0                	mov    %esi,%eax
  80097d:	e8 5e fb ff ff       	call   8004e0 <printnum>
			break;
  800982:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800985:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800988:	e9 54 fc ff ff       	jmp    8005e1 <vprintfmt+0x1e>
	if (lflag >= 2)
  80098d:	83 f9 01             	cmp    $0x1,%ecx
  800990:	7f 1b                	jg     8009ad <vprintfmt+0x3ea>
	else if (lflag)
  800992:	85 c9                	test   %ecx,%ecx
  800994:	74 2c                	je     8009c2 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800996:	8b 45 14             	mov    0x14(%ebp),%eax
  800999:	8b 10                	mov    (%eax),%edx
  80099b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a0:	8d 40 04             	lea    0x4(%eax),%eax
  8009a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8009ab:	eb be                	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b0:	8b 10                	mov    (%eax),%edx
  8009b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8009b5:	8d 40 08             	lea    0x8(%eax),%eax
  8009b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009bb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8009c0:	eb a9                	jmp    80096b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8b 10                	mov    (%eax),%edx
  8009c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009cc:	8d 40 04             	lea    0x4(%eax),%eax
  8009cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009d2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8009d7:	eb 92                	jmp    80096b <vprintfmt+0x3a8>
			putch(ch, putdat);
  8009d9:	83 ec 08             	sub    $0x8,%esp
  8009dc:	53                   	push   %ebx
  8009dd:	6a 25                	push   $0x25
  8009df:	ff d6                	call   *%esi
			break;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	eb 9f                	jmp    800985 <vprintfmt+0x3c2>
			putch('%', putdat);
  8009e6:	83 ec 08             	sub    $0x8,%esp
  8009e9:	53                   	push   %ebx
  8009ea:	6a 25                	push   $0x25
  8009ec:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009ee:	83 c4 10             	add    $0x10,%esp
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009f7:	74 05                	je     8009fe <vprintfmt+0x43b>
  8009f9:	83 e8 01             	sub    $0x1,%eax
  8009fc:	eb f5                	jmp    8009f3 <vprintfmt+0x430>
  8009fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a01:	eb 82                	jmp    800985 <vprintfmt+0x3c2>

00800a03 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	83 ec 18             	sub    $0x18,%esp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a12:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a16:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a20:	85 c0                	test   %eax,%eax
  800a22:	74 26                	je     800a4a <vsnprintf+0x47>
  800a24:	85 d2                	test   %edx,%edx
  800a26:	7e 22                	jle    800a4a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a28:	ff 75 14             	push   0x14(%ebp)
  800a2b:	ff 75 10             	push   0x10(%ebp)
  800a2e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a31:	50                   	push   %eax
  800a32:	68 89 05 80 00       	push   $0x800589
  800a37:	e8 87 fb ff ff       	call   8005c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a3f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a45:	83 c4 10             	add    $0x10,%esp
}
  800a48:	c9                   	leave  
  800a49:	c3                   	ret    
		return -E_INVAL;
  800a4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a4f:	eb f7                	jmp    800a48 <vsnprintf+0x45>

00800a51 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a57:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a5a:	50                   	push   %eax
  800a5b:	ff 75 10             	push   0x10(%ebp)
  800a5e:	ff 75 0c             	push   0xc(%ebp)
  800a61:	ff 75 08             	push   0x8(%ebp)
  800a64:	e8 9a ff ff ff       	call   800a03 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	eb 03                	jmp    800a7b <strlen+0x10>
		n++;
  800a78:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a7b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a7f:	75 f7                	jne    800a78 <strlen+0xd>
	return n;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	eb 03                	jmp    800a96 <strnlen+0x13>
		n++;
  800a93:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a96:	39 d0                	cmp    %edx,%eax
  800a98:	74 08                	je     800aa2 <strnlen+0x1f>
  800a9a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a9e:	75 f3                	jne    800a93 <strnlen+0x10>
  800aa0:	89 c2                	mov    %eax,%edx
	return n;
}
  800aa2:	89 d0                	mov    %edx,%eax
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	53                   	push   %ebx
  800aaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800ab9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800abc:	83 c0 01             	add    $0x1,%eax
  800abf:	84 d2                	test   %dl,%dl
  800ac1:	75 f2                	jne    800ab5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac3:	89 c8                	mov    %ecx,%eax
  800ac5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    

00800aca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	53                   	push   %ebx
  800ace:	83 ec 10             	sub    $0x10,%esp
  800ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad4:	53                   	push   %ebx
  800ad5:	e8 91 ff ff ff       	call   800a6b <strlen>
  800ada:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800add:	ff 75 0c             	push   0xc(%ebp)
  800ae0:	01 d8                	add    %ebx,%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 be ff ff ff       	call   800aa6 <strcpy>
	return dst;
}
  800ae8:	89 d8                	mov    %ebx,%eax
  800aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 75 08             	mov    0x8(%ebp),%esi
  800af7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aff:	89 f0                	mov    %esi,%eax
  800b01:	eb 0f                	jmp    800b12 <strncpy+0x23>
		*dst++ = *src;
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	0f b6 0a             	movzbl (%edx),%ecx
  800b09:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0c:	80 f9 01             	cmp    $0x1,%cl
  800b0f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800b12:	39 d8                	cmp    %ebx,%eax
  800b14:	75 ed                	jne    800b03 <strncpy+0x14>
	}
	return ret;
}
  800b16:	89 f0                	mov    %esi,%eax
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	8b 75 08             	mov    0x8(%ebp),%esi
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b27:	8b 55 10             	mov    0x10(%ebp),%edx
  800b2a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b2c:	85 d2                	test   %edx,%edx
  800b2e:	74 21                	je     800b51 <strlcpy+0x35>
  800b30:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b34:	89 f2                	mov    %esi,%edx
  800b36:	eb 09                	jmp    800b41 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b38:	83 c1 01             	add    $0x1,%ecx
  800b3b:	83 c2 01             	add    $0x1,%edx
  800b3e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800b41:	39 c2                	cmp    %eax,%edx
  800b43:	74 09                	je     800b4e <strlcpy+0x32>
  800b45:	0f b6 19             	movzbl (%ecx),%ebx
  800b48:	84 db                	test   %bl,%bl
  800b4a:	75 ec                	jne    800b38 <strlcpy+0x1c>
  800b4c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b4e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b51:	29 f0                	sub    %esi,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b60:	eb 06                	jmp    800b68 <strcmp+0x11>
		p++, q++;
  800b62:	83 c1 01             	add    $0x1,%ecx
  800b65:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b68:	0f b6 01             	movzbl (%ecx),%eax
  800b6b:	84 c0                	test   %al,%al
  800b6d:	74 04                	je     800b73 <strcmp+0x1c>
  800b6f:	3a 02                	cmp    (%edx),%al
  800b71:	74 ef                	je     800b62 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b73:	0f b6 c0             	movzbl %al,%eax
  800b76:	0f b6 12             	movzbl (%edx),%edx
  800b79:	29 d0                	sub    %edx,%eax
}
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	53                   	push   %ebx
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b87:	89 c3                	mov    %eax,%ebx
  800b89:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b8c:	eb 06                	jmp    800b94 <strncmp+0x17>
		n--, p++, q++;
  800b8e:	83 c0 01             	add    $0x1,%eax
  800b91:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b94:	39 d8                	cmp    %ebx,%eax
  800b96:	74 18                	je     800bb0 <strncmp+0x33>
  800b98:	0f b6 08             	movzbl (%eax),%ecx
  800b9b:	84 c9                	test   %cl,%cl
  800b9d:	74 04                	je     800ba3 <strncmp+0x26>
  800b9f:	3a 0a                	cmp    (%edx),%cl
  800ba1:	74 eb                	je     800b8e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba3:	0f b6 00             	movzbl (%eax),%eax
  800ba6:	0f b6 12             	movzbl (%edx),%edx
  800ba9:	29 d0                	sub    %edx,%eax
}
  800bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    
		return 0;
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	eb f4                	jmp    800bab <strncmp+0x2e>

00800bb7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc1:	eb 03                	jmp    800bc6 <strchr+0xf>
  800bc3:	83 c0 01             	add    $0x1,%eax
  800bc6:	0f b6 10             	movzbl (%eax),%edx
  800bc9:	84 d2                	test   %dl,%dl
  800bcb:	74 06                	je     800bd3 <strchr+0x1c>
		if (*s == c)
  800bcd:	38 ca                	cmp    %cl,%dl
  800bcf:	75 f2                	jne    800bc3 <strchr+0xc>
  800bd1:	eb 05                	jmp    800bd8 <strchr+0x21>
			return (char *) s;
	return 0;
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be7:	38 ca                	cmp    %cl,%dl
  800be9:	74 09                	je     800bf4 <strfind+0x1a>
  800beb:	84 d2                	test   %dl,%dl
  800bed:	74 05                	je     800bf4 <strfind+0x1a>
	for (; *s; s++)
  800bef:	83 c0 01             	add    $0x1,%eax
  800bf2:	eb f0                	jmp    800be4 <strfind+0xa>
			break;
	return (char *) s;
}
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c02:	85 c9                	test   %ecx,%ecx
  800c04:	74 2f                	je     800c35 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c06:	89 f8                	mov    %edi,%eax
  800c08:	09 c8                	or     %ecx,%eax
  800c0a:	a8 03                	test   $0x3,%al
  800c0c:	75 21                	jne    800c2f <memset+0x39>
		c &= 0xFF;
  800c0e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	c1 e0 08             	shl    $0x8,%eax
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	c1 e3 18             	shl    $0x18,%ebx
  800c1c:	89 d6                	mov    %edx,%esi
  800c1e:	c1 e6 10             	shl    $0x10,%esi
  800c21:	09 f3                	or     %esi,%ebx
  800c23:	09 da                	or     %ebx,%edx
  800c25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c27:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c2a:	fc                   	cld    
  800c2b:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2d:	eb 06                	jmp    800c35 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	fc                   	cld    
  800c33:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c35:	89 f8                	mov    %edi,%eax
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c4a:	39 c6                	cmp    %eax,%esi
  800c4c:	73 32                	jae    800c80 <memmove+0x44>
  800c4e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c51:	39 c2                	cmp    %eax,%edx
  800c53:	76 2b                	jbe    800c80 <memmove+0x44>
		s += n;
		d += n;
  800c55:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	09 fe                	or     %edi,%esi
  800c5c:	09 ce                	or     %ecx,%esi
  800c5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c64:	75 0e                	jne    800c74 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c66:	83 ef 04             	sub    $0x4,%edi
  800c69:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c6c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c6f:	fd                   	std    
  800c70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c72:	eb 09                	jmp    800c7d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c74:	83 ef 01             	sub    $0x1,%edi
  800c77:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c7a:	fd                   	std    
  800c7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7d:	fc                   	cld    
  800c7e:	eb 1a                	jmp    800c9a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c80:	89 f2                	mov    %esi,%edx
  800c82:	09 c2                	or     %eax,%edx
  800c84:	09 ca                	or     %ecx,%edx
  800c86:	f6 c2 03             	test   $0x3,%dl
  800c89:	75 0a                	jne    800c95 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c8b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c8e:	89 c7                	mov    %eax,%edi
  800c90:	fc                   	cld    
  800c91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c93:	eb 05                	jmp    800c9a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800c95:	89 c7                	mov    %eax,%edi
  800c97:	fc                   	cld    
  800c98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca4:	ff 75 10             	push   0x10(%ebp)
  800ca7:	ff 75 0c             	push   0xc(%ebp)
  800caa:	ff 75 08             	push   0x8(%ebp)
  800cad:	e8 8a ff ff ff       	call   800c3c <memmove>
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbf:	89 c6                	mov    %eax,%esi
  800cc1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc4:	eb 06                	jmp    800ccc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc6:	83 c0 01             	add    $0x1,%eax
  800cc9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ccc:	39 f0                	cmp    %esi,%eax
  800cce:	74 14                	je     800ce4 <memcmp+0x30>
		if (*s1 != *s2)
  800cd0:	0f b6 08             	movzbl (%eax),%ecx
  800cd3:	0f b6 1a             	movzbl (%edx),%ebx
  800cd6:	38 d9                	cmp    %bl,%cl
  800cd8:	74 ec                	je     800cc6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800cda:	0f b6 c1             	movzbl %cl,%eax
  800cdd:	0f b6 db             	movzbl %bl,%ebx
  800ce0:	29 d8                	sub    %ebx,%eax
  800ce2:	eb 05                	jmp    800ce9 <memcmp+0x35>
	}

	return 0;
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf6:	89 c2                	mov    %eax,%edx
  800cf8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfb:	eb 03                	jmp    800d00 <memfind+0x13>
  800cfd:	83 c0 01             	add    $0x1,%eax
  800d00:	39 d0                	cmp    %edx,%eax
  800d02:	73 04                	jae    800d08 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d04:	38 08                	cmp    %cl,(%eax)
  800d06:	75 f5                	jne    800cfd <memfind+0x10>
			break;
	return (void *) s;
}
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d16:	eb 03                	jmp    800d1b <strtol+0x11>
		s++;
  800d18:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d1b:	0f b6 02             	movzbl (%edx),%eax
  800d1e:	3c 20                	cmp    $0x20,%al
  800d20:	74 f6                	je     800d18 <strtol+0xe>
  800d22:	3c 09                	cmp    $0x9,%al
  800d24:	74 f2                	je     800d18 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d26:	3c 2b                	cmp    $0x2b,%al
  800d28:	74 2a                	je     800d54 <strtol+0x4a>
	int neg = 0;
  800d2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d2f:	3c 2d                	cmp    $0x2d,%al
  800d31:	74 2b                	je     800d5e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d39:	75 0f                	jne    800d4a <strtol+0x40>
  800d3b:	80 3a 30             	cmpb   $0x30,(%edx)
  800d3e:	74 28                	je     800d68 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d40:	85 db                	test   %ebx,%ebx
  800d42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d47:	0f 44 d8             	cmove  %eax,%ebx
  800d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d52:	eb 46                	jmp    800d9a <strtol+0x90>
		s++;
  800d54:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d57:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5c:	eb d5                	jmp    800d33 <strtol+0x29>
		s++, neg = 1;
  800d5e:	83 c2 01             	add    $0x1,%edx
  800d61:	bf 01 00 00 00       	mov    $0x1,%edi
  800d66:	eb cb                	jmp    800d33 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d68:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d6c:	74 0e                	je     800d7c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800d6e:	85 db                	test   %ebx,%ebx
  800d70:	75 d8                	jne    800d4a <strtol+0x40>
		s++, base = 8;
  800d72:	83 c2 01             	add    $0x1,%edx
  800d75:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d7a:	eb ce                	jmp    800d4a <strtol+0x40>
		s += 2, base = 16;
  800d7c:	83 c2 02             	add    $0x2,%edx
  800d7f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d84:	eb c4                	jmp    800d4a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d86:	0f be c0             	movsbl %al,%eax
  800d89:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d8c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d8f:	7d 3a                	jge    800dcb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d91:	83 c2 01             	add    $0x1,%edx
  800d94:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800d98:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800d9a:	0f b6 02             	movzbl (%edx),%eax
  800d9d:	8d 70 d0             	lea    -0x30(%eax),%esi
  800da0:	89 f3                	mov    %esi,%ebx
  800da2:	80 fb 09             	cmp    $0x9,%bl
  800da5:	76 df                	jbe    800d86 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800da7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800daa:	89 f3                	mov    %esi,%ebx
  800dac:	80 fb 19             	cmp    $0x19,%bl
  800daf:	77 08                	ja     800db9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800db1:	0f be c0             	movsbl %al,%eax
  800db4:	83 e8 57             	sub    $0x57,%eax
  800db7:	eb d3                	jmp    800d8c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800db9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800dbc:	89 f3                	mov    %esi,%ebx
  800dbe:	80 fb 19             	cmp    $0x19,%bl
  800dc1:	77 08                	ja     800dcb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800dc3:	0f be c0             	movsbl %al,%eax
  800dc6:	83 e8 37             	sub    $0x37,%eax
  800dc9:	eb c1                	jmp    800d8c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dcb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcf:	74 05                	je     800dd6 <strtol+0xcc>
		*endptr = (char *) s;
  800dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dd6:	89 c8                	mov    %ecx,%eax
  800dd8:	f7 d8                	neg    %eax
  800dda:	85 ff                	test   %edi,%edi
  800ddc:	0f 45 c8             	cmovne %eax,%ecx
}
  800ddf:	89 c8                	mov    %ecx,%eax
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	89 c7                	mov    %eax,%edi
  800dfb:	89 c6                	mov    %eax,%esi
  800dfd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e14:	89 d1                	mov    %edx,%ecx
  800e16:	89 d3                	mov    %edx,%ebx
  800e18:	89 d7                	mov    %edx,%edi
  800e1a:	89 d6                	mov    %edx,%esi
  800e1c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	b8 03 00 00 00       	mov    $0x3,%eax
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7f 08                	jg     800e4d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	6a 03                	push   $0x3
  800e53:	68 ff 2e 80 00       	push   $0x802eff
  800e58:	6a 2a                	push   $0x2a
  800e5a:	68 1c 2f 80 00       	push   $0x802f1c
  800e5f:	e8 8d f5 ff ff       	call   8003f1 <_panic>

00800e64 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e74:	89 d1                	mov    %edx,%ecx
  800e76:	89 d3                	mov    %edx,%ebx
  800e78:	89 d7                	mov    %edx,%edi
  800e7a:	89 d6                	mov    %edx,%esi
  800e7c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_yield>:

void
sys_yield(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e93:	89 d1                	mov    %edx,%ecx
  800e95:	89 d3                	mov    %edx,%ebx
  800e97:	89 d7                	mov    %edx,%edi
  800e99:	89 d6                	mov    %edx,%esi
  800e9b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eab:	be 00 00 00 00       	mov    $0x0,%esi
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebe:	89 f7                	mov    %esi,%edi
  800ec0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7f 08                	jg     800ece <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	6a 04                	push   $0x4
  800ed4:	68 ff 2e 80 00       	push   $0x802eff
  800ed9:	6a 2a                	push   $0x2a
  800edb:	68 1c 2f 80 00       	push   $0x802f1c
  800ee0:	e8 0c f5 ff ff       	call   8003f1 <_panic>

00800ee5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eff:	8b 75 18             	mov    0x18(%ebp),%esi
  800f02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7f 08                	jg     800f10 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 05                	push   $0x5
  800f16:	68 ff 2e 80 00       	push   $0x802eff
  800f1b:	6a 2a                	push   $0x2a
  800f1d:	68 1c 2f 80 00       	push   $0x802f1c
  800f22:	e8 ca f4 ff ff       	call   8003f1 <_panic>

00800f27 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	8b 55 08             	mov    0x8(%ebp),%edx
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7f 08                	jg     800f52 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	50                   	push   %eax
  800f56:	6a 06                	push   $0x6
  800f58:	68 ff 2e 80 00       	push   $0x802eff
  800f5d:	6a 2a                	push   $0x2a
  800f5f:	68 1c 2f 80 00       	push   $0x802f1c
  800f64:	e8 88 f4 ff ff       	call   8003f1 <_panic>

00800f69 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f77:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f82:	89 df                	mov    %ebx,%edi
  800f84:	89 de                	mov    %ebx,%esi
  800f86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7f 08                	jg     800f94 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	50                   	push   %eax
  800f98:	6a 08                	push   $0x8
  800f9a:	68 ff 2e 80 00       	push   $0x802eff
  800f9f:	6a 2a                	push   $0x2a
  800fa1:	68 1c 2f 80 00       	push   $0x802f1c
  800fa6:	e8 46 f4 ff ff       	call   8003f1 <_panic>

00800fab <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc4:	89 df                	mov    %ebx,%edi
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7f 08                	jg     800fd6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	6a 09                	push   $0x9
  800fdc:	68 ff 2e 80 00       	push   $0x802eff
  800fe1:	6a 2a                	push   $0x2a
  800fe3:	68 1c 2f 80 00       	push   $0x802f1c
  800fe8:	e8 04 f4 ff ff       	call   8003f1 <_panic>

00800fed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801001:	b8 0a 00 00 00       	mov    $0xa,%eax
  801006:	89 df                	mov    %ebx,%edi
  801008:	89 de                	mov    %ebx,%esi
  80100a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7f 08                	jg     801018 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	50                   	push   %eax
  80101c:	6a 0a                	push   $0xa
  80101e:	68 ff 2e 80 00       	push   $0x802eff
  801023:	6a 2a                	push   $0x2a
  801025:	68 1c 2f 80 00       	push   $0x802f1c
  80102a:	e8 c2 f3 ff ff       	call   8003f1 <_panic>

0080102f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	asm volatile("int %1\n"
  801035:	8b 55 08             	mov    0x8(%ebp),%edx
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801040:	be 00 00 00 00       	mov    $0x0,%esi
  801045:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801048:	8b 7d 14             	mov    0x14(%ebp),%edi
  80104b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80105b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	b8 0d 00 00 00       	mov    $0xd,%eax
  801068:	89 cb                	mov    %ecx,%ebx
  80106a:	89 cf                	mov    %ecx,%edi
  80106c:	89 ce                	mov    %ecx,%esi
  80106e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801070:	85 c0                	test   %eax,%eax
  801072:	7f 08                	jg     80107c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801074:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	6a 0d                	push   $0xd
  801082:	68 ff 2e 80 00       	push   $0x802eff
  801087:	6a 2a                	push   $0x2a
  801089:	68 1c 2f 80 00       	push   $0x802f1c
  80108e:	e8 5e f3 ff ff       	call   8003f1 <_panic>

00801093 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
	asm volatile("int %1\n"
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 d3                	mov    %edx,%ebx
  8010a7:	89 d7                	mov    %edx,%edi
  8010a9:	89 d6                	mov    %edx,%esi
  8010ab:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c3:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010c8:	89 df                	mov    %ebx,%edi
  8010ca:	89 de                	mov    %ebx,%esi
  8010cc:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8010e9:	89 df                	mov    %ebx,%edi
  8010eb:	89 de                	mov    %ebx,%esi
  8010ed:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80110f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801114:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 16             	shr    $0x16,%edx
  801128:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	74 29                	je     80115d <fd_alloc+0x42>
  801134:	89 c2                	mov    %eax,%edx
  801136:	c1 ea 0c             	shr    $0xc,%edx
  801139:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	74 18                	je     80115d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801145:	05 00 10 00 00       	add    $0x1000,%eax
  80114a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114f:	75 d2                	jne    801123 <fd_alloc+0x8>
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801156:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80115b:	eb 05                	jmp    801162 <fd_alloc+0x47>
			return 0;
  80115d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801162:	8b 55 08             	mov    0x8(%ebp),%edx
  801165:	89 02                	mov    %eax,(%edx)
}
  801167:	89 c8                	mov    %ecx,%eax
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801171:	83 f8 1f             	cmp    $0x1f,%eax
  801174:	77 30                	ja     8011a6 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801176:	c1 e0 0c             	shl    $0xc,%eax
  801179:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80117e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801184:	f6 c2 01             	test   $0x1,%dl
  801187:	74 24                	je     8011ad <fd_lookup+0x42>
  801189:	89 c2                	mov    %eax,%edx
  80118b:	c1 ea 0c             	shr    $0xc,%edx
  80118e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	74 1a                	je     8011b4 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80119a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119d:	89 02                	mov    %eax,(%edx)
	return 0;
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    
		return -E_INVAL;
  8011a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ab:	eb f7                	jmp    8011a4 <fd_lookup+0x39>
		return -E_INVAL;
  8011ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b2:	eb f0                	jmp    8011a4 <fd_lookup+0x39>
  8011b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b9:	eb e9                	jmp    8011a4 <fd_lookup+0x39>

008011bb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	bb 90 57 80 00       	mov    $0x805790,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011cf:	39 13                	cmp    %edx,(%ebx)
  8011d1:	74 37                	je     80120a <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8011d3:	83 c0 01             	add    $0x1,%eax
  8011d6:	8b 1c 85 a8 2f 80 00 	mov    0x802fa8(,%eax,4),%ebx
  8011dd:	85 db                	test   %ebx,%ebx
  8011df:	75 ee                	jne    8011cf <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e1:	a1 70 77 80 00       	mov    0x807770,%eax
  8011e6:	8b 40 58             	mov    0x58(%eax),%eax
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	52                   	push   %edx
  8011ed:	50                   	push   %eax
  8011ee:	68 2c 2f 80 00       	push   $0x802f2c
  8011f3:	e8 d4 f2 ff ff       	call   8004cc <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801200:	8b 55 0c             	mov    0xc(%ebp),%edx
  801203:	89 1a                	mov    %ebx,(%edx)
}
  801205:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801208:	c9                   	leave  
  801209:	c3                   	ret    
			return 0;
  80120a:	b8 00 00 00 00       	mov    $0x0,%eax
  80120f:	eb ef                	jmp    801200 <dev_lookup+0x45>

00801211 <fd_close>:
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 24             	sub    $0x24,%esp
  80121a:	8b 75 08             	mov    0x8(%ebp),%esi
  80121d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801220:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801223:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801224:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80122a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122d:	50                   	push   %eax
  80122e:	e8 38 ff ff ff       	call   80116b <fd_lookup>
  801233:	89 c3                	mov    %eax,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 05                	js     801241 <fd_close+0x30>
	    || fd != fd2)
  80123c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80123f:	74 16                	je     801257 <fd_close+0x46>
		return (must_exist ? r : 0);
  801241:	89 f8                	mov    %edi,%eax
  801243:	84 c0                	test   %al,%al
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	0f 44 d8             	cmove  %eax,%ebx
}
  80124d:	89 d8                	mov    %ebx,%eax
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	ff 36                	push   (%esi)
  801260:	e8 56 ff ff ff       	call   8011bb <dev_lookup>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 1a                	js     801288 <fd_close+0x77>
		if (dev->dev_close)
  80126e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801271:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801274:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801279:	85 c0                	test   %eax,%eax
  80127b:	74 0b                	je     801288 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	56                   	push   %esi
  801281:	ff d0                	call   *%eax
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	56                   	push   %esi
  80128c:	6a 00                	push   $0x0
  80128e:	e8 94 fc ff ff       	call   800f27 <sys_page_unmap>
	return r;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb b5                	jmp    80124d <fd_close+0x3c>

00801298 <close>:

int
close(int fdnum)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 08             	push   0x8(%ebp)
  8012a5:	e8 c1 fe ff ff       	call   80116b <fd_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	79 02                	jns    8012b3 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    
		return fd_close(fd, 1);
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	6a 01                	push   $0x1
  8012b8:	ff 75 f4             	push   -0xc(%ebp)
  8012bb:	e8 51 ff ff ff       	call   801211 <fd_close>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	eb ec                	jmp    8012b1 <close+0x19>

008012c5 <close_all>:

void
close_all(void)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	e8 be ff ff ff       	call   801298 <close>
	for (i = 0; i < MAXFD; i++)
  8012da:	83 c3 01             	add    $0x1,%ebx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	83 fb 20             	cmp    $0x20,%ebx
  8012e3:	75 ec                	jne    8012d1 <close_all+0xc>
}
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	push   0x8(%ebp)
  8012fa:	e8 6c fe ff ff       	call   80116b <fd_lookup>
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 7f                	js     801387 <dup+0x9d>
		return r;
	close(newfdnum);
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	ff 75 0c             	push   0xc(%ebp)
  80130e:	e8 85 ff ff ff       	call   801298 <close>

	newfd = INDEX2FD(newfdnum);
  801313:	8b 75 0c             	mov    0xc(%ebp),%esi
  801316:	c1 e6 0c             	shl    $0xc,%esi
  801319:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80131f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801322:	89 3c 24             	mov    %edi,(%esp)
  801325:	e8 da fd ff ff       	call   801104 <fd2data>
  80132a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80132c:	89 34 24             	mov    %esi,(%esp)
  80132f:	e8 d0 fd ff ff       	call   801104 <fd2data>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133a:	89 d8                	mov    %ebx,%eax
  80133c:	c1 e8 16             	shr    $0x16,%eax
  80133f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801346:	a8 01                	test   $0x1,%al
  801348:	74 11                	je     80135b <dup+0x71>
  80134a:	89 d8                	mov    %ebx,%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
  80134f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801356:	f6 c2 01             	test   $0x1,%dl
  801359:	75 36                	jne    801391 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135b:	89 f8                	mov    %edi,%eax
  80135d:	c1 e8 0c             	shr    $0xc,%eax
  801360:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	25 07 0e 00 00       	and    $0xe07,%eax
  80136f:	50                   	push   %eax
  801370:	56                   	push   %esi
  801371:	6a 00                	push   $0x0
  801373:	57                   	push   %edi
  801374:	6a 00                	push   $0x0
  801376:	e8 6a fb ff ff       	call   800ee5 <sys_page_map>
  80137b:	89 c3                	mov    %eax,%ebx
  80137d:	83 c4 20             	add    $0x20,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 33                	js     8013b7 <dup+0xcd>
		goto err;

	return newfdnum;
  801384:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801387:	89 d8                	mov    %ebx,%eax
  801389:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801391:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a0:	50                   	push   %eax
  8013a1:	ff 75 d4             	push   -0x2c(%ebp)
  8013a4:	6a 00                	push   $0x0
  8013a6:	53                   	push   %ebx
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 37 fb ff ff       	call   800ee5 <sys_page_map>
  8013ae:	89 c3                	mov    %eax,%ebx
  8013b0:	83 c4 20             	add    $0x20,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	79 a4                	jns    80135b <dup+0x71>
	sys_page_unmap(0, newfd);
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	56                   	push   %esi
  8013bb:	6a 00                	push   $0x0
  8013bd:	e8 65 fb ff ff       	call   800f27 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	ff 75 d4             	push   -0x2c(%ebp)
  8013c8:	6a 00                	push   $0x0
  8013ca:	e8 58 fb ff ff       	call   800f27 <sys_page_unmap>
	return r;
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	eb b3                	jmp    801387 <dup+0x9d>

008013d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 18             	sub    $0x18,%esp
  8013dc:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	56                   	push   %esi
  8013e4:	e8 82 fd ff ff       	call   80116b <fd_lookup>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 3c                	js     80142c <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	ff 33                	push   (%ebx)
  8013fc:	e8 ba fd ff ff       	call   8011bb <dev_lookup>
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	85 c0                	test   %eax,%eax
  801406:	78 24                	js     80142c <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801408:	8b 43 08             	mov    0x8(%ebx),%eax
  80140b:	83 e0 03             	and    $0x3,%eax
  80140e:	83 f8 01             	cmp    $0x1,%eax
  801411:	74 20                	je     801433 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801413:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801416:	8b 40 08             	mov    0x8(%eax),%eax
  801419:	85 c0                	test   %eax,%eax
  80141b:	74 37                	je     801454 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141d:	83 ec 04             	sub    $0x4,%esp
  801420:	ff 75 10             	push   0x10(%ebp)
  801423:	ff 75 0c             	push   0xc(%ebp)
  801426:	53                   	push   %ebx
  801427:	ff d0                	call   *%eax
  801429:	83 c4 10             	add    $0x10,%esp
}
  80142c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801433:	a1 70 77 80 00       	mov    0x807770,%eax
  801438:	8b 40 58             	mov    0x58(%eax),%eax
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	56                   	push   %esi
  80143f:	50                   	push   %eax
  801440:	68 6d 2f 80 00       	push   $0x802f6d
  801445:	e8 82 f0 ff ff       	call   8004cc <cprintf>
		return -E_INVAL;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801452:	eb d8                	jmp    80142c <read+0x58>
		return -E_NOT_SUPP;
  801454:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801459:	eb d1                	jmp    80142c <read+0x58>

0080145b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	57                   	push   %edi
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	8b 7d 08             	mov    0x8(%ebp),%edi
  801467:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146f:	eb 02                	jmp    801473 <readn+0x18>
  801471:	01 c3                	add    %eax,%ebx
  801473:	39 f3                	cmp    %esi,%ebx
  801475:	73 21                	jae    801498 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	89 f0                	mov    %esi,%eax
  80147c:	29 d8                	sub    %ebx,%eax
  80147e:	50                   	push   %eax
  80147f:	89 d8                	mov    %ebx,%eax
  801481:	03 45 0c             	add    0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	57                   	push   %edi
  801486:	e8 49 ff ff ff       	call   8013d4 <read>
		if (m < 0)
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 04                	js     801496 <readn+0x3b>
			return m;
		if (m == 0)
  801492:	75 dd                	jne    801471 <readn+0x16>
  801494:	eb 02                	jmp    801498 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801496:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5e                   	pop    %esi
  80149f:	5f                   	pop    %edi
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 18             	sub    $0x18,%esp
  8014aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	53                   	push   %ebx
  8014b2:	e8 b4 fc ff ff       	call   80116b <fd_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 37                	js     8014f5 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014be:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 36                	push   (%esi)
  8014ca:	e8 ec fc ff ff       	call   8011bb <dev_lookup>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 1f                	js     8014f5 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014da:	74 20                	je     8014fc <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014df:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	74 37                	je     80151d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	ff 75 10             	push   0x10(%ebp)
  8014ec:	ff 75 0c             	push   0xc(%ebp)
  8014ef:	56                   	push   %esi
  8014f0:	ff d0                	call   *%eax
  8014f2:	83 c4 10             	add    $0x10,%esp
}
  8014f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fc:	a1 70 77 80 00       	mov    0x807770,%eax
  801501:	8b 40 58             	mov    0x58(%eax),%eax
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	53                   	push   %ebx
  801508:	50                   	push   %eax
  801509:	68 89 2f 80 00       	push   $0x802f89
  80150e:	e8 b9 ef ff ff       	call   8004cc <cprintf>
		return -E_INVAL;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151b:	eb d8                	jmp    8014f5 <write+0x53>
		return -E_NOT_SUPP;
  80151d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801522:	eb d1                	jmp    8014f5 <write+0x53>

00801524 <seek>:

int
seek(int fdnum, off_t offset)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	ff 75 08             	push   0x8(%ebp)
  801531:	e8 35 fc ff ff       	call   80116b <fd_lookup>
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 0e                	js     80154b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80153d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801543:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801546:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	83 ec 18             	sub    $0x18,%esp
  801555:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801558:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	53                   	push   %ebx
  80155d:	e8 09 fc ff ff       	call   80116b <fd_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 34                	js     80159d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801569:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	ff 36                	push   (%esi)
  801575:	e8 41 fc ff ff       	call   8011bb <dev_lookup>
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 1c                	js     80159d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801581:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801585:	74 1d                	je     8015a4 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801587:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158a:	8b 40 18             	mov    0x18(%eax),%eax
  80158d:	85 c0                	test   %eax,%eax
  80158f:	74 34                	je     8015c5 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	ff 75 0c             	push   0xc(%ebp)
  801597:	56                   	push   %esi
  801598:	ff d0                	call   *%eax
  80159a:	83 c4 10             	add    $0x10,%esp
}
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015a4:	a1 70 77 80 00       	mov    0x807770,%eax
  8015a9:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	53                   	push   %ebx
  8015b0:	50                   	push   %eax
  8015b1:	68 4c 2f 80 00       	push   $0x802f4c
  8015b6:	e8 11 ef ff ff       	call   8004cc <cprintf>
		return -E_INVAL;
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c3:	eb d8                	jmp    80159d <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ca:	eb d1                	jmp    80159d <ftruncate+0x50>

008015cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 18             	sub    $0x18,%esp
  8015d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	push   0x8(%ebp)
  8015de:	e8 88 fb ff ff       	call   80116b <fd_lookup>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 49                	js     801633 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	ff 36                	push   (%esi)
  8015f6:	e8 c0 fb ff ff       	call   8011bb <dev_lookup>
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 31                	js     801633 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801602:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801605:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801609:	74 2f                	je     80163a <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80160b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80160e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801615:	00 00 00 
	stat->st_isdir = 0;
  801618:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161f:	00 00 00 
	stat->st_dev = dev;
  801622:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	53                   	push   %ebx
  80162c:	56                   	push   %esi
  80162d:	ff 50 14             	call   *0x14(%eax)
  801630:	83 c4 10             	add    $0x10,%esp
}
  801633:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801636:	5b                   	pop    %ebx
  801637:	5e                   	pop    %esi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    
		return -E_NOT_SUPP;
  80163a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80163f:	eb f2                	jmp    801633 <fstat+0x67>

00801641 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	6a 00                	push   $0x0
  80164b:	ff 75 08             	push   0x8(%ebp)
  80164e:	e8 e4 01 00 00       	call   801837 <open>
  801653:	89 c3                	mov    %eax,%ebx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 1b                	js     801677 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	ff 75 0c             	push   0xc(%ebp)
  801662:	50                   	push   %eax
  801663:	e8 64 ff ff ff       	call   8015cc <fstat>
  801668:	89 c6                	mov    %eax,%esi
	close(fd);
  80166a:	89 1c 24             	mov    %ebx,(%esp)
  80166d:	e8 26 fc ff ff       	call   801298 <close>
	return r;
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	89 f3                	mov    %esi,%ebx
}
  801677:	89 d8                	mov    %ebx,%eax
  801679:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
  801685:	89 c6                	mov    %eax,%esi
  801687:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801689:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  801690:	74 27                	je     8016b9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801692:	6a 07                	push   $0x7
  801694:	68 00 80 80 00       	push   $0x808000
  801699:	56                   	push   %esi
  80169a:	ff 35 00 90 80 00    	push   0x809000
  8016a0:	e8 c0 10 00 00       	call   802765 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016a5:	83 c4 0c             	add    $0xc,%esp
  8016a8:	6a 00                	push   $0x0
  8016aa:	53                   	push   %ebx
  8016ab:	6a 00                	push   $0x0
  8016ad:	e8 43 10 00 00       	call   8026f5 <ipc_recv>
}
  8016b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	6a 01                	push   $0x1
  8016be:	e8 f6 10 00 00       	call   8027b9 <ipc_find_env>
  8016c3:	a3 00 90 80 00       	mov    %eax,0x809000
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	eb c5                	jmp    801692 <fsipc+0x12>

008016cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d9:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8016de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e1:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8016f0:	e8 8b ff ff ff       	call   801680 <fsipc>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <devfile_flush>:
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 40 0c             	mov    0xc(%eax),%eax
  801703:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801708:	ba 00 00 00 00       	mov    $0x0,%edx
  80170d:	b8 06 00 00 00       	mov    $0x6,%eax
  801712:	e8 69 ff ff ff       	call   801680 <fsipc>
}
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <devfile_stat>:
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	53                   	push   %ebx
  80171d:	83 ec 04             	sub    $0x4,%esp
  801720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	8b 40 0c             	mov    0xc(%eax),%eax
  801729:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 05 00 00 00       	mov    $0x5,%eax
  801738:	e8 43 ff ff ff       	call   801680 <fsipc>
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 2c                	js     80176d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	68 00 80 80 00       	push   $0x808000
  801749:	53                   	push   %ebx
  80174a:	e8 57 f3 ff ff       	call   800aa6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174f:	a1 80 80 80 00       	mov    0x808080,%eax
  801754:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80175a:	a1 84 80 80 00       	mov    0x808084,%eax
  80175f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <devfile_write>:
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 0c             	sub    $0xc,%esp
  801778:	8b 45 10             	mov    0x10(%ebp),%eax
  80177b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801780:	39 d0                	cmp    %edx,%eax
  801782:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801785:	8b 55 08             	mov    0x8(%ebp),%edx
  801788:	8b 52 0c             	mov    0xc(%edx),%edx
  80178b:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  801791:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801796:	50                   	push   %eax
  801797:	ff 75 0c             	push   0xc(%ebp)
  80179a:	68 08 80 80 00       	push   $0x808008
  80179f:	e8 98 f4 ff ff       	call   800c3c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ae:	e8 cd fe ff ff       	call   801680 <fsipc>
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_read>:
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  8017c8:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d8:	e8 a3 fe ff ff       	call   801680 <fsipc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 1f                	js     801802 <devfile_read+0x4d>
	assert(r <= n);
  8017e3:	39 f0                	cmp    %esi,%eax
  8017e5:	77 24                	ja     80180b <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ec:	7f 33                	jg     801821 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	50                   	push   %eax
  8017f2:	68 00 80 80 00       	push   $0x808000
  8017f7:	ff 75 0c             	push   0xc(%ebp)
  8017fa:	e8 3d f4 ff ff       	call   800c3c <memmove>
	return r;
  8017ff:	83 c4 10             	add    $0x10,%esp
}
  801802:	89 d8                	mov    %ebx,%eax
  801804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    
	assert(r <= n);
  80180b:	68 bc 2f 80 00       	push   $0x802fbc
  801810:	68 c3 2f 80 00       	push   $0x802fc3
  801815:	6a 7c                	push   $0x7c
  801817:	68 d8 2f 80 00       	push   $0x802fd8
  80181c:	e8 d0 eb ff ff       	call   8003f1 <_panic>
	assert(r <= PGSIZE);
  801821:	68 e3 2f 80 00       	push   $0x802fe3
  801826:	68 c3 2f 80 00       	push   $0x802fc3
  80182b:	6a 7d                	push   $0x7d
  80182d:	68 d8 2f 80 00       	push   $0x802fd8
  801832:	e8 ba eb ff ff       	call   8003f1 <_panic>

00801837 <open>:
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	83 ec 1c             	sub    $0x1c,%esp
  80183f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801842:	56                   	push   %esi
  801843:	e8 23 f2 ff ff       	call   800a6b <strlen>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801850:	7f 6c                	jg     8018be <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	e8 bd f8 ff ff       	call   80111b <fd_alloc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 3c                	js     8018a3 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	56                   	push   %esi
  80186b:	68 00 80 80 00       	push   $0x808000
  801870:	e8 31 f2 ff ff       	call   800aa6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	a3 00 84 80 00       	mov    %eax,0x808400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	b8 01 00 00 00       	mov    $0x1,%eax
  801885:	e8 f6 fd ff ff       	call   801680 <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 19                	js     8018ac <open+0x75>
	return fd2num(fd);
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	ff 75 f4             	push   -0xc(%ebp)
  801899:	e8 56 f8 ff ff       	call   8010f4 <fd2num>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
}
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    
		fd_close(fd, 0);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	6a 00                	push   $0x0
  8018b1:	ff 75 f4             	push   -0xc(%ebp)
  8018b4:	e8 58 f9 ff ff       	call   801211 <fd_close>
		return r;
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	eb e5                	jmp    8018a3 <open+0x6c>
		return -E_BAD_PATH;
  8018be:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018c3:	eb de                	jmp    8018a3 <open+0x6c>

008018c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d5:	e8 a6 fd ff ff       	call   801680 <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018e8:	6a 00                	push   $0x0
  8018ea:	ff 75 08             	push   0x8(%ebp)
  8018ed:	e8 45 ff ff ff       	call   801837 <open>
  8018f2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	0f 88 ad 04 00 00    	js     801db0 <spawn+0x4d4>
  801903:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	68 00 02 00 00       	push   $0x200
  80190d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	57                   	push   %edi
  801915:	e8 41 fb ff ff       	call   80145b <readn>
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801922:	75 5a                	jne    80197e <spawn+0xa2>
	    || elf->e_magic != ELF_MAGIC) {
  801924:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80192b:	45 4c 46 
  80192e:	75 4e                	jne    80197e <spawn+0xa2>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801930:	b8 07 00 00 00       	mov    $0x7,%eax
  801935:	cd 30                	int    $0x30
  801937:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80193d:	85 c0                	test   %eax,%eax
  80193f:	0f 88 5f 04 00 00    	js     801da4 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801945:	25 ff 03 00 00       	and    $0x3ff,%eax
  80194a:	69 f0 8c 00 00 00    	imul   $0x8c,%eax,%esi
  801950:	81 c6 10 00 c0 ee    	add    $0xeec00010,%esi
  801956:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80195c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801963:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801969:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80196f:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801974:	be 00 00 00 00       	mov    $0x0,%esi
  801979:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  80197c:	eb 4b                	jmp    8019c9 <spawn+0xed>
		close(fd);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801987:	e8 0c f9 ff ff       	call   801298 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80198c:	83 c4 0c             	add    $0xc,%esp
  80198f:	68 7f 45 4c 46       	push   $0x464c457f
  801994:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  80199a:	68 ef 2f 80 00       	push   $0x802fef
  80199f:	e8 28 eb ff ff       	call   8004cc <cprintf>
		return -E_NOT_EXEC;
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  8019ae:	ff ff ff 
  8019b1:	e9 fa 03 00 00       	jmp    801db0 <spawn+0x4d4>
		string_size += strlen(argv[argc]) + 1;
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	50                   	push   %eax
  8019ba:	e8 ac f0 ff ff       	call   800a6b <strlen>
  8019bf:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8019c3:	83 c3 01             	add    $0x1,%ebx
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019d0:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	75 df                	jne    8019b6 <spawn+0xda>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019d7:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8019dd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8019e3:	b8 00 10 40 00       	mov    $0x401000,%eax
  8019e8:	29 f0                	sub    %esi,%eax
  8019ea:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019ec:	89 c2                	mov    %eax,%edx
  8019ee:	83 e2 fc             	and    $0xfffffffc,%edx
  8019f1:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019f8:	29 c2                	sub    %eax,%edx
  8019fa:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a00:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a03:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a08:	0f 86 14 04 00 00    	jbe    801e22 <spawn+0x546>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	6a 07                	push   $0x7
  801a13:	68 00 00 40 00       	push   $0x400000
  801a18:	6a 00                	push   $0x0
  801a1a:	e8 83 f4 ff ff       	call   800ea2 <sys_page_alloc>
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	85 c0                	test   %eax,%eax
  801a24:	0f 88 fd 03 00 00    	js     801e27 <spawn+0x54b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a2a:	be 00 00 00 00       	mov    $0x0,%esi
  801a2f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a38:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a3e:	7e 32                	jle    801a72 <spawn+0x196>
		argv_store[i] = UTEMP2USTACK(string_store);
  801a40:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a46:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a4c:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a4f:	83 ec 08             	sub    $0x8,%esp
  801a52:	ff 34 b3             	push   (%ebx,%esi,4)
  801a55:	57                   	push   %edi
  801a56:	e8 4b f0 ff ff       	call   800aa6 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a5b:	83 c4 04             	add    $0x4,%esp
  801a5e:	ff 34 b3             	push   (%ebx,%esi,4)
  801a61:	e8 05 f0 ff ff       	call   800a6b <strlen>
  801a66:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801a6a:	83 c6 01             	add    $0x1,%esi
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	eb c6                	jmp    801a38 <spawn+0x15c>
	}
	argv_store[argc] = 0;
  801a72:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a78:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a7e:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a85:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a8b:	0f 85 8c 00 00 00    	jne    801b1d <spawn+0x241>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a91:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a97:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801a9d:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801aa0:	89 c8                	mov    %ecx,%eax
  801aa2:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801aa8:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801aab:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ab0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	6a 07                	push   $0x7
  801abb:	68 00 d0 bf ee       	push   $0xeebfd000
  801ac0:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ac6:	68 00 00 40 00       	push   $0x400000
  801acb:	6a 00                	push   $0x0
  801acd:	e8 13 f4 ff ff       	call   800ee5 <sys_page_map>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 20             	add    $0x20,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 50 03 00 00    	js     801e2f <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	68 00 00 40 00       	push   $0x400000
  801ae7:	6a 00                	push   $0x0
  801ae9:	e8 39 f4 ff ff       	call   800f27 <sys_page_unmap>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 34 03 00 00    	js     801e2f <spawn+0x553>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801afb:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b01:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b08:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b0e:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b15:	00 00 00 
  801b18:	e9 4e 01 00 00       	jmp    801c6b <spawn+0x38f>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b1d:	68 7c 30 80 00       	push   $0x80307c
  801b22:	68 c3 2f 80 00       	push   $0x802fc3
  801b27:	68 f2 00 00 00       	push   $0xf2
  801b2c:	68 09 30 80 00       	push   $0x803009
  801b31:	e8 bb e8 ff ff       	call   8003f1 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b36:	83 ec 04             	sub    $0x4,%esp
  801b39:	6a 07                	push   $0x7
  801b3b:	68 00 00 40 00       	push   $0x400000
  801b40:	6a 00                	push   $0x0
  801b42:	e8 5b f3 ff ff       	call   800ea2 <sys_page_alloc>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	0f 88 6c 02 00 00    	js     801dbe <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b5b:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b61:	50                   	push   %eax
  801b62:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801b68:	e8 b7 f9 ff ff       	call   801524 <seek>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 88 4d 02 00 00    	js     801dc5 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b78:	83 ec 04             	sub    $0x4,%esp
  801b7b:	89 f8                	mov    %edi,%eax
  801b7d:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801b83:	ba 00 10 00 00       	mov    $0x1000,%edx
  801b88:	39 d0                	cmp    %edx,%eax
  801b8a:	0f 47 c2             	cmova  %edx,%eax
  801b8d:	50                   	push   %eax
  801b8e:	68 00 00 40 00       	push   $0x400000
  801b93:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801b99:	e8 bd f8 ff ff       	call   80145b <readn>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	0f 88 23 02 00 00    	js     801dcc <spawn+0x4f0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ba9:	83 ec 0c             	sub    $0xc,%esp
  801bac:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801bb2:	56                   	push   %esi
  801bb3:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801bb9:	68 00 00 40 00       	push   $0x400000
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 20 f3 ff ff       	call   800ee5 <sys_page_map>
  801bc5:	83 c4 20             	add    $0x20,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 7c                	js     801c48 <spawn+0x36c>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	68 00 00 40 00       	push   $0x400000
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 4c f3 ff ff       	call   800f27 <sys_page_unmap>
  801bdb:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801bde:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801be4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801bea:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801bf0:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801bf6:	76 65                	jbe    801c5d <spawn+0x381>
		if (i >= filesz) {
  801bf8:	39 df                	cmp    %ebx,%edi
  801bfa:	0f 87 36 ff ff ff    	ja     801b36 <spawn+0x25a>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c00:	83 ec 04             	sub    $0x4,%esp
  801c03:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801c09:	56                   	push   %esi
  801c0a:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c10:	e8 8d f2 ff ff       	call   800ea2 <sys_page_alloc>
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	79 c2                	jns    801bde <spawn+0x302>
  801c1c:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801c27:	e8 f7 f1 ff ff       	call   800e23 <sys_env_destroy>
	close(fd);
  801c2c:	83 c4 04             	add    $0x4,%esp
  801c2f:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801c35:	e8 5e f6 ff ff       	call   801298 <close>
	return r;
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801c43:	e9 68 01 00 00       	jmp    801db0 <spawn+0x4d4>
				panic("spawn: sys_page_map data: %e", r);
  801c48:	50                   	push   %eax
  801c49:	68 15 30 80 00       	push   $0x803015
  801c4e:	68 25 01 00 00       	push   $0x125
  801c53:	68 09 30 80 00       	push   $0x803009
  801c58:	e8 94 e7 ff ff       	call   8003f1 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c5d:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801c64:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801c6b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c72:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801c78:	7e 67                	jle    801ce1 <spawn+0x405>
		if (ph->p_type != ELF_PROG_LOAD)
  801c7a:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801c80:	83 39 01             	cmpl   $0x1,(%ecx)
  801c83:	75 d8                	jne    801c5d <spawn+0x381>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c85:	8b 41 18             	mov    0x18(%ecx),%eax
  801c88:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c8e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c91:	83 f8 01             	cmp    $0x1,%eax
  801c94:	19 c0                	sbb    %eax,%eax
  801c96:	83 e0 fe             	and    $0xfffffffe,%eax
  801c99:	83 c0 07             	add    $0x7,%eax
  801c9c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ca2:	8b 51 04             	mov    0x4(%ecx),%edx
  801ca5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801cab:	8b 79 10             	mov    0x10(%ecx),%edi
  801cae:	8b 59 14             	mov    0x14(%ecx),%ebx
  801cb1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801cb7:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  801cba:	89 f0                	mov    %esi,%eax
  801cbc:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cc1:	74 14                	je     801cd7 <spawn+0x3fb>
		va -= i;
  801cc3:	29 c6                	sub    %eax,%esi
		memsz += i;
  801cc5:	01 c3                	add    %eax,%ebx
  801cc7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801ccd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ccf:	29 c2                	sub    %eax,%edx
  801cd1:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cdc:	e9 09 ff ff ff       	jmp    801bea <spawn+0x30e>
	close(fd);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801cea:	e8 a9 f5 ff ff       	call   801298 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  801cef:	e8 70 f1 ff ff       	call   800e64 <sys_getenvid>
  801cf4:	89 c6                	mov    %eax,%esi
  801cf6:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801cf9:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801cfe:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801d04:	eb 12                	jmp    801d18 <spawn+0x43c>
  801d06:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d0c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d12:	0f 84 bb 00 00 00    	je     801dd3 <spawn+0x4f7>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  801d18:	89 d8                	mov    %ebx,%eax
  801d1a:	c1 e8 16             	shr    $0x16,%eax
  801d1d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d24:	a8 01                	test   $0x1,%al
  801d26:	74 de                	je     801d06 <spawn+0x42a>
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	c1 e8 0c             	shr    $0xc,%eax
  801d2d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d34:	f6 c2 01             	test   $0x1,%dl
  801d37:	74 cd                	je     801d06 <spawn+0x42a>
  801d39:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d40:	f6 c6 04             	test   $0x4,%dh
  801d43:	74 c1                	je     801d06 <spawn+0x42a>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  801d45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d4c:	83 ec 0c             	sub    $0xc,%esp
  801d4f:	25 07 0e 00 00       	and    $0xe07,%eax
  801d54:	50                   	push   %eax
  801d55:	53                   	push   %ebx
  801d56:	57                   	push   %edi
  801d57:	53                   	push   %ebx
  801d58:	56                   	push   %esi
  801d59:	e8 87 f1 ff ff       	call   800ee5 <sys_page_map>
  801d5e:	83 c4 20             	add    $0x20,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	79 a1                	jns    801d06 <spawn+0x42a>
		panic("copy_shared_pages: %e", r);
  801d65:	50                   	push   %eax
  801d66:	68 63 30 80 00       	push   $0x803063
  801d6b:	68 82 00 00 00       	push   $0x82
  801d70:	68 09 30 80 00       	push   $0x803009
  801d75:	e8 77 e6 ff ff       	call   8003f1 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801d7a:	50                   	push   %eax
  801d7b:	68 32 30 80 00       	push   $0x803032
  801d80:	68 86 00 00 00       	push   $0x86
  801d85:	68 09 30 80 00       	push   $0x803009
  801d8a:	e8 62 e6 ff ff       	call   8003f1 <_panic>
		panic("sys_env_set_status: %e", r);
  801d8f:	50                   	push   %eax
  801d90:	68 4c 30 80 00       	push   $0x80304c
  801d95:	68 89 00 00 00       	push   $0x89
  801d9a:	68 09 30 80 00       	push   $0x803009
  801d9f:	e8 4d e6 ff ff       	call   8003f1 <_panic>
		return r;
  801da4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801daa:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  801db0:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db9:	5b                   	pop    %ebx
  801dba:	5e                   	pop    %esi
  801dbb:	5f                   	pop    %edi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    
  801dbe:	89 c7                	mov    %eax,%edi
  801dc0:	e9 59 fe ff ff       	jmp    801c1e <spawn+0x342>
  801dc5:	89 c7                	mov    %eax,%edi
  801dc7:	e9 52 fe ff ff       	jmp    801c1e <spawn+0x342>
  801dcc:	89 c7                	mov    %eax,%edi
  801dce:	e9 4b fe ff ff       	jmp    801c1e <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801dd3:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801dda:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ddd:	83 ec 08             	sub    $0x8,%esp
  801de0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801de6:	50                   	push   %eax
  801de7:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801ded:	e8 b9 f1 ff ff       	call   800fab <sys_env_set_trapframe>
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 81                	js     801d7a <spawn+0x49e>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801df9:	83 ec 08             	sub    $0x8,%esp
  801dfc:	6a 02                	push   $0x2
  801dfe:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e04:	e8 60 f1 ff ff       	call   800f69 <sys_env_set_status>
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	0f 88 7b ff ff ff    	js     801d8f <spawn+0x4b3>
	return child;
  801e14:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e1a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e20:	eb 8e                	jmp    801db0 <spawn+0x4d4>
		return -E_NO_MEM;
  801e22:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801e27:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e2d:	eb 81                	jmp    801db0 <spawn+0x4d4>
	sys_page_unmap(0, UTEMP);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	68 00 00 40 00       	push   $0x400000
  801e37:	6a 00                	push   $0x0
  801e39:	e8 e9 f0 ff ff       	call   800f27 <sys_page_unmap>
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801e47:	e9 64 ff ff ff       	jmp    801db0 <spawn+0x4d4>

00801e4c <spawnl>:
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
	va_start(vl, arg0);
  801e51:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801e59:	eb 05                	jmp    801e60 <spawnl+0x14>
		argc++;
  801e5b:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801e5e:	89 ca                	mov    %ecx,%edx
  801e60:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e63:	83 3a 00             	cmpl   $0x0,(%edx)
  801e66:	75 f3                	jne    801e5b <spawnl+0xf>
	const char *argv[argc+2];
  801e68:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801e6f:	89 d3                	mov    %edx,%ebx
  801e71:	83 e3 f0             	and    $0xfffffff0,%ebx
  801e74:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801e7a:	89 e1                	mov    %esp,%ecx
  801e7c:	29 d1                	sub    %edx,%ecx
  801e7e:	39 cc                	cmp    %ecx,%esp
  801e80:	74 10                	je     801e92 <spawnl+0x46>
  801e82:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801e88:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801e8f:	00 
  801e90:	eb ec                	jmp    801e7e <spawnl+0x32>
  801e92:	89 da                	mov    %ebx,%edx
  801e94:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801e9a:	29 d4                	sub    %edx,%esp
  801e9c:	85 d2                	test   %edx,%edx
  801e9e:	74 05                	je     801ea5 <spawnl+0x59>
  801ea0:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801ea5:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  801ea9:	89 da                	mov    %ebx,%edx
  801eab:	c1 ea 02             	shr    $0x2,%edx
  801eae:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  801eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eb4:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ebb:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  801ec2:	00 
	va_start(vl, arg0);
  801ec3:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801ec6:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecd:	eb 0b                	jmp    801eda <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  801ecf:	83 c0 01             	add    $0x1,%eax
  801ed2:	8b 31                	mov    (%ecx),%esi
  801ed4:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  801ed7:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801eda:	39 d0                	cmp    %edx,%eax
  801edc:	75 f1                	jne    801ecf <spawnl+0x83>
	return spawn(prog, argv);
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	53                   	push   %ebx
  801ee2:	ff 75 08             	push   0x8(%ebp)
  801ee5:	e8 f2 f9 ff ff       	call   8018dc <spawn>
}
  801eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ef7:	68 a2 30 80 00       	push   $0x8030a2
  801efc:	ff 75 0c             	push   0xc(%ebp)
  801eff:	e8 a2 eb ff ff       	call   800aa6 <strcpy>
	return 0;
}
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <devsock_close>:
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	53                   	push   %ebx
  801f0f:	83 ec 10             	sub    $0x10,%esp
  801f12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f15:	53                   	push   %ebx
  801f16:	e8 dd 08 00 00       	call   8027f8 <pageref>
  801f1b:	89 c2                	mov    %eax,%edx
  801f1d:	83 c4 10             	add    $0x10,%esp
		return 0;
  801f20:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801f25:	83 fa 01             	cmp    $0x1,%edx
  801f28:	74 05                	je     801f2f <devsock_close+0x24>
}
  801f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	ff 73 0c             	push   0xc(%ebx)
  801f35:	e8 b7 02 00 00       	call   8021f1 <nsipc_close>
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	eb eb                	jmp    801f2a <devsock_close+0x1f>

00801f3f <devsock_write>:
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f45:	6a 00                	push   $0x0
  801f47:	ff 75 10             	push   0x10(%ebp)
  801f4a:	ff 75 0c             	push   0xc(%ebp)
  801f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f50:	ff 70 0c             	push   0xc(%eax)
  801f53:	e8 79 03 00 00       	call   8022d1 <nsipc_send>
}
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <devsock_read>:
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f60:	6a 00                	push   $0x0
  801f62:	ff 75 10             	push   0x10(%ebp)
  801f65:	ff 75 0c             	push   0xc(%ebp)
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	ff 70 0c             	push   0xc(%eax)
  801f6e:	e8 ef 02 00 00       	call   802262 <nsipc_recv>
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <fd2sockid>:
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f7b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f7e:	52                   	push   %edx
  801f7f:	50                   	push   %eax
  801f80:	e8 e6 f1 ff ff       	call   80116b <fd_lookup>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 10                	js     801f9c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8f:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801f95:	39 08                	cmp    %ecx,(%eax)
  801f97:	75 05                	jne    801f9e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801f99:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    
		return -E_NOT_SUPP;
  801f9e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801fa3:	eb f7                	jmp    801f9c <fd2sockid+0x27>

00801fa5 <alloc_sockfd>:
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	56                   	push   %esi
  801fa9:	53                   	push   %ebx
  801faa:	83 ec 1c             	sub    $0x1c,%esp
  801fad:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb2:	50                   	push   %eax
  801fb3:	e8 63 f1 ff ff       	call   80111b <fd_alloc>
  801fb8:	89 c3                	mov    %eax,%ebx
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 43                	js     802004 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fc1:	83 ec 04             	sub    $0x4,%esp
  801fc4:	68 07 04 00 00       	push   $0x407
  801fc9:	ff 75 f4             	push   -0xc(%ebp)
  801fcc:	6a 00                	push   $0x0
  801fce:	e8 cf ee ff ff       	call   800ea2 <sys_page_alloc>
  801fd3:	89 c3                	mov    %eax,%ebx
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 28                	js     802004 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdf:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801fe5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ff1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ff4:	83 ec 0c             	sub    $0xc,%esp
  801ff7:	50                   	push   %eax
  801ff8:	e8 f7 f0 ff ff       	call   8010f4 <fd2num>
  801ffd:	89 c3                	mov    %eax,%ebx
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	eb 0c                	jmp    802010 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802004:	83 ec 0c             	sub    $0xc,%esp
  802007:	56                   	push   %esi
  802008:	e8 e4 01 00 00       	call   8021f1 <nsipc_close>
		return r;
  80200d:	83 c4 10             	add    $0x10,%esp
}
  802010:	89 d8                	mov    %ebx,%eax
  802012:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <accept>:
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	e8 4e ff ff ff       	call   801f75 <fd2sockid>
  802027:	85 c0                	test   %eax,%eax
  802029:	78 1b                	js     802046 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80202b:	83 ec 04             	sub    $0x4,%esp
  80202e:	ff 75 10             	push   0x10(%ebp)
  802031:	ff 75 0c             	push   0xc(%ebp)
  802034:	50                   	push   %eax
  802035:	e8 0e 01 00 00       	call   802148 <nsipc_accept>
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	85 c0                	test   %eax,%eax
  80203f:	78 05                	js     802046 <accept+0x2d>
	return alloc_sockfd(r);
  802041:	e8 5f ff ff ff       	call   801fa5 <alloc_sockfd>
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <bind>:
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	e8 1f ff ff ff       	call   801f75 <fd2sockid>
  802056:	85 c0                	test   %eax,%eax
  802058:	78 12                	js     80206c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80205a:	83 ec 04             	sub    $0x4,%esp
  80205d:	ff 75 10             	push   0x10(%ebp)
  802060:	ff 75 0c             	push   0xc(%ebp)
  802063:	50                   	push   %eax
  802064:	e8 31 01 00 00       	call   80219a <nsipc_bind>
  802069:	83 c4 10             	add    $0x10,%esp
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <shutdown>:
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	e8 f9 fe ff ff       	call   801f75 <fd2sockid>
  80207c:	85 c0                	test   %eax,%eax
  80207e:	78 0f                	js     80208f <shutdown+0x21>
	return nsipc_shutdown(r, how);
  802080:	83 ec 08             	sub    $0x8,%esp
  802083:	ff 75 0c             	push   0xc(%ebp)
  802086:	50                   	push   %eax
  802087:	e8 43 01 00 00       	call   8021cf <nsipc_shutdown>
  80208c:	83 c4 10             	add    $0x10,%esp
}
  80208f:	c9                   	leave  
  802090:	c3                   	ret    

00802091 <connect>:
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802097:	8b 45 08             	mov    0x8(%ebp),%eax
  80209a:	e8 d6 fe ff ff       	call   801f75 <fd2sockid>
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 12                	js     8020b5 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8020a3:	83 ec 04             	sub    $0x4,%esp
  8020a6:	ff 75 10             	push   0x10(%ebp)
  8020a9:	ff 75 0c             	push   0xc(%ebp)
  8020ac:	50                   	push   %eax
  8020ad:	e8 59 01 00 00       	call   80220b <nsipc_connect>
  8020b2:	83 c4 10             	add    $0x10,%esp
}
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <listen>:
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8020bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c0:	e8 b0 fe ff ff       	call   801f75 <fd2sockid>
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	78 0f                	js     8020d8 <listen+0x21>
	return nsipc_listen(r, backlog);
  8020c9:	83 ec 08             	sub    $0x8,%esp
  8020cc:	ff 75 0c             	push   0xc(%ebp)
  8020cf:	50                   	push   %eax
  8020d0:	e8 6b 01 00 00       	call   802240 <nsipc_listen>
  8020d5:	83 c4 10             	add    $0x10,%esp
}
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    

008020da <socket>:

int
socket(int domain, int type, int protocol)
{
  8020da:	55                   	push   %ebp
  8020db:	89 e5                	mov    %esp,%ebp
  8020dd:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020e0:	ff 75 10             	push   0x10(%ebp)
  8020e3:	ff 75 0c             	push   0xc(%ebp)
  8020e6:	ff 75 08             	push   0x8(%ebp)
  8020e9:	e8 41 02 00 00       	call   80232f <nsipc_socket>
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	78 05                	js     8020fa <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020f5:	e8 ab fe ff ff       	call   801fa5 <alloc_sockfd>
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	53                   	push   %ebx
  802100:	83 ec 04             	sub    $0x4,%esp
  802103:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802105:	83 3d 00 b0 80 00 00 	cmpl   $0x0,0x80b000
  80210c:	74 26                	je     802134 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80210e:	6a 07                	push   $0x7
  802110:	68 00 a0 80 00       	push   $0x80a000
  802115:	53                   	push   %ebx
  802116:	ff 35 00 b0 80 00    	push   0x80b000
  80211c:	e8 44 06 00 00       	call   802765 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802121:	83 c4 0c             	add    $0xc,%esp
  802124:	6a 00                	push   $0x0
  802126:	6a 00                	push   $0x0
  802128:	6a 00                	push   $0x0
  80212a:	e8 c6 05 00 00       	call   8026f5 <ipc_recv>
}
  80212f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802132:	c9                   	leave  
  802133:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802134:	83 ec 0c             	sub    $0xc,%esp
  802137:	6a 02                	push   $0x2
  802139:	e8 7b 06 00 00       	call   8027b9 <ipc_find_env>
  80213e:	a3 00 b0 80 00       	mov    %eax,0x80b000
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	eb c6                	jmp    80210e <nsipc+0x12>

00802148 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	56                   	push   %esi
  80214c:	53                   	push   %ebx
  80214d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802150:	8b 45 08             	mov    0x8(%ebp),%eax
  802153:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802158:	8b 06                	mov    (%esi),%eax
  80215a:	a3 04 a0 80 00       	mov    %eax,0x80a004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80215f:	b8 01 00 00 00       	mov    $0x1,%eax
  802164:	e8 93 ff ff ff       	call   8020fc <nsipc>
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	79 09                	jns    802178 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80216f:	89 d8                	mov    %ebx,%eax
  802171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802178:	83 ec 04             	sub    $0x4,%esp
  80217b:	ff 35 10 a0 80 00    	push   0x80a010
  802181:	68 00 a0 80 00       	push   $0x80a000
  802186:	ff 75 0c             	push   0xc(%ebp)
  802189:	e8 ae ea ff ff       	call   800c3c <memmove>
		*addrlen = ret->ret_addrlen;
  80218e:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802193:	89 06                	mov    %eax,(%esi)
  802195:	83 c4 10             	add    $0x10,%esp
	return r;
  802198:	eb d5                	jmp    80216f <nsipc_accept+0x27>

0080219a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	53                   	push   %ebx
  80219e:	83 ec 08             	sub    $0x8,%esp
  8021a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a7:	a3 00 a0 80 00       	mov    %eax,0x80a000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021ac:	53                   	push   %ebx
  8021ad:	ff 75 0c             	push   0xc(%ebp)
  8021b0:	68 04 a0 80 00       	push   $0x80a004
  8021b5:	e8 82 ea ff ff       	call   800c3c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021ba:	89 1d 14 a0 80 00    	mov    %ebx,0x80a014
	return nsipc(NSREQ_BIND);
  8021c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8021c5:	e8 32 ff ff ff       	call   8020fc <nsipc>
}
  8021ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d8:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.shutdown.req_how = how;
  8021dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e0:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return nsipc(NSREQ_SHUTDOWN);
  8021e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8021ea:	e8 0d ff ff ff       	call   8020fc <nsipc>
}
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <nsipc_close>:

int
nsipc_close(int s)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fa:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return nsipc(NSREQ_CLOSE);
  8021ff:	b8 04 00 00 00       	mov    $0x4,%eax
  802204:	e8 f3 fe ff ff       	call   8020fc <nsipc>
}
  802209:	c9                   	leave  
  80220a:	c3                   	ret    

0080220b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	53                   	push   %ebx
  80220f:	83 ec 08             	sub    $0x8,%esp
  802212:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802215:	8b 45 08             	mov    0x8(%ebp),%eax
  802218:	a3 00 a0 80 00       	mov    %eax,0x80a000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80221d:	53                   	push   %ebx
  80221e:	ff 75 0c             	push   0xc(%ebp)
  802221:	68 04 a0 80 00       	push   $0x80a004
  802226:	e8 11 ea ff ff       	call   800c3c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80222b:	89 1d 14 a0 80 00    	mov    %ebx,0x80a014
	return nsipc(NSREQ_CONNECT);
  802231:	b8 05 00 00 00       	mov    $0x5,%eax
  802236:	e8 c1 fe ff ff       	call   8020fc <nsipc>
}
  80223b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80223e:	c9                   	leave  
  80223f:	c3                   	ret    

00802240 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802246:	8b 45 08             	mov    0x8(%ebp),%eax
  802249:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.listen.req_backlog = backlog;
  80224e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802251:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return nsipc(NSREQ_LISTEN);
  802256:	b8 06 00 00 00       	mov    $0x6,%eax
  80225b:	e8 9c fe ff ff       	call   8020fc <nsipc>
}
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	56                   	push   %esi
  802266:	53                   	push   %ebx
  802267:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80226a:	8b 45 08             	mov    0x8(%ebp),%eax
  80226d:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.recv.req_len = len;
  802272:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	nsipcbuf.recv.req_flags = flags;
  802278:	8b 45 14             	mov    0x14(%ebp),%eax
  80227b:	a3 08 a0 80 00       	mov    %eax,0x80a008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802280:	b8 07 00 00 00       	mov    $0x7,%eax
  802285:	e8 72 fe ff ff       	call   8020fc <nsipc>
  80228a:	89 c3                	mov    %eax,%ebx
  80228c:	85 c0                	test   %eax,%eax
  80228e:	78 22                	js     8022b2 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802290:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802295:	39 c6                	cmp    %eax,%esi
  802297:	0f 4e c6             	cmovle %esi,%eax
  80229a:	39 c3                	cmp    %eax,%ebx
  80229c:	7f 1d                	jg     8022bb <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80229e:	83 ec 04             	sub    $0x4,%esp
  8022a1:	53                   	push   %ebx
  8022a2:	68 00 a0 80 00       	push   $0x80a000
  8022a7:	ff 75 0c             	push   0xc(%ebp)
  8022aa:	e8 8d e9 ff ff       	call   800c3c <memmove>
  8022af:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8022b2:	89 d8                	mov    %ebx,%eax
  8022b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8022bb:	68 ae 30 80 00       	push   $0x8030ae
  8022c0:	68 c3 2f 80 00       	push   $0x802fc3
  8022c5:	6a 62                	push   $0x62
  8022c7:	68 c3 30 80 00       	push   $0x8030c3
  8022cc:	e8 20 e1 ff ff       	call   8003f1 <_panic>

008022d1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	53                   	push   %ebx
  8022d5:	83 ec 04             	sub    $0x4,%esp
  8022d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022db:	8b 45 08             	mov    0x8(%ebp),%eax
  8022de:	a3 00 a0 80 00       	mov    %eax,0x80a000
	assert(size < 1600);
  8022e3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022e9:	7f 2e                	jg     802319 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022eb:	83 ec 04             	sub    $0x4,%esp
  8022ee:	53                   	push   %ebx
  8022ef:	ff 75 0c             	push   0xc(%ebp)
  8022f2:	68 0c a0 80 00       	push   $0x80a00c
  8022f7:	e8 40 e9 ff ff       	call   800c3c <memmove>
	nsipcbuf.send.req_size = size;
  8022fc:	89 1d 04 a0 80 00    	mov    %ebx,0x80a004
	nsipcbuf.send.req_flags = flags;
  802302:	8b 45 14             	mov    0x14(%ebp),%eax
  802305:	a3 08 a0 80 00       	mov    %eax,0x80a008
	return nsipc(NSREQ_SEND);
  80230a:	b8 08 00 00 00       	mov    $0x8,%eax
  80230f:	e8 e8 fd ff ff       	call   8020fc <nsipc>
}
  802314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802317:	c9                   	leave  
  802318:	c3                   	ret    
	assert(size < 1600);
  802319:	68 cf 30 80 00       	push   $0x8030cf
  80231e:	68 c3 2f 80 00       	push   $0x802fc3
  802323:	6a 6d                	push   $0x6d
  802325:	68 c3 30 80 00       	push   $0x8030c3
  80232a:	e8 c2 e0 ff ff       	call   8003f1 <_panic>

0080232f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80232f:	55                   	push   %ebp
  802330:	89 e5                	mov    %esp,%ebp
  802332:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802335:	8b 45 08             	mov    0x8(%ebp),%eax
  802338:	a3 00 a0 80 00       	mov    %eax,0x80a000
	nsipcbuf.socket.req_type = type;
  80233d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802340:	a3 04 a0 80 00       	mov    %eax,0x80a004
	nsipcbuf.socket.req_protocol = protocol;
  802345:	8b 45 10             	mov    0x10(%ebp),%eax
  802348:	a3 08 a0 80 00       	mov    %eax,0x80a008
	return nsipc(NSREQ_SOCKET);
  80234d:	b8 09 00 00 00       	mov    $0x9,%eax
  802352:	e8 a5 fd ff ff       	call   8020fc <nsipc>
}
  802357:	c9                   	leave  
  802358:	c3                   	ret    

00802359 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	56                   	push   %esi
  80235d:	53                   	push   %ebx
  80235e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802361:	83 ec 0c             	sub    $0xc,%esp
  802364:	ff 75 08             	push   0x8(%ebp)
  802367:	e8 98 ed ff ff       	call   801104 <fd2data>
  80236c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80236e:	83 c4 08             	add    $0x8,%esp
  802371:	68 db 30 80 00       	push   $0x8030db
  802376:	53                   	push   %ebx
  802377:	e8 2a e7 ff ff       	call   800aa6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80237c:	8b 46 04             	mov    0x4(%esi),%eax
  80237f:	2b 06                	sub    (%esi),%eax
  802381:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802387:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80238e:	00 00 00 
	stat->st_dev = &devpipe;
  802391:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  802398:	57 80 00 
	return 0;
}
  80239b:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a3:	5b                   	pop    %ebx
  8023a4:	5e                   	pop    %esi
  8023a5:	5d                   	pop    %ebp
  8023a6:	c3                   	ret    

008023a7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023a7:	55                   	push   %ebp
  8023a8:	89 e5                	mov    %esp,%ebp
  8023aa:	53                   	push   %ebx
  8023ab:	83 ec 0c             	sub    $0xc,%esp
  8023ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023b1:	53                   	push   %ebx
  8023b2:	6a 00                	push   $0x0
  8023b4:	e8 6e eb ff ff       	call   800f27 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023b9:	89 1c 24             	mov    %ebx,(%esp)
  8023bc:	e8 43 ed ff ff       	call   801104 <fd2data>
  8023c1:	83 c4 08             	add    $0x8,%esp
  8023c4:	50                   	push   %eax
  8023c5:	6a 00                	push   $0x0
  8023c7:	e8 5b eb ff ff       	call   800f27 <sys_page_unmap>
}
  8023cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023cf:	c9                   	leave  
  8023d0:	c3                   	ret    

008023d1 <_pipeisclosed>:
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	57                   	push   %edi
  8023d5:	56                   	push   %esi
  8023d6:	53                   	push   %ebx
  8023d7:	83 ec 1c             	sub    $0x1c,%esp
  8023da:	89 c7                	mov    %eax,%edi
  8023dc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8023de:	a1 70 77 80 00       	mov    0x807770,%eax
  8023e3:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023e6:	83 ec 0c             	sub    $0xc,%esp
  8023e9:	57                   	push   %edi
  8023ea:	e8 09 04 00 00       	call   8027f8 <pageref>
  8023ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8023f2:	89 34 24             	mov    %esi,(%esp)
  8023f5:	e8 fe 03 00 00       	call   8027f8 <pageref>
		nn = thisenv->env_runs;
  8023fa:	8b 15 70 77 80 00    	mov    0x807770,%edx
  802400:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  802403:	83 c4 10             	add    $0x10,%esp
  802406:	39 cb                	cmp    %ecx,%ebx
  802408:	74 1b                	je     802425 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80240a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80240d:	75 cf                	jne    8023de <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80240f:	8b 42 68             	mov    0x68(%edx),%eax
  802412:	6a 01                	push   $0x1
  802414:	50                   	push   %eax
  802415:	53                   	push   %ebx
  802416:	68 e2 30 80 00       	push   $0x8030e2
  80241b:	e8 ac e0 ff ff       	call   8004cc <cprintf>
  802420:	83 c4 10             	add    $0x10,%esp
  802423:	eb b9                	jmp    8023de <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802425:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802428:	0f 94 c0             	sete   %al
  80242b:	0f b6 c0             	movzbl %al,%eax
}
  80242e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802431:	5b                   	pop    %ebx
  802432:	5e                   	pop    %esi
  802433:	5f                   	pop    %edi
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    

00802436 <devpipe_write>:
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	57                   	push   %edi
  80243a:	56                   	push   %esi
  80243b:	53                   	push   %ebx
  80243c:	83 ec 28             	sub    $0x28,%esp
  80243f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802442:	56                   	push   %esi
  802443:	e8 bc ec ff ff       	call   801104 <fd2data>
  802448:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80244a:	83 c4 10             	add    $0x10,%esp
  80244d:	bf 00 00 00 00       	mov    $0x0,%edi
  802452:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802455:	75 09                	jne    802460 <devpipe_write+0x2a>
	return i;
  802457:	89 f8                	mov    %edi,%eax
  802459:	eb 23                	jmp    80247e <devpipe_write+0x48>
			sys_yield();
  80245b:	e8 23 ea ff ff       	call   800e83 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802460:	8b 43 04             	mov    0x4(%ebx),%eax
  802463:	8b 0b                	mov    (%ebx),%ecx
  802465:	8d 51 20             	lea    0x20(%ecx),%edx
  802468:	39 d0                	cmp    %edx,%eax
  80246a:	72 1a                	jb     802486 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80246c:	89 da                	mov    %ebx,%edx
  80246e:	89 f0                	mov    %esi,%eax
  802470:	e8 5c ff ff ff       	call   8023d1 <_pipeisclosed>
  802475:	85 c0                	test   %eax,%eax
  802477:	74 e2                	je     80245b <devpipe_write+0x25>
				return 0;
  802479:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80247e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802481:	5b                   	pop    %ebx
  802482:	5e                   	pop    %esi
  802483:	5f                   	pop    %edi
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802486:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802489:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80248d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802490:	89 c2                	mov    %eax,%edx
  802492:	c1 fa 1f             	sar    $0x1f,%edx
  802495:	89 d1                	mov    %edx,%ecx
  802497:	c1 e9 1b             	shr    $0x1b,%ecx
  80249a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80249d:	83 e2 1f             	and    $0x1f,%edx
  8024a0:	29 ca                	sub    %ecx,%edx
  8024a2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8024a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024aa:	83 c0 01             	add    $0x1,%eax
  8024ad:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8024b0:	83 c7 01             	add    $0x1,%edi
  8024b3:	eb 9d                	jmp    802452 <devpipe_write+0x1c>

008024b5 <devpipe_read>:
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	57                   	push   %edi
  8024b9:	56                   	push   %esi
  8024ba:	53                   	push   %ebx
  8024bb:	83 ec 18             	sub    $0x18,%esp
  8024be:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8024c1:	57                   	push   %edi
  8024c2:	e8 3d ec ff ff       	call   801104 <fd2data>
  8024c7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8024c9:	83 c4 10             	add    $0x10,%esp
  8024cc:	be 00 00 00 00       	mov    $0x0,%esi
  8024d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024d4:	75 13                	jne    8024e9 <devpipe_read+0x34>
	return i;
  8024d6:	89 f0                	mov    %esi,%eax
  8024d8:	eb 02                	jmp    8024dc <devpipe_read+0x27>
				return i;
  8024da:	89 f0                	mov    %esi,%eax
}
  8024dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
			sys_yield();
  8024e4:	e8 9a e9 ff ff       	call   800e83 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8024e9:	8b 03                	mov    (%ebx),%eax
  8024eb:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024ee:	75 18                	jne    802508 <devpipe_read+0x53>
			if (i > 0)
  8024f0:	85 f6                	test   %esi,%esi
  8024f2:	75 e6                	jne    8024da <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8024f4:	89 da                	mov    %ebx,%edx
  8024f6:	89 f8                	mov    %edi,%eax
  8024f8:	e8 d4 fe ff ff       	call   8023d1 <_pipeisclosed>
  8024fd:	85 c0                	test   %eax,%eax
  8024ff:	74 e3                	je     8024e4 <devpipe_read+0x2f>
				return 0;
  802501:	b8 00 00 00 00       	mov    $0x0,%eax
  802506:	eb d4                	jmp    8024dc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802508:	99                   	cltd   
  802509:	c1 ea 1b             	shr    $0x1b,%edx
  80250c:	01 d0                	add    %edx,%eax
  80250e:	83 e0 1f             	and    $0x1f,%eax
  802511:	29 d0                	sub    %edx,%eax
  802513:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802518:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80251b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80251e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802521:	83 c6 01             	add    $0x1,%esi
  802524:	eb ab                	jmp    8024d1 <devpipe_read+0x1c>

00802526 <pipe>:
{
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	56                   	push   %esi
  80252a:	53                   	push   %ebx
  80252b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80252e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802531:	50                   	push   %eax
  802532:	e8 e4 eb ff ff       	call   80111b <fd_alloc>
  802537:	89 c3                	mov    %eax,%ebx
  802539:	83 c4 10             	add    $0x10,%esp
  80253c:	85 c0                	test   %eax,%eax
  80253e:	0f 88 23 01 00 00    	js     802667 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802544:	83 ec 04             	sub    $0x4,%esp
  802547:	68 07 04 00 00       	push   $0x407
  80254c:	ff 75 f4             	push   -0xc(%ebp)
  80254f:	6a 00                	push   $0x0
  802551:	e8 4c e9 ff ff       	call   800ea2 <sys_page_alloc>
  802556:	89 c3                	mov    %eax,%ebx
  802558:	83 c4 10             	add    $0x10,%esp
  80255b:	85 c0                	test   %eax,%eax
  80255d:	0f 88 04 01 00 00    	js     802667 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802563:	83 ec 0c             	sub    $0xc,%esp
  802566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802569:	50                   	push   %eax
  80256a:	e8 ac eb ff ff       	call   80111b <fd_alloc>
  80256f:	89 c3                	mov    %eax,%ebx
  802571:	83 c4 10             	add    $0x10,%esp
  802574:	85 c0                	test   %eax,%eax
  802576:	0f 88 db 00 00 00    	js     802657 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80257c:	83 ec 04             	sub    $0x4,%esp
  80257f:	68 07 04 00 00       	push   $0x407
  802584:	ff 75 f0             	push   -0x10(%ebp)
  802587:	6a 00                	push   $0x0
  802589:	e8 14 e9 ff ff       	call   800ea2 <sys_page_alloc>
  80258e:	89 c3                	mov    %eax,%ebx
  802590:	83 c4 10             	add    $0x10,%esp
  802593:	85 c0                	test   %eax,%eax
  802595:	0f 88 bc 00 00 00    	js     802657 <pipe+0x131>
	va = fd2data(fd0);
  80259b:	83 ec 0c             	sub    $0xc,%esp
  80259e:	ff 75 f4             	push   -0xc(%ebp)
  8025a1:	e8 5e eb ff ff       	call   801104 <fd2data>
  8025a6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025a8:	83 c4 0c             	add    $0xc,%esp
  8025ab:	68 07 04 00 00       	push   $0x407
  8025b0:	50                   	push   %eax
  8025b1:	6a 00                	push   $0x0
  8025b3:	e8 ea e8 ff ff       	call   800ea2 <sys_page_alloc>
  8025b8:	89 c3                	mov    %eax,%ebx
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	0f 88 82 00 00 00    	js     802647 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025c5:	83 ec 0c             	sub    $0xc,%esp
  8025c8:	ff 75 f0             	push   -0x10(%ebp)
  8025cb:	e8 34 eb ff ff       	call   801104 <fd2data>
  8025d0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025d7:	50                   	push   %eax
  8025d8:	6a 00                	push   $0x0
  8025da:	56                   	push   %esi
  8025db:	6a 00                	push   $0x0
  8025dd:	e8 03 e9 ff ff       	call   800ee5 <sys_page_map>
  8025e2:	89 c3                	mov    %eax,%ebx
  8025e4:	83 c4 20             	add    $0x20,%esp
  8025e7:	85 c0                	test   %eax,%eax
  8025e9:	78 4e                	js     802639 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8025eb:	a1 c8 57 80 00       	mov    0x8057c8,%eax
  8025f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8025f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8025ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802602:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802607:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80260e:	83 ec 0c             	sub    $0xc,%esp
  802611:	ff 75 f4             	push   -0xc(%ebp)
  802614:	e8 db ea ff ff       	call   8010f4 <fd2num>
  802619:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80261c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80261e:	83 c4 04             	add    $0x4,%esp
  802621:	ff 75 f0             	push   -0x10(%ebp)
  802624:	e8 cb ea ff ff       	call   8010f4 <fd2num>
  802629:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80262f:	83 c4 10             	add    $0x10,%esp
  802632:	bb 00 00 00 00       	mov    $0x0,%ebx
  802637:	eb 2e                	jmp    802667 <pipe+0x141>
	sys_page_unmap(0, va);
  802639:	83 ec 08             	sub    $0x8,%esp
  80263c:	56                   	push   %esi
  80263d:	6a 00                	push   $0x0
  80263f:	e8 e3 e8 ff ff       	call   800f27 <sys_page_unmap>
  802644:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802647:	83 ec 08             	sub    $0x8,%esp
  80264a:	ff 75 f0             	push   -0x10(%ebp)
  80264d:	6a 00                	push   $0x0
  80264f:	e8 d3 e8 ff ff       	call   800f27 <sys_page_unmap>
  802654:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802657:	83 ec 08             	sub    $0x8,%esp
  80265a:	ff 75 f4             	push   -0xc(%ebp)
  80265d:	6a 00                	push   $0x0
  80265f:	e8 c3 e8 ff ff       	call   800f27 <sys_page_unmap>
  802664:	83 c4 10             	add    $0x10,%esp
}
  802667:	89 d8                	mov    %ebx,%eax
  802669:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80266c:	5b                   	pop    %ebx
  80266d:	5e                   	pop    %esi
  80266e:	5d                   	pop    %ebp
  80266f:	c3                   	ret    

00802670 <pipeisclosed>:
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802679:	50                   	push   %eax
  80267a:	ff 75 08             	push   0x8(%ebp)
  80267d:	e8 e9 ea ff ff       	call   80116b <fd_lookup>
  802682:	83 c4 10             	add    $0x10,%esp
  802685:	85 c0                	test   %eax,%eax
  802687:	78 18                	js     8026a1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802689:	83 ec 0c             	sub    $0xc,%esp
  80268c:	ff 75 f4             	push   -0xc(%ebp)
  80268f:	e8 70 ea ff ff       	call   801104 <fd2data>
  802694:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802699:	e8 33 fd ff ff       	call   8023d1 <_pipeisclosed>
  80269e:	83 c4 10             	add    $0x10,%esp
}
  8026a1:	c9                   	leave  
  8026a2:	c3                   	ret    

008026a3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8026a3:	55                   	push   %ebp
  8026a4:	89 e5                	mov    %esp,%ebp
  8026a6:	56                   	push   %esi
  8026a7:	53                   	push   %ebx
  8026a8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026ab:	85 f6                	test   %esi,%esi
  8026ad:	74 16                	je     8026c5 <wait+0x22>
	e = &envs[ENVX(envid)];
  8026af:	89 f3                	mov    %esi,%ebx
  8026b1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026b7:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  8026bd:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026c3:	eb 1b                	jmp    8026e0 <wait+0x3d>
	assert(envid != 0);
  8026c5:	68 fa 30 80 00       	push   $0x8030fa
  8026ca:	68 c3 2f 80 00       	push   $0x802fc3
  8026cf:	6a 09                	push   $0x9
  8026d1:	68 05 31 80 00       	push   $0x803105
  8026d6:	e8 16 dd ff ff       	call   8003f1 <_panic>
		sys_yield();
  8026db:	e8 a3 e7 ff ff       	call   800e83 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026e0:	8b 43 58             	mov    0x58(%ebx),%eax
  8026e3:	39 f0                	cmp    %esi,%eax
  8026e5:	75 07                	jne    8026ee <wait+0x4b>
  8026e7:	8b 43 64             	mov    0x64(%ebx),%eax
  8026ea:	85 c0                	test   %eax,%eax
  8026ec:	75 ed                	jne    8026db <wait+0x38>
}
  8026ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f1:	5b                   	pop    %ebx
  8026f2:	5e                   	pop    %esi
  8026f3:	5d                   	pop    %ebp
  8026f4:	c3                   	ret    

008026f5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026f5:	55                   	push   %ebp
  8026f6:	89 e5                	mov    %esp,%ebp
  8026f8:	56                   	push   %esi
  8026f9:	53                   	push   %ebx
  8026fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8026fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802700:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802703:	85 c0                	test   %eax,%eax
  802705:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80270a:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80270d:	83 ec 0c             	sub    $0xc,%esp
  802710:	50                   	push   %eax
  802711:	e8 3c e9 ff ff       	call   801052 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802716:	83 c4 10             	add    $0x10,%esp
  802719:	85 f6                	test   %esi,%esi
  80271b:	74 17                	je     802734 <ipc_recv+0x3f>
  80271d:	ba 00 00 00 00       	mov    $0x0,%edx
  802722:	85 c0                	test   %eax,%eax
  802724:	78 0c                	js     802732 <ipc_recv+0x3d>
  802726:	8b 15 70 77 80 00    	mov    0x807770,%edx
  80272c:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802732:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802734:	85 db                	test   %ebx,%ebx
  802736:	74 17                	je     80274f <ipc_recv+0x5a>
  802738:	ba 00 00 00 00       	mov    $0x0,%edx
  80273d:	85 c0                	test   %eax,%eax
  80273f:	78 0c                	js     80274d <ipc_recv+0x58>
  802741:	8b 15 70 77 80 00    	mov    0x807770,%edx
  802747:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80274d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80274f:	85 c0                	test   %eax,%eax
  802751:	78 0b                	js     80275e <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802753:	a1 70 77 80 00       	mov    0x807770,%eax
  802758:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80275e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802761:	5b                   	pop    %ebx
  802762:	5e                   	pop    %esi
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    

00802765 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	57                   	push   %edi
  802769:	56                   	push   %esi
  80276a:	53                   	push   %ebx
  80276b:	83 ec 0c             	sub    $0xc,%esp
  80276e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802771:	8b 75 0c             	mov    0xc(%ebp),%esi
  802774:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802777:	85 db                	test   %ebx,%ebx
  802779:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80277e:	0f 44 d8             	cmove  %eax,%ebx
  802781:	eb 05                	jmp    802788 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802783:	e8 fb e6 ff ff       	call   800e83 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802788:	ff 75 14             	push   0x14(%ebp)
  80278b:	53                   	push   %ebx
  80278c:	56                   	push   %esi
  80278d:	57                   	push   %edi
  80278e:	e8 9c e8 ff ff       	call   80102f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802793:	83 c4 10             	add    $0x10,%esp
  802796:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802799:	74 e8                	je     802783 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80279b:	85 c0                	test   %eax,%eax
  80279d:	78 08                	js     8027a7 <ipc_send+0x42>
	}while (r<0);

}
  80279f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027a2:	5b                   	pop    %ebx
  8027a3:	5e                   	pop    %esi
  8027a4:	5f                   	pop    %edi
  8027a5:	5d                   	pop    %ebp
  8027a6:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8027a7:	50                   	push   %eax
  8027a8:	68 10 31 80 00       	push   $0x803110
  8027ad:	6a 3d                	push   $0x3d
  8027af:	68 24 31 80 00       	push   $0x803124
  8027b4:	e8 38 dc ff ff       	call   8003f1 <_panic>

008027b9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027b9:	55                   	push   %ebp
  8027ba:	89 e5                	mov    %esp,%ebp
  8027bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c4:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8027ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027d0:	8b 52 60             	mov    0x60(%edx),%edx
  8027d3:	39 ca                	cmp    %ecx,%edx
  8027d5:	74 11                	je     8027e8 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8027d7:	83 c0 01             	add    $0x1,%eax
  8027da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027df:	75 e3                	jne    8027c4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8027e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8027e6:	eb 0e                	jmp    8027f6 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8027e8:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8027ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027f3:	8b 40 58             	mov    0x58(%eax),%eax
}
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    

008027f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027f8:	55                   	push   %ebp
  8027f9:	89 e5                	mov    %esp,%ebp
  8027fb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027fe:	89 c2                	mov    %eax,%edx
  802800:	c1 ea 16             	shr    $0x16,%edx
  802803:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80280a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80280f:	f6 c1 01             	test   $0x1,%cl
  802812:	74 1c                	je     802830 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802814:	c1 e8 0c             	shr    $0xc,%eax
  802817:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80281e:	a8 01                	test   $0x1,%al
  802820:	74 0e                	je     802830 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802822:	c1 e8 0c             	shr    $0xc,%eax
  802825:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80282c:	ef 
  80282d:	0f b7 d2             	movzwl %dx,%edx
}
  802830:	89 d0                	mov    %edx,%eax
  802832:	5d                   	pop    %ebp
  802833:	c3                   	ret    
  802834:	66 90                	xchg   %ax,%ax
  802836:	66 90                	xchg   %ax,%ax
  802838:	66 90                	xchg   %ax,%ax
  80283a:	66 90                	xchg   %ax,%ax
  80283c:	66 90                	xchg   %ax,%ax
  80283e:	66 90                	xchg   %ax,%ax

00802840 <__udivdi3>:
  802840:	f3 0f 1e fb          	endbr32 
  802844:	55                   	push   %ebp
  802845:	57                   	push   %edi
  802846:	56                   	push   %esi
  802847:	53                   	push   %ebx
  802848:	83 ec 1c             	sub    $0x1c,%esp
  80284b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80284f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802853:	8b 74 24 34          	mov    0x34(%esp),%esi
  802857:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80285b:	85 c0                	test   %eax,%eax
  80285d:	75 19                	jne    802878 <__udivdi3+0x38>
  80285f:	39 f3                	cmp    %esi,%ebx
  802861:	76 4d                	jbe    8028b0 <__udivdi3+0x70>
  802863:	31 ff                	xor    %edi,%edi
  802865:	89 e8                	mov    %ebp,%eax
  802867:	89 f2                	mov    %esi,%edx
  802869:	f7 f3                	div    %ebx
  80286b:	89 fa                	mov    %edi,%edx
  80286d:	83 c4 1c             	add    $0x1c,%esp
  802870:	5b                   	pop    %ebx
  802871:	5e                   	pop    %esi
  802872:	5f                   	pop    %edi
  802873:	5d                   	pop    %ebp
  802874:	c3                   	ret    
  802875:	8d 76 00             	lea    0x0(%esi),%esi
  802878:	39 f0                	cmp    %esi,%eax
  80287a:	76 14                	jbe    802890 <__udivdi3+0x50>
  80287c:	31 ff                	xor    %edi,%edi
  80287e:	31 c0                	xor    %eax,%eax
  802880:	89 fa                	mov    %edi,%edx
  802882:	83 c4 1c             	add    $0x1c,%esp
  802885:	5b                   	pop    %ebx
  802886:	5e                   	pop    %esi
  802887:	5f                   	pop    %edi
  802888:	5d                   	pop    %ebp
  802889:	c3                   	ret    
  80288a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802890:	0f bd f8             	bsr    %eax,%edi
  802893:	83 f7 1f             	xor    $0x1f,%edi
  802896:	75 48                	jne    8028e0 <__udivdi3+0xa0>
  802898:	39 f0                	cmp    %esi,%eax
  80289a:	72 06                	jb     8028a2 <__udivdi3+0x62>
  80289c:	31 c0                	xor    %eax,%eax
  80289e:	39 eb                	cmp    %ebp,%ebx
  8028a0:	77 de                	ja     802880 <__udivdi3+0x40>
  8028a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8028a7:	eb d7                	jmp    802880 <__udivdi3+0x40>
  8028a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028b0:	89 d9                	mov    %ebx,%ecx
  8028b2:	85 db                	test   %ebx,%ebx
  8028b4:	75 0b                	jne    8028c1 <__udivdi3+0x81>
  8028b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028bb:	31 d2                	xor    %edx,%edx
  8028bd:	f7 f3                	div    %ebx
  8028bf:	89 c1                	mov    %eax,%ecx
  8028c1:	31 d2                	xor    %edx,%edx
  8028c3:	89 f0                	mov    %esi,%eax
  8028c5:	f7 f1                	div    %ecx
  8028c7:	89 c6                	mov    %eax,%esi
  8028c9:	89 e8                	mov    %ebp,%eax
  8028cb:	89 f7                	mov    %esi,%edi
  8028cd:	f7 f1                	div    %ecx
  8028cf:	89 fa                	mov    %edi,%edx
  8028d1:	83 c4 1c             	add    $0x1c,%esp
  8028d4:	5b                   	pop    %ebx
  8028d5:	5e                   	pop    %esi
  8028d6:	5f                   	pop    %edi
  8028d7:	5d                   	pop    %ebp
  8028d8:	c3                   	ret    
  8028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	89 f9                	mov    %edi,%ecx
  8028e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8028e7:	29 fa                	sub    %edi,%edx
  8028e9:	d3 e0                	shl    %cl,%eax
  8028eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028ef:	89 d1                	mov    %edx,%ecx
  8028f1:	89 d8                	mov    %ebx,%eax
  8028f3:	d3 e8                	shr    %cl,%eax
  8028f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8028f9:	09 c1                	or     %eax,%ecx
  8028fb:	89 f0                	mov    %esi,%eax
  8028fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802901:	89 f9                	mov    %edi,%ecx
  802903:	d3 e3                	shl    %cl,%ebx
  802905:	89 d1                	mov    %edx,%ecx
  802907:	d3 e8                	shr    %cl,%eax
  802909:	89 f9                	mov    %edi,%ecx
  80290b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80290f:	89 eb                	mov    %ebp,%ebx
  802911:	d3 e6                	shl    %cl,%esi
  802913:	89 d1                	mov    %edx,%ecx
  802915:	d3 eb                	shr    %cl,%ebx
  802917:	09 f3                	or     %esi,%ebx
  802919:	89 c6                	mov    %eax,%esi
  80291b:	89 f2                	mov    %esi,%edx
  80291d:	89 d8                	mov    %ebx,%eax
  80291f:	f7 74 24 08          	divl   0x8(%esp)
  802923:	89 d6                	mov    %edx,%esi
  802925:	89 c3                	mov    %eax,%ebx
  802927:	f7 64 24 0c          	mull   0xc(%esp)
  80292b:	39 d6                	cmp    %edx,%esi
  80292d:	72 19                	jb     802948 <__udivdi3+0x108>
  80292f:	89 f9                	mov    %edi,%ecx
  802931:	d3 e5                	shl    %cl,%ebp
  802933:	39 c5                	cmp    %eax,%ebp
  802935:	73 04                	jae    80293b <__udivdi3+0xfb>
  802937:	39 d6                	cmp    %edx,%esi
  802939:	74 0d                	je     802948 <__udivdi3+0x108>
  80293b:	89 d8                	mov    %ebx,%eax
  80293d:	31 ff                	xor    %edi,%edi
  80293f:	e9 3c ff ff ff       	jmp    802880 <__udivdi3+0x40>
  802944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802948:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80294b:	31 ff                	xor    %edi,%edi
  80294d:	e9 2e ff ff ff       	jmp    802880 <__udivdi3+0x40>
  802952:	66 90                	xchg   %ax,%ax
  802954:	66 90                	xchg   %ax,%ax
  802956:	66 90                	xchg   %ax,%ax
  802958:	66 90                	xchg   %ax,%ax
  80295a:	66 90                	xchg   %ax,%ax
  80295c:	66 90                	xchg   %ax,%ax
  80295e:	66 90                	xchg   %ax,%ax

00802960 <__umoddi3>:
  802960:	f3 0f 1e fb          	endbr32 
  802964:	55                   	push   %ebp
  802965:	57                   	push   %edi
  802966:	56                   	push   %esi
  802967:	53                   	push   %ebx
  802968:	83 ec 1c             	sub    $0x1c,%esp
  80296b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80296f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802973:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802977:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80297b:	89 f0                	mov    %esi,%eax
  80297d:	89 da                	mov    %ebx,%edx
  80297f:	85 ff                	test   %edi,%edi
  802981:	75 15                	jne    802998 <__umoddi3+0x38>
  802983:	39 dd                	cmp    %ebx,%ebp
  802985:	76 39                	jbe    8029c0 <__umoddi3+0x60>
  802987:	f7 f5                	div    %ebp
  802989:	89 d0                	mov    %edx,%eax
  80298b:	31 d2                	xor    %edx,%edx
  80298d:	83 c4 1c             	add    $0x1c,%esp
  802990:	5b                   	pop    %ebx
  802991:	5e                   	pop    %esi
  802992:	5f                   	pop    %edi
  802993:	5d                   	pop    %ebp
  802994:	c3                   	ret    
  802995:	8d 76 00             	lea    0x0(%esi),%esi
  802998:	39 df                	cmp    %ebx,%edi
  80299a:	77 f1                	ja     80298d <__umoddi3+0x2d>
  80299c:	0f bd cf             	bsr    %edi,%ecx
  80299f:	83 f1 1f             	xor    $0x1f,%ecx
  8029a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8029a6:	75 40                	jne    8029e8 <__umoddi3+0x88>
  8029a8:	39 df                	cmp    %ebx,%edi
  8029aa:	72 04                	jb     8029b0 <__umoddi3+0x50>
  8029ac:	39 f5                	cmp    %esi,%ebp
  8029ae:	77 dd                	ja     80298d <__umoddi3+0x2d>
  8029b0:	89 da                	mov    %ebx,%edx
  8029b2:	89 f0                	mov    %esi,%eax
  8029b4:	29 e8                	sub    %ebp,%eax
  8029b6:	19 fa                	sbb    %edi,%edx
  8029b8:	eb d3                	jmp    80298d <__umoddi3+0x2d>
  8029ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029c0:	89 e9                	mov    %ebp,%ecx
  8029c2:	85 ed                	test   %ebp,%ebp
  8029c4:	75 0b                	jne    8029d1 <__umoddi3+0x71>
  8029c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029cb:	31 d2                	xor    %edx,%edx
  8029cd:	f7 f5                	div    %ebp
  8029cf:	89 c1                	mov    %eax,%ecx
  8029d1:	89 d8                	mov    %ebx,%eax
  8029d3:	31 d2                	xor    %edx,%edx
  8029d5:	f7 f1                	div    %ecx
  8029d7:	89 f0                	mov    %esi,%eax
  8029d9:	f7 f1                	div    %ecx
  8029db:	89 d0                	mov    %edx,%eax
  8029dd:	31 d2                	xor    %edx,%edx
  8029df:	eb ac                	jmp    80298d <__umoddi3+0x2d>
  8029e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8029f1:	29 c2                	sub    %eax,%edx
  8029f3:	89 c1                	mov    %eax,%ecx
  8029f5:	89 e8                	mov    %ebp,%eax
  8029f7:	d3 e7                	shl    %cl,%edi
  8029f9:	89 d1                	mov    %edx,%ecx
  8029fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8029ff:	d3 e8                	shr    %cl,%eax
  802a01:	89 c1                	mov    %eax,%ecx
  802a03:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a07:	09 f9                	or     %edi,%ecx
  802a09:	89 df                	mov    %ebx,%edi
  802a0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a0f:	89 c1                	mov    %eax,%ecx
  802a11:	d3 e5                	shl    %cl,%ebp
  802a13:	89 d1                	mov    %edx,%ecx
  802a15:	d3 ef                	shr    %cl,%edi
  802a17:	89 c1                	mov    %eax,%ecx
  802a19:	89 f0                	mov    %esi,%eax
  802a1b:	d3 e3                	shl    %cl,%ebx
  802a1d:	89 d1                	mov    %edx,%ecx
  802a1f:	89 fa                	mov    %edi,%edx
  802a21:	d3 e8                	shr    %cl,%eax
  802a23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a28:	09 d8                	or     %ebx,%eax
  802a2a:	f7 74 24 08          	divl   0x8(%esp)
  802a2e:	89 d3                	mov    %edx,%ebx
  802a30:	d3 e6                	shl    %cl,%esi
  802a32:	f7 e5                	mul    %ebp
  802a34:	89 c7                	mov    %eax,%edi
  802a36:	89 d1                	mov    %edx,%ecx
  802a38:	39 d3                	cmp    %edx,%ebx
  802a3a:	72 06                	jb     802a42 <__umoddi3+0xe2>
  802a3c:	75 0e                	jne    802a4c <__umoddi3+0xec>
  802a3e:	39 c6                	cmp    %eax,%esi
  802a40:	73 0a                	jae    802a4c <__umoddi3+0xec>
  802a42:	29 e8                	sub    %ebp,%eax
  802a44:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802a48:	89 d1                	mov    %edx,%ecx
  802a4a:	89 c7                	mov    %eax,%edi
  802a4c:	89 f5                	mov    %esi,%ebp
  802a4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a52:	29 fd                	sub    %edi,%ebp
  802a54:	19 cb                	sbb    %ecx,%ebx
  802a56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802a5b:	89 d8                	mov    %ebx,%eax
  802a5d:	d3 e0                	shl    %cl,%eax
  802a5f:	89 f1                	mov    %esi,%ecx
  802a61:	d3 ed                	shr    %cl,%ebp
  802a63:	d3 eb                	shr    %cl,%ebx
  802a65:	09 e8                	or     %ebp,%eax
  802a67:	89 da                	mov    %ebx,%edx
  802a69:	83 c4 1c             	add    $0x1c,%esp
  802a6c:	5b                   	pop    %ebx
  802a6d:	5e                   	pop    %esi
  802a6e:	5f                   	pop    %edi
  802a6f:	5d                   	pop    %ebp
  802a70:	c3                   	ret    
