
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 80 1e 80 00       	push   $0x801e80
  800045:	e8 bb 01 00 00       	call   800205 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 7d 0b 00 00       	call   800bdb <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 cc 1e 80 00       	push   $0x801ecc
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 17 07 00 00       	call   80078a <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 a0 1e 80 00       	push   $0x801ea0
  800085:	6a 0e                	push   $0xe
  800087:	68 8a 1e 80 00       	push   $0x801e8a
  80008c:	e8 99 00 00 00       	call   80012a <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 2b 0d 00 00       	call   800dcc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 1e 80 00       	push   $0x801e9c
  8000ae:	e8 52 01 00 00       	call   800205 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 1e 80 00       	push   $0x801e9c
  8000c0:	e8 40 01 00 00       	call   800205 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 c3 0a 00 00       	call   800b9d <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 19 0f 00 00       	call   801034 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 37 0a 00 00       	call   800b5c <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 60 0a 00 00       	call   800b9d <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	push   0xc(%ebp)
  800143:	ff 75 08             	push   0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 f8 1e 80 00       	push   $0x801ef8
  80014d:	e8 b3 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	push   0x10(%ebp)
  800159:	e8 56 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 a7 23 80 00 	movl   $0x8023a7,(%esp)
  800165:	e8 9b 00 00 00       	call   800205 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	74 09                	je     800198 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	68 ff 00 00 00       	push   $0xff
  8001a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 76 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	eb db                	jmp    80018f <putch+0x1f>

008001b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	ff 75 0c             	push   0xc(%ebp)
  8001d4:	ff 75 08             	push   0x8(%ebp)
  8001d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	68 70 01 80 00       	push   $0x800170
  8001e3:	e8 14 01 00 00       	call   8002fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	83 c4 08             	add    $0x8,%esp
  8001eb:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 22 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  8001fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020e:	50                   	push   %eax
  80020f:	ff 75 08             	push   0x8(%ebp)
  800212:	e8 9d ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 1c             	sub    $0x1c,%esp
  800222:	89 c7                	mov    %eax,%edi
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 d1                	mov    %edx,%ecx
  80022e:	89 c2                	mov    %eax,%edx
  800230:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800233:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800236:	8b 45 10             	mov    0x10(%ebp),%eax
  800239:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800246:	39 c2                	cmp    %eax,%edx
  800248:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024b:	72 3e                	jb     80028b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	ff 75 18             	push   0x18(%ebp)
  800253:	83 eb 01             	sub    $0x1,%ebx
  800256:	53                   	push   %ebx
  800257:	50                   	push   %eax
  800258:	83 ec 08             	sub    $0x8,%esp
  80025b:	ff 75 e4             	push   -0x1c(%ebp)
  80025e:	ff 75 e0             	push   -0x20(%ebp)
  800261:	ff 75 dc             	push   -0x24(%ebp)
  800264:	ff 75 d8             	push   -0x28(%ebp)
  800267:	e8 d4 19 00 00       	call   801c40 <__udivdi3>
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	52                   	push   %edx
  800270:	50                   	push   %eax
  800271:	89 f2                	mov    %esi,%edx
  800273:	89 f8                	mov    %edi,%eax
  800275:	e8 9f ff ff ff       	call   800219 <printnum>
  80027a:	83 c4 20             	add    $0x20,%esp
  80027d:	eb 13                	jmp    800292 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027f:	83 ec 08             	sub    $0x8,%esp
  800282:	56                   	push   %esi
  800283:	ff 75 18             	push   0x18(%ebp)
  800286:	ff d7                	call   *%edi
  800288:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028b:	83 eb 01             	sub    $0x1,%ebx
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7f ed                	jg     80027f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	56                   	push   %esi
  800296:	83 ec 04             	sub    $0x4,%esp
  800299:	ff 75 e4             	push   -0x1c(%ebp)
  80029c:	ff 75 e0             	push   -0x20(%ebp)
  80029f:	ff 75 dc             	push   -0x24(%ebp)
  8002a2:	ff 75 d8             	push   -0x28(%ebp)
  8002a5:	e8 b6 1a 00 00       	call   801d60 <__umoddi3>
  8002aa:	83 c4 14             	add    $0x14,%esp
  8002ad:	0f be 80 1b 1f 80 00 	movsbl 0x801f1b(%eax),%eax
  8002b4:	50                   	push   %eax
  8002b5:	ff d7                	call   *%edi
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d1:	73 0a                	jae    8002dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 02                	mov    %al,(%edx)
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <printfmt>:
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e8:	50                   	push   %eax
  8002e9:	ff 75 10             	push   0x10(%ebp)
  8002ec:	ff 75 0c             	push   0xc(%ebp)
  8002ef:	ff 75 08             	push   0x8(%ebp)
  8002f2:	e8 05 00 00 00       	call   8002fc <vprintfmt>
}
  8002f7:	83 c4 10             	add    $0x10,%esp
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <vprintfmt>:
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
  800302:	83 ec 3c             	sub    $0x3c,%esp
  800305:	8b 75 08             	mov    0x8(%ebp),%esi
  800308:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030e:	eb 0a                	jmp    80031a <vprintfmt+0x1e>
			putch(ch, putdat);
  800310:	83 ec 08             	sub    $0x8,%esp
  800313:	53                   	push   %ebx
  800314:	50                   	push   %eax
  800315:	ff d6                	call   *%esi
  800317:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031a:	83 c7 01             	add    $0x1,%edi
  80031d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	74 0c                	je     800332 <vprintfmt+0x36>
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	75 e6                	jne    800310 <vprintfmt+0x14>
}
  80032a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    
		padc = ' ';
  800332:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800336:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80033d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8d 47 01             	lea    0x1(%edi),%eax
  800353:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800356:	0f b6 17             	movzbl (%edi),%edx
  800359:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035c:	3c 55                	cmp    $0x55,%al
  80035e:	0f 87 bb 03 00 00    	ja     80071f <vprintfmt+0x423>
  800364:	0f b6 c0             	movzbl %al,%eax
  800367:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800371:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800375:	eb d9                	jmp    800350 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80037e:	eb d0                	jmp    800350 <vprintfmt+0x54>
  800380:	0f b6 d2             	movzbl %dl,%edx
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800391:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 55                	ja     8003f5 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a3:	eb e9                	jmp    80038e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 40 04             	lea    0x4(%eax),%eax
  8003b3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bd:	79 91                	jns    800350 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003cc:	eb 82                	jmp    800350 <vprintfmt+0x54>
  8003ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d8:	0f 49 c2             	cmovns %edx,%eax
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e1:	e9 6a ff ff ff       	jmp    800350 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f0:	e9 5b ff ff ff       	jmp    800350 <vprintfmt+0x54>
  8003f5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fb:	eb bc                	jmp    8003b9 <vprintfmt+0xbd>
			lflag++;
  8003fd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800403:	e9 48 ff ff ff       	jmp    800350 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 78 04             	lea    0x4(%eax),%edi
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	53                   	push   %ebx
  800412:	ff 30                	push   (%eax)
  800414:	ff d6                	call   *%esi
			break;
  800416:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800419:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041c:	e9 9d 02 00 00       	jmp    8006be <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 78 04             	lea    0x4(%eax),%edi
  800427:	8b 10                	mov    (%eax),%edx
  800429:	89 d0                	mov    %edx,%eax
  80042b:	f7 d8                	neg    %eax
  80042d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800430:	83 f8 0f             	cmp    $0xf,%eax
  800433:	7f 23                	jg     800458 <vprintfmt+0x15c>
  800435:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  80043c:	85 d2                	test   %edx,%edx
  80043e:	74 18                	je     800458 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800440:	52                   	push   %edx
  800441:	68 75 23 80 00       	push   $0x802375
  800446:	53                   	push   %ebx
  800447:	56                   	push   %esi
  800448:	e8 92 fe ff ff       	call   8002df <printfmt>
  80044d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800450:	89 7d 14             	mov    %edi,0x14(%ebp)
  800453:	e9 66 02 00 00       	jmp    8006be <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800458:	50                   	push   %eax
  800459:	68 33 1f 80 00       	push   $0x801f33
  80045e:	53                   	push   %ebx
  80045f:	56                   	push   %esi
  800460:	e8 7a fe ff ff       	call   8002df <printfmt>
  800465:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800468:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046b:	e9 4e 02 00 00       	jmp    8006be <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	83 c0 04             	add    $0x4,%eax
  800476:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80047e:	85 d2                	test   %edx,%edx
  800480:	b8 2c 1f 80 00       	mov    $0x801f2c,%eax
  800485:	0f 45 c2             	cmovne %edx,%eax
  800488:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	7e 06                	jle    800497 <vprintfmt+0x19b>
  800491:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800495:	75 0d                	jne    8004a4 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049a:	89 c7                	mov    %eax,%edi
  80049c:	03 45 e0             	add    -0x20(%ebp),%eax
  80049f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a2:	eb 55                	jmp    8004f9 <vprintfmt+0x1fd>
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	ff 75 d8             	push   -0x28(%ebp)
  8004aa:	ff 75 cc             	push   -0x34(%ebp)
  8004ad:	e8 0a 03 00 00       	call   8007bc <strnlen>
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004bf:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c6:	eb 0f                	jmp    8004d7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	53                   	push   %ebx
  8004cc:	ff 75 e0             	push   -0x20(%ebp)
  8004cf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	83 ef 01             	sub    $0x1,%edi
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	85 ff                	test   %edi,%edi
  8004d9:	7f ed                	jg     8004c8 <vprintfmt+0x1cc>
  8004db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004de:	85 d2                	test   %edx,%edx
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e5:	0f 49 c2             	cmovns %edx,%eax
  8004e8:	29 c2                	sub    %eax,%edx
  8004ea:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ed:	eb a8                	jmp    800497 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	52                   	push   %edx
  8004f4:	ff d6                	call   *%esi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	83 c7 01             	add    $0x1,%edi
  800501:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800505:	0f be d0             	movsbl %al,%edx
  800508:	85 d2                	test   %edx,%edx
  80050a:	74 4b                	je     800557 <vprintfmt+0x25b>
  80050c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800510:	78 06                	js     800518 <vprintfmt+0x21c>
  800512:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800516:	78 1e                	js     800536 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800518:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051c:	74 d1                	je     8004ef <vprintfmt+0x1f3>
  80051e:	0f be c0             	movsbl %al,%eax
  800521:	83 e8 20             	sub    $0x20,%eax
  800524:	83 f8 5e             	cmp    $0x5e,%eax
  800527:	76 c6                	jbe    8004ef <vprintfmt+0x1f3>
					putch('?', putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	6a 3f                	push   $0x3f
  80052f:	ff d6                	call   *%esi
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	eb c3                	jmp    8004f9 <vprintfmt+0x1fd>
  800536:	89 cf                	mov    %ecx,%edi
  800538:	eb 0e                	jmp    800548 <vprintfmt+0x24c>
				putch(' ', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	53                   	push   %ebx
  80053e:	6a 20                	push   $0x20
  800540:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800542:	83 ef 01             	sub    $0x1,%edi
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	85 ff                	test   %edi,%edi
  80054a:	7f ee                	jg     80053a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80054c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054f:	89 45 14             	mov    %eax,0x14(%ebp)
  800552:	e9 67 01 00 00       	jmp    8006be <vprintfmt+0x3c2>
  800557:	89 cf                	mov    %ecx,%edi
  800559:	eb ed                	jmp    800548 <vprintfmt+0x24c>
	if (lflag >= 2)
  80055b:	83 f9 01             	cmp    $0x1,%ecx
  80055e:	7f 1b                	jg     80057b <vprintfmt+0x27f>
	else if (lflag)
  800560:	85 c9                	test   %ecx,%ecx
  800562:	74 63                	je     8005c7 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	99                   	cltd   
  80056d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
  800579:	eb 17                	jmp    800592 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 50 04             	mov    0x4(%eax),%edx
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 40 08             	lea    0x8(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800592:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800595:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800598:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80059d:	85 c9                	test   %ecx,%ecx
  80059f:	0f 89 ff 00 00 00    	jns    8006a4 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 2d                	push   $0x2d
  8005ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b3:	f7 da                	neg    %edx
  8005b5:	83 d1 00             	adc    $0x0,%ecx
  8005b8:	f7 d9                	neg    %ecx
  8005ba:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005bd:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005c2:	e9 dd 00 00 00       	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	99                   	cltd   
  8005d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	eb b4                	jmp    800592 <vprintfmt+0x296>
	if (lflag >= 2)
  8005de:	83 f9 01             	cmp    $0x1,%ecx
  8005e1:	7f 1e                	jg     800601 <vprintfmt+0x305>
	else if (lflag)
  8005e3:	85 c9                	test   %ecx,%ecx
  8005e5:	74 32                	je     800619 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f1:	8d 40 04             	lea    0x4(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005fc:	e9 a3 00 00 00       	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 10                	mov    (%eax),%edx
  800606:	8b 48 04             	mov    0x4(%eax),%ecx
  800609:	8d 40 08             	lea    0x8(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800614:	e9 8b 00 00 00       	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800629:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80062e:	eb 74                	jmp    8006a4 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800630:	83 f9 01             	cmp    $0x1,%ecx
  800633:	7f 1b                	jg     800650 <vprintfmt+0x354>
	else if (lflag)
  800635:	85 c9                	test   %ecx,%ecx
  800637:	74 2c                	je     800665 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800649:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80064e:	eb 54                	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	8b 48 04             	mov    0x4(%eax),%ecx
  800658:	8d 40 08             	lea    0x8(%eax),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800663:	eb 3f                	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800675:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80067a:	eb 28                	jmp    8006a4 <vprintfmt+0x3a8>
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800696:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	ff 75 e0             	push   -0x20(%ebp)
  8006af:	57                   	push   %edi
  8006b0:	51                   	push   %ecx
  8006b1:	52                   	push   %edx
  8006b2:	89 da                	mov    %ebx,%edx
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	e8 5e fb ff ff       	call   800219 <printnum>
			break;
  8006bb:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c1:	e9 54 fc ff ff       	jmp    80031a <vprintfmt+0x1e>
	if (lflag >= 2)
  8006c6:	83 f9 01             	cmp    $0x1,%ecx
  8006c9:	7f 1b                	jg     8006e6 <vprintfmt+0x3ea>
	else if (lflag)
  8006cb:	85 c9                	test   %ecx,%ecx
  8006cd:	74 2c                	je     8006fb <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006e4:	eb be                	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ee:	8d 40 08             	lea    0x8(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006f9:	eb a9                	jmp    8006a4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	b9 00 00 00 00       	mov    $0x0,%ecx
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800710:	eb 92                	jmp    8006a4 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 25                	push   $0x25
  800718:	ff d6                	call   *%esi
			break;
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 9f                	jmp    8006be <vprintfmt+0x3c2>
			putch('%', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 25                	push   $0x25
  800725:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	89 f8                	mov    %edi,%eax
  80072c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800730:	74 05                	je     800737 <vprintfmt+0x43b>
  800732:	83 e8 01             	sub    $0x1,%eax
  800735:	eb f5                	jmp    80072c <vprintfmt+0x430>
  800737:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073a:	eb 82                	jmp    8006be <vprintfmt+0x3c2>

0080073c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 18             	sub    $0x18,%esp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800752:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 26                	je     800783 <vsnprintf+0x47>
  80075d:	85 d2                	test   %edx,%edx
  80075f:	7e 22                	jle    800783 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800761:	ff 75 14             	push   0x14(%ebp)
  800764:	ff 75 10             	push   0x10(%ebp)
  800767:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	68 c2 02 80 00       	push   $0x8002c2
  800770:	e8 87 fb ff ff       	call   8002fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800778:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077e:	83 c4 10             	add    $0x10,%esp
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800788:	eb f7                	jmp    800781 <vsnprintf+0x45>

0080078a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800793:	50                   	push   %eax
  800794:	ff 75 10             	push   0x10(%ebp)
  800797:	ff 75 0c             	push   0xc(%ebp)
  80079a:	ff 75 08             	push   0x8(%ebp)
  80079d:	e8 9a ff ff ff       	call   80073c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 03                	jmp    8007b4 <strlen+0x10>
		n++;
  8007b1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b8:	75 f7                	jne    8007b1 <strlen+0xd>
	return n;
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	eb 03                	jmp    8007cf <strnlen+0x13>
		n++;
  8007cc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 d0                	cmp    %edx,%eax
  8007d1:	74 08                	je     8007db <strnlen+0x1f>
  8007d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d7:	75 f3                	jne    8007cc <strnlen+0x10>
  8007d9:	89 c2                	mov    %eax,%edx
	return n;
}
  8007db:	89 d0                	mov    %edx,%eax
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ee:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f5:	83 c0 01             	add    $0x1,%eax
  8007f8:	84 d2                	test   %dl,%dl
  8007fa:	75 f2                	jne    8007ee <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fc:	89 c8                	mov    %ecx,%eax
  8007fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	83 ec 10             	sub    $0x10,%esp
  80080a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080d:	53                   	push   %ebx
  80080e:	e8 91 ff ff ff       	call   8007a4 <strlen>
  800813:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800816:	ff 75 0c             	push   0xc(%ebp)
  800819:	01 d8                	add    %ebx,%eax
  80081b:	50                   	push   %eax
  80081c:	e8 be ff ff ff       	call   8007df <strcpy>
	return dst;
}
  800821:	89 d8                	mov    %ebx,%eax
  800823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 f3                	mov    %esi,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	89 f0                	mov    %esi,%eax
  80083a:	eb 0f                	jmp    80084b <strncpy+0x23>
		*dst++ = *src;
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	0f b6 0a             	movzbl (%edx),%ecx
  800842:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800845:	80 f9 01             	cmp    $0x1,%cl
  800848:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80084b:	39 d8                	cmp    %ebx,%eax
  80084d:	75 ed                	jne    80083c <strncpy+0x14>
	}
	return ret;
}
  80084f:	89 f0                	mov    %esi,%eax
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	8b 55 10             	mov    0x10(%ebp),%edx
  800863:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800865:	85 d2                	test   %edx,%edx
  800867:	74 21                	je     80088a <strlcpy+0x35>
  800869:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086d:	89 f2                	mov    %esi,%edx
  80086f:	eb 09                	jmp    80087a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800871:	83 c1 01             	add    $0x1,%ecx
  800874:	83 c2 01             	add    $0x1,%edx
  800877:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80087a:	39 c2                	cmp    %eax,%edx
  80087c:	74 09                	je     800887 <strlcpy+0x32>
  80087e:	0f b6 19             	movzbl (%ecx),%ebx
  800881:	84 db                	test   %bl,%bl
  800883:	75 ec                	jne    800871 <strlcpy+0x1c>
  800885:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800887:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088a:	29 f0                	sub    %esi,%eax
}
  80088c:	5b                   	pop    %ebx
  80088d:	5e                   	pop    %esi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800899:	eb 06                	jmp    8008a1 <strcmp+0x11>
		p++, q++;
  80089b:	83 c1 01             	add    $0x1,%ecx
  80089e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a1:	0f b6 01             	movzbl (%ecx),%eax
  8008a4:	84 c0                	test   %al,%al
  8008a6:	74 04                	je     8008ac <strcmp+0x1c>
  8008a8:	3a 02                	cmp    (%edx),%al
  8008aa:	74 ef                	je     80089b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 c0             	movzbl %al,%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 c3                	mov    %eax,%ebx
  8008c2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c5:	eb 06                	jmp    8008cd <strncmp+0x17>
		n--, p++, q++;
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008cd:	39 d8                	cmp    %ebx,%eax
  8008cf:	74 18                	je     8008e9 <strncmp+0x33>
  8008d1:	0f b6 08             	movzbl (%eax),%ecx
  8008d4:	84 c9                	test   %cl,%cl
  8008d6:	74 04                	je     8008dc <strncmp+0x26>
  8008d8:	3a 0a                	cmp    (%edx),%cl
  8008da:	74 eb                	je     8008c7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dc:	0f b6 00             	movzbl (%eax),%eax
  8008df:	0f b6 12             	movzbl (%edx),%edx
  8008e2:	29 d0                	sub    %edx,%eax
}
  8008e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	eb f4                	jmp    8008e4 <strncmp+0x2e>

008008f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fa:	eb 03                	jmp    8008ff <strchr+0xf>
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	0f b6 10             	movzbl (%eax),%edx
  800902:	84 d2                	test   %dl,%dl
  800904:	74 06                	je     80090c <strchr+0x1c>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	75 f2                	jne    8008fc <strchr+0xc>
  80090a:	eb 05                	jmp    800911 <strchr+0x21>
			return (char *) s;
	return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 09                	je     80092d <strfind+0x1a>
  800924:	84 d2                	test   %dl,%dl
  800926:	74 05                	je     80092d <strfind+0x1a>
	for (; *s; s++)
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	eb f0                	jmp    80091d <strfind+0xa>
			break;
	return (char *) s;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 2f                	je     80096e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	89 f8                	mov    %edi,%eax
  800941:	09 c8                	or     %ecx,%eax
  800943:	a8 03                	test   $0x3,%al
  800945:	75 21                	jne    800968 <memset+0x39>
		c &= 0xFF;
  800947:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 08             	shl    $0x8,%eax
  800950:	89 d3                	mov    %edx,%ebx
  800952:	c1 e3 18             	shl    $0x18,%ebx
  800955:	89 d6                	mov    %edx,%esi
  800957:	c1 e6 10             	shl    $0x10,%esi
  80095a:	09 f3                	or     %esi,%ebx
  80095c:	09 da                	or     %ebx,%edx
  80095e:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800960:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800963:	fc                   	cld    
  800964:	f3 ab                	rep stos %eax,%es:(%edi)
  800966:	eb 06                	jmp    80096e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	fc                   	cld    
  80096c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096e:	89 f8                	mov    %edi,%eax
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800983:	39 c6                	cmp    %eax,%esi
  800985:	73 32                	jae    8009b9 <memmove+0x44>
  800987:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	76 2b                	jbe    8009b9 <memmove+0x44>
		s += n;
		d += n;
  80098e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 d6                	mov    %edx,%esi
  800993:	09 fe                	or     %edi,%esi
  800995:	09 ce                	or     %ecx,%esi
  800997:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099d:	75 0e                	jne    8009ad <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099f:	83 ef 04             	sub    $0x4,%edi
  8009a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ab:	eb 09                	jmp    8009b6 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 1a                	jmp    8009d3 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 f2                	mov    %esi,%edx
  8009bb:	09 c2                	or     %eax,%edx
  8009bd:	09 ca                	or     %ecx,%edx
  8009bf:	f6 c2 03             	test   $0x3,%dl
  8009c2:	75 0a                	jne    8009ce <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	fc                   	cld    
  8009ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cc:	eb 05                	jmp    8009d3 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009dd:	ff 75 10             	push   0x10(%ebp)
  8009e0:	ff 75 0c             	push   0xc(%ebp)
  8009e3:	ff 75 08             	push   0x8(%ebp)
  8009e6:	e8 8a ff ff ff       	call   800975 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 c6                	mov    %eax,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	eb 06                	jmp    800a05 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a05:	39 f0                	cmp    %esi,%eax
  800a07:	74 14                	je     800a1d <memcmp+0x30>
		if (*s1 != *s2)
  800a09:	0f b6 08             	movzbl (%eax),%ecx
  800a0c:	0f b6 1a             	movzbl (%edx),%ebx
  800a0f:	38 d9                	cmp    %bl,%cl
  800a11:	74 ec                	je     8009ff <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a13:	0f b6 c1             	movzbl %cl,%eax
  800a16:	0f b6 db             	movzbl %bl,%ebx
  800a19:	29 d8                	sub    %ebx,%eax
  800a1b:	eb 05                	jmp    800a22 <memcmp+0x35>
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a34:	eb 03                	jmp    800a39 <memfind+0x13>
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	39 d0                	cmp    %edx,%eax
  800a3b:	73 04                	jae    800a41 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	38 08                	cmp    %cl,(%eax)
  800a3f:	75 f5                	jne    800a36 <memfind+0x10>
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x11>
		s++;
  800a51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 02             	movzbl (%edx),%eax
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f6                	je     800a51 <strtol+0xe>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f2                	je     800a51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	74 2a                	je     800a8d <strtol+0x4a>
	int neg = 0;
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a68:	3c 2d                	cmp    $0x2d,%al
  800a6a:	74 2b                	je     800a97 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a72:	75 0f                	jne    800a83 <strtol+0x40>
  800a74:	80 3a 30             	cmpb   $0x30,(%edx)
  800a77:	74 28                	je     800aa1 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a80:	0f 44 d8             	cmove  %eax,%ebx
  800a83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a88:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8b:	eb 46                	jmp    800ad3 <strtol+0x90>
		s++;
  800a8d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
  800a95:	eb d5                	jmp    800a6c <strtol+0x29>
		s++, neg = 1;
  800a97:	83 c2 01             	add    $0x1,%edx
  800a9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9f:	eb cb                	jmp    800a6c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa5:	74 0e                	je     800ab5 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	75 d8                	jne    800a83 <strtol+0x40>
		s++, base = 8;
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab3:	eb ce                	jmp    800a83 <strtol+0x40>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb c4                	jmp    800a83 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800abf:	0f be c0             	movsbl %al,%eax
  800ac2:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac5:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ac8:	7d 3a                	jge    800b04 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aca:	83 c2 01             	add    $0x1,%edx
  800acd:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ad1:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ad3:	0f b6 02             	movzbl (%edx),%eax
  800ad6:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 09             	cmp    $0x9,%bl
  800ade:	76 df                	jbe    800abf <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ae0:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800aea:	0f be c0             	movsbl %al,%eax
  800aed:	83 e8 57             	sub    $0x57,%eax
  800af0:	eb d3                	jmp    800ac5 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800af2:	8d 70 bf             	lea    -0x41(%eax),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800afc:	0f be c0             	movsbl %al,%eax
  800aff:	83 e8 37             	sub    $0x37,%eax
  800b02:	eb c1                	jmp    800ac5 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b08:	74 05                	je     800b0f <strtol+0xcc>
		*endptr = (char *) s;
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b0f:	89 c8                	mov    %ecx,%eax
  800b11:	f7 d8                	neg    %eax
  800b13:	85 ff                	test   %edi,%edi
  800b15:	0f 45 c8             	cmovne %eax,%ecx
}
  800b18:	89 c8                	mov    %ecx,%eax
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	89 c6                	mov    %eax,%esi
  800b36:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b72:	89 cb                	mov    %ecx,%ebx
  800b74:	89 cf                	mov    %ecx,%edi
  800b76:	89 ce                	mov    %ecx,%esi
  800b78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7f 08                	jg     800b86 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 03                	push   $0x3
  800b8c:	68 1f 22 80 00       	push   $0x80221f
  800b91:	6a 2a                	push   $0x2a
  800b93:	68 3c 22 80 00       	push   $0x80223c
  800b98:	e8 8d f5 ff ff       	call   80012a <_panic>

00800b9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_yield>:

void
sys_yield(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be4:	be 00 00 00 00       	mov    $0x0,%esi
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	89 f7                	mov    %esi,%edi
  800bf9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7f 08                	jg     800c07 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 04                	push   $0x4
  800c0d:	68 1f 22 80 00       	push   $0x80221f
  800c12:	6a 2a                	push   $0x2a
  800c14:	68 3c 22 80 00       	push   $0x80223c
  800c19:	e8 0c f5 ff ff       	call   80012a <_panic>

00800c1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c38:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7f 08                	jg     800c49 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 05                	push   $0x5
  800c4f:	68 1f 22 80 00       	push   $0x80221f
  800c54:	6a 2a                	push   $0x2a
  800c56:	68 3c 22 80 00       	push   $0x80223c
  800c5b:	e8 ca f4 ff ff       	call   80012a <_panic>

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	b8 06 00 00 00       	mov    $0x6,%eax
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7f 08                	jg     800c8b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 06                	push   $0x6
  800c91:	68 1f 22 80 00       	push   $0x80221f
  800c96:	6a 2a                	push   $0x2a
  800c98:	68 3c 22 80 00       	push   $0x80223c
  800c9d:	e8 88 f4 ff ff       	call   80012a <_panic>

00800ca2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7f 08                	jg     800ccd <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 08                	push   $0x8
  800cd3:	68 1f 22 80 00       	push   $0x80221f
  800cd8:	6a 2a                	push   $0x2a
  800cda:	68 3c 22 80 00       	push   $0x80223c
  800cdf:	e8 46 f4 ff ff       	call   80012a <_panic>

00800ce4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7f 08                	jg     800d0f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 09                	push   $0x9
  800d15:	68 1f 22 80 00       	push   $0x80221f
  800d1a:	6a 2a                	push   $0x2a
  800d1c:	68 3c 22 80 00       	push   $0x80223c
  800d21:	e8 04 f4 ff ff       	call   80012a <_panic>

00800d26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 0a                	push   $0xa
  800d57:	68 1f 22 80 00       	push   $0x80221f
  800d5c:	6a 2a                	push   $0x2a
  800d5e:	68 3c 22 80 00       	push   $0x80223c
  800d63:	e8 c2 f3 ff ff       	call   80012a <_panic>

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d79:	be 00 00 00 00       	mov    $0x0,%esi
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d84:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7f 08                	jg     800db5 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 0d                	push   $0xd
  800dbb:	68 1f 22 80 00       	push   $0x80221f
  800dc0:	6a 2a                	push   $0x2a
  800dc2:	68 3c 22 80 00       	push   $0x80223c
  800dc7:	e8 5e f3 ff ff       	call   80012a <_panic>

00800dcc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800dd2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dd9:	74 0a                	je     800de5 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800de5:	e8 b3 fd ff ff       	call   800b9d <sys_getenvid>
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	68 07 0e 00 00       	push   $0xe07
  800df2:	68 00 f0 bf ee       	push   $0xeebff000
  800df7:	50                   	push   %eax
  800df8:	e8 de fd ff ff       	call   800bdb <sys_page_alloc>
		if (r < 0) {
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 2c                	js     800e30 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e04:	e8 94 fd ff ff       	call   800b9d <sys_getenvid>
  800e09:	83 ec 08             	sub    $0x8,%esp
  800e0c:	68 42 0e 80 00       	push   $0x800e42
  800e11:	50                   	push   %eax
  800e12:	e8 0f ff ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 bd                	jns    800ddb <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800e1e:	50                   	push   %eax
  800e1f:	68 8c 22 80 00       	push   $0x80228c
  800e24:	6a 28                	push   $0x28
  800e26:	68 c2 22 80 00       	push   $0x8022c2
  800e2b:	e8 fa f2 ff ff       	call   80012a <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e30:	50                   	push   %eax
  800e31:	68 4c 22 80 00       	push   $0x80224c
  800e36:	6a 23                	push   $0x23
  800e38:	68 c2 22 80 00       	push   $0x8022c2
  800e3d:	e8 e8 f2 ff ff       	call   80012a <_panic>

00800e42 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e42:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e43:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800e48:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e4a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e4d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800e51:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e54:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800e58:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e5c:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800e5e:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800e61:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800e62:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800e65:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800e66:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800e67:	c3                   	ret    

00800e68 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e73:	c1 e8 0c             	shr    $0xc,%eax
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e88:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 16             	shr    $0x16,%edx
  800e9c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea3:	f6 c2 01             	test   $0x1,%dl
  800ea6:	74 29                	je     800ed1 <fd_alloc+0x42>
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 ea 0c             	shr    $0xc,%edx
  800ead:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	74 18                	je     800ed1 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800eb9:	05 00 10 00 00       	add    $0x1000,%eax
  800ebe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ec3:	75 d2                	jne    800e97 <fd_alloc+0x8>
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800eca:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ecf:	eb 05                	jmp    800ed6 <fd_alloc+0x47>
			return 0;
  800ed1:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	89 02                	mov    %eax,(%edx)
}
  800edb:	89 c8                	mov    %ecx,%eax
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee5:	83 f8 1f             	cmp    $0x1f,%eax
  800ee8:	77 30                	ja     800f1a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eea:	c1 e0 0c             	shl    $0xc,%eax
  800eed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ef2:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ef8:	f6 c2 01             	test   $0x1,%dl
  800efb:	74 24                	je     800f21 <fd_lookup+0x42>
  800efd:	89 c2                	mov    %eax,%edx
  800eff:	c1 ea 0c             	shr    $0xc,%edx
  800f02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	74 1a                	je     800f28 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f11:	89 02                	mov    %eax,(%edx)
	return 0;
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
		return -E_INVAL;
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1f:	eb f7                	jmp    800f18 <fd_lookup+0x39>
		return -E_INVAL;
  800f21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f26:	eb f0                	jmp    800f18 <fd_lookup+0x39>
  800f28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f2d:	eb e9                	jmp    800f18 <fd_lookup+0x39>

00800f2f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	53                   	push   %ebx
  800f33:	83 ec 04             	sub    $0x4,%esp
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	b8 4c 23 80 00       	mov    $0x80234c,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800f3e:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f43:	39 13                	cmp    %edx,(%ebx)
  800f45:	74 32                	je     800f79 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800f47:	83 c0 04             	add    $0x4,%eax
  800f4a:	8b 18                	mov    (%eax),%ebx
  800f4c:	85 db                	test   %ebx,%ebx
  800f4e:	75 f3                	jne    800f43 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f50:	a1 00 40 80 00       	mov    0x804000,%eax
  800f55:	8b 40 48             	mov    0x48(%eax),%eax
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	52                   	push   %edx
  800f5c:	50                   	push   %eax
  800f5d:	68 d0 22 80 00       	push   $0x8022d0
  800f62:	e8 9e f2 ff ff       	call   800205 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f72:	89 1a                	mov    %ebx,(%edx)
}
  800f74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    
			return 0;
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7e:	eb ef                	jmp    800f6f <dev_lookup+0x40>

00800f80 <fd_close>:
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 24             	sub    $0x24,%esp
  800f89:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f92:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f93:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f99:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f9c:	50                   	push   %eax
  800f9d:	e8 3d ff ff ff       	call   800edf <fd_lookup>
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 05                	js     800fb0 <fd_close+0x30>
	    || fd != fd2)
  800fab:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fae:	74 16                	je     800fc6 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fb0:	89 f8                	mov    %edi,%eax
  800fb2:	84 c0                	test   %al,%al
  800fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb9:	0f 44 d8             	cmove  %eax,%ebx
}
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fcc:	50                   	push   %eax
  800fcd:	ff 36                	push   (%esi)
  800fcf:	e8 5b ff ff ff       	call   800f2f <dev_lookup>
  800fd4:	89 c3                	mov    %eax,%ebx
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 1a                	js     800ff7 <fd_close+0x77>
		if (dev->dev_close)
  800fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe0:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	74 0b                	je     800ff7 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	56                   	push   %esi
  800ff0:	ff d0                	call   *%eax
  800ff2:	89 c3                	mov    %eax,%ebx
  800ff4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	56                   	push   %esi
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 5e fc ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	eb b5                	jmp    800fbc <fd_close+0x3c>

00801007 <close>:

int
close(int fdnum)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	push   0x8(%ebp)
  801014:	e8 c6 fe ff ff       	call   800edf <fd_lookup>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 02                	jns    801022 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801020:	c9                   	leave  
  801021:	c3                   	ret    
		return fd_close(fd, 1);
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	6a 01                	push   $0x1
  801027:	ff 75 f4             	push   -0xc(%ebp)
  80102a:	e8 51 ff ff ff       	call   800f80 <fd_close>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	eb ec                	jmp    801020 <close+0x19>

00801034 <close_all>:

void
close_all(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	53                   	push   %ebx
  801038:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80103b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	53                   	push   %ebx
  801044:	e8 be ff ff ff       	call   801007 <close>
	for (i = 0; i < MAXFD; i++)
  801049:	83 c3 01             	add    $0x1,%ebx
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	83 fb 20             	cmp    $0x20,%ebx
  801052:	75 ec                	jne    801040 <close_all+0xc>
}
  801054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
  80105f:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801062:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801065:	50                   	push   %eax
  801066:	ff 75 08             	push   0x8(%ebp)
  801069:	e8 71 fe ff ff       	call   800edf <fd_lookup>
  80106e:	89 c3                	mov    %eax,%ebx
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 7f                	js     8010f6 <dup+0x9d>
		return r;
	close(newfdnum);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	ff 75 0c             	push   0xc(%ebp)
  80107d:	e8 85 ff ff ff       	call   801007 <close>

	newfd = INDEX2FD(newfdnum);
  801082:	8b 75 0c             	mov    0xc(%ebp),%esi
  801085:	c1 e6 0c             	shl    $0xc,%esi
  801088:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80108e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801091:	89 3c 24             	mov    %edi,(%esp)
  801094:	e8 df fd ff ff       	call   800e78 <fd2data>
  801099:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80109b:	89 34 24             	mov    %esi,(%esp)
  80109e:	e8 d5 fd ff ff       	call   800e78 <fd2data>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	c1 e8 16             	shr    $0x16,%eax
  8010ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b5:	a8 01                	test   $0x1,%al
  8010b7:	74 11                	je     8010ca <dup+0x71>
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	c1 e8 0c             	shr    $0xc,%eax
  8010be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	75 36                	jne    801100 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ca:	89 f8                	mov    %edi,%eax
  8010cc:	c1 e8 0c             	shr    $0xc,%eax
  8010cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010de:	50                   	push   %eax
  8010df:	56                   	push   %esi
  8010e0:	6a 00                	push   $0x0
  8010e2:	57                   	push   %edi
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 34 fb ff ff       	call   800c1e <sys_page_map>
  8010ea:	89 c3                	mov    %eax,%ebx
  8010ec:	83 c4 20             	add    $0x20,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 33                	js     801126 <dup+0xcd>
		goto err;

	return newfdnum;
  8010f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010f6:	89 d8                	mov    %ebx,%eax
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801100:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801107:	83 ec 0c             	sub    $0xc,%esp
  80110a:	25 07 0e 00 00       	and    $0xe07,%eax
  80110f:	50                   	push   %eax
  801110:	ff 75 d4             	push   -0x2c(%ebp)
  801113:	6a 00                	push   $0x0
  801115:	53                   	push   %ebx
  801116:	6a 00                	push   $0x0
  801118:	e8 01 fb ff ff       	call   800c1e <sys_page_map>
  80111d:	89 c3                	mov    %eax,%ebx
  80111f:	83 c4 20             	add    $0x20,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	79 a4                	jns    8010ca <dup+0x71>
	sys_page_unmap(0, newfd);
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	56                   	push   %esi
  80112a:	6a 00                	push   $0x0
  80112c:	e8 2f fb ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801131:	83 c4 08             	add    $0x8,%esp
  801134:	ff 75 d4             	push   -0x2c(%ebp)
  801137:	6a 00                	push   $0x0
  801139:	e8 22 fb ff ff       	call   800c60 <sys_page_unmap>
	return r;
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	eb b3                	jmp    8010f6 <dup+0x9d>

00801143 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 18             	sub    $0x18,%esp
  80114b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	56                   	push   %esi
  801153:	e8 87 fd ff ff       	call   800edf <fd_lookup>
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 3c                	js     80119b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801162:	83 ec 08             	sub    $0x8,%esp
  801165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	ff 33                	push   (%ebx)
  80116b:	e8 bf fd ff ff       	call   800f2f <dev_lookup>
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 24                	js     80119b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801177:	8b 43 08             	mov    0x8(%ebx),%eax
  80117a:	83 e0 03             	and    $0x3,%eax
  80117d:	83 f8 01             	cmp    $0x1,%eax
  801180:	74 20                	je     8011a2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801182:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801185:	8b 40 08             	mov    0x8(%eax),%eax
  801188:	85 c0                	test   %eax,%eax
  80118a:	74 37                	je     8011c3 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	ff 75 10             	push   0x10(%ebp)
  801192:	ff 75 0c             	push   0xc(%ebp)
  801195:	53                   	push   %ebx
  801196:	ff d0                	call   *%eax
  801198:	83 c4 10             	add    $0x10,%esp
}
  80119b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8011a7:	8b 40 48             	mov    0x48(%eax),%eax
  8011aa:	83 ec 04             	sub    $0x4,%esp
  8011ad:	56                   	push   %esi
  8011ae:	50                   	push   %eax
  8011af:	68 11 23 80 00       	push   $0x802311
  8011b4:	e8 4c f0 ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c1:	eb d8                	jmp    80119b <read+0x58>
		return -E_NOT_SUPP;
  8011c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011c8:	eb d1                	jmp    80119b <read+0x58>

008011ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011de:	eb 02                	jmp    8011e2 <readn+0x18>
  8011e0:	01 c3                	add    %eax,%ebx
  8011e2:	39 f3                	cmp    %esi,%ebx
  8011e4:	73 21                	jae    801207 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	89 f0                	mov    %esi,%eax
  8011eb:	29 d8                	sub    %ebx,%eax
  8011ed:	50                   	push   %eax
  8011ee:	89 d8                	mov    %ebx,%eax
  8011f0:	03 45 0c             	add    0xc(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	57                   	push   %edi
  8011f5:	e8 49 ff ff ff       	call   801143 <read>
		if (m < 0)
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 04                	js     801205 <readn+0x3b>
			return m;
		if (m == 0)
  801201:	75 dd                	jne    8011e0 <readn+0x16>
  801203:	eb 02                	jmp    801207 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801205:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801207:	89 d8                	mov    %ebx,%eax
  801209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 18             	sub    $0x18,%esp
  801219:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	53                   	push   %ebx
  801221:	e8 b9 fc ff ff       	call   800edf <fd_lookup>
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 37                	js     801264 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	ff 36                	push   (%esi)
  801239:	e8 f1 fc ff ff       	call   800f2f <dev_lookup>
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 1f                	js     801264 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801245:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801249:	74 20                	je     80126b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80124b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124e:	8b 40 0c             	mov    0xc(%eax),%eax
  801251:	85 c0                	test   %eax,%eax
  801253:	74 37                	je     80128c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	ff 75 10             	push   0x10(%ebp)
  80125b:	ff 75 0c             	push   0xc(%ebp)
  80125e:	56                   	push   %esi
  80125f:	ff d0                	call   *%eax
  801261:	83 c4 10             	add    $0x10,%esp
}
  801264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80126b:	a1 00 40 80 00       	mov    0x804000,%eax
  801270:	8b 40 48             	mov    0x48(%eax),%eax
  801273:	83 ec 04             	sub    $0x4,%esp
  801276:	53                   	push   %ebx
  801277:	50                   	push   %eax
  801278:	68 2d 23 80 00       	push   $0x80232d
  80127d:	e8 83 ef ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128a:	eb d8                	jmp    801264 <write+0x53>
		return -E_NOT_SUPP;
  80128c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801291:	eb d1                	jmp    801264 <write+0x53>

00801293 <seek>:

int
seek(int fdnum, off_t offset)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 75 08             	push   0x8(%ebp)
  8012a0:	e8 3a fc ff ff       	call   800edf <fd_lookup>
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 0e                	js     8012ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	56                   	push   %esi
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 18             	sub    $0x18,%esp
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	53                   	push   %ebx
  8012cc:	e8 0e fc ff ff       	call   800edf <fd_lookup>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 34                	js     80130c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 36                	push   (%esi)
  8012e4:	e8 46 fc ff ff       	call   800f2f <dev_lookup>
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 1c                	js     80130c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012f4:	74 1d                	je     801313 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f9:	8b 40 18             	mov    0x18(%eax),%eax
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	74 34                	je     801334 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	ff 75 0c             	push   0xc(%ebp)
  801306:	56                   	push   %esi
  801307:	ff d0                	call   *%eax
  801309:	83 c4 10             	add    $0x10,%esp
}
  80130c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    
			thisenv->env_id, fdnum);
  801313:	a1 00 40 80 00       	mov    0x804000,%eax
  801318:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80131b:	83 ec 04             	sub    $0x4,%esp
  80131e:	53                   	push   %ebx
  80131f:	50                   	push   %eax
  801320:	68 f0 22 80 00       	push   $0x8022f0
  801325:	e8 db ee ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801332:	eb d8                	jmp    80130c <ftruncate+0x50>
		return -E_NOT_SUPP;
  801334:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801339:	eb d1                	jmp    80130c <ftruncate+0x50>

0080133b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 18             	sub    $0x18,%esp
  801343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801346:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	ff 75 08             	push   0x8(%ebp)
  80134d:	e8 8d fb ff ff       	call   800edf <fd_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 49                	js     8013a2 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801359:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801362:	50                   	push   %eax
  801363:	ff 36                	push   (%esi)
  801365:	e8 c5 fb ff ff       	call   800f2f <dev_lookup>
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 31                	js     8013a2 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801371:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801374:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801378:	74 2f                	je     8013a9 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80137a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80137d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801384:	00 00 00 
	stat->st_isdir = 0;
  801387:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80138e:	00 00 00 
	stat->st_dev = dev;
  801391:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	53                   	push   %ebx
  80139b:	56                   	push   %esi
  80139c:	ff 50 14             	call   *0x14(%eax)
  80139f:	83 c4 10             	add    $0x10,%esp
}
  8013a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    
		return -E_NOT_SUPP;
  8013a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ae:	eb f2                	jmp    8013a2 <fstat+0x67>

008013b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	6a 00                	push   $0x0
  8013ba:	ff 75 08             	push   0x8(%ebp)
  8013bd:	e8 e4 01 00 00       	call   8015a6 <open>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 1b                	js     8013e6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	ff 75 0c             	push   0xc(%ebp)
  8013d1:	50                   	push   %eax
  8013d2:	e8 64 ff ff ff       	call   80133b <fstat>
  8013d7:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d9:	89 1c 24             	mov    %ebx,(%esp)
  8013dc:	e8 26 fc ff ff       	call   801007 <close>
	return r;
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	89 f3                	mov    %esi,%ebx
}
  8013e6:	89 d8                	mov    %ebx,%eax
  8013e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	89 c6                	mov    %eax,%esi
  8013f6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013f8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013ff:	74 27                	je     801428 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801401:	6a 07                	push   $0x7
  801403:	68 00 50 80 00       	push   $0x805000
  801408:	56                   	push   %esi
  801409:	ff 35 00 60 80 00    	push   0x806000
  80140f:	e8 5c 07 00 00       	call   801b70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801414:	83 c4 0c             	add    $0xc,%esp
  801417:	6a 00                	push   $0x0
  801419:	53                   	push   %ebx
  80141a:	6a 00                	push   $0x0
  80141c:	e8 e8 06 00 00       	call   801b09 <ipc_recv>
}
  801421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	6a 01                	push   $0x1
  80142d:	e8 92 07 00 00       	call   801bc4 <ipc_find_env>
  801432:	a3 00 60 80 00       	mov    %eax,0x806000
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	eb c5                	jmp    801401 <fsipc+0x12>

0080143c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	8b 40 0c             	mov    0xc(%eax),%eax
  801448:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80144d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801450:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	b8 02 00 00 00       	mov    $0x2,%eax
  80145f:	e8 8b ff ff ff       	call   8013ef <fsipc>
}
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <devfile_flush>:
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80146c:	8b 45 08             	mov    0x8(%ebp),%eax
  80146f:	8b 40 0c             	mov    0xc(%eax),%eax
  801472:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801477:	ba 00 00 00 00       	mov    $0x0,%edx
  80147c:	b8 06 00 00 00       	mov    $0x6,%eax
  801481:	e8 69 ff ff ff       	call   8013ef <fsipc>
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <devfile_stat>:
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	8b 40 0c             	mov    0xc(%eax),%eax
  801498:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a7:	e8 43 ff ff ff       	call   8013ef <fsipc>
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 2c                	js     8014dc <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	68 00 50 80 00       	push   $0x805000
  8014b8:	53                   	push   %ebx
  8014b9:	e8 21 f3 ff ff       	call   8007df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014be:	a1 80 50 80 00       	mov    0x805080,%eax
  8014c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <devfile_write>:
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8014ea:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ef:	39 d0                	cmp    %edx,%eax
  8014f1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014fa:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801500:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801505:	50                   	push   %eax
  801506:	ff 75 0c             	push   0xc(%ebp)
  801509:	68 08 50 80 00       	push   $0x805008
  80150e:	e8 62 f4 ff ff       	call   800975 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 04 00 00 00       	mov    $0x4,%eax
  80151d:	e8 cd fe ff ff       	call   8013ef <fsipc>
}
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <devfile_read>:
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152c:	8b 45 08             	mov    0x8(%ebp),%eax
  80152f:	8b 40 0c             	mov    0xc(%eax),%eax
  801532:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801537:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153d:	ba 00 00 00 00       	mov    $0x0,%edx
  801542:	b8 03 00 00 00       	mov    $0x3,%eax
  801547:	e8 a3 fe ff ff       	call   8013ef <fsipc>
  80154c:	89 c3                	mov    %eax,%ebx
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 1f                	js     801571 <devfile_read+0x4d>
	assert(r <= n);
  801552:	39 f0                	cmp    %esi,%eax
  801554:	77 24                	ja     80157a <devfile_read+0x56>
	assert(r <= PGSIZE);
  801556:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155b:	7f 33                	jg     801590 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	50                   	push   %eax
  801561:	68 00 50 80 00       	push   $0x805000
  801566:	ff 75 0c             	push   0xc(%ebp)
  801569:	e8 07 f4 ff ff       	call   800975 <memmove>
	return r;
  80156e:	83 c4 10             	add    $0x10,%esp
}
  801571:	89 d8                	mov    %ebx,%eax
  801573:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    
	assert(r <= n);
  80157a:	68 5c 23 80 00       	push   $0x80235c
  80157f:	68 63 23 80 00       	push   $0x802363
  801584:	6a 7c                	push   $0x7c
  801586:	68 78 23 80 00       	push   $0x802378
  80158b:	e8 9a eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801590:	68 83 23 80 00       	push   $0x802383
  801595:	68 63 23 80 00       	push   $0x802363
  80159a:	6a 7d                	push   $0x7d
  80159c:	68 78 23 80 00       	push   $0x802378
  8015a1:	e8 84 eb ff ff       	call   80012a <_panic>

008015a6 <open>:
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 1c             	sub    $0x1c,%esp
  8015ae:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015b1:	56                   	push   %esi
  8015b2:	e8 ed f1 ff ff       	call   8007a4 <strlen>
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015bf:	7f 6c                	jg     80162d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	e8 c2 f8 ff ff       	call   800e8f <fd_alloc>
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 3c                	js     801612 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	56                   	push   %esi
  8015da:	68 00 50 80 00       	push   $0x805000
  8015df:	e8 fb f1 ff ff       	call   8007df <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f4:	e8 f6 fd ff ff       	call   8013ef <fsipc>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 19                	js     80161b <open+0x75>
	return fd2num(fd);
  801602:	83 ec 0c             	sub    $0xc,%esp
  801605:	ff 75 f4             	push   -0xc(%ebp)
  801608:	e8 5b f8 ff ff       	call   800e68 <fd2num>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	83 c4 10             	add    $0x10,%esp
}
  801612:	89 d8                	mov    %ebx,%eax
  801614:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    
		fd_close(fd, 0);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	6a 00                	push   $0x0
  801620:	ff 75 f4             	push   -0xc(%ebp)
  801623:	e8 58 f9 ff ff       	call   800f80 <fd_close>
		return r;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb e5                	jmp    801612 <open+0x6c>
		return -E_BAD_PATH;
  80162d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801632:	eb de                	jmp    801612 <open+0x6c>

00801634 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80163a:	ba 00 00 00 00       	mov    $0x0,%edx
  80163f:	b8 08 00 00 00       	mov    $0x8,%eax
  801644:	e8 a6 fd ff ff       	call   8013ef <fsipc>
}
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	56                   	push   %esi
  80164f:	53                   	push   %ebx
  801650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	ff 75 08             	push   0x8(%ebp)
  801659:	e8 1a f8 ff ff       	call   800e78 <fd2data>
  80165e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	68 8f 23 80 00       	push   $0x80238f
  801668:	53                   	push   %ebx
  801669:	e8 71 f1 ff ff       	call   8007df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80166e:	8b 46 04             	mov    0x4(%esi),%eax
  801671:	2b 06                	sub    (%esi),%eax
  801673:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801679:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801680:	00 00 00 
	stat->st_dev = &devpipe;
  801683:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80168a:	30 80 00 
	return 0;
}
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
  801692:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	53                   	push   %ebx
  80169d:	83 ec 0c             	sub    $0xc,%esp
  8016a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a3:	53                   	push   %ebx
  8016a4:	6a 00                	push   $0x0
  8016a6:	e8 b5 f5 ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016ab:	89 1c 24             	mov    %ebx,(%esp)
  8016ae:	e8 c5 f7 ff ff       	call   800e78 <fd2data>
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	50                   	push   %eax
  8016b7:	6a 00                	push   $0x0
  8016b9:	e8 a2 f5 ff ff       	call   800c60 <sys_page_unmap>
}
  8016be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <_pipeisclosed>:
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	57                   	push   %edi
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 1c             	sub    $0x1c,%esp
  8016cc:	89 c7                	mov    %eax,%edi
  8016ce:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016d0:	a1 00 40 80 00       	mov    0x804000,%eax
  8016d5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	57                   	push   %edi
  8016dc:	e8 1c 05 00 00       	call   801bfd <pageref>
  8016e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e4:	89 34 24             	mov    %esi,(%esp)
  8016e7:	e8 11 05 00 00       	call   801bfd <pageref>
		nn = thisenv->env_runs;
  8016ec:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8016f2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	39 cb                	cmp    %ecx,%ebx
  8016fa:	74 1b                	je     801717 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016fc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016ff:	75 cf                	jne    8016d0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801701:	8b 42 58             	mov    0x58(%edx),%eax
  801704:	6a 01                	push   $0x1
  801706:	50                   	push   %eax
  801707:	53                   	push   %ebx
  801708:	68 96 23 80 00       	push   $0x802396
  80170d:	e8 f3 ea ff ff       	call   800205 <cprintf>
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	eb b9                	jmp    8016d0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801717:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80171a:	0f 94 c0             	sete   %al
  80171d:	0f b6 c0             	movzbl %al,%eax
}
  801720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <devpipe_write>:
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	57                   	push   %edi
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	83 ec 28             	sub    $0x28,%esp
  801731:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801734:	56                   	push   %esi
  801735:	e8 3e f7 ff ff       	call   800e78 <fd2data>
  80173a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	bf 00 00 00 00       	mov    $0x0,%edi
  801744:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801747:	75 09                	jne    801752 <devpipe_write+0x2a>
	return i;
  801749:	89 f8                	mov    %edi,%eax
  80174b:	eb 23                	jmp    801770 <devpipe_write+0x48>
			sys_yield();
  80174d:	e8 6a f4 ff ff       	call   800bbc <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801752:	8b 43 04             	mov    0x4(%ebx),%eax
  801755:	8b 0b                	mov    (%ebx),%ecx
  801757:	8d 51 20             	lea    0x20(%ecx),%edx
  80175a:	39 d0                	cmp    %edx,%eax
  80175c:	72 1a                	jb     801778 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80175e:	89 da                	mov    %ebx,%edx
  801760:	89 f0                	mov    %esi,%eax
  801762:	e8 5c ff ff ff       	call   8016c3 <_pipeisclosed>
  801767:	85 c0                	test   %eax,%eax
  801769:	74 e2                	je     80174d <devpipe_write+0x25>
				return 0;
  80176b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80177f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801782:	89 c2                	mov    %eax,%edx
  801784:	c1 fa 1f             	sar    $0x1f,%edx
  801787:	89 d1                	mov    %edx,%ecx
  801789:	c1 e9 1b             	shr    $0x1b,%ecx
  80178c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80178f:	83 e2 1f             	and    $0x1f,%edx
  801792:	29 ca                	sub    %ecx,%edx
  801794:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801798:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80179c:	83 c0 01             	add    $0x1,%eax
  80179f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017a2:	83 c7 01             	add    $0x1,%edi
  8017a5:	eb 9d                	jmp    801744 <devpipe_write+0x1c>

008017a7 <devpipe_read>:
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	57                   	push   %edi
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 18             	sub    $0x18,%esp
  8017b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017b3:	57                   	push   %edi
  8017b4:	e8 bf f6 ff ff       	call   800e78 <fd2data>
  8017b9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	be 00 00 00 00       	mov    $0x0,%esi
  8017c3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017c6:	75 13                	jne    8017db <devpipe_read+0x34>
	return i;
  8017c8:	89 f0                	mov    %esi,%eax
  8017ca:	eb 02                	jmp    8017ce <devpipe_read+0x27>
				return i;
  8017cc:	89 f0                	mov    %esi,%eax
}
  8017ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5f                   	pop    %edi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    
			sys_yield();
  8017d6:	e8 e1 f3 ff ff       	call   800bbc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017db:	8b 03                	mov    (%ebx),%eax
  8017dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017e0:	75 18                	jne    8017fa <devpipe_read+0x53>
			if (i > 0)
  8017e2:	85 f6                	test   %esi,%esi
  8017e4:	75 e6                	jne    8017cc <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8017e6:	89 da                	mov    %ebx,%edx
  8017e8:	89 f8                	mov    %edi,%eax
  8017ea:	e8 d4 fe ff ff       	call   8016c3 <_pipeisclosed>
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	74 e3                	je     8017d6 <devpipe_read+0x2f>
				return 0;
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	eb d4                	jmp    8017ce <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017fa:	99                   	cltd   
  8017fb:	c1 ea 1b             	shr    $0x1b,%edx
  8017fe:	01 d0                	add    %edx,%eax
  801800:	83 e0 1f             	and    $0x1f,%eax
  801803:	29 d0                	sub    %edx,%eax
  801805:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80180a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801810:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801813:	83 c6 01             	add    $0x1,%esi
  801816:	eb ab                	jmp    8017c3 <devpipe_read+0x1c>

00801818 <pipe>:
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801823:	50                   	push   %eax
  801824:	e8 66 f6 ff ff       	call   800e8f <fd_alloc>
  801829:	89 c3                	mov    %eax,%ebx
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	85 c0                	test   %eax,%eax
  801830:	0f 88 23 01 00 00    	js     801959 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801836:	83 ec 04             	sub    $0x4,%esp
  801839:	68 07 04 00 00       	push   $0x407
  80183e:	ff 75 f4             	push   -0xc(%ebp)
  801841:	6a 00                	push   $0x0
  801843:	e8 93 f3 ff ff       	call   800bdb <sys_page_alloc>
  801848:	89 c3                	mov    %eax,%ebx
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	85 c0                	test   %eax,%eax
  80184f:	0f 88 04 01 00 00    	js     801959 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801855:	83 ec 0c             	sub    $0xc,%esp
  801858:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185b:	50                   	push   %eax
  80185c:	e8 2e f6 ff ff       	call   800e8f <fd_alloc>
  801861:	89 c3                	mov    %eax,%ebx
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	0f 88 db 00 00 00    	js     801949 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186e:	83 ec 04             	sub    $0x4,%esp
  801871:	68 07 04 00 00       	push   $0x407
  801876:	ff 75 f0             	push   -0x10(%ebp)
  801879:	6a 00                	push   $0x0
  80187b:	e8 5b f3 ff ff       	call   800bdb <sys_page_alloc>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 bc 00 00 00    	js     801949 <pipe+0x131>
	va = fd2data(fd0);
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	ff 75 f4             	push   -0xc(%ebp)
  801893:	e8 e0 f5 ff ff       	call   800e78 <fd2data>
  801898:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189a:	83 c4 0c             	add    $0xc,%esp
  80189d:	68 07 04 00 00       	push   $0x407
  8018a2:	50                   	push   %eax
  8018a3:	6a 00                	push   $0x0
  8018a5:	e8 31 f3 ff ff       	call   800bdb <sys_page_alloc>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	0f 88 82 00 00 00    	js     801939 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff 75 f0             	push   -0x10(%ebp)
  8018bd:	e8 b6 f5 ff ff       	call   800e78 <fd2data>
  8018c2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018c9:	50                   	push   %eax
  8018ca:	6a 00                	push   $0x0
  8018cc:	56                   	push   %esi
  8018cd:	6a 00                	push   $0x0
  8018cf:	e8 4a f3 ff ff       	call   800c1e <sys_page_map>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	83 c4 20             	add    $0x20,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 4e                	js     80192b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8018dd:	a1 20 30 80 00       	mov    0x803020,%eax
  8018e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ea:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018f4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	ff 75 f4             	push   -0xc(%ebp)
  801906:	e8 5d f5 ff ff       	call   800e68 <fd2num>
  80190b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80190e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801910:	83 c4 04             	add    $0x4,%esp
  801913:	ff 75 f0             	push   -0x10(%ebp)
  801916:	e8 4d f5 ff ff       	call   800e68 <fd2num>
  80191b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	bb 00 00 00 00       	mov    $0x0,%ebx
  801929:	eb 2e                	jmp    801959 <pipe+0x141>
	sys_page_unmap(0, va);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	56                   	push   %esi
  80192f:	6a 00                	push   $0x0
  801931:	e8 2a f3 ff ff       	call   800c60 <sys_page_unmap>
  801936:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801939:	83 ec 08             	sub    $0x8,%esp
  80193c:	ff 75 f0             	push   -0x10(%ebp)
  80193f:	6a 00                	push   $0x0
  801941:	e8 1a f3 ff ff       	call   800c60 <sys_page_unmap>
  801946:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	ff 75 f4             	push   -0xc(%ebp)
  80194f:	6a 00                	push   $0x0
  801951:	e8 0a f3 ff ff       	call   800c60 <sys_page_unmap>
  801956:	83 c4 10             	add    $0x10,%esp
}
  801959:	89 d8                	mov    %ebx,%eax
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <pipeisclosed>:
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801968:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196b:	50                   	push   %eax
  80196c:	ff 75 08             	push   0x8(%ebp)
  80196f:	e8 6b f5 ff ff       	call   800edf <fd_lookup>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 18                	js     801993 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	ff 75 f4             	push   -0xc(%ebp)
  801981:	e8 f2 f4 ff ff       	call   800e78 <fd2data>
  801986:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198b:	e8 33 fd ff ff       	call   8016c3 <_pipeisclosed>
  801990:	83 c4 10             	add    $0x10,%esp
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	c3                   	ret    

0080199b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019a1:	68 ae 23 80 00       	push   $0x8023ae
  8019a6:	ff 75 0c             	push   0xc(%ebp)
  8019a9:	e8 31 ee ff ff       	call   8007df <strcpy>
	return 0;
}
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <devcons_write>:
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	57                   	push   %edi
  8019b9:	56                   	push   %esi
  8019ba:	53                   	push   %ebx
  8019bb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019c1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019c6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019cc:	eb 2e                	jmp    8019fc <devcons_write+0x47>
		m = n - tot;
  8019ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019d1:	29 f3                	sub    %esi,%ebx
  8019d3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019d8:	39 c3                	cmp    %eax,%ebx
  8019da:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019dd:	83 ec 04             	sub    $0x4,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	89 f0                	mov    %esi,%eax
  8019e3:	03 45 0c             	add    0xc(%ebp),%eax
  8019e6:	50                   	push   %eax
  8019e7:	57                   	push   %edi
  8019e8:	e8 88 ef ff ff       	call   800975 <memmove>
		sys_cputs(buf, m);
  8019ed:	83 c4 08             	add    $0x8,%esp
  8019f0:	53                   	push   %ebx
  8019f1:	57                   	push   %edi
  8019f2:	e8 28 f1 ff ff       	call   800b1f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019f7:	01 de                	add    %ebx,%esi
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ff:	72 cd                	jb     8019ce <devcons_write+0x19>
}
  801a01:	89 f0                	mov    %esi,%eax
  801a03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5f                   	pop    %edi
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <devcons_read>:
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a1a:	75 07                	jne    801a23 <devcons_read+0x18>
  801a1c:	eb 1f                	jmp    801a3d <devcons_read+0x32>
		sys_yield();
  801a1e:	e8 99 f1 ff ff       	call   800bbc <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a23:	e8 15 f1 ff ff       	call   800b3d <sys_cgetc>
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	74 f2                	je     801a1e <devcons_read+0x13>
	if (c < 0)
  801a2c:	78 0f                	js     801a3d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801a2e:	83 f8 04             	cmp    $0x4,%eax
  801a31:	74 0c                	je     801a3f <devcons_read+0x34>
	*(char*)vbuf = c;
  801a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a36:	88 02                	mov    %al,(%edx)
	return 1;
  801a38:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    
		return 0;
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a44:	eb f7                	jmp    801a3d <devcons_read+0x32>

00801a46 <cputchar>:
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a52:	6a 01                	push   $0x1
  801a54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a57:	50                   	push   %eax
  801a58:	e8 c2 f0 ff ff       	call   800b1f <sys_cputs>
}
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <getchar>:
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a68:	6a 01                	push   $0x1
  801a6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6d:	50                   	push   %eax
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 ce f6 ff ff       	call   801143 <read>
	if (r < 0)
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 06                	js     801a82 <getchar+0x20>
	if (r < 1)
  801a7c:	74 06                	je     801a84 <getchar+0x22>
	return c;
  801a7e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    
		return -E_EOF;
  801a84:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a89:	eb f7                	jmp    801a82 <getchar+0x20>

00801a8b <iscons>:
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a94:	50                   	push   %eax
  801a95:	ff 75 08             	push   0x8(%ebp)
  801a98:	e8 42 f4 ff ff       	call   800edf <fd_lookup>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 11                	js     801ab5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aad:	39 10                	cmp    %edx,(%eax)
  801aaf:	0f 94 c0             	sete   %al
  801ab2:	0f b6 c0             	movzbl %al,%eax
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <opencons>:
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801abd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac0:	50                   	push   %eax
  801ac1:	e8 c9 f3 ff ff       	call   800e8f <fd_alloc>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 3a                	js     801b07 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 07 04 00 00       	push   $0x407
  801ad5:	ff 75 f4             	push   -0xc(%ebp)
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 fc f0 ff ff       	call   800bdb <sys_page_alloc>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 21                	js     801b07 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	50                   	push   %eax
  801aff:	e8 64 f3 ff ff       	call   800e68 <fd2num>
  801b04:	83 c4 10             	add    $0x10,%esp
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801b17:	85 c0                	test   %eax,%eax
  801b19:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b1e:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801b21:	83 ec 0c             	sub    $0xc,%esp
  801b24:	50                   	push   %eax
  801b25:	e8 61 f2 ff ff       	call   800d8b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 f6                	test   %esi,%esi
  801b2f:	74 14                	je     801b45 <ipc_recv+0x3c>
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 09                	js     801b43 <ipc_recv+0x3a>
  801b3a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b40:	8b 52 74             	mov    0x74(%edx),%edx
  801b43:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801b45:	85 db                	test   %ebx,%ebx
  801b47:	74 14                	je     801b5d <ipc_recv+0x54>
  801b49:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 09                	js     801b5b <ipc_recv+0x52>
  801b52:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b58:	8b 52 78             	mov    0x78(%edx),%edx
  801b5b:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	78 08                	js     801b69 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801b61:	a1 00 40 80 00       	mov    0x804000,%eax
  801b66:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801b82:	85 db                	test   %ebx,%ebx
  801b84:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b89:	0f 44 d8             	cmove  %eax,%ebx
  801b8c:	eb 05                	jmp    801b93 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b8e:	e8 29 f0 ff ff       	call   800bbc <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801b93:	ff 75 14             	push   0x14(%ebp)
  801b96:	53                   	push   %ebx
  801b97:	56                   	push   %esi
  801b98:	57                   	push   %edi
  801b99:	e8 ca f1 ff ff       	call   800d68 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba4:	74 e8                	je     801b8e <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 08                	js     801bb2 <ipc_send+0x42>
	}while (r<0);

}
  801baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801bb2:	50                   	push   %eax
  801bb3:	68 ba 23 80 00       	push   $0x8023ba
  801bb8:	6a 3d                	push   $0x3d
  801bba:	68 ce 23 80 00       	push   $0x8023ce
  801bbf:	e8 66 e5 ff ff       	call   80012a <_panic>

00801bc4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bcf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bd2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bd8:	8b 52 50             	mov    0x50(%edx),%edx
  801bdb:	39 ca                	cmp    %ecx,%edx
  801bdd:	74 11                	je     801bf0 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bdf:	83 c0 01             	add    $0x1,%eax
  801be2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be7:	75 e6                	jne    801bcf <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801be9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bee:	eb 0b                	jmp    801bfb <ipc_find_env+0x37>
			return envs[i].env_id;
  801bf0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf8:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	c1 ea 16             	shr    $0x16,%edx
  801c08:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c0f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c14:	f6 c1 01             	test   $0x1,%cl
  801c17:	74 1c                	je     801c35 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801c19:	c1 e8 0c             	shr    $0xc,%eax
  801c1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c23:	a8 01                	test   $0x1,%al
  801c25:	74 0e                	je     801c35 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c27:	c1 e8 0c             	shr    $0xc,%eax
  801c2a:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c31:	ef 
  801c32:	0f b7 d2             	movzwl %dx,%edx
}
  801c35:	89 d0                	mov    %edx,%eax
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	66 90                	xchg   %ax,%ax
  801c3b:	66 90                	xchg   %ax,%ax
  801c3d:	66 90                	xchg   %ax,%ax
  801c3f:	90                   	nop

00801c40 <__udivdi3>:
  801c40:	f3 0f 1e fb          	endbr32 
  801c44:	55                   	push   %ebp
  801c45:	57                   	push   %edi
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 1c             	sub    $0x1c,%esp
  801c4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c53:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	75 19                	jne    801c78 <__udivdi3+0x38>
  801c5f:	39 f3                	cmp    %esi,%ebx
  801c61:	76 4d                	jbe    801cb0 <__udivdi3+0x70>
  801c63:	31 ff                	xor    %edi,%edi
  801c65:	89 e8                	mov    %ebp,%eax
  801c67:	89 f2                	mov    %esi,%edx
  801c69:	f7 f3                	div    %ebx
  801c6b:	89 fa                	mov    %edi,%edx
  801c6d:	83 c4 1c             	add    $0x1c,%esp
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	8d 76 00             	lea    0x0(%esi),%esi
  801c78:	39 f0                	cmp    %esi,%eax
  801c7a:	76 14                	jbe    801c90 <__udivdi3+0x50>
  801c7c:	31 ff                	xor    %edi,%edi
  801c7e:	31 c0                	xor    %eax,%eax
  801c80:	89 fa                	mov    %edi,%edx
  801c82:	83 c4 1c             	add    $0x1c,%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5f                   	pop    %edi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    
  801c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c90:	0f bd f8             	bsr    %eax,%edi
  801c93:	83 f7 1f             	xor    $0x1f,%edi
  801c96:	75 48                	jne    801ce0 <__udivdi3+0xa0>
  801c98:	39 f0                	cmp    %esi,%eax
  801c9a:	72 06                	jb     801ca2 <__udivdi3+0x62>
  801c9c:	31 c0                	xor    %eax,%eax
  801c9e:	39 eb                	cmp    %ebp,%ebx
  801ca0:	77 de                	ja     801c80 <__udivdi3+0x40>
  801ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca7:	eb d7                	jmp    801c80 <__udivdi3+0x40>
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d9                	mov    %ebx,%ecx
  801cb2:	85 db                	test   %ebx,%ebx
  801cb4:	75 0b                	jne    801cc1 <__udivdi3+0x81>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f3                	div    %ebx
  801cbf:	89 c1                	mov    %eax,%ecx
  801cc1:	31 d2                	xor    %edx,%edx
  801cc3:	89 f0                	mov    %esi,%eax
  801cc5:	f7 f1                	div    %ecx
  801cc7:	89 c6                	mov    %eax,%esi
  801cc9:	89 e8                	mov    %ebp,%eax
  801ccb:	89 f7                	mov    %esi,%edi
  801ccd:	f7 f1                	div    %ecx
  801ccf:	89 fa                	mov    %edi,%edx
  801cd1:	83 c4 1c             	add    $0x1c,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 f9                	mov    %edi,%ecx
  801ce2:	ba 20 00 00 00       	mov    $0x20,%edx
  801ce7:	29 fa                	sub    %edi,%edx
  801ce9:	d3 e0                	shl    %cl,%eax
  801ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cef:	89 d1                	mov    %edx,%ecx
  801cf1:	89 d8                	mov    %ebx,%eax
  801cf3:	d3 e8                	shr    %cl,%eax
  801cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cf9:	09 c1                	or     %eax,%ecx
  801cfb:	89 f0                	mov    %esi,%eax
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e3                	shl    %cl,%ebx
  801d05:	89 d1                	mov    %edx,%ecx
  801d07:	d3 e8                	shr    %cl,%eax
  801d09:	89 f9                	mov    %edi,%ecx
  801d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d0f:	89 eb                	mov    %ebp,%ebx
  801d11:	d3 e6                	shl    %cl,%esi
  801d13:	89 d1                	mov    %edx,%ecx
  801d15:	d3 eb                	shr    %cl,%ebx
  801d17:	09 f3                	or     %esi,%ebx
  801d19:	89 c6                	mov    %eax,%esi
  801d1b:	89 f2                	mov    %esi,%edx
  801d1d:	89 d8                	mov    %ebx,%eax
  801d1f:	f7 74 24 08          	divl   0x8(%esp)
  801d23:	89 d6                	mov    %edx,%esi
  801d25:	89 c3                	mov    %eax,%ebx
  801d27:	f7 64 24 0c          	mull   0xc(%esp)
  801d2b:	39 d6                	cmp    %edx,%esi
  801d2d:	72 19                	jb     801d48 <__udivdi3+0x108>
  801d2f:	89 f9                	mov    %edi,%ecx
  801d31:	d3 e5                	shl    %cl,%ebp
  801d33:	39 c5                	cmp    %eax,%ebp
  801d35:	73 04                	jae    801d3b <__udivdi3+0xfb>
  801d37:	39 d6                	cmp    %edx,%esi
  801d39:	74 0d                	je     801d48 <__udivdi3+0x108>
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	31 ff                	xor    %edi,%edi
  801d3f:	e9 3c ff ff ff       	jmp    801c80 <__udivdi3+0x40>
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d4b:	31 ff                	xor    %edi,%edi
  801d4d:	e9 2e ff ff ff       	jmp    801c80 <__udivdi3+0x40>
  801d52:	66 90                	xchg   %ax,%ax
  801d54:	66 90                	xchg   %ax,%ax
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	f3 0f 1e fb          	endbr32 
  801d64:	55                   	push   %ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	83 ec 1c             	sub    $0x1c,%esp
  801d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801d77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801d7b:	89 f0                	mov    %esi,%eax
  801d7d:	89 da                	mov    %ebx,%edx
  801d7f:	85 ff                	test   %edi,%edi
  801d81:	75 15                	jne    801d98 <__umoddi3+0x38>
  801d83:	39 dd                	cmp    %ebx,%ebp
  801d85:	76 39                	jbe    801dc0 <__umoddi3+0x60>
  801d87:	f7 f5                	div    %ebp
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	39 df                	cmp    %ebx,%edi
  801d9a:	77 f1                	ja     801d8d <__umoddi3+0x2d>
  801d9c:	0f bd cf             	bsr    %edi,%ecx
  801d9f:	83 f1 1f             	xor    $0x1f,%ecx
  801da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801da6:	75 40                	jne    801de8 <__umoddi3+0x88>
  801da8:	39 df                	cmp    %ebx,%edi
  801daa:	72 04                	jb     801db0 <__umoddi3+0x50>
  801dac:	39 f5                	cmp    %esi,%ebp
  801dae:	77 dd                	ja     801d8d <__umoddi3+0x2d>
  801db0:	89 da                	mov    %ebx,%edx
  801db2:	89 f0                	mov    %esi,%eax
  801db4:	29 e8                	sub    %ebp,%eax
  801db6:	19 fa                	sbb    %edi,%edx
  801db8:	eb d3                	jmp    801d8d <__umoddi3+0x2d>
  801dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc0:	89 e9                	mov    %ebp,%ecx
  801dc2:	85 ed                	test   %ebp,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x71>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f5                	div    %ebp
  801dcf:	89 c1                	mov    %eax,%ecx
  801dd1:	89 d8                	mov    %ebx,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f1                	div    %ecx
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	f7 f1                	div    %ecx
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	31 d2                	xor    %edx,%edx
  801ddf:	eb ac                	jmp    801d8d <__umoddi3+0x2d>
  801de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801dec:	ba 20 00 00 00       	mov    $0x20,%edx
  801df1:	29 c2                	sub    %eax,%edx
  801df3:	89 c1                	mov    %eax,%ecx
  801df5:	89 e8                	mov    %ebp,%eax
  801df7:	d3 e7                	shl    %cl,%edi
  801df9:	89 d1                	mov    %edx,%ecx
  801dfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dff:	d3 e8                	shr    %cl,%eax
  801e01:	89 c1                	mov    %eax,%ecx
  801e03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e07:	09 f9                	or     %edi,%ecx
  801e09:	89 df                	mov    %ebx,%edi
  801e0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0f:	89 c1                	mov    %eax,%ecx
  801e11:	d3 e5                	shl    %cl,%ebp
  801e13:	89 d1                	mov    %edx,%ecx
  801e15:	d3 ef                	shr    %cl,%edi
  801e17:	89 c1                	mov    %eax,%ecx
  801e19:	89 f0                	mov    %esi,%eax
  801e1b:	d3 e3                	shl    %cl,%ebx
  801e1d:	89 d1                	mov    %edx,%ecx
  801e1f:	89 fa                	mov    %edi,%edx
  801e21:	d3 e8                	shr    %cl,%eax
  801e23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e28:	09 d8                	or     %ebx,%eax
  801e2a:	f7 74 24 08          	divl   0x8(%esp)
  801e2e:	89 d3                	mov    %edx,%ebx
  801e30:	d3 e6                	shl    %cl,%esi
  801e32:	f7 e5                	mul    %ebp
  801e34:	89 c7                	mov    %eax,%edi
  801e36:	89 d1                	mov    %edx,%ecx
  801e38:	39 d3                	cmp    %edx,%ebx
  801e3a:	72 06                	jb     801e42 <__umoddi3+0xe2>
  801e3c:	75 0e                	jne    801e4c <__umoddi3+0xec>
  801e3e:	39 c6                	cmp    %eax,%esi
  801e40:	73 0a                	jae    801e4c <__umoddi3+0xec>
  801e42:	29 e8                	sub    %ebp,%eax
  801e44:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e48:	89 d1                	mov    %edx,%ecx
  801e4a:	89 c7                	mov    %eax,%edi
  801e4c:	89 f5                	mov    %esi,%ebp
  801e4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e52:	29 fd                	sub    %edi,%ebp
  801e54:	19 cb                	sbb    %ecx,%ebx
  801e56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e5b:	89 d8                	mov    %ebx,%eax
  801e5d:	d3 e0                	shl    %cl,%eax
  801e5f:	89 f1                	mov    %esi,%ecx
  801e61:	d3 ed                	shr    %cl,%ebp
  801e63:	d3 eb                	shr    %cl,%ebx
  801e65:	09 e8                	or     %ebp,%eax
  801e67:	89 da                	mov    %ebx,%edx
  801e69:	83 c4 1c             	add    $0x1c,%esp
  801e6c:	5b                   	pop    %ebx
  801e6d:	5e                   	pop    %esi
  801e6e:	5f                   	pop    %edi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    
