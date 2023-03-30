
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
  80003a:	e8 b7 0d 00 00       	call   800df6 <sys_time_msec>
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
  800058:	68 02 23 80 00       	push   $0x802302
  80005d:	6a 0d                	push   $0xd
  80005f:	68 f2 22 80 00       	push   $0x8022f2
  800064:	e8 eb 00 00 00       	call   800154 <_panic>
		panic("sys_time_msec: %e", (int)now);
  800069:	50                   	push   %eax
  80006a:	68 e0 22 80 00       	push   $0x8022e0
  80006f:	6a 0b                	push   $0xb
  800071:	68 f2 22 80 00       	push   $0x8022f2
  800076:	e8 d9 00 00 00       	call   800154 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  80007b:	e8 66 0b 00 00       	call   800be6 <sys_yield>
	while (sys_time_msec() < end)
  800080:	e8 71 0d 00 00       	call   800df6 <sys_time_msec>
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
  80009a:	e8 47 0b 00 00       	call   800be6 <sys_yield>
	for (i = 0; i < 50; i++)
  80009f:	83 eb 01             	sub    $0x1,%ebx
  8000a2:	75 f6                	jne    80009a <umain+0xc>

	cprintf("starting count down: ");
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	68 0e 23 80 00       	push   $0x80230e
  8000ac:	e8 7e 01 00 00       	call   80022f <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b4:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	53                   	push   %ebx
  8000bd:	68 24 23 80 00       	push   $0x802324
  8000c2:	e8 68 01 00 00       	call   80022f <cprintf>
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
  8000e1:	68 a0 27 80 00       	push   $0x8027a0
  8000e6:	e8 44 01 00 00       	call   80022f <cprintf>
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
  8000ff:	e8 c3 0a 00 00       	call   800bc7 <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800111:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800116:	85 db                	test   %ebx,%ebx
  800118:	7e 07                	jle    800121 <libmain+0x2d>
		binaryname = argv[0];
  80011a:	8b 06                	mov    (%esi),%eax
  80011c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
  800126:	e8 63 ff ff ff       	call   80008e <umain>

	// exit gracefully
	exit();
  80012b:	e8 0a 00 00 00       	call   80013a <exit>
}
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800140:	e8 e3 0e 00 00       	call   801028 <close_all>
	sys_env_destroy(0);
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	6a 00                	push   $0x0
  80014a:	e8 37 0a 00 00       	call   800b86 <sys_env_destroy>
}
  80014f:	83 c4 10             	add    $0x10,%esp
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800162:	e8 60 0a 00 00       	call   800bc7 <sys_getenvid>
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	ff 75 0c             	push   0xc(%ebp)
  80016d:	ff 75 08             	push   0x8(%ebp)
  800170:	56                   	push   %esi
  800171:	50                   	push   %eax
  800172:	68 34 23 80 00       	push   $0x802334
  800177:	e8 b3 00 00 00       	call   80022f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017c:	83 c4 18             	add    $0x18,%esp
  80017f:	53                   	push   %ebx
  800180:	ff 75 10             	push   0x10(%ebp)
  800183:	e8 56 00 00 00       	call   8001de <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 a0 27 80 00 	movl   $0x8027a0,(%esp)
  80018f:	e8 9b 00 00 00       	call   80022f <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800197:	cc                   	int3   
  800198:	eb fd                	jmp    800197 <_panic+0x43>

0080019a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	83 ec 04             	sub    $0x4,%esp
  8001a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a4:	8b 13                	mov    (%ebx),%edx
  8001a6:	8d 42 01             	lea    0x1(%edx),%eax
  8001a9:	89 03                	mov    %eax,(%ebx)
  8001ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b7:	74 09                	je     8001c2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	68 ff 00 00 00       	push   $0xff
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 76 09 00 00       	call   800b49 <sys_cputs>
		b->idx = 0;
  8001d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb db                	jmp    8001b9 <putch+0x1f>

008001de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ee:	00 00 00 
	b.cnt = 0;
  8001f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fb:	ff 75 0c             	push   0xc(%ebp)
  8001fe:	ff 75 08             	push   0x8(%ebp)
  800201:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	68 9a 01 80 00       	push   $0x80019a
  80020d:	e8 14 01 00 00       	call   800326 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800212:	83 c4 08             	add    $0x8,%esp
  800215:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	50                   	push   %eax
  800222:	e8 22 09 00 00       	call   800b49 <sys_cputs>

	return b.cnt;
}
  800227:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800235:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800238:	50                   	push   %eax
  800239:	ff 75 08             	push   0x8(%ebp)
  80023c:	e8 9d ff ff ff       	call   8001de <vcprintf>
	va_end(ap);

	return cnt;
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 1c             	sub    $0x1c,%esp
  80024c:	89 c7                	mov    %eax,%edi
  80024e:	89 d6                	mov    %edx,%esi
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	8b 55 0c             	mov    0xc(%ebp),%edx
  800256:	89 d1                	mov    %edx,%ecx
  800258:	89 c2                	mov    %eax,%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800260:	8b 45 10             	mov    0x10(%ebp),%eax
  800263:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800269:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800270:	39 c2                	cmp    %eax,%edx
  800272:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800275:	72 3e                	jb     8002b5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	push   0x18(%ebp)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	53                   	push   %ebx
  800281:	50                   	push   %eax
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	ff 75 e4             	push   -0x1c(%ebp)
  800288:	ff 75 e0             	push   -0x20(%ebp)
  80028b:	ff 75 dc             	push   -0x24(%ebp)
  80028e:	ff 75 d8             	push   -0x28(%ebp)
  800291:	e8 0a 1e 00 00       	call   8020a0 <__udivdi3>
  800296:	83 c4 18             	add    $0x18,%esp
  800299:	52                   	push   %edx
  80029a:	50                   	push   %eax
  80029b:	89 f2                	mov    %esi,%edx
  80029d:	89 f8                	mov    %edi,%eax
  80029f:	e8 9f ff ff ff       	call   800243 <printnum>
  8002a4:	83 c4 20             	add    $0x20,%esp
  8002a7:	eb 13                	jmp    8002bc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	ff 75 18             	push   0x18(%ebp)
  8002b0:	ff d7                	call   *%edi
  8002b2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f ed                	jg     8002a9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	push   -0x1c(%ebp)
  8002c6:	ff 75 e0             	push   -0x20(%ebp)
  8002c9:	ff 75 dc             	push   -0x24(%ebp)
  8002cc:	ff 75 d8             	push   -0x28(%ebp)
  8002cf:	e8 ec 1e 00 00       	call   8021c0 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 57 23 80 00 	movsbl 0x802357(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fb:	73 0a                	jae    800307 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fd:	8d 4a 01             	lea    0x1(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	88 02                	mov    %al,(%edx)
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <printfmt>:
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800312:	50                   	push   %eax
  800313:	ff 75 10             	push   0x10(%ebp)
  800316:	ff 75 0c             	push   0xc(%ebp)
  800319:	ff 75 08             	push   0x8(%ebp)
  80031c:	e8 05 00 00 00       	call   800326 <vprintfmt>
}
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <vprintfmt>:
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 3c             	sub    $0x3c,%esp
  80032f:	8b 75 08             	mov    0x8(%ebp),%esi
  800332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800335:	8b 7d 10             	mov    0x10(%ebp),%edi
  800338:	eb 0a                	jmp    800344 <vprintfmt+0x1e>
			putch(ch, putdat);
  80033a:	83 ec 08             	sub    $0x8,%esp
  80033d:	53                   	push   %ebx
  80033e:	50                   	push   %eax
  80033f:	ff d6                	call   *%esi
  800341:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800344:	83 c7 01             	add    $0x1,%edi
  800347:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034b:	83 f8 25             	cmp    $0x25,%eax
  80034e:	74 0c                	je     80035c <vprintfmt+0x36>
			if (ch == '\0')
  800350:	85 c0                	test   %eax,%eax
  800352:	75 e6                	jne    80033a <vprintfmt+0x14>
}
  800354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    
		padc = ' ';
  80035c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800360:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800367:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80036e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800375:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8d 47 01             	lea    0x1(%edi),%eax
  80037d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800380:	0f b6 17             	movzbl (%edi),%edx
  800383:	8d 42 dd             	lea    -0x23(%edx),%eax
  800386:	3c 55                	cmp    $0x55,%al
  800388:	0f 87 bb 03 00 00    	ja     800749 <vprintfmt+0x423>
  80038e:	0f b6 c0             	movzbl %al,%eax
  800391:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80039b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80039f:	eb d9                	jmp    80037a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a8:	eb d0                	jmp    80037a <vprintfmt+0x54>
  8003aa:	0f b6 d2             	movzbl %dl,%edx
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003bf:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c5:	83 f9 09             	cmp    $0x9,%ecx
  8003c8:	77 55                	ja     80041f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003ca:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003cd:	eb e9                	jmp    8003b8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 40 04             	lea    0x4(%eax),%eax
  8003dd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e7:	79 91                	jns    80037a <vprintfmt+0x54>
				width = precision, precision = -1;
  8003e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ef:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003f6:	eb 82                	jmp    80037a <vprintfmt+0x54>
  8003f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fb:	85 d2                	test   %edx,%edx
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	0f 49 c2             	cmovns %edx,%eax
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040b:	e9 6a ff ff ff       	jmp    80037a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800413:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041a:	e9 5b ff ff ff       	jmp    80037a <vprintfmt+0x54>
  80041f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800422:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800425:	eb bc                	jmp    8003e3 <vprintfmt+0xbd>
			lflag++;
  800427:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80042d:	e9 48 ff ff ff       	jmp    80037a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 78 04             	lea    0x4(%eax),%edi
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 30                	push   (%eax)
  80043e:	ff d6                	call   *%esi
			break;
  800440:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800446:	e9 9d 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 78 04             	lea    0x4(%eax),%edi
  800451:	8b 10                	mov    (%eax),%edx
  800453:	89 d0                	mov    %edx,%eax
  800455:	f7 d8                	neg    %eax
  800457:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 23                	jg     800482 <vprintfmt+0x15c>
  80045f:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	74 18                	je     800482 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80046a:	52                   	push   %edx
  80046b:	68 35 27 80 00       	push   $0x802735
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 92 fe ff ff       	call   800309 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80047d:	e9 66 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800482:	50                   	push   %eax
  800483:	68 6f 23 80 00       	push   $0x80236f
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7a fe ff ff       	call   800309 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800492:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800495:	e9 4e 02 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	83 c0 04             	add    $0x4,%eax
  8004a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	b8 68 23 80 00       	mov    $0x802368,%eax
  8004af:	0f 45 c2             	cmovne %edx,%eax
  8004b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	7e 06                	jle    8004c1 <vprintfmt+0x19b>
  8004bb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004bf:	75 0d                	jne    8004ce <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c4:	89 c7                	mov    %eax,%edi
  8004c6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	eb 55                	jmp    800523 <vprintfmt+0x1fd>
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 d8             	push   -0x28(%ebp)
  8004d4:	ff 75 cc             	push   -0x34(%ebp)
  8004d7:	e8 0a 03 00 00       	call   8007e6 <strnlen>
  8004dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004df:	29 c1                	sub    %eax,%ecx
  8004e1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004e9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	eb 0f                	jmp    800501 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	ff 75 e0             	push   -0x20(%ebp)
  8004f9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ed                	jg     8004f2 <vprintfmt+0x1cc>
  800505:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800508:	85 d2                	test   %edx,%edx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c2             	cmovns %edx,%eax
  800512:	29 c2                	sub    %eax,%edx
  800514:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800517:	eb a8                	jmp    8004c1 <vprintfmt+0x19b>
					putch(ch, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	52                   	push   %edx
  80051e:	ff d6                	call   *%esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	83 c7 01             	add    $0x1,%edi
  80052b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052f:	0f be d0             	movsbl %al,%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	74 4b                	je     800581 <vprintfmt+0x25b>
  800536:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053a:	78 06                	js     800542 <vprintfmt+0x21c>
  80053c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800540:	78 1e                	js     800560 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800542:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800546:	74 d1                	je     800519 <vprintfmt+0x1f3>
  800548:	0f be c0             	movsbl %al,%eax
  80054b:	83 e8 20             	sub    $0x20,%eax
  80054e:	83 f8 5e             	cmp    $0x5e,%eax
  800551:	76 c6                	jbe    800519 <vprintfmt+0x1f3>
					putch('?', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	6a 3f                	push   $0x3f
  800559:	ff d6                	call   *%esi
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	eb c3                	jmp    800523 <vprintfmt+0x1fd>
  800560:	89 cf                	mov    %ecx,%edi
  800562:	eb 0e                	jmp    800572 <vprintfmt+0x24c>
				putch(' ', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 20                	push   $0x20
  80056a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ee                	jg     800564 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	e9 67 01 00 00       	jmp    8006e8 <vprintfmt+0x3c2>
  800581:	89 cf                	mov    %ecx,%edi
  800583:	eb ed                	jmp    800572 <vprintfmt+0x24c>
	if (lflag >= 2)
  800585:	83 f9 01             	cmp    $0x1,%ecx
  800588:	7f 1b                	jg     8005a5 <vprintfmt+0x27f>
	else if (lflag)
  80058a:	85 c9                	test   %ecx,%ecx
  80058c:	74 63                	je     8005f1 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	99                   	cltd   
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a3:	eb 17                	jmp    8005bc <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 50 04             	mov    0x4(%eax),%edx
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 08             	lea    0x8(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c2:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	0f 89 ff 00 00 00    	jns    8006ce <vprintfmt+0x3a8>
				putch('-', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 2d                	push   $0x2d
  8005d5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 d1 00             	adc    $0x0,%ecx
  8005e2:	f7 d9                	neg    %ecx
  8005e4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e7:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ec:	e9 dd 00 00 00       	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	99                   	cltd   
  8005fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
  800606:	eb b4                	jmp    8005bc <vprintfmt+0x296>
	if (lflag >= 2)
  800608:	83 f9 01             	cmp    $0x1,%ecx
  80060b:	7f 1e                	jg     80062b <vprintfmt+0x305>
	else if (lflag)
  80060d:	85 c9                	test   %ecx,%ecx
  80060f:	74 32                	je     800643 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800621:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800626:	e9 a3 00 00 00       	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	8b 48 04             	mov    0x4(%eax),%ecx
  800633:	8d 40 08             	lea    0x8(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800639:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80063e:	e9 8b 00 00 00       	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800653:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800658:	eb 74                	jmp    8006ce <vprintfmt+0x3a8>
	if (lflag >= 2)
  80065a:	83 f9 01             	cmp    $0x1,%ecx
  80065d:	7f 1b                	jg     80067a <vprintfmt+0x354>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	74 2c                	je     80068f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800673:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800678:	eb 54                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8b 48 04             	mov    0x4(%eax),%ecx
  800682:	8d 40 08             	lea    0x8(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800688:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80068d:	eb 3f                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 10                	mov    (%eax),%edx
  800694:	b9 00 00 00 00       	mov    $0x0,%ecx
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80069f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006a4:	eb 28                	jmp    8006ce <vprintfmt+0x3a8>
			putch('0', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 30                	push   $0x30
  8006ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 78                	push   $0x78
  8006b4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c9:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	ff 75 e0             	push   -0x20(%ebp)
  8006d9:	57                   	push   %edi
  8006da:	51                   	push   %ecx
  8006db:	52                   	push   %edx
  8006dc:	89 da                	mov    %ebx,%edx
  8006de:	89 f0                	mov    %esi,%eax
  8006e0:	e8 5e fb ff ff       	call   800243 <printnum>
			break;
  8006e5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006eb:	e9 54 fc ff ff       	jmp    800344 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006f0:	83 f9 01             	cmp    $0x1,%ecx
  8006f3:	7f 1b                	jg     800710 <vprintfmt+0x3ea>
	else if (lflag)
  8006f5:	85 c9                	test   %ecx,%ecx
  8006f7:	74 2c                	je     800725 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80070e:	eb be                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	8b 48 04             	mov    0x4(%eax),%ecx
  800718:	8d 40 08             	lea    0x8(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800723:	eb a9                	jmp    8006ce <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800735:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80073a:	eb 92                	jmp    8006ce <vprintfmt+0x3a8>
			putch(ch, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 25                	push   $0x25
  800742:	ff d6                	call   *%esi
			break;
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 9f                	jmp    8006e8 <vprintfmt+0x3c2>
			putch('%', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 25                	push   $0x25
  80074f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	89 f8                	mov    %edi,%eax
  800756:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075a:	74 05                	je     800761 <vprintfmt+0x43b>
  80075c:	83 e8 01             	sub    $0x1,%eax
  80075f:	eb f5                	jmp    800756 <vprintfmt+0x430>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800764:	eb 82                	jmp    8006e8 <vprintfmt+0x3c2>

00800766 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 26                	je     8007ad <vsnprintf+0x47>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 22                	jle    8007ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	push   0x14(%ebp)
  80078e:	ff 75 10             	push   0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	68 ec 02 80 00       	push   $0x8002ec
  80079a:	e8 87 fb ff ff       	call   800326 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a8:	83 c4 10             	add    $0x10,%esp
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b2:	eb f7                	jmp    8007ab <vsnprintf+0x45>

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	push   0x10(%ebp)
  8007c1:	ff 75 0c             	push   0xc(%ebp)
  8007c4:	ff 75 08             	push   0x8(%ebp)
  8007c7:	e8 9a ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 03                	jmp    8007de <strlen+0x10>
		n++;
  8007db:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f7                	jne    8007db <strlen+0xd>
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 03                	jmp    8007f9 <strnlen+0x13>
		n++;
  8007f6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	39 d0                	cmp    %edx,%eax
  8007fb:	74 08                	je     800805 <strnlen+0x1f>
  8007fd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800801:	75 f3                	jne    8007f6 <strnlen+0x10>
  800803:	89 c2                	mov    %eax,%edx
	return n;
}
  800805:	89 d0                	mov    %edx,%eax
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80081c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	84 d2                	test   %dl,%dl
  800824:	75 f2                	jne    800818 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800826:	89 c8                	mov    %ecx,%eax
  800828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	53                   	push   %ebx
  800831:	83 ec 10             	sub    $0x10,%esp
  800834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800837:	53                   	push   %ebx
  800838:	e8 91 ff ff ff       	call   8007ce <strlen>
  80083d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800840:	ff 75 0c             	push   0xc(%ebp)
  800843:	01 d8                	add    %ebx,%eax
  800845:	50                   	push   %eax
  800846:	e8 be ff ff ff       	call   800809 <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f0                	mov    %esi,%eax
  800864:	eb 0f                	jmp    800875 <strncpy+0x23>
		*dst++ = *src;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	0f b6 0a             	movzbl (%edx),%ecx
  80086c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086f:	80 f9 01             	cmp    $0x1,%cl
  800872:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800875:	39 d8                	cmp    %ebx,%eax
  800877:	75 ed                	jne    800866 <strncpy+0x14>
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	8b 55 10             	mov    0x10(%ebp),%edx
  80088d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088f:	85 d2                	test   %edx,%edx
  800891:	74 21                	je     8008b4 <strlcpy+0x35>
  800893:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800897:	89 f2                	mov    %esi,%edx
  800899:	eb 09                	jmp    8008a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089b:	83 c1 01             	add    $0x1,%ecx
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008a4:	39 c2                	cmp    %eax,%edx
  8008a6:	74 09                	je     8008b1 <strlcpy+0x32>
  8008a8:	0f b6 19             	movzbl (%ecx),%ebx
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 ec                	jne    80089b <strlcpy+0x1c>
  8008af:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strcmp+0x11>
		p++, q++;
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strcmp+0x1c>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	74 ef                	je     8008c5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 c0             	movzbl %al,%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ef:	eb 06                	jmp    8008f7 <strncmp+0x17>
		n--, p++, q++;
  8008f1:	83 c0 01             	add    $0x1,%eax
  8008f4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f7:	39 d8                	cmp    %ebx,%eax
  8008f9:	74 18                	je     800913 <strncmp+0x33>
  8008fb:	0f b6 08             	movzbl (%eax),%ecx
  8008fe:	84 c9                	test   %cl,%cl
  800900:	74 04                	je     800906 <strncmp+0x26>
  800902:	3a 0a                	cmp    (%edx),%cl
  800904:	74 eb                	je     8008f1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 00             	movzbl (%eax),%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800911:	c9                   	leave  
  800912:	c3                   	ret    
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	eb f4                	jmp    80090e <strncmp+0x2e>

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 03                	jmp    800929 <strchr+0xf>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
  80092c:	84 d2                	test   %dl,%dl
  80092e:	74 06                	je     800936 <strchr+0x1c>
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	75 f2                	jne    800926 <strchr+0xc>
  800934:	eb 05                	jmp    80093b <strchr+0x21>
			return (char *) s;
	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 09                	je     800957 <strfind+0x1a>
  80094e:	84 d2                	test   %dl,%dl
  800950:	74 05                	je     800957 <strfind+0x1a>
	for (; *s; s++)
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	eb f0                	jmp    800947 <strfind+0xa>
			break;
	return (char *) s;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 2f                	je     800998 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	89 f8                	mov    %edi,%eax
  80096b:	09 c8                	or     %ecx,%eax
  80096d:	a8 03                	test   $0x3,%al
  80096f:	75 21                	jne    800992 <memset+0x39>
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d0                	mov    %edx,%eax
  800977:	c1 e0 08             	shl    $0x8,%eax
  80097a:	89 d3                	mov    %edx,%ebx
  80097c:	c1 e3 18             	shl    $0x18,%ebx
  80097f:	89 d6                	mov    %edx,%esi
  800981:	c1 e6 10             	shl    $0x10,%esi
  800984:	09 f3                	or     %esi,%ebx
  800986:	09 da                	or     %ebx,%edx
  800988:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098d:	fc                   	cld    
  80098e:	f3 ab                	rep stos %eax,%es:(%edi)
  800990:	eb 06                	jmp    800998 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	fc                   	cld    
  800996:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800998:	89 f8                	mov    %edi,%eax
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ad:	39 c6                	cmp    %eax,%esi
  8009af:	73 32                	jae    8009e3 <memmove+0x44>
  8009b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b4:	39 c2                	cmp    %eax,%edx
  8009b6:	76 2b                	jbe    8009e3 <memmove+0x44>
		s += n;
		d += n;
  8009b8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	89 d6                	mov    %edx,%esi
  8009bd:	09 fe                	or     %edi,%esi
  8009bf:	09 ce                	or     %ecx,%esi
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 0e                	jne    8009d7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c9:	83 ef 04             	sub    $0x4,%edi
  8009cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d2:	fd                   	std    
  8009d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d5:	eb 09                	jmp    8009e0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d7:	83 ef 01             	sub    $0x1,%edi
  8009da:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009dd:	fd                   	std    
  8009de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e0:	fc                   	cld    
  8009e1:	eb 1a                	jmp    8009fd <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 f2                	mov    %esi,%edx
  8009e5:	09 c2                	or     %eax,%edx
  8009e7:	09 ca                	or     %ecx,%edx
  8009e9:	f6 c2 03             	test   $0x3,%dl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a07:	ff 75 10             	push   0x10(%ebp)
  800a0a:	ff 75 0c             	push   0xc(%ebp)
  800a0d:	ff 75 08             	push   0x8(%ebp)
  800a10:	e8 8a ff ff ff       	call   80099f <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	eb 06                	jmp    800a2f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a2f:	39 f0                	cmp    %esi,%eax
  800a31:	74 14                	je     800a47 <memcmp+0x30>
		if (*s1 != *s2)
  800a33:	0f b6 08             	movzbl (%eax),%ecx
  800a36:	0f b6 1a             	movzbl (%edx),%ebx
  800a39:	38 d9                	cmp    %bl,%cl
  800a3b:	74 ec                	je     800a29 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c1             	movzbl %cl,%eax
  800a40:	0f b6 db             	movzbl %bl,%ebx
  800a43:	29 d8                	sub    %ebx,%eax
  800a45:	eb 05                	jmp    800a4c <memcmp+0x35>
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5e:	eb 03                	jmp    800a63 <memfind+0x13>
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	39 d0                	cmp    %edx,%eax
  800a65:	73 04                	jae    800a6b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	38 08                	cmp    %cl,(%eax)
  800a69:	75 f5                	jne    800a60 <memfind+0x10>
			break;
	return (void *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	eb 03                	jmp    800a7e <strtol+0x11>
		s++;
  800a7b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a7e:	0f b6 02             	movzbl (%edx),%eax
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f6                	je     800a7b <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f2                	je     800a7b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	74 2a                	je     800ab7 <strtol+0x4a>
	int neg = 0;
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a92:	3c 2d                	cmp    $0x2d,%al
  800a94:	74 2b                	je     800ac1 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 0f                	jne    800aad <strtol+0x40>
  800a9e:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa1:	74 28                	je     800acb <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aaa:	0f 44 d8             	cmove  %eax,%ebx
  800aad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab5:	eb 46                	jmp    800afd <strtol+0x90>
		s++;
  800ab7:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aba:	bf 00 00 00 00       	mov    $0x0,%edi
  800abf:	eb d5                	jmp    800a96 <strtol+0x29>
		s++, neg = 1;
  800ac1:	83 c2 01             	add    $0x1,%edx
  800ac4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac9:	eb cb                	jmp    800a96 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acf:	74 0e                	je     800adf <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	75 d8                	jne    800aad <strtol+0x40>
		s++, base = 8;
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800add:	eb ce                	jmp    800aad <strtol+0x40>
		s += 2, base = 16;
  800adf:	83 c2 02             	add    $0x2,%edx
  800ae2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae7:	eb c4                	jmp    800aad <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae9:	0f be c0             	movsbl %al,%eax
  800aec:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aef:	3b 45 10             	cmp    0x10(%ebp),%eax
  800af2:	7d 3a                	jge    800b2e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800afb:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800afd:	0f b6 02             	movzbl (%edx),%eax
  800b00:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b03:	89 f3                	mov    %esi,%ebx
  800b05:	80 fb 09             	cmp    $0x9,%bl
  800b08:	76 df                	jbe    800ae9 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b0a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b14:	0f be c0             	movsbl %al,%eax
  800b17:	83 e8 57             	sub    $0x57,%eax
  800b1a:	eb d3                	jmp    800aef <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b1f:	89 f3                	mov    %esi,%ebx
  800b21:	80 fb 19             	cmp    $0x19,%bl
  800b24:	77 08                	ja     800b2e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b26:	0f be c0             	movsbl %al,%eax
  800b29:	83 e8 37             	sub    $0x37,%eax
  800b2c:	eb c1                	jmp    800aef <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b32:	74 05                	je     800b39 <strtol+0xcc>
		*endptr = (char *) s;
  800b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b37:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b39:	89 c8                	mov    %ecx,%eax
  800b3b:	f7 d8                	neg    %eax
  800b3d:	85 ff                	test   %edi,%edi
  800b3f:	0f 45 c8             	cmovne %eax,%ecx
}
  800b42:	89 c8                	mov    %ecx,%eax
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	89 c3                	mov    %eax,%ebx
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 01 00 00 00       	mov    $0x1,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9c:	89 cb                	mov    %ecx,%ebx
  800b9e:	89 cf                	mov    %ecx,%edi
  800ba0:	89 ce                	mov    %ecx,%esi
  800ba2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7f 08                	jg     800bb0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	50                   	push   %eax
  800bb4:	6a 03                	push   $0x3
  800bb6:	68 5f 26 80 00       	push   $0x80265f
  800bbb:	6a 2a                	push   $0x2a
  800bbd:	68 7c 26 80 00       	push   $0x80267c
  800bc2:	e8 8d f5 ff ff       	call   800154 <_panic>

00800bc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd7:	89 d1                	mov    %edx,%ecx
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	89 d7                	mov    %edx,%edi
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7f 08                	jg     800c31 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	50                   	push   %eax
  800c35:	6a 04                	push   $0x4
  800c37:	68 5f 26 80 00       	push   $0x80265f
  800c3c:	6a 2a                	push   $0x2a
  800c3e:	68 7c 26 80 00       	push   $0x80267c
  800c43:	e8 0c f5 ff ff       	call   800154 <_panic>

00800c48 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c62:	8b 75 18             	mov    0x18(%ebp),%esi
  800c65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7f 08                	jg     800c73 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 05                	push   $0x5
  800c79:	68 5f 26 80 00       	push   $0x80265f
  800c7e:	6a 2a                	push   $0x2a
  800c80:	68 7c 26 80 00       	push   $0x80267c
  800c85:	e8 ca f4 ff ff       	call   800154 <_panic>

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7f 08                	jg     800cb5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	6a 06                	push   $0x6
  800cbb:	68 5f 26 80 00       	push   $0x80265f
  800cc0:	6a 2a                	push   $0x2a
  800cc2:	68 7c 26 80 00       	push   $0x80267c
  800cc7:	e8 88 f4 ff ff       	call   800154 <_panic>

00800ccc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7f 08                	jg     800cf7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 08                	push   $0x8
  800cfd:	68 5f 26 80 00       	push   $0x80265f
  800d02:	6a 2a                	push   $0x2a
  800d04:	68 7c 26 80 00       	push   $0x80267c
  800d09:	e8 46 f4 ff ff       	call   800154 <_panic>

00800d0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	b8 09 00 00 00       	mov    $0x9,%eax
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7f 08                	jg     800d39 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 09                	push   $0x9
  800d3f:	68 5f 26 80 00       	push   $0x80265f
  800d44:	6a 2a                	push   $0x2a
  800d46:	68 7c 26 80 00       	push   $0x80267c
  800d4b:	e8 04 f4 ff ff       	call   800154 <_panic>

00800d50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7f 08                	jg     800d7b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	50                   	push   %eax
  800d7f:	6a 0a                	push   $0xa
  800d81:	68 5f 26 80 00       	push   $0x80265f
  800d86:	6a 2a                	push   $0x2a
  800d88:	68 7c 26 80 00       	push   $0x80267c
  800d8d:	e8 c2 f3 ff ff       	call   800154 <_panic>

00800d92 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da3:	be 00 00 00 00       	mov    $0x0,%esi
  800da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dae:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcb:	89 cb                	mov    %ecx,%ebx
  800dcd:	89 cf                	mov    %ecx,%edi
  800dcf:	89 ce                	mov    %ecx,%esi
  800dd1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7f 08                	jg     800ddf <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	50                   	push   %eax
  800de3:	6a 0d                	push   $0xd
  800de5:	68 5f 26 80 00       	push   $0x80265f
  800dea:	6a 2a                	push   $0x2a
  800dec:	68 7c 26 80 00       	push   $0x80267c
  800df1:	e8 5e f3 ff ff       	call   800154 <_panic>

00800df6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800e01:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	89 d3                	mov    %edx,%ebx
  800e0a:	89 d7                	mov    %edx,%edi
  800e0c:	89 d6                	mov    %edx,%esi
  800e0e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e62:	c1 e8 0c             	shr    $0xc,%eax
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e77:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	c1 ea 16             	shr    $0x16,%edx
  800e8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e92:	f6 c2 01             	test   $0x1,%dl
  800e95:	74 29                	je     800ec0 <fd_alloc+0x42>
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 0c             	shr    $0xc,%edx
  800e9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea3:	f6 c2 01             	test   $0x1,%dl
  800ea6:	74 18                	je     800ec0 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800ea8:	05 00 10 00 00       	add    $0x1000,%eax
  800ead:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb2:	75 d2                	jne    800e86 <fd_alloc+0x8>
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800eb9:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ebe:	eb 05                	jmp    800ec5 <fd_alloc+0x47>
			return 0;
  800ec0:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	89 02                	mov    %eax,(%edx)
}
  800eca:	89 c8                	mov    %ecx,%eax
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed4:	83 f8 1f             	cmp    $0x1f,%eax
  800ed7:	77 30                	ja     800f09 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed9:	c1 e0 0c             	shl    $0xc,%eax
  800edc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ee1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	74 24                	je     800f10 <fd_lookup+0x42>
  800eec:	89 c2                	mov    %eax,%edx
  800eee:	c1 ea 0c             	shr    $0xc,%edx
  800ef1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef8:	f6 c2 01             	test   $0x1,%dl
  800efb:	74 1a                	je     800f17 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f00:	89 02                	mov    %eax,(%edx)
	return 0;
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
		return -E_INVAL;
  800f09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0e:	eb f7                	jmp    800f07 <fd_lookup+0x39>
		return -E_INVAL;
  800f10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f15:	eb f0                	jmp    800f07 <fd_lookup+0x39>
  800f17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1c:	eb e9                	jmp    800f07 <fd_lookup+0x39>

00800f1e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	53                   	push   %ebx
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f32:	39 13                	cmp    %edx,(%ebx)
  800f34:	74 37                	je     800f6d <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f36:	83 c0 01             	add    $0x1,%eax
  800f39:	8b 1c 85 08 27 80 00 	mov    0x802708(,%eax,4),%ebx
  800f40:	85 db                	test   %ebx,%ebx
  800f42:	75 ee                	jne    800f32 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f44:	a1 00 40 80 00       	mov    0x804000,%eax
  800f49:	8b 40 48             	mov    0x48(%eax),%eax
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	52                   	push   %edx
  800f50:	50                   	push   %eax
  800f51:	68 8c 26 80 00       	push   $0x80268c
  800f56:	e8 d4 f2 ff ff       	call   80022f <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f66:	89 1a                	mov    %ebx,(%edx)
}
  800f68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    
			return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	eb ef                	jmp    800f63 <dev_lookup+0x45>

00800f74 <fd_close>:
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 24             	sub    $0x24,%esp
  800f7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f80:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f83:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f86:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f87:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f90:	50                   	push   %eax
  800f91:	e8 38 ff ff ff       	call   800ece <fd_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 05                	js     800fa4 <fd_close+0x30>
	    || fd != fd2)
  800f9f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fa2:	74 16                	je     800fba <fd_close+0x46>
		return (must_exist ? r : 0);
  800fa4:	89 f8                	mov    %edi,%eax
  800fa6:	84 c0                	test   %al,%al
  800fa8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fad:	0f 44 d8             	cmove  %eax,%ebx
}
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 36                	push   (%esi)
  800fc3:	e8 56 ff ff ff       	call   800f1e <dev_lookup>
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 1a                	js     800feb <fd_close+0x77>
		if (dev->dev_close)
  800fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd4:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	74 0b                	je     800feb <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	56                   	push   %esi
  800fe4:	ff d0                	call   *%eax
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	56                   	push   %esi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 94 fc ff ff       	call   800c8a <sys_page_unmap>
	return r;
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	eb b5                	jmp    800fb0 <fd_close+0x3c>

00800ffb <close>:

int
close(int fdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	push   0x8(%ebp)
  801008:	e8 c1 fe ff ff       	call   800ece <fd_lookup>
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	79 02                	jns    801016 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801014:	c9                   	leave  
  801015:	c3                   	ret    
		return fd_close(fd, 1);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	6a 01                	push   $0x1
  80101b:	ff 75 f4             	push   -0xc(%ebp)
  80101e:	e8 51 ff ff ff       	call   800f74 <fd_close>
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	eb ec                	jmp    801014 <close+0x19>

00801028 <close_all>:

void
close_all(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	53                   	push   %ebx
  80102c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	53                   	push   %ebx
  801038:	e8 be ff ff ff       	call   800ffb <close>
	for (i = 0; i < MAXFD; i++)
  80103d:	83 c3 01             	add    $0x1,%ebx
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	83 fb 20             	cmp    $0x20,%ebx
  801046:	75 ec                	jne    801034 <close_all+0xc>
}
  801048:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801056:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801059:	50                   	push   %eax
  80105a:	ff 75 08             	push   0x8(%ebp)
  80105d:	e8 6c fe ff ff       	call   800ece <fd_lookup>
  801062:	89 c3                	mov    %eax,%ebx
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	78 7f                	js     8010ea <dup+0x9d>
		return r;
	close(newfdnum);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	ff 75 0c             	push   0xc(%ebp)
  801071:	e8 85 ff ff ff       	call   800ffb <close>

	newfd = INDEX2FD(newfdnum);
  801076:	8b 75 0c             	mov    0xc(%ebp),%esi
  801079:	c1 e6 0c             	shl    $0xc,%esi
  80107c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801082:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801085:	89 3c 24             	mov    %edi,(%esp)
  801088:	e8 da fd ff ff       	call   800e67 <fd2data>
  80108d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80108f:	89 34 24             	mov    %esi,(%esp)
  801092:	e8 d0 fd ff ff       	call   800e67 <fd2data>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80109d:	89 d8                	mov    %ebx,%eax
  80109f:	c1 e8 16             	shr    $0x16,%eax
  8010a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a9:	a8 01                	test   $0x1,%al
  8010ab:	74 11                	je     8010be <dup+0x71>
  8010ad:	89 d8                	mov    %ebx,%eax
  8010af:	c1 e8 0c             	shr    $0xc,%eax
  8010b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b9:	f6 c2 01             	test   $0x1,%dl
  8010bc:	75 36                	jne    8010f4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010be:	89 f8                	mov    %edi,%eax
  8010c0:	c1 e8 0c             	shr    $0xc,%eax
  8010c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d2:	50                   	push   %eax
  8010d3:	56                   	push   %esi
  8010d4:	6a 00                	push   $0x0
  8010d6:	57                   	push   %edi
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 6a fb ff ff       	call   800c48 <sys_page_map>
  8010de:	89 c3                	mov    %eax,%ebx
  8010e0:	83 c4 20             	add    $0x20,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 33                	js     80111a <dup+0xcd>
		goto err;

	return newfdnum;
  8010e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ea:	89 d8                	mov    %ebx,%eax
  8010ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801103:	50                   	push   %eax
  801104:	ff 75 d4             	push   -0x2c(%ebp)
  801107:	6a 00                	push   $0x0
  801109:	53                   	push   %ebx
  80110a:	6a 00                	push   $0x0
  80110c:	e8 37 fb ff ff       	call   800c48 <sys_page_map>
  801111:	89 c3                	mov    %eax,%ebx
  801113:	83 c4 20             	add    $0x20,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	79 a4                	jns    8010be <dup+0x71>
	sys_page_unmap(0, newfd);
  80111a:	83 ec 08             	sub    $0x8,%esp
  80111d:	56                   	push   %esi
  80111e:	6a 00                	push   $0x0
  801120:	e8 65 fb ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801125:	83 c4 08             	add    $0x8,%esp
  801128:	ff 75 d4             	push   -0x2c(%ebp)
  80112b:	6a 00                	push   $0x0
  80112d:	e8 58 fb ff ff       	call   800c8a <sys_page_unmap>
	return r;
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	eb b3                	jmp    8010ea <dup+0x9d>

00801137 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 18             	sub    $0x18,%esp
  80113f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	56                   	push   %esi
  801147:	e8 82 fd ff ff       	call   800ece <fd_lookup>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 3c                	js     80118f <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801153:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115c:	50                   	push   %eax
  80115d:	ff 33                	push   (%ebx)
  80115f:	e8 ba fd ff ff       	call   800f1e <dev_lookup>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 24                	js     80118f <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80116b:	8b 43 08             	mov    0x8(%ebx),%eax
  80116e:	83 e0 03             	and    $0x3,%eax
  801171:	83 f8 01             	cmp    $0x1,%eax
  801174:	74 20                	je     801196 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801176:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801179:	8b 40 08             	mov    0x8(%eax),%eax
  80117c:	85 c0                	test   %eax,%eax
  80117e:	74 37                	je     8011b7 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	ff 75 10             	push   0x10(%ebp)
  801186:	ff 75 0c             	push   0xc(%ebp)
  801189:	53                   	push   %ebx
  80118a:	ff d0                	call   *%eax
  80118c:	83 c4 10             	add    $0x10,%esp
}
  80118f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801196:	a1 00 40 80 00       	mov    0x804000,%eax
  80119b:	8b 40 48             	mov    0x48(%eax),%eax
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	56                   	push   %esi
  8011a2:	50                   	push   %eax
  8011a3:	68 cd 26 80 00       	push   $0x8026cd
  8011a8:	e8 82 f0 ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b5:	eb d8                	jmp    80118f <read+0x58>
		return -E_NOT_SUPP;
  8011b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011bc:	eb d1                	jmp    80118f <read+0x58>

008011be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	eb 02                	jmp    8011d6 <readn+0x18>
  8011d4:	01 c3                	add    %eax,%ebx
  8011d6:	39 f3                	cmp    %esi,%ebx
  8011d8:	73 21                	jae    8011fb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	89 f0                	mov    %esi,%eax
  8011df:	29 d8                	sub    %ebx,%eax
  8011e1:	50                   	push   %eax
  8011e2:	89 d8                	mov    %ebx,%eax
  8011e4:	03 45 0c             	add    0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	57                   	push   %edi
  8011e9:	e8 49 ff ff ff       	call   801137 <read>
		if (m < 0)
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 04                	js     8011f9 <readn+0x3b>
			return m;
		if (m == 0)
  8011f5:	75 dd                	jne    8011d4 <readn+0x16>
  8011f7:	eb 02                	jmp    8011fb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801200:	5b                   	pop    %ebx
  801201:	5e                   	pop    %esi
  801202:	5f                   	pop    %edi
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 18             	sub    $0x18,%esp
  80120d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801210:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	53                   	push   %ebx
  801215:	e8 b4 fc ff ff       	call   800ece <fd_lookup>
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 37                	js     801258 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801221:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	ff 36                	push   (%esi)
  80122d:	e8 ec fc ff ff       	call   800f1e <dev_lookup>
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 1f                	js     801258 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801239:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80123d:	74 20                	je     80125f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	8b 40 0c             	mov    0xc(%eax),%eax
  801245:	85 c0                	test   %eax,%eax
  801247:	74 37                	je     801280 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	ff 75 10             	push   0x10(%ebp)
  80124f:	ff 75 0c             	push   0xc(%ebp)
  801252:	56                   	push   %esi
  801253:	ff d0                	call   *%eax
  801255:	83 c4 10             	add    $0x10,%esp
}
  801258:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80125f:	a1 00 40 80 00       	mov    0x804000,%eax
  801264:	8b 40 48             	mov    0x48(%eax),%eax
  801267:	83 ec 04             	sub    $0x4,%esp
  80126a:	53                   	push   %ebx
  80126b:	50                   	push   %eax
  80126c:	68 e9 26 80 00       	push   $0x8026e9
  801271:	e8 b9 ef ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127e:	eb d8                	jmp    801258 <write+0x53>
		return -E_NOT_SUPP;
  801280:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801285:	eb d1                	jmp    801258 <write+0x53>

00801287 <seek>:

int
seek(int fdnum, off_t offset)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	ff 75 08             	push   0x8(%ebp)
  801294:	e8 35 fc ff ff       	call   800ece <fd_lookup>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 0e                	js     8012ae <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 18             	sub    $0x18,%esp
  8012b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	53                   	push   %ebx
  8012c0:	e8 09 fc ff ff       	call   800ece <fd_lookup>
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 34                	js     801300 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	ff 36                	push   (%esi)
  8012d8:	e8 41 fc ff ff       	call   800f1e <dev_lookup>
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 1c                	js     801300 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e4:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012e8:	74 1d                	je     801307 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ed:	8b 40 18             	mov    0x18(%eax),%eax
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	74 34                	je     801328 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	ff 75 0c             	push   0xc(%ebp)
  8012fa:	56                   	push   %esi
  8012fb:	ff d0                	call   *%eax
  8012fd:	83 c4 10             	add    $0x10,%esp
}
  801300:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    
			thisenv->env_id, fdnum);
  801307:	a1 00 40 80 00       	mov    0x804000,%eax
  80130c:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80130f:	83 ec 04             	sub    $0x4,%esp
  801312:	53                   	push   %ebx
  801313:	50                   	push   %eax
  801314:	68 ac 26 80 00       	push   $0x8026ac
  801319:	e8 11 ef ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801326:	eb d8                	jmp    801300 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801328:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80132d:	eb d1                	jmp    801300 <ftruncate+0x50>

0080132f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 18             	sub    $0x18,%esp
  801337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	ff 75 08             	push   0x8(%ebp)
  801341:	e8 88 fb ff ff       	call   800ece <fd_lookup>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 49                	js     801396 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	ff 36                	push   (%esi)
  801359:	e8 c0 fb ff ff       	call   800f1e <dev_lookup>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 31                	js     801396 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801368:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80136c:	74 2f                	je     80139d <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80136e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801371:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801378:	00 00 00 
	stat->st_isdir = 0;
  80137b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801382:	00 00 00 
	stat->st_dev = dev;
  801385:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	53                   	push   %ebx
  80138f:	56                   	push   %esi
  801390:	ff 50 14             	call   *0x14(%eax)
  801393:	83 c4 10             	add    $0x10,%esp
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
		return -E_NOT_SUPP;
  80139d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a2:	eb f2                	jmp    801396 <fstat+0x67>

008013a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	6a 00                	push   $0x0
  8013ae:	ff 75 08             	push   0x8(%ebp)
  8013b1:	e8 e4 01 00 00       	call   80159a <open>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 1b                	js     8013da <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	ff 75 0c             	push   0xc(%ebp)
  8013c5:	50                   	push   %eax
  8013c6:	e8 64 ff ff ff       	call   80132f <fstat>
  8013cb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cd:	89 1c 24             	mov    %ebx,(%esp)
  8013d0:	e8 26 fc ff ff       	call   800ffb <close>
	return r;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	89 f3                	mov    %esi,%ebx
}
  8013da:	89 d8                	mov    %ebx,%eax
  8013dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
  8013e8:	89 c6                	mov    %eax,%esi
  8013ea:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ec:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013f3:	74 27                	je     80141c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f5:	6a 07                	push   $0x7
  8013f7:	68 00 50 80 00       	push   $0x805000
  8013fc:	56                   	push   %esi
  8013fd:	ff 35 00 60 80 00    	push   0x806000
  801403:	e8 c4 0b 00 00       	call   801fcc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801408:	83 c4 0c             	add    $0xc,%esp
  80140b:	6a 00                	push   $0x0
  80140d:	53                   	push   %ebx
  80140e:	6a 00                	push   $0x0
  801410:	e8 50 0b 00 00       	call   801f65 <ipc_recv>
}
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	6a 01                	push   $0x1
  801421:	e8 fa 0b 00 00       	call   802020 <ipc_find_env>
  801426:	a3 00 60 80 00       	mov    %eax,0x806000
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	eb c5                	jmp    8013f5 <fsipc+0x12>

00801430 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801441:	8b 45 0c             	mov    0xc(%ebp),%eax
  801444:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	b8 02 00 00 00       	mov    $0x2,%eax
  801453:	e8 8b ff ff ff       	call   8013e3 <fsipc>
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <devfile_flush>:
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801460:	8b 45 08             	mov    0x8(%ebp),%eax
  801463:	8b 40 0c             	mov    0xc(%eax),%eax
  801466:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 06 00 00 00       	mov    $0x6,%eax
  801475:	e8 69 ff ff ff       	call   8013e3 <fsipc>
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_stat>:
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801486:	8b 45 08             	mov    0x8(%ebp),%eax
  801489:	8b 40 0c             	mov    0xc(%eax),%eax
  80148c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
  801496:	b8 05 00 00 00       	mov    $0x5,%eax
  80149b:	e8 43 ff ff ff       	call   8013e3 <fsipc>
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 2c                	js     8014d0 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	68 00 50 80 00       	push   $0x805000
  8014ac:	53                   	push   %ebx
  8014ad:	e8 57 f3 ff ff       	call   800809 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <devfile_write>:
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	8b 45 10             	mov    0x10(%ebp),%eax
  8014de:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014e3:	39 d0                	cmp    %edx,%eax
  8014e5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ee:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014f4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014f9:	50                   	push   %eax
  8014fa:	ff 75 0c             	push   0xc(%ebp)
  8014fd:	68 08 50 80 00       	push   $0x805008
  801502:	e8 98 f4 ff ff       	call   80099f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 04 00 00 00       	mov    $0x4,%eax
  801511:	e8 cd fe ff ff       	call   8013e3 <fsipc>
}
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <devfile_read>:
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	8b 40 0c             	mov    0xc(%eax),%eax
  801526:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80152b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 03 00 00 00       	mov    $0x3,%eax
  80153b:	e8 a3 fe ff ff       	call   8013e3 <fsipc>
  801540:	89 c3                	mov    %eax,%ebx
  801542:	85 c0                	test   %eax,%eax
  801544:	78 1f                	js     801565 <devfile_read+0x4d>
	assert(r <= n);
  801546:	39 f0                	cmp    %esi,%eax
  801548:	77 24                	ja     80156e <devfile_read+0x56>
	assert(r <= PGSIZE);
  80154a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80154f:	7f 33                	jg     801584 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801551:	83 ec 04             	sub    $0x4,%esp
  801554:	50                   	push   %eax
  801555:	68 00 50 80 00       	push   $0x805000
  80155a:	ff 75 0c             	push   0xc(%ebp)
  80155d:	e8 3d f4 ff ff       	call   80099f <memmove>
	return r;
  801562:	83 c4 10             	add    $0x10,%esp
}
  801565:	89 d8                	mov    %ebx,%eax
  801567:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    
	assert(r <= n);
  80156e:	68 1c 27 80 00       	push   $0x80271c
  801573:	68 23 27 80 00       	push   $0x802723
  801578:	6a 7c                	push   $0x7c
  80157a:	68 38 27 80 00       	push   $0x802738
  80157f:	e8 d0 eb ff ff       	call   800154 <_panic>
	assert(r <= PGSIZE);
  801584:	68 43 27 80 00       	push   $0x802743
  801589:	68 23 27 80 00       	push   $0x802723
  80158e:	6a 7d                	push   $0x7d
  801590:	68 38 27 80 00       	push   $0x802738
  801595:	e8 ba eb ff ff       	call   800154 <_panic>

0080159a <open>:
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
  80159f:	83 ec 1c             	sub    $0x1c,%esp
  8015a2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015a5:	56                   	push   %esi
  8015a6:	e8 23 f2 ff ff       	call   8007ce <strlen>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b3:	7f 6c                	jg     801621 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	e8 bd f8 ff ff       	call   800e7e <fd_alloc>
  8015c1:	89 c3                	mov    %eax,%ebx
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 3c                	js     801606 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	56                   	push   %esi
  8015ce:	68 00 50 80 00       	push   $0x805000
  8015d3:	e8 31 f2 ff ff       	call   800809 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015db:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e8:	e8 f6 fd ff ff       	call   8013e3 <fsipc>
  8015ed:	89 c3                	mov    %eax,%ebx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 19                	js     80160f <open+0x75>
	return fd2num(fd);
  8015f6:	83 ec 0c             	sub    $0xc,%esp
  8015f9:	ff 75 f4             	push   -0xc(%ebp)
  8015fc:	e8 56 f8 ff ff       	call   800e57 <fd2num>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 10             	add    $0x10,%esp
}
  801606:	89 d8                	mov    %ebx,%eax
  801608:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    
		fd_close(fd, 0);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	6a 00                	push   $0x0
  801614:	ff 75 f4             	push   -0xc(%ebp)
  801617:	e8 58 f9 ff ff       	call   800f74 <fd_close>
		return r;
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb e5                	jmp    801606 <open+0x6c>
		return -E_BAD_PATH;
  801621:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801626:	eb de                	jmp    801606 <open+0x6c>

00801628 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162e:	ba 00 00 00 00       	mov    $0x0,%edx
  801633:	b8 08 00 00 00       	mov    $0x8,%eax
  801638:	e8 a6 fd ff ff       	call   8013e3 <fsipc>
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801645:	68 4f 27 80 00       	push   $0x80274f
  80164a:	ff 75 0c             	push   0xc(%ebp)
  80164d:	e8 b7 f1 ff ff       	call   800809 <strcpy>
	return 0;
}
  801652:	b8 00 00 00 00       	mov    $0x0,%eax
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <devsock_close>:
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	53                   	push   %ebx
  80165d:	83 ec 10             	sub    $0x10,%esp
  801660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801663:	53                   	push   %ebx
  801664:	e8 f0 09 00 00       	call   802059 <pageref>
  801669:	89 c2                	mov    %eax,%edx
  80166b:	83 c4 10             	add    $0x10,%esp
		return 0;
  80166e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801673:	83 fa 01             	cmp    $0x1,%edx
  801676:	74 05                	je     80167d <devsock_close+0x24>
}
  801678:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	ff 73 0c             	push   0xc(%ebx)
  801683:	e8 b7 02 00 00       	call   80193f <nsipc_close>
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb eb                	jmp    801678 <devsock_close+0x1f>

0080168d <devsock_write>:
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801693:	6a 00                	push   $0x0
  801695:	ff 75 10             	push   0x10(%ebp)
  801698:	ff 75 0c             	push   0xc(%ebp)
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	ff 70 0c             	push   0xc(%eax)
  8016a1:	e8 79 03 00 00       	call   801a1f <nsipc_send>
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <devsock_read>:
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016ae:	6a 00                	push   $0x0
  8016b0:	ff 75 10             	push   0x10(%ebp)
  8016b3:	ff 75 0c             	push   0xc(%ebp)
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	ff 70 0c             	push   0xc(%eax)
  8016bc:	e8 ef 02 00 00       	call   8019b0 <nsipc_recv>
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <fd2sockid>:
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016c9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016cc:	52                   	push   %edx
  8016cd:	50                   	push   %eax
  8016ce:	e8 fb f7 ff ff       	call   800ece <fd_lookup>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 10                	js     8016ea <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016dd:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016e3:	39 08                	cmp    %ecx,(%eax)
  8016e5:	75 05                	jne    8016ec <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016e7:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f1:	eb f7                	jmp    8016ea <fd2sockid+0x27>

008016f3 <alloc_sockfd>:
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 1c             	sub    $0x1c,%esp
  8016fb:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	e8 78 f7 ff ff       	call   800e7e <fd_alloc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 43                	js     801752 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80170f:	83 ec 04             	sub    $0x4,%esp
  801712:	68 07 04 00 00       	push   $0x407
  801717:	ff 75 f4             	push   -0xc(%ebp)
  80171a:	6a 00                	push   $0x0
  80171c:	e8 e4 f4 ff ff       	call   800c05 <sys_page_alloc>
  801721:	89 c3                	mov    %eax,%ebx
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	78 28                	js     801752 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801733:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801738:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80173f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	50                   	push   %eax
  801746:	e8 0c f7 ff ff       	call   800e57 <fd2num>
  80174b:	89 c3                	mov    %eax,%ebx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	eb 0c                	jmp    80175e <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	56                   	push   %esi
  801756:	e8 e4 01 00 00       	call   80193f <nsipc_close>
		return r;
  80175b:	83 c4 10             	add    $0x10,%esp
}
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <accept>:
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80176d:	8b 45 08             	mov    0x8(%ebp),%eax
  801770:	e8 4e ff ff ff       	call   8016c3 <fd2sockid>
  801775:	85 c0                	test   %eax,%eax
  801777:	78 1b                	js     801794 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	ff 75 10             	push   0x10(%ebp)
  80177f:	ff 75 0c             	push   0xc(%ebp)
  801782:	50                   	push   %eax
  801783:	e8 0e 01 00 00       	call   801896 <nsipc_accept>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 05                	js     801794 <accept+0x2d>
	return alloc_sockfd(r);
  80178f:	e8 5f ff ff ff       	call   8016f3 <alloc_sockfd>
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <bind>:
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	e8 1f ff ff ff       	call   8016c3 <fd2sockid>
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 12                	js     8017ba <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	ff 75 10             	push   0x10(%ebp)
  8017ae:	ff 75 0c             	push   0xc(%ebp)
  8017b1:	50                   	push   %eax
  8017b2:	e8 31 01 00 00       	call   8018e8 <nsipc_bind>
  8017b7:	83 c4 10             	add    $0x10,%esp
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <shutdown>:
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	e8 f9 fe ff ff       	call   8016c3 <fd2sockid>
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 0f                	js     8017dd <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	ff 75 0c             	push   0xc(%ebp)
  8017d4:	50                   	push   %eax
  8017d5:	e8 43 01 00 00       	call   80191d <nsipc_shutdown>
  8017da:	83 c4 10             	add    $0x10,%esp
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <connect>:
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	e8 d6 fe ff ff       	call   8016c3 <fd2sockid>
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 12                	js     801803 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8017f1:	83 ec 04             	sub    $0x4,%esp
  8017f4:	ff 75 10             	push   0x10(%ebp)
  8017f7:	ff 75 0c             	push   0xc(%ebp)
  8017fa:	50                   	push   %eax
  8017fb:	e8 59 01 00 00       	call   801959 <nsipc_connect>
  801800:	83 c4 10             	add    $0x10,%esp
}
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <listen>:
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	e8 b0 fe ff ff       	call   8016c3 <fd2sockid>
  801813:	85 c0                	test   %eax,%eax
  801815:	78 0f                	js     801826 <listen+0x21>
	return nsipc_listen(r, backlog);
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	ff 75 0c             	push   0xc(%ebp)
  80181d:	50                   	push   %eax
  80181e:	e8 6b 01 00 00       	call   80198e <nsipc_listen>
  801823:	83 c4 10             	add    $0x10,%esp
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <socket>:

int
socket(int domain, int type, int protocol)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80182e:	ff 75 10             	push   0x10(%ebp)
  801831:	ff 75 0c             	push   0xc(%ebp)
  801834:	ff 75 08             	push   0x8(%ebp)
  801837:	e8 41 02 00 00       	call   801a7d <nsipc_socket>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 05                	js     801848 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801843:	e8 ab fe ff ff       	call   8016f3 <alloc_sockfd>
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	53                   	push   %ebx
  80184e:	83 ec 04             	sub    $0x4,%esp
  801851:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801853:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80185a:	74 26                	je     801882 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80185c:	6a 07                	push   $0x7
  80185e:	68 00 70 80 00       	push   $0x807000
  801863:	53                   	push   %ebx
  801864:	ff 35 00 80 80 00    	push   0x808000
  80186a:	e8 5d 07 00 00       	call   801fcc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80186f:	83 c4 0c             	add    $0xc,%esp
  801872:	6a 00                	push   $0x0
  801874:	6a 00                	push   $0x0
  801876:	6a 00                	push   $0x0
  801878:	e8 e8 06 00 00       	call   801f65 <ipc_recv>
}
  80187d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801880:	c9                   	leave  
  801881:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	6a 02                	push   $0x2
  801887:	e8 94 07 00 00       	call   802020 <ipc_find_env>
  80188c:	a3 00 80 80 00       	mov    %eax,0x808000
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	eb c6                	jmp    80185c <nsipc+0x12>

00801896 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018a6:	8b 06                	mov    (%esi),%eax
  8018a8:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b2:	e8 93 ff ff ff       	call   80184a <nsipc>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	79 09                	jns    8018c6 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8018bd:	89 d8                	mov    %ebx,%eax
  8018bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	ff 35 10 70 80 00    	push   0x807010
  8018cf:	68 00 70 80 00       	push   $0x807000
  8018d4:	ff 75 0c             	push   0xc(%ebp)
  8018d7:	e8 c3 f0 ff ff       	call   80099f <memmove>
		*addrlen = ret->ret_addrlen;
  8018dc:	a1 10 70 80 00       	mov    0x807010,%eax
  8018e1:	89 06                	mov    %eax,(%esi)
  8018e3:	83 c4 10             	add    $0x10,%esp
	return r;
  8018e6:	eb d5                	jmp    8018bd <nsipc_accept+0x27>

008018e8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 08             	sub    $0x8,%esp
  8018ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018fa:	53                   	push   %ebx
  8018fb:	ff 75 0c             	push   0xc(%ebp)
  8018fe:	68 04 70 80 00       	push   $0x807004
  801903:	e8 97 f0 ff ff       	call   80099f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801908:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80190e:	b8 02 00 00 00       	mov    $0x2,%eax
  801913:	e8 32 ff ff ff       	call   80184a <nsipc>
}
  801918:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801933:	b8 03 00 00 00       	mov    $0x3,%eax
  801938:	e8 0d ff ff ff       	call   80184a <nsipc>
}
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <nsipc_close>:

int
nsipc_close(int s)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80194d:	b8 04 00 00 00       	mov    $0x4,%eax
  801952:	e8 f3 fe ff ff       	call   80184a <nsipc>
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	53                   	push   %ebx
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80196b:	53                   	push   %ebx
  80196c:	ff 75 0c             	push   0xc(%ebp)
  80196f:	68 04 70 80 00       	push   $0x807004
  801974:	e8 26 f0 ff ff       	call   80099f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801979:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80197f:	b8 05 00 00 00       	mov    $0x5,%eax
  801984:	e8 c1 fe ff ff       	call   80184a <nsipc>
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8019a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a9:	e8 9c fe ff ff       	call   80184a <nsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
  8019b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8019c0:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8019c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c9:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019ce:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d3:	e8 72 fe ff ff       	call   80184a <nsipc>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 22                	js     801a00 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8019de:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019e3:	39 c6                	cmp    %eax,%esi
  8019e5:	0f 4e c6             	cmovle %esi,%eax
  8019e8:	39 c3                	cmp    %eax,%ebx
  8019ea:	7f 1d                	jg     801a09 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019ec:	83 ec 04             	sub    $0x4,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	68 00 70 80 00       	push   $0x807000
  8019f5:	ff 75 0c             	push   0xc(%ebp)
  8019f8:	e8 a2 ef ff ff       	call   80099f <memmove>
  8019fd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a00:	89 d8                	mov    %ebx,%eax
  801a02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a09:	68 5b 27 80 00       	push   $0x80275b
  801a0e:	68 23 27 80 00       	push   $0x802723
  801a13:	6a 62                	push   $0x62
  801a15:	68 70 27 80 00       	push   $0x802770
  801a1a:	e8 35 e7 ff ff       	call   800154 <_panic>

00801a1f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	53                   	push   %ebx
  801a23:	83 ec 04             	sub    $0x4,%esp
  801a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a31:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a37:	7f 2e                	jg     801a67 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a39:	83 ec 04             	sub    $0x4,%esp
  801a3c:	53                   	push   %ebx
  801a3d:	ff 75 0c             	push   0xc(%ebp)
  801a40:	68 0c 70 80 00       	push   $0x80700c
  801a45:	e8 55 ef ff ff       	call   80099f <memmove>
	nsipcbuf.send.req_size = size;
  801a4a:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801a50:	8b 45 14             	mov    0x14(%ebp),%eax
  801a53:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801a58:	b8 08 00 00 00       	mov    $0x8,%eax
  801a5d:	e8 e8 fd ff ff       	call   80184a <nsipc>
}
  801a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    
	assert(size < 1600);
  801a67:	68 7c 27 80 00       	push   $0x80277c
  801a6c:	68 23 27 80 00       	push   $0x802723
  801a71:	6a 6d                	push   $0x6d
  801a73:	68 70 27 80 00       	push   $0x802770
  801a78:	e8 d7 e6 ff ff       	call   800154 <_panic>

00801a7d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8e:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801a93:	8b 45 10             	mov    0x10(%ebp),%eax
  801a96:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801a9b:	b8 09 00 00 00       	mov    $0x9,%eax
  801aa0:	e8 a5 fd ff ff       	call   80184a <nsipc>
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	ff 75 08             	push   0x8(%ebp)
  801ab5:	e8 ad f3 ff ff       	call   800e67 <fd2data>
  801aba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801abc:	83 c4 08             	add    $0x8,%esp
  801abf:	68 88 27 80 00       	push   $0x802788
  801ac4:	53                   	push   %ebx
  801ac5:	e8 3f ed ff ff       	call   800809 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aca:	8b 46 04             	mov    0x4(%esi),%eax
  801acd:	2b 06                	sub    (%esi),%eax
  801acf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801adc:	00 00 00 
	stat->st_dev = &devpipe;
  801adf:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ae6:	30 80 00 
	return 0;
}
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	53                   	push   %ebx
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aff:	53                   	push   %ebx
  801b00:	6a 00                	push   $0x0
  801b02:	e8 83 f1 ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b07:	89 1c 24             	mov    %ebx,(%esp)
  801b0a:	e8 58 f3 ff ff       	call   800e67 <fd2data>
  801b0f:	83 c4 08             	add    $0x8,%esp
  801b12:	50                   	push   %eax
  801b13:	6a 00                	push   $0x0
  801b15:	e8 70 f1 ff ff       	call   800c8a <sys_page_unmap>
}
  801b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <_pipeisclosed>:
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	57                   	push   %edi
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	83 ec 1c             	sub    $0x1c,%esp
  801b28:	89 c7                	mov    %eax,%edi
  801b2a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b2c:	a1 00 40 80 00       	mov    0x804000,%eax
  801b31:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	57                   	push   %edi
  801b38:	e8 1c 05 00 00       	call   802059 <pageref>
  801b3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b40:	89 34 24             	mov    %esi,(%esp)
  801b43:	e8 11 05 00 00       	call   802059 <pageref>
		nn = thisenv->env_runs;
  801b48:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b4e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	39 cb                	cmp    %ecx,%ebx
  801b56:	74 1b                	je     801b73 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b58:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b5b:	75 cf                	jne    801b2c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b5d:	8b 42 58             	mov    0x58(%edx),%eax
  801b60:	6a 01                	push   $0x1
  801b62:	50                   	push   %eax
  801b63:	53                   	push   %ebx
  801b64:	68 8f 27 80 00       	push   $0x80278f
  801b69:	e8 c1 e6 ff ff       	call   80022f <cprintf>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	eb b9                	jmp    801b2c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b73:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b76:	0f 94 c0             	sete   %al
  801b79:	0f b6 c0             	movzbl %al,%eax
}
  801b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <devpipe_write>:
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 28             	sub    $0x28,%esp
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b90:	56                   	push   %esi
  801b91:	e8 d1 f2 ff ff       	call   800e67 <fd2data>
  801b96:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba3:	75 09                	jne    801bae <devpipe_write+0x2a>
	return i;
  801ba5:	89 f8                	mov    %edi,%eax
  801ba7:	eb 23                	jmp    801bcc <devpipe_write+0x48>
			sys_yield();
  801ba9:	e8 38 f0 ff ff       	call   800be6 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bae:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb1:	8b 0b                	mov    (%ebx),%ecx
  801bb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb6:	39 d0                	cmp    %edx,%eax
  801bb8:	72 1a                	jb     801bd4 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801bba:	89 da                	mov    %ebx,%edx
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	e8 5c ff ff ff       	call   801b1f <_pipeisclosed>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	74 e2                	je     801ba9 <devpipe_write+0x25>
				return 0;
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5f                   	pop    %edi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bdb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bde:	89 c2                	mov    %eax,%edx
  801be0:	c1 fa 1f             	sar    $0x1f,%edx
  801be3:	89 d1                	mov    %edx,%ecx
  801be5:	c1 e9 1b             	shr    $0x1b,%ecx
  801be8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801beb:	83 e2 1f             	and    $0x1f,%edx
  801bee:	29 ca                	sub    %ecx,%edx
  801bf0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bf4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf8:	83 c0 01             	add    $0x1,%eax
  801bfb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bfe:	83 c7 01             	add    $0x1,%edi
  801c01:	eb 9d                	jmp    801ba0 <devpipe_write+0x1c>

00801c03 <devpipe_read>:
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	57                   	push   %edi
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	83 ec 18             	sub    $0x18,%esp
  801c0c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c0f:	57                   	push   %edi
  801c10:	e8 52 f2 ff ff       	call   800e67 <fd2data>
  801c15:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	be 00 00 00 00       	mov    $0x0,%esi
  801c1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c22:	75 13                	jne    801c37 <devpipe_read+0x34>
	return i;
  801c24:	89 f0                	mov    %esi,%eax
  801c26:	eb 02                	jmp    801c2a <devpipe_read+0x27>
				return i;
  801c28:	89 f0                	mov    %esi,%eax
}
  801c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
			sys_yield();
  801c32:	e8 af ef ff ff       	call   800be6 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c37:	8b 03                	mov    (%ebx),%eax
  801c39:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c3c:	75 18                	jne    801c56 <devpipe_read+0x53>
			if (i > 0)
  801c3e:	85 f6                	test   %esi,%esi
  801c40:	75 e6                	jne    801c28 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c42:	89 da                	mov    %ebx,%edx
  801c44:	89 f8                	mov    %edi,%eax
  801c46:	e8 d4 fe ff ff       	call   801b1f <_pipeisclosed>
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	74 e3                	je     801c32 <devpipe_read+0x2f>
				return 0;
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c54:	eb d4                	jmp    801c2a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c56:	99                   	cltd   
  801c57:	c1 ea 1b             	shr    $0x1b,%edx
  801c5a:	01 d0                	add    %edx,%eax
  801c5c:	83 e0 1f             	and    $0x1f,%eax
  801c5f:	29 d0                	sub    %edx,%eax
  801c61:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c69:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c6c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c6f:	83 c6 01             	add    $0x1,%esi
  801c72:	eb ab                	jmp    801c1f <devpipe_read+0x1c>

00801c74 <pipe>:
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	e8 f9 f1 ff ff       	call   800e7e <fd_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	0f 88 23 01 00 00    	js     801db5 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c92:	83 ec 04             	sub    $0x4,%esp
  801c95:	68 07 04 00 00       	push   $0x407
  801c9a:	ff 75 f4             	push   -0xc(%ebp)
  801c9d:	6a 00                	push   $0x0
  801c9f:	e8 61 ef ff ff       	call   800c05 <sys_page_alloc>
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	0f 88 04 01 00 00    	js     801db5 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	e8 c1 f1 ff ff       	call   800e7e <fd_alloc>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	0f 88 db 00 00 00    	js     801da5 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cca:	83 ec 04             	sub    $0x4,%esp
  801ccd:	68 07 04 00 00       	push   $0x407
  801cd2:	ff 75 f0             	push   -0x10(%ebp)
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 29 ef ff ff       	call   800c05 <sys_page_alloc>
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	0f 88 bc 00 00 00    	js     801da5 <pipe+0x131>
	va = fd2data(fd0);
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	ff 75 f4             	push   -0xc(%ebp)
  801cef:	e8 73 f1 ff ff       	call   800e67 <fd2data>
  801cf4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf6:	83 c4 0c             	add    $0xc,%esp
  801cf9:	68 07 04 00 00       	push   $0x407
  801cfe:	50                   	push   %eax
  801cff:	6a 00                	push   $0x0
  801d01:	e8 ff ee ff ff       	call   800c05 <sys_page_alloc>
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	0f 88 82 00 00 00    	js     801d95 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 f0             	push   -0x10(%ebp)
  801d19:	e8 49 f1 ff ff       	call   800e67 <fd2data>
  801d1e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d25:	50                   	push   %eax
  801d26:	6a 00                	push   $0x0
  801d28:	56                   	push   %esi
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 18 ef ff ff       	call   800c48 <sys_page_map>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	83 c4 20             	add    $0x20,%esp
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 4e                	js     801d87 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d39:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d41:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d46:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d4d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d50:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 f4             	push   -0xc(%ebp)
  801d62:	e8 f0 f0 ff ff       	call   800e57 <fd2num>
  801d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6c:	83 c4 04             	add    $0x4,%esp
  801d6f:	ff 75 f0             	push   -0x10(%ebp)
  801d72:	e8 e0 f0 ff ff       	call   800e57 <fd2num>
  801d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d85:	eb 2e                	jmp    801db5 <pipe+0x141>
	sys_page_unmap(0, va);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	56                   	push   %esi
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 f8 ee ff ff       	call   800c8a <sys_page_unmap>
  801d92:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	ff 75 f0             	push   -0x10(%ebp)
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 e8 ee ff ff       	call   800c8a <sys_page_unmap>
  801da2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	ff 75 f4             	push   -0xc(%ebp)
  801dab:	6a 00                	push   $0x0
  801dad:	e8 d8 ee ff ff       	call   800c8a <sys_page_unmap>
  801db2:	83 c4 10             	add    $0x10,%esp
}
  801db5:	89 d8                	mov    %ebx,%eax
  801db7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <pipeisclosed>:
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc7:	50                   	push   %eax
  801dc8:	ff 75 08             	push   0x8(%ebp)
  801dcb:	e8 fe f0 ff ff       	call   800ece <fd_lookup>
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	78 18                	js     801def <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	ff 75 f4             	push   -0xc(%ebp)
  801ddd:	e8 85 f0 ff ff       	call   800e67 <fd2data>
  801de2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de7:	e8 33 fd ff ff       	call   801b1f <_pipeisclosed>
  801dec:	83 c4 10             	add    $0x10,%esp
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801df1:	b8 00 00 00 00       	mov    $0x0,%eax
  801df6:	c3                   	ret    

00801df7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dfd:	68 a7 27 80 00       	push   $0x8027a7
  801e02:	ff 75 0c             	push   0xc(%ebp)
  801e05:	e8 ff e9 ff ff       	call   800809 <strcpy>
	return 0;
}
  801e0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    

00801e11 <devcons_write>:
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	57                   	push   %edi
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e1d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e22:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e28:	eb 2e                	jmp    801e58 <devcons_write+0x47>
		m = n - tot;
  801e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e2d:	29 f3                	sub    %esi,%ebx
  801e2f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e34:	39 c3                	cmp    %eax,%ebx
  801e36:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	53                   	push   %ebx
  801e3d:	89 f0                	mov    %esi,%eax
  801e3f:	03 45 0c             	add    0xc(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	57                   	push   %edi
  801e44:	e8 56 eb ff ff       	call   80099f <memmove>
		sys_cputs(buf, m);
  801e49:	83 c4 08             	add    $0x8,%esp
  801e4c:	53                   	push   %ebx
  801e4d:	57                   	push   %edi
  801e4e:	e8 f6 ec ff ff       	call   800b49 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e53:	01 de                	add    %ebx,%esi
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5b:	72 cd                	jb     801e2a <devcons_write+0x19>
}
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <devcons_read>:
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 08             	sub    $0x8,%esp
  801e6d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e76:	75 07                	jne    801e7f <devcons_read+0x18>
  801e78:	eb 1f                	jmp    801e99 <devcons_read+0x32>
		sys_yield();
  801e7a:	e8 67 ed ff ff       	call   800be6 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e7f:	e8 e3 ec ff ff       	call   800b67 <sys_cgetc>
  801e84:	85 c0                	test   %eax,%eax
  801e86:	74 f2                	je     801e7a <devcons_read+0x13>
	if (c < 0)
  801e88:	78 0f                	js     801e99 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e8a:	83 f8 04             	cmp    $0x4,%eax
  801e8d:	74 0c                	je     801e9b <devcons_read+0x34>
	*(char*)vbuf = c;
  801e8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e92:	88 02                	mov    %al,(%edx)
	return 1;
  801e94:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    
		return 0;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	eb f7                	jmp    801e99 <devcons_read+0x32>

00801ea2 <cputchar>:
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  801eab:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801eae:	6a 01                	push   $0x1
  801eb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	e8 90 ec ff ff       	call   800b49 <sys_cputs>
}
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <getchar>:
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ec4:	6a 01                	push   $0x1
  801ec6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 66 f2 ff ff       	call   801137 <read>
	if (r < 0)
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 06                	js     801ede <getchar+0x20>
	if (r < 1)
  801ed8:	74 06                	je     801ee0 <getchar+0x22>
	return c;
  801eda:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    
		return -E_EOF;
  801ee0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ee5:	eb f7                	jmp    801ede <getchar+0x20>

00801ee7 <iscons>:
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef0:	50                   	push   %eax
  801ef1:	ff 75 08             	push   0x8(%ebp)
  801ef4:	e8 d5 ef ff ff       	call   800ece <fd_lookup>
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 11                	js     801f11 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f03:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f09:	39 10                	cmp    %edx,(%eax)
  801f0b:	0f 94 c0             	sete   %al
  801f0e:	0f b6 c0             	movzbl %al,%eax
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <opencons>:
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	e8 5c ef ff ff       	call   800e7e <fd_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 3a                	js     801f63 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f29:	83 ec 04             	sub    $0x4,%esp
  801f2c:	68 07 04 00 00       	push   $0x407
  801f31:	ff 75 f4             	push   -0xc(%ebp)
  801f34:	6a 00                	push   $0x0
  801f36:	e8 ca ec ff ff       	call   800c05 <sys_page_alloc>
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 21                	js     801f63 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f45:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f4b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f57:	83 ec 0c             	sub    $0xc,%esp
  801f5a:	50                   	push   %eax
  801f5b:	e8 f7 ee ff ff       	call   800e57 <fd2num>
  801f60:	83 c4 10             	add    $0x10,%esp
}
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	56                   	push   %esi
  801f69:	53                   	push   %ebx
  801f6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f73:	85 c0                	test   %eax,%eax
  801f75:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f7a:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f7d:	83 ec 0c             	sub    $0xc,%esp
  801f80:	50                   	push   %eax
  801f81:	e8 2f ee ff ff       	call   800db5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	85 f6                	test   %esi,%esi
  801f8b:	74 14                	je     801fa1 <ipc_recv+0x3c>
  801f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 09                	js     801f9f <ipc_recv+0x3a>
  801f96:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f9c:	8b 52 74             	mov    0x74(%edx),%edx
  801f9f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801fa1:	85 db                	test   %ebx,%ebx
  801fa3:	74 14                	je     801fb9 <ipc_recv+0x54>
  801fa5:	ba 00 00 00 00       	mov    $0x0,%edx
  801faa:	85 c0                	test   %eax,%eax
  801fac:	78 09                	js     801fb7 <ipc_recv+0x52>
  801fae:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fb4:	8b 52 78             	mov    0x78(%edx),%edx
  801fb7:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 08                	js     801fc5 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801fbd:	a1 00 40 80 00       	mov    0x804000,%eax
  801fc2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	57                   	push   %edi
  801fd0:	56                   	push   %esi
  801fd1:	53                   	push   %ebx
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fde:	85 db                	test   %ebx,%ebx
  801fe0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fe5:	0f 44 d8             	cmove  %eax,%ebx
  801fe8:	eb 05                	jmp    801fef <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fea:	e8 f7 eb ff ff       	call   800be6 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801fef:	ff 75 14             	push   0x14(%ebp)
  801ff2:	53                   	push   %ebx
  801ff3:	56                   	push   %esi
  801ff4:	57                   	push   %edi
  801ff5:	e8 98 ed ff ff       	call   800d92 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802000:	74 e8                	je     801fea <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802002:	85 c0                	test   %eax,%eax
  802004:	78 08                	js     80200e <ipc_send+0x42>
	}while (r<0);

}
  802006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802009:	5b                   	pop    %ebx
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80200e:	50                   	push   %eax
  80200f:	68 b3 27 80 00       	push   $0x8027b3
  802014:	6a 3d                	push   $0x3d
  802016:	68 c7 27 80 00       	push   $0x8027c7
  80201b:	e8 34 e1 ff ff       	call   800154 <_panic>

00802020 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802026:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80202b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80202e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802034:	8b 52 50             	mov    0x50(%edx),%edx
  802037:	39 ca                	cmp    %ecx,%edx
  802039:	74 11                	je     80204c <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80203b:	83 c0 01             	add    $0x1,%eax
  80203e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802043:	75 e6                	jne    80202b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
  80204a:	eb 0b                	jmp    802057 <ipc_find_env+0x37>
			return envs[i].env_id;
  80204c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80204f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802054:	8b 40 48             	mov    0x48(%eax),%eax
}
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205f:	89 c2                	mov    %eax,%edx
  802061:	c1 ea 16             	shr    $0x16,%edx
  802064:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80206b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802070:	f6 c1 01             	test   $0x1,%cl
  802073:	74 1c                	je     802091 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802075:	c1 e8 0c             	shr    $0xc,%eax
  802078:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80207f:	a8 01                	test   $0x1,%al
  802081:	74 0e                	je     802091 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802083:	c1 e8 0c             	shr    $0xc,%eax
  802086:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80208d:	ef 
  80208e:	0f b7 d2             	movzwl %dx,%edx
}
  802091:	89 d0                	mov    %edx,%eax
  802093:	5d                   	pop    %ebp
  802094:	c3                   	ret    
  802095:	66 90                	xchg   %ax,%ax
  802097:	66 90                	xchg   %ax,%ax
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	f3 0f 1e fb          	endbr32 
  8020a4:	55                   	push   %ebp
  8020a5:	57                   	push   %edi
  8020a6:	56                   	push   %esi
  8020a7:	53                   	push   %ebx
  8020a8:	83 ec 1c             	sub    $0x1c,%esp
  8020ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	75 19                	jne    8020d8 <__udivdi3+0x38>
  8020bf:	39 f3                	cmp    %esi,%ebx
  8020c1:	76 4d                	jbe    802110 <__udivdi3+0x70>
  8020c3:	31 ff                	xor    %edi,%edi
  8020c5:	89 e8                	mov    %ebp,%eax
  8020c7:	89 f2                	mov    %esi,%edx
  8020c9:	f7 f3                	div    %ebx
  8020cb:	89 fa                	mov    %edi,%edx
  8020cd:	83 c4 1c             	add    $0x1c,%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
  8020d8:	39 f0                	cmp    %esi,%eax
  8020da:	76 14                	jbe    8020f0 <__udivdi3+0x50>
  8020dc:	31 ff                	xor    %edi,%edi
  8020de:	31 c0                	xor    %eax,%eax
  8020e0:	89 fa                	mov    %edi,%edx
  8020e2:	83 c4 1c             	add    $0x1c,%esp
  8020e5:	5b                   	pop    %ebx
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    
  8020ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f0:	0f bd f8             	bsr    %eax,%edi
  8020f3:	83 f7 1f             	xor    $0x1f,%edi
  8020f6:	75 48                	jne    802140 <__udivdi3+0xa0>
  8020f8:	39 f0                	cmp    %esi,%eax
  8020fa:	72 06                	jb     802102 <__udivdi3+0x62>
  8020fc:	31 c0                	xor    %eax,%eax
  8020fe:	39 eb                	cmp    %ebp,%ebx
  802100:	77 de                	ja     8020e0 <__udivdi3+0x40>
  802102:	b8 01 00 00 00       	mov    $0x1,%eax
  802107:	eb d7                	jmp    8020e0 <__udivdi3+0x40>
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d9                	mov    %ebx,%ecx
  802112:	85 db                	test   %ebx,%ebx
  802114:	75 0b                	jne    802121 <__udivdi3+0x81>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f3                	div    %ebx
  80211f:	89 c1                	mov    %eax,%ecx
  802121:	31 d2                	xor    %edx,%edx
  802123:	89 f0                	mov    %esi,%eax
  802125:	f7 f1                	div    %ecx
  802127:	89 c6                	mov    %eax,%esi
  802129:	89 e8                	mov    %ebp,%eax
  80212b:	89 f7                	mov    %esi,%edi
  80212d:	f7 f1                	div    %ecx
  80212f:	89 fa                	mov    %edi,%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 f9                	mov    %edi,%ecx
  802142:	ba 20 00 00 00       	mov    $0x20,%edx
  802147:	29 fa                	sub    %edi,%edx
  802149:	d3 e0                	shl    %cl,%eax
  80214b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80214f:	89 d1                	mov    %edx,%ecx
  802151:	89 d8                	mov    %ebx,%eax
  802153:	d3 e8                	shr    %cl,%eax
  802155:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802159:	09 c1                	or     %eax,%ecx
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e3                	shl    %cl,%ebx
  802165:	89 d1                	mov    %edx,%ecx
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 f9                	mov    %edi,%ecx
  80216b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80216f:	89 eb                	mov    %ebp,%ebx
  802171:	d3 e6                	shl    %cl,%esi
  802173:	89 d1                	mov    %edx,%ecx
  802175:	d3 eb                	shr    %cl,%ebx
  802177:	09 f3                	or     %esi,%ebx
  802179:	89 c6                	mov    %eax,%esi
  80217b:	89 f2                	mov    %esi,%edx
  80217d:	89 d8                	mov    %ebx,%eax
  80217f:	f7 74 24 08          	divl   0x8(%esp)
  802183:	89 d6                	mov    %edx,%esi
  802185:	89 c3                	mov    %eax,%ebx
  802187:	f7 64 24 0c          	mull   0xc(%esp)
  80218b:	39 d6                	cmp    %edx,%esi
  80218d:	72 19                	jb     8021a8 <__udivdi3+0x108>
  80218f:	89 f9                	mov    %edi,%ecx
  802191:	d3 e5                	shl    %cl,%ebp
  802193:	39 c5                	cmp    %eax,%ebp
  802195:	73 04                	jae    80219b <__udivdi3+0xfb>
  802197:	39 d6                	cmp    %edx,%esi
  802199:	74 0d                	je     8021a8 <__udivdi3+0x108>
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	31 ff                	xor    %edi,%edi
  80219f:	e9 3c ff ff ff       	jmp    8020e0 <__udivdi3+0x40>
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021ab:	31 ff                	xor    %edi,%edi
  8021ad:	e9 2e ff ff ff       	jmp    8020e0 <__udivdi3+0x40>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	f3 0f 1e fb          	endbr32 
  8021c4:	55                   	push   %ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 1c             	sub    $0x1c,%esp
  8021cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021db:	89 f0                	mov    %esi,%eax
  8021dd:	89 da                	mov    %ebx,%edx
  8021df:	85 ff                	test   %edi,%edi
  8021e1:	75 15                	jne    8021f8 <__umoddi3+0x38>
  8021e3:	39 dd                	cmp    %ebx,%ebp
  8021e5:	76 39                	jbe    802220 <__umoddi3+0x60>
  8021e7:	f7 f5                	div    %ebp
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	39 df                	cmp    %ebx,%edi
  8021fa:	77 f1                	ja     8021ed <__umoddi3+0x2d>
  8021fc:	0f bd cf             	bsr    %edi,%ecx
  8021ff:	83 f1 1f             	xor    $0x1f,%ecx
  802202:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802206:	75 40                	jne    802248 <__umoddi3+0x88>
  802208:	39 df                	cmp    %ebx,%edi
  80220a:	72 04                	jb     802210 <__umoddi3+0x50>
  80220c:	39 f5                	cmp    %esi,%ebp
  80220e:	77 dd                	ja     8021ed <__umoddi3+0x2d>
  802210:	89 da                	mov    %ebx,%edx
  802212:	89 f0                	mov    %esi,%eax
  802214:	29 e8                	sub    %ebp,%eax
  802216:	19 fa                	sbb    %edi,%edx
  802218:	eb d3                	jmp    8021ed <__umoddi3+0x2d>
  80221a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802220:	89 e9                	mov    %ebp,%ecx
  802222:	85 ed                	test   %ebp,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x71>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f5                	div    %ebp
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	89 d8                	mov    %ebx,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f1                	div    %ecx
  802237:	89 f0                	mov    %esi,%eax
  802239:	f7 f1                	div    %ecx
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	31 d2                	xor    %edx,%edx
  80223f:	eb ac                	jmp    8021ed <__umoddi3+0x2d>
  802241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802248:	8b 44 24 04          	mov    0x4(%esp),%eax
  80224c:	ba 20 00 00 00       	mov    $0x20,%edx
  802251:	29 c2                	sub    %eax,%edx
  802253:	89 c1                	mov    %eax,%ecx
  802255:	89 e8                	mov    %ebp,%eax
  802257:	d3 e7                	shl    %cl,%edi
  802259:	89 d1                	mov    %edx,%ecx
  80225b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80225f:	d3 e8                	shr    %cl,%eax
  802261:	89 c1                	mov    %eax,%ecx
  802263:	8b 44 24 04          	mov    0x4(%esp),%eax
  802267:	09 f9                	or     %edi,%ecx
  802269:	89 df                	mov    %ebx,%edi
  80226b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226f:	89 c1                	mov    %eax,%ecx
  802271:	d3 e5                	shl    %cl,%ebp
  802273:	89 d1                	mov    %edx,%ecx
  802275:	d3 ef                	shr    %cl,%edi
  802277:	89 c1                	mov    %eax,%ecx
  802279:	89 f0                	mov    %esi,%eax
  80227b:	d3 e3                	shl    %cl,%ebx
  80227d:	89 d1                	mov    %edx,%ecx
  80227f:	89 fa                	mov    %edi,%edx
  802281:	d3 e8                	shr    %cl,%eax
  802283:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802288:	09 d8                	or     %ebx,%eax
  80228a:	f7 74 24 08          	divl   0x8(%esp)
  80228e:	89 d3                	mov    %edx,%ebx
  802290:	d3 e6                	shl    %cl,%esi
  802292:	f7 e5                	mul    %ebp
  802294:	89 c7                	mov    %eax,%edi
  802296:	89 d1                	mov    %edx,%ecx
  802298:	39 d3                	cmp    %edx,%ebx
  80229a:	72 06                	jb     8022a2 <__umoddi3+0xe2>
  80229c:	75 0e                	jne    8022ac <__umoddi3+0xec>
  80229e:	39 c6                	cmp    %eax,%esi
  8022a0:	73 0a                	jae    8022ac <__umoddi3+0xec>
  8022a2:	29 e8                	sub    %ebp,%eax
  8022a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022a8:	89 d1                	mov    %edx,%ecx
  8022aa:	89 c7                	mov    %eax,%edi
  8022ac:	89 f5                	mov    %esi,%ebp
  8022ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022b2:	29 fd                	sub    %edi,%ebp
  8022b4:	19 cb                	sbb    %ecx,%ebx
  8022b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022bb:	89 d8                	mov    %ebx,%eax
  8022bd:	d3 e0                	shl    %cl,%eax
  8022bf:	89 f1                	mov    %esi,%ecx
  8022c1:	d3 ed                	shr    %cl,%ebp
  8022c3:	d3 eb                	shr    %cl,%ebx
  8022c5:	09 e8                	or     %ebp,%eax
  8022c7:	89 da                	mov    %ebx,%edx
  8022c9:	83 c4 1c             	add    $0x1c,%esp
  8022cc:	5b                   	pop    %ebx
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    
