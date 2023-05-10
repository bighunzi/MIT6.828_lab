
obj/user/testpiperace2.debug：     文件格式 elf32-i386


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
  80002c:	e8 a2 01 00 00       	call   8001d3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 00 27 80 00       	push   $0x802700
  800041:	e8 cb 02 00 00       	call   800311 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 86 1f 00 00       	call   801fd7 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	78 5e                	js     8000b6 <umain+0x83>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  800058:	e8 da 0f 00 00       	call   801037 <fork>
  80005d:	89 c7                	mov    %eax,%edi
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 65                	js     8000c8 <umain+0x95>
		panic("fork: %e", r);
	if (r == 0) {
  800063:	74 75                	je     8000da <umain+0xa7>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800065:	89 fb                	mov    %edi,%ebx
  800067:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80006d:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  800073:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800079:	8b 43 64             	mov    0x64(%ebx),%eax
  80007c:	83 f8 02             	cmp    $0x2,%eax
  80007f:	0f 85 d1 00 00 00    	jne    800156 <umain+0x123>
		if (pipeisclosed(p[0]) != 0) {
  800085:	83 ec 0c             	sub    $0xc,%esp
  800088:	ff 75 e0             	push   -0x20(%ebp)
  80008b:	e8 91 20 00 00       	call   802121 <pipeisclosed>
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	85 c0                	test   %eax,%eax
  800095:	74 e2                	je     800079 <umain+0x46>
			cprintf("\nRACE: pipe appears closed\n");
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	68 70 27 80 00       	push   $0x802770
  80009f:	e8 6d 02 00 00       	call   800311 <cprintf>
			sys_env_destroy(r);
  8000a4:	89 3c 24             	mov    %edi,(%esp)
  8000a7:	e8 bc 0b 00 00       	call   800c68 <sys_env_destroy>
			exit();
  8000ac:	e8 6b 01 00 00       	call   80021c <exit>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	eb c3                	jmp    800079 <umain+0x46>
		panic("pipe: %e", r);
  8000b6:	50                   	push   %eax
  8000b7:	68 4e 27 80 00       	push   $0x80274e
  8000bc:	6a 0d                	push   $0xd
  8000be:	68 57 27 80 00       	push   $0x802757
  8000c3:	e8 6e 01 00 00       	call   800236 <_panic>
		panic("fork: %e", r);
  8000c8:	50                   	push   %eax
  8000c9:	68 d8 2b 80 00       	push   $0x802bd8
  8000ce:	6a 0f                	push   $0xf
  8000d0:	68 57 27 80 00       	push   $0x802757
  8000d5:	e8 5c 01 00 00       	call   800236 <_panic>
		close(p[1]);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	ff 75 e4             	push   -0x1c(%ebp)
  8000e0:	e8 79 12 00 00       	call   80135e <close>
  8000e5:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  8000e8:	89 fb                	mov    %edi,%ebx
			if (i % 10 == 0)
  8000ea:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000ef:	eb 31                	jmp    800122 <umain+0xef>
			dup(p[0], 10);
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	6a 0a                	push   $0xa
  8000f6:	ff 75 e0             	push   -0x20(%ebp)
  8000f9:	e8 b2 12 00 00       	call   8013b0 <dup>
			sys_yield();
  8000fe:	e8 c5 0b 00 00       	call   800cc8 <sys_yield>
			close(10);
  800103:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80010a:	e8 4f 12 00 00       	call   80135e <close>
			sys_yield();
  80010f:	e8 b4 0b 00 00       	call   800cc8 <sys_yield>
		for (i = 0; i < 200; i++) {
  800114:	83 c3 01             	add    $0x1,%ebx
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800120:	74 2a                	je     80014c <umain+0x119>
			if (i % 10 == 0)
  800122:	89 d8                	mov    %ebx,%eax
  800124:	f7 ee                	imul   %esi
  800126:	c1 fa 02             	sar    $0x2,%edx
  800129:	89 d8                	mov    %ebx,%eax
  80012b:	c1 f8 1f             	sar    $0x1f,%eax
  80012e:	29 c2                	sub    %eax,%edx
  800130:	8d 04 92             	lea    (%edx,%edx,4),%eax
  800133:	01 c0                	add    %eax,%eax
  800135:	39 c3                	cmp    %eax,%ebx
  800137:	75 b8                	jne    8000f1 <umain+0xbe>
				cprintf("%d.", i);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	53                   	push   %ebx
  80013d:	68 6c 27 80 00       	push   $0x80276c
  800142:	e8 ca 01 00 00       	call   800311 <cprintf>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	eb a5                	jmp    8000f1 <umain+0xbe>
		exit();
  80014c:	e8 cb 00 00 00       	call   80021c <exit>
  800151:	e9 0f ff ff ff       	jmp    800065 <umain+0x32>
		}
	cprintf("child done with loop\n");
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	68 8c 27 80 00       	push   $0x80278c
  80015e:	e8 ae 01 00 00       	call   800311 <cprintf>
	if (pipeisclosed(p[0]))
  800163:	83 c4 04             	add    $0x4,%esp
  800166:	ff 75 e0             	push   -0x20(%ebp)
  800169:	e8 b3 1f 00 00       	call   802121 <pipeisclosed>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	85 c0                	test   %eax,%eax
  800173:	75 38                	jne    8001ad <umain+0x17a>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	ff 75 e0             	push   -0x20(%ebp)
  80017f:	e8 ad 10 00 00       	call   801231 <fd_lookup>
  800184:	83 c4 10             	add    $0x10,%esp
  800187:	85 c0                	test   %eax,%eax
  800189:	78 36                	js     8001c1 <umain+0x18e>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  80018b:	83 ec 0c             	sub    $0xc,%esp
  80018e:	ff 75 dc             	push   -0x24(%ebp)
  800191:	e8 34 10 00 00       	call   8011ca <fd2data>
	cprintf("race didn't happen\n");
  800196:	c7 04 24 ba 27 80 00 	movl   $0x8027ba,(%esp)
  80019d:	e8 6f 01 00 00       	call   800311 <cprintf>
}
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001ad:	83 ec 04             	sub    $0x4,%esp
  8001b0:	68 24 27 80 00       	push   $0x802724
  8001b5:	6a 40                	push   $0x40
  8001b7:	68 57 27 80 00       	push   $0x802757
  8001bc:	e8 75 00 00 00       	call   800236 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 a2 27 80 00       	push   $0x8027a2
  8001c7:	6a 42                	push   $0x42
  8001c9:	68 57 27 80 00       	push   $0x802757
  8001ce:	e8 63 00 00 00       	call   800236 <_panic>

008001d3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001db:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001de:	e8 c6 0a 00 00       	call   800ca9 <sys_getenvid>
  8001e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e8:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x30>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 64 11 00 00       	call   80138b <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 37 0a 00 00       	call   800c68 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 60 0a 00 00       	call   800ca9 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	push   0xc(%ebp)
  80024f:	ff 75 08             	push   0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 d8 27 80 00       	push   $0x8027d8
  800259:	e8 b3 00 00 00       	call   800311 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	push   0x10(%ebp)
  800265:	e8 56 00 00 00       	call   8002c0 <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 0c 2d 80 00 	movl   $0x802d0c,(%esp)
  800271:	e8 9b 00 00 00       	call   800311 <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	74 09                	je     8002a4 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80029b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	68 ff 00 00 00       	push   $0xff
  8002ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8002af:	50                   	push   %eax
  8002b0:	e8 76 09 00 00       	call   800c2b <sys_cputs>
		b->idx = 0;
  8002b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	eb db                	jmp    80029b <putch+0x1f>

008002c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d0:	00 00 00 
	b.cnt = 0;
  8002d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002dd:	ff 75 0c             	push   0xc(%ebp)
  8002e0:	ff 75 08             	push   0x8(%ebp)
  8002e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e9:	50                   	push   %eax
  8002ea:	68 7c 02 80 00       	push   $0x80027c
  8002ef:	e8 14 01 00 00       	call   800408 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f4:	83 c4 08             	add    $0x8,%esp
  8002f7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800303:	50                   	push   %eax
  800304:	e8 22 09 00 00       	call   800c2b <sys_cputs>

	return b.cnt;
}
  800309:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800317:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 08             	push   0x8(%ebp)
  80031e:	e8 9d ff ff ff       	call   8002c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 1c             	sub    $0x1c,%esp
  80032e:	89 c7                	mov    %eax,%edi
  800330:	89 d6                	mov    %edx,%esi
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	8b 55 0c             	mov    0xc(%ebp),%edx
  800338:	89 d1                	mov    %edx,%ecx
  80033a:	89 c2                	mov    %eax,%edx
  80033c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800342:	8b 45 10             	mov    0x10(%ebp),%eax
  800345:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800348:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800352:	39 c2                	cmp    %eax,%edx
  800354:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800357:	72 3e                	jb     800397 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800359:	83 ec 0c             	sub    $0xc,%esp
  80035c:	ff 75 18             	push   0x18(%ebp)
  80035f:	83 eb 01             	sub    $0x1,%ebx
  800362:	53                   	push   %ebx
  800363:	50                   	push   %eax
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	ff 75 e4             	push   -0x1c(%ebp)
  80036a:	ff 75 e0             	push   -0x20(%ebp)
  80036d:	ff 75 dc             	push   -0x24(%ebp)
  800370:	ff 75 d8             	push   -0x28(%ebp)
  800373:	e8 38 21 00 00       	call   8024b0 <__udivdi3>
  800378:	83 c4 18             	add    $0x18,%esp
  80037b:	52                   	push   %edx
  80037c:	50                   	push   %eax
  80037d:	89 f2                	mov    %esi,%edx
  80037f:	89 f8                	mov    %edi,%eax
  800381:	e8 9f ff ff ff       	call   800325 <printnum>
  800386:	83 c4 20             	add    $0x20,%esp
  800389:	eb 13                	jmp    80039e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	56                   	push   %esi
  80038f:	ff 75 18             	push   0x18(%ebp)
  800392:	ff d7                	call   *%edi
  800394:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800397:	83 eb 01             	sub    $0x1,%ebx
  80039a:	85 db                	test   %ebx,%ebx
  80039c:	7f ed                	jg     80038b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039e:	83 ec 08             	sub    $0x8,%esp
  8003a1:	56                   	push   %esi
  8003a2:	83 ec 04             	sub    $0x4,%esp
  8003a5:	ff 75 e4             	push   -0x1c(%ebp)
  8003a8:	ff 75 e0             	push   -0x20(%ebp)
  8003ab:	ff 75 dc             	push   -0x24(%ebp)
  8003ae:	ff 75 d8             	push   -0x28(%ebp)
  8003b1:	e8 1a 22 00 00       	call   8025d0 <__umoddi3>
  8003b6:	83 c4 14             	add    $0x14,%esp
  8003b9:	0f be 80 fb 27 80 00 	movsbl 0x8027fb(%eax),%eax
  8003c0:	50                   	push   %eax
  8003c1:	ff d7                	call   *%edi
}
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c9:	5b                   	pop    %ebx
  8003ca:	5e                   	pop    %esi
  8003cb:	5f                   	pop    %edi
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	3b 50 04             	cmp    0x4(%eax),%edx
  8003dd:	73 0a                	jae    8003e9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e2:	89 08                	mov    %ecx,(%eax)
  8003e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e7:	88 02                	mov    %al,(%edx)
}
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <printfmt>:
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 10             	push   0x10(%ebp)
  8003f8:	ff 75 0c             	push   0xc(%ebp)
  8003fb:	ff 75 08             	push   0x8(%ebp)
  8003fe:	e8 05 00 00 00       	call   800408 <vprintfmt>
}
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <vprintfmt>:
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	57                   	push   %edi
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
  80040e:	83 ec 3c             	sub    $0x3c,%esp
  800411:	8b 75 08             	mov    0x8(%ebp),%esi
  800414:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800417:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041a:	eb 0a                	jmp    800426 <vprintfmt+0x1e>
			putch(ch, putdat);
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	50                   	push   %eax
  800421:	ff d6                	call   *%esi
  800423:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800426:	83 c7 01             	add    $0x1,%edi
  800429:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80042d:	83 f8 25             	cmp    $0x25,%eax
  800430:	74 0c                	je     80043e <vprintfmt+0x36>
			if (ch == '\0')
  800432:	85 c0                	test   %eax,%eax
  800434:	75 e6                	jne    80041c <vprintfmt+0x14>
}
  800436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800439:	5b                   	pop    %ebx
  80043a:	5e                   	pop    %esi
  80043b:	5f                   	pop    %edi
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    
		padc = ' ';
  80043e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800442:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800449:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800450:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8d 47 01             	lea    0x1(%edi),%eax
  80045f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800462:	0f b6 17             	movzbl (%edi),%edx
  800465:	8d 42 dd             	lea    -0x23(%edx),%eax
  800468:	3c 55                	cmp    $0x55,%al
  80046a:	0f 87 bb 03 00 00    	ja     80082b <vprintfmt+0x423>
  800470:	0f b6 c0             	movzbl %al,%eax
  800473:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800481:	eb d9                	jmp    80045c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800486:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80048a:	eb d0                	jmp    80045c <vprintfmt+0x54>
  80048c:	0f b6 d2             	movzbl %dl,%edx
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800492:	b8 00 00 00 00       	mov    $0x0,%eax
  800497:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80049a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a7:	83 f9 09             	cmp    $0x9,%ecx
  8004aa:	77 55                	ja     800501 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004af:	eb e9                	jmp    80049a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 40 04             	lea    0x4(%eax),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	79 91                	jns    80045c <vprintfmt+0x54>
				width = precision, precision = -1;
  8004cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004d8:	eb 82                	jmp    80045c <vprintfmt+0x54>
  8004da:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e4:	0f 49 c2             	cmovns %edx,%eax
  8004e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ed:	e9 6a ff ff ff       	jmp    80045c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004fc:	e9 5b ff ff ff       	jmp    80045c <vprintfmt+0x54>
  800501:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800504:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800507:	eb bc                	jmp    8004c5 <vprintfmt+0xbd>
			lflag++;
  800509:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050f:	e9 48 ff ff ff       	jmp    80045c <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 78 04             	lea    0x4(%eax),%edi
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	ff 30                	push   (%eax)
  800520:	ff d6                	call   *%esi
			break;
  800522:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800525:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800528:	e9 9d 02 00 00       	jmp    8007ca <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 78 04             	lea    0x4(%eax),%edi
  800533:	8b 10                	mov    (%eax),%edx
  800535:	89 d0                	mov    %edx,%eax
  800537:	f7 d8                	neg    %eax
  800539:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053c:	83 f8 0f             	cmp    $0xf,%eax
  80053f:	7f 23                	jg     800564 <vprintfmt+0x15c>
  800541:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  800548:	85 d2                	test   %edx,%edx
  80054a:	74 18                	je     800564 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80054c:	52                   	push   %edx
  80054d:	68 a1 2c 80 00       	push   $0x802ca1
  800552:	53                   	push   %ebx
  800553:	56                   	push   %esi
  800554:	e8 92 fe ff ff       	call   8003eb <printfmt>
  800559:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80055c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80055f:	e9 66 02 00 00       	jmp    8007ca <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800564:	50                   	push   %eax
  800565:	68 13 28 80 00       	push   $0x802813
  80056a:	53                   	push   %ebx
  80056b:	56                   	push   %esi
  80056c:	e8 7a fe ff ff       	call   8003eb <printfmt>
  800571:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800574:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800577:	e9 4e 02 00 00       	jmp    8007ca <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	83 c0 04             	add    $0x4,%eax
  800582:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80058a:	85 d2                	test   %edx,%edx
  80058c:	b8 0c 28 80 00       	mov    $0x80280c,%eax
  800591:	0f 45 c2             	cmovne %edx,%eax
  800594:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800597:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059b:	7e 06                	jle    8005a3 <vprintfmt+0x19b>
  80059d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005a1:	75 0d                	jne    8005b0 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a6:	89 c7                	mov    %eax,%edi
  8005a8:	03 45 e0             	add    -0x20(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	eb 55                	jmp    800605 <vprintfmt+0x1fd>
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	ff 75 d8             	push   -0x28(%ebp)
  8005b6:	ff 75 cc             	push   -0x34(%ebp)
  8005b9:	e8 0a 03 00 00       	call   8008c8 <strnlen>
  8005be:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c1:	29 c1                	sub    %eax,%ecx
  8005c3:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005cb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d2:	eb 0f                	jmp    8005e3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	ff 75 e0             	push   -0x20(%ebp)
  8005db:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dd:	83 ef 01             	sub    $0x1,%edi
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	85 ff                	test   %edi,%edi
  8005e5:	7f ed                	jg     8005d4 <vprintfmt+0x1cc>
  8005e7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f1:	0f 49 c2             	cmovns %edx,%eax
  8005f4:	29 c2                	sub    %eax,%edx
  8005f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f9:	eb a8                	jmp    8005a3 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	52                   	push   %edx
  800600:	ff d6                	call   *%esi
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800608:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060a:	83 c7 01             	add    $0x1,%edi
  80060d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800611:	0f be d0             	movsbl %al,%edx
  800614:	85 d2                	test   %edx,%edx
  800616:	74 4b                	je     800663 <vprintfmt+0x25b>
  800618:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061c:	78 06                	js     800624 <vprintfmt+0x21c>
  80061e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800622:	78 1e                	js     800642 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800628:	74 d1                	je     8005fb <vprintfmt+0x1f3>
  80062a:	0f be c0             	movsbl %al,%eax
  80062d:	83 e8 20             	sub    $0x20,%eax
  800630:	83 f8 5e             	cmp    $0x5e,%eax
  800633:	76 c6                	jbe    8005fb <vprintfmt+0x1f3>
					putch('?', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 3f                	push   $0x3f
  80063b:	ff d6                	call   *%esi
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	eb c3                	jmp    800605 <vprintfmt+0x1fd>
  800642:	89 cf                	mov    %ecx,%edi
  800644:	eb 0e                	jmp    800654 <vprintfmt+0x24c>
				putch(' ', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 20                	push   $0x20
  80064c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80064e:	83 ef 01             	sub    $0x1,%edi
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 ff                	test   %edi,%edi
  800656:	7f ee                	jg     800646 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800658:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
  80065e:	e9 67 01 00 00       	jmp    8007ca <vprintfmt+0x3c2>
  800663:	89 cf                	mov    %ecx,%edi
  800665:	eb ed                	jmp    800654 <vprintfmt+0x24c>
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7f 1b                	jg     800687 <vprintfmt+0x27f>
	else if (lflag)
  80066c:	85 c9                	test   %ecx,%ecx
  80066e:	74 63                	je     8006d3 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	99                   	cltd   
  800679:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
  800685:	eb 17                	jmp    80069e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 50 04             	mov    0x4(%eax),%edx
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800692:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 40 08             	lea    0x8(%eax),%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80069e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a4:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	0f 89 ff 00 00 00    	jns    8007b0 <vprintfmt+0x3a8>
				putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bf:	f7 da                	neg    %edx
  8006c1:	83 d1 00             	adc    $0x0,%ecx
  8006c4:	f7 d9                	neg    %ecx
  8006c6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c9:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006ce:	e9 dd 00 00 00       	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006db:	99                   	cltd   
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e8:	eb b4                	jmp    80069e <vprintfmt+0x296>
	if (lflag >= 2)
  8006ea:	83 f9 01             	cmp    $0x1,%ecx
  8006ed:	7f 1e                	jg     80070d <vprintfmt+0x305>
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	74 32                	je     800725 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800703:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800708:	e9 a3 00 00 00       	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	8b 48 04             	mov    0x4(%eax),%ecx
  800715:	8d 40 08             	lea    0x8(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80071b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800720:	e9 8b 00 00 00       	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800735:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80073a:	eb 74                	jmp    8007b0 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80073c:	83 f9 01             	cmp    $0x1,%ecx
  80073f:	7f 1b                	jg     80075c <vprintfmt+0x354>
	else if (lflag)
  800741:	85 c9                	test   %ecx,%ecx
  800743:	74 2c                	je     800771 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800755:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80075a:	eb 54                	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8b 10                	mov    (%eax),%edx
  800761:	8b 48 04             	mov    0x4(%eax),%ecx
  800764:	8d 40 08             	lea    0x8(%eax),%eax
  800767:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80076a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80076f:	eb 3f                	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8b 10                	mov    (%eax),%edx
  800776:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077b:	8d 40 04             	lea    0x4(%eax),%eax
  80077e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800781:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800786:	eb 28                	jmp    8007b0 <vprintfmt+0x3a8>
			putch('0', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 30                	push   $0x30
  80078e:	ff d6                	call   *%esi
			putch('x', putdat);
  800790:	83 c4 08             	add    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 78                	push   $0x78
  800796:	ff d6                	call   *%esi
			num = (unsigned long long)
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007a2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007a5:	8d 40 04             	lea    0x4(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ab:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007b0:	83 ec 0c             	sub    $0xc,%esp
  8007b3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007b7:	50                   	push   %eax
  8007b8:	ff 75 e0             	push   -0x20(%ebp)
  8007bb:	57                   	push   %edi
  8007bc:	51                   	push   %ecx
  8007bd:	52                   	push   %edx
  8007be:	89 da                	mov    %ebx,%edx
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	e8 5e fb ff ff       	call   800325 <printnum>
			break;
  8007c7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007cd:	e9 54 fc ff ff       	jmp    800426 <vprintfmt+0x1e>
	if (lflag >= 2)
  8007d2:	83 f9 01             	cmp    $0x1,%ecx
  8007d5:	7f 1b                	jg     8007f2 <vprintfmt+0x3ea>
	else if (lflag)
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	74 2c                	je     800807 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e5:	8d 40 04             	lea    0x4(%eax),%eax
  8007e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007eb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007f0:	eb be                	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8b 10                	mov    (%eax),%edx
  8007f7:	8b 48 04             	mov    0x4(%eax),%ecx
  8007fa:	8d 40 08             	lea    0x8(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800800:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800805:	eb a9                	jmp    8007b0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800811:	8d 40 04             	lea    0x4(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800817:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80081c:	eb 92                	jmp    8007b0 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	53                   	push   %ebx
  800822:	6a 25                	push   $0x25
  800824:	ff d6                	call   *%esi
			break;
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 9f                	jmp    8007ca <vprintfmt+0x3c2>
			putch('%', putdat);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	53                   	push   %ebx
  80082f:	6a 25                	push   $0x25
  800831:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	89 f8                	mov    %edi,%eax
  800838:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083c:	74 05                	je     800843 <vprintfmt+0x43b>
  80083e:	83 e8 01             	sub    $0x1,%eax
  800841:	eb f5                	jmp    800838 <vprintfmt+0x430>
  800843:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800846:	eb 82                	jmp    8007ca <vprintfmt+0x3c2>

00800848 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 18             	sub    $0x18,%esp
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800854:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800857:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800865:	85 c0                	test   %eax,%eax
  800867:	74 26                	je     80088f <vsnprintf+0x47>
  800869:	85 d2                	test   %edx,%edx
  80086b:	7e 22                	jle    80088f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086d:	ff 75 14             	push   0x14(%ebp)
  800870:	ff 75 10             	push   0x10(%ebp)
  800873:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800876:	50                   	push   %eax
  800877:	68 ce 03 80 00       	push   $0x8003ce
  80087c:	e8 87 fb ff ff       	call   800408 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800881:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800884:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088a:	83 c4 10             	add    $0x10,%esp
}
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    
		return -E_INVAL;
  80088f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800894:	eb f7                	jmp    80088d <vsnprintf+0x45>

00800896 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089f:	50                   	push   %eax
  8008a0:	ff 75 10             	push   0x10(%ebp)
  8008a3:	ff 75 0c             	push   0xc(%ebp)
  8008a6:	ff 75 08             	push   0x8(%ebp)
  8008a9:	e8 9a ff ff ff       	call   800848 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb 03                	jmp    8008c0 <strlen+0x10>
		n++;
  8008bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c4:	75 f7                	jne    8008bd <strlen+0xd>
	return n;
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb 03                	jmp    8008db <strnlen+0x13>
		n++;
  8008d8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	39 d0                	cmp    %edx,%eax
  8008dd:	74 08                	je     8008e7 <strnlen+0x1f>
  8008df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e3:	75 f3                	jne    8008d8 <strnlen+0x10>
  8008e5:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008fe:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f2                	jne    8008fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800908:	89 c8                	mov    %ecx,%eax
  80090a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	83 ec 10             	sub    $0x10,%esp
  800916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800919:	53                   	push   %ebx
  80091a:	e8 91 ff ff ff       	call   8008b0 <strlen>
  80091f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800922:	ff 75 0c             	push   0xc(%ebp)
  800925:	01 d8                	add    %ebx,%eax
  800927:	50                   	push   %eax
  800928:	e8 be ff ff ff       	call   8008eb <strcpy>
	return dst;
}
  80092d:	89 d8                	mov    %ebx,%eax
  80092f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 f3                	mov    %esi,%ebx
  800941:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	89 f0                	mov    %esi,%eax
  800946:	eb 0f                	jmp    800957 <strncpy+0x23>
		*dst++ = *src;
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	0f b6 0a             	movzbl (%edx),%ecx
  80094e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800951:	80 f9 01             	cmp    $0x1,%cl
  800954:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800957:	39 d8                	cmp    %ebx,%eax
  800959:	75 ed                	jne    800948 <strncpy+0x14>
	}
	return ret;
}
  80095b:	89 f0                	mov    %esi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096c:	8b 55 10             	mov    0x10(%ebp),%edx
  80096f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800971:	85 d2                	test   %edx,%edx
  800973:	74 21                	je     800996 <strlcpy+0x35>
  800975:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800979:	89 f2                	mov    %esi,%edx
  80097b:	eb 09                	jmp    800986 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097d:	83 c1 01             	add    $0x1,%ecx
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800986:	39 c2                	cmp    %eax,%edx
  800988:	74 09                	je     800993 <strlcpy+0x32>
  80098a:	0f b6 19             	movzbl (%ecx),%ebx
  80098d:	84 db                	test   %bl,%bl
  80098f:	75 ec                	jne    80097d <strlcpy+0x1c>
  800991:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800993:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800996:	29 f0                	sub    %esi,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a5:	eb 06                	jmp    8009ad <strcmp+0x11>
		p++, q++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 04                	je     8009b8 <strcmp+0x1c>
  8009b4:	3a 02                	cmp    (%edx),%al
  8009b6:	74 ef                	je     8009a7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 c0             	movzbl %al,%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c3                	mov    %eax,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d1:	eb 06                	jmp    8009d9 <strncmp+0x17>
		n--, p++, q++;
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d9:	39 d8                	cmp    %ebx,%eax
  8009db:	74 18                	je     8009f5 <strncmp+0x33>
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	84 c9                	test   %cl,%cl
  8009e2:	74 04                	je     8009e8 <strncmp+0x26>
  8009e4:	3a 0a                	cmp    (%edx),%cl
  8009e6:	74 eb                	je     8009d3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
}
  8009f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    
		return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	eb f4                	jmp    8009f0 <strncmp+0x2e>

008009fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a06:	eb 03                	jmp    800a0b <strchr+0xf>
  800a08:	83 c0 01             	add    $0x1,%eax
  800a0b:	0f b6 10             	movzbl (%eax),%edx
  800a0e:	84 d2                	test   %dl,%dl
  800a10:	74 06                	je     800a18 <strchr+0x1c>
		if (*s == c)
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	75 f2                	jne    800a08 <strchr+0xc>
  800a16:	eb 05                	jmp    800a1d <strchr+0x21>
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 09                	je     800a39 <strfind+0x1a>
  800a30:	84 d2                	test   %dl,%dl
  800a32:	74 05                	je     800a39 <strfind+0x1a>
	for (; *s; s++)
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	eb f0                	jmp    800a29 <strfind+0xa>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 2f                	je     800a7a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4b:	89 f8                	mov    %edi,%eax
  800a4d:	09 c8                	or     %ecx,%eax
  800a4f:	a8 03                	test   $0x3,%al
  800a51:	75 21                	jne    800a74 <memset+0x39>
		c &= 0xFF;
  800a53:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a57:	89 d0                	mov    %edx,%eax
  800a59:	c1 e0 08             	shl    $0x8,%eax
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	c1 e3 18             	shl    $0x18,%ebx
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 10             	shl    $0x10,%esi
  800a66:	09 f3                	or     %esi,%ebx
  800a68:	09 da                	or     %ebx,%edx
  800a6a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a6c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6f:	fc                   	cld    
  800a70:	f3 ab                	rep stos %eax,%es:(%edi)
  800a72:	eb 06                	jmp    800a7a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a77:	fc                   	cld    
  800a78:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7a:	89 f8                	mov    %edi,%eax
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8f:	39 c6                	cmp    %eax,%esi
  800a91:	73 32                	jae    800ac5 <memmove+0x44>
  800a93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a96:	39 c2                	cmp    %eax,%edx
  800a98:	76 2b                	jbe    800ac5 <memmove+0x44>
		s += n;
		d += n;
  800a9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9d:	89 d6                	mov    %edx,%esi
  800a9f:	09 fe                	or     %edi,%esi
  800aa1:	09 ce                	or     %ecx,%esi
  800aa3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa9:	75 0e                	jne    800ab9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aab:	83 ef 04             	sub    $0x4,%edi
  800aae:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab4:	fd                   	std    
  800ab5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab7:	eb 09                	jmp    800ac2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab9:	83 ef 01             	sub    $0x1,%edi
  800abc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800abf:	fd                   	std    
  800ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac2:	fc                   	cld    
  800ac3:	eb 1a                	jmp    800adf <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	89 f2                	mov    %esi,%edx
  800ac7:	09 c2                	or     %eax,%edx
  800ac9:	09 ca                	or     %ecx,%edx
  800acb:	f6 c2 03             	test   $0x3,%dl
  800ace:	75 0a                	jne    800ada <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad8:	eb 05                	jmp    800adf <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	fc                   	cld    
  800add:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae9:	ff 75 10             	push   0x10(%ebp)
  800aec:	ff 75 0c             	push   0xc(%ebp)
  800aef:	ff 75 08             	push   0x8(%ebp)
  800af2:	e8 8a ff ff ff       	call   800a81 <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	eb 06                	jmp    800b11 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b11:	39 f0                	cmp    %esi,%eax
  800b13:	74 14                	je     800b29 <memcmp+0x30>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	74 ec                	je     800b0b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 05                	jmp    800b2e <memcmp+0x35>
	}

	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	eb 03                	jmp    800b45 <memfind+0x13>
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	39 d0                	cmp    %edx,%eax
  800b47:	73 04                	jae    800b4d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b49:	38 08                	cmp    %cl,(%eax)
  800b4b:	75 f5                	jne    800b42 <memfind+0x10>
			break;
	return (void *) s;
}
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	eb 03                	jmp    800b60 <strtol+0x11>
		s++;
  800b5d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b60:	0f b6 02             	movzbl (%edx),%eax
  800b63:	3c 20                	cmp    $0x20,%al
  800b65:	74 f6                	je     800b5d <strtol+0xe>
  800b67:	3c 09                	cmp    $0x9,%al
  800b69:	74 f2                	je     800b5d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6b:	3c 2b                	cmp    $0x2b,%al
  800b6d:	74 2a                	je     800b99 <strtol+0x4a>
	int neg = 0;
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b74:	3c 2d                	cmp    $0x2d,%al
  800b76:	74 2b                	je     800ba3 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7e:	75 0f                	jne    800b8f <strtol+0x40>
  800b80:	80 3a 30             	cmpb   $0x30,(%edx)
  800b83:	74 28                	je     800bad <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8c:	0f 44 d8             	cmove  %eax,%ebx
  800b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b94:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b97:	eb 46                	jmp    800bdf <strtol+0x90>
		s++;
  800b99:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba1:	eb d5                	jmp    800b78 <strtol+0x29>
		s++, neg = 1;
  800ba3:	83 c2 01             	add    $0x1,%edx
  800ba6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bab:	eb cb                	jmp    800b78 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb1:	74 0e                	je     800bc1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bb3:	85 db                	test   %ebx,%ebx
  800bb5:	75 d8                	jne    800b8f <strtol+0x40>
		s++, base = 8;
  800bb7:	83 c2 01             	add    $0x1,%edx
  800bba:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bbf:	eb ce                	jmp    800b8f <strtol+0x40>
		s += 2, base = 16;
  800bc1:	83 c2 02             	add    $0x2,%edx
  800bc4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc9:	eb c4                	jmp    800b8f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bcb:	0f be c0             	movsbl %al,%eax
  800bce:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bd4:	7d 3a                	jge    800c10 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd6:	83 c2 01             	add    $0x1,%edx
  800bd9:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bdd:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bdf:	0f b6 02             	movzbl (%edx),%eax
  800be2:	8d 70 d0             	lea    -0x30(%eax),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 09             	cmp    $0x9,%bl
  800bea:	76 df                	jbe    800bcb <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bec:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	80 fb 19             	cmp    $0x19,%bl
  800bf4:	77 08                	ja     800bfe <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bf6:	0f be c0             	movsbl %al,%eax
  800bf9:	83 e8 57             	sub    $0x57,%eax
  800bfc:	eb d3                	jmp    800bd1 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bfe:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c01:	89 f3                	mov    %esi,%ebx
  800c03:	80 fb 19             	cmp    $0x19,%bl
  800c06:	77 08                	ja     800c10 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c08:	0f be c0             	movsbl %al,%eax
  800c0b:	83 e8 37             	sub    $0x37,%eax
  800c0e:	eb c1                	jmp    800bd1 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 05                	je     800c1b <strtol+0xcc>
		*endptr = (char *) s;
  800c16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c19:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c1b:	89 c8                	mov    %ecx,%eax
  800c1d:	f7 d8                	neg    %eax
  800c1f:	85 ff                	test   %edi,%edi
  800c21:	0f 45 c8             	cmovne %eax,%ecx
}
  800c24:	89 c8                	mov    %ecx,%eax
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	89 c3                	mov    %eax,%ebx
  800c3e:	89 c7                	mov    %eax,%edi
  800c40:	89 c6                	mov    %eax,%esi
  800c42:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c54:	b8 01 00 00 00       	mov    $0x1,%eax
  800c59:	89 d1                	mov    %edx,%ecx
  800c5b:	89 d3                	mov    %edx,%ebx
  800c5d:	89 d7                	mov    %edx,%edi
  800c5f:	89 d6                	mov    %edx,%esi
  800c61:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7e:	89 cb                	mov    %ecx,%ebx
  800c80:	89 cf                	mov    %ecx,%edi
  800c82:	89 ce                	mov    %ecx,%esi
  800c84:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7f 08                	jg     800c92 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 03                	push   $0x3
  800c98:	68 ff 2a 80 00       	push   $0x802aff
  800c9d:	6a 2a                	push   $0x2a
  800c9f:	68 1c 2b 80 00       	push   $0x802b1c
  800ca4:	e8 8d f5 ff ff       	call   800236 <_panic>

00800ca9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb4:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb9:	89 d1                	mov    %edx,%ecx
  800cbb:	89 d3                	mov    %edx,%ebx
  800cbd:	89 d7                	mov    %edx,%edi
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_yield>:

void
sys_yield(void)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd8:	89 d1                	mov    %edx,%ecx
  800cda:	89 d3                	mov    %edx,%ebx
  800cdc:	89 d7                	mov    %edx,%edi
  800cde:	89 d6                	mov    %edx,%esi
  800ce0:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf0:	be 00 00 00 00       	mov    $0x0,%esi
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d03:	89 f7                	mov    %esi,%edi
  800d05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7f 08                	jg     800d13 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 04                	push   $0x4
  800d19:	68 ff 2a 80 00       	push   $0x802aff
  800d1e:	6a 2a                	push   $0x2a
  800d20:	68 1c 2b 80 00       	push   $0x802b1c
  800d25:	e8 0c f5 ff ff       	call   800236 <_panic>

00800d2a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d44:	8b 75 18             	mov    0x18(%ebp),%esi
  800d47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7f 08                	jg     800d55 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 05                	push   $0x5
  800d5b:	68 ff 2a 80 00       	push   $0x802aff
  800d60:	6a 2a                	push   $0x2a
  800d62:	68 1c 2b 80 00       	push   $0x802b1c
  800d67:	e8 ca f4 ff ff       	call   800236 <_panic>

00800d6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	b8 06 00 00 00       	mov    $0x6,%eax
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7f 08                	jg     800d97 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 06                	push   $0x6
  800d9d:	68 ff 2a 80 00       	push   $0x802aff
  800da2:	6a 2a                	push   $0x2a
  800da4:	68 1c 2b 80 00       	push   $0x802b1c
  800da9:	e8 88 f4 ff ff       	call   800236 <_panic>

00800dae <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7f 08                	jg     800dd9 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 08                	push   $0x8
  800ddf:	68 ff 2a 80 00       	push   $0x802aff
  800de4:	6a 2a                	push   $0x2a
  800de6:	68 1c 2b 80 00       	push   $0x802b1c
  800deb:	e8 46 f4 ff ff       	call   800236 <_panic>

00800df0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	b8 09 00 00 00       	mov    $0x9,%eax
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7f 08                	jg     800e1b <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 09                	push   $0x9
  800e21:	68 ff 2a 80 00       	push   $0x802aff
  800e26:	6a 2a                	push   $0x2a
  800e28:	68 1c 2b 80 00       	push   $0x802b1c
  800e2d:	e8 04 f4 ff ff       	call   800236 <_panic>

00800e32 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4b:	89 df                	mov    %ebx,%edi
  800e4d:	89 de                	mov    %ebx,%esi
  800e4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7f 08                	jg     800e5d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	50                   	push   %eax
  800e61:	6a 0a                	push   $0xa
  800e63:	68 ff 2a 80 00       	push   $0x802aff
  800e68:	6a 2a                	push   $0x2a
  800e6a:	68 1c 2b 80 00       	push   $0x802b1c
  800e6f:	e8 c2 f3 ff ff       	call   800236 <_panic>

00800e74 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e85:	be 00 00 00 00       	mov    $0x0,%esi
  800e8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e90:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ead:	89 cb                	mov    %ecx,%ebx
  800eaf:	89 cf                	mov    %ecx,%edi
  800eb1:	89 ce                	mov    %ecx,%esi
  800eb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7f 08                	jg     800ec1 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	50                   	push   %eax
  800ec5:	6a 0d                	push   $0xd
  800ec7:	68 ff 2a 80 00       	push   $0x802aff
  800ecc:	6a 2a                	push   $0x2a
  800ece:	68 1c 2b 80 00       	push   $0x802b1c
  800ed3:	e8 5e f3 ff ff       	call   800236 <_panic>

00800ed8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ede:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ee8:	89 d1                	mov    %edx,%ecx
  800eea:	89 d3                	mov    %edx,%ebx
  800eec:	89 d7                	mov    %edx,%edi
  800eee:	89 d6                	mov    %edx,%esi
  800ef0:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f08:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f0d:	89 df                	mov    %ebx,%edi
  800f0f:	89 de                	mov    %ebx,%esi
  800f11:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	b8 10 00 00 00       	mov    $0x10,%eax
  800f2e:	89 df                	mov    %ebx,%edi
  800f30:	89 de                	mov    %ebx,%esi
  800f32:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f41:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f43:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f47:	0f 84 8e 00 00 00    	je     800fdb <pgfault+0xa2>
  800f4d:	89 f0                	mov    %esi,%eax
  800f4f:	c1 e8 0c             	shr    $0xc,%eax
  800f52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f59:	f6 c4 08             	test   $0x8,%ah
  800f5c:	74 7d                	je     800fdb <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f5e:	e8 46 fd ff ff       	call   800ca9 <sys_getenvid>
  800f63:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	6a 07                	push   $0x7
  800f6a:	68 00 f0 7f 00       	push   $0x7ff000
  800f6f:	50                   	push   %eax
  800f70:	e8 72 fd ff ff       	call   800ce7 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 73                	js     800fef <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f7c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 00 10 00 00       	push   $0x1000
  800f8a:	56                   	push   %esi
  800f8b:	68 00 f0 7f 00       	push   $0x7ff000
  800f90:	e8 ec fa ff ff       	call   800a81 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f95:	83 c4 08             	add    $0x8,%esp
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	e8 cd fd ff ff       	call   800d6c <sys_page_unmap>
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	78 5b                	js     801001 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	6a 07                	push   $0x7
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	68 00 f0 7f 00       	push   $0x7ff000
  800fb2:	53                   	push   %ebx
  800fb3:	e8 72 fd ff ff       	call   800d2a <sys_page_map>
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 54                	js     801013 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	68 00 f0 7f 00       	push   $0x7ff000
  800fc7:	53                   	push   %ebx
  800fc8:	e8 9f fd ff ff       	call   800d6c <sys_page_unmap>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 51                	js     801025 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fdb:	83 ec 04             	sub    $0x4,%esp
  800fde:	68 2c 2b 80 00       	push   $0x802b2c
  800fe3:	6a 1d                	push   $0x1d
  800fe5:	68 a8 2b 80 00       	push   $0x802ba8
  800fea:	e8 47 f2 ff ff       	call   800236 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fef:	50                   	push   %eax
  800ff0:	68 64 2b 80 00       	push   $0x802b64
  800ff5:	6a 29                	push   $0x29
  800ff7:	68 a8 2b 80 00       	push   $0x802ba8
  800ffc:	e8 35 f2 ff ff       	call   800236 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801001:	50                   	push   %eax
  801002:	68 88 2b 80 00       	push   $0x802b88
  801007:	6a 2e                	push   $0x2e
  801009:	68 a8 2b 80 00       	push   $0x802ba8
  80100e:	e8 23 f2 ff ff       	call   800236 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801013:	50                   	push   %eax
  801014:	68 b3 2b 80 00       	push   $0x802bb3
  801019:	6a 30                	push   $0x30
  80101b:	68 a8 2b 80 00       	push   $0x802ba8
  801020:	e8 11 f2 ff ff       	call   800236 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801025:	50                   	push   %eax
  801026:	68 88 2b 80 00       	push   $0x802b88
  80102b:	6a 32                	push   $0x32
  80102d:	68 a8 2b 80 00       	push   $0x802ba8
  801032:	e8 ff f1 ff ff       	call   800236 <_panic>

00801037 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801040:	68 39 0f 80 00       	push   $0x800f39
  801045:	e8 7e 12 00 00       	call   8022c8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80104a:	b8 07 00 00 00       	mov    $0x7,%eax
  80104f:	cd 30                	int    $0x30
  801051:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	78 30                	js     80108b <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80105b:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801060:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801064:	75 76                	jne    8010dc <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  801066:	e8 3e fc ff ff       	call   800ca9 <sys_getenvid>
  80106b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801070:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107b:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801080:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80108b:	50                   	push   %eax
  80108c:	68 d1 2b 80 00       	push   $0x802bd1
  801091:	6a 78                	push   $0x78
  801093:	68 a8 2b 80 00       	push   $0x802ba8
  801098:	e8 99 f1 ff ff       	call   800236 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	ff 75 e4             	push   -0x1c(%ebp)
  8010a3:	57                   	push   %edi
  8010a4:	ff 75 dc             	push   -0x24(%ebp)
  8010a7:	57                   	push   %edi
  8010a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010ab:	56                   	push   %esi
  8010ac:	e8 79 fc ff ff       	call   800d2a <sys_page_map>
	if(r<0) return r;
  8010b1:	83 c4 20             	add    $0x20,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 cb                	js     801083 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	ff 75 e4             	push   -0x1c(%ebp)
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	e8 63 fc ff ff       	call   800d2a <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010c7:	83 c4 20             	add    $0x20,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	78 76                	js     801144 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010da:	74 75                	je     801151 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	c1 e8 16             	shr    $0x16,%eax
  8010e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e8:	a8 01                	test   $0x1,%al
  8010ea:	74 e2                	je     8010ce <fork+0x97>
  8010ec:	89 de                	mov    %ebx,%esi
  8010ee:	c1 ee 0c             	shr    $0xc,%esi
  8010f1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f8:	a8 01                	test   $0x1,%al
  8010fa:	74 d2                	je     8010ce <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  8010fc:	e8 a8 fb ff ff       	call   800ca9 <sys_getenvid>
  801101:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801104:	89 f7                	mov    %esi,%edi
  801106:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801109:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801110:	89 c1                	mov    %eax,%ecx
  801112:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801118:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80111b:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801122:	f6 c6 04             	test   $0x4,%dh
  801125:	0f 85 72 ff ff ff    	jne    80109d <fork+0x66>
		perm &= ~PTE_W;
  80112b:	25 05 0e 00 00       	and    $0xe05,%eax
  801130:	80 cc 08             	or     $0x8,%ah
  801133:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801139:	0f 44 c1             	cmove  %ecx,%eax
  80113c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80113f:	e9 59 ff ff ff       	jmp    80109d <fork+0x66>
  801144:	ba 00 00 00 00       	mov    $0x0,%edx
  801149:	0f 4f c2             	cmovg  %edx,%eax
  80114c:	e9 32 ff ff ff       	jmp    801083 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	6a 07                	push   $0x7
  801156:	68 00 f0 bf ee       	push   $0xeebff000
  80115b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80115e:	57                   	push   %edi
  80115f:	e8 83 fb ff ff       	call   800ce7 <sys_page_alloc>
	if(r<0) return r;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	0f 88 14 ff ff ff    	js     801083 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	68 3e 23 80 00       	push   $0x80233e
  801177:	57                   	push   %edi
  801178:	e8 b5 fc ff ff       	call   800e32 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	0f 88 fb fe ff ff    	js     801083 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	6a 02                	push   $0x2
  80118d:	57                   	push   %edi
  80118e:	e8 1b fc ff ff       	call   800dae <sys_env_set_status>
	if(r<0) return r;
  801193:	83 c4 10             	add    $0x10,%esp
	return envid;
  801196:	85 c0                	test   %eax,%eax
  801198:	0f 49 c7             	cmovns %edi,%eax
  80119b:	e9 e3 fe ff ff       	jmp    801083 <fork+0x4c>

008011a0 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a6:	68 e1 2b 80 00       	push   $0x802be1
  8011ab:	68 a1 00 00 00       	push   $0xa1
  8011b0:	68 a8 2b 80 00       	push   $0x802ba8
  8011b5:	e8 7c f0 ff ff       	call   800236 <_panic>

008011ba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011da:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 16             	shr    $0x16,%edx
  8011ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 29                	je     801223 <fd_alloc+0x42>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 0c             	shr    $0xc,%edx
  8011ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 18                	je     801223 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80120b:	05 00 10 00 00       	add    $0x1000,%eax
  801210:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801215:	75 d2                	jne    8011e9 <fd_alloc+0x8>
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80121c:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801221:	eb 05                	jmp    801228 <fd_alloc+0x47>
			return 0;
  801223:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801228:	8b 55 08             	mov    0x8(%ebp),%edx
  80122b:	89 02                	mov    %eax,(%edx)
}
  80122d:	89 c8                	mov    %ecx,%eax
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801237:	83 f8 1f             	cmp    $0x1f,%eax
  80123a:	77 30                	ja     80126c <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123c:	c1 e0 0c             	shl    $0xc,%eax
  80123f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801244:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	74 24                	je     801273 <fd_lookup+0x42>
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 ea 0c             	shr    $0xc,%edx
  801254:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125b:	f6 c2 01             	test   $0x1,%dl
  80125e:	74 1a                	je     80127a <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801260:	8b 55 0c             	mov    0xc(%ebp),%edx
  801263:	89 02                	mov    %eax,(%edx)
	return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    
		return -E_INVAL;
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801271:	eb f7                	jmp    80126a <fd_lookup+0x39>
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb f0                	jmp    80126a <fd_lookup+0x39>
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127f:	eb e9                	jmp    80126a <fd_lookup+0x39>

00801281 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	53                   	push   %ebx
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801295:	39 13                	cmp    %edx,(%ebx)
  801297:	74 37                	je     8012d0 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801299:	83 c0 01             	add    $0x1,%eax
  80129c:	8b 1c 85 74 2c 80 00 	mov    0x802c74(,%eax,4),%ebx
  8012a3:	85 db                	test   %ebx,%ebx
  8012a5:	75 ee                	jne    801295 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a7:	a1 00 40 80 00       	mov    0x804000,%eax
  8012ac:	8b 40 58             	mov    0x58(%eax),%eax
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	52                   	push   %edx
  8012b3:	50                   	push   %eax
  8012b4:	68 f8 2b 80 00       	push   $0x802bf8
  8012b9:	e8 53 f0 ff ff       	call   800311 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c9:	89 1a                	mov    %ebx,(%edx)
}
  8012cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    
			return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d5:	eb ef                	jmp    8012c6 <dev_lookup+0x45>

008012d7 <fd_close>:
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	57                   	push   %edi
  8012db:	56                   	push   %esi
  8012dc:	53                   	push   %ebx
  8012dd:	83 ec 24             	sub    $0x24,%esp
  8012e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ea:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f3:	50                   	push   %eax
  8012f4:	e8 38 ff ff ff       	call   801231 <fd_lookup>
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 05                	js     801307 <fd_close+0x30>
	    || fd != fd2)
  801302:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801305:	74 16                	je     80131d <fd_close+0x46>
		return (must_exist ? r : 0);
  801307:	89 f8                	mov    %edi,%eax
  801309:	84 c0                	test   %al,%al
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
  801310:	0f 44 d8             	cmove  %eax,%ebx
}
  801313:	89 d8                	mov    %ebx,%eax
  801315:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 36                	push   (%esi)
  801326:	e8 56 ff ff ff       	call   801281 <dev_lookup>
  80132b:	89 c3                	mov    %eax,%ebx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 1a                	js     80134e <fd_close+0x77>
		if (dev->dev_close)
  801334:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801337:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80133a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80133f:	85 c0                	test   %eax,%eax
  801341:	74 0b                	je     80134e <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	56                   	push   %esi
  801347:	ff d0                	call   *%eax
  801349:	89 c3                	mov    %eax,%ebx
  80134b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	56                   	push   %esi
  801352:	6a 00                	push   $0x0
  801354:	e8 13 fa ff ff       	call   800d6c <sys_page_unmap>
	return r;
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	eb b5                	jmp    801313 <fd_close+0x3c>

0080135e <close>:

int
close(int fdnum)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	push   0x8(%ebp)
  80136b:	e8 c1 fe ff ff       	call   801231 <fd_lookup>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	79 02                	jns    801379 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    
		return fd_close(fd, 1);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	6a 01                	push   $0x1
  80137e:	ff 75 f4             	push   -0xc(%ebp)
  801381:	e8 51 ff ff ff       	call   8012d7 <fd_close>
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	eb ec                	jmp    801377 <close+0x19>

0080138b <close_all>:

void
close_all(void)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801392:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	53                   	push   %ebx
  80139b:	e8 be ff ff ff       	call   80135e <close>
	for (i = 0; i < MAXFD; i++)
  8013a0:	83 c3 01             	add    $0x1,%ebx
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	83 fb 20             	cmp    $0x20,%ebx
  8013a9:	75 ec                	jne    801397 <close_all+0xc>
}
  8013ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	57                   	push   %edi
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	push   0x8(%ebp)
  8013c0:	e8 6c fe ff ff       	call   801231 <fd_lookup>
  8013c5:	89 c3                	mov    %eax,%ebx
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 7f                	js     80144d <dup+0x9d>
		return r;
	close(newfdnum);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	ff 75 0c             	push   0xc(%ebp)
  8013d4:	e8 85 ff ff ff       	call   80135e <close>

	newfd = INDEX2FD(newfdnum);
  8013d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013dc:	c1 e6 0c             	shl    $0xc,%esi
  8013df:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013e8:	89 3c 24             	mov    %edi,(%esp)
  8013eb:	e8 da fd ff ff       	call   8011ca <fd2data>
  8013f0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013f2:	89 34 24             	mov    %esi,(%esp)
  8013f5:	e8 d0 fd ff ff       	call   8011ca <fd2data>
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801400:	89 d8                	mov    %ebx,%eax
  801402:	c1 e8 16             	shr    $0x16,%eax
  801405:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140c:	a8 01                	test   $0x1,%al
  80140e:	74 11                	je     801421 <dup+0x71>
  801410:	89 d8                	mov    %ebx,%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
  801415:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141c:	f6 c2 01             	test   $0x1,%dl
  80141f:	75 36                	jne    801457 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801421:	89 f8                	mov    %edi,%eax
  801423:	c1 e8 0c             	shr    $0xc,%eax
  801426:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	25 07 0e 00 00       	and    $0xe07,%eax
  801435:	50                   	push   %eax
  801436:	56                   	push   %esi
  801437:	6a 00                	push   $0x0
  801439:	57                   	push   %edi
  80143a:	6a 00                	push   $0x0
  80143c:	e8 e9 f8 ff ff       	call   800d2a <sys_page_map>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 20             	add    $0x20,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 33                	js     80147d <dup+0xcd>
		goto err;

	return newfdnum;
  80144a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80144d:	89 d8                	mov    %ebx,%eax
  80144f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801452:	5b                   	pop    %ebx
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801457:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	25 07 0e 00 00       	and    $0xe07,%eax
  801466:	50                   	push   %eax
  801467:	ff 75 d4             	push   -0x2c(%ebp)
  80146a:	6a 00                	push   $0x0
  80146c:	53                   	push   %ebx
  80146d:	6a 00                	push   $0x0
  80146f:	e8 b6 f8 ff ff       	call   800d2a <sys_page_map>
  801474:	89 c3                	mov    %eax,%ebx
  801476:	83 c4 20             	add    $0x20,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	79 a4                	jns    801421 <dup+0x71>
	sys_page_unmap(0, newfd);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	56                   	push   %esi
  801481:	6a 00                	push   $0x0
  801483:	e8 e4 f8 ff ff       	call   800d6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	ff 75 d4             	push   -0x2c(%ebp)
  80148e:	6a 00                	push   $0x0
  801490:	e8 d7 f8 ff ff       	call   800d6c <sys_page_unmap>
	return r;
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	eb b3                	jmp    80144d <dup+0x9d>

0080149a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	56                   	push   %esi
  80149e:	53                   	push   %ebx
  80149f:	83 ec 18             	sub    $0x18,%esp
  8014a2:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	56                   	push   %esi
  8014aa:	e8 82 fd ff ff       	call   801231 <fd_lookup>
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 3c                	js     8014f2 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	ff 33                	push   (%ebx)
  8014c2:	e8 ba fd ff ff       	call   801281 <dev_lookup>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 24                	js     8014f2 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ce:	8b 43 08             	mov    0x8(%ebx),%eax
  8014d1:	83 e0 03             	and    $0x3,%eax
  8014d4:	83 f8 01             	cmp    $0x1,%eax
  8014d7:	74 20                	je     8014f9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dc:	8b 40 08             	mov    0x8(%eax),%eax
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	74 37                	je     80151a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	ff 75 10             	push   0x10(%ebp)
  8014e9:	ff 75 0c             	push   0xc(%ebp)
  8014ec:	53                   	push   %ebx
  8014ed:	ff d0                	call   *%eax
  8014ef:	83 c4 10             	add    $0x10,%esp
}
  8014f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f9:	a1 00 40 80 00       	mov    0x804000,%eax
  8014fe:	8b 40 58             	mov    0x58(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	56                   	push   %esi
  801505:	50                   	push   %eax
  801506:	68 39 2c 80 00       	push   $0x802c39
  80150b:	e8 01 ee ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801518:	eb d8                	jmp    8014f2 <read+0x58>
		return -E_NOT_SUPP;
  80151a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80151f:	eb d1                	jmp    8014f2 <read+0x58>

00801521 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	57                   	push   %edi
  801525:	56                   	push   %esi
  801526:	53                   	push   %ebx
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801530:	bb 00 00 00 00       	mov    $0x0,%ebx
  801535:	eb 02                	jmp    801539 <readn+0x18>
  801537:	01 c3                	add    %eax,%ebx
  801539:	39 f3                	cmp    %esi,%ebx
  80153b:	73 21                	jae    80155e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	89 f0                	mov    %esi,%eax
  801542:	29 d8                	sub    %ebx,%eax
  801544:	50                   	push   %eax
  801545:	89 d8                	mov    %ebx,%eax
  801547:	03 45 0c             	add    0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	57                   	push   %edi
  80154c:	e8 49 ff ff ff       	call   80149a <read>
		if (m < 0)
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 04                	js     80155c <readn+0x3b>
			return m;
		if (m == 0)
  801558:	75 dd                	jne    801537 <readn+0x16>
  80155a:	eb 02                	jmp    80155e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 18             	sub    $0x18,%esp
  801570:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	53                   	push   %ebx
  801578:	e8 b4 fc ff ff       	call   801231 <fd_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 37                	js     8015bb <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 36                	push   (%esi)
  801590:	e8 ec fc ff ff       	call   801281 <dev_lookup>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 1f                	js     8015bb <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015a0:	74 20                	je     8015c2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	74 37                	je     8015e3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	ff 75 10             	push   0x10(%ebp)
  8015b2:	ff 75 0c             	push   0xc(%ebp)
  8015b5:	56                   	push   %esi
  8015b6:	ff d0                	call   *%eax
  8015b8:	83 c4 10             	add    $0x10,%esp
}
  8015bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c2:	a1 00 40 80 00       	mov    0x804000,%eax
  8015c7:	8b 40 58             	mov    0x58(%eax),%eax
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	50                   	push   %eax
  8015cf:	68 55 2c 80 00       	push   $0x802c55
  8015d4:	e8 38 ed ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e1:	eb d8                	jmp    8015bb <write+0x53>
		return -E_NOT_SUPP;
  8015e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e8:	eb d1                	jmp    8015bb <write+0x53>

008015ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 08             	push   0x8(%ebp)
  8015f7:	e8 35 fc ff ff       	call   801231 <fd_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 0e                	js     801611 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
  801606:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801609:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80160c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 18             	sub    $0x18,%esp
  80161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	53                   	push   %ebx
  801623:	e8 09 fc ff ff       	call   801231 <fd_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 34                	js     801663 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	ff 36                	push   (%esi)
  80163b:	e8 41 fc ff ff       	call   801281 <dev_lookup>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 1c                	js     801663 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801647:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80164b:	74 1d                	je     80166a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80164d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801650:	8b 40 18             	mov    0x18(%eax),%eax
  801653:	85 c0                	test   %eax,%eax
  801655:	74 34                	je     80168b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	ff 75 0c             	push   0xc(%ebp)
  80165d:	56                   	push   %esi
  80165e:	ff d0                	call   *%eax
  801660:	83 c4 10             	add    $0x10,%esp
}
  801663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    
			thisenv->env_id, fdnum);
  80166a:	a1 00 40 80 00       	mov    0x804000,%eax
  80166f:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801672:	83 ec 04             	sub    $0x4,%esp
  801675:	53                   	push   %ebx
  801676:	50                   	push   %eax
  801677:	68 18 2c 80 00       	push   $0x802c18
  80167c:	e8 90 ec ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801689:	eb d8                	jmp    801663 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80168b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801690:	eb d1                	jmp    801663 <ftruncate+0x50>

00801692 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
  801697:	83 ec 18             	sub    $0x18,%esp
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	ff 75 08             	push   0x8(%ebp)
  8016a4:	e8 88 fb ff ff       	call   801231 <fd_lookup>
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 49                	js     8016f9 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	ff 36                	push   (%esi)
  8016bc:	e8 c0 fb ff ff       	call   801281 <dev_lookup>
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 31                	js     8016f9 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cf:	74 2f                	je     801700 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016db:	00 00 00 
	stat->st_isdir = 0;
  8016de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e5:	00 00 00 
	stat->st_dev = dev;
  8016e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	56                   	push   %esi
  8016f3:	ff 50 14             	call   *0x14(%eax)
  8016f6:	83 c4 10             	add    $0x10,%esp
}
  8016f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5e                   	pop    %esi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    
		return -E_NOT_SUPP;
  801700:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801705:	eb f2                	jmp    8016f9 <fstat+0x67>

00801707 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	6a 00                	push   $0x0
  801711:	ff 75 08             	push   0x8(%ebp)
  801714:	e8 e4 01 00 00       	call   8018fd <open>
  801719:	89 c3                	mov    %eax,%ebx
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 1b                	js     80173d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	ff 75 0c             	push   0xc(%ebp)
  801728:	50                   	push   %eax
  801729:	e8 64 ff ff ff       	call   801692 <fstat>
  80172e:	89 c6                	mov    %eax,%esi
	close(fd);
  801730:	89 1c 24             	mov    %ebx,(%esp)
  801733:	e8 26 fc ff ff       	call   80135e <close>
	return r;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	89 f3                	mov    %esi,%ebx
}
  80173d:	89 d8                	mov    %ebx,%eax
  80173f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	89 c6                	mov    %eax,%esi
  80174d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801756:	74 27                	je     80177f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801758:	6a 07                	push   $0x7
  80175a:	68 00 50 80 00       	push   $0x805000
  80175f:	56                   	push   %esi
  801760:	ff 35 00 60 80 00    	push   0x806000
  801766:	e8 69 0c 00 00       	call   8023d4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80176b:	83 c4 0c             	add    $0xc,%esp
  80176e:	6a 00                	push   $0x0
  801770:	53                   	push   %ebx
  801771:	6a 00                	push   $0x0
  801773:	e8 ec 0b 00 00       	call   802364 <ipc_recv>
}
  801778:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	6a 01                	push   $0x1
  801784:	e8 9f 0c 00 00       	call   802428 <ipc_find_env>
  801789:	a3 00 60 80 00       	mov    %eax,0x806000
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	eb c5                	jmp    801758 <fsipc+0x12>

00801793 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b6:	e8 8b ff ff ff       	call   801746 <fsipc>
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <devfile_flush>:
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d8:	e8 69 ff ff ff       	call   801746 <fsipc>
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <devfile_stat>:
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fe:	e8 43 ff ff ff       	call   801746 <fsipc>
  801803:	85 c0                	test   %eax,%eax
  801805:	78 2c                	js     801833 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	53                   	push   %ebx
  801810:	e8 d6 f0 ff ff       	call   8008eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801815:	a1 80 50 80 00       	mov    0x805080,%eax
  80181a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801820:	a1 84 50 80 00       	mov    0x805084,%eax
  801825:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devfile_write>:
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	8b 45 10             	mov    0x10(%ebp),%eax
  801841:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801846:	39 d0                	cmp    %edx,%eax
  801848:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80184b:	8b 55 08             	mov    0x8(%ebp),%edx
  80184e:	8b 52 0c             	mov    0xc(%edx),%edx
  801851:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801857:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80185c:	50                   	push   %eax
  80185d:	ff 75 0c             	push   0xc(%ebp)
  801860:	68 08 50 80 00       	push   $0x805008
  801865:	e8 17 f2 ff ff       	call   800a81 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80186a:	ba 00 00 00 00       	mov    $0x0,%edx
  80186f:	b8 04 00 00 00       	mov    $0x4,%eax
  801874:	e8 cd fe ff ff       	call   801746 <fsipc>
}
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <devfile_read>:
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	8b 40 0c             	mov    0xc(%eax),%eax
  801889:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80188e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 03 00 00 00       	mov    $0x3,%eax
  80189e:	e8 a3 fe ff ff       	call   801746 <fsipc>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 1f                	js     8018c8 <devfile_read+0x4d>
	assert(r <= n);
  8018a9:	39 f0                	cmp    %esi,%eax
  8018ab:	77 24                	ja     8018d1 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018ad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b2:	7f 33                	jg     8018e7 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018b4:	83 ec 04             	sub    $0x4,%esp
  8018b7:	50                   	push   %eax
  8018b8:	68 00 50 80 00       	push   $0x805000
  8018bd:	ff 75 0c             	push   0xc(%ebp)
  8018c0:	e8 bc f1 ff ff       	call   800a81 <memmove>
	return r;
  8018c5:	83 c4 10             	add    $0x10,%esp
}
  8018c8:	89 d8                	mov    %ebx,%eax
  8018ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cd:	5b                   	pop    %ebx
  8018ce:	5e                   	pop    %esi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    
	assert(r <= n);
  8018d1:	68 88 2c 80 00       	push   $0x802c88
  8018d6:	68 8f 2c 80 00       	push   $0x802c8f
  8018db:	6a 7c                	push   $0x7c
  8018dd:	68 a4 2c 80 00       	push   $0x802ca4
  8018e2:	e8 4f e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018e7:	68 af 2c 80 00       	push   $0x802caf
  8018ec:	68 8f 2c 80 00       	push   $0x802c8f
  8018f1:	6a 7d                	push   $0x7d
  8018f3:	68 a4 2c 80 00       	push   $0x802ca4
  8018f8:	e8 39 e9 ff ff       	call   800236 <_panic>

008018fd <open>:
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	83 ec 1c             	sub    $0x1c,%esp
  801905:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801908:	56                   	push   %esi
  801909:	e8 a2 ef ff ff       	call   8008b0 <strlen>
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801916:	7f 6c                	jg     801984 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191e:	50                   	push   %eax
  80191f:	e8 bd f8 ff ff       	call   8011e1 <fd_alloc>
  801924:	89 c3                	mov    %eax,%ebx
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 3c                	js     801969 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	56                   	push   %esi
  801931:	68 00 50 80 00       	push   $0x805000
  801936:	e8 b0 ef ff ff       	call   8008eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801943:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801946:	b8 01 00 00 00       	mov    $0x1,%eax
  80194b:	e8 f6 fd ff ff       	call   801746 <fsipc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	78 19                	js     801972 <open+0x75>
	return fd2num(fd);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	ff 75 f4             	push   -0xc(%ebp)
  80195f:	e8 56 f8 ff ff       	call   8011ba <fd2num>
  801964:	89 c3                	mov    %eax,%ebx
  801966:	83 c4 10             	add    $0x10,%esp
}
  801969:	89 d8                	mov    %ebx,%eax
  80196b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    
		fd_close(fd, 0);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	6a 00                	push   $0x0
  801977:	ff 75 f4             	push   -0xc(%ebp)
  80197a:	e8 58 f9 ff ff       	call   8012d7 <fd_close>
		return r;
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	eb e5                	jmp    801969 <open+0x6c>
		return -E_BAD_PATH;
  801984:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801989:	eb de                	jmp    801969 <open+0x6c>

0080198b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801991:	ba 00 00 00 00       	mov    $0x0,%edx
  801996:	b8 08 00 00 00       	mov    $0x8,%eax
  80199b:	e8 a6 fd ff ff       	call   801746 <fsipc>
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019a8:	68 bb 2c 80 00       	push   $0x802cbb
  8019ad:	ff 75 0c             	push   0xc(%ebp)
  8019b0:	e8 36 ef ff ff       	call   8008eb <strcpy>
	return 0;
}
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <devsock_close>:
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 10             	sub    $0x10,%esp
  8019c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019c6:	53                   	push   %ebx
  8019c7:	e8 9b 0a 00 00       	call   802467 <pageref>
  8019cc:	89 c2                	mov    %eax,%edx
  8019ce:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019d1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019d6:	83 fa 01             	cmp    $0x1,%edx
  8019d9:	74 05                	je     8019e0 <devsock_close+0x24>
}
  8019db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 73 0c             	push   0xc(%ebx)
  8019e6:	e8 b7 02 00 00       	call   801ca2 <nsipc_close>
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	eb eb                	jmp    8019db <devsock_close+0x1f>

008019f0 <devsock_write>:
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019f6:	6a 00                	push   $0x0
  8019f8:	ff 75 10             	push   0x10(%ebp)
  8019fb:	ff 75 0c             	push   0xc(%ebp)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	ff 70 0c             	push   0xc(%eax)
  801a04:	e8 79 03 00 00       	call   801d82 <nsipc_send>
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <devsock_read>:
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a11:	6a 00                	push   $0x0
  801a13:	ff 75 10             	push   0x10(%ebp)
  801a16:	ff 75 0c             	push   0xc(%ebp)
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	ff 70 0c             	push   0xc(%eax)
  801a1f:	e8 ef 02 00 00       	call   801d13 <nsipc_recv>
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <fd2sockid>:
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a2c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a2f:	52                   	push   %edx
  801a30:	50                   	push   %eax
  801a31:	e8 fb f7 ff ff       	call   801231 <fd_lookup>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 10                	js     801a4d <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a40:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a46:	39 08                	cmp    %ecx,(%eax)
  801a48:	75 05                	jne    801a4f <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a4a:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    
		return -E_NOT_SUPP;
  801a4f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a54:	eb f7                	jmp    801a4d <fd2sockid+0x27>

00801a56 <alloc_sockfd>:
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	83 ec 1c             	sub    $0x1c,%esp
  801a5e:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a63:	50                   	push   %eax
  801a64:	e8 78 f7 ff ff       	call   8011e1 <fd_alloc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 43                	js     801ab5 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a72:	83 ec 04             	sub    $0x4,%esp
  801a75:	68 07 04 00 00       	push   $0x407
  801a7a:	ff 75 f4             	push   -0xc(%ebp)
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 63 f2 ff ff       	call   800ce7 <sys_page_alloc>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 28                	js     801ab5 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a96:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aa2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	50                   	push   %eax
  801aa9:	e8 0c f7 ff ff       	call   8011ba <fd2num>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	eb 0c                	jmp    801ac1 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	56                   	push   %esi
  801ab9:	e8 e4 01 00 00       	call   801ca2 <nsipc_close>
		return r;
  801abe:	83 c4 10             	add    $0x10,%esp
}
  801ac1:	89 d8                	mov    %ebx,%eax
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <accept>:
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad3:	e8 4e ff ff ff       	call   801a26 <fd2sockid>
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 1b                	js     801af7 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801adc:	83 ec 04             	sub    $0x4,%esp
  801adf:	ff 75 10             	push   0x10(%ebp)
  801ae2:	ff 75 0c             	push   0xc(%ebp)
  801ae5:	50                   	push   %eax
  801ae6:	e8 0e 01 00 00       	call   801bf9 <nsipc_accept>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 05                	js     801af7 <accept+0x2d>
	return alloc_sockfd(r);
  801af2:	e8 5f ff ff ff       	call   801a56 <alloc_sockfd>
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <bind>:
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	e8 1f ff ff ff       	call   801a26 <fd2sockid>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 12                	js     801b1d <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	ff 75 10             	push   0x10(%ebp)
  801b11:	ff 75 0c             	push   0xc(%ebp)
  801b14:	50                   	push   %eax
  801b15:	e8 31 01 00 00       	call   801c4b <nsipc_bind>
  801b1a:	83 c4 10             	add    $0x10,%esp
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <shutdown>:
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	e8 f9 fe ff ff       	call   801a26 <fd2sockid>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 0f                	js     801b40 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b31:	83 ec 08             	sub    $0x8,%esp
  801b34:	ff 75 0c             	push   0xc(%ebp)
  801b37:	50                   	push   %eax
  801b38:	e8 43 01 00 00       	call   801c80 <nsipc_shutdown>
  801b3d:	83 c4 10             	add    $0x10,%esp
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <connect>:
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	e8 d6 fe ff ff       	call   801a26 <fd2sockid>
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 12                	js     801b66 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	ff 75 10             	push   0x10(%ebp)
  801b5a:	ff 75 0c             	push   0xc(%ebp)
  801b5d:	50                   	push   %eax
  801b5e:	e8 59 01 00 00       	call   801cbc <nsipc_connect>
  801b63:	83 c4 10             	add    $0x10,%esp
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <listen>:
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	e8 b0 fe ff ff       	call   801a26 <fd2sockid>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 0f                	js     801b89 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	ff 75 0c             	push   0xc(%ebp)
  801b80:	50                   	push   %eax
  801b81:	e8 6b 01 00 00       	call   801cf1 <nsipc_listen>
  801b86:	83 c4 10             	add    $0x10,%esp
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <socket>:

int
socket(int domain, int type, int protocol)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b91:	ff 75 10             	push   0x10(%ebp)
  801b94:	ff 75 0c             	push   0xc(%ebp)
  801b97:	ff 75 08             	push   0x8(%ebp)
  801b9a:	e8 41 02 00 00       	call   801de0 <nsipc_socket>
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 05                	js     801bab <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ba6:	e8 ab fe ff ff       	call   801a56 <alloc_sockfd>
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 04             	sub    $0x4,%esp
  801bb4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bb6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bbd:	74 26                	je     801be5 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bbf:	6a 07                	push   $0x7
  801bc1:	68 00 70 80 00       	push   $0x807000
  801bc6:	53                   	push   %ebx
  801bc7:	ff 35 00 80 80 00    	push   0x808000
  801bcd:	e8 02 08 00 00       	call   8023d4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd2:	83 c4 0c             	add    $0xc,%esp
  801bd5:	6a 00                	push   $0x0
  801bd7:	6a 00                	push   $0x0
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 84 07 00 00       	call   802364 <ipc_recv>
}
  801be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	6a 02                	push   $0x2
  801bea:	e8 39 08 00 00       	call   802428 <ipc_find_env>
  801bef:	a3 00 80 80 00       	mov    %eax,0x808000
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	eb c6                	jmp    801bbf <nsipc+0x12>

00801bf9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c09:	8b 06                	mov    (%esi),%eax
  801c0b:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c10:	b8 01 00 00 00       	mov    $0x1,%eax
  801c15:	e8 93 ff ff ff       	call   801bad <nsipc>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	79 09                	jns    801c29 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c29:	83 ec 04             	sub    $0x4,%esp
  801c2c:	ff 35 10 70 80 00    	push   0x807010
  801c32:	68 00 70 80 00       	push   $0x807000
  801c37:	ff 75 0c             	push   0xc(%ebp)
  801c3a:	e8 42 ee ff ff       	call   800a81 <memmove>
		*addrlen = ret->ret_addrlen;
  801c3f:	a1 10 70 80 00       	mov    0x807010,%eax
  801c44:	89 06                	mov    %eax,(%esi)
  801c46:	83 c4 10             	add    $0x10,%esp
	return r;
  801c49:	eb d5                	jmp    801c20 <nsipc_accept+0x27>

00801c4b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 08             	sub    $0x8,%esp
  801c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c5d:	53                   	push   %ebx
  801c5e:	ff 75 0c             	push   0xc(%ebp)
  801c61:	68 04 70 80 00       	push   $0x807004
  801c66:	e8 16 ee ff ff       	call   800a81 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c6b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c71:	b8 02 00 00 00       	mov    $0x2,%eax
  801c76:	e8 32 ff ff ff       	call   801bad <nsipc>
}
  801c7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c91:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c96:	b8 03 00 00 00       	mov    $0x3,%eax
  801c9b:	e8 0d ff ff ff       	call   801bad <nsipc>
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <nsipc_close>:

int
nsipc_close(int s)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801cb0:	b8 04 00 00 00       	mov    $0x4,%eax
  801cb5:	e8 f3 fe ff ff       	call   801bad <nsipc>
}
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	53                   	push   %ebx
  801cc0:	83 ec 08             	sub    $0x8,%esp
  801cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cce:	53                   	push   %ebx
  801ccf:	ff 75 0c             	push   0xc(%ebp)
  801cd2:	68 04 70 80 00       	push   $0x807004
  801cd7:	e8 a5 ed ff ff       	call   800a81 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cdc:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ce2:	b8 05 00 00 00       	mov    $0x5,%eax
  801ce7:	e8 c1 fe ff ff       	call   801bad <nsipc>
}
  801cec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801cff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d02:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d07:	b8 06 00 00 00       	mov    $0x6,%eax
  801d0c:	e8 9c fe ff ff       	call   801bad <nsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d23:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d29:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d31:	b8 07 00 00 00       	mov    $0x7,%eax
  801d36:	e8 72 fe ff ff       	call   801bad <nsipc>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 22                	js     801d63 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d41:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d46:	39 c6                	cmp    %eax,%esi
  801d48:	0f 4e c6             	cmovle %esi,%eax
  801d4b:	39 c3                	cmp    %eax,%ebx
  801d4d:	7f 1d                	jg     801d6c <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	53                   	push   %ebx
  801d53:	68 00 70 80 00       	push   $0x807000
  801d58:	ff 75 0c             	push   0xc(%ebp)
  801d5b:	e8 21 ed ff ff       	call   800a81 <memmove>
  801d60:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d63:	89 d8                	mov    %ebx,%eax
  801d65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d6c:	68 c7 2c 80 00       	push   $0x802cc7
  801d71:	68 8f 2c 80 00       	push   $0x802c8f
  801d76:	6a 62                	push   $0x62
  801d78:	68 dc 2c 80 00       	push   $0x802cdc
  801d7d:	e8 b4 e4 ff ff       	call   800236 <_panic>

00801d82 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	53                   	push   %ebx
  801d86:	83 ec 04             	sub    $0x4,%esp
  801d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d94:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d9a:	7f 2e                	jg     801dca <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	53                   	push   %ebx
  801da0:	ff 75 0c             	push   0xc(%ebp)
  801da3:	68 0c 70 80 00       	push   $0x80700c
  801da8:	e8 d4 ec ff ff       	call   800a81 <memmove>
	nsipcbuf.send.req_size = size;
  801dad:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801db3:	8b 45 14             	mov    0x14(%ebp),%eax
  801db6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc0:	e8 e8 fd ff ff       	call   801bad <nsipc>
}
  801dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    
	assert(size < 1600);
  801dca:	68 e8 2c 80 00       	push   $0x802ce8
  801dcf:	68 8f 2c 80 00       	push   $0x802c8f
  801dd4:	6a 6d                	push   $0x6d
  801dd6:	68 dc 2c 80 00       	push   $0x802cdc
  801ddb:	e8 56 e4 ff ff       	call   800236 <_panic>

00801de0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801df6:	8b 45 10             	mov    0x10(%ebp),%eax
  801df9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801dfe:	b8 09 00 00 00       	mov    $0x9,%eax
  801e03:	e8 a5 fd ff ff       	call   801bad <nsipc>
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	56                   	push   %esi
  801e0e:	53                   	push   %ebx
  801e0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	ff 75 08             	push   0x8(%ebp)
  801e18:	e8 ad f3 ff ff       	call   8011ca <fd2data>
  801e1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e1f:	83 c4 08             	add    $0x8,%esp
  801e22:	68 f4 2c 80 00       	push   $0x802cf4
  801e27:	53                   	push   %ebx
  801e28:	e8 be ea ff ff       	call   8008eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e2d:	8b 46 04             	mov    0x4(%esi),%eax
  801e30:	2b 06                	sub    (%esi),%eax
  801e32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e3f:	00 00 00 
	stat->st_dev = &devpipe;
  801e42:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e49:	30 80 00 
	return 0;
}
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e62:	53                   	push   %ebx
  801e63:	6a 00                	push   $0x0
  801e65:	e8 02 ef ff ff       	call   800d6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e6a:	89 1c 24             	mov    %ebx,(%esp)
  801e6d:	e8 58 f3 ff ff       	call   8011ca <fd2data>
  801e72:	83 c4 08             	add    $0x8,%esp
  801e75:	50                   	push   %eax
  801e76:	6a 00                	push   $0x0
  801e78:	e8 ef ee ff ff       	call   800d6c <sys_page_unmap>
}
  801e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <_pipeisclosed>:
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	57                   	push   %edi
  801e86:	56                   	push   %esi
  801e87:	53                   	push   %ebx
  801e88:	83 ec 1c             	sub    $0x1c,%esp
  801e8b:	89 c7                	mov    %eax,%edi
  801e8d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e8f:	a1 00 40 80 00       	mov    0x804000,%eax
  801e94:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e97:	83 ec 0c             	sub    $0xc,%esp
  801e9a:	57                   	push   %edi
  801e9b:	e8 c7 05 00 00       	call   802467 <pageref>
  801ea0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ea3:	89 34 24             	mov    %esi,(%esp)
  801ea6:	e8 bc 05 00 00       	call   802467 <pageref>
		nn = thisenv->env_runs;
  801eab:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801eb1:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	39 cb                	cmp    %ecx,%ebx
  801eb9:	74 1b                	je     801ed6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ebb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ebe:	75 cf                	jne    801e8f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ec0:	8b 42 68             	mov    0x68(%edx),%eax
  801ec3:	6a 01                	push   $0x1
  801ec5:	50                   	push   %eax
  801ec6:	53                   	push   %ebx
  801ec7:	68 fb 2c 80 00       	push   $0x802cfb
  801ecc:	e8 40 e4 ff ff       	call   800311 <cprintf>
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	eb b9                	jmp    801e8f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ed6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ed9:	0f 94 c0             	sete   %al
  801edc:	0f b6 c0             	movzbl %al,%eax
}
  801edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5f                   	pop    %edi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <devpipe_write>:
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	57                   	push   %edi
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 28             	sub    $0x28,%esp
  801ef0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ef3:	56                   	push   %esi
  801ef4:	e8 d1 f2 ff ff       	call   8011ca <fd2data>
  801ef9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	bf 00 00 00 00       	mov    $0x0,%edi
  801f03:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f06:	75 09                	jne    801f11 <devpipe_write+0x2a>
	return i;
  801f08:	89 f8                	mov    %edi,%eax
  801f0a:	eb 23                	jmp    801f2f <devpipe_write+0x48>
			sys_yield();
  801f0c:	e8 b7 ed ff ff       	call   800cc8 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f11:	8b 43 04             	mov    0x4(%ebx),%eax
  801f14:	8b 0b                	mov    (%ebx),%ecx
  801f16:	8d 51 20             	lea    0x20(%ecx),%edx
  801f19:	39 d0                	cmp    %edx,%eax
  801f1b:	72 1a                	jb     801f37 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f1d:	89 da                	mov    %ebx,%edx
  801f1f:	89 f0                	mov    %esi,%eax
  801f21:	e8 5c ff ff ff       	call   801e82 <_pipeisclosed>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	74 e2                	je     801f0c <devpipe_write+0x25>
				return 0;
  801f2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f3e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f41:	89 c2                	mov    %eax,%edx
  801f43:	c1 fa 1f             	sar    $0x1f,%edx
  801f46:	89 d1                	mov    %edx,%ecx
  801f48:	c1 e9 1b             	shr    $0x1b,%ecx
  801f4b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f4e:	83 e2 1f             	and    $0x1f,%edx
  801f51:	29 ca                	sub    %ecx,%edx
  801f53:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f57:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f5b:	83 c0 01             	add    $0x1,%eax
  801f5e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f61:	83 c7 01             	add    $0x1,%edi
  801f64:	eb 9d                	jmp    801f03 <devpipe_write+0x1c>

00801f66 <devpipe_read>:
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	57                   	push   %edi
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 18             	sub    $0x18,%esp
  801f6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f72:	57                   	push   %edi
  801f73:	e8 52 f2 ff ff       	call   8011ca <fd2data>
  801f78:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	be 00 00 00 00       	mov    $0x0,%esi
  801f82:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f85:	75 13                	jne    801f9a <devpipe_read+0x34>
	return i;
  801f87:	89 f0                	mov    %esi,%eax
  801f89:	eb 02                	jmp    801f8d <devpipe_read+0x27>
				return i;
  801f8b:	89 f0                	mov    %esi,%eax
}
  801f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f90:	5b                   	pop    %ebx
  801f91:	5e                   	pop    %esi
  801f92:	5f                   	pop    %edi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    
			sys_yield();
  801f95:	e8 2e ed ff ff       	call   800cc8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f9a:	8b 03                	mov    (%ebx),%eax
  801f9c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f9f:	75 18                	jne    801fb9 <devpipe_read+0x53>
			if (i > 0)
  801fa1:	85 f6                	test   %esi,%esi
  801fa3:	75 e6                	jne    801f8b <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801fa5:	89 da                	mov    %ebx,%edx
  801fa7:	89 f8                	mov    %edi,%eax
  801fa9:	e8 d4 fe ff ff       	call   801e82 <_pipeisclosed>
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	74 e3                	je     801f95 <devpipe_read+0x2f>
				return 0;
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb7:	eb d4                	jmp    801f8d <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fb9:	99                   	cltd   
  801fba:	c1 ea 1b             	shr    $0x1b,%edx
  801fbd:	01 d0                	add    %edx,%eax
  801fbf:	83 e0 1f             	and    $0x1f,%eax
  801fc2:	29 d0                	sub    %edx,%eax
  801fc4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fcc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fcf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fd2:	83 c6 01             	add    $0x1,%esi
  801fd5:	eb ab                	jmp    801f82 <devpipe_read+0x1c>

00801fd7 <pipe>:
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe2:	50                   	push   %eax
  801fe3:	e8 f9 f1 ff ff       	call   8011e1 <fd_alloc>
  801fe8:	89 c3                	mov    %eax,%ebx
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	85 c0                	test   %eax,%eax
  801fef:	0f 88 23 01 00 00    	js     802118 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff5:	83 ec 04             	sub    $0x4,%esp
  801ff8:	68 07 04 00 00       	push   $0x407
  801ffd:	ff 75 f4             	push   -0xc(%ebp)
  802000:	6a 00                	push   $0x0
  802002:	e8 e0 ec ff ff       	call   800ce7 <sys_page_alloc>
  802007:	89 c3                	mov    %eax,%ebx
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	85 c0                	test   %eax,%eax
  80200e:	0f 88 04 01 00 00    	js     802118 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802014:	83 ec 0c             	sub    $0xc,%esp
  802017:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80201a:	50                   	push   %eax
  80201b:	e8 c1 f1 ff ff       	call   8011e1 <fd_alloc>
  802020:	89 c3                	mov    %eax,%ebx
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	85 c0                	test   %eax,%eax
  802027:	0f 88 db 00 00 00    	js     802108 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202d:	83 ec 04             	sub    $0x4,%esp
  802030:	68 07 04 00 00       	push   $0x407
  802035:	ff 75 f0             	push   -0x10(%ebp)
  802038:	6a 00                	push   $0x0
  80203a:	e8 a8 ec ff ff       	call   800ce7 <sys_page_alloc>
  80203f:	89 c3                	mov    %eax,%ebx
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	85 c0                	test   %eax,%eax
  802046:	0f 88 bc 00 00 00    	js     802108 <pipe+0x131>
	va = fd2data(fd0);
  80204c:	83 ec 0c             	sub    $0xc,%esp
  80204f:	ff 75 f4             	push   -0xc(%ebp)
  802052:	e8 73 f1 ff ff       	call   8011ca <fd2data>
  802057:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802059:	83 c4 0c             	add    $0xc,%esp
  80205c:	68 07 04 00 00       	push   $0x407
  802061:	50                   	push   %eax
  802062:	6a 00                	push   $0x0
  802064:	e8 7e ec ff ff       	call   800ce7 <sys_page_alloc>
  802069:	89 c3                	mov    %eax,%ebx
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	85 c0                	test   %eax,%eax
  802070:	0f 88 82 00 00 00    	js     8020f8 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802076:	83 ec 0c             	sub    $0xc,%esp
  802079:	ff 75 f0             	push   -0x10(%ebp)
  80207c:	e8 49 f1 ff ff       	call   8011ca <fd2data>
  802081:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802088:	50                   	push   %eax
  802089:	6a 00                	push   $0x0
  80208b:	56                   	push   %esi
  80208c:	6a 00                	push   $0x0
  80208e:	e8 97 ec ff ff       	call   800d2a <sys_page_map>
  802093:	89 c3                	mov    %eax,%ebx
  802095:	83 c4 20             	add    $0x20,%esp
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 4e                	js     8020ea <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80209c:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8020a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8020a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020b3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020bf:	83 ec 0c             	sub    $0xc,%esp
  8020c2:	ff 75 f4             	push   -0xc(%ebp)
  8020c5:	e8 f0 f0 ff ff       	call   8011ba <fd2num>
  8020ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020cd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020cf:	83 c4 04             	add    $0x4,%esp
  8020d2:	ff 75 f0             	push   -0x10(%ebp)
  8020d5:	e8 e0 f0 ff ff       	call   8011ba <fd2num>
  8020da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020dd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020e8:	eb 2e                	jmp    802118 <pipe+0x141>
	sys_page_unmap(0, va);
  8020ea:	83 ec 08             	sub    $0x8,%esp
  8020ed:	56                   	push   %esi
  8020ee:	6a 00                	push   $0x0
  8020f0:	e8 77 ec ff ff       	call   800d6c <sys_page_unmap>
  8020f5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020f8:	83 ec 08             	sub    $0x8,%esp
  8020fb:	ff 75 f0             	push   -0x10(%ebp)
  8020fe:	6a 00                	push   $0x0
  802100:	e8 67 ec ff ff       	call   800d6c <sys_page_unmap>
  802105:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802108:	83 ec 08             	sub    $0x8,%esp
  80210b:	ff 75 f4             	push   -0xc(%ebp)
  80210e:	6a 00                	push   $0x0
  802110:	e8 57 ec ff ff       	call   800d6c <sys_page_unmap>
  802115:	83 c4 10             	add    $0x10,%esp
}
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    

00802121 <pipeisclosed>:
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212a:	50                   	push   %eax
  80212b:	ff 75 08             	push   0x8(%ebp)
  80212e:	e8 fe f0 ff ff       	call   801231 <fd_lookup>
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	85 c0                	test   %eax,%eax
  802138:	78 18                	js     802152 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80213a:	83 ec 0c             	sub    $0xc,%esp
  80213d:	ff 75 f4             	push   -0xc(%ebp)
  802140:	e8 85 f0 ff ff       	call   8011ca <fd2data>
  802145:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802147:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214a:	e8 33 fd ff ff       	call   801e82 <_pipeisclosed>
  80214f:	83 c4 10             	add    $0x10,%esp
}
  802152:	c9                   	leave  
  802153:	c3                   	ret    

00802154 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802154:	b8 00 00 00 00       	mov    $0x0,%eax
  802159:	c3                   	ret    

0080215a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802160:	68 13 2d 80 00       	push   $0x802d13
  802165:	ff 75 0c             	push   0xc(%ebp)
  802168:	e8 7e e7 ff ff       	call   8008eb <strcpy>
	return 0;
}
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
  802172:	c9                   	leave  
  802173:	c3                   	ret    

00802174 <devcons_write>:
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	57                   	push   %edi
  802178:	56                   	push   %esi
  802179:	53                   	push   %ebx
  80217a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802180:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802185:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80218b:	eb 2e                	jmp    8021bb <devcons_write+0x47>
		m = n - tot;
  80218d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802190:	29 f3                	sub    %esi,%ebx
  802192:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802197:	39 c3                	cmp    %eax,%ebx
  802199:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80219c:	83 ec 04             	sub    $0x4,%esp
  80219f:	53                   	push   %ebx
  8021a0:	89 f0                	mov    %esi,%eax
  8021a2:	03 45 0c             	add    0xc(%ebp),%eax
  8021a5:	50                   	push   %eax
  8021a6:	57                   	push   %edi
  8021a7:	e8 d5 e8 ff ff       	call   800a81 <memmove>
		sys_cputs(buf, m);
  8021ac:	83 c4 08             	add    $0x8,%esp
  8021af:	53                   	push   %ebx
  8021b0:	57                   	push   %edi
  8021b1:	e8 75 ea ff ff       	call   800c2b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021b6:	01 de                	add    %ebx,%esi
  8021b8:	83 c4 10             	add    $0x10,%esp
  8021bb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021be:	72 cd                	jb     80218d <devcons_write+0x19>
}
  8021c0:	89 f0                	mov    %esi,%eax
  8021c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c5:	5b                   	pop    %ebx
  8021c6:	5e                   	pop    %esi
  8021c7:	5f                   	pop    %edi
  8021c8:	5d                   	pop    %ebp
  8021c9:	c3                   	ret    

008021ca <devcons_read>:
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	83 ec 08             	sub    $0x8,%esp
  8021d0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d9:	75 07                	jne    8021e2 <devcons_read+0x18>
  8021db:	eb 1f                	jmp    8021fc <devcons_read+0x32>
		sys_yield();
  8021dd:	e8 e6 ea ff ff       	call   800cc8 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8021e2:	e8 62 ea ff ff       	call   800c49 <sys_cgetc>
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	74 f2                	je     8021dd <devcons_read+0x13>
	if (c < 0)
  8021eb:	78 0f                	js     8021fc <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8021ed:	83 f8 04             	cmp    $0x4,%eax
  8021f0:	74 0c                	je     8021fe <devcons_read+0x34>
	*(char*)vbuf = c;
  8021f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f5:	88 02                	mov    %al,(%edx)
	return 1;
  8021f7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    
		return 0;
  8021fe:	b8 00 00 00 00       	mov    $0x0,%eax
  802203:	eb f7                	jmp    8021fc <devcons_read+0x32>

00802205 <cputchar>:
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802211:	6a 01                	push   $0x1
  802213:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802216:	50                   	push   %eax
  802217:	e8 0f ea ff ff       	call   800c2b <sys_cputs>
}
  80221c:	83 c4 10             	add    $0x10,%esp
  80221f:	c9                   	leave  
  802220:	c3                   	ret    

00802221 <getchar>:
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802227:	6a 01                	push   $0x1
  802229:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222c:	50                   	push   %eax
  80222d:	6a 00                	push   $0x0
  80222f:	e8 66 f2 ff ff       	call   80149a <read>
	if (r < 0)
  802234:	83 c4 10             	add    $0x10,%esp
  802237:	85 c0                	test   %eax,%eax
  802239:	78 06                	js     802241 <getchar+0x20>
	if (r < 1)
  80223b:	74 06                	je     802243 <getchar+0x22>
	return c;
  80223d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802241:	c9                   	leave  
  802242:	c3                   	ret    
		return -E_EOF;
  802243:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802248:	eb f7                	jmp    802241 <getchar+0x20>

0080224a <iscons>:
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802250:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802253:	50                   	push   %eax
  802254:	ff 75 08             	push   0x8(%ebp)
  802257:	e8 d5 ef ff ff       	call   801231 <fd_lookup>
  80225c:	83 c4 10             	add    $0x10,%esp
  80225f:	85 c0                	test   %eax,%eax
  802261:	78 11                	js     802274 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802266:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80226c:	39 10                	cmp    %edx,(%eax)
  80226e:	0f 94 c0             	sete   %al
  802271:	0f b6 c0             	movzbl %al,%eax
}
  802274:	c9                   	leave  
  802275:	c3                   	ret    

00802276 <opencons>:
{
  802276:	55                   	push   %ebp
  802277:	89 e5                	mov    %esp,%ebp
  802279:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80227c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227f:	50                   	push   %eax
  802280:	e8 5c ef ff ff       	call   8011e1 <fd_alloc>
  802285:	83 c4 10             	add    $0x10,%esp
  802288:	85 c0                	test   %eax,%eax
  80228a:	78 3a                	js     8022c6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228c:	83 ec 04             	sub    $0x4,%esp
  80228f:	68 07 04 00 00       	push   $0x407
  802294:	ff 75 f4             	push   -0xc(%ebp)
  802297:	6a 00                	push   $0x0
  802299:	e8 49 ea ff ff       	call   800ce7 <sys_page_alloc>
  80229e:	83 c4 10             	add    $0x10,%esp
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	78 21                	js     8022c6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8022a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ae:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022ba:	83 ec 0c             	sub    $0xc,%esp
  8022bd:	50                   	push   %eax
  8022be:	e8 f7 ee ff ff       	call   8011ba <fd2num>
  8022c3:	83 c4 10             	add    $0x10,%esp
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022ce:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022d5:	74 0a                	je     8022e1 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022da:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8022df:	c9                   	leave  
  8022e0:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8022e1:	e8 c3 e9 ff ff       	call   800ca9 <sys_getenvid>
  8022e6:	83 ec 04             	sub    $0x4,%esp
  8022e9:	68 07 0e 00 00       	push   $0xe07
  8022ee:	68 00 f0 bf ee       	push   $0xeebff000
  8022f3:	50                   	push   %eax
  8022f4:	e8 ee e9 ff ff       	call   800ce7 <sys_page_alloc>
		if (r < 0) {
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	78 2c                	js     80232c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802300:	e8 a4 e9 ff ff       	call   800ca9 <sys_getenvid>
  802305:	83 ec 08             	sub    $0x8,%esp
  802308:	68 3e 23 80 00       	push   $0x80233e
  80230d:	50                   	push   %eax
  80230e:	e8 1f eb ff ff       	call   800e32 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802313:	83 c4 10             	add    $0x10,%esp
  802316:	85 c0                	test   %eax,%eax
  802318:	79 bd                	jns    8022d7 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80231a:	50                   	push   %eax
  80231b:	68 60 2d 80 00       	push   $0x802d60
  802320:	6a 28                	push   $0x28
  802322:	68 96 2d 80 00       	push   $0x802d96
  802327:	e8 0a df ff ff       	call   800236 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80232c:	50                   	push   %eax
  80232d:	68 20 2d 80 00       	push   $0x802d20
  802332:	6a 23                	push   $0x23
  802334:	68 96 2d 80 00       	push   $0x802d96
  802339:	e8 f8 de ff ff       	call   800236 <_panic>

0080233e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80233e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80233f:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802344:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802346:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802349:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80234d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802350:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802354:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802358:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80235a:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80235d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80235e:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802361:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802362:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802363:	c3                   	ret    

00802364 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	56                   	push   %esi
  802368:	53                   	push   %ebx
  802369:	8b 75 08             	mov    0x8(%ebp),%esi
  80236c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802372:	85 c0                	test   %eax,%eax
  802374:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802379:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80237c:	83 ec 0c             	sub    $0xc,%esp
  80237f:	50                   	push   %eax
  802380:	e8 12 eb ff ff       	call   800e97 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802385:	83 c4 10             	add    $0x10,%esp
  802388:	85 f6                	test   %esi,%esi
  80238a:	74 17                	je     8023a3 <ipc_recv+0x3f>
  80238c:	ba 00 00 00 00       	mov    $0x0,%edx
  802391:	85 c0                	test   %eax,%eax
  802393:	78 0c                	js     8023a1 <ipc_recv+0x3d>
  802395:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80239b:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8023a1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8023a3:	85 db                	test   %ebx,%ebx
  8023a5:	74 17                	je     8023be <ipc_recv+0x5a>
  8023a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	78 0c                	js     8023bc <ipc_recv+0x58>
  8023b0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8023b6:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8023bc:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	78 0b                	js     8023cd <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8023c2:	a1 00 40 80 00       	mov    0x804000,%eax
  8023c7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8023cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	57                   	push   %edi
  8023d8:	56                   	push   %esi
  8023d9:	53                   	push   %ebx
  8023da:	83 ec 0c             	sub    $0xc,%esp
  8023dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8023e6:	85 db                	test   %ebx,%ebx
  8023e8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023ed:	0f 44 d8             	cmove  %eax,%ebx
  8023f0:	eb 05                	jmp    8023f7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023f2:	e8 d1 e8 ff ff       	call   800cc8 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8023f7:	ff 75 14             	push   0x14(%ebp)
  8023fa:	53                   	push   %ebx
  8023fb:	56                   	push   %esi
  8023fc:	57                   	push   %edi
  8023fd:	e8 72 ea ff ff       	call   800e74 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802402:	83 c4 10             	add    $0x10,%esp
  802405:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802408:	74 e8                	je     8023f2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80240a:	85 c0                	test   %eax,%eax
  80240c:	78 08                	js     802416 <ipc_send+0x42>
	}while (r<0);

}
  80240e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802411:	5b                   	pop    %ebx
  802412:	5e                   	pop    %esi
  802413:	5f                   	pop    %edi
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802416:	50                   	push   %eax
  802417:	68 a4 2d 80 00       	push   $0x802da4
  80241c:	6a 3d                	push   $0x3d
  80241e:	68 b8 2d 80 00       	push   $0x802db8
  802423:	e8 0e de ff ff       	call   800236 <_panic>

00802428 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80242e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802433:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802439:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80243f:	8b 52 60             	mov    0x60(%edx),%edx
  802442:	39 ca                	cmp    %ecx,%edx
  802444:	74 11                	je     802457 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802446:	83 c0 01             	add    $0x1,%eax
  802449:	3d 00 04 00 00       	cmp    $0x400,%eax
  80244e:	75 e3                	jne    802433 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802450:	b8 00 00 00 00       	mov    $0x0,%eax
  802455:	eb 0e                	jmp    802465 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802457:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80245d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802462:	8b 40 58             	mov    0x58(%eax),%eax
}
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246d:	89 c2                	mov    %eax,%edx
  80246f:	c1 ea 16             	shr    $0x16,%edx
  802472:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802479:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80247e:	f6 c1 01             	test   $0x1,%cl
  802481:	74 1c                	je     80249f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802483:	c1 e8 0c             	shr    $0xc,%eax
  802486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80248d:	a8 01                	test   $0x1,%al
  80248f:	74 0e                	je     80249f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802491:	c1 e8 0c             	shr    $0xc,%eax
  802494:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80249b:	ef 
  80249c:	0f b7 d2             	movzwl %dx,%edx
}
  80249f:	89 d0                	mov    %edx,%eax
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    
  8024a3:	66 90                	xchg   %ax,%ax
  8024a5:	66 90                	xchg   %ax,%ax
  8024a7:	66 90                	xchg   %ax,%ax
  8024a9:	66 90                	xchg   %ax,%ax
  8024ab:	66 90                	xchg   %ax,%ax
  8024ad:	66 90                	xchg   %ax,%ax
  8024af:	90                   	nop

008024b0 <__udivdi3>:
  8024b0:	f3 0f 1e fb          	endbr32 
  8024b4:	55                   	push   %ebp
  8024b5:	57                   	push   %edi
  8024b6:	56                   	push   %esi
  8024b7:	53                   	push   %ebx
  8024b8:	83 ec 1c             	sub    $0x1c,%esp
  8024bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	75 19                	jne    8024e8 <__udivdi3+0x38>
  8024cf:	39 f3                	cmp    %esi,%ebx
  8024d1:	76 4d                	jbe    802520 <__udivdi3+0x70>
  8024d3:	31 ff                	xor    %edi,%edi
  8024d5:	89 e8                	mov    %ebp,%eax
  8024d7:	89 f2                	mov    %esi,%edx
  8024d9:	f7 f3                	div    %ebx
  8024db:	89 fa                	mov    %edi,%edx
  8024dd:	83 c4 1c             	add    $0x1c,%esp
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
  8024e8:	39 f0                	cmp    %esi,%eax
  8024ea:	76 14                	jbe    802500 <__udivdi3+0x50>
  8024ec:	31 ff                	xor    %edi,%edi
  8024ee:	31 c0                	xor    %eax,%eax
  8024f0:	89 fa                	mov    %edi,%edx
  8024f2:	83 c4 1c             	add    $0x1c,%esp
  8024f5:	5b                   	pop    %ebx
  8024f6:	5e                   	pop    %esi
  8024f7:	5f                   	pop    %edi
  8024f8:	5d                   	pop    %ebp
  8024f9:	c3                   	ret    
  8024fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802500:	0f bd f8             	bsr    %eax,%edi
  802503:	83 f7 1f             	xor    $0x1f,%edi
  802506:	75 48                	jne    802550 <__udivdi3+0xa0>
  802508:	39 f0                	cmp    %esi,%eax
  80250a:	72 06                	jb     802512 <__udivdi3+0x62>
  80250c:	31 c0                	xor    %eax,%eax
  80250e:	39 eb                	cmp    %ebp,%ebx
  802510:	77 de                	ja     8024f0 <__udivdi3+0x40>
  802512:	b8 01 00 00 00       	mov    $0x1,%eax
  802517:	eb d7                	jmp    8024f0 <__udivdi3+0x40>
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d9                	mov    %ebx,%ecx
  802522:	85 db                	test   %ebx,%ebx
  802524:	75 0b                	jne    802531 <__udivdi3+0x81>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f3                	div    %ebx
  80252f:	89 c1                	mov    %eax,%ecx
  802531:	31 d2                	xor    %edx,%edx
  802533:	89 f0                	mov    %esi,%eax
  802535:	f7 f1                	div    %ecx
  802537:	89 c6                	mov    %eax,%esi
  802539:	89 e8                	mov    %ebp,%eax
  80253b:	89 f7                	mov    %esi,%edi
  80253d:	f7 f1                	div    %ecx
  80253f:	89 fa                	mov    %edi,%edx
  802541:	83 c4 1c             	add    $0x1c,%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5f                   	pop    %edi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 f9                	mov    %edi,%ecx
  802552:	ba 20 00 00 00       	mov    $0x20,%edx
  802557:	29 fa                	sub    %edi,%edx
  802559:	d3 e0                	shl    %cl,%eax
  80255b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255f:	89 d1                	mov    %edx,%ecx
  802561:	89 d8                	mov    %ebx,%eax
  802563:	d3 e8                	shr    %cl,%eax
  802565:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802569:	09 c1                	or     %eax,%ecx
  80256b:	89 f0                	mov    %esi,%eax
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f9                	mov    %edi,%ecx
  802573:	d3 e3                	shl    %cl,%ebx
  802575:	89 d1                	mov    %edx,%ecx
  802577:	d3 e8                	shr    %cl,%eax
  802579:	89 f9                	mov    %edi,%ecx
  80257b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80257f:	89 eb                	mov    %ebp,%ebx
  802581:	d3 e6                	shl    %cl,%esi
  802583:	89 d1                	mov    %edx,%ecx
  802585:	d3 eb                	shr    %cl,%ebx
  802587:	09 f3                	or     %esi,%ebx
  802589:	89 c6                	mov    %eax,%esi
  80258b:	89 f2                	mov    %esi,%edx
  80258d:	89 d8                	mov    %ebx,%eax
  80258f:	f7 74 24 08          	divl   0x8(%esp)
  802593:	89 d6                	mov    %edx,%esi
  802595:	89 c3                	mov    %eax,%ebx
  802597:	f7 64 24 0c          	mull   0xc(%esp)
  80259b:	39 d6                	cmp    %edx,%esi
  80259d:	72 19                	jb     8025b8 <__udivdi3+0x108>
  80259f:	89 f9                	mov    %edi,%ecx
  8025a1:	d3 e5                	shl    %cl,%ebp
  8025a3:	39 c5                	cmp    %eax,%ebp
  8025a5:	73 04                	jae    8025ab <__udivdi3+0xfb>
  8025a7:	39 d6                	cmp    %edx,%esi
  8025a9:	74 0d                	je     8025b8 <__udivdi3+0x108>
  8025ab:	89 d8                	mov    %ebx,%eax
  8025ad:	31 ff                	xor    %edi,%edi
  8025af:	e9 3c ff ff ff       	jmp    8024f0 <__udivdi3+0x40>
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025bb:	31 ff                	xor    %edi,%edi
  8025bd:	e9 2e ff ff ff       	jmp    8024f0 <__udivdi3+0x40>
  8025c2:	66 90                	xchg   %ax,%ax
  8025c4:	66 90                	xchg   %ax,%ax
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	66 90                	xchg   %ax,%ax
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__umoddi3>:
  8025d0:	f3 0f 1e fb          	endbr32 
  8025d4:	55                   	push   %ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
  8025d8:	83 ec 1c             	sub    $0x1c,%esp
  8025db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025eb:	89 f0                	mov    %esi,%eax
  8025ed:	89 da                	mov    %ebx,%edx
  8025ef:	85 ff                	test   %edi,%edi
  8025f1:	75 15                	jne    802608 <__umoddi3+0x38>
  8025f3:	39 dd                	cmp    %ebx,%ebp
  8025f5:	76 39                	jbe    802630 <__umoddi3+0x60>
  8025f7:	f7 f5                	div    %ebp
  8025f9:	89 d0                	mov    %edx,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	83 c4 1c             	add    $0x1c,%esp
  802600:	5b                   	pop    %ebx
  802601:	5e                   	pop    %esi
  802602:	5f                   	pop    %edi
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    
  802605:	8d 76 00             	lea    0x0(%esi),%esi
  802608:	39 df                	cmp    %ebx,%edi
  80260a:	77 f1                	ja     8025fd <__umoddi3+0x2d>
  80260c:	0f bd cf             	bsr    %edi,%ecx
  80260f:	83 f1 1f             	xor    $0x1f,%ecx
  802612:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802616:	75 40                	jne    802658 <__umoddi3+0x88>
  802618:	39 df                	cmp    %ebx,%edi
  80261a:	72 04                	jb     802620 <__umoddi3+0x50>
  80261c:	39 f5                	cmp    %esi,%ebp
  80261e:	77 dd                	ja     8025fd <__umoddi3+0x2d>
  802620:	89 da                	mov    %ebx,%edx
  802622:	89 f0                	mov    %esi,%eax
  802624:	29 e8                	sub    %ebp,%eax
  802626:	19 fa                	sbb    %edi,%edx
  802628:	eb d3                	jmp    8025fd <__umoddi3+0x2d>
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	89 e9                	mov    %ebp,%ecx
  802632:	85 ed                	test   %ebp,%ebp
  802634:	75 0b                	jne    802641 <__umoddi3+0x71>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f5                	div    %ebp
  80263f:	89 c1                	mov    %eax,%ecx
  802641:	89 d8                	mov    %ebx,%eax
  802643:	31 d2                	xor    %edx,%edx
  802645:	f7 f1                	div    %ecx
  802647:	89 f0                	mov    %esi,%eax
  802649:	f7 f1                	div    %ecx
  80264b:	89 d0                	mov    %edx,%eax
  80264d:	31 d2                	xor    %edx,%edx
  80264f:	eb ac                	jmp    8025fd <__umoddi3+0x2d>
  802651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802658:	8b 44 24 04          	mov    0x4(%esp),%eax
  80265c:	ba 20 00 00 00       	mov    $0x20,%edx
  802661:	29 c2                	sub    %eax,%edx
  802663:	89 c1                	mov    %eax,%ecx
  802665:	89 e8                	mov    %ebp,%eax
  802667:	d3 e7                	shl    %cl,%edi
  802669:	89 d1                	mov    %edx,%ecx
  80266b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80266f:	d3 e8                	shr    %cl,%eax
  802671:	89 c1                	mov    %eax,%ecx
  802673:	8b 44 24 04          	mov    0x4(%esp),%eax
  802677:	09 f9                	or     %edi,%ecx
  802679:	89 df                	mov    %ebx,%edi
  80267b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80267f:	89 c1                	mov    %eax,%ecx
  802681:	d3 e5                	shl    %cl,%ebp
  802683:	89 d1                	mov    %edx,%ecx
  802685:	d3 ef                	shr    %cl,%edi
  802687:	89 c1                	mov    %eax,%ecx
  802689:	89 f0                	mov    %esi,%eax
  80268b:	d3 e3                	shl    %cl,%ebx
  80268d:	89 d1                	mov    %edx,%ecx
  80268f:	89 fa                	mov    %edi,%edx
  802691:	d3 e8                	shr    %cl,%eax
  802693:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802698:	09 d8                	or     %ebx,%eax
  80269a:	f7 74 24 08          	divl   0x8(%esp)
  80269e:	89 d3                	mov    %edx,%ebx
  8026a0:	d3 e6                	shl    %cl,%esi
  8026a2:	f7 e5                	mul    %ebp
  8026a4:	89 c7                	mov    %eax,%edi
  8026a6:	89 d1                	mov    %edx,%ecx
  8026a8:	39 d3                	cmp    %edx,%ebx
  8026aa:	72 06                	jb     8026b2 <__umoddi3+0xe2>
  8026ac:	75 0e                	jne    8026bc <__umoddi3+0xec>
  8026ae:	39 c6                	cmp    %eax,%esi
  8026b0:	73 0a                	jae    8026bc <__umoddi3+0xec>
  8026b2:	29 e8                	sub    %ebp,%eax
  8026b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026b8:	89 d1                	mov    %edx,%ecx
  8026ba:	89 c7                	mov    %eax,%edi
  8026bc:	89 f5                	mov    %esi,%ebp
  8026be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026c2:	29 fd                	sub    %edi,%ebp
  8026c4:	19 cb                	sbb    %ecx,%ebx
  8026c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026cb:	89 d8                	mov    %ebx,%eax
  8026cd:	d3 e0                	shl    %cl,%eax
  8026cf:	89 f1                	mov    %esi,%ecx
  8026d1:	d3 ed                	shr    %cl,%ebp
  8026d3:	d3 eb                	shr    %cl,%ebx
  8026d5:	09 e8                	or     %ebp,%eax
  8026d7:	89 da                	mov    %ebx,%edx
  8026d9:	83 c4 1c             	add    $0x1c,%esp
  8026dc:	5b                   	pop    %ebx
  8026dd:	5e                   	pop    %esi
  8026de:	5f                   	pop    %edi
  8026df:	5d                   	pop    %ebp
  8026e0:	c3                   	ret    
