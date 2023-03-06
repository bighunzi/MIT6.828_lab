
obj/user/spin：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 12 80 00       	push   $0x8012c0
  80003f:	e8 5e 01 00 00       	call   8001a2 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 dc 0d 00 00       	call   800e25 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 13 80 00       	push   $0x801338
  800058:	e8 45 01 00 00       	call   8001a2 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 12 80 00       	push   $0x8012e8
  80006c:	e8 31 01 00 00       	call   8001a2 <cprintf>
	sys_yield();
  800071:	e8 e3 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800076:	e8 de 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80007b:	e8 d9 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800080:	e8 d4 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800085:	e8 cf 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008a:	e8 ca 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008f:	e8 c5 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800094:	e8 c0 0a 00 00       	call   800b59 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 13 80 00 	movl   $0x801310,(%esp)
  8000a0:	e8 fd 00 00 00       	call   8001a2 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 4c 0a 00 00       	call   800af9 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 75 0a 00 00       	call   800b3a <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 f1 09 00 00       	call   800af9 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	74 09                	je     800135 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80012c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800133:	c9                   	leave  
  800134:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 76 09 00 00       	call   800abc <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	eb db                	jmp    80012c <putch+0x1f>

00800151 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	push   0xc(%ebp)
  800171:	ff 75 08             	push   0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	68 0d 01 80 00       	push   $0x80010d
  800180:	e8 14 01 00 00       	call   800299 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 22 09 00 00       	call   800abc <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	50                   	push   %eax
  8001ac:	ff 75 08             	push   0x8(%ebp)
  8001af:	e8 9d ff ff ff       	call   800151 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	89 c7                	mov    %eax,%edi
  8001c1:	89 d6                	mov    %edx,%esi
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c9:	89 d1                	mov    %edx,%ecx
  8001cb:	89 c2                	mov    %eax,%edx
  8001cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e3:	39 c2                	cmp    %eax,%edx
  8001e5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e8:	72 3e                	jb     800228 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	ff 75 18             	push   0x18(%ebp)
  8001f0:	83 eb 01             	sub    $0x1,%ebx
  8001f3:	53                   	push   %ebx
  8001f4:	50                   	push   %eax
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	ff 75 e4             	push   -0x1c(%ebp)
  8001fb:	ff 75 e0             	push   -0x20(%ebp)
  8001fe:	ff 75 dc             	push   -0x24(%ebp)
  800201:	ff 75 d8             	push   -0x28(%ebp)
  800204:	e8 77 0e 00 00       	call   801080 <__udivdi3>
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	89 f2                	mov    %esi,%edx
  800210:	89 f8                	mov    %edi,%eax
  800212:	e8 9f ff ff ff       	call   8001b6 <printnum>
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	eb 13                	jmp    80022f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	ff 75 18             	push   0x18(%ebp)
  800223:	ff d7                	call   *%edi
  800225:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	7f ed                	jg     80021c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	83 ec 04             	sub    $0x4,%esp
  800236:	ff 75 e4             	push   -0x1c(%ebp)
  800239:	ff 75 e0             	push   -0x20(%ebp)
  80023c:	ff 75 dc             	push   -0x24(%ebp)
  80023f:	ff 75 d8             	push   -0x28(%ebp)
  800242:	e8 59 0f 00 00       	call   8011a0 <__umoddi3>
  800247:	83 c4 14             	add    $0x14,%esp
  80024a:	0f be 80 60 13 80 00 	movsbl 0x801360(%eax),%eax
  800251:	50                   	push   %eax
  800252:	ff d7                	call   *%edi
}
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800265:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	3b 50 04             	cmp    0x4(%eax),%edx
  80026e:	73 0a                	jae    80027a <sprintputch+0x1b>
		*b->buf++ = ch;
  800270:	8d 4a 01             	lea    0x1(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	88 02                	mov    %al,(%edx)
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <printfmt>:
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800282:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 10             	push   0x10(%ebp)
  800289:	ff 75 0c             	push   0xc(%ebp)
  80028c:	ff 75 08             	push   0x8(%ebp)
  80028f:	e8 05 00 00 00       	call   800299 <vprintfmt>
}
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <vprintfmt>:
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 3c             	sub    $0x3c,%esp
  8002a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ab:	eb 0a                	jmp    8002b7 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	50                   	push   %eax
  8002b2:	ff d6                	call   *%esi
  8002b4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	74 0c                	je     8002cf <vprintfmt+0x36>
			if (ch == '\0')
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	75 e6                	jne    8002ad <vprintfmt+0x14>
}
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    
		padc = ' ';
  8002cf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8d 47 01             	lea    0x1(%edi),%eax
  8002f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f3:	0f b6 17             	movzbl (%edi),%edx
  8002f6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 bb 03 00 00    	ja     8006bc <vprintfmt+0x423>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 20 14 80 00 	jmp    *0x801420(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800312:	eb d9                	jmp    8002ed <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80031b:	eb d0                	jmp    8002ed <vprintfmt+0x54>
  80031d:	0f b6 d2             	movzbl %dl,%edx
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80032b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800332:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800335:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800338:	83 f9 09             	cmp    $0x9,%ecx
  80033b:	77 55                	ja     800392 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80033d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800340:	eb e9                	jmp    80032b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800342:	8b 45 14             	mov    0x14(%ebp),%eax
  800345:	8b 00                	mov    (%eax),%eax
  800347:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 40 04             	lea    0x4(%eax),%eax
  800350:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800356:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035a:	79 91                	jns    8002ed <vprintfmt+0x54>
				width = precision, precision = -1;
  80035c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800362:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800369:	eb 82                	jmp    8002ed <vprintfmt+0x54>
  80036b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80036e:	85 d2                	test   %edx,%edx
  800370:	b8 00 00 00 00       	mov    $0x0,%eax
  800375:	0f 49 c2             	cmovns %edx,%eax
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037e:	e9 6a ff ff ff       	jmp    8002ed <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800386:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80038d:	e9 5b ff ff ff       	jmp    8002ed <vprintfmt+0x54>
  800392:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	eb bc                	jmp    800356 <vprintfmt+0xbd>
			lflag++;
  80039a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a0:	e9 48 ff ff ff       	jmp    8002ed <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 78 04             	lea    0x4(%eax),%edi
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	53                   	push   %ebx
  8003af:	ff 30                	push   (%eax)
  8003b1:	ff d6                	call   *%esi
			break;
  8003b3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b9:	e9 9d 02 00 00       	jmp    80065b <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 78 04             	lea    0x4(%eax),%edi
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	89 d0                	mov    %edx,%eax
  8003c8:	f7 d8                	neg    %eax
  8003ca:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 08             	cmp    $0x8,%eax
  8003d0:	7f 23                	jg     8003f5 <vprintfmt+0x15c>
  8003d2:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	74 18                	je     8003f5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003dd:	52                   	push   %edx
  8003de:	68 81 13 80 00       	push   $0x801381
  8003e3:	53                   	push   %ebx
  8003e4:	56                   	push   %esi
  8003e5:	e8 92 fe ff ff       	call   80027c <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f0:	e9 66 02 00 00       	jmp    80065b <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	50                   	push   %eax
  8003f6:	68 78 13 80 00       	push   $0x801378
  8003fb:	53                   	push   %ebx
  8003fc:	56                   	push   %esi
  8003fd:	e8 7a fe ff ff       	call   80027c <printfmt>
  800402:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800405:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800408:	e9 4e 02 00 00       	jmp    80065b <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	83 c0 04             	add    $0x4,%eax
  800413:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80041b:	85 d2                	test   %edx,%edx
  80041d:	b8 71 13 80 00       	mov    $0x801371,%eax
  800422:	0f 45 c2             	cmovne %edx,%eax
  800425:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	7e 06                	jle    800434 <vprintfmt+0x19b>
  80042e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800432:	75 0d                	jne    800441 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800434:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800437:	89 c7                	mov    %eax,%edi
  800439:	03 45 e0             	add    -0x20(%ebp),%eax
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043f:	eb 55                	jmp    800496 <vprintfmt+0x1fd>
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	ff 75 d8             	push   -0x28(%ebp)
  800447:	ff 75 cc             	push   -0x34(%ebp)
  80044a:	e8 0a 03 00 00       	call   800759 <strnlen>
  80044f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800452:	29 c1                	sub    %eax,%ecx
  800454:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80045c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	eb 0f                	jmp    800474 <vprintfmt+0x1db>
					putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	53                   	push   %ebx
  800469:	ff 75 e0             	push   -0x20(%ebp)
  80046c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	83 ef 01             	sub    $0x1,%edi
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	85 ff                	test   %edi,%edi
  800476:	7f ed                	jg     800465 <vprintfmt+0x1cc>
  800478:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	0f 49 c2             	cmovns %edx,%eax
  800485:	29 c2                	sub    %eax,%edx
  800487:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048a:	eb a8                	jmp    800434 <vprintfmt+0x19b>
					putch(ch, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	53                   	push   %ebx
  800490:	52                   	push   %edx
  800491:	ff d6                	call   *%esi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800499:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049b:	83 c7 01             	add    $0x1,%edi
  80049e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a2:	0f be d0             	movsbl %al,%edx
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 4b                	je     8004f4 <vprintfmt+0x25b>
  8004a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ad:	78 06                	js     8004b5 <vprintfmt+0x21c>
  8004af:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b3:	78 1e                	js     8004d3 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b9:	74 d1                	je     80048c <vprintfmt+0x1f3>
  8004bb:	0f be c0             	movsbl %al,%eax
  8004be:	83 e8 20             	sub    $0x20,%eax
  8004c1:	83 f8 5e             	cmp    $0x5e,%eax
  8004c4:	76 c6                	jbe    80048c <vprintfmt+0x1f3>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	6a 3f                	push   $0x3f
  8004cc:	ff d6                	call   *%esi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	eb c3                	jmp    800496 <vprintfmt+0x1fd>
  8004d3:	89 cf                	mov    %ecx,%edi
  8004d5:	eb 0e                	jmp    8004e5 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	6a 20                	push   $0x20
  8004dd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004df:	83 ef 01             	sub    $0x1,%edi
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	7f ee                	jg     8004d7 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ef:	e9 67 01 00 00       	jmp    80065b <vprintfmt+0x3c2>
  8004f4:	89 cf                	mov    %ecx,%edi
  8004f6:	eb ed                	jmp    8004e5 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004f8:	83 f9 01             	cmp    $0x1,%ecx
  8004fb:	7f 1b                	jg     800518 <vprintfmt+0x27f>
	else if (lflag)
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	74 63                	je     800564 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800509:	99                   	cltd   
  80050a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 40 04             	lea    0x4(%eax),%eax
  800513:	89 45 14             	mov    %eax,0x14(%ebp)
  800516:	eb 17                	jmp    80052f <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8b 50 04             	mov    0x4(%eax),%edx
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 40 08             	lea    0x8(%eax),%eax
  80052c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800532:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800535:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80053a:	85 c9                	test   %ecx,%ecx
  80053c:	0f 89 ff 00 00 00    	jns    800641 <vprintfmt+0x3a8>
				putch('-', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 2d                	push   $0x2d
  800548:	ff d6                	call   *%esi
				num = -(long long) num;
  80054a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800550:	f7 da                	neg    %edx
  800552:	83 d1 00             	adc    $0x0,%ecx
  800555:	f7 d9                	neg    %ecx
  800557:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80055f:	e9 dd 00 00 00       	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	99                   	cltd   
  80056d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
  800579:	eb b4                	jmp    80052f <vprintfmt+0x296>
	if (lflag >= 2)
  80057b:	83 f9 01             	cmp    $0x1,%ecx
  80057e:	7f 1e                	jg     80059e <vprintfmt+0x305>
	else if (lflag)
  800580:	85 c9                	test   %ecx,%ecx
  800582:	74 32                	je     8005b6 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 10                	mov    (%eax),%edx
  800589:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058e:	8d 40 04             	lea    0x4(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800594:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800599:	e9 a3 00 00 00       	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ac:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005b1:	e9 8b 00 00 00       	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005cb:	eb 74                	jmp    800641 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7f 1b                	jg     8005ed <vprintfmt+0x354>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	74 2c                	je     800602 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005eb:	eb 54                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f5:	8d 40 08             	lea    0x8(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005fb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800600:	eb 3f                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800612:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800617:	eb 28                	jmp    800641 <vprintfmt+0x3a8>
			putch('0', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 30                	push   $0x30
  80061f:	ff d6                	call   *%esi
			putch('x', putdat);
  800621:	83 c4 08             	add    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 78                	push   $0x78
  800627:	ff d6                	call   *%esi
			num = (unsigned long long)
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800633:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	ff 75 e0             	push   -0x20(%ebp)
  80064c:	57                   	push   %edi
  80064d:	51                   	push   %ecx
  80064e:	52                   	push   %edx
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 5e fb ff ff       	call   8001b6 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065e:	e9 54 fc ff ff       	jmp    8002b7 <vprintfmt+0x1e>
	if (lflag >= 2)
  800663:	83 f9 01             	cmp    $0x1,%ecx
  800666:	7f 1b                	jg     800683 <vprintfmt+0x3ea>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	74 2c                	je     800698 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800681:	eb be                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800691:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800696:	eb a9                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006ad:	eb 92                	jmp    800641 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			break;
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 9f                	jmp    80065b <vprintfmt+0x3c2>
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 f8                	mov    %edi,%eax
  8006c9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006cd:	74 05                	je     8006d4 <vprintfmt+0x43b>
  8006cf:	83 e8 01             	sub    $0x1,%eax
  8006d2:	eb f5                	jmp    8006c9 <vprintfmt+0x430>
  8006d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d7:	eb 82                	jmp    80065b <vprintfmt+0x3c2>

008006d9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 26                	je     800720 <vsnprintf+0x47>
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	7e 22                	jle    800720 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fe:	ff 75 14             	push   0x14(%ebp)
  800701:	ff 75 10             	push   0x10(%ebp)
  800704:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800707:	50                   	push   %eax
  800708:	68 5f 02 80 00       	push   $0x80025f
  80070d:	e8 87 fb ff ff       	call   800299 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071b:	83 c4 10             	add    $0x10,%esp
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    
		return -E_INVAL;
  800720:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800725:	eb f7                	jmp    80071e <vsnprintf+0x45>

00800727 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800730:	50                   	push   %eax
  800731:	ff 75 10             	push   0x10(%ebp)
  800734:	ff 75 0c             	push   0xc(%ebp)
  800737:	ff 75 08             	push   0x8(%ebp)
  80073a:	e8 9a ff ff ff       	call   8006d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 03                	jmp    800751 <strlen+0x10>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f7                	jne    80074e <strlen+0xd>
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 03                	jmp    80076c <strnlen+0x13>
		n++;
  800769:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 d0                	cmp    %edx,%eax
  80076e:	74 08                	je     800778 <strnlen+0x1f>
  800770:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800774:	75 f3                	jne    800769 <strnlen+0x10>
  800776:	89 c2                	mov    %eax,%edx
	return n;
}
  800778:	89 d0                	mov    %edx,%eax
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80078f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800792:	83 c0 01             	add    $0x1,%eax
  800795:	84 d2                	test   %dl,%dl
  800797:	75 f2                	jne    80078b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800799:	89 c8                	mov    %ecx,%eax
  80079b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 10             	sub    $0x10,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 91 ff ff ff       	call   800741 <strlen>
  8007b0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	push   0xc(%ebp)
  8007b6:	01 d8                	add    %ebx,%eax
  8007b8:	50                   	push   %eax
  8007b9:	e8 be ff ff ff       	call   80077c <strcpy>
	return dst;
}
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 f3                	mov    %esi,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	eb 0f                	jmp    8007e8 <strncpy+0x23>
		*dst++ = *src;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	0f b6 0a             	movzbl (%edx),%ecx
  8007df:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 f9 01             	cmp    $0x1,%cl
  8007e5:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007e8:	39 d8                	cmp    %ebx,%eax
  8007ea:	75 ed                	jne    8007d9 <strncpy+0x14>
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800800:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	74 21                	je     800827 <strlcpy+0x35>
  800806:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 09                	jmp    800817 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800817:	39 c2                	cmp    %eax,%edx
  800819:	74 09                	je     800824 <strlcpy+0x32>
  80081b:	0f b6 19             	movzbl (%ecx),%ebx
  80081e:	84 db                	test   %bl,%bl
  800820:	75 ec                	jne    80080e <strlcpy+0x1c>
  800822:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800824:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800827:	29 f0                	sub    %esi,%eax
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800836:	eb 06                	jmp    80083e <strcmp+0x11>
		p++, q++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x1c>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	74 ef                	je     800838 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 c3                	mov    %eax,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800862:	eb 06                	jmp    80086a <strncmp+0x17>
		n--, p++, q++;
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80086a:	39 d8                	cmp    %ebx,%eax
  80086c:	74 18                	je     800886 <strncmp+0x33>
  80086e:	0f b6 08             	movzbl (%eax),%ecx
  800871:	84 c9                	test   %cl,%cl
  800873:	74 04                	je     800879 <strncmp+0x26>
  800875:	3a 0a                	cmp    (%edx),%cl
  800877:	74 eb                	je     800864 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 00             	movzbl (%eax),%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb f4                	jmp    800881 <strncmp+0x2e>

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 03                	jmp    80089c <strchr+0xf>
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	0f b6 10             	movzbl (%eax),%edx
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	74 06                	je     8008a9 <strchr+0x1c>
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	75 f2                	jne    800899 <strchr+0xc>
  8008a7:	eb 05                	jmp    8008ae <strchr+0x21>
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 09                	je     8008ca <strfind+0x1a>
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 05                	je     8008ca <strfind+0x1a>
	for (; *s; s++)
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	eb f0                	jmp    8008ba <strfind+0xa>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d8:	85 c9                	test   %ecx,%ecx
  8008da:	74 2f                	je     80090b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dc:	89 f8                	mov    %edi,%eax
  8008de:	09 c8                	or     %ecx,%eax
  8008e0:	a8 03                	test   $0x3,%al
  8008e2:	75 21                	jne    800905 <memset+0x39>
		c &= 0xFF;
  8008e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	c1 e0 08             	shl    $0x8,%eax
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 18             	shl    $0x18,%ebx
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	c1 e6 10             	shl    $0x10,%esi
  8008f7:	09 f3                	or     %esi,%ebx
  8008f9:	09 da                	or     %ebx,%edx
  8008fb:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 32                	jae    800956 <memmove+0x44>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 c2                	cmp    %eax,%edx
  800929:	76 2b                	jbe    800956 <memmove+0x44>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	09 ce                	or     %ecx,%esi
  800934:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093a:	75 0e                	jne    80094a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 1a                	jmp    800970 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 f2                	mov    %esi,%edx
  800958:	09 c2                	or     %eax,%edx
  80095a:	09 ca                	or     %ecx,%edx
  80095c:	f6 c2 03             	test   $0x3,%dl
  80095f:	75 0a                	jne    80096b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800961:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 05                	jmp    800970 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80096b:	89 c7                	mov    %eax,%edi
  80096d:	fc                   	cld    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80097a:	ff 75 10             	push   0x10(%ebp)
  80097d:	ff 75 0c             	push   0xc(%ebp)
  800980:	ff 75 08             	push   0x8(%ebp)
  800983:	e8 8a ff ff ff       	call   800912 <memmove>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c6                	mov    %eax,%esi
  800997:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	eb 06                	jmp    8009a2 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009a2:	39 f0                	cmp    %esi,%eax
  8009a4:	74 14                	je     8009ba <memcmp+0x30>
		if (*s1 != *s2)
  8009a6:	0f b6 08             	movzbl (%eax),%ecx
  8009a9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ac:	38 d9                	cmp    %bl,%cl
  8009ae:	74 ec                	je     80099c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009b0:	0f b6 c1             	movzbl %cl,%eax
  8009b3:	0f b6 db             	movzbl %bl,%ebx
  8009b6:	29 d8                	sub    %ebx,%eax
  8009b8:	eb 05                	jmp    8009bf <memcmp+0x35>
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d1:	eb 03                	jmp    8009d6 <memfind+0x13>
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	73 04                	jae    8009de <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	38 08                	cmp    %cl,(%eax)
  8009dc:	75 f5                	jne    8009d3 <memfind+0x10>
			break;
	return (void *) s;
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	eb 03                	jmp    8009f1 <strtol+0x11>
		s++;
  8009ee:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009f1:	0f b6 02             	movzbl (%edx),%eax
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f6                	je     8009ee <strtol+0xe>
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f2                	je     8009ee <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fc:	3c 2b                	cmp    $0x2b,%al
  8009fe:	74 2a                	je     800a2a <strtol+0x4a>
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a05:	3c 2d                	cmp    $0x2d,%al
  800a07:	74 2b                	je     800a34 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a09:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0f:	75 0f                	jne    800a20 <strtol+0x40>
  800a11:	80 3a 30             	cmpb   $0x30,(%edx)
  800a14:	74 28                	je     800a3e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a16:	85 db                	test   %ebx,%ebx
  800a18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a1d:	0f 44 d8             	cmove  %eax,%ebx
  800a20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a25:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a28:	eb 46                	jmp    800a70 <strtol+0x90>
		s++;
  800a2a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a32:	eb d5                	jmp    800a09 <strtol+0x29>
		s++, neg = 1;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3c:	eb cb                	jmp    800a09 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a42:	74 0e                	je     800a52 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	75 d8                	jne    800a20 <strtol+0x40>
		s++, base = 8;
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a50:	eb ce                	jmp    800a20 <strtol+0x40>
		s += 2, base = 16;
  800a52:	83 c2 02             	add    $0x2,%edx
  800a55:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5a:	eb c4                	jmp    800a20 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a5c:	0f be c0             	movsbl %al,%eax
  800a5f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a62:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a65:	7d 3a                	jge    800aa1 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a67:	83 c2 01             	add    $0x1,%edx
  800a6a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a6e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 02             	movzbl (%edx),%eax
  800a73:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	76 df                	jbe    800a5c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a7d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 08                	ja     800a8f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a87:	0f be c0             	movsbl %al,%eax
  800a8a:	83 e8 57             	sub    $0x57,%eax
  800a8d:	eb d3                	jmp    800a62 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a8f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 08                	ja     800aa1 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a99:	0f be c0             	movsbl %al,%eax
  800a9c:	83 e8 37             	sub    $0x37,%eax
  800a9f:	eb c1                	jmp    800a62 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa5:	74 05                	je     800aac <strtol+0xcc>
		*endptr = (char *) s;
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800aac:	89 c8                	mov    %ecx,%eax
  800aae:	f7 d8                	neg    %eax
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c8             	cmovne %eax,%ecx
}
  800ab5:	89 c8                	mov    %ecx,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cgetc>:

int
sys_cgetc(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b07:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0f:	89 cb                	mov    %ecx,%ebx
  800b11:	89 cf                	mov    %ecx,%edi
  800b13:	89 ce                	mov    %ecx,%esi
  800b15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7f 08                	jg     800b23 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 a4 15 80 00       	push   $0x8015a4
  800b2e:	6a 2a                	push   $0x2a
  800b30:	68 c1 15 80 00       	push   $0x8015c1
  800b35:	e8 59 04 00 00       	call   800f93 <_panic>

00800b3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_yield>:

void
sys_yield(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b81:	be 00 00 00 00       	mov    $0x0,%esi
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	89 f7                	mov    %esi,%edi
  800b96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7f 08                	jg     800ba4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 a4 15 80 00       	push   $0x8015a4
  800baf:	6a 2a                	push   $0x2a
  800bb1:	68 c1 15 80 00       	push   $0x8015c1
  800bb6:	e8 d8 03 00 00       	call   800f93 <_panic>

00800bbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 a4 15 80 00       	push   $0x8015a4
  800bf1:	6a 2a                	push   $0x2a
  800bf3:	68 c1 15 80 00       	push   $0x8015c1
  800bf8:	e8 96 03 00 00       	call   800f93 <_panic>

00800bfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	89 df                	mov    %ebx,%edi
  800c18:	89 de                	mov    %ebx,%esi
  800c1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7f 08                	jg     800c28 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 a4 15 80 00       	push   $0x8015a4
  800c33:	6a 2a                	push   $0x2a
  800c35:	68 c1 15 80 00       	push   $0x8015c1
  800c3a:	e8 54 03 00 00       	call   800f93 <_panic>

00800c3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7f 08                	jg     800c6a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 a4 15 80 00       	push   $0x8015a4
  800c75:	6a 2a                	push   $0x2a
  800c77:	68 c1 15 80 00       	push   $0x8015c1
  800c7c:	e8 12 03 00 00       	call   800f93 <_panic>

00800c81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 a4 15 80 00       	push   $0x8015a4
  800cb7:	6a 2a                	push   $0x2a
  800cb9:	68 c1 15 80 00       	push   $0x8015c1
  800cbe:	e8 d0 02 00 00       	call   800f93 <_panic>

00800cc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	89 cb                	mov    %ecx,%ebx
  800cfe:	89 cf                	mov    %ecx,%edi
  800d00:	89 ce                	mov    %ecx,%esi
  800d02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 0c                	push   $0xc
  800d16:	68 a4 15 80 00       	push   $0x8015a4
  800d1b:	6a 2a                	push   $0x2a
  800d1d:	68 c1 15 80 00       	push   $0x8015c1
  800d22:	e8 6c 02 00 00       	call   800f93 <_panic>

00800d27 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d2f:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800d31:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d35:	0f 84 8e 00 00 00    	je     800dc9 <pgfault+0xa2>
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	c1 e8 0c             	shr    $0xc,%eax
  800d40:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d47:	f6 c4 08             	test   $0x8,%ah
  800d4a:	74 7d                	je     800dc9 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800d4c:	e8 e9 fd ff ff       	call   800b3a <sys_getenvid>
  800d51:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	6a 07                	push   $0x7
  800d58:	68 00 f0 7f 00       	push   $0x7ff000
  800d5d:	50                   	push   %eax
  800d5e:	e8 15 fe ff ff       	call   800b78 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800d63:	83 c4 10             	add    $0x10,%esp
  800d66:	85 c0                	test   %eax,%eax
  800d68:	78 73                	js     800ddd <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800d6a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800d70:	83 ec 04             	sub    $0x4,%esp
  800d73:	68 00 10 00 00       	push   $0x1000
  800d78:	56                   	push   %esi
  800d79:	68 00 f0 7f 00       	push   $0x7ff000
  800d7e:	e8 8f fb ff ff       	call   800912 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800d83:	83 c4 08             	add    $0x8,%esp
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	e8 70 fe ff ff       	call   800bfd <sys_page_unmap>
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	85 c0                	test   %eax,%eax
  800d92:	78 5b                	js     800def <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	6a 07                	push   $0x7
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	68 00 f0 7f 00       	push   $0x7ff000
  800da0:	53                   	push   %ebx
  800da1:	e8 15 fe ff ff       	call   800bbb <sys_page_map>
  800da6:	83 c4 20             	add    $0x20,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	78 54                	js     800e01 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800dad:	83 ec 08             	sub    $0x8,%esp
  800db0:	68 00 f0 7f 00       	push   $0x7ff000
  800db5:	53                   	push   %ebx
  800db6:	e8 42 fe ff ff       	call   800bfd <sys_page_unmap>
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	78 51                	js     800e13 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800dc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	68 d0 15 80 00       	push   $0x8015d0
  800dd1:	6a 1d                	push   $0x1d
  800dd3:	68 4c 16 80 00       	push   $0x80164c
  800dd8:	e8 b6 01 00 00       	call   800f93 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800ddd:	50                   	push   %eax
  800dde:	68 08 16 80 00       	push   $0x801608
  800de3:	6a 29                	push   $0x29
  800de5:	68 4c 16 80 00       	push   $0x80164c
  800dea:	e8 a4 01 00 00       	call   800f93 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800def:	50                   	push   %eax
  800df0:	68 2c 16 80 00       	push   $0x80162c
  800df5:	6a 2e                	push   $0x2e
  800df7:	68 4c 16 80 00       	push   $0x80164c
  800dfc:	e8 92 01 00 00       	call   800f93 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e01:	50                   	push   %eax
  800e02:	68 57 16 80 00       	push   $0x801657
  800e07:	6a 30                	push   $0x30
  800e09:	68 4c 16 80 00       	push   $0x80164c
  800e0e:	e8 80 01 00 00       	call   800f93 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e13:	50                   	push   %eax
  800e14:	68 2c 16 80 00       	push   $0x80162c
  800e19:	6a 32                	push   $0x32
  800e1b:	68 4c 16 80 00       	push   $0x80164c
  800e20:	e8 6e 01 00 00       	call   800f93 <_panic>

00800e25 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800e2e:	68 27 0d 80 00       	push   $0x800d27
  800e33:	e8 a1 01 00 00       	call   800fd9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e38:	b8 07 00 00 00       	mov    $0x7,%eax
  800e3d:	cd 30                	int    $0x30
  800e3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	78 2a                	js     800e73 <fork+0x4e>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800e49:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800e4e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e52:	75 5e                	jne    800eb2 <fork+0x8d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e54:	e8 e1 fc ff ff       	call   800b3a <sys_getenvid>
  800e59:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e5e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e61:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e66:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e6e:	e9 b0 00 00 00       	jmp    800f23 <fork+0xfe>
		panic("sys_exofork: %e", envid);
  800e73:	50                   	push   %eax
  800e74:	68 75 16 80 00       	push   $0x801675
  800e79:	6a 75                	push   $0x75
  800e7b:	68 4c 16 80 00       	push   $0x80164c
  800e80:	e8 0e 01 00 00       	call   800f93 <_panic>
	r=sys_page_map(this_envid, va, this_envid, va, perm);//一定要用系统调用， 因为权限！！
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	56                   	push   %esi
  800e89:	57                   	push   %edi
  800e8a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800e8d:	51                   	push   %ecx
  800e8e:	57                   	push   %edi
  800e8f:	51                   	push   %ecx
  800e90:	e8 26 fd ff ff       	call   800bbb <sys_page_map>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
		    // dup page to child
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800e95:	83 c4 20             	add    $0x20,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	0f 88 8b 00 00 00    	js     800f2b <fork+0x106>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ea0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ea6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800eac:	0f 84 83 00 00 00    	je     800f35 <fork+0x110>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800eb2:	89 d8                	mov    %ebx,%eax
  800eb4:	c1 e8 16             	shr    $0x16,%eax
  800eb7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ebe:	a8 01                	test   $0x1,%al
  800ec0:	74 de                	je     800ea0 <fork+0x7b>
  800ec2:	89 de                	mov    %ebx,%esi
  800ec4:	c1 ee 0c             	shr    $0xc,%esi
  800ec7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ece:	a8 01                	test   $0x1,%al
  800ed0:	74 ce                	je     800ea0 <fork+0x7b>
	envid_t this_envid = sys_getenvid();//父进程号
  800ed2:	e8 63 fc ff ff       	call   800b3a <sys_getenvid>
  800ed7:	89 c1                	mov    %eax,%ecx
	void * va = (void *)(pn * PGSIZE);
  800ed9:	89 f7                	mov    %esi,%edi
  800edb:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & 0xFFF;
  800ede:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
		perm &= ~PTE_W;
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	25 fd 0f 00 00       	and    $0xffd,%eax
  800eec:	80 cc 08             	or     $0x8,%ah
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
  800ef7:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800efd:	0f 45 f0             	cmovne %eax,%esi
	perm&=PTE_SYSCALL; // 写sys_page_map函数时 perm必须要达成的要求
  800f00:	81 e6 07 0e 00 00    	and    $0xe07,%esi
	r=sys_page_map(this_envid, va, envid, va, perm);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	56                   	push   %esi
  800f0a:	57                   	push   %edi
  800f0b:	ff 75 e0             	push   -0x20(%ebp)
  800f0e:	57                   	push   %edi
  800f0f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800f12:	51                   	push   %ecx
  800f13:	e8 a3 fc ff ff       	call   800bbb <sys_page_map>
	if(r<0) return r;
  800f18:	83 c4 20             	add    $0x20,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	0f 89 62 ff ff ff    	jns    800e85 <fork+0x60>
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	0f 4f c2             	cmovg  %edx,%eax
  800f33:	eb ee                	jmp    800f23 <fork+0xfe>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	6a 07                	push   $0x7
  800f3a:	68 00 f0 bf ee       	push   $0xeebff000
  800f3f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800f42:	57                   	push   %edi
  800f43:	e8 30 fc ff ff       	call   800b78 <sys_page_alloc>
	if(r<0) return r;
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 d4                	js     800f23 <fork+0xfe>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	68 4f 10 80 00       	push   $0x80104f
  800f57:	57                   	push   %edi
  800f58:	e8 24 fd ff ff       	call   800c81 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 bf                	js     800f23 <fork+0xfe>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	6a 02                	push   $0x2
  800f69:	57                   	push   %edi
  800f6a:	e8 d0 fc ff ff       	call   800c3f <sys_env_set_status>
	if(r<0) return r;
  800f6f:	83 c4 10             	add    $0x10,%esp
	return envid;
  800f72:	85 c0                	test   %eax,%eax
  800f74:	0f 49 c7             	cmovns %edi,%eax
  800f77:	eb aa                	jmp    800f23 <fork+0xfe>

00800f79 <sfork>:

// Challenge!
int
sfork(void)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f7f:	68 85 16 80 00       	push   $0x801685
  800f84:	68 9e 00 00 00       	push   $0x9e
  800f89:	68 4c 16 80 00       	push   $0x80164c
  800f8e:	e8 00 00 00 00       	call   800f93 <_panic>

00800f93 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f98:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f9b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fa1:	e8 94 fb ff ff       	call   800b3a <sys_getenvid>
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	ff 75 0c             	push   0xc(%ebp)
  800fac:	ff 75 08             	push   0x8(%ebp)
  800faf:	56                   	push   %esi
  800fb0:	50                   	push   %eax
  800fb1:	68 9c 16 80 00       	push   $0x80169c
  800fb6:	e8 e7 f1 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fbb:	83 c4 18             	add    $0x18,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	ff 75 10             	push   0x10(%ebp)
  800fc2:	e8 8a f1 ff ff       	call   800151 <vcprintf>
	cprintf("\n");
  800fc7:	c7 04 24 54 13 80 00 	movl   $0x801354,(%esp)
  800fce:	e8 cf f1 ff ff       	call   8001a2 <cprintf>
  800fd3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fd6:	cc                   	int3   
  800fd7:	eb fd                	jmp    800fd6 <_panic+0x43>

00800fd9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800fdf:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fe6:	74 0a                	je     800ff2 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800ff2:	e8 43 fb ff ff       	call   800b3a <sys_getenvid>
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 07 0e 00 00       	push   $0xe07
  800fff:	68 00 f0 bf ee       	push   $0xeebff000
  801004:	50                   	push   %eax
  801005:	e8 6e fb ff ff       	call   800b78 <sys_page_alloc>
		if (r < 0) {
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 2c                	js     80103d <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801011:	e8 24 fb ff ff       	call   800b3a <sys_getenvid>
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	68 4f 10 80 00       	push   $0x80104f
  80101e:	50                   	push   %eax
  80101f:	e8 5d fc ff ff       	call   800c81 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 bd                	jns    800fe8 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80102b:	50                   	push   %eax
  80102c:	68 00 17 80 00       	push   $0x801700
  801031:	6a 28                	push   $0x28
  801033:	68 36 17 80 00       	push   $0x801736
  801038:	e8 56 ff ff ff       	call   800f93 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80103d:	50                   	push   %eax
  80103e:	68 c0 16 80 00       	push   $0x8016c0
  801043:	6a 23                	push   $0x23
  801045:	68 36 17 80 00       	push   $0x801736
  80104a:	e8 44 ff ff ff       	call   800f93 <_panic>

0080104f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80104f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801050:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801055:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801057:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80105a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80105e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801061:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801065:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801069:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80106b:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80106e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80106f:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801072:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801073:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801074:	c3                   	ret    
  801075:	66 90                	xchg   %ax,%ax
  801077:	66 90                	xchg   %ax,%ax
  801079:	66 90                	xchg   %ax,%ax
  80107b:	66 90                	xchg   %ax,%ax
  80107d:	66 90                	xchg   %ax,%ax
  80107f:	90                   	nop

00801080 <__udivdi3>:
  801080:	f3 0f 1e fb          	endbr32 
  801084:	55                   	push   %ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	83 ec 1c             	sub    $0x1c,%esp
  80108b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80108f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801093:	8b 74 24 34          	mov    0x34(%esp),%esi
  801097:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80109b:	85 c0                	test   %eax,%eax
  80109d:	75 19                	jne    8010b8 <__udivdi3+0x38>
  80109f:	39 f3                	cmp    %esi,%ebx
  8010a1:	76 4d                	jbe    8010f0 <__udivdi3+0x70>
  8010a3:	31 ff                	xor    %edi,%edi
  8010a5:	89 e8                	mov    %ebp,%eax
  8010a7:	89 f2                	mov    %esi,%edx
  8010a9:	f7 f3                	div    %ebx
  8010ab:	89 fa                	mov    %edi,%edx
  8010ad:	83 c4 1c             	add    $0x1c,%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    
  8010b5:	8d 76 00             	lea    0x0(%esi),%esi
  8010b8:	39 f0                	cmp    %esi,%eax
  8010ba:	76 14                	jbe    8010d0 <__udivdi3+0x50>
  8010bc:	31 ff                	xor    %edi,%edi
  8010be:	31 c0                	xor    %eax,%eax
  8010c0:	89 fa                	mov    %edi,%edx
  8010c2:	83 c4 1c             	add    $0x1c,%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    
  8010ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010d0:	0f bd f8             	bsr    %eax,%edi
  8010d3:	83 f7 1f             	xor    $0x1f,%edi
  8010d6:	75 48                	jne    801120 <__udivdi3+0xa0>
  8010d8:	39 f0                	cmp    %esi,%eax
  8010da:	72 06                	jb     8010e2 <__udivdi3+0x62>
  8010dc:	31 c0                	xor    %eax,%eax
  8010de:	39 eb                	cmp    %ebp,%ebx
  8010e0:	77 de                	ja     8010c0 <__udivdi3+0x40>
  8010e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e7:	eb d7                	jmp    8010c0 <__udivdi3+0x40>
  8010e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010f0:	89 d9                	mov    %ebx,%ecx
  8010f2:	85 db                	test   %ebx,%ebx
  8010f4:	75 0b                	jne    801101 <__udivdi3+0x81>
  8010f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010fb:	31 d2                	xor    %edx,%edx
  8010fd:	f7 f3                	div    %ebx
  8010ff:	89 c1                	mov    %eax,%ecx
  801101:	31 d2                	xor    %edx,%edx
  801103:	89 f0                	mov    %esi,%eax
  801105:	f7 f1                	div    %ecx
  801107:	89 c6                	mov    %eax,%esi
  801109:	89 e8                	mov    %ebp,%eax
  80110b:	89 f7                	mov    %esi,%edi
  80110d:	f7 f1                	div    %ecx
  80110f:	89 fa                	mov    %edi,%edx
  801111:	83 c4 1c             	add    $0x1c,%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    
  801119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 f9                	mov    %edi,%ecx
  801122:	ba 20 00 00 00       	mov    $0x20,%edx
  801127:	29 fa                	sub    %edi,%edx
  801129:	d3 e0                	shl    %cl,%eax
  80112b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112f:	89 d1                	mov    %edx,%ecx
  801131:	89 d8                	mov    %ebx,%eax
  801133:	d3 e8                	shr    %cl,%eax
  801135:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801139:	09 c1                	or     %eax,%ecx
  80113b:	89 f0                	mov    %esi,%eax
  80113d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801141:	89 f9                	mov    %edi,%ecx
  801143:	d3 e3                	shl    %cl,%ebx
  801145:	89 d1                	mov    %edx,%ecx
  801147:	d3 e8                	shr    %cl,%eax
  801149:	89 f9                	mov    %edi,%ecx
  80114b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80114f:	89 eb                	mov    %ebp,%ebx
  801151:	d3 e6                	shl    %cl,%esi
  801153:	89 d1                	mov    %edx,%ecx
  801155:	d3 eb                	shr    %cl,%ebx
  801157:	09 f3                	or     %esi,%ebx
  801159:	89 c6                	mov    %eax,%esi
  80115b:	89 f2                	mov    %esi,%edx
  80115d:	89 d8                	mov    %ebx,%eax
  80115f:	f7 74 24 08          	divl   0x8(%esp)
  801163:	89 d6                	mov    %edx,%esi
  801165:	89 c3                	mov    %eax,%ebx
  801167:	f7 64 24 0c          	mull   0xc(%esp)
  80116b:	39 d6                	cmp    %edx,%esi
  80116d:	72 19                	jb     801188 <__udivdi3+0x108>
  80116f:	89 f9                	mov    %edi,%ecx
  801171:	d3 e5                	shl    %cl,%ebp
  801173:	39 c5                	cmp    %eax,%ebp
  801175:	73 04                	jae    80117b <__udivdi3+0xfb>
  801177:	39 d6                	cmp    %edx,%esi
  801179:	74 0d                	je     801188 <__udivdi3+0x108>
  80117b:	89 d8                	mov    %ebx,%eax
  80117d:	31 ff                	xor    %edi,%edi
  80117f:	e9 3c ff ff ff       	jmp    8010c0 <__udivdi3+0x40>
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80118b:	31 ff                	xor    %edi,%edi
  80118d:	e9 2e ff ff ff       	jmp    8010c0 <__udivdi3+0x40>
  801192:	66 90                	xchg   %ax,%ax
  801194:	66 90                	xchg   %ax,%ax
  801196:	66 90                	xchg   %ax,%ax
  801198:	66 90                	xchg   %ax,%ax
  80119a:	66 90                	xchg   %ax,%ax
  80119c:	66 90                	xchg   %ax,%ax
  80119e:	66 90                	xchg   %ax,%ax

008011a0 <__umoddi3>:
  8011a0:	f3 0f 1e fb          	endbr32 
  8011a4:	55                   	push   %ebp
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 1c             	sub    $0x1c,%esp
  8011ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8011af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8011b3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8011b7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8011bb:	89 f0                	mov    %esi,%eax
  8011bd:	89 da                	mov    %ebx,%edx
  8011bf:	85 ff                	test   %edi,%edi
  8011c1:	75 15                	jne    8011d8 <__umoddi3+0x38>
  8011c3:	39 dd                	cmp    %ebx,%ebp
  8011c5:	76 39                	jbe    801200 <__umoddi3+0x60>
  8011c7:	f7 f5                	div    %ebp
  8011c9:	89 d0                	mov    %edx,%eax
  8011cb:	31 d2                	xor    %edx,%edx
  8011cd:	83 c4 1c             	add    $0x1c,%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    
  8011d5:	8d 76 00             	lea    0x0(%esi),%esi
  8011d8:	39 df                	cmp    %ebx,%edi
  8011da:	77 f1                	ja     8011cd <__umoddi3+0x2d>
  8011dc:	0f bd cf             	bsr    %edi,%ecx
  8011df:	83 f1 1f             	xor    $0x1f,%ecx
  8011e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011e6:	75 40                	jne    801228 <__umoddi3+0x88>
  8011e8:	39 df                	cmp    %ebx,%edi
  8011ea:	72 04                	jb     8011f0 <__umoddi3+0x50>
  8011ec:	39 f5                	cmp    %esi,%ebp
  8011ee:	77 dd                	ja     8011cd <__umoddi3+0x2d>
  8011f0:	89 da                	mov    %ebx,%edx
  8011f2:	89 f0                	mov    %esi,%eax
  8011f4:	29 e8                	sub    %ebp,%eax
  8011f6:	19 fa                	sbb    %edi,%edx
  8011f8:	eb d3                	jmp    8011cd <__umoddi3+0x2d>
  8011fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801200:	89 e9                	mov    %ebp,%ecx
  801202:	85 ed                	test   %ebp,%ebp
  801204:	75 0b                	jne    801211 <__umoddi3+0x71>
  801206:	b8 01 00 00 00       	mov    $0x1,%eax
  80120b:	31 d2                	xor    %edx,%edx
  80120d:	f7 f5                	div    %ebp
  80120f:	89 c1                	mov    %eax,%ecx
  801211:	89 d8                	mov    %ebx,%eax
  801213:	31 d2                	xor    %edx,%edx
  801215:	f7 f1                	div    %ecx
  801217:	89 f0                	mov    %esi,%eax
  801219:	f7 f1                	div    %ecx
  80121b:	89 d0                	mov    %edx,%eax
  80121d:	31 d2                	xor    %edx,%edx
  80121f:	eb ac                	jmp    8011cd <__umoddi3+0x2d>
  801221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801228:	8b 44 24 04          	mov    0x4(%esp),%eax
  80122c:	ba 20 00 00 00       	mov    $0x20,%edx
  801231:	29 c2                	sub    %eax,%edx
  801233:	89 c1                	mov    %eax,%ecx
  801235:	89 e8                	mov    %ebp,%eax
  801237:	d3 e7                	shl    %cl,%edi
  801239:	89 d1                	mov    %edx,%ecx
  80123b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80123f:	d3 e8                	shr    %cl,%eax
  801241:	89 c1                	mov    %eax,%ecx
  801243:	8b 44 24 04          	mov    0x4(%esp),%eax
  801247:	09 f9                	or     %edi,%ecx
  801249:	89 df                	mov    %ebx,%edi
  80124b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80124f:	89 c1                	mov    %eax,%ecx
  801251:	d3 e5                	shl    %cl,%ebp
  801253:	89 d1                	mov    %edx,%ecx
  801255:	d3 ef                	shr    %cl,%edi
  801257:	89 c1                	mov    %eax,%ecx
  801259:	89 f0                	mov    %esi,%eax
  80125b:	d3 e3                	shl    %cl,%ebx
  80125d:	89 d1                	mov    %edx,%ecx
  80125f:	89 fa                	mov    %edi,%edx
  801261:	d3 e8                	shr    %cl,%eax
  801263:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801268:	09 d8                	or     %ebx,%eax
  80126a:	f7 74 24 08          	divl   0x8(%esp)
  80126e:	89 d3                	mov    %edx,%ebx
  801270:	d3 e6                	shl    %cl,%esi
  801272:	f7 e5                	mul    %ebp
  801274:	89 c7                	mov    %eax,%edi
  801276:	89 d1                	mov    %edx,%ecx
  801278:	39 d3                	cmp    %edx,%ebx
  80127a:	72 06                	jb     801282 <__umoddi3+0xe2>
  80127c:	75 0e                	jne    80128c <__umoddi3+0xec>
  80127e:	39 c6                	cmp    %eax,%esi
  801280:	73 0a                	jae    80128c <__umoddi3+0xec>
  801282:	29 e8                	sub    %ebp,%eax
  801284:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801288:	89 d1                	mov    %edx,%ecx
  80128a:	89 c7                	mov    %eax,%edi
  80128c:	89 f5                	mov    %esi,%ebp
  80128e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801292:	29 fd                	sub    %edi,%ebp
  801294:	19 cb                	sbb    %ecx,%ebx
  801296:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80129b:	89 d8                	mov    %ebx,%eax
  80129d:	d3 e0                	shl    %cl,%eax
  80129f:	89 f1                	mov    %esi,%ecx
  8012a1:	d3 ed                	shr    %cl,%ebp
  8012a3:	d3 eb                	shr    %cl,%ebx
  8012a5:	09 e8                	or     %ebp,%eax
  8012a7:	89 da                	mov    %ebx,%edx
  8012a9:	83 c4 1c             	add    $0x1c,%esp
  8012ac:	5b                   	pop    %ebx
  8012ad:	5e                   	pop    %esi
  8012ae:	5f                   	pop    %edi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    
