
obj/user/testkbd.debug：     文件格式 elf32-i386


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
  80002c:	e8 28 02 00 00       	call   800259 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 f7 0d 00 00       	call   800e3b <sys_yield>
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 fd 11 00 00       	call   801250 <close>
	if ((r = opencons()) < 0)
  800053:	e8 af 01 00 00       	call   800207 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	78 14                	js     800073 <umain+0x40>
		panic("opencons: %e", r);
	if (r != 0)
  80005f:	74 24                	je     800085 <umain+0x52>
		panic("first opencons used fd %d", r);
  800061:	50                   	push   %eax
  800062:	68 fc 24 80 00       	push   $0x8024fc
  800067:	6a 11                	push   $0x11
  800069:	68 ed 24 80 00       	push   $0x8024ed
  80006e:	e8 46 02 00 00       	call   8002b9 <_panic>
		panic("opencons: %e", r);
  800073:	50                   	push   %eax
  800074:	68 e0 24 80 00       	push   $0x8024e0
  800079:	6a 0f                	push   $0xf
  80007b:	68 ed 24 80 00       	push   $0x8024ed
  800080:	e8 34 02 00 00       	call   8002b9 <_panic>
	if ((r = dup(0, 1)) < 0)
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	6a 01                	push   $0x1
  80008a:	6a 00                	push   $0x0
  80008c:	e8 11 12 00 00       	call   8012a2 <dup>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 25                	jns    8000bd <umain+0x8a>
		panic("dup: %e", r);
  800098:	50                   	push   %eax
  800099:	68 16 25 80 00       	push   $0x802516
  80009e:	6a 13                	push   $0x13
  8000a0:	68 ed 24 80 00       	push   $0x8024ed
  8000a5:	e8 0f 02 00 00       	call   8002b9 <_panic>
	for(;;){
		char *buf;

		buf = readline("Type a line: ");
		if (buf != NULL)
			fprintf(1, "%s\n", buf);
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	50                   	push   %eax
  8000ae:	68 2c 25 80 00       	push   $0x80252c
  8000b3:	6a 01                	push   $0x1
  8000b5:	e8 c0 18 00 00       	call   80197a <fprintf>
  8000ba:	83 c4 10             	add    $0x10,%esp
		buf = readline("Type a line: ");
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	68 1e 25 80 00       	push   $0x80251e
  8000c5:	e8 69 08 00 00       	call   800933 <readline>
		if (buf != NULL)
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	75 d9                	jne    8000aa <umain+0x77>
		else
			fprintf(1, "(end of file received)\n");
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	68 30 25 80 00       	push   $0x802530
  8000d9:	6a 01                	push   $0x1
  8000db:	e8 9a 18 00 00       	call   80197a <fprintf>
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	eb d8                	jmp    8000bd <umain+0x8a>

008000e5 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	c3                   	ret    

008000eb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f1:	68 48 25 80 00       	push   $0x802548
  8000f6:	ff 75 0c             	push   0xc(%ebp)
  8000f9:	e8 60 09 00 00       	call   800a5e <strcpy>
	return 0;
}
  8000fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <devcons_write>:
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800111:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800116:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80011c:	eb 2e                	jmp    80014c <devcons_write+0x47>
		m = n - tot;
  80011e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800121:	29 f3                	sub    %esi,%ebx
  800123:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800128:	39 c3                	cmp    %eax,%ebx
  80012a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80012d:	83 ec 04             	sub    $0x4,%esp
  800130:	53                   	push   %ebx
  800131:	89 f0                	mov    %esi,%eax
  800133:	03 45 0c             	add    0xc(%ebp),%eax
  800136:	50                   	push   %eax
  800137:	57                   	push   %edi
  800138:	e8 b7 0a 00 00       	call   800bf4 <memmove>
		sys_cputs(buf, m);
  80013d:	83 c4 08             	add    $0x8,%esp
  800140:	53                   	push   %ebx
  800141:	57                   	push   %edi
  800142:	e8 57 0c 00 00       	call   800d9e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800147:	01 de                	add    %ebx,%esi
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80014f:	72 cd                	jb     80011e <devcons_write+0x19>
}
  800151:	89 f0                	mov    %esi,%eax
  800153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <devcons_read>:
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
  800161:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800166:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80016a:	75 07                	jne    800173 <devcons_read+0x18>
  80016c:	eb 1f                	jmp    80018d <devcons_read+0x32>
		sys_yield();
  80016e:	e8 c8 0c 00 00       	call   800e3b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800173:	e8 44 0c 00 00       	call   800dbc <sys_cgetc>
  800178:	85 c0                	test   %eax,%eax
  80017a:	74 f2                	je     80016e <devcons_read+0x13>
	if (c < 0)
  80017c:	78 0f                	js     80018d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80017e:	83 f8 04             	cmp    $0x4,%eax
  800181:	74 0c                	je     80018f <devcons_read+0x34>
	*(char*)vbuf = c;
  800183:	8b 55 0c             	mov    0xc(%ebp),%edx
  800186:	88 02                	mov    %al,(%edx)
	return 1;
  800188:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    
		return 0;
  80018f:	b8 00 00 00 00       	mov    $0x0,%eax
  800194:	eb f7                	jmp    80018d <devcons_read+0x32>

00800196 <cputchar>:
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80019c:	8b 45 08             	mov    0x8(%ebp),%eax
  80019f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8001a2:	6a 01                	push   $0x1
  8001a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 f1 0b 00 00       	call   800d9e <sys_cputs>
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <getchar>:
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8001b8:	6a 01                	push   $0x1
  8001ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001bd:	50                   	push   %eax
  8001be:	6a 00                	push   $0x0
  8001c0:	e8 c7 11 00 00       	call   80138c <read>
	if (r < 0)
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	78 06                	js     8001d2 <getchar+0x20>
	if (r < 1)
  8001cc:	74 06                	je     8001d4 <getchar+0x22>
	return c;
  8001ce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    
		return -E_EOF;
  8001d4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8001d9:	eb f7                	jmp    8001d2 <getchar+0x20>

008001db <iscons>:
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	ff 75 08             	push   0x8(%ebp)
  8001e8:	e8 36 0f 00 00       	call   801123 <fd_lookup>
  8001ed:	83 c4 10             	add    $0x10,%esp
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	78 11                	js     800205 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8001f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001f7:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8001fd:	39 10                	cmp    %edx,(%eax)
  8001ff:	0f 94 c0             	sete   %al
  800202:	0f b6 c0             	movzbl %al,%eax
}
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <opencons>:
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80020d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 bd 0e 00 00       	call   8010d3 <fd_alloc>
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	85 c0                	test   %eax,%eax
  80021b:	78 3a                	js     800257 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80021d:	83 ec 04             	sub    $0x4,%esp
  800220:	68 07 04 00 00       	push   $0x407
  800225:	ff 75 f4             	push   -0xc(%ebp)
  800228:	6a 00                	push   $0x0
  80022a:	e8 2b 0c 00 00       	call   800e5a <sys_page_alloc>
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	85 c0                	test   %eax,%eax
  800234:	78 21                	js     800257 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800239:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80023f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800244:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	50                   	push   %eax
  80024f:	e8 58 0e 00 00       	call   8010ac <fd2num>
  800254:	83 c4 10             	add    $0x10,%esp
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800261:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800264:	e8 b3 0b 00 00       	call   800e1c <sys_getenvid>
  800269:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800271:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800276:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027b:	85 db                	test   %ebx,%ebx
  80027d:	7e 07                	jle    800286 <libmain+0x2d>
		binaryname = argv[0];
  80027f:	8b 06                	mov    (%esi),%eax
  800281:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	53                   	push   %ebx
  80028b:	e8 a3 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800290:	e8 0a 00 00 00       	call   80029f <exit>
}
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002a5:	e8 d3 0f 00 00       	call   80127d <close_all>
	sys_env_destroy(0);
  8002aa:	83 ec 0c             	sub    $0xc,%esp
  8002ad:	6a 00                	push   $0x0
  8002af:	e8 27 0b 00 00       	call   800ddb <sys_env_destroy>
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002be:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c1:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002c7:	e8 50 0b 00 00       	call   800e1c <sys_getenvid>
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	ff 75 0c             	push   0xc(%ebp)
  8002d2:	ff 75 08             	push   0x8(%ebp)
  8002d5:	56                   	push   %esi
  8002d6:	50                   	push   %eax
  8002d7:	68 60 25 80 00       	push   $0x802560
  8002dc:	e8 b3 00 00 00       	call   800394 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e1:	83 c4 18             	add    $0x18,%esp
  8002e4:	53                   	push   %ebx
  8002e5:	ff 75 10             	push   0x10(%ebp)
  8002e8:	e8 56 00 00 00       	call   800343 <vcprintf>
	cprintf("\n");
  8002ed:	c7 04 24 46 25 80 00 	movl   $0x802546,(%esp)
  8002f4:	e8 9b 00 00 00       	call   800394 <cprintf>
  8002f9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002fc:	cc                   	int3   
  8002fd:	eb fd                	jmp    8002fc <_panic+0x43>

008002ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	53                   	push   %ebx
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800309:	8b 13                	mov    (%ebx),%edx
  80030b:	8d 42 01             	lea    0x1(%edx),%eax
  80030e:	89 03                	mov    %eax,(%ebx)
  800310:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800313:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800317:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031c:	74 09                	je     800327 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80031e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800325:	c9                   	leave  
  800326:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	68 ff 00 00 00       	push   $0xff
  80032f:	8d 43 08             	lea    0x8(%ebx),%eax
  800332:	50                   	push   %eax
  800333:	e8 66 0a 00 00       	call   800d9e <sys_cputs>
		b->idx = 0;
  800338:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80033e:	83 c4 10             	add    $0x10,%esp
  800341:	eb db                	jmp    80031e <putch+0x1f>

00800343 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80034c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800353:	00 00 00 
	b.cnt = 0;
  800356:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80035d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800360:	ff 75 0c             	push   0xc(%ebp)
  800363:	ff 75 08             	push   0x8(%ebp)
  800366:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036c:	50                   	push   %eax
  80036d:	68 ff 02 80 00       	push   $0x8002ff
  800372:	e8 14 01 00 00       	call   80048b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800377:	83 c4 08             	add    $0x8,%esp
  80037a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800380:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800386:	50                   	push   %eax
  800387:	e8 12 0a 00 00       	call   800d9e <sys_cputs>

	return b.cnt;
}
  80038c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80039d:	50                   	push   %eax
  80039e:	ff 75 08             	push   0x8(%ebp)
  8003a1:	e8 9d ff ff ff       	call   800343 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
  8003ae:	83 ec 1c             	sub    $0x1c,%esp
  8003b1:	89 c7                	mov    %eax,%edi
  8003b3:	89 d6                	mov    %edx,%esi
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bb:	89 d1                	mov    %edx,%ecx
  8003bd:	89 c2                	mov    %eax,%edx
  8003bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d5:	39 c2                	cmp    %eax,%edx
  8003d7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003da:	72 3e                	jb     80041a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003dc:	83 ec 0c             	sub    $0xc,%esp
  8003df:	ff 75 18             	push   0x18(%ebp)
  8003e2:	83 eb 01             	sub    $0x1,%ebx
  8003e5:	53                   	push   %ebx
  8003e6:	50                   	push   %eax
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	ff 75 e4             	push   -0x1c(%ebp)
  8003ed:	ff 75 e0             	push   -0x20(%ebp)
  8003f0:	ff 75 dc             	push   -0x24(%ebp)
  8003f3:	ff 75 d8             	push   -0x28(%ebp)
  8003f6:	e8 95 1e 00 00       	call   802290 <__udivdi3>
  8003fb:	83 c4 18             	add    $0x18,%esp
  8003fe:	52                   	push   %edx
  8003ff:	50                   	push   %eax
  800400:	89 f2                	mov    %esi,%edx
  800402:	89 f8                	mov    %edi,%eax
  800404:	e8 9f ff ff ff       	call   8003a8 <printnum>
  800409:	83 c4 20             	add    $0x20,%esp
  80040c:	eb 13                	jmp    800421 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	56                   	push   %esi
  800412:	ff 75 18             	push   0x18(%ebp)
  800415:	ff d7                	call   *%edi
  800417:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80041a:	83 eb 01             	sub    $0x1,%ebx
  80041d:	85 db                	test   %ebx,%ebx
  80041f:	7f ed                	jg     80040e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	56                   	push   %esi
  800425:	83 ec 04             	sub    $0x4,%esp
  800428:	ff 75 e4             	push   -0x1c(%ebp)
  80042b:	ff 75 e0             	push   -0x20(%ebp)
  80042e:	ff 75 dc             	push   -0x24(%ebp)
  800431:	ff 75 d8             	push   -0x28(%ebp)
  800434:	e8 77 1f 00 00       	call   8023b0 <__umoddi3>
  800439:	83 c4 14             	add    $0x14,%esp
  80043c:	0f be 80 83 25 80 00 	movsbl 0x802583(%eax),%eax
  800443:	50                   	push   %eax
  800444:	ff d7                	call   *%edi
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80044c:	5b                   	pop    %ebx
  80044d:	5e                   	pop    %esi
  80044e:	5f                   	pop    %edi
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800457:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80045b:	8b 10                	mov    (%eax),%edx
  80045d:	3b 50 04             	cmp    0x4(%eax),%edx
  800460:	73 0a                	jae    80046c <sprintputch+0x1b>
		*b->buf++ = ch;
  800462:	8d 4a 01             	lea    0x1(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	88 02                	mov    %al,(%edx)
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <printfmt>:
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800474:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800477:	50                   	push   %eax
  800478:	ff 75 10             	push   0x10(%ebp)
  80047b:	ff 75 0c             	push   0xc(%ebp)
  80047e:	ff 75 08             	push   0x8(%ebp)
  800481:	e8 05 00 00 00       	call   80048b <vprintfmt>
}
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	c9                   	leave  
  80048a:	c3                   	ret    

0080048b <vprintfmt>:
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	57                   	push   %edi
  80048f:	56                   	push   %esi
  800490:	53                   	push   %ebx
  800491:	83 ec 3c             	sub    $0x3c,%esp
  800494:	8b 75 08             	mov    0x8(%ebp),%esi
  800497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80049d:	eb 0a                	jmp    8004a9 <vprintfmt+0x1e>
			putch(ch, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	50                   	push   %eax
  8004a4:	ff d6                	call   *%esi
  8004a6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a9:	83 c7 01             	add    $0x1,%edi
  8004ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b0:	83 f8 25             	cmp    $0x25,%eax
  8004b3:	74 0c                	je     8004c1 <vprintfmt+0x36>
			if (ch == '\0')
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	75 e6                	jne    80049f <vprintfmt+0x14>
}
  8004b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bc:	5b                   	pop    %ebx
  8004bd:	5e                   	pop    %esi
  8004be:	5f                   	pop    %edi
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    
		padc = ' ';
  8004c1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004c5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004da:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8d 47 01             	lea    0x1(%edi),%eax
  8004e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e5:	0f b6 17             	movzbl (%edi),%edx
  8004e8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004eb:	3c 55                	cmp    $0x55,%al
  8004ed:	0f 87 bb 03 00 00    	ja     8008ae <vprintfmt+0x423>
  8004f3:	0f b6 c0             	movzbl %al,%eax
  8004f6:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  8004fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800500:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800504:	eb d9                	jmp    8004df <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80050d:	eb d0                	jmp    8004df <vprintfmt+0x54>
  80050f:	0f b6 d2             	movzbl %dl,%edx
  800512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80051d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800520:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800524:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800527:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80052a:	83 f9 09             	cmp    $0x9,%ecx
  80052d:	77 55                	ja     800584 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80052f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800532:	eb e9                	jmp    80051d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 40 04             	lea    0x4(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800548:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054c:	79 91                	jns    8004df <vprintfmt+0x54>
				width = precision, precision = -1;
  80054e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800551:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800554:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80055b:	eb 82                	jmp    8004df <vprintfmt+0x54>
  80055d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800560:	85 d2                	test   %edx,%edx
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	0f 49 c2             	cmovns %edx,%eax
  80056a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800570:	e9 6a ff ff ff       	jmp    8004df <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800578:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80057f:	e9 5b ff ff ff       	jmp    8004df <vprintfmt+0x54>
  800584:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800587:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058a:	eb bc                	jmp    800548 <vprintfmt+0xbd>
			lflag++;
  80058c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800592:	e9 48 ff ff ff       	jmp    8004df <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 78 04             	lea    0x4(%eax),%edi
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	ff 30                	push   (%eax)
  8005a3:	ff d6                	call   *%esi
			break;
  8005a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005a8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ab:	e9 9d 02 00 00       	jmp    80084d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 78 04             	lea    0x4(%eax),%edi
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	89 d0                	mov    %edx,%eax
  8005ba:	f7 d8                	neg    %eax
  8005bc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005bf:	83 f8 0f             	cmp    $0xf,%eax
  8005c2:	7f 23                	jg     8005e7 <vprintfmt+0x15c>
  8005c4:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	74 18                	je     8005e7 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8005cf:	52                   	push   %edx
  8005d0:	68 65 29 80 00       	push   $0x802965
  8005d5:	53                   	push   %ebx
  8005d6:	56                   	push   %esi
  8005d7:	e8 92 fe ff ff       	call   80046e <printfmt>
  8005dc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005df:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005e2:	e9 66 02 00 00       	jmp    80084d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8005e7:	50                   	push   %eax
  8005e8:	68 9b 25 80 00       	push   $0x80259b
  8005ed:	53                   	push   %ebx
  8005ee:	56                   	push   %esi
  8005ef:	e8 7a fe ff ff       	call   80046e <printfmt>
  8005f4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005f7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005fa:	e9 4e 02 00 00       	jmp    80084d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	83 c0 04             	add    $0x4,%eax
  800605:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80060d:	85 d2                	test   %edx,%edx
  80060f:	b8 94 25 80 00       	mov    $0x802594,%eax
  800614:	0f 45 c2             	cmovne %edx,%eax
  800617:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80061a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061e:	7e 06                	jle    800626 <vprintfmt+0x19b>
  800620:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800624:	75 0d                	jne    800633 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800626:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800629:	89 c7                	mov    %eax,%edi
  80062b:	03 45 e0             	add    -0x20(%ebp),%eax
  80062e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800631:	eb 55                	jmp    800688 <vprintfmt+0x1fd>
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	ff 75 d8             	push   -0x28(%ebp)
  800639:	ff 75 cc             	push   -0x34(%ebp)
  80063c:	e8 fa 03 00 00       	call   800a3b <strnlen>
  800641:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800644:	29 c1                	sub    %eax,%ecx
  800646:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80064e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800652:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800655:	eb 0f                	jmp    800666 <vprintfmt+0x1db>
					putch(padc, putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	ff 75 e0             	push   -0x20(%ebp)
  80065e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800660:	83 ef 01             	sub    $0x1,%edi
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	85 ff                	test   %edi,%edi
  800668:	7f ed                	jg     800657 <vprintfmt+0x1cc>
  80066a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80066d:	85 d2                	test   %edx,%edx
  80066f:	b8 00 00 00 00       	mov    $0x0,%eax
  800674:	0f 49 c2             	cmovns %edx,%eax
  800677:	29 c2                	sub    %eax,%edx
  800679:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80067c:	eb a8                	jmp    800626 <vprintfmt+0x19b>
					putch(ch, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	52                   	push   %edx
  800683:	ff d6                	call   *%esi
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068d:	83 c7 01             	add    $0x1,%edi
  800690:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800694:	0f be d0             	movsbl %al,%edx
  800697:	85 d2                	test   %edx,%edx
  800699:	74 4b                	je     8006e6 <vprintfmt+0x25b>
  80069b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069f:	78 06                	js     8006a7 <vprintfmt+0x21c>
  8006a1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006a5:	78 1e                	js     8006c5 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ab:	74 d1                	je     80067e <vprintfmt+0x1f3>
  8006ad:	0f be c0             	movsbl %al,%eax
  8006b0:	83 e8 20             	sub    $0x20,%eax
  8006b3:	83 f8 5e             	cmp    $0x5e,%eax
  8006b6:	76 c6                	jbe    80067e <vprintfmt+0x1f3>
					putch('?', putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	6a 3f                	push   $0x3f
  8006be:	ff d6                	call   *%esi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb c3                	jmp    800688 <vprintfmt+0x1fd>
  8006c5:	89 cf                	mov    %ecx,%edi
  8006c7:	eb 0e                	jmp    8006d7 <vprintfmt+0x24c>
				putch(' ', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 20                	push   $0x20
  8006cf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	85 ff                	test   %edi,%edi
  8006d9:	7f ee                	jg     8006c9 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8006db:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e1:	e9 67 01 00 00       	jmp    80084d <vprintfmt+0x3c2>
  8006e6:	89 cf                	mov    %ecx,%edi
  8006e8:	eb ed                	jmp    8006d7 <vprintfmt+0x24c>
	if (lflag >= 2)
  8006ea:	83 f9 01             	cmp    $0x1,%ecx
  8006ed:	7f 1b                	jg     80070a <vprintfmt+0x27f>
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	74 63                	je     800756 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fb:	99                   	cltd   
  8006fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
  800708:	eb 17                	jmp    800721 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 50 04             	mov    0x4(%eax),%edx
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800715:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800721:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800724:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800727:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80072c:	85 c9                	test   %ecx,%ecx
  80072e:	0f 89 ff 00 00 00    	jns    800833 <vprintfmt+0x3a8>
				putch('-', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 2d                	push   $0x2d
  80073a:	ff d6                	call   *%esi
				num = -(long long) num;
  80073c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80073f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800742:	f7 da                	neg    %edx
  800744:	83 d1 00             	adc    $0x0,%ecx
  800747:	f7 d9                	neg    %ecx
  800749:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80074c:	bf 0a 00 00 00       	mov    $0xa,%edi
  800751:	e9 dd 00 00 00       	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 00                	mov    (%eax),%eax
  80075b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075e:	99                   	cltd   
  80075f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8d 40 04             	lea    0x4(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
  80076b:	eb b4                	jmp    800721 <vprintfmt+0x296>
	if (lflag >= 2)
  80076d:	83 f9 01             	cmp    $0x1,%ecx
  800770:	7f 1e                	jg     800790 <vprintfmt+0x305>
	else if (lflag)
  800772:	85 c9                	test   %ecx,%ecx
  800774:	74 32                	je     8007a8 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8b 10                	mov    (%eax),%edx
  80077b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800780:	8d 40 04             	lea    0x4(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800786:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80078b:	e9 a3 00 00 00       	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8b 10                	mov    (%eax),%edx
  800795:	8b 48 04             	mov    0x4(%eax),%ecx
  800798:	8d 40 08             	lea    0x8(%eax),%eax
  80079b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80079e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007a3:	e9 8b 00 00 00       	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 10                	mov    (%eax),%edx
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007b8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8007bd:	eb 74                	jmp    800833 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8007bf:	83 f9 01             	cmp    $0x1,%ecx
  8007c2:	7f 1b                	jg     8007df <vprintfmt+0x354>
	else if (lflag)
  8007c4:	85 c9                	test   %ecx,%ecx
  8007c6:	74 2c                	je     8007f4 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007d8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8007dd:	eb 54                	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007ed:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8007f2:	eb 3f                	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fe:	8d 40 04             	lea    0x4(%eax),%eax
  800801:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800804:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800809:	eb 28                	jmp    800833 <vprintfmt+0x3a8>
			putch('0', putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	6a 30                	push   $0x30
  800811:	ff d6                	call   *%esi
			putch('x', putdat);
  800813:	83 c4 08             	add    $0x8,%esp
  800816:	53                   	push   %ebx
  800817:	6a 78                	push   $0x78
  800819:	ff d6                	call   *%esi
			num = (unsigned long long)
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800825:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800828:	8d 40 04             	lea    0x4(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800833:	83 ec 0c             	sub    $0xc,%esp
  800836:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	ff 75 e0             	push   -0x20(%ebp)
  80083e:	57                   	push   %edi
  80083f:	51                   	push   %ecx
  800840:	52                   	push   %edx
  800841:	89 da                	mov    %ebx,%edx
  800843:	89 f0                	mov    %esi,%eax
  800845:	e8 5e fb ff ff       	call   8003a8 <printnum>
			break;
  80084a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80084d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800850:	e9 54 fc ff ff       	jmp    8004a9 <vprintfmt+0x1e>
	if (lflag >= 2)
  800855:	83 f9 01             	cmp    $0x1,%ecx
  800858:	7f 1b                	jg     800875 <vprintfmt+0x3ea>
	else if (lflag)
  80085a:	85 c9                	test   %ecx,%ecx
  80085c:	74 2c                	je     80088a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8b 10                	mov    (%eax),%edx
  800863:	b9 00 00 00 00       	mov    $0x0,%ecx
  800868:	8d 40 04             	lea    0x4(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80086e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800873:	eb be                	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8b 10                	mov    (%eax),%edx
  80087a:	8b 48 04             	mov    0x4(%eax),%ecx
  80087d:	8d 40 08             	lea    0x8(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800883:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800888:	eb a9                	jmp    800833 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800894:	8d 40 04             	lea    0x4(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80089f:	eb 92                	jmp    800833 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 25                	push   $0x25
  8008a7:	ff d6                	call   *%esi
			break;
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	eb 9f                	jmp    80084d <vprintfmt+0x3c2>
			putch('%', putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	6a 25                	push   $0x25
  8008b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	89 f8                	mov    %edi,%eax
  8008bb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008bf:	74 05                	je     8008c6 <vprintfmt+0x43b>
  8008c1:	83 e8 01             	sub    $0x1,%eax
  8008c4:	eb f5                	jmp    8008bb <vprintfmt+0x430>
  8008c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008c9:	eb 82                	jmp    80084d <vprintfmt+0x3c2>

008008cb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	83 ec 18             	sub    $0x18,%esp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	74 26                	je     800912 <vsnprintf+0x47>
  8008ec:	85 d2                	test   %edx,%edx
  8008ee:	7e 22                	jle    800912 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f0:	ff 75 14             	push   0x14(%ebp)
  8008f3:	ff 75 10             	push   0x10(%ebp)
  8008f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	68 51 04 80 00       	push   $0x800451
  8008ff:	e8 87 fb ff ff       	call   80048b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800904:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800907:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090d:	83 c4 10             	add    $0x10,%esp
}
  800910:	c9                   	leave  
  800911:	c3                   	ret    
		return -E_INVAL;
  800912:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800917:	eb f7                	jmp    800910 <vsnprintf+0x45>

00800919 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800922:	50                   	push   %eax
  800923:	ff 75 10             	push   0x10(%ebp)
  800926:	ff 75 0c             	push   0xc(%ebp)
  800929:	ff 75 08             	push   0x8(%ebp)
  80092c:	e8 9a ff ff ff       	call   8008cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	83 ec 0c             	sub    $0xc,%esp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80093f:	85 c0                	test   %eax,%eax
  800941:	74 13                	je     800956 <readline+0x23>
		fprintf(1, "%s", prompt);
  800943:	83 ec 04             	sub    $0x4,%esp
  800946:	50                   	push   %eax
  800947:	68 65 29 80 00       	push   $0x802965
  80094c:	6a 01                	push   $0x1
  80094e:	e8 27 10 00 00       	call   80197a <fprintf>
  800953:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800956:	83 ec 0c             	sub    $0xc,%esp
  800959:	6a 00                	push   $0x0
  80095b:	e8 7b f8 ff ff       	call   8001db <iscons>
  800960:	89 c7                	mov    %eax,%edi
  800962:	83 c4 10             	add    $0x10,%esp
	i = 0;
  800965:	be 00 00 00 00       	mov    $0x0,%esi
  80096a:	eb 4b                	jmp    8009b7 <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  800971:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800974:	75 08                	jne    80097e <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800976:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    
				cprintf("read error: %e\n", c);
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	53                   	push   %ebx
  800982:	68 7f 28 80 00       	push   $0x80287f
  800987:	e8 08 fa ff ff       	call   800394 <cprintf>
  80098c:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
  800994:	eb e0                	jmp    800976 <readline+0x43>
			if (echoing)
  800996:	85 ff                	test   %edi,%edi
  800998:	75 05                	jne    80099f <readline+0x6c>
			i--;
  80099a:	83 ee 01             	sub    $0x1,%esi
  80099d:	eb 18                	jmp    8009b7 <readline+0x84>
				cputchar('\b');
  80099f:	83 ec 0c             	sub    $0xc,%esp
  8009a2:	6a 08                	push   $0x8
  8009a4:	e8 ed f7 ff ff       	call   800196 <cputchar>
  8009a9:	83 c4 10             	add    $0x10,%esp
  8009ac:	eb ec                	jmp    80099a <readline+0x67>
			buf[i++] = c;
  8009ae:	88 9e 20 40 80 00    	mov    %bl,0x804020(%esi)
  8009b4:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  8009b7:	e8 f6 f7 ff ff       	call   8001b2 <getchar>
  8009bc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 aa                	js     80096c <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009c2:	83 f8 08             	cmp    $0x8,%eax
  8009c5:	0f 94 c0             	sete   %al
  8009c8:	83 fb 7f             	cmp    $0x7f,%ebx
  8009cb:	0f 94 c2             	sete   %dl
  8009ce:	08 d0                	or     %dl,%al
  8009d0:	74 04                	je     8009d6 <readline+0xa3>
  8009d2:	85 f6                	test   %esi,%esi
  8009d4:	7f c0                	jg     800996 <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009d6:	83 fb 1f             	cmp    $0x1f,%ebx
  8009d9:	7e 1a                	jle    8009f5 <readline+0xc2>
  8009db:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009e1:	7f 12                	jg     8009f5 <readline+0xc2>
			if (echoing)
  8009e3:	85 ff                	test   %edi,%edi
  8009e5:	74 c7                	je     8009ae <readline+0x7b>
				cputchar(c);
  8009e7:	83 ec 0c             	sub    $0xc,%esp
  8009ea:	53                   	push   %ebx
  8009eb:	e8 a6 f7 ff ff       	call   800196 <cputchar>
  8009f0:	83 c4 10             	add    $0x10,%esp
  8009f3:	eb b9                	jmp    8009ae <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  8009f5:	83 fb 0a             	cmp    $0xa,%ebx
  8009f8:	74 05                	je     8009ff <readline+0xcc>
  8009fa:	83 fb 0d             	cmp    $0xd,%ebx
  8009fd:	75 b8                	jne    8009b7 <readline+0x84>
			if (echoing)
  8009ff:	85 ff                	test   %edi,%edi
  800a01:	75 11                	jne    800a14 <readline+0xe1>
			buf[i] = 0;
  800a03:	c6 86 20 40 80 00 00 	movb   $0x0,0x804020(%esi)
			return buf;
  800a0a:	b8 20 40 80 00       	mov    $0x804020,%eax
  800a0f:	e9 62 ff ff ff       	jmp    800976 <readline+0x43>
				cputchar('\n');
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	6a 0a                	push   $0xa
  800a19:	e8 78 f7 ff ff       	call   800196 <cputchar>
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	eb e0                	jmp    800a03 <readline+0xd0>

00800a23 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	eb 03                	jmp    800a33 <strlen+0x10>
		n++;
  800a30:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a37:	75 f7                	jne    800a30 <strlen+0xd>
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	eb 03                	jmp    800a4e <strnlen+0x13>
		n++;
  800a4b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	74 08                	je     800a5a <strnlen+0x1f>
  800a52:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a56:	75 f3                	jne    800a4b <strnlen+0x10>
  800a58:	89 c2                	mov    %eax,%edx
	return n;
}
  800a5a:	89 d0                	mov    %edx,%eax
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	53                   	push   %ebx
  800a62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a71:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	84 d2                	test   %dl,%dl
  800a79:	75 f2                	jne    800a6d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a7b:	89 c8                	mov    %ecx,%eax
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	83 ec 10             	sub    $0x10,%esp
  800a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8c:	53                   	push   %ebx
  800a8d:	e8 91 ff ff ff       	call   800a23 <strlen>
  800a92:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a95:	ff 75 0c             	push   0xc(%ebp)
  800a98:	01 d8                	add    %ebx,%eax
  800a9a:	50                   	push   %eax
  800a9b:	e8 be ff ff ff       	call   800a5e <strcpy>
	return dst;
}
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab7:	89 f0                	mov    %esi,%eax
  800ab9:	eb 0f                	jmp    800aca <strncpy+0x23>
		*dst++ = *src;
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	0f b6 0a             	movzbl (%edx),%ecx
  800ac1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac4:	80 f9 01             	cmp    $0x1,%cl
  800ac7:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800aca:	39 d8                	cmp    %ebx,%eax
  800acc:	75 ed                	jne    800abb <strncpy+0x14>
	}
	return ret;
}
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adf:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae4:	85 d2                	test   %edx,%edx
  800ae6:	74 21                	je     800b09 <strlcpy+0x35>
  800ae8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aec:	89 f2                	mov    %esi,%edx
  800aee:	eb 09                	jmp    800af9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800af0:	83 c1 01             	add    $0x1,%ecx
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800af9:	39 c2                	cmp    %eax,%edx
  800afb:	74 09                	je     800b06 <strlcpy+0x32>
  800afd:	0f b6 19             	movzbl (%ecx),%ebx
  800b00:	84 db                	test   %bl,%bl
  800b02:	75 ec                	jne    800af0 <strlcpy+0x1c>
  800b04:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b06:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b09:	29 f0                	sub    %esi,%eax
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b18:	eb 06                	jmp    800b20 <strcmp+0x11>
		p++, q++;
  800b1a:	83 c1 01             	add    $0x1,%ecx
  800b1d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b20:	0f b6 01             	movzbl (%ecx),%eax
  800b23:	84 c0                	test   %al,%al
  800b25:	74 04                	je     800b2b <strcmp+0x1c>
  800b27:	3a 02                	cmp    (%edx),%al
  800b29:	74 ef                	je     800b1a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2b:	0f b6 c0             	movzbl %al,%eax
  800b2e:	0f b6 12             	movzbl (%edx),%edx
  800b31:	29 d0                	sub    %edx,%eax
}
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	53                   	push   %ebx
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 c3                	mov    %eax,%ebx
  800b41:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b44:	eb 06                	jmp    800b4c <strncmp+0x17>
		n--, p++, q++;
  800b46:	83 c0 01             	add    $0x1,%eax
  800b49:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b4c:	39 d8                	cmp    %ebx,%eax
  800b4e:	74 18                	je     800b68 <strncmp+0x33>
  800b50:	0f b6 08             	movzbl (%eax),%ecx
  800b53:	84 c9                	test   %cl,%cl
  800b55:	74 04                	je     800b5b <strncmp+0x26>
  800b57:	3a 0a                	cmp    (%edx),%cl
  800b59:	74 eb                	je     800b46 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5b:	0f b6 00             	movzbl (%eax),%eax
  800b5e:	0f b6 12             	movzbl (%edx),%edx
  800b61:	29 d0                	sub    %edx,%eax
}
  800b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    
		return 0;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	eb f4                	jmp    800b63 <strncmp+0x2e>

00800b6f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b79:	eb 03                	jmp    800b7e <strchr+0xf>
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	0f b6 10             	movzbl (%eax),%edx
  800b81:	84 d2                	test   %dl,%dl
  800b83:	74 06                	je     800b8b <strchr+0x1c>
		if (*s == c)
  800b85:	38 ca                	cmp    %cl,%dl
  800b87:	75 f2                	jne    800b7b <strchr+0xc>
  800b89:	eb 05                	jmp    800b90 <strchr+0x21>
			return (char *) s;
	return 0;
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b9f:	38 ca                	cmp    %cl,%dl
  800ba1:	74 09                	je     800bac <strfind+0x1a>
  800ba3:	84 d2                	test   %dl,%dl
  800ba5:	74 05                	je     800bac <strfind+0x1a>
	for (; *s; s++)
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	eb f0                	jmp    800b9c <strfind+0xa>
			break;
	return (char *) s;
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bba:	85 c9                	test   %ecx,%ecx
  800bbc:	74 2f                	je     800bed <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbe:	89 f8                	mov    %edi,%eax
  800bc0:	09 c8                	or     %ecx,%eax
  800bc2:	a8 03                	test   $0x3,%al
  800bc4:	75 21                	jne    800be7 <memset+0x39>
		c &= 0xFF;
  800bc6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bca:	89 d0                	mov    %edx,%eax
  800bcc:	c1 e0 08             	shl    $0x8,%eax
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	c1 e3 18             	shl    $0x18,%ebx
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	c1 e6 10             	shl    $0x10,%esi
  800bd9:	09 f3                	or     %esi,%ebx
  800bdb:	09 da                	or     %ebx,%edx
  800bdd:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bdf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800be2:	fc                   	cld    
  800be3:	f3 ab                	rep stos %eax,%es:(%edi)
  800be5:	eb 06                	jmp    800bed <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bea:	fc                   	cld    
  800beb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c02:	39 c6                	cmp    %eax,%esi
  800c04:	73 32                	jae    800c38 <memmove+0x44>
  800c06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c09:	39 c2                	cmp    %eax,%edx
  800c0b:	76 2b                	jbe    800c38 <memmove+0x44>
		s += n;
		d += n;
  800c0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	09 fe                	or     %edi,%esi
  800c14:	09 ce                	or     %ecx,%esi
  800c16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1c:	75 0e                	jne    800c2c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1e:	83 ef 04             	sub    $0x4,%edi
  800c21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c27:	fd                   	std    
  800c28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2a:	eb 09                	jmp    800c35 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2c:	83 ef 01             	sub    $0x1,%edi
  800c2f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c32:	fd                   	std    
  800c33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c35:	fc                   	cld    
  800c36:	eb 1a                	jmp    800c52 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c38:	89 f2                	mov    %esi,%edx
  800c3a:	09 c2                	or     %eax,%edx
  800c3c:	09 ca                	or     %ecx,%edx
  800c3e:	f6 c2 03             	test   $0x3,%dl
  800c41:	75 0a                	jne    800c4d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c43:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	fc                   	cld    
  800c49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4b:	eb 05                	jmp    800c52 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800c4d:	89 c7                	mov    %eax,%edi
  800c4f:	fc                   	cld    
  800c50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5c:	ff 75 10             	push   0x10(%ebp)
  800c5f:	ff 75 0c             	push   0xc(%ebp)
  800c62:	ff 75 08             	push   0x8(%ebp)
  800c65:	e8 8a ff ff ff       	call   800bf4 <memmove>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c77:	89 c6                	mov    %eax,%esi
  800c79:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7c:	eb 06                	jmp    800c84 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c7e:	83 c0 01             	add    $0x1,%eax
  800c81:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c84:	39 f0                	cmp    %esi,%eax
  800c86:	74 14                	je     800c9c <memcmp+0x30>
		if (*s1 != *s2)
  800c88:	0f b6 08             	movzbl (%eax),%ecx
  800c8b:	0f b6 1a             	movzbl (%edx),%ebx
  800c8e:	38 d9                	cmp    %bl,%cl
  800c90:	74 ec                	je     800c7e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c92:	0f b6 c1             	movzbl %cl,%eax
  800c95:	0f b6 db             	movzbl %bl,%ebx
  800c98:	29 d8                	sub    %ebx,%eax
  800c9a:	eb 05                	jmp    800ca1 <memcmp+0x35>
	}

	return 0;
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb3:	eb 03                	jmp    800cb8 <memfind+0x13>
  800cb5:	83 c0 01             	add    $0x1,%eax
  800cb8:	39 d0                	cmp    %edx,%eax
  800cba:	73 04                	jae    800cc0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cbc:	38 08                	cmp    %cl,(%eax)
  800cbe:	75 f5                	jne    800cb5 <memfind+0x10>
			break;
	return (void *) s;
}
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cce:	eb 03                	jmp    800cd3 <strtol+0x11>
		s++;
  800cd0:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800cd3:	0f b6 02             	movzbl (%edx),%eax
  800cd6:	3c 20                	cmp    $0x20,%al
  800cd8:	74 f6                	je     800cd0 <strtol+0xe>
  800cda:	3c 09                	cmp    $0x9,%al
  800cdc:	74 f2                	je     800cd0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cde:	3c 2b                	cmp    $0x2b,%al
  800ce0:	74 2a                	je     800d0c <strtol+0x4a>
	int neg = 0;
  800ce2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ce7:	3c 2d                	cmp    $0x2d,%al
  800ce9:	74 2b                	je     800d16 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ceb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf1:	75 0f                	jne    800d02 <strtol+0x40>
  800cf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf6:	74 28                	je     800d20 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf8:	85 db                	test   %ebx,%ebx
  800cfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cff:	0f 44 d8             	cmove  %eax,%ebx
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d0a:	eb 46                	jmp    800d52 <strtol+0x90>
		s++;
  800d0c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d14:	eb d5                	jmp    800ceb <strtol+0x29>
		s++, neg = 1;
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	bf 01 00 00 00       	mov    $0x1,%edi
  800d1e:	eb cb                	jmp    800ceb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d20:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d24:	74 0e                	je     800d34 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800d26:	85 db                	test   %ebx,%ebx
  800d28:	75 d8                	jne    800d02 <strtol+0x40>
		s++, base = 8;
  800d2a:	83 c2 01             	add    $0x1,%edx
  800d2d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d32:	eb ce                	jmp    800d02 <strtol+0x40>
		s += 2, base = 16;
  800d34:	83 c2 02             	add    $0x2,%edx
  800d37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3c:	eb c4                	jmp    800d02 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d3e:	0f be c0             	movsbl %al,%eax
  800d41:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d44:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d47:	7d 3a                	jge    800d83 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d49:	83 c2 01             	add    $0x1,%edx
  800d4c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800d50:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800d52:	0f b6 02             	movzbl (%edx),%eax
  800d55:	8d 70 d0             	lea    -0x30(%eax),%esi
  800d58:	89 f3                	mov    %esi,%ebx
  800d5a:	80 fb 09             	cmp    $0x9,%bl
  800d5d:	76 df                	jbe    800d3e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800d5f:	8d 70 9f             	lea    -0x61(%eax),%esi
  800d62:	89 f3                	mov    %esi,%ebx
  800d64:	80 fb 19             	cmp    $0x19,%bl
  800d67:	77 08                	ja     800d71 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800d69:	0f be c0             	movsbl %al,%eax
  800d6c:	83 e8 57             	sub    $0x57,%eax
  800d6f:	eb d3                	jmp    800d44 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800d71:	8d 70 bf             	lea    -0x41(%eax),%esi
  800d74:	89 f3                	mov    %esi,%ebx
  800d76:	80 fb 19             	cmp    $0x19,%bl
  800d79:	77 08                	ja     800d83 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d7b:	0f be c0             	movsbl %al,%eax
  800d7e:	83 e8 37             	sub    $0x37,%eax
  800d81:	eb c1                	jmp    800d44 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d87:	74 05                	je     800d8e <strtol+0xcc>
		*endptr = (char *) s;
  800d89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d8e:	89 c8                	mov    %ecx,%eax
  800d90:	f7 d8                	neg    %eax
  800d92:	85 ff                	test   %edi,%edi
  800d94:	0f 45 c8             	cmovne %eax,%ecx
}
  800d97:	89 c8                	mov    %ecx,%eax
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	89 c7                	mov    %eax,%edi
  800db3:	89 c6                	mov    %eax,%esi
  800db5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_cgetc>:

int
sys_cgetc(void)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcc:	89 d1                	mov    %edx,%ecx
  800dce:	89 d3                	mov    %edx,%ebx
  800dd0:	89 d7                	mov    %edx,%edi
  800dd2:	89 d6                	mov    %edx,%esi
  800dd4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	b8 03 00 00 00       	mov    $0x3,%eax
  800df1:	89 cb                	mov    %ecx,%ebx
  800df3:	89 cf                	mov    %ecx,%edi
  800df5:	89 ce                	mov    %ecx,%esi
  800df7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7f 08                	jg     800e05 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 03                	push   $0x3
  800e0b:	68 8f 28 80 00       	push   $0x80288f
  800e10:	6a 2a                	push   $0x2a
  800e12:	68 ac 28 80 00       	push   $0x8028ac
  800e17:	e8 9d f4 ff ff       	call   8002b9 <_panic>

00800e1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	b8 02 00 00 00       	mov    $0x2,%eax
  800e2c:	89 d1                	mov    %edx,%ecx
  800e2e:	89 d3                	mov    %edx,%ebx
  800e30:	89 d7                	mov    %edx,%edi
  800e32:	89 d6                	mov    %edx,%esi
  800e34:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_yield>:

void
sys_yield(void)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e4b:	89 d1                	mov    %edx,%ecx
  800e4d:	89 d3                	mov    %edx,%ebx
  800e4f:	89 d7                	mov    %edx,%edi
  800e51:	89 d6                	mov    %edx,%esi
  800e53:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e63:	be 00 00 00 00       	mov    $0x0,%esi
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	89 f7                	mov    %esi,%edi
  800e78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7f 08                	jg     800e86 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	50                   	push   %eax
  800e8a:	6a 04                	push   $0x4
  800e8c:	68 8f 28 80 00       	push   $0x80288f
  800e91:	6a 2a                	push   $0x2a
  800e93:	68 ac 28 80 00       	push   $0x8028ac
  800e98:	e8 1c f4 ff ff       	call   8002b9 <_panic>

00800e9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	7f 08                	jg     800ec8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 05                	push   $0x5
  800ece:	68 8f 28 80 00       	push   $0x80288f
  800ed3:	6a 2a                	push   $0x2a
  800ed5:	68 ac 28 80 00       	push   $0x8028ac
  800eda:	e8 da f3 ff ff       	call   8002b9 <_panic>

00800edf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ee8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	89 df                	mov    %ebx,%edi
  800efa:	89 de                	mov    %ebx,%esi
  800efc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800efe:	85 c0                	test   %eax,%eax
  800f00:	7f 08                	jg     800f0a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	50                   	push   %eax
  800f0e:	6a 06                	push   $0x6
  800f10:	68 8f 28 80 00       	push   $0x80288f
  800f15:	6a 2a                	push   $0x2a
  800f17:	68 ac 28 80 00       	push   $0x8028ac
  800f1c:	e8 98 f3 ff ff       	call   8002b9 <_panic>

00800f21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	89 df                	mov    %ebx,%edi
  800f3c:	89 de                	mov    %ebx,%esi
  800f3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f40:	85 c0                	test   %eax,%eax
  800f42:	7f 08                	jg     800f4c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	50                   	push   %eax
  800f50:	6a 08                	push   $0x8
  800f52:	68 8f 28 80 00       	push   $0x80288f
  800f57:	6a 2a                	push   $0x2a
  800f59:	68 ac 28 80 00       	push   $0x8028ac
  800f5e:	e8 56 f3 ff ff       	call   8002b9 <_panic>

00800f63 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f77:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7c:	89 df                	mov    %ebx,%edi
  800f7e:	89 de                	mov    %ebx,%esi
  800f80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7f 08                	jg     800f8e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 09                	push   $0x9
  800f94:	68 8f 28 80 00       	push   $0x80288f
  800f99:	6a 2a                	push   $0x2a
  800f9b:	68 ac 28 80 00       	push   $0x8028ac
  800fa0:	e8 14 f3 ff ff       	call   8002b9 <_panic>

00800fa5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
  800fab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbe:	89 df                	mov    %ebx,%edi
  800fc0:	89 de                	mov    %ebx,%esi
  800fc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	7f 08                	jg     800fd0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd0:	83 ec 0c             	sub    $0xc,%esp
  800fd3:	50                   	push   %eax
  800fd4:	6a 0a                	push   $0xa
  800fd6:	68 8f 28 80 00       	push   $0x80288f
  800fdb:	6a 2a                	push   $0x2a
  800fdd:	68 ac 28 80 00       	push   $0x8028ac
  800fe2:	e8 d2 f2 ff ff       	call   8002b9 <_panic>

00800fe7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff8:	be 00 00 00 00       	mov    $0x0,%esi
  800ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801000:	8b 7d 14             	mov    0x14(%ebp),%edi
  801003:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	57                   	push   %edi
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801013:	b9 00 00 00 00       	mov    $0x0,%ecx
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801020:	89 cb                	mov    %ecx,%ebx
  801022:	89 cf                	mov    %ecx,%edi
  801024:	89 ce                	mov    %ecx,%esi
  801026:	cd 30                	int    $0x30
	if(check && ret > 0)
  801028:	85 c0                	test   %eax,%eax
  80102a:	7f 08                	jg     801034 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	50                   	push   %eax
  801038:	6a 0d                	push   $0xd
  80103a:	68 8f 28 80 00       	push   $0x80288f
  80103f:	6a 2a                	push   $0x2a
  801041:	68 ac 28 80 00       	push   $0x8028ac
  801046:	e8 6e f2 ff ff       	call   8002b9 <_panic>

0080104b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	asm volatile("int %1\n"
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	b8 0e 00 00 00       	mov    $0xe,%eax
  80105b:	89 d1                	mov    %edx,%ecx
  80105d:	89 d3                	mov    %edx,%ebx
  80105f:	89 d7                	mov    %edx,%edi
  801061:	89 d6                	mov    %edx,%esi
  801063:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801070:	bb 00 00 00 00       	mov    $0x0,%ebx
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801080:	89 df                	mov    %ebx,%edi
  801082:	89 de                	mov    %ebx,%esi
  801084:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
	asm volatile("int %1\n"
  801091:	bb 00 00 00 00       	mov    $0x0,%ebx
  801096:	8b 55 08             	mov    0x8(%ebp),%edx
  801099:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109c:	b8 10 00 00 00       	mov    $0x10,%eax
  8010a1:	89 df                	mov    %ebx,%edi
  8010a3:	89 de                	mov    %ebx,%esi
  8010a5:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 16             	shr    $0x16,%edx
  8010e0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	74 29                	je     801115 <fd_alloc+0x42>
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	c1 ea 0c             	shr    $0xc,%edx
  8010f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f8:	f6 c2 01             	test   $0x1,%dl
  8010fb:	74 18                	je     801115 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010fd:	05 00 10 00 00       	add    $0x1000,%eax
  801102:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801107:	75 d2                	jne    8010db <fd_alloc+0x8>
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80110e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801113:	eb 05                	jmp    80111a <fd_alloc+0x47>
			return 0;
  801115:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80111a:	8b 55 08             	mov    0x8(%ebp),%edx
  80111d:	89 02                	mov    %eax,(%edx)
}
  80111f:	89 c8                	mov    %ecx,%eax
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801129:	83 f8 1f             	cmp    $0x1f,%eax
  80112c:	77 30                	ja     80115e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80112e:	c1 e0 0c             	shl    $0xc,%eax
  801131:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801136:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80113c:	f6 c2 01             	test   $0x1,%dl
  80113f:	74 24                	je     801165 <fd_lookup+0x42>
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 ea 0c             	shr    $0xc,%edx
  801146:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114d:	f6 c2 01             	test   $0x1,%dl
  801150:	74 1a                	je     80116c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801152:	8b 55 0c             	mov    0xc(%ebp),%edx
  801155:	89 02                	mov    %eax,(%edx)
	return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
		return -E_INVAL;
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801163:	eb f7                	jmp    80115c <fd_lookup+0x39>
		return -E_INVAL;
  801165:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116a:	eb f0                	jmp    80115c <fd_lookup+0x39>
  80116c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801171:	eb e9                	jmp    80115c <fd_lookup+0x39>

00801173 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	53                   	push   %ebx
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
  801182:	bb 20 30 80 00       	mov    $0x803020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801187:	39 13                	cmp    %edx,(%ebx)
  801189:	74 37                	je     8011c2 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80118b:	83 c0 01             	add    $0x1,%eax
  80118e:	8b 1c 85 38 29 80 00 	mov    0x802938(,%eax,4),%ebx
  801195:	85 db                	test   %ebx,%ebx
  801197:	75 ee                	jne    801187 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801199:	a1 00 40 80 00       	mov    0x804000,%eax
  80119e:	8b 40 48             	mov    0x48(%eax),%eax
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	52                   	push   %edx
  8011a5:	50                   	push   %eax
  8011a6:	68 bc 28 80 00       	push   $0x8028bc
  8011ab:	e8 e4 f1 ff ff       	call   800394 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8011b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bb:	89 1a                	mov    %ebx,(%edx)
}
  8011bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    
			return 0;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c7:	eb ef                	jmp    8011b8 <dev_lookup+0x45>

008011c9 <fd_close>:
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	57                   	push   %edi
  8011cd:	56                   	push   %esi
  8011ce:	53                   	push   %ebx
  8011cf:	83 ec 24             	sub    $0x24,%esp
  8011d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011db:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011dc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e5:	50                   	push   %eax
  8011e6:	e8 38 ff ff ff       	call   801123 <fd_lookup>
  8011eb:	89 c3                	mov    %eax,%ebx
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 05                	js     8011f9 <fd_close+0x30>
	    || fd != fd2)
  8011f4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011f7:	74 16                	je     80120f <fd_close+0x46>
		return (must_exist ? r : 0);
  8011f9:	89 f8                	mov    %edi,%eax
  8011fb:	84 c0                	test   %al,%al
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	0f 44 d8             	cmove  %eax,%ebx
}
  801205:	89 d8                	mov    %ebx,%eax
  801207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120a:	5b                   	pop    %ebx
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 36                	push   (%esi)
  801218:	e8 56 ff ff ff       	call   801173 <dev_lookup>
  80121d:	89 c3                	mov    %eax,%ebx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 1a                	js     801240 <fd_close+0x77>
		if (dev->dev_close)
  801226:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801229:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80122c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801231:	85 c0                	test   %eax,%eax
  801233:	74 0b                	je     801240 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801235:	83 ec 0c             	sub    $0xc,%esp
  801238:	56                   	push   %esi
  801239:	ff d0                	call   *%eax
  80123b:	89 c3                	mov    %eax,%ebx
  80123d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	56                   	push   %esi
  801244:	6a 00                	push   $0x0
  801246:	e8 94 fc ff ff       	call   800edf <sys_page_unmap>
	return r;
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	eb b5                	jmp    801205 <fd_close+0x3c>

00801250 <close>:

int
close(int fdnum)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801256:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	ff 75 08             	push   0x8(%ebp)
  80125d:	e8 c1 fe ff ff       	call   801123 <fd_lookup>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	79 02                	jns    80126b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801269:	c9                   	leave  
  80126a:	c3                   	ret    
		return fd_close(fd, 1);
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	6a 01                	push   $0x1
  801270:	ff 75 f4             	push   -0xc(%ebp)
  801273:	e8 51 ff ff ff       	call   8011c9 <fd_close>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	eb ec                	jmp    801269 <close+0x19>

0080127d <close_all>:

void
close_all(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	53                   	push   %ebx
  801281:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801284:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801289:	83 ec 0c             	sub    $0xc,%esp
  80128c:	53                   	push   %ebx
  80128d:	e8 be ff ff ff       	call   801250 <close>
	for (i = 0; i < MAXFD; i++)
  801292:	83 c3 01             	add    $0x1,%ebx
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	83 fb 20             	cmp    $0x20,%ebx
  80129b:	75 ec                	jne    801289 <close_all+0xc>
}
  80129d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 75 08             	push   0x8(%ebp)
  8012b2:	e8 6c fe ff ff       	call   801123 <fd_lookup>
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 7f                	js     80133f <dup+0x9d>
		return r;
	close(newfdnum);
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	ff 75 0c             	push   0xc(%ebp)
  8012c6:	e8 85 ff ff ff       	call   801250 <close>

	newfd = INDEX2FD(newfdnum);
  8012cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ce:	c1 e6 0c             	shl    $0xc,%esi
  8012d1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012da:	89 3c 24             	mov    %edi,(%esp)
  8012dd:	e8 da fd ff ff       	call   8010bc <fd2data>
  8012e2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012e4:	89 34 24             	mov    %esi,(%esp)
  8012e7:	e8 d0 fd ff ff       	call   8010bc <fd2data>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f2:	89 d8                	mov    %ebx,%eax
  8012f4:	c1 e8 16             	shr    $0x16,%eax
  8012f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fe:	a8 01                	test   $0x1,%al
  801300:	74 11                	je     801313 <dup+0x71>
  801302:	89 d8                	mov    %ebx,%eax
  801304:	c1 e8 0c             	shr    $0xc,%eax
  801307:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130e:	f6 c2 01             	test   $0x1,%dl
  801311:	75 36                	jne    801349 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801313:	89 f8                	mov    %edi,%eax
  801315:	c1 e8 0c             	shr    $0xc,%eax
  801318:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	25 07 0e 00 00       	and    $0xe07,%eax
  801327:	50                   	push   %eax
  801328:	56                   	push   %esi
  801329:	6a 00                	push   $0x0
  80132b:	57                   	push   %edi
  80132c:	6a 00                	push   $0x0
  80132e:	e8 6a fb ff ff       	call   800e9d <sys_page_map>
  801333:	89 c3                	mov    %eax,%ebx
  801335:	83 c4 20             	add    $0x20,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 33                	js     80136f <dup+0xcd>
		goto err;

	return newfdnum;
  80133c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80133f:	89 d8                	mov    %ebx,%eax
  801341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801349:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	25 07 0e 00 00       	and    $0xe07,%eax
  801358:	50                   	push   %eax
  801359:	ff 75 d4             	push   -0x2c(%ebp)
  80135c:	6a 00                	push   $0x0
  80135e:	53                   	push   %ebx
  80135f:	6a 00                	push   $0x0
  801361:	e8 37 fb ff ff       	call   800e9d <sys_page_map>
  801366:	89 c3                	mov    %eax,%ebx
  801368:	83 c4 20             	add    $0x20,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	79 a4                	jns    801313 <dup+0x71>
	sys_page_unmap(0, newfd);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	56                   	push   %esi
  801373:	6a 00                	push   $0x0
  801375:	e8 65 fb ff ff       	call   800edf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	ff 75 d4             	push   -0x2c(%ebp)
  801380:	6a 00                	push   $0x0
  801382:	e8 58 fb ff ff       	call   800edf <sys_page_unmap>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	eb b3                	jmp    80133f <dup+0x9d>

0080138c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 18             	sub    $0x18,%esp
  801394:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801397:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	56                   	push   %esi
  80139c:	e8 82 fd ff ff       	call   801123 <fd_lookup>
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 3c                	js     8013e4 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 33                	push   (%ebx)
  8013b4:	e8 ba fd ff ff       	call   801173 <dev_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 24                	js     8013e4 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c0:	8b 43 08             	mov    0x8(%ebx),%eax
  8013c3:	83 e0 03             	and    $0x3,%eax
  8013c6:	83 f8 01             	cmp    $0x1,%eax
  8013c9:	74 20                	je     8013eb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ce:	8b 40 08             	mov    0x8(%eax),%eax
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	74 37                	je     80140c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	ff 75 10             	push   0x10(%ebp)
  8013db:	ff 75 0c             	push   0xc(%ebp)
  8013de:	53                   	push   %ebx
  8013df:	ff d0                	call   *%eax
  8013e1:	83 c4 10             	add    $0x10,%esp
}
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013eb:	a1 00 40 80 00       	mov    0x804000,%eax
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	56                   	push   %esi
  8013f7:	50                   	push   %eax
  8013f8:	68 fd 28 80 00       	push   $0x8028fd
  8013fd:	e8 92 ef ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140a:	eb d8                	jmp    8013e4 <read+0x58>
		return -E_NOT_SUPP;
  80140c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801411:	eb d1                	jmp    8013e4 <read+0x58>

00801413 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801422:	bb 00 00 00 00       	mov    $0x0,%ebx
  801427:	eb 02                	jmp    80142b <readn+0x18>
  801429:	01 c3                	add    %eax,%ebx
  80142b:	39 f3                	cmp    %esi,%ebx
  80142d:	73 21                	jae    801450 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80142f:	83 ec 04             	sub    $0x4,%esp
  801432:	89 f0                	mov    %esi,%eax
  801434:	29 d8                	sub    %ebx,%eax
  801436:	50                   	push   %eax
  801437:	89 d8                	mov    %ebx,%eax
  801439:	03 45 0c             	add    0xc(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	57                   	push   %edi
  80143e:	e8 49 ff ff ff       	call   80138c <read>
		if (m < 0)
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 04                	js     80144e <readn+0x3b>
			return m;
		if (m == 0)
  80144a:	75 dd                	jne    801429 <readn+0x16>
  80144c:	eb 02                	jmp    801450 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80144e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	83 ec 18             	sub    $0x18,%esp
  801462:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801465:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	53                   	push   %ebx
  80146a:	e8 b4 fc ff ff       	call   801123 <fd_lookup>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 37                	js     8014ad <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	ff 36                	push   (%esi)
  801482:	e8 ec fc ff ff       	call   801173 <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 1f                	js     8014ad <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801492:	74 20                	je     8014b4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801497:	8b 40 0c             	mov    0xc(%eax),%eax
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 37                	je     8014d5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	ff 75 10             	push   0x10(%ebp)
  8014a4:	ff 75 0c             	push   0xc(%ebp)
  8014a7:	56                   	push   %esi
  8014a8:	ff d0                	call   *%eax
  8014aa:	83 c4 10             	add    $0x10,%esp
}
  8014ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b4:	a1 00 40 80 00       	mov    0x804000,%eax
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	50                   	push   %eax
  8014c1:	68 19 29 80 00       	push   $0x802919
  8014c6:	e8 c9 ee ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb d8                	jmp    8014ad <write+0x53>
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014da:	eb d1                	jmp    8014ad <write+0x53>

008014dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	ff 75 08             	push   0x8(%ebp)
  8014e9:	e8 35 fc ff ff       	call   801123 <fd_lookup>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 0e                	js     801503 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	56                   	push   %esi
  801509:	53                   	push   %ebx
  80150a:	83 ec 18             	sub    $0x18,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	53                   	push   %ebx
  801515:	e8 09 fc ff ff       	call   801123 <fd_lookup>
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 34                	js     801555 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801521:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	ff 36                	push   (%esi)
  80152d:	e8 41 fc ff ff       	call   801173 <dev_lookup>
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 1c                	js     801555 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801539:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80153d:	74 1d                	je     80155c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801542:	8b 40 18             	mov    0x18(%eax),%eax
  801545:	85 c0                	test   %eax,%eax
  801547:	74 34                	je     80157d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	ff 75 0c             	push   0xc(%ebp)
  80154f:	56                   	push   %esi
  801550:	ff d0                	call   *%eax
  801552:	83 c4 10             	add    $0x10,%esp
}
  801555:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80155c:	a1 00 40 80 00       	mov    0x804000,%eax
  801561:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	53                   	push   %ebx
  801568:	50                   	push   %eax
  801569:	68 dc 28 80 00       	push   $0x8028dc
  80156e:	e8 21 ee ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157b:	eb d8                	jmp    801555 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80157d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801582:	eb d1                	jmp    801555 <ftruncate+0x50>

00801584 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 18             	sub    $0x18,%esp
  80158c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801592:	50                   	push   %eax
  801593:	ff 75 08             	push   0x8(%ebp)
  801596:	e8 88 fb ff ff       	call   801123 <fd_lookup>
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 49                	js     8015eb <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	ff 36                	push   (%esi)
  8015ae:	e8 c0 fb ff ff       	call   801173 <dev_lookup>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 31                	js     8015eb <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c1:	74 2f                	je     8015f2 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015cd:	00 00 00 
	stat->st_isdir = 0;
  8015d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d7:	00 00 00 
	stat->st_dev = dev;
  8015da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	56                   	push   %esi
  8015e5:	ff 50 14             	call   *0x14(%eax)
  8015e8:	83 c4 10             	add    $0x10,%esp
}
  8015eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    
		return -E_NOT_SUPP;
  8015f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f7:	eb f2                	jmp    8015eb <fstat+0x67>

008015f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fe:	83 ec 08             	sub    $0x8,%esp
  801601:	6a 00                	push   $0x0
  801603:	ff 75 08             	push   0x8(%ebp)
  801606:	e8 e4 01 00 00       	call   8017ef <open>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	78 1b                	js     80162f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	ff 75 0c             	push   0xc(%ebp)
  80161a:	50                   	push   %eax
  80161b:	e8 64 ff ff ff       	call   801584 <fstat>
  801620:	89 c6                	mov    %eax,%esi
	close(fd);
  801622:	89 1c 24             	mov    %ebx,(%esp)
  801625:	e8 26 fc ff ff       	call   801250 <close>
	return r;
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	89 f3                	mov    %esi,%ebx
}
  80162f:	89 d8                	mov    %ebx,%eax
  801631:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	89 c6                	mov    %eax,%esi
  80163f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801641:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801648:	74 27                	je     801671 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164a:	6a 07                	push   $0x7
  80164c:	68 00 50 80 00       	push   $0x805000
  801651:	56                   	push   %esi
  801652:	ff 35 00 60 80 00    	push   0x806000
  801658:	e8 63 0b 00 00       	call   8021c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165d:	83 c4 0c             	add    $0xc,%esp
  801660:	6a 00                	push   $0x0
  801662:	53                   	push   %ebx
  801663:	6a 00                	push   $0x0
  801665:	e8 ef 0a 00 00       	call   802159 <ipc_recv>
}
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	6a 01                	push   $0x1
  801676:	e8 99 0b 00 00       	call   802214 <ipc_find_env>
  80167b:	a3 00 60 80 00       	mov    %eax,0x806000
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	eb c5                	jmp    80164a <fsipc+0x12>

00801685 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	8b 40 0c             	mov    0xc(%eax),%eax
  801691:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801696:	8b 45 0c             	mov    0xc(%ebp),%eax
  801699:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a8:	e8 8b ff ff ff       	call   801638 <fsipc>
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <devfile_flush>:
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ca:	e8 69 ff ff ff       	call   801638 <fsipc>
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <devfile_stat>:
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016db:	8b 45 08             	mov    0x8(%ebp),%eax
  8016de:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f0:	e8 43 ff ff ff       	call   801638 <fsipc>
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 2c                	js     801725 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	68 00 50 80 00       	push   $0x805000
  801701:	53                   	push   %ebx
  801702:	e8 57 f3 ff ff       	call   800a5e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801707:	a1 80 50 80 00       	mov    0x805080,%eax
  80170c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801712:	a1 84 50 80 00       	mov    0x805084,%eax
  801717:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <devfile_write>:
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	8b 45 10             	mov    0x10(%ebp),%eax
  801733:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801738:	39 d0                	cmp    %edx,%eax
  80173a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80173d:	8b 55 08             	mov    0x8(%ebp),%edx
  801740:	8b 52 0c             	mov    0xc(%edx),%edx
  801743:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801749:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80174e:	50                   	push   %eax
  80174f:	ff 75 0c             	push   0xc(%ebp)
  801752:	68 08 50 80 00       	push   $0x805008
  801757:	e8 98 f4 ff ff       	call   800bf4 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80175c:	ba 00 00 00 00       	mov    $0x0,%edx
  801761:	b8 04 00 00 00       	mov    $0x4,%eax
  801766:	e8 cd fe ff ff       	call   801638 <fsipc>
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <devfile_read>:
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
  801772:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801775:	8b 45 08             	mov    0x8(%ebp),%eax
  801778:	8b 40 0c             	mov    0xc(%eax),%eax
  80177b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801780:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801786:	ba 00 00 00 00       	mov    $0x0,%edx
  80178b:	b8 03 00 00 00       	mov    $0x3,%eax
  801790:	e8 a3 fe ff ff       	call   801638 <fsipc>
  801795:	89 c3                	mov    %eax,%ebx
  801797:	85 c0                	test   %eax,%eax
  801799:	78 1f                	js     8017ba <devfile_read+0x4d>
	assert(r <= n);
  80179b:	39 f0                	cmp    %esi,%eax
  80179d:	77 24                	ja     8017c3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80179f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a4:	7f 33                	jg     8017d9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	50                   	push   %eax
  8017aa:	68 00 50 80 00       	push   $0x805000
  8017af:	ff 75 0c             	push   0xc(%ebp)
  8017b2:	e8 3d f4 ff ff       	call   800bf4 <memmove>
	return r;
  8017b7:	83 c4 10             	add    $0x10,%esp
}
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    
	assert(r <= n);
  8017c3:	68 4c 29 80 00       	push   $0x80294c
  8017c8:	68 53 29 80 00       	push   $0x802953
  8017cd:	6a 7c                	push   $0x7c
  8017cf:	68 68 29 80 00       	push   $0x802968
  8017d4:	e8 e0 ea ff ff       	call   8002b9 <_panic>
	assert(r <= PGSIZE);
  8017d9:	68 73 29 80 00       	push   $0x802973
  8017de:	68 53 29 80 00       	push   $0x802953
  8017e3:	6a 7d                	push   $0x7d
  8017e5:	68 68 29 80 00       	push   $0x802968
  8017ea:	e8 ca ea ff ff       	call   8002b9 <_panic>

008017ef <open>:
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 1c             	sub    $0x1c,%esp
  8017f7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017fa:	56                   	push   %esi
  8017fb:	e8 23 f2 ff ff       	call   800a23 <strlen>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801808:	7f 6c                	jg     801876 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801810:	50                   	push   %eax
  801811:	e8 bd f8 ff ff       	call   8010d3 <fd_alloc>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 3c                	js     80185b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	56                   	push   %esi
  801823:	68 00 50 80 00       	push   $0x805000
  801828:	e8 31 f2 ff ff       	call   800a5e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80182d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801830:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801835:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801838:	b8 01 00 00 00       	mov    $0x1,%eax
  80183d:	e8 f6 fd ff ff       	call   801638 <fsipc>
  801842:	89 c3                	mov    %eax,%ebx
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	78 19                	js     801864 <open+0x75>
	return fd2num(fd);
  80184b:	83 ec 0c             	sub    $0xc,%esp
  80184e:	ff 75 f4             	push   -0xc(%ebp)
  801851:	e8 56 f8 ff ff       	call   8010ac <fd2num>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	83 c4 10             	add    $0x10,%esp
}
  80185b:	89 d8                	mov    %ebx,%eax
  80185d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801860:	5b                   	pop    %ebx
  801861:	5e                   	pop    %esi
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    
		fd_close(fd, 0);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	6a 00                	push   $0x0
  801869:	ff 75 f4             	push   -0xc(%ebp)
  80186c:	e8 58 f9 ff ff       	call   8011c9 <fd_close>
		return r;
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	eb e5                	jmp    80185b <open+0x6c>
		return -E_BAD_PATH;
  801876:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80187b:	eb de                	jmp    80185b <open+0x6c>

0080187d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 08 00 00 00       	mov    $0x8,%eax
  80188d:	e8 a6 fd ff ff       	call   801638 <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801894:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801898:	7f 01                	jg     80189b <writebuf+0x7>
  80189a:	c3                   	ret    
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018a4:	ff 70 04             	push   0x4(%eax)
  8018a7:	8d 40 10             	lea    0x10(%eax),%eax
  8018aa:	50                   	push   %eax
  8018ab:	ff 33                	push   (%ebx)
  8018ad:	e8 a8 fb ff ff       	call   80145a <write>
		if (result > 0)
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	7e 03                	jle    8018bc <writebuf+0x28>
			b->result += result;
  8018b9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018bc:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018bf:	74 0d                	je     8018ce <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c8:	0f 4f c2             	cmovg  %edx,%eax
  8018cb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <putch>:

static void
putch(int ch, void *thunk)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018dd:	8b 53 04             	mov    0x4(%ebx),%edx
  8018e0:	8d 42 01             	lea    0x1(%edx),%eax
  8018e3:	89 43 04             	mov    %eax,0x4(%ebx)
  8018e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e9:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018ed:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018f2:	74 05                	je     8018f9 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8018f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    
		writebuf(b);
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	e8 94 ff ff ff       	call   801894 <writebuf>
		b->idx = 0;
  801900:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801907:	eb eb                	jmp    8018f4 <putch+0x21>

00801909 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80191b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801922:	00 00 00 
	b.result = 0;
  801925:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80192c:	00 00 00 
	b.error = 1;
  80192f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801936:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801939:	ff 75 10             	push   0x10(%ebp)
  80193c:	ff 75 0c             	push   0xc(%ebp)
  80193f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	68 d3 18 80 00       	push   $0x8018d3
  80194b:	e8 3b eb ff ff       	call   80048b <vprintfmt>
	if (b.idx > 0)
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80195a:	7f 11                	jg     80196d <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80195c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801962:	85 c0                	test   %eax,%eax
  801964:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    
		writebuf(&b);
  80196d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801973:	e8 1c ff ff ff       	call   801894 <writebuf>
  801978:	eb e2                	jmp    80195c <vfprintf+0x53>

0080197a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801980:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801983:	50                   	push   %eax
  801984:	ff 75 0c             	push   0xc(%ebp)
  801987:	ff 75 08             	push   0x8(%ebp)
  80198a:	e8 7a ff ff ff       	call   801909 <vfprintf>
	va_end(ap);

	return cnt;
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <printf>:

int
printf(const char *fmt, ...)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801997:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80199a:	50                   	push   %eax
  80199b:	ff 75 08             	push   0x8(%ebp)
  80199e:	6a 01                	push   $0x1
  8019a0:	e8 64 ff ff ff       	call   801909 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019ad:	68 7f 29 80 00       	push   $0x80297f
  8019b2:	ff 75 0c             	push   0xc(%ebp)
  8019b5:	e8 a4 f0 ff ff       	call   800a5e <strcpy>
	return 0;
}
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <devsock_close>:
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 10             	sub    $0x10,%esp
  8019c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019cb:	53                   	push   %ebx
  8019cc:	e8 7c 08 00 00       	call   80224d <pageref>
  8019d1:	89 c2                	mov    %eax,%edx
  8019d3:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019d6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019db:	83 fa 01             	cmp    $0x1,%edx
  8019de:	74 05                	je     8019e5 <devsock_close+0x24>
}
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 73 0c             	push   0xc(%ebx)
  8019eb:	e8 b7 02 00 00       	call   801ca7 <nsipc_close>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	eb eb                	jmp    8019e0 <devsock_close+0x1f>

008019f5 <devsock_write>:
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 10             	push   0x10(%ebp)
  801a00:	ff 75 0c             	push   0xc(%ebp)
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	ff 70 0c             	push   0xc(%eax)
  801a09:	e8 79 03 00 00       	call   801d87 <nsipc_send>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devsock_read>:
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a16:	6a 00                	push   $0x0
  801a18:	ff 75 10             	push   0x10(%ebp)
  801a1b:	ff 75 0c             	push   0xc(%ebp)
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	ff 70 0c             	push   0xc(%eax)
  801a24:	e8 ef 02 00 00       	call   801d18 <nsipc_recv>
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <fd2sockid>:
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a31:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a34:	52                   	push   %edx
  801a35:	50                   	push   %eax
  801a36:	e8 e8 f6 ff ff       	call   801123 <fd_lookup>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 10                	js     801a52 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a45:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a4b:	39 08                	cmp    %ecx,(%eax)
  801a4d:	75 05                	jne    801a54 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a4f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    
		return -E_NOT_SUPP;
  801a54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a59:	eb f7                	jmp    801a52 <fd2sockid+0x27>

00801a5b <alloc_sockfd>:
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 1c             	sub    $0x1c,%esp
  801a63:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	e8 65 f6 ff ff       	call   8010d3 <fd_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 43                	js     801aba <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	68 07 04 00 00       	push   $0x407
  801a7f:	ff 75 f4             	push   -0xc(%ebp)
  801a82:	6a 00                	push   $0x0
  801a84:	e8 d1 f3 ff ff       	call   800e5a <sys_page_alloc>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 28                	js     801aba <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a9b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aa7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	50                   	push   %eax
  801aae:	e8 f9 f5 ff ff       	call   8010ac <fd2num>
  801ab3:	89 c3                	mov    %eax,%ebx
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	eb 0c                	jmp    801ac6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	56                   	push   %esi
  801abe:	e8 e4 01 00 00       	call   801ca7 <nsipc_close>
		return r;
  801ac3:	83 c4 10             	add    $0x10,%esp
}
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <accept>:
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad8:	e8 4e ff ff ff       	call   801a2b <fd2sockid>
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 1b                	js     801afc <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ae1:	83 ec 04             	sub    $0x4,%esp
  801ae4:	ff 75 10             	push   0x10(%ebp)
  801ae7:	ff 75 0c             	push   0xc(%ebp)
  801aea:	50                   	push   %eax
  801aeb:	e8 0e 01 00 00       	call   801bfe <nsipc_accept>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 05                	js     801afc <accept+0x2d>
	return alloc_sockfd(r);
  801af7:	e8 5f ff ff ff       	call   801a5b <alloc_sockfd>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <bind>:
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	e8 1f ff ff ff       	call   801a2b <fd2sockid>
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 12                	js     801b22 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	ff 75 10             	push   0x10(%ebp)
  801b16:	ff 75 0c             	push   0xc(%ebp)
  801b19:	50                   	push   %eax
  801b1a:	e8 31 01 00 00       	call   801c50 <nsipc_bind>
  801b1f:	83 c4 10             	add    $0x10,%esp
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <shutdown>:
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	e8 f9 fe ff ff       	call   801a2b <fd2sockid>
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 0f                	js     801b45 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b36:	83 ec 08             	sub    $0x8,%esp
  801b39:	ff 75 0c             	push   0xc(%ebp)
  801b3c:	50                   	push   %eax
  801b3d:	e8 43 01 00 00       	call   801c85 <nsipc_shutdown>
  801b42:	83 c4 10             	add    $0x10,%esp
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <connect>:
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	e8 d6 fe ff ff       	call   801a2b <fd2sockid>
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 12                	js     801b6b <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b59:	83 ec 04             	sub    $0x4,%esp
  801b5c:	ff 75 10             	push   0x10(%ebp)
  801b5f:	ff 75 0c             	push   0xc(%ebp)
  801b62:	50                   	push   %eax
  801b63:	e8 59 01 00 00       	call   801cc1 <nsipc_connect>
  801b68:	83 c4 10             	add    $0x10,%esp
}
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    

00801b6d <listen>:
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	e8 b0 fe ff ff       	call   801a2b <fd2sockid>
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 0f                	js     801b8e <listen+0x21>
	return nsipc_listen(r, backlog);
  801b7f:	83 ec 08             	sub    $0x8,%esp
  801b82:	ff 75 0c             	push   0xc(%ebp)
  801b85:	50                   	push   %eax
  801b86:	e8 6b 01 00 00       	call   801cf6 <nsipc_listen>
  801b8b:	83 c4 10             	add    $0x10,%esp
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b96:	ff 75 10             	push   0x10(%ebp)
  801b99:	ff 75 0c             	push   0xc(%ebp)
  801b9c:	ff 75 08             	push   0x8(%ebp)
  801b9f:	e8 41 02 00 00       	call   801de5 <nsipc_socket>
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 05                	js     801bb0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bab:	e8 ab fe ff ff       	call   801a5b <alloc_sockfd>
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	53                   	push   %ebx
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bbb:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bc2:	74 26                	je     801bea <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc4:	6a 07                	push   $0x7
  801bc6:	68 00 70 80 00       	push   $0x807000
  801bcb:	53                   	push   %ebx
  801bcc:	ff 35 00 80 80 00    	push   0x808000
  801bd2:	e8 e9 05 00 00       	call   8021c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd7:	83 c4 0c             	add    $0xc,%esp
  801bda:	6a 00                	push   $0x0
  801bdc:	6a 00                	push   $0x0
  801bde:	6a 00                	push   $0x0
  801be0:	e8 74 05 00 00       	call   802159 <ipc_recv>
}
  801be5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	6a 02                	push   $0x2
  801bef:	e8 20 06 00 00       	call   802214 <ipc_find_env>
  801bf4:	a3 00 80 80 00       	mov    %eax,0x808000
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	eb c6                	jmp    801bc4 <nsipc+0x12>

00801bfe <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	56                   	push   %esi
  801c02:	53                   	push   %ebx
  801c03:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c0e:	8b 06                	mov    (%esi),%eax
  801c10:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c15:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1a:	e8 93 ff ff ff       	call   801bb2 <nsipc>
  801c1f:	89 c3                	mov    %eax,%ebx
  801c21:	85 c0                	test   %eax,%eax
  801c23:	79 09                	jns    801c2e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c25:	89 d8                	mov    %ebx,%eax
  801c27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	ff 35 10 70 80 00    	push   0x807010
  801c37:	68 00 70 80 00       	push   $0x807000
  801c3c:	ff 75 0c             	push   0xc(%ebp)
  801c3f:	e8 b0 ef ff ff       	call   800bf4 <memmove>
		*addrlen = ret->ret_addrlen;
  801c44:	a1 10 70 80 00       	mov    0x807010,%eax
  801c49:	89 06                	mov    %eax,(%esi)
  801c4b:	83 c4 10             	add    $0x10,%esp
	return r;
  801c4e:	eb d5                	jmp    801c25 <nsipc_accept+0x27>

00801c50 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	53                   	push   %ebx
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c62:	53                   	push   %ebx
  801c63:	ff 75 0c             	push   0xc(%ebp)
  801c66:	68 04 70 80 00       	push   $0x807004
  801c6b:	e8 84 ef ff ff       	call   800bf4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c70:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c76:	b8 02 00 00 00       	mov    $0x2,%eax
  801c7b:	e8 32 ff ff ff       	call   801bb2 <nsipc>
}
  801c80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c96:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c9b:	b8 03 00 00 00       	mov    $0x3,%eax
  801ca0:	e8 0d ff ff ff       	call   801bb2 <nsipc>
}
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <nsipc_close>:

int
nsipc_close(int s)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cb5:	b8 04 00 00 00       	mov    $0x4,%eax
  801cba:	e8 f3 fe ff ff       	call   801bb2 <nsipc>
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cd3:	53                   	push   %ebx
  801cd4:	ff 75 0c             	push   0xc(%ebp)
  801cd7:	68 04 70 80 00       	push   $0x807004
  801cdc:	e8 13 ef ff ff       	call   800bf4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ce1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ce7:	b8 05 00 00 00       	mov    $0x5,%eax
  801cec:	e8 c1 fe ff ff       	call   801bb2 <nsipc>
}
  801cf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d07:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  801d11:	e8 9c fe ff ff       	call   801bb2 <nsipc>
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d28:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d2e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d31:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d36:	b8 07 00 00 00       	mov    $0x7,%eax
  801d3b:	e8 72 fe ff ff       	call   801bb2 <nsipc>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 22                	js     801d68 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d46:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d4b:	39 c6                	cmp    %eax,%esi
  801d4d:	0f 4e c6             	cmovle %esi,%eax
  801d50:	39 c3                	cmp    %eax,%ebx
  801d52:	7f 1d                	jg     801d71 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d54:	83 ec 04             	sub    $0x4,%esp
  801d57:	53                   	push   %ebx
  801d58:	68 00 70 80 00       	push   $0x807000
  801d5d:	ff 75 0c             	push   0xc(%ebp)
  801d60:	e8 8f ee ff ff       	call   800bf4 <memmove>
  801d65:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d71:	68 8b 29 80 00       	push   $0x80298b
  801d76:	68 53 29 80 00       	push   $0x802953
  801d7b:	6a 62                	push   $0x62
  801d7d:	68 a0 29 80 00       	push   $0x8029a0
  801d82:	e8 32 e5 ff ff       	call   8002b9 <_panic>

00801d87 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 04             	sub    $0x4,%esp
  801d8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d91:	8b 45 08             	mov    0x8(%ebp),%eax
  801d94:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d99:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d9f:	7f 2e                	jg     801dcf <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	53                   	push   %ebx
  801da5:	ff 75 0c             	push   0xc(%ebp)
  801da8:	68 0c 70 80 00       	push   $0x80700c
  801dad:	e8 42 ee ff ff       	call   800bf4 <memmove>
	nsipcbuf.send.req_size = size;
  801db2:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801db8:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801dc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc5:	e8 e8 fd ff ff       	call   801bb2 <nsipc>
}
  801dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    
	assert(size < 1600);
  801dcf:	68 ac 29 80 00       	push   $0x8029ac
  801dd4:	68 53 29 80 00       	push   $0x802953
  801dd9:	6a 6d                	push   $0x6d
  801ddb:	68 a0 29 80 00       	push   $0x8029a0
  801de0:	e8 d4 e4 ff ff       	call   8002b9 <_panic>

00801de5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801deb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dee:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801df3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df6:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801dfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfe:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e03:	b8 09 00 00 00       	mov    $0x9,%eax
  801e08:	e8 a5 fd ff ff       	call   801bb2 <nsipc>
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
  801e14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e17:	83 ec 0c             	sub    $0xc,%esp
  801e1a:	ff 75 08             	push   0x8(%ebp)
  801e1d:	e8 9a f2 ff ff       	call   8010bc <fd2data>
  801e22:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e24:	83 c4 08             	add    $0x8,%esp
  801e27:	68 b8 29 80 00       	push   $0x8029b8
  801e2c:	53                   	push   %ebx
  801e2d:	e8 2c ec ff ff       	call   800a5e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e32:	8b 46 04             	mov    0x4(%esi),%eax
  801e35:	2b 06                	sub    (%esi),%eax
  801e37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e44:	00 00 00 
	stat->st_dev = &devpipe;
  801e47:	c7 83 88 00 00 00 58 	movl   $0x803058,0x88(%ebx)
  801e4e:	30 80 00 
	return 0;
}
  801e51:	b8 00 00 00 00       	mov    $0x0,%eax
  801e56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e59:	5b                   	pop    %ebx
  801e5a:	5e                   	pop    %esi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    

00801e5d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	53                   	push   %ebx
  801e61:	83 ec 0c             	sub    $0xc,%esp
  801e64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e67:	53                   	push   %ebx
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 70 f0 ff ff       	call   800edf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e6f:	89 1c 24             	mov    %ebx,(%esp)
  801e72:	e8 45 f2 ff ff       	call   8010bc <fd2data>
  801e77:	83 c4 08             	add    $0x8,%esp
  801e7a:	50                   	push   %eax
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 5d f0 ff ff       	call   800edf <sys_page_unmap>
}
  801e82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <_pipeisclosed>:
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	57                   	push   %edi
  801e8b:	56                   	push   %esi
  801e8c:	53                   	push   %ebx
  801e8d:	83 ec 1c             	sub    $0x1c,%esp
  801e90:	89 c7                	mov    %eax,%edi
  801e92:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e94:	a1 00 40 80 00       	mov    0x804000,%eax
  801e99:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	57                   	push   %edi
  801ea0:	e8 a8 03 00 00       	call   80224d <pageref>
  801ea5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ea8:	89 34 24             	mov    %esi,(%esp)
  801eab:	e8 9d 03 00 00       	call   80224d <pageref>
		nn = thisenv->env_runs;
  801eb0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801eb6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	39 cb                	cmp    %ecx,%ebx
  801ebe:	74 1b                	je     801edb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ec0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ec3:	75 cf                	jne    801e94 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ec5:	8b 42 58             	mov    0x58(%edx),%eax
  801ec8:	6a 01                	push   $0x1
  801eca:	50                   	push   %eax
  801ecb:	53                   	push   %ebx
  801ecc:	68 bf 29 80 00       	push   $0x8029bf
  801ed1:	e8 be e4 ff ff       	call   800394 <cprintf>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	eb b9                	jmp    801e94 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801edb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ede:	0f 94 c0             	sete   %al
  801ee1:	0f b6 c0             	movzbl %al,%eax
}
  801ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <devpipe_write>:
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
  801ef2:	83 ec 28             	sub    $0x28,%esp
  801ef5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ef8:	56                   	push   %esi
  801ef9:	e8 be f1 ff ff       	call   8010bc <fd2data>
  801efe:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	bf 00 00 00 00       	mov    $0x0,%edi
  801f08:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f0b:	75 09                	jne    801f16 <devpipe_write+0x2a>
	return i;
  801f0d:	89 f8                	mov    %edi,%eax
  801f0f:	eb 23                	jmp    801f34 <devpipe_write+0x48>
			sys_yield();
  801f11:	e8 25 ef ff ff       	call   800e3b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f16:	8b 43 04             	mov    0x4(%ebx),%eax
  801f19:	8b 0b                	mov    (%ebx),%ecx
  801f1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801f1e:	39 d0                	cmp    %edx,%eax
  801f20:	72 1a                	jb     801f3c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f22:	89 da                	mov    %ebx,%edx
  801f24:	89 f0                	mov    %esi,%eax
  801f26:	e8 5c ff ff ff       	call   801e87 <_pipeisclosed>
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	74 e2                	je     801f11 <devpipe_write+0x25>
				return 0;
  801f2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f37:	5b                   	pop    %ebx
  801f38:	5e                   	pop    %esi
  801f39:	5f                   	pop    %edi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f46:	89 c2                	mov    %eax,%edx
  801f48:	c1 fa 1f             	sar    $0x1f,%edx
  801f4b:	89 d1                	mov    %edx,%ecx
  801f4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801f50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f53:	83 e2 1f             	and    $0x1f,%edx
  801f56:	29 ca                	sub    %ecx,%edx
  801f58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f60:	83 c0 01             	add    $0x1,%eax
  801f63:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f66:	83 c7 01             	add    $0x1,%edi
  801f69:	eb 9d                	jmp    801f08 <devpipe_write+0x1c>

00801f6b <devpipe_read>:
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	57                   	push   %edi
  801f6f:	56                   	push   %esi
  801f70:	53                   	push   %ebx
  801f71:	83 ec 18             	sub    $0x18,%esp
  801f74:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f77:	57                   	push   %edi
  801f78:	e8 3f f1 ff ff       	call   8010bc <fd2data>
  801f7d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	be 00 00 00 00       	mov    $0x0,%esi
  801f87:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f8a:	75 13                	jne    801f9f <devpipe_read+0x34>
	return i;
  801f8c:	89 f0                	mov    %esi,%eax
  801f8e:	eb 02                	jmp    801f92 <devpipe_read+0x27>
				return i;
  801f90:	89 f0                	mov    %esi,%eax
}
  801f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    
			sys_yield();
  801f9a:	e8 9c ee ff ff       	call   800e3b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f9f:	8b 03                	mov    (%ebx),%eax
  801fa1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fa4:	75 18                	jne    801fbe <devpipe_read+0x53>
			if (i > 0)
  801fa6:	85 f6                	test   %esi,%esi
  801fa8:	75 e6                	jne    801f90 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801faa:	89 da                	mov    %ebx,%edx
  801fac:	89 f8                	mov    %edi,%eax
  801fae:	e8 d4 fe ff ff       	call   801e87 <_pipeisclosed>
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	74 e3                	je     801f9a <devpipe_read+0x2f>
				return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbc:	eb d4                	jmp    801f92 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fbe:	99                   	cltd   
  801fbf:	c1 ea 1b             	shr    $0x1b,%edx
  801fc2:	01 d0                	add    %edx,%eax
  801fc4:	83 e0 1f             	and    $0x1f,%eax
  801fc7:	29 d0                	sub    %edx,%eax
  801fc9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fd1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fd4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fd7:	83 c6 01             	add    $0x1,%esi
  801fda:	eb ab                	jmp    801f87 <devpipe_read+0x1c>

00801fdc <pipe>:
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	56                   	push   %esi
  801fe0:	53                   	push   %ebx
  801fe1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe7:	50                   	push   %eax
  801fe8:	e8 e6 f0 ff ff       	call   8010d3 <fd_alloc>
  801fed:	89 c3                	mov    %eax,%ebx
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	0f 88 23 01 00 00    	js     80211d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffa:	83 ec 04             	sub    $0x4,%esp
  801ffd:	68 07 04 00 00       	push   $0x407
  802002:	ff 75 f4             	push   -0xc(%ebp)
  802005:	6a 00                	push   $0x0
  802007:	e8 4e ee ff ff       	call   800e5a <sys_page_alloc>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	0f 88 04 01 00 00    	js     80211d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802019:	83 ec 0c             	sub    $0xc,%esp
  80201c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80201f:	50                   	push   %eax
  802020:	e8 ae f0 ff ff       	call   8010d3 <fd_alloc>
  802025:	89 c3                	mov    %eax,%ebx
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	85 c0                	test   %eax,%eax
  80202c:	0f 88 db 00 00 00    	js     80210d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802032:	83 ec 04             	sub    $0x4,%esp
  802035:	68 07 04 00 00       	push   $0x407
  80203a:	ff 75 f0             	push   -0x10(%ebp)
  80203d:	6a 00                	push   $0x0
  80203f:	e8 16 ee ff ff       	call   800e5a <sys_page_alloc>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	0f 88 bc 00 00 00    	js     80210d <pipe+0x131>
	va = fd2data(fd0);
  802051:	83 ec 0c             	sub    $0xc,%esp
  802054:	ff 75 f4             	push   -0xc(%ebp)
  802057:	e8 60 f0 ff ff       	call   8010bc <fd2data>
  80205c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205e:	83 c4 0c             	add    $0xc,%esp
  802061:	68 07 04 00 00       	push   $0x407
  802066:	50                   	push   %eax
  802067:	6a 00                	push   $0x0
  802069:	e8 ec ed ff ff       	call   800e5a <sys_page_alloc>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	0f 88 82 00 00 00    	js     8020fd <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207b:	83 ec 0c             	sub    $0xc,%esp
  80207e:	ff 75 f0             	push   -0x10(%ebp)
  802081:	e8 36 f0 ff ff       	call   8010bc <fd2data>
  802086:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80208d:	50                   	push   %eax
  80208e:	6a 00                	push   $0x0
  802090:	56                   	push   %esi
  802091:	6a 00                	push   $0x0
  802093:	e8 05 ee ff ff       	call   800e9d <sys_page_map>
  802098:	89 c3                	mov    %eax,%ebx
  80209a:	83 c4 20             	add    $0x20,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 4e                	js     8020ef <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020a1:	a1 58 30 80 00       	mov    0x803058,%eax
  8020a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ae:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020b8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020bd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020c4:	83 ec 0c             	sub    $0xc,%esp
  8020c7:	ff 75 f4             	push   -0xc(%ebp)
  8020ca:	e8 dd ef ff ff       	call   8010ac <fd2num>
  8020cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020d4:	83 c4 04             	add    $0x4,%esp
  8020d7:	ff 75 f0             	push   -0x10(%ebp)
  8020da:	e8 cd ef ff ff       	call   8010ac <fd2num>
  8020df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020e5:	83 c4 10             	add    $0x10,%esp
  8020e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ed:	eb 2e                	jmp    80211d <pipe+0x141>
	sys_page_unmap(0, va);
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	56                   	push   %esi
  8020f3:	6a 00                	push   $0x0
  8020f5:	e8 e5 ed ff ff       	call   800edf <sys_page_unmap>
  8020fa:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020fd:	83 ec 08             	sub    $0x8,%esp
  802100:	ff 75 f0             	push   -0x10(%ebp)
  802103:	6a 00                	push   $0x0
  802105:	e8 d5 ed ff ff       	call   800edf <sys_page_unmap>
  80210a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80210d:	83 ec 08             	sub    $0x8,%esp
  802110:	ff 75 f4             	push   -0xc(%ebp)
  802113:	6a 00                	push   $0x0
  802115:	e8 c5 ed ff ff       	call   800edf <sys_page_unmap>
  80211a:	83 c4 10             	add    $0x10,%esp
}
  80211d:	89 d8                	mov    %ebx,%eax
  80211f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802122:	5b                   	pop    %ebx
  802123:	5e                   	pop    %esi
  802124:	5d                   	pop    %ebp
  802125:	c3                   	ret    

00802126 <pipeisclosed>:
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80212c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212f:	50                   	push   %eax
  802130:	ff 75 08             	push   0x8(%ebp)
  802133:	e8 eb ef ff ff       	call   801123 <fd_lookup>
  802138:	83 c4 10             	add    $0x10,%esp
  80213b:	85 c0                	test   %eax,%eax
  80213d:	78 18                	js     802157 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80213f:	83 ec 0c             	sub    $0xc,%esp
  802142:	ff 75 f4             	push   -0xc(%ebp)
  802145:	e8 72 ef ff ff       	call   8010bc <fd2data>
  80214a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80214c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214f:	e8 33 fd ff ff       	call   801e87 <_pipeisclosed>
  802154:	83 c4 10             	add    $0x10,%esp
}
  802157:	c9                   	leave  
  802158:	c3                   	ret    

00802159 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	56                   	push   %esi
  80215d:	53                   	push   %ebx
  80215e:	8b 75 08             	mov    0x8(%ebp),%esi
  802161:	8b 45 0c             	mov    0xc(%ebp),%eax
  802164:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802167:	85 c0                	test   %eax,%eax
  802169:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80216e:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802171:	83 ec 0c             	sub    $0xc,%esp
  802174:	50                   	push   %eax
  802175:	e8 90 ee ff ff       	call   80100a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	85 f6                	test   %esi,%esi
  80217f:	74 14                	je     802195 <ipc_recv+0x3c>
  802181:	ba 00 00 00 00       	mov    $0x0,%edx
  802186:	85 c0                	test   %eax,%eax
  802188:	78 09                	js     802193 <ipc_recv+0x3a>
  80218a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802190:	8b 52 74             	mov    0x74(%edx),%edx
  802193:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802195:	85 db                	test   %ebx,%ebx
  802197:	74 14                	je     8021ad <ipc_recv+0x54>
  802199:	ba 00 00 00 00       	mov    $0x0,%edx
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	78 09                	js     8021ab <ipc_recv+0x52>
  8021a2:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8021a8:	8b 52 78             	mov    0x78(%edx),%edx
  8021ab:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	78 08                	js     8021b9 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8021b1:	a1 00 40 80 00       	mov    0x804000,%eax
  8021b6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5e                   	pop    %esi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	57                   	push   %edi
  8021c4:	56                   	push   %esi
  8021c5:	53                   	push   %ebx
  8021c6:	83 ec 0c             	sub    $0xc,%esp
  8021c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8021d2:	85 db                	test   %ebx,%ebx
  8021d4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021d9:	0f 44 d8             	cmove  %eax,%ebx
  8021dc:	eb 05                	jmp    8021e3 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8021de:	e8 58 ec ff ff       	call   800e3b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8021e3:	ff 75 14             	push   0x14(%ebp)
  8021e6:	53                   	push   %ebx
  8021e7:	56                   	push   %esi
  8021e8:	57                   	push   %edi
  8021e9:	e8 f9 ed ff ff       	call   800fe7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021f4:	74 e8                	je     8021de <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	78 08                	js     802202 <ipc_send+0x42>
	}while (r<0);

}
  8021fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802202:	50                   	push   %eax
  802203:	68 d7 29 80 00       	push   $0x8029d7
  802208:	6a 3d                	push   $0x3d
  80220a:	68 eb 29 80 00       	push   $0x8029eb
  80220f:	e8 a5 e0 ff ff       	call   8002b9 <_panic>

00802214 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80221a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80221f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802222:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802228:	8b 52 50             	mov    0x50(%edx),%edx
  80222b:	39 ca                	cmp    %ecx,%edx
  80222d:	74 11                	je     802240 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80222f:	83 c0 01             	add    $0x1,%eax
  802232:	3d 00 04 00 00       	cmp    $0x400,%eax
  802237:	75 e6                	jne    80221f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
  80223e:	eb 0b                	jmp    80224b <ipc_find_env+0x37>
			return envs[i].env_id;
  802240:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802243:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802248:	8b 40 48             	mov    0x48(%eax),%eax
}
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    

0080224d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802253:	89 c2                	mov    %eax,%edx
  802255:	c1 ea 16             	shr    $0x16,%edx
  802258:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80225f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802264:	f6 c1 01             	test   $0x1,%cl
  802267:	74 1c                	je     802285 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802269:	c1 e8 0c             	shr    $0xc,%eax
  80226c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802273:	a8 01                	test   $0x1,%al
  802275:	74 0e                	je     802285 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802277:	c1 e8 0c             	shr    $0xc,%eax
  80227a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802281:	ef 
  802282:	0f b7 d2             	movzwl %dx,%edx
}
  802285:	89 d0                	mov    %edx,%eax
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	66 90                	xchg   %ax,%ax
  80228b:	66 90                	xchg   %ax,%ax
  80228d:	66 90                	xchg   %ax,%ax
  80228f:	90                   	nop

00802290 <__udivdi3>:
  802290:	f3 0f 1e fb          	endbr32 
  802294:	55                   	push   %ebp
  802295:	57                   	push   %edi
  802296:	56                   	push   %esi
  802297:	53                   	push   %ebx
  802298:	83 ec 1c             	sub    $0x1c,%esp
  80229b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80229f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	75 19                	jne    8022c8 <__udivdi3+0x38>
  8022af:	39 f3                	cmp    %esi,%ebx
  8022b1:	76 4d                	jbe    802300 <__udivdi3+0x70>
  8022b3:	31 ff                	xor    %edi,%edi
  8022b5:	89 e8                	mov    %ebp,%eax
  8022b7:	89 f2                	mov    %esi,%edx
  8022b9:	f7 f3                	div    %ebx
  8022bb:	89 fa                	mov    %edi,%edx
  8022bd:	83 c4 1c             	add    $0x1c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	39 f0                	cmp    %esi,%eax
  8022ca:	76 14                	jbe    8022e0 <__udivdi3+0x50>
  8022cc:	31 ff                	xor    %edi,%edi
  8022ce:	31 c0                	xor    %eax,%eax
  8022d0:	89 fa                	mov    %edi,%edx
  8022d2:	83 c4 1c             	add    $0x1c,%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5f                   	pop    %edi
  8022d8:	5d                   	pop    %ebp
  8022d9:	c3                   	ret    
  8022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e0:	0f bd f8             	bsr    %eax,%edi
  8022e3:	83 f7 1f             	xor    $0x1f,%edi
  8022e6:	75 48                	jne    802330 <__udivdi3+0xa0>
  8022e8:	39 f0                	cmp    %esi,%eax
  8022ea:	72 06                	jb     8022f2 <__udivdi3+0x62>
  8022ec:	31 c0                	xor    %eax,%eax
  8022ee:	39 eb                	cmp    %ebp,%ebx
  8022f0:	77 de                	ja     8022d0 <__udivdi3+0x40>
  8022f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f7:	eb d7                	jmp    8022d0 <__udivdi3+0x40>
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d9                	mov    %ebx,%ecx
  802302:	85 db                	test   %ebx,%ebx
  802304:	75 0b                	jne    802311 <__udivdi3+0x81>
  802306:	b8 01 00 00 00       	mov    $0x1,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	f7 f3                	div    %ebx
  80230f:	89 c1                	mov    %eax,%ecx
  802311:	31 d2                	xor    %edx,%edx
  802313:	89 f0                	mov    %esi,%eax
  802315:	f7 f1                	div    %ecx
  802317:	89 c6                	mov    %eax,%esi
  802319:	89 e8                	mov    %ebp,%eax
  80231b:	89 f7                	mov    %esi,%edi
  80231d:	f7 f1                	div    %ecx
  80231f:	89 fa                	mov    %edi,%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 f9                	mov    %edi,%ecx
  802332:	ba 20 00 00 00       	mov    $0x20,%edx
  802337:	29 fa                	sub    %edi,%edx
  802339:	d3 e0                	shl    %cl,%eax
  80233b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80233f:	89 d1                	mov    %edx,%ecx
  802341:	89 d8                	mov    %ebx,%eax
  802343:	d3 e8                	shr    %cl,%eax
  802345:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802349:	09 c1                	or     %eax,%ecx
  80234b:	89 f0                	mov    %esi,%eax
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f9                	mov    %edi,%ecx
  802353:	d3 e3                	shl    %cl,%ebx
  802355:	89 d1                	mov    %edx,%ecx
  802357:	d3 e8                	shr    %cl,%eax
  802359:	89 f9                	mov    %edi,%ecx
  80235b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80235f:	89 eb                	mov    %ebp,%ebx
  802361:	d3 e6                	shl    %cl,%esi
  802363:	89 d1                	mov    %edx,%ecx
  802365:	d3 eb                	shr    %cl,%ebx
  802367:	09 f3                	or     %esi,%ebx
  802369:	89 c6                	mov    %eax,%esi
  80236b:	89 f2                	mov    %esi,%edx
  80236d:	89 d8                	mov    %ebx,%eax
  80236f:	f7 74 24 08          	divl   0x8(%esp)
  802373:	89 d6                	mov    %edx,%esi
  802375:	89 c3                	mov    %eax,%ebx
  802377:	f7 64 24 0c          	mull   0xc(%esp)
  80237b:	39 d6                	cmp    %edx,%esi
  80237d:	72 19                	jb     802398 <__udivdi3+0x108>
  80237f:	89 f9                	mov    %edi,%ecx
  802381:	d3 e5                	shl    %cl,%ebp
  802383:	39 c5                	cmp    %eax,%ebp
  802385:	73 04                	jae    80238b <__udivdi3+0xfb>
  802387:	39 d6                	cmp    %edx,%esi
  802389:	74 0d                	je     802398 <__udivdi3+0x108>
  80238b:	89 d8                	mov    %ebx,%eax
  80238d:	31 ff                	xor    %edi,%edi
  80238f:	e9 3c ff ff ff       	jmp    8022d0 <__udivdi3+0x40>
  802394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802398:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80239b:	31 ff                	xor    %edi,%edi
  80239d:	e9 2e ff ff ff       	jmp    8022d0 <__udivdi3+0x40>
  8023a2:	66 90                	xchg   %ax,%ax
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	f3 0f 1e fb          	endbr32 
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 1c             	sub    $0x1c,%esp
  8023bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8023c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8023cb:	89 f0                	mov    %esi,%eax
  8023cd:	89 da                	mov    %ebx,%edx
  8023cf:	85 ff                	test   %edi,%edi
  8023d1:	75 15                	jne    8023e8 <__umoddi3+0x38>
  8023d3:	39 dd                	cmp    %ebx,%ebp
  8023d5:	76 39                	jbe    802410 <__umoddi3+0x60>
  8023d7:	f7 f5                	div    %ebp
  8023d9:	89 d0                	mov    %edx,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	39 df                	cmp    %ebx,%edi
  8023ea:	77 f1                	ja     8023dd <__umoddi3+0x2d>
  8023ec:	0f bd cf             	bsr    %edi,%ecx
  8023ef:	83 f1 1f             	xor    $0x1f,%ecx
  8023f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023f6:	75 40                	jne    802438 <__umoddi3+0x88>
  8023f8:	39 df                	cmp    %ebx,%edi
  8023fa:	72 04                	jb     802400 <__umoddi3+0x50>
  8023fc:	39 f5                	cmp    %esi,%ebp
  8023fe:	77 dd                	ja     8023dd <__umoddi3+0x2d>
  802400:	89 da                	mov    %ebx,%edx
  802402:	89 f0                	mov    %esi,%eax
  802404:	29 e8                	sub    %ebp,%eax
  802406:	19 fa                	sbb    %edi,%edx
  802408:	eb d3                	jmp    8023dd <__umoddi3+0x2d>
  80240a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802410:	89 e9                	mov    %ebp,%ecx
  802412:	85 ed                	test   %ebp,%ebp
  802414:	75 0b                	jne    802421 <__umoddi3+0x71>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f5                	div    %ebp
  80241f:	89 c1                	mov    %eax,%ecx
  802421:	89 d8                	mov    %ebx,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f1                	div    %ecx
  802427:	89 f0                	mov    %esi,%eax
  802429:	f7 f1                	div    %ecx
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	31 d2                	xor    %edx,%edx
  80242f:	eb ac                	jmp    8023dd <__umoddi3+0x2d>
  802431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802438:	8b 44 24 04          	mov    0x4(%esp),%eax
  80243c:	ba 20 00 00 00       	mov    $0x20,%edx
  802441:	29 c2                	sub    %eax,%edx
  802443:	89 c1                	mov    %eax,%ecx
  802445:	89 e8                	mov    %ebp,%eax
  802447:	d3 e7                	shl    %cl,%edi
  802449:	89 d1                	mov    %edx,%ecx
  80244b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80244f:	d3 e8                	shr    %cl,%eax
  802451:	89 c1                	mov    %eax,%ecx
  802453:	8b 44 24 04          	mov    0x4(%esp),%eax
  802457:	09 f9                	or     %edi,%ecx
  802459:	89 df                	mov    %ebx,%edi
  80245b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245f:	89 c1                	mov    %eax,%ecx
  802461:	d3 e5                	shl    %cl,%ebp
  802463:	89 d1                	mov    %edx,%ecx
  802465:	d3 ef                	shr    %cl,%edi
  802467:	89 c1                	mov    %eax,%ecx
  802469:	89 f0                	mov    %esi,%eax
  80246b:	d3 e3                	shl    %cl,%ebx
  80246d:	89 d1                	mov    %edx,%ecx
  80246f:	89 fa                	mov    %edi,%edx
  802471:	d3 e8                	shr    %cl,%eax
  802473:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802478:	09 d8                	or     %ebx,%eax
  80247a:	f7 74 24 08          	divl   0x8(%esp)
  80247e:	89 d3                	mov    %edx,%ebx
  802480:	d3 e6                	shl    %cl,%esi
  802482:	f7 e5                	mul    %ebp
  802484:	89 c7                	mov    %eax,%edi
  802486:	89 d1                	mov    %edx,%ecx
  802488:	39 d3                	cmp    %edx,%ebx
  80248a:	72 06                	jb     802492 <__umoddi3+0xe2>
  80248c:	75 0e                	jne    80249c <__umoddi3+0xec>
  80248e:	39 c6                	cmp    %eax,%esi
  802490:	73 0a                	jae    80249c <__umoddi3+0xec>
  802492:	29 e8                	sub    %ebp,%eax
  802494:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802498:	89 d1                	mov    %edx,%ecx
  80249a:	89 c7                	mov    %eax,%edi
  80249c:	89 f5                	mov    %esi,%ebp
  80249e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8024a2:	29 fd                	sub    %edi,%ebp
  8024a4:	19 cb                	sbb    %ecx,%ebx
  8024a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8024ab:	89 d8                	mov    %ebx,%eax
  8024ad:	d3 e0                	shl    %cl,%eax
  8024af:	89 f1                	mov    %esi,%ecx
  8024b1:	d3 ed                	shr    %cl,%ebp
  8024b3:	d3 eb                	shr    %cl,%ebx
  8024b5:	09 e8                	or     %ebp,%eax
  8024b7:	89 da                	mov    %ebx,%edx
  8024b9:	83 c4 1c             	add    $0x1c,%esp
  8024bc:	5b                   	pop    %ebx
  8024bd:	5e                   	pop    %esi
  8024be:	5f                   	pop    %edi
  8024bf:	5d                   	pop    %ebp
  8024c0:	c3                   	ret    
