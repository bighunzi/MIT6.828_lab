
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
  800040:	68 60 23 80 00       	push   $0x802360
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
  800066:	68 ac 23 80 00       	push   $0x8023ac
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
  800080:	68 80 23 80 00       	push   $0x802380
  800085:	6a 0e                	push   $0xe
  800087:	68 6a 23 80 00       	push   $0x80236a
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
  80009c:	e8 8c 0d 00 00       	call   800e2d <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 23 80 00       	push   $0x80237c
  8000ae:	e8 52 01 00 00       	call   800205 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 23 80 00       	push   $0x80237c
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
  800116:	e8 7f 0f 00 00       	call   80109a <close_all>
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
  800148:	68 d8 23 80 00       	push   $0x8023d8
  80014d:	e8 b3 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	push   0x10(%ebp)
  800159:	e8 56 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
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
  800267:	e8 a4 1e 00 00       	call   802110 <__udivdi3>
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
  8002a5:	e8 86 1f 00 00       	call   802230 <__umoddi3>
  8002aa:	83 c4 14             	add    $0x14,%esp
  8002ad:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
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
  800367:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
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
  800435:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80043c:	85 d2                	test   %edx,%edx
  80043e:	74 18                	je     800458 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800440:	52                   	push   %edx
  800441:	68 59 28 80 00       	push   $0x802859
  800446:	53                   	push   %ebx
  800447:	56                   	push   %esi
  800448:	e8 92 fe ff ff       	call   8002df <printfmt>
  80044d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800450:	89 7d 14             	mov    %edi,0x14(%ebp)
  800453:	e9 66 02 00 00       	jmp    8006be <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800458:	50                   	push   %eax
  800459:	68 13 24 80 00       	push   $0x802413
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
  800480:	b8 0c 24 80 00       	mov    $0x80240c,%eax
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
  800b8c:	68 ff 26 80 00       	push   $0x8026ff
  800b91:	6a 2a                	push   $0x2a
  800b93:	68 1c 27 80 00       	push   $0x80271c
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
  800c0d:	68 ff 26 80 00       	push   $0x8026ff
  800c12:	6a 2a                	push   $0x2a
  800c14:	68 1c 27 80 00       	push   $0x80271c
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
  800c4f:	68 ff 26 80 00       	push   $0x8026ff
  800c54:	6a 2a                	push   $0x2a
  800c56:	68 1c 27 80 00       	push   $0x80271c
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
  800c91:	68 ff 26 80 00       	push   $0x8026ff
  800c96:	6a 2a                	push   $0x2a
  800c98:	68 1c 27 80 00       	push   $0x80271c
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
  800cd3:	68 ff 26 80 00       	push   $0x8026ff
  800cd8:	6a 2a                	push   $0x2a
  800cda:	68 1c 27 80 00       	push   $0x80271c
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
  800d15:	68 ff 26 80 00       	push   $0x8026ff
  800d1a:	6a 2a                	push   $0x2a
  800d1c:	68 1c 27 80 00       	push   $0x80271c
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
  800d57:	68 ff 26 80 00       	push   $0x8026ff
  800d5c:	6a 2a                	push   $0x2a
  800d5e:	68 1c 27 80 00       	push   $0x80271c
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
  800dbb:	68 ff 26 80 00       	push   $0x8026ff
  800dc0:	6a 2a                	push   $0x2a
  800dc2:	68 1c 27 80 00       	push   $0x80271c
  800dc7:	e8 5e f3 ff ff       	call   80012a <_panic>

00800dcc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ddc:	89 d1                	mov    %edx,%ecx
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	89 d7                	mov    %edx,%edi
  800de2:	89 d6                	mov    %edx,%esi
  800de4:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	b8 10 00 00 00       	mov    $0x10,%eax
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	89 de                	mov    %ebx,%esi
  800e26:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800e33:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e3a:	74 0a                	je     800e46 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800e46:	e8 52 fd ff ff       	call   800b9d <sys_getenvid>
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	68 07 0e 00 00       	push   $0xe07
  800e53:	68 00 f0 bf ee       	push   $0xeebff000
  800e58:	50                   	push   %eax
  800e59:	e8 7d fd ff ff       	call   800bdb <sys_page_alloc>
		if (r < 0) {
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	85 c0                	test   %eax,%eax
  800e63:	78 2c                	js     800e91 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800e65:	e8 33 fd ff ff       	call   800b9d <sys_getenvid>
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	68 a3 0e 80 00       	push   $0x800ea3
  800e72:	50                   	push   %eax
  800e73:	e8 ae fe ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	79 bd                	jns    800e3c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800e7f:	50                   	push   %eax
  800e80:	68 6c 27 80 00       	push   $0x80276c
  800e85:	6a 28                	push   $0x28
  800e87:	68 a2 27 80 00       	push   $0x8027a2
  800e8c:	e8 99 f2 ff ff       	call   80012a <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e91:	50                   	push   %eax
  800e92:	68 2c 27 80 00       	push   $0x80272c
  800e97:	6a 23                	push   $0x23
  800e99:	68 a2 27 80 00       	push   $0x8027a2
  800e9e:	e8 87 f2 ff ff       	call   80012a <_panic>

00800ea3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ea3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ea4:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800ea9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800eab:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800eae:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800eb2:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800eb5:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800eb9:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800ebd:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800ebf:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800ec2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800ec3:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800ec6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800ec7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800ec8:	c3                   	ret    

00800ec9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed4:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ee4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef8:	89 c2                	mov    %eax,%edx
  800efa:	c1 ea 16             	shr    $0x16,%edx
  800efd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f04:	f6 c2 01             	test   $0x1,%dl
  800f07:	74 29                	je     800f32 <fd_alloc+0x42>
  800f09:	89 c2                	mov    %eax,%edx
  800f0b:	c1 ea 0c             	shr    $0xc,%edx
  800f0e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f15:	f6 c2 01             	test   $0x1,%dl
  800f18:	74 18                	je     800f32 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f1a:	05 00 10 00 00       	add    $0x1000,%eax
  800f1f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f24:	75 d2                	jne    800ef8 <fd_alloc+0x8>
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f2b:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f30:	eb 05                	jmp    800f37 <fd_alloc+0x47>
			return 0;
  800f32:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f37:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3a:	89 02                	mov    %eax,(%edx)
}
  800f3c:	89 c8                	mov    %ecx,%eax
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f46:	83 f8 1f             	cmp    $0x1f,%eax
  800f49:	77 30                	ja     800f7b <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4b:	c1 e0 0c             	shl    $0xc,%eax
  800f4e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f53:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f59:	f6 c2 01             	test   $0x1,%dl
  800f5c:	74 24                	je     800f82 <fd_lookup+0x42>
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	c1 ea 0c             	shr    $0xc,%edx
  800f63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	74 1a                	je     800f89 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f72:	89 02                	mov    %eax,(%edx)
	return 0;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    
		return -E_INVAL;
  800f7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f80:	eb f7                	jmp    800f79 <fd_lookup+0x39>
		return -E_INVAL;
  800f82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f87:	eb f0                	jmp    800f79 <fd_lookup+0x39>
  800f89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8e:	eb e9                	jmp    800f79 <fd_lookup+0x39>

00800f90 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	53                   	push   %ebx
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9f:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800fa4:	39 13                	cmp    %edx,(%ebx)
  800fa6:	74 37                	je     800fdf <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800fa8:	83 c0 01             	add    $0x1,%eax
  800fab:	8b 1c 85 2c 28 80 00 	mov    0x80282c(,%eax,4),%ebx
  800fb2:	85 db                	test   %ebx,%ebx
  800fb4:	75 ee                	jne    800fa4 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb6:	a1 00 40 80 00       	mov    0x804000,%eax
  800fbb:	8b 40 48             	mov    0x48(%eax),%eax
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	52                   	push   %edx
  800fc2:	50                   	push   %eax
  800fc3:	68 b0 27 80 00       	push   $0x8027b0
  800fc8:	e8 38 f2 ff ff       	call   800205 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd8:	89 1a                	mov    %ebx,(%edx)
}
  800fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    
			return 0;
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe4:	eb ef                	jmp    800fd5 <dev_lookup+0x45>

00800fe6 <fd_close>:
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	83 ec 24             	sub    $0x24,%esp
  800fef:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff8:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fff:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801002:	50                   	push   %eax
  801003:	e8 38 ff ff ff       	call   800f40 <fd_lookup>
  801008:	89 c3                	mov    %eax,%ebx
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 05                	js     801016 <fd_close+0x30>
	    || fd != fd2)
  801011:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801014:	74 16                	je     80102c <fd_close+0x46>
		return (must_exist ? r : 0);
  801016:	89 f8                	mov    %edi,%eax
  801018:	84 c0                	test   %al,%al
  80101a:	b8 00 00 00 00       	mov    $0x0,%eax
  80101f:	0f 44 d8             	cmove  %eax,%ebx
}
  801022:	89 d8                	mov    %ebx,%eax
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	ff 36                	push   (%esi)
  801035:	e8 56 ff ff ff       	call   800f90 <dev_lookup>
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 1a                	js     80105d <fd_close+0x77>
		if (dev->dev_close)
  801043:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801046:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801049:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80104e:	85 c0                	test   %eax,%eax
  801050:	74 0b                	je     80105d <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	56                   	push   %esi
  801056:	ff d0                	call   *%eax
  801058:	89 c3                	mov    %eax,%ebx
  80105a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	56                   	push   %esi
  801061:	6a 00                	push   $0x0
  801063:	e8 f8 fb ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	eb b5                	jmp    801022 <fd_close+0x3c>

0080106d <close>:

int
close(int fdnum)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	ff 75 08             	push   0x8(%ebp)
  80107a:	e8 c1 fe ff ff       	call   800f40 <fd_lookup>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	79 02                	jns    801088 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801086:	c9                   	leave  
  801087:	c3                   	ret    
		return fd_close(fd, 1);
  801088:	83 ec 08             	sub    $0x8,%esp
  80108b:	6a 01                	push   $0x1
  80108d:	ff 75 f4             	push   -0xc(%ebp)
  801090:	e8 51 ff ff ff       	call   800fe6 <fd_close>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	eb ec                	jmp    801086 <close+0x19>

0080109a <close_all>:

void
close_all(void)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	53                   	push   %ebx
  80109e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	53                   	push   %ebx
  8010aa:	e8 be ff ff ff       	call   80106d <close>
	for (i = 0; i < MAXFD; i++)
  8010af:	83 c3 01             	add    $0x1,%ebx
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	83 fb 20             	cmp    $0x20,%ebx
  8010b8:	75 ec                	jne    8010a6 <close_all+0xc>
}
  8010ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	57                   	push   %edi
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	ff 75 08             	push   0x8(%ebp)
  8010cf:	e8 6c fe ff ff       	call   800f40 <fd_lookup>
  8010d4:	89 c3                	mov    %eax,%ebx
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	78 7f                	js     80115c <dup+0x9d>
		return r;
	close(newfdnum);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	ff 75 0c             	push   0xc(%ebp)
  8010e3:	e8 85 ff ff ff       	call   80106d <close>

	newfd = INDEX2FD(newfdnum);
  8010e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010eb:	c1 e6 0c             	shl    $0xc,%esi
  8010ee:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f7:	89 3c 24             	mov    %edi,(%esp)
  8010fa:	e8 da fd ff ff       	call   800ed9 <fd2data>
  8010ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801101:	89 34 24             	mov    %esi,(%esp)
  801104:	e8 d0 fd ff ff       	call   800ed9 <fd2data>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	c1 e8 16             	shr    $0x16,%eax
  801114:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111b:	a8 01                	test   $0x1,%al
  80111d:	74 11                	je     801130 <dup+0x71>
  80111f:	89 d8                	mov    %ebx,%eax
  801121:	c1 e8 0c             	shr    $0xc,%eax
  801124:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112b:	f6 c2 01             	test   $0x1,%dl
  80112e:	75 36                	jne    801166 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801130:	89 f8                	mov    %edi,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	25 07 0e 00 00       	and    $0xe07,%eax
  801144:	50                   	push   %eax
  801145:	56                   	push   %esi
  801146:	6a 00                	push   $0x0
  801148:	57                   	push   %edi
  801149:	6a 00                	push   $0x0
  80114b:	e8 ce fa ff ff       	call   800c1e <sys_page_map>
  801150:	89 c3                	mov    %eax,%ebx
  801152:	83 c4 20             	add    $0x20,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	78 33                	js     80118c <dup+0xcd>
		goto err;

	return newfdnum;
  801159:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80115c:	89 d8                	mov    %ebx,%eax
  80115e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5f                   	pop    %edi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801166:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	25 07 0e 00 00       	and    $0xe07,%eax
  801175:	50                   	push   %eax
  801176:	ff 75 d4             	push   -0x2c(%ebp)
  801179:	6a 00                	push   $0x0
  80117b:	53                   	push   %ebx
  80117c:	6a 00                	push   $0x0
  80117e:	e8 9b fa ff ff       	call   800c1e <sys_page_map>
  801183:	89 c3                	mov    %eax,%ebx
  801185:	83 c4 20             	add    $0x20,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	79 a4                	jns    801130 <dup+0x71>
	sys_page_unmap(0, newfd);
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	56                   	push   %esi
  801190:	6a 00                	push   $0x0
  801192:	e8 c9 fa ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801197:	83 c4 08             	add    $0x8,%esp
  80119a:	ff 75 d4             	push   -0x2c(%ebp)
  80119d:	6a 00                	push   $0x0
  80119f:	e8 bc fa ff ff       	call   800c60 <sys_page_unmap>
	return r;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	eb b3                	jmp    80115c <dup+0x9d>

008011a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 18             	sub    $0x18,%esp
  8011b1:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	56                   	push   %esi
  8011b9:	e8 82 fd ff ff       	call   800f40 <fd_lookup>
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 3c                	js     801201 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	ff 33                	push   (%ebx)
  8011d1:	e8 ba fd ff ff       	call   800f90 <dev_lookup>
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 24                	js     801201 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011dd:	8b 43 08             	mov    0x8(%ebx),%eax
  8011e0:	83 e0 03             	and    $0x3,%eax
  8011e3:	83 f8 01             	cmp    $0x1,%eax
  8011e6:	74 20                	je     801208 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	8b 40 08             	mov    0x8(%eax),%eax
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	74 37                	je     801229 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	ff 75 10             	push   0x10(%ebp)
  8011f8:	ff 75 0c             	push   0xc(%ebp)
  8011fb:	53                   	push   %ebx
  8011fc:	ff d0                	call   *%eax
  8011fe:	83 c4 10             	add    $0x10,%esp
}
  801201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801208:	a1 00 40 80 00       	mov    0x804000,%eax
  80120d:	8b 40 48             	mov    0x48(%eax),%eax
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	56                   	push   %esi
  801214:	50                   	push   %eax
  801215:	68 f1 27 80 00       	push   $0x8027f1
  80121a:	e8 e6 ef ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801227:	eb d8                	jmp    801201 <read+0x58>
		return -E_NOT_SUPP;
  801229:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80122e:	eb d1                	jmp    801201 <read+0x58>

00801230 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801244:	eb 02                	jmp    801248 <readn+0x18>
  801246:	01 c3                	add    %eax,%ebx
  801248:	39 f3                	cmp    %esi,%ebx
  80124a:	73 21                	jae    80126d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	89 f0                	mov    %esi,%eax
  801251:	29 d8                	sub    %ebx,%eax
  801253:	50                   	push   %eax
  801254:	89 d8                	mov    %ebx,%eax
  801256:	03 45 0c             	add    0xc(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	57                   	push   %edi
  80125b:	e8 49 ff ff ff       	call   8011a9 <read>
		if (m < 0)
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 04                	js     80126b <readn+0x3b>
			return m;
		if (m == 0)
  801267:	75 dd                	jne    801246 <readn+0x16>
  801269:	eb 02                	jmp    80126d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80126d:	89 d8                	mov    %ebx,%eax
  80126f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
  80127c:	83 ec 18             	sub    $0x18,%esp
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	53                   	push   %ebx
  801287:	e8 b4 fc ff ff       	call   800f40 <fd_lookup>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 37                	js     8012ca <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801293:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 36                	push   (%esi)
  80129f:	e8 ec fc ff ff       	call   800f90 <dev_lookup>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 1f                	js     8012ca <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ab:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012af:	74 20                	je     8012d1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	74 37                	je     8012f2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	ff 75 10             	push   0x10(%ebp)
  8012c1:	ff 75 0c             	push   0xc(%ebp)
  8012c4:	56                   	push   %esi
  8012c5:	ff d0                	call   *%eax
  8012c7:	83 c4 10             	add    $0x10,%esp
}
  8012ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d1:	a1 00 40 80 00       	mov    0x804000,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	50                   	push   %eax
  8012de:	68 0d 28 80 00       	push   $0x80280d
  8012e3:	e8 1d ef ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f0:	eb d8                	jmp    8012ca <write+0x53>
		return -E_NOT_SUPP;
  8012f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f7:	eb d1                	jmp    8012ca <write+0x53>

008012f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	ff 75 08             	push   0x8(%ebp)
  801306:	e8 35 fc ff ff       	call   800f40 <fd_lookup>
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 0e                	js     801320 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801312:	8b 55 0c             	mov    0xc(%ebp),%edx
  801315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801318:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	83 ec 18             	sub    $0x18,%esp
  80132a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	53                   	push   %ebx
  801332:	e8 09 fc ff ff       	call   800f40 <fd_lookup>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 34                	js     801372 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 36                	push   (%esi)
  80134a:	e8 41 fc ff ff       	call   800f90 <dev_lookup>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 1c                	js     801372 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801356:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80135a:	74 1d                	je     801379 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135f:	8b 40 18             	mov    0x18(%eax),%eax
  801362:	85 c0                	test   %eax,%eax
  801364:	74 34                	je     80139a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	ff 75 0c             	push   0xc(%ebp)
  80136c:	56                   	push   %esi
  80136d:	ff d0                	call   *%eax
  80136f:	83 c4 10             	add    $0x10,%esp
}
  801372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
			thisenv->env_id, fdnum);
  801379:	a1 00 40 80 00       	mov    0x804000,%eax
  80137e:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801381:	83 ec 04             	sub    $0x4,%esp
  801384:	53                   	push   %ebx
  801385:	50                   	push   %eax
  801386:	68 d0 27 80 00       	push   $0x8027d0
  80138b:	e8 75 ee ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801398:	eb d8                	jmp    801372 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80139a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80139f:	eb d1                	jmp    801372 <ftruncate+0x50>

008013a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 18             	sub    $0x18,%esp
  8013a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 75 08             	push   0x8(%ebp)
  8013b3:	e8 88 fb ff ff       	call   800f40 <fd_lookup>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 49                	js     801408 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bf:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	ff 36                	push   (%esi)
  8013cb:	e8 c0 fb ff ff       	call   800f90 <dev_lookup>
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 31                	js     801408 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013de:	74 2f                	je     80140f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ea:	00 00 00 
	stat->st_isdir = 0;
  8013ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f4:	00 00 00 
	stat->st_dev = dev;
  8013f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fd:	83 ec 08             	sub    $0x8,%esp
  801400:	53                   	push   %ebx
  801401:	56                   	push   %esi
  801402:	ff 50 14             	call   *0x14(%eax)
  801405:	83 c4 10             	add    $0x10,%esp
}
  801408:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140b:	5b                   	pop    %ebx
  80140c:	5e                   	pop    %esi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    
		return -E_NOT_SUPP;
  80140f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801414:	eb f2                	jmp    801408 <fstat+0x67>

00801416 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	6a 00                	push   $0x0
  801420:	ff 75 08             	push   0x8(%ebp)
  801423:	e8 e4 01 00 00       	call   80160c <open>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 1b                	js     80144c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 0c             	push   0xc(%ebp)
  801437:	50                   	push   %eax
  801438:	e8 64 ff ff ff       	call   8013a1 <fstat>
  80143d:	89 c6                	mov    %eax,%esi
	close(fd);
  80143f:	89 1c 24             	mov    %ebx,(%esp)
  801442:	e8 26 fc ff ff       	call   80106d <close>
	return r;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	89 f3                	mov    %esi,%ebx
}
  80144c:	89 d8                	mov    %ebx,%eax
  80144e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
  80145a:	89 c6                	mov    %eax,%esi
  80145c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80145e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801465:	74 27                	je     80148e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801467:	6a 07                	push   $0x7
  801469:	68 00 50 80 00       	push   $0x805000
  80146e:	56                   	push   %esi
  80146f:	ff 35 00 60 80 00    	push   0x806000
  801475:	e8 c4 0b 00 00       	call   80203e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80147a:	83 c4 0c             	add    $0xc,%esp
  80147d:	6a 00                	push   $0x0
  80147f:	53                   	push   %ebx
  801480:	6a 00                	push   $0x0
  801482:	e8 50 0b 00 00       	call   801fd7 <ipc_recv>
}
  801487:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5e                   	pop    %esi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	6a 01                	push   $0x1
  801493:	e8 fa 0b 00 00       	call   802092 <ipc_find_env>
  801498:	a3 00 60 80 00       	mov    %eax,0x806000
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	eb c5                	jmp    801467 <fsipc+0x12>

008014a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c5:	e8 8b ff ff ff       	call   801455 <fsipc>
}
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <devfile_flush>:
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e7:	e8 69 ff ff ff       	call   801455 <fsipc>
}
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <devfile_stat>:
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	b8 05 00 00 00       	mov    $0x5,%eax
  80150d:	e8 43 ff ff ff       	call   801455 <fsipc>
  801512:	85 c0                	test   %eax,%eax
  801514:	78 2c                	js     801542 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	68 00 50 80 00       	push   $0x805000
  80151e:	53                   	push   %ebx
  80151f:	e8 bb f2 ff ff       	call   8007df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801524:	a1 80 50 80 00       	mov    0x805080,%eax
  801529:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80152f:	a1 84 50 80 00       	mov    0x805084,%eax
  801534:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <devfile_write>:
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	8b 45 10             	mov    0x10(%ebp),%eax
  801550:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801555:	39 d0                	cmp    %edx,%eax
  801557:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80155a:	8b 55 08             	mov    0x8(%ebp),%edx
  80155d:	8b 52 0c             	mov    0xc(%edx),%edx
  801560:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801566:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80156b:	50                   	push   %eax
  80156c:	ff 75 0c             	push   0xc(%ebp)
  80156f:	68 08 50 80 00       	push   $0x805008
  801574:	e8 fc f3 ff ff       	call   800975 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	b8 04 00 00 00       	mov    $0x4,%eax
  801583:	e8 cd fe ff ff       	call   801455 <fsipc>
}
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <devfile_read>:
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	8b 40 0c             	mov    0xc(%eax),%eax
  801598:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80159d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ad:	e8 a3 fe ff ff       	call   801455 <fsipc>
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 1f                	js     8015d7 <devfile_read+0x4d>
	assert(r <= n);
  8015b8:	39 f0                	cmp    %esi,%eax
  8015ba:	77 24                	ja     8015e0 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c1:	7f 33                	jg     8015f6 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	50                   	push   %eax
  8015c7:	68 00 50 80 00       	push   $0x805000
  8015cc:	ff 75 0c             	push   0xc(%ebp)
  8015cf:	e8 a1 f3 ff ff       	call   800975 <memmove>
	return r;
  8015d4:	83 c4 10             	add    $0x10,%esp
}
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015dc:	5b                   	pop    %ebx
  8015dd:	5e                   	pop    %esi
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    
	assert(r <= n);
  8015e0:	68 40 28 80 00       	push   $0x802840
  8015e5:	68 47 28 80 00       	push   $0x802847
  8015ea:	6a 7c                	push   $0x7c
  8015ec:	68 5c 28 80 00       	push   $0x80285c
  8015f1:	e8 34 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015f6:	68 67 28 80 00       	push   $0x802867
  8015fb:	68 47 28 80 00       	push   $0x802847
  801600:	6a 7d                	push   $0x7d
  801602:	68 5c 28 80 00       	push   $0x80285c
  801607:	e8 1e eb ff ff       	call   80012a <_panic>

0080160c <open>:
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	83 ec 1c             	sub    $0x1c,%esp
  801614:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801617:	56                   	push   %esi
  801618:	e8 87 f1 ff ff       	call   8007a4 <strlen>
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801625:	7f 6c                	jg     801693 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801627:	83 ec 0c             	sub    $0xc,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	e8 bd f8 ff ff       	call   800ef0 <fd_alloc>
  801633:	89 c3                	mov    %eax,%ebx
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 3c                	js     801678 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	56                   	push   %esi
  801640:	68 00 50 80 00       	push   $0x805000
  801645:	e8 95 f1 ff ff       	call   8007df <strcpy>
	fsipcbuf.open.req_omode = mode;
  80164a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801652:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801655:	b8 01 00 00 00       	mov    $0x1,%eax
  80165a:	e8 f6 fd ff ff       	call   801455 <fsipc>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 19                	js     801681 <open+0x75>
	return fd2num(fd);
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	ff 75 f4             	push   -0xc(%ebp)
  80166e:	e8 56 f8 ff ff       	call   800ec9 <fd2num>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	83 c4 10             	add    $0x10,%esp
}
  801678:	89 d8                	mov    %ebx,%eax
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    
		fd_close(fd, 0);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	6a 00                	push   $0x0
  801686:	ff 75 f4             	push   -0xc(%ebp)
  801689:	e8 58 f9 ff ff       	call   800fe6 <fd_close>
		return r;
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb e5                	jmp    801678 <open+0x6c>
		return -E_BAD_PATH;
  801693:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801698:	eb de                	jmp    801678 <open+0x6c>

0080169a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8016aa:	e8 a6 fd ff ff       	call   801455 <fsipc>
}
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016b7:	68 73 28 80 00       	push   $0x802873
  8016bc:	ff 75 0c             	push   0xc(%ebp)
  8016bf:	e8 1b f1 ff ff       	call   8007df <strcpy>
	return 0;
}
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <devsock_close>:
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 10             	sub    $0x10,%esp
  8016d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016d5:	53                   	push   %ebx
  8016d6:	e8 f0 09 00 00       	call   8020cb <pageref>
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016e0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016e5:	83 fa 01             	cmp    $0x1,%edx
  8016e8:	74 05                	je     8016ef <devsock_close+0x24>
}
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	ff 73 0c             	push   0xc(%ebx)
  8016f5:	e8 b7 02 00 00       	call   8019b1 <nsipc_close>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	eb eb                	jmp    8016ea <devsock_close+0x1f>

008016ff <devsock_write>:
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801705:	6a 00                	push   $0x0
  801707:	ff 75 10             	push   0x10(%ebp)
  80170a:	ff 75 0c             	push   0xc(%ebp)
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	ff 70 0c             	push   0xc(%eax)
  801713:	e8 79 03 00 00       	call   801a91 <nsipc_send>
}
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <devsock_read>:
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801720:	6a 00                	push   $0x0
  801722:	ff 75 10             	push   0x10(%ebp)
  801725:	ff 75 0c             	push   0xc(%ebp)
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	ff 70 0c             	push   0xc(%eax)
  80172e:	e8 ef 02 00 00       	call   801a22 <nsipc_recv>
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <fd2sockid>:
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80173b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80173e:	52                   	push   %edx
  80173f:	50                   	push   %eax
  801740:	e8 fb f7 ff ff       	call   800f40 <fd_lookup>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 10                	js     80175c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801755:	39 08                	cmp    %ecx,(%eax)
  801757:	75 05                	jne    80175e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801759:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    
		return -E_NOT_SUPP;
  80175e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801763:	eb f7                	jmp    80175c <fd2sockid+0x27>

00801765 <alloc_sockfd>:
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	83 ec 1c             	sub    $0x1c,%esp
  80176d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80176f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801772:	50                   	push   %eax
  801773:	e8 78 f7 ff ff       	call   800ef0 <fd_alloc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 43                	js     8017c4 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	68 07 04 00 00       	push   $0x407
  801789:	ff 75 f4             	push   -0xc(%ebp)
  80178c:	6a 00                	push   $0x0
  80178e:	e8 48 f4 ff ff       	call   800bdb <sys_page_alloc>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 28                	js     8017c4 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80179c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017b1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	50                   	push   %eax
  8017b8:	e8 0c f7 ff ff       	call   800ec9 <fd2num>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	eb 0c                	jmp    8017d0 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017c4:	83 ec 0c             	sub    $0xc,%esp
  8017c7:	56                   	push   %esi
  8017c8:	e8 e4 01 00 00       	call   8019b1 <nsipc_close>
		return r;
  8017cd:	83 c4 10             	add    $0x10,%esp
}
  8017d0:	89 d8                	mov    %ebx,%eax
  8017d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <accept>:
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	e8 4e ff ff ff       	call   801735 <fd2sockid>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 1b                	js     801806 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	ff 75 10             	push   0x10(%ebp)
  8017f1:	ff 75 0c             	push   0xc(%ebp)
  8017f4:	50                   	push   %eax
  8017f5:	e8 0e 01 00 00       	call   801908 <nsipc_accept>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 05                	js     801806 <accept+0x2d>
	return alloc_sockfd(r);
  801801:	e8 5f ff ff ff       	call   801765 <alloc_sockfd>
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <bind>:
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	e8 1f ff ff ff       	call   801735 <fd2sockid>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 12                	js     80182c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	ff 75 10             	push   0x10(%ebp)
  801820:	ff 75 0c             	push   0xc(%ebp)
  801823:	50                   	push   %eax
  801824:	e8 31 01 00 00       	call   80195a <nsipc_bind>
  801829:	83 c4 10             	add    $0x10,%esp
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <shutdown>:
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	e8 f9 fe ff ff       	call   801735 <fd2sockid>
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 0f                	js     80184f <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	ff 75 0c             	push   0xc(%ebp)
  801846:	50                   	push   %eax
  801847:	e8 43 01 00 00       	call   80198f <nsipc_shutdown>
  80184c:	83 c4 10             	add    $0x10,%esp
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <connect>:
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	e8 d6 fe ff ff       	call   801735 <fd2sockid>
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 12                	js     801875 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801863:	83 ec 04             	sub    $0x4,%esp
  801866:	ff 75 10             	push   0x10(%ebp)
  801869:	ff 75 0c             	push   0xc(%ebp)
  80186c:	50                   	push   %eax
  80186d:	e8 59 01 00 00       	call   8019cb <nsipc_connect>
  801872:	83 c4 10             	add    $0x10,%esp
}
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <listen>:
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	e8 b0 fe ff ff       	call   801735 <fd2sockid>
  801885:	85 c0                	test   %eax,%eax
  801887:	78 0f                	js     801898 <listen+0x21>
	return nsipc_listen(r, backlog);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	ff 75 0c             	push   0xc(%ebp)
  80188f:	50                   	push   %eax
  801890:	e8 6b 01 00 00       	call   801a00 <nsipc_listen>
  801895:	83 c4 10             	add    $0x10,%esp
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <socket>:

int
socket(int domain, int type, int protocol)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018a0:	ff 75 10             	push   0x10(%ebp)
  8018a3:	ff 75 0c             	push   0xc(%ebp)
  8018a6:	ff 75 08             	push   0x8(%ebp)
  8018a9:	e8 41 02 00 00       	call   801aef <nsipc_socket>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 05                	js     8018ba <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018b5:	e8 ab fe ff ff       	call   801765 <alloc_sockfd>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018c5:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8018cc:	74 26                	je     8018f4 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018ce:	6a 07                	push   $0x7
  8018d0:	68 00 70 80 00       	push   $0x807000
  8018d5:	53                   	push   %ebx
  8018d6:	ff 35 00 80 80 00    	push   0x808000
  8018dc:	e8 5d 07 00 00       	call   80203e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018e1:	83 c4 0c             	add    $0xc,%esp
  8018e4:	6a 00                	push   $0x0
  8018e6:	6a 00                	push   $0x0
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 e8 06 00 00       	call   801fd7 <ipc_recv>
}
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018f4:	83 ec 0c             	sub    $0xc,%esp
  8018f7:	6a 02                	push   $0x2
  8018f9:	e8 94 07 00 00       	call   802092 <ipc_find_env>
  8018fe:	a3 00 80 80 00       	mov    %eax,0x808000
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	eb c6                	jmp    8018ce <nsipc+0x12>

00801908 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801918:	8b 06                	mov    (%esi),%eax
  80191a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80191f:	b8 01 00 00 00       	mov    $0x1,%eax
  801924:	e8 93 ff ff ff       	call   8018bc <nsipc>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	85 c0                	test   %eax,%eax
  80192d:	79 09                	jns    801938 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80192f:	89 d8                	mov    %ebx,%eax
  801931:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	ff 35 10 70 80 00    	push   0x807010
  801941:	68 00 70 80 00       	push   $0x807000
  801946:	ff 75 0c             	push   0xc(%ebp)
  801949:	e8 27 f0 ff ff       	call   800975 <memmove>
		*addrlen = ret->ret_addrlen;
  80194e:	a1 10 70 80 00       	mov    0x807010,%eax
  801953:	89 06                	mov    %eax,(%esi)
  801955:	83 c4 10             	add    $0x10,%esp
	return r;
  801958:	eb d5                	jmp    80192f <nsipc_accept+0x27>

0080195a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801964:	8b 45 08             	mov    0x8(%ebp),%eax
  801967:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80196c:	53                   	push   %ebx
  80196d:	ff 75 0c             	push   0xc(%ebp)
  801970:	68 04 70 80 00       	push   $0x807004
  801975:	e8 fb ef ff ff       	call   800975 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80197a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801980:	b8 02 00 00 00       	mov    $0x2,%eax
  801985:	e8 32 ff ff ff       	call   8018bc <nsipc>
}
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80199d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8019a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8019aa:	e8 0d ff ff ff       	call   8018bc <nsipc>
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <nsipc_close>:

int
nsipc_close(int s)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8019bf:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c4:	e8 f3 fe ff ff       	call   8018bc <nsipc>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	53                   	push   %ebx
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019dd:	53                   	push   %ebx
  8019de:	ff 75 0c             	push   0xc(%ebp)
  8019e1:	68 04 70 80 00       	push   $0x807004
  8019e6:	e8 8a ef ff ff       	call   800975 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019eb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8019f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f6:	e8 c1 fe ff ff       	call   8018bc <nsipc>
}
  8019fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a11:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a16:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1b:	e8 9c fe ff ff       	call   8018bc <nsipc>
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a32:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a40:	b8 07 00 00 00       	mov    $0x7,%eax
  801a45:	e8 72 fe ff ff       	call   8018bc <nsipc>
  801a4a:	89 c3                	mov    %eax,%ebx
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 22                	js     801a72 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801a50:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a55:	39 c6                	cmp    %eax,%esi
  801a57:	0f 4e c6             	cmovle %esi,%eax
  801a5a:	39 c3                	cmp    %eax,%ebx
  801a5c:	7f 1d                	jg     801a7b <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a5e:	83 ec 04             	sub    $0x4,%esp
  801a61:	53                   	push   %ebx
  801a62:	68 00 70 80 00       	push   $0x807000
  801a67:	ff 75 0c             	push   0xc(%ebp)
  801a6a:	e8 06 ef ff ff       	call   800975 <memmove>
  801a6f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a72:	89 d8                	mov    %ebx,%eax
  801a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a7b:	68 7f 28 80 00       	push   $0x80287f
  801a80:	68 47 28 80 00       	push   $0x802847
  801a85:	6a 62                	push   $0x62
  801a87:	68 94 28 80 00       	push   $0x802894
  801a8c:	e8 99 e6 ff ff       	call   80012a <_panic>

00801a91 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	53                   	push   %ebx
  801a95:	83 ec 04             	sub    $0x4,%esp
  801a98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801aa3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801aa9:	7f 2e                	jg     801ad9 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801aab:	83 ec 04             	sub    $0x4,%esp
  801aae:	53                   	push   %ebx
  801aaf:	ff 75 0c             	push   0xc(%ebp)
  801ab2:	68 0c 70 80 00       	push   $0x80700c
  801ab7:	e8 b9 ee ff ff       	call   800975 <memmove>
	nsipcbuf.send.req_size = size;
  801abc:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801aca:	b8 08 00 00 00       	mov    $0x8,%eax
  801acf:	e8 e8 fd ff ff       	call   8018bc <nsipc>
}
  801ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    
	assert(size < 1600);
  801ad9:	68 a0 28 80 00       	push   $0x8028a0
  801ade:	68 47 28 80 00       	push   $0x802847
  801ae3:	6a 6d                	push   $0x6d
  801ae5:	68 94 28 80 00       	push   $0x802894
  801aea:	e8 3b e6 ff ff       	call   80012a <_panic>

00801aef <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801af5:	8b 45 08             	mov    0x8(%ebp),%eax
  801af8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b00:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801b05:	8b 45 10             	mov    0x10(%ebp),%eax
  801b08:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801b0d:	b8 09 00 00 00       	mov    $0x9,%eax
  801b12:	e8 a5 fd ff ff       	call   8018bc <nsipc>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b21:	83 ec 0c             	sub    $0xc,%esp
  801b24:	ff 75 08             	push   0x8(%ebp)
  801b27:	e8 ad f3 ff ff       	call   800ed9 <fd2data>
  801b2c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b2e:	83 c4 08             	add    $0x8,%esp
  801b31:	68 ac 28 80 00       	push   $0x8028ac
  801b36:	53                   	push   %ebx
  801b37:	e8 a3 ec ff ff       	call   8007df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b3c:	8b 46 04             	mov    0x4(%esi),%eax
  801b3f:	2b 06                	sub    (%esi),%eax
  801b41:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b4e:	00 00 00 
	stat->st_dev = &devpipe;
  801b51:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b58:	30 80 00 
	return 0;
}
  801b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b71:	53                   	push   %ebx
  801b72:	6a 00                	push   $0x0
  801b74:	e8 e7 f0 ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b79:	89 1c 24             	mov    %ebx,(%esp)
  801b7c:	e8 58 f3 ff ff       	call   800ed9 <fd2data>
  801b81:	83 c4 08             	add    $0x8,%esp
  801b84:	50                   	push   %eax
  801b85:	6a 00                	push   $0x0
  801b87:	e8 d4 f0 ff ff       	call   800c60 <sys_page_unmap>
}
  801b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <_pipeisclosed>:
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 1c             	sub    $0x1c,%esp
  801b9a:	89 c7                	mov    %eax,%edi
  801b9c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b9e:	a1 00 40 80 00       	mov    0x804000,%eax
  801ba3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	57                   	push   %edi
  801baa:	e8 1c 05 00 00       	call   8020cb <pageref>
  801baf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bb2:	89 34 24             	mov    %esi,(%esp)
  801bb5:	e8 11 05 00 00       	call   8020cb <pageref>
		nn = thisenv->env_runs;
  801bba:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801bc0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	39 cb                	cmp    %ecx,%ebx
  801bc8:	74 1b                	je     801be5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bca:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bcd:	75 cf                	jne    801b9e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bcf:	8b 42 58             	mov    0x58(%edx),%eax
  801bd2:	6a 01                	push   $0x1
  801bd4:	50                   	push   %eax
  801bd5:	53                   	push   %ebx
  801bd6:	68 b3 28 80 00       	push   $0x8028b3
  801bdb:	e8 25 e6 ff ff       	call   800205 <cprintf>
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	eb b9                	jmp    801b9e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801be5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801be8:	0f 94 c0             	sete   %al
  801beb:	0f b6 c0             	movzbl %al,%eax
}
  801bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <devpipe_write>:
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	57                   	push   %edi
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 28             	sub    $0x28,%esp
  801bff:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c02:	56                   	push   %esi
  801c03:	e8 d1 f2 ff ff       	call   800ed9 <fd2data>
  801c08:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	bf 00 00 00 00       	mov    $0x0,%edi
  801c12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c15:	75 09                	jne    801c20 <devpipe_write+0x2a>
	return i;
  801c17:	89 f8                	mov    %edi,%eax
  801c19:	eb 23                	jmp    801c3e <devpipe_write+0x48>
			sys_yield();
  801c1b:	e8 9c ef ff ff       	call   800bbc <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c20:	8b 43 04             	mov    0x4(%ebx),%eax
  801c23:	8b 0b                	mov    (%ebx),%ecx
  801c25:	8d 51 20             	lea    0x20(%ecx),%edx
  801c28:	39 d0                	cmp    %edx,%eax
  801c2a:	72 1a                	jb     801c46 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c2c:	89 da                	mov    %ebx,%edx
  801c2e:	89 f0                	mov    %esi,%eax
  801c30:	e8 5c ff ff ff       	call   801b91 <_pipeisclosed>
  801c35:	85 c0                	test   %eax,%eax
  801c37:	74 e2                	je     801c1b <devpipe_write+0x25>
				return 0;
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c49:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c4d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c50:	89 c2                	mov    %eax,%edx
  801c52:	c1 fa 1f             	sar    $0x1f,%edx
  801c55:	89 d1                	mov    %edx,%ecx
  801c57:	c1 e9 1b             	shr    $0x1b,%ecx
  801c5a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c5d:	83 e2 1f             	and    $0x1f,%edx
  801c60:	29 ca                	sub    %ecx,%edx
  801c62:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c6a:	83 c0 01             	add    $0x1,%eax
  801c6d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c70:	83 c7 01             	add    $0x1,%edi
  801c73:	eb 9d                	jmp    801c12 <devpipe_write+0x1c>

00801c75 <devpipe_read>:
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	57                   	push   %edi
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 18             	sub    $0x18,%esp
  801c7e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c81:	57                   	push   %edi
  801c82:	e8 52 f2 ff ff       	call   800ed9 <fd2data>
  801c87:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	be 00 00 00 00       	mov    $0x0,%esi
  801c91:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c94:	75 13                	jne    801ca9 <devpipe_read+0x34>
	return i;
  801c96:	89 f0                	mov    %esi,%eax
  801c98:	eb 02                	jmp    801c9c <devpipe_read+0x27>
				return i;
  801c9a:	89 f0                	mov    %esi,%eax
}
  801c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
			sys_yield();
  801ca4:	e8 13 ef ff ff       	call   800bbc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ca9:	8b 03                	mov    (%ebx),%eax
  801cab:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cae:	75 18                	jne    801cc8 <devpipe_read+0x53>
			if (i > 0)
  801cb0:	85 f6                	test   %esi,%esi
  801cb2:	75 e6                	jne    801c9a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801cb4:	89 da                	mov    %ebx,%edx
  801cb6:	89 f8                	mov    %edi,%eax
  801cb8:	e8 d4 fe ff ff       	call   801b91 <_pipeisclosed>
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	74 e3                	je     801ca4 <devpipe_read+0x2f>
				return 0;
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc6:	eb d4                	jmp    801c9c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc8:	99                   	cltd   
  801cc9:	c1 ea 1b             	shr    $0x1b,%edx
  801ccc:	01 d0                	add    %edx,%eax
  801cce:	83 e0 1f             	and    $0x1f,%eax
  801cd1:	29 d0                	sub    %edx,%eax
  801cd3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cdb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cde:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ce1:	83 c6 01             	add    $0x1,%esi
  801ce4:	eb ab                	jmp    801c91 <devpipe_read+0x1c>

00801ce6 <pipe>:
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	56                   	push   %esi
  801cea:	53                   	push   %ebx
  801ceb:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf1:	50                   	push   %eax
  801cf2:	e8 f9 f1 ff ff       	call   800ef0 <fd_alloc>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	0f 88 23 01 00 00    	js     801e27 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	83 ec 04             	sub    $0x4,%esp
  801d07:	68 07 04 00 00       	push   $0x407
  801d0c:	ff 75 f4             	push   -0xc(%ebp)
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 c5 ee ff ff       	call   800bdb <sys_page_alloc>
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	0f 88 04 01 00 00    	js     801e27 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	e8 c1 f1 ff ff       	call   800ef0 <fd_alloc>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	0f 88 db 00 00 00    	js     801e17 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	83 ec 04             	sub    $0x4,%esp
  801d3f:	68 07 04 00 00       	push   $0x407
  801d44:	ff 75 f0             	push   -0x10(%ebp)
  801d47:	6a 00                	push   $0x0
  801d49:	e8 8d ee ff ff       	call   800bdb <sys_page_alloc>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 bc 00 00 00    	js     801e17 <pipe+0x131>
	va = fd2data(fd0);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	ff 75 f4             	push   -0xc(%ebp)
  801d61:	e8 73 f1 ff ff       	call   800ed9 <fd2data>
  801d66:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d68:	83 c4 0c             	add    $0xc,%esp
  801d6b:	68 07 04 00 00       	push   $0x407
  801d70:	50                   	push   %eax
  801d71:	6a 00                	push   $0x0
  801d73:	e8 63 ee ff ff       	call   800bdb <sys_page_alloc>
  801d78:	89 c3                	mov    %eax,%ebx
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	0f 88 82 00 00 00    	js     801e07 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	ff 75 f0             	push   -0x10(%ebp)
  801d8b:	e8 49 f1 ff ff       	call   800ed9 <fd2data>
  801d90:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d97:	50                   	push   %eax
  801d98:	6a 00                	push   $0x0
  801d9a:	56                   	push   %esi
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 7c ee ff ff       	call   800c1e <sys_page_map>
  801da2:	89 c3                	mov    %eax,%ebx
  801da4:	83 c4 20             	add    $0x20,%esp
  801da7:	85 c0                	test   %eax,%eax
  801da9:	78 4e                	js     801df9 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801dab:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801dbf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dc2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 f4             	push   -0xc(%ebp)
  801dd4:	e8 f0 f0 ff ff       	call   800ec9 <fd2num>
  801dd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dde:	83 c4 04             	add    $0x4,%esp
  801de1:	ff 75 f0             	push   -0x10(%ebp)
  801de4:	e8 e0 f0 ff ff       	call   800ec9 <fd2num>
  801de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df7:	eb 2e                	jmp    801e27 <pipe+0x141>
	sys_page_unmap(0, va);
  801df9:	83 ec 08             	sub    $0x8,%esp
  801dfc:	56                   	push   %esi
  801dfd:	6a 00                	push   $0x0
  801dff:	e8 5c ee ff ff       	call   800c60 <sys_page_unmap>
  801e04:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	ff 75 f0             	push   -0x10(%ebp)
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 4c ee ff ff       	call   800c60 <sys_page_unmap>
  801e14:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e17:	83 ec 08             	sub    $0x8,%esp
  801e1a:	ff 75 f4             	push   -0xc(%ebp)
  801e1d:	6a 00                	push   $0x0
  801e1f:	e8 3c ee ff ff       	call   800c60 <sys_page_unmap>
  801e24:	83 c4 10             	add    $0x10,%esp
}
  801e27:	89 d8                	mov    %ebx,%eax
  801e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5e                   	pop    %esi
  801e2e:	5d                   	pop    %ebp
  801e2f:	c3                   	ret    

00801e30 <pipeisclosed>:
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e39:	50                   	push   %eax
  801e3a:	ff 75 08             	push   0x8(%ebp)
  801e3d:	e8 fe f0 ff ff       	call   800f40 <fd_lookup>
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	78 18                	js     801e61 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e49:	83 ec 0c             	sub    $0xc,%esp
  801e4c:	ff 75 f4             	push   -0xc(%ebp)
  801e4f:	e8 85 f0 ff ff       	call   800ed9 <fd2data>
  801e54:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e59:	e8 33 fd ff ff       	call   801b91 <_pipeisclosed>
  801e5e:	83 c4 10             	add    $0x10,%esp
}
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	c3                   	ret    

00801e69 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e6f:	68 cb 28 80 00       	push   $0x8028cb
  801e74:	ff 75 0c             	push   0xc(%ebp)
  801e77:	e8 63 e9 ff ff       	call   8007df <strcpy>
	return 0;
}
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <devcons_write>:
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	57                   	push   %edi
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e8f:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e94:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e9a:	eb 2e                	jmp    801eca <devcons_write+0x47>
		m = n - tot;
  801e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e9f:	29 f3                	sub    %esi,%ebx
  801ea1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ea6:	39 c3                	cmp    %eax,%ebx
  801ea8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eab:	83 ec 04             	sub    $0x4,%esp
  801eae:	53                   	push   %ebx
  801eaf:	89 f0                	mov    %esi,%eax
  801eb1:	03 45 0c             	add    0xc(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	57                   	push   %edi
  801eb6:	e8 ba ea ff ff       	call   800975 <memmove>
		sys_cputs(buf, m);
  801ebb:	83 c4 08             	add    $0x8,%esp
  801ebe:	53                   	push   %ebx
  801ebf:	57                   	push   %edi
  801ec0:	e8 5a ec ff ff       	call   800b1f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ec5:	01 de                	add    %ebx,%esi
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ecd:	72 cd                	jb     801e9c <devcons_write+0x19>
}
  801ecf:	89 f0                	mov    %esi,%eax
  801ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <devcons_read>:
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ee4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee8:	75 07                	jne    801ef1 <devcons_read+0x18>
  801eea:	eb 1f                	jmp    801f0b <devcons_read+0x32>
		sys_yield();
  801eec:	e8 cb ec ff ff       	call   800bbc <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ef1:	e8 47 ec ff ff       	call   800b3d <sys_cgetc>
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	74 f2                	je     801eec <devcons_read+0x13>
	if (c < 0)
  801efa:	78 0f                	js     801f0b <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801efc:	83 f8 04             	cmp    $0x4,%eax
  801eff:	74 0c                	je     801f0d <devcons_read+0x34>
	*(char*)vbuf = c;
  801f01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f04:	88 02                	mov    %al,(%edx)
	return 1;
  801f06:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f0b:	c9                   	leave  
  801f0c:	c3                   	ret    
		return 0;
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f12:	eb f7                	jmp    801f0b <devcons_read+0x32>

00801f14 <cputchar>:
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f20:	6a 01                	push   $0x1
  801f22:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f25:	50                   	push   %eax
  801f26:	e8 f4 eb ff ff       	call   800b1f <sys_cputs>
}
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <getchar>:
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f36:	6a 01                	push   $0x1
  801f38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	6a 00                	push   $0x0
  801f3e:	e8 66 f2 ff ff       	call   8011a9 <read>
	if (r < 0)
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 06                	js     801f50 <getchar+0x20>
	if (r < 1)
  801f4a:	74 06                	je     801f52 <getchar+0x22>
	return c;
  801f4c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    
		return -E_EOF;
  801f52:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f57:	eb f7                	jmp    801f50 <getchar+0x20>

00801f59 <iscons>:
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	ff 75 08             	push   0x8(%ebp)
  801f66:	e8 d5 ef ff ff       	call   800f40 <fd_lookup>
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 11                	js     801f83 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f75:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f7b:	39 10                	cmp    %edx,(%eax)
  801f7d:	0f 94 c0             	sete   %al
  801f80:	0f b6 c0             	movzbl %al,%eax
}
  801f83:	c9                   	leave  
  801f84:	c3                   	ret    

00801f85 <opencons>:
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8e:	50                   	push   %eax
  801f8f:	e8 5c ef ff ff       	call   800ef0 <fd_alloc>
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	78 3a                	js     801fd5 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9b:	83 ec 04             	sub    $0x4,%esp
  801f9e:	68 07 04 00 00       	push   $0x407
  801fa3:	ff 75 f4             	push   -0xc(%ebp)
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 2e ec ff ff       	call   800bdb <sys_page_alloc>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 21                	js     801fd5 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fbd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	50                   	push   %eax
  801fcd:	e8 f7 ee ff ff       	call   800ec9 <fd2num>
  801fd2:	83 c4 10             	add    $0x10,%esp
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fec:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	50                   	push   %eax
  801ff3:	e8 93 ed ff ff       	call   800d8b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	85 f6                	test   %esi,%esi
  801ffd:	74 14                	je     802013 <ipc_recv+0x3c>
  801fff:	ba 00 00 00 00       	mov    $0x0,%edx
  802004:	85 c0                	test   %eax,%eax
  802006:	78 09                	js     802011 <ipc_recv+0x3a>
  802008:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80200e:	8b 52 74             	mov    0x74(%edx),%edx
  802011:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802013:	85 db                	test   %ebx,%ebx
  802015:	74 14                	je     80202b <ipc_recv+0x54>
  802017:	ba 00 00 00 00       	mov    $0x0,%edx
  80201c:	85 c0                	test   %eax,%eax
  80201e:	78 09                	js     802029 <ipc_recv+0x52>
  802020:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802026:	8b 52 78             	mov    0x78(%edx),%edx
  802029:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 08                	js     802037 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80202f:	a1 00 40 80 00       	mov    0x804000,%eax
  802034:	8b 40 70             	mov    0x70(%eax),%eax
}
  802037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802050:	85 db                	test   %ebx,%ebx
  802052:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802057:	0f 44 d8             	cmove  %eax,%ebx
  80205a:	eb 05                	jmp    802061 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80205c:	e8 5b eb ff ff       	call   800bbc <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802061:	ff 75 14             	push   0x14(%ebp)
  802064:	53                   	push   %ebx
  802065:	56                   	push   %esi
  802066:	57                   	push   %edi
  802067:	e8 fc ec ff ff       	call   800d68 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802072:	74 e8                	je     80205c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802074:	85 c0                	test   %eax,%eax
  802076:	78 08                	js     802080 <ipc_send+0x42>
	}while (r<0);

}
  802078:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207b:	5b                   	pop    %ebx
  80207c:	5e                   	pop    %esi
  80207d:	5f                   	pop    %edi
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802080:	50                   	push   %eax
  802081:	68 d7 28 80 00       	push   $0x8028d7
  802086:	6a 3d                	push   $0x3d
  802088:	68 eb 28 80 00       	push   $0x8028eb
  80208d:	e8 98 e0 ff ff       	call   80012a <_panic>

00802092 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802098:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a6:	8b 52 50             	mov    0x50(%edx),%edx
  8020a9:	39 ca                	cmp    %ecx,%edx
  8020ab:	74 11                	je     8020be <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8020ad:	83 c0 01             	add    $0x1,%eax
  8020b0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b5:	75 e6                	jne    80209d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020bc:	eb 0b                	jmp    8020c9 <ipc_find_env+0x37>
			return envs[i].env_id;
  8020be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c6:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d1:	89 c2                	mov    %eax,%edx
  8020d3:	c1 ea 16             	shr    $0x16,%edx
  8020d6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020dd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020e2:	f6 c1 01             	test   $0x1,%cl
  8020e5:	74 1c                	je     802103 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8020e7:	c1 e8 0c             	shr    $0xc,%eax
  8020ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020f1:	a8 01                	test   $0x1,%al
  8020f3:	74 0e                	je     802103 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f5:	c1 e8 0c             	shr    $0xc,%eax
  8020f8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020ff:	ef 
  802100:	0f b7 d2             	movzwl %dx,%edx
}
  802103:	89 d0                	mov    %edx,%eax
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	66 90                	xchg   %ax,%ax
  802109:	66 90                	xchg   %ax,%ax
  80210b:	66 90                	xchg   %ax,%ax
  80210d:	66 90                	xchg   %ax,%ax
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80211f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802123:	8b 74 24 34          	mov    0x34(%esp),%esi
  802127:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80212b:	85 c0                	test   %eax,%eax
  80212d:	75 19                	jne    802148 <__udivdi3+0x38>
  80212f:	39 f3                	cmp    %esi,%ebx
  802131:	76 4d                	jbe    802180 <__udivdi3+0x70>
  802133:	31 ff                	xor    %edi,%edi
  802135:	89 e8                	mov    %ebp,%eax
  802137:	89 f2                	mov    %esi,%edx
  802139:	f7 f3                	div    %ebx
  80213b:	89 fa                	mov    %edi,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 f0                	cmp    %esi,%eax
  80214a:	76 14                	jbe    802160 <__udivdi3+0x50>
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	31 c0                	xor    %eax,%eax
  802150:	89 fa                	mov    %edi,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	0f bd f8             	bsr    %eax,%edi
  802163:	83 f7 1f             	xor    $0x1f,%edi
  802166:	75 48                	jne    8021b0 <__udivdi3+0xa0>
  802168:	39 f0                	cmp    %esi,%eax
  80216a:	72 06                	jb     802172 <__udivdi3+0x62>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 de                	ja     802150 <__udivdi3+0x40>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb d7                	jmp    802150 <__udivdi3+0x40>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d9                	mov    %ebx,%ecx
  802182:	85 db                	test   %ebx,%ebx
  802184:	75 0b                	jne    802191 <__udivdi3+0x81>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f3                	div    %ebx
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	31 d2                	xor    %edx,%edx
  802193:	89 f0                	mov    %esi,%eax
  802195:	f7 f1                	div    %ecx
  802197:	89 c6                	mov    %eax,%esi
  802199:	89 e8                	mov    %ebp,%eax
  80219b:	89 f7                	mov    %esi,%edi
  80219d:	f7 f1                	div    %ecx
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 f9                	mov    %edi,%ecx
  8021b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b7:	29 fa                	sub    %edi,%edx
  8021b9:	d3 e0                	shl    %cl,%eax
  8021bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021bf:	89 d1                	mov    %edx,%ecx
  8021c1:	89 d8                	mov    %ebx,%eax
  8021c3:	d3 e8                	shr    %cl,%eax
  8021c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c9:	09 c1                	or     %eax,%ecx
  8021cb:	89 f0                	mov    %esi,%eax
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e3                	shl    %cl,%ebx
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 f9                	mov    %edi,%ecx
  8021db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021df:	89 eb                	mov    %ebp,%ebx
  8021e1:	d3 e6                	shl    %cl,%esi
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 eb                	shr    %cl,%ebx
  8021e7:	09 f3                	or     %esi,%ebx
  8021e9:	89 c6                	mov    %eax,%esi
  8021eb:	89 f2                	mov    %esi,%edx
  8021ed:	89 d8                	mov    %ebx,%eax
  8021ef:	f7 74 24 08          	divl   0x8(%esp)
  8021f3:	89 d6                	mov    %edx,%esi
  8021f5:	89 c3                	mov    %eax,%ebx
  8021f7:	f7 64 24 0c          	mull   0xc(%esp)
  8021fb:	39 d6                	cmp    %edx,%esi
  8021fd:	72 19                	jb     802218 <__udivdi3+0x108>
  8021ff:	89 f9                	mov    %edi,%ecx
  802201:	d3 e5                	shl    %cl,%ebp
  802203:	39 c5                	cmp    %eax,%ebp
  802205:	73 04                	jae    80220b <__udivdi3+0xfb>
  802207:	39 d6                	cmp    %edx,%esi
  802209:	74 0d                	je     802218 <__udivdi3+0x108>
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	31 ff                	xor    %edi,%edi
  80220f:	e9 3c ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80221b:	31 ff                	xor    %edi,%edi
  80221d:	e9 2e ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	f3 0f 1e fb          	endbr32 
  802234:	55                   	push   %ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	83 ec 1c             	sub    $0x1c,%esp
  80223b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80223f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802243:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802247:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80224b:	89 f0                	mov    %esi,%eax
  80224d:	89 da                	mov    %ebx,%edx
  80224f:	85 ff                	test   %edi,%edi
  802251:	75 15                	jne    802268 <__umoddi3+0x38>
  802253:	39 dd                	cmp    %ebx,%ebp
  802255:	76 39                	jbe    802290 <__umoddi3+0x60>
  802257:	f7 f5                	div    %ebp
  802259:	89 d0                	mov    %edx,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	83 c4 1c             	add    $0x1c,%esp
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
  802268:	39 df                	cmp    %ebx,%edi
  80226a:	77 f1                	ja     80225d <__umoddi3+0x2d>
  80226c:	0f bd cf             	bsr    %edi,%ecx
  80226f:	83 f1 1f             	xor    $0x1f,%ecx
  802272:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802276:	75 40                	jne    8022b8 <__umoddi3+0x88>
  802278:	39 df                	cmp    %ebx,%edi
  80227a:	72 04                	jb     802280 <__umoddi3+0x50>
  80227c:	39 f5                	cmp    %esi,%ebp
  80227e:	77 dd                	ja     80225d <__umoddi3+0x2d>
  802280:	89 da                	mov    %ebx,%edx
  802282:	89 f0                	mov    %esi,%eax
  802284:	29 e8                	sub    %ebp,%eax
  802286:	19 fa                	sbb    %edi,%edx
  802288:	eb d3                	jmp    80225d <__umoddi3+0x2d>
  80228a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802290:	89 e9                	mov    %ebp,%ecx
  802292:	85 ed                	test   %ebp,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x71>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f5                	div    %ebp
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	89 d8                	mov    %ebx,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f1                	div    %ecx
  8022a7:	89 f0                	mov    %esi,%eax
  8022a9:	f7 f1                	div    %ecx
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	31 d2                	xor    %edx,%edx
  8022af:	eb ac                	jmp    80225d <__umoddi3+0x2d>
  8022b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8022c1:	29 c2                	sub    %eax,%edx
  8022c3:	89 c1                	mov    %eax,%ecx
  8022c5:	89 e8                	mov    %ebp,%eax
  8022c7:	d3 e7                	shl    %cl,%edi
  8022c9:	89 d1                	mov    %edx,%ecx
  8022cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022cf:	d3 e8                	shr    %cl,%eax
  8022d1:	89 c1                	mov    %eax,%ecx
  8022d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022d7:	09 f9                	or     %edi,%ecx
  8022d9:	89 df                	mov    %ebx,%edi
  8022db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022df:	89 c1                	mov    %eax,%ecx
  8022e1:	d3 e5                	shl    %cl,%ebp
  8022e3:	89 d1                	mov    %edx,%ecx
  8022e5:	d3 ef                	shr    %cl,%edi
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	89 f0                	mov    %esi,%eax
  8022eb:	d3 e3                	shl    %cl,%ebx
  8022ed:	89 d1                	mov    %edx,%ecx
  8022ef:	89 fa                	mov    %edi,%edx
  8022f1:	d3 e8                	shr    %cl,%eax
  8022f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022f8:	09 d8                	or     %ebx,%eax
  8022fa:	f7 74 24 08          	divl   0x8(%esp)
  8022fe:	89 d3                	mov    %edx,%ebx
  802300:	d3 e6                	shl    %cl,%esi
  802302:	f7 e5                	mul    %ebp
  802304:	89 c7                	mov    %eax,%edi
  802306:	89 d1                	mov    %edx,%ecx
  802308:	39 d3                	cmp    %edx,%ebx
  80230a:	72 06                	jb     802312 <__umoddi3+0xe2>
  80230c:	75 0e                	jne    80231c <__umoddi3+0xec>
  80230e:	39 c6                	cmp    %eax,%esi
  802310:	73 0a                	jae    80231c <__umoddi3+0xec>
  802312:	29 e8                	sub    %ebp,%eax
  802314:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802318:	89 d1                	mov    %edx,%ecx
  80231a:	89 c7                	mov    %eax,%edi
  80231c:	89 f5                	mov    %esi,%ebp
  80231e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802322:	29 fd                	sub    %edi,%ebp
  802324:	19 cb                	sbb    %ecx,%ebx
  802326:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	d3 e0                	shl    %cl,%eax
  80232f:	89 f1                	mov    %esi,%ecx
  802331:	d3 ed                	shr    %cl,%ebp
  802333:	d3 eb                	shr    %cl,%ebx
  802335:	09 e8                	or     %ebp,%eax
  802337:	89 da                	mov    %ebx,%edx
  802339:	83 c4 1c             	add    $0x1c,%esp
  80233c:	5b                   	pop    %ebx
  80233d:	5e                   	pop    %esi
  80233e:	5f                   	pop    %edi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    
