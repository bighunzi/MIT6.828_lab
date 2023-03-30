
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
  80002c:	e8 9f 01 00 00       	call   8001d0 <libmain>
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
  80003c:	68 e0 26 80 00       	push   $0x8026e0
  800041:	e8 c5 02 00 00       	call   80030b <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 7d 1f 00 00       	call   801fce <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	78 5b                	js     8000b3 <umain+0x80>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  800058:	e8 d4 0f 00 00       	call   801031 <fork>
  80005d:	89 c7                	mov    %eax,%edi
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 62                	js     8000c5 <umain+0x92>
		panic("fork: %e", r);
	if (r == 0) {
  800063:	74 72                	je     8000d7 <umain+0xa4>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800065:	89 fb                	mov    %edi,%ebx
  800067:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80006d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800070:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800076:	8b 43 54             	mov    0x54(%ebx),%eax
  800079:	83 f8 02             	cmp    $0x2,%eax
  80007c:	0f 85 d1 00 00 00    	jne    800153 <umain+0x120>
		if (pipeisclosed(p[0]) != 0) {
  800082:	83 ec 0c             	sub    $0xc,%esp
  800085:	ff 75 e0             	push   -0x20(%ebp)
  800088:	e8 8b 20 00 00       	call   802118 <pipeisclosed>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	74 e2                	je     800076 <umain+0x43>
			cprintf("\nRACE: pipe appears closed\n");
  800094:	83 ec 0c             	sub    $0xc,%esp
  800097:	68 50 27 80 00       	push   $0x802750
  80009c:	e8 6a 02 00 00       	call   80030b <cprintf>
			sys_env_destroy(r);
  8000a1:	89 3c 24             	mov    %edi,(%esp)
  8000a4:	e8 b9 0b 00 00       	call   800c62 <sys_env_destroy>
			exit();
  8000a9:	e8 68 01 00 00       	call   800216 <exit>
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	eb c3                	jmp    800076 <umain+0x43>
		panic("pipe: %e", r);
  8000b3:	50                   	push   %eax
  8000b4:	68 2e 27 80 00       	push   $0x80272e
  8000b9:	6a 0d                	push   $0xd
  8000bb:	68 37 27 80 00       	push   $0x802737
  8000c0:	e8 6b 01 00 00       	call   800230 <_panic>
		panic("fork: %e", r);
  8000c5:	50                   	push   %eax
  8000c6:	68 b8 2b 80 00       	push   $0x802bb8
  8000cb:	6a 0f                	push   $0xf
  8000cd:	68 37 27 80 00       	push   $0x802737
  8000d2:	e8 59 01 00 00       	call   800230 <_panic>
		close(p[1]);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	ff 75 e4             	push   -0x1c(%ebp)
  8000dd:	e8 73 12 00 00       	call   801355 <close>
  8000e2:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  8000e5:	89 fb                	mov    %edi,%ebx
			if (i % 10 == 0)
  8000e7:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000ec:	eb 31                	jmp    80011f <umain+0xec>
			dup(p[0], 10);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	6a 0a                	push   $0xa
  8000f3:	ff 75 e0             	push   -0x20(%ebp)
  8000f6:	e8 ac 12 00 00       	call   8013a7 <dup>
			sys_yield();
  8000fb:	e8 c2 0b 00 00       	call   800cc2 <sys_yield>
			close(10);
  800100:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800107:	e8 49 12 00 00       	call   801355 <close>
			sys_yield();
  80010c:	e8 b1 0b 00 00       	call   800cc2 <sys_yield>
		for (i = 0; i < 200; i++) {
  800111:	83 c3 01             	add    $0x1,%ebx
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  80011d:	74 2a                	je     800149 <umain+0x116>
			if (i % 10 == 0)
  80011f:	89 d8                	mov    %ebx,%eax
  800121:	f7 ee                	imul   %esi
  800123:	c1 fa 02             	sar    $0x2,%edx
  800126:	89 d8                	mov    %ebx,%eax
  800128:	c1 f8 1f             	sar    $0x1f,%eax
  80012b:	29 c2                	sub    %eax,%edx
  80012d:	8d 04 92             	lea    (%edx,%edx,4),%eax
  800130:	01 c0                	add    %eax,%eax
  800132:	39 c3                	cmp    %eax,%ebx
  800134:	75 b8                	jne    8000ee <umain+0xbb>
				cprintf("%d.", i);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	53                   	push   %ebx
  80013a:	68 4c 27 80 00       	push   $0x80274c
  80013f:	e8 c7 01 00 00       	call   80030b <cprintf>
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	eb a5                	jmp    8000ee <umain+0xbb>
		exit();
  800149:	e8 c8 00 00 00       	call   800216 <exit>
  80014e:	e9 12 ff ff ff       	jmp    800065 <umain+0x32>
		}
	cprintf("child done with loop\n");
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	68 6c 27 80 00       	push   $0x80276c
  80015b:	e8 ab 01 00 00       	call   80030b <cprintf>
	if (pipeisclosed(p[0]))
  800160:	83 c4 04             	add    $0x4,%esp
  800163:	ff 75 e0             	push   -0x20(%ebp)
  800166:	e8 ad 1f 00 00       	call   802118 <pipeisclosed>
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	85 c0                	test   %eax,%eax
  800170:	75 38                	jne    8001aa <umain+0x177>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	ff 75 e0             	push   -0x20(%ebp)
  80017c:	e8 a7 10 00 00       	call   801228 <fd_lookup>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	85 c0                	test   %eax,%eax
  800186:	78 36                	js     8001be <umain+0x18b>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 dc             	push   -0x24(%ebp)
  80018e:	e8 2e 10 00 00       	call   8011c1 <fd2data>
	cprintf("race didn't happen\n");
  800193:	c7 04 24 9a 27 80 00 	movl   $0x80279a,(%esp)
  80019a:	e8 6c 01 00 00       	call   80030b <cprintf>
}
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a5:	5b                   	pop    %ebx
  8001a6:	5e                   	pop    %esi
  8001a7:	5f                   	pop    %edi
  8001a8:	5d                   	pop    %ebp
  8001a9:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001aa:	83 ec 04             	sub    $0x4,%esp
  8001ad:	68 04 27 80 00       	push   $0x802704
  8001b2:	6a 40                	push   $0x40
  8001b4:	68 37 27 80 00       	push   $0x802737
  8001b9:	e8 72 00 00 00       	call   800230 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001be:	50                   	push   %eax
  8001bf:	68 82 27 80 00       	push   $0x802782
  8001c4:	6a 42                	push   $0x42
  8001c6:	68 37 27 80 00       	push   $0x802737
  8001cb:	e8 60 00 00 00       	call   800230 <_panic>

008001d0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001db:	e8 c3 0a 00 00       	call   800ca3 <sys_getenvid>
  8001e0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ed:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f2:	85 db                	test   %ebx,%ebx
  8001f4:	7e 07                	jle    8001fd <libmain+0x2d>
		binaryname = argv[0];
  8001f6:	8b 06                	mov    (%esi),%eax
  8001f8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	e8 2c fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800207:	e8 0a 00 00 00       	call   800216 <exit>
}
  80020c:	83 c4 10             	add    $0x10,%esp
  80020f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800212:	5b                   	pop    %ebx
  800213:	5e                   	pop    %esi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021c:	e8 61 11 00 00       	call   801382 <close_all>
	sys_env_destroy(0);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	6a 00                	push   $0x0
  800226:	e8 37 0a 00 00       	call   800c62 <sys_env_destroy>
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800235:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800238:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023e:	e8 60 0a 00 00       	call   800ca3 <sys_getenvid>
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	ff 75 0c             	push   0xc(%ebp)
  800249:	ff 75 08             	push   0x8(%ebp)
  80024c:	56                   	push   %esi
  80024d:	50                   	push   %eax
  80024e:	68 b8 27 80 00       	push   $0x8027b8
  800253:	e8 b3 00 00 00       	call   80030b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	53                   	push   %ebx
  80025c:	ff 75 10             	push   0x10(%ebp)
  80025f:	e8 56 00 00 00       	call   8002ba <vcprintf>
	cprintf("\n");
  800264:	c7 04 24 ec 2c 80 00 	movl   $0x802cec,(%esp)
  80026b:	e8 9b 00 00 00       	call   80030b <cprintf>
  800270:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800273:	cc                   	int3   
  800274:	eb fd                	jmp    800273 <_panic+0x43>

00800276 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	53                   	push   %ebx
  80027a:	83 ec 04             	sub    $0x4,%esp
  80027d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800280:	8b 13                	mov    (%ebx),%edx
  800282:	8d 42 01             	lea    0x1(%edx),%eax
  800285:	89 03                	mov    %eax,(%ebx)
  800287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800293:	74 09                	je     80029e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800295:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	68 ff 00 00 00       	push   $0xff
  8002a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a9:	50                   	push   %eax
  8002aa:	e8 76 09 00 00       	call   800c25 <sys_cputs>
		b->idx = 0;
  8002af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb db                	jmp    800295 <putch+0x1f>

008002ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ca:	00 00 00 
	b.cnt = 0;
  8002cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d7:	ff 75 0c             	push   0xc(%ebp)
  8002da:	ff 75 08             	push   0x8(%ebp)
  8002dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	68 76 02 80 00       	push   $0x800276
  8002e9:	e8 14 01 00 00       	call   800402 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ee:	83 c4 08             	add    $0x8,%esp
  8002f1:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fd:	50                   	push   %eax
  8002fe:	e8 22 09 00 00       	call   800c25 <sys_cputs>

	return b.cnt;
}
  800303:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800311:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 08             	push   0x8(%ebp)
  800318:	e8 9d ff ff ff       	call   8002ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80031d:	c9                   	leave  
  80031e:	c3                   	ret    

0080031f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	57                   	push   %edi
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
  800325:	83 ec 1c             	sub    $0x1c,%esp
  800328:	89 c7                	mov    %eax,%edi
  80032a:	89 d6                	mov    %edx,%esi
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800332:	89 d1                	mov    %edx,%ecx
  800334:	89 c2                	mov    %eax,%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033c:	8b 45 10             	mov    0x10(%ebp),%eax
  80033f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800342:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800345:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034c:	39 c2                	cmp    %eax,%edx
  80034e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800351:	72 3e                	jb     800391 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	push   0x18(%ebp)
  800359:	83 eb 01             	sub    $0x1,%ebx
  80035c:	53                   	push   %ebx
  80035d:	50                   	push   %eax
  80035e:	83 ec 08             	sub    $0x8,%esp
  800361:	ff 75 e4             	push   -0x1c(%ebp)
  800364:	ff 75 e0             	push   -0x20(%ebp)
  800367:	ff 75 dc             	push   -0x24(%ebp)
  80036a:	ff 75 d8             	push   -0x28(%ebp)
  80036d:	e8 1e 21 00 00       	call   802490 <__udivdi3>
  800372:	83 c4 18             	add    $0x18,%esp
  800375:	52                   	push   %edx
  800376:	50                   	push   %eax
  800377:	89 f2                	mov    %esi,%edx
  800379:	89 f8                	mov    %edi,%eax
  80037b:	e8 9f ff ff ff       	call   80031f <printnum>
  800380:	83 c4 20             	add    $0x20,%esp
  800383:	eb 13                	jmp    800398 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	56                   	push   %esi
  800389:	ff 75 18             	push   0x18(%ebp)
  80038c:	ff d7                	call   *%edi
  80038e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800391:	83 eb 01             	sub    $0x1,%ebx
  800394:	85 db                	test   %ebx,%ebx
  800396:	7f ed                	jg     800385 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	ff 75 e4             	push   -0x1c(%ebp)
  8003a2:	ff 75 e0             	push   -0x20(%ebp)
  8003a5:	ff 75 dc             	push   -0x24(%ebp)
  8003a8:	ff 75 d8             	push   -0x28(%ebp)
  8003ab:	e8 00 22 00 00       	call   8025b0 <__umoddi3>
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	0f be 80 db 27 80 00 	movsbl 0x8027db(%eax),%eax
  8003ba:	50                   	push   %eax
  8003bb:	ff d7                	call   *%edi
}
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5f                   	pop    %edi
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d7:	73 0a                	jae    8003e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	88 02                	mov    %al,(%edx)
}
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <printfmt>:
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ee:	50                   	push   %eax
  8003ef:	ff 75 10             	push   0x10(%ebp)
  8003f2:	ff 75 0c             	push   0xc(%ebp)
  8003f5:	ff 75 08             	push   0x8(%ebp)
  8003f8:	e8 05 00 00 00       	call   800402 <vprintfmt>
}
  8003fd:	83 c4 10             	add    $0x10,%esp
  800400:	c9                   	leave  
  800401:	c3                   	ret    

00800402 <vprintfmt>:
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	57                   	push   %edi
  800406:	56                   	push   %esi
  800407:	53                   	push   %ebx
  800408:	83 ec 3c             	sub    $0x3c,%esp
  80040b:	8b 75 08             	mov    0x8(%ebp),%esi
  80040e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800411:	8b 7d 10             	mov    0x10(%ebp),%edi
  800414:	eb 0a                	jmp    800420 <vprintfmt+0x1e>
			putch(ch, putdat);
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	53                   	push   %ebx
  80041a:	50                   	push   %eax
  80041b:	ff d6                	call   *%esi
  80041d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800420:	83 c7 01             	add    $0x1,%edi
  800423:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800427:	83 f8 25             	cmp    $0x25,%eax
  80042a:	74 0c                	je     800438 <vprintfmt+0x36>
			if (ch == '\0')
  80042c:	85 c0                	test   %eax,%eax
  80042e:	75 e6                	jne    800416 <vprintfmt+0x14>
}
  800430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800433:	5b                   	pop    %ebx
  800434:	5e                   	pop    %esi
  800435:	5f                   	pop    %edi
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    
		padc = ' ';
  800438:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80043c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800443:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80044a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800451:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8d 47 01             	lea    0x1(%edi),%eax
  800459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045c:	0f b6 17             	movzbl (%edi),%edx
  80045f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800462:	3c 55                	cmp    $0x55,%al
  800464:	0f 87 bb 03 00 00    	ja     800825 <vprintfmt+0x423>
  80046a:	0f b6 c0             	movzbl %al,%eax
  80046d:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800477:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80047b:	eb d9                	jmp    800456 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800480:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800484:	eb d0                	jmp    800456 <vprintfmt+0x54>
  800486:	0f b6 d2             	movzbl %dl,%edx
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800494:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800497:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80049b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80049e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a1:	83 f9 09             	cmp    $0x9,%ecx
  8004a4:	77 55                	ja     8004fb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a9:	eb e9                	jmp    800494 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 40 04             	lea    0x4(%eax),%eax
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c3:	79 91                	jns    800456 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004d2:	eb 82                	jmp    800456 <vprintfmt+0x54>
  8004d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d7:	85 d2                	test   %edx,%edx
  8004d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004de:	0f 49 c2             	cmovns %edx,%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e7:	e9 6a ff ff ff       	jmp    800456 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f6:	e9 5b ff ff ff       	jmp    800456 <vprintfmt+0x54>
  8004fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800501:	eb bc                	jmp    8004bf <vprintfmt+0xbd>
			lflag++;
  800503:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800509:	e9 48 ff ff ff       	jmp    800456 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 78 04             	lea    0x4(%eax),%edi
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	ff 30                	push   (%eax)
  80051a:	ff d6                	call   *%esi
			break;
  80051c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80051f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800522:	e9 9d 02 00 00       	jmp    8007c4 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 78 04             	lea    0x4(%eax),%edi
  80052d:	8b 10                	mov    (%eax),%edx
  80052f:	89 d0                	mov    %edx,%eax
  800531:	f7 d8                	neg    %eax
  800533:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800536:	83 f8 0f             	cmp    $0xf,%eax
  800539:	7f 23                	jg     80055e <vprintfmt+0x15c>
  80053b:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  800542:	85 d2                	test   %edx,%edx
  800544:	74 18                	je     80055e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800546:	52                   	push   %edx
  800547:	68 81 2c 80 00       	push   $0x802c81
  80054c:	53                   	push   %ebx
  80054d:	56                   	push   %esi
  80054e:	e8 92 fe ff ff       	call   8003e5 <printfmt>
  800553:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800556:	89 7d 14             	mov    %edi,0x14(%ebp)
  800559:	e9 66 02 00 00       	jmp    8007c4 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80055e:	50                   	push   %eax
  80055f:	68 f3 27 80 00       	push   $0x8027f3
  800564:	53                   	push   %ebx
  800565:	56                   	push   %esi
  800566:	e8 7a fe ff ff       	call   8003e5 <printfmt>
  80056b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800571:	e9 4e 02 00 00       	jmp    8007c4 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	83 c0 04             	add    $0x4,%eax
  80057c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800584:	85 d2                	test   %edx,%edx
  800586:	b8 ec 27 80 00       	mov    $0x8027ec,%eax
  80058b:	0f 45 c2             	cmovne %edx,%eax
  80058e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800591:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800595:	7e 06                	jle    80059d <vprintfmt+0x19b>
  800597:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80059b:	75 0d                	jne    8005aa <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a0:	89 c7                	mov    %eax,%edi
  8005a2:	03 45 e0             	add    -0x20(%ebp),%eax
  8005a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a8:	eb 55                	jmp    8005ff <vprintfmt+0x1fd>
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	ff 75 d8             	push   -0x28(%ebp)
  8005b0:	ff 75 cc             	push   -0x34(%ebp)
  8005b3:	e8 0a 03 00 00       	call   8008c2 <strnlen>
  8005b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bb:	29 c1                	sub    %eax,%ecx
  8005bd:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005c5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	eb 0f                	jmp    8005dd <vprintfmt+0x1db>
					putch(padc, putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	ff 75 e0             	push   -0x20(%ebp)
  8005d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	83 ef 01             	sub    $0x1,%edi
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	7f ed                	jg     8005ce <vprintfmt+0x1cc>
  8005e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005eb:	0f 49 c2             	cmovns %edx,%eax
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f3:	eb a8                	jmp    80059d <vprintfmt+0x19b>
					putch(ch, putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	52                   	push   %edx
  8005fa:	ff d6                	call   *%esi
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800602:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800604:	83 c7 01             	add    $0x1,%edi
  800607:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060b:	0f be d0             	movsbl %al,%edx
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 4b                	je     80065d <vprintfmt+0x25b>
  800612:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800616:	78 06                	js     80061e <vprintfmt+0x21c>
  800618:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80061c:	78 1e                	js     80063c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80061e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800622:	74 d1                	je     8005f5 <vprintfmt+0x1f3>
  800624:	0f be c0             	movsbl %al,%eax
  800627:	83 e8 20             	sub    $0x20,%eax
  80062a:	83 f8 5e             	cmp    $0x5e,%eax
  80062d:	76 c6                	jbe    8005f5 <vprintfmt+0x1f3>
					putch('?', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 3f                	push   $0x3f
  800635:	ff d6                	call   *%esi
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	eb c3                	jmp    8005ff <vprintfmt+0x1fd>
  80063c:	89 cf                	mov    %ecx,%edi
  80063e:	eb 0e                	jmp    80064e <vprintfmt+0x24c>
				putch(' ', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 20                	push   $0x20
  800646:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800648:	83 ef 01             	sub    $0x1,%edi
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 ff                	test   %edi,%edi
  800650:	7f ee                	jg     800640 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800652:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
  800658:	e9 67 01 00 00       	jmp    8007c4 <vprintfmt+0x3c2>
  80065d:	89 cf                	mov    %ecx,%edi
  80065f:	eb ed                	jmp    80064e <vprintfmt+0x24c>
	if (lflag >= 2)
  800661:	83 f9 01             	cmp    $0x1,%ecx
  800664:	7f 1b                	jg     800681 <vprintfmt+0x27f>
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	74 63                	je     8006cd <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	99                   	cltd   
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb 17                	jmp    800698 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 50 04             	mov    0x4(%eax),%edx
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 40 08             	lea    0x8(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800698:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80069e:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	0f 89 ff 00 00 00    	jns    8007aa <vprintfmt+0x3a8>
				putch('-', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 2d                	push   $0x2d
  8006b1:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b9:	f7 da                	neg    %edx
  8006bb:	83 d1 00             	adc    $0x0,%ecx
  8006be:	f7 d9                	neg    %ecx
  8006c0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c3:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006c8:	e9 dd 00 00 00       	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	99                   	cltd   
  8006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e2:	eb b4                	jmp    800698 <vprintfmt+0x296>
	if (lflag >= 2)
  8006e4:	83 f9 01             	cmp    $0x1,%ecx
  8006e7:	7f 1e                	jg     800707 <vprintfmt+0x305>
	else if (lflag)
  8006e9:	85 c9                	test   %ecx,%ecx
  8006eb:	74 32                	je     80071f <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006fd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800702:	e9 a3 00 00 00       	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	8b 48 04             	mov    0x4(%eax),%ecx
  80070f:	8d 40 08             	lea    0x8(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800715:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80071a:	e9 8b 00 00 00       	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800734:	eb 74                	jmp    8007aa <vprintfmt+0x3a8>
	if (lflag >= 2)
  800736:	83 f9 01             	cmp    $0x1,%ecx
  800739:	7f 1b                	jg     800756 <vprintfmt+0x354>
	else if (lflag)
  80073b:	85 c9                	test   %ecx,%ecx
  80073d:	74 2c                	je     80076b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 10                	mov    (%eax),%edx
  800744:	b9 00 00 00 00       	mov    $0x0,%ecx
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80074f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800754:	eb 54                	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 10                	mov    (%eax),%edx
  80075b:	8b 48 04             	mov    0x4(%eax),%ecx
  80075e:	8d 40 08             	lea    0x8(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800764:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800769:	eb 3f                	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 10                	mov    (%eax),%edx
  800770:	b9 00 00 00 00       	mov    $0x0,%ecx
  800775:	8d 40 04             	lea    0x4(%eax),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80077b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800780:	eb 28                	jmp    8007aa <vprintfmt+0x3a8>
			putch('0', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 30                	push   $0x30
  800788:	ff d6                	call   *%esi
			putch('x', putdat);
  80078a:	83 c4 08             	add    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 78                	push   $0x78
  800790:	ff d6                	call   *%esi
			num = (unsigned long long)
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80079c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80079f:	8d 40 04             	lea    0x4(%eax),%eax
  8007a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a5:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 e0             	push   -0x20(%ebp)
  8007b5:	57                   	push   %edi
  8007b6:	51                   	push   %ecx
  8007b7:	52                   	push   %edx
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	e8 5e fb ff ff       	call   80031f <printnum>
			break;
  8007c1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c7:	e9 54 fc ff ff       	jmp    800420 <vprintfmt+0x1e>
	if (lflag >= 2)
  8007cc:	83 f9 01             	cmp    $0x1,%ecx
  8007cf:	7f 1b                	jg     8007ec <vprintfmt+0x3ea>
	else if (lflag)
  8007d1:	85 c9                	test   %ecx,%ecx
  8007d3:	74 2c                	je     800801 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8b 10                	mov    (%eax),%edx
  8007da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007df:	8d 40 04             	lea    0x4(%eax),%eax
  8007e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007ea:	eb be                	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8b 10                	mov    (%eax),%edx
  8007f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f4:	8d 40 08             	lea    0x8(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fa:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007ff:	eb a9                	jmp    8007aa <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 10                	mov    (%eax),%edx
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080b:	8d 40 04             	lea    0x4(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800811:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800816:	eb 92                	jmp    8007aa <vprintfmt+0x3a8>
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 25                	push   $0x25
  80081e:	ff d6                	call   *%esi
			break;
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	eb 9f                	jmp    8007c4 <vprintfmt+0x3c2>
			putch('%', putdat);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	53                   	push   %ebx
  800829:	6a 25                	push   $0x25
  80082b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	89 f8                	mov    %edi,%eax
  800832:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800836:	74 05                	je     80083d <vprintfmt+0x43b>
  800838:	83 e8 01             	sub    $0x1,%eax
  80083b:	eb f5                	jmp    800832 <vprintfmt+0x430>
  80083d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800840:	eb 82                	jmp    8007c4 <vprintfmt+0x3c2>

00800842 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 18             	sub    $0x18,%esp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800851:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800855:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085f:	85 c0                	test   %eax,%eax
  800861:	74 26                	je     800889 <vsnprintf+0x47>
  800863:	85 d2                	test   %edx,%edx
  800865:	7e 22                	jle    800889 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800867:	ff 75 14             	push   0x14(%ebp)
  80086a:	ff 75 10             	push   0x10(%ebp)
  80086d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	68 c8 03 80 00       	push   $0x8003c8
  800876:	e8 87 fb ff ff       	call   800402 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800884:	83 c4 10             	add    $0x10,%esp
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    
		return -E_INVAL;
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb f7                	jmp    800887 <vsnprintf+0x45>

00800890 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800899:	50                   	push   %eax
  80089a:	ff 75 10             	push   0x10(%ebp)
  80089d:	ff 75 0c             	push   0xc(%ebp)
  8008a0:	ff 75 08             	push   0x8(%ebp)
  8008a3:	e8 9a ff ff ff       	call   800842 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb 03                	jmp    8008ba <strlen+0x10>
		n++;
  8008b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008be:	75 f7                	jne    8008b7 <strlen+0xd>
	return n;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d0:	eb 03                	jmp    8008d5 <strnlen+0x13>
		n++;
  8008d2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d5:	39 d0                	cmp    %edx,%eax
  8008d7:	74 08                	je     8008e1 <strnlen+0x1f>
  8008d9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008dd:	75 f3                	jne    8008d2 <strnlen+0x10>
  8008df:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e1:	89 d0                	mov    %edx,%eax
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	84 d2                	test   %dl,%dl
  800900:	75 f2                	jne    8008f4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800902:	89 c8                	mov    %ecx,%eax
  800904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	83 ec 10             	sub    $0x10,%esp
  800910:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800913:	53                   	push   %ebx
  800914:	e8 91 ff ff ff       	call   8008aa <strlen>
  800919:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80091c:	ff 75 0c             	push   0xc(%ebp)
  80091f:	01 d8                	add    %ebx,%eax
  800921:	50                   	push   %eax
  800922:	e8 be ff ff ff       	call   8008e5 <strcpy>
	return dst;
}
  800927:	89 d8                	mov    %ebx,%eax
  800929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 75 08             	mov    0x8(%ebp),%esi
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
  800939:	89 f3                	mov    %esi,%ebx
  80093b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093e:	89 f0                	mov    %esi,%eax
  800940:	eb 0f                	jmp    800951 <strncpy+0x23>
		*dst++ = *src;
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 0a             	movzbl (%edx),%ecx
  800948:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094b:	80 f9 01             	cmp    $0x1,%cl
  80094e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800951:	39 d8                	cmp    %ebx,%eax
  800953:	75 ed                	jne    800942 <strncpy+0x14>
	}
	return ret;
}
  800955:	89 f0                	mov    %esi,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 75 08             	mov    0x8(%ebp),%esi
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800966:	8b 55 10             	mov    0x10(%ebp),%edx
  800969:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096b:	85 d2                	test   %edx,%edx
  80096d:	74 21                	je     800990 <strlcpy+0x35>
  80096f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800973:	89 f2                	mov    %esi,%edx
  800975:	eb 09                	jmp    800980 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	83 c2 01             	add    $0x1,%edx
  80097d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800980:	39 c2                	cmp    %eax,%edx
  800982:	74 09                	je     80098d <strlcpy+0x32>
  800984:	0f b6 19             	movzbl (%ecx),%ebx
  800987:	84 db                	test   %bl,%bl
  800989:	75 ec                	jne    800977 <strlcpy+0x1c>
  80098b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80098d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strcmp+0x11>
		p++, q++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 04                	je     8009b2 <strcmp+0x1c>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	74 ef                	je     8009a1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	0f b6 c0             	movzbl %al,%eax
  8009b5:	0f b6 12             	movzbl (%edx),%edx
  8009b8:	29 d0                	sub    %edx,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strncmp+0x17>
		n--, p++, q++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d3:	39 d8                	cmp    %ebx,%eax
  8009d5:	74 18                	je     8009ef <strncmp+0x33>
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	84 c9                	test   %cl,%cl
  8009dc:	74 04                	je     8009e2 <strncmp+0x26>
  8009de:	3a 0a                	cmp    (%edx),%cl
  8009e0:	74 eb                	je     8009cd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e2:	0f b6 00             	movzbl (%eax),%eax
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	29 d0                	sub    %edx,%eax
}
  8009ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    
		return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	eb f4                	jmp    8009ea <strncmp+0x2e>

008009f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a00:	eb 03                	jmp    800a05 <strchr+0xf>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	74 06                	je     800a12 <strchr+0x1c>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	75 f2                	jne    800a02 <strchr+0xc>
  800a10:	eb 05                	jmp    800a17 <strchr+0x21>
			return (char *) s;
	return 0;
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a23:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a26:	38 ca                	cmp    %cl,%dl
  800a28:	74 09                	je     800a33 <strfind+0x1a>
  800a2a:	84 d2                	test   %dl,%dl
  800a2c:	74 05                	je     800a33 <strfind+0x1a>
	for (; *s; s++)
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	eb f0                	jmp    800a23 <strfind+0xa>
			break;
	return (char *) s;
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a41:	85 c9                	test   %ecx,%ecx
  800a43:	74 2f                	je     800a74 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	09 c8                	or     %ecx,%eax
  800a49:	a8 03                	test   $0x3,%al
  800a4b:	75 21                	jne    800a6e <memset+0x39>
		c &= 0xFF;
  800a4d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a51:	89 d0                	mov    %edx,%eax
  800a53:	c1 e0 08             	shl    $0x8,%eax
  800a56:	89 d3                	mov    %edx,%ebx
  800a58:	c1 e3 18             	shl    $0x18,%ebx
  800a5b:	89 d6                	mov    %edx,%esi
  800a5d:	c1 e6 10             	shl    $0x10,%esi
  800a60:	09 f3                	or     %esi,%ebx
  800a62:	09 da                	or     %ebx,%edx
  800a64:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a66:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a69:	fc                   	cld    
  800a6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6c:	eb 06                	jmp    800a74 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	fc                   	cld    
  800a72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a74:	89 f8                	mov    %edi,%eax
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a89:	39 c6                	cmp    %eax,%esi
  800a8b:	73 32                	jae    800abf <memmove+0x44>
  800a8d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a90:	39 c2                	cmp    %eax,%edx
  800a92:	76 2b                	jbe    800abf <memmove+0x44>
		s += n;
		d += n;
  800a94:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a97:	89 d6                	mov    %edx,%esi
  800a99:	09 fe                	or     %edi,%esi
  800a9b:	09 ce                	or     %ecx,%esi
  800a9d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa3:	75 0e                	jne    800ab3 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa5:	83 ef 04             	sub    $0x4,%edi
  800aa8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aab:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aae:	fd                   	std    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb 09                	jmp    800abc <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab3:	83 ef 01             	sub    $0x1,%edi
  800ab6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab9:	fd                   	std    
  800aba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abc:	fc                   	cld    
  800abd:	eb 1a                	jmp    800ad9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	89 f2                	mov    %esi,%edx
  800ac1:	09 c2                	or     %eax,%edx
  800ac3:	09 ca                	or     %ecx,%edx
  800ac5:	f6 c2 03             	test   $0x3,%dl
  800ac8:	75 0a                	jne    800ad4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aca:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad2:	eb 05                	jmp    800ad9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae3:	ff 75 10             	push   0x10(%ebp)
  800ae6:	ff 75 0c             	push   0xc(%ebp)
  800ae9:	ff 75 08             	push   0x8(%ebp)
  800aec:	e8 8a ff ff ff       	call   800a7b <memmove>
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afe:	89 c6                	mov    %eax,%esi
  800b00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b03:	eb 06                	jmp    800b0b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b05:	83 c0 01             	add    $0x1,%eax
  800b08:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b0b:	39 f0                	cmp    %esi,%eax
  800b0d:	74 14                	je     800b23 <memcmp+0x30>
		if (*s1 != *s2)
  800b0f:	0f b6 08             	movzbl (%eax),%ecx
  800b12:	0f b6 1a             	movzbl (%edx),%ebx
  800b15:	38 d9                	cmp    %bl,%cl
  800b17:	74 ec                	je     800b05 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b19:	0f b6 c1             	movzbl %cl,%eax
  800b1c:	0f b6 db             	movzbl %bl,%ebx
  800b1f:	29 d8                	sub    %ebx,%eax
  800b21:	eb 05                	jmp    800b28 <memcmp+0x35>
	}

	return 0;
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3a:	eb 03                	jmp    800b3f <memfind+0x13>
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	39 d0                	cmp    %edx,%eax
  800b41:	73 04                	jae    800b47 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b43:	38 08                	cmp    %cl,(%eax)
  800b45:	75 f5                	jne    800b3c <memfind+0x10>
			break;
	return (void *) s;
}
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b55:	eb 03                	jmp    800b5a <strtol+0x11>
		s++;
  800b57:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 02             	movzbl (%edx),%eax
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 f6                	je     800b57 <strtol+0xe>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	74 f2                	je     800b57 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b65:	3c 2b                	cmp    $0x2b,%al
  800b67:	74 2a                	je     800b93 <strtol+0x4a>
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6e:	3c 2d                	cmp    $0x2d,%al
  800b70:	74 2b                	je     800b9d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b78:	75 0f                	jne    800b89 <strtol+0x40>
  800b7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7d:	74 28                	je     800ba7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b86:	0f 44 d8             	cmove  %eax,%ebx
  800b89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b91:	eb 46                	jmp    800bd9 <strtol+0x90>
		s++;
  800b93:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b96:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9b:	eb d5                	jmp    800b72 <strtol+0x29>
		s++, neg = 1;
  800b9d:	83 c2 01             	add    $0x1,%edx
  800ba0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba5:	eb cb                	jmp    800b72 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bab:	74 0e                	je     800bbb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bad:	85 db                	test   %ebx,%ebx
  800baf:	75 d8                	jne    800b89 <strtol+0x40>
		s++, base = 8;
  800bb1:	83 c2 01             	add    $0x1,%edx
  800bb4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb9:	eb ce                	jmp    800b89 <strtol+0x40>
		s += 2, base = 16;
  800bbb:	83 c2 02             	add    $0x2,%edx
  800bbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc3:	eb c4                	jmp    800b89 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc5:	0f be c0             	movsbl %al,%eax
  800bc8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bce:	7d 3a                	jge    800c0a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bd7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bd9:	0f b6 02             	movzbl (%edx),%eax
  800bdc:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	76 df                	jbe    800bc5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 70 9f             	lea    -0x61(%eax),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bf0:	0f be c0             	movsbl %al,%eax
  800bf3:	83 e8 57             	sub    $0x57,%eax
  800bf6:	eb d3                	jmp    800bcb <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 19             	cmp    $0x19,%bl
  800c00:	77 08                	ja     800c0a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c02:	0f be c0             	movsbl %al,%eax
  800c05:	83 e8 37             	sub    $0x37,%eax
  800c08:	eb c1                	jmp    800bcb <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0e:	74 05                	je     800c15 <strtol+0xcc>
		*endptr = (char *) s;
  800c10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c13:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c15:	89 c8                	mov    %ecx,%eax
  800c17:	f7 d8                	neg    %eax
  800c19:	85 ff                	test   %edi,%edi
  800c1b:	0f 45 c8             	cmovne %eax,%ecx
}
  800c1e:	89 c8                	mov    %ecx,%eax
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	89 c3                	mov    %eax,%ebx
  800c38:	89 c7                	mov    %eax,%edi
  800c3a:	89 c6                	mov    %eax,%esi
  800c3c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	b8 03 00 00 00       	mov    $0x3,%eax
  800c78:	89 cb                	mov    %ecx,%ebx
  800c7a:	89 cf                	mov    %ecx,%edi
  800c7c:	89 ce                	mov    %ecx,%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 03                	push   $0x3
  800c92:	68 df 2a 80 00       	push   $0x802adf
  800c97:	6a 2a                	push   $0x2a
  800c99:	68 fc 2a 80 00       	push   $0x802afc
  800c9e:	e8 8d f5 ff ff       	call   800230 <_panic>

00800ca3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_yield>:

void
sys_yield(void)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	b8 04 00 00 00       	mov    $0x4,%eax
  800cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfd:	89 f7                	mov    %esi,%edi
  800cff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7f 08                	jg     800d0d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 04                	push   $0x4
  800d13:	68 df 2a 80 00       	push   $0x802adf
  800d18:	6a 2a                	push   $0x2a
  800d1a:	68 fc 2a 80 00       	push   $0x802afc
  800d1f:	e8 0c f5 ff ff       	call   800230 <_panic>

00800d24 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 05 00 00 00       	mov    $0x5,%eax
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7f 08                	jg     800d4f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	50                   	push   %eax
  800d53:	6a 05                	push   $0x5
  800d55:	68 df 2a 80 00       	push   $0x802adf
  800d5a:	6a 2a                	push   $0x2a
  800d5c:	68 fc 2a 80 00       	push   $0x802afc
  800d61:	e8 ca f4 ff ff       	call   800230 <_panic>

00800d66 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7f 08                	jg     800d91 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 06                	push   $0x6
  800d97:	68 df 2a 80 00       	push   $0x802adf
  800d9c:	6a 2a                	push   $0x2a
  800d9e:	68 fc 2a 80 00       	push   $0x802afc
  800da3:	e8 88 f4 ff ff       	call   800230 <_panic>

00800da8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7f 08                	jg     800dd3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	50                   	push   %eax
  800dd7:	6a 08                	push   $0x8
  800dd9:	68 df 2a 80 00       	push   $0x802adf
  800dde:	6a 2a                	push   $0x2a
  800de0:	68 fc 2a 80 00       	push   $0x802afc
  800de5:	e8 46 f4 ff ff       	call   800230 <_panic>

00800dea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800e03:	89 df                	mov    %ebx,%edi
  800e05:	89 de                	mov    %ebx,%esi
  800e07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7f 08                	jg     800e15 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 09                	push   $0x9
  800e1b:	68 df 2a 80 00       	push   $0x802adf
  800e20:	6a 2a                	push   $0x2a
  800e22:	68 fc 2a 80 00       	push   $0x802afc
  800e27:	e8 04 f4 ff ff       	call   800230 <_panic>

00800e2c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e45:	89 df                	mov    %ebx,%edi
  800e47:	89 de                	mov    %ebx,%esi
  800e49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	7f 08                	jg     800e57 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	50                   	push   %eax
  800e5b:	6a 0a                	push   $0xa
  800e5d:	68 df 2a 80 00       	push   $0x802adf
  800e62:	6a 2a                	push   $0x2a
  800e64:	68 fc 2a 80 00       	push   $0x802afc
  800e69:	e8 c2 f3 ff ff       	call   800230 <_panic>

00800e6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7f:	be 00 00 00 00       	mov    $0x0,%esi
  800e84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea7:	89 cb                	mov    %ecx,%ebx
  800ea9:	89 cf                	mov    %ecx,%edi
  800eab:	89 ce                	mov    %ecx,%esi
  800ead:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7f 08                	jg     800ebb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	6a 0d                	push   $0xd
  800ec1:	68 df 2a 80 00       	push   $0x802adf
  800ec6:	6a 2a                	push   $0x2a
  800ec8:	68 fc 2a 80 00       	push   $0x802afc
  800ecd:	e8 5e f3 ff ff       	call   800230 <_panic>

00800ed2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed8:	ba 00 00 00 00       	mov    $0x0,%edx
  800edd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ee2:	89 d1                	mov    %edx,%ecx
  800ee4:	89 d3                	mov    %edx,%ebx
  800ee6:	89 d7                	mov    %edx,%edi
  800ee8:	89 d6                	mov    %edx,%esi
  800eea:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f02:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	89 de                	mov    %ebx,%esi
  800f0b:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	b8 10 00 00 00       	mov    $0x10,%eax
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f3d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f41:	0f 84 8e 00 00 00    	je     800fd5 <pgfault+0xa2>
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	c1 e8 0c             	shr    $0xc,%eax
  800f4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f53:	f6 c4 08             	test   $0x8,%ah
  800f56:	74 7d                	je     800fd5 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f58:	e8 46 fd ff ff       	call   800ca3 <sys_getenvid>
  800f5d:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	6a 07                	push   $0x7
  800f64:	68 00 f0 7f 00       	push   $0x7ff000
  800f69:	50                   	push   %eax
  800f6a:	e8 72 fd ff ff       	call   800ce1 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 73                	js     800fe9 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f76:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	68 00 10 00 00       	push   $0x1000
  800f84:	56                   	push   %esi
  800f85:	68 00 f0 7f 00       	push   $0x7ff000
  800f8a:	e8 ec fa ff ff       	call   800a7b <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f8f:	83 c4 08             	add    $0x8,%esp
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	e8 cd fd ff ff       	call   800d66 <sys_page_unmap>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 5b                	js     800ffb <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	6a 07                	push   $0x7
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	68 00 f0 7f 00       	push   $0x7ff000
  800fac:	53                   	push   %ebx
  800fad:	e8 72 fd ff ff       	call   800d24 <sys_page_map>
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 54                	js     80100d <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	68 00 f0 7f 00       	push   $0x7ff000
  800fc1:	53                   	push   %ebx
  800fc2:	e8 9f fd ff ff       	call   800d66 <sys_page_unmap>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 51                	js     80101f <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800fce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fd5:	83 ec 04             	sub    $0x4,%esp
  800fd8:	68 0c 2b 80 00       	push   $0x802b0c
  800fdd:	6a 1d                	push   $0x1d
  800fdf:	68 88 2b 80 00       	push   $0x802b88
  800fe4:	e8 47 f2 ff ff       	call   800230 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fe9:	50                   	push   %eax
  800fea:	68 44 2b 80 00       	push   $0x802b44
  800fef:	6a 29                	push   $0x29
  800ff1:	68 88 2b 80 00       	push   $0x802b88
  800ff6:	e8 35 f2 ff ff       	call   800230 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ffb:	50                   	push   %eax
  800ffc:	68 68 2b 80 00       	push   $0x802b68
  801001:	6a 2e                	push   $0x2e
  801003:	68 88 2b 80 00       	push   $0x802b88
  801008:	e8 23 f2 ff ff       	call   800230 <_panic>
		panic("pgfault: page map failed (%e)", r);
  80100d:	50                   	push   %eax
  80100e:	68 93 2b 80 00       	push   $0x802b93
  801013:	6a 30                	push   $0x30
  801015:	68 88 2b 80 00       	push   $0x802b88
  80101a:	e8 11 f2 ff ff       	call   800230 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80101f:	50                   	push   %eax
  801020:	68 68 2b 80 00       	push   $0x802b68
  801025:	6a 32                	push   $0x32
  801027:	68 88 2b 80 00       	push   $0x802b88
  80102c:	e8 ff f1 ff ff       	call   800230 <_panic>

00801031 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80103a:	68 33 0f 80 00       	push   $0x800f33
  80103f:	e8 7b 12 00 00       	call   8022bf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801044:	b8 07 00 00 00       	mov    $0x7,%eax
  801049:	cd 30                	int    $0x30
  80104b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	78 2d                	js     801082 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801055:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80105a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80105e:	75 73                	jne    8010d3 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801060:	e8 3e fc ff ff       	call   800ca3 <sys_getenvid>
  801065:	25 ff 03 00 00       	and    $0x3ff,%eax
  80106a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80106d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801072:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801077:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80107a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801082:	50                   	push   %eax
  801083:	68 b1 2b 80 00       	push   $0x802bb1
  801088:	6a 78                	push   $0x78
  80108a:	68 88 2b 80 00       	push   $0x802b88
  80108f:	e8 9c f1 ff ff       	call   800230 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 e4             	push   -0x1c(%ebp)
  80109a:	57                   	push   %edi
  80109b:	ff 75 dc             	push   -0x24(%ebp)
  80109e:	57                   	push   %edi
  80109f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010a2:	56                   	push   %esi
  8010a3:	e8 7c fc ff ff       	call   800d24 <sys_page_map>
	if(r<0) return r;
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 cb                	js     80107a <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	ff 75 e4             	push   -0x1c(%ebp)
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	e8 66 fc ff ff       	call   800d24 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 76                	js     80113b <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010cb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d1:	74 75                	je     801148 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	c1 e8 16             	shr    $0x16,%eax
  8010d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 e2                	je     8010c5 <fork+0x94>
  8010e3:	89 de                	mov    %ebx,%esi
  8010e5:	c1 ee 0c             	shr    $0xc,%esi
  8010e8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ef:	a8 01                	test   $0x1,%al
  8010f1:	74 d2                	je     8010c5 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8010f3:	e8 ab fb ff ff       	call   800ca3 <sys_getenvid>
  8010f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010fb:	89 f7                	mov    %esi,%edi
  8010fd:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801100:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801107:	89 c1                	mov    %eax,%ecx
  801109:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80110f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801112:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801119:	f6 c6 04             	test   $0x4,%dh
  80111c:	0f 85 72 ff ff ff    	jne    801094 <fork+0x63>
		perm &= ~PTE_W;
  801122:	25 05 0e 00 00       	and    $0xe05,%eax
  801127:	80 cc 08             	or     $0x8,%ah
  80112a:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801130:	0f 44 c1             	cmove  %ecx,%eax
  801133:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801136:	e9 59 ff ff ff       	jmp    801094 <fork+0x63>
  80113b:	ba 00 00 00 00       	mov    $0x0,%edx
  801140:	0f 4f c2             	cmovg  %edx,%eax
  801143:	e9 32 ff ff ff       	jmp    80107a <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	6a 07                	push   $0x7
  80114d:	68 00 f0 bf ee       	push   $0xeebff000
  801152:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801155:	57                   	push   %edi
  801156:	e8 86 fb ff ff       	call   800ce1 <sys_page_alloc>
	if(r<0) return r;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	0f 88 14 ff ff ff    	js     80107a <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	68 35 23 80 00       	push   $0x802335
  80116e:	57                   	push   %edi
  80116f:	e8 b8 fc ff ff       	call   800e2c <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	0f 88 fb fe ff ff    	js     80107a <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	6a 02                	push   $0x2
  801184:	57                   	push   %edi
  801185:	e8 1e fc ff ff       	call   800da8 <sys_env_set_status>
	if(r<0) return r;
  80118a:	83 c4 10             	add    $0x10,%esp
	return envid;
  80118d:	85 c0                	test   %eax,%eax
  80118f:	0f 49 c7             	cmovns %edi,%eax
  801192:	e9 e3 fe ff ff       	jmp    80107a <fork+0x49>

00801197 <sfork>:

// Challenge!
int
sfork(void)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80119d:	68 c1 2b 80 00       	push   $0x802bc1
  8011a2:	68 a1 00 00 00       	push   $0xa1
  8011a7:	68 88 2b 80 00       	push   $0x802b88
  8011ac:	e8 7f f0 ff ff       	call   800230 <_panic>

008011b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c7:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 ea 16             	shr    $0x16,%edx
  8011e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	74 29                	je     80121a <fd_alloc+0x42>
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 0c             	shr    $0xc,%edx
  8011f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	74 18                	je     80121a <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801202:	05 00 10 00 00       	add    $0x1000,%eax
  801207:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120c:	75 d2                	jne    8011e0 <fd_alloc+0x8>
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801213:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801218:	eb 05                	jmp    80121f <fd_alloc+0x47>
			return 0;
  80121a:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80121f:	8b 55 08             	mov    0x8(%ebp),%edx
  801222:	89 02                	mov    %eax,(%edx)
}
  801224:	89 c8                	mov    %ecx,%eax
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80122e:	83 f8 1f             	cmp    $0x1f,%eax
  801231:	77 30                	ja     801263 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801233:	c1 e0 0c             	shl    $0xc,%eax
  801236:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801241:	f6 c2 01             	test   $0x1,%dl
  801244:	74 24                	je     80126a <fd_lookup+0x42>
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 0c             	shr    $0xc,%edx
  80124b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	74 1a                	je     801271 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 02                	mov    %eax,(%edx)
	return 0;
  80125c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
		return -E_INVAL;
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801268:	eb f7                	jmp    801261 <fd_lookup+0x39>
		return -E_INVAL;
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126f:	eb f0                	jmp    801261 <fd_lookup+0x39>
  801271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801276:	eb e9                	jmp    801261 <fd_lookup+0x39>

00801278 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80128c:	39 13                	cmp    %edx,(%ebx)
  80128e:	74 37                	je     8012c7 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801290:	83 c0 01             	add    $0x1,%eax
  801293:	8b 1c 85 54 2c 80 00 	mov    0x802c54(,%eax,4),%ebx
  80129a:	85 db                	test   %ebx,%ebx
  80129c:	75 ee                	jne    80128c <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80129e:	a1 00 40 80 00       	mov    0x804000,%eax
  8012a3:	8b 40 48             	mov    0x48(%eax),%eax
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	52                   	push   %edx
  8012aa:	50                   	push   %eax
  8012ab:	68 d8 2b 80 00       	push   $0x802bd8
  8012b0:	e8 56 f0 ff ff       	call   80030b <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c0:	89 1a                	mov    %ebx,(%edx)
}
  8012c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    
			return 0;
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	eb ef                	jmp    8012bd <dev_lookup+0x45>

008012ce <fd_close>:
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 24             	sub    $0x24,%esp
  8012d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ea:	50                   	push   %eax
  8012eb:	e8 38 ff ff ff       	call   801228 <fd_lookup>
  8012f0:	89 c3                	mov    %eax,%ebx
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 05                	js     8012fe <fd_close+0x30>
	    || fd != fd2)
  8012f9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012fc:	74 16                	je     801314 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012fe:	89 f8                	mov    %edi,%eax
  801300:	84 c0                	test   %al,%al
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	0f 44 d8             	cmove  %eax,%ebx
}
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 36                	push   (%esi)
  80131d:	e8 56 ff ff ff       	call   801278 <dev_lookup>
  801322:	89 c3                	mov    %eax,%ebx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 1a                	js     801345 <fd_close+0x77>
		if (dev->dev_close)
  80132b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801331:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801336:	85 c0                	test   %eax,%eax
  801338:	74 0b                	je     801345 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	56                   	push   %esi
  80133e:	ff d0                	call   *%eax
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	56                   	push   %esi
  801349:	6a 00                	push   $0x0
  80134b:	e8 16 fa ff ff       	call   800d66 <sys_page_unmap>
	return r;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	eb b5                	jmp    80130a <fd_close+0x3c>

00801355 <close>:

int
close(int fdnum)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135e:	50                   	push   %eax
  80135f:	ff 75 08             	push   0x8(%ebp)
  801362:	e8 c1 fe ff ff       	call   801228 <fd_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	79 02                	jns    801370 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    
		return fd_close(fd, 1);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	6a 01                	push   $0x1
  801375:	ff 75 f4             	push   -0xc(%ebp)
  801378:	e8 51 ff ff ff       	call   8012ce <fd_close>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	eb ec                	jmp    80136e <close+0x19>

00801382 <close_all>:

void
close_all(void)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	53                   	push   %ebx
  801392:	e8 be ff ff ff       	call   801355 <close>
	for (i = 0; i < MAXFD; i++)
  801397:	83 c3 01             	add    $0x1,%ebx
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	83 fb 20             	cmp    $0x20,%ebx
  8013a0:	75 ec                	jne    80138e <close_all+0xc>
}
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 75 08             	push   0x8(%ebp)
  8013b7:	e8 6c fe ff ff       	call   801228 <fd_lookup>
  8013bc:	89 c3                	mov    %eax,%ebx
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 7f                	js     801444 <dup+0x9d>
		return r;
	close(newfdnum);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	ff 75 0c             	push   0xc(%ebp)
  8013cb:	e8 85 ff ff ff       	call   801355 <close>

	newfd = INDEX2FD(newfdnum);
  8013d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d3:	c1 e6 0c             	shl    $0xc,%esi
  8013d6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013df:	89 3c 24             	mov    %edi,(%esp)
  8013e2:	e8 da fd ff ff       	call   8011c1 <fd2data>
  8013e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e9:	89 34 24             	mov    %esi,(%esp)
  8013ec:	e8 d0 fd ff ff       	call   8011c1 <fd2data>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	c1 e8 16             	shr    $0x16,%eax
  8013fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801403:	a8 01                	test   $0x1,%al
  801405:	74 11                	je     801418 <dup+0x71>
  801407:	89 d8                	mov    %ebx,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
  80140c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801413:	f6 c2 01             	test   $0x1,%dl
  801416:	75 36                	jne    80144e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801418:	89 f8                	mov    %edi,%eax
  80141a:	c1 e8 0c             	shr    $0xc,%eax
  80141d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	25 07 0e 00 00       	and    $0xe07,%eax
  80142c:	50                   	push   %eax
  80142d:	56                   	push   %esi
  80142e:	6a 00                	push   $0x0
  801430:	57                   	push   %edi
  801431:	6a 00                	push   $0x0
  801433:	e8 ec f8 ff ff       	call   800d24 <sys_page_map>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 20             	add    $0x20,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 33                	js     801474 <dup+0xcd>
		goto err;

	return newfdnum;
  801441:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801444:	89 d8                	mov    %ebx,%eax
  801446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	25 07 0e 00 00       	and    $0xe07,%eax
  80145d:	50                   	push   %eax
  80145e:	ff 75 d4             	push   -0x2c(%ebp)
  801461:	6a 00                	push   $0x0
  801463:	53                   	push   %ebx
  801464:	6a 00                	push   $0x0
  801466:	e8 b9 f8 ff ff       	call   800d24 <sys_page_map>
  80146b:	89 c3                	mov    %eax,%ebx
  80146d:	83 c4 20             	add    $0x20,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	79 a4                	jns    801418 <dup+0x71>
	sys_page_unmap(0, newfd);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	56                   	push   %esi
  801478:	6a 00                	push   $0x0
  80147a:	e8 e7 f8 ff ff       	call   800d66 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	ff 75 d4             	push   -0x2c(%ebp)
  801485:	6a 00                	push   $0x0
  801487:	e8 da f8 ff ff       	call   800d66 <sys_page_unmap>
	return r;
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	eb b3                	jmp    801444 <dup+0x9d>

00801491 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	56                   	push   %esi
  801495:	53                   	push   %ebx
  801496:	83 ec 18             	sub    $0x18,%esp
  801499:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	56                   	push   %esi
  8014a1:	e8 82 fd ff ff       	call   801228 <fd_lookup>
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 3c                	js     8014e9 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	ff 33                	push   (%ebx)
  8014b9:	e8 ba fd ff ff       	call   801278 <dev_lookup>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 24                	js     8014e9 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c5:	8b 43 08             	mov    0x8(%ebx),%eax
  8014c8:	83 e0 03             	and    $0x3,%eax
  8014cb:	83 f8 01             	cmp    $0x1,%eax
  8014ce:	74 20                	je     8014f0 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d3:	8b 40 08             	mov    0x8(%eax),%eax
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	74 37                	je     801511 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014da:	83 ec 04             	sub    $0x4,%esp
  8014dd:	ff 75 10             	push   0x10(%ebp)
  8014e0:	ff 75 0c             	push   0xc(%ebp)
  8014e3:	53                   	push   %ebx
  8014e4:	ff d0                	call   *%eax
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f0:	a1 00 40 80 00       	mov    0x804000,%eax
  8014f5:	8b 40 48             	mov    0x48(%eax),%eax
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	56                   	push   %esi
  8014fc:	50                   	push   %eax
  8014fd:	68 19 2c 80 00       	push   $0x802c19
  801502:	e8 04 ee ff ff       	call   80030b <cprintf>
		return -E_INVAL;
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150f:	eb d8                	jmp    8014e9 <read+0x58>
		return -E_NOT_SUPP;
  801511:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801516:	eb d1                	jmp    8014e9 <read+0x58>

00801518 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	57                   	push   %edi
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	83 ec 0c             	sub    $0xc,%esp
  801521:	8b 7d 08             	mov    0x8(%ebp),%edi
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801527:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152c:	eb 02                	jmp    801530 <readn+0x18>
  80152e:	01 c3                	add    %eax,%ebx
  801530:	39 f3                	cmp    %esi,%ebx
  801532:	73 21                	jae    801555 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	89 f0                	mov    %esi,%eax
  801539:	29 d8                	sub    %ebx,%eax
  80153b:	50                   	push   %eax
  80153c:	89 d8                	mov    %ebx,%eax
  80153e:	03 45 0c             	add    0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	57                   	push   %edi
  801543:	e8 49 ff ff ff       	call   801491 <read>
		if (m < 0)
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 04                	js     801553 <readn+0x3b>
			return m;
		if (m == 0)
  80154f:	75 dd                	jne    80152e <readn+0x16>
  801551:	eb 02                	jmp    801555 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801553:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801555:	89 d8                	mov    %ebx,%eax
  801557:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	83 ec 18             	sub    $0x18,%esp
  801567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	53                   	push   %ebx
  80156f:	e8 b4 fc ff ff       	call   801228 <fd_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 37                	js     8015b2 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	ff 36                	push   (%esi)
  801587:	e8 ec fc ff ff       	call   801278 <dev_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 1f                	js     8015b2 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801593:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801597:	74 20                	je     8015b9 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	8b 40 0c             	mov    0xc(%eax),%eax
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	74 37                	je     8015da <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	ff 75 10             	push   0x10(%ebp)
  8015a9:	ff 75 0c             	push   0xc(%ebp)
  8015ac:	56                   	push   %esi
  8015ad:	ff d0                	call   *%eax
  8015af:	83 c4 10             	add    $0x10,%esp
}
  8015b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b9:	a1 00 40 80 00       	mov    0x804000,%eax
  8015be:	8b 40 48             	mov    0x48(%eax),%eax
  8015c1:	83 ec 04             	sub    $0x4,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	50                   	push   %eax
  8015c6:	68 35 2c 80 00       	push   $0x802c35
  8015cb:	e8 3b ed ff ff       	call   80030b <cprintf>
		return -E_INVAL;
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d8:	eb d8                	jmp    8015b2 <write+0x53>
		return -E_NOT_SUPP;
  8015da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015df:	eb d1                	jmp    8015b2 <write+0x53>

008015e1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	ff 75 08             	push   0x8(%ebp)
  8015ee:	e8 35 fc ff ff       	call   801228 <fd_lookup>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 0e                	js     801608 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	83 ec 18             	sub    $0x18,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	53                   	push   %ebx
  80161a:	e8 09 fc ff ff       	call   801228 <fd_lookup>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 34                	js     80165a <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	ff 36                	push   (%esi)
  801632:	e8 41 fc ff ff       	call   801278 <dev_lookup>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 1c                	js     80165a <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801642:	74 1d                	je     801661 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801647:	8b 40 18             	mov    0x18(%eax),%eax
  80164a:	85 c0                	test   %eax,%eax
  80164c:	74 34                	je     801682 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	ff 75 0c             	push   0xc(%ebp)
  801654:	56                   	push   %esi
  801655:	ff d0                	call   *%eax
  801657:	83 c4 10             	add    $0x10,%esp
}
  80165a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    
			thisenv->env_id, fdnum);
  801661:	a1 00 40 80 00       	mov    0x804000,%eax
  801666:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	53                   	push   %ebx
  80166d:	50                   	push   %eax
  80166e:	68 f8 2b 80 00       	push   $0x802bf8
  801673:	e8 93 ec ff ff       	call   80030b <cprintf>
		return -E_INVAL;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801680:	eb d8                	jmp    80165a <ftruncate+0x50>
		return -E_NOT_SUPP;
  801682:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801687:	eb d1                	jmp    80165a <ftruncate+0x50>

00801689 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	56                   	push   %esi
  80168d:	53                   	push   %ebx
  80168e:	83 ec 18             	sub    $0x18,%esp
  801691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	ff 75 08             	push   0x8(%ebp)
  80169b:	e8 88 fb ff ff       	call   801228 <fd_lookup>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 49                	js     8016f0 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	ff 36                	push   (%esi)
  8016b3:	e8 c0 fb ff ff       	call   801278 <dev_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 31                	js     8016f0 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c6:	74 2f                	je     8016f7 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016cb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d2:	00 00 00 
	stat->st_isdir = 0;
  8016d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016dc:	00 00 00 
	stat->st_dev = dev;
  8016df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	53                   	push   %ebx
  8016e9:	56                   	push   %esi
  8016ea:	ff 50 14             	call   *0x14(%eax)
  8016ed:	83 c4 10             	add    $0x10,%esp
}
  8016f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    
		return -E_NOT_SUPP;
  8016f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016fc:	eb f2                	jmp    8016f0 <fstat+0x67>

008016fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	6a 00                	push   $0x0
  801708:	ff 75 08             	push   0x8(%ebp)
  80170b:	e8 e4 01 00 00       	call   8018f4 <open>
  801710:	89 c3                	mov    %eax,%ebx
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	85 c0                	test   %eax,%eax
  801717:	78 1b                	js     801734 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	ff 75 0c             	push   0xc(%ebp)
  80171f:	50                   	push   %eax
  801720:	e8 64 ff ff ff       	call   801689 <fstat>
  801725:	89 c6                	mov    %eax,%esi
	close(fd);
  801727:	89 1c 24             	mov    %ebx,(%esp)
  80172a:	e8 26 fc ff ff       	call   801355 <close>
	return r;
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	89 f3                	mov    %esi,%ebx
}
  801734:	89 d8                	mov    %ebx,%eax
  801736:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	89 c6                	mov    %eax,%esi
  801744:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801746:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80174d:	74 27                	je     801776 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174f:	6a 07                	push   $0x7
  801751:	68 00 50 80 00       	push   $0x805000
  801756:	56                   	push   %esi
  801757:	ff 35 00 60 80 00    	push   0x806000
  80175d:	e8 60 0c 00 00       	call   8023c2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801762:	83 c4 0c             	add    $0xc,%esp
  801765:	6a 00                	push   $0x0
  801767:	53                   	push   %ebx
  801768:	6a 00                	push   $0x0
  80176a:	e8 ec 0b 00 00       	call   80235b <ipc_recv>
}
  80176f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	6a 01                	push   $0x1
  80177b:	e8 96 0c 00 00       	call   802416 <ipc_find_env>
  801780:	a3 00 60 80 00       	mov    %eax,0x806000
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	eb c5                	jmp    80174f <fsipc+0x12>

0080178a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 40 0c             	mov    0xc(%eax),%eax
  801796:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ad:	e8 8b ff ff ff       	call   80173d <fsipc>
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <devfile_flush>:
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cf:	e8 69 ff ff ff       	call   80173d <fsipc>
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_stat>:
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f5:	e8 43 ff ff ff       	call   80173d <fsipc>
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 2c                	js     80182a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	68 00 50 80 00       	push   $0x805000
  801806:	53                   	push   %ebx
  801807:	e8 d9 f0 ff ff       	call   8008e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180c:	a1 80 50 80 00       	mov    0x805080,%eax
  801811:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801817:	a1 84 50 80 00       	mov    0x805084,%eax
  80181c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_write>:
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	8b 45 10             	mov    0x10(%ebp),%eax
  801838:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183d:	39 d0                	cmp    %edx,%eax
  80183f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801842:	8b 55 08             	mov    0x8(%ebp),%edx
  801845:	8b 52 0c             	mov    0xc(%edx),%edx
  801848:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801853:	50                   	push   %eax
  801854:	ff 75 0c             	push   0xc(%ebp)
  801857:	68 08 50 80 00       	push   $0x805008
  80185c:	e8 1a f2 ff ff       	call   800a7b <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 04 00 00 00       	mov    $0x4,%eax
  80186b:	e8 cd fe ff ff       	call   80173d <fsipc>
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_read>:
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801885:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 03 00 00 00       	mov    $0x3,%eax
  801895:	e8 a3 fe ff ff       	call   80173d <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 1f                	js     8018bf <devfile_read+0x4d>
	assert(r <= n);
  8018a0:	39 f0                	cmp    %esi,%eax
  8018a2:	77 24                	ja     8018c8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a9:	7f 33                	jg     8018de <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	50                   	push   %eax
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	ff 75 0c             	push   0xc(%ebp)
  8018b7:	e8 bf f1 ff ff       	call   800a7b <memmove>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    
	assert(r <= n);
  8018c8:	68 68 2c 80 00       	push   $0x802c68
  8018cd:	68 6f 2c 80 00       	push   $0x802c6f
  8018d2:	6a 7c                	push   $0x7c
  8018d4:	68 84 2c 80 00       	push   $0x802c84
  8018d9:	e8 52 e9 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  8018de:	68 8f 2c 80 00       	push   $0x802c8f
  8018e3:	68 6f 2c 80 00       	push   $0x802c6f
  8018e8:	6a 7d                	push   $0x7d
  8018ea:	68 84 2c 80 00       	push   $0x802c84
  8018ef:	e8 3c e9 ff ff       	call   800230 <_panic>

008018f4 <open>:
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 1c             	sub    $0x1c,%esp
  8018fc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018ff:	56                   	push   %esi
  801900:	e8 a5 ef ff ff       	call   8008aa <strlen>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190d:	7f 6c                	jg     80197b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	e8 bd f8 ff ff       	call   8011d8 <fd_alloc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 3c                	js     801960 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	56                   	push   %esi
  801928:	68 00 50 80 00       	push   $0x805000
  80192d:	e8 b3 ef ff ff       	call   8008e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801932:	8b 45 0c             	mov    0xc(%ebp),%eax
  801935:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193d:	b8 01 00 00 00       	mov    $0x1,%eax
  801942:	e8 f6 fd ff ff       	call   80173d <fsipc>
  801947:	89 c3                	mov    %eax,%ebx
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 19                	js     801969 <open+0x75>
	return fd2num(fd);
  801950:	83 ec 0c             	sub    $0xc,%esp
  801953:	ff 75 f4             	push   -0xc(%ebp)
  801956:	e8 56 f8 ff ff       	call   8011b1 <fd2num>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	83 c4 10             	add    $0x10,%esp
}
  801960:	89 d8                	mov    %ebx,%eax
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    
		fd_close(fd, 0);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	6a 00                	push   $0x0
  80196e:	ff 75 f4             	push   -0xc(%ebp)
  801971:	e8 58 f9 ff ff       	call   8012ce <fd_close>
		return r;
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	eb e5                	jmp    801960 <open+0x6c>
		return -E_BAD_PATH;
  80197b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801980:	eb de                	jmp    801960 <open+0x6c>

00801982 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801988:	ba 00 00 00 00       	mov    $0x0,%edx
  80198d:	b8 08 00 00 00       	mov    $0x8,%eax
  801992:	e8 a6 fd ff ff       	call   80173d <fsipc>
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80199f:	68 9b 2c 80 00       	push   $0x802c9b
  8019a4:	ff 75 0c             	push   0xc(%ebp)
  8019a7:	e8 39 ef ff ff       	call   8008e5 <strcpy>
	return 0;
}
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devsock_close>:
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	53                   	push   %ebx
  8019b7:	83 ec 10             	sub    $0x10,%esp
  8019ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019bd:	53                   	push   %ebx
  8019be:	e8 8c 0a 00 00       	call   80244f <pageref>
  8019c3:	89 c2                	mov    %eax,%edx
  8019c5:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019cd:	83 fa 01             	cmp    $0x1,%edx
  8019d0:	74 05                	je     8019d7 <devsock_close+0x24>
}
  8019d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 73 0c             	push   0xc(%ebx)
  8019dd:	e8 b7 02 00 00       	call   801c99 <nsipc_close>
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	eb eb                	jmp    8019d2 <devsock_close+0x1f>

008019e7 <devsock_write>:
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ed:	6a 00                	push   $0x0
  8019ef:	ff 75 10             	push   0x10(%ebp)
  8019f2:	ff 75 0c             	push   0xc(%ebp)
  8019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f8:	ff 70 0c             	push   0xc(%eax)
  8019fb:	e8 79 03 00 00       	call   801d79 <nsipc_send>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devsock_read>:
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a08:	6a 00                	push   $0x0
  801a0a:	ff 75 10             	push   0x10(%ebp)
  801a0d:	ff 75 0c             	push   0xc(%ebp)
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	ff 70 0c             	push   0xc(%eax)
  801a16:	e8 ef 02 00 00       	call   801d0a <nsipc_recv>
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <fd2sockid>:
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a26:	52                   	push   %edx
  801a27:	50                   	push   %eax
  801a28:	e8 fb f7 ff ff       	call   801228 <fd_lookup>
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 10                	js     801a44 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a37:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a3d:	39 08                	cmp    %ecx,(%eax)
  801a3f:	75 05                	jne    801a46 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a41:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    
		return -E_NOT_SUPP;
  801a46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a4b:	eb f7                	jmp    801a44 <fd2sockid+0x27>

00801a4d <alloc_sockfd>:
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 1c             	sub    $0x1c,%esp
  801a55:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5a:	50                   	push   %eax
  801a5b:	e8 78 f7 ff ff       	call   8011d8 <fd_alloc>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 43                	js     801aac <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a69:	83 ec 04             	sub    $0x4,%esp
  801a6c:	68 07 04 00 00       	push   $0x407
  801a71:	ff 75 f4             	push   -0xc(%ebp)
  801a74:	6a 00                	push   $0x0
  801a76:	e8 66 f2 ff ff       	call   800ce1 <sys_page_alloc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 28                	js     801aac <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a8d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a99:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	50                   	push   %eax
  801aa0:	e8 0c f7 ff ff       	call   8011b1 <fd2num>
  801aa5:	89 c3                	mov    %eax,%ebx
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	eb 0c                	jmp    801ab8 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	56                   	push   %esi
  801ab0:	e8 e4 01 00 00       	call   801c99 <nsipc_close>
		return r;
  801ab5:	83 c4 10             	add    $0x10,%esp
}
  801ab8:	89 d8                	mov    %ebx,%eax
  801aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <accept>:
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	e8 4e ff ff ff       	call   801a1d <fd2sockid>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	78 1b                	js     801aee <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad3:	83 ec 04             	sub    $0x4,%esp
  801ad6:	ff 75 10             	push   0x10(%ebp)
  801ad9:	ff 75 0c             	push   0xc(%ebp)
  801adc:	50                   	push   %eax
  801add:	e8 0e 01 00 00       	call   801bf0 <nsipc_accept>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 05                	js     801aee <accept+0x2d>
	return alloc_sockfd(r);
  801ae9:	e8 5f ff ff ff       	call   801a4d <alloc_sockfd>
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <bind>:
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	e8 1f ff ff ff       	call   801a1d <fd2sockid>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 12                	js     801b14 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b02:	83 ec 04             	sub    $0x4,%esp
  801b05:	ff 75 10             	push   0x10(%ebp)
  801b08:	ff 75 0c             	push   0xc(%ebp)
  801b0b:	50                   	push   %eax
  801b0c:	e8 31 01 00 00       	call   801c42 <nsipc_bind>
  801b11:	83 c4 10             	add    $0x10,%esp
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <shutdown>:
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	e8 f9 fe ff ff       	call   801a1d <fd2sockid>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 0f                	js     801b37 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b28:	83 ec 08             	sub    $0x8,%esp
  801b2b:	ff 75 0c             	push   0xc(%ebp)
  801b2e:	50                   	push   %eax
  801b2f:	e8 43 01 00 00       	call   801c77 <nsipc_shutdown>
  801b34:	83 c4 10             	add    $0x10,%esp
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <connect>:
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	e8 d6 fe ff ff       	call   801a1d <fd2sockid>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 12                	js     801b5d <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	ff 75 10             	push   0x10(%ebp)
  801b51:	ff 75 0c             	push   0xc(%ebp)
  801b54:	50                   	push   %eax
  801b55:	e8 59 01 00 00       	call   801cb3 <nsipc_connect>
  801b5a:	83 c4 10             	add    $0x10,%esp
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <listen>:
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b65:	8b 45 08             	mov    0x8(%ebp),%eax
  801b68:	e8 b0 fe ff ff       	call   801a1d <fd2sockid>
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 0f                	js     801b80 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	ff 75 0c             	push   0xc(%ebp)
  801b77:	50                   	push   %eax
  801b78:	e8 6b 01 00 00       	call   801ce8 <nsipc_listen>
  801b7d:	83 c4 10             	add    $0x10,%esp
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b88:	ff 75 10             	push   0x10(%ebp)
  801b8b:	ff 75 0c             	push   0xc(%ebp)
  801b8e:	ff 75 08             	push   0x8(%ebp)
  801b91:	e8 41 02 00 00       	call   801dd7 <nsipc_socket>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 05                	js     801ba2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b9d:	e8 ab fe ff ff       	call   801a4d <alloc_sockfd>
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 04             	sub    $0x4,%esp
  801bab:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bad:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801bb4:	74 26                	je     801bdc <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bb6:	6a 07                	push   $0x7
  801bb8:	68 00 70 80 00       	push   $0x807000
  801bbd:	53                   	push   %ebx
  801bbe:	ff 35 00 80 80 00    	push   0x808000
  801bc4:	e8 f9 07 00 00       	call   8023c2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bc9:	83 c4 0c             	add    $0xc,%esp
  801bcc:	6a 00                	push   $0x0
  801bce:	6a 00                	push   $0x0
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 84 07 00 00       	call   80235b <ipc_recv>
}
  801bd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	6a 02                	push   $0x2
  801be1:	e8 30 08 00 00       	call   802416 <ipc_find_env>
  801be6:	a3 00 80 80 00       	mov    %eax,0x808000
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	eb c6                	jmp    801bb6 <nsipc+0x12>

00801bf0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c00:	8b 06                	mov    (%esi),%eax
  801c02:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c07:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0c:	e8 93 ff ff ff       	call   801ba4 <nsipc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	85 c0                	test   %eax,%eax
  801c15:	79 09                	jns    801c20 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c17:	89 d8                	mov    %ebx,%eax
  801c19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c20:	83 ec 04             	sub    $0x4,%esp
  801c23:	ff 35 10 70 80 00    	push   0x807010
  801c29:	68 00 70 80 00       	push   $0x807000
  801c2e:	ff 75 0c             	push   0xc(%ebp)
  801c31:	e8 45 ee ff ff       	call   800a7b <memmove>
		*addrlen = ret->ret_addrlen;
  801c36:	a1 10 70 80 00       	mov    0x807010,%eax
  801c3b:	89 06                	mov    %eax,(%esi)
  801c3d:	83 c4 10             	add    $0x10,%esp
	return r;
  801c40:	eb d5                	jmp    801c17 <nsipc_accept+0x27>

00801c42 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	53                   	push   %ebx
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c54:	53                   	push   %ebx
  801c55:	ff 75 0c             	push   0xc(%ebp)
  801c58:	68 04 70 80 00       	push   $0x807004
  801c5d:	e8 19 ee ff ff       	call   800a7b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c62:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c68:	b8 02 00 00 00       	mov    $0x2,%eax
  801c6d:	e8 32 ff ff ff       	call   801ba4 <nsipc>
}
  801c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c88:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c8d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c92:	e8 0d ff ff ff       	call   801ba4 <nsipc>
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <nsipc_close>:

int
nsipc_close(int s)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  801cac:	e8 f3 fe ff ff       	call   801ba4 <nsipc>
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cc5:	53                   	push   %ebx
  801cc6:	ff 75 0c             	push   0xc(%ebp)
  801cc9:	68 04 70 80 00       	push   $0x807004
  801cce:	e8 a8 ed ff ff       	call   800a7b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cd3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801cd9:	b8 05 00 00 00       	mov    $0x5,%eax
  801cde:	e8 c1 fe ff ff       	call   801ba4 <nsipc>
}
  801ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801cfe:	b8 06 00 00 00       	mov    $0x6,%eax
  801d03:	e8 9c fe ff ff       	call   801ba4 <nsipc>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d1a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d20:	8b 45 14             	mov    0x14(%ebp),%eax
  801d23:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d28:	b8 07 00 00 00       	mov    $0x7,%eax
  801d2d:	e8 72 fe ff ff       	call   801ba4 <nsipc>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 22                	js     801d5a <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d38:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d3d:	39 c6                	cmp    %eax,%esi
  801d3f:	0f 4e c6             	cmovle %esi,%eax
  801d42:	39 c3                	cmp    %eax,%ebx
  801d44:	7f 1d                	jg     801d63 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	53                   	push   %ebx
  801d4a:	68 00 70 80 00       	push   $0x807000
  801d4f:	ff 75 0c             	push   0xc(%ebp)
  801d52:	e8 24 ed ff ff       	call   800a7b <memmove>
  801d57:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d5a:	89 d8                	mov    %ebx,%eax
  801d5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d63:	68 a7 2c 80 00       	push   $0x802ca7
  801d68:	68 6f 2c 80 00       	push   $0x802c6f
  801d6d:	6a 62                	push   $0x62
  801d6f:	68 bc 2c 80 00       	push   $0x802cbc
  801d74:	e8 b7 e4 ff ff       	call   800230 <_panic>

00801d79 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d8b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d91:	7f 2e                	jg     801dc1 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	53                   	push   %ebx
  801d97:	ff 75 0c             	push   0xc(%ebp)
  801d9a:	68 0c 70 80 00       	push   $0x80700c
  801d9f:	e8 d7 ec ff ff       	call   800a7b <memmove>
	nsipcbuf.send.req_size = size;
  801da4:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801daa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dad:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801db2:	b8 08 00 00 00       	mov    $0x8,%eax
  801db7:	e8 e8 fd ff ff       	call   801ba4 <nsipc>
}
  801dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    
	assert(size < 1600);
  801dc1:	68 c8 2c 80 00       	push   $0x802cc8
  801dc6:	68 6f 2c 80 00       	push   $0x802c6f
  801dcb:	6a 6d                	push   $0x6d
  801dcd:	68 bc 2c 80 00       	push   $0x802cbc
  801dd2:	e8 59 e4 ff ff       	call   800230 <_panic>

00801dd7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ded:	8b 45 10             	mov    0x10(%ebp),%eax
  801df0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801df5:	b8 09 00 00 00       	mov    $0x9,%eax
  801dfa:	e8 a5 fd ff ff       	call   801ba4 <nsipc>
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    

00801e01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	ff 75 08             	push   0x8(%ebp)
  801e0f:	e8 ad f3 ff ff       	call   8011c1 <fd2data>
  801e14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e16:	83 c4 08             	add    $0x8,%esp
  801e19:	68 d4 2c 80 00       	push   $0x802cd4
  801e1e:	53                   	push   %ebx
  801e1f:	e8 c1 ea ff ff       	call   8008e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e24:	8b 46 04             	mov    0x4(%esi),%eax
  801e27:	2b 06                	sub    (%esi),%eax
  801e29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e36:	00 00 00 
	stat->st_dev = &devpipe;
  801e39:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e40:	30 80 00 
	return 0;
}
  801e43:	b8 00 00 00 00       	mov    $0x0,%eax
  801e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e59:	53                   	push   %ebx
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 05 ef ff ff       	call   800d66 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e61:	89 1c 24             	mov    %ebx,(%esp)
  801e64:	e8 58 f3 ff ff       	call   8011c1 <fd2data>
  801e69:	83 c4 08             	add    $0x8,%esp
  801e6c:	50                   	push   %eax
  801e6d:	6a 00                	push   $0x0
  801e6f:	e8 f2 ee ff ff       	call   800d66 <sys_page_unmap>
}
  801e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <_pipeisclosed>:
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	57                   	push   %edi
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 1c             	sub    $0x1c,%esp
  801e82:	89 c7                	mov    %eax,%edi
  801e84:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e86:	a1 00 40 80 00       	mov    0x804000,%eax
  801e8b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	57                   	push   %edi
  801e92:	e8 b8 05 00 00       	call   80244f <pageref>
  801e97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e9a:	89 34 24             	mov    %esi,(%esp)
  801e9d:	e8 ad 05 00 00       	call   80244f <pageref>
		nn = thisenv->env_runs;
  801ea2:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ea8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	39 cb                	cmp    %ecx,%ebx
  801eb0:	74 1b                	je     801ecd <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801eb2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eb5:	75 cf                	jne    801e86 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb7:	8b 42 58             	mov    0x58(%edx),%eax
  801eba:	6a 01                	push   $0x1
  801ebc:	50                   	push   %eax
  801ebd:	53                   	push   %ebx
  801ebe:	68 db 2c 80 00       	push   $0x802cdb
  801ec3:	e8 43 e4 ff ff       	call   80030b <cprintf>
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	eb b9                	jmp    801e86 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ecd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ed0:	0f 94 c0             	sete   %al
  801ed3:	0f b6 c0             	movzbl %al,%eax
}
  801ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5f                   	pop    %edi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <devpipe_write>:
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 28             	sub    $0x28,%esp
  801ee7:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801eea:	56                   	push   %esi
  801eeb:	e8 d1 f2 ff ff       	call   8011c1 <fd2data>
  801ef0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	bf 00 00 00 00       	mov    $0x0,%edi
  801efa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801efd:	75 09                	jne    801f08 <devpipe_write+0x2a>
	return i;
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	eb 23                	jmp    801f26 <devpipe_write+0x48>
			sys_yield();
  801f03:	e8 ba ed ff ff       	call   800cc2 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f08:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0b:	8b 0b                	mov    (%ebx),%ecx
  801f0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801f10:	39 d0                	cmp    %edx,%eax
  801f12:	72 1a                	jb     801f2e <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f14:	89 da                	mov    %ebx,%edx
  801f16:	89 f0                	mov    %esi,%eax
  801f18:	e8 5c ff ff ff       	call   801e79 <_pipeisclosed>
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	74 e2                	je     801f03 <devpipe_write+0x25>
				return 0;
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5f                   	pop    %edi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f31:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f35:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f38:	89 c2                	mov    %eax,%edx
  801f3a:	c1 fa 1f             	sar    $0x1f,%edx
  801f3d:	89 d1                	mov    %edx,%ecx
  801f3f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f42:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f45:	83 e2 1f             	and    $0x1f,%edx
  801f48:	29 ca                	sub    %ecx,%edx
  801f4a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f4e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f52:	83 c0 01             	add    $0x1,%eax
  801f55:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f58:	83 c7 01             	add    $0x1,%edi
  801f5b:	eb 9d                	jmp    801efa <devpipe_write+0x1c>

00801f5d <devpipe_read>:
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	57                   	push   %edi
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	83 ec 18             	sub    $0x18,%esp
  801f66:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f69:	57                   	push   %edi
  801f6a:	e8 52 f2 ff ff       	call   8011c1 <fd2data>
  801f6f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	be 00 00 00 00       	mov    $0x0,%esi
  801f79:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f7c:	75 13                	jne    801f91 <devpipe_read+0x34>
	return i;
  801f7e:	89 f0                	mov    %esi,%eax
  801f80:	eb 02                	jmp    801f84 <devpipe_read+0x27>
				return i;
  801f82:	89 f0                	mov    %esi,%eax
}
  801f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5f                   	pop    %edi
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    
			sys_yield();
  801f8c:	e8 31 ed ff ff       	call   800cc2 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f91:	8b 03                	mov    (%ebx),%eax
  801f93:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f96:	75 18                	jne    801fb0 <devpipe_read+0x53>
			if (i > 0)
  801f98:	85 f6                	test   %esi,%esi
  801f9a:	75 e6                	jne    801f82 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f9c:	89 da                	mov    %ebx,%edx
  801f9e:	89 f8                	mov    %edi,%eax
  801fa0:	e8 d4 fe ff ff       	call   801e79 <_pipeisclosed>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	74 e3                	je     801f8c <devpipe_read+0x2f>
				return 0;
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	eb d4                	jmp    801f84 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fb0:	99                   	cltd   
  801fb1:	c1 ea 1b             	shr    $0x1b,%edx
  801fb4:	01 d0                	add    %edx,%eax
  801fb6:	83 e0 1f             	and    $0x1f,%eax
  801fb9:	29 d0                	sub    %edx,%eax
  801fbb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fc6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fc9:	83 c6 01             	add    $0x1,%esi
  801fcc:	eb ab                	jmp    801f79 <devpipe_read+0x1c>

00801fce <pipe>:
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd9:	50                   	push   %eax
  801fda:	e8 f9 f1 ff ff       	call   8011d8 <fd_alloc>
  801fdf:	89 c3                	mov    %eax,%ebx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	0f 88 23 01 00 00    	js     80210f <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fec:	83 ec 04             	sub    $0x4,%esp
  801fef:	68 07 04 00 00       	push   $0x407
  801ff4:	ff 75 f4             	push   -0xc(%ebp)
  801ff7:	6a 00                	push   $0x0
  801ff9:	e8 e3 ec ff ff       	call   800ce1 <sys_page_alloc>
  801ffe:	89 c3                	mov    %eax,%ebx
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 04 01 00 00    	js     80210f <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802011:	50                   	push   %eax
  802012:	e8 c1 f1 ff ff       	call   8011d8 <fd_alloc>
  802017:	89 c3                	mov    %eax,%ebx
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	0f 88 db 00 00 00    	js     8020ff <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802024:	83 ec 04             	sub    $0x4,%esp
  802027:	68 07 04 00 00       	push   $0x407
  80202c:	ff 75 f0             	push   -0x10(%ebp)
  80202f:	6a 00                	push   $0x0
  802031:	e8 ab ec ff ff       	call   800ce1 <sys_page_alloc>
  802036:	89 c3                	mov    %eax,%ebx
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	0f 88 bc 00 00 00    	js     8020ff <pipe+0x131>
	va = fd2data(fd0);
  802043:	83 ec 0c             	sub    $0xc,%esp
  802046:	ff 75 f4             	push   -0xc(%ebp)
  802049:	e8 73 f1 ff ff       	call   8011c1 <fd2data>
  80204e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802050:	83 c4 0c             	add    $0xc,%esp
  802053:	68 07 04 00 00       	push   $0x407
  802058:	50                   	push   %eax
  802059:	6a 00                	push   $0x0
  80205b:	e8 81 ec ff ff       	call   800ce1 <sys_page_alloc>
  802060:	89 c3                	mov    %eax,%ebx
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	85 c0                	test   %eax,%eax
  802067:	0f 88 82 00 00 00    	js     8020ef <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206d:	83 ec 0c             	sub    $0xc,%esp
  802070:	ff 75 f0             	push   -0x10(%ebp)
  802073:	e8 49 f1 ff ff       	call   8011c1 <fd2data>
  802078:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80207f:	50                   	push   %eax
  802080:	6a 00                	push   $0x0
  802082:	56                   	push   %esi
  802083:	6a 00                	push   $0x0
  802085:	e8 9a ec ff ff       	call   800d24 <sys_page_map>
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	83 c4 20             	add    $0x20,%esp
  80208f:	85 c0                	test   %eax,%eax
  802091:	78 4e                	js     8020e1 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802093:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802098:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80209b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80209d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8020a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020aa:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020af:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	ff 75 f4             	push   -0xc(%ebp)
  8020bc:	e8 f0 f0 ff ff       	call   8011b1 <fd2num>
  8020c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c6:	83 c4 04             	add    $0x4,%esp
  8020c9:	ff 75 f0             	push   -0x10(%ebp)
  8020cc:	e8 e0 f0 ff ff       	call   8011b1 <fd2num>
  8020d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020df:	eb 2e                	jmp    80210f <pipe+0x141>
	sys_page_unmap(0, va);
  8020e1:	83 ec 08             	sub    $0x8,%esp
  8020e4:	56                   	push   %esi
  8020e5:	6a 00                	push   $0x0
  8020e7:	e8 7a ec ff ff       	call   800d66 <sys_page_unmap>
  8020ec:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	ff 75 f0             	push   -0x10(%ebp)
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 6a ec ff ff       	call   800d66 <sys_page_unmap>
  8020fc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020ff:	83 ec 08             	sub    $0x8,%esp
  802102:	ff 75 f4             	push   -0xc(%ebp)
  802105:	6a 00                	push   $0x0
  802107:	e8 5a ec ff ff       	call   800d66 <sys_page_unmap>
  80210c:	83 c4 10             	add    $0x10,%esp
}
  80210f:	89 d8                	mov    %ebx,%eax
  802111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <pipeisclosed>:
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802121:	50                   	push   %eax
  802122:	ff 75 08             	push   0x8(%ebp)
  802125:	e8 fe f0 ff ff       	call   801228 <fd_lookup>
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 18                	js     802149 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802131:	83 ec 0c             	sub    $0xc,%esp
  802134:	ff 75 f4             	push   -0xc(%ebp)
  802137:	e8 85 f0 ff ff       	call   8011c1 <fd2data>
  80213c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	e8 33 fd ff ff       	call   801e79 <_pipeisclosed>
  802146:	83 c4 10             	add    $0x10,%esp
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80214b:	b8 00 00 00 00       	mov    $0x0,%eax
  802150:	c3                   	ret    

00802151 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802157:	68 f3 2c 80 00       	push   $0x802cf3
  80215c:	ff 75 0c             	push   0xc(%ebp)
  80215f:	e8 81 e7 ff ff       	call   8008e5 <strcpy>
	return 0;
}
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <devcons_write>:
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	57                   	push   %edi
  80216f:	56                   	push   %esi
  802170:	53                   	push   %ebx
  802171:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802177:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80217c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802182:	eb 2e                	jmp    8021b2 <devcons_write+0x47>
		m = n - tot;
  802184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802187:	29 f3                	sub    %esi,%ebx
  802189:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80218e:	39 c3                	cmp    %eax,%ebx
  802190:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802193:	83 ec 04             	sub    $0x4,%esp
  802196:	53                   	push   %ebx
  802197:	89 f0                	mov    %esi,%eax
  802199:	03 45 0c             	add    0xc(%ebp),%eax
  80219c:	50                   	push   %eax
  80219d:	57                   	push   %edi
  80219e:	e8 d8 e8 ff ff       	call   800a7b <memmove>
		sys_cputs(buf, m);
  8021a3:	83 c4 08             	add    $0x8,%esp
  8021a6:	53                   	push   %ebx
  8021a7:	57                   	push   %edi
  8021a8:	e8 78 ea ff ff       	call   800c25 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021ad:	01 de                	add    %ebx,%esi
  8021af:	83 c4 10             	add    $0x10,%esp
  8021b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021b5:	72 cd                	jb     802184 <devcons_write+0x19>
}
  8021b7:	89 f0                	mov    %esi,%eax
  8021b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5e                   	pop    %esi
  8021be:	5f                   	pop    %edi
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <devcons_read>:
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	83 ec 08             	sub    $0x8,%esp
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d0:	75 07                	jne    8021d9 <devcons_read+0x18>
  8021d2:	eb 1f                	jmp    8021f3 <devcons_read+0x32>
		sys_yield();
  8021d4:	e8 e9 ea ff ff       	call   800cc2 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8021d9:	e8 65 ea ff ff       	call   800c43 <sys_cgetc>
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	74 f2                	je     8021d4 <devcons_read+0x13>
	if (c < 0)
  8021e2:	78 0f                	js     8021f3 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8021e4:	83 f8 04             	cmp    $0x4,%eax
  8021e7:	74 0c                	je     8021f5 <devcons_read+0x34>
	*(char*)vbuf = c;
  8021e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ec:	88 02                	mov    %al,(%edx)
	return 1;
  8021ee:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    
		return 0;
  8021f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fa:	eb f7                	jmp    8021f3 <devcons_read+0x32>

008021fc <cputchar>:
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802202:	8b 45 08             	mov    0x8(%ebp),%eax
  802205:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802208:	6a 01                	push   $0x1
  80220a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220d:	50                   	push   %eax
  80220e:	e8 12 ea ff ff       	call   800c25 <sys_cputs>
}
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	c9                   	leave  
  802217:	c3                   	ret    

00802218 <getchar>:
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80221e:	6a 01                	push   $0x1
  802220:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802223:	50                   	push   %eax
  802224:	6a 00                	push   $0x0
  802226:	e8 66 f2 ff ff       	call   801491 <read>
	if (r < 0)
  80222b:	83 c4 10             	add    $0x10,%esp
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 06                	js     802238 <getchar+0x20>
	if (r < 1)
  802232:	74 06                	je     80223a <getchar+0x22>
	return c;
  802234:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802238:	c9                   	leave  
  802239:	c3                   	ret    
		return -E_EOF;
  80223a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80223f:	eb f7                	jmp    802238 <getchar+0x20>

00802241 <iscons>:
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802247:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224a:	50                   	push   %eax
  80224b:	ff 75 08             	push   0x8(%ebp)
  80224e:	e8 d5 ef ff ff       	call   801228 <fd_lookup>
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	85 c0                	test   %eax,%eax
  802258:	78 11                	js     80226b <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80225a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802263:	39 10                	cmp    %edx,(%eax)
  802265:	0f 94 c0             	sete   %al
  802268:	0f b6 c0             	movzbl %al,%eax
}
  80226b:	c9                   	leave  
  80226c:	c3                   	ret    

0080226d <opencons>:
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802273:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802276:	50                   	push   %eax
  802277:	e8 5c ef ff ff       	call   8011d8 <fd_alloc>
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	85 c0                	test   %eax,%eax
  802281:	78 3a                	js     8022bd <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802283:	83 ec 04             	sub    $0x4,%esp
  802286:	68 07 04 00 00       	push   $0x407
  80228b:	ff 75 f4             	push   -0xc(%ebp)
  80228e:	6a 00                	push   $0x0
  802290:	e8 4c ea ff ff       	call   800ce1 <sys_page_alloc>
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 21                	js     8022bd <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80229c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022b1:	83 ec 0c             	sub    $0xc,%esp
  8022b4:	50                   	push   %eax
  8022b5:	e8 f7 ee ff ff       	call   8011b1 <fd2num>
  8022ba:	83 c4 10             	add    $0x10,%esp
}
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022c5:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022cc:	74 0a                	je     8022d8 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d1:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8022d6:	c9                   	leave  
  8022d7:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8022d8:	e8 c6 e9 ff ff       	call   800ca3 <sys_getenvid>
  8022dd:	83 ec 04             	sub    $0x4,%esp
  8022e0:	68 07 0e 00 00       	push   $0xe07
  8022e5:	68 00 f0 bf ee       	push   $0xeebff000
  8022ea:	50                   	push   %eax
  8022eb:	e8 f1 e9 ff ff       	call   800ce1 <sys_page_alloc>
		if (r < 0) {
  8022f0:	83 c4 10             	add    $0x10,%esp
  8022f3:	85 c0                	test   %eax,%eax
  8022f5:	78 2c                	js     802323 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022f7:	e8 a7 e9 ff ff       	call   800ca3 <sys_getenvid>
  8022fc:	83 ec 08             	sub    $0x8,%esp
  8022ff:	68 35 23 80 00       	push   $0x802335
  802304:	50                   	push   %eax
  802305:	e8 22 eb ff ff       	call   800e2c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	85 c0                	test   %eax,%eax
  80230f:	79 bd                	jns    8022ce <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802311:	50                   	push   %eax
  802312:	68 40 2d 80 00       	push   $0x802d40
  802317:	6a 28                	push   $0x28
  802319:	68 76 2d 80 00       	push   $0x802d76
  80231e:	e8 0d df ff ff       	call   800230 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802323:	50                   	push   %eax
  802324:	68 00 2d 80 00       	push   $0x802d00
  802329:	6a 23                	push   $0x23
  80232b:	68 76 2d 80 00       	push   $0x802d76
  802330:	e8 fb de ff ff       	call   800230 <_panic>

00802335 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802335:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802336:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80233b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80233d:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802340:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802344:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802347:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80234b:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80234f:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802351:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802354:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802355:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802358:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802359:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80235a:	c3                   	ret    

0080235b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	56                   	push   %esi
  80235f:	53                   	push   %ebx
  802360:	8b 75 08             	mov    0x8(%ebp),%esi
  802363:	8b 45 0c             	mov    0xc(%ebp),%eax
  802366:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802369:	85 c0                	test   %eax,%eax
  80236b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802370:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	50                   	push   %eax
  802377:	e8 15 eb ff ff       	call   800e91 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	85 f6                	test   %esi,%esi
  802381:	74 14                	je     802397 <ipc_recv+0x3c>
  802383:	ba 00 00 00 00       	mov    $0x0,%edx
  802388:	85 c0                	test   %eax,%eax
  80238a:	78 09                	js     802395 <ipc_recv+0x3a>
  80238c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802392:	8b 52 74             	mov    0x74(%edx),%edx
  802395:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802397:	85 db                	test   %ebx,%ebx
  802399:	74 14                	je     8023af <ipc_recv+0x54>
  80239b:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	78 09                	js     8023ad <ipc_recv+0x52>
  8023a4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8023aa:	8b 52 78             	mov    0x78(%edx),%edx
  8023ad:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 08                	js     8023bb <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8023b3:	a1 00 40 80 00       	mov    0x804000,%eax
  8023b8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023be:	5b                   	pop    %ebx
  8023bf:	5e                   	pop    %esi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    

008023c2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 0c             	sub    $0xc,%esp
  8023cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8023d4:	85 db                	test   %ebx,%ebx
  8023d6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023db:	0f 44 d8             	cmove  %eax,%ebx
  8023de:	eb 05                	jmp    8023e5 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023e0:	e8 dd e8 ff ff       	call   800cc2 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8023e5:	ff 75 14             	push   0x14(%ebp)
  8023e8:	53                   	push   %ebx
  8023e9:	56                   	push   %esi
  8023ea:	57                   	push   %edi
  8023eb:	e8 7e ea ff ff       	call   800e6e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8023f0:	83 c4 10             	add    $0x10,%esp
  8023f3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f6:	74 e8                	je     8023e0 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	78 08                	js     802404 <ipc_send+0x42>
	}while (r<0);

}
  8023fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802404:	50                   	push   %eax
  802405:	68 84 2d 80 00       	push   $0x802d84
  80240a:	6a 3d                	push   $0x3d
  80240c:	68 98 2d 80 00       	push   $0x802d98
  802411:	e8 1a de ff ff       	call   800230 <_panic>

00802416 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802416:	55                   	push   %ebp
  802417:	89 e5                	mov    %esp,%ebp
  802419:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80241c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802421:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802424:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80242a:	8b 52 50             	mov    0x50(%edx),%edx
  80242d:	39 ca                	cmp    %ecx,%edx
  80242f:	74 11                	je     802442 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802431:	83 c0 01             	add    $0x1,%eax
  802434:	3d 00 04 00 00       	cmp    $0x400,%eax
  802439:	75 e6                	jne    802421 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80243b:	b8 00 00 00 00       	mov    $0x0,%eax
  802440:	eb 0b                	jmp    80244d <ipc_find_env+0x37>
			return envs[i].env_id;
  802442:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802445:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80244a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    

0080244f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802455:	89 c2                	mov    %eax,%edx
  802457:	c1 ea 16             	shr    $0x16,%edx
  80245a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802461:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802466:	f6 c1 01             	test   $0x1,%cl
  802469:	74 1c                	je     802487 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80246b:	c1 e8 0c             	shr    $0xc,%eax
  80246e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802475:	a8 01                	test   $0x1,%al
  802477:	74 0e                	je     802487 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802479:	c1 e8 0c             	shr    $0xc,%eax
  80247c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802483:	ef 
  802484:	0f b7 d2             	movzwl %dx,%edx
}
  802487:	89 d0                	mov    %edx,%eax
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    
  80248b:	66 90                	xchg   %ax,%ax
  80248d:	66 90                	xchg   %ax,%ax
  80248f:	90                   	nop

00802490 <__udivdi3>:
  802490:	f3 0f 1e fb          	endbr32 
  802494:	55                   	push   %ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 1c             	sub    $0x1c,%esp
  80249b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80249f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024ab:	85 c0                	test   %eax,%eax
  8024ad:	75 19                	jne    8024c8 <__udivdi3+0x38>
  8024af:	39 f3                	cmp    %esi,%ebx
  8024b1:	76 4d                	jbe    802500 <__udivdi3+0x70>
  8024b3:	31 ff                	xor    %edi,%edi
  8024b5:	89 e8                	mov    %ebp,%eax
  8024b7:	89 f2                	mov    %esi,%edx
  8024b9:	f7 f3                	div    %ebx
  8024bb:	89 fa                	mov    %edi,%edx
  8024bd:	83 c4 1c             	add    $0x1c,%esp
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    
  8024c5:	8d 76 00             	lea    0x0(%esi),%esi
  8024c8:	39 f0                	cmp    %esi,%eax
  8024ca:	76 14                	jbe    8024e0 <__udivdi3+0x50>
  8024cc:	31 ff                	xor    %edi,%edi
  8024ce:	31 c0                	xor    %eax,%eax
  8024d0:	89 fa                	mov    %edi,%edx
  8024d2:	83 c4 1c             	add    $0x1c,%esp
  8024d5:	5b                   	pop    %ebx
  8024d6:	5e                   	pop    %esi
  8024d7:	5f                   	pop    %edi
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    
  8024da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e0:	0f bd f8             	bsr    %eax,%edi
  8024e3:	83 f7 1f             	xor    $0x1f,%edi
  8024e6:	75 48                	jne    802530 <__udivdi3+0xa0>
  8024e8:	39 f0                	cmp    %esi,%eax
  8024ea:	72 06                	jb     8024f2 <__udivdi3+0x62>
  8024ec:	31 c0                	xor    %eax,%eax
  8024ee:	39 eb                	cmp    %ebp,%ebx
  8024f0:	77 de                	ja     8024d0 <__udivdi3+0x40>
  8024f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f7:	eb d7                	jmp    8024d0 <__udivdi3+0x40>
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d9                	mov    %ebx,%ecx
  802502:	85 db                	test   %ebx,%ebx
  802504:	75 0b                	jne    802511 <__udivdi3+0x81>
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	f7 f3                	div    %ebx
  80250f:	89 c1                	mov    %eax,%ecx
  802511:	31 d2                	xor    %edx,%edx
  802513:	89 f0                	mov    %esi,%eax
  802515:	f7 f1                	div    %ecx
  802517:	89 c6                	mov    %eax,%esi
  802519:	89 e8                	mov    %ebp,%eax
  80251b:	89 f7                	mov    %esi,%edi
  80251d:	f7 f1                	div    %ecx
  80251f:	89 fa                	mov    %edi,%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 f9                	mov    %edi,%ecx
  802532:	ba 20 00 00 00       	mov    $0x20,%edx
  802537:	29 fa                	sub    %edi,%edx
  802539:	d3 e0                	shl    %cl,%eax
  80253b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80253f:	89 d1                	mov    %edx,%ecx
  802541:	89 d8                	mov    %ebx,%eax
  802543:	d3 e8                	shr    %cl,%eax
  802545:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802549:	09 c1                	or     %eax,%ecx
  80254b:	89 f0                	mov    %esi,%eax
  80254d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802551:	89 f9                	mov    %edi,%ecx
  802553:	d3 e3                	shl    %cl,%ebx
  802555:	89 d1                	mov    %edx,%ecx
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 f9                	mov    %edi,%ecx
  80255b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80255f:	89 eb                	mov    %ebp,%ebx
  802561:	d3 e6                	shl    %cl,%esi
  802563:	89 d1                	mov    %edx,%ecx
  802565:	d3 eb                	shr    %cl,%ebx
  802567:	09 f3                	or     %esi,%ebx
  802569:	89 c6                	mov    %eax,%esi
  80256b:	89 f2                	mov    %esi,%edx
  80256d:	89 d8                	mov    %ebx,%eax
  80256f:	f7 74 24 08          	divl   0x8(%esp)
  802573:	89 d6                	mov    %edx,%esi
  802575:	89 c3                	mov    %eax,%ebx
  802577:	f7 64 24 0c          	mull   0xc(%esp)
  80257b:	39 d6                	cmp    %edx,%esi
  80257d:	72 19                	jb     802598 <__udivdi3+0x108>
  80257f:	89 f9                	mov    %edi,%ecx
  802581:	d3 e5                	shl    %cl,%ebp
  802583:	39 c5                	cmp    %eax,%ebp
  802585:	73 04                	jae    80258b <__udivdi3+0xfb>
  802587:	39 d6                	cmp    %edx,%esi
  802589:	74 0d                	je     802598 <__udivdi3+0x108>
  80258b:	89 d8                	mov    %ebx,%eax
  80258d:	31 ff                	xor    %edi,%edi
  80258f:	e9 3c ff ff ff       	jmp    8024d0 <__udivdi3+0x40>
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80259b:	31 ff                	xor    %edi,%edi
  80259d:	e9 2e ff ff ff       	jmp    8024d0 <__udivdi3+0x40>
  8025a2:	66 90                	xchg   %ax,%ax
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__umoddi3>:
  8025b0:	f3 0f 1e fb          	endbr32 
  8025b4:	55                   	push   %ebp
  8025b5:	57                   	push   %edi
  8025b6:	56                   	push   %esi
  8025b7:	53                   	push   %ebx
  8025b8:	83 ec 1c             	sub    $0x1c,%esp
  8025bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8025c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8025cb:	89 f0                	mov    %esi,%eax
  8025cd:	89 da                	mov    %ebx,%edx
  8025cf:	85 ff                	test   %edi,%edi
  8025d1:	75 15                	jne    8025e8 <__umoddi3+0x38>
  8025d3:	39 dd                	cmp    %ebx,%ebp
  8025d5:	76 39                	jbe    802610 <__umoddi3+0x60>
  8025d7:	f7 f5                	div    %ebp
  8025d9:	89 d0                	mov    %edx,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	83 c4 1c             	add    $0x1c,%esp
  8025e0:	5b                   	pop    %ebx
  8025e1:	5e                   	pop    %esi
  8025e2:	5f                   	pop    %edi
  8025e3:	5d                   	pop    %ebp
  8025e4:	c3                   	ret    
  8025e5:	8d 76 00             	lea    0x0(%esi),%esi
  8025e8:	39 df                	cmp    %ebx,%edi
  8025ea:	77 f1                	ja     8025dd <__umoddi3+0x2d>
  8025ec:	0f bd cf             	bsr    %edi,%ecx
  8025ef:	83 f1 1f             	xor    $0x1f,%ecx
  8025f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025f6:	75 40                	jne    802638 <__umoddi3+0x88>
  8025f8:	39 df                	cmp    %ebx,%edi
  8025fa:	72 04                	jb     802600 <__umoddi3+0x50>
  8025fc:	39 f5                	cmp    %esi,%ebp
  8025fe:	77 dd                	ja     8025dd <__umoddi3+0x2d>
  802600:	89 da                	mov    %ebx,%edx
  802602:	89 f0                	mov    %esi,%eax
  802604:	29 e8                	sub    %ebp,%eax
  802606:	19 fa                	sbb    %edi,%edx
  802608:	eb d3                	jmp    8025dd <__umoddi3+0x2d>
  80260a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802610:	89 e9                	mov    %ebp,%ecx
  802612:	85 ed                	test   %ebp,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x71>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f5                	div    %ebp
  80261f:	89 c1                	mov    %eax,%ecx
  802621:	89 d8                	mov    %ebx,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f1                	div    %ecx
  802627:	89 f0                	mov    %esi,%eax
  802629:	f7 f1                	div    %ecx
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	31 d2                	xor    %edx,%edx
  80262f:	eb ac                	jmp    8025dd <__umoddi3+0x2d>
  802631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802638:	8b 44 24 04          	mov    0x4(%esp),%eax
  80263c:	ba 20 00 00 00       	mov    $0x20,%edx
  802641:	29 c2                	sub    %eax,%edx
  802643:	89 c1                	mov    %eax,%ecx
  802645:	89 e8                	mov    %ebp,%eax
  802647:	d3 e7                	shl    %cl,%edi
  802649:	89 d1                	mov    %edx,%ecx
  80264b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80264f:	d3 e8                	shr    %cl,%eax
  802651:	89 c1                	mov    %eax,%ecx
  802653:	8b 44 24 04          	mov    0x4(%esp),%eax
  802657:	09 f9                	or     %edi,%ecx
  802659:	89 df                	mov    %ebx,%edi
  80265b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265f:	89 c1                	mov    %eax,%ecx
  802661:	d3 e5                	shl    %cl,%ebp
  802663:	89 d1                	mov    %edx,%ecx
  802665:	d3 ef                	shr    %cl,%edi
  802667:	89 c1                	mov    %eax,%ecx
  802669:	89 f0                	mov    %esi,%eax
  80266b:	d3 e3                	shl    %cl,%ebx
  80266d:	89 d1                	mov    %edx,%ecx
  80266f:	89 fa                	mov    %edi,%edx
  802671:	d3 e8                	shr    %cl,%eax
  802673:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802678:	09 d8                	or     %ebx,%eax
  80267a:	f7 74 24 08          	divl   0x8(%esp)
  80267e:	89 d3                	mov    %edx,%ebx
  802680:	d3 e6                	shl    %cl,%esi
  802682:	f7 e5                	mul    %ebp
  802684:	89 c7                	mov    %eax,%edi
  802686:	89 d1                	mov    %edx,%ecx
  802688:	39 d3                	cmp    %edx,%ebx
  80268a:	72 06                	jb     802692 <__umoddi3+0xe2>
  80268c:	75 0e                	jne    80269c <__umoddi3+0xec>
  80268e:	39 c6                	cmp    %eax,%esi
  802690:	73 0a                	jae    80269c <__umoddi3+0xec>
  802692:	29 e8                	sub    %ebp,%eax
  802694:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802698:	89 d1                	mov    %edx,%ecx
  80269a:	89 c7                	mov    %eax,%edi
  80269c:	89 f5                	mov    %esi,%ebp
  80269e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026a2:	29 fd                	sub    %edi,%ebp
  8026a4:	19 cb                	sbb    %ecx,%ebx
  8026a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026ab:	89 d8                	mov    %ebx,%eax
  8026ad:	d3 e0                	shl    %cl,%eax
  8026af:	89 f1                	mov    %esi,%ecx
  8026b1:	d3 ed                	shr    %cl,%ebp
  8026b3:	d3 eb                	shr    %cl,%ebx
  8026b5:	09 e8                	or     %ebp,%eax
  8026b7:	89 da                	mov    %ebx,%edx
  8026b9:	83 c4 1c             	add    $0x1c,%esp
  8026bc:	5b                   	pop    %ebx
  8026bd:	5e                   	pop    %esi
  8026be:	5f                   	pop    %edi
  8026bf:	5d                   	pop    %ebp
  8026c0:	c3                   	ret    
