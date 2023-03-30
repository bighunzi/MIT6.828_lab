
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
  80003f:	68 40 22 80 00       	push   $0x802240
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
  80009a:	e8 9d 0e 00 00       	call   800f3c <close_all>
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
  8001a5:	e8 46 1e 00 00       	call   801ff0 <__udivdi3>
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
  8001e3:	e8 28 1f 00 00       	call   802110 <__umoddi3>
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	0f be 80 71 22 80 00 	movsbl 0x802271(%eax),%eax
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
  8002a5:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  800373:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80037a:	85 d2                	test   %edx,%edx
  80037c:	74 18                	je     800396 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80037e:	52                   	push   %edx
  80037f:	68 55 26 80 00       	push   $0x802655
  800384:	53                   	push   %ebx
  800385:	56                   	push   %esi
  800386:	e8 92 fe ff ff       	call   80021d <printfmt>
  80038b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800391:	e9 66 02 00 00       	jmp    8005fc <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800396:	50                   	push   %eax
  800397:	68 89 22 80 00       	push   $0x802289
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
  8003be:	b8 82 22 80 00       	mov    $0x802282,%eax
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
  800aca:	68 7f 25 80 00       	push   $0x80257f
  800acf:	6a 2a                	push   $0x2a
  800ad1:	68 9c 25 80 00       	push   $0x80259c
  800ad6:	e8 9e 13 00 00       	call   801e79 <_panic>

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
  800b4b:	68 7f 25 80 00       	push   $0x80257f
  800b50:	6a 2a                	push   $0x2a
  800b52:	68 9c 25 80 00       	push   $0x80259c
  800b57:	e8 1d 13 00 00       	call   801e79 <_panic>

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
  800b8d:	68 7f 25 80 00       	push   $0x80257f
  800b92:	6a 2a                	push   $0x2a
  800b94:	68 9c 25 80 00       	push   $0x80259c
  800b99:	e8 db 12 00 00       	call   801e79 <_panic>

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
  800bcf:	68 7f 25 80 00       	push   $0x80257f
  800bd4:	6a 2a                	push   $0x2a
  800bd6:	68 9c 25 80 00       	push   $0x80259c
  800bdb:	e8 99 12 00 00       	call   801e79 <_panic>

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
  800c11:	68 7f 25 80 00       	push   $0x80257f
  800c16:	6a 2a                	push   $0x2a
  800c18:	68 9c 25 80 00       	push   $0x80259c
  800c1d:	e8 57 12 00 00       	call   801e79 <_panic>

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
  800c53:	68 7f 25 80 00       	push   $0x80257f
  800c58:	6a 2a                	push   $0x2a
  800c5a:	68 9c 25 80 00       	push   $0x80259c
  800c5f:	e8 15 12 00 00       	call   801e79 <_panic>

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
  800c95:	68 7f 25 80 00       	push   $0x80257f
  800c9a:	6a 2a                	push   $0x2a
  800c9c:	68 9c 25 80 00       	push   $0x80259c
  800ca1:	e8 d3 11 00 00       	call   801e79 <_panic>

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
  800cf9:	68 7f 25 80 00       	push   $0x80257f
  800cfe:	6a 2a                	push   $0x2a
  800d00:	68 9c 25 80 00       	push   $0x80259c
  800d05:	e8 6f 11 00 00       	call   801e79 <_panic>

00800d0a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1a:	89 d1                	mov    %edx,%ecx
  800d1c:	89 d3                	mov    %edx,%ebx
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 d6                	mov    %edx,%esi
  800d22:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 10 00 00 00       	mov    $0x10,%eax
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	05 00 00 00 30       	add    $0x30000000,%eax
  800d76:	c1 e8 0c             	shr    $0xc,%eax
}
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	c1 ea 16             	shr    $0x16,%edx
  800d9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da6:	f6 c2 01             	test   $0x1,%dl
  800da9:	74 29                	je     800dd4 <fd_alloc+0x42>
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	c1 ea 0c             	shr    $0xc,%edx
  800db0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db7:	f6 c2 01             	test   $0x1,%dl
  800dba:	74 18                	je     800dd4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dbc:	05 00 10 00 00       	add    $0x1000,%eax
  800dc1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc6:	75 d2                	jne    800d9a <fd_alloc+0x8>
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800dcd:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800dd2:	eb 05                	jmp    800dd9 <fd_alloc+0x47>
			return 0;
  800dd4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 02                	mov    %eax,(%edx)
}
  800dde:	89 c8                	mov    %ecx,%eax
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de8:	83 f8 1f             	cmp    $0x1f,%eax
  800deb:	77 30                	ja     800e1d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ded:	c1 e0 0c             	shl    $0xc,%eax
  800df0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800dfb:	f6 c2 01             	test   $0x1,%dl
  800dfe:	74 24                	je     800e24 <fd_lookup+0x42>
  800e00:	89 c2                	mov    %eax,%edx
  800e02:	c1 ea 0c             	shr    $0xc,%edx
  800e05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0c:	f6 c2 01             	test   $0x1,%dl
  800e0f:	74 1a                	je     800e2b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e14:	89 02                	mov    %eax,(%edx)
	return 0;
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
		return -E_INVAL;
  800e1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e22:	eb f7                	jmp    800e1b <fd_lookup+0x39>
		return -E_INVAL;
  800e24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e29:	eb f0                	jmp    800e1b <fd_lookup+0x39>
  800e2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e30:	eb e9                	jmp    800e1b <fd_lookup+0x39>

00800e32 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	53                   	push   %ebx
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e46:	39 13                	cmp    %edx,(%ebx)
  800e48:	74 37                	je     800e81 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e4a:	83 c0 01             	add    $0x1,%eax
  800e4d:	8b 1c 85 28 26 80 00 	mov    0x802628(,%eax,4),%ebx
  800e54:	85 db                	test   %ebx,%ebx
  800e56:	75 ee                	jne    800e46 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e58:	a1 00 40 80 00       	mov    0x804000,%eax
  800e5d:	8b 40 48             	mov    0x48(%eax),%eax
  800e60:	83 ec 04             	sub    $0x4,%esp
  800e63:	52                   	push   %edx
  800e64:	50                   	push   %eax
  800e65:	68 ac 25 80 00       	push   $0x8025ac
  800e6a:	e8 d4 f2 ff ff       	call   800143 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7a:	89 1a                	mov    %ebx,(%edx)
}
  800e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    
			return 0;
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	eb ef                	jmp    800e77 <dev_lookup+0x45>

00800e88 <fd_close>:
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	83 ec 24             	sub    $0x24,%esp
  800e91:	8b 75 08             	mov    0x8(%ebp),%esi
  800e94:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e9a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea4:	50                   	push   %eax
  800ea5:	e8 38 ff ff ff       	call   800de2 <fd_lookup>
  800eaa:	89 c3                	mov    %eax,%ebx
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	78 05                	js     800eb8 <fd_close+0x30>
	    || fd != fd2)
  800eb3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eb6:	74 16                	je     800ece <fd_close+0x46>
		return (must_exist ? r : 0);
  800eb8:	89 f8                	mov    %edi,%eax
  800eba:	84 c0                	test   %al,%al
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec1:	0f 44 d8             	cmove  %eax,%ebx
}
  800ec4:	89 d8                	mov    %ebx,%eax
  800ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	ff 36                	push   (%esi)
  800ed7:	e8 56 ff ff ff       	call   800e32 <dev_lookup>
  800edc:	89 c3                	mov    %eax,%ebx
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 1a                	js     800eff <fd_close+0x77>
		if (dev->dev_close)
  800ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ee8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	74 0b                	je     800eff <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	56                   	push   %esi
  800ef8:	ff d0                	call   *%eax
  800efa:	89 c3                	mov    %eax,%ebx
  800efc:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	56                   	push   %esi
  800f03:	6a 00                	push   $0x0
  800f05:	e8 94 fc ff ff       	call   800b9e <sys_page_unmap>
	return r;
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	eb b5                	jmp    800ec4 <fd_close+0x3c>

00800f0f <close>:

int
close(int fdnum)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f18:	50                   	push   %eax
  800f19:	ff 75 08             	push   0x8(%ebp)
  800f1c:	e8 c1 fe ff ff       	call   800de2 <fd_lookup>
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	79 02                	jns    800f2a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    
		return fd_close(fd, 1);
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	6a 01                	push   $0x1
  800f2f:	ff 75 f4             	push   -0xc(%ebp)
  800f32:	e8 51 ff ff ff       	call   800e88 <fd_close>
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	eb ec                	jmp    800f28 <close+0x19>

00800f3c <close_all>:

void
close_all(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f43:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	53                   	push   %ebx
  800f4c:	e8 be ff ff ff       	call   800f0f <close>
	for (i = 0; i < MAXFD; i++)
  800f51:	83 c3 01             	add    $0x1,%ebx
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	83 fb 20             	cmp    $0x20,%ebx
  800f5a:	75 ec                	jne    800f48 <close_all+0xc>
}
  800f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f6a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6d:	50                   	push   %eax
  800f6e:	ff 75 08             	push   0x8(%ebp)
  800f71:	e8 6c fe ff ff       	call   800de2 <fd_lookup>
  800f76:	89 c3                	mov    %eax,%ebx
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 7f                	js     800ffe <dup+0x9d>
		return r;
	close(newfdnum);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	ff 75 0c             	push   0xc(%ebp)
  800f85:	e8 85 ff ff ff       	call   800f0f <close>

	newfd = INDEX2FD(newfdnum);
  800f8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f8d:	c1 e6 0c             	shl    $0xc,%esi
  800f90:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f99:	89 3c 24             	mov    %edi,(%esp)
  800f9c:	e8 da fd ff ff       	call   800d7b <fd2data>
  800fa1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fa3:	89 34 24             	mov    %esi,(%esp)
  800fa6:	e8 d0 fd ff ff       	call   800d7b <fd2data>
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb1:	89 d8                	mov    %ebx,%eax
  800fb3:	c1 e8 16             	shr    $0x16,%eax
  800fb6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbd:	a8 01                	test   $0x1,%al
  800fbf:	74 11                	je     800fd2 <dup+0x71>
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	c1 e8 0c             	shr    $0xc,%eax
  800fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcd:	f6 c2 01             	test   $0x1,%dl
  800fd0:	75 36                	jne    801008 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd2:	89 f8                	mov    %edi,%eax
  800fd4:	c1 e8 0c             	shr    $0xc,%eax
  800fd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe6:	50                   	push   %eax
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	57                   	push   %edi
  800feb:	6a 00                	push   $0x0
  800fed:	e8 6a fb ff ff       	call   800b5c <sys_page_map>
  800ff2:	89 c3                	mov    %eax,%ebx
  800ff4:	83 c4 20             	add    $0x20,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 33                	js     80102e <dup+0xcd>
		goto err;

	return newfdnum;
  800ffb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801008:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	25 07 0e 00 00       	and    $0xe07,%eax
  801017:	50                   	push   %eax
  801018:	ff 75 d4             	push   -0x2c(%ebp)
  80101b:	6a 00                	push   $0x0
  80101d:	53                   	push   %ebx
  80101e:	6a 00                	push   $0x0
  801020:	e8 37 fb ff ff       	call   800b5c <sys_page_map>
  801025:	89 c3                	mov    %eax,%ebx
  801027:	83 c4 20             	add    $0x20,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	79 a4                	jns    800fd2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	56                   	push   %esi
  801032:	6a 00                	push   $0x0
  801034:	e8 65 fb ff ff       	call   800b9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	ff 75 d4             	push   -0x2c(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	e8 58 fb ff ff       	call   800b9e <sys_page_unmap>
	return r;
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	eb b3                	jmp    800ffe <dup+0x9d>

0080104b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 18             	sub    $0x18,%esp
  801053:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801056:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801059:	50                   	push   %eax
  80105a:	56                   	push   %esi
  80105b:	e8 82 fd ff ff       	call   800de2 <fd_lookup>
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	78 3c                	js     8010a3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801067:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801070:	50                   	push   %eax
  801071:	ff 33                	push   (%ebx)
  801073:	e8 ba fd ff ff       	call   800e32 <dev_lookup>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 24                	js     8010a3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107f:	8b 43 08             	mov    0x8(%ebx),%eax
  801082:	83 e0 03             	and    $0x3,%eax
  801085:	83 f8 01             	cmp    $0x1,%eax
  801088:	74 20                	je     8010aa <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80108a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108d:	8b 40 08             	mov    0x8(%eax),%eax
  801090:	85 c0                	test   %eax,%eax
  801092:	74 37                	je     8010cb <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	ff 75 10             	push   0x10(%ebp)
  80109a:	ff 75 0c             	push   0xc(%ebp)
  80109d:	53                   	push   %ebx
  80109e:	ff d0                	call   *%eax
  8010a0:	83 c4 10             	add    $0x10,%esp
}
  8010a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010aa:	a1 00 40 80 00       	mov    0x804000,%eax
  8010af:	8b 40 48             	mov    0x48(%eax),%eax
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	56                   	push   %esi
  8010b6:	50                   	push   %eax
  8010b7:	68 ed 25 80 00       	push   $0x8025ed
  8010bc:	e8 82 f0 ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c9:	eb d8                	jmp    8010a3 <read+0x58>
		return -E_NOT_SUPP;
  8010cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010d0:	eb d1                	jmp    8010a3 <read+0x58>

008010d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e6:	eb 02                	jmp    8010ea <readn+0x18>
  8010e8:	01 c3                	add    %eax,%ebx
  8010ea:	39 f3                	cmp    %esi,%ebx
  8010ec:	73 21                	jae    80110f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	89 f0                	mov    %esi,%eax
  8010f3:	29 d8                	sub    %ebx,%eax
  8010f5:	50                   	push   %eax
  8010f6:	89 d8                	mov    %ebx,%eax
  8010f8:	03 45 0c             	add    0xc(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	57                   	push   %edi
  8010fd:	e8 49 ff ff ff       	call   80104b <read>
		if (m < 0)
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	78 04                	js     80110d <readn+0x3b>
			return m;
		if (m == 0)
  801109:	75 dd                	jne    8010e8 <readn+0x16>
  80110b:	eb 02                	jmp    80110f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80110d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	83 ec 18             	sub    $0x18,%esp
  801121:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801124:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	53                   	push   %ebx
  801129:	e8 b4 fc ff ff       	call   800de2 <fd_lookup>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 37                	js     80116c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801135:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	ff 36                	push   (%esi)
  801141:	e8 ec fc ff ff       	call   800e32 <dev_lookup>
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 1f                	js     80116c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80114d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801151:	74 20                	je     801173 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801156:	8b 40 0c             	mov    0xc(%eax),%eax
  801159:	85 c0                	test   %eax,%eax
  80115b:	74 37                	je     801194 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80115d:	83 ec 04             	sub    $0x4,%esp
  801160:	ff 75 10             	push   0x10(%ebp)
  801163:	ff 75 0c             	push   0xc(%ebp)
  801166:	56                   	push   %esi
  801167:	ff d0                	call   *%eax
  801169:	83 c4 10             	add    $0x10,%esp
}
  80116c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801173:	a1 00 40 80 00       	mov    0x804000,%eax
  801178:	8b 40 48             	mov    0x48(%eax),%eax
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	53                   	push   %ebx
  80117f:	50                   	push   %eax
  801180:	68 09 26 80 00       	push   $0x802609
  801185:	e8 b9 ef ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801192:	eb d8                	jmp    80116c <write+0x53>
		return -E_NOT_SUPP;
  801194:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801199:	eb d1                	jmp    80116c <write+0x53>

0080119b <seek>:

int
seek(int fdnum, off_t offset)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	ff 75 08             	push   0x8(%ebp)
  8011a8:	e8 35 fc ff ff       	call   800de2 <fd_lookup>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 0e                	js     8011c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 18             	sub    $0x18,%esp
  8011cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	53                   	push   %ebx
  8011d4:	e8 09 fc ff ff       	call   800de2 <fd_lookup>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 34                	js     801214 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	ff 36                	push   (%esi)
  8011ec:	e8 41 fc ff ff       	call   800e32 <dev_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 1c                	js     801214 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f8:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011fc:	74 1d                	je     80121b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801201:	8b 40 18             	mov    0x18(%eax),%eax
  801204:	85 c0                	test   %eax,%eax
  801206:	74 34                	je     80123c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801208:	83 ec 08             	sub    $0x8,%esp
  80120b:	ff 75 0c             	push   0xc(%ebp)
  80120e:	56                   	push   %esi
  80120f:	ff d0                	call   *%eax
  801211:	83 c4 10             	add    $0x10,%esp
}
  801214:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80121b:	a1 00 40 80 00       	mov    0x804000,%eax
  801220:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	53                   	push   %ebx
  801227:	50                   	push   %eax
  801228:	68 cc 25 80 00       	push   $0x8025cc
  80122d:	e8 11 ef ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb d8                	jmp    801214 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80123c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801241:	eb d1                	jmp    801214 <ftruncate+0x50>

00801243 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 18             	sub    $0x18,%esp
  80124b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 75 08             	push   0x8(%ebp)
  801255:	e8 88 fb ff ff       	call   800de2 <fd_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 49                	js     8012aa <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	ff 36                	push   (%esi)
  80126d:	e8 c0 fb ff ff       	call   800e32 <dev_lookup>
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 31                	js     8012aa <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801280:	74 2f                	je     8012b1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801282:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801285:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128c:	00 00 00 
	stat->st_isdir = 0;
  80128f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801296:	00 00 00 
	stat->st_dev = dev;
  801299:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	53                   	push   %ebx
  8012a3:	56                   	push   %esi
  8012a4:	ff 50 14             	call   *0x14(%eax)
  8012a7:	83 c4 10             	add    $0x10,%esp
}
  8012aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    
		return -E_NOT_SUPP;
  8012b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b6:	eb f2                	jmp    8012aa <fstat+0x67>

008012b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	6a 00                	push   $0x0
  8012c2:	ff 75 08             	push   0x8(%ebp)
  8012c5:	e8 e4 01 00 00       	call   8014ae <open>
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 1b                	js     8012ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	ff 75 0c             	push   0xc(%ebp)
  8012d9:	50                   	push   %eax
  8012da:	e8 64 ff ff ff       	call   801243 <fstat>
  8012df:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e1:	89 1c 24             	mov    %ebx,(%esp)
  8012e4:	e8 26 fc ff ff       	call   800f0f <close>
	return r;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	89 f3                	mov    %esi,%ebx
}
  8012ee:	89 d8                	mov    %ebx,%eax
  8012f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	89 c6                	mov    %eax,%esi
  8012fe:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801300:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801307:	74 27                	je     801330 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801309:	6a 07                	push   $0x7
  80130b:	68 00 50 80 00       	push   $0x805000
  801310:	56                   	push   %esi
  801311:	ff 35 00 60 80 00    	push   0x806000
  801317:	e8 0a 0c 00 00       	call   801f26 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80131c:	83 c4 0c             	add    $0xc,%esp
  80131f:	6a 00                	push   $0x0
  801321:	53                   	push   %ebx
  801322:	6a 00                	push   $0x0
  801324:	e8 96 0b 00 00       	call   801ebf <ipc_recv>
}
  801329:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	6a 01                	push   $0x1
  801335:	e8 40 0c 00 00       	call   801f7a <ipc_find_env>
  80133a:	a3 00 60 80 00       	mov    %eax,0x806000
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	eb c5                	jmp    801309 <fsipc+0x12>

00801344 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
  80134d:	8b 40 0c             	mov    0xc(%eax),%eax
  801350:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801355:	8b 45 0c             	mov    0xc(%ebp),%eax
  801358:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135d:	ba 00 00 00 00       	mov    $0x0,%edx
  801362:	b8 02 00 00 00       	mov    $0x2,%eax
  801367:	e8 8b ff ff ff       	call   8012f7 <fsipc>
}
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <devfile_flush>:
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801374:	8b 45 08             	mov    0x8(%ebp),%eax
  801377:	8b 40 0c             	mov    0xc(%eax),%eax
  80137a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
  801384:	b8 06 00 00 00       	mov    $0x6,%eax
  801389:	e8 69 ff ff ff       	call   8012f7 <fsipc>
}
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <devfile_stat>:
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	53                   	push   %ebx
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139a:	8b 45 08             	mov    0x8(%ebp),%eax
  80139d:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8013af:	e8 43 ff ff ff       	call   8012f7 <fsipc>
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 2c                	js     8013e4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	68 00 50 80 00       	push   $0x805000
  8013c0:	53                   	push   %ebx
  8013c1:	e8 57 f3 ff ff       	call   80071d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d1:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <devfile_write>:
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013f7:	39 d0                	cmp    %edx,%eax
  8013f9:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801402:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801408:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80140d:	50                   	push   %eax
  80140e:	ff 75 0c             	push   0xc(%ebp)
  801411:	68 08 50 80 00       	push   $0x805008
  801416:	e8 98 f4 ff ff       	call   8008b3 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
  801420:	b8 04 00 00 00       	mov    $0x4,%eax
  801425:	e8 cd fe ff ff       	call   8012f7 <fsipc>
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <devfile_read>:
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
  80144a:	b8 03 00 00 00       	mov    $0x3,%eax
  80144f:	e8 a3 fe ff ff       	call   8012f7 <fsipc>
  801454:	89 c3                	mov    %eax,%ebx
  801456:	85 c0                	test   %eax,%eax
  801458:	78 1f                	js     801479 <devfile_read+0x4d>
	assert(r <= n);
  80145a:	39 f0                	cmp    %esi,%eax
  80145c:	77 24                	ja     801482 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80145e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801463:	7f 33                	jg     801498 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801465:	83 ec 04             	sub    $0x4,%esp
  801468:	50                   	push   %eax
  801469:	68 00 50 80 00       	push   $0x805000
  80146e:	ff 75 0c             	push   0xc(%ebp)
  801471:	e8 3d f4 ff ff       	call   8008b3 <memmove>
	return r;
  801476:	83 c4 10             	add    $0x10,%esp
}
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    
	assert(r <= n);
  801482:	68 3c 26 80 00       	push   $0x80263c
  801487:	68 43 26 80 00       	push   $0x802643
  80148c:	6a 7c                	push   $0x7c
  80148e:	68 58 26 80 00       	push   $0x802658
  801493:	e8 e1 09 00 00       	call   801e79 <_panic>
	assert(r <= PGSIZE);
  801498:	68 63 26 80 00       	push   $0x802663
  80149d:	68 43 26 80 00       	push   $0x802643
  8014a2:	6a 7d                	push   $0x7d
  8014a4:	68 58 26 80 00       	push   $0x802658
  8014a9:	e8 cb 09 00 00       	call   801e79 <_panic>

008014ae <open>:
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 1c             	sub    $0x1c,%esp
  8014b6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014b9:	56                   	push   %esi
  8014ba:	e8 23 f2 ff ff       	call   8006e2 <strlen>
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c7:	7f 6c                	jg     801535 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	e8 bd f8 ff ff       	call   800d92 <fd_alloc>
  8014d5:	89 c3                	mov    %eax,%ebx
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 3c                	js     80151a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	56                   	push   %esi
  8014e2:	68 00 50 80 00       	push   $0x805000
  8014e7:	e8 31 f2 ff ff       	call   80071d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ef:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fc:	e8 f6 fd ff ff       	call   8012f7 <fsipc>
  801501:	89 c3                	mov    %eax,%ebx
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	78 19                	js     801523 <open+0x75>
	return fd2num(fd);
  80150a:	83 ec 0c             	sub    $0xc,%esp
  80150d:	ff 75 f4             	push   -0xc(%ebp)
  801510:	e8 56 f8 ff ff       	call   800d6b <fd2num>
  801515:	89 c3                	mov    %eax,%ebx
  801517:	83 c4 10             	add    $0x10,%esp
}
  80151a:	89 d8                	mov    %ebx,%eax
  80151c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    
		fd_close(fd, 0);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	6a 00                	push   $0x0
  801528:	ff 75 f4             	push   -0xc(%ebp)
  80152b:	e8 58 f9 ff ff       	call   800e88 <fd_close>
		return r;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	eb e5                	jmp    80151a <open+0x6c>
		return -E_BAD_PATH;
  801535:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80153a:	eb de                	jmp    80151a <open+0x6c>

0080153c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 08 00 00 00       	mov    $0x8,%eax
  80154c:	e8 a6 fd ff ff       	call   8012f7 <fsipc>
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801559:	68 6f 26 80 00       	push   $0x80266f
  80155e:	ff 75 0c             	push   0xc(%ebp)
  801561:	e8 b7 f1 ff ff       	call   80071d <strcpy>
	return 0;
}
  801566:	b8 00 00 00 00       	mov    $0x0,%eax
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <devsock_close>:
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	53                   	push   %ebx
  801571:	83 ec 10             	sub    $0x10,%esp
  801574:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801577:	53                   	push   %ebx
  801578:	e8 36 0a 00 00       	call   801fb3 <pageref>
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801582:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801587:	83 fa 01             	cmp    $0x1,%edx
  80158a:	74 05                	je     801591 <devsock_close+0x24>
}
  80158c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158f:	c9                   	leave  
  801590:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	ff 73 0c             	push   0xc(%ebx)
  801597:	e8 b7 02 00 00       	call   801853 <nsipc_close>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	eb eb                	jmp    80158c <devsock_close+0x1f>

008015a1 <devsock_write>:
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015a7:	6a 00                	push   $0x0
  8015a9:	ff 75 10             	push   0x10(%ebp)
  8015ac:	ff 75 0c             	push   0xc(%ebp)
  8015af:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b2:	ff 70 0c             	push   0xc(%eax)
  8015b5:	e8 79 03 00 00       	call   801933 <nsipc_send>
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <devsock_read>:
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015c2:	6a 00                	push   $0x0
  8015c4:	ff 75 10             	push   0x10(%ebp)
  8015c7:	ff 75 0c             	push   0xc(%ebp)
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	ff 70 0c             	push   0xc(%eax)
  8015d0:	e8 ef 02 00 00       	call   8018c4 <nsipc_recv>
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <fd2sockid>:
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015dd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015e0:	52                   	push   %edx
  8015e1:	50                   	push   %eax
  8015e2:	e8 fb f7 ff ff       	call   800de2 <fd_lookup>
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 10                	js     8015fe <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015f7:	39 08                	cmp    %ecx,(%eax)
  8015f9:	75 05                	jne    801600 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8015fb:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    
		return -E_NOT_SUPP;
  801600:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801605:	eb f7                	jmp    8015fe <fd2sockid+0x27>

00801607 <alloc_sockfd>:
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 1c             	sub    $0x1c,%esp
  80160f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	e8 78 f7 ff ff       	call   800d92 <fd_alloc>
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 43                	js     801666 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801623:	83 ec 04             	sub    $0x4,%esp
  801626:	68 07 04 00 00       	push   $0x407
  80162b:	ff 75 f4             	push   -0xc(%ebp)
  80162e:	6a 00                	push   $0x0
  801630:	e8 e4 f4 ff ff       	call   800b19 <sys_page_alloc>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 28                	js     801666 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80163e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801641:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801647:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801653:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	50                   	push   %eax
  80165a:	e8 0c f7 ff ff       	call   800d6b <fd2num>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	eb 0c                	jmp    801672 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	56                   	push   %esi
  80166a:	e8 e4 01 00 00       	call   801853 <nsipc_close>
		return r;
  80166f:	83 c4 10             	add    $0x10,%esp
}
  801672:	89 d8                	mov    %ebx,%eax
  801674:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <accept>:
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801681:	8b 45 08             	mov    0x8(%ebp),%eax
  801684:	e8 4e ff ff ff       	call   8015d7 <fd2sockid>
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 1b                	js     8016a8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80168d:	83 ec 04             	sub    $0x4,%esp
  801690:	ff 75 10             	push   0x10(%ebp)
  801693:	ff 75 0c             	push   0xc(%ebp)
  801696:	50                   	push   %eax
  801697:	e8 0e 01 00 00       	call   8017aa <nsipc_accept>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 05                	js     8016a8 <accept+0x2d>
	return alloc_sockfd(r);
  8016a3:	e8 5f ff ff ff       	call   801607 <alloc_sockfd>
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <bind>:
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	e8 1f ff ff ff       	call   8015d7 <fd2sockid>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 12                	js     8016ce <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016bc:	83 ec 04             	sub    $0x4,%esp
  8016bf:	ff 75 10             	push   0x10(%ebp)
  8016c2:	ff 75 0c             	push   0xc(%ebp)
  8016c5:	50                   	push   %eax
  8016c6:	e8 31 01 00 00       	call   8017fc <nsipc_bind>
  8016cb:	83 c4 10             	add    $0x10,%esp
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <shutdown>:
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	e8 f9 fe ff ff       	call   8015d7 <fd2sockid>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 0f                	js     8016f1 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	ff 75 0c             	push   0xc(%ebp)
  8016e8:	50                   	push   %eax
  8016e9:	e8 43 01 00 00       	call   801831 <nsipc_shutdown>
  8016ee:	83 c4 10             	add    $0x10,%esp
}
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <connect>:
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fc:	e8 d6 fe ff ff       	call   8015d7 <fd2sockid>
  801701:	85 c0                	test   %eax,%eax
  801703:	78 12                	js     801717 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	ff 75 10             	push   0x10(%ebp)
  80170b:	ff 75 0c             	push   0xc(%ebp)
  80170e:	50                   	push   %eax
  80170f:	e8 59 01 00 00       	call   80186d <nsipc_connect>
  801714:	83 c4 10             	add    $0x10,%esp
}
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <listen>:
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	e8 b0 fe ff ff       	call   8015d7 <fd2sockid>
  801727:	85 c0                	test   %eax,%eax
  801729:	78 0f                	js     80173a <listen+0x21>
	return nsipc_listen(r, backlog);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	ff 75 0c             	push   0xc(%ebp)
  801731:	50                   	push   %eax
  801732:	e8 6b 01 00 00       	call   8018a2 <nsipc_listen>
  801737:	83 c4 10             	add    $0x10,%esp
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <socket>:

int
socket(int domain, int type, int protocol)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801742:	ff 75 10             	push   0x10(%ebp)
  801745:	ff 75 0c             	push   0xc(%ebp)
  801748:	ff 75 08             	push   0x8(%ebp)
  80174b:	e8 41 02 00 00       	call   801991 <nsipc_socket>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 05                	js     80175c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801757:	e8 ab fe ff ff       	call   801607 <alloc_sockfd>
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801767:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80176e:	74 26                	je     801796 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801770:	6a 07                	push   $0x7
  801772:	68 00 70 80 00       	push   $0x807000
  801777:	53                   	push   %ebx
  801778:	ff 35 00 80 80 00    	push   0x808000
  80177e:	e8 a3 07 00 00       	call   801f26 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801783:	83 c4 0c             	add    $0xc,%esp
  801786:	6a 00                	push   $0x0
  801788:	6a 00                	push   $0x0
  80178a:	6a 00                	push   $0x0
  80178c:	e8 2e 07 00 00       	call   801ebf <ipc_recv>
}
  801791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801794:	c9                   	leave  
  801795:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	6a 02                	push   $0x2
  80179b:	e8 da 07 00 00       	call   801f7a <ipc_find_env>
  8017a0:	a3 00 80 80 00       	mov    %eax,0x808000
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	eb c6                	jmp    801770 <nsipc+0x12>

008017aa <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017ba:	8b 06                	mov    (%esi),%eax
  8017bc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c6:	e8 93 ff ff ff       	call   80175e <nsipc>
  8017cb:	89 c3                	mov    %eax,%ebx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	79 09                	jns    8017da <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017d1:	89 d8                	mov    %ebx,%eax
  8017d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	ff 35 10 70 80 00    	push   0x807010
  8017e3:	68 00 70 80 00       	push   $0x807000
  8017e8:	ff 75 0c             	push   0xc(%ebp)
  8017eb:	e8 c3 f0 ff ff       	call   8008b3 <memmove>
		*addrlen = ret->ret_addrlen;
  8017f0:	a1 10 70 80 00       	mov    0x807010,%eax
  8017f5:	89 06                	mov    %eax,(%esi)
  8017f7:	83 c4 10             	add    $0x10,%esp
	return r;
  8017fa:	eb d5                	jmp    8017d1 <nsipc_accept+0x27>

008017fc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	53                   	push   %ebx
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80180e:	53                   	push   %ebx
  80180f:	ff 75 0c             	push   0xc(%ebp)
  801812:	68 04 70 80 00       	push   $0x807004
  801817:	e8 97 f0 ff ff       	call   8008b3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80181c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801822:	b8 02 00 00 00       	mov    $0x2,%eax
  801827:	e8 32 ff ff ff       	call   80175e <nsipc>
}
  80182c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80183f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801842:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801847:	b8 03 00 00 00       	mov    $0x3,%eax
  80184c:	e8 0d ff ff ff       	call   80175e <nsipc>
}
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <nsipc_close>:

int
nsipc_close(int s)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801859:	8b 45 08             	mov    0x8(%ebp),%eax
  80185c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801861:	b8 04 00 00 00       	mov    $0x4,%eax
  801866:	e8 f3 fe ff ff       	call   80175e <nsipc>
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80187f:	53                   	push   %ebx
  801880:	ff 75 0c             	push   0xc(%ebp)
  801883:	68 04 70 80 00       	push   $0x807004
  801888:	e8 26 f0 ff ff       	call   8008b3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80188d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801893:	b8 05 00 00 00       	mov    $0x5,%eax
  801898:	e8 c1 fe ff ff       	call   80175e <nsipc>
}
  80189d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8018bd:	e8 9c fe ff ff       	call   80175e <nsipc>
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018d4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018da:	8b 45 14             	mov    0x14(%ebp),%eax
  8018dd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8018e7:	e8 72 fe ff ff       	call   80175e <nsipc>
  8018ec:	89 c3                	mov    %eax,%ebx
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 22                	js     801914 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8018f2:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8018f7:	39 c6                	cmp    %eax,%esi
  8018f9:	0f 4e c6             	cmovle %esi,%eax
  8018fc:	39 c3                	cmp    %eax,%ebx
  8018fe:	7f 1d                	jg     80191d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	53                   	push   %ebx
  801904:	68 00 70 80 00       	push   $0x807000
  801909:	ff 75 0c             	push   0xc(%ebp)
  80190c:	e8 a2 ef ff ff       	call   8008b3 <memmove>
  801911:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801914:	89 d8                	mov    %ebx,%eax
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80191d:	68 7b 26 80 00       	push   $0x80267b
  801922:	68 43 26 80 00       	push   $0x802643
  801927:	6a 62                	push   $0x62
  801929:	68 90 26 80 00       	push   $0x802690
  80192e:	e8 46 05 00 00       	call   801e79 <_panic>

00801933 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	53                   	push   %ebx
  801937:	83 ec 04             	sub    $0x4,%esp
  80193a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801945:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80194b:	7f 2e                	jg     80197b <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80194d:	83 ec 04             	sub    $0x4,%esp
  801950:	53                   	push   %ebx
  801951:	ff 75 0c             	push   0xc(%ebp)
  801954:	68 0c 70 80 00       	push   $0x80700c
  801959:	e8 55 ef ff ff       	call   8008b3 <memmove>
	nsipcbuf.send.req_size = size;
  80195e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801964:	8b 45 14             	mov    0x14(%ebp),%eax
  801967:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80196c:	b8 08 00 00 00       	mov    $0x8,%eax
  801971:	e8 e8 fd ff ff       	call   80175e <nsipc>
}
  801976:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801979:	c9                   	leave  
  80197a:	c3                   	ret    
	assert(size < 1600);
  80197b:	68 9c 26 80 00       	push   $0x80269c
  801980:	68 43 26 80 00       	push   $0x802643
  801985:	6a 6d                	push   $0x6d
  801987:	68 90 26 80 00       	push   $0x802690
  80198c:	e8 e8 04 00 00       	call   801e79 <_panic>

00801991 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80199f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019aa:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019af:	b8 09 00 00 00       	mov    $0x9,%eax
  8019b4:	e8 a5 fd ff ff       	call   80175e <nsipc>
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 75 08             	push   0x8(%ebp)
  8019c9:	e8 ad f3 ff ff       	call   800d7b <fd2data>
  8019ce:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d0:	83 c4 08             	add    $0x8,%esp
  8019d3:	68 a8 26 80 00       	push   $0x8026a8
  8019d8:	53                   	push   %ebx
  8019d9:	e8 3f ed ff ff       	call   80071d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019de:	8b 46 04             	mov    0x4(%esi),%eax
  8019e1:	2b 06                	sub    (%esi),%eax
  8019e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f0:	00 00 00 
	stat->st_dev = &devpipe;
  8019f3:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019fa:	30 80 00 
	return 0;
}
  8019fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801a02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a13:	53                   	push   %ebx
  801a14:	6a 00                	push   $0x0
  801a16:	e8 83 f1 ff ff       	call   800b9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a1b:	89 1c 24             	mov    %ebx,(%esp)
  801a1e:	e8 58 f3 ff ff       	call   800d7b <fd2data>
  801a23:	83 c4 08             	add    $0x8,%esp
  801a26:	50                   	push   %eax
  801a27:	6a 00                	push   $0x0
  801a29:	e8 70 f1 ff ff       	call   800b9e <sys_page_unmap>
}
  801a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <_pipeisclosed>:
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	57                   	push   %edi
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	83 ec 1c             	sub    $0x1c,%esp
  801a3c:	89 c7                	mov    %eax,%edi
  801a3e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a40:	a1 00 40 80 00       	mov    0x804000,%eax
  801a45:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	57                   	push   %edi
  801a4c:	e8 62 05 00 00       	call   801fb3 <pageref>
  801a51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a54:	89 34 24             	mov    %esi,(%esp)
  801a57:	e8 57 05 00 00       	call   801fb3 <pageref>
		nn = thisenv->env_runs;
  801a5c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a62:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	39 cb                	cmp    %ecx,%ebx
  801a6a:	74 1b                	je     801a87 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a6c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a6f:	75 cf                	jne    801a40 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a71:	8b 42 58             	mov    0x58(%edx),%eax
  801a74:	6a 01                	push   $0x1
  801a76:	50                   	push   %eax
  801a77:	53                   	push   %ebx
  801a78:	68 af 26 80 00       	push   $0x8026af
  801a7d:	e8 c1 e6 ff ff       	call   800143 <cprintf>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	eb b9                	jmp    801a40 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a87:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a8a:	0f 94 c0             	sete   %al
  801a8d:	0f b6 c0             	movzbl %al,%eax
}
  801a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <devpipe_write>:
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 28             	sub    $0x28,%esp
  801aa1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801aa4:	56                   	push   %esi
  801aa5:	e8 d1 f2 ff ff       	call   800d7b <fd2data>
  801aaa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab7:	75 09                	jne    801ac2 <devpipe_write+0x2a>
	return i;
  801ab9:	89 f8                	mov    %edi,%eax
  801abb:	eb 23                	jmp    801ae0 <devpipe_write+0x48>
			sys_yield();
  801abd:	e8 38 f0 ff ff       	call   800afa <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac2:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac5:	8b 0b                	mov    (%ebx),%ecx
  801ac7:	8d 51 20             	lea    0x20(%ecx),%edx
  801aca:	39 d0                	cmp    %edx,%eax
  801acc:	72 1a                	jb     801ae8 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ace:	89 da                	mov    %ebx,%edx
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	e8 5c ff ff ff       	call   801a33 <_pipeisclosed>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	74 e2                	je     801abd <devpipe_write+0x25>
				return 0;
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5e                   	pop    %esi
  801ae5:	5f                   	pop    %edi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aeb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aef:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	c1 fa 1f             	sar    $0x1f,%edx
  801af7:	89 d1                	mov    %edx,%ecx
  801af9:	c1 e9 1b             	shr    $0x1b,%ecx
  801afc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aff:	83 e2 1f             	and    $0x1f,%edx
  801b02:	29 ca                	sub    %ecx,%edx
  801b04:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b08:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0c:	83 c0 01             	add    $0x1,%eax
  801b0f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b12:	83 c7 01             	add    $0x1,%edi
  801b15:	eb 9d                	jmp    801ab4 <devpipe_write+0x1c>

00801b17 <devpipe_read>:
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	57                   	push   %edi
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 18             	sub    $0x18,%esp
  801b20:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b23:	57                   	push   %edi
  801b24:	e8 52 f2 ff ff       	call   800d7b <fd2data>
  801b29:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	be 00 00 00 00       	mov    $0x0,%esi
  801b33:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b36:	75 13                	jne    801b4b <devpipe_read+0x34>
	return i;
  801b38:	89 f0                	mov    %esi,%eax
  801b3a:	eb 02                	jmp    801b3e <devpipe_read+0x27>
				return i;
  801b3c:	89 f0                	mov    %esi,%eax
}
  801b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    
			sys_yield();
  801b46:	e8 af ef ff ff       	call   800afa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b4b:	8b 03                	mov    (%ebx),%eax
  801b4d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b50:	75 18                	jne    801b6a <devpipe_read+0x53>
			if (i > 0)
  801b52:	85 f6                	test   %esi,%esi
  801b54:	75 e6                	jne    801b3c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b56:	89 da                	mov    %ebx,%edx
  801b58:	89 f8                	mov    %edi,%eax
  801b5a:	e8 d4 fe ff ff       	call   801a33 <_pipeisclosed>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	74 e3                	je     801b46 <devpipe_read+0x2f>
				return 0;
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
  801b68:	eb d4                	jmp    801b3e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6a:	99                   	cltd   
  801b6b:	c1 ea 1b             	shr    $0x1b,%edx
  801b6e:	01 d0                	add    %edx,%eax
  801b70:	83 e0 1f             	and    $0x1f,%eax
  801b73:	29 d0                	sub    %edx,%eax
  801b75:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b80:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b83:	83 c6 01             	add    $0x1,%esi
  801b86:	eb ab                	jmp    801b33 <devpipe_read+0x1c>

00801b88 <pipe>:
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b93:	50                   	push   %eax
  801b94:	e8 f9 f1 ff ff       	call   800d92 <fd_alloc>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 23 01 00 00    	js     801cc9 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	68 07 04 00 00       	push   $0x407
  801bae:	ff 75 f4             	push   -0xc(%ebp)
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 61 ef ff ff       	call   800b19 <sys_page_alloc>
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 04 01 00 00    	js     801cc9 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bcb:	50                   	push   %eax
  801bcc:	e8 c1 f1 ff ff       	call   800d92 <fd_alloc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 88 db 00 00 00    	js     801cb9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	68 07 04 00 00       	push   $0x407
  801be6:	ff 75 f0             	push   -0x10(%ebp)
  801be9:	6a 00                	push   $0x0
  801beb:	e8 29 ef ff ff       	call   800b19 <sys_page_alloc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 bc 00 00 00    	js     801cb9 <pipe+0x131>
	va = fd2data(fd0);
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	ff 75 f4             	push   -0xc(%ebp)
  801c03:	e8 73 f1 ff ff       	call   800d7b <fd2data>
  801c08:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0a:	83 c4 0c             	add    $0xc,%esp
  801c0d:	68 07 04 00 00       	push   $0x407
  801c12:	50                   	push   %eax
  801c13:	6a 00                	push   $0x0
  801c15:	e8 ff ee ff ff       	call   800b19 <sys_page_alloc>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 82 00 00 00    	js     801ca9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c27:	83 ec 0c             	sub    $0xc,%esp
  801c2a:	ff 75 f0             	push   -0x10(%ebp)
  801c2d:	e8 49 f1 ff ff       	call   800d7b <fd2data>
  801c32:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c39:	50                   	push   %eax
  801c3a:	6a 00                	push   $0x0
  801c3c:	56                   	push   %esi
  801c3d:	6a 00                	push   $0x0
  801c3f:	e8 18 ef ff ff       	call   800b5c <sys_page_map>
  801c44:	89 c3                	mov    %eax,%ebx
  801c46:	83 c4 20             	add    $0x20,%esp
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 4e                	js     801c9b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c4d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c55:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c5a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c61:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c64:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c69:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c70:	83 ec 0c             	sub    $0xc,%esp
  801c73:	ff 75 f4             	push   -0xc(%ebp)
  801c76:	e8 f0 f0 ff ff       	call   800d6b <fd2num>
  801c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c80:	83 c4 04             	add    $0x4,%esp
  801c83:	ff 75 f0             	push   -0x10(%ebp)
  801c86:	e8 e0 f0 ff ff       	call   800d6b <fd2num>
  801c8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c99:	eb 2e                	jmp    801cc9 <pipe+0x141>
	sys_page_unmap(0, va);
  801c9b:	83 ec 08             	sub    $0x8,%esp
  801c9e:	56                   	push   %esi
  801c9f:	6a 00                	push   $0x0
  801ca1:	e8 f8 ee ff ff       	call   800b9e <sys_page_unmap>
  801ca6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ca9:	83 ec 08             	sub    $0x8,%esp
  801cac:	ff 75 f0             	push   -0x10(%ebp)
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 e8 ee ff ff       	call   800b9e <sys_page_unmap>
  801cb6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cb9:	83 ec 08             	sub    $0x8,%esp
  801cbc:	ff 75 f4             	push   -0xc(%ebp)
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 d8 ee ff ff       	call   800b9e <sys_page_unmap>
  801cc6:	83 c4 10             	add    $0x10,%esp
}
  801cc9:	89 d8                	mov    %ebx,%eax
  801ccb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <pipeisclosed>:
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdb:	50                   	push   %eax
  801cdc:	ff 75 08             	push   0x8(%ebp)
  801cdf:	e8 fe f0 ff ff       	call   800de2 <fd_lookup>
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 18                	js     801d03 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff 75 f4             	push   -0xc(%ebp)
  801cf1:	e8 85 f0 ff ff       	call   800d7b <fd2data>
  801cf6:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfb:	e8 33 fd ff ff       	call   801a33 <_pipeisclosed>
  801d00:	83 c4 10             	add    $0x10,%esp
}
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0a:	c3                   	ret    

00801d0b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d11:	68 c7 26 80 00       	push   $0x8026c7
  801d16:	ff 75 0c             	push   0xc(%ebp)
  801d19:	e8 ff e9 ff ff       	call   80071d <strcpy>
	return 0;
}
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <devcons_write>:
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	57                   	push   %edi
  801d29:	56                   	push   %esi
  801d2a:	53                   	push   %ebx
  801d2b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d31:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d36:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d3c:	eb 2e                	jmp    801d6c <devcons_write+0x47>
		m = n - tot;
  801d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d41:	29 f3                	sub    %esi,%ebx
  801d43:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d48:	39 c3                	cmp    %eax,%ebx
  801d4a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d4d:	83 ec 04             	sub    $0x4,%esp
  801d50:	53                   	push   %ebx
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	03 45 0c             	add    0xc(%ebp),%eax
  801d56:	50                   	push   %eax
  801d57:	57                   	push   %edi
  801d58:	e8 56 eb ff ff       	call   8008b3 <memmove>
		sys_cputs(buf, m);
  801d5d:	83 c4 08             	add    $0x8,%esp
  801d60:	53                   	push   %ebx
  801d61:	57                   	push   %edi
  801d62:	e8 f6 ec ff ff       	call   800a5d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d67:	01 de                	add    %ebx,%esi
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6f:	72 cd                	jb     801d3e <devcons_write+0x19>
}
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <devcons_read>:
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 08             	sub    $0x8,%esp
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d8a:	75 07                	jne    801d93 <devcons_read+0x18>
  801d8c:	eb 1f                	jmp    801dad <devcons_read+0x32>
		sys_yield();
  801d8e:	e8 67 ed ff ff       	call   800afa <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d93:	e8 e3 ec ff ff       	call   800a7b <sys_cgetc>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	74 f2                	je     801d8e <devcons_read+0x13>
	if (c < 0)
  801d9c:	78 0f                	js     801dad <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801d9e:	83 f8 04             	cmp    $0x4,%eax
  801da1:	74 0c                	je     801daf <devcons_read+0x34>
	*(char*)vbuf = c;
  801da3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da6:	88 02                	mov    %al,(%edx)
	return 1;
  801da8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    
		return 0;
  801daf:	b8 00 00 00 00       	mov    $0x0,%eax
  801db4:	eb f7                	jmp    801dad <devcons_read+0x32>

00801db6 <cputchar>:
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dc2:	6a 01                	push   $0x1
  801dc4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc7:	50                   	push   %eax
  801dc8:	e8 90 ec ff ff       	call   800a5d <sys_cputs>
}
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <getchar>:
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801dd8:	6a 01                	push   $0x1
  801dda:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddd:	50                   	push   %eax
  801dde:	6a 00                	push   $0x0
  801de0:	e8 66 f2 ff ff       	call   80104b <read>
	if (r < 0)
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 06                	js     801df2 <getchar+0x20>
	if (r < 1)
  801dec:	74 06                	je     801df4 <getchar+0x22>
	return c;
  801dee:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    
		return -E_EOF;
  801df4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801df9:	eb f7                	jmp    801df2 <getchar+0x20>

00801dfb <iscons>:
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e04:	50                   	push   %eax
  801e05:	ff 75 08             	push   0x8(%ebp)
  801e08:	e8 d5 ef ff ff       	call   800de2 <fd_lookup>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 11                	js     801e25 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e1d:	39 10                	cmp    %edx,(%eax)
  801e1f:	0f 94 c0             	sete   %al
  801e22:	0f b6 c0             	movzbl %al,%eax
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <opencons>:
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	e8 5c ef ff ff       	call   800d92 <fd_alloc>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 3a                	js     801e77 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3d:	83 ec 04             	sub    $0x4,%esp
  801e40:	68 07 04 00 00       	push   $0x407
  801e45:	ff 75 f4             	push   -0xc(%ebp)
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 ca ec ff ff       	call   800b19 <sys_page_alloc>
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 21                	js     801e77 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e59:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e5f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e64:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e6b:	83 ec 0c             	sub    $0xc,%esp
  801e6e:	50                   	push   %eax
  801e6f:	e8 f7 ee ff ff       	call   800d6b <fd2num>
  801e74:	83 c4 10             	add    $0x10,%esp
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e7e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e81:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e87:	e8 4f ec ff ff       	call   800adb <sys_getenvid>
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	ff 75 0c             	push   0xc(%ebp)
  801e92:	ff 75 08             	push   0x8(%ebp)
  801e95:	56                   	push   %esi
  801e96:	50                   	push   %eax
  801e97:	68 d4 26 80 00       	push   $0x8026d4
  801e9c:	e8 a2 e2 ff ff       	call   800143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ea1:	83 c4 18             	add    $0x18,%esp
  801ea4:	53                   	push   %ebx
  801ea5:	ff 75 10             	push   0x10(%ebp)
  801ea8:	e8 45 e2 ff ff       	call   8000f2 <vcprintf>
	cprintf("\n");
  801ead:	c7 04 24 c0 26 80 00 	movl   $0x8026c0,(%esp)
  801eb4:	e8 8a e2 ff ff       	call   800143 <cprintf>
  801eb9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ebc:	cc                   	int3   
  801ebd:	eb fd                	jmp    801ebc <_panic+0x43>

00801ebf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ed7:	83 ec 0c             	sub    $0xc,%esp
  801eda:	50                   	push   %eax
  801edb:	e8 e9 ed ff ff       	call   800cc9 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 f6                	test   %esi,%esi
  801ee5:	74 14                	je     801efb <ipc_recv+0x3c>
  801ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 09                	js     801ef9 <ipc_recv+0x3a>
  801ef0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef6:	8b 52 74             	mov    0x74(%edx),%edx
  801ef9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	74 14                	je     801f13 <ipc_recv+0x54>
  801eff:	ba 00 00 00 00       	mov    $0x0,%edx
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 09                	js     801f11 <ipc_recv+0x52>
  801f08:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f0e:	8b 52 78             	mov    0x78(%edx),%edx
  801f11:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 08                	js     801f1f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f17:	a1 00 40 80 00       	mov    0x804000,%eax
  801f1c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	57                   	push   %edi
  801f2a:	56                   	push   %esi
  801f2b:	53                   	push   %ebx
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f38:	85 db                	test   %ebx,%ebx
  801f3a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f3f:	0f 44 d8             	cmove  %eax,%ebx
  801f42:	eb 05                	jmp    801f49 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f44:	e8 b1 eb ff ff       	call   800afa <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f49:	ff 75 14             	push   0x14(%ebp)
  801f4c:	53                   	push   %ebx
  801f4d:	56                   	push   %esi
  801f4e:	57                   	push   %edi
  801f4f:	e8 52 ed ff ff       	call   800ca6 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5a:	74 e8                	je     801f44 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 08                	js     801f68 <ipc_send+0x42>
	}while (r<0);

}
  801f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f68:	50                   	push   %eax
  801f69:	68 f7 26 80 00       	push   $0x8026f7
  801f6e:	6a 3d                	push   $0x3d
  801f70:	68 0b 27 80 00       	push   $0x80270b
  801f75:	e8 ff fe ff ff       	call   801e79 <_panic>

00801f7a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f85:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f88:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8e:	8b 52 50             	mov    0x50(%edx),%edx
  801f91:	39 ca                	cmp    %ecx,%edx
  801f93:	74 11                	je     801fa6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f95:	83 c0 01             	add    $0x1,%eax
  801f98:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f9d:	75 e6                	jne    801f85 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	eb 0b                	jmp    801fb1 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fa6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fa9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fae:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb9:	89 c2                	mov    %eax,%edx
  801fbb:	c1 ea 16             	shr    $0x16,%edx
  801fbe:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fc5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fca:	f6 c1 01             	test   $0x1,%cl
  801fcd:	74 1c                	je     801feb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fcf:	c1 e8 0c             	shr    $0xc,%eax
  801fd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd9:	a8 01                	test   $0x1,%al
  801fdb:	74 0e                	je     801feb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdd:	c1 e8 0c             	shr    $0xc,%eax
  801fe0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe7:	ef 
  801fe8:	0f b7 d2             	movzwl %dx,%edx
}
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802003:	8b 74 24 34          	mov    0x34(%esp),%esi
  802007:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80200b:	85 c0                	test   %eax,%eax
  80200d:	75 19                	jne    802028 <__udivdi3+0x38>
  80200f:	39 f3                	cmp    %esi,%ebx
  802011:	76 4d                	jbe    802060 <__udivdi3+0x70>
  802013:	31 ff                	xor    %edi,%edi
  802015:	89 e8                	mov    %ebp,%eax
  802017:	89 f2                	mov    %esi,%edx
  802019:	f7 f3                	div    %ebx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 f0                	cmp    %esi,%eax
  80202a:	76 14                	jbe    802040 <__udivdi3+0x50>
  80202c:	31 ff                	xor    %edi,%edi
  80202e:	31 c0                	xor    %eax,%eax
  802030:	89 fa                	mov    %edi,%edx
  802032:	83 c4 1c             	add    $0x1c,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
  80203a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802040:	0f bd f8             	bsr    %eax,%edi
  802043:	83 f7 1f             	xor    $0x1f,%edi
  802046:	75 48                	jne    802090 <__udivdi3+0xa0>
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	72 06                	jb     802052 <__udivdi3+0x62>
  80204c:	31 c0                	xor    %eax,%eax
  80204e:	39 eb                	cmp    %ebp,%ebx
  802050:	77 de                	ja     802030 <__udivdi3+0x40>
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb d7                	jmp    802030 <__udivdi3+0x40>
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d9                	mov    %ebx,%ecx
  802062:	85 db                	test   %ebx,%ebx
  802064:	75 0b                	jne    802071 <__udivdi3+0x81>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f3                	div    %ebx
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	31 d2                	xor    %edx,%edx
  802073:	89 f0                	mov    %esi,%eax
  802075:	f7 f1                	div    %ecx
  802077:	89 c6                	mov    %eax,%esi
  802079:	89 e8                	mov    %ebp,%eax
  80207b:	89 f7                	mov    %esi,%edi
  80207d:	f7 f1                	div    %ecx
  80207f:	89 fa                	mov    %edi,%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 f9                	mov    %edi,%ecx
  802092:	ba 20 00 00 00       	mov    $0x20,%edx
  802097:	29 fa                	sub    %edi,%edx
  802099:	d3 e0                	shl    %cl,%eax
  80209b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209f:	89 d1                	mov    %edx,%ecx
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	d3 e8                	shr    %cl,%eax
  8020a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020a9:	09 c1                	or     %eax,%ecx
  8020ab:	89 f0                	mov    %esi,%eax
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e3                	shl    %cl,%ebx
  8020b5:	89 d1                	mov    %edx,%ecx
  8020b7:	d3 e8                	shr    %cl,%eax
  8020b9:	89 f9                	mov    %edi,%ecx
  8020bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020bf:	89 eb                	mov    %ebp,%ebx
  8020c1:	d3 e6                	shl    %cl,%esi
  8020c3:	89 d1                	mov    %edx,%ecx
  8020c5:	d3 eb                	shr    %cl,%ebx
  8020c7:	09 f3                	or     %esi,%ebx
  8020c9:	89 c6                	mov    %eax,%esi
  8020cb:	89 f2                	mov    %esi,%edx
  8020cd:	89 d8                	mov    %ebx,%eax
  8020cf:	f7 74 24 08          	divl   0x8(%esp)
  8020d3:	89 d6                	mov    %edx,%esi
  8020d5:	89 c3                	mov    %eax,%ebx
  8020d7:	f7 64 24 0c          	mull   0xc(%esp)
  8020db:	39 d6                	cmp    %edx,%esi
  8020dd:	72 19                	jb     8020f8 <__udivdi3+0x108>
  8020df:	89 f9                	mov    %edi,%ecx
  8020e1:	d3 e5                	shl    %cl,%ebp
  8020e3:	39 c5                	cmp    %eax,%ebp
  8020e5:	73 04                	jae    8020eb <__udivdi3+0xfb>
  8020e7:	39 d6                	cmp    %edx,%esi
  8020e9:	74 0d                	je     8020f8 <__udivdi3+0x108>
  8020eb:	89 d8                	mov    %ebx,%eax
  8020ed:	31 ff                	xor    %edi,%edi
  8020ef:	e9 3c ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020fb:	31 ff                	xor    %edi,%edi
  8020fd:	e9 2e ff ff ff       	jmp    802030 <__udivdi3+0x40>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80211f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802123:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802127:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	89 da                	mov    %ebx,%edx
  80212f:	85 ff                	test   %edi,%edi
  802131:	75 15                	jne    802148 <__umoddi3+0x38>
  802133:	39 dd                	cmp    %ebx,%ebp
  802135:	76 39                	jbe    802170 <__umoddi3+0x60>
  802137:	f7 f5                	div    %ebp
  802139:	89 d0                	mov    %edx,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 df                	cmp    %ebx,%edi
  80214a:	77 f1                	ja     80213d <__umoddi3+0x2d>
  80214c:	0f bd cf             	bsr    %edi,%ecx
  80214f:	83 f1 1f             	xor    $0x1f,%ecx
  802152:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802156:	75 40                	jne    802198 <__umoddi3+0x88>
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	72 04                	jb     802160 <__umoddi3+0x50>
  80215c:	39 f5                	cmp    %esi,%ebp
  80215e:	77 dd                	ja     80213d <__umoddi3+0x2d>
  802160:	89 da                	mov    %ebx,%edx
  802162:	89 f0                	mov    %esi,%eax
  802164:	29 e8                	sub    %ebp,%eax
  802166:	19 fa                	sbb    %edi,%edx
  802168:	eb d3                	jmp    80213d <__umoddi3+0x2d>
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	89 e9                	mov    %ebp,%ecx
  802172:	85 ed                	test   %ebp,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x71>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f5                	div    %ebp
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	89 d8                	mov    %ebx,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f1                	div    %ecx
  802187:	89 f0                	mov    %esi,%eax
  802189:	f7 f1                	div    %ecx
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	31 d2                	xor    %edx,%edx
  80218f:	eb ac                	jmp    80213d <__umoddi3+0x2d>
  802191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802198:	8b 44 24 04          	mov    0x4(%esp),%eax
  80219c:	ba 20 00 00 00       	mov    $0x20,%edx
  8021a1:	29 c2                	sub    %eax,%edx
  8021a3:	89 c1                	mov    %eax,%ecx
  8021a5:	89 e8                	mov    %ebp,%eax
  8021a7:	d3 e7                	shl    %cl,%edi
  8021a9:	89 d1                	mov    %edx,%ecx
  8021ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021af:	d3 e8                	shr    %cl,%eax
  8021b1:	89 c1                	mov    %eax,%ecx
  8021b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021b7:	09 f9                	or     %edi,%ecx
  8021b9:	89 df                	mov    %ebx,%edi
  8021bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	d3 e5                	shl    %cl,%ebp
  8021c3:	89 d1                	mov    %edx,%ecx
  8021c5:	d3 ef                	shr    %cl,%edi
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	d3 e3                	shl    %cl,%ebx
  8021cd:	89 d1                	mov    %edx,%ecx
  8021cf:	89 fa                	mov    %edi,%edx
  8021d1:	d3 e8                	shr    %cl,%eax
  8021d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021d8:	09 d8                	or     %ebx,%eax
  8021da:	f7 74 24 08          	divl   0x8(%esp)
  8021de:	89 d3                	mov    %edx,%ebx
  8021e0:	d3 e6                	shl    %cl,%esi
  8021e2:	f7 e5                	mul    %ebp
  8021e4:	89 c7                	mov    %eax,%edi
  8021e6:	89 d1                	mov    %edx,%ecx
  8021e8:	39 d3                	cmp    %edx,%ebx
  8021ea:	72 06                	jb     8021f2 <__umoddi3+0xe2>
  8021ec:	75 0e                	jne    8021fc <__umoddi3+0xec>
  8021ee:	39 c6                	cmp    %eax,%esi
  8021f0:	73 0a                	jae    8021fc <__umoddi3+0xec>
  8021f2:	29 e8                	sub    %ebp,%eax
  8021f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021f8:	89 d1                	mov    %edx,%ecx
  8021fa:	89 c7                	mov    %eax,%edi
  8021fc:	89 f5                	mov    %esi,%ebp
  8021fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802202:	29 fd                	sub    %edi,%ebp
  802204:	19 cb                	sbb    %ecx,%ebx
  802206:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	d3 e0                	shl    %cl,%eax
  80220f:	89 f1                	mov    %esi,%ecx
  802211:	d3 ed                	shr    %cl,%ebp
  802213:	d3 eb                	shr    %cl,%ebx
  802215:	09 e8                	or     %ebp,%eax
  802217:	89 da                	mov    %ebx,%edx
  802219:	83 c4 1c             	add    $0x1c,%esp
  80221c:	5b                   	pop    %ebx
  80221d:	5e                   	pop    %esi
  80221e:	5f                   	pop    %edi
  80221f:	5d                   	pop    %ebp
  802220:	c3                   	ret    
