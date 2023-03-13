
obj/user/faultreadkernel.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	push   0xf0100000
  80003f:	68 80 1d 80 00       	push   $0x801d80
  800044:	e8 fa 00 00 00       	call   800143 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 7d 0a 00 00       	call   800adb <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 37 0e 00 00       	call   800ed6 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 f1 09 00 00       	call   800a9a <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	74 09                	je     8000d6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000cd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	68 ff 00 00 00       	push   $0xff
  8000de:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e1:	50                   	push   %eax
  8000e2:	e8 76 09 00 00       	call   800a5d <sys_cputs>
		b->idx = 0;
  8000e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	eb db                	jmp    8000cd <putch+0x1f>

008000f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800102:	00 00 00 
	b.cnt = 0;
  800105:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010f:	ff 75 0c             	push   0xc(%ebp)
  800112:	ff 75 08             	push   0x8(%ebp)
  800115:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011b:	50                   	push   %eax
  80011c:	68 ae 00 80 00       	push   $0x8000ae
  800121:	e8 14 01 00 00       	call   80023a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800126:	83 c4 08             	add    $0x8,%esp
  800129:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80012f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800135:	50                   	push   %eax
  800136:	e8 22 09 00 00       	call   800a5d <sys_cputs>

	return b.cnt;
}
  80013b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014c:	50                   	push   %eax
  80014d:	ff 75 08             	push   0x8(%ebp)
  800150:	e8 9d ff ff ff       	call   8000f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 1c             	sub    $0x1c,%esp
  800160:	89 c7                	mov    %eax,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 c2                	mov    %eax,%edx
  80016e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800171:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800174:	8b 45 10             	mov    0x10(%ebp),%eax
  800177:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80017d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800184:	39 c2                	cmp    %eax,%edx
  800186:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800189:	72 3e                	jb     8001c9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018b:	83 ec 0c             	sub    $0xc,%esp
  80018e:	ff 75 18             	push   0x18(%ebp)
  800191:	83 eb 01             	sub    $0x1,%ebx
  800194:	53                   	push   %ebx
  800195:	50                   	push   %eax
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	ff 75 e4             	push   -0x1c(%ebp)
  80019c:	ff 75 e0             	push   -0x20(%ebp)
  80019f:	ff 75 dc             	push   -0x24(%ebp)
  8001a2:	ff 75 d8             	push   -0x28(%ebp)
  8001a5:	e8 86 19 00 00       	call   801b30 <__udivdi3>
  8001aa:	83 c4 18             	add    $0x18,%esp
  8001ad:	52                   	push   %edx
  8001ae:	50                   	push   %eax
  8001af:	89 f2                	mov    %esi,%edx
  8001b1:	89 f8                	mov    %edi,%eax
  8001b3:	e8 9f ff ff ff       	call   800157 <printnum>
  8001b8:	83 c4 20             	add    $0x20,%esp
  8001bb:	eb 13                	jmp    8001d0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	56                   	push   %esi
  8001c1:	ff 75 18             	push   0x18(%ebp)
  8001c4:	ff d7                	call   *%edi
  8001c6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001c9:	83 eb 01             	sub    $0x1,%ebx
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7f ed                	jg     8001bd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	83 ec 04             	sub    $0x4,%esp
  8001d7:	ff 75 e4             	push   -0x1c(%ebp)
  8001da:	ff 75 e0             	push   -0x20(%ebp)
  8001dd:	ff 75 dc             	push   -0x24(%ebp)
  8001e0:	ff 75 d8             	push   -0x28(%ebp)
  8001e3:	e8 68 1a 00 00       	call   801c50 <__umoddi3>
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	0f be 80 b1 1d 80 00 	movsbl 0x801db1(%eax),%eax
  8001f2:	50                   	push   %eax
  8001f3:	ff d7                	call   *%edi
}
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5f                   	pop    %edi
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    

00800200 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800206:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80020a:	8b 10                	mov    (%eax),%edx
  80020c:	3b 50 04             	cmp    0x4(%eax),%edx
  80020f:	73 0a                	jae    80021b <sprintputch+0x1b>
		*b->buf++ = ch;
  800211:	8d 4a 01             	lea    0x1(%edx),%ecx
  800214:	89 08                	mov    %ecx,(%eax)
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	88 02                	mov    %al,(%edx)
}
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <printfmt>:
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800223:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800226:	50                   	push   %eax
  800227:	ff 75 10             	push   0x10(%ebp)
  80022a:	ff 75 0c             	push   0xc(%ebp)
  80022d:	ff 75 08             	push   0x8(%ebp)
  800230:	e8 05 00 00 00       	call   80023a <vprintfmt>
}
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <vprintfmt>:
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 3c             	sub    $0x3c,%esp
  800243:	8b 75 08             	mov    0x8(%ebp),%esi
  800246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800249:	8b 7d 10             	mov    0x10(%ebp),%edi
  80024c:	eb 0a                	jmp    800258 <vprintfmt+0x1e>
			putch(ch, putdat);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	53                   	push   %ebx
  800252:	50                   	push   %eax
  800253:	ff d6                	call   *%esi
  800255:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800258:	83 c7 01             	add    $0x1,%edi
  80025b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80025f:	83 f8 25             	cmp    $0x25,%eax
  800262:	74 0c                	je     800270 <vprintfmt+0x36>
			if (ch == '\0')
  800264:	85 c0                	test   %eax,%eax
  800266:	75 e6                	jne    80024e <vprintfmt+0x14>
}
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    
		padc = ' ';
  800270:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800274:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80027b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800282:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800289:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80028e:	8d 47 01             	lea    0x1(%edi),%eax
  800291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800294:	0f b6 17             	movzbl (%edi),%edx
  800297:	8d 42 dd             	lea    -0x23(%edx),%eax
  80029a:	3c 55                	cmp    $0x55,%al
  80029c:	0f 87 bb 03 00 00    	ja     80065d <vprintfmt+0x423>
  8002a2:	0f b6 c0             	movzbl %al,%eax
  8002a5:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
  8002ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002af:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002b3:	eb d9                	jmp    80028e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002b8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002bc:	eb d0                	jmp    80028e <vprintfmt+0x54>
  8002be:	0f b6 d2             	movzbl %dl,%edx
  8002c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002cf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d9:	83 f9 09             	cmp    $0x9,%ecx
  8002dc:	77 55                	ja     800333 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e1:	eb e9                	jmp    8002cc <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8b 00                	mov    (%eax),%eax
  8002e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8d 40 04             	lea    0x4(%eax),%eax
  8002f1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002fb:	79 91                	jns    80028e <vprintfmt+0x54>
				width = precision, precision = -1;
  8002fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800300:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800303:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80030a:	eb 82                	jmp    80028e <vprintfmt+0x54>
  80030c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80030f:	85 d2                	test   %edx,%edx
  800311:	b8 00 00 00 00       	mov    $0x0,%eax
  800316:	0f 49 c2             	cmovns %edx,%eax
  800319:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80031f:	e9 6a ff ff ff       	jmp    80028e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800327:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80032e:	e9 5b ff ff ff       	jmp    80028e <vprintfmt+0x54>
  800333:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	eb bc                	jmp    8002f7 <vprintfmt+0xbd>
			lflag++;
  80033b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800341:	e9 48 ff ff ff       	jmp    80028e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 78 04             	lea    0x4(%eax),%edi
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 30                	push   (%eax)
  800352:	ff d6                	call   *%esi
			break;
  800354:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800357:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80035a:	e9 9d 02 00 00       	jmp    8005fc <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8d 78 04             	lea    0x4(%eax),%edi
  800365:	8b 10                	mov    (%eax),%edx
  800367:	89 d0                	mov    %edx,%eax
  800369:	f7 d8                	neg    %eax
  80036b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80036e:	83 f8 0f             	cmp    $0xf,%eax
  800371:	7f 23                	jg     800396 <vprintfmt+0x15c>
  800373:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  80037a:	85 d2                	test   %edx,%edx
  80037c:	74 18                	je     800396 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80037e:	52                   	push   %edx
  80037f:	68 91 21 80 00       	push   $0x802191
  800384:	53                   	push   %ebx
  800385:	56                   	push   %esi
  800386:	e8 92 fe ff ff       	call   80021d <printfmt>
  80038b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800391:	e9 66 02 00 00       	jmp    8005fc <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800396:	50                   	push   %eax
  800397:	68 c9 1d 80 00       	push   $0x801dc9
  80039c:	53                   	push   %ebx
  80039d:	56                   	push   %esi
  80039e:	e8 7a fe ff ff       	call   80021d <printfmt>
  8003a3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a9:	e9 4e 02 00 00       	jmp    8005fc <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	83 c0 04             	add    $0x4,%eax
  8003b4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	b8 c2 1d 80 00       	mov    $0x801dc2,%eax
  8003c3:	0f 45 c2             	cmovne %edx,%eax
  8003c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cd:	7e 06                	jle    8003d5 <vprintfmt+0x19b>
  8003cf:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003d3:	75 0d                	jne    8003e2 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d8:	89 c7                	mov    %eax,%edi
  8003da:	03 45 e0             	add    -0x20(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	eb 55                	jmp    800437 <vprintfmt+0x1fd>
  8003e2:	83 ec 08             	sub    $0x8,%esp
  8003e5:	ff 75 d8             	push   -0x28(%ebp)
  8003e8:	ff 75 cc             	push   -0x34(%ebp)
  8003eb:	e8 0a 03 00 00       	call   8006fa <strnlen>
  8003f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f3:	29 c1                	sub    %eax,%ecx
  8003f5:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8003fd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800401:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800404:	eb 0f                	jmp    800415 <vprintfmt+0x1db>
					putch(padc, putdat);
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	53                   	push   %ebx
  80040a:	ff 75 e0             	push   -0x20(%ebp)
  80040d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	83 ef 01             	sub    $0x1,%edi
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	85 ff                	test   %edi,%edi
  800417:	7f ed                	jg     800406 <vprintfmt+0x1cc>
  800419:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80041c:	85 d2                	test   %edx,%edx
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	0f 49 c2             	cmovns %edx,%eax
  800426:	29 c2                	sub    %eax,%edx
  800428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042b:	eb a8                	jmp    8003d5 <vprintfmt+0x19b>
					putch(ch, putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	52                   	push   %edx
  800432:	ff d6                	call   *%esi
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043c:	83 c7 01             	add    $0x1,%edi
  80043f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800443:	0f be d0             	movsbl %al,%edx
  800446:	85 d2                	test   %edx,%edx
  800448:	74 4b                	je     800495 <vprintfmt+0x25b>
  80044a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044e:	78 06                	js     800456 <vprintfmt+0x21c>
  800450:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800454:	78 1e                	js     800474 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800456:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045a:	74 d1                	je     80042d <vprintfmt+0x1f3>
  80045c:	0f be c0             	movsbl %al,%eax
  80045f:	83 e8 20             	sub    $0x20,%eax
  800462:	83 f8 5e             	cmp    $0x5e,%eax
  800465:	76 c6                	jbe    80042d <vprintfmt+0x1f3>
					putch('?', putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	6a 3f                	push   $0x3f
  80046d:	ff d6                	call   *%esi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb c3                	jmp    800437 <vprintfmt+0x1fd>
  800474:	89 cf                	mov    %ecx,%edi
  800476:	eb 0e                	jmp    800486 <vprintfmt+0x24c>
				putch(' ', putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	6a 20                	push   $0x20
  80047e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800480:	83 ef 01             	sub    $0x1,%edi
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	85 ff                	test   %edi,%edi
  800488:	7f ee                	jg     800478 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80048a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048d:	89 45 14             	mov    %eax,0x14(%ebp)
  800490:	e9 67 01 00 00       	jmp    8005fc <vprintfmt+0x3c2>
  800495:	89 cf                	mov    %ecx,%edi
  800497:	eb ed                	jmp    800486 <vprintfmt+0x24c>
	if (lflag >= 2)
  800499:	83 f9 01             	cmp    $0x1,%ecx
  80049c:	7f 1b                	jg     8004b9 <vprintfmt+0x27f>
	else if (lflag)
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	74 63                	je     800505 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8b 00                	mov    (%eax),%eax
  8004a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004aa:	99                   	cltd   
  8004ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 40 04             	lea    0x4(%eax),%eax
  8004b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b7:	eb 17                	jmp    8004d0 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8b 50 04             	mov    0x4(%eax),%edx
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 08             	lea    0x8(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004d6:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004db:	85 c9                	test   %ecx,%ecx
  8004dd:	0f 89 ff 00 00 00    	jns    8005e2 <vprintfmt+0x3a8>
				putch('-', putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	6a 2d                	push   $0x2d
  8004e9:	ff d6                	call   *%esi
				num = -(long long) num;
  8004eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f1:	f7 da                	neg    %edx
  8004f3:	83 d1 00             	adc    $0x0,%ecx
  8004f6:	f7 d9                	neg    %ecx
  8004f8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004fb:	bf 0a 00 00 00       	mov    $0xa,%edi
  800500:	e9 dd 00 00 00       	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	99                   	cltd   
  80050e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 04             	lea    0x4(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb b4                	jmp    8004d0 <vprintfmt+0x296>
	if (lflag >= 2)
  80051c:	83 f9 01             	cmp    $0x1,%ecx
  80051f:	7f 1e                	jg     80053f <vprintfmt+0x305>
	else if (lflag)
  800521:	85 c9                	test   %ecx,%ecx
  800523:	74 32                	je     800557 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800535:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80053a:	e9 a3 00 00 00       	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 10                	mov    (%eax),%edx
  800544:	8b 48 04             	mov    0x4(%eax),%ecx
  800547:	8d 40 08             	lea    0x8(%eax),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800552:	e9 8b 00 00 00       	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800567:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80056c:	eb 74                	jmp    8005e2 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80056e:	83 f9 01             	cmp    $0x1,%ecx
  800571:	7f 1b                	jg     80058e <vprintfmt+0x354>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	74 2c                	je     8005a3 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800587:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80058c:	eb 54                	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 10                	mov    (%eax),%edx
  800593:	8b 48 04             	mov    0x4(%eax),%ecx
  800596:	8d 40 08             	lea    0x8(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80059c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005a1:	eb 3f                	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ad:	8d 40 04             	lea    0x4(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005b3:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005b8:	eb 28                	jmp    8005e2 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 30                	push   $0x30
  8005c0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c2:	83 c4 08             	add    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 78                	push   $0x78
  8005c8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 10                	mov    (%eax),%edx
  8005cf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005d4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005dd:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005e9:	50                   	push   %eax
  8005ea:	ff 75 e0             	push   -0x20(%ebp)
  8005ed:	57                   	push   %edi
  8005ee:	51                   	push   %ecx
  8005ef:	52                   	push   %edx
  8005f0:	89 da                	mov    %ebx,%edx
  8005f2:	89 f0                	mov    %esi,%eax
  8005f4:	e8 5e fb ff ff       	call   800157 <printnum>
			break;
  8005f9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ff:	e9 54 fc ff ff       	jmp    800258 <vprintfmt+0x1e>
	if (lflag >= 2)
  800604:	83 f9 01             	cmp    $0x1,%ecx
  800607:	7f 1b                	jg     800624 <vprintfmt+0x3ea>
	else if (lflag)
  800609:	85 c9                	test   %ecx,%ecx
  80060b:	74 2c                	je     800639 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80061d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800622:	eb be                	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 10                	mov    (%eax),%edx
  800629:	8b 48 04             	mov    0x4(%eax),%ecx
  80062c:	8d 40 08             	lea    0x8(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800632:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800637:	eb a9                	jmp    8005e2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800649:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80064e:	eb 92                	jmp    8005e2 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 25                	push   $0x25
  800656:	ff d6                	call   *%esi
			break;
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	eb 9f                	jmp    8005fc <vprintfmt+0x3c2>
			putch('%', putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 25                	push   $0x25
  800663:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	89 f8                	mov    %edi,%eax
  80066a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80066e:	74 05                	je     800675 <vprintfmt+0x43b>
  800670:	83 e8 01             	sub    $0x1,%eax
  800673:	eb f5                	jmp    80066a <vprintfmt+0x430>
  800675:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800678:	eb 82                	jmp    8005fc <vprintfmt+0x3c2>

0080067a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 18             	sub    $0x18,%esp
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800686:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800689:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800697:	85 c0                	test   %eax,%eax
  800699:	74 26                	je     8006c1 <vsnprintf+0x47>
  80069b:	85 d2                	test   %edx,%edx
  80069d:	7e 22                	jle    8006c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069f:	ff 75 14             	push   0x14(%ebp)
  8006a2:	ff 75 10             	push   0x10(%ebp)
  8006a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 00 02 80 00       	push   $0x800200
  8006ae:	e8 87 fb ff ff       	call   80023a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bc:	83 c4 10             	add    $0x10,%esp
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    
		return -E_INVAL;
  8006c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c6:	eb f7                	jmp    8006bf <vsnprintf+0x45>

008006c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d1:	50                   	push   %eax
  8006d2:	ff 75 10             	push   0x10(%ebp)
  8006d5:	ff 75 0c             	push   0xc(%ebp)
  8006d8:	ff 75 08             	push   0x8(%ebp)
  8006db:	e8 9a ff ff ff       	call   80067a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	eb 03                	jmp    8006f2 <strlen+0x10>
		n++;
  8006ef:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f6:	75 f7                	jne    8006ef <strlen+0xd>
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 03                	jmp    80070d <strnlen+0x13>
		n++;
  80070a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	39 d0                	cmp    %edx,%eax
  80070f:	74 08                	je     800719 <strnlen+0x1f>
  800711:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800715:	75 f3                	jne    80070a <strnlen+0x10>
  800717:	89 c2                	mov    %eax,%edx
	return n;
}
  800719:	89 d0                	mov    %edx,%eax
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	53                   	push   %ebx
  800721:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800730:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800733:	83 c0 01             	add    $0x1,%eax
  800736:	84 d2                	test   %dl,%dl
  800738:	75 f2                	jne    80072c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80073a:	89 c8                	mov    %ecx,%eax
  80073c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	53                   	push   %ebx
  800745:	83 ec 10             	sub    $0x10,%esp
  800748:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074b:	53                   	push   %ebx
  80074c:	e8 91 ff ff ff       	call   8006e2 <strlen>
  800751:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800754:	ff 75 0c             	push   0xc(%ebp)
  800757:	01 d8                	add    %ebx,%eax
  800759:	50                   	push   %eax
  80075a:	e8 be ff ff ff       	call   80071d <strcpy>
	return dst;
}
  80075f:	89 d8                	mov    %ebx,%eax
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	56                   	push   %esi
  80076a:	53                   	push   %ebx
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	89 f3                	mov    %esi,%ebx
  800773:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800776:	89 f0                	mov    %esi,%eax
  800778:	eb 0f                	jmp    800789 <strncpy+0x23>
		*dst++ = *src;
  80077a:	83 c0 01             	add    $0x1,%eax
  80077d:	0f b6 0a             	movzbl (%edx),%ecx
  800780:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800783:	80 f9 01             	cmp    $0x1,%cl
  800786:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800789:	39 d8                	cmp    %ebx,%eax
  80078b:	75 ed                	jne    80077a <strncpy+0x14>
	}
	return ret;
}
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	8b 75 08             	mov    0x8(%ebp),%esi
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079e:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	74 21                	je     8007c8 <strlcpy+0x35>
  8007a7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	eb 09                	jmp    8007b8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007af:	83 c1 01             	add    $0x1,%ecx
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007b8:	39 c2                	cmp    %eax,%edx
  8007ba:	74 09                	je     8007c5 <strlcpy+0x32>
  8007bc:	0f b6 19             	movzbl (%ecx),%ebx
  8007bf:	84 db                	test   %bl,%bl
  8007c1:	75 ec                	jne    8007af <strlcpy+0x1c>
  8007c3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007c5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c8:	29 f0                	sub    %esi,%eax
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strcmp+0x11>
		p++, q++;
  8007d9:	83 c1 01             	add    $0x1,%ecx
  8007dc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007df:	0f b6 01             	movzbl (%ecx),%eax
  8007e2:	84 c0                	test   %al,%al
  8007e4:	74 04                	je     8007ea <strcmp+0x1c>
  8007e6:	3a 02                	cmp    (%edx),%al
  8007e8:	74 ef                	je     8007d9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	0f b6 c0             	movzbl %al,%eax
  8007ed:	0f b6 12             	movzbl (%edx),%edx
  8007f0:	29 d0                	sub    %edx,%eax
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	89 c3                	mov    %eax,%ebx
  800800:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800803:	eb 06                	jmp    80080b <strncmp+0x17>
		n--, p++, q++;
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80080b:	39 d8                	cmp    %ebx,%eax
  80080d:	74 18                	je     800827 <strncmp+0x33>
  80080f:	0f b6 08             	movzbl (%eax),%ecx
  800812:	84 c9                	test   %cl,%cl
  800814:	74 04                	je     80081a <strncmp+0x26>
  800816:	3a 0a                	cmp    (%edx),%cl
  800818:	74 eb                	je     800805 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081a:	0f b6 00             	movzbl (%eax),%eax
  80081d:	0f b6 12             	movzbl (%edx),%edx
  800820:	29 d0                	sub    %edx,%eax
}
  800822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    
		return 0;
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb f4                	jmp    800822 <strncmp+0x2e>

0080082e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800838:	eb 03                	jmp    80083d <strchr+0xf>
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	0f b6 10             	movzbl (%eax),%edx
  800840:	84 d2                	test   %dl,%dl
  800842:	74 06                	je     80084a <strchr+0x1c>
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	75 f2                	jne    80083a <strchr+0xc>
  800848:	eb 05                	jmp    80084f <strchr+0x21>
			return (char *) s;
	return 0;
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085e:	38 ca                	cmp    %cl,%dl
  800860:	74 09                	je     80086b <strfind+0x1a>
  800862:	84 d2                	test   %dl,%dl
  800864:	74 05                	je     80086b <strfind+0x1a>
	for (; *s; s++)
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	eb f0                	jmp    80085b <strfind+0xa>
			break;
	return (char *) s;
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	57                   	push   %edi
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 7d 08             	mov    0x8(%ebp),%edi
  800876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 2f                	je     8008ac <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087d:	89 f8                	mov    %edi,%eax
  80087f:	09 c8                	or     %ecx,%eax
  800881:	a8 03                	test   $0x3,%al
  800883:	75 21                	jne    8008a6 <memset+0x39>
		c &= 0xFF;
  800885:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800889:	89 d0                	mov    %edx,%eax
  80088b:	c1 e0 08             	shl    $0x8,%eax
  80088e:	89 d3                	mov    %edx,%ebx
  800890:	c1 e3 18             	shl    $0x18,%ebx
  800893:	89 d6                	mov    %edx,%esi
  800895:	c1 e6 10             	shl    $0x10,%esi
  800898:	09 f3                	or     %esi,%ebx
  80089a:	09 da                	or     %ebx,%edx
  80089c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80089e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008a1:	fc                   	cld    
  8008a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a4:	eb 06                	jmp    8008ac <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a9:	fc                   	cld    
  8008aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ac:	89 f8                	mov    %edi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c1:	39 c6                	cmp    %eax,%esi
  8008c3:	73 32                	jae    8008f7 <memmove+0x44>
  8008c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c8:	39 c2                	cmp    %eax,%edx
  8008ca:	76 2b                	jbe    8008f7 <memmove+0x44>
		s += n;
		d += n;
  8008cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cf:	89 d6                	mov    %edx,%esi
  8008d1:	09 fe                	or     %edi,%esi
  8008d3:	09 ce                	or     %ecx,%esi
  8008d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008db:	75 0e                	jne    8008eb <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008dd:	83 ef 04             	sub    $0x4,%edi
  8008e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008e6:	fd                   	std    
  8008e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e9:	eb 09                	jmp    8008f4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008eb:	83 ef 01             	sub    $0x1,%edi
  8008ee:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f1:	fd                   	std    
  8008f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f4:	fc                   	cld    
  8008f5:	eb 1a                	jmp    800911 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f7:	89 f2                	mov    %esi,%edx
  8008f9:	09 c2                	or     %eax,%edx
  8008fb:	09 ca                	or     %ecx,%edx
  8008fd:	f6 c2 03             	test   $0x3,%dl
  800900:	75 0a                	jne    80090c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800902:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800905:	89 c7                	mov    %eax,%edi
  800907:	fc                   	cld    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 05                	jmp    800911 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80090c:	89 c7                	mov    %eax,%edi
  80090e:	fc                   	cld    
  80090f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80091b:	ff 75 10             	push   0x10(%ebp)
  80091e:	ff 75 0c             	push   0xc(%ebp)
  800921:	ff 75 08             	push   0x8(%ebp)
  800924:	e8 8a ff ff ff       	call   8008b3 <memmove>
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	89 c6                	mov    %eax,%esi
  800938:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093b:	eb 06                	jmp    800943 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800943:	39 f0                	cmp    %esi,%eax
  800945:	74 14                	je     80095b <memcmp+0x30>
		if (*s1 != *s2)
  800947:	0f b6 08             	movzbl (%eax),%ecx
  80094a:	0f b6 1a             	movzbl (%edx),%ebx
  80094d:	38 d9                	cmp    %bl,%cl
  80094f:	74 ec                	je     80093d <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800951:	0f b6 c1             	movzbl %cl,%eax
  800954:	0f b6 db             	movzbl %bl,%ebx
  800957:	29 d8                	sub    %ebx,%eax
  800959:	eb 05                	jmp    800960 <memcmp+0x35>
	}

	return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800972:	eb 03                	jmp    800977 <memfind+0x13>
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	39 d0                	cmp    %edx,%eax
  800979:	73 04                	jae    80097f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097b:	38 08                	cmp    %cl,(%eax)
  80097d:	75 f5                	jne    800974 <memfind+0x10>
			break;
	return (void *) s;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 55 08             	mov    0x8(%ebp),%edx
  80098a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098d:	eb 03                	jmp    800992 <strtol+0x11>
		s++;
  80098f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800992:	0f b6 02             	movzbl (%edx),%eax
  800995:	3c 20                	cmp    $0x20,%al
  800997:	74 f6                	je     80098f <strtol+0xe>
  800999:	3c 09                	cmp    $0x9,%al
  80099b:	74 f2                	je     80098f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80099d:	3c 2b                	cmp    $0x2b,%al
  80099f:	74 2a                	je     8009cb <strtol+0x4a>
	int neg = 0;
  8009a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009a6:	3c 2d                	cmp    $0x2d,%al
  8009a8:	74 2b                	je     8009d5 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009aa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b0:	75 0f                	jne    8009c1 <strtol+0x40>
  8009b2:	80 3a 30             	cmpb   $0x30,(%edx)
  8009b5:	74 28                	je     8009df <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009be:	0f 44 d8             	cmove  %eax,%ebx
  8009c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009c9:	eb 46                	jmp    800a11 <strtol+0x90>
		s++;
  8009cb:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d3:	eb d5                	jmp    8009aa <strtol+0x29>
		s++, neg = 1;
  8009d5:	83 c2 01             	add    $0x1,%edx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009dd:	eb cb                	jmp    8009aa <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e3:	74 0e                	je     8009f3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009e5:	85 db                	test   %ebx,%ebx
  8009e7:	75 d8                	jne    8009c1 <strtol+0x40>
		s++, base = 8;
  8009e9:	83 c2 01             	add    $0x1,%edx
  8009ec:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009f1:	eb ce                	jmp    8009c1 <strtol+0x40>
		s += 2, base = 16;
  8009f3:	83 c2 02             	add    $0x2,%edx
  8009f6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fb:	eb c4                	jmp    8009c1 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009fd:	0f be c0             	movsbl %al,%eax
  800a00:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a03:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a06:	7d 3a                	jge    800a42 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a08:	83 c2 01             	add    $0x1,%edx
  800a0b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a0f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a11:	0f b6 02             	movzbl (%edx),%eax
  800a14:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	80 fb 09             	cmp    $0x9,%bl
  800a1c:	76 df                	jbe    8009fd <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a1e:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 19             	cmp    $0x19,%bl
  800a26:	77 08                	ja     800a30 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a28:	0f be c0             	movsbl %al,%eax
  800a2b:	83 e8 57             	sub    $0x57,%eax
  800a2e:	eb d3                	jmp    800a03 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a30:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 08                	ja     800a42 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a3a:	0f be c0             	movsbl %al,%eax
  800a3d:	83 e8 37             	sub    $0x37,%eax
  800a40:	eb c1                	jmp    800a03 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a46:	74 05                	je     800a4d <strtol+0xcc>
		*endptr = (char *) s;
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a4d:	89 c8                	mov    %ecx,%eax
  800a4f:	f7 d8                	neg    %eax
  800a51:	85 ff                	test   %edi,%edi
  800a53:	0f 45 c8             	cmovne %eax,%ecx
}
  800a56:	89 c8                	mov    %ecx,%eax
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	89 c7                	mov    %eax,%edi
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8b:	89 d1                	mov    %edx,%ecx
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	89 d7                	mov    %edx,%edi
  800a91:	89 d6                	mov    %edx,%esi
  800a93:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	89 cb                	mov    %ecx,%ebx
  800ab2:	89 cf                	mov    %ecx,%edi
  800ab4:	89 ce                	mov    %ecx,%esi
  800ab6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	7f 08                	jg     800ac4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac4:	83 ec 0c             	sub    $0xc,%esp
  800ac7:	50                   	push   %eax
  800ac8:	6a 03                	push   $0x3
  800aca:	68 bf 20 80 00       	push   $0x8020bf
  800acf:	6a 2a                	push   $0x2a
  800ad1:	68 dc 20 80 00       	push   $0x8020dc
  800ad6:	e8 d0 0e 00 00       	call   8019ab <_panic>

00800adb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_yield>:

void
sys_yield(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b22:	be 00 00 00 00       	mov    $0x0,%esi
  800b27:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b35:	89 f7                	mov    %esi,%edi
  800b37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7f 08                	jg     800b45 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	50                   	push   %eax
  800b49:	6a 04                	push   $0x4
  800b4b:	68 bf 20 80 00       	push   $0x8020bf
  800b50:	6a 2a                	push   $0x2a
  800b52:	68 dc 20 80 00       	push   $0x8020dc
  800b57:	e8 4f 0e 00 00       	call   8019ab <_panic>

00800b5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b76:	8b 75 18             	mov    0x18(%ebp),%esi
  800b79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7f 08                	jg     800b87 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 05                	push   $0x5
  800b8d:	68 bf 20 80 00       	push   $0x8020bf
  800b92:	6a 2a                	push   $0x2a
  800b94:	68 dc 20 80 00       	push   $0x8020dc
  800b99:	e8 0d 0e 00 00       	call   8019ab <_panic>

00800b9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb7:	89 df                	mov    %ebx,%edi
  800bb9:	89 de                	mov    %ebx,%esi
  800bbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7f 08                	jg     800bc9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 06                	push   $0x6
  800bcf:	68 bf 20 80 00       	push   $0x8020bf
  800bd4:	6a 2a                	push   $0x2a
  800bd6:	68 dc 20 80 00       	push   $0x8020dc
  800bdb:	e8 cb 0d 00 00       	call   8019ab <_panic>

00800be0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7f 08                	jg     800c0b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 08                	push   $0x8
  800c11:	68 bf 20 80 00       	push   $0x8020bf
  800c16:	6a 2a                	push   $0x2a
  800c18:	68 dc 20 80 00       	push   $0x8020dc
  800c1d:	e8 89 0d 00 00       	call   8019ab <_panic>

00800c22 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7f 08                	jg     800c4d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 09                	push   $0x9
  800c53:	68 bf 20 80 00       	push   $0x8020bf
  800c58:	6a 2a                	push   $0x2a
  800c5a:	68 dc 20 80 00       	push   $0x8020dc
  800c5f:	e8 47 0d 00 00       	call   8019ab <_panic>

00800c64 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7f 08                	jg     800c8f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 0a                	push   $0xa
  800c95:	68 bf 20 80 00       	push   $0x8020bf
  800c9a:	6a 2a                	push   $0x2a
  800c9c:	68 dc 20 80 00       	push   $0x8020dc
  800ca1:	e8 05 0d 00 00       	call   8019ab <_panic>

00800ca6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb7:	be 00 00 00 00       	mov    $0x0,%esi
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7f 08                	jg     800cf3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 0d                	push   $0xd
  800cf9:	68 bf 20 80 00       	push   $0x8020bf
  800cfe:	6a 2a                	push   $0x2a
  800d00:	68 dc 20 80 00       	push   $0x8020dc
  800d05:	e8 a1 0c 00 00       	call   8019ab <_panic>

00800d0a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	05 00 00 00 30       	add    $0x30000000,%eax
  800d15:	c1 e8 0c             	shr    $0xc,%eax
}
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d2a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d39:	89 c2                	mov    %eax,%edx
  800d3b:	c1 ea 16             	shr    $0x16,%edx
  800d3e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d45:	f6 c2 01             	test   $0x1,%dl
  800d48:	74 29                	je     800d73 <fd_alloc+0x42>
  800d4a:	89 c2                	mov    %eax,%edx
  800d4c:	c1 ea 0c             	shr    $0xc,%edx
  800d4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d56:	f6 c2 01             	test   $0x1,%dl
  800d59:	74 18                	je     800d73 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800d5b:	05 00 10 00 00       	add    $0x1000,%eax
  800d60:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d65:	75 d2                	jne    800d39 <fd_alloc+0x8>
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800d6c:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800d71:	eb 05                	jmp    800d78 <fd_alloc+0x47>
			return 0;
  800d73:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 02                	mov    %eax,(%edx)
}
  800d7d:	89 c8                	mov    %ecx,%eax
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d87:	83 f8 1f             	cmp    $0x1f,%eax
  800d8a:	77 30                	ja     800dbc <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d8c:	c1 e0 0c             	shl    $0xc,%eax
  800d8f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d94:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800d9a:	f6 c2 01             	test   $0x1,%dl
  800d9d:	74 24                	je     800dc3 <fd_lookup+0x42>
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	c1 ea 0c             	shr    $0xc,%edx
  800da4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dab:	f6 c2 01             	test   $0x1,%dl
  800dae:	74 1a                	je     800dca <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800db0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db3:	89 02                	mov    %eax,(%edx)
	return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
		return -E_INVAL;
  800dbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc1:	eb f7                	jmp    800dba <fd_lookup+0x39>
		return -E_INVAL;
  800dc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc8:	eb f0                	jmp    800dba <fd_lookup+0x39>
  800dca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dcf:	eb e9                	jmp    800dba <fd_lookup+0x39>

00800dd1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	b8 68 21 80 00       	mov    $0x802168,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800de0:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800de5:	39 13                	cmp    %edx,(%ebx)
  800de7:	74 32                	je     800e1b <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800de9:	83 c0 04             	add    $0x4,%eax
  800dec:	8b 18                	mov    (%eax),%ebx
  800dee:	85 db                	test   %ebx,%ebx
  800df0:	75 f3                	jne    800de5 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800df2:	a1 00 40 80 00       	mov    0x804000,%eax
  800df7:	8b 40 48             	mov    0x48(%eax),%eax
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	52                   	push   %edx
  800dfe:	50                   	push   %eax
  800dff:	68 ec 20 80 00       	push   $0x8020ec
  800e04:	e8 3a f3 ff ff       	call   800143 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e09:	83 c4 10             	add    $0x10,%esp
  800e0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e14:	89 1a                	mov    %ebx,(%edx)
}
  800e16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    
			return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	eb ef                	jmp    800e11 <dev_lookup+0x40>

00800e22 <fd_close>:
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 24             	sub    $0x24,%esp
  800e2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e34:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e3e:	50                   	push   %eax
  800e3f:	e8 3d ff ff ff       	call   800d81 <fd_lookup>
  800e44:	89 c3                	mov    %eax,%ebx
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 05                	js     800e52 <fd_close+0x30>
	    || fd != fd2)
  800e4d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e50:	74 16                	je     800e68 <fd_close+0x46>
		return (must_exist ? r : 0);
  800e52:	89 f8                	mov    %edi,%eax
  800e54:	84 c0                	test   %al,%al
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	0f 44 d8             	cmove  %eax,%ebx
}
  800e5e:	89 d8                	mov    %ebx,%eax
  800e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e6e:	50                   	push   %eax
  800e6f:	ff 36                	push   (%esi)
  800e71:	e8 5b ff ff ff       	call   800dd1 <dev_lookup>
  800e76:	89 c3                	mov    %eax,%ebx
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	78 1a                	js     800e99 <fd_close+0x77>
		if (dev->dev_close)
  800e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e82:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	74 0b                	je     800e99 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	56                   	push   %esi
  800e92:	ff d0                	call   *%eax
  800e94:	89 c3                	mov    %eax,%ebx
  800e96:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	56                   	push   %esi
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 fa fc ff ff       	call   800b9e <sys_page_unmap>
	return r;
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	eb b5                	jmp    800e5e <fd_close+0x3c>

00800ea9 <close>:

int
close(int fdnum)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb2:	50                   	push   %eax
  800eb3:	ff 75 08             	push   0x8(%ebp)
  800eb6:	e8 c6 fe ff ff       	call   800d81 <fd_lookup>
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 02                	jns    800ec4 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    
		return fd_close(fd, 1);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	6a 01                	push   $0x1
  800ec9:	ff 75 f4             	push   -0xc(%ebp)
  800ecc:	e8 51 ff ff ff       	call   800e22 <fd_close>
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	eb ec                	jmp    800ec2 <close+0x19>

00800ed6 <close_all>:

void
close_all(void)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	53                   	push   %ebx
  800ee6:	e8 be ff ff ff       	call   800ea9 <close>
	for (i = 0; i < MAXFD; i++)
  800eeb:	83 c3 01             	add    $0x1,%ebx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	83 fb 20             	cmp    $0x20,%ebx
  800ef4:	75 ec                	jne    800ee2 <close_all+0xc>
}
  800ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f07:	50                   	push   %eax
  800f08:	ff 75 08             	push   0x8(%ebp)
  800f0b:	e8 71 fe ff ff       	call   800d81 <fd_lookup>
  800f10:	89 c3                	mov    %eax,%ebx
  800f12:	83 c4 10             	add    $0x10,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	78 7f                	js     800f98 <dup+0x9d>
		return r;
	close(newfdnum);
  800f19:	83 ec 0c             	sub    $0xc,%esp
  800f1c:	ff 75 0c             	push   0xc(%ebp)
  800f1f:	e8 85 ff ff ff       	call   800ea9 <close>

	newfd = INDEX2FD(newfdnum);
  800f24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f27:	c1 e6 0c             	shl    $0xc,%esi
  800f2a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f33:	89 3c 24             	mov    %edi,(%esp)
  800f36:	e8 df fd ff ff       	call   800d1a <fd2data>
  800f3b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f3d:	89 34 24             	mov    %esi,(%esp)
  800f40:	e8 d5 fd ff ff       	call   800d1a <fd2data>
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	c1 e8 16             	shr    $0x16,%eax
  800f50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f57:	a8 01                	test   $0x1,%al
  800f59:	74 11                	je     800f6c <dup+0x71>
  800f5b:	89 d8                	mov    %ebx,%eax
  800f5d:	c1 e8 0c             	shr    $0xc,%eax
  800f60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	75 36                	jne    800fa2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f6c:	89 f8                	mov    %edi,%eax
  800f6e:	c1 e8 0c             	shr    $0xc,%eax
  800f71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f80:	50                   	push   %eax
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	57                   	push   %edi
  800f85:	6a 00                	push   $0x0
  800f87:	e8 d0 fb ff ff       	call   800b5c <sys_page_map>
  800f8c:	89 c3                	mov    %eax,%ebx
  800f8e:	83 c4 20             	add    $0x20,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 33                	js     800fc8 <dup+0xcd>
		goto err;

	return newfdnum;
  800f95:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb1:	50                   	push   %eax
  800fb2:	ff 75 d4             	push   -0x2c(%ebp)
  800fb5:	6a 00                	push   $0x0
  800fb7:	53                   	push   %ebx
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 9d fb ff ff       	call   800b5c <sys_page_map>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 20             	add    $0x20,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 a4                	jns    800f6c <dup+0x71>
	sys_page_unmap(0, newfd);
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 cb fb ff ff       	call   800b9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	ff 75 d4             	push   -0x2c(%ebp)
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 be fb ff ff       	call   800b9e <sys_page_unmap>
	return r;
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	eb b3                	jmp    800f98 <dup+0x9d>

00800fe5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	56                   	push   %esi
  800fe9:	53                   	push   %ebx
  800fea:	83 ec 18             	sub    $0x18,%esp
  800fed:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ff0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff3:	50                   	push   %eax
  800ff4:	56                   	push   %esi
  800ff5:	e8 87 fd ff ff       	call   800d81 <fd_lookup>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 3c                	js     80103d <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801001:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801004:	83 ec 08             	sub    $0x8,%esp
  801007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	ff 33                	push   (%ebx)
  80100d:	e8 bf fd ff ff       	call   800dd1 <dev_lookup>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 24                	js     80103d <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801019:	8b 43 08             	mov    0x8(%ebx),%eax
  80101c:	83 e0 03             	and    $0x3,%eax
  80101f:	83 f8 01             	cmp    $0x1,%eax
  801022:	74 20                	je     801044 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	8b 40 08             	mov    0x8(%eax),%eax
  80102a:	85 c0                	test   %eax,%eax
  80102c:	74 37                	je     801065 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	ff 75 10             	push   0x10(%ebp)
  801034:	ff 75 0c             	push   0xc(%ebp)
  801037:	53                   	push   %ebx
  801038:	ff d0                	call   *%eax
  80103a:	83 c4 10             	add    $0x10,%esp
}
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801044:	a1 00 40 80 00       	mov    0x804000,%eax
  801049:	8b 40 48             	mov    0x48(%eax),%eax
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	56                   	push   %esi
  801050:	50                   	push   %eax
  801051:	68 2d 21 80 00       	push   $0x80212d
  801056:	e8 e8 f0 ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801063:	eb d8                	jmp    80103d <read+0x58>
		return -E_NOT_SUPP;
  801065:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80106a:	eb d1                	jmp    80103d <read+0x58>

0080106c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	8b 7d 08             	mov    0x8(%ebp),%edi
  801078:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801080:	eb 02                	jmp    801084 <readn+0x18>
  801082:	01 c3                	add    %eax,%ebx
  801084:	39 f3                	cmp    %esi,%ebx
  801086:	73 21                	jae    8010a9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	89 f0                	mov    %esi,%eax
  80108d:	29 d8                	sub    %ebx,%eax
  80108f:	50                   	push   %eax
  801090:	89 d8                	mov    %ebx,%eax
  801092:	03 45 0c             	add    0xc(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	57                   	push   %edi
  801097:	e8 49 ff ff ff       	call   800fe5 <read>
		if (m < 0)
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 04                	js     8010a7 <readn+0x3b>
			return m;
		if (m == 0)
  8010a3:	75 dd                	jne    801082 <readn+0x16>
  8010a5:	eb 02                	jmp    8010a9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 18             	sub    $0x18,%esp
  8010bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	53                   	push   %ebx
  8010c3:	e8 b9 fc ff ff       	call   800d81 <fd_lookup>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 37                	js     801106 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cf:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010d2:	83 ec 08             	sub    $0x8,%esp
  8010d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	ff 36                	push   (%esi)
  8010db:	e8 f1 fc ff ff       	call   800dd1 <dev_lookup>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 1f                	js     801106 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010e7:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8010eb:	74 20                	je     80110d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 37                	je     80112e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	ff 75 10             	push   0x10(%ebp)
  8010fd:	ff 75 0c             	push   0xc(%ebp)
  801100:	56                   	push   %esi
  801101:	ff d0                	call   *%eax
  801103:	83 c4 10             	add    $0x10,%esp
}
  801106:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80110d:	a1 00 40 80 00       	mov    0x804000,%eax
  801112:	8b 40 48             	mov    0x48(%eax),%eax
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	53                   	push   %ebx
  801119:	50                   	push   %eax
  80111a:	68 49 21 80 00       	push   $0x802149
  80111f:	e8 1f f0 ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112c:	eb d8                	jmp    801106 <write+0x53>
		return -E_NOT_SUPP;
  80112e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801133:	eb d1                	jmp    801106 <write+0x53>

00801135 <seek>:

int
seek(int fdnum, off_t offset)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	ff 75 08             	push   0x8(%ebp)
  801142:	e8 3a fc ff ff       	call   800d81 <fd_lookup>
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 0e                	js     80115c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80114e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801154:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 18             	sub    $0x18,%esp
  801166:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801169:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	53                   	push   %ebx
  80116e:	e8 0e fc ff ff       	call   800d81 <fd_lookup>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	78 34                	js     8011ae <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	ff 36                	push   (%esi)
  801186:	e8 46 fc ff ff       	call   800dd1 <dev_lookup>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 1c                	js     8011ae <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801192:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801196:	74 1d                	je     8011b5 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119b:	8b 40 18             	mov    0x18(%eax),%eax
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	74 34                	je     8011d6 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	ff 75 0c             	push   0xc(%ebp)
  8011a8:	56                   	push   %esi
  8011a9:	ff d0                	call   *%eax
  8011ab:	83 c4 10             	add    $0x10,%esp
}
  8011ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8011b5:	a1 00 40 80 00       	mov    0x804000,%eax
  8011ba:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011bd:	83 ec 04             	sub    $0x4,%esp
  8011c0:	53                   	push   %ebx
  8011c1:	50                   	push   %eax
  8011c2:	68 0c 21 80 00       	push   $0x80210c
  8011c7:	e8 77 ef ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d4:	eb d8                	jmp    8011ae <ftruncate+0x50>
		return -E_NOT_SUPP;
  8011d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011db:	eb d1                	jmp    8011ae <ftruncate+0x50>

008011dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 18             	sub    $0x18,%esp
  8011e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	ff 75 08             	push   0x8(%ebp)
  8011ef:	e8 8d fb ff ff       	call   800d81 <fd_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 49                	js     801244 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 36                	push   (%esi)
  801207:	e8 c5 fb ff ff       	call   800dd1 <dev_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 31                	js     801244 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801213:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801216:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80121a:	74 2f                	je     80124b <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80121c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80121f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801226:	00 00 00 
	stat->st_isdir = 0;
  801229:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801230:	00 00 00 
	stat->st_dev = dev;
  801233:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	53                   	push   %ebx
  80123d:	56                   	push   %esi
  80123e:	ff 50 14             	call   *0x14(%eax)
  801241:	83 c4 10             	add    $0x10,%esp
}
  801244:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    
		return -E_NOT_SUPP;
  80124b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801250:	eb f2                	jmp    801244 <fstat+0x67>

00801252 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	6a 00                	push   $0x0
  80125c:	ff 75 08             	push   0x8(%ebp)
  80125f:	e8 e4 01 00 00       	call   801448 <open>
  801264:	89 c3                	mov    %eax,%ebx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 1b                	js     801288 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	ff 75 0c             	push   0xc(%ebp)
  801273:	50                   	push   %eax
  801274:	e8 64 ff ff ff       	call   8011dd <fstat>
  801279:	89 c6                	mov    %eax,%esi
	close(fd);
  80127b:	89 1c 24             	mov    %ebx,(%esp)
  80127e:	e8 26 fc ff ff       	call   800ea9 <close>
	return r;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	89 f3                	mov    %esi,%ebx
}
  801288:	89 d8                	mov    %ebx,%eax
  80128a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	89 c6                	mov    %eax,%esi
  801298:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80129a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8012a1:	74 27                	je     8012ca <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012a3:	6a 07                	push   $0x7
  8012a5:	68 00 50 80 00       	push   $0x805000
  8012aa:	56                   	push   %esi
  8012ab:	ff 35 00 60 80 00    	push   0x806000
  8012b1:	e8 a2 07 00 00       	call   801a58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012b6:	83 c4 0c             	add    $0xc,%esp
  8012b9:	6a 00                	push   $0x0
  8012bb:	53                   	push   %ebx
  8012bc:	6a 00                	push   $0x0
  8012be:	e8 2e 07 00 00       	call   8019f1 <ipc_recv>
}
  8012c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	6a 01                	push   $0x1
  8012cf:	e8 d8 07 00 00       	call   801aac <ipc_find_env>
  8012d4:	a3 00 60 80 00       	mov    %eax,0x806000
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	eb c5                	jmp    8012a3 <fsipc+0x12>

008012de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801301:	e8 8b ff ff ff       	call   801291 <fsipc>
}
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <devfile_flush>:
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	8b 40 0c             	mov    0xc(%eax),%eax
  801314:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801319:	ba 00 00 00 00       	mov    $0x0,%edx
  80131e:	b8 06 00 00 00       	mov    $0x6,%eax
  801323:	e8 69 ff ff ff       	call   801291 <fsipc>
}
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <devfile_stat>:
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	53                   	push   %ebx
  80132e:	83 ec 04             	sub    $0x4,%esp
  801331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801334:	8b 45 08             	mov    0x8(%ebp),%eax
  801337:	8b 40 0c             	mov    0xc(%eax),%eax
  80133a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80133f:	ba 00 00 00 00       	mov    $0x0,%edx
  801344:	b8 05 00 00 00       	mov    $0x5,%eax
  801349:	e8 43 ff ff ff       	call   801291 <fsipc>
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 2c                	js     80137e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	68 00 50 80 00       	push   $0x805000
  80135a:	53                   	push   %ebx
  80135b:	e8 bd f3 ff ff       	call   80071d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801360:	a1 80 50 80 00       	mov    0x805080,%eax
  801365:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80136b:	a1 84 50 80 00       	mov    0x805084,%eax
  801370:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <devfile_write>:
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	8b 45 10             	mov    0x10(%ebp),%eax
  80138c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801391:	39 d0                	cmp    %edx,%eax
  801393:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	8b 52 0c             	mov    0xc(%edx),%edx
  80139c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013a2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013a7:	50                   	push   %eax
  8013a8:	ff 75 0c             	push   0xc(%ebp)
  8013ab:	68 08 50 80 00       	push   $0x805008
  8013b0:	e8 fe f4 ff ff       	call   8008b3 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8013b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8013bf:	e8 cd fe ff ff       	call   801291 <fsipc>
}
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <devfile_read>:
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013d9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013df:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8013e9:	e8 a3 fe ff ff       	call   801291 <fsipc>
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 1f                	js     801413 <devfile_read+0x4d>
	assert(r <= n);
  8013f4:	39 f0                	cmp    %esi,%eax
  8013f6:	77 24                	ja     80141c <devfile_read+0x56>
	assert(r <= PGSIZE);
  8013f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013fd:	7f 33                	jg     801432 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8013ff:	83 ec 04             	sub    $0x4,%esp
  801402:	50                   	push   %eax
  801403:	68 00 50 80 00       	push   $0x805000
  801408:	ff 75 0c             	push   0xc(%ebp)
  80140b:	e8 a3 f4 ff ff       	call   8008b3 <memmove>
	return r;
  801410:	83 c4 10             	add    $0x10,%esp
}
  801413:	89 d8                	mov    %ebx,%eax
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    
	assert(r <= n);
  80141c:	68 78 21 80 00       	push   $0x802178
  801421:	68 7f 21 80 00       	push   $0x80217f
  801426:	6a 7c                	push   $0x7c
  801428:	68 94 21 80 00       	push   $0x802194
  80142d:	e8 79 05 00 00       	call   8019ab <_panic>
	assert(r <= PGSIZE);
  801432:	68 9f 21 80 00       	push   $0x80219f
  801437:	68 7f 21 80 00       	push   $0x80217f
  80143c:	6a 7d                	push   $0x7d
  80143e:	68 94 21 80 00       	push   $0x802194
  801443:	e8 63 05 00 00       	call   8019ab <_panic>

00801448 <open>:
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	56                   	push   %esi
  80144c:	53                   	push   %ebx
  80144d:	83 ec 1c             	sub    $0x1c,%esp
  801450:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801453:	56                   	push   %esi
  801454:	e8 89 f2 ff ff       	call   8006e2 <strlen>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801461:	7f 6c                	jg     8014cf <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	e8 c2 f8 ff ff       	call   800d31 <fd_alloc>
  80146f:	89 c3                	mov    %eax,%ebx
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 3c                	js     8014b4 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	56                   	push   %esi
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	e8 97 f2 ff ff       	call   80071d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801486:	8b 45 0c             	mov    0xc(%ebp),%eax
  801489:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80148e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801491:	b8 01 00 00 00       	mov    $0x1,%eax
  801496:	e8 f6 fd ff ff       	call   801291 <fsipc>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 19                	js     8014bd <open+0x75>
	return fd2num(fd);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	ff 75 f4             	push   -0xc(%ebp)
  8014aa:	e8 5b f8 ff ff       	call   800d0a <fd2num>
  8014af:	89 c3                	mov    %eax,%ebx
  8014b1:	83 c4 10             	add    $0x10,%esp
}
  8014b4:	89 d8                	mov    %ebx,%eax
  8014b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5e                   	pop    %esi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    
		fd_close(fd, 0);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	6a 00                	push   $0x0
  8014c2:	ff 75 f4             	push   -0xc(%ebp)
  8014c5:	e8 58 f9 ff ff       	call   800e22 <fd_close>
		return r;
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	eb e5                	jmp    8014b4 <open+0x6c>
		return -E_BAD_PATH;
  8014cf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014d4:	eb de                	jmp    8014b4 <open+0x6c>

008014d6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e6:	e8 a6 fd ff ff       	call   801291 <fsipc>
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
  8014f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	ff 75 08             	push   0x8(%ebp)
  8014fb:	e8 1a f8 ff ff       	call   800d1a <fd2data>
  801500:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801502:	83 c4 08             	add    $0x8,%esp
  801505:	68 ab 21 80 00       	push   $0x8021ab
  80150a:	53                   	push   %ebx
  80150b:	e8 0d f2 ff ff       	call   80071d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801510:	8b 46 04             	mov    0x4(%esi),%eax
  801513:	2b 06                	sub    (%esi),%eax
  801515:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80151b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801522:	00 00 00 
	stat->st_dev = &devpipe;
  801525:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80152c:	30 80 00 
	return 0;
}
  80152f:	b8 00 00 00 00       	mov    $0x0,%eax
  801534:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801537:	5b                   	pop    %ebx
  801538:	5e                   	pop    %esi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801545:	53                   	push   %ebx
  801546:	6a 00                	push   $0x0
  801548:	e8 51 f6 ff ff       	call   800b9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80154d:	89 1c 24             	mov    %ebx,(%esp)
  801550:	e8 c5 f7 ff ff       	call   800d1a <fd2data>
  801555:	83 c4 08             	add    $0x8,%esp
  801558:	50                   	push   %eax
  801559:	6a 00                	push   $0x0
  80155b:	e8 3e f6 ff ff       	call   800b9e <sys_page_unmap>
}
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <_pipeisclosed>:
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	57                   	push   %edi
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 1c             	sub    $0x1c,%esp
  80156e:	89 c7                	mov    %eax,%edi
  801570:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801572:	a1 00 40 80 00       	mov    0x804000,%eax
  801577:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	57                   	push   %edi
  80157e:	e8 62 05 00 00       	call   801ae5 <pageref>
  801583:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801586:	89 34 24             	mov    %esi,(%esp)
  801589:	e8 57 05 00 00       	call   801ae5 <pageref>
		nn = thisenv->env_runs;
  80158e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801594:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	39 cb                	cmp    %ecx,%ebx
  80159c:	74 1b                	je     8015b9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80159e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015a1:	75 cf                	jne    801572 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015a3:	8b 42 58             	mov    0x58(%edx),%eax
  8015a6:	6a 01                	push   $0x1
  8015a8:	50                   	push   %eax
  8015a9:	53                   	push   %ebx
  8015aa:	68 b2 21 80 00       	push   $0x8021b2
  8015af:	e8 8f eb ff ff       	call   800143 <cprintf>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	eb b9                	jmp    801572 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015b9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015bc:	0f 94 c0             	sete   %al
  8015bf:	0f b6 c0             	movzbl %al,%eax
}
  8015c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5f                   	pop    %edi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <devpipe_write>:
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 28             	sub    $0x28,%esp
  8015d3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8015d6:	56                   	push   %esi
  8015d7:	e8 3e f7 ff ff       	call   800d1a <fd2data>
  8015dc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8015e6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015e9:	75 09                	jne    8015f4 <devpipe_write+0x2a>
	return i;
  8015eb:	89 f8                	mov    %edi,%eax
  8015ed:	eb 23                	jmp    801612 <devpipe_write+0x48>
			sys_yield();
  8015ef:	e8 06 f5 ff ff       	call   800afa <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f7:	8b 0b                	mov    (%ebx),%ecx
  8015f9:	8d 51 20             	lea    0x20(%ecx),%edx
  8015fc:	39 d0                	cmp    %edx,%eax
  8015fe:	72 1a                	jb     80161a <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801600:	89 da                	mov    %ebx,%edx
  801602:	89 f0                	mov    %esi,%eax
  801604:	e8 5c ff ff ff       	call   801565 <_pipeisclosed>
  801609:	85 c0                	test   %eax,%eax
  80160b:	74 e2                	je     8015ef <devpipe_write+0x25>
				return 0;
  80160d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80161a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801621:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801624:	89 c2                	mov    %eax,%edx
  801626:	c1 fa 1f             	sar    $0x1f,%edx
  801629:	89 d1                	mov    %edx,%ecx
  80162b:	c1 e9 1b             	shr    $0x1b,%ecx
  80162e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801631:	83 e2 1f             	and    $0x1f,%edx
  801634:	29 ca                	sub    %ecx,%edx
  801636:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80163a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80163e:	83 c0 01             	add    $0x1,%eax
  801641:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801644:	83 c7 01             	add    $0x1,%edi
  801647:	eb 9d                	jmp    8015e6 <devpipe_write+0x1c>

00801649 <devpipe_read>:
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	57                   	push   %edi
  80164d:	56                   	push   %esi
  80164e:	53                   	push   %ebx
  80164f:	83 ec 18             	sub    $0x18,%esp
  801652:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801655:	57                   	push   %edi
  801656:	e8 bf f6 ff ff       	call   800d1a <fd2data>
  80165b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	be 00 00 00 00       	mov    $0x0,%esi
  801665:	3b 75 10             	cmp    0x10(%ebp),%esi
  801668:	75 13                	jne    80167d <devpipe_read+0x34>
	return i;
  80166a:	89 f0                	mov    %esi,%eax
  80166c:	eb 02                	jmp    801670 <devpipe_read+0x27>
				return i;
  80166e:	89 f0                	mov    %esi,%eax
}
  801670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801673:	5b                   	pop    %ebx
  801674:	5e                   	pop    %esi
  801675:	5f                   	pop    %edi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    
			sys_yield();
  801678:	e8 7d f4 ff ff       	call   800afa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80167d:	8b 03                	mov    (%ebx),%eax
  80167f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801682:	75 18                	jne    80169c <devpipe_read+0x53>
			if (i > 0)
  801684:	85 f6                	test   %esi,%esi
  801686:	75 e6                	jne    80166e <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801688:	89 da                	mov    %ebx,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	e8 d4 fe ff ff       	call   801565 <_pipeisclosed>
  801691:	85 c0                	test   %eax,%eax
  801693:	74 e3                	je     801678 <devpipe_read+0x2f>
				return 0;
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	eb d4                	jmp    801670 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80169c:	99                   	cltd   
  80169d:	c1 ea 1b             	shr    $0x1b,%edx
  8016a0:	01 d0                	add    %edx,%eax
  8016a2:	83 e0 1f             	and    $0x1f,%eax
  8016a5:	29 d0                	sub    %edx,%eax
  8016a7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016af:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016b2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016b5:	83 c6 01             	add    $0x1,%esi
  8016b8:	eb ab                	jmp    801665 <devpipe_read+0x1c>

008016ba <pipe>:
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c5:	50                   	push   %eax
  8016c6:	e8 66 f6 ff ff       	call   800d31 <fd_alloc>
  8016cb:	89 c3                	mov    %eax,%ebx
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	0f 88 23 01 00 00    	js     8017fb <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	68 07 04 00 00       	push   $0x407
  8016e0:	ff 75 f4             	push   -0xc(%ebp)
  8016e3:	6a 00                	push   $0x0
  8016e5:	e8 2f f4 ff ff       	call   800b19 <sys_page_alloc>
  8016ea:	89 c3                	mov    %eax,%ebx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	0f 88 04 01 00 00    	js     8017fb <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	e8 2e f6 ff ff       	call   800d31 <fd_alloc>
  801703:	89 c3                	mov    %eax,%ebx
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	0f 88 db 00 00 00    	js     8017eb <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801710:	83 ec 04             	sub    $0x4,%esp
  801713:	68 07 04 00 00       	push   $0x407
  801718:	ff 75 f0             	push   -0x10(%ebp)
  80171b:	6a 00                	push   $0x0
  80171d:	e8 f7 f3 ff ff       	call   800b19 <sys_page_alloc>
  801722:	89 c3                	mov    %eax,%ebx
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	0f 88 bc 00 00 00    	js     8017eb <pipe+0x131>
	va = fd2data(fd0);
  80172f:	83 ec 0c             	sub    $0xc,%esp
  801732:	ff 75 f4             	push   -0xc(%ebp)
  801735:	e8 e0 f5 ff ff       	call   800d1a <fd2data>
  80173a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173c:	83 c4 0c             	add    $0xc,%esp
  80173f:	68 07 04 00 00       	push   $0x407
  801744:	50                   	push   %eax
  801745:	6a 00                	push   $0x0
  801747:	e8 cd f3 ff ff       	call   800b19 <sys_page_alloc>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	0f 88 82 00 00 00    	js     8017db <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801759:	83 ec 0c             	sub    $0xc,%esp
  80175c:	ff 75 f0             	push   -0x10(%ebp)
  80175f:	e8 b6 f5 ff ff       	call   800d1a <fd2data>
  801764:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80176b:	50                   	push   %eax
  80176c:	6a 00                	push   $0x0
  80176e:	56                   	push   %esi
  80176f:	6a 00                	push   $0x0
  801771:	e8 e6 f3 ff ff       	call   800b5c <sys_page_map>
  801776:	89 c3                	mov    %eax,%ebx
  801778:	83 c4 20             	add    $0x20,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 4e                	js     8017cd <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80177f:	a1 20 30 80 00       	mov    0x803020,%eax
  801784:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801787:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801789:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178c:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801793:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801796:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801798:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	ff 75 f4             	push   -0xc(%ebp)
  8017a8:	e8 5d f5 ff ff       	call   800d0a <fd2num>
  8017ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017b2:	83 c4 04             	add    $0x4,%esp
  8017b5:	ff 75 f0             	push   -0x10(%ebp)
  8017b8:	e8 4d f5 ff ff       	call   800d0a <fd2num>
  8017bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017cb:	eb 2e                	jmp    8017fb <pipe+0x141>
	sys_page_unmap(0, va);
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	56                   	push   %esi
  8017d1:	6a 00                	push   $0x0
  8017d3:	e8 c6 f3 ff ff       	call   800b9e <sys_page_unmap>
  8017d8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	ff 75 f0             	push   -0x10(%ebp)
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 b6 f3 ff ff       	call   800b9e <sys_page_unmap>
  8017e8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	ff 75 f4             	push   -0xc(%ebp)
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 a6 f3 ff ff       	call   800b9e <sys_page_unmap>
  8017f8:	83 c4 10             	add    $0x10,%esp
}
  8017fb:	89 d8                	mov    %ebx,%eax
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <pipeisclosed>:
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	50                   	push   %eax
  80180e:	ff 75 08             	push   0x8(%ebp)
  801811:	e8 6b f5 ff ff       	call   800d81 <fd_lookup>
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 18                	js     801835 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	ff 75 f4             	push   -0xc(%ebp)
  801823:	e8 f2 f4 ff ff       	call   800d1a <fd2data>
  801828:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182d:	e8 33 fd ff ff       	call   801565 <_pipeisclosed>
  801832:	83 c4 10             	add    $0x10,%esp
}
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
  80183c:	c3                   	ret    

0080183d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801843:	68 ca 21 80 00       	push   $0x8021ca
  801848:	ff 75 0c             	push   0xc(%ebp)
  80184b:	e8 cd ee ff ff       	call   80071d <strcpy>
	return 0;
}
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <devcons_write>:
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	57                   	push   %edi
  80185b:	56                   	push   %esi
  80185c:	53                   	push   %ebx
  80185d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801863:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801868:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80186e:	eb 2e                	jmp    80189e <devcons_write+0x47>
		m = n - tot;
  801870:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801873:	29 f3                	sub    %esi,%ebx
  801875:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80187a:	39 c3                	cmp    %eax,%ebx
  80187c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	53                   	push   %ebx
  801883:	89 f0                	mov    %esi,%eax
  801885:	03 45 0c             	add    0xc(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	57                   	push   %edi
  80188a:	e8 24 f0 ff ff       	call   8008b3 <memmove>
		sys_cputs(buf, m);
  80188f:	83 c4 08             	add    $0x8,%esp
  801892:	53                   	push   %ebx
  801893:	57                   	push   %edi
  801894:	e8 c4 f1 ff ff       	call   800a5d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801899:	01 de                	add    %ebx,%esi
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018a1:	72 cd                	jb     801870 <devcons_write+0x19>
}
  8018a3:	89 f0                	mov    %esi,%eax
  8018a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5f                   	pop    %edi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <devcons_read>:
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8018b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018bc:	75 07                	jne    8018c5 <devcons_read+0x18>
  8018be:	eb 1f                	jmp    8018df <devcons_read+0x32>
		sys_yield();
  8018c0:	e8 35 f2 ff ff       	call   800afa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8018c5:	e8 b1 f1 ff ff       	call   800a7b <sys_cgetc>
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	74 f2                	je     8018c0 <devcons_read+0x13>
	if (c < 0)
  8018ce:	78 0f                	js     8018df <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8018d0:	83 f8 04             	cmp    $0x4,%eax
  8018d3:	74 0c                	je     8018e1 <devcons_read+0x34>
	*(char*)vbuf = c;
  8018d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d8:	88 02                	mov    %al,(%edx)
	return 1;
  8018da:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    
		return 0;
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e6:	eb f7                	jmp    8018df <devcons_read+0x32>

008018e8 <cputchar>:
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8018f4:	6a 01                	push   $0x1
  8018f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	e8 5e f1 ff ff       	call   800a5d <sys_cputs>
}
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <getchar>:
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80190a:	6a 01                	push   $0x1
  80190c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	6a 00                	push   $0x0
  801912:	e8 ce f6 ff ff       	call   800fe5 <read>
	if (r < 0)
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 06                	js     801924 <getchar+0x20>
	if (r < 1)
  80191e:	74 06                	je     801926 <getchar+0x22>
	return c;
  801920:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    
		return -E_EOF;
  801926:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80192b:	eb f7                	jmp    801924 <getchar+0x20>

0080192d <iscons>:
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801936:	50                   	push   %eax
  801937:	ff 75 08             	push   0x8(%ebp)
  80193a:	e8 42 f4 ff ff       	call   800d81 <fd_lookup>
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	78 11                	js     801957 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801946:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801949:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80194f:	39 10                	cmp    %edx,(%eax)
  801951:	0f 94 c0             	sete   %al
  801954:	0f b6 c0             	movzbl %al,%eax
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <opencons>:
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80195f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	e8 c9 f3 ff ff       	call   800d31 <fd_alloc>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 3a                	js     8019a9 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	68 07 04 00 00       	push   $0x407
  801977:	ff 75 f4             	push   -0xc(%ebp)
  80197a:	6a 00                	push   $0x0
  80197c:	e8 98 f1 ff ff       	call   800b19 <sys_page_alloc>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 21                	js     8019a9 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801991:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	50                   	push   %eax
  8019a1:	e8 64 f3 ff ff       	call   800d0a <fd2num>
  8019a6:	83 c4 10             	add    $0x10,%esp
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019b3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019b9:	e8 1d f1 ff ff       	call   800adb <sys_getenvid>
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff 75 0c             	push   0xc(%ebp)
  8019c4:	ff 75 08             	push   0x8(%ebp)
  8019c7:	56                   	push   %esi
  8019c8:	50                   	push   %eax
  8019c9:	68 d8 21 80 00       	push   $0x8021d8
  8019ce:	e8 70 e7 ff ff       	call   800143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019d3:	83 c4 18             	add    $0x18,%esp
  8019d6:	53                   	push   %ebx
  8019d7:	ff 75 10             	push   0x10(%ebp)
  8019da:	e8 13 e7 ff ff       	call   8000f2 <vcprintf>
	cprintf("\n");
  8019df:	c7 04 24 c3 21 80 00 	movl   $0x8021c3,(%esp)
  8019e6:	e8 58 e7 ff ff       	call   800143 <cprintf>
  8019eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019ee:	cc                   	int3   
  8019ef:	eb fd                	jmp    8019ee <_panic+0x43>

008019f1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a06:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	50                   	push   %eax
  801a0d:	e8 b7 f2 ff ff       	call   800cc9 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 f6                	test   %esi,%esi
  801a17:	74 14                	je     801a2d <ipc_recv+0x3c>
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 09                	js     801a2b <ipc_recv+0x3a>
  801a22:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a28:	8b 52 74             	mov    0x74(%edx),%edx
  801a2b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a2d:	85 db                	test   %ebx,%ebx
  801a2f:	74 14                	je     801a45 <ipc_recv+0x54>
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 09                	js     801a43 <ipc_recv+0x52>
  801a3a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a40:	8b 52 78             	mov    0x78(%edx),%edx
  801a43:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 08                	js     801a51 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a49:	a1 00 40 80 00       	mov    0x804000,%eax
  801a4e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a71:	0f 44 d8             	cmove  %eax,%ebx
  801a74:	eb 05                	jmp    801a7b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a76:	e8 7f f0 ff ff       	call   800afa <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a7b:	ff 75 14             	push   0x14(%ebp)
  801a7e:	53                   	push   %ebx
  801a7f:	56                   	push   %esi
  801a80:	57                   	push   %edi
  801a81:	e8 20 f2 ff ff       	call   800ca6 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8c:	74 e8                	je     801a76 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 08                	js     801a9a <ipc_send+0x42>
	}while (r<0);

}
  801a92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5f                   	pop    %edi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a9a:	50                   	push   %eax
  801a9b:	68 fb 21 80 00       	push   $0x8021fb
  801aa0:	6a 3d                	push   $0x3d
  801aa2:	68 0f 22 80 00       	push   $0x80220f
  801aa7:	e8 ff fe ff ff       	call   8019ab <_panic>

00801aac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac0:	8b 52 50             	mov    0x50(%edx),%edx
  801ac3:	39 ca                	cmp    %ecx,%edx
  801ac5:	74 11                	je     801ad8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ac7:	83 c0 01             	add    $0x1,%eax
  801aca:	3d 00 04 00 00       	cmp    $0x400,%eax
  801acf:	75 e6                	jne    801ab7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad6:	eb 0b                	jmp    801ae3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801ad8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aeb:	89 c2                	mov    %eax,%edx
  801aed:	c1 ea 16             	shr    $0x16,%edx
  801af0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801af7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801afc:	f6 c1 01             	test   $0x1,%cl
  801aff:	74 1c                	je     801b1d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b01:	c1 e8 0c             	shr    $0xc,%eax
  801b04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b0b:	a8 01                	test   $0x1,%al
  801b0d:	74 0e                	je     801b1d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0f:	c1 e8 0c             	shr    $0xc,%eax
  801b12:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b19:	ef 
  801b1a:	0f b7 d2             	movzwl %dx,%edx
}
  801b1d:	89 d0                	mov    %edx,%eax
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    
  801b21:	66 90                	xchg   %ax,%ax
  801b23:	66 90                	xchg   %ax,%ax
  801b25:	66 90                	xchg   %ax,%ax
  801b27:	66 90                	xchg   %ax,%ax
  801b29:	66 90                	xchg   %ax,%ax
  801b2b:	66 90                	xchg   %ax,%ax
  801b2d:	66 90                	xchg   %ax,%ax
  801b2f:	90                   	nop

00801b30 <__udivdi3>:
  801b30:	f3 0f 1e fb          	endbr32 
  801b34:	55                   	push   %ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 1c             	sub    $0x1c,%esp
  801b3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b43:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	75 19                	jne    801b68 <__udivdi3+0x38>
  801b4f:	39 f3                	cmp    %esi,%ebx
  801b51:	76 4d                	jbe    801ba0 <__udivdi3+0x70>
  801b53:	31 ff                	xor    %edi,%edi
  801b55:	89 e8                	mov    %ebp,%eax
  801b57:	89 f2                	mov    %esi,%edx
  801b59:	f7 f3                	div    %ebx
  801b5b:	89 fa                	mov    %edi,%edx
  801b5d:	83 c4 1c             	add    $0x1c,%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    
  801b65:	8d 76 00             	lea    0x0(%esi),%esi
  801b68:	39 f0                	cmp    %esi,%eax
  801b6a:	76 14                	jbe    801b80 <__udivdi3+0x50>
  801b6c:	31 ff                	xor    %edi,%edi
  801b6e:	31 c0                	xor    %eax,%eax
  801b70:	89 fa                	mov    %edi,%edx
  801b72:	83 c4 1c             	add    $0x1c,%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5f                   	pop    %edi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    
  801b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b80:	0f bd f8             	bsr    %eax,%edi
  801b83:	83 f7 1f             	xor    $0x1f,%edi
  801b86:	75 48                	jne    801bd0 <__udivdi3+0xa0>
  801b88:	39 f0                	cmp    %esi,%eax
  801b8a:	72 06                	jb     801b92 <__udivdi3+0x62>
  801b8c:	31 c0                	xor    %eax,%eax
  801b8e:	39 eb                	cmp    %ebp,%ebx
  801b90:	77 de                	ja     801b70 <__udivdi3+0x40>
  801b92:	b8 01 00 00 00       	mov    $0x1,%eax
  801b97:	eb d7                	jmp    801b70 <__udivdi3+0x40>
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	89 d9                	mov    %ebx,%ecx
  801ba2:	85 db                	test   %ebx,%ebx
  801ba4:	75 0b                	jne    801bb1 <__udivdi3+0x81>
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f3                	div    %ebx
  801baf:	89 c1                	mov    %eax,%ecx
  801bb1:	31 d2                	xor    %edx,%edx
  801bb3:	89 f0                	mov    %esi,%eax
  801bb5:	f7 f1                	div    %ecx
  801bb7:	89 c6                	mov    %eax,%esi
  801bb9:	89 e8                	mov    %ebp,%eax
  801bbb:	89 f7                	mov    %esi,%edi
  801bbd:	f7 f1                	div    %ecx
  801bbf:	89 fa                	mov    %edi,%edx
  801bc1:	83 c4 1c             	add    $0x1c,%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	89 f9                	mov    %edi,%ecx
  801bd2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bd7:	29 fa                	sub    %edi,%edx
  801bd9:	d3 e0                	shl    %cl,%eax
  801bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bdf:	89 d1                	mov    %edx,%ecx
  801be1:	89 d8                	mov    %ebx,%eax
  801be3:	d3 e8                	shr    %cl,%eax
  801be5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801be9:	09 c1                	or     %eax,%ecx
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bf1:	89 f9                	mov    %edi,%ecx
  801bf3:	d3 e3                	shl    %cl,%ebx
  801bf5:	89 d1                	mov    %edx,%ecx
  801bf7:	d3 e8                	shr    %cl,%eax
  801bf9:	89 f9                	mov    %edi,%ecx
  801bfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bff:	89 eb                	mov    %ebp,%ebx
  801c01:	d3 e6                	shl    %cl,%esi
  801c03:	89 d1                	mov    %edx,%ecx
  801c05:	d3 eb                	shr    %cl,%ebx
  801c07:	09 f3                	or     %esi,%ebx
  801c09:	89 c6                	mov    %eax,%esi
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 d8                	mov    %ebx,%eax
  801c0f:	f7 74 24 08          	divl   0x8(%esp)
  801c13:	89 d6                	mov    %edx,%esi
  801c15:	89 c3                	mov    %eax,%ebx
  801c17:	f7 64 24 0c          	mull   0xc(%esp)
  801c1b:	39 d6                	cmp    %edx,%esi
  801c1d:	72 19                	jb     801c38 <__udivdi3+0x108>
  801c1f:	89 f9                	mov    %edi,%ecx
  801c21:	d3 e5                	shl    %cl,%ebp
  801c23:	39 c5                	cmp    %eax,%ebp
  801c25:	73 04                	jae    801c2b <__udivdi3+0xfb>
  801c27:	39 d6                	cmp    %edx,%esi
  801c29:	74 0d                	je     801c38 <__udivdi3+0x108>
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	31 ff                	xor    %edi,%edi
  801c2f:	e9 3c ff ff ff       	jmp    801b70 <__udivdi3+0x40>
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c3b:	31 ff                	xor    %edi,%edi
  801c3d:	e9 2e ff ff ff       	jmp    801b70 <__udivdi3+0x40>
  801c42:	66 90                	xchg   %ax,%ax
  801c44:	66 90                	xchg   %ax,%ax
  801c46:	66 90                	xchg   %ax,%ax
  801c48:	66 90                	xchg   %ax,%ax
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__umoddi3>:
  801c50:	f3 0f 1e fb          	endbr32 
  801c54:	55                   	push   %ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
  801c5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c6b:	89 f0                	mov    %esi,%eax
  801c6d:	89 da                	mov    %ebx,%edx
  801c6f:	85 ff                	test   %edi,%edi
  801c71:	75 15                	jne    801c88 <__umoddi3+0x38>
  801c73:	39 dd                	cmp    %ebx,%ebp
  801c75:	76 39                	jbe    801cb0 <__umoddi3+0x60>
  801c77:	f7 f5                	div    %ebp
  801c79:	89 d0                	mov    %edx,%eax
  801c7b:	31 d2                	xor    %edx,%edx
  801c7d:	83 c4 1c             	add    $0x1c,%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	39 df                	cmp    %ebx,%edi
  801c8a:	77 f1                	ja     801c7d <__umoddi3+0x2d>
  801c8c:	0f bd cf             	bsr    %edi,%ecx
  801c8f:	83 f1 1f             	xor    $0x1f,%ecx
  801c92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c96:	75 40                	jne    801cd8 <__umoddi3+0x88>
  801c98:	39 df                	cmp    %ebx,%edi
  801c9a:	72 04                	jb     801ca0 <__umoddi3+0x50>
  801c9c:	39 f5                	cmp    %esi,%ebp
  801c9e:	77 dd                	ja     801c7d <__umoddi3+0x2d>
  801ca0:	89 da                	mov    %ebx,%edx
  801ca2:	89 f0                	mov    %esi,%eax
  801ca4:	29 e8                	sub    %ebp,%eax
  801ca6:	19 fa                	sbb    %edi,%edx
  801ca8:	eb d3                	jmp    801c7d <__umoddi3+0x2d>
  801caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb0:	89 e9                	mov    %ebp,%ecx
  801cb2:	85 ed                	test   %ebp,%ebp
  801cb4:	75 0b                	jne    801cc1 <__umoddi3+0x71>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f5                	div    %ebp
  801cbf:	89 c1                	mov    %eax,%ecx
  801cc1:	89 d8                	mov    %ebx,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  801cc5:	f7 f1                	div    %ecx
  801cc7:	89 f0                	mov    %esi,%eax
  801cc9:	f7 f1                	div    %ecx
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	31 d2                	xor    %edx,%edx
  801ccf:	eb ac                	jmp    801c7d <__umoddi3+0x2d>
  801cd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cdc:	ba 20 00 00 00       	mov    $0x20,%edx
  801ce1:	29 c2                	sub    %eax,%edx
  801ce3:	89 c1                	mov    %eax,%ecx
  801ce5:	89 e8                	mov    %ebp,%eax
  801ce7:	d3 e7                	shl    %cl,%edi
  801ce9:	89 d1                	mov    %edx,%ecx
  801ceb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cef:	d3 e8                	shr    %cl,%eax
  801cf1:	89 c1                	mov    %eax,%ecx
  801cf3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cf7:	09 f9                	or     %edi,%ecx
  801cf9:	89 df                	mov    %ebx,%edi
  801cfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	d3 e5                	shl    %cl,%ebp
  801d03:	89 d1                	mov    %edx,%ecx
  801d05:	d3 ef                	shr    %cl,%edi
  801d07:	89 c1                	mov    %eax,%ecx
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	d3 e3                	shl    %cl,%ebx
  801d0d:	89 d1                	mov    %edx,%ecx
  801d0f:	89 fa                	mov    %edi,%edx
  801d11:	d3 e8                	shr    %cl,%eax
  801d13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d18:	09 d8                	or     %ebx,%eax
  801d1a:	f7 74 24 08          	divl   0x8(%esp)
  801d1e:	89 d3                	mov    %edx,%ebx
  801d20:	d3 e6                	shl    %cl,%esi
  801d22:	f7 e5                	mul    %ebp
  801d24:	89 c7                	mov    %eax,%edi
  801d26:	89 d1                	mov    %edx,%ecx
  801d28:	39 d3                	cmp    %edx,%ebx
  801d2a:	72 06                	jb     801d32 <__umoddi3+0xe2>
  801d2c:	75 0e                	jne    801d3c <__umoddi3+0xec>
  801d2e:	39 c6                	cmp    %eax,%esi
  801d30:	73 0a                	jae    801d3c <__umoddi3+0xec>
  801d32:	29 e8                	sub    %ebp,%eax
  801d34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d38:	89 d1                	mov    %edx,%ecx
  801d3a:	89 c7                	mov    %eax,%edi
  801d3c:	89 f5                	mov    %esi,%ebp
  801d3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d42:	29 fd                	sub    %edi,%ebp
  801d44:	19 cb                	sbb    %ecx,%ebx
  801d46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	d3 e0                	shl    %cl,%eax
  801d4f:	89 f1                	mov    %esi,%ecx
  801d51:	d3 ed                	shr    %cl,%ebp
  801d53:	d3 eb                	shr    %cl,%ebx
  801d55:	09 e8                	or     %ebp,%eax
  801d57:	89 da                	mov    %ebx,%edx
  801d59:	83 c4 1c             	add    $0x1c,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    
