
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
  80003c:	68 00 22 80 00       	push   $0x802200
  800041:	e8 c5 02 00 00       	call   80030b <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 af 1a 00 00       	call   801b00 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	78 5b                	js     8000b3 <umain+0x80>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  800058:	e8 73 0f 00 00       	call   800fd0 <fork>
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
  800088:	e8 bd 1b 00 00       	call   801c4a <pipeisclosed>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	74 e2                	je     800076 <umain+0x43>
			cprintf("\nRACE: pipe appears closed\n");
  800094:	83 ec 0c             	sub    $0xc,%esp
  800097:	68 70 22 80 00       	push   $0x802270
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
  8000b4:	68 4e 22 80 00       	push   $0x80224e
  8000b9:	6a 0d                	push   $0xd
  8000bb:	68 57 22 80 00       	push   $0x802257
  8000c0:	e8 6b 01 00 00       	call   800230 <_panic>
		panic("fork: %e", r);
  8000c5:	50                   	push   %eax
  8000c6:	68 d8 26 80 00       	push   $0x8026d8
  8000cb:	6a 0f                	push   $0xf
  8000cd:	68 57 22 80 00       	push   $0x802257
  8000d2:	e8 59 01 00 00       	call   800230 <_panic>
		close(p[1]);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	ff 75 e4             	push   -0x1c(%ebp)
  8000dd:	e8 0d 12 00 00       	call   8012ef <close>
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
  8000f6:	e8 46 12 00 00       	call   801341 <dup>
			sys_yield();
  8000fb:	e8 c2 0b 00 00       	call   800cc2 <sys_yield>
			close(10);
  800100:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800107:	e8 e3 11 00 00       	call   8012ef <close>
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
  80013a:	68 6c 22 80 00       	push   $0x80226c
  80013f:	e8 c7 01 00 00       	call   80030b <cprintf>
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	eb a5                	jmp    8000ee <umain+0xbb>
		exit();
  800149:	e8 c8 00 00 00       	call   800216 <exit>
  80014e:	e9 12 ff ff ff       	jmp    800065 <umain+0x32>
		}
	cprintf("child done with loop\n");
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	68 8c 22 80 00       	push   $0x80228c
  80015b:	e8 ab 01 00 00       	call   80030b <cprintf>
	if (pipeisclosed(p[0]))
  800160:	83 c4 04             	add    $0x4,%esp
  800163:	ff 75 e0             	push   -0x20(%ebp)
  800166:	e8 df 1a 00 00       	call   801c4a <pipeisclosed>
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	85 c0                	test   %eax,%eax
  800170:	75 38                	jne    8001aa <umain+0x177>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	ff 75 e0             	push   -0x20(%ebp)
  80017c:	e8 46 10 00 00       	call   8011c7 <fd_lookup>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	85 c0                	test   %eax,%eax
  800186:	78 36                	js     8001be <umain+0x18b>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 dc             	push   -0x24(%ebp)
  80018e:	e8 cd 0f 00 00       	call   801160 <fd2data>
	cprintf("race didn't happen\n");
  800193:	c7 04 24 ba 22 80 00 	movl   $0x8022ba,(%esp)
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
  8001ad:	68 24 22 80 00       	push   $0x802224
  8001b2:	6a 40                	push   $0x40
  8001b4:	68 57 22 80 00       	push   $0x802257
  8001b9:	e8 72 00 00 00       	call   800230 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001be:	50                   	push   %eax
  8001bf:	68 a2 22 80 00       	push   $0x8022a2
  8001c4:	6a 42                	push   $0x42
  8001c6:	68 57 22 80 00       	push   $0x802257
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
  80021c:	e8 fb 10 00 00       	call   80131c <close_all>
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
  80024e:	68 d8 22 80 00       	push   $0x8022d8
  800253:	e8 b3 00 00 00       	call   80030b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	53                   	push   %ebx
  80025c:	ff 75 10             	push   0x10(%ebp)
  80025f:	e8 56 00 00 00       	call   8002ba <vcprintf>
	cprintf("\n");
  800264:	c7 04 24 cf 27 80 00 	movl   $0x8027cf,(%esp)
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
  80036d:	e8 4e 1c 00 00       	call   801fc0 <__udivdi3>
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
  8003ab:	e8 30 1d 00 00       	call   8020e0 <__umoddi3>
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	0f be 80 fb 22 80 00 	movsbl 0x8022fb(%eax),%eax
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
  80046d:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
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
  80053b:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800542:	85 d2                	test   %edx,%edx
  800544:	74 18                	je     80055e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800546:	52                   	push   %edx
  800547:	68 9d 27 80 00       	push   $0x80279d
  80054c:	53                   	push   %ebx
  80054d:	56                   	push   %esi
  80054e:	e8 92 fe ff ff       	call   8003e5 <printfmt>
  800553:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800556:	89 7d 14             	mov    %edi,0x14(%ebp)
  800559:	e9 66 02 00 00       	jmp    8007c4 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80055e:	50                   	push   %eax
  80055f:	68 13 23 80 00       	push   $0x802313
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
  800586:	b8 0c 23 80 00       	mov    $0x80230c,%eax
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
  800c92:	68 ff 25 80 00       	push   $0x8025ff
  800c97:	6a 2a                	push   $0x2a
  800c99:	68 1c 26 80 00       	push   $0x80261c
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
  800d13:	68 ff 25 80 00       	push   $0x8025ff
  800d18:	6a 2a                	push   $0x2a
  800d1a:	68 1c 26 80 00       	push   $0x80261c
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
  800d55:	68 ff 25 80 00       	push   $0x8025ff
  800d5a:	6a 2a                	push   $0x2a
  800d5c:	68 1c 26 80 00       	push   $0x80261c
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
  800d97:	68 ff 25 80 00       	push   $0x8025ff
  800d9c:	6a 2a                	push   $0x2a
  800d9e:	68 1c 26 80 00       	push   $0x80261c
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
  800dd9:	68 ff 25 80 00       	push   $0x8025ff
  800dde:	6a 2a                	push   $0x2a
  800de0:	68 1c 26 80 00       	push   $0x80261c
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
  800e1b:	68 ff 25 80 00       	push   $0x8025ff
  800e20:	6a 2a                	push   $0x2a
  800e22:	68 1c 26 80 00       	push   $0x80261c
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
  800e5d:	68 ff 25 80 00       	push   $0x8025ff
  800e62:	6a 2a                	push   $0x2a
  800e64:	68 1c 26 80 00       	push   $0x80261c
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
  800ec1:	68 ff 25 80 00       	push   $0x8025ff
  800ec6:	6a 2a                	push   $0x2a
  800ec8:	68 1c 26 80 00       	push   $0x80261c
  800ecd:	e8 5e f3 ff ff       	call   800230 <_panic>

00800ed2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eda:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800edc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee0:	0f 84 8e 00 00 00    	je     800f74 <pgfault+0xa2>
  800ee6:	89 f0                	mov    %esi,%eax
  800ee8:	c1 e8 0c             	shr    $0xc,%eax
  800eeb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef2:	f6 c4 08             	test   $0x8,%ah
  800ef5:	74 7d                	je     800f74 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ef7:	e8 a7 fd ff ff       	call   800ca3 <sys_getenvid>
  800efc:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	6a 07                	push   $0x7
  800f03:	68 00 f0 7f 00       	push   $0x7ff000
  800f08:	50                   	push   %eax
  800f09:	e8 d3 fd ff ff       	call   800ce1 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	78 73                	js     800f88 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f15:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f1b:	83 ec 04             	sub    $0x4,%esp
  800f1e:	68 00 10 00 00       	push   $0x1000
  800f23:	56                   	push   %esi
  800f24:	68 00 f0 7f 00       	push   $0x7ff000
  800f29:	e8 4d fb ff ff       	call   800a7b <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f2e:	83 c4 08             	add    $0x8,%esp
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	e8 2e fe ff ff       	call   800d66 <sys_page_unmap>
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 5b                	js     800f9a <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	6a 07                	push   $0x7
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	68 00 f0 7f 00       	push   $0x7ff000
  800f4b:	53                   	push   %ebx
  800f4c:	e8 d3 fd ff ff       	call   800d24 <sys_page_map>
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 54                	js     800fac <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f58:	83 ec 08             	sub    $0x8,%esp
  800f5b:	68 00 f0 7f 00       	push   $0x7ff000
  800f60:	53                   	push   %ebx
  800f61:	e8 00 fe ff ff       	call   800d66 <sys_page_unmap>
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 51                	js     800fbe <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 2c 26 80 00       	push   $0x80262c
  800f7c:	6a 1d                	push   $0x1d
  800f7e:	68 a8 26 80 00       	push   $0x8026a8
  800f83:	e8 a8 f2 ff ff       	call   800230 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f88:	50                   	push   %eax
  800f89:	68 64 26 80 00       	push   $0x802664
  800f8e:	6a 29                	push   $0x29
  800f90:	68 a8 26 80 00       	push   $0x8026a8
  800f95:	e8 96 f2 ff ff       	call   800230 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 88 26 80 00       	push   $0x802688
  800fa0:	6a 2e                	push   $0x2e
  800fa2:	68 a8 26 80 00       	push   $0x8026a8
  800fa7:	e8 84 f2 ff ff       	call   800230 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800fac:	50                   	push   %eax
  800fad:	68 b3 26 80 00       	push   $0x8026b3
  800fb2:	6a 30                	push   $0x30
  800fb4:	68 a8 26 80 00       	push   $0x8026a8
  800fb9:	e8 72 f2 ff ff       	call   800230 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fbe:	50                   	push   %eax
  800fbf:	68 88 26 80 00       	push   $0x802688
  800fc4:	6a 32                	push   $0x32
  800fc6:	68 a8 26 80 00       	push   $0x8026a8
  800fcb:	e8 60 f2 ff ff       	call   800230 <_panic>

00800fd0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800fd9:	68 d2 0e 80 00       	push   $0x800ed2
  800fde:	e8 0e 0e 00 00       	call   801df1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe8:	cd 30                	int    $0x30
  800fea:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 2d                	js     801021 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ff4:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ff9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ffd:	75 73                	jne    801072 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fff:	e8 9f fc ff ff       	call   800ca3 <sys_getenvid>
  801004:	25 ff 03 00 00       	and    $0x3ff,%eax
  801009:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80100c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801011:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801016:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801019:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801021:	50                   	push   %eax
  801022:	68 d1 26 80 00       	push   $0x8026d1
  801027:	6a 78                	push   $0x78
  801029:	68 a8 26 80 00       	push   $0x8026a8
  80102e:	e8 fd f1 ff ff       	call   800230 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	ff 75 e4             	push   -0x1c(%ebp)
  801039:	57                   	push   %edi
  80103a:	ff 75 dc             	push   -0x24(%ebp)
  80103d:	57                   	push   %edi
  80103e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801041:	56                   	push   %esi
  801042:	e8 dd fc ff ff       	call   800d24 <sys_page_map>
	if(r<0) return r;
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 cb                	js     801019 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	ff 75 e4             	push   -0x1c(%ebp)
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	e8 c7 fc ff ff       	call   800d24 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 76                	js     8010da <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801064:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80106a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801070:	74 75                	je     8010e7 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801072:	89 d8                	mov    %ebx,%eax
  801074:	c1 e8 16             	shr    $0x16,%eax
  801077:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107e:	a8 01                	test   $0x1,%al
  801080:	74 e2                	je     801064 <fork+0x94>
  801082:	89 de                	mov    %ebx,%esi
  801084:	c1 ee 0c             	shr    $0xc,%esi
  801087:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108e:	a8 01                	test   $0x1,%al
  801090:	74 d2                	je     801064 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801092:	e8 0c fc ff ff       	call   800ca3 <sys_getenvid>
  801097:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80109a:	89 f7                	mov    %esi,%edi
  80109c:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80109f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a6:	89 c1                	mov    %eax,%ecx
  8010a8:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010b1:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010b8:	f6 c6 04             	test   $0x4,%dh
  8010bb:	0f 85 72 ff ff ff    	jne    801033 <fork+0x63>
		perm &= ~PTE_W;
  8010c1:	25 05 0e 00 00       	and    $0xe05,%eax
  8010c6:	80 cc 08             	or     $0x8,%ah
  8010c9:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010cf:	0f 44 c1             	cmove  %ecx,%eax
  8010d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d5:	e9 59 ff ff ff       	jmp    801033 <fork+0x63>
  8010da:	ba 00 00 00 00       	mov    $0x0,%edx
  8010df:	0f 4f c2             	cmovg  %edx,%eax
  8010e2:	e9 32 ff ff ff       	jmp    801019 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8010e7:	83 ec 04             	sub    $0x4,%esp
  8010ea:	6a 07                	push   $0x7
  8010ec:	68 00 f0 bf ee       	push   $0xeebff000
  8010f1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010f4:	57                   	push   %edi
  8010f5:	e8 e7 fb ff ff       	call   800ce1 <sys_page_alloc>
	if(r<0) return r;
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 88 14 ff ff ff    	js     801019 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	68 67 1e 80 00       	push   $0x801e67
  80110d:	57                   	push   %edi
  80110e:	e8 19 fd ff ff       	call   800e2c <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	0f 88 fb fe ff ff    	js     801019 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	6a 02                	push   $0x2
  801123:	57                   	push   %edi
  801124:	e8 7f fc ff ff       	call   800da8 <sys_env_set_status>
	if(r<0) return r;
  801129:	83 c4 10             	add    $0x10,%esp
	return envid;
  80112c:	85 c0                	test   %eax,%eax
  80112e:	0f 49 c7             	cmovns %edi,%eax
  801131:	e9 e3 fe ff ff       	jmp    801019 <fork+0x49>

00801136 <sfork>:

// Challenge!
int
sfork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80113c:	68 e1 26 80 00       	push   $0x8026e1
  801141:	68 a1 00 00 00       	push   $0xa1
  801146:	68 a8 26 80 00       	push   $0x8026a8
  80114b:	e8 e0 f0 ff ff       	call   800230 <_panic>

00801150 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	05 00 00 00 30       	add    $0x30000000,%eax
  80115b:	c1 e8 0c             	shr    $0xc,%eax
}
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80116b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801170:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 16             	shr    $0x16,%edx
  801184:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118b:	f6 c2 01             	test   $0x1,%dl
  80118e:	74 29                	je     8011b9 <fd_alloc+0x42>
  801190:	89 c2                	mov    %eax,%edx
  801192:	c1 ea 0c             	shr    $0xc,%edx
  801195:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119c:	f6 c2 01             	test   $0x1,%dl
  80119f:	74 18                	je     8011b9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011a1:	05 00 10 00 00       	add    $0x1000,%eax
  8011a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ab:	75 d2                	jne    80117f <fd_alloc+0x8>
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011b2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011b7:	eb 05                	jmp    8011be <fd_alloc+0x47>
			return 0;
  8011b9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011be:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c1:	89 02                	mov    %eax,(%edx)
}
  8011c3:	89 c8                	mov    %ecx,%eax
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cd:	83 f8 1f             	cmp    $0x1f,%eax
  8011d0:	77 30                	ja     801202 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d2:	c1 e0 0c             	shl    $0xc,%eax
  8011d5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011da:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011e0:	f6 c2 01             	test   $0x1,%dl
  8011e3:	74 24                	je     801209 <fd_lookup+0x42>
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	c1 ea 0c             	shr    $0xc,%edx
  8011ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f1:	f6 c2 01             	test   $0x1,%dl
  8011f4:	74 1a                	je     801210 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    
		return -E_INVAL;
  801202:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801207:	eb f7                	jmp    801200 <fd_lookup+0x39>
		return -E_INVAL;
  801209:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120e:	eb f0                	jmp    801200 <fd_lookup+0x39>
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801215:	eb e9                	jmp    801200 <fd_lookup+0x39>

00801217 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	53                   	push   %ebx
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	8b 55 08             	mov    0x8(%ebp),%edx
  801221:	b8 74 27 80 00       	mov    $0x802774,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801226:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80122b:	39 13                	cmp    %edx,(%ebx)
  80122d:	74 32                	je     801261 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80122f:	83 c0 04             	add    $0x4,%eax
  801232:	8b 18                	mov    (%eax),%ebx
  801234:	85 db                	test   %ebx,%ebx
  801236:	75 f3                	jne    80122b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801238:	a1 00 40 80 00       	mov    0x804000,%eax
  80123d:	8b 40 48             	mov    0x48(%eax),%eax
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	52                   	push   %edx
  801244:	50                   	push   %eax
  801245:	68 f8 26 80 00       	push   $0x8026f8
  80124a:	e8 bc f0 ff ff       	call   80030b <cprintf>
	*dev = 0;
	return -E_INVAL;
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 1a                	mov    %ebx,(%edx)
}
  80125c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125f:	c9                   	leave  
  801260:	c3                   	ret    
			return 0;
  801261:	b8 00 00 00 00       	mov    $0x0,%eax
  801266:	eb ef                	jmp    801257 <dev_lookup+0x40>

00801268 <fd_close>:
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	57                   	push   %edi
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 24             	sub    $0x24,%esp
  801271:	8b 75 08             	mov    0x8(%ebp),%esi
  801274:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801277:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80127a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801284:	50                   	push   %eax
  801285:	e8 3d ff ff ff       	call   8011c7 <fd_lookup>
  80128a:	89 c3                	mov    %eax,%ebx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 05                	js     801298 <fd_close+0x30>
	    || fd != fd2)
  801293:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801296:	74 16                	je     8012ae <fd_close+0x46>
		return (must_exist ? r : 0);
  801298:	89 f8                	mov    %edi,%eax
  80129a:	84 c0                	test   %al,%al
  80129c:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a1:	0f 44 d8             	cmove  %eax,%ebx
}
  8012a4:	89 d8                	mov    %ebx,%eax
  8012a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5e                   	pop    %esi
  8012ab:	5f                   	pop    %edi
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ae:	83 ec 08             	sub    $0x8,%esp
  8012b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	ff 36                	push   (%esi)
  8012b7:	e8 5b ff ff ff       	call   801217 <dev_lookup>
  8012bc:	89 c3                	mov    %eax,%ebx
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 1a                	js     8012df <fd_close+0x77>
		if (dev->dev_close)
  8012c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012cb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	74 0b                	je     8012df <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	56                   	push   %esi
  8012d8:	ff d0                	call   *%eax
  8012da:	89 c3                	mov    %eax,%ebx
  8012dc:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	56                   	push   %esi
  8012e3:	6a 00                	push   $0x0
  8012e5:	e8 7c fa ff ff       	call   800d66 <sys_page_unmap>
	return r;
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	eb b5                	jmp    8012a4 <fd_close+0x3c>

008012ef <close>:

int
close(int fdnum)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 75 08             	push   0x8(%ebp)
  8012fc:	e8 c6 fe ff ff       	call   8011c7 <fd_lookup>
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	79 02                	jns    80130a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801308:	c9                   	leave  
  801309:	c3                   	ret    
		return fd_close(fd, 1);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	6a 01                	push   $0x1
  80130f:	ff 75 f4             	push   -0xc(%ebp)
  801312:	e8 51 ff ff ff       	call   801268 <fd_close>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	eb ec                	jmp    801308 <close+0x19>

0080131c <close_all>:

void
close_all(void)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	53                   	push   %ebx
  801320:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801323:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	53                   	push   %ebx
  80132c:	e8 be ff ff ff       	call   8012ef <close>
	for (i = 0; i < MAXFD; i++)
  801331:	83 c3 01             	add    $0x1,%ebx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	83 fb 20             	cmp    $0x20,%ebx
  80133a:	75 ec                	jne    801328 <close_all+0xc>
}
  80133c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	57                   	push   %edi
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
  801347:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	ff 75 08             	push   0x8(%ebp)
  801351:	e8 71 fe ff ff       	call   8011c7 <fd_lookup>
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 7f                	js     8013de <dup+0x9d>
		return r;
	close(newfdnum);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	ff 75 0c             	push   0xc(%ebp)
  801365:	e8 85 ff ff ff       	call   8012ef <close>

	newfd = INDEX2FD(newfdnum);
  80136a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80136d:	c1 e6 0c             	shl    $0xc,%esi
  801370:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801379:	89 3c 24             	mov    %edi,(%esp)
  80137c:	e8 df fd ff ff       	call   801160 <fd2data>
  801381:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801383:	89 34 24             	mov    %esi,(%esp)
  801386:	e8 d5 fd ff ff       	call   801160 <fd2data>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801391:	89 d8                	mov    %ebx,%eax
  801393:	c1 e8 16             	shr    $0x16,%eax
  801396:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139d:	a8 01                	test   $0x1,%al
  80139f:	74 11                	je     8013b2 <dup+0x71>
  8013a1:	89 d8                	mov    %ebx,%eax
  8013a3:	c1 e8 0c             	shr    $0xc,%eax
  8013a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	75 36                	jne    8013e8 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b2:	89 f8                	mov    %edi,%eax
  8013b4:	c1 e8 0c             	shr    $0xc,%eax
  8013b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c6:	50                   	push   %eax
  8013c7:	56                   	push   %esi
  8013c8:	6a 00                	push   $0x0
  8013ca:	57                   	push   %edi
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 52 f9 ff ff       	call   800d24 <sys_page_map>
  8013d2:	89 c3                	mov    %eax,%ebx
  8013d4:	83 c4 20             	add    $0x20,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 33                	js     80140e <dup+0xcd>
		goto err;

	return newfdnum;
  8013db:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013de:	89 d8                	mov    %ebx,%eax
  8013e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f7:	50                   	push   %eax
  8013f8:	ff 75 d4             	push   -0x2c(%ebp)
  8013fb:	6a 00                	push   $0x0
  8013fd:	53                   	push   %ebx
  8013fe:	6a 00                	push   $0x0
  801400:	e8 1f f9 ff ff       	call   800d24 <sys_page_map>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	83 c4 20             	add    $0x20,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	79 a4                	jns    8013b2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	56                   	push   %esi
  801412:	6a 00                	push   $0x0
  801414:	e8 4d f9 ff ff       	call   800d66 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801419:	83 c4 08             	add    $0x8,%esp
  80141c:	ff 75 d4             	push   -0x2c(%ebp)
  80141f:	6a 00                	push   $0x0
  801421:	e8 40 f9 ff ff       	call   800d66 <sys_page_unmap>
	return r;
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	eb b3                	jmp    8013de <dup+0x9d>

0080142b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	56                   	push   %esi
  80142f:	53                   	push   %ebx
  801430:	83 ec 18             	sub    $0x18,%esp
  801433:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	56                   	push   %esi
  80143b:	e8 87 fd ff ff       	call   8011c7 <fd_lookup>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 3c                	js     801483 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801447:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	ff 33                	push   (%ebx)
  801453:	e8 bf fd ff ff       	call   801217 <dev_lookup>
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 24                	js     801483 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145f:	8b 43 08             	mov    0x8(%ebx),%eax
  801462:	83 e0 03             	and    $0x3,%eax
  801465:	83 f8 01             	cmp    $0x1,%eax
  801468:	74 20                	je     80148a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146d:	8b 40 08             	mov    0x8(%eax),%eax
  801470:	85 c0                	test   %eax,%eax
  801472:	74 37                	je     8014ab <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	ff 75 10             	push   0x10(%ebp)
  80147a:	ff 75 0c             	push   0xc(%ebp)
  80147d:	53                   	push   %ebx
  80147e:	ff d0                	call   *%eax
  801480:	83 c4 10             	add    $0x10,%esp
}
  801483:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148a:	a1 00 40 80 00       	mov    0x804000,%eax
  80148f:	8b 40 48             	mov    0x48(%eax),%eax
  801492:	83 ec 04             	sub    $0x4,%esp
  801495:	56                   	push   %esi
  801496:	50                   	push   %eax
  801497:	68 39 27 80 00       	push   $0x802739
  80149c:	e8 6a ee ff ff       	call   80030b <cprintf>
		return -E_INVAL;
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a9:	eb d8                	jmp    801483 <read+0x58>
		return -E_NOT_SUPP;
  8014ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b0:	eb d1                	jmp    801483 <read+0x58>

008014b2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	57                   	push   %edi
  8014b6:	56                   	push   %esi
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014be:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c6:	eb 02                	jmp    8014ca <readn+0x18>
  8014c8:	01 c3                	add    %eax,%ebx
  8014ca:	39 f3                	cmp    %esi,%ebx
  8014cc:	73 21                	jae    8014ef <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ce:	83 ec 04             	sub    $0x4,%esp
  8014d1:	89 f0                	mov    %esi,%eax
  8014d3:	29 d8                	sub    %ebx,%eax
  8014d5:	50                   	push   %eax
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	03 45 0c             	add    0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	57                   	push   %edi
  8014dd:	e8 49 ff ff ff       	call   80142b <read>
		if (m < 0)
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 04                	js     8014ed <readn+0x3b>
			return m;
		if (m == 0)
  8014e9:	75 dd                	jne    8014c8 <readn+0x16>
  8014eb:	eb 02                	jmp    8014ef <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ed:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	56                   	push   %esi
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 18             	sub    $0x18,%esp
  801501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	53                   	push   %ebx
  801509:	e8 b9 fc ff ff       	call   8011c7 <fd_lookup>
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 37                	js     80154c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801515:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	ff 36                	push   (%esi)
  801521:	e8 f1 fc ff ff       	call   801217 <dev_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 1f                	js     80154c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801531:	74 20                	je     801553 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801533:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801536:	8b 40 0c             	mov    0xc(%eax),%eax
  801539:	85 c0                	test   %eax,%eax
  80153b:	74 37                	je     801574 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	ff 75 10             	push   0x10(%ebp)
  801543:	ff 75 0c             	push   0xc(%ebp)
  801546:	56                   	push   %esi
  801547:	ff d0                	call   *%eax
  801549:	83 c4 10             	add    $0x10,%esp
}
  80154c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801553:	a1 00 40 80 00       	mov    0x804000,%eax
  801558:	8b 40 48             	mov    0x48(%eax),%eax
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	53                   	push   %ebx
  80155f:	50                   	push   %eax
  801560:	68 55 27 80 00       	push   $0x802755
  801565:	e8 a1 ed ff ff       	call   80030b <cprintf>
		return -E_INVAL;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801572:	eb d8                	jmp    80154c <write+0x53>
		return -E_NOT_SUPP;
  801574:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801579:	eb d1                	jmp    80154c <write+0x53>

0080157b <seek>:

int
seek(int fdnum, off_t offset)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	ff 75 08             	push   0x8(%ebp)
  801588:	e8 3a fc ff ff       	call   8011c7 <fd_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 0e                	js     8015a2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
  801597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 18             	sub    $0x18,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	53                   	push   %ebx
  8015b4:	e8 0e fc ff ff       	call   8011c7 <fd_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 34                	js     8015f4 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	ff 36                	push   (%esi)
  8015cc:	e8 46 fc ff ff       	call   801217 <dev_lookup>
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 1c                	js     8015f4 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d8:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015dc:	74 1d                	je     8015fb <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e1:	8b 40 18             	mov    0x18(%eax),%eax
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	74 34                	je     80161c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	ff 75 0c             	push   0xc(%ebp)
  8015ee:	56                   	push   %esi
  8015ef:	ff d0                	call   *%eax
  8015f1:	83 c4 10             	add    $0x10,%esp
}
  8015f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5e                   	pop    %esi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015fb:	a1 00 40 80 00       	mov    0x804000,%eax
  801600:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	53                   	push   %ebx
  801607:	50                   	push   %eax
  801608:	68 18 27 80 00       	push   $0x802718
  80160d:	e8 f9 ec ff ff       	call   80030b <cprintf>
		return -E_INVAL;
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161a:	eb d8                	jmp    8015f4 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80161c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801621:	eb d1                	jmp    8015f4 <ftruncate+0x50>

00801623 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
  801628:	83 ec 18             	sub    $0x18,%esp
  80162b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	ff 75 08             	push   0x8(%ebp)
  801635:	e8 8d fb ff ff       	call   8011c7 <fd_lookup>
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 49                	js     80168a <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 36                	push   (%esi)
  80164d:	e8 c5 fb ff ff       	call   801217 <dev_lookup>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 31                	js     80168a <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801660:	74 2f                	je     801691 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801662:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801665:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80166c:	00 00 00 
	stat->st_isdir = 0;
  80166f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801676:	00 00 00 
	stat->st_dev = dev;
  801679:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	53                   	push   %ebx
  801683:	56                   	push   %esi
  801684:	ff 50 14             	call   *0x14(%eax)
  801687:	83 c4 10             	add    $0x10,%esp
}
  80168a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    
		return -E_NOT_SUPP;
  801691:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801696:	eb f2                	jmp    80168a <fstat+0x67>

00801698 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	6a 00                	push   $0x0
  8016a2:	ff 75 08             	push   0x8(%ebp)
  8016a5:	e8 e4 01 00 00       	call   80188e <open>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 1b                	js     8016ce <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	ff 75 0c             	push   0xc(%ebp)
  8016b9:	50                   	push   %eax
  8016ba:	e8 64 ff ff ff       	call   801623 <fstat>
  8016bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c1:	89 1c 24             	mov    %ebx,(%esp)
  8016c4:	e8 26 fc ff ff       	call   8012ef <close>
	return r;
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	89 f3                	mov    %esi,%ebx
}
  8016ce:	89 d8                	mov    %ebx,%eax
  8016d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	56                   	push   %esi
  8016db:	53                   	push   %ebx
  8016dc:	89 c6                	mov    %eax,%esi
  8016de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016e7:	74 27                	je     801710 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e9:	6a 07                	push   $0x7
  8016eb:	68 00 50 80 00       	push   $0x805000
  8016f0:	56                   	push   %esi
  8016f1:	ff 35 00 60 80 00    	push   0x806000
  8016f7:	e8 f8 07 00 00       	call   801ef4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016fc:	83 c4 0c             	add    $0xc,%esp
  8016ff:	6a 00                	push   $0x0
  801701:	53                   	push   %ebx
  801702:	6a 00                	push   $0x0
  801704:	e8 84 07 00 00       	call   801e8d <ipc_recv>
}
  801709:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801710:	83 ec 0c             	sub    $0xc,%esp
  801713:	6a 01                	push   $0x1
  801715:	e8 2e 08 00 00       	call   801f48 <ipc_find_env>
  80171a:	a3 00 60 80 00       	mov    %eax,0x806000
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb c5                	jmp    8016e9 <fsipc+0x12>

00801724 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	8b 40 0c             	mov    0xc(%eax),%eax
  801730:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801735:	8b 45 0c             	mov    0xc(%ebp),%eax
  801738:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 02 00 00 00       	mov    $0x2,%eax
  801747:	e8 8b ff ff ff       	call   8016d7 <fsipc>
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <devfile_flush>:
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	8b 40 0c             	mov    0xc(%eax),%eax
  80175a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80175f:	ba 00 00 00 00       	mov    $0x0,%edx
  801764:	b8 06 00 00 00       	mov    $0x6,%eax
  801769:	e8 69 ff ff ff       	call   8016d7 <fsipc>
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_stat>:
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	8b 40 0c             	mov    0xc(%eax),%eax
  801780:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	b8 05 00 00 00       	mov    $0x5,%eax
  80178f:	e8 43 ff ff ff       	call   8016d7 <fsipc>
  801794:	85 c0                	test   %eax,%eax
  801796:	78 2c                	js     8017c4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	68 00 50 80 00       	push   $0x805000
  8017a0:	53                   	push   %ebx
  8017a1:	e8 3f f1 ff ff       	call   8008e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b1:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <devfile_write>:
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	83 ec 0c             	sub    $0xc,%esp
  8017cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017d7:	39 d0                	cmp    %edx,%eax
  8017d9:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017df:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017e8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ed:	50                   	push   %eax
  8017ee:	ff 75 0c             	push   0xc(%ebp)
  8017f1:	68 08 50 80 00       	push   $0x805008
  8017f6:	e8 80 f2 ff ff       	call   800a7b <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801800:	b8 04 00 00 00       	mov    $0x4,%eax
  801805:	e8 cd fe ff ff       	call   8016d7 <fsipc>
}
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <devfile_read>:
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	56                   	push   %esi
  801810:	53                   	push   %ebx
  801811:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	8b 40 0c             	mov    0xc(%eax),%eax
  80181a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80181f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801825:	ba 00 00 00 00       	mov    $0x0,%edx
  80182a:	b8 03 00 00 00       	mov    $0x3,%eax
  80182f:	e8 a3 fe ff ff       	call   8016d7 <fsipc>
  801834:	89 c3                	mov    %eax,%ebx
  801836:	85 c0                	test   %eax,%eax
  801838:	78 1f                	js     801859 <devfile_read+0x4d>
	assert(r <= n);
  80183a:	39 f0                	cmp    %esi,%eax
  80183c:	77 24                	ja     801862 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80183e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801843:	7f 33                	jg     801878 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801845:	83 ec 04             	sub    $0x4,%esp
  801848:	50                   	push   %eax
  801849:	68 00 50 80 00       	push   $0x805000
  80184e:	ff 75 0c             	push   0xc(%ebp)
  801851:	e8 25 f2 ff ff       	call   800a7b <memmove>
	return r;
  801856:	83 c4 10             	add    $0x10,%esp
}
  801859:	89 d8                	mov    %ebx,%eax
  80185b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    
	assert(r <= n);
  801862:	68 84 27 80 00       	push   $0x802784
  801867:	68 8b 27 80 00       	push   $0x80278b
  80186c:	6a 7c                	push   $0x7c
  80186e:	68 a0 27 80 00       	push   $0x8027a0
  801873:	e8 b8 e9 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  801878:	68 ab 27 80 00       	push   $0x8027ab
  80187d:	68 8b 27 80 00       	push   $0x80278b
  801882:	6a 7d                	push   $0x7d
  801884:	68 a0 27 80 00       	push   $0x8027a0
  801889:	e8 a2 e9 ff ff       	call   800230 <_panic>

0080188e <open>:
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	83 ec 1c             	sub    $0x1c,%esp
  801896:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801899:	56                   	push   %esi
  80189a:	e8 0b f0 ff ff       	call   8008aa <strlen>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a7:	7f 6c                	jg     801915 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	e8 c2 f8 ff ff       	call   801177 <fd_alloc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 3c                	js     8018fa <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	56                   	push   %esi
  8018c2:	68 00 50 80 00       	push   $0x805000
  8018c7:	e8 19 f0 ff ff       	call   8008e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018dc:	e8 f6 fd ff ff       	call   8016d7 <fsipc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 19                	js     801903 <open+0x75>
	return fd2num(fd);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	ff 75 f4             	push   -0xc(%ebp)
  8018f0:	e8 5b f8 ff ff       	call   801150 <fd2num>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
}
  8018fa:	89 d8                	mov    %ebx,%eax
  8018fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    
		fd_close(fd, 0);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	6a 00                	push   $0x0
  801908:	ff 75 f4             	push   -0xc(%ebp)
  80190b:	e8 58 f9 ff ff       	call   801268 <fd_close>
		return r;
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	eb e5                	jmp    8018fa <open+0x6c>
		return -E_BAD_PATH;
  801915:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80191a:	eb de                	jmp    8018fa <open+0x6c>

0080191c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 08 00 00 00       	mov    $0x8,%eax
  80192c:	e8 a6 fd ff ff       	call   8016d7 <fsipc>
}
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	ff 75 08             	push   0x8(%ebp)
  801941:	e8 1a f8 ff ff       	call   801160 <fd2data>
  801946:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801948:	83 c4 08             	add    $0x8,%esp
  80194b:	68 b7 27 80 00       	push   $0x8027b7
  801950:	53                   	push   %ebx
  801951:	e8 8f ef ff ff       	call   8008e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801956:	8b 46 04             	mov    0x4(%esi),%eax
  801959:	2b 06                	sub    (%esi),%eax
  80195b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801961:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801968:	00 00 00 
	stat->st_dev = &devpipe;
  80196b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801972:	30 80 00 
	return 0;
}
  801975:	b8 00 00 00 00       	mov    $0x0,%eax
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80198b:	53                   	push   %ebx
  80198c:	6a 00                	push   $0x0
  80198e:	e8 d3 f3 ff ff       	call   800d66 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801993:	89 1c 24             	mov    %ebx,(%esp)
  801996:	e8 c5 f7 ff ff       	call   801160 <fd2data>
  80199b:	83 c4 08             	add    $0x8,%esp
  80199e:	50                   	push   %eax
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 c0 f3 ff ff       	call   800d66 <sys_page_unmap>
}
  8019a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <_pipeisclosed>:
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 1c             	sub    $0x1c,%esp
  8019b4:	89 c7                	mov    %eax,%edi
  8019b6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019b8:	a1 00 40 80 00       	mov    0x804000,%eax
  8019bd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	57                   	push   %edi
  8019c4:	e8 b8 05 00 00       	call   801f81 <pageref>
  8019c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019cc:	89 34 24             	mov    %esi,(%esp)
  8019cf:	e8 ad 05 00 00       	call   801f81 <pageref>
		nn = thisenv->env_runs;
  8019d4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8019da:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	39 cb                	cmp    %ecx,%ebx
  8019e2:	74 1b                	je     8019ff <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019e7:	75 cf                	jne    8019b8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019e9:	8b 42 58             	mov    0x58(%edx),%eax
  8019ec:	6a 01                	push   $0x1
  8019ee:	50                   	push   %eax
  8019ef:	53                   	push   %ebx
  8019f0:	68 be 27 80 00       	push   $0x8027be
  8019f5:	e8 11 e9 ff ff       	call   80030b <cprintf>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	eb b9                	jmp    8019b8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019ff:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a02:	0f 94 c0             	sete   %al
  801a05:	0f b6 c0             	movzbl %al,%eax
}
  801a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <devpipe_write>:
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 28             	sub    $0x28,%esp
  801a19:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a1c:	56                   	push   %esi
  801a1d:	e8 3e f7 ff ff       	call   801160 <fd2data>
  801a22:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	bf 00 00 00 00       	mov    $0x0,%edi
  801a2c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a2f:	75 09                	jne    801a3a <devpipe_write+0x2a>
	return i;
  801a31:	89 f8                	mov    %edi,%eax
  801a33:	eb 23                	jmp    801a58 <devpipe_write+0x48>
			sys_yield();
  801a35:	e8 88 f2 ff ff       	call   800cc2 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a3a:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3d:	8b 0b                	mov    (%ebx),%ecx
  801a3f:	8d 51 20             	lea    0x20(%ecx),%edx
  801a42:	39 d0                	cmp    %edx,%eax
  801a44:	72 1a                	jb     801a60 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801a46:	89 da                	mov    %ebx,%edx
  801a48:	89 f0                	mov    %esi,%eax
  801a4a:	e8 5c ff ff ff       	call   8019ab <_pipeisclosed>
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	74 e2                	je     801a35 <devpipe_write+0x25>
				return 0;
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5f                   	pop    %edi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a63:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a67:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a6a:	89 c2                	mov    %eax,%edx
  801a6c:	c1 fa 1f             	sar    $0x1f,%edx
  801a6f:	89 d1                	mov    %edx,%ecx
  801a71:	c1 e9 1b             	shr    $0x1b,%ecx
  801a74:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a77:	83 e2 1f             	and    $0x1f,%edx
  801a7a:	29 ca                	sub    %ecx,%edx
  801a7c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a80:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a84:	83 c0 01             	add    $0x1,%eax
  801a87:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a8a:	83 c7 01             	add    $0x1,%edi
  801a8d:	eb 9d                	jmp    801a2c <devpipe_write+0x1c>

00801a8f <devpipe_read>:
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	57                   	push   %edi
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 18             	sub    $0x18,%esp
  801a98:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a9b:	57                   	push   %edi
  801a9c:	e8 bf f6 ff ff       	call   801160 <fd2data>
  801aa1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	be 00 00 00 00       	mov    $0x0,%esi
  801aab:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aae:	75 13                	jne    801ac3 <devpipe_read+0x34>
	return i;
  801ab0:	89 f0                	mov    %esi,%eax
  801ab2:	eb 02                	jmp    801ab6 <devpipe_read+0x27>
				return i;
  801ab4:	89 f0                	mov    %esi,%eax
}
  801ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5f                   	pop    %edi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    
			sys_yield();
  801abe:	e8 ff f1 ff ff       	call   800cc2 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ac3:	8b 03                	mov    (%ebx),%eax
  801ac5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ac8:	75 18                	jne    801ae2 <devpipe_read+0x53>
			if (i > 0)
  801aca:	85 f6                	test   %esi,%esi
  801acc:	75 e6                	jne    801ab4 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ace:	89 da                	mov    %ebx,%edx
  801ad0:	89 f8                	mov    %edi,%eax
  801ad2:	e8 d4 fe ff ff       	call   8019ab <_pipeisclosed>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	74 e3                	je     801abe <devpipe_read+0x2f>
				return 0;
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae0:	eb d4                	jmp    801ab6 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae2:	99                   	cltd   
  801ae3:	c1 ea 1b             	shr    $0x1b,%edx
  801ae6:	01 d0                	add    %edx,%eax
  801ae8:	83 e0 1f             	and    $0x1f,%eax
  801aeb:	29 d0                	sub    %edx,%eax
  801aed:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801af8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801afb:	83 c6 01             	add    $0x1,%esi
  801afe:	eb ab                	jmp    801aab <devpipe_read+0x1c>

00801b00 <pipe>:
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0b:	50                   	push   %eax
  801b0c:	e8 66 f6 ff ff       	call   801177 <fd_alloc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 23 01 00 00    	js     801c41 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1e:	83 ec 04             	sub    $0x4,%esp
  801b21:	68 07 04 00 00       	push   $0x407
  801b26:	ff 75 f4             	push   -0xc(%ebp)
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 b1 f1 ff ff       	call   800ce1 <sys_page_alloc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	0f 88 04 01 00 00    	js     801c41 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b43:	50                   	push   %eax
  801b44:	e8 2e f6 ff ff       	call   801177 <fd_alloc>
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	0f 88 db 00 00 00    	js     801c31 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b56:	83 ec 04             	sub    $0x4,%esp
  801b59:	68 07 04 00 00       	push   $0x407
  801b5e:	ff 75 f0             	push   -0x10(%ebp)
  801b61:	6a 00                	push   $0x0
  801b63:	e8 79 f1 ff ff       	call   800ce1 <sys_page_alloc>
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	0f 88 bc 00 00 00    	js     801c31 <pipe+0x131>
	va = fd2data(fd0);
  801b75:	83 ec 0c             	sub    $0xc,%esp
  801b78:	ff 75 f4             	push   -0xc(%ebp)
  801b7b:	e8 e0 f5 ff ff       	call   801160 <fd2data>
  801b80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b82:	83 c4 0c             	add    $0xc,%esp
  801b85:	68 07 04 00 00       	push   $0x407
  801b8a:	50                   	push   %eax
  801b8b:	6a 00                	push   $0x0
  801b8d:	e8 4f f1 ff ff       	call   800ce1 <sys_page_alloc>
  801b92:	89 c3                	mov    %eax,%ebx
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	85 c0                	test   %eax,%eax
  801b99:	0f 88 82 00 00 00    	js     801c21 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	ff 75 f0             	push   -0x10(%ebp)
  801ba5:	e8 b6 f5 ff ff       	call   801160 <fd2data>
  801baa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bb1:	50                   	push   %eax
  801bb2:	6a 00                	push   $0x0
  801bb4:	56                   	push   %esi
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 68 f1 ff ff       	call   800d24 <sys_page_map>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	83 c4 20             	add    $0x20,%esp
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 4e                	js     801c13 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801bc5:	a1 20 30 80 00       	mov    0x803020,%eax
  801bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801be8:	83 ec 0c             	sub    $0xc,%esp
  801beb:	ff 75 f4             	push   -0xc(%ebp)
  801bee:	e8 5d f5 ff ff       	call   801150 <fd2num>
  801bf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf8:	83 c4 04             	add    $0x4,%esp
  801bfb:	ff 75 f0             	push   -0x10(%ebp)
  801bfe:	e8 4d f5 ff ff       	call   801150 <fd2num>
  801c03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c06:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c11:	eb 2e                	jmp    801c41 <pipe+0x141>
	sys_page_unmap(0, va);
  801c13:	83 ec 08             	sub    $0x8,%esp
  801c16:	56                   	push   %esi
  801c17:	6a 00                	push   $0x0
  801c19:	e8 48 f1 ff ff       	call   800d66 <sys_page_unmap>
  801c1e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c21:	83 ec 08             	sub    $0x8,%esp
  801c24:	ff 75 f0             	push   -0x10(%ebp)
  801c27:	6a 00                	push   $0x0
  801c29:	e8 38 f1 ff ff       	call   800d66 <sys_page_unmap>
  801c2e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c31:	83 ec 08             	sub    $0x8,%esp
  801c34:	ff 75 f4             	push   -0xc(%ebp)
  801c37:	6a 00                	push   $0x0
  801c39:	e8 28 f1 ff ff       	call   800d66 <sys_page_unmap>
  801c3e:	83 c4 10             	add    $0x10,%esp
}
  801c41:	89 d8                	mov    %ebx,%eax
  801c43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <pipeisclosed>:
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	ff 75 08             	push   0x8(%ebp)
  801c57:	e8 6b f5 ff ff       	call   8011c7 <fd_lookup>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 18                	js     801c7b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	ff 75 f4             	push   -0xc(%ebp)
  801c69:	e8 f2 f4 ff ff       	call   801160 <fd2data>
  801c6e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c73:	e8 33 fd ff ff       	call   8019ab <_pipeisclosed>
  801c78:	83 c4 10             	add    $0x10,%esp
}
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c82:	c3                   	ret    

00801c83 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c89:	68 d6 27 80 00       	push   $0x8027d6
  801c8e:	ff 75 0c             	push   0xc(%ebp)
  801c91:	e8 4f ec ff ff       	call   8008e5 <strcpy>
	return 0;
}
  801c96:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <devcons_write>:
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	57                   	push   %edi
  801ca1:	56                   	push   %esi
  801ca2:	53                   	push   %ebx
  801ca3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ca9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801cb4:	eb 2e                	jmp    801ce4 <devcons_write+0x47>
		m = n - tot;
  801cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb9:	29 f3                	sub    %esi,%ebx
  801cbb:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801cc0:	39 c3                	cmp    %eax,%ebx
  801cc2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cc5:	83 ec 04             	sub    $0x4,%esp
  801cc8:	53                   	push   %ebx
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	03 45 0c             	add    0xc(%ebp),%eax
  801cce:	50                   	push   %eax
  801ccf:	57                   	push   %edi
  801cd0:	e8 a6 ed ff ff       	call   800a7b <memmove>
		sys_cputs(buf, m);
  801cd5:	83 c4 08             	add    $0x8,%esp
  801cd8:	53                   	push   %ebx
  801cd9:	57                   	push   %edi
  801cda:	e8 46 ef ff ff       	call   800c25 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cdf:	01 de                	add    %ebx,%esi
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ce7:	72 cd                	jb     801cb6 <devcons_write+0x19>
}
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5e                   	pop    %esi
  801cf0:	5f                   	pop    %edi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <devcons_read>:
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 08             	sub    $0x8,%esp
  801cf9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d02:	75 07                	jne    801d0b <devcons_read+0x18>
  801d04:	eb 1f                	jmp    801d25 <devcons_read+0x32>
		sys_yield();
  801d06:	e8 b7 ef ff ff       	call   800cc2 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d0b:	e8 33 ef ff ff       	call   800c43 <sys_cgetc>
  801d10:	85 c0                	test   %eax,%eax
  801d12:	74 f2                	je     801d06 <devcons_read+0x13>
	if (c < 0)
  801d14:	78 0f                	js     801d25 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801d16:	83 f8 04             	cmp    $0x4,%eax
  801d19:	74 0c                	je     801d27 <devcons_read+0x34>
	*(char*)vbuf = c;
  801d1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1e:	88 02                	mov    %al,(%edx)
	return 1;
  801d20:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    
		return 0;
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2c:	eb f7                	jmp    801d25 <devcons_read+0x32>

00801d2e <cputchar>:
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d3a:	6a 01                	push   $0x1
  801d3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d3f:	50                   	push   %eax
  801d40:	e8 e0 ee ff ff       	call   800c25 <sys_cputs>
}
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <getchar>:
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d50:	6a 01                	push   $0x1
  801d52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	6a 00                	push   $0x0
  801d58:	e8 ce f6 ff ff       	call   80142b <read>
	if (r < 0)
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 06                	js     801d6a <getchar+0x20>
	if (r < 1)
  801d64:	74 06                	je     801d6c <getchar+0x22>
	return c;
  801d66:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    
		return -E_EOF;
  801d6c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d71:	eb f7                	jmp    801d6a <getchar+0x20>

00801d73 <iscons>:
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	ff 75 08             	push   0x8(%ebp)
  801d80:	e8 42 f4 ff ff       	call   8011c7 <fd_lookup>
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 11                	js     801d9d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d95:	39 10                	cmp    %edx,(%eax)
  801d97:	0f 94 c0             	sete   %al
  801d9a:	0f b6 c0             	movzbl %al,%eax
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <opencons>:
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801da5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	e8 c9 f3 ff ff       	call   801177 <fd_alloc>
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	85 c0                	test   %eax,%eax
  801db3:	78 3a                	js     801def <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db5:	83 ec 04             	sub    $0x4,%esp
  801db8:	68 07 04 00 00       	push   $0x407
  801dbd:	ff 75 f4             	push   -0xc(%ebp)
  801dc0:	6a 00                	push   $0x0
  801dc2:	e8 1a ef ff ff       	call   800ce1 <sys_page_alloc>
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 21                	js     801def <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	50                   	push   %eax
  801de7:	e8 64 f3 ff ff       	call   801150 <fd2num>
  801dec:	83 c4 10             	add    $0x10,%esp
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801df7:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801dfe:	74 0a                	je     801e0a <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801e0a:	e8 94 ee ff ff       	call   800ca3 <sys_getenvid>
  801e0f:	83 ec 04             	sub    $0x4,%esp
  801e12:	68 07 0e 00 00       	push   $0xe07
  801e17:	68 00 f0 bf ee       	push   $0xeebff000
  801e1c:	50                   	push   %eax
  801e1d:	e8 bf ee ff ff       	call   800ce1 <sys_page_alloc>
		if (r < 0) {
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 2c                	js     801e55 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e29:	e8 75 ee ff ff       	call   800ca3 <sys_getenvid>
  801e2e:	83 ec 08             	sub    $0x8,%esp
  801e31:	68 67 1e 80 00       	push   $0x801e67
  801e36:	50                   	push   %eax
  801e37:	e8 f0 ef ff ff       	call   800e2c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	79 bd                	jns    801e00 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801e43:	50                   	push   %eax
  801e44:	68 24 28 80 00       	push   $0x802824
  801e49:	6a 28                	push   $0x28
  801e4b:	68 5a 28 80 00       	push   $0x80285a
  801e50:	e8 db e3 ff ff       	call   800230 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801e55:	50                   	push   %eax
  801e56:	68 e4 27 80 00       	push   $0x8027e4
  801e5b:	6a 23                	push   $0x23
  801e5d:	68 5a 28 80 00       	push   $0x80285a
  801e62:	e8 c9 e3 ff ff       	call   800230 <_panic>

00801e67 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e67:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e68:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801e6d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e6f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801e72:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801e76:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801e79:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801e7d:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801e81:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801e83:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801e86:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801e87:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801e8a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801e8b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801e8c:	c3                   	ret    

00801e8d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	8b 75 08             	mov    0x8(%ebp),%esi
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ea2:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	50                   	push   %eax
  801ea9:	e8 e3 ef ff ff       	call   800e91 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 f6                	test   %esi,%esi
  801eb3:	74 14                	je     801ec9 <ipc_recv+0x3c>
  801eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 09                	js     801ec7 <ipc_recv+0x3a>
  801ebe:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ec4:	8b 52 74             	mov    0x74(%edx),%edx
  801ec7:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ec9:	85 db                	test   %ebx,%ebx
  801ecb:	74 14                	je     801ee1 <ipc_recv+0x54>
  801ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 09                	js     801edf <ipc_recv+0x52>
  801ed6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801edc:	8b 52 78             	mov    0x78(%edx),%edx
  801edf:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 08                	js     801eed <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801ee5:	a1 00 40 80 00       	mov    0x804000,%eax
  801eea:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    

00801ef4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	57                   	push   %edi
  801ef8:	56                   	push   %esi
  801ef9:	53                   	push   %ebx
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f00:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f06:	85 db                	test   %ebx,%ebx
  801f08:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f0d:	0f 44 d8             	cmove  %eax,%ebx
  801f10:	eb 05                	jmp    801f17 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f12:	e8 ab ed ff ff       	call   800cc2 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f17:	ff 75 14             	push   0x14(%ebp)
  801f1a:	53                   	push   %ebx
  801f1b:	56                   	push   %esi
  801f1c:	57                   	push   %edi
  801f1d:	e8 4c ef ff ff       	call   800e6e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f28:	74 e8                	je     801f12 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 08                	js     801f36 <ipc_send+0x42>
	}while (r<0);

}
  801f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f31:	5b                   	pop    %ebx
  801f32:	5e                   	pop    %esi
  801f33:	5f                   	pop    %edi
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f36:	50                   	push   %eax
  801f37:	68 68 28 80 00       	push   $0x802868
  801f3c:	6a 3d                	push   $0x3d
  801f3e:	68 7c 28 80 00       	push   $0x80287c
  801f43:	e8 e8 e2 ff ff       	call   800230 <_panic>

00801f48 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f53:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f56:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5c:	8b 52 50             	mov    0x50(%edx),%edx
  801f5f:	39 ca                	cmp    %ecx,%edx
  801f61:	74 11                	je     801f74 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f63:	83 c0 01             	add    $0x1,%eax
  801f66:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6b:	75 e6                	jne    801f53 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f72:	eb 0b                	jmp    801f7f <ipc_find_env+0x37>
			return envs[i].env_id;
  801f74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7c:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f87:	89 c2                	mov    %eax,%edx
  801f89:	c1 ea 16             	shr    $0x16,%edx
  801f8c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801f93:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801f98:	f6 c1 01             	test   $0x1,%cl
  801f9b:	74 1c                	je     801fb9 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801f9d:	c1 e8 0c             	shr    $0xc,%eax
  801fa0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fa7:	a8 01                	test   $0x1,%al
  801fa9:	74 0e                	je     801fb9 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fab:	c1 e8 0c             	shr    $0xc,%eax
  801fae:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fb5:	ef 
  801fb6:	0f b7 d2             	movzwl %dx,%edx
}
  801fb9:	89 d0                	mov    %edx,%eax
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	f3 0f 1e fb          	endbr32 
  801fc4:	55                   	push   %ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 1c             	sub    $0x1c,%esp
  801fcb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	75 19                	jne    801ff8 <__udivdi3+0x38>
  801fdf:	39 f3                	cmp    %esi,%ebx
  801fe1:	76 4d                	jbe    802030 <__udivdi3+0x70>
  801fe3:	31 ff                	xor    %edi,%edi
  801fe5:	89 e8                	mov    %ebp,%eax
  801fe7:	89 f2                	mov    %esi,%edx
  801fe9:	f7 f3                	div    %ebx
  801feb:	89 fa                	mov    %edi,%edx
  801fed:	83 c4 1c             	add    $0x1c,%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi
  801ff8:	39 f0                	cmp    %esi,%eax
  801ffa:	76 14                	jbe    802010 <__udivdi3+0x50>
  801ffc:	31 ff                	xor    %edi,%edi
  801ffe:	31 c0                	xor    %eax,%eax
  802000:	89 fa                	mov    %edi,%edx
  802002:	83 c4 1c             	add    $0x1c,%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
  80200a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802010:	0f bd f8             	bsr    %eax,%edi
  802013:	83 f7 1f             	xor    $0x1f,%edi
  802016:	75 48                	jne    802060 <__udivdi3+0xa0>
  802018:	39 f0                	cmp    %esi,%eax
  80201a:	72 06                	jb     802022 <__udivdi3+0x62>
  80201c:	31 c0                	xor    %eax,%eax
  80201e:	39 eb                	cmp    %ebp,%ebx
  802020:	77 de                	ja     802000 <__udivdi3+0x40>
  802022:	b8 01 00 00 00       	mov    $0x1,%eax
  802027:	eb d7                	jmp    802000 <__udivdi3+0x40>
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d9                	mov    %ebx,%ecx
  802032:	85 db                	test   %ebx,%ebx
  802034:	75 0b                	jne    802041 <__udivdi3+0x81>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f3                	div    %ebx
  80203f:	89 c1                	mov    %eax,%ecx
  802041:	31 d2                	xor    %edx,%edx
  802043:	89 f0                	mov    %esi,%eax
  802045:	f7 f1                	div    %ecx
  802047:	89 c6                	mov    %eax,%esi
  802049:	89 e8                	mov    %ebp,%eax
  80204b:	89 f7                	mov    %esi,%edi
  80204d:	f7 f1                	div    %ecx
  80204f:	89 fa                	mov    %edi,%edx
  802051:	83 c4 1c             	add    $0x1c,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 f9                	mov    %edi,%ecx
  802062:	ba 20 00 00 00       	mov    $0x20,%edx
  802067:	29 fa                	sub    %edi,%edx
  802069:	d3 e0                	shl    %cl,%eax
  80206b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80206f:	89 d1                	mov    %edx,%ecx
  802071:	89 d8                	mov    %ebx,%eax
  802073:	d3 e8                	shr    %cl,%eax
  802075:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802079:	09 c1                	or     %eax,%ecx
  80207b:	89 f0                	mov    %esi,%eax
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e3                	shl    %cl,%ebx
  802085:	89 d1                	mov    %edx,%ecx
  802087:	d3 e8                	shr    %cl,%eax
  802089:	89 f9                	mov    %edi,%ecx
  80208b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80208f:	89 eb                	mov    %ebp,%ebx
  802091:	d3 e6                	shl    %cl,%esi
  802093:	89 d1                	mov    %edx,%ecx
  802095:	d3 eb                	shr    %cl,%ebx
  802097:	09 f3                	or     %esi,%ebx
  802099:	89 c6                	mov    %eax,%esi
  80209b:	89 f2                	mov    %esi,%edx
  80209d:	89 d8                	mov    %ebx,%eax
  80209f:	f7 74 24 08          	divl   0x8(%esp)
  8020a3:	89 d6                	mov    %edx,%esi
  8020a5:	89 c3                	mov    %eax,%ebx
  8020a7:	f7 64 24 0c          	mull   0xc(%esp)
  8020ab:	39 d6                	cmp    %edx,%esi
  8020ad:	72 19                	jb     8020c8 <__udivdi3+0x108>
  8020af:	89 f9                	mov    %edi,%ecx
  8020b1:	d3 e5                	shl    %cl,%ebp
  8020b3:	39 c5                	cmp    %eax,%ebp
  8020b5:	73 04                	jae    8020bb <__udivdi3+0xfb>
  8020b7:	39 d6                	cmp    %edx,%esi
  8020b9:	74 0d                	je     8020c8 <__udivdi3+0x108>
  8020bb:	89 d8                	mov    %ebx,%eax
  8020bd:	31 ff                	xor    %edi,%edi
  8020bf:	e9 3c ff ff ff       	jmp    802000 <__udivdi3+0x40>
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020cb:	31 ff                	xor    %edi,%edi
  8020cd:	e9 2e ff ff ff       	jmp    802000 <__udivdi3+0x40>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	f3 0f 1e fb          	endbr32 
  8020e4:	55                   	push   %ebp
  8020e5:	57                   	push   %edi
  8020e6:	56                   	push   %esi
  8020e7:	53                   	push   %ebx
  8020e8:	83 ec 1c             	sub    $0x1c,%esp
  8020eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8020f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8020fb:	89 f0                	mov    %esi,%eax
  8020fd:	89 da                	mov    %ebx,%edx
  8020ff:	85 ff                	test   %edi,%edi
  802101:	75 15                	jne    802118 <__umoddi3+0x38>
  802103:	39 dd                	cmp    %ebx,%ebp
  802105:	76 39                	jbe    802140 <__umoddi3+0x60>
  802107:	f7 f5                	div    %ebp
  802109:	89 d0                	mov    %edx,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	83 c4 1c             	add    $0x1c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    
  802115:	8d 76 00             	lea    0x0(%esi),%esi
  802118:	39 df                	cmp    %ebx,%edi
  80211a:	77 f1                	ja     80210d <__umoddi3+0x2d>
  80211c:	0f bd cf             	bsr    %edi,%ecx
  80211f:	83 f1 1f             	xor    $0x1f,%ecx
  802122:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802126:	75 40                	jne    802168 <__umoddi3+0x88>
  802128:	39 df                	cmp    %ebx,%edi
  80212a:	72 04                	jb     802130 <__umoddi3+0x50>
  80212c:	39 f5                	cmp    %esi,%ebp
  80212e:	77 dd                	ja     80210d <__umoddi3+0x2d>
  802130:	89 da                	mov    %ebx,%edx
  802132:	89 f0                	mov    %esi,%eax
  802134:	29 e8                	sub    %ebp,%eax
  802136:	19 fa                	sbb    %edi,%edx
  802138:	eb d3                	jmp    80210d <__umoddi3+0x2d>
  80213a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802140:	89 e9                	mov    %ebp,%ecx
  802142:	85 ed                	test   %ebp,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x71>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f5                	div    %ebp
  80214f:	89 c1                	mov    %eax,%ecx
  802151:	89 d8                	mov    %ebx,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f1                	div    %ecx
  802157:	89 f0                	mov    %esi,%eax
  802159:	f7 f1                	div    %ecx
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	eb ac                	jmp    80210d <__umoddi3+0x2d>
  802161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802168:	8b 44 24 04          	mov    0x4(%esp),%eax
  80216c:	ba 20 00 00 00       	mov    $0x20,%edx
  802171:	29 c2                	sub    %eax,%edx
  802173:	89 c1                	mov    %eax,%ecx
  802175:	89 e8                	mov    %ebp,%eax
  802177:	d3 e7                	shl    %cl,%edi
  802179:	89 d1                	mov    %edx,%ecx
  80217b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80217f:	d3 e8                	shr    %cl,%eax
  802181:	89 c1                	mov    %eax,%ecx
  802183:	8b 44 24 04          	mov    0x4(%esp),%eax
  802187:	09 f9                	or     %edi,%ecx
  802189:	89 df                	mov    %ebx,%edi
  80218b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	d3 e5                	shl    %cl,%ebp
  802193:	89 d1                	mov    %edx,%ecx
  802195:	d3 ef                	shr    %cl,%edi
  802197:	89 c1                	mov    %eax,%ecx
  802199:	89 f0                	mov    %esi,%eax
  80219b:	d3 e3                	shl    %cl,%ebx
  80219d:	89 d1                	mov    %edx,%ecx
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	d3 e8                	shr    %cl,%eax
  8021a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021a8:	09 d8                	or     %ebx,%eax
  8021aa:	f7 74 24 08          	divl   0x8(%esp)
  8021ae:	89 d3                	mov    %edx,%ebx
  8021b0:	d3 e6                	shl    %cl,%esi
  8021b2:	f7 e5                	mul    %ebp
  8021b4:	89 c7                	mov    %eax,%edi
  8021b6:	89 d1                	mov    %edx,%ecx
  8021b8:	39 d3                	cmp    %edx,%ebx
  8021ba:	72 06                	jb     8021c2 <__umoddi3+0xe2>
  8021bc:	75 0e                	jne    8021cc <__umoddi3+0xec>
  8021be:	39 c6                	cmp    %eax,%esi
  8021c0:	73 0a                	jae    8021cc <__umoddi3+0xec>
  8021c2:	29 e8                	sub    %ebp,%eax
  8021c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021c8:	89 d1                	mov    %edx,%ecx
  8021ca:	89 c7                	mov    %eax,%edi
  8021cc:	89 f5                	mov    %esi,%ebp
  8021ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021d2:	29 fd                	sub    %edi,%ebp
  8021d4:	19 cb                	sbb    %ecx,%ebx
  8021d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021db:	89 d8                	mov    %ebx,%eax
  8021dd:	d3 e0                	shl    %cl,%eax
  8021df:	89 f1                	mov    %esi,%ecx
  8021e1:	d3 ed                	shr    %cl,%ebp
  8021e3:	d3 eb                	shr    %cl,%ebx
  8021e5:	09 e8                	or     %ebp,%eax
  8021e7:	89 da                	mov    %ebx,%edx
  8021e9:	83 c4 1c             	add    $0x1c,%esp
  8021ec:	5b                   	pop    %ebx
  8021ed:	5e                   	pop    %esi
  8021ee:	5f                   	pop    %edi
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    
