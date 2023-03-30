
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
  800044:	e8 fb 0e 00 00       	call   800f44 <fork>
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
  8000b8:	68 1b 26 80 00       	push   $0x80261b
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
  8000d2:	68 e0 25 80 00       	push   $0x8025e0
  8000d7:	6a 21                	push   $0x21
  8000d9:	68 08 26 80 00       	push   $0x802608
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
  80012f:	e8 61 11 00 00       	call   801295 <close_all>
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
  800161:	68 44 26 80 00       	push   $0x802644
  800166:	e8 b3 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016b:	83 c4 18             	add    $0x18,%esp
  80016e:	53                   	push   %ebx
  80016f:	ff 75 10             	push   0x10(%ebp)
  800172:	e8 56 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800177:	c7 04 24 37 26 80 00 	movl   $0x802637,(%esp)
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
  800280:	e8 1b 21 00 00       	call   8023a0 <__udivdi3>
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
  8002be:	e8 fd 21 00 00       	call   8024c0 <__umoddi3>
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
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
  800380:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
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
  80044e:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800455:	85 d2                	test   %edx,%edx
  800457:	74 18                	je     800471 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800459:	52                   	push   %edx
  80045a:	68 01 2b 80 00       	push   $0x802b01
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 92 fe ff ff       	call   8002f8 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
  80046c:	e9 66 02 00 00       	jmp    8006d7 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 7f 26 80 00       	push   $0x80267f
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
  800499:	b8 78 26 80 00       	mov    $0x802678,%eax
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
  800ba5:	68 5f 29 80 00       	push   $0x80295f
  800baa:	6a 2a                	push   $0x2a
  800bac:	68 7c 29 80 00       	push   $0x80297c
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
  800c26:	68 5f 29 80 00       	push   $0x80295f
  800c2b:	6a 2a                	push   $0x2a
  800c2d:	68 7c 29 80 00       	push   $0x80297c
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
  800c68:	68 5f 29 80 00       	push   $0x80295f
  800c6d:	6a 2a                	push   $0x2a
  800c6f:	68 7c 29 80 00       	push   $0x80297c
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
  800caa:	68 5f 29 80 00       	push   $0x80295f
  800caf:	6a 2a                	push   $0x2a
  800cb1:	68 7c 29 80 00       	push   $0x80297c
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
  800cec:	68 5f 29 80 00       	push   $0x80295f
  800cf1:	6a 2a                	push   $0x2a
  800cf3:	68 7c 29 80 00       	push   $0x80297c
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
  800d2e:	68 5f 29 80 00       	push   $0x80295f
  800d33:	6a 2a                	push   $0x2a
  800d35:	68 7c 29 80 00       	push   $0x80297c
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
  800d70:	68 5f 29 80 00       	push   $0x80295f
  800d75:	6a 2a                	push   $0x2a
  800d77:	68 7c 29 80 00       	push   $0x80297c
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
  800dd4:	68 5f 29 80 00       	push   $0x80295f
  800dd9:	6a 2a                	push   $0x2a
  800ddb:	68 7c 29 80 00       	push   $0x80297c
  800de0:	e8 5e f3 ff ff       	call   800143 <_panic>

00800de5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	b8 10 00 00 00       	mov    $0x10,%eax
  800e3b:	89 df                	mov    %ebx,%edi
  800e3d:	89 de                	mov    %ebx,%esi
  800e3f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e4e:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e50:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e54:	0f 84 8e 00 00 00    	je     800ee8 <pgfault+0xa2>
  800e5a:	89 f0                	mov    %esi,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
  800e5f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e66:	f6 c4 08             	test   $0x8,%ah
  800e69:	74 7d                	je     800ee8 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e6b:	e8 46 fd ff ff       	call   800bb6 <sys_getenvid>
  800e70:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	6a 07                	push   $0x7
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	50                   	push   %eax
  800e7d:	e8 72 fd ff ff       	call   800bf4 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	78 73                	js     800efc <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e89:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	68 00 10 00 00       	push   $0x1000
  800e97:	56                   	push   %esi
  800e98:	68 00 f0 7f 00       	push   $0x7ff000
  800e9d:	e8 ec fa ff ff       	call   80098e <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800ea2:	83 c4 08             	add    $0x8,%esp
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	e8 cd fd ff ff       	call   800c79 <sys_page_unmap>
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	78 5b                	js     800f0e <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	6a 07                	push   $0x7
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	68 00 f0 7f 00       	push   $0x7ff000
  800ebf:	53                   	push   %ebx
  800ec0:	e8 72 fd ff ff       	call   800c37 <sys_page_map>
  800ec5:	83 c4 20             	add    $0x20,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 54                	js     800f20 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ecc:	83 ec 08             	sub    $0x8,%esp
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	53                   	push   %ebx
  800ed5:	e8 9f fd ff ff       	call   800c79 <sys_page_unmap>
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 51                	js     800f32 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ee1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	68 8c 29 80 00       	push   $0x80298c
  800ef0:	6a 1d                	push   $0x1d
  800ef2:	68 08 2a 80 00       	push   $0x802a08
  800ef7:	e8 47 f2 ff ff       	call   800143 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800efc:	50                   	push   %eax
  800efd:	68 c4 29 80 00       	push   $0x8029c4
  800f02:	6a 29                	push   $0x29
  800f04:	68 08 2a 80 00       	push   $0x802a08
  800f09:	e8 35 f2 ff ff       	call   800143 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f0e:	50                   	push   %eax
  800f0f:	68 e8 29 80 00       	push   $0x8029e8
  800f14:	6a 2e                	push   $0x2e
  800f16:	68 08 2a 80 00       	push   $0x802a08
  800f1b:	e8 23 f2 ff ff       	call   800143 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f20:	50                   	push   %eax
  800f21:	68 13 2a 80 00       	push   $0x802a13
  800f26:	6a 30                	push   $0x30
  800f28:	68 08 2a 80 00       	push   $0x802a08
  800f2d:	e8 11 f2 ff ff       	call   800143 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f32:	50                   	push   %eax
  800f33:	68 e8 29 80 00       	push   $0x8029e8
  800f38:	6a 32                	push   $0x32
  800f3a:	68 08 2a 80 00       	push   $0x802a08
  800f3f:	e8 ff f1 ff ff       	call   800143 <_panic>

00800f44 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
  800f4a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f4d:	68 46 0e 80 00       	push   $0x800e46
  800f52:	e8 7b 12 00 00       	call   8021d2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f57:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5c:	cd 30                	int    $0x30
  800f5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 2d                	js     800f95 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f68:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f6d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f71:	75 73                	jne    800fe6 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f73:	e8 3e fc ff ff       	call   800bb6 <sys_getenvid>
  800f78:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f80:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f85:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f95:	50                   	push   %eax
  800f96:	68 31 2a 80 00       	push   $0x802a31
  800f9b:	6a 78                	push   $0x78
  800f9d:	68 08 2a 80 00       	push   $0x802a08
  800fa2:	e8 9c f1 ff ff       	call   800143 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	ff 75 e4             	push   -0x1c(%ebp)
  800fad:	57                   	push   %edi
  800fae:	ff 75 dc             	push   -0x24(%ebp)
  800fb1:	57                   	push   %edi
  800fb2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fb5:	56                   	push   %esi
  800fb6:	e8 7c fc ff ff       	call   800c37 <sys_page_map>
	if(r<0) return r;
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 cb                	js     800f8d <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	ff 75 e4             	push   -0x1c(%ebp)
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	57                   	push   %edi
  800fcb:	56                   	push   %esi
  800fcc:	e8 66 fc ff ff       	call   800c37 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 76                	js     80104e <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fd8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fde:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fe4:	74 75                	je     80105b <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fe6:	89 d8                	mov    %ebx,%eax
  800fe8:	c1 e8 16             	shr    $0x16,%eax
  800feb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff2:	a8 01                	test   $0x1,%al
  800ff4:	74 e2                	je     800fd8 <fork+0x94>
  800ff6:	89 de                	mov    %ebx,%esi
  800ff8:	c1 ee 0c             	shr    $0xc,%esi
  800ffb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801002:	a8 01                	test   $0x1,%al
  801004:	74 d2                	je     800fd8 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801006:	e8 ab fb ff ff       	call   800bb6 <sys_getenvid>
  80100b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80100e:	89 f7                	mov    %esi,%edi
  801010:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801013:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101a:	89 c1                	mov    %eax,%ecx
  80101c:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801022:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801025:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80102c:	f6 c6 04             	test   $0x4,%dh
  80102f:	0f 85 72 ff ff ff    	jne    800fa7 <fork+0x63>
		perm &= ~PTE_W;
  801035:	25 05 0e 00 00       	and    $0xe05,%eax
  80103a:	80 cc 08             	or     $0x8,%ah
  80103d:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801043:	0f 44 c1             	cmove  %ecx,%eax
  801046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801049:	e9 59 ff ff ff       	jmp    800fa7 <fork+0x63>
  80104e:	ba 00 00 00 00       	mov    $0x0,%edx
  801053:	0f 4f c2             	cmovg  %edx,%eax
  801056:	e9 32 ff ff ff       	jmp    800f8d <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	6a 07                	push   $0x7
  801060:	68 00 f0 bf ee       	push   $0xeebff000
  801065:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801068:	57                   	push   %edi
  801069:	e8 86 fb ff ff       	call   800bf4 <sys_page_alloc>
	if(r<0) return r;
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	0f 88 14 ff ff ff    	js     800f8d <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	68 48 22 80 00       	push   $0x802248
  801081:	57                   	push   %edi
  801082:	e8 b8 fc ff ff       	call   800d3f <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	0f 88 fb fe ff ff    	js     800f8d <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801092:	83 ec 08             	sub    $0x8,%esp
  801095:	6a 02                	push   $0x2
  801097:	57                   	push   %edi
  801098:	e8 1e fc ff ff       	call   800cbb <sys_env_set_status>
	if(r<0) return r;
  80109d:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	0f 49 c7             	cmovns %edi,%eax
  8010a5:	e9 e3 fe ff ff       	jmp    800f8d <fork+0x49>

008010aa <sfork>:

// Challenge!
int
sfork(void)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b0:	68 41 2a 80 00       	push   $0x802a41
  8010b5:	68 a1 00 00 00       	push   $0xa1
  8010ba:	68 08 2a 80 00       	push   $0x802a08
  8010bf:	e8 7f f0 ff ff       	call   800143 <_panic>

008010c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	c1 ea 16             	shr    $0x16,%edx
  8010f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 29                	je     80112d <fd_alloc+0x42>
  801104:	89 c2                	mov    %eax,%edx
  801106:	c1 ea 0c             	shr    $0xc,%edx
  801109:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801110:	f6 c2 01             	test   $0x1,%dl
  801113:	74 18                	je     80112d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801115:	05 00 10 00 00       	add    $0x1000,%eax
  80111a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111f:	75 d2                	jne    8010f3 <fd_alloc+0x8>
  801121:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801126:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80112b:	eb 05                	jmp    801132 <fd_alloc+0x47>
			return 0;
  80112d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801132:	8b 55 08             	mov    0x8(%ebp),%edx
  801135:	89 02                	mov    %eax,(%edx)
}
  801137:	89 c8                	mov    %ecx,%eax
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801141:	83 f8 1f             	cmp    $0x1f,%eax
  801144:	77 30                	ja     801176 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801146:	c1 e0 0c             	shl    $0xc,%eax
  801149:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80114e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801154:	f6 c2 01             	test   $0x1,%dl
  801157:	74 24                	je     80117d <fd_lookup+0x42>
  801159:	89 c2                	mov    %eax,%edx
  80115b:	c1 ea 0c             	shr    $0xc,%edx
  80115e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801165:	f6 c2 01             	test   $0x1,%dl
  801168:	74 1a                	je     801184 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80116a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116d:	89 02                	mov    %eax,(%edx)
	return 0;
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    
		return -E_INVAL;
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb f7                	jmp    801174 <fd_lookup+0x39>
		return -E_INVAL;
  80117d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801182:	eb f0                	jmp    801174 <fd_lookup+0x39>
  801184:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801189:	eb e9                	jmp    801174 <fd_lookup+0x39>

0080118b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	53                   	push   %ebx
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801195:	b8 00 00 00 00       	mov    $0x0,%eax
  80119a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80119f:	39 13                	cmp    %edx,(%ebx)
  8011a1:	74 37                	je     8011da <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8011a3:	83 c0 01             	add    $0x1,%eax
  8011a6:	8b 1c 85 d4 2a 80 00 	mov    0x802ad4(,%eax,4),%ebx
  8011ad:	85 db                	test   %ebx,%ebx
  8011af:	75 ee                	jne    80119f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b6:	8b 40 48             	mov    0x48(%eax),%eax
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	52                   	push   %edx
  8011bd:	50                   	push   %eax
  8011be:	68 58 2a 80 00       	push   $0x802a58
  8011c3:	e8 56 f0 ff ff       	call   80021e <cprintf>
	*dev = 0;
	return -E_INVAL;
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8011d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d3:	89 1a                	mov    %ebx,(%edx)
}
  8011d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    
			return 0;
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
  8011df:	eb ef                	jmp    8011d0 <dev_lookup+0x45>

008011e1 <fd_close>:
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 24             	sub    $0x24,%esp
  8011ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011fa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011fd:	50                   	push   %eax
  8011fe:	e8 38 ff ff ff       	call   80113b <fd_lookup>
  801203:	89 c3                	mov    %eax,%ebx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 05                	js     801211 <fd_close+0x30>
	    || fd != fd2)
  80120c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80120f:	74 16                	je     801227 <fd_close+0x46>
		return (must_exist ? r : 0);
  801211:	89 f8                	mov    %edi,%eax
  801213:	84 c0                	test   %al,%al
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
  80121a:	0f 44 d8             	cmove  %eax,%ebx
}
  80121d:	89 d8                	mov    %ebx,%eax
  80121f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	ff 36                	push   (%esi)
  801230:	e8 56 ff ff ff       	call   80118b <dev_lookup>
  801235:	89 c3                	mov    %eax,%ebx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 1a                	js     801258 <fd_close+0x77>
		if (dev->dev_close)
  80123e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801241:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801244:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801249:	85 c0                	test   %eax,%eax
  80124b:	74 0b                	je     801258 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	56                   	push   %esi
  801251:	ff d0                	call   *%eax
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	56                   	push   %esi
  80125c:	6a 00                	push   $0x0
  80125e:	e8 16 fa ff ff       	call   800c79 <sys_page_unmap>
	return r;
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb b5                	jmp    80121d <fd_close+0x3c>

00801268 <close>:

int
close(int fdnum)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	ff 75 08             	push   0x8(%ebp)
  801275:	e8 c1 fe ff ff       	call   80113b <fd_lookup>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	79 02                	jns    801283 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    
		return fd_close(fd, 1);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	6a 01                	push   $0x1
  801288:	ff 75 f4             	push   -0xc(%ebp)
  80128b:	e8 51 ff ff ff       	call   8011e1 <fd_close>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	eb ec                	jmp    801281 <close+0x19>

00801295 <close_all>:

void
close_all(void)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	53                   	push   %ebx
  801299:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80129c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	53                   	push   %ebx
  8012a5:	e8 be ff ff ff       	call   801268 <close>
	for (i = 0; i < MAXFD; i++)
  8012aa:	83 c3 01             	add    $0x1,%ebx
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	83 fb 20             	cmp    $0x20,%ebx
  8012b3:	75 ec                	jne    8012a1 <close_all+0xc>
}
  8012b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	57                   	push   %edi
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	ff 75 08             	push   0x8(%ebp)
  8012ca:	e8 6c fe ff ff       	call   80113b <fd_lookup>
  8012cf:	89 c3                	mov    %eax,%ebx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 7f                	js     801357 <dup+0x9d>
		return r;
	close(newfdnum);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	ff 75 0c             	push   0xc(%ebp)
  8012de:	e8 85 ff ff ff       	call   801268 <close>

	newfd = INDEX2FD(newfdnum);
  8012e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012e6:	c1 e6 0c             	shl    $0xc,%esi
  8012e9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f2:	89 3c 24             	mov    %edi,(%esp)
  8012f5:	e8 da fd ff ff       	call   8010d4 <fd2data>
  8012fa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012fc:	89 34 24             	mov    %esi,(%esp)
  8012ff:	e8 d0 fd ff ff       	call   8010d4 <fd2data>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80130a:	89 d8                	mov    %ebx,%eax
  80130c:	c1 e8 16             	shr    $0x16,%eax
  80130f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801316:	a8 01                	test   $0x1,%al
  801318:	74 11                	je     80132b <dup+0x71>
  80131a:	89 d8                	mov    %ebx,%eax
  80131c:	c1 e8 0c             	shr    $0xc,%eax
  80131f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801326:	f6 c2 01             	test   $0x1,%dl
  801329:	75 36                	jne    801361 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132b:	89 f8                	mov    %edi,%eax
  80132d:	c1 e8 0c             	shr    $0xc,%eax
  801330:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	25 07 0e 00 00       	and    $0xe07,%eax
  80133f:	50                   	push   %eax
  801340:	56                   	push   %esi
  801341:	6a 00                	push   $0x0
  801343:	57                   	push   %edi
  801344:	6a 00                	push   $0x0
  801346:	e8 ec f8 ff ff       	call   800c37 <sys_page_map>
  80134b:	89 c3                	mov    %eax,%ebx
  80134d:	83 c4 20             	add    $0x20,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 33                	js     801387 <dup+0xcd>
		goto err;

	return newfdnum;
  801354:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801357:	89 d8                	mov    %ebx,%eax
  801359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135c:	5b                   	pop    %ebx
  80135d:	5e                   	pop    %esi
  80135e:	5f                   	pop    %edi
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801361:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	25 07 0e 00 00       	and    $0xe07,%eax
  801370:	50                   	push   %eax
  801371:	ff 75 d4             	push   -0x2c(%ebp)
  801374:	6a 00                	push   $0x0
  801376:	53                   	push   %ebx
  801377:	6a 00                	push   $0x0
  801379:	e8 b9 f8 ff ff       	call   800c37 <sys_page_map>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 20             	add    $0x20,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	79 a4                	jns    80132b <dup+0x71>
	sys_page_unmap(0, newfd);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	56                   	push   %esi
  80138b:	6a 00                	push   $0x0
  80138d:	e8 e7 f8 ff ff       	call   800c79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	ff 75 d4             	push   -0x2c(%ebp)
  801398:	6a 00                	push   $0x0
  80139a:	e8 da f8 ff ff       	call   800c79 <sys_page_unmap>
	return r;
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	eb b3                	jmp    801357 <dup+0x9d>

008013a4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 18             	sub    $0x18,%esp
  8013ac:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	56                   	push   %esi
  8013b4:	e8 82 fd ff ff       	call   80113b <fd_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 3c                	js     8013fc <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	ff 33                	push   (%ebx)
  8013cc:	e8 ba fd ff ff       	call   80118b <dev_lookup>
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 24                	js     8013fc <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d8:	8b 43 08             	mov    0x8(%ebx),%eax
  8013db:	83 e0 03             	and    $0x3,%eax
  8013de:	83 f8 01             	cmp    $0x1,%eax
  8013e1:	74 20                	je     801403 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e6:	8b 40 08             	mov    0x8(%eax),%eax
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	74 37                	je     801424 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ed:	83 ec 04             	sub    $0x4,%esp
  8013f0:	ff 75 10             	push   0x10(%ebp)
  8013f3:	ff 75 0c             	push   0xc(%ebp)
  8013f6:	53                   	push   %ebx
  8013f7:	ff d0                	call   *%eax
  8013f9:	83 c4 10             	add    $0x10,%esp
}
  8013fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801403:	a1 04 40 80 00       	mov    0x804004,%eax
  801408:	8b 40 48             	mov    0x48(%eax),%eax
  80140b:	83 ec 04             	sub    $0x4,%esp
  80140e:	56                   	push   %esi
  80140f:	50                   	push   %eax
  801410:	68 99 2a 80 00       	push   $0x802a99
  801415:	e8 04 ee ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801422:	eb d8                	jmp    8013fc <read+0x58>
		return -E_NOT_SUPP;
  801424:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801429:	eb d1                	jmp    8013fc <read+0x58>

0080142b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	57                   	push   %edi
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	83 ec 0c             	sub    $0xc,%esp
  801434:	8b 7d 08             	mov    0x8(%ebp),%edi
  801437:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143f:	eb 02                	jmp    801443 <readn+0x18>
  801441:	01 c3                	add    %eax,%ebx
  801443:	39 f3                	cmp    %esi,%ebx
  801445:	73 21                	jae    801468 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	89 f0                	mov    %esi,%eax
  80144c:	29 d8                	sub    %ebx,%eax
  80144e:	50                   	push   %eax
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	03 45 0c             	add    0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	57                   	push   %edi
  801456:	e8 49 ff ff ff       	call   8013a4 <read>
		if (m < 0)
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 04                	js     801466 <readn+0x3b>
			return m;
		if (m == 0)
  801462:	75 dd                	jne    801441 <readn+0x16>
  801464:	eb 02                	jmp    801468 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801466:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	56                   	push   %esi
  801476:	53                   	push   %ebx
  801477:	83 ec 18             	sub    $0x18,%esp
  80147a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	53                   	push   %ebx
  801482:	e8 b4 fc ff ff       	call   80113b <fd_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 37                	js     8014c5 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	ff 36                	push   (%esi)
  80149a:	e8 ec fc ff ff       	call   80118b <dev_lookup>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 1f                	js     8014c5 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014aa:	74 20                	je     8014cc <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014af:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	74 37                	je     8014ed <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b6:	83 ec 04             	sub    $0x4,%esp
  8014b9:	ff 75 10             	push   0x10(%ebp)
  8014bc:	ff 75 0c             	push   0xc(%ebp)
  8014bf:	56                   	push   %esi
  8014c0:	ff d0                	call   *%eax
  8014c2:	83 c4 10             	add    $0x10,%esp
}
  8014c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d1:	8b 40 48             	mov    0x48(%eax),%eax
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	53                   	push   %ebx
  8014d8:	50                   	push   %eax
  8014d9:	68 b5 2a 80 00       	push   $0x802ab5
  8014de:	e8 3b ed ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014eb:	eb d8                	jmp    8014c5 <write+0x53>
		return -E_NOT_SUPP;
  8014ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f2:	eb d1                	jmp    8014c5 <write+0x53>

008014f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	ff 75 08             	push   0x8(%ebp)
  801501:	e8 35 fc ff ff       	call   80113b <fd_lookup>
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 0e                	js     80151b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80150d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801513:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 18             	sub    $0x18,%esp
  801525:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801528:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	53                   	push   %ebx
  80152d:	e8 09 fc ff ff       	call   80113b <fd_lookup>
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 34                	js     80156d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801539:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	ff 36                	push   (%esi)
  801545:	e8 41 fc ff ff       	call   80118b <dev_lookup>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 1c                	js     80156d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801551:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801555:	74 1d                	je     801574 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155a:	8b 40 18             	mov    0x18(%eax),%eax
  80155d:	85 c0                	test   %eax,%eax
  80155f:	74 34                	je     801595 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	ff 75 0c             	push   0xc(%ebp)
  801567:	56                   	push   %esi
  801568:	ff d0                	call   *%eax
  80156a:	83 c4 10             	add    $0x10,%esp
}
  80156d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801570:	5b                   	pop    %ebx
  801571:	5e                   	pop    %esi
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    
			thisenv->env_id, fdnum);
  801574:	a1 04 40 80 00       	mov    0x804004,%eax
  801579:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	53                   	push   %ebx
  801580:	50                   	push   %eax
  801581:	68 78 2a 80 00       	push   $0x802a78
  801586:	e8 93 ec ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801593:	eb d8                	jmp    80156d <ftruncate+0x50>
		return -E_NOT_SUPP;
  801595:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80159a:	eb d1                	jmp    80156d <ftruncate+0x50>

0080159c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 18             	sub    $0x18,%esp
  8015a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	ff 75 08             	push   0x8(%ebp)
  8015ae:	e8 88 fb ff ff       	call   80113b <fd_lookup>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 49                	js     801603 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	ff 36                	push   (%esi)
  8015c6:	e8 c0 fb ff ff       	call   80118b <dev_lookup>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 31                	js     801603 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d9:	74 2f                	je     80160a <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e5:	00 00 00 
	stat->st_isdir = 0;
  8015e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ef:	00 00 00 
	stat->st_dev = dev;
  8015f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	56                   	push   %esi
  8015fd:	ff 50 14             	call   *0x14(%eax)
  801600:	83 c4 10             	add    $0x10,%esp
}
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    
		return -E_NOT_SUPP;
  80160a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160f:	eb f2                	jmp    801603 <fstat+0x67>

00801611 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	6a 00                	push   $0x0
  80161b:	ff 75 08             	push   0x8(%ebp)
  80161e:	e8 e4 01 00 00       	call   801807 <open>
  801623:	89 c3                	mov    %eax,%ebx
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 1b                	js     801647 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	ff 75 0c             	push   0xc(%ebp)
  801632:	50                   	push   %eax
  801633:	e8 64 ff ff ff       	call   80159c <fstat>
  801638:	89 c6                	mov    %eax,%esi
	close(fd);
  80163a:	89 1c 24             	mov    %ebx,(%esp)
  80163d:	e8 26 fc ff ff       	call   801268 <close>
	return r;
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	89 f3                	mov    %esi,%ebx
}
  801647:	89 d8                	mov    %ebx,%eax
  801649:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	56                   	push   %esi
  801654:	53                   	push   %ebx
  801655:	89 c6                	mov    %eax,%esi
  801657:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801659:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801660:	74 27                	je     801689 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801662:	6a 07                	push   $0x7
  801664:	68 00 50 80 00       	push   $0x805000
  801669:	56                   	push   %esi
  80166a:	ff 35 00 60 80 00    	push   0x806000
  801670:	e8 60 0c 00 00       	call   8022d5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801675:	83 c4 0c             	add    $0xc,%esp
  801678:	6a 00                	push   $0x0
  80167a:	53                   	push   %ebx
  80167b:	6a 00                	push   $0x0
  80167d:	e8 ec 0b 00 00       	call   80226e <ipc_recv>
}
  801682:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	6a 01                	push   $0x1
  80168e:	e8 96 0c 00 00       	call   802329 <ipc_find_env>
  801693:	a3 00 60 80 00       	mov    %eax,0x806000
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	eb c5                	jmp    801662 <fsipc+0x12>

0080169d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c0:	e8 8b ff ff ff       	call   801650 <fsipc>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <devfile_flush>:
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e2:	e8 69 ff ff ff       	call   801650 <fsipc>
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <devfile_stat>:
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 05 00 00 00       	mov    $0x5,%eax
  801708:	e8 43 ff ff ff       	call   801650 <fsipc>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 2c                	js     80173d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	68 00 50 80 00       	push   $0x805000
  801719:	53                   	push   %ebx
  80171a:	e8 d9 f0 ff ff       	call   8007f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171f:	a1 80 50 80 00       	mov    0x805080,%eax
  801724:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172a:	a1 84 50 80 00       	mov    0x805084,%eax
  80172f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devfile_write>:
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 0c             	sub    $0xc,%esp
  801748:	8b 45 10             	mov    0x10(%ebp),%eax
  80174b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801750:	39 d0                	cmp    %edx,%eax
  801752:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801755:	8b 55 08             	mov    0x8(%ebp),%edx
  801758:	8b 52 0c             	mov    0xc(%edx),%edx
  80175b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801761:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801766:	50                   	push   %eax
  801767:	ff 75 0c             	push   0xc(%ebp)
  80176a:	68 08 50 80 00       	push   $0x805008
  80176f:	e8 1a f2 ff ff       	call   80098e <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	b8 04 00 00 00       	mov    $0x4,%eax
  80177e:	e8 cd fe ff ff       	call   801650 <fsipc>
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <devfile_read>:
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	8b 40 0c             	mov    0xc(%eax),%eax
  801793:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801798:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179e:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a8:	e8 a3 fe ff ff       	call   801650 <fsipc>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 1f                	js     8017d2 <devfile_read+0x4d>
	assert(r <= n);
  8017b3:	39 f0                	cmp    %esi,%eax
  8017b5:	77 24                	ja     8017db <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017bc:	7f 33                	jg     8017f1 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	50                   	push   %eax
  8017c2:	68 00 50 80 00       	push   $0x805000
  8017c7:	ff 75 0c             	push   0xc(%ebp)
  8017ca:	e8 bf f1 ff ff       	call   80098e <memmove>
	return r;
  8017cf:	83 c4 10             	add    $0x10,%esp
}
  8017d2:	89 d8                	mov    %ebx,%eax
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    
	assert(r <= n);
  8017db:	68 e8 2a 80 00       	push   $0x802ae8
  8017e0:	68 ef 2a 80 00       	push   $0x802aef
  8017e5:	6a 7c                	push   $0x7c
  8017e7:	68 04 2b 80 00       	push   $0x802b04
  8017ec:	e8 52 e9 ff ff       	call   800143 <_panic>
	assert(r <= PGSIZE);
  8017f1:	68 0f 2b 80 00       	push   $0x802b0f
  8017f6:	68 ef 2a 80 00       	push   $0x802aef
  8017fb:	6a 7d                	push   $0x7d
  8017fd:	68 04 2b 80 00       	push   $0x802b04
  801802:	e8 3c e9 ff ff       	call   800143 <_panic>

00801807 <open>:
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	83 ec 1c             	sub    $0x1c,%esp
  80180f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801812:	56                   	push   %esi
  801813:	e8 a5 ef ff ff       	call   8007bd <strlen>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801820:	7f 6c                	jg     80188e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	e8 bd f8 ff ff       	call   8010eb <fd_alloc>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 3c                	js     801873 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	56                   	push   %esi
  80183b:	68 00 50 80 00       	push   $0x805000
  801840:	e8 b3 ef ff ff       	call   8007f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801850:	b8 01 00 00 00       	mov    $0x1,%eax
  801855:	e8 f6 fd ff ff       	call   801650 <fsipc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 19                	js     80187c <open+0x75>
	return fd2num(fd);
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	ff 75 f4             	push   -0xc(%ebp)
  801869:	e8 56 f8 ff ff       	call   8010c4 <fd2num>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 10             	add    $0x10,%esp
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    
		fd_close(fd, 0);
  80187c:	83 ec 08             	sub    $0x8,%esp
  80187f:	6a 00                	push   $0x0
  801881:	ff 75 f4             	push   -0xc(%ebp)
  801884:	e8 58 f9 ff ff       	call   8011e1 <fd_close>
		return r;
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	eb e5                	jmp    801873 <open+0x6c>
		return -E_BAD_PATH;
  80188e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801893:	eb de                	jmp    801873 <open+0x6c>

00801895 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a5:	e8 a6 fd ff ff       	call   801650 <fsipc>
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018b2:	68 1b 2b 80 00       	push   $0x802b1b
  8018b7:	ff 75 0c             	push   0xc(%ebp)
  8018ba:	e8 39 ef ff ff       	call   8007f8 <strcpy>
	return 0;
}
  8018bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <devsock_close>:
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 10             	sub    $0x10,%esp
  8018cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018d0:	53                   	push   %ebx
  8018d1:	e8 8c 0a 00 00       	call   802362 <pageref>
  8018d6:	89 c2                	mov    %eax,%edx
  8018d8:	83 c4 10             	add    $0x10,%esp
		return 0;
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8018e0:	83 fa 01             	cmp    $0x1,%edx
  8018e3:	74 05                	je     8018ea <devsock_close+0x24>
}
  8018e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	ff 73 0c             	push   0xc(%ebx)
  8018f0:	e8 b7 02 00 00       	call   801bac <nsipc_close>
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	eb eb                	jmp    8018e5 <devsock_close+0x1f>

008018fa <devsock_write>:
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801900:	6a 00                	push   $0x0
  801902:	ff 75 10             	push   0x10(%ebp)
  801905:	ff 75 0c             	push   0xc(%ebp)
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	ff 70 0c             	push   0xc(%eax)
  80190e:	e8 79 03 00 00       	call   801c8c <nsipc_send>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devsock_read>:
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80191b:	6a 00                	push   $0x0
  80191d:	ff 75 10             	push   0x10(%ebp)
  801920:	ff 75 0c             	push   0xc(%ebp)
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	ff 70 0c             	push   0xc(%eax)
  801929:	e8 ef 02 00 00       	call   801c1d <nsipc_recv>
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <fd2sockid>:
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801936:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801939:	52                   	push   %edx
  80193a:	50                   	push   %eax
  80193b:	e8 fb f7 ff ff       	call   80113b <fd_lookup>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	78 10                	js     801957 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801950:	39 08                	cmp    %ecx,(%eax)
  801952:	75 05                	jne    801959 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801954:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    
		return -E_NOT_SUPP;
  801959:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80195e:	eb f7                	jmp    801957 <fd2sockid+0x27>

00801960 <alloc_sockfd>:
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	83 ec 1c             	sub    $0x1c,%esp
  801968:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80196a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	e8 78 f7 ff ff       	call   8010eb <fd_alloc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 43                	js     8019bf <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80197c:	83 ec 04             	sub    $0x4,%esp
  80197f:	68 07 04 00 00       	push   $0x407
  801984:	ff 75 f4             	push   -0xc(%ebp)
  801987:	6a 00                	push   $0x0
  801989:	e8 66 f2 ff ff       	call   800bf4 <sys_page_alloc>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	78 28                	js     8019bf <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019a0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019ac:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	50                   	push   %eax
  8019b3:	e8 0c f7 ff ff       	call   8010c4 <fd2num>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	eb 0c                	jmp    8019cb <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	56                   	push   %esi
  8019c3:	e8 e4 01 00 00       	call   801bac <nsipc_close>
		return r;
  8019c8:	83 c4 10             	add    $0x10,%esp
}
  8019cb:	89 d8                	mov    %ebx,%eax
  8019cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <accept>:
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019da:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dd:	e8 4e ff ff ff       	call   801930 <fd2sockid>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 1b                	js     801a01 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019e6:	83 ec 04             	sub    $0x4,%esp
  8019e9:	ff 75 10             	push   0x10(%ebp)
  8019ec:	ff 75 0c             	push   0xc(%ebp)
  8019ef:	50                   	push   %eax
  8019f0:	e8 0e 01 00 00       	call   801b03 <nsipc_accept>
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 05                	js     801a01 <accept+0x2d>
	return alloc_sockfd(r);
  8019fc:	e8 5f ff ff ff       	call   801960 <alloc_sockfd>
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <bind>:
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	e8 1f ff ff ff       	call   801930 <fd2sockid>
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 12                	js     801a27 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	ff 75 10             	push   0x10(%ebp)
  801a1b:	ff 75 0c             	push   0xc(%ebp)
  801a1e:	50                   	push   %eax
  801a1f:	e8 31 01 00 00       	call   801b55 <nsipc_bind>
  801a24:	83 c4 10             	add    $0x10,%esp
}
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <shutdown>:
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	e8 f9 fe ff ff       	call   801930 <fd2sockid>
  801a37:	85 c0                	test   %eax,%eax
  801a39:	78 0f                	js     801a4a <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801a3b:	83 ec 08             	sub    $0x8,%esp
  801a3e:	ff 75 0c             	push   0xc(%ebp)
  801a41:	50                   	push   %eax
  801a42:	e8 43 01 00 00       	call   801b8a <nsipc_shutdown>
  801a47:	83 c4 10             	add    $0x10,%esp
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <connect>:
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a52:	8b 45 08             	mov    0x8(%ebp),%eax
  801a55:	e8 d6 fe ff ff       	call   801930 <fd2sockid>
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 12                	js     801a70 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801a5e:	83 ec 04             	sub    $0x4,%esp
  801a61:	ff 75 10             	push   0x10(%ebp)
  801a64:	ff 75 0c             	push   0xc(%ebp)
  801a67:	50                   	push   %eax
  801a68:	e8 59 01 00 00       	call   801bc6 <nsipc_connect>
  801a6d:	83 c4 10             	add    $0x10,%esp
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <listen>:
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	e8 b0 fe ff ff       	call   801930 <fd2sockid>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 0f                	js     801a93 <listen+0x21>
	return nsipc_listen(r, backlog);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	ff 75 0c             	push   0xc(%ebp)
  801a8a:	50                   	push   %eax
  801a8b:	e8 6b 01 00 00       	call   801bfb <nsipc_listen>
  801a90:	83 c4 10             	add    $0x10,%esp
}
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a9b:	ff 75 10             	push   0x10(%ebp)
  801a9e:	ff 75 0c             	push   0xc(%ebp)
  801aa1:	ff 75 08             	push   0x8(%ebp)
  801aa4:	e8 41 02 00 00       	call   801cea <nsipc_socket>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 05                	js     801ab5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ab0:	e8 ab fe ff ff       	call   801960 <alloc_sockfd>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ac0:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801ac7:	74 26                	je     801aef <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ac9:	6a 07                	push   $0x7
  801acb:	68 00 70 80 00       	push   $0x807000
  801ad0:	53                   	push   %ebx
  801ad1:	ff 35 00 80 80 00    	push   0x808000
  801ad7:	e8 f9 07 00 00       	call   8022d5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801adc:	83 c4 0c             	add    $0xc,%esp
  801adf:	6a 00                	push   $0x0
  801ae1:	6a 00                	push   $0x0
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 84 07 00 00       	call   80226e <ipc_recv>
}
  801aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	6a 02                	push   $0x2
  801af4:	e8 30 08 00 00       	call   802329 <ipc_find_env>
  801af9:	a3 00 80 80 00       	mov    %eax,0x808000
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	eb c6                	jmp    801ac9 <nsipc+0x12>

00801b03 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	56                   	push   %esi
  801b07:	53                   	push   %ebx
  801b08:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b13:	8b 06                	mov    (%esi),%eax
  801b15:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1f:	e8 93 ff ff ff       	call   801ab7 <nsipc>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	85 c0                	test   %eax,%eax
  801b28:	79 09                	jns    801b33 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801b2a:	89 d8                	mov    %ebx,%eax
  801b2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	ff 35 10 70 80 00    	push   0x807010
  801b3c:	68 00 70 80 00       	push   $0x807000
  801b41:	ff 75 0c             	push   0xc(%ebp)
  801b44:	e8 45 ee ff ff       	call   80098e <memmove>
		*addrlen = ret->ret_addrlen;
  801b49:	a1 10 70 80 00       	mov    0x807010,%eax
  801b4e:	89 06                	mov    %eax,(%esi)
  801b50:	83 c4 10             	add    $0x10,%esp
	return r;
  801b53:	eb d5                	jmp    801b2a <nsipc_accept+0x27>

00801b55 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	53                   	push   %ebx
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b67:	53                   	push   %ebx
  801b68:	ff 75 0c             	push   0xc(%ebp)
  801b6b:	68 04 70 80 00       	push   $0x807004
  801b70:	e8 19 ee ff ff       	call   80098e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b75:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  801b80:	e8 32 ff ff ff       	call   801ab7 <nsipc>
}
  801b85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b90:	8b 45 08             	mov    0x8(%ebp),%eax
  801b93:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ba0:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba5:	e8 0d ff ff ff       	call   801ab7 <nsipc>
}
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <nsipc_close>:

int
nsipc_close(int s)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb5:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801bba:	b8 04 00 00 00       	mov    $0x4,%eax
  801bbf:	e8 f3 fe ff ff       	call   801ab7 <nsipc>
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	53                   	push   %ebx
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bd8:	53                   	push   %ebx
  801bd9:	ff 75 0c             	push   0xc(%ebp)
  801bdc:	68 04 70 80 00       	push   $0x807004
  801be1:	e8 a8 ed ff ff       	call   80098e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801be6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801bec:	b8 05 00 00 00       	mov    $0x5,%eax
  801bf1:	e8 c1 fe ff ff       	call   801ab7 <nsipc>
}
  801bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801c09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801c11:	b8 06 00 00 00       	mov    $0x6,%eax
  801c16:	e8 9c fe ff ff       	call   801ab7 <nsipc>
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801c2d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801c33:	8b 45 14             	mov    0x14(%ebp),%eax
  801c36:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c3b:	b8 07 00 00 00       	mov    $0x7,%eax
  801c40:	e8 72 fe ff ff       	call   801ab7 <nsipc>
  801c45:	89 c3                	mov    %eax,%ebx
  801c47:	85 c0                	test   %eax,%eax
  801c49:	78 22                	js     801c6d <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801c4b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c50:	39 c6                	cmp    %eax,%esi
  801c52:	0f 4e c6             	cmovle %esi,%eax
  801c55:	39 c3                	cmp    %eax,%ebx
  801c57:	7f 1d                	jg     801c76 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	53                   	push   %ebx
  801c5d:	68 00 70 80 00       	push   $0x807000
  801c62:	ff 75 0c             	push   0xc(%ebp)
  801c65:	e8 24 ed ff ff       	call   80098e <memmove>
  801c6a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c6d:	89 d8                	mov    %ebx,%eax
  801c6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5e                   	pop    %esi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c76:	68 27 2b 80 00       	push   $0x802b27
  801c7b:	68 ef 2a 80 00       	push   $0x802aef
  801c80:	6a 62                	push   $0x62
  801c82:	68 3c 2b 80 00       	push   $0x802b3c
  801c87:	e8 b7 e4 ff ff       	call   800143 <_panic>

00801c8c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	53                   	push   %ebx
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c9e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ca4:	7f 2e                	jg     801cd4 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	53                   	push   %ebx
  801caa:	ff 75 0c             	push   0xc(%ebp)
  801cad:	68 0c 70 80 00       	push   $0x80700c
  801cb2:	e8 d7 ec ff ff       	call   80098e <memmove>
	nsipcbuf.send.req_size = size;
  801cb7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801cbd:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801cc5:	b8 08 00 00 00       	mov    $0x8,%eax
  801cca:	e8 e8 fd ff ff       	call   801ab7 <nsipc>
}
  801ccf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    
	assert(size < 1600);
  801cd4:	68 48 2b 80 00       	push   $0x802b48
  801cd9:	68 ef 2a 80 00       	push   $0x802aef
  801cde:	6a 6d                	push   $0x6d
  801ce0:	68 3c 2b 80 00       	push   $0x802b3c
  801ce5:	e8 59 e4 ff ff       	call   800143 <_panic>

00801cea <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfb:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801d00:	8b 45 10             	mov    0x10(%ebp),%eax
  801d03:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801d08:	b8 09 00 00 00       	mov    $0x9,%eax
  801d0d:	e8 a5 fd ff ff       	call   801ab7 <nsipc>
}
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	ff 75 08             	push   0x8(%ebp)
  801d22:	e8 ad f3 ff ff       	call   8010d4 <fd2data>
  801d27:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d29:	83 c4 08             	add    $0x8,%esp
  801d2c:	68 54 2b 80 00       	push   $0x802b54
  801d31:	53                   	push   %ebx
  801d32:	e8 c1 ea ff ff       	call   8007f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d37:	8b 46 04             	mov    0x4(%esi),%eax
  801d3a:	2b 06                	sub    (%esi),%eax
  801d3c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d42:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d49:	00 00 00 
	stat->st_dev = &devpipe;
  801d4c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d53:	30 80 00 
	return 0;
}
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	53                   	push   %ebx
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d6c:	53                   	push   %ebx
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 05 ef ff ff       	call   800c79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d74:	89 1c 24             	mov    %ebx,(%esp)
  801d77:	e8 58 f3 ff ff       	call   8010d4 <fd2data>
  801d7c:	83 c4 08             	add    $0x8,%esp
  801d7f:	50                   	push   %eax
  801d80:	6a 00                	push   $0x0
  801d82:	e8 f2 ee ff ff       	call   800c79 <sys_page_unmap>
}
  801d87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <_pipeisclosed>:
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 1c             	sub    $0x1c,%esp
  801d95:	89 c7                	mov    %eax,%edi
  801d97:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d99:	a1 04 40 80 00       	mov    0x804004,%eax
  801d9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801da1:	83 ec 0c             	sub    $0xc,%esp
  801da4:	57                   	push   %edi
  801da5:	e8 b8 05 00 00       	call   802362 <pageref>
  801daa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801dad:	89 34 24             	mov    %esi,(%esp)
  801db0:	e8 ad 05 00 00       	call   802362 <pageref>
		nn = thisenv->env_runs;
  801db5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dbb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	39 cb                	cmp    %ecx,%ebx
  801dc3:	74 1b                	je     801de0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801dc5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dc8:	75 cf                	jne    801d99 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dca:	8b 42 58             	mov    0x58(%edx),%eax
  801dcd:	6a 01                	push   $0x1
  801dcf:	50                   	push   %eax
  801dd0:	53                   	push   %ebx
  801dd1:	68 5b 2b 80 00       	push   $0x802b5b
  801dd6:	e8 43 e4 ff ff       	call   80021e <cprintf>
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	eb b9                	jmp    801d99 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801de0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801de3:	0f 94 c0             	sete   %al
  801de6:	0f b6 c0             	movzbl %al,%eax
}
  801de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devpipe_write>:
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	83 ec 28             	sub    $0x28,%esp
  801dfa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dfd:	56                   	push   %esi
  801dfe:	e8 d1 f2 ff ff       	call   8010d4 <fd2data>
  801e03:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	bf 00 00 00 00       	mov    $0x0,%edi
  801e0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e10:	75 09                	jne    801e1b <devpipe_write+0x2a>
	return i;
  801e12:	89 f8                	mov    %edi,%eax
  801e14:	eb 23                	jmp    801e39 <devpipe_write+0x48>
			sys_yield();
  801e16:	e8 ba ed ff ff       	call   800bd5 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e1b:	8b 43 04             	mov    0x4(%ebx),%eax
  801e1e:	8b 0b                	mov    (%ebx),%ecx
  801e20:	8d 51 20             	lea    0x20(%ecx),%edx
  801e23:	39 d0                	cmp    %edx,%eax
  801e25:	72 1a                	jb     801e41 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801e27:	89 da                	mov    %ebx,%edx
  801e29:	89 f0                	mov    %esi,%eax
  801e2b:	e8 5c ff ff ff       	call   801d8c <_pipeisclosed>
  801e30:	85 c0                	test   %eax,%eax
  801e32:	74 e2                	je     801e16 <devpipe_write+0x25>
				return 0;
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5f                   	pop    %edi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e44:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e48:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e4b:	89 c2                	mov    %eax,%edx
  801e4d:	c1 fa 1f             	sar    $0x1f,%edx
  801e50:	89 d1                	mov    %edx,%ecx
  801e52:	c1 e9 1b             	shr    $0x1b,%ecx
  801e55:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e58:	83 e2 1f             	and    $0x1f,%edx
  801e5b:	29 ca                	sub    %ecx,%edx
  801e5d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e65:	83 c0 01             	add    $0x1,%eax
  801e68:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e6b:	83 c7 01             	add    $0x1,%edi
  801e6e:	eb 9d                	jmp    801e0d <devpipe_write+0x1c>

00801e70 <devpipe_read>:
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	57                   	push   %edi
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
  801e76:	83 ec 18             	sub    $0x18,%esp
  801e79:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e7c:	57                   	push   %edi
  801e7d:	e8 52 f2 ff ff       	call   8010d4 <fd2data>
  801e82:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	be 00 00 00 00       	mov    $0x0,%esi
  801e8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e8f:	75 13                	jne    801ea4 <devpipe_read+0x34>
	return i;
  801e91:	89 f0                	mov    %esi,%eax
  801e93:	eb 02                	jmp    801e97 <devpipe_read+0x27>
				return i;
  801e95:	89 f0                	mov    %esi,%eax
}
  801e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9a:	5b                   	pop    %ebx
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    
			sys_yield();
  801e9f:	e8 31 ed ff ff       	call   800bd5 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ea4:	8b 03                	mov    (%ebx),%eax
  801ea6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ea9:	75 18                	jne    801ec3 <devpipe_read+0x53>
			if (i > 0)
  801eab:	85 f6                	test   %esi,%esi
  801ead:	75 e6                	jne    801e95 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801eaf:	89 da                	mov    %ebx,%edx
  801eb1:	89 f8                	mov    %edi,%eax
  801eb3:	e8 d4 fe ff ff       	call   801d8c <_pipeisclosed>
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	74 e3                	je     801e9f <devpipe_read+0x2f>
				return 0;
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec1:	eb d4                	jmp    801e97 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ec3:	99                   	cltd   
  801ec4:	c1 ea 1b             	shr    $0x1b,%edx
  801ec7:	01 d0                	add    %edx,%eax
  801ec9:	83 e0 1f             	and    $0x1f,%eax
  801ecc:	29 d0                	sub    %edx,%eax
  801ece:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ed9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801edc:	83 c6 01             	add    $0x1,%esi
  801edf:	eb ab                	jmp    801e8c <devpipe_read+0x1c>

00801ee1 <pipe>:
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	56                   	push   %esi
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ee9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eec:	50                   	push   %eax
  801eed:	e8 f9 f1 ff ff       	call   8010eb <fd_alloc>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	0f 88 23 01 00 00    	js     802022 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eff:	83 ec 04             	sub    $0x4,%esp
  801f02:	68 07 04 00 00       	push   $0x407
  801f07:	ff 75 f4             	push   -0xc(%ebp)
  801f0a:	6a 00                	push   $0x0
  801f0c:	e8 e3 ec ff ff       	call   800bf4 <sys_page_alloc>
  801f11:	89 c3                	mov    %eax,%ebx
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	85 c0                	test   %eax,%eax
  801f18:	0f 88 04 01 00 00    	js     802022 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801f1e:	83 ec 0c             	sub    $0xc,%esp
  801f21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	e8 c1 f1 ff ff       	call   8010eb <fd_alloc>
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	0f 88 db 00 00 00    	js     802012 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f37:	83 ec 04             	sub    $0x4,%esp
  801f3a:	68 07 04 00 00       	push   $0x407
  801f3f:	ff 75 f0             	push   -0x10(%ebp)
  801f42:	6a 00                	push   $0x0
  801f44:	e8 ab ec ff ff       	call   800bf4 <sys_page_alloc>
  801f49:	89 c3                	mov    %eax,%ebx
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	0f 88 bc 00 00 00    	js     802012 <pipe+0x131>
	va = fd2data(fd0);
  801f56:	83 ec 0c             	sub    $0xc,%esp
  801f59:	ff 75 f4             	push   -0xc(%ebp)
  801f5c:	e8 73 f1 ff ff       	call   8010d4 <fd2data>
  801f61:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f63:	83 c4 0c             	add    $0xc,%esp
  801f66:	68 07 04 00 00       	push   $0x407
  801f6b:	50                   	push   %eax
  801f6c:	6a 00                	push   $0x0
  801f6e:	e8 81 ec ff ff       	call   800bf4 <sys_page_alloc>
  801f73:	89 c3                	mov    %eax,%ebx
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	0f 88 82 00 00 00    	js     802002 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	ff 75 f0             	push   -0x10(%ebp)
  801f86:	e8 49 f1 ff ff       	call   8010d4 <fd2data>
  801f8b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f92:	50                   	push   %eax
  801f93:	6a 00                	push   $0x0
  801f95:	56                   	push   %esi
  801f96:	6a 00                	push   $0x0
  801f98:	e8 9a ec ff ff       	call   800c37 <sys_page_map>
  801f9d:	89 c3                	mov    %eax,%ebx
  801f9f:	83 c4 20             	add    $0x20,%esp
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 4e                	js     801ff4 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801fa6:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801fab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fae:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801fb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fb3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801fba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fbd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	ff 75 f4             	push   -0xc(%ebp)
  801fcf:	e8 f0 f0 ff ff       	call   8010c4 <fd2num>
  801fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fd9:	83 c4 04             	add    $0x4,%esp
  801fdc:	ff 75 f0             	push   -0x10(%ebp)
  801fdf:	e8 e0 f0 ff ff       	call   8010c4 <fd2num>
  801fe4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff2:	eb 2e                	jmp    802022 <pipe+0x141>
	sys_page_unmap(0, va);
  801ff4:	83 ec 08             	sub    $0x8,%esp
  801ff7:	56                   	push   %esi
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 7a ec ff ff       	call   800c79 <sys_page_unmap>
  801fff:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802002:	83 ec 08             	sub    $0x8,%esp
  802005:	ff 75 f0             	push   -0x10(%ebp)
  802008:	6a 00                	push   $0x0
  80200a:	e8 6a ec ff ff       	call   800c79 <sys_page_unmap>
  80200f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	ff 75 f4             	push   -0xc(%ebp)
  802018:	6a 00                	push   $0x0
  80201a:	e8 5a ec ff ff       	call   800c79 <sys_page_unmap>
  80201f:	83 c4 10             	add    $0x10,%esp
}
  802022:	89 d8                	mov    %ebx,%eax
  802024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    

0080202b <pipeisclosed>:
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	ff 75 08             	push   0x8(%ebp)
  802038:	e8 fe f0 ff ff       	call   80113b <fd_lookup>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	78 18                	js     80205c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	ff 75 f4             	push   -0xc(%ebp)
  80204a:	e8 85 f0 ff ff       	call   8010d4 <fd2data>
  80204f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802054:	e8 33 fd ff ff       	call   801d8c <_pipeisclosed>
  802059:	83 c4 10             	add    $0x10,%esp
}
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
  802063:	c3                   	ret    

00802064 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80206a:	68 73 2b 80 00       	push   $0x802b73
  80206f:	ff 75 0c             	push   0xc(%ebp)
  802072:	e8 81 e7 ff ff       	call   8007f8 <strcpy>
	return 0;
}
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
  80207c:	c9                   	leave  
  80207d:	c3                   	ret    

0080207e <devcons_write>:
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80208a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80208f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802095:	eb 2e                	jmp    8020c5 <devcons_write+0x47>
		m = n - tot;
  802097:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80209a:	29 f3                	sub    %esi,%ebx
  80209c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020a1:	39 c3                	cmp    %eax,%ebx
  8020a3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020a6:	83 ec 04             	sub    $0x4,%esp
  8020a9:	53                   	push   %ebx
  8020aa:	89 f0                	mov    %esi,%eax
  8020ac:	03 45 0c             	add    0xc(%ebp),%eax
  8020af:	50                   	push   %eax
  8020b0:	57                   	push   %edi
  8020b1:	e8 d8 e8 ff ff       	call   80098e <memmove>
		sys_cputs(buf, m);
  8020b6:	83 c4 08             	add    $0x8,%esp
  8020b9:	53                   	push   %ebx
  8020ba:	57                   	push   %edi
  8020bb:	e8 78 ea ff ff       	call   800b38 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020c0:	01 de                	add    %ebx,%esi
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020c8:	72 cd                	jb     802097 <devcons_write+0x19>
}
  8020ca:	89 f0                	mov    %esi,%eax
  8020cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <devcons_read>:
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020e3:	75 07                	jne    8020ec <devcons_read+0x18>
  8020e5:	eb 1f                	jmp    802106 <devcons_read+0x32>
		sys_yield();
  8020e7:	e8 e9 ea ff ff       	call   800bd5 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020ec:	e8 65 ea ff ff       	call   800b56 <sys_cgetc>
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	74 f2                	je     8020e7 <devcons_read+0x13>
	if (c < 0)
  8020f5:	78 0f                	js     802106 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8020f7:	83 f8 04             	cmp    $0x4,%eax
  8020fa:	74 0c                	je     802108 <devcons_read+0x34>
	*(char*)vbuf = c;
  8020fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ff:	88 02                	mov    %al,(%edx)
	return 1;
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    
		return 0;
  802108:	b8 00 00 00 00       	mov    $0x0,%eax
  80210d:	eb f7                	jmp    802106 <devcons_read+0x32>

0080210f <cputchar>:
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802115:	8b 45 08             	mov    0x8(%ebp),%eax
  802118:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80211b:	6a 01                	push   $0x1
  80211d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802120:	50                   	push   %eax
  802121:	e8 12 ea ff ff       	call   800b38 <sys_cputs>
}
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	c9                   	leave  
  80212a:	c3                   	ret    

0080212b <getchar>:
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802131:	6a 01                	push   $0x1
  802133:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802136:	50                   	push   %eax
  802137:	6a 00                	push   $0x0
  802139:	e8 66 f2 ff ff       	call   8013a4 <read>
	if (r < 0)
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	85 c0                	test   %eax,%eax
  802143:	78 06                	js     80214b <getchar+0x20>
	if (r < 1)
  802145:	74 06                	je     80214d <getchar+0x22>
	return c;
  802147:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    
		return -E_EOF;
  80214d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802152:	eb f7                	jmp    80214b <getchar+0x20>

00802154 <iscons>:
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80215a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215d:	50                   	push   %eax
  80215e:	ff 75 08             	push   0x8(%ebp)
  802161:	e8 d5 ef ff ff       	call   80113b <fd_lookup>
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	85 c0                	test   %eax,%eax
  80216b:	78 11                	js     80217e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80216d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802170:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802176:	39 10                	cmp    %edx,(%eax)
  802178:	0f 94 c0             	sete   %al
  80217b:	0f b6 c0             	movzbl %al,%eax
}
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    

00802180 <opencons>:
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802189:	50                   	push   %eax
  80218a:	e8 5c ef ff ff       	call   8010eb <fd_alloc>
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	85 c0                	test   %eax,%eax
  802194:	78 3a                	js     8021d0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802196:	83 ec 04             	sub    $0x4,%esp
  802199:	68 07 04 00 00       	push   $0x407
  80219e:	ff 75 f4             	push   -0xc(%ebp)
  8021a1:	6a 00                	push   $0x0
  8021a3:	e8 4c ea ff ff       	call   800bf4 <sys_page_alloc>
  8021a8:	83 c4 10             	add    $0x10,%esp
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	78 21                	js     8021d0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8021af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021b8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021c4:	83 ec 0c             	sub    $0xc,%esp
  8021c7:	50                   	push   %eax
  8021c8:	e8 f7 ee ff ff       	call   8010c4 <fd2num>
  8021cd:	83 c4 10             	add    $0x10,%esp
}
  8021d0:	c9                   	leave  
  8021d1:	c3                   	ret    

008021d2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d2:	55                   	push   %ebp
  8021d3:	89 e5                	mov    %esp,%ebp
  8021d5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8021d8:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8021df:	74 0a                	je     8021eb <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e4:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8021eb:	e8 c6 e9 ff ff       	call   800bb6 <sys_getenvid>
  8021f0:	83 ec 04             	sub    $0x4,%esp
  8021f3:	68 07 0e 00 00       	push   $0xe07
  8021f8:	68 00 f0 bf ee       	push   $0xeebff000
  8021fd:	50                   	push   %eax
  8021fe:	e8 f1 e9 ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) {
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	85 c0                	test   %eax,%eax
  802208:	78 2c                	js     802236 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80220a:	e8 a7 e9 ff ff       	call   800bb6 <sys_getenvid>
  80220f:	83 ec 08             	sub    $0x8,%esp
  802212:	68 48 22 80 00       	push   $0x802248
  802217:	50                   	push   %eax
  802218:	e8 22 eb ff ff       	call   800d3f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	79 bd                	jns    8021e1 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802224:	50                   	push   %eax
  802225:	68 c0 2b 80 00       	push   $0x802bc0
  80222a:	6a 28                	push   $0x28
  80222c:	68 f6 2b 80 00       	push   $0x802bf6
  802231:	e8 0d df ff ff       	call   800143 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802236:	50                   	push   %eax
  802237:	68 80 2b 80 00       	push   $0x802b80
  80223c:	6a 23                	push   $0x23
  80223e:	68 f6 2b 80 00       	push   $0x802bf6
  802243:	e8 fb de ff ff       	call   800143 <_panic>

00802248 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802248:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802249:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80224e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802250:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802253:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802257:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80225a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80225e:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802262:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802264:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802267:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802268:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80226b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80226c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80226d:	c3                   	ret    

0080226e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	56                   	push   %esi
  802272:	53                   	push   %ebx
  802273:	8b 75 08             	mov    0x8(%ebp),%esi
  802276:	8b 45 0c             	mov    0xc(%ebp),%eax
  802279:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80227c:	85 c0                	test   %eax,%eax
  80227e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802283:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802286:	83 ec 0c             	sub    $0xc,%esp
  802289:	50                   	push   %eax
  80228a:	e8 15 eb ff ff       	call   800da4 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80228f:	83 c4 10             	add    $0x10,%esp
  802292:	85 f6                	test   %esi,%esi
  802294:	74 14                	je     8022aa <ipc_recv+0x3c>
  802296:	ba 00 00 00 00       	mov    $0x0,%edx
  80229b:	85 c0                	test   %eax,%eax
  80229d:	78 09                	js     8022a8 <ipc_recv+0x3a>
  80229f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022a5:	8b 52 74             	mov    0x74(%edx),%edx
  8022a8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8022aa:	85 db                	test   %ebx,%ebx
  8022ac:	74 14                	je     8022c2 <ipc_recv+0x54>
  8022ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	78 09                	js     8022c0 <ipc_recv+0x52>
  8022b7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022bd:	8b 52 78             	mov    0x78(%edx),%edx
  8022c0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	78 08                	js     8022ce <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8022c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8022cb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d1:	5b                   	pop    %ebx
  8022d2:	5e                   	pop    %esi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	57                   	push   %edi
  8022d9:	56                   	push   %esi
  8022da:	53                   	push   %ebx
  8022db:	83 ec 0c             	sub    $0xc,%esp
  8022de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8022e7:	85 db                	test   %ebx,%ebx
  8022e9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022ee:	0f 44 d8             	cmove  %eax,%ebx
  8022f1:	eb 05                	jmp    8022f8 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022f3:	e8 dd e8 ff ff       	call   800bd5 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8022f8:	ff 75 14             	push   0x14(%ebp)
  8022fb:	53                   	push   %ebx
  8022fc:	56                   	push   %esi
  8022fd:	57                   	push   %edi
  8022fe:	e8 7e ea ff ff       	call   800d81 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802303:	83 c4 10             	add    $0x10,%esp
  802306:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802309:	74 e8                	je     8022f3 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 08                	js     802317 <ipc_send+0x42>
	}while (r<0);

}
  80230f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802312:	5b                   	pop    %ebx
  802313:	5e                   	pop    %esi
  802314:	5f                   	pop    %edi
  802315:	5d                   	pop    %ebp
  802316:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802317:	50                   	push   %eax
  802318:	68 04 2c 80 00       	push   $0x802c04
  80231d:	6a 3d                	push   $0x3d
  80231f:	68 18 2c 80 00       	push   $0x802c18
  802324:	e8 1a de ff ff       	call   800143 <_panic>

00802329 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802334:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802337:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80233d:	8b 52 50             	mov    0x50(%edx),%edx
  802340:	39 ca                	cmp    %ecx,%edx
  802342:	74 11                	je     802355 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802344:	83 c0 01             	add    $0x1,%eax
  802347:	3d 00 04 00 00       	cmp    $0x400,%eax
  80234c:	75 e6                	jne    802334 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80234e:	b8 00 00 00 00       	mov    $0x0,%eax
  802353:	eb 0b                	jmp    802360 <ipc_find_env+0x37>
			return envs[i].env_id;
  802355:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802358:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    

00802362 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802368:	89 c2                	mov    %eax,%edx
  80236a:	c1 ea 16             	shr    $0x16,%edx
  80236d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802374:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802379:	f6 c1 01             	test   $0x1,%cl
  80237c:	74 1c                	je     80239a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80237e:	c1 e8 0c             	shr    $0xc,%eax
  802381:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802388:	a8 01                	test   $0x1,%al
  80238a:	74 0e                	je     80239a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80238c:	c1 e8 0c             	shr    $0xc,%eax
  80238f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802396:	ef 
  802397:	0f b7 d2             	movzwl %dx,%edx
}
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__udivdi3>:
  8023a0:	f3 0f 1e fb          	endbr32 
  8023a4:	55                   	push   %ebp
  8023a5:	57                   	push   %edi
  8023a6:	56                   	push   %esi
  8023a7:	53                   	push   %ebx
  8023a8:	83 ec 1c             	sub    $0x1c,%esp
  8023ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	75 19                	jne    8023d8 <__udivdi3+0x38>
  8023bf:	39 f3                	cmp    %esi,%ebx
  8023c1:	76 4d                	jbe    802410 <__udivdi3+0x70>
  8023c3:	31 ff                	xor    %edi,%edi
  8023c5:	89 e8                	mov    %ebp,%eax
  8023c7:	89 f2                	mov    %esi,%edx
  8023c9:	f7 f3                	div    %ebx
  8023cb:	89 fa                	mov    %edi,%edx
  8023cd:	83 c4 1c             	add    $0x1c,%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    
  8023d5:	8d 76 00             	lea    0x0(%esi),%esi
  8023d8:	39 f0                	cmp    %esi,%eax
  8023da:	76 14                	jbe    8023f0 <__udivdi3+0x50>
  8023dc:	31 ff                	xor    %edi,%edi
  8023de:	31 c0                	xor    %eax,%eax
  8023e0:	89 fa                	mov    %edi,%edx
  8023e2:	83 c4 1c             	add    $0x1c,%esp
  8023e5:	5b                   	pop    %ebx
  8023e6:	5e                   	pop    %esi
  8023e7:	5f                   	pop    %edi
  8023e8:	5d                   	pop    %ebp
  8023e9:	c3                   	ret    
  8023ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f0:	0f bd f8             	bsr    %eax,%edi
  8023f3:	83 f7 1f             	xor    $0x1f,%edi
  8023f6:	75 48                	jne    802440 <__udivdi3+0xa0>
  8023f8:	39 f0                	cmp    %esi,%eax
  8023fa:	72 06                	jb     802402 <__udivdi3+0x62>
  8023fc:	31 c0                	xor    %eax,%eax
  8023fe:	39 eb                	cmp    %ebp,%ebx
  802400:	77 de                	ja     8023e0 <__udivdi3+0x40>
  802402:	b8 01 00 00 00       	mov    $0x1,%eax
  802407:	eb d7                	jmp    8023e0 <__udivdi3+0x40>
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	89 d9                	mov    %ebx,%ecx
  802412:	85 db                	test   %ebx,%ebx
  802414:	75 0b                	jne    802421 <__udivdi3+0x81>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f3                	div    %ebx
  80241f:	89 c1                	mov    %eax,%ecx
  802421:	31 d2                	xor    %edx,%edx
  802423:	89 f0                	mov    %esi,%eax
  802425:	f7 f1                	div    %ecx
  802427:	89 c6                	mov    %eax,%esi
  802429:	89 e8                	mov    %ebp,%eax
  80242b:	89 f7                	mov    %esi,%edi
  80242d:	f7 f1                	div    %ecx
  80242f:	89 fa                	mov    %edi,%edx
  802431:	83 c4 1c             	add    $0x1c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	89 f9                	mov    %edi,%ecx
  802442:	ba 20 00 00 00       	mov    $0x20,%edx
  802447:	29 fa                	sub    %edi,%edx
  802449:	d3 e0                	shl    %cl,%eax
  80244b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80244f:	89 d1                	mov    %edx,%ecx
  802451:	89 d8                	mov    %ebx,%eax
  802453:	d3 e8                	shr    %cl,%eax
  802455:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802459:	09 c1                	or     %eax,%ecx
  80245b:	89 f0                	mov    %esi,%eax
  80245d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e3                	shl    %cl,%ebx
  802465:	89 d1                	mov    %edx,%ecx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 f9                	mov    %edi,%ecx
  80246b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80246f:	89 eb                	mov    %ebp,%ebx
  802471:	d3 e6                	shl    %cl,%esi
  802473:	89 d1                	mov    %edx,%ecx
  802475:	d3 eb                	shr    %cl,%ebx
  802477:	09 f3                	or     %esi,%ebx
  802479:	89 c6                	mov    %eax,%esi
  80247b:	89 f2                	mov    %esi,%edx
  80247d:	89 d8                	mov    %ebx,%eax
  80247f:	f7 74 24 08          	divl   0x8(%esp)
  802483:	89 d6                	mov    %edx,%esi
  802485:	89 c3                	mov    %eax,%ebx
  802487:	f7 64 24 0c          	mull   0xc(%esp)
  80248b:	39 d6                	cmp    %edx,%esi
  80248d:	72 19                	jb     8024a8 <__udivdi3+0x108>
  80248f:	89 f9                	mov    %edi,%ecx
  802491:	d3 e5                	shl    %cl,%ebp
  802493:	39 c5                	cmp    %eax,%ebp
  802495:	73 04                	jae    80249b <__udivdi3+0xfb>
  802497:	39 d6                	cmp    %edx,%esi
  802499:	74 0d                	je     8024a8 <__udivdi3+0x108>
  80249b:	89 d8                	mov    %ebx,%eax
  80249d:	31 ff                	xor    %edi,%edi
  80249f:	e9 3c ff ff ff       	jmp    8023e0 <__udivdi3+0x40>
  8024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024ab:	31 ff                	xor    %edi,%edi
  8024ad:	e9 2e ff ff ff       	jmp    8023e0 <__udivdi3+0x40>
  8024b2:	66 90                	xchg   %ax,%ax
  8024b4:	66 90                	xchg   %ax,%ax
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	f3 0f 1e fb          	endbr32 
  8024c4:	55                   	push   %ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	83 ec 1c             	sub    $0x1c,%esp
  8024cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024db:	89 f0                	mov    %esi,%eax
  8024dd:	89 da                	mov    %ebx,%edx
  8024df:	85 ff                	test   %edi,%edi
  8024e1:	75 15                	jne    8024f8 <__umoddi3+0x38>
  8024e3:	39 dd                	cmp    %ebx,%ebp
  8024e5:	76 39                	jbe    802520 <__umoddi3+0x60>
  8024e7:	f7 f5                	div    %ebp
  8024e9:	89 d0                	mov    %edx,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	83 c4 1c             	add    $0x1c,%esp
  8024f0:	5b                   	pop    %ebx
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	39 df                	cmp    %ebx,%edi
  8024fa:	77 f1                	ja     8024ed <__umoddi3+0x2d>
  8024fc:	0f bd cf             	bsr    %edi,%ecx
  8024ff:	83 f1 1f             	xor    $0x1f,%ecx
  802502:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802506:	75 40                	jne    802548 <__umoddi3+0x88>
  802508:	39 df                	cmp    %ebx,%edi
  80250a:	72 04                	jb     802510 <__umoddi3+0x50>
  80250c:	39 f5                	cmp    %esi,%ebp
  80250e:	77 dd                	ja     8024ed <__umoddi3+0x2d>
  802510:	89 da                	mov    %ebx,%edx
  802512:	89 f0                	mov    %esi,%eax
  802514:	29 e8                	sub    %ebp,%eax
  802516:	19 fa                	sbb    %edi,%edx
  802518:	eb d3                	jmp    8024ed <__umoddi3+0x2d>
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	89 e9                	mov    %ebp,%ecx
  802522:	85 ed                	test   %ebp,%ebp
  802524:	75 0b                	jne    802531 <__umoddi3+0x71>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f5                	div    %ebp
  80252f:	89 c1                	mov    %eax,%ecx
  802531:	89 d8                	mov    %ebx,%eax
  802533:	31 d2                	xor    %edx,%edx
  802535:	f7 f1                	div    %ecx
  802537:	89 f0                	mov    %esi,%eax
  802539:	f7 f1                	div    %ecx
  80253b:	89 d0                	mov    %edx,%eax
  80253d:	31 d2                	xor    %edx,%edx
  80253f:	eb ac                	jmp    8024ed <__umoddi3+0x2d>
  802541:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802548:	8b 44 24 04          	mov    0x4(%esp),%eax
  80254c:	ba 20 00 00 00       	mov    $0x20,%edx
  802551:	29 c2                	sub    %eax,%edx
  802553:	89 c1                	mov    %eax,%ecx
  802555:	89 e8                	mov    %ebp,%eax
  802557:	d3 e7                	shl    %cl,%edi
  802559:	89 d1                	mov    %edx,%ecx
  80255b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80255f:	d3 e8                	shr    %cl,%eax
  802561:	89 c1                	mov    %eax,%ecx
  802563:	8b 44 24 04          	mov    0x4(%esp),%eax
  802567:	09 f9                	or     %edi,%ecx
  802569:	89 df                	mov    %ebx,%edi
  80256b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80256f:	89 c1                	mov    %eax,%ecx
  802571:	d3 e5                	shl    %cl,%ebp
  802573:	89 d1                	mov    %edx,%ecx
  802575:	d3 ef                	shr    %cl,%edi
  802577:	89 c1                	mov    %eax,%ecx
  802579:	89 f0                	mov    %esi,%eax
  80257b:	d3 e3                	shl    %cl,%ebx
  80257d:	89 d1                	mov    %edx,%ecx
  80257f:	89 fa                	mov    %edi,%edx
  802581:	d3 e8                	shr    %cl,%eax
  802583:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802588:	09 d8                	or     %ebx,%eax
  80258a:	f7 74 24 08          	divl   0x8(%esp)
  80258e:	89 d3                	mov    %edx,%ebx
  802590:	d3 e6                	shl    %cl,%esi
  802592:	f7 e5                	mul    %ebp
  802594:	89 c7                	mov    %eax,%edi
  802596:	89 d1                	mov    %edx,%ecx
  802598:	39 d3                	cmp    %edx,%ebx
  80259a:	72 06                	jb     8025a2 <__umoddi3+0xe2>
  80259c:	75 0e                	jne    8025ac <__umoddi3+0xec>
  80259e:	39 c6                	cmp    %eax,%esi
  8025a0:	73 0a                	jae    8025ac <__umoddi3+0xec>
  8025a2:	29 e8                	sub    %ebp,%eax
  8025a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025a8:	89 d1                	mov    %edx,%ecx
  8025aa:	89 c7                	mov    %eax,%edi
  8025ac:	89 f5                	mov    %esi,%ebp
  8025ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025b2:	29 fd                	sub    %edi,%ebp
  8025b4:	19 cb                	sbb    %ecx,%ebx
  8025b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025bb:	89 d8                	mov    %ebx,%eax
  8025bd:	d3 e0                	shl    %cl,%eax
  8025bf:	89 f1                	mov    %esi,%ecx
  8025c1:	d3 ed                	shr    %cl,%ebp
  8025c3:	d3 eb                	shr    %cl,%ebx
  8025c5:	09 e8                	or     %ebp,%eax
  8025c7:	89 da                	mov    %ebx,%edx
  8025c9:	83 c4 1c             	add    $0x1c,%esp
  8025cc:	5b                   	pop    %ebx
  8025cd:	5e                   	pop    %esi
  8025ce:	5f                   	pop    %edi
  8025cf:	5d                   	pop    %ebp
  8025d0:	c3                   	ret    
