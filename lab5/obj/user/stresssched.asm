
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 79 0b 00 00       	call   800bb6 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 9a 0e 00 00       	call   800ee3 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 7b 0b 00 00       	call   800bd5 <sys_yield>
		return;
  80005a:	eb 69                	jmp    8000c5 <umain+0x92>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005c:	89 f0                	mov    %esi,%eax
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	eb 02                	jmp    80006f <umain+0x3c>
		asm volatile("pause");
  80006d:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006f:	8b 50 54             	mov    0x54(%eax),%edx
  800072:	85 d2                	test   %edx,%edx
  800074:	75 f7                	jne    80006d <umain+0x3a>
  800076:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007b:	e8 55 0b 00 00       	call   800bd5 <sys_yield>
  800080:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800085:	a1 00 40 80 00       	mov    0x804000,%eax
  80008a:	83 c0 01             	add    $0x1,%eax
  80008d:	a3 00 40 80 00       	mov    %eax,0x804000
		for (j = 0; j < 10000; j++)
  800092:	83 ea 01             	sub    $0x1,%edx
  800095:	75 ee                	jne    800085 <umain+0x52>
	for (i = 0; i < 10; i++) {
  800097:	83 eb 01             	sub    $0x1,%ebx
  80009a:	75 df                	jne    80007b <umain+0x48>
	}

	if (counter != 10*10000)
  80009c:	a1 00 40 80 00       	mov    0x804000,%eax
  8000a1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000a6:	75 24                	jne    8000cc <umain+0x99>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ad:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b0:	8b 40 48             	mov    0x48(%eax),%eax
  8000b3:	83 ec 04             	sub    $0x4,%esp
  8000b6:	52                   	push   %edx
  8000b7:	50                   	push   %eax
  8000b8:	68 5b 21 80 00       	push   $0x80215b
  8000bd:	e8 5c 01 00 00       	call   80021e <cprintf>
  8000c2:	83 c4 10             	add    $0x10,%esp

}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000cc:	a1 00 40 80 00       	mov    0x804000,%eax
  8000d1:	50                   	push   %eax
  8000d2:	68 20 21 80 00       	push   $0x802120
  8000d7:	6a 21                	push   $0x21
  8000d9:	68 48 21 80 00       	push   $0x802148
  8000de:	e8 60 00 00 00       	call   800143 <_panic>

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 c3 0a 00 00       	call   800bb6 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 19 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012f:	e8 fb 10 00 00       	call   80122f <close_all>
	sys_env_destroy(0);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	6a 00                	push   $0x0
  800139:	e8 37 0a 00 00       	call   800b75 <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	56                   	push   %esi
  800147:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800148:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800151:	e8 60 0a 00 00       	call   800bb6 <sys_getenvid>
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	ff 75 0c             	push   0xc(%ebp)
  80015c:	ff 75 08             	push   0x8(%ebp)
  80015f:	56                   	push   %esi
  800160:	50                   	push   %eax
  800161:	68 84 21 80 00       	push   $0x802184
  800166:	e8 b3 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016b:	83 c4 18             	add    $0x18,%esp
  80016e:	53                   	push   %ebx
  80016f:	ff 75 10             	push   0x10(%ebp)
  800172:	e8 56 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800177:	c7 04 24 77 21 80 00 	movl   $0x802177,(%esp)
  80017e:	e8 9b 00 00 00       	call   80021e <cprintf>
  800183:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800186:	cc                   	int3   
  800187:	eb fd                	jmp    800186 <_panic+0x43>

00800189 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	53                   	push   %ebx
  80018d:	83 ec 04             	sub    $0x4,%esp
  800190:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800193:	8b 13                	mov    (%ebx),%edx
  800195:	8d 42 01             	lea    0x1(%edx),%eax
  800198:	89 03                	mov    %eax,(%ebx)
  80019a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a6:	74 09                	je     8001b1 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	68 ff 00 00 00       	push   $0xff
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 76 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  8001c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	eb db                	jmp    8001a8 <putch+0x1f>

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	push   0xc(%ebp)
  8001ed:	ff 75 08             	push   0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 89 01 80 00       	push   $0x800189
  8001fc:	e8 14 01 00 00       	call   800315 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 22 09 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	push   0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 d1                	mov    %edx,%ecx
  800247:	89 c2                	mov    %eax,%edx
  800249:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024f:	8b 45 10             	mov    0x10(%ebp),%eax
  800252:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800255:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800258:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025f:	39 c2                	cmp    %eax,%edx
  800261:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800264:	72 3e                	jb     8002a4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	ff 75 18             	push   0x18(%ebp)
  80026c:	83 eb 01             	sub    $0x1,%ebx
  80026f:	53                   	push   %ebx
  800270:	50                   	push   %eax
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	ff 75 e4             	push   -0x1c(%ebp)
  800277:	ff 75 e0             	push   -0x20(%ebp)
  80027a:	ff 75 dc             	push   -0x24(%ebp)
  80027d:	ff 75 d8             	push   -0x28(%ebp)
  800280:	e8 4b 1c 00 00       	call   801ed0 <__udivdi3>
  800285:	83 c4 18             	add    $0x18,%esp
  800288:	52                   	push   %edx
  800289:	50                   	push   %eax
  80028a:	89 f2                	mov    %esi,%edx
  80028c:	89 f8                	mov    %edi,%eax
  80028e:	e8 9f ff ff ff       	call   800232 <printnum>
  800293:	83 c4 20             	add    $0x20,%esp
  800296:	eb 13                	jmp    8002ab <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	56                   	push   %esi
  80029c:	ff 75 18             	push   0x18(%ebp)
  80029f:	ff d7                	call   *%edi
  8002a1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a4:	83 eb 01             	sub    $0x1,%ebx
  8002a7:	85 db                	test   %ebx,%ebx
  8002a9:	7f ed                	jg     800298 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	83 ec 04             	sub    $0x4,%esp
  8002b2:	ff 75 e4             	push   -0x1c(%ebp)
  8002b5:	ff 75 e0             	push   -0x20(%ebp)
  8002b8:	ff 75 dc             	push   -0x24(%ebp)
  8002bb:	ff 75 d8             	push   -0x28(%ebp)
  8002be:	e8 2d 1d 00 00       	call   801ff0 <__umoddi3>
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	0f be 80 a7 21 80 00 	movsbl 0x8021a7(%eax),%eax
  8002cd:	50                   	push   %eax
  8002ce:	ff d7                	call   *%edi
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ea:	73 0a                	jae    8002f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	88 02                	mov    %al,(%edx)
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800301:	50                   	push   %eax
  800302:	ff 75 10             	push   0x10(%ebp)
  800305:	ff 75 0c             	push   0xc(%ebp)
  800308:	ff 75 08             	push   0x8(%ebp)
  80030b:	e8 05 00 00 00       	call   800315 <vprintfmt>
}
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <vprintfmt>:
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 3c             	sub    $0x3c,%esp
  80031e:	8b 75 08             	mov    0x8(%ebp),%esi
  800321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800324:	8b 7d 10             	mov    0x10(%ebp),%edi
  800327:	eb 0a                	jmp    800333 <vprintfmt+0x1e>
			putch(ch, putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	53                   	push   %ebx
  80032d:	50                   	push   %eax
  80032e:	ff d6                	call   *%esi
  800330:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800333:	83 c7 01             	add    $0x1,%edi
  800336:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033a:	83 f8 25             	cmp    $0x25,%eax
  80033d:	74 0c                	je     80034b <vprintfmt+0x36>
			if (ch == '\0')
  80033f:	85 c0                	test   %eax,%eax
  800341:	75 e6                	jne    800329 <vprintfmt+0x14>
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    
		padc = ' ';
  80034b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800356:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800364:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8d 47 01             	lea    0x1(%edi),%eax
  80036c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036f:	0f b6 17             	movzbl (%edi),%edx
  800372:	8d 42 dd             	lea    -0x23(%edx),%eax
  800375:	3c 55                	cmp    $0x55,%al
  800377:	0f 87 bb 03 00 00    	ja     800738 <vprintfmt+0x423>
  80037d:	0f b6 c0             	movzbl %al,%eax
  800380:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80038e:	eb d9                	jmp    800369 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800393:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800397:	eb d0                	jmp    800369 <vprintfmt+0x54>
  800399:	0f b6 d2             	movzbl %dl,%edx
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039f:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003aa:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ae:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b4:	83 f9 09             	cmp    $0x9,%ecx
  8003b7:	77 55                	ja     80040e <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003bc:	eb e9                	jmp    8003a7 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 40 04             	lea    0x4(%eax),%eax
  8003cc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d6:	79 91                	jns    800369 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003de:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e5:	eb 82                	jmp    800369 <vprintfmt+0x54>
  8003e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f1:	0f 49 c2             	cmovns %edx,%eax
  8003f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fa:	e9 6a ff ff ff       	jmp    800369 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800402:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800409:	e9 5b ff ff ff       	jmp    800369 <vprintfmt+0x54>
  80040e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	eb bc                	jmp    8003d2 <vprintfmt+0xbd>
			lflag++;
  800416:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041c:	e9 48 ff ff ff       	jmp    800369 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 78 04             	lea    0x4(%eax),%edi
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 30                	push   (%eax)
  80042d:	ff d6                	call   *%esi
			break;
  80042f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800432:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800435:	e9 9d 02 00 00       	jmp    8006d7 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	8b 10                	mov    (%eax),%edx
  800442:	89 d0                	mov    %edx,%eax
  800444:	f7 d8                	neg    %eax
  800446:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 0f             	cmp    $0xf,%eax
  80044c:	7f 23                	jg     800471 <vprintfmt+0x15c>
  80044e:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800455:	85 d2                	test   %edx,%edx
  800457:	74 18                	je     800471 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800459:	52                   	push   %edx
  80045a:	68 3d 26 80 00       	push   $0x80263d
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 92 fe ff ff       	call   8002f8 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
  80046c:	e9 66 02 00 00       	jmp    8006d7 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 bf 21 80 00       	push   $0x8021bf
  800477:	53                   	push   %ebx
  800478:	56                   	push   %esi
  800479:	e8 7a fe ff ff       	call   8002f8 <printfmt>
  80047e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800481:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800484:	e9 4e 02 00 00       	jmp    8006d7 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	83 c0 04             	add    $0x4,%eax
  80048f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800497:	85 d2                	test   %edx,%edx
  800499:	b8 b8 21 80 00       	mov    $0x8021b8,%eax
  80049e:	0f 45 c2             	cmovne %edx,%eax
  8004a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	7e 06                	jle    8004b0 <vprintfmt+0x19b>
  8004aa:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004ae:	75 0d                	jne    8004bd <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b3:	89 c7                	mov    %eax,%edi
  8004b5:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	eb 55                	jmp    800512 <vprintfmt+0x1fd>
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 d8             	push   -0x28(%ebp)
  8004c3:	ff 75 cc             	push   -0x34(%ebp)
  8004c6:	e8 0a 03 00 00       	call   8007d5 <strnlen>
  8004cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004d8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	eb 0f                	jmp    8004f0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	53                   	push   %ebx
  8004e5:	ff 75 e0             	push   -0x20(%ebp)
  8004e8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f ed                	jg     8004e1 <vprintfmt+0x1cc>
  8004f4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c2             	cmovns %edx,%eax
  800501:	29 c2                	sub    %eax,%edx
  800503:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800506:	eb a8                	jmp    8004b0 <vprintfmt+0x19b>
					putch(ch, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	52                   	push   %edx
  80050d:	ff d6                	call   *%esi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 c7 01             	add    $0x1,%edi
  80051a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051e:	0f be d0             	movsbl %al,%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	74 4b                	je     800570 <vprintfmt+0x25b>
  800525:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800529:	78 06                	js     800531 <vprintfmt+0x21c>
  80052b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052f:	78 1e                	js     80054f <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800535:	74 d1                	je     800508 <vprintfmt+0x1f3>
  800537:	0f be c0             	movsbl %al,%eax
  80053a:	83 e8 20             	sub    $0x20,%eax
  80053d:	83 f8 5e             	cmp    $0x5e,%eax
  800540:	76 c6                	jbe    800508 <vprintfmt+0x1f3>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 3f                	push   $0x3f
  800548:	ff d6                	call   *%esi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb c3                	jmp    800512 <vprintfmt+0x1fd>
  80054f:	89 cf                	mov    %ecx,%edi
  800551:	eb 0e                	jmp    800561 <vprintfmt+0x24c>
				putch(' ', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	6a 20                	push   $0x20
  800559:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055b:	83 ef 01             	sub    $0x1,%edi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 ff                	test   %edi,%edi
  800563:	7f ee                	jg     800553 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	e9 67 01 00 00       	jmp    8006d7 <vprintfmt+0x3c2>
  800570:	89 cf                	mov    %ecx,%edi
  800572:	eb ed                	jmp    800561 <vprintfmt+0x24c>
	if (lflag >= 2)
  800574:	83 f9 01             	cmp    $0x1,%ecx
  800577:	7f 1b                	jg     800594 <vprintfmt+0x27f>
	else if (lflag)
  800579:	85 c9                	test   %ecx,%ecx
  80057b:	74 63                	je     8005e0 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	99                   	cltd   
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
  800592:	eb 17                	jmp    8005ab <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 50 04             	mov    0x4(%eax),%edx
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 40 08             	lea    0x8(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b1:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005b6:	85 c9                	test   %ecx,%ecx
  8005b8:	0f 89 ff 00 00 00    	jns    8006bd <vprintfmt+0x3a8>
				putch('-', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 2d                	push   $0x2d
  8005c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005cc:	f7 da                	neg    %edx
  8005ce:	83 d1 00             	adc    $0x0,%ecx
  8005d1:	f7 d9                	neg    %ecx
  8005d3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d6:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005db:	e9 dd 00 00 00       	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	99                   	cltd   
  8005e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 40 04             	lea    0x4(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f5:	eb b4                	jmp    8005ab <vprintfmt+0x296>
	if (lflag >= 2)
  8005f7:	83 f9 01             	cmp    $0x1,%ecx
  8005fa:	7f 1e                	jg     80061a <vprintfmt+0x305>
	else if (lflag)
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	74 32                	je     800632 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800610:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800615:	e9 a3 00 00 00       	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80062d:	e9 8b 00 00 00       	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800642:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800647:	eb 74                	jmp    8006bd <vprintfmt+0x3a8>
	if (lflag >= 2)
  800649:	83 f9 01             	cmp    $0x1,%ecx
  80064c:	7f 1b                	jg     800669 <vprintfmt+0x354>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	74 2c                	je     80067e <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800662:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800667:	eb 54                	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	8b 48 04             	mov    0x4(%eax),%ecx
  800671:	8d 40 08             	lea    0x8(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800677:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80067c:	eb 3f                	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800693:	eb 28                	jmp    8006bd <vprintfmt+0x3a8>
			putch('0', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 30                	push   $0x30
  80069b:	ff d6                	call   *%esi
			putch('x', putdat);
  80069d:	83 c4 08             	add    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 78                	push   $0x78
  8006a3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	ff 75 e0             	push   -0x20(%ebp)
  8006c8:	57                   	push   %edi
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 5e fb ff ff       	call   800232 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006da:	e9 54 fc ff ff       	jmp    800333 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7f 1b                	jg     8006ff <vprintfmt+0x3ea>
	else if (lflag)
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 2c                	je     800714 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006fd:	eb be                	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	8b 48 04             	mov    0x4(%eax),%ecx
  800707:	8d 40 08             	lea    0x8(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800712:	eb a9                	jmp    8006bd <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800724:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800729:	eb 92                	jmp    8006bd <vprintfmt+0x3a8>
			putch(ch, putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 25                	push   $0x25
  800731:	ff d6                	call   *%esi
			break;
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	eb 9f                	jmp    8006d7 <vprintfmt+0x3c2>
			putch('%', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 25                	push   $0x25
  80073e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	89 f8                	mov    %edi,%eax
  800745:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800749:	74 05                	je     800750 <vprintfmt+0x43b>
  80074b:	83 e8 01             	sub    $0x1,%eax
  80074e:	eb f5                	jmp    800745 <vprintfmt+0x430>
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	eb 82                	jmp    8006d7 <vprintfmt+0x3c2>

00800755 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 18             	sub    $0x18,%esp
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800761:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800764:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800768:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800772:	85 c0                	test   %eax,%eax
  800774:	74 26                	je     80079c <vsnprintf+0x47>
  800776:	85 d2                	test   %edx,%edx
  800778:	7e 22                	jle    80079c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077a:	ff 75 14             	push   0x14(%ebp)
  80077d:	ff 75 10             	push   0x10(%ebp)
  800780:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800783:	50                   	push   %eax
  800784:	68 db 02 80 00       	push   $0x8002db
  800789:	e8 87 fb ff ff       	call   800315 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800791:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800797:	83 c4 10             	add    $0x10,%esp
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    
		return -E_INVAL;
  80079c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a1:	eb f7                	jmp    80079a <vsnprintf+0x45>

008007a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ac:	50                   	push   %eax
  8007ad:	ff 75 10             	push   0x10(%ebp)
  8007b0:	ff 75 0c             	push   0xc(%ebp)
  8007b3:	ff 75 08             	push   0x8(%ebp)
  8007b6:	e8 9a ff ff ff       	call   800755 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	eb 03                	jmp    8007cd <strlen+0x10>
		n++;
  8007ca:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d1:	75 f7                	jne    8007ca <strlen+0xd>
	return n;
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strnlen+0x13>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e8:	39 d0                	cmp    %edx,%eax
  8007ea:	74 08                	je     8007f4 <strnlen+0x1f>
  8007ec:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f0:	75 f3                	jne    8007e5 <strnlen+0x10>
  8007f2:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f4:	89 d0                	mov    %edx,%eax
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80080b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	84 d2                	test   %dl,%dl
  800813:	75 f2                	jne    800807 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	89 c8                	mov    %ecx,%eax
  800817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	83 ec 10             	sub    $0x10,%esp
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800826:	53                   	push   %ebx
  800827:	e8 91 ff ff ff       	call   8007bd <strlen>
  80082c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80082f:	ff 75 0c             	push   0xc(%ebp)
  800832:	01 d8                	add    %ebx,%eax
  800834:	50                   	push   %eax
  800835:	e8 be ff ff ff       	call   8007f8 <strcpy>
	return dst;
}
  80083a:	89 d8                	mov    %ebx,%eax
  80083c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 75 08             	mov    0x8(%ebp),%esi
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 f3                	mov    %esi,%ebx
  80084e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	89 f0                	mov    %esi,%eax
  800853:	eb 0f                	jmp    800864 <strncpy+0x23>
		*dst++ = *src;
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	0f b6 0a             	movzbl (%edx),%ecx
  80085b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085e:	80 f9 01             	cmp    $0x1,%cl
  800861:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	75 ed                	jne    800855 <strncpy+0x14>
	}
	return ret;
}
  800868:	89 f0                	mov    %esi,%eax
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 75 08             	mov    0x8(%ebp),%esi
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
  80087c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087e:	85 d2                	test   %edx,%edx
  800880:	74 21                	je     8008a3 <strlcpy+0x35>
  800882:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800886:	89 f2                	mov    %esi,%edx
  800888:	eb 09                	jmp    800893 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	83 c1 01             	add    $0x1,%ecx
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 09                	je     8008a0 <strlcpy+0x32>
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	84 db                	test   %bl,%bl
  80089c:	75 ec                	jne    80088a <strlcpy+0x1c>
  80089e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a3:	29 f0                	sub    %esi,%eax
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strcmp+0x11>
		p++, q++;
  8008b4:	83 c1 01             	add    $0x1,%ecx
  8008b7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x1c>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	74 ef                	je     8008b4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d9:	89 c3                	mov    %eax,%ebx
  8008db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008de:	eb 06                	jmp    8008e6 <strncmp+0x17>
		n--, p++, q++;
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e6:	39 d8                	cmp    %ebx,%eax
  8008e8:	74 18                	je     800902 <strncmp+0x33>
  8008ea:	0f b6 08             	movzbl (%eax),%ecx
  8008ed:	84 c9                	test   %cl,%cl
  8008ef:	74 04                	je     8008f5 <strncmp+0x26>
  8008f1:	3a 0a                	cmp    (%edx),%cl
  8008f3:	74 eb                	je     8008e0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 00             	movzbl (%eax),%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    
		return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
  800907:	eb f4                	jmp    8008fd <strncmp+0x2e>

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	eb 03                	jmp    800918 <strchr+0xf>
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
  80091b:	84 d2                	test   %dl,%dl
  80091d:	74 06                	je     800925 <strchr+0x1c>
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	75 f2                	jne    800915 <strchr+0xc>
  800923:	eb 05                	jmp    80092a <strchr+0x21>
			return (char *) s;
	return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800936:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 09                	je     800946 <strfind+0x1a>
  80093d:	84 d2                	test   %dl,%dl
  80093f:	74 05                	je     800946 <strfind+0x1a>
	for (; *s; s++)
  800941:	83 c0 01             	add    $0x1,%eax
  800944:	eb f0                	jmp    800936 <strfind+0xa>
			break;
	return (char *) s;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 2f                	je     800987 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800958:	89 f8                	mov    %edi,%eax
  80095a:	09 c8                	or     %ecx,%eax
  80095c:	a8 03                	test   $0x3,%al
  80095e:	75 21                	jne    800981 <memset+0x39>
		c &= 0xFF;
  800960:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800964:	89 d0                	mov    %edx,%eax
  800966:	c1 e0 08             	shl    $0x8,%eax
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 18             	shl    $0x18,%ebx
  80096e:	89 d6                	mov    %edx,%esi
  800970:	c1 e6 10             	shl    $0x10,%esi
  800973:	09 f3                	or     %esi,%ebx
  800975:	09 da                	or     %ebx,%edx
  800977:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800979:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097c:	fc                   	cld    
  80097d:	f3 ab                	rep stos %eax,%es:(%edi)
  80097f:	eb 06                	jmp    800987 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	fc                   	cld    
  800985:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800987:	89 f8                	mov    %edi,%eax
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 32                	jae    8009d2 <memmove+0x44>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 c2                	cmp    %eax,%edx
  8009a5:	76 2b                	jbe    8009d2 <memmove+0x44>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	09 fe                	or     %edi,%esi
  8009ae:	09 ce                	or     %ecx,%esi
  8009b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b6:	75 0e                	jne    8009c6 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b8:	83 ef 04             	sub    $0x4,%edi
  8009bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c1:	fd                   	std    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 09                	jmp    8009cf <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c6:	83 ef 01             	sub    $0x1,%edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 1a                	jmp    8009ec <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	89 f2                	mov    %esi,%edx
  8009d4:	09 c2                	or     %eax,%edx
  8009d6:	09 ca                	or     %ecx,%edx
  8009d8:	f6 c2 03             	test   $0x3,%dl
  8009db:	75 0a                	jne    8009e7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 05                	jmp    8009ec <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009e7:	89 c7                	mov    %eax,%edi
  8009e9:	fc                   	cld    
  8009ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f6:	ff 75 10             	push   0x10(%ebp)
  8009f9:	ff 75 0c             	push   0xc(%ebp)
  8009fc:	ff 75 08             	push   0x8(%ebp)
  8009ff:	e8 8a ff ff ff       	call   80098e <memmove>
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a11:	89 c6                	mov    %eax,%esi
  800a13:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	eb 06                	jmp    800a1e <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a1e:	39 f0                	cmp    %esi,%eax
  800a20:	74 14                	je     800a36 <memcmp+0x30>
		if (*s1 != *s2)
  800a22:	0f b6 08             	movzbl (%eax),%ecx
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	38 d9                	cmp    %bl,%cl
  800a2a:	74 ec                	je     800a18 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a2c:	0f b6 c1             	movzbl %cl,%eax
  800a2f:	0f b6 db             	movzbl %bl,%ebx
  800a32:	29 d8                	sub    %ebx,%eax
  800a34:	eb 05                	jmp    800a3b <memcmp+0x35>
	}

	return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a48:	89 c2                	mov    %eax,%edx
  800a4a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4d:	eb 03                	jmp    800a52 <memfind+0x13>
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	39 d0                	cmp    %edx,%eax
  800a54:	73 04                	jae    800a5a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	75 f5                	jne    800a4f <memfind+0x10>
			break;
	return (void *) s;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 03                	jmp    800a6d <strtol+0x11>
		s++;
  800a6a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a6d:	0f b6 02             	movzbl (%edx),%eax
  800a70:	3c 20                	cmp    $0x20,%al
  800a72:	74 f6                	je     800a6a <strtol+0xe>
  800a74:	3c 09                	cmp    $0x9,%al
  800a76:	74 f2                	je     800a6a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a78:	3c 2b                	cmp    $0x2b,%al
  800a7a:	74 2a                	je     800aa6 <strtol+0x4a>
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	74 2b                	je     800ab0 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a85:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8b:	75 0f                	jne    800a9c <strtol+0x40>
  800a8d:	80 3a 30             	cmpb   $0x30,(%edx)
  800a90:	74 28                	je     800aba <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a99:	0f 44 d8             	cmove  %eax,%ebx
  800a9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa4:	eb 46                	jmp    800aec <strtol+0x90>
		s++;
  800aa6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb d5                	jmp    800a85 <strtol+0x29>
		s++, neg = 1;
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab8:	eb cb                	jmp    800a85 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abe:	74 0e                	je     800ace <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ac0:	85 db                	test   %ebx,%ebx
  800ac2:	75 d8                	jne    800a9c <strtol+0x40>
		s++, base = 8;
  800ac4:	83 c2 01             	add    $0x1,%edx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800acc:	eb ce                	jmp    800a9c <strtol+0x40>
		s += 2, base = 16;
  800ace:	83 c2 02             	add    $0x2,%edx
  800ad1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad6:	eb c4                	jmp    800a9c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad8:	0f be c0             	movsbl %al,%eax
  800adb:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ade:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ae1:	7d 3a                	jge    800b1d <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aea:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aec:	0f b6 02             	movzbl (%edx),%eax
  800aef:	8d 70 d0             	lea    -0x30(%eax),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 09             	cmp    $0x9,%bl
  800af7:	76 df                	jbe    800ad8 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800af9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 08                	ja     800b0b <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b03:	0f be c0             	movsbl %al,%eax
  800b06:	83 e8 57             	sub    $0x57,%eax
  800b09:	eb d3                	jmp    800ade <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 08                	ja     800b1d <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b15:	0f be c0             	movsbl %al,%eax
  800b18:	83 e8 37             	sub    $0x37,%eax
  800b1b:	eb c1                	jmp    800ade <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b21:	74 05                	je     800b28 <strtol+0xcc>
		*endptr = (char *) s;
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b28:	89 c8                	mov    %ecx,%eax
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 45 c8             	cmovne %eax,%ecx
}
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7f 08                	jg     800b9f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 03                	push   $0x3
  800ba5:	68 9f 24 80 00       	push   $0x80249f
  800baa:	6a 2a                	push   $0x2a
  800bac:	68 bc 24 80 00       	push   $0x8024bc
  800bb1:	e8 8d f5 ff ff       	call   800143 <_panic>

00800bb6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_yield>:

void
sys_yield(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfd:	be 00 00 00 00       	mov    $0x0,%esi
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	89 f7                	mov    %esi,%edi
  800c12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7f 08                	jg     800c20 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 04                	push   $0x4
  800c26:	68 9f 24 80 00       	push   $0x80249f
  800c2b:	6a 2a                	push   $0x2a
  800c2d:	68 bc 24 80 00       	push   $0x8024bc
  800c32:	e8 0c f5 ff ff       	call   800143 <_panic>

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7f 08                	jg     800c62 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 05                	push   $0x5
  800c68:	68 9f 24 80 00       	push   $0x80249f
  800c6d:	6a 2a                	push   $0x2a
  800c6f:	68 bc 24 80 00       	push   $0x8024bc
  800c74:	e8 ca f4 ff ff       	call   800143 <_panic>

00800c79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c92:	89 df                	mov    %ebx,%edi
  800c94:	89 de                	mov    %ebx,%esi
  800c96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7f 08                	jg     800ca4 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 06                	push   $0x6
  800caa:	68 9f 24 80 00       	push   $0x80249f
  800caf:	6a 2a                	push   $0x2a
  800cb1:	68 bc 24 80 00       	push   $0x8024bc
  800cb6:	e8 88 f4 ff ff       	call   800143 <_panic>

00800cbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7f 08                	jg     800ce6 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 08                	push   $0x8
  800cec:	68 9f 24 80 00       	push   $0x80249f
  800cf1:	6a 2a                	push   $0x2a
  800cf3:	68 bc 24 80 00       	push   $0x8024bc
  800cf8:	e8 46 f4 ff ff       	call   800143 <_panic>

00800cfd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	b8 09 00 00 00       	mov    $0x9,%eax
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7f 08                	jg     800d28 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 09                	push   $0x9
  800d2e:	68 9f 24 80 00       	push   $0x80249f
  800d33:	6a 2a                	push   $0x2a
  800d35:	68 bc 24 80 00       	push   $0x8024bc
  800d3a:	e8 04 f4 ff ff       	call   800143 <_panic>

00800d3f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7f 08                	jg     800d6a <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 0a                	push   $0xa
  800d70:	68 9f 24 80 00       	push   $0x80249f
  800d75:	6a 2a                	push   $0x2a
  800d77:	68 bc 24 80 00       	push   $0x8024bc
  800d7c:	e8 c2 f3 ff ff       	call   800143 <_panic>

00800d81 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dba:	89 cb                	mov    %ecx,%ebx
  800dbc:	89 cf                	mov    %ecx,%edi
  800dbe:	89 ce                	mov    %ecx,%esi
  800dc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7f 08                	jg     800dce <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	6a 0d                	push   $0xd
  800dd4:	68 9f 24 80 00       	push   $0x80249f
  800dd9:	6a 2a                	push   $0x2a
  800ddb:	68 bc 24 80 00       	push   $0x8024bc
  800de0:	e8 5e f3 ff ff       	call   800143 <_panic>

00800de5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ded:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800def:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df3:	0f 84 8e 00 00 00    	je     800e87 <pgfault+0xa2>
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	c1 e8 0c             	shr    $0xc,%eax
  800dfe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e05:	f6 c4 08             	test   $0x8,%ah
  800e08:	74 7d                	je     800e87 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e0a:	e8 a7 fd ff ff       	call   800bb6 <sys_getenvid>
  800e0f:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	6a 07                	push   $0x7
  800e16:	68 00 f0 7f 00       	push   $0x7ff000
  800e1b:	50                   	push   %eax
  800e1c:	e8 d3 fd ff ff       	call   800bf4 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	78 73                	js     800e9b <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e28:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 00 10 00 00       	push   $0x1000
  800e36:	56                   	push   %esi
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	e8 4d fb ff ff       	call   80098e <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e41:	83 c4 08             	add    $0x8,%esp
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	e8 2e fe ff ff       	call   800c79 <sys_page_unmap>
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	78 5b                	js     800ead <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	6a 07                	push   $0x7
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	68 00 f0 7f 00       	push   $0x7ff000
  800e5e:	53                   	push   %ebx
  800e5f:	e8 d3 fd ff ff       	call   800c37 <sys_page_map>
  800e64:	83 c4 20             	add    $0x20,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 54                	js     800ebf <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	68 00 f0 7f 00       	push   $0x7ff000
  800e73:	53                   	push   %ebx
  800e74:	e8 00 fe ff ff       	call   800c79 <sys_page_unmap>
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 51                	js     800ed1 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	68 cc 24 80 00       	push   $0x8024cc
  800e8f:	6a 1d                	push   $0x1d
  800e91:	68 48 25 80 00       	push   $0x802548
  800e96:	e8 a8 f2 ff ff       	call   800143 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e9b:	50                   	push   %eax
  800e9c:	68 04 25 80 00       	push   $0x802504
  800ea1:	6a 29                	push   $0x29
  800ea3:	68 48 25 80 00       	push   $0x802548
  800ea8:	e8 96 f2 ff ff       	call   800143 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ead:	50                   	push   %eax
  800eae:	68 28 25 80 00       	push   $0x802528
  800eb3:	6a 2e                	push   $0x2e
  800eb5:	68 48 25 80 00       	push   $0x802548
  800eba:	e8 84 f2 ff ff       	call   800143 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800ebf:	50                   	push   %eax
  800ec0:	68 53 25 80 00       	push   $0x802553
  800ec5:	6a 30                	push   $0x30
  800ec7:	68 48 25 80 00       	push   $0x802548
  800ecc:	e8 72 f2 ff ff       	call   800143 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ed1:	50                   	push   %eax
  800ed2:	68 28 25 80 00       	push   $0x802528
  800ed7:	6a 32                	push   $0x32
  800ed9:	68 48 25 80 00       	push   $0x802548
  800ede:	e8 60 f2 ff ff       	call   800143 <_panic>

00800ee3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800eec:	68 e5 0d 80 00       	push   $0x800de5
  800ef1:	e8 0e 0e 00 00       	call   801d04 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef6:	b8 07 00 00 00       	mov    $0x7,%eax
  800efb:	cd 30                	int    $0x30
  800efd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 2d                	js     800f34 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f07:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f0c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f10:	75 73                	jne    800f85 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f12:	e8 9f fc ff ff       	call   800bb6 <sys_getenvid>
  800f17:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f1f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f24:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f29:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f34:	50                   	push   %eax
  800f35:	68 71 25 80 00       	push   $0x802571
  800f3a:	6a 78                	push   $0x78
  800f3c:	68 48 25 80 00       	push   $0x802548
  800f41:	e8 fd f1 ff ff       	call   800143 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	ff 75 e4             	push   -0x1c(%ebp)
  800f4c:	57                   	push   %edi
  800f4d:	ff 75 dc             	push   -0x24(%ebp)
  800f50:	57                   	push   %edi
  800f51:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f54:	56                   	push   %esi
  800f55:	e8 dd fc ff ff       	call   800c37 <sys_page_map>
	if(r<0) return r;
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 cb                	js     800f2c <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	ff 75 e4             	push   -0x1c(%ebp)
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	e8 c7 fc ff ff       	call   800c37 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f70:	83 c4 20             	add    $0x20,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 76                	js     800fed <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f77:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f7d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f83:	74 75                	je     800ffa <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f85:	89 d8                	mov    %ebx,%eax
  800f87:	c1 e8 16             	shr    $0x16,%eax
  800f8a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f91:	a8 01                	test   $0x1,%al
  800f93:	74 e2                	je     800f77 <fork+0x94>
  800f95:	89 de                	mov    %ebx,%esi
  800f97:	c1 ee 0c             	shr    $0xc,%esi
  800f9a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa1:	a8 01                	test   $0x1,%al
  800fa3:	74 d2                	je     800f77 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800fa5:	e8 0c fc ff ff       	call   800bb6 <sys_getenvid>
  800faa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fad:	89 f7                	mov    %esi,%edi
  800faf:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fb2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb9:	89 c1                	mov    %eax,%ecx
  800fbb:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fc1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fc4:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fcb:	f6 c6 04             	test   $0x4,%dh
  800fce:	0f 85 72 ff ff ff    	jne    800f46 <fork+0x63>
		perm &= ~PTE_W;
  800fd4:	25 05 0e 00 00       	and    $0xe05,%eax
  800fd9:	80 cc 08             	or     $0x8,%ah
  800fdc:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800fe2:	0f 44 c1             	cmove  %ecx,%eax
  800fe5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe8:	e9 59 ff ff ff       	jmp    800f46 <fork+0x63>
  800fed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff2:	0f 4f c2             	cmovg  %edx,%eax
  800ff5:	e9 32 ff ff ff       	jmp    800f2c <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800ffa:	83 ec 04             	sub    $0x4,%esp
  800ffd:	6a 07                	push   $0x7
  800fff:	68 00 f0 bf ee       	push   $0xeebff000
  801004:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801007:	57                   	push   %edi
  801008:	e8 e7 fb ff ff       	call   800bf4 <sys_page_alloc>
	if(r<0) return r;
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	0f 88 14 ff ff ff    	js     800f2c <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801018:	83 ec 08             	sub    $0x8,%esp
  80101b:	68 7a 1d 80 00       	push   $0x801d7a
  801020:	57                   	push   %edi
  801021:	e8 19 fd ff ff       	call   800d3f <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	85 c0                	test   %eax,%eax
  80102b:	0f 88 fb fe ff ff    	js     800f2c <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	6a 02                	push   $0x2
  801036:	57                   	push   %edi
  801037:	e8 7f fc ff ff       	call   800cbb <sys_env_set_status>
	if(r<0) return r;
  80103c:	83 c4 10             	add    $0x10,%esp
	return envid;
  80103f:	85 c0                	test   %eax,%eax
  801041:	0f 49 c7             	cmovns %edi,%eax
  801044:	e9 e3 fe ff ff       	jmp    800f2c <fork+0x49>

00801049 <sfork>:

// Challenge!
int
sfork(void)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104f:	68 81 25 80 00       	push   $0x802581
  801054:	68 a1 00 00 00       	push   $0xa1
  801059:	68 48 25 80 00       	push   $0x802548
  80105e:	e8 e0 f0 ff ff       	call   800143 <_panic>

00801063 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	05 00 00 00 30       	add    $0x30000000,%eax
  80106e:	c1 e8 0c             	shr    $0xc,%eax
}
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80107e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801083:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 ea 16             	shr    $0x16,%edx
  801097:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	74 29                	je     8010cc <fd_alloc+0x42>
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	c1 ea 0c             	shr    $0xc,%edx
  8010a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 18                	je     8010cc <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010b4:	05 00 10 00 00       	add    $0x1000,%eax
  8010b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010be:	75 d2                	jne    801092 <fd_alloc+0x8>
  8010c0:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8010c5:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8010ca:	eb 05                	jmp    8010d1 <fd_alloc+0x47>
			return 0;
  8010cc:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8010d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d4:	89 02                	mov    %eax,(%edx)
}
  8010d6:	89 c8                	mov    %ecx,%eax
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e0:	83 f8 1f             	cmp    $0x1f,%eax
  8010e3:	77 30                	ja     801115 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010e5:	c1 e0 0c             	shl    $0xc,%eax
  8010e8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ed:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	74 24                	je     80111c <fd_lookup+0x42>
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	c1 ea 0c             	shr    $0xc,%edx
  8010fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801104:	f6 c2 01             	test   $0x1,%dl
  801107:	74 1a                	je     801123 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801109:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110c:	89 02                	mov    %eax,(%edx)
	return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    
		return -E_INVAL;
  801115:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111a:	eb f7                	jmp    801113 <fd_lookup+0x39>
		return -E_INVAL;
  80111c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801121:	eb f0                	jmp    801113 <fd_lookup+0x39>
  801123:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801128:	eb e9                	jmp    801113 <fd_lookup+0x39>

0080112a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	53                   	push   %ebx
  80112e:	83 ec 04             	sub    $0x4,%esp
  801131:	8b 55 08             	mov    0x8(%ebp),%edx
  801134:	b8 14 26 80 00       	mov    $0x802614,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801139:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80113e:	39 13                	cmp    %edx,(%ebx)
  801140:	74 32                	je     801174 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801142:	83 c0 04             	add    $0x4,%eax
  801145:	8b 18                	mov    (%eax),%ebx
  801147:	85 db                	test   %ebx,%ebx
  801149:	75 f3                	jne    80113e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80114b:	a1 04 40 80 00       	mov    0x804004,%eax
  801150:	8b 40 48             	mov    0x48(%eax),%eax
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	52                   	push   %edx
  801157:	50                   	push   %eax
  801158:	68 98 25 80 00       	push   $0x802598
  80115d:	e8 bc f0 ff ff       	call   80021e <cprintf>
	*dev = 0;
	return -E_INVAL;
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80116a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116d:	89 1a                	mov    %ebx,(%edx)
}
  80116f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801172:	c9                   	leave  
  801173:	c3                   	ret    
			return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	eb ef                	jmp    80116a <dev_lookup+0x40>

0080117b <fd_close>:
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 24             	sub    $0x24,%esp
  801184:	8b 75 08             	mov    0x8(%ebp),%esi
  801187:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80118d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801194:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801197:	50                   	push   %eax
  801198:	e8 3d ff ff ff       	call   8010da <fd_lookup>
  80119d:	89 c3                	mov    %eax,%ebx
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 05                	js     8011ab <fd_close+0x30>
	    || fd != fd2)
  8011a6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011a9:	74 16                	je     8011c1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8011ab:	89 f8                	mov    %edi,%eax
  8011ad:	84 c0                	test   %al,%al
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b4:	0f 44 d8             	cmove  %eax,%ebx
}
  8011b7:	89 d8                	mov    %ebx,%eax
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	ff 36                	push   (%esi)
  8011ca:	e8 5b ff ff ff       	call   80112a <dev_lookup>
  8011cf:	89 c3                	mov    %eax,%ebx
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 1a                	js     8011f2 <fd_close+0x77>
		if (dev->dev_close)
  8011d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011db:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011de:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	74 0b                	je     8011f2 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	56                   	push   %esi
  8011eb:	ff d0                	call   *%eax
  8011ed:	89 c3                	mov    %eax,%ebx
  8011ef:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8011f2:	83 ec 08             	sub    $0x8,%esp
  8011f5:	56                   	push   %esi
  8011f6:	6a 00                	push   $0x0
  8011f8:	e8 7c fa ff ff       	call   800c79 <sys_page_unmap>
	return r;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	eb b5                	jmp    8011b7 <fd_close+0x3c>

00801202 <close>:

int
close(int fdnum)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	ff 75 08             	push   0x8(%ebp)
  80120f:	e8 c6 fe ff ff       	call   8010da <fd_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	79 02                	jns    80121d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    
		return fd_close(fd, 1);
  80121d:	83 ec 08             	sub    $0x8,%esp
  801220:	6a 01                	push   $0x1
  801222:	ff 75 f4             	push   -0xc(%ebp)
  801225:	e8 51 ff ff ff       	call   80117b <fd_close>
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	eb ec                	jmp    80121b <close+0x19>

0080122f <close_all>:

void
close_all(void)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	53                   	push   %ebx
  801233:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80123b:	83 ec 0c             	sub    $0xc,%esp
  80123e:	53                   	push   %ebx
  80123f:	e8 be ff ff ff       	call   801202 <close>
	for (i = 0; i < MAXFD; i++)
  801244:	83 c3 01             	add    $0x1,%ebx
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	83 fb 20             	cmp    $0x20,%ebx
  80124d:	75 ec                	jne    80123b <close_all+0xc>
}
  80124f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	57                   	push   %edi
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80125d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	ff 75 08             	push   0x8(%ebp)
  801264:	e8 71 fe ff ff       	call   8010da <fd_lookup>
  801269:	89 c3                	mov    %eax,%ebx
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 7f                	js     8012f1 <dup+0x9d>
		return r;
	close(newfdnum);
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	ff 75 0c             	push   0xc(%ebp)
  801278:	e8 85 ff ff ff       	call   801202 <close>

	newfd = INDEX2FD(newfdnum);
  80127d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801280:	c1 e6 0c             	shl    $0xc,%esi
  801283:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80128c:	89 3c 24             	mov    %edi,(%esp)
  80128f:	e8 df fd ff ff       	call   801073 <fd2data>
  801294:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801296:	89 34 24             	mov    %esi,(%esp)
  801299:	e8 d5 fd ff ff       	call   801073 <fd2data>
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012a4:	89 d8                	mov    %ebx,%eax
  8012a6:	c1 e8 16             	shr    $0x16,%eax
  8012a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b0:	a8 01                	test   $0x1,%al
  8012b2:	74 11                	je     8012c5 <dup+0x71>
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	c1 e8 0c             	shr    $0xc,%eax
  8012b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c0:	f6 c2 01             	test   $0x1,%dl
  8012c3:	75 36                	jne    8012fb <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c5:	89 f8                	mov    %edi,%eax
  8012c7:	c1 e8 0c             	shr    $0xc,%eax
  8012ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d9:	50                   	push   %eax
  8012da:	56                   	push   %esi
  8012db:	6a 00                	push   $0x0
  8012dd:	57                   	push   %edi
  8012de:	6a 00                	push   $0x0
  8012e0:	e8 52 f9 ff ff       	call   800c37 <sys_page_map>
  8012e5:	89 c3                	mov    %eax,%ebx
  8012e7:	83 c4 20             	add    $0x20,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 33                	js     801321 <dup+0xcd>
		goto err;

	return newfdnum;
  8012ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012f1:	89 d8                	mov    %ebx,%eax
  8012f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5f                   	pop    %edi
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	25 07 0e 00 00       	and    $0xe07,%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 d4             	push   -0x2c(%ebp)
  80130e:	6a 00                	push   $0x0
  801310:	53                   	push   %ebx
  801311:	6a 00                	push   $0x0
  801313:	e8 1f f9 ff ff       	call   800c37 <sys_page_map>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 20             	add    $0x20,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	79 a4                	jns    8012c5 <dup+0x71>
	sys_page_unmap(0, newfd);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	56                   	push   %esi
  801325:	6a 00                	push   $0x0
  801327:	e8 4d f9 ff ff       	call   800c79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	ff 75 d4             	push   -0x2c(%ebp)
  801332:	6a 00                	push   $0x0
  801334:	e8 40 f9 ff ff       	call   800c79 <sys_page_unmap>
	return r;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	eb b3                	jmp    8012f1 <dup+0x9d>

0080133e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 18             	sub    $0x18,%esp
  801346:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801349:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	56                   	push   %esi
  80134e:	e8 87 fd ff ff       	call   8010da <fd_lookup>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 3c                	js     801396 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	ff 33                	push   (%ebx)
  801366:	e8 bf fd ff ff       	call   80112a <dev_lookup>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 24                	js     801396 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801372:	8b 43 08             	mov    0x8(%ebx),%eax
  801375:	83 e0 03             	and    $0x3,%eax
  801378:	83 f8 01             	cmp    $0x1,%eax
  80137b:	74 20                	je     80139d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801380:	8b 40 08             	mov    0x8(%eax),%eax
  801383:	85 c0                	test   %eax,%eax
  801385:	74 37                	je     8013be <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801387:	83 ec 04             	sub    $0x4,%esp
  80138a:	ff 75 10             	push   0x10(%ebp)
  80138d:	ff 75 0c             	push   0xc(%ebp)
  801390:	53                   	push   %ebx
  801391:	ff d0                	call   *%eax
  801393:	83 c4 10             	add    $0x10,%esp
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80139d:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a2:	8b 40 48             	mov    0x48(%eax),%eax
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	56                   	push   %esi
  8013a9:	50                   	push   %eax
  8013aa:	68 d9 25 80 00       	push   $0x8025d9
  8013af:	e8 6a ee ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bc:	eb d8                	jmp    801396 <read+0x58>
		return -E_NOT_SUPP;
  8013be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c3:	eb d1                	jmp    801396 <read+0x58>

008013c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	57                   	push   %edi
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d9:	eb 02                	jmp    8013dd <readn+0x18>
  8013db:	01 c3                	add    %eax,%ebx
  8013dd:	39 f3                	cmp    %esi,%ebx
  8013df:	73 21                	jae    801402 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e1:	83 ec 04             	sub    $0x4,%esp
  8013e4:	89 f0                	mov    %esi,%eax
  8013e6:	29 d8                	sub    %ebx,%eax
  8013e8:	50                   	push   %eax
  8013e9:	89 d8                	mov    %ebx,%eax
  8013eb:	03 45 0c             	add    0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	57                   	push   %edi
  8013f0:	e8 49 ff ff ff       	call   80133e <read>
		if (m < 0)
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 04                	js     801400 <readn+0x3b>
			return m;
		if (m == 0)
  8013fc:	75 dd                	jne    8013db <readn+0x16>
  8013fe:	eb 02                	jmp    801402 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801400:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801402:	89 d8                	mov    %ebx,%eax
  801404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 18             	sub    $0x18,%esp
  801414:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801417:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	53                   	push   %ebx
  80141c:	e8 b9 fc ff ff       	call   8010da <fd_lookup>
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 37                	js     80145f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	ff 36                	push   (%esi)
  801434:	e8 f1 fc ff ff       	call   80112a <dev_lookup>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 1f                	js     80145f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801440:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801444:	74 20                	je     801466 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801449:	8b 40 0c             	mov    0xc(%eax),%eax
  80144c:	85 c0                	test   %eax,%eax
  80144e:	74 37                	je     801487 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	ff 75 10             	push   0x10(%ebp)
  801456:	ff 75 0c             	push   0xc(%ebp)
  801459:	56                   	push   %esi
  80145a:	ff d0                	call   *%eax
  80145c:	83 c4 10             	add    $0x10,%esp
}
  80145f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801462:	5b                   	pop    %ebx
  801463:	5e                   	pop    %esi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801466:	a1 04 40 80 00       	mov    0x804004,%eax
  80146b:	8b 40 48             	mov    0x48(%eax),%eax
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	53                   	push   %ebx
  801472:	50                   	push   %eax
  801473:	68 f5 25 80 00       	push   $0x8025f5
  801478:	e8 a1 ed ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801485:	eb d8                	jmp    80145f <write+0x53>
		return -E_NOT_SUPP;
  801487:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80148c:	eb d1                	jmp    80145f <write+0x53>

0080148e <seek>:

int
seek(int fdnum, off_t offset)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	ff 75 08             	push   0x8(%ebp)
  80149b:	e8 3a fc ff ff       	call   8010da <fd_lookup>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 0e                	js     8014b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 18             	sub    $0x18,%esp
  8014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	53                   	push   %ebx
  8014c7:	e8 0e fc ff ff       	call   8010da <fd_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 34                	js     801507 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	ff 36                	push   (%esi)
  8014df:	e8 46 fc ff ff       	call   80112a <dev_lookup>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 1c                	js     801507 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014eb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014ef:	74 1d                	je     80150e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8014f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f4:	8b 40 18             	mov    0x18(%eax),%eax
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	74 34                	je     80152f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	ff 75 0c             	push   0xc(%ebp)
  801501:	56                   	push   %esi
  801502:	ff d0                	call   *%eax
  801504:	83 c4 10             	add    $0x10,%esp
}
  801507:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150a:	5b                   	pop    %ebx
  80150b:	5e                   	pop    %esi
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80150e:	a1 04 40 80 00       	mov    0x804004,%eax
  801513:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	53                   	push   %ebx
  80151a:	50                   	push   %eax
  80151b:	68 b8 25 80 00       	push   $0x8025b8
  801520:	e8 f9 ec ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152d:	eb d8                	jmp    801507 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80152f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801534:	eb d1                	jmp    801507 <ftruncate+0x50>

00801536 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	83 ec 18             	sub    $0x18,%esp
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801541:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	ff 75 08             	push   0x8(%ebp)
  801548:	e8 8d fb ff ff       	call   8010da <fd_lookup>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 49                	js     80159d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801554:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	ff 36                	push   (%esi)
  801560:	e8 c5 fb ff ff       	call   80112a <dev_lookup>
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 31                	js     80159d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80156c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801573:	74 2f                	je     8015a4 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801575:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801578:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80157f:	00 00 00 
	stat->st_isdir = 0;
  801582:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801589:	00 00 00 
	stat->st_dev = dev;
  80158c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	56                   	push   %esi
  801597:	ff 50 14             	call   *0x14(%eax)
  80159a:	83 c4 10             	add    $0x10,%esp
}
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    
		return -E_NOT_SUPP;
  8015a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a9:	eb f2                	jmp    80159d <fstat+0x67>

008015ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	6a 00                	push   $0x0
  8015b5:	ff 75 08             	push   0x8(%ebp)
  8015b8:	e8 e4 01 00 00       	call   8017a1 <open>
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 1b                	js     8015e1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	ff 75 0c             	push   0xc(%ebp)
  8015cc:	50                   	push   %eax
  8015cd:	e8 64 ff ff ff       	call   801536 <fstat>
  8015d2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015d4:	89 1c 24             	mov    %ebx,(%esp)
  8015d7:	e8 26 fc ff ff       	call   801202 <close>
	return r;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	89 f3                	mov    %esi,%ebx
}
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e6:	5b                   	pop    %ebx
  8015e7:	5e                   	pop    %esi
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
  8015ef:	89 c6                	mov    %eax,%esi
  8015f1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015f3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8015fa:	74 27                	je     801623 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015fc:	6a 07                	push   $0x7
  8015fe:	68 00 50 80 00       	push   $0x805000
  801603:	56                   	push   %esi
  801604:	ff 35 00 60 80 00    	push   0x806000
  80160a:	e8 f8 07 00 00       	call   801e07 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80160f:	83 c4 0c             	add    $0xc,%esp
  801612:	6a 00                	push   $0x0
  801614:	53                   	push   %ebx
  801615:	6a 00                	push   $0x0
  801617:	e8 84 07 00 00       	call   801da0 <ipc_recv>
}
  80161c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	6a 01                	push   $0x1
  801628:	e8 2e 08 00 00       	call   801e5b <ipc_find_env>
  80162d:	a3 00 60 80 00       	mov    %eax,0x806000
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	eb c5                	jmp    8015fc <fsipc+0x12>

00801637 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80163d:	8b 45 08             	mov    0x8(%ebp),%eax
  801640:	8b 40 0c             	mov    0xc(%eax),%eax
  801643:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801650:	ba 00 00 00 00       	mov    $0x0,%edx
  801655:	b8 02 00 00 00       	mov    $0x2,%eax
  80165a:	e8 8b ff ff ff       	call   8015ea <fsipc>
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <devfile_flush>:
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	8b 40 0c             	mov    0xc(%eax),%eax
  80166d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801672:	ba 00 00 00 00       	mov    $0x0,%edx
  801677:	b8 06 00 00 00       	mov    $0x6,%eax
  80167c:	e8 69 ff ff ff       	call   8015ea <fsipc>
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <devfile_stat>:
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	8b 40 0c             	mov    0xc(%eax),%eax
  801693:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801698:	ba 00 00 00 00       	mov    $0x0,%edx
  80169d:	b8 05 00 00 00       	mov    $0x5,%eax
  8016a2:	e8 43 ff ff ff       	call   8015ea <fsipc>
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 2c                	js     8016d7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	68 00 50 80 00       	push   $0x805000
  8016b3:	53                   	push   %ebx
  8016b4:	e8 3f f1 ff ff       	call   8007f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016b9:	a1 80 50 80 00       	mov    0x805080,%eax
  8016be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016c4:	a1 84 50 80 00       	mov    0x805084,%eax
  8016c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devfile_write>:
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016ea:	39 d0                	cmp    %edx,%eax
  8016ec:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016fb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801700:	50                   	push   %eax
  801701:	ff 75 0c             	push   0xc(%ebp)
  801704:	68 08 50 80 00       	push   $0x805008
  801709:	e8 80 f2 ff ff       	call   80098e <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 04 00 00 00       	mov    $0x4,%eax
  801718:	e8 cd fe ff ff       	call   8015ea <fsipc>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_read>:
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	8b 40 0c             	mov    0xc(%eax),%eax
  80172d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801732:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801738:	ba 00 00 00 00       	mov    $0x0,%edx
  80173d:	b8 03 00 00 00       	mov    $0x3,%eax
  801742:	e8 a3 fe ff ff       	call   8015ea <fsipc>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 1f                	js     80176c <devfile_read+0x4d>
	assert(r <= n);
  80174d:	39 f0                	cmp    %esi,%eax
  80174f:	77 24                	ja     801775 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801751:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801756:	7f 33                	jg     80178b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801758:	83 ec 04             	sub    $0x4,%esp
  80175b:	50                   	push   %eax
  80175c:	68 00 50 80 00       	push   $0x805000
  801761:	ff 75 0c             	push   0xc(%ebp)
  801764:	e8 25 f2 ff ff       	call   80098e <memmove>
	return r;
  801769:	83 c4 10             	add    $0x10,%esp
}
  80176c:	89 d8                	mov    %ebx,%eax
  80176e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    
	assert(r <= n);
  801775:	68 24 26 80 00       	push   $0x802624
  80177a:	68 2b 26 80 00       	push   $0x80262b
  80177f:	6a 7c                	push   $0x7c
  801781:	68 40 26 80 00       	push   $0x802640
  801786:	e8 b8 e9 ff ff       	call   800143 <_panic>
	assert(r <= PGSIZE);
  80178b:	68 4b 26 80 00       	push   $0x80264b
  801790:	68 2b 26 80 00       	push   $0x80262b
  801795:	6a 7d                	push   $0x7d
  801797:	68 40 26 80 00       	push   $0x802640
  80179c:	e8 a2 e9 ff ff       	call   800143 <_panic>

008017a1 <open>:
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 1c             	sub    $0x1c,%esp
  8017a9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017ac:	56                   	push   %esi
  8017ad:	e8 0b f0 ff ff       	call   8007bd <strlen>
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ba:	7f 6c                	jg     801828 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	e8 c2 f8 ff ff       	call   80108a <fd_alloc>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 3c                	js     80180d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	56                   	push   %esi
  8017d5:	68 00 50 80 00       	push   $0x805000
  8017da:	e8 19 f0 ff ff       	call   8007f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ef:	e8 f6 fd ff ff       	call   8015ea <fsipc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 19                	js     801816 <open+0x75>
	return fd2num(fd);
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	ff 75 f4             	push   -0xc(%ebp)
  801803:	e8 5b f8 ff ff       	call   801063 <fd2num>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	83 c4 10             	add    $0x10,%esp
}
  80180d:	89 d8                	mov    %ebx,%eax
  80180f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    
		fd_close(fd, 0);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	6a 00                	push   $0x0
  80181b:	ff 75 f4             	push   -0xc(%ebp)
  80181e:	e8 58 f9 ff ff       	call   80117b <fd_close>
		return r;
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	eb e5                	jmp    80180d <open+0x6c>
		return -E_BAD_PATH;
  801828:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80182d:	eb de                	jmp    80180d <open+0x6c>

0080182f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 08 00 00 00       	mov    $0x8,%eax
  80183f:	e8 a6 fd ff ff       	call   8015ea <fsipc>
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	ff 75 08             	push   0x8(%ebp)
  801854:	e8 1a f8 ff ff       	call   801073 <fd2data>
  801859:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80185b:	83 c4 08             	add    $0x8,%esp
  80185e:	68 57 26 80 00       	push   $0x802657
  801863:	53                   	push   %ebx
  801864:	e8 8f ef ff ff       	call   8007f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801869:	8b 46 04             	mov    0x4(%esi),%eax
  80186c:	2b 06                	sub    (%esi),%eax
  80186e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801874:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80187b:	00 00 00 
	stat->st_dev = &devpipe;
  80187e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801885:	30 80 00 
	return 0;
}
  801888:	b8 00 00 00 00       	mov    $0x0,%eax
  80188d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	53                   	push   %ebx
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80189e:	53                   	push   %ebx
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 d3 f3 ff ff       	call   800c79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018a6:	89 1c 24             	mov    %ebx,(%esp)
  8018a9:	e8 c5 f7 ff ff       	call   801073 <fd2data>
  8018ae:	83 c4 08             	add    $0x8,%esp
  8018b1:	50                   	push   %eax
  8018b2:	6a 00                	push   $0x0
  8018b4:	e8 c0 f3 ff ff       	call   800c79 <sys_page_unmap>
}
  8018b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <_pipeisclosed>:
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	57                   	push   %edi
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 1c             	sub    $0x1c,%esp
  8018c7:	89 c7                	mov    %eax,%edi
  8018c9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8018cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	57                   	push   %edi
  8018d7:	e8 b8 05 00 00       	call   801e94 <pageref>
  8018dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018df:	89 34 24             	mov    %esi,(%esp)
  8018e2:	e8 ad 05 00 00       	call   801e94 <pageref>
		nn = thisenv->env_runs;
  8018e7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018ed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	39 cb                	cmp    %ecx,%ebx
  8018f5:	74 1b                	je     801912 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8018f7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018fa:	75 cf                	jne    8018cb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018fc:	8b 42 58             	mov    0x58(%edx),%eax
  8018ff:	6a 01                	push   $0x1
  801901:	50                   	push   %eax
  801902:	53                   	push   %ebx
  801903:	68 5e 26 80 00       	push   $0x80265e
  801908:	e8 11 e9 ff ff       	call   80021e <cprintf>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	eb b9                	jmp    8018cb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801912:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801915:	0f 94 c0             	sete   %al
  801918:	0f b6 c0             	movzbl %al,%eax
}
  80191b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5f                   	pop    %edi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <devpipe_write>:
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	57                   	push   %edi
  801927:	56                   	push   %esi
  801928:	53                   	push   %ebx
  801929:	83 ec 28             	sub    $0x28,%esp
  80192c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80192f:	56                   	push   %esi
  801930:	e8 3e f7 ff ff       	call   801073 <fd2data>
  801935:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	bf 00 00 00 00       	mov    $0x0,%edi
  80193f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801942:	75 09                	jne    80194d <devpipe_write+0x2a>
	return i;
  801944:	89 f8                	mov    %edi,%eax
  801946:	eb 23                	jmp    80196b <devpipe_write+0x48>
			sys_yield();
  801948:	e8 88 f2 ff ff       	call   800bd5 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80194d:	8b 43 04             	mov    0x4(%ebx),%eax
  801950:	8b 0b                	mov    (%ebx),%ecx
  801952:	8d 51 20             	lea    0x20(%ecx),%edx
  801955:	39 d0                	cmp    %edx,%eax
  801957:	72 1a                	jb     801973 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801959:	89 da                	mov    %ebx,%edx
  80195b:	89 f0                	mov    %esi,%eax
  80195d:	e8 5c ff ff ff       	call   8018be <_pipeisclosed>
  801962:	85 c0                	test   %eax,%eax
  801964:	74 e2                	je     801948 <devpipe_write+0x25>
				return 0;
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	5f                   	pop    %edi
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801976:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80197a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	c1 fa 1f             	sar    $0x1f,%edx
  801982:	89 d1                	mov    %edx,%ecx
  801984:	c1 e9 1b             	shr    $0x1b,%ecx
  801987:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80198a:	83 e2 1f             	and    $0x1f,%edx
  80198d:	29 ca                	sub    %ecx,%edx
  80198f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801993:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801997:	83 c0 01             	add    $0x1,%eax
  80199a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80199d:	83 c7 01             	add    $0x1,%edi
  8019a0:	eb 9d                	jmp    80193f <devpipe_write+0x1c>

008019a2 <devpipe_read>:
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	57                   	push   %edi
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 18             	sub    $0x18,%esp
  8019ab:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8019ae:	57                   	push   %edi
  8019af:	e8 bf f6 ff ff       	call   801073 <fd2data>
  8019b4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	be 00 00 00 00       	mov    $0x0,%esi
  8019be:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019c1:	75 13                	jne    8019d6 <devpipe_read+0x34>
	return i;
  8019c3:	89 f0                	mov    %esi,%eax
  8019c5:	eb 02                	jmp    8019c9 <devpipe_read+0x27>
				return i;
  8019c7:	89 f0                	mov    %esi,%eax
}
  8019c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5f                   	pop    %edi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    
			sys_yield();
  8019d1:	e8 ff f1 ff ff       	call   800bd5 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8019d6:	8b 03                	mov    (%ebx),%eax
  8019d8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019db:	75 18                	jne    8019f5 <devpipe_read+0x53>
			if (i > 0)
  8019dd:	85 f6                	test   %esi,%esi
  8019df:	75 e6                	jne    8019c7 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8019e1:	89 da                	mov    %ebx,%edx
  8019e3:	89 f8                	mov    %edi,%eax
  8019e5:	e8 d4 fe ff ff       	call   8018be <_pipeisclosed>
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	74 e3                	je     8019d1 <devpipe_read+0x2f>
				return 0;
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f3:	eb d4                	jmp    8019c9 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019f5:	99                   	cltd   
  8019f6:	c1 ea 1b             	shr    $0x1b,%edx
  8019f9:	01 d0                	add    %edx,%eax
  8019fb:	83 e0 1f             	and    $0x1f,%eax
  8019fe:	29 d0                	sub    %edx,%eax
  801a00:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a08:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a0b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a0e:	83 c6 01             	add    $0x1,%esi
  801a11:	eb ab                	jmp    8019be <devpipe_read+0x1c>

00801a13 <pipe>:
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1e:	50                   	push   %eax
  801a1f:	e8 66 f6 ff ff       	call   80108a <fd_alloc>
  801a24:	89 c3                	mov    %eax,%ebx
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	0f 88 23 01 00 00    	js     801b54 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a31:	83 ec 04             	sub    $0x4,%esp
  801a34:	68 07 04 00 00       	push   $0x407
  801a39:	ff 75 f4             	push   -0xc(%ebp)
  801a3c:	6a 00                	push   $0x0
  801a3e:	e8 b1 f1 ff ff       	call   800bf4 <sys_page_alloc>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	0f 88 04 01 00 00    	js     801b54 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a56:	50                   	push   %eax
  801a57:	e8 2e f6 ff ff       	call   80108a <fd_alloc>
  801a5c:	89 c3                	mov    %eax,%ebx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	0f 88 db 00 00 00    	js     801b44 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a69:	83 ec 04             	sub    $0x4,%esp
  801a6c:	68 07 04 00 00       	push   $0x407
  801a71:	ff 75 f0             	push   -0x10(%ebp)
  801a74:	6a 00                	push   $0x0
  801a76:	e8 79 f1 ff ff       	call   800bf4 <sys_page_alloc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	85 c0                	test   %eax,%eax
  801a82:	0f 88 bc 00 00 00    	js     801b44 <pipe+0x131>
	va = fd2data(fd0);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 f4             	push   -0xc(%ebp)
  801a8e:	e8 e0 f5 ff ff       	call   801073 <fd2data>
  801a93:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a95:	83 c4 0c             	add    $0xc,%esp
  801a98:	68 07 04 00 00       	push   $0x407
  801a9d:	50                   	push   %eax
  801a9e:	6a 00                	push   $0x0
  801aa0:	e8 4f f1 ff ff       	call   800bf4 <sys_page_alloc>
  801aa5:	89 c3                	mov    %eax,%ebx
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	0f 88 82 00 00 00    	js     801b34 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 75 f0             	push   -0x10(%ebp)
  801ab8:	e8 b6 f5 ff ff       	call   801073 <fd2data>
  801abd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ac4:	50                   	push   %eax
  801ac5:	6a 00                	push   $0x0
  801ac7:	56                   	push   %esi
  801ac8:	6a 00                	push   $0x0
  801aca:	e8 68 f1 ff ff       	call   800c37 <sys_page_map>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 20             	add    $0x20,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 4e                	js     801b26 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801ad8:	a1 20 30 80 00       	mov    0x803020,%eax
  801add:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801aec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aef:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	ff 75 f4             	push   -0xc(%ebp)
  801b01:	e8 5d f5 ff ff       	call   801063 <fd2num>
  801b06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b09:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b0b:	83 c4 04             	add    $0x4,%esp
  801b0e:	ff 75 f0             	push   -0x10(%ebp)
  801b11:	e8 4d f5 ff ff       	call   801063 <fd2num>
  801b16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b19:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b24:	eb 2e                	jmp    801b54 <pipe+0x141>
	sys_page_unmap(0, va);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	56                   	push   %esi
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 48 f1 ff ff       	call   800c79 <sys_page_unmap>
  801b31:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	ff 75 f0             	push   -0x10(%ebp)
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 38 f1 ff ff       	call   800c79 <sys_page_unmap>
  801b41:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	ff 75 f4             	push   -0xc(%ebp)
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 28 f1 ff ff       	call   800c79 <sys_page_unmap>
  801b51:	83 c4 10             	add    $0x10,%esp
}
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <pipeisclosed>:
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b66:	50                   	push   %eax
  801b67:	ff 75 08             	push   0x8(%ebp)
  801b6a:	e8 6b f5 ff ff       	call   8010da <fd_lookup>
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	78 18                	js     801b8e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	ff 75 f4             	push   -0xc(%ebp)
  801b7c:	e8 f2 f4 ff ff       	call   801073 <fd2data>
  801b81:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b86:	e8 33 fd ff ff       	call   8018be <_pipeisclosed>
  801b8b:	83 c4 10             	add    $0x10,%esp
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
  801b95:	c3                   	ret    

00801b96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b9c:	68 76 26 80 00       	push   $0x802676
  801ba1:	ff 75 0c             	push   0xc(%ebp)
  801ba4:	e8 4f ec ff ff       	call   8007f8 <strcpy>
	return 0;
}
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devcons_write>:
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801bbc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801bc1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801bc7:	eb 2e                	jmp    801bf7 <devcons_write+0x47>
		m = n - tot;
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bcc:	29 f3                	sub    %esi,%ebx
  801bce:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801bd3:	39 c3                	cmp    %eax,%ebx
  801bd5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	53                   	push   %ebx
  801bdc:	89 f0                	mov    %esi,%eax
  801bde:	03 45 0c             	add    0xc(%ebp),%eax
  801be1:	50                   	push   %eax
  801be2:	57                   	push   %edi
  801be3:	e8 a6 ed ff ff       	call   80098e <memmove>
		sys_cputs(buf, m);
  801be8:	83 c4 08             	add    $0x8,%esp
  801beb:	53                   	push   %ebx
  801bec:	57                   	push   %edi
  801bed:	e8 46 ef ff ff       	call   800b38 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801bf2:	01 de                	add    %ebx,%esi
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfa:	72 cd                	jb     801bc9 <devcons_write+0x19>
}
  801bfc:	89 f0                	mov    %esi,%eax
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <devcons_read>:
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c15:	75 07                	jne    801c1e <devcons_read+0x18>
  801c17:	eb 1f                	jmp    801c38 <devcons_read+0x32>
		sys_yield();
  801c19:	e8 b7 ef ff ff       	call   800bd5 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c1e:	e8 33 ef ff ff       	call   800b56 <sys_cgetc>
  801c23:	85 c0                	test   %eax,%eax
  801c25:	74 f2                	je     801c19 <devcons_read+0x13>
	if (c < 0)
  801c27:	78 0f                	js     801c38 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801c29:	83 f8 04             	cmp    $0x4,%eax
  801c2c:	74 0c                	je     801c3a <devcons_read+0x34>
	*(char*)vbuf = c;
  801c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c31:	88 02                	mov    %al,(%edx)
	return 1;
  801c33:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    
		return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3f:	eb f7                	jmp    801c38 <devcons_read+0x32>

00801c41 <cputchar>:
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c47:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c4d:	6a 01                	push   $0x1
  801c4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c52:	50                   	push   %eax
  801c53:	e8 e0 ee ff ff       	call   800b38 <sys_cputs>
}
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <getchar>:
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801c63:	6a 01                	push   $0x1
  801c65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c68:	50                   	push   %eax
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 ce f6 ff ff       	call   80133e <read>
	if (r < 0)
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 06                	js     801c7d <getchar+0x20>
	if (r < 1)
  801c77:	74 06                	je     801c7f <getchar+0x22>
	return c;
  801c79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    
		return -E_EOF;
  801c7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c84:	eb f7                	jmp    801c7d <getchar+0x20>

00801c86 <iscons>:
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	ff 75 08             	push   0x8(%ebp)
  801c93:	e8 42 f4 ff ff       	call   8010da <fd_lookup>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 11                	js     801cb0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca8:	39 10                	cmp    %edx,(%eax)
  801caa:	0f 94 c0             	sete   %al
  801cad:	0f b6 c0             	movzbl %al,%eax
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <opencons>:
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	e8 c9 f3 ff ff       	call   80108a <fd_alloc>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 3a                	js     801d02 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	68 07 04 00 00       	push   $0x407
  801cd0:	ff 75 f4             	push   -0xc(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 1a ef ff ff       	call   800bf4 <sys_page_alloc>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 21                	js     801d02 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	50                   	push   %eax
  801cfa:	e8 64 f3 ff ff       	call   801063 <fd2num>
  801cff:	83 c4 10             	add    $0x10,%esp
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801d0a:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801d11:	74 0a                	je     801d1d <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d13:	8b 45 08             	mov    0x8(%ebp),%eax
  801d16:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801d1d:	e8 94 ee ff ff       	call   800bb6 <sys_getenvid>
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	68 07 0e 00 00       	push   $0xe07
  801d2a:	68 00 f0 bf ee       	push   $0xeebff000
  801d2f:	50                   	push   %eax
  801d30:	e8 bf ee ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) {
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 2c                	js     801d68 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801d3c:	e8 75 ee ff ff       	call   800bb6 <sys_getenvid>
  801d41:	83 ec 08             	sub    $0x8,%esp
  801d44:	68 7a 1d 80 00       	push   $0x801d7a
  801d49:	50                   	push   %eax
  801d4a:	e8 f0 ef ff ff       	call   800d3f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	79 bd                	jns    801d13 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801d56:	50                   	push   %eax
  801d57:	68 c4 26 80 00       	push   $0x8026c4
  801d5c:	6a 28                	push   $0x28
  801d5e:	68 fa 26 80 00       	push   $0x8026fa
  801d63:	e8 db e3 ff ff       	call   800143 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801d68:	50                   	push   %eax
  801d69:	68 84 26 80 00       	push   $0x802684
  801d6e:	6a 23                	push   $0x23
  801d70:	68 fa 26 80 00       	push   $0x8026fa
  801d75:	e8 c9 e3 ff ff       	call   800143 <_panic>

00801d7a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d7a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d7b:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801d80:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d82:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801d85:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801d89:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801d8c:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801d90:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801d94:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801d96:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801d99:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801d9a:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801d9d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801d9e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801d9f:	c3                   	ret    

00801da0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	56                   	push   %esi
  801da4:	53                   	push   %ebx
  801da5:	8b 75 08             	mov    0x8(%ebp),%esi
  801da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801dae:	85 c0                	test   %eax,%eax
  801db0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801db5:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	50                   	push   %eax
  801dbc:	e8 e3 ef ff ff       	call   800da4 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 f6                	test   %esi,%esi
  801dc6:	74 14                	je     801ddc <ipc_recv+0x3c>
  801dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 09                	js     801dda <ipc_recv+0x3a>
  801dd1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dd7:	8b 52 74             	mov    0x74(%edx),%edx
  801dda:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ddc:	85 db                	test   %ebx,%ebx
  801dde:	74 14                	je     801df4 <ipc_recv+0x54>
  801de0:	ba 00 00 00 00       	mov    $0x0,%edx
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 09                	js     801df2 <ipc_recv+0x52>
  801de9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801def:	8b 52 78             	mov    0x78(%edx),%edx
  801df2:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 08                	js     801e00 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801df8:	a1 04 40 80 00       	mov    0x804004,%eax
  801dfd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	57                   	push   %edi
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 0c             	sub    $0xc,%esp
  801e10:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801e19:	85 db                	test   %ebx,%ebx
  801e1b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e20:	0f 44 d8             	cmove  %eax,%ebx
  801e23:	eb 05                	jmp    801e2a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801e25:	e8 ab ed ff ff       	call   800bd5 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801e2a:	ff 75 14             	push   0x14(%ebp)
  801e2d:	53                   	push   %ebx
  801e2e:	56                   	push   %esi
  801e2f:	57                   	push   %edi
  801e30:	e8 4c ef ff ff       	call   800d81 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e3b:	74 e8                	je     801e25 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 08                	js     801e49 <ipc_send+0x42>
	}while (r<0);

}
  801e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801e49:	50                   	push   %eax
  801e4a:	68 08 27 80 00       	push   $0x802708
  801e4f:	6a 3d                	push   $0x3d
  801e51:	68 1c 27 80 00       	push   $0x80271c
  801e56:	e8 e8 e2 ff ff       	call   800143 <_panic>

00801e5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e66:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e69:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e6f:	8b 52 50             	mov    0x50(%edx),%edx
  801e72:	39 ca                	cmp    %ecx,%edx
  801e74:	74 11                	je     801e87 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801e76:	83 c0 01             	add    $0x1,%eax
  801e79:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e7e:	75 e6                	jne    801e66 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
  801e85:	eb 0b                	jmp    801e92 <ipc_find_env+0x37>
			return envs[i].env_id;
  801e87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e8f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	c1 ea 16             	shr    $0x16,%edx
  801e9f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ea6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801eab:	f6 c1 01             	test   $0x1,%cl
  801eae:	74 1c                	je     801ecc <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801eb0:	c1 e8 0c             	shr    $0xc,%eax
  801eb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801eba:	a8 01                	test   $0x1,%al
  801ebc:	74 0e                	je     801ecc <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ebe:	c1 e8 0c             	shr    $0xc,%eax
  801ec1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ec8:	ef 
  801ec9:	0f b7 d2             	movzwl %dx,%edx
}
  801ecc:	89 d0                	mov    %edx,%eax
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <__udivdi3>:
  801ed0:	f3 0f 1e fb          	endbr32 
  801ed4:	55                   	push   %ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 1c             	sub    $0x1c,%esp
  801edb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801edf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ee3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ee7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	75 19                	jne    801f08 <__udivdi3+0x38>
  801eef:	39 f3                	cmp    %esi,%ebx
  801ef1:	76 4d                	jbe    801f40 <__udivdi3+0x70>
  801ef3:	31 ff                	xor    %edi,%edi
  801ef5:	89 e8                	mov    %ebp,%eax
  801ef7:	89 f2                	mov    %esi,%edx
  801ef9:	f7 f3                	div    %ebx
  801efb:	89 fa                	mov    %edi,%edx
  801efd:	83 c4 1c             	add    $0x1c,%esp
  801f00:	5b                   	pop    %ebx
  801f01:	5e                   	pop    %esi
  801f02:	5f                   	pop    %edi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    
  801f05:	8d 76 00             	lea    0x0(%esi),%esi
  801f08:	39 f0                	cmp    %esi,%eax
  801f0a:	76 14                	jbe    801f20 <__udivdi3+0x50>
  801f0c:	31 ff                	xor    %edi,%edi
  801f0e:	31 c0                	xor    %eax,%eax
  801f10:	89 fa                	mov    %edi,%edx
  801f12:	83 c4 1c             	add    $0x1c,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    
  801f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f20:	0f bd f8             	bsr    %eax,%edi
  801f23:	83 f7 1f             	xor    $0x1f,%edi
  801f26:	75 48                	jne    801f70 <__udivdi3+0xa0>
  801f28:	39 f0                	cmp    %esi,%eax
  801f2a:	72 06                	jb     801f32 <__udivdi3+0x62>
  801f2c:	31 c0                	xor    %eax,%eax
  801f2e:	39 eb                	cmp    %ebp,%ebx
  801f30:	77 de                	ja     801f10 <__udivdi3+0x40>
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	eb d7                	jmp    801f10 <__udivdi3+0x40>
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	89 d9                	mov    %ebx,%ecx
  801f42:	85 db                	test   %ebx,%ebx
  801f44:	75 0b                	jne    801f51 <__udivdi3+0x81>
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	f7 f3                	div    %ebx
  801f4f:	89 c1                	mov    %eax,%ecx
  801f51:	31 d2                	xor    %edx,%edx
  801f53:	89 f0                	mov    %esi,%eax
  801f55:	f7 f1                	div    %ecx
  801f57:	89 c6                	mov    %eax,%esi
  801f59:	89 e8                	mov    %ebp,%eax
  801f5b:	89 f7                	mov    %esi,%edi
  801f5d:	f7 f1                	div    %ecx
  801f5f:	89 fa                	mov    %edi,%edx
  801f61:	83 c4 1c             	add    $0x1c,%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	89 f9                	mov    %edi,%ecx
  801f72:	ba 20 00 00 00       	mov    $0x20,%edx
  801f77:	29 fa                	sub    %edi,%edx
  801f79:	d3 e0                	shl    %cl,%eax
  801f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f7f:	89 d1                	mov    %edx,%ecx
  801f81:	89 d8                	mov    %ebx,%eax
  801f83:	d3 e8                	shr    %cl,%eax
  801f85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f89:	09 c1                	or     %eax,%ecx
  801f8b:	89 f0                	mov    %esi,%eax
  801f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	d3 e3                	shl    %cl,%ebx
  801f95:	89 d1                	mov    %edx,%ecx
  801f97:	d3 e8                	shr    %cl,%eax
  801f99:	89 f9                	mov    %edi,%ecx
  801f9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f9f:	89 eb                	mov    %ebp,%ebx
  801fa1:	d3 e6                	shl    %cl,%esi
  801fa3:	89 d1                	mov    %edx,%ecx
  801fa5:	d3 eb                	shr    %cl,%ebx
  801fa7:	09 f3                	or     %esi,%ebx
  801fa9:	89 c6                	mov    %eax,%esi
  801fab:	89 f2                	mov    %esi,%edx
  801fad:	89 d8                	mov    %ebx,%eax
  801faf:	f7 74 24 08          	divl   0x8(%esp)
  801fb3:	89 d6                	mov    %edx,%esi
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	f7 64 24 0c          	mull   0xc(%esp)
  801fbb:	39 d6                	cmp    %edx,%esi
  801fbd:	72 19                	jb     801fd8 <__udivdi3+0x108>
  801fbf:	89 f9                	mov    %edi,%ecx
  801fc1:	d3 e5                	shl    %cl,%ebp
  801fc3:	39 c5                	cmp    %eax,%ebp
  801fc5:	73 04                	jae    801fcb <__udivdi3+0xfb>
  801fc7:	39 d6                	cmp    %edx,%esi
  801fc9:	74 0d                	je     801fd8 <__udivdi3+0x108>
  801fcb:	89 d8                	mov    %ebx,%eax
  801fcd:	31 ff                	xor    %edi,%edi
  801fcf:	e9 3c ff ff ff       	jmp    801f10 <__udivdi3+0x40>
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801fdb:	31 ff                	xor    %edi,%edi
  801fdd:	e9 2e ff ff ff       	jmp    801f10 <__udivdi3+0x40>
  801fe2:	66 90                	xchg   %ax,%ax
  801fe4:	66 90                	xchg   %ax,%ax
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__umoddi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801fff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802003:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802007:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80200b:	89 f0                	mov    %esi,%eax
  80200d:	89 da                	mov    %ebx,%edx
  80200f:	85 ff                	test   %edi,%edi
  802011:	75 15                	jne    802028 <__umoddi3+0x38>
  802013:	39 dd                	cmp    %ebx,%ebp
  802015:	76 39                	jbe    802050 <__umoddi3+0x60>
  802017:	f7 f5                	div    %ebp
  802019:	89 d0                	mov    %edx,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 df                	cmp    %ebx,%edi
  80202a:	77 f1                	ja     80201d <__umoddi3+0x2d>
  80202c:	0f bd cf             	bsr    %edi,%ecx
  80202f:	83 f1 1f             	xor    $0x1f,%ecx
  802032:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802036:	75 40                	jne    802078 <__umoddi3+0x88>
  802038:	39 df                	cmp    %ebx,%edi
  80203a:	72 04                	jb     802040 <__umoddi3+0x50>
  80203c:	39 f5                	cmp    %esi,%ebp
  80203e:	77 dd                	ja     80201d <__umoddi3+0x2d>
  802040:	89 da                	mov    %ebx,%edx
  802042:	89 f0                	mov    %esi,%eax
  802044:	29 e8                	sub    %ebp,%eax
  802046:	19 fa                	sbb    %edi,%edx
  802048:	eb d3                	jmp    80201d <__umoddi3+0x2d>
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	89 e9                	mov    %ebp,%ecx
  802052:	85 ed                	test   %ebp,%ebp
  802054:	75 0b                	jne    802061 <__umoddi3+0x71>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f5                	div    %ebp
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	89 d8                	mov    %ebx,%eax
  802063:	31 d2                	xor    %edx,%edx
  802065:	f7 f1                	div    %ecx
  802067:	89 f0                	mov    %esi,%eax
  802069:	f7 f1                	div    %ecx
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	31 d2                	xor    %edx,%edx
  80206f:	eb ac                	jmp    80201d <__umoddi3+0x2d>
  802071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802078:	8b 44 24 04          	mov    0x4(%esp),%eax
  80207c:	ba 20 00 00 00       	mov    $0x20,%edx
  802081:	29 c2                	sub    %eax,%edx
  802083:	89 c1                	mov    %eax,%ecx
  802085:	89 e8                	mov    %ebp,%eax
  802087:	d3 e7                	shl    %cl,%edi
  802089:	89 d1                	mov    %edx,%ecx
  80208b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80208f:	d3 e8                	shr    %cl,%eax
  802091:	89 c1                	mov    %eax,%ecx
  802093:	8b 44 24 04          	mov    0x4(%esp),%eax
  802097:	09 f9                	or     %edi,%ecx
  802099:	89 df                	mov    %ebx,%edi
  80209b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	d3 e5                	shl    %cl,%ebp
  8020a3:	89 d1                	mov    %edx,%ecx
  8020a5:	d3 ef                	shr    %cl,%edi
  8020a7:	89 c1                	mov    %eax,%ecx
  8020a9:	89 f0                	mov    %esi,%eax
  8020ab:	d3 e3                	shl    %cl,%ebx
  8020ad:	89 d1                	mov    %edx,%ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	d3 e8                	shr    %cl,%eax
  8020b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020b8:	09 d8                	or     %ebx,%eax
  8020ba:	f7 74 24 08          	divl   0x8(%esp)
  8020be:	89 d3                	mov    %edx,%ebx
  8020c0:	d3 e6                	shl    %cl,%esi
  8020c2:	f7 e5                	mul    %ebp
  8020c4:	89 c7                	mov    %eax,%edi
  8020c6:	89 d1                	mov    %edx,%ecx
  8020c8:	39 d3                	cmp    %edx,%ebx
  8020ca:	72 06                	jb     8020d2 <__umoddi3+0xe2>
  8020cc:	75 0e                	jne    8020dc <__umoddi3+0xec>
  8020ce:	39 c6                	cmp    %eax,%esi
  8020d0:	73 0a                	jae    8020dc <__umoddi3+0xec>
  8020d2:	29 e8                	sub    %ebp,%eax
  8020d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8020d8:	89 d1                	mov    %edx,%ecx
  8020da:	89 c7                	mov    %eax,%edi
  8020dc:	89 f5                	mov    %esi,%ebp
  8020de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8020e2:	29 fd                	sub    %edi,%ebp
  8020e4:	19 cb                	sbb    %ecx,%ebx
  8020e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8020eb:	89 d8                	mov    %ebx,%eax
  8020ed:	d3 e0                	shl    %cl,%eax
  8020ef:	89 f1                	mov    %esi,%ecx
  8020f1:	d3 ed                	shr    %cl,%ebp
  8020f3:	d3 eb                	shr    %cl,%ebx
  8020f5:	09 e8                	or     %ebp,%eax
  8020f7:	89 da                	mov    %ebx,%edx
  8020f9:	83 c4 1c             	add    $0x1c,%esp
  8020fc:	5b                   	pop    %ebx
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    
