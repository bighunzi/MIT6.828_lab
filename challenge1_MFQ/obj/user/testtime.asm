
obj/user/testtime.debug：     文件格式 elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003a:	e8 ba 0d 00 00       	call   800df9 <sys_time_msec>
	unsigned end = now + sec * 1000;
  80003f:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  800046:	01 c3                	add    %eax,%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
  800048:	85 c0                	test   %eax,%eax
  80004a:	79 05                	jns    800051 <sleep+0x1e>
  80004c:	83 f8 f1             	cmp    $0xfffffff1,%eax
  80004f:	7d 18                	jge    800069 <sleep+0x36>
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
  800051:	39 d8                	cmp    %ebx,%eax
  800053:	76 2b                	jbe    800080 <sleep+0x4d>
		panic("sleep: wrap");
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	68 22 23 80 00       	push   $0x802322
  80005d:	6a 0d                	push   $0xd
  80005f:	68 12 23 80 00       	push   $0x802312
  800064:	e8 ee 00 00 00       	call   800157 <_panic>
		panic("sys_time_msec: %e", (int)now);
  800069:	50                   	push   %eax
  80006a:	68 00 23 80 00       	push   $0x802300
  80006f:	6a 0b                	push   $0xb
  800071:	68 12 23 80 00       	push   $0x802312
  800076:	e8 dc 00 00 00       	call   800157 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  80007b:	e8 69 0b 00 00       	call   800be9 <sys_yield>
	while (sys_time_msec() < end)
  800080:	e8 74 0d 00 00       	call   800df9 <sys_time_msec>
  800085:	39 d8                	cmp    %ebx,%eax
  800087:	72 f2                	jb     80007b <sleep+0x48>
}
  800089:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    

0080008e <umain>:

void
umain(int argc, char **argv)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	53                   	push   %ebx
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  80009a:	e8 4a 0b 00 00       	call   800be9 <sys_yield>
	for (i = 0; i < 50; i++)
  80009f:	83 eb 01             	sub    $0x1,%ebx
  8000a2:	75 f6                	jne    80009a <umain+0xc>

	cprintf("starting count down: ");
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	68 2e 23 80 00       	push   $0x80232e
  8000ac:	e8 81 01 00 00       	call   800232 <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b4:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	53                   	push   %ebx
  8000bd:	68 44 23 80 00       	push   $0x802344
  8000c2:	e8 6b 01 00 00       	call   800232 <cprintf>
		sleep(1);
  8000c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ce:	e8 60 ff ff ff       	call   800033 <sleep>
	for (i = 5; i >= 0; i--) {
  8000d3:	83 eb 01             	sub    $0x1,%ebx
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000dc:	75 db                	jne    8000b9 <umain+0x2b>
	}
	cprintf("\n");
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	68 c0 27 80 00       	push   $0x8027c0
  8000e6:	e8 47 01 00 00       	call   800232 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8000eb:	cc                   	int3   
	breakpoint();
}
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ff:	e8 c6 0a 00 00       	call   800bca <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	e8 60 ff ff ff       	call   80008e <umain>

	// exit gracefully
	exit();
  80012e:	e8 0a 00 00 00       	call   80013d <exit>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800143:	e8 e3 0e 00 00       	call   80102b <close_all>
	sys_env_destroy(0);
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	6a 00                	push   $0x0
  80014d:	e8 37 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800165:	e8 60 0a 00 00       	call   800bca <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	push   0xc(%ebp)
  800170:	ff 75 08             	push   0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 54 23 80 00       	push   $0x802354
  80017a:	e8 b3 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	push   0x10(%ebp)
  800186:	e8 56 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  800192:	e8 9b 00 00 00       	call   800232 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x43>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 04             	sub    $0x4,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	74 09                	je     8001c5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 76 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	eb db                	jmp    8001bc <putch+0x1f>

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	push   0xc(%ebp)
  800201:	ff 75 08             	push   0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9d 01 80 00       	push   $0x80019d
  800210:	e8 14 01 00 00       	call   800329 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 22 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	push   0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 d1                	mov    %edx,%ecx
  80025b:	89 c2                	mov    %eax,%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800269:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800273:	39 c2                	cmp    %eax,%edx
  800275:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800278:	72 3e                	jb     8002b8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	push   0x18(%ebp)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	push   -0x1c(%ebp)
  80028b:	ff 75 e0             	push   -0x20(%ebp)
  80028e:	ff 75 dc             	push   -0x24(%ebp)
  800291:	ff 75 d8             	push   -0x28(%ebp)
  800294:	e8 17 1e 00 00       	call   8020b0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9f ff ff ff       	call   800246 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 13                	jmp    8002bf <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	push   0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	7f ed                	jg     8002ac <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 e4             	push   -0x1c(%ebp)
  8002c9:	ff 75 e0             	push   -0x20(%ebp)
  8002cc:	ff 75 dc             	push   -0x24(%ebp)
  8002cf:	ff 75 d8             	push   -0x28(%ebp)
  8002d2:	e8 f9 1e 00 00       	call   8021d0 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 77 23 80 00 	movsbl 0x802377(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
}
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8d 4a 01             	lea    0x1(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	88 02                	mov    %al,(%edx)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 10             	push   0x10(%ebp)
  800319:	ff 75 0c             	push   0xc(%ebp)
  80031c:	ff 75 08             	push   0x8(%ebp)
  80031f:	e8 05 00 00 00       	call   800329 <vprintfmt>
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <vprintfmt>:
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 3c             	sub    $0x3c,%esp
  800332:	8b 75 08             	mov    0x8(%ebp),%esi
  800335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800338:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033b:	eb 0a                	jmp    800347 <vprintfmt+0x1e>
			putch(ch, putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	53                   	push   %ebx
  800341:	50                   	push   %eax
  800342:	ff d6                	call   *%esi
  800344:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800347:	83 c7 01             	add    $0x1,%edi
  80034a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034e:	83 f8 25             	cmp    $0x25,%eax
  800351:	74 0c                	je     80035f <vprintfmt+0x36>
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	75 e6                	jne    80033d <vprintfmt+0x14>
}
  800357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    
		padc = ' ';
  80035f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800363:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80036a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800371:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800378:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8d 47 01             	lea    0x1(%edi),%eax
  800380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800383:	0f b6 17             	movzbl (%edi),%edx
  800386:	8d 42 dd             	lea    -0x23(%edx),%eax
  800389:	3c 55                	cmp    $0x55,%al
  80038b:	0f 87 bb 03 00 00    	ja     80074c <vprintfmt+0x423>
  800391:	0f b6 c0             	movzbl %al,%eax
  800394:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80039e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a2:	eb d9                	jmp    80037d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ab:	eb d0                	jmp    80037d <vprintfmt+0x54>
  8003ad:	0f b6 d2             	movzbl %dl,%edx
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003be:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c8:	83 f9 09             	cmp    $0x9,%ecx
  8003cb:	77 55                	ja     800422 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d0:	eb e9                	jmp    8003bb <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 40 04             	lea    0x4(%eax),%eax
  8003e0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ea:	79 91                	jns    80037d <vprintfmt+0x54>
				width = precision, precision = -1;
  8003ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f9:	eb 82                	jmp    80037d <vprintfmt+0x54>
  8003fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fe:	85 d2                	test   %edx,%edx
  800400:	b8 00 00 00 00       	mov    $0x0,%eax
  800405:	0f 49 c2             	cmovns %edx,%eax
  800408:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040e:	e9 6a ff ff ff       	jmp    80037d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800416:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041d:	e9 5b ff ff ff       	jmp    80037d <vprintfmt+0x54>
  800422:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800425:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800428:	eb bc                	jmp    8003e6 <vprintfmt+0xbd>
			lflag++;
  80042a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800430:	e9 48 ff ff ff       	jmp    80037d <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 78 04             	lea    0x4(%eax),%edi
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 30                	push   (%eax)
  800441:	ff d6                	call   *%esi
			break;
  800443:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800446:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800449:	e9 9d 02 00 00       	jmp    8006eb <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 78 04             	lea    0x4(%eax),%edi
  800454:	8b 10                	mov    (%eax),%edx
  800456:	89 d0                	mov    %edx,%eax
  800458:	f7 d8                	neg    %eax
  80045a:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045d:	83 f8 0f             	cmp    $0xf,%eax
  800460:	7f 23                	jg     800485 <vprintfmt+0x15c>
  800462:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	74 18                	je     800485 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80046d:	52                   	push   %edx
  80046e:	68 55 27 80 00       	push   $0x802755
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 92 fe ff ff       	call   80030c <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800480:	e9 66 02 00 00       	jmp    8006eb <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800485:	50                   	push   %eax
  800486:	68 8f 23 80 00       	push   $0x80238f
  80048b:	53                   	push   %ebx
  80048c:	56                   	push   %esi
  80048d:	e8 7a fe ff ff       	call   80030c <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800495:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800498:	e9 4e 02 00 00       	jmp    8006eb <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	83 c0 04             	add    $0x4,%eax
  8004a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	b8 88 23 80 00       	mov    $0x802388,%eax
  8004b2:	0f 45 c2             	cmovne %edx,%eax
  8004b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bc:	7e 06                	jle    8004c4 <vprintfmt+0x19b>
  8004be:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c2:	75 0d                	jne    8004d1 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c7:	89 c7                	mov    %eax,%edi
  8004c9:	03 45 e0             	add    -0x20(%ebp),%eax
  8004cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cf:	eb 55                	jmp    800526 <vprintfmt+0x1fd>
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 d8             	push   -0x28(%ebp)
  8004d7:	ff 75 cc             	push   -0x34(%ebp)
  8004da:	e8 0a 03 00 00       	call   8007e9 <strnlen>
  8004df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e2:	29 c1                	sub    %eax,%ecx
  8004e4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004ec:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	eb 0f                	jmp    800504 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	ff 75 e0             	push   -0x20(%ebp)
  8004fc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	83 ef 01             	sub    $0x1,%edi
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	85 ff                	test   %edi,%edi
  800506:	7f ed                	jg     8004f5 <vprintfmt+0x1cc>
  800508:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050b:	85 d2                	test   %edx,%edx
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 49 c2             	cmovns %edx,%eax
  800515:	29 c2                	sub    %eax,%edx
  800517:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051a:	eb a8                	jmp    8004c4 <vprintfmt+0x19b>
					putch(ch, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	52                   	push   %edx
  800521:	ff d6                	call   *%esi
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 c7 01             	add    $0x1,%edi
  80052e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800532:	0f be d0             	movsbl %al,%edx
  800535:	85 d2                	test   %edx,%edx
  800537:	74 4b                	je     800584 <vprintfmt+0x25b>
  800539:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053d:	78 06                	js     800545 <vprintfmt+0x21c>
  80053f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800543:	78 1e                	js     800563 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800545:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800549:	74 d1                	je     80051c <vprintfmt+0x1f3>
  80054b:	0f be c0             	movsbl %al,%eax
  80054e:	83 e8 20             	sub    $0x20,%eax
  800551:	83 f8 5e             	cmp    $0x5e,%eax
  800554:	76 c6                	jbe    80051c <vprintfmt+0x1f3>
					putch('?', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 3f                	push   $0x3f
  80055c:	ff d6                	call   *%esi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb c3                	jmp    800526 <vprintfmt+0x1fd>
  800563:	89 cf                	mov    %ecx,%edi
  800565:	eb 0e                	jmp    800575 <vprintfmt+0x24c>
				putch(' ', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	6a 20                	push   $0x20
  80056d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056f:	83 ef 01             	sub    $0x1,%edi
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 ff                	test   %edi,%edi
  800577:	7f ee                	jg     800567 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800579:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	e9 67 01 00 00       	jmp    8006eb <vprintfmt+0x3c2>
  800584:	89 cf                	mov    %ecx,%edi
  800586:	eb ed                	jmp    800575 <vprintfmt+0x24c>
	if (lflag >= 2)
  800588:	83 f9 01             	cmp    $0x1,%ecx
  80058b:	7f 1b                	jg     8005a8 <vprintfmt+0x27f>
	else if (lflag)
  80058d:	85 c9                	test   %ecx,%ecx
  80058f:	74 63                	je     8005f4 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	99                   	cltd   
  80059a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 40 04             	lea    0x4(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a6:	eb 17                	jmp    8005bf <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 50 04             	mov    0x4(%eax),%edx
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 08             	lea    0x8(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	0f 89 ff 00 00 00    	jns    8006d1 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 d1 00             	adc    $0x0,%ecx
  8005e5:	f7 d9                	neg    %ecx
  8005e7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ea:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ef:	e9 dd 00 00 00       	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	99                   	cltd   
  8005fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 40 04             	lea    0x4(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	eb b4                	jmp    8005bf <vprintfmt+0x296>
	if (lflag >= 2)
  80060b:	83 f9 01             	cmp    $0x1,%ecx
  80060e:	7f 1e                	jg     80062e <vprintfmt+0x305>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 32                	je     800646 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800629:	e9 a3 00 00 00       	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	8b 48 04             	mov    0x4(%eax),%ecx
  800636:	8d 40 08             	lea    0x8(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800641:	e9 8b 00 00 00       	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800656:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80065b:	eb 74                	jmp    8006d1 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80065d:	83 f9 01             	cmp    $0x1,%ecx
  800660:	7f 1b                	jg     80067d <vprintfmt+0x354>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 2c                	je     800692 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800676:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80067b:	eb 54                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8b 48 04             	mov    0x4(%eax),%ecx
  800685:	8d 40 08             	lea    0x8(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800690:	eb 3f                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006a2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006a7:	eb 28                	jmp    8006d1 <vprintfmt+0x3a8>
			putch('0', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 30                	push   $0x30
  8006af:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b1:	83 c4 08             	add    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 78                	push   $0x78
  8006b7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cc:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006d1:	83 ec 0c             	sub    $0xc,%esp
  8006d4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 e0             	push   -0x20(%ebp)
  8006dc:	57                   	push   %edi
  8006dd:	51                   	push   %ecx
  8006de:	52                   	push   %edx
  8006df:	89 da                	mov    %ebx,%edx
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	e8 5e fb ff ff       	call   800246 <printnum>
			break;
  8006e8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ee:	e9 54 fc ff ff       	jmp    800347 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7f 1b                	jg     800713 <vprintfmt+0x3ea>
	else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 2c                	je     800728 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800711:	eb be                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	8b 48 04             	mov    0x4(%eax),%ecx
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800721:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800726:	eb a9                	jmp    8006d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800738:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80073d:	eb 92                	jmp    8006d1 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 25                	push   $0x25
  800745:	ff d6                	call   *%esi
			break;
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 9f                	jmp    8006eb <vprintfmt+0x3c2>
			putch('%', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 25                	push   $0x25
  800752:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	89 f8                	mov    %edi,%eax
  800759:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075d:	74 05                	je     800764 <vprintfmt+0x43b>
  80075f:	83 e8 01             	sub    $0x1,%eax
  800762:	eb f5                	jmp    800759 <vprintfmt+0x430>
  800764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800767:	eb 82                	jmp    8006eb <vprintfmt+0x3c2>

00800769 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 18             	sub    $0x18,%esp
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800775:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800778:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800786:	85 c0                	test   %eax,%eax
  800788:	74 26                	je     8007b0 <vsnprintf+0x47>
  80078a:	85 d2                	test   %edx,%edx
  80078c:	7e 22                	jle    8007b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078e:	ff 75 14             	push   0x14(%ebp)
  800791:	ff 75 10             	push   0x10(%ebp)
  800794:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	68 ef 02 80 00       	push   $0x8002ef
  80079d:	e8 87 fb ff ff       	call   800329 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ab:	83 c4 10             	add    $0x10,%esp
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    
		return -E_INVAL;
  8007b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b5:	eb f7                	jmp    8007ae <vsnprintf+0x45>

008007b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c0:	50                   	push   %eax
  8007c1:	ff 75 10             	push   0x10(%ebp)
  8007c4:	ff 75 0c             	push   0xc(%ebp)
  8007c7:	ff 75 08             	push   0x8(%ebp)
  8007ca:	e8 9a ff ff ff       	call   800769 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	eb 03                	jmp    8007e1 <strlen+0x10>
		n++;
  8007de:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e5:	75 f7                	jne    8007de <strlen+0xd>
	return n;
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	eb 03                	jmp    8007fc <strnlen+0x13>
		n++;
  8007f9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 d0                	cmp    %edx,%eax
  8007fe:	74 08                	je     800808 <strnlen+0x1f>
  800800:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800804:	75 f3                	jne    8007f9 <strnlen+0x10>
  800806:	89 c2                	mov    %eax,%edx
	return n;
}
  800808:	89 d0                	mov    %edx,%eax
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80081f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f2                	jne    80081b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	89 c8                	mov    %ecx,%eax
  80082b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 10             	sub    $0x10,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 91 ff ff ff       	call   8007d1 <strlen>
  800840:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800843:	ff 75 0c             	push   0xc(%ebp)
  800846:	01 d8                	add    %ebx,%eax
  800848:	50                   	push   %eax
  800849:	e8 be ff ff ff       	call   80080c <strcpy>
	return dst;
}
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800860:	89 f3                	mov    %esi,%ebx
  800862:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	89 f0                	mov    %esi,%eax
  800867:	eb 0f                	jmp    800878 <strncpy+0x23>
		*dst++ = *src;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	0f b6 0a             	movzbl (%edx),%ecx
  80086f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800872:	80 f9 01             	cmp    $0x1,%cl
  800875:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	75 ed                	jne    800869 <strncpy+0x14>
	}
	return ret;
}
  80087c:	89 f0                	mov    %esi,%eax
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 10             	mov    0x10(%ebp),%edx
  800890:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	74 21                	je     8008b7 <strlcpy+0x35>
  800896:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089a:	89 f2                	mov    %esi,%edx
  80089c:	eb 09                	jmp    8008a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 09                	je     8008b4 <strlcpy+0x32>
  8008ab:	0f b6 19             	movzbl (%ecx),%ebx
  8008ae:	84 db                	test   %bl,%bl
  8008b0:	75 ec                	jne    80089e <strlcpy+0x1c>
  8008b2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strcmp+0x11>
		p++, q++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x1c>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 ef                	je     8008c8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strncmp+0x17>
		n--, p++, q++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 18                	je     800916 <strncmp+0x33>
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 04                	je     800909 <strncmp+0x26>
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 eb                	je     8008f4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 00             	movzbl (%eax),%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    
		return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb f4                	jmp    800911 <strncmp+0x2e>

0080091d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 03                	jmp    80092c <strchr+0xf>
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 06                	je     800939 <strchr+0x1c>
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	75 f2                	jne    800929 <strchr+0xc>
  800937:	eb 05                	jmp    80093e <strchr+0x21>
			return (char *) s;
	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 09                	je     80095a <strfind+0x1a>
  800951:	84 d2                	test   %dl,%dl
  800953:	74 05                	je     80095a <strfind+0x1a>
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	eb f0                	jmp    80094a <strfind+0xa>
			break;
	return (char *) s;
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 7d 08             	mov    0x8(%ebp),%edi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 2f                	je     80099b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	09 c8                	or     %ecx,%eax
  800970:	a8 03                	test   $0x3,%al
  800972:	75 21                	jne    800995 <memset+0x39>
		c &= 0xFF;
  800974:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800978:	89 d0                	mov    %edx,%eax
  80097a:	c1 e0 08             	shl    $0x8,%eax
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	c1 e3 18             	shl    $0x18,%ebx
  800982:	89 d6                	mov    %edx,%esi
  800984:	c1 e6 10             	shl    $0x10,%esi
  800987:	09 f3                	or     %esi,%ebx
  800989:	09 da                	or     %ebx,%edx
  80098b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800990:	fc                   	cld    
  800991:	f3 ab                	rep stos %eax,%es:(%edi)
  800993:	eb 06                	jmp    80099b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	fc                   	cld    
  800999:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099b:	89 f8                	mov    %edi,%eax
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b0:	39 c6                	cmp    %eax,%esi
  8009b2:	73 32                	jae    8009e6 <memmove+0x44>
  8009b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b7:	39 c2                	cmp    %eax,%edx
  8009b9:	76 2b                	jbe    8009e6 <memmove+0x44>
		s += n;
		d += n;
  8009bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	09 fe                	or     %edi,%esi
  8009c2:	09 ce                	or     %ecx,%esi
  8009c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ca:	75 0e                	jne    8009da <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cc:	83 ef 04             	sub    $0x4,%edi
  8009cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d5:	fd                   	std    
  8009d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d8:	eb 09                	jmp    8009e3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009da:	83 ef 01             	sub    $0x1,%edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 1a                	jmp    800a00 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	89 f2                	mov    %esi,%edx
  8009e8:	09 c2                	or     %eax,%edx
  8009ea:	09 ca                	or     %ecx,%edx
  8009ec:	f6 c2 03             	test   $0x3,%dl
  8009ef:	75 0a                	jne    8009fb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	fc                   	cld    
  8009f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f9:	eb 05                	jmp    800a00 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a0a:	ff 75 10             	push   0x10(%ebp)
  800a0d:	ff 75 0c             	push   0xc(%ebp)
  800a10:	ff 75 08             	push   0x8(%ebp)
  800a13:	e8 8a ff ff ff       	call   8009a2 <memmove>
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a25:	89 c6                	mov    %eax,%esi
  800a27:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	eb 06                	jmp    800a32 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a32:	39 f0                	cmp    %esi,%eax
  800a34:	74 14                	je     800a4a <memcmp+0x30>
		if (*s1 != *s2)
  800a36:	0f b6 08             	movzbl (%eax),%ecx
  800a39:	0f b6 1a             	movzbl (%edx),%ebx
  800a3c:	38 d9                	cmp    %bl,%cl
  800a3e:	74 ec                	je     800a2c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a40:	0f b6 c1             	movzbl %cl,%eax
  800a43:	0f b6 db             	movzbl %bl,%ebx
  800a46:	29 d8                	sub    %ebx,%eax
  800a48:	eb 05                	jmp    800a4f <memcmp+0x35>
	}

	return 0;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5c:	89 c2                	mov    %eax,%edx
  800a5e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a61:	eb 03                	jmp    800a66 <memfind+0x13>
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	73 04                	jae    800a6e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6a:	38 08                	cmp    %cl,(%eax)
  800a6c:	75 f5                	jne    800a63 <memfind+0x10>
			break;
	return (void *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 03                	jmp    800a81 <strtol+0x11>
		s++;
  800a7e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 02             	movzbl (%edx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0xe>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	74 2a                	je     800aba <strtol+0x4a>
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	74 2b                	je     800ac4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9f:	75 0f                	jne    800ab0 <strtol+0x40>
  800aa1:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa4:	74 28                	je     800ace <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aad:	0f 44 d8             	cmove  %eax,%ebx
  800ab0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab8:	eb 46                	jmp    800b00 <strtol+0x90>
		s++;
  800aba:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac2:	eb d5                	jmp    800a99 <strtol+0x29>
		s++, neg = 1;
  800ac4:	83 c2 01             	add    $0x1,%edx
  800ac7:	bf 01 00 00 00       	mov    $0x1,%edi
  800acc:	eb cb                	jmp    800a99 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad2:	74 0e                	je     800ae2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ad4:	85 db                	test   %ebx,%ebx
  800ad6:	75 d8                	jne    800ab0 <strtol+0x40>
		s++, base = 8;
  800ad8:	83 c2 01             	add    $0x1,%edx
  800adb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae0:	eb ce                	jmp    800ab0 <strtol+0x40>
		s += 2, base = 16;
  800ae2:	83 c2 02             	add    $0x2,%edx
  800ae5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aea:	eb c4                	jmp    800ab0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aec:	0f be c0             	movsbl %al,%eax
  800aef:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800af5:	7d 3a                	jge    800b31 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800af7:	83 c2 01             	add    $0x1,%edx
  800afa:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800afe:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b00:	0f b6 02             	movzbl (%edx),%eax
  800b03:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 09             	cmp    $0x9,%bl
  800b0b:	76 df                	jbe    800aec <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b0d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 08                	ja     800b1f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b17:	0f be c0             	movsbl %al,%eax
  800b1a:	83 e8 57             	sub    $0x57,%eax
  800b1d:	eb d3                	jmp    800af2 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b22:	89 f3                	mov    %esi,%ebx
  800b24:	80 fb 19             	cmp    $0x19,%bl
  800b27:	77 08                	ja     800b31 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b29:	0f be c0             	movsbl %al,%eax
  800b2c:	83 e8 37             	sub    $0x37,%eax
  800b2f:	eb c1                	jmp    800af2 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b35:	74 05                	je     800b3c <strtol+0xcc>
		*endptr = (char *) s;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b3c:	89 c8                	mov    %ecx,%eax
  800b3e:	f7 d8                	neg    %eax
  800b40:	85 ff                	test   %edi,%edi
  800b42:	0f 45 c8             	cmovne %eax,%ecx
}
  800b45:	89 c8                	mov    %ecx,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7f 08                	jg     800bb3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 03                	push   $0x3
  800bb9:	68 7f 26 80 00       	push   $0x80267f
  800bbe:	6a 2a                	push   $0x2a
  800bc0:	68 9c 26 80 00       	push   $0x80269c
  800bc5:	e8 8d f5 ff ff       	call   800157 <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	be 00 00 00 00       	mov    $0x0,%esi
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	89 f7                	mov    %esi,%edi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 04                	push   $0x4
  800c3a:	68 7f 26 80 00       	push   $0x80267f
  800c3f:	6a 2a                	push   $0x2a
  800c41:	68 9c 26 80 00       	push   $0x80269c
  800c46:	e8 0c f5 ff ff       	call   800157 <_panic>

00800c4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 75 18             	mov    0x18(%ebp),%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 05                	push   $0x5
  800c7c:	68 7f 26 80 00       	push   $0x80267f
  800c81:	6a 2a                	push   $0x2a
  800c83:	68 9c 26 80 00       	push   $0x80269c
  800c88:	e8 ca f4 ff ff       	call   800157 <_panic>

00800c8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 06                	push   $0x6
  800cbe:	68 7f 26 80 00       	push   $0x80267f
  800cc3:	6a 2a                	push   $0x2a
  800cc5:	68 9c 26 80 00       	push   $0x80269c
  800cca:	e8 88 f4 ff ff       	call   800157 <_panic>

00800ccf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 08                	push   $0x8
  800d00:	68 7f 26 80 00       	push   $0x80267f
  800d05:	6a 2a                	push   $0x2a
  800d07:	68 9c 26 80 00       	push   $0x80269c
  800d0c:	e8 46 f4 ff ff       	call   800157 <_panic>

00800d11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 09                	push   $0x9
  800d42:	68 7f 26 80 00       	push   $0x80267f
  800d47:	6a 2a                	push   $0x2a
  800d49:	68 9c 26 80 00       	push   $0x80269c
  800d4e:	e8 04 f4 ff ff       	call   800157 <_panic>

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7f 08                	jg     800d7e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 0a                	push   $0xa
  800d84:	68 7f 26 80 00       	push   $0x80267f
  800d89:	6a 2a                	push   $0x2a
  800d8b:	68 9c 26 80 00       	push   $0x80269c
  800d90:	e8 c2 f3 ff ff       	call   800157 <_panic>

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	be 00 00 00 00       	mov    $0x0,%esi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	89 cb                	mov    %ecx,%ebx
  800dd0:	89 cf                	mov    %ecx,%edi
  800dd2:	89 ce                	mov    %ecx,%esi
  800dd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7f 08                	jg     800de2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 0d                	push   $0xd
  800de8:	68 7f 26 80 00       	push   $0x80267f
  800ded:	6a 2a                	push   $0x2a
  800def:	68 9c 26 80 00       	push   $0x80269c
  800df4:	e8 5e f3 ff ff       	call   800157 <_panic>

00800df9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dff:	ba 00 00 00 00       	mov    $0x0,%edx
  800e04:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e09:	89 d1                	mov    %edx,%ecx
  800e0b:	89 d3                	mov    %edx,%ebx
  800e0d:	89 d7                	mov    %edx,%edi
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2e:	89 df                	mov    %ebx,%edi
  800e30:	89 de                	mov    %ebx,%esi
  800e32:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4f:	89 df                	mov    %ebx,%edi
  800e51:	89 de                	mov    %ebx,%esi
  800e53:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	05 00 00 00 30       	add    $0x30000000,%eax
  800e65:	c1 e8 0c             	shr    $0xc,%eax
}
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e7a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e89:	89 c2                	mov    %eax,%edx
  800e8b:	c1 ea 16             	shr    $0x16,%edx
  800e8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e95:	f6 c2 01             	test   $0x1,%dl
  800e98:	74 29                	je     800ec3 <fd_alloc+0x42>
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	c1 ea 0c             	shr    $0xc,%edx
  800e9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	74 18                	je     800ec3 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800eab:	05 00 10 00 00       	add    $0x1000,%eax
  800eb0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb5:	75 d2                	jne    800e89 <fd_alloc+0x8>
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ebc:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ec1:	eb 05                	jmp    800ec8 <fd_alloc+0x47>
			return 0;
  800ec3:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 02                	mov    %eax,(%edx)
}
  800ecd:	89 c8                	mov    %ecx,%eax
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed7:	83 f8 1f             	cmp    $0x1f,%eax
  800eda:	77 30                	ja     800f0c <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800edc:	c1 e0 0c             	shl    $0xc,%eax
  800edf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ee4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	74 24                	je     800f13 <fd_lookup+0x42>
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 0c             	shr    $0xc,%edx
  800ef4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	74 1a                	je     800f1a <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f03:	89 02                	mov    %eax,(%edx)
	return 0;
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    
		return -E_INVAL;
  800f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f11:	eb f7                	jmp    800f0a <fd_lookup+0x39>
		return -E_INVAL;
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f18:	eb f0                	jmp    800f0a <fd_lookup+0x39>
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1f:	eb e9                	jmp    800f0a <fd_lookup+0x39>

00800f21 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	53                   	push   %ebx
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f30:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f35:	39 13                	cmp    %edx,(%ebx)
  800f37:	74 37                	je     800f70 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f39:	83 c0 01             	add    $0x1,%eax
  800f3c:	8b 1c 85 28 27 80 00 	mov    0x802728(,%eax,4),%ebx
  800f43:	85 db                	test   %ebx,%ebx
  800f45:	75 ee                	jne    800f35 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f47:	a1 00 40 80 00       	mov    0x804000,%eax
  800f4c:	8b 40 58             	mov    0x58(%eax),%eax
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	52                   	push   %edx
  800f53:	50                   	push   %eax
  800f54:	68 ac 26 80 00       	push   $0x8026ac
  800f59:	e8 d4 f2 ff ff       	call   800232 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f69:	89 1a                	mov    %ebx,(%edx)
}
  800f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    
			return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	eb ef                	jmp    800f66 <dev_lookup+0x45>

00800f77 <fd_close>:
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 24             	sub    $0x24,%esp
  800f80:	8b 75 08             	mov    0x8(%ebp),%esi
  800f83:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f89:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f8a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f90:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f93:	50                   	push   %eax
  800f94:	e8 38 ff ff ff       	call   800ed1 <fd_lookup>
  800f99:	89 c3                	mov    %eax,%ebx
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 05                	js     800fa7 <fd_close+0x30>
	    || fd != fd2)
  800fa2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fa5:	74 16                	je     800fbd <fd_close+0x46>
		return (must_exist ? r : 0);
  800fa7:	89 f8                	mov    %edi,%eax
  800fa9:	84 c0                	test   %al,%al
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	0f 44 d8             	cmove  %eax,%ebx
}
  800fb3:	89 d8                	mov    %ebx,%eax
  800fb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 36                	push   (%esi)
  800fc6:	e8 56 ff ff ff       	call   800f21 <dev_lookup>
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 1a                	js     800fee <fd_close+0x77>
		if (dev->dev_close)
  800fd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	74 0b                	je     800fee <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	56                   	push   %esi
  800fe7:	ff d0                	call   *%eax
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	56                   	push   %esi
  800ff2:	6a 00                	push   $0x0
  800ff4:	e8 94 fc ff ff       	call   800c8d <sys_page_unmap>
	return r;
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	eb b5                	jmp    800fb3 <fd_close+0x3c>

00800ffe <close>:

int
close(int fdnum)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801004:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801007:	50                   	push   %eax
  801008:	ff 75 08             	push   0x8(%ebp)
  80100b:	e8 c1 fe ff ff       	call   800ed1 <fd_lookup>
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	79 02                	jns    801019 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801017:	c9                   	leave  
  801018:	c3                   	ret    
		return fd_close(fd, 1);
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	6a 01                	push   $0x1
  80101e:	ff 75 f4             	push   -0xc(%ebp)
  801021:	e8 51 ff ff ff       	call   800f77 <fd_close>
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	eb ec                	jmp    801017 <close+0x19>

0080102b <close_all>:

void
close_all(void)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	53                   	push   %ebx
  80102f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801032:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	53                   	push   %ebx
  80103b:	e8 be ff ff ff       	call   800ffe <close>
	for (i = 0; i < MAXFD; i++)
  801040:	83 c3 01             	add    $0x1,%ebx
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	83 fb 20             	cmp    $0x20,%ebx
  801049:	75 ec                	jne    801037 <close_all+0xc>
}
  80104b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801059:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	ff 75 08             	push   0x8(%ebp)
  801060:	e8 6c fe ff ff       	call   800ed1 <fd_lookup>
  801065:	89 c3                	mov    %eax,%ebx
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 7f                	js     8010ed <dup+0x9d>
		return r;
	close(newfdnum);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	ff 75 0c             	push   0xc(%ebp)
  801074:	e8 85 ff ff ff       	call   800ffe <close>

	newfd = INDEX2FD(newfdnum);
  801079:	8b 75 0c             	mov    0xc(%ebp),%esi
  80107c:	c1 e6 0c             	shl    $0xc,%esi
  80107f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801085:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801088:	89 3c 24             	mov    %edi,(%esp)
  80108b:	e8 da fd ff ff       	call   800e6a <fd2data>
  801090:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801092:	89 34 24             	mov    %esi,(%esp)
  801095:	e8 d0 fd ff ff       	call   800e6a <fd2data>
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a0:	89 d8                	mov    %ebx,%eax
  8010a2:	c1 e8 16             	shr    $0x16,%eax
  8010a5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ac:	a8 01                	test   $0x1,%al
  8010ae:	74 11                	je     8010c1 <dup+0x71>
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	c1 e8 0c             	shr    $0xc,%eax
  8010b5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bc:	f6 c2 01             	test   $0x1,%dl
  8010bf:	75 36                	jne    8010f7 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c1:	89 f8                	mov    %edi,%eax
  8010c3:	c1 e8 0c             	shr    $0xc,%eax
  8010c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d5:	50                   	push   %eax
  8010d6:	56                   	push   %esi
  8010d7:	6a 00                	push   $0x0
  8010d9:	57                   	push   %edi
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 6a fb ff ff       	call   800c4b <sys_page_map>
  8010e1:	89 c3                	mov    %eax,%ebx
  8010e3:	83 c4 20             	add    $0x20,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 33                	js     80111d <dup+0xcd>
		goto err;

	return newfdnum;
  8010ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ed:	89 d8                	mov    %ebx,%eax
  8010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	25 07 0e 00 00       	and    $0xe07,%eax
  801106:	50                   	push   %eax
  801107:	ff 75 d4             	push   -0x2c(%ebp)
  80110a:	6a 00                	push   $0x0
  80110c:	53                   	push   %ebx
  80110d:	6a 00                	push   $0x0
  80110f:	e8 37 fb ff ff       	call   800c4b <sys_page_map>
  801114:	89 c3                	mov    %eax,%ebx
  801116:	83 c4 20             	add    $0x20,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	79 a4                	jns    8010c1 <dup+0x71>
	sys_page_unmap(0, newfd);
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	56                   	push   %esi
  801121:	6a 00                	push   $0x0
  801123:	e8 65 fb ff ff       	call   800c8d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801128:	83 c4 08             	add    $0x8,%esp
  80112b:	ff 75 d4             	push   -0x2c(%ebp)
  80112e:	6a 00                	push   $0x0
  801130:	e8 58 fb ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	eb b3                	jmp    8010ed <dup+0x9d>

0080113a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	56                   	push   %esi
  80113e:	53                   	push   %ebx
  80113f:	83 ec 18             	sub    $0x18,%esp
  801142:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801145:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	56                   	push   %esi
  80114a:	e8 82 fd ff ff       	call   800ed1 <fd_lookup>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 3c                	js     801192 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801156:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	ff 33                	push   (%ebx)
  801162:	e8 ba fd ff ff       	call   800f21 <dev_lookup>
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 24                	js     801192 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80116e:	8b 43 08             	mov    0x8(%ebx),%eax
  801171:	83 e0 03             	and    $0x3,%eax
  801174:	83 f8 01             	cmp    $0x1,%eax
  801177:	74 20                	je     801199 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117c:	8b 40 08             	mov    0x8(%eax),%eax
  80117f:	85 c0                	test   %eax,%eax
  801181:	74 37                	je     8011ba <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	ff 75 10             	push   0x10(%ebp)
  801189:	ff 75 0c             	push   0xc(%ebp)
  80118c:	53                   	push   %ebx
  80118d:	ff d0                	call   *%eax
  80118f:	83 c4 10             	add    $0x10,%esp
}
  801192:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801199:	a1 00 40 80 00       	mov    0x804000,%eax
  80119e:	8b 40 58             	mov    0x58(%eax),%eax
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	56                   	push   %esi
  8011a5:	50                   	push   %eax
  8011a6:	68 ed 26 80 00       	push   $0x8026ed
  8011ab:	e8 82 f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b8:	eb d8                	jmp    801192 <read+0x58>
		return -E_NOT_SUPP;
  8011ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011bf:	eb d1                	jmp    801192 <read+0x58>

008011c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d5:	eb 02                	jmp    8011d9 <readn+0x18>
  8011d7:	01 c3                	add    %eax,%ebx
  8011d9:	39 f3                	cmp    %esi,%ebx
  8011db:	73 21                	jae    8011fe <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011dd:	83 ec 04             	sub    $0x4,%esp
  8011e0:	89 f0                	mov    %esi,%eax
  8011e2:	29 d8                	sub    %ebx,%eax
  8011e4:	50                   	push   %eax
  8011e5:	89 d8                	mov    %ebx,%eax
  8011e7:	03 45 0c             	add    0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	57                   	push   %edi
  8011ec:	e8 49 ff ff ff       	call   80113a <read>
		if (m < 0)
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 04                	js     8011fc <readn+0x3b>
			return m;
		if (m == 0)
  8011f8:	75 dd                	jne    8011d7 <readn+0x16>
  8011fa:	eb 02                	jmp    8011fe <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011fc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011fe:	89 d8                	mov    %ebx,%eax
  801200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 18             	sub    $0x18,%esp
  801210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	53                   	push   %ebx
  801218:	e8 b4 fc ff ff       	call   800ed1 <fd_lookup>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 37                	js     80125b <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	ff 36                	push   (%esi)
  801230:	e8 ec fc ff ff       	call   800f21 <dev_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 1f                	js     80125b <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801240:	74 20                	je     801262 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801245:	8b 40 0c             	mov    0xc(%eax),%eax
  801248:	85 c0                	test   %eax,%eax
  80124a:	74 37                	je     801283 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	ff 75 10             	push   0x10(%ebp)
  801252:	ff 75 0c             	push   0xc(%ebp)
  801255:	56                   	push   %esi
  801256:	ff d0                	call   *%eax
  801258:	83 c4 10             	add    $0x10,%esp
}
  80125b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801262:	a1 00 40 80 00       	mov    0x804000,%eax
  801267:	8b 40 58             	mov    0x58(%eax),%eax
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	53                   	push   %ebx
  80126e:	50                   	push   %eax
  80126f:	68 09 27 80 00       	push   $0x802709
  801274:	e8 b9 ef ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801281:	eb d8                	jmp    80125b <write+0x53>
		return -E_NOT_SUPP;
  801283:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801288:	eb d1                	jmp    80125b <write+0x53>

0080128a <seek>:

int
seek(int fdnum, off_t offset)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	ff 75 08             	push   0x8(%ebp)
  801297:	e8 35 fc ff ff       	call   800ed1 <fd_lookup>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 0e                	js     8012b1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 18             	sub    $0x18,%esp
  8012bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	53                   	push   %ebx
  8012c3:	e8 09 fc ff ff       	call   800ed1 <fd_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 34                	js     801303 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cf:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 36                	push   (%esi)
  8012db:	e8 41 fc ff ff       	call   800f21 <dev_lookup>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 1c                	js     801303 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e7:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012eb:	74 1d                	je     80130a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f0:	8b 40 18             	mov    0x18(%eax),%eax
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	74 34                	je     80132b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	ff 75 0c             	push   0xc(%ebp)
  8012fd:	56                   	push   %esi
  8012fe:	ff d0                	call   *%eax
  801300:	83 c4 10             	add    $0x10,%esp
}
  801303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    
			thisenv->env_id, fdnum);
  80130a:	a1 00 40 80 00       	mov    0x804000,%eax
  80130f:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801312:	83 ec 04             	sub    $0x4,%esp
  801315:	53                   	push   %ebx
  801316:	50                   	push   %eax
  801317:	68 cc 26 80 00       	push   $0x8026cc
  80131c:	e8 11 ef ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801329:	eb d8                	jmp    801303 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80132b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801330:	eb d1                	jmp    801303 <ftruncate+0x50>

00801332 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	56                   	push   %esi
  801336:	53                   	push   %ebx
  801337:	83 ec 18             	sub    $0x18,%esp
  80133a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	push   0x8(%ebp)
  801344:	e8 88 fb ff ff       	call   800ed1 <fd_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 49                	js     801399 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801350:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	ff 36                	push   (%esi)
  80135c:	e8 c0 fb ff ff       	call   800f21 <dev_lookup>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 31                	js     801399 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80136f:	74 2f                	je     8013a0 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801371:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801374:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137b:	00 00 00 
	stat->st_isdir = 0;
  80137e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801385:	00 00 00 
	stat->st_dev = dev;
  801388:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	53                   	push   %ebx
  801392:	56                   	push   %esi
  801393:	ff 50 14             	call   *0x14(%eax)
  801396:	83 c4 10             	add    $0x10,%esp
}
  801399:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    
		return -E_NOT_SUPP;
  8013a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a5:	eb f2                	jmp    801399 <fstat+0x67>

008013a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	6a 00                	push   $0x0
  8013b1:	ff 75 08             	push   0x8(%ebp)
  8013b4:	e8 e4 01 00 00       	call   80159d <open>
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 1b                	js     8013dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	ff 75 0c             	push   0xc(%ebp)
  8013c8:	50                   	push   %eax
  8013c9:	e8 64 ff ff ff       	call   801332 <fstat>
  8013ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d0:	89 1c 24             	mov    %ebx,(%esp)
  8013d3:	e8 26 fc ff ff       	call   800ffe <close>
	return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 f3                	mov    %esi,%ebx
}
  8013dd:	89 d8                	mov    %ebx,%eax
  8013df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e2:	5b                   	pop    %ebx
  8013e3:	5e                   	pop    %esi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	89 c6                	mov    %eax,%esi
  8013ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ef:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013f6:	74 27                	je     80141f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f8:	6a 07                	push   $0x7
  8013fa:	68 00 50 80 00       	push   $0x805000
  8013ff:	56                   	push   %esi
  801400:	ff 35 00 60 80 00    	push   0x806000
  801406:	e8 cd 0b 00 00       	call   801fd8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140b:	83 c4 0c             	add    $0xc,%esp
  80140e:	6a 00                	push   $0x0
  801410:	53                   	push   %ebx
  801411:	6a 00                	push   $0x0
  801413:	e8 50 0b 00 00       	call   801f68 <ipc_recv>
}
  801418:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	6a 01                	push   $0x1
  801424:	e8 03 0c 00 00       	call   80202c <ipc_find_env>
  801429:	a3 00 60 80 00       	mov    %eax,0x806000
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	eb c5                	jmp    8013f8 <fsipc+0x12>

00801433 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	8b 40 0c             	mov    0xc(%eax),%eax
  80143f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801444:	8b 45 0c             	mov    0xc(%ebp),%eax
  801447:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80144c:	ba 00 00 00 00       	mov    $0x0,%edx
  801451:	b8 02 00 00 00       	mov    $0x2,%eax
  801456:	e8 8b ff ff ff       	call   8013e6 <fsipc>
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <devfile_flush>:
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	8b 40 0c             	mov    0xc(%eax),%eax
  801469:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80146e:	ba 00 00 00 00       	mov    $0x0,%edx
  801473:	b8 06 00 00 00       	mov    $0x6,%eax
  801478:	e8 69 ff ff ff       	call   8013e6 <fsipc>
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <devfile_stat>:
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 40 0c             	mov    0xc(%eax),%eax
  80148f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 05 00 00 00       	mov    $0x5,%eax
  80149e:	e8 43 ff ff ff       	call   8013e6 <fsipc>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 2c                	js     8014d3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	53                   	push   %ebx
  8014b0:	e8 57 f3 ff ff       	call   80080c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <devfile_write>:
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	8b 45 10             	mov    0x10(%ebp),%eax
  8014e1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014e6:	39 d0                	cmp    %edx,%eax
  8014e8:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ee:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014f7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014fc:	50                   	push   %eax
  8014fd:	ff 75 0c             	push   0xc(%ebp)
  801500:	68 08 50 80 00       	push   $0x805008
  801505:	e8 98 f4 ff ff       	call   8009a2 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
  80150f:	b8 04 00 00 00       	mov    $0x4,%eax
  801514:	e8 cd fe ff ff       	call   8013e6 <fsipc>
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <devfile_read>:
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	56                   	push   %esi
  80151f:	53                   	push   %ebx
  801520:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	8b 40 0c             	mov    0xc(%eax),%eax
  801529:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80152e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
  801539:	b8 03 00 00 00       	mov    $0x3,%eax
  80153e:	e8 a3 fe ff ff       	call   8013e6 <fsipc>
  801543:	89 c3                	mov    %eax,%ebx
  801545:	85 c0                	test   %eax,%eax
  801547:	78 1f                	js     801568 <devfile_read+0x4d>
	assert(r <= n);
  801549:	39 f0                	cmp    %esi,%eax
  80154b:	77 24                	ja     801571 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80154d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801552:	7f 33                	jg     801587 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	50                   	push   %eax
  801558:	68 00 50 80 00       	push   $0x805000
  80155d:	ff 75 0c             	push   0xc(%ebp)
  801560:	e8 3d f4 ff ff       	call   8009a2 <memmove>
	return r;
  801565:	83 c4 10             	add    $0x10,%esp
}
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156d:	5b                   	pop    %ebx
  80156e:	5e                   	pop    %esi
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    
	assert(r <= n);
  801571:	68 3c 27 80 00       	push   $0x80273c
  801576:	68 43 27 80 00       	push   $0x802743
  80157b:	6a 7c                	push   $0x7c
  80157d:	68 58 27 80 00       	push   $0x802758
  801582:	e8 d0 eb ff ff       	call   800157 <_panic>
	assert(r <= PGSIZE);
  801587:	68 63 27 80 00       	push   $0x802763
  80158c:	68 43 27 80 00       	push   $0x802743
  801591:	6a 7d                	push   $0x7d
  801593:	68 58 27 80 00       	push   $0x802758
  801598:	e8 ba eb ff ff       	call   800157 <_panic>

0080159d <open>:
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	56                   	push   %esi
  8015a1:	53                   	push   %ebx
  8015a2:	83 ec 1c             	sub    $0x1c,%esp
  8015a5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015a8:	56                   	push   %esi
  8015a9:	e8 23 f2 ff ff       	call   8007d1 <strlen>
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b6:	7f 6c                	jg     801624 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	e8 bd f8 ff ff       	call   800e81 <fd_alloc>
  8015c4:	89 c3                	mov    %eax,%ebx
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 3c                	js     801609 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	56                   	push   %esi
  8015d1:	68 00 50 80 00       	push   $0x805000
  8015d6:	e8 31 f2 ff ff       	call   80080c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015eb:	e8 f6 fd ff ff       	call   8013e6 <fsipc>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 19                	js     801612 <open+0x75>
	return fd2num(fd);
  8015f9:	83 ec 0c             	sub    $0xc,%esp
  8015fc:	ff 75 f4             	push   -0xc(%ebp)
  8015ff:	e8 56 f8 ff ff       	call   800e5a <fd2num>
  801604:	89 c3                	mov    %eax,%ebx
  801606:	83 c4 10             	add    $0x10,%esp
}
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    
		fd_close(fd, 0);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	6a 00                	push   $0x0
  801617:	ff 75 f4             	push   -0xc(%ebp)
  80161a:	e8 58 f9 ff ff       	call   800f77 <fd_close>
		return r;
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	eb e5                	jmp    801609 <open+0x6c>
		return -E_BAD_PATH;
  801624:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801629:	eb de                	jmp    801609 <open+0x6c>

0080162b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801631:	ba 00 00 00 00       	mov    $0x0,%edx
  801636:	b8 08 00 00 00       	mov    $0x8,%eax
  80163b:	e8 a6 fd ff ff       	call   8013e6 <fsipc>
}
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801648:	68 6f 27 80 00       	push   $0x80276f
  80164d:	ff 75 0c             	push   0xc(%ebp)
  801650:	e8 b7 f1 ff ff       	call   80080c <strcpy>
	return 0;
}
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <devsock_close>:
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 10             	sub    $0x10,%esp
  801663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801666:	53                   	push   %ebx
  801667:	e8 ff 09 00 00       	call   80206b <pageref>
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
		return 0;
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801676:	83 fa 01             	cmp    $0x1,%edx
  801679:	74 05                	je     801680 <devsock_close+0x24>
}
  80167b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	ff 73 0c             	push   0xc(%ebx)
  801686:	e8 b7 02 00 00       	call   801942 <nsipc_close>
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb eb                	jmp    80167b <devsock_close+0x1f>

00801690 <devsock_write>:
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801696:	6a 00                	push   $0x0
  801698:	ff 75 10             	push   0x10(%ebp)
  80169b:	ff 75 0c             	push   0xc(%ebp)
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	ff 70 0c             	push   0xc(%eax)
  8016a4:	e8 79 03 00 00       	call   801a22 <nsipc_send>
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <devsock_read>:
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016b1:	6a 00                	push   $0x0
  8016b3:	ff 75 10             	push   0x10(%ebp)
  8016b6:	ff 75 0c             	push   0xc(%ebp)
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	ff 70 0c             	push   0xc(%eax)
  8016bf:	e8 ef 02 00 00       	call   8019b3 <nsipc_recv>
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <fd2sockid>:
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016cc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016cf:	52                   	push   %edx
  8016d0:	50                   	push   %eax
  8016d1:	e8 fb f7 ff ff       	call   800ed1 <fd_lookup>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 10                	js     8016ed <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016e6:	39 08                	cmp    %ecx,(%eax)
  8016e8:	75 05                	jne    8016ef <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016ea:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f4:	eb f7                	jmp    8016ed <fd2sockid+0x27>

008016f6 <alloc_sockfd>:
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 1c             	sub    $0x1c,%esp
  8016fe:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	e8 78 f7 ff ff       	call   800e81 <fd_alloc>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 43                	js     801755 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	68 07 04 00 00       	push   $0x407
  80171a:	ff 75 f4             	push   -0xc(%ebp)
  80171d:	6a 00                	push   $0x0
  80171f:	e8 e4 f4 ff ff       	call   800c08 <sys_page_alloc>
  801724:	89 c3                	mov    %eax,%ebx
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	85 c0                	test   %eax,%eax
  80172b:	78 28                	js     801755 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80172d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801730:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801736:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801742:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801745:	83 ec 0c             	sub    $0xc,%esp
  801748:	50                   	push   %eax
  801749:	e8 0c f7 ff ff       	call   800e5a <fd2num>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	eb 0c                	jmp    801761 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801755:	83 ec 0c             	sub    $0xc,%esp
  801758:	56                   	push   %esi
  801759:	e8 e4 01 00 00       	call   801942 <nsipc_close>
		return r;
  80175e:	83 c4 10             	add    $0x10,%esp
}
  801761:	89 d8                	mov    %ebx,%eax
  801763:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <accept>:
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	e8 4e ff ff ff       	call   8016c6 <fd2sockid>
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 1b                	js     801797 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80177c:	83 ec 04             	sub    $0x4,%esp
  80177f:	ff 75 10             	push   0x10(%ebp)
  801782:	ff 75 0c             	push   0xc(%ebp)
  801785:	50                   	push   %eax
  801786:	e8 0e 01 00 00       	call   801899 <nsipc_accept>
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 05                	js     801797 <accept+0x2d>
	return alloc_sockfd(r);
  801792:	e8 5f ff ff ff       	call   8016f6 <alloc_sockfd>
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <bind>:
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	e8 1f ff ff ff       	call   8016c6 <fd2sockid>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 12                	js     8017bd <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	ff 75 10             	push   0x10(%ebp)
  8017b1:	ff 75 0c             	push   0xc(%ebp)
  8017b4:	50                   	push   %eax
  8017b5:	e8 31 01 00 00       	call   8018eb <nsipc_bind>
  8017ba:	83 c4 10             	add    $0x10,%esp
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <shutdown>:
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	e8 f9 fe ff ff       	call   8016c6 <fd2sockid>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 0f                	js     8017e0 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	ff 75 0c             	push   0xc(%ebp)
  8017d7:	50                   	push   %eax
  8017d8:	e8 43 01 00 00       	call   801920 <nsipc_shutdown>
  8017dd:	83 c4 10             	add    $0x10,%esp
}
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <connect>:
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	e8 d6 fe ff ff       	call   8016c6 <fd2sockid>
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 12                	js     801806 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	ff 75 10             	push   0x10(%ebp)
  8017fa:	ff 75 0c             	push   0xc(%ebp)
  8017fd:	50                   	push   %eax
  8017fe:	e8 59 01 00 00       	call   80195c <nsipc_connect>
  801803:	83 c4 10             	add    $0x10,%esp
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <listen>:
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	e8 b0 fe ff ff       	call   8016c6 <fd2sockid>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 0f                	js     801829 <listen+0x21>
	return nsipc_listen(r, backlog);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	ff 75 0c             	push   0xc(%ebp)
  801820:	50                   	push   %eax
  801821:	e8 6b 01 00 00       	call   801991 <nsipc_listen>
  801826:	83 c4 10             	add    $0x10,%esp
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <socket>:

int
socket(int domain, int type, int protocol)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801831:	ff 75 10             	push   0x10(%ebp)
  801834:	ff 75 0c             	push   0xc(%ebp)
  801837:	ff 75 08             	push   0x8(%ebp)
  80183a:	e8 41 02 00 00       	call   801a80 <nsipc_socket>
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 05                	js     80184b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801846:	e8 ab fe ff ff       	call   8016f6 <alloc_sockfd>
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801856:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80185d:	74 26                	je     801885 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80185f:	6a 07                	push   $0x7
  801861:	68 00 70 80 00       	push   $0x807000
  801866:	53                   	push   %ebx
  801867:	ff 35 00 80 80 00    	push   0x808000
  80186d:	e8 66 07 00 00       	call   801fd8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801872:	83 c4 0c             	add    $0xc,%esp
  801875:	6a 00                	push   $0x0
  801877:	6a 00                	push   $0x0
  801879:	6a 00                	push   $0x0
  80187b:	e8 e8 06 00 00       	call   801f68 <ipc_recv>
}
  801880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801883:	c9                   	leave  
  801884:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801885:	83 ec 0c             	sub    $0xc,%esp
  801888:	6a 02                	push   $0x2
  80188a:	e8 9d 07 00 00       	call   80202c <ipc_find_env>
  80188f:	a3 00 80 80 00       	mov    %eax,0x808000
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	eb c6                	jmp    80185f <nsipc+0x12>

00801899 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018a9:	8b 06                	mov    (%esi),%eax
  8018ab:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b5:	e8 93 ff ff ff       	call   80184d <nsipc>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	79 09                	jns    8018c9 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	ff 35 10 70 80 00    	push   0x807010
  8018d2:	68 00 70 80 00       	push   $0x807000
  8018d7:	ff 75 0c             	push   0xc(%ebp)
  8018da:	e8 c3 f0 ff ff       	call   8009a2 <memmove>
		*addrlen = ret->ret_addrlen;
  8018df:	a1 10 70 80 00       	mov    0x807010,%eax
  8018e4:	89 06                	mov    %eax,(%esi)
  8018e6:	83 c4 10             	add    $0x10,%esp
	return r;
  8018e9:	eb d5                	jmp    8018c0 <nsipc_accept+0x27>

008018eb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018fd:	53                   	push   %ebx
  8018fe:	ff 75 0c             	push   0xc(%ebp)
  801901:	68 04 70 80 00       	push   $0x807004
  801906:	e8 97 f0 ff ff       	call   8009a2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80190b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801911:	b8 02 00 00 00       	mov    $0x2,%eax
  801916:	e8 32 ff ff ff       	call   80184d <nsipc>
}
  80191b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80192e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801931:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801936:	b8 03 00 00 00       	mov    $0x3,%eax
  80193b:	e8 0d ff ff ff       	call   80184d <nsipc>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <nsipc_close>:

int
nsipc_close(int s)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801950:	b8 04 00 00 00       	mov    $0x4,%eax
  801955:	e8 f3 fe ff ff       	call   80184d <nsipc>
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80196e:	53                   	push   %ebx
  80196f:	ff 75 0c             	push   0xc(%ebp)
  801972:	68 04 70 80 00       	push   $0x807004
  801977:	e8 26 f0 ff ff       	call   8009a2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80197c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801982:	b8 05 00 00 00       	mov    $0x5,%eax
  801987:	e8 c1 fe ff ff       	call   80184d <nsipc>
}
  80198c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80199f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a2:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8019a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ac:	e8 9c fe ff ff       	call   80184d <nsipc>
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8019c3:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8019c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cc:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019d1:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d6:	e8 72 fe ff ff       	call   80184d <nsipc>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 22                	js     801a03 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8019e1:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019e6:	39 c6                	cmp    %eax,%esi
  8019e8:	0f 4e c6             	cmovle %esi,%eax
  8019eb:	39 c3                	cmp    %eax,%ebx
  8019ed:	7f 1d                	jg     801a0c <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	53                   	push   %ebx
  8019f3:	68 00 70 80 00       	push   $0x807000
  8019f8:	ff 75 0c             	push   0xc(%ebp)
  8019fb:	e8 a2 ef ff ff       	call   8009a2 <memmove>
  801a00:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a03:	89 d8                	mov    %ebx,%eax
  801a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a0c:	68 7b 27 80 00       	push   $0x80277b
  801a11:	68 43 27 80 00       	push   $0x802743
  801a16:	6a 62                	push   $0x62
  801a18:	68 90 27 80 00       	push   $0x802790
  801a1d:	e8 35 e7 ff ff       	call   800157 <_panic>

00801a22 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	53                   	push   %ebx
  801a26:	83 ec 04             	sub    $0x4,%esp
  801a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a34:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a3a:	7f 2e                	jg     801a6a <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a3c:	83 ec 04             	sub    $0x4,%esp
  801a3f:	53                   	push   %ebx
  801a40:	ff 75 0c             	push   0xc(%ebp)
  801a43:	68 0c 70 80 00       	push   $0x80700c
  801a48:	e8 55 ef ff ff       	call   8009a2 <memmove>
	nsipcbuf.send.req_size = size;
  801a4d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801a53:	8b 45 14             	mov    0x14(%ebp),%eax
  801a56:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801a5b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a60:	e8 e8 fd ff ff       	call   80184d <nsipc>
}
  801a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    
	assert(size < 1600);
  801a6a:	68 9c 27 80 00       	push   $0x80279c
  801a6f:	68 43 27 80 00       	push   $0x802743
  801a74:	6a 6d                	push   $0x6d
  801a76:	68 90 27 80 00       	push   $0x802790
  801a7b:	e8 d7 e6 ff ff       	call   800157 <_panic>

00801a80 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a91:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801a96:	8b 45 10             	mov    0x10(%ebp),%eax
  801a99:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801a9e:	b8 09 00 00 00       	mov    $0x9,%eax
  801aa3:	e8 a5 fd ff ff       	call   80184d <nsipc>
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 75 08             	push   0x8(%ebp)
  801ab8:	e8 ad f3 ff ff       	call   800e6a <fd2data>
  801abd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801abf:	83 c4 08             	add    $0x8,%esp
  801ac2:	68 a8 27 80 00       	push   $0x8027a8
  801ac7:	53                   	push   %ebx
  801ac8:	e8 3f ed ff ff       	call   80080c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acd:	8b 46 04             	mov    0x4(%esi),%eax
  801ad0:	2b 06                	sub    (%esi),%eax
  801ad2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801adf:	00 00 00 
	stat->st_dev = &devpipe;
  801ae2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ae9:	30 80 00 
	return 0;
}
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
  801af1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	53                   	push   %ebx
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b02:	53                   	push   %ebx
  801b03:	6a 00                	push   $0x0
  801b05:	e8 83 f1 ff ff       	call   800c8d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 58 f3 ff ff       	call   800e6a <fd2data>
  801b12:	83 c4 08             	add    $0x8,%esp
  801b15:	50                   	push   %eax
  801b16:	6a 00                	push   $0x0
  801b18:	e8 70 f1 ff ff       	call   800c8d <sys_page_unmap>
}
  801b1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <_pipeisclosed>:
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 1c             	sub    $0x1c,%esp
  801b2b:	89 c7                	mov    %eax,%edi
  801b2d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b2f:	a1 00 40 80 00       	mov    0x804000,%eax
  801b34:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	57                   	push   %edi
  801b3b:	e8 2b 05 00 00       	call   80206b <pageref>
  801b40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b43:	89 34 24             	mov    %esi,(%esp)
  801b46:	e8 20 05 00 00       	call   80206b <pageref>
		nn = thisenv->env_runs;
  801b4b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b51:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	39 cb                	cmp    %ecx,%ebx
  801b59:	74 1b                	je     801b76 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b5b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b5e:	75 cf                	jne    801b2f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b60:	8b 42 68             	mov    0x68(%edx),%eax
  801b63:	6a 01                	push   $0x1
  801b65:	50                   	push   %eax
  801b66:	53                   	push   %ebx
  801b67:	68 af 27 80 00       	push   $0x8027af
  801b6c:	e8 c1 e6 ff ff       	call   800232 <cprintf>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	eb b9                	jmp    801b2f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b76:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b79:	0f 94 c0             	sete   %al
  801b7c:	0f b6 c0             	movzbl %al,%eax
}
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_write>:
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 28             	sub    $0x28,%esp
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b93:	56                   	push   %esi
  801b94:	e8 d1 f2 ff ff       	call   800e6a <fd2data>
  801b99:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba6:	75 09                	jne    801bb1 <devpipe_write+0x2a>
	return i;
  801ba8:	89 f8                	mov    %edi,%eax
  801baa:	eb 23                	jmp    801bcf <devpipe_write+0x48>
			sys_yield();
  801bac:	e8 38 f0 ff ff       	call   800be9 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb1:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb4:	8b 0b                	mov    (%ebx),%ecx
  801bb6:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb9:	39 d0                	cmp    %edx,%eax
  801bbb:	72 1a                	jb     801bd7 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801bbd:	89 da                	mov    %ebx,%edx
  801bbf:	89 f0                	mov    %esi,%eax
  801bc1:	e8 5c ff ff ff       	call   801b22 <_pipeisclosed>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	74 e2                	je     801bac <devpipe_write+0x25>
				return 0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bda:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bde:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801be1:	89 c2                	mov    %eax,%edx
  801be3:	c1 fa 1f             	sar    $0x1f,%edx
  801be6:	89 d1                	mov    %edx,%ecx
  801be8:	c1 e9 1b             	shr    $0x1b,%ecx
  801beb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bee:	83 e2 1f             	and    $0x1f,%edx
  801bf1:	29 ca                	sub    %ecx,%edx
  801bf3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bf7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bfb:	83 c0 01             	add    $0x1,%eax
  801bfe:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c01:	83 c7 01             	add    $0x1,%edi
  801c04:	eb 9d                	jmp    801ba3 <devpipe_write+0x1c>

00801c06 <devpipe_read>:
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	57                   	push   %edi
  801c0a:	56                   	push   %esi
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 18             	sub    $0x18,%esp
  801c0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c12:	57                   	push   %edi
  801c13:	e8 52 f2 ff ff       	call   800e6a <fd2data>
  801c18:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	be 00 00 00 00       	mov    $0x0,%esi
  801c22:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c25:	75 13                	jne    801c3a <devpipe_read+0x34>
	return i;
  801c27:	89 f0                	mov    %esi,%eax
  801c29:	eb 02                	jmp    801c2d <devpipe_read+0x27>
				return i;
  801c2b:	89 f0                	mov    %esi,%eax
}
  801c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
			sys_yield();
  801c35:	e8 af ef ff ff       	call   800be9 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c3a:	8b 03                	mov    (%ebx),%eax
  801c3c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c3f:	75 18                	jne    801c59 <devpipe_read+0x53>
			if (i > 0)
  801c41:	85 f6                	test   %esi,%esi
  801c43:	75 e6                	jne    801c2b <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c45:	89 da                	mov    %ebx,%edx
  801c47:	89 f8                	mov    %edi,%eax
  801c49:	e8 d4 fe ff ff       	call   801b22 <_pipeisclosed>
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	74 e3                	je     801c35 <devpipe_read+0x2f>
				return 0;
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
  801c57:	eb d4                	jmp    801c2d <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c59:	99                   	cltd   
  801c5a:	c1 ea 1b             	shr    $0x1b,%edx
  801c5d:	01 d0                	add    %edx,%eax
  801c5f:	83 e0 1f             	and    $0x1f,%eax
  801c62:	29 d0                	sub    %edx,%eax
  801c64:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c6f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c72:	83 c6 01             	add    $0x1,%esi
  801c75:	eb ab                	jmp    801c22 <devpipe_read+0x1c>

00801c77 <pipe>:
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c82:	50                   	push   %eax
  801c83:	e8 f9 f1 ff ff       	call   800e81 <fd_alloc>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	0f 88 23 01 00 00    	js     801db8 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c95:	83 ec 04             	sub    $0x4,%esp
  801c98:	68 07 04 00 00       	push   $0x407
  801c9d:	ff 75 f4             	push   -0xc(%ebp)
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 61 ef ff ff       	call   800c08 <sys_page_alloc>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	0f 88 04 01 00 00    	js     801db8 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cba:	50                   	push   %eax
  801cbb:	e8 c1 f1 ff ff       	call   800e81 <fd_alloc>
  801cc0:	89 c3                	mov    %eax,%ebx
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	0f 88 db 00 00 00    	js     801da8 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f0             	push   -0x10(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 29 ef ff ff       	call   800c08 <sys_page_alloc>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 bc 00 00 00    	js     801da8 <pipe+0x131>
	va = fd2data(fd0);
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	ff 75 f4             	push   -0xc(%ebp)
  801cf2:	e8 73 f1 ff ff       	call   800e6a <fd2data>
  801cf7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf9:	83 c4 0c             	add    $0xc,%esp
  801cfc:	68 07 04 00 00       	push   $0x407
  801d01:	50                   	push   %eax
  801d02:	6a 00                	push   $0x0
  801d04:	e8 ff ee ff ff       	call   800c08 <sys_page_alloc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	0f 88 82 00 00 00    	js     801d98 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	ff 75 f0             	push   -0x10(%ebp)
  801d1c:	e8 49 f1 ff ff       	call   800e6a <fd2data>
  801d21:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d28:	50                   	push   %eax
  801d29:	6a 00                	push   $0x0
  801d2b:	56                   	push   %esi
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 18 ef ff ff       	call   800c4b <sys_page_map>
  801d33:	89 c3                	mov    %eax,%ebx
  801d35:	83 c4 20             	add    $0x20,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 4e                	js     801d8a <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d3c:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d44:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d49:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d53:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 f4             	push   -0xc(%ebp)
  801d65:	e8 f0 f0 ff ff       	call   800e5a <fd2num>
  801d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6f:	83 c4 04             	add    $0x4,%esp
  801d72:	ff 75 f0             	push   -0x10(%ebp)
  801d75:	e8 e0 f0 ff ff       	call   800e5a <fd2num>
  801d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d88:	eb 2e                	jmp    801db8 <pipe+0x141>
	sys_page_unmap(0, va);
  801d8a:	83 ec 08             	sub    $0x8,%esp
  801d8d:	56                   	push   %esi
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 f8 ee ff ff       	call   800c8d <sys_page_unmap>
  801d95:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	ff 75 f0             	push   -0x10(%ebp)
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 e8 ee ff ff       	call   800c8d <sys_page_unmap>
  801da5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801da8:	83 ec 08             	sub    $0x8,%esp
  801dab:	ff 75 f4             	push   -0xc(%ebp)
  801dae:	6a 00                	push   $0x0
  801db0:	e8 d8 ee ff ff       	call   800c8d <sys_page_unmap>
  801db5:	83 c4 10             	add    $0x10,%esp
}
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <pipeisclosed>:
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	ff 75 08             	push   0x8(%ebp)
  801dce:	e8 fe f0 ff ff       	call   800ed1 <fd_lookup>
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 18                	js     801df2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	ff 75 f4             	push   -0xc(%ebp)
  801de0:	e8 85 f0 ff ff       	call   800e6a <fd2data>
  801de5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dea:	e8 33 fd ff ff       	call   801b22 <_pipeisclosed>
  801def:	83 c4 10             	add    $0x10,%esp
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
  801df9:	c3                   	ret    

00801dfa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e00:	68 c7 27 80 00       	push   $0x8027c7
  801e05:	ff 75 0c             	push   0xc(%ebp)
  801e08:	e8 ff e9 ff ff       	call   80080c <strcpy>
	return 0;
}
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <devcons_write>:
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e20:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e25:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e2b:	eb 2e                	jmp    801e5b <devcons_write+0x47>
		m = n - tot;
  801e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e30:	29 f3                	sub    %esi,%ebx
  801e32:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e37:	39 c3                	cmp    %eax,%ebx
  801e39:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	53                   	push   %ebx
  801e40:	89 f0                	mov    %esi,%eax
  801e42:	03 45 0c             	add    0xc(%ebp),%eax
  801e45:	50                   	push   %eax
  801e46:	57                   	push   %edi
  801e47:	e8 56 eb ff ff       	call   8009a2 <memmove>
		sys_cputs(buf, m);
  801e4c:	83 c4 08             	add    $0x8,%esp
  801e4f:	53                   	push   %ebx
  801e50:	57                   	push   %edi
  801e51:	e8 f6 ec ff ff       	call   800b4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e56:	01 de                	add    %ebx,%esi
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5e:	72 cd                	jb     801e2d <devcons_write+0x19>
}
  801e60:	89 f0                	mov    %esi,%eax
  801e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5f                   	pop    %edi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <devcons_read>:
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e79:	75 07                	jne    801e82 <devcons_read+0x18>
  801e7b:	eb 1f                	jmp    801e9c <devcons_read+0x32>
		sys_yield();
  801e7d:	e8 67 ed ff ff       	call   800be9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e82:	e8 e3 ec ff ff       	call   800b6a <sys_cgetc>
  801e87:	85 c0                	test   %eax,%eax
  801e89:	74 f2                	je     801e7d <devcons_read+0x13>
	if (c < 0)
  801e8b:	78 0f                	js     801e9c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e8d:	83 f8 04             	cmp    $0x4,%eax
  801e90:	74 0c                	je     801e9e <devcons_read+0x34>
	*(char*)vbuf = c;
  801e92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e95:	88 02                	mov    %al,(%edx)
	return 1;
  801e97:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    
		return 0;
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea3:	eb f7                	jmp    801e9c <devcons_read+0x32>

00801ea5 <cputchar>:
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801eb1:	6a 01                	push   $0x1
  801eb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	e8 90 ec ff ff       	call   800b4c <sys_cputs>
}
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <getchar>:
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ec7:	6a 01                	push   $0x1
  801ec9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 66 f2 ff ff       	call   80113a <read>
	if (r < 0)
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 06                	js     801ee1 <getchar+0x20>
	if (r < 1)
  801edb:	74 06                	je     801ee3 <getchar+0x22>
	return c;
  801edd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    
		return -E_EOF;
  801ee3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ee8:	eb f7                	jmp    801ee1 <getchar+0x20>

00801eea <iscons>:
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	ff 75 08             	push   0x8(%ebp)
  801ef7:	e8 d5 ef ff ff       	call   800ed1 <fd_lookup>
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 11                	js     801f14 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f06:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f0c:	39 10                	cmp    %edx,(%eax)
  801f0e:	0f 94 c0             	sete   %al
  801f11:	0f b6 c0             	movzbl %al,%eax
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <opencons>:
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1f:	50                   	push   %eax
  801f20:	e8 5c ef ff ff       	call   800e81 <fd_alloc>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 3a                	js     801f66 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f2c:	83 ec 04             	sub    $0x4,%esp
  801f2f:	68 07 04 00 00       	push   $0x407
  801f34:	ff 75 f4             	push   -0xc(%ebp)
  801f37:	6a 00                	push   $0x0
  801f39:	e8 ca ec ff ff       	call   800c08 <sys_page_alloc>
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	85 c0                	test   %eax,%eax
  801f43:	78 21                	js     801f66 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f4e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f53:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	50                   	push   %eax
  801f5e:	e8 f7 ee ff ff       	call   800e5a <fd2num>
  801f63:	83 c4 10             	add    $0x10,%esp
}
  801f66:	c9                   	leave  
  801f67:	c3                   	ret    

00801f68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	56                   	push   %esi
  801f6c:	53                   	push   %ebx
  801f6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f76:	85 c0                	test   %eax,%eax
  801f78:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f7d:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	50                   	push   %eax
  801f84:	e8 2f ee ff ff       	call   800db8 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 f6                	test   %esi,%esi
  801f8e:	74 17                	je     801fa7 <ipc_recv+0x3f>
  801f90:	ba 00 00 00 00       	mov    $0x0,%edx
  801f95:	85 c0                	test   %eax,%eax
  801f97:	78 0c                	js     801fa5 <ipc_recv+0x3d>
  801f99:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f9f:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801fa5:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801fa7:	85 db                	test   %ebx,%ebx
  801fa9:	74 17                	je     801fc2 <ipc_recv+0x5a>
  801fab:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 0c                	js     801fc0 <ipc_recv+0x58>
  801fb4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fba:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801fc0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 0b                	js     801fd1 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801fc6:	a1 00 40 80 00       	mov    0x804000,%eax
  801fcb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801fd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	57                   	push   %edi
  801fdc:	56                   	push   %esi
  801fdd:	53                   	push   %ebx
  801fde:	83 ec 0c             	sub    $0xc,%esp
  801fe1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fea:	85 db                	test   %ebx,%ebx
  801fec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff1:	0f 44 d8             	cmove  %eax,%ebx
  801ff4:	eb 05                	jmp    801ffb <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ff6:	e8 ee eb ff ff       	call   800be9 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801ffb:	ff 75 14             	push   0x14(%ebp)
  801ffe:	53                   	push   %ebx
  801fff:	56                   	push   %esi
  802000:	57                   	push   %edi
  802001:	e8 8f ed ff ff       	call   800d95 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200c:	74 e8                	je     801ff6 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 08                	js     80201a <ipc_send+0x42>
	}while (r<0);

}
  802012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5f                   	pop    %edi
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80201a:	50                   	push   %eax
  80201b:	68 d3 27 80 00       	push   $0x8027d3
  802020:	6a 3d                	push   $0x3d
  802022:	68 e7 27 80 00       	push   $0x8027e7
  802027:	e8 2b e1 ff ff       	call   800157 <_panic>

0080202c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802032:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802037:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80203d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802043:	8b 52 60             	mov    0x60(%edx),%edx
  802046:	39 ca                	cmp    %ecx,%edx
  802048:	74 11                	je     80205b <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80204a:	83 c0 01             	add    $0x1,%eax
  80204d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802052:	75 e3                	jne    802037 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
  802059:	eb 0e                	jmp    802069 <ipc_find_env+0x3d>
			return envs[i].env_id;
  80205b:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802066:	8b 40 58             	mov    0x58(%eax),%eax
}
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802071:	89 c2                	mov    %eax,%edx
  802073:	c1 ea 16             	shr    $0x16,%edx
  802076:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80207d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802082:	f6 c1 01             	test   $0x1,%cl
  802085:	74 1c                	je     8020a3 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802087:	c1 e8 0c             	shr    $0xc,%eax
  80208a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802091:	a8 01                	test   $0x1,%al
  802093:	74 0e                	je     8020a3 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802095:	c1 e8 0c             	shr    $0xc,%eax
  802098:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80209f:	ef 
  8020a0:	0f b7 d2             	movzwl %dx,%edx
}
  8020a3:	89 d0                	mov    %edx,%eax
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    
  8020a7:	66 90                	xchg   %ax,%ax
  8020a9:	66 90                	xchg   %ax,%ax
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	f3 0f 1e fb          	endbr32 
  8020b4:	55                   	push   %ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	83 ec 1c             	sub    $0x1c,%esp
  8020bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	75 19                	jne    8020e8 <__udivdi3+0x38>
  8020cf:	39 f3                	cmp    %esi,%ebx
  8020d1:	76 4d                	jbe    802120 <__udivdi3+0x70>
  8020d3:	31 ff                	xor    %edi,%edi
  8020d5:	89 e8                	mov    %ebp,%eax
  8020d7:	89 f2                	mov    %esi,%edx
  8020d9:	f7 f3                	div    %ebx
  8020db:	89 fa                	mov    %edi,%edx
  8020dd:	83 c4 1c             	add    $0x1c,%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5f                   	pop    %edi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    
  8020e5:	8d 76 00             	lea    0x0(%esi),%esi
  8020e8:	39 f0                	cmp    %esi,%eax
  8020ea:	76 14                	jbe    802100 <__udivdi3+0x50>
  8020ec:	31 ff                	xor    %edi,%edi
  8020ee:	31 c0                	xor    %eax,%eax
  8020f0:	89 fa                	mov    %edi,%edx
  8020f2:	83 c4 1c             	add    $0x1c,%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5f                   	pop    %edi
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    
  8020fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802100:	0f bd f8             	bsr    %eax,%edi
  802103:	83 f7 1f             	xor    $0x1f,%edi
  802106:	75 48                	jne    802150 <__udivdi3+0xa0>
  802108:	39 f0                	cmp    %esi,%eax
  80210a:	72 06                	jb     802112 <__udivdi3+0x62>
  80210c:	31 c0                	xor    %eax,%eax
  80210e:	39 eb                	cmp    %ebp,%ebx
  802110:	77 de                	ja     8020f0 <__udivdi3+0x40>
  802112:	b8 01 00 00 00       	mov    $0x1,%eax
  802117:	eb d7                	jmp    8020f0 <__udivdi3+0x40>
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d9                	mov    %ebx,%ecx
  802122:	85 db                	test   %ebx,%ebx
  802124:	75 0b                	jne    802131 <__udivdi3+0x81>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f3                	div    %ebx
  80212f:	89 c1                	mov    %eax,%ecx
  802131:	31 d2                	xor    %edx,%edx
  802133:	89 f0                	mov    %esi,%eax
  802135:	f7 f1                	div    %ecx
  802137:	89 c6                	mov    %eax,%esi
  802139:	89 e8                	mov    %ebp,%eax
  80213b:	89 f7                	mov    %esi,%edi
  80213d:	f7 f1                	div    %ecx
  80213f:	89 fa                	mov    %edi,%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 f9                	mov    %edi,%ecx
  802152:	ba 20 00 00 00       	mov    $0x20,%edx
  802157:	29 fa                	sub    %edi,%edx
  802159:	d3 e0                	shl    %cl,%eax
  80215b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80215f:	89 d1                	mov    %edx,%ecx
  802161:	89 d8                	mov    %ebx,%eax
  802163:	d3 e8                	shr    %cl,%eax
  802165:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802169:	09 c1                	or     %eax,%ecx
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e3                	shl    %cl,%ebx
  802175:	89 d1                	mov    %edx,%ecx
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 f9                	mov    %edi,%ecx
  80217b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80217f:	89 eb                	mov    %ebp,%ebx
  802181:	d3 e6                	shl    %cl,%esi
  802183:	89 d1                	mov    %edx,%ecx
  802185:	d3 eb                	shr    %cl,%ebx
  802187:	09 f3                	or     %esi,%ebx
  802189:	89 c6                	mov    %eax,%esi
  80218b:	89 f2                	mov    %esi,%edx
  80218d:	89 d8                	mov    %ebx,%eax
  80218f:	f7 74 24 08          	divl   0x8(%esp)
  802193:	89 d6                	mov    %edx,%esi
  802195:	89 c3                	mov    %eax,%ebx
  802197:	f7 64 24 0c          	mull   0xc(%esp)
  80219b:	39 d6                	cmp    %edx,%esi
  80219d:	72 19                	jb     8021b8 <__udivdi3+0x108>
  80219f:	89 f9                	mov    %edi,%ecx
  8021a1:	d3 e5                	shl    %cl,%ebp
  8021a3:	39 c5                	cmp    %eax,%ebp
  8021a5:	73 04                	jae    8021ab <__udivdi3+0xfb>
  8021a7:	39 d6                	cmp    %edx,%esi
  8021a9:	74 0d                	je     8021b8 <__udivdi3+0x108>
  8021ab:	89 d8                	mov    %ebx,%eax
  8021ad:	31 ff                	xor    %edi,%edi
  8021af:	e9 3c ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021bb:	31 ff                	xor    %edi,%edi
  8021bd:	e9 2e ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	f3 0f 1e fb          	endbr32 
  8021d4:	55                   	push   %ebp
  8021d5:	57                   	push   %edi
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	83 ec 1c             	sub    $0x1c,%esp
  8021db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021eb:	89 f0                	mov    %esi,%eax
  8021ed:	89 da                	mov    %ebx,%edx
  8021ef:	85 ff                	test   %edi,%edi
  8021f1:	75 15                	jne    802208 <__umoddi3+0x38>
  8021f3:	39 dd                	cmp    %ebx,%ebp
  8021f5:	76 39                	jbe    802230 <__umoddi3+0x60>
  8021f7:	f7 f5                	div    %ebp
  8021f9:	89 d0                	mov    %edx,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	39 df                	cmp    %ebx,%edi
  80220a:	77 f1                	ja     8021fd <__umoddi3+0x2d>
  80220c:	0f bd cf             	bsr    %edi,%ecx
  80220f:	83 f1 1f             	xor    $0x1f,%ecx
  802212:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802216:	75 40                	jne    802258 <__umoddi3+0x88>
  802218:	39 df                	cmp    %ebx,%edi
  80221a:	72 04                	jb     802220 <__umoddi3+0x50>
  80221c:	39 f5                	cmp    %esi,%ebp
  80221e:	77 dd                	ja     8021fd <__umoddi3+0x2d>
  802220:	89 da                	mov    %ebx,%edx
  802222:	89 f0                	mov    %esi,%eax
  802224:	29 e8                	sub    %ebp,%eax
  802226:	19 fa                	sbb    %edi,%edx
  802228:	eb d3                	jmp    8021fd <__umoddi3+0x2d>
  80222a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802230:	89 e9                	mov    %ebp,%ecx
  802232:	85 ed                	test   %ebp,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x71>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f5                	div    %ebp
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	89 d8                	mov    %ebx,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f1                	div    %ecx
  802247:	89 f0                	mov    %esi,%eax
  802249:	f7 f1                	div    %ecx
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	eb ac                	jmp    8021fd <__umoddi3+0x2d>
  802251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802258:	8b 44 24 04          	mov    0x4(%esp),%eax
  80225c:	ba 20 00 00 00       	mov    $0x20,%edx
  802261:	29 c2                	sub    %eax,%edx
  802263:	89 c1                	mov    %eax,%ecx
  802265:	89 e8                	mov    %ebp,%eax
  802267:	d3 e7                	shl    %cl,%edi
  802269:	89 d1                	mov    %edx,%ecx
  80226b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80226f:	d3 e8                	shr    %cl,%eax
  802271:	89 c1                	mov    %eax,%ecx
  802273:	8b 44 24 04          	mov    0x4(%esp),%eax
  802277:	09 f9                	or     %edi,%ecx
  802279:	89 df                	mov    %ebx,%edi
  80227b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	d3 e5                	shl    %cl,%ebp
  802283:	89 d1                	mov    %edx,%ecx
  802285:	d3 ef                	shr    %cl,%edi
  802287:	89 c1                	mov    %eax,%ecx
  802289:	89 f0                	mov    %esi,%eax
  80228b:	d3 e3                	shl    %cl,%ebx
  80228d:	89 d1                	mov    %edx,%ecx
  80228f:	89 fa                	mov    %edi,%edx
  802291:	d3 e8                	shr    %cl,%eax
  802293:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802298:	09 d8                	or     %ebx,%eax
  80229a:	f7 74 24 08          	divl   0x8(%esp)
  80229e:	89 d3                	mov    %edx,%ebx
  8022a0:	d3 e6                	shl    %cl,%esi
  8022a2:	f7 e5                	mul    %ebp
  8022a4:	89 c7                	mov    %eax,%edi
  8022a6:	89 d1                	mov    %edx,%ecx
  8022a8:	39 d3                	cmp    %edx,%ebx
  8022aa:	72 06                	jb     8022b2 <__umoddi3+0xe2>
  8022ac:	75 0e                	jne    8022bc <__umoddi3+0xec>
  8022ae:	39 c6                	cmp    %eax,%esi
  8022b0:	73 0a                	jae    8022bc <__umoddi3+0xec>
  8022b2:	29 e8                	sub    %ebp,%eax
  8022b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022b8:	89 d1                	mov    %edx,%ecx
  8022ba:	89 c7                	mov    %eax,%edi
  8022bc:	89 f5                	mov    %esi,%ebp
  8022be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022c2:	29 fd                	sub    %edi,%ebp
  8022c4:	19 cb                	sbb    %ecx,%ebx
  8022c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022cb:	89 d8                	mov    %ebx,%eax
  8022cd:	d3 e0                	shl    %cl,%eax
  8022cf:	89 f1                	mov    %esi,%ecx
  8022d1:	d3 ed                	shr    %cl,%ebp
  8022d3:	d3 eb                	shr    %cl,%ebx
  8022d5:	09 e8                	or     %ebp,%eax
  8022d7:	89 da                	mov    %ebx,%edx
  8022d9:	83 c4 1c             	add    $0x1c,%esp
  8022dc:	5b                   	pop    %ebx
  8022dd:	5e                   	pop    %esi
  8022de:	5f                   	pop    %edi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    
