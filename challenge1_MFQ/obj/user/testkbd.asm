
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
  80003f:	e8 fa 0d 00 00       	call   800e3e <sys_yield>
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 00 12 00 00       	call   801253 <close>
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
  80006e:	e8 49 02 00 00       	call   8002bc <_panic>
		panic("opencons: %e", r);
  800073:	50                   	push   %eax
  800074:	68 e0 24 80 00       	push   $0x8024e0
  800079:	6a 0f                	push   $0xf
  80007b:	68 ed 24 80 00       	push   $0x8024ed
  800080:	e8 37 02 00 00       	call   8002bc <_panic>
	if ((r = dup(0, 1)) < 0)
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	6a 01                	push   $0x1
  80008a:	6a 00                	push   $0x0
  80008c:	e8 14 12 00 00       	call   8012a5 <dup>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 25                	jns    8000bd <umain+0x8a>
		panic("dup: %e", r);
  800098:	50                   	push   %eax
  800099:	68 16 25 80 00       	push   $0x802516
  80009e:	6a 13                	push   $0x13
  8000a0:	68 ed 24 80 00       	push   $0x8024ed
  8000a5:	e8 12 02 00 00       	call   8002bc <_panic>
	for(;;){
		char *buf;

		buf = readline("Type a line: ");
		if (buf != NULL)
			fprintf(1, "%s\n", buf);
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	50                   	push   %eax
  8000ae:	68 2c 25 80 00       	push   $0x80252c
  8000b3:	6a 01                	push   $0x1
  8000b5:	e8 c3 18 00 00       	call   80197d <fprintf>
  8000ba:	83 c4 10             	add    $0x10,%esp
		buf = readline("Type a line: ");
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	68 1e 25 80 00       	push   $0x80251e
  8000c5:	e8 6c 08 00 00       	call   800936 <readline>
		if (buf != NULL)
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	75 d9                	jne    8000aa <umain+0x77>
		else
			fprintf(1, "(end of file received)\n");
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	68 30 25 80 00       	push   $0x802530
  8000d9:	6a 01                	push   $0x1
  8000db:	e8 9d 18 00 00       	call   80197d <fprintf>
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
  8000f9:	e8 63 09 00 00       	call   800a61 <strcpy>
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
  800138:	e8 ba 0a 00 00       	call   800bf7 <memmove>
		sys_cputs(buf, m);
  80013d:	83 c4 08             	add    $0x8,%esp
  800140:	53                   	push   %ebx
  800141:	57                   	push   %edi
  800142:	e8 5a 0c 00 00       	call   800da1 <sys_cputs>
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
  80016e:	e8 cb 0c 00 00       	call   800e3e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800173:	e8 47 0c 00 00       	call   800dbf <sys_cgetc>
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
  8001a8:	e8 f4 0b 00 00       	call   800da1 <sys_cputs>
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
  8001c0:	e8 ca 11 00 00       	call   80138f <read>
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
  8001e8:	e8 39 0f 00 00       	call   801126 <fd_lookup>
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
  800211:	e8 c0 0e 00 00       	call   8010d6 <fd_alloc>
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	85 c0                	test   %eax,%eax
  80021b:	78 3a                	js     800257 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80021d:	83 ec 04             	sub    $0x4,%esp
  800220:	68 07 04 00 00       	push   $0x407
  800225:	ff 75 f4             	push   -0xc(%ebp)
  800228:	6a 00                	push   $0x0
  80022a:	e8 2e 0c 00 00       	call   800e5d <sys_page_alloc>
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
  80024f:	e8 5b 0e 00 00       	call   8010af <fd2num>
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
  800264:	e8 b6 0b 00 00       	call   800e1f <sys_getenvid>
  800269:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026e:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800274:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800279:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027e:	85 db                	test   %ebx,%ebx
  800280:	7e 07                	jle    800289 <libmain+0x30>
		binaryname = argv[0];
  800282:	8b 06                	mov    (%esi),%eax
  800284:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	e8 a0 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800293:	e8 0a 00 00 00       	call   8002a2 <exit>
}
  800298:	83 c4 10             	add    $0x10,%esp
  80029b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80029e:	5b                   	pop    %ebx
  80029f:	5e                   	pop    %esi
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002a8:	e8 d3 0f 00 00       	call   801280 <close_all>
	sys_env_destroy(0);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	6a 00                	push   $0x0
  8002b2:	e8 27 0b 00 00       	call   800dde <sys_env_destroy>
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002ca:	e8 50 0b 00 00       	call   800e1f <sys_getenvid>
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	ff 75 0c             	push   0xc(%ebp)
  8002d5:	ff 75 08             	push   0x8(%ebp)
  8002d8:	56                   	push   %esi
  8002d9:	50                   	push   %eax
  8002da:	68 60 25 80 00       	push   $0x802560
  8002df:	e8 b3 00 00 00       	call   800397 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e4:	83 c4 18             	add    $0x18,%esp
  8002e7:	53                   	push   %ebx
  8002e8:	ff 75 10             	push   0x10(%ebp)
  8002eb:	e8 56 00 00 00       	call   800346 <vcprintf>
	cprintf("\n");
  8002f0:	c7 04 24 46 25 80 00 	movl   $0x802546,(%esp)
  8002f7:	e8 9b 00 00 00       	call   800397 <cprintf>
  8002fc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ff:	cc                   	int3   
  800300:	eb fd                	jmp    8002ff <_panic+0x43>

00800302 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	53                   	push   %ebx
  800306:	83 ec 04             	sub    $0x4,%esp
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030c:	8b 13                	mov    (%ebx),%edx
  80030e:	8d 42 01             	lea    0x1(%edx),%eax
  800311:	89 03                	mov    %eax,(%ebx)
  800313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800316:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80031a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031f:	74 09                	je     80032a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800321:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800328:	c9                   	leave  
  800329:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	68 ff 00 00 00       	push   $0xff
  800332:	8d 43 08             	lea    0x8(%ebx),%eax
  800335:	50                   	push   %eax
  800336:	e8 66 0a 00 00       	call   800da1 <sys_cputs>
		b->idx = 0;
  80033b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	eb db                	jmp    800321 <putch+0x1f>

00800346 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80034f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800356:	00 00 00 
	b.cnt = 0;
  800359:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800360:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800363:	ff 75 0c             	push   0xc(%ebp)
  800366:	ff 75 08             	push   0x8(%ebp)
  800369:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036f:	50                   	push   %eax
  800370:	68 02 03 80 00       	push   $0x800302
  800375:	e8 14 01 00 00       	call   80048e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037a:	83 c4 08             	add    $0x8,%esp
  80037d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800383:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800389:	50                   	push   %eax
  80038a:	e8 12 0a 00 00       	call   800da1 <sys_cputs>

	return b.cnt;
}
  80038f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a0:	50                   	push   %eax
  8003a1:	ff 75 08             	push   0x8(%ebp)
  8003a4:	e8 9d ff ff ff       	call   800346 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 1c             	sub    $0x1c,%esp
  8003b4:	89 c7                	mov    %eax,%edi
  8003b6:	89 d6                	mov    %edx,%esi
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003be:	89 d1                	mov    %edx,%ecx
  8003c0:	89 c2                	mov    %eax,%edx
  8003c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d8:	39 c2                	cmp    %eax,%edx
  8003da:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003dd:	72 3e                	jb     80041d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003df:	83 ec 0c             	sub    $0xc,%esp
  8003e2:	ff 75 18             	push   0x18(%ebp)
  8003e5:	83 eb 01             	sub    $0x1,%ebx
  8003e8:	53                   	push   %ebx
  8003e9:	50                   	push   %eax
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	ff 75 e4             	push   -0x1c(%ebp)
  8003f0:	ff 75 e0             	push   -0x20(%ebp)
  8003f3:	ff 75 dc             	push   -0x24(%ebp)
  8003f6:	ff 75 d8             	push   -0x28(%ebp)
  8003f9:	e8 a2 1e 00 00       	call   8022a0 <__udivdi3>
  8003fe:	83 c4 18             	add    $0x18,%esp
  800401:	52                   	push   %edx
  800402:	50                   	push   %eax
  800403:	89 f2                	mov    %esi,%edx
  800405:	89 f8                	mov    %edi,%eax
  800407:	e8 9f ff ff ff       	call   8003ab <printnum>
  80040c:	83 c4 20             	add    $0x20,%esp
  80040f:	eb 13                	jmp    800424 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	56                   	push   %esi
  800415:	ff 75 18             	push   0x18(%ebp)
  800418:	ff d7                	call   *%edi
  80041a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80041d:	83 eb 01             	sub    $0x1,%ebx
  800420:	85 db                	test   %ebx,%ebx
  800422:	7f ed                	jg     800411 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	56                   	push   %esi
  800428:	83 ec 04             	sub    $0x4,%esp
  80042b:	ff 75 e4             	push   -0x1c(%ebp)
  80042e:	ff 75 e0             	push   -0x20(%ebp)
  800431:	ff 75 dc             	push   -0x24(%ebp)
  800434:	ff 75 d8             	push   -0x28(%ebp)
  800437:	e8 84 1f 00 00       	call   8023c0 <__umoddi3>
  80043c:	83 c4 14             	add    $0x14,%esp
  80043f:	0f be 80 83 25 80 00 	movsbl 0x802583(%eax),%eax
  800446:	50                   	push   %eax
  800447:	ff d7                	call   *%edi
}
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80044f:	5b                   	pop    %ebx
  800450:	5e                   	pop    %esi
  800451:	5f                   	pop    %edi
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	3b 50 04             	cmp    0x4(%eax),%edx
  800463:	73 0a                	jae    80046f <sprintputch+0x1b>
		*b->buf++ = ch;
  800465:	8d 4a 01             	lea    0x1(%edx),%ecx
  800468:	89 08                	mov    %ecx,(%eax)
  80046a:	8b 45 08             	mov    0x8(%ebp),%eax
  80046d:	88 02                	mov    %al,(%edx)
}
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <printfmt>:
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800477:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047a:	50                   	push   %eax
  80047b:	ff 75 10             	push   0x10(%ebp)
  80047e:	ff 75 0c             	push   0xc(%ebp)
  800481:	ff 75 08             	push   0x8(%ebp)
  800484:	e8 05 00 00 00       	call   80048e <vprintfmt>
}
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	c9                   	leave  
  80048d:	c3                   	ret    

0080048e <vprintfmt>:
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	53                   	push   %ebx
  800494:	83 ec 3c             	sub    $0x3c,%esp
  800497:	8b 75 08             	mov    0x8(%ebp),%esi
  80049a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a0:	eb 0a                	jmp    8004ac <vprintfmt+0x1e>
			putch(ch, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	50                   	push   %eax
  8004a7:	ff d6                	call   *%esi
  8004a9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ac:	83 c7 01             	add    $0x1,%edi
  8004af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b3:	83 f8 25             	cmp    $0x25,%eax
  8004b6:	74 0c                	je     8004c4 <vprintfmt+0x36>
			if (ch == '\0')
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	75 e6                	jne    8004a2 <vprintfmt+0x14>
}
  8004bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bf:	5b                   	pop    %ebx
  8004c0:	5e                   	pop    %esi
  8004c1:	5f                   	pop    %edi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    
		padc = ' ';
  8004c4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004c8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004cf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004d6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8d 47 01             	lea    0x1(%edi),%eax
  8004e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e8:	0f b6 17             	movzbl (%edi),%edx
  8004eb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004ee:	3c 55                	cmp    $0x55,%al
  8004f0:	0f 87 bb 03 00 00    	ja     8008b1 <vprintfmt+0x423>
  8004f6:	0f b6 c0             	movzbl %al,%eax
  8004f9:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800503:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800507:	eb d9                	jmp    8004e2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800510:	eb d0                	jmp    8004e2 <vprintfmt+0x54>
  800512:	0f b6 d2             	movzbl %dl,%edx
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800520:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800523:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800527:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80052a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80052d:	83 f9 09             	cmp    $0x9,%ecx
  800530:	77 55                	ja     800587 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800532:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800535:	eb e9                	jmp    800520 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 40 04             	lea    0x4(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80054b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054f:	79 91                	jns    8004e2 <vprintfmt+0x54>
				width = precision, precision = -1;
  800551:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800554:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800557:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80055e:	eb 82                	jmp    8004e2 <vprintfmt+0x54>
  800560:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800563:	85 d2                	test   %edx,%edx
  800565:	b8 00 00 00 00       	mov    $0x0,%eax
  80056a:	0f 49 c2             	cmovns %edx,%eax
  80056d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800573:	e9 6a ff ff ff       	jmp    8004e2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80057b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800582:	e9 5b ff ff ff       	jmp    8004e2 <vprintfmt+0x54>
  800587:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	eb bc                	jmp    80054b <vprintfmt+0xbd>
			lflag++;
  80058f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800595:	e9 48 ff ff ff       	jmp    8004e2 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 78 04             	lea    0x4(%eax),%edi
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	ff 30                	push   (%eax)
  8005a6:	ff d6                	call   *%esi
			break;
  8005a8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005ab:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ae:	e9 9d 02 00 00       	jmp    800850 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 78 04             	lea    0x4(%eax),%edi
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	89 d0                	mov    %edx,%eax
  8005bd:	f7 d8                	neg    %eax
  8005bf:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c2:	83 f8 0f             	cmp    $0xf,%eax
  8005c5:	7f 23                	jg     8005ea <vprintfmt+0x15c>
  8005c7:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 18                	je     8005ea <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8005d2:	52                   	push   %edx
  8005d3:	68 65 29 80 00       	push   $0x802965
  8005d8:	53                   	push   %ebx
  8005d9:	56                   	push   %esi
  8005da:	e8 92 fe ff ff       	call   800471 <printfmt>
  8005df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005e2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005e5:	e9 66 02 00 00       	jmp    800850 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 9b 25 80 00       	push   $0x80259b
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 7a fe ff ff       	call   800471 <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005fa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 4e 02 00 00       	jmp    800850 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	83 c0 04             	add    $0x4,%eax
  800608:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800610:	85 d2                	test   %edx,%edx
  800612:	b8 94 25 80 00       	mov    $0x802594,%eax
  800617:	0f 45 c2             	cmovne %edx,%eax
  80061a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80061d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800621:	7e 06                	jle    800629 <vprintfmt+0x19b>
  800623:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800627:	75 0d                	jne    800636 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800629:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80062c:	89 c7                	mov    %eax,%edi
  80062e:	03 45 e0             	add    -0x20(%ebp),%eax
  800631:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800634:	eb 55                	jmp    80068b <vprintfmt+0x1fd>
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	ff 75 d8             	push   -0x28(%ebp)
  80063c:	ff 75 cc             	push   -0x34(%ebp)
  80063f:	e8 fa 03 00 00       	call   800a3e <strnlen>
  800644:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800647:	29 c1                	sub    %eax,%ecx
  800649:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800651:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800655:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800658:	eb 0f                	jmp    800669 <vprintfmt+0x1db>
					putch(padc, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	ff 75 e0             	push   -0x20(%ebp)
  800661:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	83 ef 01             	sub    $0x1,%edi
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	85 ff                	test   %edi,%edi
  80066b:	7f ed                	jg     80065a <vprintfmt+0x1cc>
  80066d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800670:	85 d2                	test   %edx,%edx
  800672:	b8 00 00 00 00       	mov    $0x0,%eax
  800677:	0f 49 c2             	cmovns %edx,%eax
  80067a:	29 c2                	sub    %eax,%edx
  80067c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80067f:	eb a8                	jmp    800629 <vprintfmt+0x19b>
					putch(ch, putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	52                   	push   %edx
  800686:	ff d6                	call   *%esi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800690:	83 c7 01             	add    $0x1,%edi
  800693:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800697:	0f be d0             	movsbl %al,%edx
  80069a:	85 d2                	test   %edx,%edx
  80069c:	74 4b                	je     8006e9 <vprintfmt+0x25b>
  80069e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a2:	78 06                	js     8006aa <vprintfmt+0x21c>
  8006a4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006a8:	78 1e                	js     8006c8 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ae:	74 d1                	je     800681 <vprintfmt+0x1f3>
  8006b0:	0f be c0             	movsbl %al,%eax
  8006b3:	83 e8 20             	sub    $0x20,%eax
  8006b6:	83 f8 5e             	cmp    $0x5e,%eax
  8006b9:	76 c6                	jbe    800681 <vprintfmt+0x1f3>
					putch('?', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 3f                	push   $0x3f
  8006c1:	ff d6                	call   *%esi
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	eb c3                	jmp    80068b <vprintfmt+0x1fd>
  8006c8:	89 cf                	mov    %ecx,%edi
  8006ca:	eb 0e                	jmp    8006da <vprintfmt+0x24c>
				putch(' ', putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 20                	push   $0x20
  8006d2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006d4:	83 ef 01             	sub    $0x1,%edi
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	85 ff                	test   %edi,%edi
  8006dc:	7f ee                	jg     8006cc <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8006de:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e4:	e9 67 01 00 00       	jmp    800850 <vprintfmt+0x3c2>
  8006e9:	89 cf                	mov    %ecx,%edi
  8006eb:	eb ed                	jmp    8006da <vprintfmt+0x24c>
	if (lflag >= 2)
  8006ed:	83 f9 01             	cmp    $0x1,%ecx
  8006f0:	7f 1b                	jg     80070d <vprintfmt+0x27f>
	else if (lflag)
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	74 63                	je     800759 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fe:	99                   	cltd   
  8006ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
  80070b:	eb 17                	jmp    800724 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 50 04             	mov    0x4(%eax),%edx
  800713:	8b 00                	mov    (%eax),%eax
  800715:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800718:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8d 40 08             	lea    0x8(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800724:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800727:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80072a:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	0f 89 ff 00 00 00    	jns    800836 <vprintfmt+0x3a8>
				putch('-', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 2d                	push   $0x2d
  80073d:	ff d6                	call   *%esi
				num = -(long long) num;
  80073f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800742:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800745:	f7 da                	neg    %edx
  800747:	83 d1 00             	adc    $0x0,%ecx
  80074a:	f7 d9                	neg    %ecx
  80074c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80074f:	bf 0a 00 00 00       	mov    $0xa,%edi
  800754:	e9 dd 00 00 00       	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 00                	mov    (%eax),%eax
  80075e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800761:	99                   	cltd   
  800762:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
  80076e:	eb b4                	jmp    800724 <vprintfmt+0x296>
	if (lflag >= 2)
  800770:	83 f9 01             	cmp    $0x1,%ecx
  800773:	7f 1e                	jg     800793 <vprintfmt+0x305>
	else if (lflag)
  800775:	85 c9                	test   %ecx,%ecx
  800777:	74 32                	je     8007ab <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8b 10                	mov    (%eax),%edx
  80077e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800783:	8d 40 04             	lea    0x4(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800789:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80078e:	e9 a3 00 00 00       	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8b 10                	mov    (%eax),%edx
  800798:	8b 48 04             	mov    0x4(%eax),%ecx
  80079b:	8d 40 08             	lea    0x8(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007a1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007a6:	e9 8b 00 00 00       	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007bb:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8007c0:	eb 74                	jmp    800836 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8007c2:	83 f9 01             	cmp    $0x1,%ecx
  8007c5:	7f 1b                	jg     8007e2 <vprintfmt+0x354>
	else if (lflag)
  8007c7:	85 c9                	test   %ecx,%ecx
  8007c9:	74 2c                	je     8007f7 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d5:	8d 40 04             	lea    0x4(%eax),%eax
  8007d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007db:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8007e0:	eb 54                	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8b 10                	mov    (%eax),%edx
  8007e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ea:	8d 40 08             	lea    0x8(%eax),%eax
  8007ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007f0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8007f5:	eb 3f                	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800801:	8d 40 04             	lea    0x4(%eax),%eax
  800804:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800807:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80080c:	eb 28                	jmp    800836 <vprintfmt+0x3a8>
			putch('0', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	53                   	push   %ebx
  800812:	6a 30                	push   $0x30
  800814:	ff d6                	call   *%esi
			putch('x', putdat);
  800816:	83 c4 08             	add    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 78                	push   $0x78
  80081c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800828:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80082b:	8d 40 04             	lea    0x4(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800831:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800836:	83 ec 0c             	sub    $0xc,%esp
  800839:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	ff 75 e0             	push   -0x20(%ebp)
  800841:	57                   	push   %edi
  800842:	51                   	push   %ecx
  800843:	52                   	push   %edx
  800844:	89 da                	mov    %ebx,%edx
  800846:	89 f0                	mov    %esi,%eax
  800848:	e8 5e fb ff ff       	call   8003ab <printnum>
			break;
  80084d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800853:	e9 54 fc ff ff       	jmp    8004ac <vprintfmt+0x1e>
	if (lflag >= 2)
  800858:	83 f9 01             	cmp    $0x1,%ecx
  80085b:	7f 1b                	jg     800878 <vprintfmt+0x3ea>
	else if (lflag)
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	74 2c                	je     80088d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800871:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800876:	eb be                	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	8b 48 04             	mov    0x4(%eax),%ecx
  800880:	8d 40 08             	lea    0x8(%eax),%eax
  800883:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800886:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80088b:	eb a9                	jmp    800836 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 10                	mov    (%eax),%edx
  800892:	b9 00 00 00 00       	mov    $0x0,%ecx
  800897:	8d 40 04             	lea    0x4(%eax),%eax
  80089a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008a2:	eb 92                	jmp    800836 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	6a 25                	push   $0x25
  8008aa:	ff d6                	call   *%esi
			break;
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 9f                	jmp    800850 <vprintfmt+0x3c2>
			putch('%', putdat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 25                	push   $0x25
  8008b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	89 f8                	mov    %edi,%eax
  8008be:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008c2:	74 05                	je     8008c9 <vprintfmt+0x43b>
  8008c4:	83 e8 01             	sub    $0x1,%eax
  8008c7:	eb f5                	jmp    8008be <vprintfmt+0x430>
  8008c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008cc:	eb 82                	jmp    800850 <vprintfmt+0x3c2>

008008ce <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 18             	sub    $0x18,%esp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	74 26                	je     800915 <vsnprintf+0x47>
  8008ef:	85 d2                	test   %edx,%edx
  8008f1:	7e 22                	jle    800915 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f3:	ff 75 14             	push   0x14(%ebp)
  8008f6:	ff 75 10             	push   0x10(%ebp)
  8008f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fc:	50                   	push   %eax
  8008fd:	68 54 04 80 00       	push   $0x800454
  800902:	e8 87 fb ff ff       	call   80048e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800907:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800910:	83 c4 10             	add    $0x10,%esp
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    
		return -E_INVAL;
  800915:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80091a:	eb f7                	jmp    800913 <vsnprintf+0x45>

0080091c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800925:	50                   	push   %eax
  800926:	ff 75 10             	push   0x10(%ebp)
  800929:	ff 75 0c             	push   0xc(%ebp)
  80092c:	ff 75 08             	push   0x8(%ebp)
  80092f:	e8 9a ff ff ff       	call   8008ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	83 ec 0c             	sub    $0xc,%esp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800942:	85 c0                	test   %eax,%eax
  800944:	74 13                	je     800959 <readline+0x23>
		fprintf(1, "%s", prompt);
  800946:	83 ec 04             	sub    $0x4,%esp
  800949:	50                   	push   %eax
  80094a:	68 65 29 80 00       	push   $0x802965
  80094f:	6a 01                	push   $0x1
  800951:	e8 27 10 00 00       	call   80197d <fprintf>
  800956:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800959:	83 ec 0c             	sub    $0xc,%esp
  80095c:	6a 00                	push   $0x0
  80095e:	e8 78 f8 ff ff       	call   8001db <iscons>
  800963:	89 c7                	mov    %eax,%edi
  800965:	83 c4 10             	add    $0x10,%esp
	i = 0;
  800968:	be 00 00 00 00       	mov    $0x0,%esi
  80096d:	eb 4b                	jmp    8009ba <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  800974:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800977:	75 08                	jne    800981 <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800979:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    
				cprintf("read error: %e\n", c);
  800981:	83 ec 08             	sub    $0x8,%esp
  800984:	53                   	push   %ebx
  800985:	68 7f 28 80 00       	push   $0x80287f
  80098a:	e8 08 fa ff ff       	call   800397 <cprintf>
  80098f:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
  800997:	eb e0                	jmp    800979 <readline+0x43>
			if (echoing)
  800999:	85 ff                	test   %edi,%edi
  80099b:	75 05                	jne    8009a2 <readline+0x6c>
			i--;
  80099d:	83 ee 01             	sub    $0x1,%esi
  8009a0:	eb 18                	jmp    8009ba <readline+0x84>
				cputchar('\b');
  8009a2:	83 ec 0c             	sub    $0xc,%esp
  8009a5:	6a 08                	push   $0x8
  8009a7:	e8 ea f7 ff ff       	call   800196 <cputchar>
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	eb ec                	jmp    80099d <readline+0x67>
			buf[i++] = c;
  8009b1:	88 9e 20 40 80 00    	mov    %bl,0x804020(%esi)
  8009b7:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  8009ba:	e8 f3 f7 ff ff       	call   8001b2 <getchar>
  8009bf:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 aa                	js     80096f <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009c5:	83 f8 08             	cmp    $0x8,%eax
  8009c8:	0f 94 c0             	sete   %al
  8009cb:	83 fb 7f             	cmp    $0x7f,%ebx
  8009ce:	0f 94 c2             	sete   %dl
  8009d1:	08 d0                	or     %dl,%al
  8009d3:	74 04                	je     8009d9 <readline+0xa3>
  8009d5:	85 f6                	test   %esi,%esi
  8009d7:	7f c0                	jg     800999 <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009d9:	83 fb 1f             	cmp    $0x1f,%ebx
  8009dc:	7e 1a                	jle    8009f8 <readline+0xc2>
  8009de:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009e4:	7f 12                	jg     8009f8 <readline+0xc2>
			if (echoing)
  8009e6:	85 ff                	test   %edi,%edi
  8009e8:	74 c7                	je     8009b1 <readline+0x7b>
				cputchar(c);
  8009ea:	83 ec 0c             	sub    $0xc,%esp
  8009ed:	53                   	push   %ebx
  8009ee:	e8 a3 f7 ff ff       	call   800196 <cputchar>
  8009f3:	83 c4 10             	add    $0x10,%esp
  8009f6:	eb b9                	jmp    8009b1 <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  8009f8:	83 fb 0a             	cmp    $0xa,%ebx
  8009fb:	74 05                	je     800a02 <readline+0xcc>
  8009fd:	83 fb 0d             	cmp    $0xd,%ebx
  800a00:	75 b8                	jne    8009ba <readline+0x84>
			if (echoing)
  800a02:	85 ff                	test   %edi,%edi
  800a04:	75 11                	jne    800a17 <readline+0xe1>
			buf[i] = 0;
  800a06:	c6 86 20 40 80 00 00 	movb   $0x0,0x804020(%esi)
			return buf;
  800a0d:	b8 20 40 80 00       	mov    $0x804020,%eax
  800a12:	e9 62 ff ff ff       	jmp    800979 <readline+0x43>
				cputchar('\n');
  800a17:	83 ec 0c             	sub    $0xc,%esp
  800a1a:	6a 0a                	push   $0xa
  800a1c:	e8 75 f7 ff ff       	call   800196 <cputchar>
  800a21:	83 c4 10             	add    $0x10,%esp
  800a24:	eb e0                	jmp    800a06 <readline+0xd0>

00800a26 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 03                	jmp    800a36 <strlen+0x10>
		n++;
  800a33:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a36:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3a:	75 f7                	jne    800a33 <strlen+0xd>
	return n;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb 03                	jmp    800a51 <strnlen+0x13>
		n++;
  800a4e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a51:	39 d0                	cmp    %edx,%eax
  800a53:	74 08                	je     800a5d <strnlen+0x1f>
  800a55:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a59:	75 f3                	jne    800a4e <strnlen+0x10>
  800a5b:	89 c2                	mov    %eax,%edx
	return n;
}
  800a5d:	89 d0                	mov    %edx,%eax
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	53                   	push   %ebx
  800a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a74:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	84 d2                	test   %dl,%dl
  800a7c:	75 f2                	jne    800a70 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a7e:	89 c8                	mov    %ecx,%eax
  800a80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	83 ec 10             	sub    $0x10,%esp
  800a8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8f:	53                   	push   %ebx
  800a90:	e8 91 ff ff ff       	call   800a26 <strlen>
  800a95:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a98:	ff 75 0c             	push   0xc(%ebp)
  800a9b:	01 d8                	add    %ebx,%eax
  800a9d:	50                   	push   %eax
  800a9e:	e8 be ff ff ff       	call   800a61 <strcpy>
	return dst;
}
  800aa3:	89 d8                	mov    %ebx,%eax
  800aa5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aba:	89 f0                	mov    %esi,%eax
  800abc:	eb 0f                	jmp    800acd <strncpy+0x23>
		*dst++ = *src;
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	0f b6 0a             	movzbl (%edx),%ecx
  800ac4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac7:	80 f9 01             	cmp    $0x1,%cl
  800aca:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800acd:	39 d8                	cmp    %ebx,%eax
  800acf:	75 ed                	jne    800abe <strncpy+0x14>
	}
	return ret;
}
  800ad1:	89 f0                	mov    %esi,%eax
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 75 08             	mov    0x8(%ebp),%esi
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae7:	85 d2                	test   %edx,%edx
  800ae9:	74 21                	je     800b0c <strlcpy+0x35>
  800aeb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aef:	89 f2                	mov    %esi,%edx
  800af1:	eb 09                	jmp    800afc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	83 c2 01             	add    $0x1,%edx
  800af9:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800afc:	39 c2                	cmp    %eax,%edx
  800afe:	74 09                	je     800b09 <strlcpy+0x32>
  800b00:	0f b6 19             	movzbl (%ecx),%ebx
  800b03:	84 db                	test   %bl,%bl
  800b05:	75 ec                	jne    800af3 <strlcpy+0x1c>
  800b07:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b09:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0c:	29 f0                	sub    %esi,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b18:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1b:	eb 06                	jmp    800b23 <strcmp+0x11>
		p++, q++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
  800b20:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b23:	0f b6 01             	movzbl (%ecx),%eax
  800b26:	84 c0                	test   %al,%al
  800b28:	74 04                	je     800b2e <strcmp+0x1c>
  800b2a:	3a 02                	cmp    (%edx),%al
  800b2c:	74 ef                	je     800b1d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2e:	0f b6 c0             	movzbl %al,%eax
  800b31:	0f b6 12             	movzbl (%edx),%edx
  800b34:	29 d0                	sub    %edx,%eax
}
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	53                   	push   %ebx
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b47:	eb 06                	jmp    800b4f <strncmp+0x17>
		n--, p++, q++;
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b4f:	39 d8                	cmp    %ebx,%eax
  800b51:	74 18                	je     800b6b <strncmp+0x33>
  800b53:	0f b6 08             	movzbl (%eax),%ecx
  800b56:	84 c9                	test   %cl,%cl
  800b58:	74 04                	je     800b5e <strncmp+0x26>
  800b5a:	3a 0a                	cmp    (%edx),%cl
  800b5c:	74 eb                	je     800b49 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5e:	0f b6 00             	movzbl (%eax),%eax
  800b61:	0f b6 12             	movzbl (%edx),%edx
  800b64:	29 d0                	sub    %edx,%eax
}
  800b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    
		return 0;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	eb f4                	jmp    800b66 <strncmp+0x2e>

00800b72 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b7c:	eb 03                	jmp    800b81 <strchr+0xf>
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	0f b6 10             	movzbl (%eax),%edx
  800b84:	84 d2                	test   %dl,%dl
  800b86:	74 06                	je     800b8e <strchr+0x1c>
		if (*s == c)
  800b88:	38 ca                	cmp    %cl,%dl
  800b8a:	75 f2                	jne    800b7e <strchr+0xc>
  800b8c:	eb 05                	jmp    800b93 <strchr+0x21>
			return (char *) s;
	return 0;
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	74 09                	je     800baf <strfind+0x1a>
  800ba6:	84 d2                	test   %dl,%dl
  800ba8:	74 05                	je     800baf <strfind+0x1a>
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	eb f0                	jmp    800b9f <strfind+0xa>
			break;
	return (char *) s;
}
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bbd:	85 c9                	test   %ecx,%ecx
  800bbf:	74 2f                	je     800bf0 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc1:	89 f8                	mov    %edi,%eax
  800bc3:	09 c8                	or     %ecx,%eax
  800bc5:	a8 03                	test   $0x3,%al
  800bc7:	75 21                	jne    800bea <memset+0x39>
		c &= 0xFF;
  800bc9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	c1 e0 08             	shl    $0x8,%eax
  800bd2:	89 d3                	mov    %edx,%ebx
  800bd4:	c1 e3 18             	shl    $0x18,%ebx
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	c1 e6 10             	shl    $0x10,%esi
  800bdc:	09 f3                	or     %esi,%ebx
  800bde:	09 da                	or     %ebx,%edx
  800be0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800be2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800be5:	fc                   	cld    
  800be6:	f3 ab                	rep stos %eax,%es:(%edi)
  800be8:	eb 06                	jmp    800bf0 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	fc                   	cld    
  800bee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c05:	39 c6                	cmp    %eax,%esi
  800c07:	73 32                	jae    800c3b <memmove+0x44>
  800c09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0c:	39 c2                	cmp    %eax,%edx
  800c0e:	76 2b                	jbe    800c3b <memmove+0x44>
		s += n;
		d += n;
  800c10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	09 fe                	or     %edi,%esi
  800c17:	09 ce                	or     %ecx,%esi
  800c19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1f:	75 0e                	jne    800c2f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c21:	83 ef 04             	sub    $0x4,%edi
  800c24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c2a:	fd                   	std    
  800c2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2d:	eb 09                	jmp    800c38 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c35:	fd                   	std    
  800c36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c38:	fc                   	cld    
  800c39:	eb 1a                	jmp    800c55 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3b:	89 f2                	mov    %esi,%edx
  800c3d:	09 c2                	or     %eax,%edx
  800c3f:	09 ca                	or     %ecx,%edx
  800c41:	f6 c2 03             	test   $0x3,%dl
  800c44:	75 0a                	jne    800c50 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	fc                   	cld    
  800c4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4e:	eb 05                	jmp    800c55 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	fc                   	cld    
  800c53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5f:	ff 75 10             	push   0x10(%ebp)
  800c62:	ff 75 0c             	push   0xc(%ebp)
  800c65:	ff 75 08             	push   0x8(%ebp)
  800c68:	e8 8a ff ff ff       	call   800bf7 <memmove>
}
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7a:	89 c6                	mov    %eax,%esi
  800c7c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7f:	eb 06                	jmp    800c87 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c81:	83 c0 01             	add    $0x1,%eax
  800c84:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c87:	39 f0                	cmp    %esi,%eax
  800c89:	74 14                	je     800c9f <memcmp+0x30>
		if (*s1 != *s2)
  800c8b:	0f b6 08             	movzbl (%eax),%ecx
  800c8e:	0f b6 1a             	movzbl (%edx),%ebx
  800c91:	38 d9                	cmp    %bl,%cl
  800c93:	74 ec                	je     800c81 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c95:	0f b6 c1             	movzbl %cl,%eax
  800c98:	0f b6 db             	movzbl %bl,%ebx
  800c9b:	29 d8                	sub    %ebx,%eax
  800c9d:	eb 05                	jmp    800ca4 <memcmp+0x35>
	}

	return 0;
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb6:	eb 03                	jmp    800cbb <memfind+0x13>
  800cb8:	83 c0 01             	add    $0x1,%eax
  800cbb:	39 d0                	cmp    %edx,%eax
  800cbd:	73 04                	jae    800cc3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cbf:	38 08                	cmp    %cl,(%eax)
  800cc1:	75 f5                	jne    800cb8 <memfind+0x10>
			break;
	return (void *) s;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd1:	eb 03                	jmp    800cd6 <strtol+0x11>
		s++;
  800cd3:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800cd6:	0f b6 02             	movzbl (%edx),%eax
  800cd9:	3c 20                	cmp    $0x20,%al
  800cdb:	74 f6                	je     800cd3 <strtol+0xe>
  800cdd:	3c 09                	cmp    $0x9,%al
  800cdf:	74 f2                	je     800cd3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ce1:	3c 2b                	cmp    $0x2b,%al
  800ce3:	74 2a                	je     800d0f <strtol+0x4a>
	int neg = 0;
  800ce5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cea:	3c 2d                	cmp    $0x2d,%al
  800cec:	74 2b                	je     800d19 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf4:	75 0f                	jne    800d05 <strtol+0x40>
  800cf6:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf9:	74 28                	je     800d23 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d02:	0f 44 d8             	cmove  %eax,%ebx
  800d05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d0d:	eb 46                	jmp    800d55 <strtol+0x90>
		s++;
  800d0f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d12:	bf 00 00 00 00       	mov    $0x0,%edi
  800d17:	eb d5                	jmp    800cee <strtol+0x29>
		s++, neg = 1;
  800d19:	83 c2 01             	add    $0x1,%edx
  800d1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d21:	eb cb                	jmp    800cee <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d27:	74 0e                	je     800d37 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800d29:	85 db                	test   %ebx,%ebx
  800d2b:	75 d8                	jne    800d05 <strtol+0x40>
		s++, base = 8;
  800d2d:	83 c2 01             	add    $0x1,%edx
  800d30:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d35:	eb ce                	jmp    800d05 <strtol+0x40>
		s += 2, base = 16;
  800d37:	83 c2 02             	add    $0x2,%edx
  800d3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3f:	eb c4                	jmp    800d05 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d41:	0f be c0             	movsbl %al,%eax
  800d44:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d47:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d4a:	7d 3a                	jge    800d86 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d4c:	83 c2 01             	add    $0x1,%edx
  800d4f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800d53:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800d55:	0f b6 02             	movzbl (%edx),%eax
  800d58:	8d 70 d0             	lea    -0x30(%eax),%esi
  800d5b:	89 f3                	mov    %esi,%ebx
  800d5d:	80 fb 09             	cmp    $0x9,%bl
  800d60:	76 df                	jbe    800d41 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800d62:	8d 70 9f             	lea    -0x61(%eax),%esi
  800d65:	89 f3                	mov    %esi,%ebx
  800d67:	80 fb 19             	cmp    $0x19,%bl
  800d6a:	77 08                	ja     800d74 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800d6c:	0f be c0             	movsbl %al,%eax
  800d6f:	83 e8 57             	sub    $0x57,%eax
  800d72:	eb d3                	jmp    800d47 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800d74:	8d 70 bf             	lea    -0x41(%eax),%esi
  800d77:	89 f3                	mov    %esi,%ebx
  800d79:	80 fb 19             	cmp    $0x19,%bl
  800d7c:	77 08                	ja     800d86 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d7e:	0f be c0             	movsbl %al,%eax
  800d81:	83 e8 37             	sub    $0x37,%eax
  800d84:	eb c1                	jmp    800d47 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8a:	74 05                	je     800d91 <strtol+0xcc>
		*endptr = (char *) s;
  800d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d91:	89 c8                	mov    %ecx,%eax
  800d93:	f7 d8                	neg    %eax
  800d95:	85 ff                	test   %edi,%edi
  800d97:	0f 45 c8             	cmovne %eax,%ecx
}
  800d9a:	89 c8                	mov    %ecx,%eax
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	89 c3                	mov    %eax,%ebx
  800db4:	89 c7                	mov    %eax,%edi
  800db6:	89 c6                	mov    %eax,%esi
  800db8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dca:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d3                	mov    %edx,%ebx
  800dd3:	89 d7                	mov    %edx,%edi
  800dd5:	89 d6                	mov    %edx,%esi
  800dd7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	b8 03 00 00 00       	mov    $0x3,%eax
  800df4:	89 cb                	mov    %ecx,%ebx
  800df6:	89 cf                	mov    %ecx,%edi
  800df8:	89 ce                	mov    %ecx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7f 08                	jg     800e08 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	50                   	push   %eax
  800e0c:	6a 03                	push   $0x3
  800e0e:	68 8f 28 80 00       	push   $0x80288f
  800e13:	6a 2a                	push   $0x2a
  800e15:	68 ac 28 80 00       	push   $0x8028ac
  800e1a:	e8 9d f4 ff ff       	call   8002bc <_panic>

00800e1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e25:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e2f:	89 d1                	mov    %edx,%ecx
  800e31:	89 d3                	mov    %edx,%ebx
  800e33:	89 d7                	mov    %edx,%edi
  800e35:	89 d6                	mov    %edx,%esi
  800e37:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <sys_yield>:

void
sys_yield(void)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e44:	ba 00 00 00 00       	mov    $0x0,%edx
  800e49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e4e:	89 d1                	mov    %edx,%ecx
  800e50:	89 d3                	mov    %edx,%ebx
  800e52:	89 d7                	mov    %edx,%edi
  800e54:	89 d6                	mov    %edx,%esi
  800e56:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e66:	be 00 00 00 00       	mov    $0x0,%esi
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	b8 04 00 00 00       	mov    $0x4,%eax
  800e76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e79:	89 f7                	mov    %esi,%edi
  800e7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	7f 08                	jg     800e89 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 04                	push   $0x4
  800e8f:	68 8f 28 80 00       	push   $0x80288f
  800e94:	6a 2a                	push   $0x2a
  800e96:	68 ac 28 80 00       	push   $0x8028ac
  800e9b:	e8 1c f4 ff ff       	call   8002bc <_panic>

00800ea0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eba:	8b 75 18             	mov    0x18(%ebp),%esi
  800ebd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7f 08                	jg     800ecb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800ecf:	6a 05                	push   $0x5
  800ed1:	68 8f 28 80 00       	push   $0x80288f
  800ed6:	6a 2a                	push   $0x2a
  800ed8:	68 ac 28 80 00       	push   $0x8028ac
  800edd:	e8 da f3 ff ff       	call   8002bc <_panic>

00800ee2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  800efb:	89 df                	mov    %ebx,%edi
  800efd:	89 de                	mov    %ebx,%esi
  800eff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7f 08                	jg     800f0d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800f11:	6a 06                	push   $0x6
  800f13:	68 8f 28 80 00       	push   $0x80288f
  800f18:	6a 2a                	push   $0x2a
  800f1a:	68 ac 28 80 00       	push   $0x8028ac
  800f1f:	e8 98 f3 ff ff       	call   8002bc <_panic>

00800f24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800f38:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3d:	89 df                	mov    %ebx,%edi
  800f3f:	89 de                	mov    %ebx,%esi
  800f41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7f 08                	jg     800f4f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800f53:	6a 08                	push   $0x8
  800f55:	68 8f 28 80 00       	push   $0x80288f
  800f5a:	6a 2a                	push   $0x2a
  800f5c:	68 ac 28 80 00       	push   $0x8028ac
  800f61:	e8 56 f3 ff ff       	call   8002bc <_panic>

00800f66 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800f7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7f:	89 df                	mov    %ebx,%edi
  800f81:	89 de                	mov    %ebx,%esi
  800f83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7f 08                	jg     800f91 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800f95:	6a 09                	push   $0x9
  800f97:	68 8f 28 80 00       	push   $0x80288f
  800f9c:	6a 2a                	push   $0x2a
  800f9e:	68 ac 28 80 00       	push   $0x8028ac
  800fa3:	e8 14 f3 ff ff       	call   8002bc <_panic>

00800fa8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800fbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc1:	89 df                	mov    %ebx,%edi
  800fc3:	89 de                	mov    %ebx,%esi
  800fc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7f 08                	jg     800fd3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800fd7:	6a 0a                	push   $0xa
  800fd9:	68 8f 28 80 00       	push   $0x80288f
  800fde:	6a 2a                	push   $0x2a
  800fe0:	68 ac 28 80 00       	push   $0x8028ac
  800fe5:	e8 d2 f2 ff ff       	call   8002bc <_panic>

00800fea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ffb:	be 00 00 00 00       	mov    $0x0,%esi
  801000:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801003:	8b 7d 14             	mov    0x14(%ebp),%edi
  801006:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801016:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801023:	89 cb                	mov    %ecx,%ebx
  801025:	89 cf                	mov    %ecx,%edi
  801027:	89 ce                	mov    %ecx,%esi
  801029:	cd 30                	int    $0x30
	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7f 08                	jg     801037 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801032:	5b                   	pop    %ebx
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	50                   	push   %eax
  80103b:	6a 0d                	push   $0xd
  80103d:	68 8f 28 80 00       	push   $0x80288f
  801042:	6a 2a                	push   $0x2a
  801044:	68 ac 28 80 00       	push   $0x8028ac
  801049:	e8 6e f2 ff ff       	call   8002bc <_panic>

0080104e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
	asm volatile("int %1\n"
  801054:	ba 00 00 00 00       	mov    $0x0,%edx
  801059:	b8 0e 00 00 00       	mov    $0xe,%eax
  80105e:	89 d1                	mov    %edx,%ecx
  801060:	89 d3                	mov    %edx,%ebx
  801062:	89 d7                	mov    %edx,%edi
  801064:	89 d6                	mov    %edx,%esi
  801066:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
	asm volatile("int %1\n"
  801073:	bb 00 00 00 00       	mov    $0x0,%ebx
  801078:	8b 55 08             	mov    0x8(%ebp),%edx
  80107b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801083:	89 df                	mov    %ebx,%edi
  801085:	89 de                	mov    %ebx,%esi
  801087:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801089:	5b                   	pop    %ebx
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
	asm volatile("int %1\n"
  801094:	bb 00 00 00 00       	mov    $0x0,%ebx
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	b8 10 00 00 00       	mov    $0x10,%eax
  8010a4:	89 df                	mov    %ebx,%edi
  8010a6:	89 de                	mov    %ebx,%esi
  8010a8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ba:	c1 e8 0c             	shr    $0xc,%eax
}
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010cf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	c1 ea 16             	shr    $0x16,%edx
  8010e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	74 29                	je     801118 <fd_alloc+0x42>
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	c1 ea 0c             	shr    $0xc,%edx
  8010f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fb:	f6 c2 01             	test   $0x1,%dl
  8010fe:	74 18                	je     801118 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801100:	05 00 10 00 00       	add    $0x1000,%eax
  801105:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110a:	75 d2                	jne    8010de <fd_alloc+0x8>
  80110c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801111:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801116:	eb 05                	jmp    80111d <fd_alloc+0x47>
			return 0;
  801118:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
  801120:	89 02                	mov    %eax,(%edx)
}
  801122:	89 c8                	mov    %ecx,%eax
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80112c:	83 f8 1f             	cmp    $0x1f,%eax
  80112f:	77 30                	ja     801161 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801131:	c1 e0 0c             	shl    $0xc,%eax
  801134:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801139:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 24                	je     801168 <fd_lookup+0x42>
  801144:	89 c2                	mov    %eax,%edx
  801146:	c1 ea 0c             	shr    $0xc,%edx
  801149:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	74 1a                	je     80116f <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801155:	8b 55 0c             	mov    0xc(%ebp),%edx
  801158:	89 02                	mov    %eax,(%edx)
	return 0;
  80115a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    
		return -E_INVAL;
  801161:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801166:	eb f7                	jmp    80115f <fd_lookup+0x39>
		return -E_INVAL;
  801168:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116d:	eb f0                	jmp    80115f <fd_lookup+0x39>
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801174:	eb e9                	jmp    80115f <fd_lookup+0x39>

00801176 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	53                   	push   %ebx
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801180:	b8 00 00 00 00       	mov    $0x0,%eax
  801185:	bb 20 30 80 00       	mov    $0x803020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80118a:	39 13                	cmp    %edx,(%ebx)
  80118c:	74 37                	je     8011c5 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80118e:	83 c0 01             	add    $0x1,%eax
  801191:	8b 1c 85 38 29 80 00 	mov    0x802938(,%eax,4),%ebx
  801198:	85 db                	test   %ebx,%ebx
  80119a:	75 ee                	jne    80118a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80119c:	a1 00 40 80 00       	mov    0x804000,%eax
  8011a1:	8b 40 58             	mov    0x58(%eax),%eax
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	52                   	push   %edx
  8011a8:	50                   	push   %eax
  8011a9:	68 bc 28 80 00       	push   $0x8028bc
  8011ae:	e8 e4 f1 ff ff       	call   800397 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8011bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011be:	89 1a                	mov    %ebx,(%edx)
}
  8011c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c3:	c9                   	leave  
  8011c4:	c3                   	ret    
			return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	eb ef                	jmp    8011bb <dev_lookup+0x45>

008011cc <fd_close>:
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 24             	sub    $0x24,%esp
  8011d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011de:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e8:	50                   	push   %eax
  8011e9:	e8 38 ff ff ff       	call   801126 <fd_lookup>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 05                	js     8011fc <fd_close+0x30>
	    || fd != fd2)
  8011f7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011fa:	74 16                	je     801212 <fd_close+0x46>
		return (must_exist ? r : 0);
  8011fc:	89 f8                	mov    %edi,%eax
  8011fe:	84 c0                	test   %al,%al
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
  801205:	0f 44 d8             	cmove  %eax,%ebx
}
  801208:	89 d8                	mov    %ebx,%eax
  80120a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5f                   	pop    %edi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	ff 36                	push   (%esi)
  80121b:	e8 56 ff ff ff       	call   801176 <dev_lookup>
  801220:	89 c3                	mov    %eax,%ebx
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 1a                	js     801243 <fd_close+0x77>
		if (dev->dev_close)
  801229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80122c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80122f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801234:	85 c0                	test   %eax,%eax
  801236:	74 0b                	je     801243 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	56                   	push   %esi
  80123c:	ff d0                	call   *%eax
  80123e:	89 c3                	mov    %eax,%ebx
  801240:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	56                   	push   %esi
  801247:	6a 00                	push   $0x0
  801249:	e8 94 fc ff ff       	call   800ee2 <sys_page_unmap>
	return r;
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	eb b5                	jmp    801208 <fd_close+0x3c>

00801253 <close>:

int
close(int fdnum)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	push   0x8(%ebp)
  801260:	e8 c1 fe ff ff       	call   801126 <fd_lookup>
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	79 02                	jns    80126e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    
		return fd_close(fd, 1);
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	6a 01                	push   $0x1
  801273:	ff 75 f4             	push   -0xc(%ebp)
  801276:	e8 51 ff ff ff       	call   8011cc <fd_close>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	eb ec                	jmp    80126c <close+0x19>

00801280 <close_all>:

void
close_all(void)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	53                   	push   %ebx
  801284:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	53                   	push   %ebx
  801290:	e8 be ff ff ff       	call   801253 <close>
	for (i = 0; i < MAXFD; i++)
  801295:	83 c3 01             	add    $0x1,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	83 fb 20             	cmp    $0x20,%ebx
  80129e:	75 ec                	jne    80128c <close_all+0xc>
}
  8012a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	57                   	push   %edi
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 08             	push   0x8(%ebp)
  8012b5:	e8 6c fe ff ff       	call   801126 <fd_lookup>
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 7f                	js     801342 <dup+0x9d>
		return r;
	close(newfdnum);
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	ff 75 0c             	push   0xc(%ebp)
  8012c9:	e8 85 ff ff ff       	call   801253 <close>

	newfd = INDEX2FD(newfdnum);
  8012ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d1:	c1 e6 0c             	shl    $0xc,%esi
  8012d4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012dd:	89 3c 24             	mov    %edi,(%esp)
  8012e0:	e8 da fd ff ff       	call   8010bf <fd2data>
  8012e5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012e7:	89 34 24             	mov    %esi,(%esp)
  8012ea:	e8 d0 fd ff ff       	call   8010bf <fd2data>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f5:	89 d8                	mov    %ebx,%eax
  8012f7:	c1 e8 16             	shr    $0x16,%eax
  8012fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801301:	a8 01                	test   $0x1,%al
  801303:	74 11                	je     801316 <dup+0x71>
  801305:	89 d8                	mov    %ebx,%eax
  801307:	c1 e8 0c             	shr    $0xc,%eax
  80130a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801311:	f6 c2 01             	test   $0x1,%dl
  801314:	75 36                	jne    80134c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801316:	89 f8                	mov    %edi,%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	25 07 0e 00 00       	and    $0xe07,%eax
  80132a:	50                   	push   %eax
  80132b:	56                   	push   %esi
  80132c:	6a 00                	push   $0x0
  80132e:	57                   	push   %edi
  80132f:	6a 00                	push   $0x0
  801331:	e8 6a fb ff ff       	call   800ea0 <sys_page_map>
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 20             	add    $0x20,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 33                	js     801372 <dup+0xcd>
		goto err;

	return newfdnum;
  80133f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801342:	89 d8                	mov    %ebx,%eax
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	25 07 0e 00 00       	and    $0xe07,%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 d4             	push   -0x2c(%ebp)
  80135f:	6a 00                	push   $0x0
  801361:	53                   	push   %ebx
  801362:	6a 00                	push   $0x0
  801364:	e8 37 fb ff ff       	call   800ea0 <sys_page_map>
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	79 a4                	jns    801316 <dup+0x71>
	sys_page_unmap(0, newfd);
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	56                   	push   %esi
  801376:	6a 00                	push   $0x0
  801378:	e8 65 fb ff ff       	call   800ee2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137d:	83 c4 08             	add    $0x8,%esp
  801380:	ff 75 d4             	push   -0x2c(%ebp)
  801383:	6a 00                	push   $0x0
  801385:	e8 58 fb ff ff       	call   800ee2 <sys_page_unmap>
	return r;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb b3                	jmp    801342 <dup+0x9d>

0080138f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 18             	sub    $0x18,%esp
  801397:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	56                   	push   %esi
  80139f:	e8 82 fd ff ff       	call   801126 <fd_lookup>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 3c                	js     8013e7 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	ff 33                	push   (%ebx)
  8013b7:	e8 ba fd ff ff       	call   801176 <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 24                	js     8013e7 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c3:	8b 43 08             	mov    0x8(%ebx),%eax
  8013c6:	83 e0 03             	and    $0x3,%eax
  8013c9:	83 f8 01             	cmp    $0x1,%eax
  8013cc:	74 20                	je     8013ee <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d1:	8b 40 08             	mov    0x8(%eax),%eax
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	74 37                	je     80140f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	ff 75 10             	push   0x10(%ebp)
  8013de:	ff 75 0c             	push   0xc(%ebp)
  8013e1:	53                   	push   %ebx
  8013e2:	ff d0                	call   *%eax
  8013e4:	83 c4 10             	add    $0x10,%esp
}
  8013e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8013f3:	8b 40 58             	mov    0x58(%eax),%eax
  8013f6:	83 ec 04             	sub    $0x4,%esp
  8013f9:	56                   	push   %esi
  8013fa:	50                   	push   %eax
  8013fb:	68 fd 28 80 00       	push   $0x8028fd
  801400:	e8 92 ef ff ff       	call   800397 <cprintf>
		return -E_INVAL;
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140d:	eb d8                	jmp    8013e7 <read+0x58>
		return -E_NOT_SUPP;
  80140f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801414:	eb d1                	jmp    8013e7 <read+0x58>

00801416 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	53                   	push   %ebx
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801422:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801425:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142a:	eb 02                	jmp    80142e <readn+0x18>
  80142c:	01 c3                	add    %eax,%ebx
  80142e:	39 f3                	cmp    %esi,%ebx
  801430:	73 21                	jae    801453 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	89 f0                	mov    %esi,%eax
  801437:	29 d8                	sub    %ebx,%eax
  801439:	50                   	push   %eax
  80143a:	89 d8                	mov    %ebx,%eax
  80143c:	03 45 0c             	add    0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	57                   	push   %edi
  801441:	e8 49 ff ff ff       	call   80138f <read>
		if (m < 0)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 04                	js     801451 <readn+0x3b>
			return m;
		if (m == 0)
  80144d:	75 dd                	jne    80142c <readn+0x16>
  80144f:	eb 02                	jmp    801453 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801451:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801453:	89 d8                	mov    %ebx,%eax
  801455:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5f                   	pop    %edi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
  801462:	83 ec 18             	sub    $0x18,%esp
  801465:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801468:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	53                   	push   %ebx
  80146d:	e8 b4 fc ff ff       	call   801126 <fd_lookup>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 37                	js     8014b0 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801479:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	ff 36                	push   (%esi)
  801485:	e8 ec fc ff ff       	call   801176 <dev_lookup>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 1f                	js     8014b0 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801491:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801495:	74 20                	je     8014b7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801497:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149a:	8b 40 0c             	mov    0xc(%eax),%eax
  80149d:	85 c0                	test   %eax,%eax
  80149f:	74 37                	je     8014d8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	ff 75 10             	push   0x10(%ebp)
  8014a7:	ff 75 0c             	push   0xc(%ebp)
  8014aa:	56                   	push   %esi
  8014ab:	ff d0                	call   *%eax
  8014ad:	83 c4 10             	add    $0x10,%esp
}
  8014b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b7:	a1 00 40 80 00       	mov    0x804000,%eax
  8014bc:	8b 40 58             	mov    0x58(%eax),%eax
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	53                   	push   %ebx
  8014c3:	50                   	push   %eax
  8014c4:	68 19 29 80 00       	push   $0x802919
  8014c9:	e8 c9 ee ff ff       	call   800397 <cprintf>
		return -E_INVAL;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d6:	eb d8                	jmp    8014b0 <write+0x53>
		return -E_NOT_SUPP;
  8014d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014dd:	eb d1                	jmp    8014b0 <write+0x53>

008014df <seek>:

int
seek(int fdnum, off_t offset)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	ff 75 08             	push   0x8(%ebp)
  8014ec:	e8 35 fc ff ff       	call   801126 <fd_lookup>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 0e                	js     801506 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 18             	sub    $0x18,%esp
  801510:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801513:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	53                   	push   %ebx
  801518:	e8 09 fc ff ff       	call   801126 <fd_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 34                	js     801558 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801524:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801527:	83 ec 08             	sub    $0x8,%esp
  80152a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	ff 36                	push   (%esi)
  801530:	e8 41 fc ff ff       	call   801176 <dev_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 1c                	js     801558 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801540:	74 1d                	je     80155f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801545:	8b 40 18             	mov    0x18(%eax),%eax
  801548:	85 c0                	test   %eax,%eax
  80154a:	74 34                	je     801580 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	ff 75 0c             	push   0xc(%ebp)
  801552:	56                   	push   %esi
  801553:	ff d0                	call   *%eax
  801555:	83 c4 10             	add    $0x10,%esp
}
  801558:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5e                   	pop    %esi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80155f:	a1 00 40 80 00       	mov    0x804000,%eax
  801564:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	53                   	push   %ebx
  80156b:	50                   	push   %eax
  80156c:	68 dc 28 80 00       	push   $0x8028dc
  801571:	e8 21 ee ff ff       	call   800397 <cprintf>
		return -E_INVAL;
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157e:	eb d8                	jmp    801558 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801580:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801585:	eb d1                	jmp    801558 <ftruncate+0x50>

00801587 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	83 ec 18             	sub    $0x18,%esp
  80158f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801592:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	ff 75 08             	push   0x8(%ebp)
  801599:	e8 88 fb ff ff       	call   801126 <fd_lookup>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 49                	js     8015ee <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	ff 36                	push   (%esi)
  8015b1:	e8 c0 fb ff ff       	call   801176 <dev_lookup>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 31                	js     8015ee <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c4:	74 2f                	je     8015f5 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d0:	00 00 00 
	stat->st_isdir = 0;
  8015d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015da:	00 00 00 
	stat->st_dev = dev;
  8015dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	56                   	push   %esi
  8015e8:	ff 50 14             	call   *0x14(%eax)
  8015eb:	83 c4 10             	add    $0x10,%esp
}
  8015ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    
		return -E_NOT_SUPP;
  8015f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015fa:	eb f2                	jmp    8015ee <fstat+0x67>

008015fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	6a 00                	push   $0x0
  801606:	ff 75 08             	push   0x8(%ebp)
  801609:	e8 e4 01 00 00       	call   8017f2 <open>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 1b                	js     801632 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	ff 75 0c             	push   0xc(%ebp)
  80161d:	50                   	push   %eax
  80161e:	e8 64 ff ff ff       	call   801587 <fstat>
  801623:	89 c6                	mov    %eax,%esi
	close(fd);
  801625:	89 1c 24             	mov    %ebx,(%esp)
  801628:	e8 26 fc ff ff       	call   801253 <close>
	return r;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	89 f3                	mov    %esi,%ebx
}
  801632:	89 d8                	mov    %ebx,%eax
  801634:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801637:	5b                   	pop    %ebx
  801638:	5e                   	pop    %esi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	89 c6                	mov    %eax,%esi
  801642:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801644:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80164b:	74 27                	je     801674 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164d:	6a 07                	push   $0x7
  80164f:	68 00 50 80 00       	push   $0x805000
  801654:	56                   	push   %esi
  801655:	ff 35 00 60 80 00    	push   0x806000
  80165b:	e8 6c 0b 00 00       	call   8021cc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801660:	83 c4 0c             	add    $0xc,%esp
  801663:	6a 00                	push   $0x0
  801665:	53                   	push   %ebx
  801666:	6a 00                	push   $0x0
  801668:	e8 ef 0a 00 00       	call   80215c <ipc_recv>
}
  80166d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801674:	83 ec 0c             	sub    $0xc,%esp
  801677:	6a 01                	push   $0x1
  801679:	e8 a2 0b 00 00       	call   802220 <ipc_find_env>
  80167e:	a3 00 60 80 00       	mov    %eax,0x806000
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb c5                	jmp    80164d <fsipc+0x12>

00801688 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	8b 40 0c             	mov    0xc(%eax),%eax
  801694:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ab:	e8 8b ff ff ff       	call   80163b <fsipc>
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <devfile_flush>:
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8016cd:	e8 69 ff ff ff       	call   80163b <fsipc>
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <devfile_stat>:
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f3:	e8 43 ff ff ff       	call   80163b <fsipc>
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 2c                	js     801728 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	68 00 50 80 00       	push   $0x805000
  801704:	53                   	push   %ebx
  801705:	e8 57 f3 ff ff       	call   800a61 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170a:	a1 80 50 80 00       	mov    0x805080,%eax
  80170f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801715:	a1 84 50 80 00       	mov    0x805084,%eax
  80171a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <devfile_write>:
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	8b 45 10             	mov    0x10(%ebp),%eax
  801736:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80173b:	39 d0                	cmp    %edx,%eax
  80173d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801740:	8b 55 08             	mov    0x8(%ebp),%edx
  801743:	8b 52 0c             	mov    0xc(%edx),%edx
  801746:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80174c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801751:	50                   	push   %eax
  801752:	ff 75 0c             	push   0xc(%ebp)
  801755:	68 08 50 80 00       	push   $0x805008
  80175a:	e8 98 f4 ff ff       	call   800bf7 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80175f:	ba 00 00 00 00       	mov    $0x0,%edx
  801764:	b8 04 00 00 00       	mov    $0x4,%eax
  801769:	e8 cd fe ff ff       	call   80163b <fsipc>
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_read>:
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 40 0c             	mov    0xc(%eax),%eax
  80177e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801783:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 03 00 00 00       	mov    $0x3,%eax
  801793:	e8 a3 fe ff ff       	call   80163b <fsipc>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 1f                	js     8017bd <devfile_read+0x4d>
	assert(r <= n);
  80179e:	39 f0                	cmp    %esi,%eax
  8017a0:	77 24                	ja     8017c6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a7:	7f 33                	jg     8017dc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a9:	83 ec 04             	sub    $0x4,%esp
  8017ac:	50                   	push   %eax
  8017ad:	68 00 50 80 00       	push   $0x805000
  8017b2:	ff 75 0c             	push   0xc(%ebp)
  8017b5:	e8 3d f4 ff ff       	call   800bf7 <memmove>
	return r;
  8017ba:	83 c4 10             	add    $0x10,%esp
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    
	assert(r <= n);
  8017c6:	68 4c 29 80 00       	push   $0x80294c
  8017cb:	68 53 29 80 00       	push   $0x802953
  8017d0:	6a 7c                	push   $0x7c
  8017d2:	68 68 29 80 00       	push   $0x802968
  8017d7:	e8 e0 ea ff ff       	call   8002bc <_panic>
	assert(r <= PGSIZE);
  8017dc:	68 73 29 80 00       	push   $0x802973
  8017e1:	68 53 29 80 00       	push   $0x802953
  8017e6:	6a 7d                	push   $0x7d
  8017e8:	68 68 29 80 00       	push   $0x802968
  8017ed:	e8 ca ea ff ff       	call   8002bc <_panic>

008017f2 <open>:
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 1c             	sub    $0x1c,%esp
  8017fa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017fd:	56                   	push   %esi
  8017fe:	e8 23 f2 ff ff       	call   800a26 <strlen>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80180b:	7f 6c                	jg     801879 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801813:	50                   	push   %eax
  801814:	e8 bd f8 ff ff       	call   8010d6 <fd_alloc>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 3c                	js     80185e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801822:	83 ec 08             	sub    $0x8,%esp
  801825:	56                   	push   %esi
  801826:	68 00 50 80 00       	push   $0x805000
  80182b:	e8 31 f2 ff ff       	call   800a61 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801830:	8b 45 0c             	mov    0xc(%ebp),%eax
  801833:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801838:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183b:	b8 01 00 00 00       	mov    $0x1,%eax
  801840:	e8 f6 fd ff ff       	call   80163b <fsipc>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 19                	js     801867 <open+0x75>
	return fd2num(fd);
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	ff 75 f4             	push   -0xc(%ebp)
  801854:	e8 56 f8 ff ff       	call   8010af <fd2num>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	83 c4 10             	add    $0x10,%esp
}
  80185e:	89 d8                	mov    %ebx,%eax
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    
		fd_close(fd, 0);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	6a 00                	push   $0x0
  80186c:	ff 75 f4             	push   -0xc(%ebp)
  80186f:	e8 58 f9 ff ff       	call   8011cc <fd_close>
		return r;
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	eb e5                	jmp    80185e <open+0x6c>
		return -E_BAD_PATH;
  801879:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80187e:	eb de                	jmp    80185e <open+0x6c>

00801880 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801886:	ba 00 00 00 00       	mov    $0x0,%edx
  80188b:	b8 08 00 00 00       	mov    $0x8,%eax
  801890:	e8 a6 fd ff ff       	call   80163b <fsipc>
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801897:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80189b:	7f 01                	jg     80189e <writebuf+0x7>
  80189d:	c3                   	ret    
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018a7:	ff 70 04             	push   0x4(%eax)
  8018aa:	8d 40 10             	lea    0x10(%eax),%eax
  8018ad:	50                   	push   %eax
  8018ae:	ff 33                	push   (%ebx)
  8018b0:	e8 a8 fb ff ff       	call   80145d <write>
		if (result > 0)
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	7e 03                	jle    8018bf <writebuf+0x28>
			b->result += result;
  8018bc:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018bf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018c2:	74 0d                	je     8018d1 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	0f 4f c2             	cmovg  %edx,%eax
  8018ce:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <putch>:

static void
putch(int ch, void *thunk)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018e0:	8b 53 04             	mov    0x4(%ebx),%edx
  8018e3:	8d 42 01             	lea    0x1(%edx),%eax
  8018e6:	89 43 04             	mov    %eax,0x4(%ebx)
  8018e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ec:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018f0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018f5:	74 05                	je     8018fc <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8018f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    
		writebuf(b);
  8018fc:	89 d8                	mov    %ebx,%eax
  8018fe:	e8 94 ff ff ff       	call   801897 <writebuf>
		b->idx = 0;
  801903:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80190a:	eb eb                	jmp    8018f7 <putch+0x21>

0080190c <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80191e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801925:	00 00 00 
	b.result = 0;
  801928:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80192f:	00 00 00 
	b.error = 1;
  801932:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801939:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80193c:	ff 75 10             	push   0x10(%ebp)
  80193f:	ff 75 0c             	push   0xc(%ebp)
  801942:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	68 d6 18 80 00       	push   $0x8018d6
  80194e:	e8 3b eb ff ff       	call   80048e <vprintfmt>
	if (b.idx > 0)
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80195d:	7f 11                	jg     801970 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80195f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801965:	85 c0                	test   %eax,%eax
  801967:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    
		writebuf(&b);
  801970:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801976:	e8 1c ff ff ff       	call   801897 <writebuf>
  80197b:	eb e2                	jmp    80195f <vfprintf+0x53>

0080197d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801983:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801986:	50                   	push   %eax
  801987:	ff 75 0c             	push   0xc(%ebp)
  80198a:	ff 75 08             	push   0x8(%ebp)
  80198d:	e8 7a ff ff ff       	call   80190c <vfprintf>
	va_end(ap);

	return cnt;
}
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <printf>:

int
printf(const char *fmt, ...)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80199a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80199d:	50                   	push   %eax
  80199e:	ff 75 08             	push   0x8(%ebp)
  8019a1:	6a 01                	push   $0x1
  8019a3:	e8 64 ff ff ff       	call   80190c <vfprintf>
	va_end(ap);

	return cnt;
}
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019b0:	68 7f 29 80 00       	push   $0x80297f
  8019b5:	ff 75 0c             	push   0xc(%ebp)
  8019b8:	e8 a4 f0 ff ff       	call   800a61 <strcpy>
	return 0;
}
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devsock_close>:
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 10             	sub    $0x10,%esp
  8019cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019ce:	53                   	push   %ebx
  8019cf:	e8 8b 08 00 00       	call   80225f <pageref>
  8019d4:	89 c2                	mov    %eax,%edx
  8019d6:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019de:	83 fa 01             	cmp    $0x1,%edx
  8019e1:	74 05                	je     8019e8 <devsock_close+0x24>
}
  8019e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	ff 73 0c             	push   0xc(%ebx)
  8019ee:	e8 b7 02 00 00       	call   801caa <nsipc_close>
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	eb eb                	jmp    8019e3 <devsock_close+0x1f>

008019f8 <devsock_write>:
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019fe:	6a 00                	push   $0x0
  801a00:	ff 75 10             	push   0x10(%ebp)
  801a03:	ff 75 0c             	push   0xc(%ebp)
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	ff 70 0c             	push   0xc(%eax)
  801a0c:	e8 79 03 00 00       	call   801d8a <nsipc_send>
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <devsock_read>:
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a19:	6a 00                	push   $0x0
  801a1b:	ff 75 10             	push   0x10(%ebp)
  801a1e:	ff 75 0c             	push   0xc(%ebp)
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	ff 70 0c             	push   0xc(%eax)
  801a27:	e8 ef 02 00 00       	call   801d1b <nsipc_recv>
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <fd2sockid>:
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a34:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a37:	52                   	push   %edx
  801a38:	50                   	push   %eax
  801a39:	e8 e8 f6 ff ff       	call   801126 <fd_lookup>
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 10                	js     801a55 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a48:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a4e:	39 08                	cmp    %ecx,(%eax)
  801a50:	75 05                	jne    801a57 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a52:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    
		return -E_NOT_SUPP;
  801a57:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a5c:	eb f7                	jmp    801a55 <fd2sockid+0x27>

00801a5e <alloc_sockfd>:
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 1c             	sub    $0x1c,%esp
  801a66:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6b:	50                   	push   %eax
  801a6c:	e8 65 f6 ff ff       	call   8010d6 <fd_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 43                	js     801abd <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	68 07 04 00 00       	push   $0x407
  801a82:	ff 75 f4             	push   -0xc(%ebp)
  801a85:	6a 00                	push   $0x0
  801a87:	e8 d1 f3 ff ff       	call   800e5d <sys_page_alloc>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 28                	js     801abd <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a98:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a9e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aaa:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	50                   	push   %eax
  801ab1:	e8 f9 f5 ff ff       	call   8010af <fd2num>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	eb 0c                	jmp    801ac9 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	56                   	push   %esi
  801ac1:	e8 e4 01 00 00       	call   801caa <nsipc_close>
		return r;
  801ac6:	83 c4 10             	add    $0x10,%esp
}
  801ac9:	89 d8                	mov    %ebx,%eax
  801acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <accept>:
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	e8 4e ff ff ff       	call   801a2e <fd2sockid>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 1b                	js     801aff <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	ff 75 10             	push   0x10(%ebp)
  801aea:	ff 75 0c             	push   0xc(%ebp)
  801aed:	50                   	push   %eax
  801aee:	e8 0e 01 00 00       	call   801c01 <nsipc_accept>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 05                	js     801aff <accept+0x2d>
	return alloc_sockfd(r);
  801afa:	e8 5f ff ff ff       	call   801a5e <alloc_sockfd>
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <bind>:
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	e8 1f ff ff ff       	call   801a2e <fd2sockid>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 12                	js     801b25 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b13:	83 ec 04             	sub    $0x4,%esp
  801b16:	ff 75 10             	push   0x10(%ebp)
  801b19:	ff 75 0c             	push   0xc(%ebp)
  801b1c:	50                   	push   %eax
  801b1d:	e8 31 01 00 00       	call   801c53 <nsipc_bind>
  801b22:	83 c4 10             	add    $0x10,%esp
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <shutdown>:
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	e8 f9 fe ff ff       	call   801a2e <fd2sockid>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 0f                	js     801b48 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b39:	83 ec 08             	sub    $0x8,%esp
  801b3c:	ff 75 0c             	push   0xc(%ebp)
  801b3f:	50                   	push   %eax
  801b40:	e8 43 01 00 00       	call   801c88 <nsipc_shutdown>
  801b45:	83 c4 10             	add    $0x10,%esp
}
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <connect>:
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	e8 d6 fe ff ff       	call   801a2e <fd2sockid>
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	78 12                	js     801b6e <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b5c:	83 ec 04             	sub    $0x4,%esp
  801b5f:	ff 75 10             	push   0x10(%ebp)
  801b62:	ff 75 0c             	push   0xc(%ebp)
  801b65:	50                   	push   %eax
  801b66:	e8 59 01 00 00       	call   801cc4 <nsipc_connect>
  801b6b:	83 c4 10             	add    $0x10,%esp
}
  801b6e:	c9                   	leave  
  801b6f:	c3                   	ret    

00801b70 <listen>:
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	e8 b0 fe ff ff       	call   801a2e <fd2sockid>
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 0f                	js     801b91 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b82:	83 ec 08             	sub    $0x8,%esp
  801b85:	ff 75 0c             	push   0xc(%ebp)
  801b88:	50                   	push   %eax
  801b89:	e8 6b 01 00 00       	call   801cf9 <nsipc_listen>
  801b8e:	83 c4 10             	add    $0x10,%esp
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b99:	ff 75 10             	push   0x10(%ebp)
  801b9c:	ff 75 0c             	push   0xc(%ebp)
  801b9f:	ff 75 08             	push   0x8(%ebp)
  801ba2:	e8 41 02 00 00       	call   801de8 <nsipc_socket>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 05                	js     801bb3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bae:	e8 ab fe ff ff       	call   801a5e <alloc_sockfd>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 04             	sub    $0x4,%esp
  801bbc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bbe:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bc5:	74 26                	je     801bed <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc7:	6a 07                	push   $0x7
  801bc9:	68 00 70 80 00       	push   $0x807000
  801bce:	53                   	push   %ebx
  801bcf:	ff 35 00 80 80 00    	push   0x808000
  801bd5:	e8 f2 05 00 00       	call   8021cc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bda:	83 c4 0c             	add    $0xc,%esp
  801bdd:	6a 00                	push   $0x0
  801bdf:	6a 00                	push   $0x0
  801be1:	6a 00                	push   $0x0
  801be3:	e8 74 05 00 00       	call   80215c <ipc_recv>
}
  801be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	6a 02                	push   $0x2
  801bf2:	e8 29 06 00 00       	call   802220 <ipc_find_env>
  801bf7:	a3 00 80 80 00       	mov    %eax,0x808000
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	eb c6                	jmp    801bc7 <nsipc+0x12>

00801c01 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	56                   	push   %esi
  801c05:	53                   	push   %ebx
  801c06:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c11:	8b 06                	mov    (%esi),%eax
  801c13:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c18:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1d:	e8 93 ff ff ff       	call   801bb5 <nsipc>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	85 c0                	test   %eax,%eax
  801c26:	79 09                	jns    801c31 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	ff 35 10 70 80 00    	push   0x807010
  801c3a:	68 00 70 80 00       	push   $0x807000
  801c3f:	ff 75 0c             	push   0xc(%ebp)
  801c42:	e8 b0 ef ff ff       	call   800bf7 <memmove>
		*addrlen = ret->ret_addrlen;
  801c47:	a1 10 70 80 00       	mov    0x807010,%eax
  801c4c:	89 06                	mov    %eax,(%esi)
  801c4e:	83 c4 10             	add    $0x10,%esp
	return r;
  801c51:	eb d5                	jmp    801c28 <nsipc_accept+0x27>

00801c53 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	53                   	push   %ebx
  801c57:	83 ec 08             	sub    $0x8,%esp
  801c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c65:	53                   	push   %ebx
  801c66:	ff 75 0c             	push   0xc(%ebp)
  801c69:	68 04 70 80 00       	push   $0x807004
  801c6e:	e8 84 ef ff ff       	call   800bf7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c73:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c79:	b8 02 00 00 00       	mov    $0x2,%eax
  801c7e:	e8 32 ff ff ff       	call   801bb5 <nsipc>
}
  801c83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c99:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801ca3:	e8 0d ff ff ff       	call   801bb5 <nsipc>
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <nsipc_close>:

int
nsipc_close(int s)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cb8:	b8 04 00 00 00       	mov    $0x4,%eax
  801cbd:	e8 f3 fe ff ff       	call   801bb5 <nsipc>
}
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	53                   	push   %ebx
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cd6:	53                   	push   %ebx
  801cd7:	ff 75 0c             	push   0xc(%ebp)
  801cda:	68 04 70 80 00       	push   $0x807004
  801cdf:	e8 13 ef ff ff       	call   800bf7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ce4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801cea:	b8 05 00 00 00       	mov    $0x5,%eax
  801cef:	e8 c1 fe ff ff       	call   801bb5 <nsipc>
}
  801cf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d0f:	b8 06 00 00 00       	mov    $0x6,%eax
  801d14:	e8 9c fe ff ff       	call   801bb5 <nsipc>
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d2b:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d31:	8b 45 14             	mov    0x14(%ebp),%eax
  801d34:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d39:	b8 07 00 00 00       	mov    $0x7,%eax
  801d3e:	e8 72 fe ff ff       	call   801bb5 <nsipc>
  801d43:	89 c3                	mov    %eax,%ebx
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 22                	js     801d6b <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d49:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d4e:	39 c6                	cmp    %eax,%esi
  801d50:	0f 4e c6             	cmovle %esi,%eax
  801d53:	39 c3                	cmp    %eax,%ebx
  801d55:	7f 1d                	jg     801d74 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d57:	83 ec 04             	sub    $0x4,%esp
  801d5a:	53                   	push   %ebx
  801d5b:	68 00 70 80 00       	push   $0x807000
  801d60:	ff 75 0c             	push   0xc(%ebp)
  801d63:	e8 8f ee ff ff       	call   800bf7 <memmove>
  801d68:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d74:	68 8b 29 80 00       	push   $0x80298b
  801d79:	68 53 29 80 00       	push   $0x802953
  801d7e:	6a 62                	push   $0x62
  801d80:	68 a0 29 80 00       	push   $0x8029a0
  801d85:	e8 32 e5 ff ff       	call   8002bc <_panic>

00801d8a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	53                   	push   %ebx
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d9c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801da2:	7f 2e                	jg     801dd2 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	53                   	push   %ebx
  801da8:	ff 75 0c             	push   0xc(%ebp)
  801dab:	68 0c 70 80 00       	push   $0x80700c
  801db0:	e8 42 ee ff ff       	call   800bf7 <memmove>
	nsipcbuf.send.req_size = size;
  801db5:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801dbb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbe:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801dc3:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc8:	e8 e8 fd ff ff       	call   801bb5 <nsipc>
}
  801dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    
	assert(size < 1600);
  801dd2:	68 ac 29 80 00       	push   $0x8029ac
  801dd7:	68 53 29 80 00       	push   $0x802953
  801ddc:	6a 6d                	push   $0x6d
  801dde:	68 a0 29 80 00       	push   $0x8029a0
  801de3:	e8 d4 e4 ff ff       	call   8002bc <_panic>

00801de8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df9:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801dfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801e01:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e06:	b8 09 00 00 00       	mov    $0x9,%eax
  801e0b:	e8 a5 fd ff ff       	call   801bb5 <nsipc>
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	ff 75 08             	push   0x8(%ebp)
  801e20:	e8 9a f2 ff ff       	call   8010bf <fd2data>
  801e25:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e27:	83 c4 08             	add    $0x8,%esp
  801e2a:	68 b8 29 80 00       	push   $0x8029b8
  801e2f:	53                   	push   %ebx
  801e30:	e8 2c ec ff ff       	call   800a61 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e35:	8b 46 04             	mov    0x4(%esi),%eax
  801e38:	2b 06                	sub    (%esi),%eax
  801e3a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e40:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e47:	00 00 00 
	stat->st_dev = &devpipe;
  801e4a:	c7 83 88 00 00 00 58 	movl   $0x803058,0x88(%ebx)
  801e51:	30 80 00 
	return 0;
}
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
  801e59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    

00801e60 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	53                   	push   %ebx
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e6a:	53                   	push   %ebx
  801e6b:	6a 00                	push   $0x0
  801e6d:	e8 70 f0 ff ff       	call   800ee2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e72:	89 1c 24             	mov    %ebx,(%esp)
  801e75:	e8 45 f2 ff ff       	call   8010bf <fd2data>
  801e7a:	83 c4 08             	add    $0x8,%esp
  801e7d:	50                   	push   %eax
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 5d f0 ff ff       	call   800ee2 <sys_page_unmap>
}
  801e85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <_pipeisclosed>:
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
  801e90:	83 ec 1c             	sub    $0x1c,%esp
  801e93:	89 c7                	mov    %eax,%edi
  801e95:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e97:	a1 00 40 80 00       	mov    0x804000,%eax
  801e9c:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	57                   	push   %edi
  801ea3:	e8 b7 03 00 00       	call   80225f <pageref>
  801ea8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eab:	89 34 24             	mov    %esi,(%esp)
  801eae:	e8 ac 03 00 00       	call   80225f <pageref>
		nn = thisenv->env_runs;
  801eb3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801eb9:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	39 cb                	cmp    %ecx,%ebx
  801ec1:	74 1b                	je     801ede <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ec3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ec6:	75 cf                	jne    801e97 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ec8:	8b 42 68             	mov    0x68(%edx),%eax
  801ecb:	6a 01                	push   $0x1
  801ecd:	50                   	push   %eax
  801ece:	53                   	push   %ebx
  801ecf:	68 bf 29 80 00       	push   $0x8029bf
  801ed4:	e8 be e4 ff ff       	call   800397 <cprintf>
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	eb b9                	jmp    801e97 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ede:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ee1:	0f 94 c0             	sete   %al
  801ee4:	0f b6 c0             	movzbl %al,%eax
}
  801ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eea:	5b                   	pop    %ebx
  801eeb:	5e                   	pop    %esi
  801eec:	5f                   	pop    %edi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    

00801eef <devpipe_write>:
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	57                   	push   %edi
  801ef3:	56                   	push   %esi
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 28             	sub    $0x28,%esp
  801ef8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801efb:	56                   	push   %esi
  801efc:	e8 be f1 ff ff       	call   8010bf <fd2data>
  801f01:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	bf 00 00 00 00       	mov    $0x0,%edi
  801f0b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f0e:	75 09                	jne    801f19 <devpipe_write+0x2a>
	return i;
  801f10:	89 f8                	mov    %edi,%eax
  801f12:	eb 23                	jmp    801f37 <devpipe_write+0x48>
			sys_yield();
  801f14:	e8 25 ef ff ff       	call   800e3e <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f19:	8b 43 04             	mov    0x4(%ebx),%eax
  801f1c:	8b 0b                	mov    (%ebx),%ecx
  801f1e:	8d 51 20             	lea    0x20(%ecx),%edx
  801f21:	39 d0                	cmp    %edx,%eax
  801f23:	72 1a                	jb     801f3f <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f25:	89 da                	mov    %ebx,%edx
  801f27:	89 f0                	mov    %esi,%eax
  801f29:	e8 5c ff ff ff       	call   801e8a <_pipeisclosed>
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	74 e2                	je     801f14 <devpipe_write+0x25>
				return 0;
  801f32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5f                   	pop    %edi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f42:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f46:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f49:	89 c2                	mov    %eax,%edx
  801f4b:	c1 fa 1f             	sar    $0x1f,%edx
  801f4e:	89 d1                	mov    %edx,%ecx
  801f50:	c1 e9 1b             	shr    $0x1b,%ecx
  801f53:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f56:	83 e2 1f             	and    $0x1f,%edx
  801f59:	29 ca                	sub    %ecx,%edx
  801f5b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f5f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f63:	83 c0 01             	add    $0x1,%eax
  801f66:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f69:	83 c7 01             	add    $0x1,%edi
  801f6c:	eb 9d                	jmp    801f0b <devpipe_write+0x1c>

00801f6e <devpipe_read>:
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 18             	sub    $0x18,%esp
  801f77:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f7a:	57                   	push   %edi
  801f7b:	e8 3f f1 ff ff       	call   8010bf <fd2data>
  801f80:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	be 00 00 00 00       	mov    $0x0,%esi
  801f8a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f8d:	75 13                	jne    801fa2 <devpipe_read+0x34>
	return i;
  801f8f:	89 f0                	mov    %esi,%eax
  801f91:	eb 02                	jmp    801f95 <devpipe_read+0x27>
				return i;
  801f93:	89 f0                	mov    %esi,%eax
}
  801f95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    
			sys_yield();
  801f9d:	e8 9c ee ff ff       	call   800e3e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801fa2:	8b 03                	mov    (%ebx),%eax
  801fa4:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fa7:	75 18                	jne    801fc1 <devpipe_read+0x53>
			if (i > 0)
  801fa9:	85 f6                	test   %esi,%esi
  801fab:	75 e6                	jne    801f93 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fad:	89 da                	mov    %ebx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	e8 d4 fe ff ff       	call   801e8a <_pipeisclosed>
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	74 e3                	je     801f9d <devpipe_read+0x2f>
				return 0;
  801fba:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbf:	eb d4                	jmp    801f95 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fc1:	99                   	cltd   
  801fc2:	c1 ea 1b             	shr    $0x1b,%edx
  801fc5:	01 d0                	add    %edx,%eax
  801fc7:	83 e0 1f             	and    $0x1f,%eax
  801fca:	29 d0                	sub    %edx,%eax
  801fcc:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fd4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fd7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fda:	83 c6 01             	add    $0x1,%esi
  801fdd:	eb ab                	jmp    801f8a <devpipe_read+0x1c>

00801fdf <pipe>:
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fea:	50                   	push   %eax
  801feb:	e8 e6 f0 ff ff       	call   8010d6 <fd_alloc>
  801ff0:	89 c3                	mov    %eax,%ebx
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	0f 88 23 01 00 00    	js     802120 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffd:	83 ec 04             	sub    $0x4,%esp
  802000:	68 07 04 00 00       	push   $0x407
  802005:	ff 75 f4             	push   -0xc(%ebp)
  802008:	6a 00                	push   $0x0
  80200a:	e8 4e ee ff ff       	call   800e5d <sys_page_alloc>
  80200f:	89 c3                	mov    %eax,%ebx
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	85 c0                	test   %eax,%eax
  802016:	0f 88 04 01 00 00    	js     802120 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80201c:	83 ec 0c             	sub    $0xc,%esp
  80201f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802022:	50                   	push   %eax
  802023:	e8 ae f0 ff ff       	call   8010d6 <fd_alloc>
  802028:	89 c3                	mov    %eax,%ebx
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	85 c0                	test   %eax,%eax
  80202f:	0f 88 db 00 00 00    	js     802110 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802035:	83 ec 04             	sub    $0x4,%esp
  802038:	68 07 04 00 00       	push   $0x407
  80203d:	ff 75 f0             	push   -0x10(%ebp)
  802040:	6a 00                	push   $0x0
  802042:	e8 16 ee ff ff       	call   800e5d <sys_page_alloc>
  802047:	89 c3                	mov    %eax,%ebx
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	85 c0                	test   %eax,%eax
  80204e:	0f 88 bc 00 00 00    	js     802110 <pipe+0x131>
	va = fd2data(fd0);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	ff 75 f4             	push   -0xc(%ebp)
  80205a:	e8 60 f0 ff ff       	call   8010bf <fd2data>
  80205f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802061:	83 c4 0c             	add    $0xc,%esp
  802064:	68 07 04 00 00       	push   $0x407
  802069:	50                   	push   %eax
  80206a:	6a 00                	push   $0x0
  80206c:	e8 ec ed ff ff       	call   800e5d <sys_page_alloc>
  802071:	89 c3                	mov    %eax,%ebx
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	85 c0                	test   %eax,%eax
  802078:	0f 88 82 00 00 00    	js     802100 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207e:	83 ec 0c             	sub    $0xc,%esp
  802081:	ff 75 f0             	push   -0x10(%ebp)
  802084:	e8 36 f0 ff ff       	call   8010bf <fd2data>
  802089:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802090:	50                   	push   %eax
  802091:	6a 00                	push   $0x0
  802093:	56                   	push   %esi
  802094:	6a 00                	push   $0x0
  802096:	e8 05 ee ff ff       	call   800ea0 <sys_page_map>
  80209b:	89 c3                	mov    %eax,%ebx
  80209d:	83 c4 20             	add    $0x20,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	78 4e                	js     8020f2 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020a4:	a1 58 30 80 00       	mov    0x803058,%eax
  8020a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ac:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020b1:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020bb:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020c7:	83 ec 0c             	sub    $0xc,%esp
  8020ca:	ff 75 f4             	push   -0xc(%ebp)
  8020cd:	e8 dd ef ff ff       	call   8010af <fd2num>
  8020d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020d7:	83 c4 04             	add    $0x4,%esp
  8020da:	ff 75 f0             	push   -0x10(%ebp)
  8020dd:	e8 cd ef ff ff       	call   8010af <fd2num>
  8020e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f0:	eb 2e                	jmp    802120 <pipe+0x141>
	sys_page_unmap(0, va);
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	56                   	push   %esi
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 e5 ed ff ff       	call   800ee2 <sys_page_unmap>
  8020fd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802100:	83 ec 08             	sub    $0x8,%esp
  802103:	ff 75 f0             	push   -0x10(%ebp)
  802106:	6a 00                	push   $0x0
  802108:	e8 d5 ed ff ff       	call   800ee2 <sys_page_unmap>
  80210d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	ff 75 f4             	push   -0xc(%ebp)
  802116:	6a 00                	push   $0x0
  802118:	e8 c5 ed ff ff       	call   800ee2 <sys_page_unmap>
  80211d:	83 c4 10             	add    $0x10,%esp
}
  802120:	89 d8                	mov    %ebx,%eax
  802122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802125:	5b                   	pop    %ebx
  802126:	5e                   	pop    %esi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <pipeisclosed>:
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80212f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802132:	50                   	push   %eax
  802133:	ff 75 08             	push   0x8(%ebp)
  802136:	e8 eb ef ff ff       	call   801126 <fd_lookup>
  80213b:	83 c4 10             	add    $0x10,%esp
  80213e:	85 c0                	test   %eax,%eax
  802140:	78 18                	js     80215a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802142:	83 ec 0c             	sub    $0xc,%esp
  802145:	ff 75 f4             	push   -0xc(%ebp)
  802148:	e8 72 ef ff ff       	call   8010bf <fd2data>
  80214d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80214f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802152:	e8 33 fd ff ff       	call   801e8a <_pipeisclosed>
  802157:	83 c4 10             	add    $0x10,%esp
}
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	56                   	push   %esi
  802160:	53                   	push   %ebx
  802161:	8b 75 08             	mov    0x8(%ebp),%esi
  802164:	8b 45 0c             	mov    0xc(%ebp),%eax
  802167:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80216a:	85 c0                	test   %eax,%eax
  80216c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802171:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802174:	83 ec 0c             	sub    $0xc,%esp
  802177:	50                   	push   %eax
  802178:	e8 90 ee ff ff       	call   80100d <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80217d:	83 c4 10             	add    $0x10,%esp
  802180:	85 f6                	test   %esi,%esi
  802182:	74 17                	je     80219b <ipc_recv+0x3f>
  802184:	ba 00 00 00 00       	mov    $0x0,%edx
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 0c                	js     802199 <ipc_recv+0x3d>
  80218d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802193:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802199:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80219b:	85 db                	test   %ebx,%ebx
  80219d:	74 17                	je     8021b6 <ipc_recv+0x5a>
  80219f:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 0c                	js     8021b4 <ipc_recv+0x58>
  8021a8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8021ae:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8021b4:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	78 0b                	js     8021c5 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8021ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8021bf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8021c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    

008021cc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	57                   	push   %edi
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	83 ec 0c             	sub    $0xc,%esp
  8021d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8021de:	85 db                	test   %ebx,%ebx
  8021e0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021e5:	0f 44 d8             	cmove  %eax,%ebx
  8021e8:	eb 05                	jmp    8021ef <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8021ea:	e8 4f ec ff ff       	call   800e3e <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8021ef:	ff 75 14             	push   0x14(%ebp)
  8021f2:	53                   	push   %ebx
  8021f3:	56                   	push   %esi
  8021f4:	57                   	push   %edi
  8021f5:	e8 f0 ed ff ff       	call   800fea <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8021fa:	83 c4 10             	add    $0x10,%esp
  8021fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802200:	74 e8                	je     8021ea <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802202:	85 c0                	test   %eax,%eax
  802204:	78 08                	js     80220e <ipc_send+0x42>
	}while (r<0);

}
  802206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802209:	5b                   	pop    %ebx
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80220e:	50                   	push   %eax
  80220f:	68 d7 29 80 00       	push   $0x8029d7
  802214:	6a 3d                	push   $0x3d
  802216:	68 eb 29 80 00       	push   $0x8029eb
  80221b:	e8 9c e0 ff ff       	call   8002bc <_panic>

00802220 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802226:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80222b:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802231:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802237:	8b 52 60             	mov    0x60(%edx),%edx
  80223a:	39 ca                	cmp    %ecx,%edx
  80223c:	74 11                	je     80224f <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80223e:	83 c0 01             	add    $0x1,%eax
  802241:	3d 00 04 00 00       	cmp    $0x400,%eax
  802246:	75 e3                	jne    80222b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
  80224d:	eb 0e                	jmp    80225d <ipc_find_env+0x3d>
			return envs[i].env_id;
  80224f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802255:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80225a:	8b 40 58             	mov    0x58(%eax),%eax
}
  80225d:	5d                   	pop    %ebp
  80225e:	c3                   	ret    

0080225f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802265:	89 c2                	mov    %eax,%edx
  802267:	c1 ea 16             	shr    $0x16,%edx
  80226a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802271:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802276:	f6 c1 01             	test   $0x1,%cl
  802279:	74 1c                	je     802297 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80227b:	c1 e8 0c             	shr    $0xc,%eax
  80227e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802285:	a8 01                	test   $0x1,%al
  802287:	74 0e                	je     802297 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802289:	c1 e8 0c             	shr    $0xc,%eax
  80228c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802293:	ef 
  802294:	0f b7 d2             	movzwl %dx,%edx
}
  802297:	89 d0                	mov    %edx,%eax
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    
  80229b:	66 90                	xchg   %ax,%ax
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__udivdi3>:
  8022a0:	f3 0f 1e fb          	endbr32 
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	53                   	push   %ebx
  8022a8:	83 ec 1c             	sub    $0x1c,%esp
  8022ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	75 19                	jne    8022d8 <__udivdi3+0x38>
  8022bf:	39 f3                	cmp    %esi,%ebx
  8022c1:	76 4d                	jbe    802310 <__udivdi3+0x70>
  8022c3:	31 ff                	xor    %edi,%edi
  8022c5:	89 e8                	mov    %ebp,%eax
  8022c7:	89 f2                	mov    %esi,%edx
  8022c9:	f7 f3                	div    %ebx
  8022cb:	89 fa                	mov    %edi,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	39 f0                	cmp    %esi,%eax
  8022da:	76 14                	jbe    8022f0 <__udivdi3+0x50>
  8022dc:	31 ff                	xor    %edi,%edi
  8022de:	31 c0                	xor    %eax,%eax
  8022e0:	89 fa                	mov    %edi,%edx
  8022e2:	83 c4 1c             	add    $0x1c,%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	0f bd f8             	bsr    %eax,%edi
  8022f3:	83 f7 1f             	xor    $0x1f,%edi
  8022f6:	75 48                	jne    802340 <__udivdi3+0xa0>
  8022f8:	39 f0                	cmp    %esi,%eax
  8022fa:	72 06                	jb     802302 <__udivdi3+0x62>
  8022fc:	31 c0                	xor    %eax,%eax
  8022fe:	39 eb                	cmp    %ebp,%ebx
  802300:	77 de                	ja     8022e0 <__udivdi3+0x40>
  802302:	b8 01 00 00 00       	mov    $0x1,%eax
  802307:	eb d7                	jmp    8022e0 <__udivdi3+0x40>
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	85 db                	test   %ebx,%ebx
  802314:	75 0b                	jne    802321 <__udivdi3+0x81>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f3                	div    %ebx
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	31 d2                	xor    %edx,%edx
  802323:	89 f0                	mov    %esi,%eax
  802325:	f7 f1                	div    %ecx
  802327:	89 c6                	mov    %eax,%esi
  802329:	89 e8                	mov    %ebp,%eax
  80232b:	89 f7                	mov    %esi,%edi
  80232d:	f7 f1                	div    %ecx
  80232f:	89 fa                	mov    %edi,%edx
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 f9                	mov    %edi,%ecx
  802342:	ba 20 00 00 00       	mov    $0x20,%edx
  802347:	29 fa                	sub    %edi,%edx
  802349:	d3 e0                	shl    %cl,%eax
  80234b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80234f:	89 d1                	mov    %edx,%ecx
  802351:	89 d8                	mov    %ebx,%eax
  802353:	d3 e8                	shr    %cl,%eax
  802355:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802359:	09 c1                	or     %eax,%ecx
  80235b:	89 f0                	mov    %esi,%eax
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f9                	mov    %edi,%ecx
  802363:	d3 e3                	shl    %cl,%ebx
  802365:	89 d1                	mov    %edx,%ecx
  802367:	d3 e8                	shr    %cl,%eax
  802369:	89 f9                	mov    %edi,%ecx
  80236b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80236f:	89 eb                	mov    %ebp,%ebx
  802371:	d3 e6                	shl    %cl,%esi
  802373:	89 d1                	mov    %edx,%ecx
  802375:	d3 eb                	shr    %cl,%ebx
  802377:	09 f3                	or     %esi,%ebx
  802379:	89 c6                	mov    %eax,%esi
  80237b:	89 f2                	mov    %esi,%edx
  80237d:	89 d8                	mov    %ebx,%eax
  80237f:	f7 74 24 08          	divl   0x8(%esp)
  802383:	89 d6                	mov    %edx,%esi
  802385:	89 c3                	mov    %eax,%ebx
  802387:	f7 64 24 0c          	mull   0xc(%esp)
  80238b:	39 d6                	cmp    %edx,%esi
  80238d:	72 19                	jb     8023a8 <__udivdi3+0x108>
  80238f:	89 f9                	mov    %edi,%ecx
  802391:	d3 e5                	shl    %cl,%ebp
  802393:	39 c5                	cmp    %eax,%ebp
  802395:	73 04                	jae    80239b <__udivdi3+0xfb>
  802397:	39 d6                	cmp    %edx,%esi
  802399:	74 0d                	je     8023a8 <__udivdi3+0x108>
  80239b:	89 d8                	mov    %ebx,%eax
  80239d:	31 ff                	xor    %edi,%edi
  80239f:	e9 3c ff ff ff       	jmp    8022e0 <__udivdi3+0x40>
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023ab:	31 ff                	xor    %edi,%edi
  8023ad:	e9 2e ff ff ff       	jmp    8022e0 <__udivdi3+0x40>
  8023b2:	66 90                	xchg   %ax,%ax
  8023b4:	66 90                	xchg   %ax,%ax
  8023b6:	66 90                	xchg   %ax,%ax
  8023b8:	66 90                	xchg   %ax,%ax
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	66 90                	xchg   %ax,%ax
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__umoddi3>:
  8023c0:	f3 0f 1e fb          	endbr32 
  8023c4:	55                   	push   %ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 1c             	sub    $0x1c,%esp
  8023cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8023d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8023db:	89 f0                	mov    %esi,%eax
  8023dd:	89 da                	mov    %ebx,%edx
  8023df:	85 ff                	test   %edi,%edi
  8023e1:	75 15                	jne    8023f8 <__umoddi3+0x38>
  8023e3:	39 dd                	cmp    %ebx,%ebp
  8023e5:	76 39                	jbe    802420 <__umoddi3+0x60>
  8023e7:	f7 f5                	div    %ebp
  8023e9:	89 d0                	mov    %edx,%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	83 c4 1c             	add    $0x1c,%esp
  8023f0:	5b                   	pop    %ebx
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	39 df                	cmp    %ebx,%edi
  8023fa:	77 f1                	ja     8023ed <__umoddi3+0x2d>
  8023fc:	0f bd cf             	bsr    %edi,%ecx
  8023ff:	83 f1 1f             	xor    $0x1f,%ecx
  802402:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802406:	75 40                	jne    802448 <__umoddi3+0x88>
  802408:	39 df                	cmp    %ebx,%edi
  80240a:	72 04                	jb     802410 <__umoddi3+0x50>
  80240c:	39 f5                	cmp    %esi,%ebp
  80240e:	77 dd                	ja     8023ed <__umoddi3+0x2d>
  802410:	89 da                	mov    %ebx,%edx
  802412:	89 f0                	mov    %esi,%eax
  802414:	29 e8                	sub    %ebp,%eax
  802416:	19 fa                	sbb    %edi,%edx
  802418:	eb d3                	jmp    8023ed <__umoddi3+0x2d>
  80241a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802420:	89 e9                	mov    %ebp,%ecx
  802422:	85 ed                	test   %ebp,%ebp
  802424:	75 0b                	jne    802431 <__umoddi3+0x71>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f5                	div    %ebp
  80242f:	89 c1                	mov    %eax,%ecx
  802431:	89 d8                	mov    %ebx,%eax
  802433:	31 d2                	xor    %edx,%edx
  802435:	f7 f1                	div    %ecx
  802437:	89 f0                	mov    %esi,%eax
  802439:	f7 f1                	div    %ecx
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	eb ac                	jmp    8023ed <__umoddi3+0x2d>
  802441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802448:	8b 44 24 04          	mov    0x4(%esp),%eax
  80244c:	ba 20 00 00 00       	mov    $0x20,%edx
  802451:	29 c2                	sub    %eax,%edx
  802453:	89 c1                	mov    %eax,%ecx
  802455:	89 e8                	mov    %ebp,%eax
  802457:	d3 e7                	shl    %cl,%edi
  802459:	89 d1                	mov    %edx,%ecx
  80245b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80245f:	d3 e8                	shr    %cl,%eax
  802461:	89 c1                	mov    %eax,%ecx
  802463:	8b 44 24 04          	mov    0x4(%esp),%eax
  802467:	09 f9                	or     %edi,%ecx
  802469:	89 df                	mov    %ebx,%edi
  80246b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246f:	89 c1                	mov    %eax,%ecx
  802471:	d3 e5                	shl    %cl,%ebp
  802473:	89 d1                	mov    %edx,%ecx
  802475:	d3 ef                	shr    %cl,%edi
  802477:	89 c1                	mov    %eax,%ecx
  802479:	89 f0                	mov    %esi,%eax
  80247b:	d3 e3                	shl    %cl,%ebx
  80247d:	89 d1                	mov    %edx,%ecx
  80247f:	89 fa                	mov    %edi,%edx
  802481:	d3 e8                	shr    %cl,%eax
  802483:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802488:	09 d8                	or     %ebx,%eax
  80248a:	f7 74 24 08          	divl   0x8(%esp)
  80248e:	89 d3                	mov    %edx,%ebx
  802490:	d3 e6                	shl    %cl,%esi
  802492:	f7 e5                	mul    %ebp
  802494:	89 c7                	mov    %eax,%edi
  802496:	89 d1                	mov    %edx,%ecx
  802498:	39 d3                	cmp    %edx,%ebx
  80249a:	72 06                	jb     8024a2 <__umoddi3+0xe2>
  80249c:	75 0e                	jne    8024ac <__umoddi3+0xec>
  80249e:	39 c6                	cmp    %eax,%esi
  8024a0:	73 0a                	jae    8024ac <__umoddi3+0xec>
  8024a2:	29 e8                	sub    %ebp,%eax
  8024a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024a8:	89 d1                	mov    %edx,%ecx
  8024aa:	89 c7                	mov    %eax,%edi
  8024ac:	89 f5                	mov    %esi,%ebp
  8024ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8024b2:	29 fd                	sub    %edi,%ebp
  8024b4:	19 cb                	sbb    %ecx,%ebx
  8024b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8024bb:	89 d8                	mov    %ebx,%eax
  8024bd:	d3 e0                	shl    %cl,%eax
  8024bf:	89 f1                	mov    %esi,%ecx
  8024c1:	d3 ed                	shr    %cl,%ebp
  8024c3:	d3 eb                	shr    %cl,%ebx
  8024c5:	09 e8                	or     %ebp,%eax
  8024c7:	89 da                	mov    %ebx,%edx
  8024c9:	83 c4 1c             	add    $0x1c,%esp
  8024cc:	5b                   	pop    %ebx
  8024cd:	5e                   	pop    %esi
  8024ce:	5f                   	pop    %edi
  8024cf:	5d                   	pop    %ebp
  8024d0:	c3                   	ret    
