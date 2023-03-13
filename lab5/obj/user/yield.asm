
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
  800043:	68 c0 1d 80 00       	push   $0x801dc0
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
  800067:	68 e0 1d 80 00       	push   $0x801de0
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
  800088:	68 0c 1e 80 00       	push   $0x801e0c
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
  8000e6:	e8 37 0e 00 00       	call   800f22 <close_all>
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
  8001f1:	e8 7a 19 00 00       	call   801b70 <__udivdi3>
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
  80022f:	e8 5c 1a 00 00       	call   801c90 <__umoddi3>
  800234:	83 c4 14             	add    $0x14,%esp
  800237:	0f be 80 35 1e 80 00 	movsbl 0x801e35(%eax),%eax
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
  8002f1:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
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
  8003bf:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	74 18                	je     8003e2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 11 22 80 00       	push   $0x802211
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 92 fe ff ff       	call   800269 <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003da:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dd:	e9 66 02 00 00       	jmp    800648 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003e2:	50                   	push   %eax
  8003e3:	68 4d 1e 80 00       	push   $0x801e4d
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
  80040a:	b8 46 1e 80 00       	mov    $0x801e46,%eax
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
  800b16:	68 3f 21 80 00       	push   $0x80213f
  800b1b:	6a 2a                	push   $0x2a
  800b1d:	68 5c 21 80 00       	push   $0x80215c
  800b22:	e8 d0 0e 00 00       	call   8019f7 <_panic>

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
  800b97:	68 3f 21 80 00       	push   $0x80213f
  800b9c:	6a 2a                	push   $0x2a
  800b9e:	68 5c 21 80 00       	push   $0x80215c
  800ba3:	e8 4f 0e 00 00       	call   8019f7 <_panic>

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
  800bd9:	68 3f 21 80 00       	push   $0x80213f
  800bde:	6a 2a                	push   $0x2a
  800be0:	68 5c 21 80 00       	push   $0x80215c
  800be5:	e8 0d 0e 00 00       	call   8019f7 <_panic>

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
  800c1b:	68 3f 21 80 00       	push   $0x80213f
  800c20:	6a 2a                	push   $0x2a
  800c22:	68 5c 21 80 00       	push   $0x80215c
  800c27:	e8 cb 0d 00 00       	call   8019f7 <_panic>

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
  800c5d:	68 3f 21 80 00       	push   $0x80213f
  800c62:	6a 2a                	push   $0x2a
  800c64:	68 5c 21 80 00       	push   $0x80215c
  800c69:	e8 89 0d 00 00       	call   8019f7 <_panic>

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
  800c9f:	68 3f 21 80 00       	push   $0x80213f
  800ca4:	6a 2a                	push   $0x2a
  800ca6:	68 5c 21 80 00       	push   $0x80215c
  800cab:	e8 47 0d 00 00       	call   8019f7 <_panic>

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
  800ce1:	68 3f 21 80 00       	push   $0x80213f
  800ce6:	6a 2a                	push   $0x2a
  800ce8:	68 5c 21 80 00       	push   $0x80215c
  800ced:	e8 05 0d 00 00       	call   8019f7 <_panic>

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
  800d45:	68 3f 21 80 00       	push   $0x80213f
  800d4a:	6a 2a                	push   $0x2a
  800d4c:	68 5c 21 80 00       	push   $0x80215c
  800d51:	e8 a1 0c 00 00       	call   8019f7 <_panic>

00800d56 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d61:	c1 e8 0c             	shr    $0xc,%eax
}
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d76:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	c1 ea 16             	shr    $0x16,%edx
  800d8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d91:	f6 c2 01             	test   $0x1,%dl
  800d94:	74 29                	je     800dbf <fd_alloc+0x42>
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	c1 ea 0c             	shr    $0xc,%edx
  800d9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da2:	f6 c2 01             	test   $0x1,%dl
  800da5:	74 18                	je     800dbf <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800da7:	05 00 10 00 00       	add    $0x1000,%eax
  800dac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db1:	75 d2                	jne    800d85 <fd_alloc+0x8>
  800db3:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800db8:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800dbd:	eb 05                	jmp    800dc4 <fd_alloc+0x47>
			return 0;
  800dbf:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 02                	mov    %eax,(%edx)
}
  800dc9:	89 c8                	mov    %ecx,%eax
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd3:	83 f8 1f             	cmp    $0x1f,%eax
  800dd6:	77 30                	ja     800e08 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd8:	c1 e0 0c             	shl    $0xc,%eax
  800ddb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de0:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800de6:	f6 c2 01             	test   $0x1,%dl
  800de9:	74 24                	je     800e0f <fd_lookup+0x42>
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	c1 ea 0c             	shr    $0xc,%edx
  800df0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df7:	f6 c2 01             	test   $0x1,%dl
  800dfa:	74 1a                	je     800e16 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dff:	89 02                	mov    %eax,(%edx)
	return 0;
  800e01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
		return -E_INVAL;
  800e08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0d:	eb f7                	jmp    800e06 <fd_lookup+0x39>
		return -E_INVAL;
  800e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e14:	eb f0                	jmp    800e06 <fd_lookup+0x39>
  800e16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1b:	eb e9                	jmp    800e06 <fd_lookup+0x39>

00800e1d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	53                   	push   %ebx
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	b8 e8 21 80 00       	mov    $0x8021e8,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800e2c:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e31:	39 13                	cmp    %edx,(%ebx)
  800e33:	74 32                	je     800e67 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800e35:	83 c0 04             	add    $0x4,%eax
  800e38:	8b 18                	mov    (%eax),%ebx
  800e3a:	85 db                	test   %ebx,%ebx
  800e3c:	75 f3                	jne    800e31 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e3e:	a1 00 40 80 00       	mov    0x804000,%eax
  800e43:	8b 40 48             	mov    0x48(%eax),%eax
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	52                   	push   %edx
  800e4a:	50                   	push   %eax
  800e4b:	68 6c 21 80 00       	push   $0x80216c
  800e50:	e8 3a f3 ff ff       	call   80018f <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e60:	89 1a                	mov    %ebx,(%edx)
}
  800e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    
			return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	eb ef                	jmp    800e5d <dev_lookup+0x40>

00800e6e <fd_close>:
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 24             	sub    $0x24,%esp
  800e77:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e80:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e81:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e87:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8a:	50                   	push   %eax
  800e8b:	e8 3d ff ff ff       	call   800dcd <fd_lookup>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 05                	js     800e9e <fd_close+0x30>
	    || fd != fd2)
  800e99:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e9c:	74 16                	je     800eb4 <fd_close+0x46>
		return (must_exist ? r : 0);
  800e9e:	89 f8                	mov    %edi,%eax
  800ea0:	84 c0                	test   %al,%al
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	0f 44 d8             	cmove  %eax,%ebx
}
  800eaa:	89 d8                	mov    %ebx,%eax
  800eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	ff 36                	push   (%esi)
  800ebd:	e8 5b ff ff ff       	call   800e1d <dev_lookup>
  800ec2:	89 c3                	mov    %eax,%ebx
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 1a                	js     800ee5 <fd_close+0x77>
		if (dev->dev_close)
  800ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ece:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ed1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	74 0b                	je     800ee5 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	56                   	push   %esi
  800ede:	ff d0                	call   *%eax
  800ee0:	89 c3                	mov    %eax,%ebx
  800ee2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	56                   	push   %esi
  800ee9:	6a 00                	push   $0x0
  800eeb:	e8 fa fc ff ff       	call   800bea <sys_page_unmap>
	return r;
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	eb b5                	jmp    800eaa <fd_close+0x3c>

00800ef5 <close>:

int
close(int fdnum)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efe:	50                   	push   %eax
  800eff:	ff 75 08             	push   0x8(%ebp)
  800f02:	e8 c6 fe ff ff       	call   800dcd <fd_lookup>
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	79 02                	jns    800f10 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    
		return fd_close(fd, 1);
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	6a 01                	push   $0x1
  800f15:	ff 75 f4             	push   -0xc(%ebp)
  800f18:	e8 51 ff ff ff       	call   800e6e <fd_close>
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	eb ec                	jmp    800f0e <close+0x19>

00800f22 <close_all>:

void
close_all(void)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	53                   	push   %ebx
  800f26:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	53                   	push   %ebx
  800f32:	e8 be ff ff ff       	call   800ef5 <close>
	for (i = 0; i < MAXFD; i++)
  800f37:	83 c3 01             	add    $0x1,%ebx
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	83 fb 20             	cmp    $0x20,%ebx
  800f40:	75 ec                	jne    800f2e <close_all+0xc>
}
  800f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f53:	50                   	push   %eax
  800f54:	ff 75 08             	push   0x8(%ebp)
  800f57:	e8 71 fe ff ff       	call   800dcd <fd_lookup>
  800f5c:	89 c3                	mov    %eax,%ebx
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 7f                	js     800fe4 <dup+0x9d>
		return r;
	close(newfdnum);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	ff 75 0c             	push   0xc(%ebp)
  800f6b:	e8 85 ff ff ff       	call   800ef5 <close>

	newfd = INDEX2FD(newfdnum);
  800f70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f73:	c1 e6 0c             	shl    $0xc,%esi
  800f76:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f7f:	89 3c 24             	mov    %edi,(%esp)
  800f82:	e8 df fd ff ff       	call   800d66 <fd2data>
  800f87:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f89:	89 34 24             	mov    %esi,(%esp)
  800f8c:	e8 d5 fd ff ff       	call   800d66 <fd2data>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f97:	89 d8                	mov    %ebx,%eax
  800f99:	c1 e8 16             	shr    $0x16,%eax
  800f9c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa3:	a8 01                	test   $0x1,%al
  800fa5:	74 11                	je     800fb8 <dup+0x71>
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	c1 e8 0c             	shr    $0xc,%eax
  800fac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb3:	f6 c2 01             	test   $0x1,%dl
  800fb6:	75 36                	jne    800fee <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb8:	89 f8                	mov    %edi,%eax
  800fba:	c1 e8 0c             	shr    $0xc,%eax
  800fbd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcc:	50                   	push   %eax
  800fcd:	56                   	push   %esi
  800fce:	6a 00                	push   $0x0
  800fd0:	57                   	push   %edi
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 d0 fb ff ff       	call   800ba8 <sys_page_map>
  800fd8:	89 c3                	mov    %eax,%ebx
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 33                	js     801014 <dup+0xcd>
		goto err;

	return newfdnum;
  800fe1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	50                   	push   %eax
  800ffe:	ff 75 d4             	push   -0x2c(%ebp)
  801001:	6a 00                	push   $0x0
  801003:	53                   	push   %ebx
  801004:	6a 00                	push   $0x0
  801006:	e8 9d fb ff ff       	call   800ba8 <sys_page_map>
  80100b:	89 c3                	mov    %eax,%ebx
  80100d:	83 c4 20             	add    $0x20,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	79 a4                	jns    800fb8 <dup+0x71>
	sys_page_unmap(0, newfd);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 cb fb ff ff       	call   800bea <sys_page_unmap>
	sys_page_unmap(0, nva);
  80101f:	83 c4 08             	add    $0x8,%esp
  801022:	ff 75 d4             	push   -0x2c(%ebp)
  801025:	6a 00                	push   $0x0
  801027:	e8 be fb ff ff       	call   800bea <sys_page_unmap>
	return r;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	eb b3                	jmp    800fe4 <dup+0x9d>

00801031 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	83 ec 18             	sub    $0x18,%esp
  801039:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80103c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80103f:	50                   	push   %eax
  801040:	56                   	push   %esi
  801041:	e8 87 fd ff ff       	call   800dcd <fd_lookup>
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 3c                	js     801089 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80104d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	ff 33                	push   (%ebx)
  801059:	e8 bf fd ff ff       	call   800e1d <dev_lookup>
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 24                	js     801089 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801065:	8b 43 08             	mov    0x8(%ebx),%eax
  801068:	83 e0 03             	and    $0x3,%eax
  80106b:	83 f8 01             	cmp    $0x1,%eax
  80106e:	74 20                	je     801090 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801070:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801073:	8b 40 08             	mov    0x8(%eax),%eax
  801076:	85 c0                	test   %eax,%eax
  801078:	74 37                	je     8010b1 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	ff 75 10             	push   0x10(%ebp)
  801080:	ff 75 0c             	push   0xc(%ebp)
  801083:	53                   	push   %ebx
  801084:	ff d0                	call   *%eax
  801086:	83 c4 10             	add    $0x10,%esp
}
  801089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801090:	a1 00 40 80 00       	mov    0x804000,%eax
  801095:	8b 40 48             	mov    0x48(%eax),%eax
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	56                   	push   %esi
  80109c:	50                   	push   %eax
  80109d:	68 ad 21 80 00       	push   $0x8021ad
  8010a2:	e8 e8 f0 ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010af:	eb d8                	jmp    801089 <read+0x58>
		return -E_NOT_SUPP;
  8010b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010b6:	eb d1                	jmp    801089 <read+0x58>

008010b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cc:	eb 02                	jmp    8010d0 <readn+0x18>
  8010ce:	01 c3                	add    %eax,%ebx
  8010d0:	39 f3                	cmp    %esi,%ebx
  8010d2:	73 21                	jae    8010f5 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	29 d8                	sub    %ebx,%eax
  8010db:	50                   	push   %eax
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	03 45 0c             	add    0xc(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	57                   	push   %edi
  8010e3:	e8 49 ff ff ff       	call   801031 <read>
		if (m < 0)
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 04                	js     8010f3 <readn+0x3b>
			return m;
		if (m == 0)
  8010ef:	75 dd                	jne    8010ce <readn+0x16>
  8010f1:	eb 02                	jmp    8010f5 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010f5:	89 d8                	mov    %ebx,%eax
  8010f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 18             	sub    $0x18,%esp
  801107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	53                   	push   %ebx
  80110f:	e8 b9 fc ff ff       	call   800dcd <fd_lookup>
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 37                	js     801152 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	ff 36                	push   (%esi)
  801127:	e8 f1 fc ff ff       	call   800e1d <dev_lookup>
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 1f                	js     801152 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801133:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801137:	74 20                	je     801159 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113c:	8b 40 0c             	mov    0xc(%eax),%eax
  80113f:	85 c0                	test   %eax,%eax
  801141:	74 37                	je     80117a <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801143:	83 ec 04             	sub    $0x4,%esp
  801146:	ff 75 10             	push   0x10(%ebp)
  801149:	ff 75 0c             	push   0xc(%ebp)
  80114c:	56                   	push   %esi
  80114d:	ff d0                	call   *%eax
  80114f:	83 c4 10             	add    $0x10,%esp
}
  801152:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801159:	a1 00 40 80 00       	mov    0x804000,%eax
  80115e:	8b 40 48             	mov    0x48(%eax),%eax
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	53                   	push   %ebx
  801165:	50                   	push   %eax
  801166:	68 c9 21 80 00       	push   $0x8021c9
  80116b:	e8 1f f0 ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801178:	eb d8                	jmp    801152 <write+0x53>
		return -E_NOT_SUPP;
  80117a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80117f:	eb d1                	jmp    801152 <write+0x53>

00801181 <seek>:

int
seek(int fdnum, off_t offset)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	ff 75 08             	push   0x8(%ebp)
  80118e:	e8 3a fc ff ff       	call   800dcd <fd_lookup>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 0e                	js     8011a8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80119a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 18             	sub    $0x18,%esp
  8011b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	53                   	push   %ebx
  8011ba:	e8 0e fc ff ff       	call   800dcd <fd_lookup>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 34                	js     8011fa <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 36                	push   (%esi)
  8011d2:	e8 46 fc ff ff       	call   800e1d <dev_lookup>
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 1c                	js     8011fa <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011de:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011e2:	74 1d                	je     801201 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e7:	8b 40 18             	mov    0x18(%eax),%eax
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 34                	je     801222 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	ff 75 0c             	push   0xc(%ebp)
  8011f4:	56                   	push   %esi
  8011f5:	ff d0                	call   *%eax
  8011f7:	83 c4 10             	add    $0x10,%esp
}
  8011fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    
			thisenv->env_id, fdnum);
  801201:	a1 00 40 80 00       	mov    0x804000,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	53                   	push   %ebx
  80120d:	50                   	push   %eax
  80120e:	68 8c 21 80 00       	push   $0x80218c
  801213:	e8 77 ef ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801220:	eb d8                	jmp    8011fa <ftruncate+0x50>
		return -E_NOT_SUPP;
  801222:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801227:	eb d1                	jmp    8011fa <ftruncate+0x50>

00801229 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	56                   	push   %esi
  80122d:	53                   	push   %ebx
  80122e:	83 ec 18             	sub    $0x18,%esp
  801231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801234:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 75 08             	push   0x8(%ebp)
  80123b:	e8 8d fb ff ff       	call   800dcd <fd_lookup>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 49                	js     801290 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801247:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 36                	push   (%esi)
  801253:	e8 c5 fb ff ff       	call   800e1d <dev_lookup>
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 31                	js     801290 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801262:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801266:	74 2f                	je     801297 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801268:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80126b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801272:	00 00 00 
	stat->st_isdir = 0;
  801275:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80127c:	00 00 00 
	stat->st_dev = dev;
  80127f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	53                   	push   %ebx
  801289:	56                   	push   %esi
  80128a:	ff 50 14             	call   *0x14(%eax)
  80128d:	83 c4 10             	add    $0x10,%esp
}
  801290:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    
		return -E_NOT_SUPP;
  801297:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80129c:	eb f2                	jmp    801290 <fstat+0x67>

0080129e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	6a 00                	push   $0x0
  8012a8:	ff 75 08             	push   0x8(%ebp)
  8012ab:	e8 e4 01 00 00       	call   801494 <open>
  8012b0:	89 c3                	mov    %eax,%ebx
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 1b                	js     8012d4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	ff 75 0c             	push   0xc(%ebp)
  8012bf:	50                   	push   %eax
  8012c0:	e8 64 ff ff ff       	call   801229 <fstat>
  8012c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c7:	89 1c 24             	mov    %ebx,(%esp)
  8012ca:	e8 26 fc ff ff       	call   800ef5 <close>
	return r;
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	89 f3                	mov    %esi,%ebx
}
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	56                   	push   %esi
  8012e1:	53                   	push   %ebx
  8012e2:	89 c6                	mov    %eax,%esi
  8012e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8012ed:	74 27                	je     801316 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012ef:	6a 07                	push   $0x7
  8012f1:	68 00 50 80 00       	push   $0x805000
  8012f6:	56                   	push   %esi
  8012f7:	ff 35 00 60 80 00    	push   0x806000
  8012fd:	e8 a2 07 00 00       	call   801aa4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801302:	83 c4 0c             	add    $0xc,%esp
  801305:	6a 00                	push   $0x0
  801307:	53                   	push   %ebx
  801308:	6a 00                	push   $0x0
  80130a:	e8 2e 07 00 00       	call   801a3d <ipc_recv>
}
  80130f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	6a 01                	push   $0x1
  80131b:	e8 d8 07 00 00       	call   801af8 <ipc_find_env>
  801320:	a3 00 60 80 00       	mov    %eax,0x806000
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	eb c5                	jmp    8012ef <fsipc+0x12>

0080132a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	8b 40 0c             	mov    0xc(%eax),%eax
  801336:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80133b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801343:	ba 00 00 00 00       	mov    $0x0,%edx
  801348:	b8 02 00 00 00       	mov    $0x2,%eax
  80134d:	e8 8b ff ff ff       	call   8012dd <fsipc>
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <devfile_flush>:
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	8b 40 0c             	mov    0xc(%eax),%eax
  801360:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801365:	ba 00 00 00 00       	mov    $0x0,%edx
  80136a:	b8 06 00 00 00       	mov    $0x6,%eax
  80136f:	e8 69 ff ff ff       	call   8012dd <fsipc>
}
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <devfile_stat>:
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	53                   	push   %ebx
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	8b 40 0c             	mov    0xc(%eax),%eax
  801386:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80138b:	ba 00 00 00 00       	mov    $0x0,%edx
  801390:	b8 05 00 00 00       	mov    $0x5,%eax
  801395:	e8 43 ff ff ff       	call   8012dd <fsipc>
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 2c                	js     8013ca <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	68 00 50 80 00       	push   $0x805000
  8013a6:	53                   	push   %ebx
  8013a7:	e8 bd f3 ff ff       	call   800769 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8013b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8013bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <devfile_write>:
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013dd:	39 d0                	cmp    %edx,%eax
  8013df:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013e8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013ee:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013f3:	50                   	push   %eax
  8013f4:	ff 75 0c             	push   0xc(%ebp)
  8013f7:	68 08 50 80 00       	push   $0x805008
  8013fc:	e8 fe f4 ff ff       	call   8008ff <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801401:	ba 00 00 00 00       	mov    $0x0,%edx
  801406:	b8 04 00 00 00       	mov    $0x4,%eax
  80140b:	e8 cd fe ff ff       	call   8012dd <fsipc>
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <devfile_read>:
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	8b 40 0c             	mov    0xc(%eax),%eax
  801420:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801425:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80142b:	ba 00 00 00 00       	mov    $0x0,%edx
  801430:	b8 03 00 00 00       	mov    $0x3,%eax
  801435:	e8 a3 fe ff ff       	call   8012dd <fsipc>
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 1f                	js     80145f <devfile_read+0x4d>
	assert(r <= n);
  801440:	39 f0                	cmp    %esi,%eax
  801442:	77 24                	ja     801468 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801444:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801449:	7f 33                	jg     80147e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	50                   	push   %eax
  80144f:	68 00 50 80 00       	push   $0x805000
  801454:	ff 75 0c             	push   0xc(%ebp)
  801457:	e8 a3 f4 ff ff       	call   8008ff <memmove>
	return r;
  80145c:	83 c4 10             	add    $0x10,%esp
}
  80145f:	89 d8                	mov    %ebx,%eax
  801461:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    
	assert(r <= n);
  801468:	68 f8 21 80 00       	push   $0x8021f8
  80146d:	68 ff 21 80 00       	push   $0x8021ff
  801472:	6a 7c                	push   $0x7c
  801474:	68 14 22 80 00       	push   $0x802214
  801479:	e8 79 05 00 00       	call   8019f7 <_panic>
	assert(r <= PGSIZE);
  80147e:	68 1f 22 80 00       	push   $0x80221f
  801483:	68 ff 21 80 00       	push   $0x8021ff
  801488:	6a 7d                	push   $0x7d
  80148a:	68 14 22 80 00       	push   $0x802214
  80148f:	e8 63 05 00 00       	call   8019f7 <_panic>

00801494 <open>:
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	83 ec 1c             	sub    $0x1c,%esp
  80149c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80149f:	56                   	push   %esi
  8014a0:	e8 89 f2 ff ff       	call   80072e <strlen>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ad:	7f 6c                	jg     80151b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	e8 c2 f8 ff ff       	call   800d7d <fd_alloc>
  8014bb:	89 c3                	mov    %eax,%ebx
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 3c                	js     801500 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	56                   	push   %esi
  8014c8:	68 00 50 80 00       	push   $0x805000
  8014cd:	e8 97 f2 ff ff       	call   800769 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e2:	e8 f6 fd ff ff       	call   8012dd <fsipc>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 19                	js     801509 <open+0x75>
	return fd2num(fd);
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	ff 75 f4             	push   -0xc(%ebp)
  8014f6:	e8 5b f8 ff ff       	call   800d56 <fd2num>
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	83 c4 10             	add    $0x10,%esp
}
  801500:	89 d8                	mov    %ebx,%eax
  801502:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    
		fd_close(fd, 0);
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	6a 00                	push   $0x0
  80150e:	ff 75 f4             	push   -0xc(%ebp)
  801511:	e8 58 f9 ff ff       	call   800e6e <fd_close>
		return r;
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	eb e5                	jmp    801500 <open+0x6c>
		return -E_BAD_PATH;
  80151b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801520:	eb de                	jmp    801500 <open+0x6c>

00801522 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 08 00 00 00       	mov    $0x8,%eax
  801532:	e8 a6 fd ff ff       	call   8012dd <fsipc>
}
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	ff 75 08             	push   0x8(%ebp)
  801547:	e8 1a f8 ff ff       	call   800d66 <fd2data>
  80154c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80154e:	83 c4 08             	add    $0x8,%esp
  801551:	68 2b 22 80 00       	push   $0x80222b
  801556:	53                   	push   %ebx
  801557:	e8 0d f2 ff ff       	call   800769 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80155c:	8b 46 04             	mov    0x4(%esi),%eax
  80155f:	2b 06                	sub    (%esi),%eax
  801561:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801567:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156e:	00 00 00 
	stat->st_dev = &devpipe;
  801571:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801578:	30 80 00 
	return 0;
}
  80157b:	b8 00 00 00 00       	mov    $0x0,%eax
  801580:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801591:	53                   	push   %ebx
  801592:	6a 00                	push   $0x0
  801594:	e8 51 f6 ff ff       	call   800bea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801599:	89 1c 24             	mov    %ebx,(%esp)
  80159c:	e8 c5 f7 ff ff       	call   800d66 <fd2data>
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	50                   	push   %eax
  8015a5:	6a 00                	push   $0x0
  8015a7:	e8 3e f6 ff ff       	call   800bea <sys_page_unmap>
}
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <_pipeisclosed>:
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 1c             	sub    $0x1c,%esp
  8015ba:	89 c7                	mov    %eax,%edi
  8015bc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8015be:	a1 00 40 80 00       	mov    0x804000,%eax
  8015c3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015c6:	83 ec 0c             	sub    $0xc,%esp
  8015c9:	57                   	push   %edi
  8015ca:	e8 62 05 00 00       	call   801b31 <pageref>
  8015cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d2:	89 34 24             	mov    %esi,(%esp)
  8015d5:	e8 57 05 00 00       	call   801b31 <pageref>
		nn = thisenv->env_runs;
  8015da:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8015e0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	39 cb                	cmp    %ecx,%ebx
  8015e8:	74 1b                	je     801605 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015ea:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015ed:	75 cf                	jne    8015be <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015ef:	8b 42 58             	mov    0x58(%edx),%eax
  8015f2:	6a 01                	push   $0x1
  8015f4:	50                   	push   %eax
  8015f5:	53                   	push   %ebx
  8015f6:	68 32 22 80 00       	push   $0x802232
  8015fb:	e8 8f eb ff ff       	call   80018f <cprintf>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb b9                	jmp    8015be <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801605:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801608:	0f 94 c0             	sete   %al
  80160b:	0f b6 c0             	movzbl %al,%eax
}
  80160e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <devpipe_write>:
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	57                   	push   %edi
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 28             	sub    $0x28,%esp
  80161f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801622:	56                   	push   %esi
  801623:	e8 3e f7 ff ff       	call   800d66 <fd2data>
  801628:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	bf 00 00 00 00       	mov    $0x0,%edi
  801632:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801635:	75 09                	jne    801640 <devpipe_write+0x2a>
	return i;
  801637:	89 f8                	mov    %edi,%eax
  801639:	eb 23                	jmp    80165e <devpipe_write+0x48>
			sys_yield();
  80163b:	e8 06 f5 ff ff       	call   800b46 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801640:	8b 43 04             	mov    0x4(%ebx),%eax
  801643:	8b 0b                	mov    (%ebx),%ecx
  801645:	8d 51 20             	lea    0x20(%ecx),%edx
  801648:	39 d0                	cmp    %edx,%eax
  80164a:	72 1a                	jb     801666 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80164c:	89 da                	mov    %ebx,%edx
  80164e:	89 f0                	mov    %esi,%eax
  801650:	e8 5c ff ff ff       	call   8015b1 <_pipeisclosed>
  801655:	85 c0                	test   %eax,%eax
  801657:	74 e2                	je     80163b <devpipe_write+0x25>
				return 0;
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801669:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80166d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801670:	89 c2                	mov    %eax,%edx
  801672:	c1 fa 1f             	sar    $0x1f,%edx
  801675:	89 d1                	mov    %edx,%ecx
  801677:	c1 e9 1b             	shr    $0x1b,%ecx
  80167a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80167d:	83 e2 1f             	and    $0x1f,%edx
  801680:	29 ca                	sub    %ecx,%edx
  801682:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801686:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80168a:	83 c0 01             	add    $0x1,%eax
  80168d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801690:	83 c7 01             	add    $0x1,%edi
  801693:	eb 9d                	jmp    801632 <devpipe_write+0x1c>

00801695 <devpipe_read>:
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	57                   	push   %edi
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	83 ec 18             	sub    $0x18,%esp
  80169e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8016a1:	57                   	push   %edi
  8016a2:	e8 bf f6 ff ff       	call   800d66 <fd2data>
  8016a7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	be 00 00 00 00       	mov    $0x0,%esi
  8016b1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016b4:	75 13                	jne    8016c9 <devpipe_read+0x34>
	return i;
  8016b6:	89 f0                	mov    %esi,%eax
  8016b8:	eb 02                	jmp    8016bc <devpipe_read+0x27>
				return i;
  8016ba:	89 f0                	mov    %esi,%eax
}
  8016bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5f                   	pop    %edi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    
			sys_yield();
  8016c4:	e8 7d f4 ff ff       	call   800b46 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8016c9:	8b 03                	mov    (%ebx),%eax
  8016cb:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ce:	75 18                	jne    8016e8 <devpipe_read+0x53>
			if (i > 0)
  8016d0:	85 f6                	test   %esi,%esi
  8016d2:	75 e6                	jne    8016ba <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8016d4:	89 da                	mov    %ebx,%edx
  8016d6:	89 f8                	mov    %edi,%eax
  8016d8:	e8 d4 fe ff ff       	call   8015b1 <_pipeisclosed>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	74 e3                	je     8016c4 <devpipe_read+0x2f>
				return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e6:	eb d4                	jmp    8016bc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e8:	99                   	cltd   
  8016e9:	c1 ea 1b             	shr    $0x1b,%edx
  8016ec:	01 d0                	add    %edx,%eax
  8016ee:	83 e0 1f             	and    $0x1f,%eax
  8016f1:	29 d0                	sub    %edx,%eax
  8016f3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016fe:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801701:	83 c6 01             	add    $0x1,%esi
  801704:	eb ab                	jmp    8016b1 <devpipe_read+0x1c>

00801706 <pipe>:
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80170e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	e8 66 f6 ff ff       	call   800d7d <fd_alloc>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	0f 88 23 01 00 00    	js     801847 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	68 07 04 00 00       	push   $0x407
  80172c:	ff 75 f4             	push   -0xc(%ebp)
  80172f:	6a 00                	push   $0x0
  801731:	e8 2f f4 ff ff       	call   800b65 <sys_page_alloc>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	0f 88 04 01 00 00    	js     801847 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	e8 2e f6 ff ff       	call   800d7d <fd_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	0f 88 db 00 00 00    	js     801837 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	68 07 04 00 00       	push   $0x407
  801764:	ff 75 f0             	push   -0x10(%ebp)
  801767:	6a 00                	push   $0x0
  801769:	e8 f7 f3 ff ff       	call   800b65 <sys_page_alloc>
  80176e:	89 c3                	mov    %eax,%ebx
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	0f 88 bc 00 00 00    	js     801837 <pipe+0x131>
	va = fd2data(fd0);
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	ff 75 f4             	push   -0xc(%ebp)
  801781:	e8 e0 f5 ff ff       	call   800d66 <fd2data>
  801786:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801788:	83 c4 0c             	add    $0xc,%esp
  80178b:	68 07 04 00 00       	push   $0x407
  801790:	50                   	push   %eax
  801791:	6a 00                	push   $0x0
  801793:	e8 cd f3 ff ff       	call   800b65 <sys_page_alloc>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	0f 88 82 00 00 00    	js     801827 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	ff 75 f0             	push   -0x10(%ebp)
  8017ab:	e8 b6 f5 ff ff       	call   800d66 <fd2data>
  8017b0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017b7:	50                   	push   %eax
  8017b8:	6a 00                	push   $0x0
  8017ba:	56                   	push   %esi
  8017bb:	6a 00                	push   $0x0
  8017bd:	e8 e6 f3 ff ff       	call   800ba8 <sys_page_map>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 20             	add    $0x20,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 4e                	js     801819 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8017cb:	a1 20 30 80 00       	mov    0x803020,%eax
  8017d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8017d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8017df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8017e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017ee:	83 ec 0c             	sub    $0xc,%esp
  8017f1:	ff 75 f4             	push   -0xc(%ebp)
  8017f4:	e8 5d f5 ff ff       	call   800d56 <fd2num>
  8017f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017fe:	83 c4 04             	add    $0x4,%esp
  801801:	ff 75 f0             	push   -0x10(%ebp)
  801804:	e8 4d f5 ff ff       	call   800d56 <fd2num>
  801809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80180c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	bb 00 00 00 00       	mov    $0x0,%ebx
  801817:	eb 2e                	jmp    801847 <pipe+0x141>
	sys_page_unmap(0, va);
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	56                   	push   %esi
  80181d:	6a 00                	push   $0x0
  80181f:	e8 c6 f3 ff ff       	call   800bea <sys_page_unmap>
  801824:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	ff 75 f0             	push   -0x10(%ebp)
  80182d:	6a 00                	push   $0x0
  80182f:	e8 b6 f3 ff ff       	call   800bea <sys_page_unmap>
  801834:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	ff 75 f4             	push   -0xc(%ebp)
  80183d:	6a 00                	push   $0x0
  80183f:	e8 a6 f3 ff ff       	call   800bea <sys_page_unmap>
  801844:	83 c4 10             	add    $0x10,%esp
}
  801847:	89 d8                	mov    %ebx,%eax
  801849:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5e                   	pop    %esi
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <pipeisclosed>:
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	ff 75 08             	push   0x8(%ebp)
  80185d:	e8 6b f5 ff ff       	call   800dcd <fd_lookup>
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	78 18                	js     801881 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	ff 75 f4             	push   -0xc(%ebp)
  80186f:	e8 f2 f4 ff ff       	call   800d66 <fd2data>
  801874:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	e8 33 fd ff ff       	call   8015b1 <_pipeisclosed>
  80187e:	83 c4 10             	add    $0x10,%esp
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801883:	b8 00 00 00 00       	mov    $0x0,%eax
  801888:	c3                   	ret    

00801889 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80188f:	68 4a 22 80 00       	push   $0x80224a
  801894:	ff 75 0c             	push   0xc(%ebp)
  801897:	e8 cd ee ff ff       	call   800769 <strcpy>
	return 0;
}
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devcons_write>:
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	57                   	push   %edi
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018af:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018b4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018ba:	eb 2e                	jmp    8018ea <devcons_write+0x47>
		m = n - tot;
  8018bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018bf:	29 f3                	sub    %esi,%ebx
  8018c1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018c6:	39 c3                	cmp    %eax,%ebx
  8018c8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	53                   	push   %ebx
  8018cf:	89 f0                	mov    %esi,%eax
  8018d1:	03 45 0c             	add    0xc(%ebp),%eax
  8018d4:	50                   	push   %eax
  8018d5:	57                   	push   %edi
  8018d6:	e8 24 f0 ff ff       	call   8008ff <memmove>
		sys_cputs(buf, m);
  8018db:	83 c4 08             	add    $0x8,%esp
  8018de:	53                   	push   %ebx
  8018df:	57                   	push   %edi
  8018e0:	e8 c4 f1 ff ff       	call   800aa9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018e5:	01 de                	add    %ebx,%esi
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018ed:	72 cd                	jb     8018bc <devcons_write+0x19>
}
  8018ef:	89 f0                	mov    %esi,%eax
  8018f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5f                   	pop    %edi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <devcons_read>:
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801904:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801908:	75 07                	jne    801911 <devcons_read+0x18>
  80190a:	eb 1f                	jmp    80192b <devcons_read+0x32>
		sys_yield();
  80190c:	e8 35 f2 ff ff       	call   800b46 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801911:	e8 b1 f1 ff ff       	call   800ac7 <sys_cgetc>
  801916:	85 c0                	test   %eax,%eax
  801918:	74 f2                	je     80190c <devcons_read+0x13>
	if (c < 0)
  80191a:	78 0f                	js     80192b <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80191c:	83 f8 04             	cmp    $0x4,%eax
  80191f:	74 0c                	je     80192d <devcons_read+0x34>
	*(char*)vbuf = c;
  801921:	8b 55 0c             	mov    0xc(%ebp),%edx
  801924:	88 02                	mov    %al,(%edx)
	return 1;
  801926:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    
		return 0;
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
  801932:	eb f7                	jmp    80192b <devcons_read+0x32>

00801934 <cputchar>:
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
  80193d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801940:	6a 01                	push   $0x1
  801942:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	e8 5e f1 ff ff       	call   800aa9 <sys_cputs>
}
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <getchar>:
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801956:	6a 01                	push   $0x1
  801958:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80195b:	50                   	push   %eax
  80195c:	6a 00                	push   $0x0
  80195e:	e8 ce f6 ff ff       	call   801031 <read>
	if (r < 0)
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	78 06                	js     801970 <getchar+0x20>
	if (r < 1)
  80196a:	74 06                	je     801972 <getchar+0x22>
	return c;
  80196c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    
		return -E_EOF;
  801972:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801977:	eb f7                	jmp    801970 <getchar+0x20>

00801979 <iscons>:
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	ff 75 08             	push   0x8(%ebp)
  801986:	e8 42 f4 ff ff       	call   800dcd <fd_lookup>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 11                	js     8019a3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801995:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80199b:	39 10                	cmp    %edx,(%eax)
  80199d:	0f 94 c0             	sete   %al
  8019a0:	0f b6 c0             	movzbl %al,%eax
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <opencons>:
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ae:	50                   	push   %eax
  8019af:	e8 c9 f3 ff ff       	call   800d7d <fd_alloc>
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 3a                	js     8019f5 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019bb:	83 ec 04             	sub    $0x4,%esp
  8019be:	68 07 04 00 00       	push   $0x407
  8019c3:	ff 75 f4             	push   -0xc(%ebp)
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 98 f1 ff ff       	call   800b65 <sys_page_alloc>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 21                	js     8019f5 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019dd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	50                   	push   %eax
  8019ed:	e8 64 f3 ff ff       	call   800d56 <fd2num>
  8019f2:	83 c4 10             	add    $0x10,%esp
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	56                   	push   %esi
  8019fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a05:	e8 1d f1 ff ff       	call   800b27 <sys_getenvid>
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	ff 75 0c             	push   0xc(%ebp)
  801a10:	ff 75 08             	push   0x8(%ebp)
  801a13:	56                   	push   %esi
  801a14:	50                   	push   %eax
  801a15:	68 58 22 80 00       	push   $0x802258
  801a1a:	e8 70 e7 ff ff       	call   80018f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a1f:	83 c4 18             	add    $0x18,%esp
  801a22:	53                   	push   %ebx
  801a23:	ff 75 10             	push   0x10(%ebp)
  801a26:	e8 13 e7 ff ff       	call   80013e <vcprintf>
	cprintf("\n");
  801a2b:	c7 04 24 43 22 80 00 	movl   $0x802243,(%esp)
  801a32:	e8 58 e7 ff ff       	call   80018f <cprintf>
  801a37:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a3a:	cc                   	int3   
  801a3b:	eb fd                	jmp    801a3a <_panic+0x43>

00801a3d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	8b 75 08             	mov    0x8(%ebp),%esi
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a52:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	50                   	push   %eax
  801a59:	e8 b7 f2 ff ff       	call   800d15 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 f6                	test   %esi,%esi
  801a63:	74 14                	je     801a79 <ipc_recv+0x3c>
  801a65:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 09                	js     801a77 <ipc_recv+0x3a>
  801a6e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a74:	8b 52 74             	mov    0x74(%edx),%edx
  801a77:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a79:	85 db                	test   %ebx,%ebx
  801a7b:	74 14                	je     801a91 <ipc_recv+0x54>
  801a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 09                	js     801a8f <ipc_recv+0x52>
  801a86:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a8c:	8b 52 78             	mov    0x78(%edx),%edx
  801a8f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 08                	js     801a9d <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a95:	a1 00 40 80 00       	mov    0x804000,%eax
  801a9a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801abd:	0f 44 d8             	cmove  %eax,%ebx
  801ac0:	eb 05                	jmp    801ac7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ac2:	e8 7f f0 ff ff       	call   800b46 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801ac7:	ff 75 14             	push   0x14(%ebp)
  801aca:	53                   	push   %ebx
  801acb:	56                   	push   %esi
  801acc:	57                   	push   %edi
  801acd:	e8 20 f2 ff ff       	call   800cf2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad8:	74 e8                	je     801ac2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ada:	85 c0                	test   %eax,%eax
  801adc:	78 08                	js     801ae6 <ipc_send+0x42>
	}while (r<0);

}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ae6:	50                   	push   %eax
  801ae7:	68 7b 22 80 00       	push   $0x80227b
  801aec:	6a 3d                	push   $0x3d
  801aee:	68 8f 22 80 00       	push   $0x80228f
  801af3:	e8 ff fe ff ff       	call   8019f7 <_panic>

00801af8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b03:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b06:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b0c:	8b 52 50             	mov    0x50(%edx),%edx
  801b0f:	39 ca                	cmp    %ecx,%edx
  801b11:	74 11                	je     801b24 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b13:	83 c0 01             	add    $0x1,%eax
  801b16:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1b:	75 e6                	jne    801b03 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b22:	eb 0b                	jmp    801b2f <ipc_find_env+0x37>
			return envs[i].env_id;
  801b24:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b27:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b2c:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	c1 ea 16             	shr    $0x16,%edx
  801b3c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b48:	f6 c1 01             	test   $0x1,%cl
  801b4b:	74 1c                	je     801b69 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b4d:	c1 e8 0c             	shr    $0xc,%eax
  801b50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b57:	a8 01                	test   $0x1,%al
  801b59:	74 0e                	je     801b69 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5b:	c1 e8 0c             	shr    $0xc,%eax
  801b5e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b65:	ef 
  801b66:	0f b7 d2             	movzwl %dx,%edx
}
  801b69:	89 d0                	mov    %edx,%eax
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    
  801b6d:	66 90                	xchg   %ax,%ax
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 1c             	sub    $0x1c,%esp
  801b7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	75 19                	jne    801ba8 <__udivdi3+0x38>
  801b8f:	39 f3                	cmp    %esi,%ebx
  801b91:	76 4d                	jbe    801be0 <__udivdi3+0x70>
  801b93:	31 ff                	xor    %edi,%edi
  801b95:	89 e8                	mov    %ebp,%eax
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	f7 f3                	div    %ebx
  801b9b:	89 fa                	mov    %edi,%edx
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    
  801ba5:	8d 76 00             	lea    0x0(%esi),%esi
  801ba8:	39 f0                	cmp    %esi,%eax
  801baa:	76 14                	jbe    801bc0 <__udivdi3+0x50>
  801bac:	31 ff                	xor    %edi,%edi
  801bae:	31 c0                	xor    %eax,%eax
  801bb0:	89 fa                	mov    %edi,%edx
  801bb2:	83 c4 1c             	add    $0x1c,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	0f bd f8             	bsr    %eax,%edi
  801bc3:	83 f7 1f             	xor    $0x1f,%edi
  801bc6:	75 48                	jne    801c10 <__udivdi3+0xa0>
  801bc8:	39 f0                	cmp    %esi,%eax
  801bca:	72 06                	jb     801bd2 <__udivdi3+0x62>
  801bcc:	31 c0                	xor    %eax,%eax
  801bce:	39 eb                	cmp    %ebp,%ebx
  801bd0:	77 de                	ja     801bb0 <__udivdi3+0x40>
  801bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd7:	eb d7                	jmp    801bb0 <__udivdi3+0x40>
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d9                	mov    %ebx,%ecx
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	75 0b                	jne    801bf1 <__udivdi3+0x81>
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	31 d2                	xor    %edx,%edx
  801bed:	f7 f3                	div    %ebx
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c6                	mov    %eax,%esi
  801bf9:	89 e8                	mov    %ebp,%eax
  801bfb:	89 f7                	mov    %esi,%edi
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	83 c4 1c             	add    $0x1c,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	ba 20 00 00 00       	mov    $0x20,%edx
  801c17:	29 fa                	sub    %edi,%edx
  801c19:	d3 e0                	shl    %cl,%eax
  801c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c1f:	89 d1                	mov    %edx,%ecx
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	d3 e8                	shr    %cl,%eax
  801c25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c29:	09 c1                	or     %eax,%ecx
  801c2b:	89 f0                	mov    %esi,%eax
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e3                	shl    %cl,%ebx
  801c35:	89 d1                	mov    %edx,%ecx
  801c37:	d3 e8                	shr    %cl,%eax
  801c39:	89 f9                	mov    %edi,%ecx
  801c3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c3f:	89 eb                	mov    %ebp,%ebx
  801c41:	d3 e6                	shl    %cl,%esi
  801c43:	89 d1                	mov    %edx,%ecx
  801c45:	d3 eb                	shr    %cl,%ebx
  801c47:	09 f3                	or     %esi,%ebx
  801c49:	89 c6                	mov    %eax,%esi
  801c4b:	89 f2                	mov    %esi,%edx
  801c4d:	89 d8                	mov    %ebx,%eax
  801c4f:	f7 74 24 08          	divl   0x8(%esp)
  801c53:	89 d6                	mov    %edx,%esi
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	f7 64 24 0c          	mull   0xc(%esp)
  801c5b:	39 d6                	cmp    %edx,%esi
  801c5d:	72 19                	jb     801c78 <__udivdi3+0x108>
  801c5f:	89 f9                	mov    %edi,%ecx
  801c61:	d3 e5                	shl    %cl,%ebp
  801c63:	39 c5                	cmp    %eax,%ebp
  801c65:	73 04                	jae    801c6b <__udivdi3+0xfb>
  801c67:	39 d6                	cmp    %edx,%esi
  801c69:	74 0d                	je     801c78 <__udivdi3+0x108>
  801c6b:	89 d8                	mov    %ebx,%eax
  801c6d:	31 ff                	xor    %edi,%edi
  801c6f:	e9 3c ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c78:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c7b:	31 ff                	xor    %edi,%edi
  801c7d:	e9 2e ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	f3 0f 1e fb          	endbr32 
  801c94:	55                   	push   %ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 1c             	sub    $0x1c,%esp
  801c9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ca3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801ca7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801cab:	89 f0                	mov    %esi,%eax
  801cad:	89 da                	mov    %ebx,%edx
  801caf:	85 ff                	test   %edi,%edi
  801cb1:	75 15                	jne    801cc8 <__umoddi3+0x38>
  801cb3:	39 dd                	cmp    %ebx,%ebp
  801cb5:	76 39                	jbe    801cf0 <__umoddi3+0x60>
  801cb7:	f7 f5                	div    %ebp
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	83 c4 1c             	add    $0x1c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	39 df                	cmp    %ebx,%edi
  801cca:	77 f1                	ja     801cbd <__umoddi3+0x2d>
  801ccc:	0f bd cf             	bsr    %edi,%ecx
  801ccf:	83 f1 1f             	xor    $0x1f,%ecx
  801cd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cd6:	75 40                	jne    801d18 <__umoddi3+0x88>
  801cd8:	39 df                	cmp    %ebx,%edi
  801cda:	72 04                	jb     801ce0 <__umoddi3+0x50>
  801cdc:	39 f5                	cmp    %esi,%ebp
  801cde:	77 dd                	ja     801cbd <__umoddi3+0x2d>
  801ce0:	89 da                	mov    %ebx,%edx
  801ce2:	89 f0                	mov    %esi,%eax
  801ce4:	29 e8                	sub    %ebp,%eax
  801ce6:	19 fa                	sbb    %edi,%edx
  801ce8:	eb d3                	jmp    801cbd <__umoddi3+0x2d>
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	89 e9                	mov    %ebp,%ecx
  801cf2:	85 ed                	test   %ebp,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x71>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f5                	div    %ebp
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	89 d8                	mov    %ebx,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f1                	div    %ecx
  801d07:	89 f0                	mov    %esi,%eax
  801d09:	f7 f1                	div    %ecx
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	eb ac                	jmp    801cbd <__umoddi3+0x2d>
  801d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d18:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d1c:	ba 20 00 00 00       	mov    $0x20,%edx
  801d21:	29 c2                	sub    %eax,%edx
  801d23:	89 c1                	mov    %eax,%ecx
  801d25:	89 e8                	mov    %ebp,%eax
  801d27:	d3 e7                	shl    %cl,%edi
  801d29:	89 d1                	mov    %edx,%ecx
  801d2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d2f:	d3 e8                	shr    %cl,%eax
  801d31:	89 c1                	mov    %eax,%ecx
  801d33:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d37:	09 f9                	or     %edi,%ecx
  801d39:	89 df                	mov    %ebx,%edi
  801d3b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d3f:	89 c1                	mov    %eax,%ecx
  801d41:	d3 e5                	shl    %cl,%ebp
  801d43:	89 d1                	mov    %edx,%ecx
  801d45:	d3 ef                	shr    %cl,%edi
  801d47:	89 c1                	mov    %eax,%ecx
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	d3 e3                	shl    %cl,%ebx
  801d4d:	89 d1                	mov    %edx,%ecx
  801d4f:	89 fa                	mov    %edi,%edx
  801d51:	d3 e8                	shr    %cl,%eax
  801d53:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d58:	09 d8                	or     %ebx,%eax
  801d5a:	f7 74 24 08          	divl   0x8(%esp)
  801d5e:	89 d3                	mov    %edx,%ebx
  801d60:	d3 e6                	shl    %cl,%esi
  801d62:	f7 e5                	mul    %ebp
  801d64:	89 c7                	mov    %eax,%edi
  801d66:	89 d1                	mov    %edx,%ecx
  801d68:	39 d3                	cmp    %edx,%ebx
  801d6a:	72 06                	jb     801d72 <__umoddi3+0xe2>
  801d6c:	75 0e                	jne    801d7c <__umoddi3+0xec>
  801d6e:	39 c6                	cmp    %eax,%esi
  801d70:	73 0a                	jae    801d7c <__umoddi3+0xec>
  801d72:	29 e8                	sub    %ebp,%eax
  801d74:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d78:	89 d1                	mov    %edx,%ecx
  801d7a:	89 c7                	mov    %eax,%edi
  801d7c:	89 f5                	mov    %esi,%ebp
  801d7e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d82:	29 fd                	sub    %edi,%ebp
  801d84:	19 cb                	sbb    %ecx,%ebx
  801d86:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d8b:	89 d8                	mov    %ebx,%eax
  801d8d:	d3 e0                	shl    %cl,%eax
  801d8f:	89 f1                	mov    %esi,%ecx
  801d91:	d3 ed                	shr    %cl,%ebp
  801d93:	d3 eb                	shr    %cl,%ebx
  801d95:	09 e8                	or     %ebp,%eax
  801d97:	89 da                	mov    %ebx,%edx
  801d99:	83 c4 1c             	add    $0x1c,%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5f                   	pop    %edi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    
