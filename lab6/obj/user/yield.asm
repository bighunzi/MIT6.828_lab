
obj/user/yield.debug：     文件格式 elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 80 22 80 00       	push   $0x802280
  800048:	e8 42 01 00 00       	call   80018f <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 ec 0a 00 00       	call   800b46 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 00 40 80 00       	mov    0x804000,%eax
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 a0 22 80 00       	push   $0x8022a0
  80006c:	e8 1e 01 00 00       	call   80018f <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 00 40 80 00       	mov    0x804000,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 cc 22 80 00       	push   $0x8022cc
  80008d:	e8 fd 00 00 00       	call   80018f <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 7d 0a 00 00       	call   800b27 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 9d 0e 00 00       	call   800f88 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 f1 09 00 00       	call   800ae6 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	74 09                	je     800122 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	68 ff 00 00 00       	push   $0xff
  80012a:	8d 43 08             	lea    0x8(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 76 09 00 00       	call   800aa9 <sys_cputs>
		b->idx = 0;
  800133:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	eb db                	jmp    800119 <putch+0x1f>

0080013e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800147:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014e:	00 00 00 
	b.cnt = 0;
  800151:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800158:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015b:	ff 75 0c             	push   0xc(%ebp)
  80015e:	ff 75 08             	push   0x8(%ebp)
  800161:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	68 fa 00 80 00       	push   $0x8000fa
  80016d:	e8 14 01 00 00       	call   800286 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800172:	83 c4 08             	add    $0x8,%esp
  800175:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	e8 22 09 00 00       	call   800aa9 <sys_cputs>

	return b.cnt;
}
  800187:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800195:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800198:	50                   	push   %eax
  800199:	ff 75 08             	push   0x8(%ebp)
  80019c:	e8 9d ff ff ff       	call   80013e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 1c             	sub    $0x1c,%esp
  8001ac:	89 c7                	mov    %eax,%edi
  8001ae:	89 d6                	mov    %edx,%esi
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b6:	89 d1                	mov    %edx,%ecx
  8001b8:	89 c2                	mov    %eax,%edx
  8001ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d0:	39 c2                	cmp    %eax,%edx
  8001d2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d5:	72 3e                	jb     800215 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	ff 75 18             	push   0x18(%ebp)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	53                   	push   %ebx
  8001e1:	50                   	push   %eax
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	ff 75 e4             	push   -0x1c(%ebp)
  8001e8:	ff 75 e0             	push   -0x20(%ebp)
  8001eb:	ff 75 dc             	push   -0x24(%ebp)
  8001ee:	ff 75 d8             	push   -0x28(%ebp)
  8001f1:	e8 4a 1e 00 00       	call   802040 <__udivdi3>
  8001f6:	83 c4 18             	add    $0x18,%esp
  8001f9:	52                   	push   %edx
  8001fa:	50                   	push   %eax
  8001fb:	89 f2                	mov    %esi,%edx
  8001fd:	89 f8                	mov    %edi,%eax
  8001ff:	e8 9f ff ff ff       	call   8001a3 <printnum>
  800204:	83 c4 20             	add    $0x20,%esp
  800207:	eb 13                	jmp    80021c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	ff 75 18             	push   0x18(%ebp)
  800210:	ff d7                	call   *%edi
  800212:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800215:	83 eb 01             	sub    $0x1,%ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f ed                	jg     800209 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	ff 75 e4             	push   -0x1c(%ebp)
  800226:	ff 75 e0             	push   -0x20(%ebp)
  800229:	ff 75 dc             	push   -0x24(%ebp)
  80022c:	ff 75 d8             	push   -0x28(%ebp)
  80022f:	e8 2c 1f 00 00       	call   802160 <__umoddi3>
  800234:	83 c4 14             	add    $0x14,%esp
  800237:	0f be 80 f5 22 80 00 	movsbl 0x8022f5(%eax),%eax
  80023e:	50                   	push   %eax
  80023f:	ff d7                	call   *%edi
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800252:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800256:	8b 10                	mov    (%eax),%edx
  800258:	3b 50 04             	cmp    0x4(%eax),%edx
  80025b:	73 0a                	jae    800267 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	88 02                	mov    %al,(%edx)
}
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <printfmt>:
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80026f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800272:	50                   	push   %eax
  800273:	ff 75 10             	push   0x10(%ebp)
  800276:	ff 75 0c             	push   0xc(%ebp)
  800279:	ff 75 08             	push   0x8(%ebp)
  80027c:	e8 05 00 00 00       	call   800286 <vprintfmt>
}
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <vprintfmt>:
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 3c             	sub    $0x3c,%esp
  80028f:	8b 75 08             	mov    0x8(%ebp),%esi
  800292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800295:	8b 7d 10             	mov    0x10(%ebp),%edi
  800298:	eb 0a                	jmp    8002a4 <vprintfmt+0x1e>
			putch(ch, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	53                   	push   %ebx
  80029e:	50                   	push   %eax
  80029f:	ff d6                	call   *%esi
  8002a1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a4:	83 c7 01             	add    $0x1,%edi
  8002a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ab:	83 f8 25             	cmp    $0x25,%eax
  8002ae:	74 0c                	je     8002bc <vprintfmt+0x36>
			if (ch == '\0')
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	75 e6                	jne    80029a <vprintfmt+0x14>
}
  8002b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    
		padc = ' ';
  8002bc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002c7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8d 47 01             	lea    0x1(%edi),%eax
  8002dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e0:	0f b6 17             	movzbl (%edi),%edx
  8002e3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e6:	3c 55                	cmp    $0x55,%al
  8002e8:	0f 87 bb 03 00 00    	ja     8006a9 <vprintfmt+0x423>
  8002ee:	0f b6 c0             	movzbl %al,%eax
  8002f1:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  8002f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fb:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002ff:	eb d9                	jmp    8002da <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800304:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800308:	eb d0                	jmp    8002da <vprintfmt+0x54>
  80030a:	0f b6 d2             	movzbl %dl,%edx
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800322:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800325:	83 f9 09             	cmp    $0x9,%ecx
  800328:	77 55                	ja     80037f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 40 04             	lea    0x4(%eax),%eax
  80033d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800343:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800347:	79 91                	jns    8002da <vprintfmt+0x54>
				width = precision, precision = -1;
  800349:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80034c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800356:	eb 82                	jmp    8002da <vprintfmt+0x54>
  800358:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80035b:	85 d2                	test   %edx,%edx
  80035d:	b8 00 00 00 00       	mov    $0x0,%eax
  800362:	0f 49 c2             	cmovns %edx,%eax
  800365:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80036b:	e9 6a ff ff ff       	jmp    8002da <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800373:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80037a:	e9 5b ff ff ff       	jmp    8002da <vprintfmt+0x54>
  80037f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800382:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800385:	eb bc                	jmp    800343 <vprintfmt+0xbd>
			lflag++;
  800387:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038d:	e9 48 ff ff ff       	jmp    8002da <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	8d 78 04             	lea    0x4(%eax),%edi
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	53                   	push   %ebx
  80039c:	ff 30                	push   (%eax)
  80039e:	ff d6                	call   *%esi
			break;
  8003a0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a6:	e9 9d 02 00 00       	jmp    800648 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 78 04             	lea    0x4(%eax),%edi
  8003b1:	8b 10                	mov    (%eax),%edx
  8003b3:	89 d0                	mov    %edx,%eax
  8003b5:	f7 d8                	neg    %eax
  8003b7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 23                	jg     8003e2 <vprintfmt+0x15c>
  8003bf:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	74 18                	je     8003e2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 d5 26 80 00       	push   $0x8026d5
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 92 fe ff ff       	call   800269 <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003da:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dd:	e9 66 02 00 00       	jmp    800648 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003e2:	50                   	push   %eax
  8003e3:	68 0d 23 80 00       	push   $0x80230d
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 7a fe ff ff       	call   800269 <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f5:	e9 4e 02 00 00       	jmp    800648 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	83 c0 04             	add    $0x4,%eax
  800400:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800408:	85 d2                	test   %edx,%edx
  80040a:	b8 06 23 80 00       	mov    $0x802306,%eax
  80040f:	0f 45 c2             	cmovne %edx,%eax
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800419:	7e 06                	jle    800421 <vprintfmt+0x19b>
  80041b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80041f:	75 0d                	jne    80042e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800421:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800424:	89 c7                	mov    %eax,%edi
  800426:	03 45 e0             	add    -0x20(%ebp),%eax
  800429:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042c:	eb 55                	jmp    800483 <vprintfmt+0x1fd>
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 d8             	push   -0x28(%ebp)
  800434:	ff 75 cc             	push   -0x34(%ebp)
  800437:	e8 0a 03 00 00       	call   800746 <strnlen>
  80043c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043f:	29 c1                	sub    %eax,%ecx
  800441:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800449:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800450:	eb 0f                	jmp    800461 <vprintfmt+0x1db>
					putch(padc, putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	53                   	push   %ebx
  800456:	ff 75 e0             	push   -0x20(%ebp)
  800459:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	83 ef 01             	sub    $0x1,%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	85 ff                	test   %edi,%edi
  800463:	7f ed                	jg     800452 <vprintfmt+0x1cc>
  800465:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800468:	85 d2                	test   %edx,%edx
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 49 c2             	cmovns %edx,%eax
  800472:	29 c2                	sub    %eax,%edx
  800474:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800477:	eb a8                	jmp    800421 <vprintfmt+0x19b>
					putch(ch, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	52                   	push   %edx
  80047e:	ff d6                	call   *%esi
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800486:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800488:	83 c7 01             	add    $0x1,%edi
  80048b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048f:	0f be d0             	movsbl %al,%edx
  800492:	85 d2                	test   %edx,%edx
  800494:	74 4b                	je     8004e1 <vprintfmt+0x25b>
  800496:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049a:	78 06                	js     8004a2 <vprintfmt+0x21c>
  80049c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a0:	78 1e                	js     8004c0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a6:	74 d1                	je     800479 <vprintfmt+0x1f3>
  8004a8:	0f be c0             	movsbl %al,%eax
  8004ab:	83 e8 20             	sub    $0x20,%eax
  8004ae:	83 f8 5e             	cmp    $0x5e,%eax
  8004b1:	76 c6                	jbe    800479 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	6a 3f                	push   $0x3f
  8004b9:	ff d6                	call   *%esi
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	eb c3                	jmp    800483 <vprintfmt+0x1fd>
  8004c0:	89 cf                	mov    %ecx,%edi
  8004c2:	eb 0e                	jmp    8004d2 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	6a 20                	push   $0x20
  8004ca:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f ee                	jg     8004c4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004dc:	e9 67 01 00 00       	jmp    800648 <vprintfmt+0x3c2>
  8004e1:	89 cf                	mov    %ecx,%edi
  8004e3:	eb ed                	jmp    8004d2 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004e5:	83 f9 01             	cmp    $0x1,%ecx
  8004e8:	7f 1b                	jg     800505 <vprintfmt+0x27f>
	else if (lflag)
  8004ea:	85 c9                	test   %ecx,%ecx
  8004ec:	74 63                	je     800551 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f6:	99                   	cltd   
  8004f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 40 04             	lea    0x4(%eax),%eax
  800500:	89 45 14             	mov    %eax,0x14(%ebp)
  800503:	eb 17                	jmp    80051c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 50 04             	mov    0x4(%eax),%edx
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 08             	lea    0x8(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80051c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800522:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800527:	85 c9                	test   %ecx,%ecx
  800529:	0f 89 ff 00 00 00    	jns    80062e <vprintfmt+0x3a8>
				putch('-', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	6a 2d                	push   $0x2d
  800535:	ff d6                	call   *%esi
				num = -(long long) num;
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053d:	f7 da                	neg    %edx
  80053f:	83 d1 00             	adc    $0x0,%ecx
  800542:	f7 d9                	neg    %ecx
  800544:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800547:	bf 0a 00 00 00       	mov    $0xa,%edi
  80054c:	e9 dd 00 00 00       	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8b 00                	mov    (%eax),%eax
  800556:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800559:	99                   	cltd   
  80055a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 40 04             	lea    0x4(%eax),%eax
  800563:	89 45 14             	mov    %eax,0x14(%ebp)
  800566:	eb b4                	jmp    80051c <vprintfmt+0x296>
	if (lflag >= 2)
  800568:	83 f9 01             	cmp    $0x1,%ecx
  80056b:	7f 1e                	jg     80058b <vprintfmt+0x305>
	else if (lflag)
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	74 32                	je     8005a3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 10                	mov    (%eax),%edx
  800576:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057b:	8d 40 04             	lea    0x4(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800581:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800586:	e9 a3 00 00 00       	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	8b 48 04             	mov    0x4(%eax),%ecx
  800593:	8d 40 08             	lea    0x8(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800599:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80059e:	e9 8b 00 00 00       	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005b8:	eb 74                	jmp    80062e <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005ba:	83 f9 01             	cmp    $0x1,%ecx
  8005bd:	7f 1b                	jg     8005da <vprintfmt+0x354>
	else if (lflag)
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	74 2c                	je     8005ef <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d3:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005d8:	eb 54                	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e2:	8d 40 08             	lea    0x8(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005ed:	eb 3f                	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ff:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800604:	eb 28                	jmp    80062e <vprintfmt+0x3a8>
			putch('0', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 30                	push   $0x30
  80060c:	ff d6                	call   *%esi
			putch('x', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 78                	push   $0x78
  800614:	ff d6                	call   *%esi
			num = (unsigned long long)
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800620:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800629:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800635:	50                   	push   %eax
  800636:	ff 75 e0             	push   -0x20(%ebp)
  800639:	57                   	push   %edi
  80063a:	51                   	push   %ecx
  80063b:	52                   	push   %edx
  80063c:	89 da                	mov    %ebx,%edx
  80063e:	89 f0                	mov    %esi,%eax
  800640:	e8 5e fb ff ff       	call   8001a3 <printnum>
			break;
  800645:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064b:	e9 54 fc ff ff       	jmp    8002a4 <vprintfmt+0x1e>
	if (lflag >= 2)
  800650:	83 f9 01             	cmp    $0x1,%ecx
  800653:	7f 1b                	jg     800670 <vprintfmt+0x3ea>
	else if (lflag)
  800655:	85 c9                	test   %ecx,%ecx
  800657:	74 2c                	je     800685 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800669:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80066e:	eb be                	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	8b 48 04             	mov    0x4(%eax),%ecx
  800678:	8d 40 08             	lea    0x8(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800683:	eb a9                	jmp    80062e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800695:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80069a:	eb 92                	jmp    80062e <vprintfmt+0x3a8>
			putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 25                	push   $0x25
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb 9f                	jmp    800648 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 25                	push   $0x25
  8006af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	89 f8                	mov    %edi,%eax
  8006b6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ba:	74 05                	je     8006c1 <vprintfmt+0x43b>
  8006bc:	83 e8 01             	sub    $0x1,%eax
  8006bf:	eb f5                	jmp    8006b6 <vprintfmt+0x430>
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c4:	eb 82                	jmp    800648 <vprintfmt+0x3c2>

008006c6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 18             	sub    $0x18,%esp
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	74 26                	je     80070d <vsnprintf+0x47>
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	7e 22                	jle    80070d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006eb:	ff 75 14             	push   0x14(%ebp)
  8006ee:	ff 75 10             	push   0x10(%ebp)
  8006f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	68 4c 02 80 00       	push   $0x80024c
  8006fa:	e8 87 fb ff ff       	call   800286 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800702:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800708:	83 c4 10             	add    $0x10,%esp
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    
		return -E_INVAL;
  80070d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800712:	eb f7                	jmp    80070b <vsnprintf+0x45>

00800714 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071d:	50                   	push   %eax
  80071e:	ff 75 10             	push   0x10(%ebp)
  800721:	ff 75 0c             	push   0xc(%ebp)
  800724:	ff 75 08             	push   0x8(%ebp)
  800727:	e8 9a ff ff ff       	call   8006c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072c:	c9                   	leave  
  80072d:	c3                   	ret    

0080072e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800734:	b8 00 00 00 00       	mov    $0x0,%eax
  800739:	eb 03                	jmp    80073e <strlen+0x10>
		n++;
  80073b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80073e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800742:	75 f7                	jne    80073b <strlen+0xd>
	return n;
}
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 03                	jmp    800759 <strnlen+0x13>
		n++;
  800756:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800759:	39 d0                	cmp    %edx,%eax
  80075b:	74 08                	je     800765 <strnlen+0x1f>
  80075d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800761:	75 f3                	jne    800756 <strnlen+0x10>
  800763:	89 c2                	mov    %eax,%edx
	return n;
}
  800765:	89 d0                	mov    %edx,%eax
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	53                   	push   %ebx
  80076d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800773:	b8 00 00 00 00       	mov    $0x0,%eax
  800778:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80077c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077f:	83 c0 01             	add    $0x1,%eax
  800782:	84 d2                	test   %dl,%dl
  800784:	75 f2                	jne    800778 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800786:	89 c8                	mov    %ecx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	53                   	push   %ebx
  800791:	83 ec 10             	sub    $0x10,%esp
  800794:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800797:	53                   	push   %ebx
  800798:	e8 91 ff ff ff       	call   80072e <strlen>
  80079d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a0:	ff 75 0c             	push   0xc(%ebp)
  8007a3:	01 d8                	add    %ebx,%eax
  8007a5:	50                   	push   %eax
  8007a6:	e8 be ff ff ff       	call   800769 <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	89 f3                	mov    %esi,%ebx
  8007bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	eb 0f                	jmp    8007d5 <strncpy+0x23>
		*dst++ = *src;
  8007c6:	83 c0 01             	add    $0x1,%eax
  8007c9:	0f b6 0a             	movzbl (%edx),%ecx
  8007cc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cf:	80 f9 01             	cmp    $0x1,%cl
  8007d2:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007d5:	39 d8                	cmp    %ebx,%eax
  8007d7:	75 ed                	jne    8007c6 <strncpy+0x14>
	}
	return ret;
}
  8007d9:	89 f0                	mov    %esi,%eax
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ef:	85 d2                	test   %edx,%edx
  8007f1:	74 21                	je     800814 <strlcpy+0x35>
  8007f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f7:	89 f2                	mov    %esi,%edx
  8007f9:	eb 09                	jmp    800804 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800804:	39 c2                	cmp    %eax,%edx
  800806:	74 09                	je     800811 <strlcpy+0x32>
  800808:	0f b6 19             	movzbl (%ecx),%ebx
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ec                	jne    8007fb <strlcpy+0x1c>
  80080f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800811:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800814:	29 f0                	sub    %esi,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800823:	eb 06                	jmp    80082b <strcmp+0x11>
		p++, q++;
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082b:	0f b6 01             	movzbl (%ecx),%eax
  80082e:	84 c0                	test   %al,%al
  800830:	74 04                	je     800836 <strcmp+0x1c>
  800832:	3a 02                	cmp    (%edx),%al
  800834:	74 ef                	je     800825 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	0f b6 c0             	movzbl %al,%eax
  800839:	0f b6 12             	movzbl (%edx),%edx
  80083c:	29 d0                	sub    %edx,%eax
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	89 c3                	mov    %eax,%ebx
  80084c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084f:	eb 06                	jmp    800857 <strncmp+0x17>
		n--, p++, q++;
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800857:	39 d8                	cmp    %ebx,%eax
  800859:	74 18                	je     800873 <strncmp+0x33>
  80085b:	0f b6 08             	movzbl (%eax),%ecx
  80085e:	84 c9                	test   %cl,%cl
  800860:	74 04                	je     800866 <strncmp+0x26>
  800862:	3a 0a                	cmp    (%edx),%cl
  800864:	74 eb                	je     800851 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800866:	0f b6 00             	movzbl (%eax),%eax
  800869:	0f b6 12             	movzbl (%edx),%edx
  80086c:	29 d0                	sub    %edx,%eax
}
  80086e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800871:	c9                   	leave  
  800872:	c3                   	ret    
		return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	eb f4                	jmp    80086e <strncmp+0x2e>

0080087a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	eb 03                	jmp    800889 <strchr+0xf>
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	0f b6 10             	movzbl (%eax),%edx
  80088c:	84 d2                	test   %dl,%dl
  80088e:	74 06                	je     800896 <strchr+0x1c>
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	75 f2                	jne    800886 <strchr+0xc>
  800894:	eb 05                	jmp    80089b <strchr+0x21>
			return (char *) s;
	return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 09                	je     8008b7 <strfind+0x1a>
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	74 05                	je     8008b7 <strfind+0x1a>
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	eb f0                	jmp    8008a7 <strfind+0xa>
			break;
	return (char *) s;
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 2f                	je     8008f8 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c9:	89 f8                	mov    %edi,%eax
  8008cb:	09 c8                	or     %ecx,%eax
  8008cd:	a8 03                	test   $0x3,%al
  8008cf:	75 21                	jne    8008f2 <memset+0x39>
		c &= 0xFF;
  8008d1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	89 d0                	mov    %edx,%eax
  8008d7:	c1 e0 08             	shl    $0x8,%eax
  8008da:	89 d3                	mov    %edx,%ebx
  8008dc:	c1 e3 18             	shl    $0x18,%ebx
  8008df:	89 d6                	mov    %edx,%esi
  8008e1:	c1 e6 10             	shl    $0x10,%esi
  8008e4:	09 f3                	or     %esi,%ebx
  8008e6:	09 da                	or     %ebx,%edx
  8008e8:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb 06                	jmp    8008f8 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	fc                   	cld    
  8008f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090d:	39 c6                	cmp    %eax,%esi
  80090f:	73 32                	jae    800943 <memmove+0x44>
  800911:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800914:	39 c2                	cmp    %eax,%edx
  800916:	76 2b                	jbe    800943 <memmove+0x44>
		s += n;
		d += n;
  800918:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	09 fe                	or     %edi,%esi
  80091f:	09 ce                	or     %ecx,%esi
  800921:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800927:	75 0e                	jne    800937 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800929:	83 ef 04             	sub    $0x4,%edi
  80092c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800932:	fd                   	std    
  800933:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800935:	eb 09                	jmp    800940 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800937:	83 ef 01             	sub    $0x1,%edi
  80093a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80093d:	fd                   	std    
  80093e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800940:	fc                   	cld    
  800941:	eb 1a                	jmp    80095d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800943:	89 f2                	mov    %esi,%edx
  800945:	09 c2                	or     %eax,%edx
  800947:	09 ca                	or     %ecx,%edx
  800949:	f6 c2 03             	test   $0x3,%dl
  80094c:	75 0a                	jne    800958 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb 05                	jmp    80095d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800958:	89 c7                	mov    %eax,%edi
  80095a:	fc                   	cld    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800967:	ff 75 10             	push   0x10(%ebp)
  80096a:	ff 75 0c             	push   0xc(%ebp)
  80096d:	ff 75 08             	push   0x8(%ebp)
  800970:	e8 8a ff ff ff       	call   8008ff <memmove>
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800982:	89 c6                	mov    %eax,%esi
  800984:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800987:	eb 06                	jmp    80098f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80098f:	39 f0                	cmp    %esi,%eax
  800991:	74 14                	je     8009a7 <memcmp+0x30>
		if (*s1 != *s2)
  800993:	0f b6 08             	movzbl (%eax),%ecx
  800996:	0f b6 1a             	movzbl (%edx),%ebx
  800999:	38 d9                	cmp    %bl,%cl
  80099b:	74 ec                	je     800989 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  80099d:	0f b6 c1             	movzbl %cl,%eax
  8009a0:	0f b6 db             	movzbl %bl,%ebx
  8009a3:	29 d8                	sub    %ebx,%eax
  8009a5:	eb 05                	jmp    8009ac <memcmp+0x35>
	}

	return 0;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009be:	eb 03                	jmp    8009c3 <memfind+0x13>
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	39 d0                	cmp    %edx,%eax
  8009c5:	73 04                	jae    8009cb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	38 08                	cmp    %cl,(%eax)
  8009c9:	75 f5                	jne    8009c0 <memfind+0x10>
			break;
	return (void *) s;
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d9:	eb 03                	jmp    8009de <strtol+0x11>
		s++;
  8009db:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009de:	0f b6 02             	movzbl (%edx),%eax
  8009e1:	3c 20                	cmp    $0x20,%al
  8009e3:	74 f6                	je     8009db <strtol+0xe>
  8009e5:	3c 09                	cmp    $0x9,%al
  8009e7:	74 f2                	je     8009db <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009e9:	3c 2b                	cmp    $0x2b,%al
  8009eb:	74 2a                	je     800a17 <strtol+0x4a>
	int neg = 0;
  8009ed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f2:	3c 2d                	cmp    $0x2d,%al
  8009f4:	74 2b                	je     800a21 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fc:	75 0f                	jne    800a0d <strtol+0x40>
  8009fe:	80 3a 30             	cmpb   $0x30,(%edx)
  800a01:	74 28                	je     800a2b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a03:	85 db                	test   %ebx,%ebx
  800a05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0a:	0f 44 d8             	cmove  %eax,%ebx
  800a0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a15:	eb 46                	jmp    800a5d <strtol+0x90>
		s++;
  800a17:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1f:	eb d5                	jmp    8009f6 <strtol+0x29>
		s++, neg = 1;
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi
  800a29:	eb cb                	jmp    8009f6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a2f:	74 0e                	je     800a3f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a31:	85 db                	test   %ebx,%ebx
  800a33:	75 d8                	jne    800a0d <strtol+0x40>
		s++, base = 8;
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a3d:	eb ce                	jmp    800a0d <strtol+0x40>
		s += 2, base = 16;
  800a3f:	83 c2 02             	add    $0x2,%edx
  800a42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a47:	eb c4                	jmp    800a0d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a49:	0f be c0             	movsbl %al,%eax
  800a4c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a4f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a52:	7d 3a                	jge    800a8e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a54:	83 c2 01             	add    $0x1,%edx
  800a57:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a5b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a5d:	0f b6 02             	movzbl (%edx),%eax
  800a60:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a63:	89 f3                	mov    %esi,%ebx
  800a65:	80 fb 09             	cmp    $0x9,%bl
  800a68:	76 df                	jbe    800a49 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a6a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 08                	ja     800a7c <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a74:	0f be c0             	movsbl %al,%eax
  800a77:	83 e8 57             	sub    $0x57,%eax
  800a7a:	eb d3                	jmp    800a4f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 08                	ja     800a8e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a86:	0f be c0             	movsbl %al,%eax
  800a89:	83 e8 37             	sub    $0x37,%eax
  800a8c:	eb c1                	jmp    800a4f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a92:	74 05                	je     800a99 <strtol+0xcc>
		*endptr = (char *) s;
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a99:	89 c8                	mov    %ecx,%eax
  800a9b:	f7 d8                	neg    %eax
  800a9d:	85 ff                	test   %edi,%edi
  800a9f:	0f 45 c8             	cmovne %eax,%ecx
}
  800aa2:	89 c8                	mov    %ecx,%eax
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aba:	89 c3                	mov    %eax,%ebx
  800abc:	89 c7                	mov    %eax,%edi
  800abe:	89 c6                	mov    %eax,%esi
  800ac0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	b8 03 00 00 00       	mov    $0x3,%eax
  800afc:	89 cb                	mov    %ecx,%ebx
  800afe:	89 cf                	mov    %ecx,%edi
  800b00:	89 ce                	mov    %ecx,%esi
  800b02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b04:	85 c0                	test   %eax,%eax
  800b06:	7f 08                	jg     800b10 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	50                   	push   %eax
  800b14:	6a 03                	push   $0x3
  800b16:	68 ff 25 80 00       	push   $0x8025ff
  800b1b:	6a 2a                	push   $0x2a
  800b1d:	68 1c 26 80 00       	push   $0x80261c
  800b22:	e8 9e 13 00 00       	call   801ec5 <_panic>

00800b27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 02 00 00 00       	mov    $0x2,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_yield>:

void
sys_yield(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6e:	be 00 00 00 00       	mov    $0x0,%esi
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b81:	89 f7                	mov    %esi,%edi
  800b83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7f 08                	jg     800b91 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	50                   	push   %eax
  800b95:	6a 04                	push   $0x4
  800b97:	68 ff 25 80 00       	push   $0x8025ff
  800b9c:	6a 2a                	push   $0x2a
  800b9e:	68 1c 26 80 00       	push   $0x80261c
  800ba3:	e8 1d 13 00 00       	call   801ec5 <_panic>

00800ba8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc2:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7f 08                	jg     800bd3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 05                	push   $0x5
  800bd9:	68 ff 25 80 00       	push   $0x8025ff
  800bde:	6a 2a                	push   $0x2a
  800be0:	68 1c 26 80 00       	push   $0x80261c
  800be5:	e8 db 12 00 00       	call   801ec5 <_panic>

00800bea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	89 de                	mov    %ebx,%esi
  800c07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7f 08                	jg     800c15 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 06                	push   $0x6
  800c1b:	68 ff 25 80 00       	push   $0x8025ff
  800c20:	6a 2a                	push   $0x2a
  800c22:	68 1c 26 80 00       	push   $0x80261c
  800c27:	e8 99 12 00 00       	call   801ec5 <_panic>

00800c2c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	b8 08 00 00 00       	mov    $0x8,%eax
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 08                	push   $0x8
  800c5d:	68 ff 25 80 00       	push   $0x8025ff
  800c62:	6a 2a                	push   $0x2a
  800c64:	68 1c 26 80 00       	push   $0x80261c
  800c69:	e8 57 12 00 00       	call   801ec5 <_panic>

00800c6e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	b8 09 00 00 00       	mov    $0x9,%eax
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7f 08                	jg     800c99 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 09                	push   $0x9
  800c9f:	68 ff 25 80 00       	push   $0x8025ff
  800ca4:	6a 2a                	push   $0x2a
  800ca6:	68 1c 26 80 00       	push   $0x80261c
  800cab:	e8 15 12 00 00       	call   801ec5 <_panic>

00800cb0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc9:	89 df                	mov    %ebx,%edi
  800ccb:	89 de                	mov    %ebx,%esi
  800ccd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7f 08                	jg     800cdb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 0a                	push   $0xa
  800ce1:	68 ff 25 80 00       	push   $0x8025ff
  800ce6:	6a 2a                	push   $0x2a
  800ce8:	68 1c 26 80 00       	push   $0x80261c
  800ced:	e8 d3 11 00 00       	call   801ec5 <_panic>

00800cf2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d03:	be 00 00 00 00       	mov    $0x0,%esi
  800d08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2b:	89 cb                	mov    %ecx,%ebx
  800d2d:	89 cf                	mov    %ecx,%edi
  800d2f:	89 ce                	mov    %ecx,%esi
  800d31:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7f 08                	jg     800d3f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 0d                	push   $0xd
  800d45:	68 ff 25 80 00       	push   $0x8025ff
  800d4a:	6a 2a                	push   $0x2a
  800d4c:	68 1c 26 80 00       	push   $0x80261c
  800d51:	e8 6f 11 00 00       	call   801ec5 <_panic>

00800d56 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d61:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d66:	89 d1                	mov    %edx,%ecx
  800d68:	89 d3                	mov    %edx,%ebx
  800d6a:	89 d7                	mov    %edx,%edi
  800d6c:	89 d6                	mov    %edx,%esi
  800d6e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d8b:	89 df                	mov    %ebx,%edi
  800d8d:	89 de                	mov    %ebx,%esi
  800d8f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	b8 10 00 00 00       	mov    $0x10,%eax
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc2:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dd7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 16             	shr    $0x16,%edx
  800deb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	74 29                	je     800e20 <fd_alloc+0x42>
  800df7:	89 c2                	mov    %eax,%edx
  800df9:	c1 ea 0c             	shr    $0xc,%edx
  800dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e03:	f6 c2 01             	test   $0x1,%dl
  800e06:	74 18                	je     800e20 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e08:	05 00 10 00 00       	add    $0x1000,%eax
  800e0d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e12:	75 d2                	jne    800de6 <fd_alloc+0x8>
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e19:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e1e:	eb 05                	jmp    800e25 <fd_alloc+0x47>
			return 0;
  800e20:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 02                	mov    %eax,(%edx)
}
  800e2a:	89 c8                	mov    %ecx,%eax
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e34:	83 f8 1f             	cmp    $0x1f,%eax
  800e37:	77 30                	ja     800e69 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e39:	c1 e0 0c             	shl    $0xc,%eax
  800e3c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e41:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e47:	f6 c2 01             	test   $0x1,%dl
  800e4a:	74 24                	je     800e70 <fd_lookup+0x42>
  800e4c:	89 c2                	mov    %eax,%edx
  800e4e:	c1 ea 0c             	shr    $0xc,%edx
  800e51:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e58:	f6 c2 01             	test   $0x1,%dl
  800e5b:	74 1a                	je     800e77 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e60:	89 02                	mov    %eax,(%edx)
	return 0;
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
		return -E_INVAL;
  800e69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6e:	eb f7                	jmp    800e67 <fd_lookup+0x39>
		return -E_INVAL;
  800e70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e75:	eb f0                	jmp    800e67 <fd_lookup+0x39>
  800e77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7c:	eb e9                	jmp    800e67 <fd_lookup+0x39>

00800e7e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	53                   	push   %ebx
  800e82:	83 ec 04             	sub    $0x4,%esp
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e92:	39 13                	cmp    %edx,(%ebx)
  800e94:	74 37                	je     800ecd <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e96:	83 c0 01             	add    $0x1,%eax
  800e99:	8b 1c 85 a8 26 80 00 	mov    0x8026a8(,%eax,4),%ebx
  800ea0:	85 db                	test   %ebx,%ebx
  800ea2:	75 ee                	jne    800e92 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea4:	a1 00 40 80 00       	mov    0x804000,%eax
  800ea9:	8b 40 48             	mov    0x48(%eax),%eax
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	52                   	push   %edx
  800eb0:	50                   	push   %eax
  800eb1:	68 2c 26 80 00       	push   $0x80262c
  800eb6:	e8 d4 f2 ff ff       	call   80018f <cprintf>
	*dev = 0;
	return -E_INVAL;
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800ec3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec6:	89 1a                	mov    %ebx,(%edx)
}
  800ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    
			return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	eb ef                	jmp    800ec3 <dev_lookup+0x45>

00800ed4 <fd_close>:
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 24             	sub    $0x24,%esp
  800edd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eed:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef0:	50                   	push   %eax
  800ef1:	e8 38 ff ff ff       	call   800e2e <fd_lookup>
  800ef6:	89 c3                	mov    %eax,%ebx
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 05                	js     800f04 <fd_close+0x30>
	    || fd != fd2)
  800eff:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f02:	74 16                	je     800f1a <fd_close+0x46>
		return (must_exist ? r : 0);
  800f04:	89 f8                	mov    %edi,%eax
  800f06:	84 c0                	test   %al,%al
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0d:	0f 44 d8             	cmove  %eax,%ebx
}
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f1a:	83 ec 08             	sub    $0x8,%esp
  800f1d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	ff 36                	push   (%esi)
  800f23:	e8 56 ff ff ff       	call   800e7e <dev_lookup>
  800f28:	89 c3                	mov    %eax,%ebx
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 1a                	js     800f4b <fd_close+0x77>
		if (dev->dev_close)
  800f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f34:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	74 0b                	je     800f4b <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	56                   	push   %esi
  800f44:	ff d0                	call   *%eax
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f4b:	83 ec 08             	sub    $0x8,%esp
  800f4e:	56                   	push   %esi
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 94 fc ff ff       	call   800bea <sys_page_unmap>
	return r;
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	eb b5                	jmp    800f10 <fd_close+0x3c>

00800f5b <close>:

int
close(int fdnum)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f64:	50                   	push   %eax
  800f65:	ff 75 08             	push   0x8(%ebp)
  800f68:	e8 c1 fe ff ff       	call   800e2e <fd_lookup>
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	79 02                	jns    800f76 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    
		return fd_close(fd, 1);
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	6a 01                	push   $0x1
  800f7b:	ff 75 f4             	push   -0xc(%ebp)
  800f7e:	e8 51 ff ff ff       	call   800ed4 <fd_close>
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	eb ec                	jmp    800f74 <close+0x19>

00800f88 <close_all>:

void
close_all(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	53                   	push   %ebx
  800f8c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	53                   	push   %ebx
  800f98:	e8 be ff ff ff       	call   800f5b <close>
	for (i = 0; i < MAXFD; i++)
  800f9d:	83 c3 01             	add    $0x1,%ebx
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	83 fb 20             	cmp    $0x20,%ebx
  800fa6:	75 ec                	jne    800f94 <close_all+0xc>
}
  800fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	ff 75 08             	push   0x8(%ebp)
  800fbd:	e8 6c fe ff ff       	call   800e2e <fd_lookup>
  800fc2:	89 c3                	mov    %eax,%ebx
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 7f                	js     80104a <dup+0x9d>
		return r;
	close(newfdnum);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	ff 75 0c             	push   0xc(%ebp)
  800fd1:	e8 85 ff ff ff       	call   800f5b <close>

	newfd = INDEX2FD(newfdnum);
  800fd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fd9:	c1 e6 0c             	shl    $0xc,%esi
  800fdc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fe2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fe5:	89 3c 24             	mov    %edi,(%esp)
  800fe8:	e8 da fd ff ff       	call   800dc7 <fd2data>
  800fed:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fef:	89 34 24             	mov    %esi,(%esp)
  800ff2:	e8 d0 fd ff ff       	call   800dc7 <fd2data>
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	c1 e8 16             	shr    $0x16,%eax
  801002:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801009:	a8 01                	test   $0x1,%al
  80100b:	74 11                	je     80101e <dup+0x71>
  80100d:	89 d8                	mov    %ebx,%eax
  80100f:	c1 e8 0c             	shr    $0xc,%eax
  801012:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801019:	f6 c2 01             	test   $0x1,%dl
  80101c:	75 36                	jne    801054 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101e:	89 f8                	mov    %edi,%eax
  801020:	c1 e8 0c             	shr    $0xc,%eax
  801023:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	25 07 0e 00 00       	and    $0xe07,%eax
  801032:	50                   	push   %eax
  801033:	56                   	push   %esi
  801034:	6a 00                	push   $0x0
  801036:	57                   	push   %edi
  801037:	6a 00                	push   $0x0
  801039:	e8 6a fb ff ff       	call   800ba8 <sys_page_map>
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	83 c4 20             	add    $0x20,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	78 33                	js     80107a <dup+0xcd>
		goto err;

	return newfdnum;
  801047:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80104a:	89 d8                	mov    %ebx,%eax
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801054:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	25 07 0e 00 00       	and    $0xe07,%eax
  801063:	50                   	push   %eax
  801064:	ff 75 d4             	push   -0x2c(%ebp)
  801067:	6a 00                	push   $0x0
  801069:	53                   	push   %ebx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 37 fb ff ff       	call   800ba8 <sys_page_map>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	79 a4                	jns    80101e <dup+0x71>
	sys_page_unmap(0, newfd);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	56                   	push   %esi
  80107e:	6a 00                	push   $0x0
  801080:	e8 65 fb ff ff       	call   800bea <sys_page_unmap>
	sys_page_unmap(0, nva);
  801085:	83 c4 08             	add    $0x8,%esp
  801088:	ff 75 d4             	push   -0x2c(%ebp)
  80108b:	6a 00                	push   $0x0
  80108d:	e8 58 fb ff ff       	call   800bea <sys_page_unmap>
	return r;
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	eb b3                	jmp    80104a <dup+0x9d>

00801097 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	83 ec 18             	sub    $0x18,%esp
  80109f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a5:	50                   	push   %eax
  8010a6:	56                   	push   %esi
  8010a7:	e8 82 fd ff ff       	call   800e2e <fd_lookup>
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 3c                	js     8010ef <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010bc:	50                   	push   %eax
  8010bd:	ff 33                	push   (%ebx)
  8010bf:	e8 ba fd ff ff       	call   800e7e <dev_lookup>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 24                	js     8010ef <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010cb:	8b 43 08             	mov    0x8(%ebx),%eax
  8010ce:	83 e0 03             	and    $0x3,%eax
  8010d1:	83 f8 01             	cmp    $0x1,%eax
  8010d4:	74 20                	je     8010f6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d9:	8b 40 08             	mov    0x8(%eax),%eax
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	74 37                	je     801117 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	ff 75 10             	push   0x10(%ebp)
  8010e6:	ff 75 0c             	push   0xc(%ebp)
  8010e9:	53                   	push   %ebx
  8010ea:	ff d0                	call   *%eax
  8010ec:	83 c4 10             	add    $0x10,%esp
}
  8010ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8010fb:	8b 40 48             	mov    0x48(%eax),%eax
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	56                   	push   %esi
  801102:	50                   	push   %eax
  801103:	68 6d 26 80 00       	push   $0x80266d
  801108:	e8 82 f0 ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801115:	eb d8                	jmp    8010ef <read+0x58>
		return -E_NOT_SUPP;
  801117:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80111c:	eb d1                	jmp    8010ef <read+0x58>

0080111e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801132:	eb 02                	jmp    801136 <readn+0x18>
  801134:	01 c3                	add    %eax,%ebx
  801136:	39 f3                	cmp    %esi,%ebx
  801138:	73 21                	jae    80115b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	89 f0                	mov    %esi,%eax
  80113f:	29 d8                	sub    %ebx,%eax
  801141:	50                   	push   %eax
  801142:	89 d8                	mov    %ebx,%eax
  801144:	03 45 0c             	add    0xc(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	57                   	push   %edi
  801149:	e8 49 ff ff ff       	call   801097 <read>
		if (m < 0)
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 04                	js     801159 <readn+0x3b>
			return m;
		if (m == 0)
  801155:	75 dd                	jne    801134 <readn+0x16>
  801157:	eb 02                	jmp    80115b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801159:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 18             	sub    $0x18,%esp
  80116d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801170:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801173:	50                   	push   %eax
  801174:	53                   	push   %ebx
  801175:	e8 b4 fc ff ff       	call   800e2e <fd_lookup>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 37                	js     8011b8 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801181:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	ff 36                	push   (%esi)
  80118d:	e8 ec fc ff ff       	call   800e7e <dev_lookup>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 1f                	js     8011b8 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801199:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80119d:	74 20                	je     8011bf <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80119f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	74 37                	je     8011e0 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	ff 75 10             	push   0x10(%ebp)
  8011af:	ff 75 0c             	push   0xc(%ebp)
  8011b2:	56                   	push   %esi
  8011b3:	ff d0                	call   *%eax
  8011b5:	83 c4 10             	add    $0x10,%esp
}
  8011b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bf:	a1 00 40 80 00       	mov    0x804000,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	53                   	push   %ebx
  8011cb:	50                   	push   %eax
  8011cc:	68 89 26 80 00       	push   $0x802689
  8011d1:	e8 b9 ef ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011de:	eb d8                	jmp    8011b8 <write+0x53>
		return -E_NOT_SUPP;
  8011e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011e5:	eb d1                	jmp    8011b8 <write+0x53>

008011e7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	ff 75 08             	push   0x8(%ebp)
  8011f4:	e8 35 fc ff ff       	call   800e2e <fd_lookup>
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 0e                	js     80120e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801200:	8b 55 0c             	mov    0xc(%ebp),%edx
  801203:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801206:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801209:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 18             	sub    $0x18,%esp
  801218:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	53                   	push   %ebx
  801220:	e8 09 fc ff ff       	call   800e2e <fd_lookup>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 34                	js     801260 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	ff 36                	push   (%esi)
  801238:	e8 41 fc ff ff       	call   800e7e <dev_lookup>
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	78 1c                	js     801260 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801244:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801248:	74 1d                	je     801267 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124d:	8b 40 18             	mov    0x18(%eax),%eax
  801250:	85 c0                	test   %eax,%eax
  801252:	74 34                	je     801288 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	ff 75 0c             	push   0xc(%ebp)
  80125a:	56                   	push   %esi
  80125b:	ff d0                	call   *%eax
  80125d:	83 c4 10             	add    $0x10,%esp
}
  801260:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    
			thisenv->env_id, fdnum);
  801267:	a1 00 40 80 00       	mov    0x804000,%eax
  80126c:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	53                   	push   %ebx
  801273:	50                   	push   %eax
  801274:	68 4c 26 80 00       	push   $0x80264c
  801279:	e8 11 ef ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801286:	eb d8                	jmp    801260 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801288:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80128d:	eb d1                	jmp    801260 <ftruncate+0x50>

0080128f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 18             	sub    $0x18,%esp
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	ff 75 08             	push   0x8(%ebp)
  8012a1:	e8 88 fb ff ff       	call   800e2e <fd_lookup>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 49                	js     8012f6 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b6:	50                   	push   %eax
  8012b7:	ff 36                	push   (%esi)
  8012b9:	e8 c0 fb ff ff       	call   800e7e <dev_lookup>
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 31                	js     8012f6 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8012c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012cc:	74 2f                	je     8012fd <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012d8:	00 00 00 
	stat->st_isdir = 0;
  8012db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012e2:	00 00 00 
	stat->st_dev = dev;
  8012e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	56                   	push   %esi
  8012f0:	ff 50 14             	call   *0x14(%eax)
  8012f3:	83 c4 10             	add    $0x10,%esp
}
  8012f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    
		return -E_NOT_SUPP;
  8012fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801302:	eb f2                	jmp    8012f6 <fstat+0x67>

00801304 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	6a 00                	push   $0x0
  80130e:	ff 75 08             	push   0x8(%ebp)
  801311:	e8 e4 01 00 00       	call   8014fa <open>
  801316:	89 c3                	mov    %eax,%ebx
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 1b                	js     80133a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	ff 75 0c             	push   0xc(%ebp)
  801325:	50                   	push   %eax
  801326:	e8 64 ff ff ff       	call   80128f <fstat>
  80132b:	89 c6                	mov    %eax,%esi
	close(fd);
  80132d:	89 1c 24             	mov    %ebx,(%esp)
  801330:	e8 26 fc ff ff       	call   800f5b <close>
	return r;
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	89 f3                	mov    %esi,%ebx
}
  80133a:	89 d8                	mov    %ebx,%eax
  80133c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	89 c6                	mov    %eax,%esi
  80134a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80134c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801353:	74 27                	je     80137c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801355:	6a 07                	push   $0x7
  801357:	68 00 50 80 00       	push   $0x805000
  80135c:	56                   	push   %esi
  80135d:	ff 35 00 60 80 00    	push   0x806000
  801363:	e8 0a 0c 00 00       	call   801f72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801368:	83 c4 0c             	add    $0xc,%esp
  80136b:	6a 00                	push   $0x0
  80136d:	53                   	push   %ebx
  80136e:	6a 00                	push   $0x0
  801370:	e8 96 0b 00 00       	call   801f0b <ipc_recv>
}
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	6a 01                	push   $0x1
  801381:	e8 40 0c 00 00       	call   801fc6 <ipc_find_env>
  801386:	a3 00 60 80 00       	mov    %eax,0x806000
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	eb c5                	jmp    801355 <fsipc+0x12>

00801390 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 40 0c             	mov    0xc(%eax),%eax
  80139c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b3:	e8 8b ff ff ff       	call   801343 <fsipc>
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <devfile_flush>:
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d5:	e8 69 ff ff ff       	call   801343 <fsipc>
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_stat>:
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ec:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fb:	e8 43 ff ff ff       	call   801343 <fsipc>
  801400:	85 c0                	test   %eax,%eax
  801402:	78 2c                	js     801430 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	68 00 50 80 00       	push   $0x805000
  80140c:	53                   	push   %ebx
  80140d:	e8 57 f3 ff ff       	call   800769 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801412:	a1 80 50 80 00       	mov    0x805080,%eax
  801417:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80141d:	a1 84 50 80 00       	mov    0x805084,%eax
  801422:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_write>:
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	8b 45 10             	mov    0x10(%ebp),%eax
  80143e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801443:	39 d0                	cmp    %edx,%eax
  801445:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801448:	8b 55 08             	mov    0x8(%ebp),%edx
  80144b:	8b 52 0c             	mov    0xc(%edx),%edx
  80144e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801454:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801459:	50                   	push   %eax
  80145a:	ff 75 0c             	push   0xc(%ebp)
  80145d:	68 08 50 80 00       	push   $0x805008
  801462:	e8 98 f4 ff ff       	call   8008ff <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801467:	ba 00 00 00 00       	mov    $0x0,%edx
  80146c:	b8 04 00 00 00       	mov    $0x4,%eax
  801471:	e8 cd fe ff ff       	call   801343 <fsipc>
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <devfile_read>:
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	56                   	push   %esi
  80147c:	53                   	push   %ebx
  80147d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80148b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
  801496:	b8 03 00 00 00       	mov    $0x3,%eax
  80149b:	e8 a3 fe ff ff       	call   801343 <fsipc>
  8014a0:	89 c3                	mov    %eax,%ebx
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 1f                	js     8014c5 <devfile_read+0x4d>
	assert(r <= n);
  8014a6:	39 f0                	cmp    %esi,%eax
  8014a8:	77 24                	ja     8014ce <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014af:	7f 33                	jg     8014e4 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014b1:	83 ec 04             	sub    $0x4,%esp
  8014b4:	50                   	push   %eax
  8014b5:	68 00 50 80 00       	push   $0x805000
  8014ba:	ff 75 0c             	push   0xc(%ebp)
  8014bd:	e8 3d f4 ff ff       	call   8008ff <memmove>
	return r;
  8014c2:	83 c4 10             	add    $0x10,%esp
}
  8014c5:	89 d8                	mov    %ebx,%eax
  8014c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5e                   	pop    %esi
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    
	assert(r <= n);
  8014ce:	68 bc 26 80 00       	push   $0x8026bc
  8014d3:	68 c3 26 80 00       	push   $0x8026c3
  8014d8:	6a 7c                	push   $0x7c
  8014da:	68 d8 26 80 00       	push   $0x8026d8
  8014df:	e8 e1 09 00 00       	call   801ec5 <_panic>
	assert(r <= PGSIZE);
  8014e4:	68 e3 26 80 00       	push   $0x8026e3
  8014e9:	68 c3 26 80 00       	push   $0x8026c3
  8014ee:	6a 7d                	push   $0x7d
  8014f0:	68 d8 26 80 00       	push   $0x8026d8
  8014f5:	e8 cb 09 00 00       	call   801ec5 <_panic>

008014fa <open>:
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 1c             	sub    $0x1c,%esp
  801502:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801505:	56                   	push   %esi
  801506:	e8 23 f2 ff ff       	call   80072e <strlen>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801513:	7f 6c                	jg     801581 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801515:	83 ec 0c             	sub    $0xc,%esp
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	e8 bd f8 ff ff       	call   800dde <fd_alloc>
  801521:	89 c3                	mov    %eax,%ebx
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 3c                	js     801566 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	56                   	push   %esi
  80152e:	68 00 50 80 00       	push   $0x805000
  801533:	e8 31 f2 ff ff       	call   800769 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801540:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801543:	b8 01 00 00 00       	mov    $0x1,%eax
  801548:	e8 f6 fd ff ff       	call   801343 <fsipc>
  80154d:	89 c3                	mov    %eax,%ebx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 19                	js     80156f <open+0x75>
	return fd2num(fd);
  801556:	83 ec 0c             	sub    $0xc,%esp
  801559:	ff 75 f4             	push   -0xc(%ebp)
  80155c:	e8 56 f8 ff ff       	call   800db7 <fd2num>
  801561:	89 c3                	mov    %eax,%ebx
  801563:	83 c4 10             	add    $0x10,%esp
}
  801566:	89 d8                	mov    %ebx,%eax
  801568:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156b:	5b                   	pop    %ebx
  80156c:	5e                   	pop    %esi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    
		fd_close(fd, 0);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	6a 00                	push   $0x0
  801574:	ff 75 f4             	push   -0xc(%ebp)
  801577:	e8 58 f9 ff ff       	call   800ed4 <fd_close>
		return r;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	eb e5                	jmp    801566 <open+0x6c>
		return -E_BAD_PATH;
  801581:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801586:	eb de                	jmp    801566 <open+0x6c>

00801588 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	b8 08 00 00 00       	mov    $0x8,%eax
  801598:	e8 a6 fd ff ff       	call   801343 <fsipc>
}
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015a5:	68 ef 26 80 00       	push   $0x8026ef
  8015aa:	ff 75 0c             	push   0xc(%ebp)
  8015ad:	e8 b7 f1 ff ff       	call   800769 <strcpy>
	return 0;
}
  8015b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <devsock_close>:
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 10             	sub    $0x10,%esp
  8015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015c3:	53                   	push   %ebx
  8015c4:	e8 36 0a 00 00       	call   801fff <pageref>
  8015c9:	89 c2                	mov    %eax,%edx
  8015cb:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8015d3:	83 fa 01             	cmp    $0x1,%edx
  8015d6:	74 05                	je     8015dd <devsock_close+0x24>
}
  8015d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	ff 73 0c             	push   0xc(%ebx)
  8015e3:	e8 b7 02 00 00       	call   80189f <nsipc_close>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb eb                	jmp    8015d8 <devsock_close+0x1f>

008015ed <devsock_write>:
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015f3:	6a 00                	push   $0x0
  8015f5:	ff 75 10             	push   0x10(%ebp)
  8015f8:	ff 75 0c             	push   0xc(%ebp)
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	ff 70 0c             	push   0xc(%eax)
  801601:	e8 79 03 00 00       	call   80197f <nsipc_send>
}
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <devsock_read>:
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80160e:	6a 00                	push   $0x0
  801610:	ff 75 10             	push   0x10(%ebp)
  801613:	ff 75 0c             	push   0xc(%ebp)
  801616:	8b 45 08             	mov    0x8(%ebp),%eax
  801619:	ff 70 0c             	push   0xc(%eax)
  80161c:	e8 ef 02 00 00       	call   801910 <nsipc_recv>
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <fd2sockid>:
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801629:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80162c:	52                   	push   %edx
  80162d:	50                   	push   %eax
  80162e:	e8 fb f7 ff ff       	call   800e2e <fd_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 10                	js     80164a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80163a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801643:	39 08                	cmp    %ecx,(%eax)
  801645:	75 05                	jne    80164c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801647:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    
		return -E_NOT_SUPP;
  80164c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801651:	eb f7                	jmp    80164a <fd2sockid+0x27>

00801653 <alloc_sockfd>:
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	83 ec 1c             	sub    $0x1c,%esp
  80165b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	e8 78 f7 ff ff       	call   800dde <fd_alloc>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 43                	js     8016b2 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	68 07 04 00 00       	push   $0x407
  801677:	ff 75 f4             	push   -0xc(%ebp)
  80167a:	6a 00                	push   $0x0
  80167c:	e8 e4 f4 ff ff       	call   800b65 <sys_page_alloc>
  801681:	89 c3                	mov    %eax,%ebx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 28                	js     8016b2 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801693:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801698:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80169f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	50                   	push   %eax
  8016a6:	e8 0c f7 ff ff       	call   800db7 <fd2num>
  8016ab:	89 c3                	mov    %eax,%ebx
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	eb 0c                	jmp    8016be <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8016b2:	83 ec 0c             	sub    $0xc,%esp
  8016b5:	56                   	push   %esi
  8016b6:	e8 e4 01 00 00       	call   80189f <nsipc_close>
		return r;
  8016bb:	83 c4 10             	add    $0x10,%esp
}
  8016be:	89 d8                	mov    %ebx,%eax
  8016c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <accept>:
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	e8 4e ff ff ff       	call   801623 <fd2sockid>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 1b                	js     8016f4 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	ff 75 10             	push   0x10(%ebp)
  8016df:	ff 75 0c             	push   0xc(%ebp)
  8016e2:	50                   	push   %eax
  8016e3:	e8 0e 01 00 00       	call   8017f6 <nsipc_accept>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 05                	js     8016f4 <accept+0x2d>
	return alloc_sockfd(r);
  8016ef:	e8 5f ff ff ff       	call   801653 <alloc_sockfd>
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <bind>:
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	e8 1f ff ff ff       	call   801623 <fd2sockid>
  801704:	85 c0                	test   %eax,%eax
  801706:	78 12                	js     80171a <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	ff 75 10             	push   0x10(%ebp)
  80170e:	ff 75 0c             	push   0xc(%ebp)
  801711:	50                   	push   %eax
  801712:	e8 31 01 00 00       	call   801848 <nsipc_bind>
  801717:	83 c4 10             	add    $0x10,%esp
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <shutdown>:
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	e8 f9 fe ff ff       	call   801623 <fd2sockid>
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 0f                	js     80173d <shutdown+0x21>
	return nsipc_shutdown(r, how);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	ff 75 0c             	push   0xc(%ebp)
  801734:	50                   	push   %eax
  801735:	e8 43 01 00 00       	call   80187d <nsipc_shutdown>
  80173a:	83 c4 10             	add    $0x10,%esp
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <connect>:
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	e8 d6 fe ff ff       	call   801623 <fd2sockid>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 12                	js     801763 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801751:	83 ec 04             	sub    $0x4,%esp
  801754:	ff 75 10             	push   0x10(%ebp)
  801757:	ff 75 0c             	push   0xc(%ebp)
  80175a:	50                   	push   %eax
  80175b:	e8 59 01 00 00       	call   8018b9 <nsipc_connect>
  801760:	83 c4 10             	add    $0x10,%esp
}
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <listen>:
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	e8 b0 fe ff ff       	call   801623 <fd2sockid>
  801773:	85 c0                	test   %eax,%eax
  801775:	78 0f                	js     801786 <listen+0x21>
	return nsipc_listen(r, backlog);
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	ff 75 0c             	push   0xc(%ebp)
  80177d:	50                   	push   %eax
  80177e:	e8 6b 01 00 00       	call   8018ee <nsipc_listen>
  801783:	83 c4 10             	add    $0x10,%esp
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <socket>:

int
socket(int domain, int type, int protocol)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80178e:	ff 75 10             	push   0x10(%ebp)
  801791:	ff 75 0c             	push   0xc(%ebp)
  801794:	ff 75 08             	push   0x8(%ebp)
  801797:	e8 41 02 00 00       	call   8019dd <nsipc_socket>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 05                	js     8017a8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017a3:	e8 ab fe ff ff       	call   801653 <alloc_sockfd>
}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017b3:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8017ba:	74 26                	je     8017e2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017bc:	6a 07                	push   $0x7
  8017be:	68 00 70 80 00       	push   $0x807000
  8017c3:	53                   	push   %ebx
  8017c4:	ff 35 00 80 80 00    	push   0x808000
  8017ca:	e8 a3 07 00 00       	call   801f72 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017cf:	83 c4 0c             	add    $0xc,%esp
  8017d2:	6a 00                	push   $0x0
  8017d4:	6a 00                	push   $0x0
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 2e 07 00 00       	call   801f0b <ipc_recv>
}
  8017dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	6a 02                	push   $0x2
  8017e7:	e8 da 07 00 00       	call   801fc6 <ipc_find_env>
  8017ec:	a3 00 80 80 00       	mov    %eax,0x808000
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	eb c6                	jmp    8017bc <nsipc+0x12>

008017f6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	56                   	push   %esi
  8017fa:	53                   	push   %ebx
  8017fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801806:	8b 06                	mov    (%esi),%eax
  801808:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80180d:	b8 01 00 00 00       	mov    $0x1,%eax
  801812:	e8 93 ff ff ff       	call   8017aa <nsipc>
  801817:	89 c3                	mov    %eax,%ebx
  801819:	85 c0                	test   %eax,%eax
  80181b:	79 09                	jns    801826 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80181d:	89 d8                	mov    %ebx,%eax
  80181f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	ff 35 10 70 80 00    	push   0x807010
  80182f:	68 00 70 80 00       	push   $0x807000
  801834:	ff 75 0c             	push   0xc(%ebp)
  801837:	e8 c3 f0 ff ff       	call   8008ff <memmove>
		*addrlen = ret->ret_addrlen;
  80183c:	a1 10 70 80 00       	mov    0x807010,%eax
  801841:	89 06                	mov    %eax,(%esi)
  801843:	83 c4 10             	add    $0x10,%esp
	return r;
  801846:	eb d5                	jmp    80181d <nsipc_accept+0x27>

00801848 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	53                   	push   %ebx
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80185a:	53                   	push   %ebx
  80185b:	ff 75 0c             	push   0xc(%ebp)
  80185e:	68 04 70 80 00       	push   $0x807004
  801863:	e8 97 f0 ff ff       	call   8008ff <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801868:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80186e:	b8 02 00 00 00       	mov    $0x2,%eax
  801873:	e8 32 ff ff ff       	call   8017aa <nsipc>
}
  801878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80188b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801893:	b8 03 00 00 00       	mov    $0x3,%eax
  801898:	e8 0d ff ff ff       	call   8017aa <nsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <nsipc_close>:

int
nsipc_close(int s)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8018ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b2:	e8 f3 fe ff ff       	call   8017aa <nsipc>
}
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	53                   	push   %ebx
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018cb:	53                   	push   %ebx
  8018cc:	ff 75 0c             	push   0xc(%ebp)
  8018cf:	68 04 70 80 00       	push   $0x807004
  8018d4:	e8 26 f0 ff ff       	call   8008ff <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018d9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018df:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e4:	e8 c1 fe ff ff       	call   8017aa <nsipc>
}
  8018e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801904:	b8 06 00 00 00       	mov    $0x6,%eax
  801909:	e8 9c fe ff ff       	call   8017aa <nsipc>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801920:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801926:	8b 45 14             	mov    0x14(%ebp),%eax
  801929:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80192e:	b8 07 00 00 00       	mov    $0x7,%eax
  801933:	e8 72 fe ff ff       	call   8017aa <nsipc>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 22                	js     801960 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  80193e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801943:	39 c6                	cmp    %eax,%esi
  801945:	0f 4e c6             	cmovle %esi,%eax
  801948:	39 c3                	cmp    %eax,%ebx
  80194a:	7f 1d                	jg     801969 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	53                   	push   %ebx
  801950:	68 00 70 80 00       	push   $0x807000
  801955:	ff 75 0c             	push   0xc(%ebp)
  801958:	e8 a2 ef ff ff       	call   8008ff <memmove>
  80195d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801960:	89 d8                	mov    %ebx,%eax
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801969:	68 fb 26 80 00       	push   $0x8026fb
  80196e:	68 c3 26 80 00       	push   $0x8026c3
  801973:	6a 62                	push   $0x62
  801975:	68 10 27 80 00       	push   $0x802710
  80197a:	e8 46 05 00 00       	call   801ec5 <_panic>

0080197f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	53                   	push   %ebx
  801983:	83 ec 04             	sub    $0x4,%esp
  801986:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801989:	8b 45 08             	mov    0x8(%ebp),%eax
  80198c:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801991:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801997:	7f 2e                	jg     8019c7 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	53                   	push   %ebx
  80199d:	ff 75 0c             	push   0xc(%ebp)
  8019a0:	68 0c 70 80 00       	push   $0x80700c
  8019a5:	e8 55 ef ff ff       	call   8008ff <memmove>
	nsipcbuf.send.req_size = size;
  8019aa:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8019b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8019b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019bd:	e8 e8 fd ff ff       	call   8017aa <nsipc>
}
  8019c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    
	assert(size < 1600);
  8019c7:	68 1c 27 80 00       	push   $0x80271c
  8019cc:	68 c3 26 80 00       	push   $0x8026c3
  8019d1:	6a 6d                	push   $0x6d
  8019d3:	68 10 27 80 00       	push   $0x802710
  8019d8:	e8 e8 04 00 00       	call   801ec5 <_panic>

008019dd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019fb:	b8 09 00 00 00       	mov    $0x9,%eax
  801a00:	e8 a5 fd ff ff       	call   8017aa <nsipc>
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	ff 75 08             	push   0x8(%ebp)
  801a15:	e8 ad f3 ff ff       	call   800dc7 <fd2data>
  801a1a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1c:	83 c4 08             	add    $0x8,%esp
  801a1f:	68 28 27 80 00       	push   $0x802728
  801a24:	53                   	push   %ebx
  801a25:	e8 3f ed ff ff       	call   800769 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2a:	8b 46 04             	mov    0x4(%esi),%eax
  801a2d:	2b 06                	sub    (%esi),%eax
  801a2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a35:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3c:	00 00 00 
	stat->st_dev = &devpipe;
  801a3f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a46:	30 80 00 
	return 0;
}
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a51:	5b                   	pop    %ebx
  801a52:	5e                   	pop    %esi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	53                   	push   %ebx
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a5f:	53                   	push   %ebx
  801a60:	6a 00                	push   $0x0
  801a62:	e8 83 f1 ff ff       	call   800bea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a67:	89 1c 24             	mov    %ebx,(%esp)
  801a6a:	e8 58 f3 ff ff       	call   800dc7 <fd2data>
  801a6f:	83 c4 08             	add    $0x8,%esp
  801a72:	50                   	push   %eax
  801a73:	6a 00                	push   $0x0
  801a75:	e8 70 f1 ff ff       	call   800bea <sys_page_unmap>
}
  801a7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <_pipeisclosed>:
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	57                   	push   %edi
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 1c             	sub    $0x1c,%esp
  801a88:	89 c7                	mov    %eax,%edi
  801a8a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a8c:	a1 00 40 80 00       	mov    0x804000,%eax
  801a91:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	57                   	push   %edi
  801a98:	e8 62 05 00 00       	call   801fff <pageref>
  801a9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aa0:	89 34 24             	mov    %esi,(%esp)
  801aa3:	e8 57 05 00 00       	call   801fff <pageref>
		nn = thisenv->env_runs;
  801aa8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801aae:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	39 cb                	cmp    %ecx,%ebx
  801ab6:	74 1b                	je     801ad3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ab8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801abb:	75 cf                	jne    801a8c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abd:	8b 42 58             	mov    0x58(%edx),%eax
  801ac0:	6a 01                	push   $0x1
  801ac2:	50                   	push   %eax
  801ac3:	53                   	push   %ebx
  801ac4:	68 2f 27 80 00       	push   $0x80272f
  801ac9:	e8 c1 e6 ff ff       	call   80018f <cprintf>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	eb b9                	jmp    801a8c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ad3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ad6:	0f 94 c0             	sete   %al
  801ad9:	0f b6 c0             	movzbl %al,%eax
}
  801adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <devpipe_write>:
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	57                   	push   %edi
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 28             	sub    $0x28,%esp
  801aed:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801af0:	56                   	push   %esi
  801af1:	e8 d1 f2 ff ff       	call   800dc7 <fd2data>
  801af6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	bf 00 00 00 00       	mov    $0x0,%edi
  801b00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b03:	75 09                	jne    801b0e <devpipe_write+0x2a>
	return i;
  801b05:	89 f8                	mov    %edi,%eax
  801b07:	eb 23                	jmp    801b2c <devpipe_write+0x48>
			sys_yield();
  801b09:	e8 38 f0 ff ff       	call   800b46 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b0e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b11:	8b 0b                	mov    (%ebx),%ecx
  801b13:	8d 51 20             	lea    0x20(%ecx),%edx
  801b16:	39 d0                	cmp    %edx,%eax
  801b18:	72 1a                	jb     801b34 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b1a:	89 da                	mov    %ebx,%edx
  801b1c:	89 f0                	mov    %esi,%eax
  801b1e:	e8 5c ff ff ff       	call   801a7f <_pipeisclosed>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	74 e2                	je     801b09 <devpipe_write+0x25>
				return 0;
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b37:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b3e:	89 c2                	mov    %eax,%edx
  801b40:	c1 fa 1f             	sar    $0x1f,%edx
  801b43:	89 d1                	mov    %edx,%ecx
  801b45:	c1 e9 1b             	shr    $0x1b,%ecx
  801b48:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4b:	83 e2 1f             	and    $0x1f,%edx
  801b4e:	29 ca                	sub    %ecx,%edx
  801b50:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b54:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b58:	83 c0 01             	add    $0x1,%eax
  801b5b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b5e:	83 c7 01             	add    $0x1,%edi
  801b61:	eb 9d                	jmp    801b00 <devpipe_write+0x1c>

00801b63 <devpipe_read>:
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	57                   	push   %edi
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	83 ec 18             	sub    $0x18,%esp
  801b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b6f:	57                   	push   %edi
  801b70:	e8 52 f2 ff ff       	call   800dc7 <fd2data>
  801b75:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	be 00 00 00 00       	mov    $0x0,%esi
  801b7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b82:	75 13                	jne    801b97 <devpipe_read+0x34>
	return i;
  801b84:	89 f0                	mov    %esi,%eax
  801b86:	eb 02                	jmp    801b8a <devpipe_read+0x27>
				return i;
  801b88:	89 f0                	mov    %esi,%eax
}
  801b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5f                   	pop    %edi
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    
			sys_yield();
  801b92:	e8 af ef ff ff       	call   800b46 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b97:	8b 03                	mov    (%ebx),%eax
  801b99:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b9c:	75 18                	jne    801bb6 <devpipe_read+0x53>
			if (i > 0)
  801b9e:	85 f6                	test   %esi,%esi
  801ba0:	75 e6                	jne    801b88 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ba2:	89 da                	mov    %ebx,%edx
  801ba4:	89 f8                	mov    %edi,%eax
  801ba6:	e8 d4 fe ff ff       	call   801a7f <_pipeisclosed>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	74 e3                	je     801b92 <devpipe_read+0x2f>
				return 0;
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb4:	eb d4                	jmp    801b8a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb6:	99                   	cltd   
  801bb7:	c1 ea 1b             	shr    $0x1b,%edx
  801bba:	01 d0                	add    %edx,%eax
  801bbc:	83 e0 1f             	and    $0x1f,%eax
  801bbf:	29 d0                	sub    %edx,%eax
  801bc1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bcc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bcf:	83 c6 01             	add    $0x1,%esi
  801bd2:	eb ab                	jmp    801b7f <devpipe_read+0x1c>

00801bd4 <pipe>:
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	e8 f9 f1 ff ff       	call   800dde <fd_alloc>
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	85 c0                	test   %eax,%eax
  801bec:	0f 88 23 01 00 00    	js     801d15 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf2:	83 ec 04             	sub    $0x4,%esp
  801bf5:	68 07 04 00 00       	push   $0x407
  801bfa:	ff 75 f4             	push   -0xc(%ebp)
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 61 ef ff ff       	call   800b65 <sys_page_alloc>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 04 01 00 00    	js     801d15 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	e8 c1 f1 ff ff       	call   800dde <fd_alloc>
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	0f 88 db 00 00 00    	js     801d05 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	68 07 04 00 00       	push   $0x407
  801c32:	ff 75 f0             	push   -0x10(%ebp)
  801c35:	6a 00                	push   $0x0
  801c37:	e8 29 ef ff ff       	call   800b65 <sys_page_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 bc 00 00 00    	js     801d05 <pipe+0x131>
	va = fd2data(fd0);
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	ff 75 f4             	push   -0xc(%ebp)
  801c4f:	e8 73 f1 ff ff       	call   800dc7 <fd2data>
  801c54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c56:	83 c4 0c             	add    $0xc,%esp
  801c59:	68 07 04 00 00       	push   $0x407
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 ff ee ff ff       	call   800b65 <sys_page_alloc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	0f 88 82 00 00 00    	js     801cf5 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff 75 f0             	push   -0x10(%ebp)
  801c79:	e8 49 f1 ff ff       	call   800dc7 <fd2data>
  801c7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c85:	50                   	push   %eax
  801c86:	6a 00                	push   $0x0
  801c88:	56                   	push   %esi
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 18 ef ff ff       	call   800ba8 <sys_page_map>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 20             	add    $0x20,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 4e                	js     801ce7 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c99:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca1:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ca3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca6:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cb0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f4             	push   -0xc(%ebp)
  801cc2:	e8 f0 f0 ff ff       	call   800db7 <fd2num>
  801cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ccc:	83 c4 04             	add    $0x4,%esp
  801ccf:	ff 75 f0             	push   -0x10(%ebp)
  801cd2:	e8 e0 f0 ff ff       	call   800db7 <fd2num>
  801cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cda:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce5:	eb 2e                	jmp    801d15 <pipe+0x141>
	sys_page_unmap(0, va);
  801ce7:	83 ec 08             	sub    $0x8,%esp
  801cea:	56                   	push   %esi
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 f8 ee ff ff       	call   800bea <sys_page_unmap>
  801cf2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cf5:	83 ec 08             	sub    $0x8,%esp
  801cf8:	ff 75 f0             	push   -0x10(%ebp)
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 e8 ee ff ff       	call   800bea <sys_page_unmap>
  801d02:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d05:	83 ec 08             	sub    $0x8,%esp
  801d08:	ff 75 f4             	push   -0xc(%ebp)
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 d8 ee ff ff       	call   800bea <sys_page_unmap>
  801d12:	83 c4 10             	add    $0x10,%esp
}
  801d15:	89 d8                	mov    %ebx,%eax
  801d17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1a:	5b                   	pop    %ebx
  801d1b:	5e                   	pop    %esi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <pipeisclosed>:
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d27:	50                   	push   %eax
  801d28:	ff 75 08             	push   0x8(%ebp)
  801d2b:	e8 fe f0 ff ff       	call   800e2e <fd_lookup>
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 18                	js     801d4f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 f4             	push   -0xc(%ebp)
  801d3d:	e8 85 f0 ff ff       	call   800dc7 <fd2data>
  801d42:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	e8 33 fd ff ff       	call   801a7f <_pipeisclosed>
  801d4c:	83 c4 10             	add    $0x10,%esp
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	c3                   	ret    

00801d57 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d5d:	68 47 27 80 00       	push   $0x802747
  801d62:	ff 75 0c             	push   0xc(%ebp)
  801d65:	e8 ff e9 ff ff       	call   800769 <strcpy>
	return 0;
}
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <devcons_write>:
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	57                   	push   %edi
  801d75:	56                   	push   %esi
  801d76:	53                   	push   %ebx
  801d77:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d7d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d82:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d88:	eb 2e                	jmp    801db8 <devcons_write+0x47>
		m = n - tot;
  801d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d8d:	29 f3                	sub    %esi,%ebx
  801d8f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d94:	39 c3                	cmp    %eax,%ebx
  801d96:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d99:	83 ec 04             	sub    $0x4,%esp
  801d9c:	53                   	push   %ebx
  801d9d:	89 f0                	mov    %esi,%eax
  801d9f:	03 45 0c             	add    0xc(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	57                   	push   %edi
  801da4:	e8 56 eb ff ff       	call   8008ff <memmove>
		sys_cputs(buf, m);
  801da9:	83 c4 08             	add    $0x8,%esp
  801dac:	53                   	push   %ebx
  801dad:	57                   	push   %edi
  801dae:	e8 f6 ec ff ff       	call   800aa9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801db3:	01 de                	add    %ebx,%esi
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbb:	72 cd                	jb     801d8a <devcons_write+0x19>
}
  801dbd:	89 f0                	mov    %esi,%eax
  801dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <devcons_read>:
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd6:	75 07                	jne    801ddf <devcons_read+0x18>
  801dd8:	eb 1f                	jmp    801df9 <devcons_read+0x32>
		sys_yield();
  801dda:	e8 67 ed ff ff       	call   800b46 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ddf:	e8 e3 ec ff ff       	call   800ac7 <sys_cgetc>
  801de4:	85 c0                	test   %eax,%eax
  801de6:	74 f2                	je     801dda <devcons_read+0x13>
	if (c < 0)
  801de8:	78 0f                	js     801df9 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801dea:	83 f8 04             	cmp    $0x4,%eax
  801ded:	74 0c                	je     801dfb <devcons_read+0x34>
	*(char*)vbuf = c;
  801def:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df2:	88 02                	mov    %al,(%edx)
	return 1;
  801df4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    
		return 0;
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801e00:	eb f7                	jmp    801df9 <devcons_read+0x32>

00801e02 <cputchar>:
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e0e:	6a 01                	push   $0x1
  801e10:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e13:	50                   	push   %eax
  801e14:	e8 90 ec ff ff       	call   800aa9 <sys_cputs>
}
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <getchar>:
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e24:	6a 01                	push   $0x1
  801e26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e29:	50                   	push   %eax
  801e2a:	6a 00                	push   $0x0
  801e2c:	e8 66 f2 ff ff       	call   801097 <read>
	if (r < 0)
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 06                	js     801e3e <getchar+0x20>
	if (r < 1)
  801e38:	74 06                	je     801e40 <getchar+0x22>
	return c;
  801e3a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    
		return -E_EOF;
  801e40:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e45:	eb f7                	jmp    801e3e <getchar+0x20>

00801e47 <iscons>:
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	ff 75 08             	push   0x8(%ebp)
  801e54:	e8 d5 ef ff ff       	call   800e2e <fd_lookup>
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 11                	js     801e71 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e63:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e69:	39 10                	cmp    %edx,(%eax)
  801e6b:	0f 94 c0             	sete   %al
  801e6e:	0f b6 c0             	movzbl %al,%eax
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <opencons>:
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	e8 5c ef ff ff       	call   800dde <fd_alloc>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 3a                	js     801ec3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e89:	83 ec 04             	sub    $0x4,%esp
  801e8c:	68 07 04 00 00       	push   $0x407
  801e91:	ff 75 f4             	push   -0xc(%ebp)
  801e94:	6a 00                	push   $0x0
  801e96:	e8 ca ec ff ff       	call   800b65 <sys_page_alloc>
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 21                	js     801ec3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	50                   	push   %eax
  801ebb:	e8 f7 ee ff ff       	call   800db7 <fd2num>
  801ec0:	83 c4 10             	add    $0x10,%esp
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    

00801ec5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ecd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ed3:	e8 4f ec ff ff       	call   800b27 <sys_getenvid>
  801ed8:	83 ec 0c             	sub    $0xc,%esp
  801edb:	ff 75 0c             	push   0xc(%ebp)
  801ede:	ff 75 08             	push   0x8(%ebp)
  801ee1:	56                   	push   %esi
  801ee2:	50                   	push   %eax
  801ee3:	68 54 27 80 00       	push   $0x802754
  801ee8:	e8 a2 e2 ff ff       	call   80018f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eed:	83 c4 18             	add    $0x18,%esp
  801ef0:	53                   	push   %ebx
  801ef1:	ff 75 10             	push   0x10(%ebp)
  801ef4:	e8 45 e2 ff ff       	call   80013e <vcprintf>
	cprintf("\n");
  801ef9:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  801f00:	e8 8a e2 ff ff       	call   80018f <cprintf>
  801f05:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f08:	cc                   	int3   
  801f09:	eb fd                	jmp    801f08 <_panic+0x43>

00801f0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	8b 75 08             	mov    0x8(%ebp),%esi
  801f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f20:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	50                   	push   %eax
  801f27:	e8 e9 ed ff ff       	call   800d15 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 f6                	test   %esi,%esi
  801f31:	74 14                	je     801f47 <ipc_recv+0x3c>
  801f33:	ba 00 00 00 00       	mov    $0x0,%edx
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	78 09                	js     801f45 <ipc_recv+0x3a>
  801f3c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f42:	8b 52 74             	mov    0x74(%edx),%edx
  801f45:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f47:	85 db                	test   %ebx,%ebx
  801f49:	74 14                	je     801f5f <ipc_recv+0x54>
  801f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 09                	js     801f5d <ipc_recv+0x52>
  801f54:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f5a:	8b 52 78             	mov    0x78(%edx),%edx
  801f5d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	78 08                	js     801f6b <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f63:	a1 00 40 80 00       	mov    0x804000,%eax
  801f68:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6e:	5b                   	pop    %ebx
  801f6f:	5e                   	pop    %esi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 0c             	sub    $0xc,%esp
  801f7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f84:	85 db                	test   %ebx,%ebx
  801f86:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f8b:	0f 44 d8             	cmove  %eax,%ebx
  801f8e:	eb 05                	jmp    801f95 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f90:	e8 b1 eb ff ff       	call   800b46 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f95:	ff 75 14             	push   0x14(%ebp)
  801f98:	53                   	push   %ebx
  801f99:	56                   	push   %esi
  801f9a:	57                   	push   %edi
  801f9b:	e8 52 ed ff ff       	call   800cf2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fa0:	83 c4 10             	add    $0x10,%esp
  801fa3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa6:	74 e8                	je     801f90 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	78 08                	js     801fb4 <ipc_send+0x42>
	}while (r<0);

}
  801fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801fb4:	50                   	push   %eax
  801fb5:	68 77 27 80 00       	push   $0x802777
  801fba:	6a 3d                	push   $0x3d
  801fbc:	68 8b 27 80 00       	push   $0x80278b
  801fc1:	e8 ff fe ff ff       	call   801ec5 <_panic>

00801fc6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fd4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fda:	8b 52 50             	mov    0x50(%edx),%edx
  801fdd:	39 ca                	cmp    %ecx,%edx
  801fdf:	74 11                	je     801ff2 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fe1:	83 c0 01             	add    $0x1,%eax
  801fe4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe9:	75 e6                	jne    801fd1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff0:	eb 0b                	jmp    801ffd <ipc_find_env+0x37>
			return envs[i].env_id;
  801ff2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ffa:	8b 40 48             	mov    0x48(%eax),%eax
}
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802005:	89 c2                	mov    %eax,%edx
  802007:	c1 ea 16             	shr    $0x16,%edx
  80200a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802011:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802016:	f6 c1 01             	test   $0x1,%cl
  802019:	74 1c                	je     802037 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80201b:	c1 e8 0c             	shr    $0xc,%eax
  80201e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802025:	a8 01                	test   $0x1,%al
  802027:	74 0e                	je     802037 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802029:	c1 e8 0c             	shr    $0xc,%eax
  80202c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802033:	ef 
  802034:	0f b7 d2             	movzwl %dx,%edx
}
  802037:	89 d0                	mov    %edx,%eax
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	66 90                	xchg   %ax,%ax
  80203d:	66 90                	xchg   %ax,%ax
  80203f:	90                   	nop

00802040 <__udivdi3>:
  802040:	f3 0f 1e fb          	endbr32 
  802044:	55                   	push   %ebp
  802045:	57                   	push   %edi
  802046:	56                   	push   %esi
  802047:	53                   	push   %ebx
  802048:	83 ec 1c             	sub    $0x1c,%esp
  80204b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80204f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802053:	8b 74 24 34          	mov    0x34(%esp),%esi
  802057:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80205b:	85 c0                	test   %eax,%eax
  80205d:	75 19                	jne    802078 <__udivdi3+0x38>
  80205f:	39 f3                	cmp    %esi,%ebx
  802061:	76 4d                	jbe    8020b0 <__udivdi3+0x70>
  802063:	31 ff                	xor    %edi,%edi
  802065:	89 e8                	mov    %ebp,%eax
  802067:	89 f2                	mov    %esi,%edx
  802069:	f7 f3                	div    %ebx
  80206b:	89 fa                	mov    %edi,%edx
  80206d:	83 c4 1c             	add    $0x1c,%esp
  802070:	5b                   	pop    %ebx
  802071:	5e                   	pop    %esi
  802072:	5f                   	pop    %edi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    
  802075:	8d 76 00             	lea    0x0(%esi),%esi
  802078:	39 f0                	cmp    %esi,%eax
  80207a:	76 14                	jbe    802090 <__udivdi3+0x50>
  80207c:	31 ff                	xor    %edi,%edi
  80207e:	31 c0                	xor    %eax,%eax
  802080:	89 fa                	mov    %edi,%edx
  802082:	83 c4 1c             	add    $0x1c,%esp
  802085:	5b                   	pop    %ebx
  802086:	5e                   	pop    %esi
  802087:	5f                   	pop    %edi
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    
  80208a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802090:	0f bd f8             	bsr    %eax,%edi
  802093:	83 f7 1f             	xor    $0x1f,%edi
  802096:	75 48                	jne    8020e0 <__udivdi3+0xa0>
  802098:	39 f0                	cmp    %esi,%eax
  80209a:	72 06                	jb     8020a2 <__udivdi3+0x62>
  80209c:	31 c0                	xor    %eax,%eax
  80209e:	39 eb                	cmp    %ebp,%ebx
  8020a0:	77 de                	ja     802080 <__udivdi3+0x40>
  8020a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a7:	eb d7                	jmp    802080 <__udivdi3+0x40>
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d9                	mov    %ebx,%ecx
  8020b2:	85 db                	test   %ebx,%ebx
  8020b4:	75 0b                	jne    8020c1 <__udivdi3+0x81>
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f3                	div    %ebx
  8020bf:	89 c1                	mov    %eax,%ecx
  8020c1:	31 d2                	xor    %edx,%edx
  8020c3:	89 f0                	mov    %esi,%eax
  8020c5:	f7 f1                	div    %ecx
  8020c7:	89 c6                	mov    %eax,%esi
  8020c9:	89 e8                	mov    %ebp,%eax
  8020cb:	89 f7                	mov    %esi,%edi
  8020cd:	f7 f1                	div    %ecx
  8020cf:	89 fa                	mov    %edi,%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 f9                	mov    %edi,%ecx
  8020e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020e7:	29 fa                	sub    %edi,%edx
  8020e9:	d3 e0                	shl    %cl,%eax
  8020eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ef:	89 d1                	mov    %edx,%ecx
  8020f1:	89 d8                	mov    %ebx,%eax
  8020f3:	d3 e8                	shr    %cl,%eax
  8020f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020f9:	09 c1                	or     %eax,%ecx
  8020fb:	89 f0                	mov    %esi,%eax
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e3                	shl    %cl,%ebx
  802105:	89 d1                	mov    %edx,%ecx
  802107:	d3 e8                	shr    %cl,%eax
  802109:	89 f9                	mov    %edi,%ecx
  80210b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80210f:	89 eb                	mov    %ebp,%ebx
  802111:	d3 e6                	shl    %cl,%esi
  802113:	89 d1                	mov    %edx,%ecx
  802115:	d3 eb                	shr    %cl,%ebx
  802117:	09 f3                	or     %esi,%ebx
  802119:	89 c6                	mov    %eax,%esi
  80211b:	89 f2                	mov    %esi,%edx
  80211d:	89 d8                	mov    %ebx,%eax
  80211f:	f7 74 24 08          	divl   0x8(%esp)
  802123:	89 d6                	mov    %edx,%esi
  802125:	89 c3                	mov    %eax,%ebx
  802127:	f7 64 24 0c          	mull   0xc(%esp)
  80212b:	39 d6                	cmp    %edx,%esi
  80212d:	72 19                	jb     802148 <__udivdi3+0x108>
  80212f:	89 f9                	mov    %edi,%ecx
  802131:	d3 e5                	shl    %cl,%ebp
  802133:	39 c5                	cmp    %eax,%ebp
  802135:	73 04                	jae    80213b <__udivdi3+0xfb>
  802137:	39 d6                	cmp    %edx,%esi
  802139:	74 0d                	je     802148 <__udivdi3+0x108>
  80213b:	89 d8                	mov    %ebx,%eax
  80213d:	31 ff                	xor    %edi,%edi
  80213f:	e9 3c ff ff ff       	jmp    802080 <__udivdi3+0x40>
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80214b:	31 ff                	xor    %edi,%edi
  80214d:	e9 2e ff ff ff       	jmp    802080 <__udivdi3+0x40>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	f3 0f 1e fb          	endbr32 
  802164:	55                   	push   %ebp
  802165:	57                   	push   %edi
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	83 ec 1c             	sub    $0x1c,%esp
  80216b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80216f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802173:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802177:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80217b:	89 f0                	mov    %esi,%eax
  80217d:	89 da                	mov    %ebx,%edx
  80217f:	85 ff                	test   %edi,%edi
  802181:	75 15                	jne    802198 <__umoddi3+0x38>
  802183:	39 dd                	cmp    %ebx,%ebp
  802185:	76 39                	jbe    8021c0 <__umoddi3+0x60>
  802187:	f7 f5                	div    %ebp
  802189:	89 d0                	mov    %edx,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	83 c4 1c             	add    $0x1c,%esp
  802190:	5b                   	pop    %ebx
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	39 df                	cmp    %ebx,%edi
  80219a:	77 f1                	ja     80218d <__umoddi3+0x2d>
  80219c:	0f bd cf             	bsr    %edi,%ecx
  80219f:	83 f1 1f             	xor    $0x1f,%ecx
  8021a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021a6:	75 40                	jne    8021e8 <__umoddi3+0x88>
  8021a8:	39 df                	cmp    %ebx,%edi
  8021aa:	72 04                	jb     8021b0 <__umoddi3+0x50>
  8021ac:	39 f5                	cmp    %esi,%ebp
  8021ae:	77 dd                	ja     80218d <__umoddi3+0x2d>
  8021b0:	89 da                	mov    %ebx,%edx
  8021b2:	89 f0                	mov    %esi,%eax
  8021b4:	29 e8                	sub    %ebp,%eax
  8021b6:	19 fa                	sbb    %edi,%edx
  8021b8:	eb d3                	jmp    80218d <__umoddi3+0x2d>
  8021ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c0:	89 e9                	mov    %ebp,%ecx
  8021c2:	85 ed                	test   %ebp,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x71>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f5                	div    %ebp
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	89 d8                	mov    %ebx,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f1                	div    %ecx
  8021d7:	89 f0                	mov    %esi,%eax
  8021d9:	f7 f1                	div    %ecx
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	31 d2                	xor    %edx,%edx
  8021df:	eb ac                	jmp    80218d <__umoddi3+0x2d>
  8021e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8021f1:	29 c2                	sub    %eax,%edx
  8021f3:	89 c1                	mov    %eax,%ecx
  8021f5:	89 e8                	mov    %ebp,%eax
  8021f7:	d3 e7                	shl    %cl,%edi
  8021f9:	89 d1                	mov    %edx,%ecx
  8021fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021ff:	d3 e8                	shr    %cl,%eax
  802201:	89 c1                	mov    %eax,%ecx
  802203:	8b 44 24 04          	mov    0x4(%esp),%eax
  802207:	09 f9                	or     %edi,%ecx
  802209:	89 df                	mov    %ebx,%edi
  80220b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	d3 e5                	shl    %cl,%ebp
  802213:	89 d1                	mov    %edx,%ecx
  802215:	d3 ef                	shr    %cl,%edi
  802217:	89 c1                	mov    %eax,%ecx
  802219:	89 f0                	mov    %esi,%eax
  80221b:	d3 e3                	shl    %cl,%ebx
  80221d:	89 d1                	mov    %edx,%ecx
  80221f:	89 fa                	mov    %edi,%edx
  802221:	d3 e8                	shr    %cl,%eax
  802223:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802228:	09 d8                	or     %ebx,%eax
  80222a:	f7 74 24 08          	divl   0x8(%esp)
  80222e:	89 d3                	mov    %edx,%ebx
  802230:	d3 e6                	shl    %cl,%esi
  802232:	f7 e5                	mul    %ebp
  802234:	89 c7                	mov    %eax,%edi
  802236:	89 d1                	mov    %edx,%ecx
  802238:	39 d3                	cmp    %edx,%ebx
  80223a:	72 06                	jb     802242 <__umoddi3+0xe2>
  80223c:	75 0e                	jne    80224c <__umoddi3+0xec>
  80223e:	39 c6                	cmp    %eax,%esi
  802240:	73 0a                	jae    80224c <__umoddi3+0xec>
  802242:	29 e8                	sub    %ebp,%eax
  802244:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802248:	89 d1                	mov    %edx,%ecx
  80224a:	89 c7                	mov    %eax,%edi
  80224c:	89 f5                	mov    %esi,%ebp
  80224e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802252:	29 fd                	sub    %edi,%ebp
  802254:	19 cb                	sbb    %ecx,%ebx
  802256:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80225b:	89 d8                	mov    %ebx,%eax
  80225d:	d3 e0                	shl    %cl,%eax
  80225f:	89 f1                	mov    %esi,%ecx
  802261:	d3 ed                	shr    %cl,%ebp
  802263:	d3 eb                	shr    %cl,%ebx
  802265:	09 e8                	or     %ebp,%eax
  802267:	89 da                	mov    %ebx,%edx
  802269:	83 c4 1c             	add    $0x1c,%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5f                   	pop    %edi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    
