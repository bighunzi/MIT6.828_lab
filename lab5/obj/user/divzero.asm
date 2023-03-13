
obj/user/divzero.debug：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 1d 80 00       	push   $0x801d80
  800056:	e8 fa 00 00 00       	call   800155 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 7d 0a 00 00       	call   800aed <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 37 0e 00 00       	call   800ee8 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 f1 09 00 00       	call   800aac <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	74 09                	je     8000e8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	68 ff 00 00 00       	push   $0xff
  8000f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f3:	50                   	push   %eax
  8000f4:	e8 76 09 00 00       	call   800a6f <sys_cputs>
		b->idx = 0;
  8000f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	eb db                	jmp    8000df <putch+0x1f>

00800104 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	ff 75 0c             	push   0xc(%ebp)
  800124:	ff 75 08             	push   0x8(%ebp)
  800127:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	68 c0 00 80 00       	push   $0x8000c0
  800133:	e8 14 01 00 00       	call   80024c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800138:	83 c4 08             	add    $0x8,%esp
  80013b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800141:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800147:	50                   	push   %eax
  800148:	e8 22 09 00 00       	call   800a6f <sys_cputs>

	return b.cnt;
}
  80014d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015e:	50                   	push   %eax
  80015f:	ff 75 08             	push   0x8(%ebp)
  800162:	e8 9d ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 1c             	sub    $0x1c,%esp
  800172:	89 c7                	mov    %eax,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017c:	89 d1                	mov    %edx,%ecx
  80017e:	89 c2                	mov    %eax,%edx
  800180:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800183:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800186:	8b 45 10             	mov    0x10(%ebp),%eax
  800189:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800196:	39 c2                	cmp    %eax,%edx
  800198:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80019b:	72 3e                	jb     8001db <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	ff 75 18             	push   0x18(%ebp)
  8001a3:	83 eb 01             	sub    $0x1,%ebx
  8001a6:	53                   	push   %ebx
  8001a7:	50                   	push   %eax
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	ff 75 e4             	push   -0x1c(%ebp)
  8001ae:	ff 75 e0             	push   -0x20(%ebp)
  8001b1:	ff 75 dc             	push   -0x24(%ebp)
  8001b4:	ff 75 d8             	push   -0x28(%ebp)
  8001b7:	e8 84 19 00 00       	call   801b40 <__udivdi3>
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	52                   	push   %edx
  8001c0:	50                   	push   %eax
  8001c1:	89 f2                	mov    %esi,%edx
  8001c3:	89 f8                	mov    %edi,%eax
  8001c5:	e8 9f ff ff ff       	call   800169 <printnum>
  8001ca:	83 c4 20             	add    $0x20,%esp
  8001cd:	eb 13                	jmp    8001e2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	ff 75 18             	push   0x18(%ebp)
  8001d6:	ff d7                	call   *%edi
  8001d8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001db:	83 eb 01             	sub    $0x1,%ebx
  8001de:	85 db                	test   %ebx,%ebx
  8001e0:	7f ed                	jg     8001cf <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	56                   	push   %esi
  8001e6:	83 ec 04             	sub    $0x4,%esp
  8001e9:	ff 75 e4             	push   -0x1c(%ebp)
  8001ec:	ff 75 e0             	push   -0x20(%ebp)
  8001ef:	ff 75 dc             	push   -0x24(%ebp)
  8001f2:	ff 75 d8             	push   -0x28(%ebp)
  8001f5:	e8 66 1a 00 00       	call   801c60 <__umoddi3>
  8001fa:	83 c4 14             	add    $0x14,%esp
  8001fd:	0f be 80 98 1d 80 00 	movsbl 0x801d98(%eax),%eax
  800204:	50                   	push   %eax
  800205:	ff d7                	call   *%edi
}
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800218:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	3b 50 04             	cmp    0x4(%eax),%edx
  800221:	73 0a                	jae    80022d <sprintputch+0x1b>
		*b->buf++ = ch;
  800223:	8d 4a 01             	lea    0x1(%edx),%ecx
  800226:	89 08                	mov    %ecx,(%eax)
  800228:	8b 45 08             	mov    0x8(%ebp),%eax
  80022b:	88 02                	mov    %al,(%edx)
}
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <printfmt>:
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800235:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800238:	50                   	push   %eax
  800239:	ff 75 10             	push   0x10(%ebp)
  80023c:	ff 75 0c             	push   0xc(%ebp)
  80023f:	ff 75 08             	push   0x8(%ebp)
  800242:	e8 05 00 00 00       	call   80024c <vprintfmt>
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <vprintfmt>:
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 3c             	sub    $0x3c,%esp
  800255:	8b 75 08             	mov    0x8(%ebp),%esi
  800258:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025e:	eb 0a                	jmp    80026a <vprintfmt+0x1e>
			putch(ch, putdat);
  800260:	83 ec 08             	sub    $0x8,%esp
  800263:	53                   	push   %ebx
  800264:	50                   	push   %eax
  800265:	ff d6                	call   *%esi
  800267:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80026a:	83 c7 01             	add    $0x1,%edi
  80026d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800271:	83 f8 25             	cmp    $0x25,%eax
  800274:	74 0c                	je     800282 <vprintfmt+0x36>
			if (ch == '\0')
  800276:	85 c0                	test   %eax,%eax
  800278:	75 e6                	jne    800260 <vprintfmt+0x14>
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    
		padc = ' ';
  800282:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800286:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800294:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80029b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a0:	8d 47 01             	lea    0x1(%edi),%eax
  8002a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a6:	0f b6 17             	movzbl (%edi),%edx
  8002a9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ac:	3c 55                	cmp    $0x55,%al
  8002ae:	0f 87 bb 03 00 00    	ja     80066f <vprintfmt+0x423>
  8002b4:	0f b6 c0             	movzbl %al,%eax
  8002b7:	ff 24 85 e0 1e 80 00 	jmp    *0x801ee0(,%eax,4)
  8002be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c5:	eb d9                	jmp    8002a0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ca:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002ce:	eb d0                	jmp    8002a0 <vprintfmt+0x54>
  8002d0:	0f b6 d2             	movzbl %dl,%edx
  8002d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002eb:	83 f9 09             	cmp    $0x9,%ecx
  8002ee:	77 55                	ja     800345 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f3:	eb e9                	jmp    8002de <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f8:	8b 00                	mov    (%eax),%eax
  8002fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8d 40 04             	lea    0x4(%eax),%eax
  800303:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800309:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030d:	79 91                	jns    8002a0 <vprintfmt+0x54>
				width = precision, precision = -1;
  80030f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800312:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800315:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031c:	eb 82                	jmp    8002a0 <vprintfmt+0x54>
  80031e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800321:	85 d2                	test   %edx,%edx
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	0f 49 c2             	cmovns %edx,%eax
  80032b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800331:	e9 6a ff ff ff       	jmp    8002a0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800339:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800340:	e9 5b ff ff ff       	jmp    8002a0 <vprintfmt+0x54>
  800345:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800348:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034b:	eb bc                	jmp    800309 <vprintfmt+0xbd>
			lflag++;
  80034d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800353:	e9 48 ff ff ff       	jmp    8002a0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800358:	8b 45 14             	mov    0x14(%ebp),%eax
  80035b:	8d 78 04             	lea    0x4(%eax),%edi
  80035e:	83 ec 08             	sub    $0x8,%esp
  800361:	53                   	push   %ebx
  800362:	ff 30                	push   (%eax)
  800364:	ff d6                	call   *%esi
			break;
  800366:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800369:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036c:	e9 9d 02 00 00       	jmp    80060e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 78 04             	lea    0x4(%eax),%edi
  800377:	8b 10                	mov    (%eax),%edx
  800379:	89 d0                	mov    %edx,%eax
  80037b:	f7 d8                	neg    %eax
  80037d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800380:	83 f8 0f             	cmp    $0xf,%eax
  800383:	7f 23                	jg     8003a8 <vprintfmt+0x15c>
  800385:	8b 14 85 40 20 80 00 	mov    0x802040(,%eax,4),%edx
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 18                	je     8003a8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800390:	52                   	push   %edx
  800391:	68 71 21 80 00       	push   $0x802171
  800396:	53                   	push   %ebx
  800397:	56                   	push   %esi
  800398:	e8 92 fe ff ff       	call   80022f <printfmt>
  80039d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a3:	e9 66 02 00 00       	jmp    80060e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003a8:	50                   	push   %eax
  8003a9:	68 b0 1d 80 00       	push   $0x801db0
  8003ae:	53                   	push   %ebx
  8003af:	56                   	push   %esi
  8003b0:	e8 7a fe ff ff       	call   80022f <printfmt>
  8003b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003bb:	e9 4e 02 00 00       	jmp    80060e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	83 c0 04             	add    $0x4,%eax
  8003c6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003ce:	85 d2                	test   %edx,%edx
  8003d0:	b8 a9 1d 80 00       	mov    $0x801da9,%eax
  8003d5:	0f 45 c2             	cmovne %edx,%eax
  8003d8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003df:	7e 06                	jle    8003e7 <vprintfmt+0x19b>
  8003e1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e5:	75 0d                	jne    8003f4 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003ea:	89 c7                	mov    %eax,%edi
  8003ec:	03 45 e0             	add    -0x20(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	eb 55                	jmp    800449 <vprintfmt+0x1fd>
  8003f4:	83 ec 08             	sub    $0x8,%esp
  8003f7:	ff 75 d8             	push   -0x28(%ebp)
  8003fa:	ff 75 cc             	push   -0x34(%ebp)
  8003fd:	e8 0a 03 00 00       	call   80070c <strnlen>
  800402:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800405:	29 c1                	sub    %eax,%ecx
  800407:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80040f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800416:	eb 0f                	jmp    800427 <vprintfmt+0x1db>
					putch(padc, putdat);
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	53                   	push   %ebx
  80041c:	ff 75 e0             	push   -0x20(%ebp)
  80041f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800421:	83 ef 01             	sub    $0x1,%edi
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	85 ff                	test   %edi,%edi
  800429:	7f ed                	jg     800418 <vprintfmt+0x1cc>
  80042b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
  800435:	0f 49 c2             	cmovns %edx,%eax
  800438:	29 c2                	sub    %eax,%edx
  80043a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043d:	eb a8                	jmp    8003e7 <vprintfmt+0x19b>
					putch(ch, putdat);
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	53                   	push   %ebx
  800443:	52                   	push   %edx
  800444:	ff d6                	call   *%esi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	0f be d0             	movsbl %al,%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 4b                	je     8004a7 <vprintfmt+0x25b>
  80045c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800460:	78 06                	js     800468 <vprintfmt+0x21c>
  800462:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800466:	78 1e                	js     800486 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800468:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046c:	74 d1                	je     80043f <vprintfmt+0x1f3>
  80046e:	0f be c0             	movsbl %al,%eax
  800471:	83 e8 20             	sub    $0x20,%eax
  800474:	83 f8 5e             	cmp    $0x5e,%eax
  800477:	76 c6                	jbe    80043f <vprintfmt+0x1f3>
					putch('?', putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	6a 3f                	push   $0x3f
  80047f:	ff d6                	call   *%esi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb c3                	jmp    800449 <vprintfmt+0x1fd>
  800486:	89 cf                	mov    %ecx,%edi
  800488:	eb 0e                	jmp    800498 <vprintfmt+0x24c>
				putch(' ', putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	53                   	push   %ebx
  80048e:	6a 20                	push   $0x20
  800490:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800492:	83 ef 01             	sub    $0x1,%edi
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 ff                	test   %edi,%edi
  80049a:	7f ee                	jg     80048a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80049c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049f:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a2:	e9 67 01 00 00       	jmp    80060e <vprintfmt+0x3c2>
  8004a7:	89 cf                	mov    %ecx,%edi
  8004a9:	eb ed                	jmp    800498 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ab:	83 f9 01             	cmp    $0x1,%ecx
  8004ae:	7f 1b                	jg     8004cb <vprintfmt+0x27f>
	else if (lflag)
  8004b0:	85 c9                	test   %ecx,%ecx
  8004b2:	74 63                	je     800517 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bc:	99                   	cltd   
  8004bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 40 04             	lea    0x4(%eax),%eax
  8004c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c9:	eb 17                	jmp    8004e2 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8b 50 04             	mov    0x4(%eax),%edx
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 40 08             	lea    0x8(%eax),%eax
  8004df:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e8:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	0f 89 ff 00 00 00    	jns    8005f4 <vprintfmt+0x3a8>
				putch('-', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	6a 2d                	push   $0x2d
  8004fb:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800500:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800503:	f7 da                	neg    %edx
  800505:	83 d1 00             	adc    $0x0,%ecx
  800508:	f7 d9                	neg    %ecx
  80050a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800512:	e9 dd 00 00 00       	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	99                   	cltd   
  800520:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 40 04             	lea    0x4(%eax),%eax
  800529:	89 45 14             	mov    %eax,0x14(%ebp)
  80052c:	eb b4                	jmp    8004e2 <vprintfmt+0x296>
	if (lflag >= 2)
  80052e:	83 f9 01             	cmp    $0x1,%ecx
  800531:	7f 1e                	jg     800551 <vprintfmt+0x305>
	else if (lflag)
  800533:	85 c9                	test   %ecx,%ecx
  800535:	74 32                	je     800569 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800541:	8d 40 04             	lea    0x4(%eax),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800547:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80054c:	e9 a3 00 00 00       	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8b 10                	mov    (%eax),%edx
  800556:	8b 48 04             	mov    0x4(%eax),%ecx
  800559:	8d 40 08             	lea    0x8(%eax),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800564:	e9 8b 00 00 00       	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800579:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80057e:	eb 74                	jmp    8005f4 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7f 1b                	jg     8005a0 <vprintfmt+0x354>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 2c                	je     8005b5 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800593:	8d 40 04             	lea    0x4(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800599:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80059e:	eb 54                	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a8:	8d 40 08             	lea    0x8(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ae:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005b3:	eb 3f                	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005ca:	eb 28                	jmp    8005f4 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 30                	push   $0x30
  8005d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d4:	83 c4 08             	add    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 78                	push   $0x78
  8005da:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ef:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 e0             	push   -0x20(%ebp)
  8005ff:	57                   	push   %edi
  800600:	51                   	push   %ecx
  800601:	52                   	push   %edx
  800602:	89 da                	mov    %ebx,%edx
  800604:	89 f0                	mov    %esi,%eax
  800606:	e8 5e fb ff ff       	call   800169 <printnum>
			break;
  80060b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800611:	e9 54 fc ff ff       	jmp    80026a <vprintfmt+0x1e>
	if (lflag >= 2)
  800616:	83 f9 01             	cmp    $0x1,%ecx
  800619:	7f 1b                	jg     800636 <vprintfmt+0x3ea>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 2c                	je     80064b <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 10                	mov    (%eax),%edx
  800624:	b9 00 00 00 00       	mov    $0x0,%ecx
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800634:	eb be                	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	8b 48 04             	mov    0x4(%eax),%ecx
  80063e:	8d 40 08             	lea    0x8(%eax),%eax
  800641:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800644:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800649:	eb a9                	jmp    8005f4 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800660:	eb 92                	jmp    8005f4 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 25                	push   $0x25
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb 9f                	jmp    80060e <vprintfmt+0x3c2>
			putch('%', putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 25                	push   $0x25
  800675:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	89 f8                	mov    %edi,%eax
  80067c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800680:	74 05                	je     800687 <vprintfmt+0x43b>
  800682:	83 e8 01             	sub    $0x1,%eax
  800685:	eb f5                	jmp    80067c <vprintfmt+0x430>
  800687:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068a:	eb 82                	jmp    80060e <vprintfmt+0x3c2>

0080068c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 18             	sub    $0x18,%esp
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	74 26                	je     8006d3 <vsnprintf+0x47>
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	7e 22                	jle    8006d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b1:	ff 75 14             	push   0x14(%ebp)
  8006b4:	ff 75 10             	push   0x10(%ebp)
  8006b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	68 12 02 80 00       	push   $0x800212
  8006c0:	e8 87 fb ff ff       	call   80024c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
}
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d8:	eb f7                	jmp    8006d1 <vsnprintf+0x45>

008006da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	push   0x10(%ebp)
  8006e7:	ff 75 0c             	push   0xc(%ebp)
  8006ea:	ff 75 08             	push   0x8(%ebp)
  8006ed:	e8 9a ff ff ff       	call   80068c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	eb 03                	jmp    800704 <strlen+0x10>
		n++;
  800701:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800704:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800708:	75 f7                	jne    800701 <strlen+0xd>
	return n;
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	b8 00 00 00 00       	mov    $0x0,%eax
  80071a:	eb 03                	jmp    80071f <strnlen+0x13>
		n++;
  80071c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 d0                	cmp    %edx,%eax
  800721:	74 08                	je     80072b <strnlen+0x1f>
  800723:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800727:	75 f3                	jne    80071c <strnlen+0x10>
  800729:	89 c2                	mov    %eax,%edx
	return n;
}
  80072b:	89 d0                	mov    %edx,%eax
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
  80073e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800742:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800745:	83 c0 01             	add    $0x1,%eax
  800748:	84 d2                	test   %dl,%dl
  80074a:	75 f2                	jne    80073e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074c:	89 c8                	mov    %ecx,%eax
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	83 ec 10             	sub    $0x10,%esp
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075d:	53                   	push   %ebx
  80075e:	e8 91 ff ff ff       	call   8006f4 <strlen>
  800763:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800766:	ff 75 0c             	push   0xc(%ebp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	50                   	push   %eax
  80076c:	e8 be ff ff ff       	call   80072f <strcpy>
	return dst;
}
  800771:	89 d8                	mov    %ebx,%eax
  800773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
  800783:	89 f3                	mov    %esi,%ebx
  800785:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	89 f0                	mov    %esi,%eax
  80078a:	eb 0f                	jmp    80079b <strncpy+0x23>
		*dst++ = *src;
  80078c:	83 c0 01             	add    $0x1,%eax
  80078f:	0f b6 0a             	movzbl (%edx),%ecx
  800792:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 f9 01             	cmp    $0x1,%cl
  800798:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80079b:	39 d8                	cmp    %ebx,%eax
  80079d:	75 ed                	jne    80078c <strncpy+0x14>
	}
	return ret;
}
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 21                	je     8007da <strlcpy+0x35>
  8007b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 09                	jmp    8007ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	83 c1 01             	add    $0x1,%ecx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 09                	je     8007d7 <strlcpy+0x32>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ec                	jne    8007c1 <strlcpy+0x1c>
  8007d5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007da:	29 f0                	sub    %esi,%eax
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strcmp+0x11>
		p++, q++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	84 c0                	test   %al,%al
  8007f6:	74 04                	je     8007fc <strcmp+0x1c>
  8007f8:	3a 02                	cmp    (%edx),%al
  8007fa:	74 ef                	je     8007eb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 c0             	movzbl %al,%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	89 c3                	mov    %eax,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800815:	eb 06                	jmp    80081d <strncmp+0x17>
		n--, p++, q++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 18                	je     800839 <strncmp+0x33>
  800821:	0f b6 08             	movzbl (%eax),%ecx
  800824:	84 c9                	test   %cl,%cl
  800826:	74 04                	je     80082c <strncmp+0x26>
  800828:	3a 0a                	cmp    (%edx),%cl
  80082a:	74 eb                	je     800817 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 00             	movzbl (%eax),%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
}
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
  80083e:	eb f4                	jmp    800834 <strncmp+0x2e>

00800840 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084a:	eb 03                	jmp    80084f <strchr+0xf>
  80084c:	83 c0 01             	add    $0x1,%eax
  80084f:	0f b6 10             	movzbl (%eax),%edx
  800852:	84 d2                	test   %dl,%dl
  800854:	74 06                	je     80085c <strchr+0x1c>
		if (*s == c)
  800856:	38 ca                	cmp    %cl,%dl
  800858:	75 f2                	jne    80084c <strchr+0xc>
  80085a:	eb 05                	jmp    800861 <strchr+0x21>
			return (char *) s;
	return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 09                	je     80087d <strfind+0x1a>
  800874:	84 d2                	test   %dl,%dl
  800876:	74 05                	je     80087d <strfind+0x1a>
	for (; *s; s++)
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	eb f0                	jmp    80086d <strfind+0xa>
			break;
	return (char *) s;
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	57                   	push   %edi
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 7d 08             	mov    0x8(%ebp),%edi
  800888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088b:	85 c9                	test   %ecx,%ecx
  80088d:	74 2f                	je     8008be <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088f:	89 f8                	mov    %edi,%eax
  800891:	09 c8                	or     %ecx,%eax
  800893:	a8 03                	test   $0x3,%al
  800895:	75 21                	jne    8008b8 <memset+0x39>
		c &= 0xFF;
  800897:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089b:	89 d0                	mov    %edx,%eax
  80089d:	c1 e0 08             	shl    $0x8,%eax
  8008a0:	89 d3                	mov    %edx,%ebx
  8008a2:	c1 e3 18             	shl    $0x18,%ebx
  8008a5:	89 d6                	mov    %edx,%esi
  8008a7:	c1 e6 10             	shl    $0x10,%esi
  8008aa:	09 f3                	or     %esi,%ebx
  8008ac:	09 da                	or     %ebx,%edx
  8008ae:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008b3:	fc                   	cld    
  8008b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b6:	eb 06                	jmp    8008be <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bb:	fc                   	cld    
  8008bc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008be:	89 f8                	mov    %edi,%eax
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5f                   	pop    %edi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d3:	39 c6                	cmp    %eax,%esi
  8008d5:	73 32                	jae    800909 <memmove+0x44>
  8008d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008da:	39 c2                	cmp    %eax,%edx
  8008dc:	76 2b                	jbe    800909 <memmove+0x44>
		s += n;
		d += n;
  8008de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e1:	89 d6                	mov    %edx,%esi
  8008e3:	09 fe                	or     %edi,%esi
  8008e5:	09 ce                	or     %ecx,%esi
  8008e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ed:	75 0e                	jne    8008fd <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ef:	83 ef 04             	sub    $0x4,%edi
  8008f2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008f8:	fd                   	std    
  8008f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fb:	eb 09                	jmp    800906 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fd:	83 ef 01             	sub    $0x1,%edi
  800900:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800903:	fd                   	std    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800906:	fc                   	cld    
  800907:	eb 1a                	jmp    800923 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800909:	89 f2                	mov    %esi,%edx
  80090b:	09 c2                	or     %eax,%edx
  80090d:	09 ca                	or     %ecx,%edx
  80090f:	f6 c2 03             	test   $0x3,%dl
  800912:	75 0a                	jne    80091e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800914:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800917:	89 c7                	mov    %eax,%edi
  800919:	fc                   	cld    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 05                	jmp    800923 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80091e:	89 c7                	mov    %eax,%edi
  800920:	fc                   	cld    
  800921:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80092d:	ff 75 10             	push   0x10(%ebp)
  800930:	ff 75 0c             	push   0xc(%ebp)
  800933:	ff 75 08             	push   0x8(%ebp)
  800936:	e8 8a ff ff ff       	call   8008c5 <memmove>
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	89 c6                	mov    %eax,%esi
  80094a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094d:	eb 06                	jmp    800955 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800955:	39 f0                	cmp    %esi,%eax
  800957:	74 14                	je     80096d <memcmp+0x30>
		if (*s1 != *s2)
  800959:	0f b6 08             	movzbl (%eax),%ecx
  80095c:	0f b6 1a             	movzbl (%edx),%ebx
  80095f:	38 d9                	cmp    %bl,%cl
  800961:	74 ec                	je     80094f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800963:	0f b6 c1             	movzbl %cl,%eax
  800966:	0f b6 db             	movzbl %bl,%ebx
  800969:	29 d8                	sub    %ebx,%eax
  80096b:	eb 05                	jmp    800972 <memcmp+0x35>
	}

	return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097f:	89 c2                	mov    %eax,%edx
  800981:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800984:	eb 03                	jmp    800989 <memfind+0x13>
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 04                	jae    800991 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098d:	38 08                	cmp    %cl,(%eax)
  80098f:	75 f5                	jne    800986 <memfind+0x10>
			break;
	return (void *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 55 08             	mov    0x8(%ebp),%edx
  80099c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099f:	eb 03                	jmp    8009a4 <strtol+0x11>
		s++;
  8009a1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009a4:	0f b6 02             	movzbl (%edx),%eax
  8009a7:	3c 20                	cmp    $0x20,%al
  8009a9:	74 f6                	je     8009a1 <strtol+0xe>
  8009ab:	3c 09                	cmp    $0x9,%al
  8009ad:	74 f2                	je     8009a1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009af:	3c 2b                	cmp    $0x2b,%al
  8009b1:	74 2a                	je     8009dd <strtol+0x4a>
	int neg = 0;
  8009b3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009b8:	3c 2d                	cmp    $0x2d,%al
  8009ba:	74 2b                	je     8009e7 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c2:	75 0f                	jne    8009d3 <strtol+0x40>
  8009c4:	80 3a 30             	cmpb   $0x30,(%edx)
  8009c7:	74 28                	je     8009f1 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c9:	85 db                	test   %ebx,%ebx
  8009cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d0:	0f 44 d8             	cmove  %eax,%ebx
  8009d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009db:	eb 46                	jmp    800a23 <strtol+0x90>
		s++;
  8009dd:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e5:	eb d5                	jmp    8009bc <strtol+0x29>
		s++, neg = 1;
  8009e7:	83 c2 01             	add    $0x1,%edx
  8009ea:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ef:	eb cb                	jmp    8009bc <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f5:	74 0e                	je     800a05 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 d8                	jne    8009d3 <strtol+0x40>
		s++, base = 8;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a03:	eb ce                	jmp    8009d3 <strtol+0x40>
		s += 2, base = 16;
  800a05:	83 c2 02             	add    $0x2,%edx
  800a08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0d:	eb c4                	jmp    8009d3 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a0f:	0f be c0             	movsbl %al,%eax
  800a12:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a15:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a18:	7d 3a                	jge    800a54 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a21:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a23:	0f b6 02             	movzbl (%edx),%eax
  800a26:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	80 fb 09             	cmp    $0x9,%bl
  800a2e:	76 df                	jbe    800a0f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a30:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 08                	ja     800a42 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a3a:	0f be c0             	movsbl %al,%eax
  800a3d:	83 e8 57             	sub    $0x57,%eax
  800a40:	eb d3                	jmp    800a15 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a42:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 08                	ja     800a54 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a4c:	0f be c0             	movsbl %al,%eax
  800a4f:	83 e8 37             	sub    $0x37,%eax
  800a52:	eb c1                	jmp    800a15 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a58:	74 05                	je     800a5f <strtol+0xcc>
		*endptr = (char *) s;
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a5f:	89 c8                	mov    %ecx,%eax
  800a61:	f7 d8                	neg    %eax
  800a63:	85 ff                	test   %edi,%edi
  800a65:	0f 45 c8             	cmovne %eax,%ecx
}
  800a68:	89 c8                	mov    %ecx,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	89 c7                	mov    %eax,%edi
  800a84:	89 c6                	mov    %eax,%esi
  800a86:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a93:	ba 00 00 00 00       	mov    $0x0,%edx
  800a98:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9d:	89 d1                	mov    %edx,%ecx
  800a9f:	89 d3                	mov    %edx,%ebx
  800aa1:	89 d7                	mov    %edx,%edi
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ab5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac2:	89 cb                	mov    %ecx,%ebx
  800ac4:	89 cf                	mov    %ecx,%edi
  800ac6:	89 ce                	mov    %ecx,%esi
  800ac8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800aca:	85 c0                	test   %eax,%eax
  800acc:	7f 08                	jg     800ad6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	50                   	push   %eax
  800ada:	6a 03                	push   $0x3
  800adc:	68 9f 20 80 00       	push   $0x80209f
  800ae1:	6a 2a                	push   $0x2a
  800ae3:	68 bc 20 80 00       	push   $0x8020bc
  800ae8:	e8 d0 0e 00 00       	call   8019bd <_panic>

00800aed <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 02 00 00 00       	mov    $0x2,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_yield>:

void
sys_yield(void)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b1c:	89 d1                	mov    %edx,%ecx
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	89 d7                	mov    %edx,%edi
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b34:	be 00 00 00 00       	mov    $0x0,%esi
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b47:	89 f7                	mov    %esi,%edi
  800b49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7f 08                	jg     800b57 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	50                   	push   %eax
  800b5b:	6a 04                	push   $0x4
  800b5d:	68 9f 20 80 00       	push   $0x80209f
  800b62:	6a 2a                	push   $0x2a
  800b64:	68 bc 20 80 00       	push   $0x8020bc
  800b69:	e8 4f 0e 00 00       	call   8019bd <_panic>

00800b6e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b88:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7f 08                	jg     800b99 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	50                   	push   %eax
  800b9d:	6a 05                	push   $0x5
  800b9f:	68 9f 20 80 00       	push   $0x80209f
  800ba4:	6a 2a                	push   $0x2a
  800ba6:	68 bc 20 80 00       	push   $0x8020bc
  800bab:	e8 0d 0e 00 00       	call   8019bd <_panic>

00800bb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc9:	89 df                	mov    %ebx,%edi
  800bcb:	89 de                	mov    %ebx,%esi
  800bcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7f 08                	jg     800bdb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 06                	push   $0x6
  800be1:	68 9f 20 80 00       	push   $0x80209f
  800be6:	6a 2a                	push   $0x2a
  800be8:	68 bc 20 80 00       	push   $0x8020bc
  800bed:	e8 cb 0d 00 00       	call   8019bd <_panic>

00800bf2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0b:	89 df                	mov    %ebx,%edi
  800c0d:	89 de                	mov    %ebx,%esi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7f 08                	jg     800c1d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 08                	push   $0x8
  800c23:	68 9f 20 80 00       	push   $0x80209f
  800c28:	6a 2a                	push   $0x2a
  800c2a:	68 bc 20 80 00       	push   $0x8020bc
  800c2f:	e8 89 0d 00 00       	call   8019bd <_panic>

00800c34 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7f 08                	jg     800c5f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 09                	push   $0x9
  800c65:	68 9f 20 80 00       	push   $0x80209f
  800c6a:	6a 2a                	push   $0x2a
  800c6c:	68 bc 20 80 00       	push   $0x8020bc
  800c71:	e8 47 0d 00 00       	call   8019bd <_panic>

00800c76 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7f 08                	jg     800ca1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 0a                	push   $0xa
  800ca7:	68 9f 20 80 00       	push   $0x80209f
  800cac:	6a 2a                	push   $0x2a
  800cae:	68 bc 20 80 00       	push   $0x8020bc
  800cb3:	e8 05 0d 00 00       	call   8019bd <_panic>

00800cb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc9:	be 00 00 00 00       	mov    $0x0,%esi
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf1:	89 cb                	mov    %ecx,%ebx
  800cf3:	89 cf                	mov    %ecx,%edi
  800cf5:	89 ce                	mov    %ecx,%esi
  800cf7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7f 08                	jg     800d05 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 0d                	push   $0xd
  800d0b:	68 9f 20 80 00       	push   $0x80209f
  800d10:	6a 2a                	push   $0x2a
  800d12:	68 bc 20 80 00       	push   $0x8020bc
  800d17:	e8 a1 0c 00 00       	call   8019bd <_panic>

00800d1c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	05 00 00 00 30       	add    $0x30000000,%eax
  800d27:	c1 e8 0c             	shr    $0xc,%eax
}
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d3c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d4b:	89 c2                	mov    %eax,%edx
  800d4d:	c1 ea 16             	shr    $0x16,%edx
  800d50:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d57:	f6 c2 01             	test   $0x1,%dl
  800d5a:	74 29                	je     800d85 <fd_alloc+0x42>
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	c1 ea 0c             	shr    $0xc,%edx
  800d61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d68:	f6 c2 01             	test   $0x1,%dl
  800d6b:	74 18                	je     800d85 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800d6d:	05 00 10 00 00       	add    $0x1000,%eax
  800d72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d77:	75 d2                	jne    800d4b <fd_alloc+0x8>
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800d7e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800d83:	eb 05                	jmp    800d8a <fd_alloc+0x47>
			return 0;
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	89 02                	mov    %eax,(%edx)
}
  800d8f:	89 c8                	mov    %ecx,%eax
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d99:	83 f8 1f             	cmp    $0x1f,%eax
  800d9c:	77 30                	ja     800dce <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d9e:	c1 e0 0c             	shl    $0xc,%eax
  800da1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800da6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800dac:	f6 c2 01             	test   $0x1,%dl
  800daf:	74 24                	je     800dd5 <fd_lookup+0x42>
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	c1 ea 0c             	shr    $0xc,%edx
  800db6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbd:	f6 c2 01             	test   $0x1,%dl
  800dc0:	74 1a                	je     800ddc <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc5:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
		return -E_INVAL;
  800dce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd3:	eb f7                	jmp    800dcc <fd_lookup+0x39>
		return -E_INVAL;
  800dd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dda:	eb f0                	jmp    800dcc <fd_lookup+0x39>
  800ddc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de1:	eb e9                	jmp    800dcc <fd_lookup+0x39>

00800de3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	53                   	push   %ebx
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	b8 48 21 80 00       	mov    $0x802148,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800df2:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800df7:	39 13                	cmp    %edx,(%ebx)
  800df9:	74 32                	je     800e2d <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800dfb:	83 c0 04             	add    $0x4,%eax
  800dfe:	8b 18                	mov    (%eax),%ebx
  800e00:	85 db                	test   %ebx,%ebx
  800e02:	75 f3                	jne    800df7 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e04:	a1 04 40 80 00       	mov    0x804004,%eax
  800e09:	8b 40 48             	mov    0x48(%eax),%eax
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	52                   	push   %edx
  800e10:	50                   	push   %eax
  800e11:	68 cc 20 80 00       	push   $0x8020cc
  800e16:	e8 3a f3 ff ff       	call   800155 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e26:	89 1a                	mov    %ebx,(%edx)
}
  800e28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    
			return 0;
  800e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e32:	eb ef                	jmp    800e23 <dev_lookup+0x40>

00800e34 <fd_close>:
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 24             	sub    $0x24,%esp
  800e3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e40:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e46:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e47:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e4d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e50:	50                   	push   %eax
  800e51:	e8 3d ff ff ff       	call   800d93 <fd_lookup>
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 05                	js     800e64 <fd_close+0x30>
	    || fd != fd2)
  800e5f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e62:	74 16                	je     800e7a <fd_close+0x46>
		return (must_exist ? r : 0);
  800e64:	89 f8                	mov    %edi,%eax
  800e66:	84 c0                	test   %al,%al
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6d:	0f 44 d8             	cmove  %eax,%ebx
}
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e80:	50                   	push   %eax
  800e81:	ff 36                	push   (%esi)
  800e83:	e8 5b ff ff ff       	call   800de3 <dev_lookup>
  800e88:	89 c3                	mov    %eax,%ebx
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 1a                	js     800eab <fd_close+0x77>
		if (dev->dev_close)
  800e91:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e94:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	74 0b                	je     800eab <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800ea0:	83 ec 0c             	sub    $0xc,%esp
  800ea3:	56                   	push   %esi
  800ea4:	ff d0                	call   *%eax
  800ea6:	89 c3                	mov    %eax,%ebx
  800ea8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	56                   	push   %esi
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 fa fc ff ff       	call   800bb0 <sys_page_unmap>
	return r;
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	eb b5                	jmp    800e70 <fd_close+0x3c>

00800ebb <close>:

int
close(int fdnum)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec4:	50                   	push   %eax
  800ec5:	ff 75 08             	push   0x8(%ebp)
  800ec8:	e8 c6 fe ff ff       	call   800d93 <fd_lookup>
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	79 02                	jns    800ed6 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    
		return fd_close(fd, 1);
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	6a 01                	push   $0x1
  800edb:	ff 75 f4             	push   -0xc(%ebp)
  800ede:	e8 51 ff ff ff       	call   800e34 <fd_close>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	eb ec                	jmp    800ed4 <close+0x19>

00800ee8 <close_all>:

void
close_all(void)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	53                   	push   %ebx
  800ef8:	e8 be ff ff ff       	call   800ebb <close>
	for (i = 0; i < MAXFD; i++)
  800efd:	83 c3 01             	add    $0x1,%ebx
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	83 fb 20             	cmp    $0x20,%ebx
  800f06:	75 ec                	jne    800ef4 <close_all+0xc>
}
  800f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f19:	50                   	push   %eax
  800f1a:	ff 75 08             	push   0x8(%ebp)
  800f1d:	e8 71 fe ff ff       	call   800d93 <fd_lookup>
  800f22:	89 c3                	mov    %eax,%ebx
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	78 7f                	js     800faa <dup+0x9d>
		return r;
	close(newfdnum);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	ff 75 0c             	push   0xc(%ebp)
  800f31:	e8 85 ff ff ff       	call   800ebb <close>

	newfd = INDEX2FD(newfdnum);
  800f36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f39:	c1 e6 0c             	shl    $0xc,%esi
  800f3c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f45:	89 3c 24             	mov    %edi,(%esp)
  800f48:	e8 df fd ff ff       	call   800d2c <fd2data>
  800f4d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f4f:	89 34 24             	mov    %esi,(%esp)
  800f52:	e8 d5 fd ff ff       	call   800d2c <fd2data>
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f5d:	89 d8                	mov    %ebx,%eax
  800f5f:	c1 e8 16             	shr    $0x16,%eax
  800f62:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f69:	a8 01                	test   $0x1,%al
  800f6b:	74 11                	je     800f7e <dup+0x71>
  800f6d:	89 d8                	mov    %ebx,%eax
  800f6f:	c1 e8 0c             	shr    $0xc,%eax
  800f72:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	75 36                	jne    800fb4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f7e:	89 f8                	mov    %edi,%eax
  800f80:	c1 e8 0c             	shr    $0xc,%eax
  800f83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f92:	50                   	push   %eax
  800f93:	56                   	push   %esi
  800f94:	6a 00                	push   $0x0
  800f96:	57                   	push   %edi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 d0 fb ff ff       	call   800b6e <sys_page_map>
  800f9e:	89 c3                	mov    %eax,%ebx
  800fa0:	83 c4 20             	add    $0x20,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 33                	js     800fda <dup+0xcd>
		goto err;

	return newfdnum;
  800fa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800faa:	89 d8                	mov    %ebx,%eax
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 75 d4             	push   -0x2c(%ebp)
  800fc7:	6a 00                	push   $0x0
  800fc9:	53                   	push   %ebx
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 9d fb ff ff       	call   800b6e <sys_page_map>
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	83 c4 20             	add    $0x20,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	79 a4                	jns    800f7e <dup+0x71>
	sys_page_unmap(0, newfd);
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 cb fb ff ff       	call   800bb0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	ff 75 d4             	push   -0x2c(%ebp)
  800feb:	6a 00                	push   $0x0
  800fed:	e8 be fb ff ff       	call   800bb0 <sys_page_unmap>
	return r;
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	eb b3                	jmp    800faa <dup+0x9d>

00800ff7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 18             	sub    $0x18,%esp
  800fff:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801002:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	56                   	push   %esi
  801007:	e8 87 fd ff ff       	call   800d93 <fd_lookup>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 3c                	js     80104f <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801013:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101c:	50                   	push   %eax
  80101d:	ff 33                	push   (%ebx)
  80101f:	e8 bf fd ff ff       	call   800de3 <dev_lookup>
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 24                	js     80104f <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80102b:	8b 43 08             	mov    0x8(%ebx),%eax
  80102e:	83 e0 03             	and    $0x3,%eax
  801031:	83 f8 01             	cmp    $0x1,%eax
  801034:	74 20                	je     801056 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801036:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801039:	8b 40 08             	mov    0x8(%eax),%eax
  80103c:	85 c0                	test   %eax,%eax
  80103e:	74 37                	je     801077 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	ff 75 10             	push   0x10(%ebp)
  801046:	ff 75 0c             	push   0xc(%ebp)
  801049:	53                   	push   %ebx
  80104a:	ff d0                	call   *%eax
  80104c:	83 c4 10             	add    $0x10,%esp
}
  80104f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801056:	a1 04 40 80 00       	mov    0x804004,%eax
  80105b:	8b 40 48             	mov    0x48(%eax),%eax
  80105e:	83 ec 04             	sub    $0x4,%esp
  801061:	56                   	push   %esi
  801062:	50                   	push   %eax
  801063:	68 0d 21 80 00       	push   $0x80210d
  801068:	e8 e8 f0 ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801075:	eb d8                	jmp    80104f <read+0x58>
		return -E_NOT_SUPP;
  801077:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80107c:	eb d1                	jmp    80104f <read+0x58>

0080107e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801092:	eb 02                	jmp    801096 <readn+0x18>
  801094:	01 c3                	add    %eax,%ebx
  801096:	39 f3                	cmp    %esi,%ebx
  801098:	73 21                	jae    8010bb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	89 f0                	mov    %esi,%eax
  80109f:	29 d8                	sub    %ebx,%eax
  8010a1:	50                   	push   %eax
  8010a2:	89 d8                	mov    %ebx,%eax
  8010a4:	03 45 0c             	add    0xc(%ebp),%eax
  8010a7:	50                   	push   %eax
  8010a8:	57                   	push   %edi
  8010a9:	e8 49 ff ff ff       	call   800ff7 <read>
		if (m < 0)
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	78 04                	js     8010b9 <readn+0x3b>
			return m;
		if (m == 0)
  8010b5:	75 dd                	jne    801094 <readn+0x16>
  8010b7:	eb 02                	jmp    8010bb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 18             	sub    $0x18,%esp
  8010cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d3:	50                   	push   %eax
  8010d4:	53                   	push   %ebx
  8010d5:	e8 b9 fc ff ff       	call   800d93 <fd_lookup>
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 37                	js     801118 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	ff 36                	push   (%esi)
  8010ed:	e8 f1 fc ff ff       	call   800de3 <dev_lookup>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 1f                	js     801118 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010f9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8010fd:	74 20                	je     80111f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801102:	8b 40 0c             	mov    0xc(%eax),%eax
  801105:	85 c0                	test   %eax,%eax
  801107:	74 37                	je     801140 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	ff 75 10             	push   0x10(%ebp)
  80110f:	ff 75 0c             	push   0xc(%ebp)
  801112:	56                   	push   %esi
  801113:	ff d0                	call   *%eax
  801115:	83 c4 10             	add    $0x10,%esp
}
  801118:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80111f:	a1 04 40 80 00       	mov    0x804004,%eax
  801124:	8b 40 48             	mov    0x48(%eax),%eax
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	53                   	push   %ebx
  80112b:	50                   	push   %eax
  80112c:	68 29 21 80 00       	push   $0x802129
  801131:	e8 1f f0 ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113e:	eb d8                	jmp    801118 <write+0x53>
		return -E_NOT_SUPP;
  801140:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801145:	eb d1                	jmp    801118 <write+0x53>

00801147 <seek>:

int
seek(int fdnum, off_t offset)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	ff 75 08             	push   0x8(%ebp)
  801154:	e8 3a fc ff ff       	call   800d93 <fd_lookup>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 0e                	js     80116e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801160:	8b 55 0c             	mov    0xc(%ebp),%edx
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 18             	sub    $0x18,%esp
  801178:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	53                   	push   %ebx
  801180:	e8 0e fc ff ff       	call   800d93 <fd_lookup>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 34                	js     8011c0 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	ff 36                	push   (%esi)
  801198:	e8 46 fc ff ff       	call   800de3 <dev_lookup>
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 1c                	js     8011c0 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a4:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011a8:	74 1d                	je     8011c7 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ad:	8b 40 18             	mov    0x18(%eax),%eax
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	74 34                	je     8011e8 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	ff 75 0c             	push   0xc(%ebp)
  8011ba:	56                   	push   %esi
  8011bb:	ff d0                	call   *%eax
  8011bd:	83 c4 10             	add    $0x10,%esp
}
  8011c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8011c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cc:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	53                   	push   %ebx
  8011d3:	50                   	push   %eax
  8011d4:	68 ec 20 80 00       	push   $0x8020ec
  8011d9:	e8 77 ef ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e6:	eb d8                	jmp    8011c0 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8011e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ed:	eb d1                	jmp    8011c0 <ftruncate+0x50>

008011ef <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 18             	sub    $0x18,%esp
  8011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 08             	push   0x8(%ebp)
  801201:	e8 8d fb ff ff       	call   800d93 <fd_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 49                	js     801256 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	ff 36                	push   (%esi)
  801219:	e8 c5 fb ff ff       	call   800de3 <dev_lookup>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 31                	js     801256 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801228:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80122c:	74 2f                	je     80125d <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80122e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801231:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801238:	00 00 00 
	stat->st_isdir = 0;
  80123b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801242:	00 00 00 
	stat->st_dev = dev;
  801245:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	53                   	push   %ebx
  80124f:	56                   	push   %esi
  801250:	ff 50 14             	call   *0x14(%eax)
  801253:	83 c4 10             	add    $0x10,%esp
}
  801256:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    
		return -E_NOT_SUPP;
  80125d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801262:	eb f2                	jmp    801256 <fstat+0x67>

00801264 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	6a 00                	push   $0x0
  80126e:	ff 75 08             	push   0x8(%ebp)
  801271:	e8 e4 01 00 00       	call   80145a <open>
  801276:	89 c3                	mov    %eax,%ebx
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 1b                	js     80129a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	ff 75 0c             	push   0xc(%ebp)
  801285:	50                   	push   %eax
  801286:	e8 64 ff ff ff       	call   8011ef <fstat>
  80128b:	89 c6                	mov    %eax,%esi
	close(fd);
  80128d:	89 1c 24             	mov    %ebx,(%esp)
  801290:	e8 26 fc ff ff       	call   800ebb <close>
	return r;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	89 f3                	mov    %esi,%ebx
}
  80129a:	89 d8                	mov    %ebx,%eax
  80129c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	89 c6                	mov    %eax,%esi
  8012aa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012ac:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8012b3:	74 27                	je     8012dc <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012b5:	6a 07                	push   $0x7
  8012b7:	68 00 50 80 00       	push   $0x805000
  8012bc:	56                   	push   %esi
  8012bd:	ff 35 00 60 80 00    	push   0x806000
  8012c3:	e8 a2 07 00 00       	call   801a6a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012c8:	83 c4 0c             	add    $0xc,%esp
  8012cb:	6a 00                	push   $0x0
  8012cd:	53                   	push   %ebx
  8012ce:	6a 00                	push   $0x0
  8012d0:	e8 2e 07 00 00       	call   801a03 <ipc_recv>
}
  8012d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	6a 01                	push   $0x1
  8012e1:	e8 d8 07 00 00       	call   801abe <ipc_find_env>
  8012e6:	a3 00 60 80 00       	mov    %eax,0x806000
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	eb c5                	jmp    8012b5 <fsipc+0x12>

008012f0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8012fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801301:	8b 45 0c             	mov    0xc(%ebp),%eax
  801304:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801309:	ba 00 00 00 00       	mov    $0x0,%edx
  80130e:	b8 02 00 00 00       	mov    $0x2,%eax
  801313:	e8 8b ff ff ff       	call   8012a3 <fsipc>
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <devfile_flush>:
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	8b 40 0c             	mov    0xc(%eax),%eax
  801326:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80132b:	ba 00 00 00 00       	mov    $0x0,%edx
  801330:	b8 06 00 00 00       	mov    $0x6,%eax
  801335:	e8 69 ff ff ff       	call   8012a3 <fsipc>
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <devfile_stat>:
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801346:	8b 45 08             	mov    0x8(%ebp),%eax
  801349:	8b 40 0c             	mov    0xc(%eax),%eax
  80134c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801351:	ba 00 00 00 00       	mov    $0x0,%edx
  801356:	b8 05 00 00 00       	mov    $0x5,%eax
  80135b:	e8 43 ff ff ff       	call   8012a3 <fsipc>
  801360:	85 c0                	test   %eax,%eax
  801362:	78 2c                	js     801390 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	68 00 50 80 00       	push   $0x805000
  80136c:	53                   	push   %ebx
  80136d:	e8 bd f3 ff ff       	call   80072f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801372:	a1 80 50 80 00       	mov    0x805080,%eax
  801377:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80137d:	a1 84 50 80 00       	mov    0x805084,%eax
  801382:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <devfile_write>:
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	8b 45 10             	mov    0x10(%ebp),%eax
  80139e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013a3:	39 d0                	cmp    %edx,%eax
  8013a5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ae:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013b4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013b9:	50                   	push   %eax
  8013ba:	ff 75 0c             	push   0xc(%ebp)
  8013bd:	68 08 50 80 00       	push   $0x805008
  8013c2:	e8 fe f4 ff ff       	call   8008c5 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d1:	e8 cd fe ff ff       	call   8012a3 <fsipc>
}
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <devfile_read>:
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fb:	e8 a3 fe ff ff       	call   8012a3 <fsipc>
  801400:	89 c3                	mov    %eax,%ebx
  801402:	85 c0                	test   %eax,%eax
  801404:	78 1f                	js     801425 <devfile_read+0x4d>
	assert(r <= n);
  801406:	39 f0                	cmp    %esi,%eax
  801408:	77 24                	ja     80142e <devfile_read+0x56>
	assert(r <= PGSIZE);
  80140a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80140f:	7f 33                	jg     801444 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	50                   	push   %eax
  801415:	68 00 50 80 00       	push   $0x805000
  80141a:	ff 75 0c             	push   0xc(%ebp)
  80141d:	e8 a3 f4 ff ff       	call   8008c5 <memmove>
	return r;
  801422:	83 c4 10             	add    $0x10,%esp
}
  801425:	89 d8                	mov    %ebx,%eax
  801427:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    
	assert(r <= n);
  80142e:	68 58 21 80 00       	push   $0x802158
  801433:	68 5f 21 80 00       	push   $0x80215f
  801438:	6a 7c                	push   $0x7c
  80143a:	68 74 21 80 00       	push   $0x802174
  80143f:	e8 79 05 00 00       	call   8019bd <_panic>
	assert(r <= PGSIZE);
  801444:	68 7f 21 80 00       	push   $0x80217f
  801449:	68 5f 21 80 00       	push   $0x80215f
  80144e:	6a 7d                	push   $0x7d
  801450:	68 74 21 80 00       	push   $0x802174
  801455:	e8 63 05 00 00       	call   8019bd <_panic>

0080145a <open>:
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	83 ec 1c             	sub    $0x1c,%esp
  801462:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801465:	56                   	push   %esi
  801466:	e8 89 f2 ff ff       	call   8006f4 <strlen>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801473:	7f 6c                	jg     8014e1 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	e8 c2 f8 ff ff       	call   800d43 <fd_alloc>
  801481:	89 c3                	mov    %eax,%ebx
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 3c                	js     8014c6 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	56                   	push   %esi
  80148e:	68 00 50 80 00       	push   $0x805000
  801493:	e8 97 f2 ff ff       	call   80072f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a8:	e8 f6 fd ff ff       	call   8012a3 <fsipc>
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 19                	js     8014cf <open+0x75>
	return fd2num(fd);
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	ff 75 f4             	push   -0xc(%ebp)
  8014bc:	e8 5b f8 ff ff       	call   800d1c <fd2num>
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	83 c4 10             	add    $0x10,%esp
}
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    
		fd_close(fd, 0);
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	6a 00                	push   $0x0
  8014d4:	ff 75 f4             	push   -0xc(%ebp)
  8014d7:	e8 58 f9 ff ff       	call   800e34 <fd_close>
		return r;
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	eb e5                	jmp    8014c6 <open+0x6c>
		return -E_BAD_PATH;
  8014e1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014e6:	eb de                	jmp    8014c6 <open+0x6c>

008014e8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f8:	e8 a6 fd ff ff       	call   8012a3 <fsipc>
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	ff 75 08             	push   0x8(%ebp)
  80150d:	e8 1a f8 ff ff       	call   800d2c <fd2data>
  801512:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	68 8b 21 80 00       	push   $0x80218b
  80151c:	53                   	push   %ebx
  80151d:	e8 0d f2 ff ff       	call   80072f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801522:	8b 46 04             	mov    0x4(%esi),%eax
  801525:	2b 06                	sub    (%esi),%eax
  801527:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80152d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801534:	00 00 00 
	stat->st_dev = &devpipe;
  801537:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80153e:	30 80 00 
	return 0;
}
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
  801546:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801557:	53                   	push   %ebx
  801558:	6a 00                	push   $0x0
  80155a:	e8 51 f6 ff ff       	call   800bb0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80155f:	89 1c 24             	mov    %ebx,(%esp)
  801562:	e8 c5 f7 ff ff       	call   800d2c <fd2data>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	50                   	push   %eax
  80156b:	6a 00                	push   $0x0
  80156d:	e8 3e f6 ff ff       	call   800bb0 <sys_page_unmap>
}
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <_pipeisclosed>:
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	83 ec 1c             	sub    $0x1c,%esp
  801580:	89 c7                	mov    %eax,%edi
  801582:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801584:	a1 04 40 80 00       	mov    0x804004,%eax
  801589:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	57                   	push   %edi
  801590:	e8 62 05 00 00       	call   801af7 <pageref>
  801595:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801598:	89 34 24             	mov    %esi,(%esp)
  80159b:	e8 57 05 00 00       	call   801af7 <pageref>
		nn = thisenv->env_runs;
  8015a0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015a6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	39 cb                	cmp    %ecx,%ebx
  8015ae:	74 1b                	je     8015cb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015b3:	75 cf                	jne    801584 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015b5:	8b 42 58             	mov    0x58(%edx),%eax
  8015b8:	6a 01                	push   $0x1
  8015ba:	50                   	push   %eax
  8015bb:	53                   	push   %ebx
  8015bc:	68 92 21 80 00       	push   $0x802192
  8015c1:	e8 8f eb ff ff       	call   800155 <cprintf>
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	eb b9                	jmp    801584 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015cb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015ce:	0f 94 c0             	sete   %al
  8015d1:	0f b6 c0             	movzbl %al,%eax
}
  8015d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	5f                   	pop    %edi
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <devpipe_write>:
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	57                   	push   %edi
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 28             	sub    $0x28,%esp
  8015e5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8015e8:	56                   	push   %esi
  8015e9:	e8 3e f7 ff ff       	call   800d2c <fd2data>
  8015ee:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015fb:	75 09                	jne    801606 <devpipe_write+0x2a>
	return i;
  8015fd:	89 f8                	mov    %edi,%eax
  8015ff:	eb 23                	jmp    801624 <devpipe_write+0x48>
			sys_yield();
  801601:	e8 06 f5 ff ff       	call   800b0c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801606:	8b 43 04             	mov    0x4(%ebx),%eax
  801609:	8b 0b                	mov    (%ebx),%ecx
  80160b:	8d 51 20             	lea    0x20(%ecx),%edx
  80160e:	39 d0                	cmp    %edx,%eax
  801610:	72 1a                	jb     80162c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801612:	89 da                	mov    %ebx,%edx
  801614:	89 f0                	mov    %esi,%eax
  801616:	e8 5c ff ff ff       	call   801577 <_pipeisclosed>
  80161b:	85 c0                	test   %eax,%eax
  80161d:	74 e2                	je     801601 <devpipe_write+0x25>
				return 0;
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801624:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5f                   	pop    %edi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80162c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801633:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801636:	89 c2                	mov    %eax,%edx
  801638:	c1 fa 1f             	sar    $0x1f,%edx
  80163b:	89 d1                	mov    %edx,%ecx
  80163d:	c1 e9 1b             	shr    $0x1b,%ecx
  801640:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801643:	83 e2 1f             	and    $0x1f,%edx
  801646:	29 ca                	sub    %ecx,%edx
  801648:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80164c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801650:	83 c0 01             	add    $0x1,%eax
  801653:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801656:	83 c7 01             	add    $0x1,%edi
  801659:	eb 9d                	jmp    8015f8 <devpipe_write+0x1c>

0080165b <devpipe_read>:
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	57                   	push   %edi
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 18             	sub    $0x18,%esp
  801664:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801667:	57                   	push   %edi
  801668:	e8 bf f6 ff ff       	call   800d2c <fd2data>
  80166d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	be 00 00 00 00       	mov    $0x0,%esi
  801677:	3b 75 10             	cmp    0x10(%ebp),%esi
  80167a:	75 13                	jne    80168f <devpipe_read+0x34>
	return i;
  80167c:	89 f0                	mov    %esi,%eax
  80167e:	eb 02                	jmp    801682 <devpipe_read+0x27>
				return i;
  801680:	89 f0                	mov    %esi,%eax
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    
			sys_yield();
  80168a:	e8 7d f4 ff ff       	call   800b0c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80168f:	8b 03                	mov    (%ebx),%eax
  801691:	3b 43 04             	cmp    0x4(%ebx),%eax
  801694:	75 18                	jne    8016ae <devpipe_read+0x53>
			if (i > 0)
  801696:	85 f6                	test   %esi,%esi
  801698:	75 e6                	jne    801680 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80169a:	89 da                	mov    %ebx,%edx
  80169c:	89 f8                	mov    %edi,%eax
  80169e:	e8 d4 fe ff ff       	call   801577 <_pipeisclosed>
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	74 e3                	je     80168a <devpipe_read+0x2f>
				return 0;
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ac:	eb d4                	jmp    801682 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ae:	99                   	cltd   
  8016af:	c1 ea 1b             	shr    $0x1b,%edx
  8016b2:	01 d0                	add    %edx,%eax
  8016b4:	83 e0 1f             	and    $0x1f,%eax
  8016b7:	29 d0                	sub    %edx,%eax
  8016b9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016c4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016c7:	83 c6 01             	add    $0x1,%esi
  8016ca:	eb ab                	jmp    801677 <devpipe_read+0x1c>

008016cc <pipe>:
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	e8 66 f6 ff ff       	call   800d43 <fd_alloc>
  8016dd:	89 c3                	mov    %eax,%ebx
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	0f 88 23 01 00 00    	js     80180d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016ea:	83 ec 04             	sub    $0x4,%esp
  8016ed:	68 07 04 00 00       	push   $0x407
  8016f2:	ff 75 f4             	push   -0xc(%ebp)
  8016f5:	6a 00                	push   $0x0
  8016f7:	e8 2f f4 ff ff       	call   800b2b <sys_page_alloc>
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	0f 88 04 01 00 00    	js     80180d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	e8 2e f6 ff ff       	call   800d43 <fd_alloc>
  801715:	89 c3                	mov    %eax,%ebx
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	0f 88 db 00 00 00    	js     8017fd <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801722:	83 ec 04             	sub    $0x4,%esp
  801725:	68 07 04 00 00       	push   $0x407
  80172a:	ff 75 f0             	push   -0x10(%ebp)
  80172d:	6a 00                	push   $0x0
  80172f:	e8 f7 f3 ff ff       	call   800b2b <sys_page_alloc>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	0f 88 bc 00 00 00    	js     8017fd <pipe+0x131>
	va = fd2data(fd0);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	ff 75 f4             	push   -0xc(%ebp)
  801747:	e8 e0 f5 ff ff       	call   800d2c <fd2data>
  80174c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174e:	83 c4 0c             	add    $0xc,%esp
  801751:	68 07 04 00 00       	push   $0x407
  801756:	50                   	push   %eax
  801757:	6a 00                	push   $0x0
  801759:	e8 cd f3 ff ff       	call   800b2b <sys_page_alloc>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	0f 88 82 00 00 00    	js     8017ed <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176b:	83 ec 0c             	sub    $0xc,%esp
  80176e:	ff 75 f0             	push   -0x10(%ebp)
  801771:	e8 b6 f5 ff ff       	call   800d2c <fd2data>
  801776:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80177d:	50                   	push   %eax
  80177e:	6a 00                	push   $0x0
  801780:	56                   	push   %esi
  801781:	6a 00                	push   $0x0
  801783:	e8 e6 f3 ff ff       	call   800b6e <sys_page_map>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	83 c4 20             	add    $0x20,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 4e                	js     8017df <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801791:	a1 20 30 80 00       	mov    0x803020,%eax
  801796:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801799:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80179b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8017a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	ff 75 f4             	push   -0xc(%ebp)
  8017ba:	e8 5d f5 ff ff       	call   800d1c <fd2num>
  8017bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017c4:	83 c4 04             	add    $0x4,%esp
  8017c7:	ff 75 f0             	push   -0x10(%ebp)
  8017ca:	e8 4d f5 ff ff       	call   800d1c <fd2num>
  8017cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017dd:	eb 2e                	jmp    80180d <pipe+0x141>
	sys_page_unmap(0, va);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	56                   	push   %esi
  8017e3:	6a 00                	push   $0x0
  8017e5:	e8 c6 f3 ff ff       	call   800bb0 <sys_page_unmap>
  8017ea:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	ff 75 f0             	push   -0x10(%ebp)
  8017f3:	6a 00                	push   $0x0
  8017f5:	e8 b6 f3 ff ff       	call   800bb0 <sys_page_unmap>
  8017fa:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	ff 75 f4             	push   -0xc(%ebp)
  801803:	6a 00                	push   $0x0
  801805:	e8 a6 f3 ff ff       	call   800bb0 <sys_page_unmap>
  80180a:	83 c4 10             	add    $0x10,%esp
}
  80180d:	89 d8                	mov    %ebx,%eax
  80180f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <pipeisclosed>:
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	ff 75 08             	push   0x8(%ebp)
  801823:	e8 6b f5 ff ff       	call   800d93 <fd_lookup>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 18                	js     801847 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	ff 75 f4             	push   -0xc(%ebp)
  801835:	e8 f2 f4 ff ff       	call   800d2c <fd2data>
  80183a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183f:	e8 33 fd ff ff       	call   801577 <_pipeisclosed>
  801844:	83 c4 10             	add    $0x10,%esp
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801849:	b8 00 00 00 00       	mov    $0x0,%eax
  80184e:	c3                   	ret    

0080184f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801855:	68 aa 21 80 00       	push   $0x8021aa
  80185a:	ff 75 0c             	push   0xc(%ebp)
  80185d:	e8 cd ee ff ff       	call   80072f <strcpy>
	return 0;
}
  801862:	b8 00 00 00 00       	mov    $0x0,%eax
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <devcons_write>:
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801875:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80187a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801880:	eb 2e                	jmp    8018b0 <devcons_write+0x47>
		m = n - tot;
  801882:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801885:	29 f3                	sub    %esi,%ebx
  801887:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80188c:	39 c3                	cmp    %eax,%ebx
  80188e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	53                   	push   %ebx
  801895:	89 f0                	mov    %esi,%eax
  801897:	03 45 0c             	add    0xc(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	57                   	push   %edi
  80189c:	e8 24 f0 ff ff       	call   8008c5 <memmove>
		sys_cputs(buf, m);
  8018a1:	83 c4 08             	add    $0x8,%esp
  8018a4:	53                   	push   %ebx
  8018a5:	57                   	push   %edi
  8018a6:	e8 c4 f1 ff ff       	call   800a6f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018ab:	01 de                	add    %ebx,%esi
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b3:	72 cd                	jb     801882 <devcons_write+0x19>
}
  8018b5:	89 f0                	mov    %esi,%eax
  8018b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devcons_read>:
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8018ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ce:	75 07                	jne    8018d7 <devcons_read+0x18>
  8018d0:	eb 1f                	jmp    8018f1 <devcons_read+0x32>
		sys_yield();
  8018d2:	e8 35 f2 ff ff       	call   800b0c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8018d7:	e8 b1 f1 ff ff       	call   800a8d <sys_cgetc>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	74 f2                	je     8018d2 <devcons_read+0x13>
	if (c < 0)
  8018e0:	78 0f                	js     8018f1 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8018e2:	83 f8 04             	cmp    $0x4,%eax
  8018e5:	74 0c                	je     8018f3 <devcons_read+0x34>
	*(char*)vbuf = c;
  8018e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ea:	88 02                	mov    %al,(%edx)
	return 1;
  8018ec:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    
		return 0;
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f8:	eb f7                	jmp    8018f1 <devcons_read+0x32>

008018fa <cputchar>:
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801906:	6a 01                	push   $0x1
  801908:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80190b:	50                   	push   %eax
  80190c:	e8 5e f1 ff ff       	call   800a6f <sys_cputs>
}
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <getchar>:
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80191c:	6a 01                	push   $0x1
  80191e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801921:	50                   	push   %eax
  801922:	6a 00                	push   $0x0
  801924:	e8 ce f6 ff ff       	call   800ff7 <read>
	if (r < 0)
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 06                	js     801936 <getchar+0x20>
	if (r < 1)
  801930:	74 06                	je     801938 <getchar+0x22>
	return c;
  801932:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801936:	c9                   	leave  
  801937:	c3                   	ret    
		return -E_EOF;
  801938:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80193d:	eb f7                	jmp    801936 <getchar+0x20>

0080193f <iscons>:
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	ff 75 08             	push   0x8(%ebp)
  80194c:	e8 42 f4 ff ff       	call   800d93 <fd_lookup>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	85 c0                	test   %eax,%eax
  801956:	78 11                	js     801969 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801961:	39 10                	cmp    %edx,(%eax)
  801963:	0f 94 c0             	sete   %al
  801966:	0f b6 c0             	movzbl %al,%eax
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <opencons>:
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801971:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801974:	50                   	push   %eax
  801975:	e8 c9 f3 ff ff       	call   800d43 <fd_alloc>
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 3a                	js     8019bb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801981:	83 ec 04             	sub    $0x4,%esp
  801984:	68 07 04 00 00       	push   $0x407
  801989:	ff 75 f4             	push   -0xc(%ebp)
  80198c:	6a 00                	push   $0x0
  80198e:	e8 98 f1 ff ff       	call   800b2b <sys_page_alloc>
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	85 c0                	test   %eax,%eax
  801998:	78 21                	js     8019bb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	50                   	push   %eax
  8019b3:	e8 64 f3 ff ff       	call   800d1c <fd2num>
  8019b8:	83 c4 10             	add    $0x10,%esp
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	56                   	push   %esi
  8019c1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019c5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019cb:	e8 1d f1 ff ff       	call   800aed <sys_getenvid>
  8019d0:	83 ec 0c             	sub    $0xc,%esp
  8019d3:	ff 75 0c             	push   0xc(%ebp)
  8019d6:	ff 75 08             	push   0x8(%ebp)
  8019d9:	56                   	push   %esi
  8019da:	50                   	push   %eax
  8019db:	68 b8 21 80 00       	push   $0x8021b8
  8019e0:	e8 70 e7 ff ff       	call   800155 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019e5:	83 c4 18             	add    $0x18,%esp
  8019e8:	53                   	push   %ebx
  8019e9:	ff 75 10             	push   0x10(%ebp)
  8019ec:	e8 13 e7 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  8019f1:	c7 04 24 8c 1d 80 00 	movl   $0x801d8c,(%esp)
  8019f8:	e8 58 e7 ff ff       	call   800155 <cprintf>
  8019fd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a00:	cc                   	int3   
  801a01:	eb fd                	jmp    801a00 <_panic+0x43>

00801a03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a11:	85 c0                	test   %eax,%eax
  801a13:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a18:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	50                   	push   %eax
  801a1f:	e8 b7 f2 ff ff       	call   800cdb <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 f6                	test   %esi,%esi
  801a29:	74 14                	je     801a3f <ipc_recv+0x3c>
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 09                	js     801a3d <ipc_recv+0x3a>
  801a34:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a3a:	8b 52 74             	mov    0x74(%edx),%edx
  801a3d:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a3f:	85 db                	test   %ebx,%ebx
  801a41:	74 14                	je     801a57 <ipc_recv+0x54>
  801a43:	ba 00 00 00 00       	mov    $0x0,%edx
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 09                	js     801a55 <ipc_recv+0x52>
  801a4c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a52:	8b 52 78             	mov    0x78(%edx),%edx
  801a55:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 08                	js     801a63 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a5b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a60:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	57                   	push   %edi
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a7c:	85 db                	test   %ebx,%ebx
  801a7e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a83:	0f 44 d8             	cmove  %eax,%ebx
  801a86:	eb 05                	jmp    801a8d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a88:	e8 7f f0 ff ff       	call   800b0c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a8d:	ff 75 14             	push   0x14(%ebp)
  801a90:	53                   	push   %ebx
  801a91:	56                   	push   %esi
  801a92:	57                   	push   %edi
  801a93:	e8 20 f2 ff ff       	call   800cb8 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9e:	74 e8                	je     801a88 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 08                	js     801aac <ipc_send+0x42>
	}while (r<0);

}
  801aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5f                   	pop    %edi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801aac:	50                   	push   %eax
  801aad:	68 db 21 80 00       	push   $0x8021db
  801ab2:	6a 3d                	push   $0x3d
  801ab4:	68 ef 21 80 00       	push   $0x8021ef
  801ab9:	e8 ff fe ff ff       	call   8019bd <_panic>

00801abe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad2:	8b 52 50             	mov    0x50(%edx),%edx
  801ad5:	39 ca                	cmp    %ecx,%edx
  801ad7:	74 11                	je     801aea <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ad9:	83 c0 01             	add    $0x1,%eax
  801adc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ae1:	75 e6                	jne    801ac9 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	eb 0b                	jmp    801af5 <ipc_find_env+0x37>
			return envs[i].env_id;
  801aea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af2:	8b 40 48             	mov    0x48(%eax),%eax
}
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	c1 ea 16             	shr    $0x16,%edx
  801b02:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b09:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b0e:	f6 c1 01             	test   $0x1,%cl
  801b11:	74 1c                	je     801b2f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b13:	c1 e8 0c             	shr    $0xc,%eax
  801b16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b1d:	a8 01                	test   $0x1,%al
  801b1f:	74 0e                	je     801b2f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b21:	c1 e8 0c             	shr    $0xc,%eax
  801b24:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b2b:	ef 
  801b2c:	0f b7 d2             	movzwl %dx,%edx
}
  801b2f:	89 d0                	mov    %edx,%eax
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    
  801b33:	66 90                	xchg   %ax,%ax
  801b35:	66 90                	xchg   %ax,%ax
  801b37:	66 90                	xchg   %ax,%ax
  801b39:	66 90                	xchg   %ax,%ax
  801b3b:	66 90                	xchg   %ax,%ax
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	f3 0f 1e fb          	endbr32 
  801b44:	55                   	push   %ebp
  801b45:	57                   	push   %edi
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 1c             	sub    $0x1c,%esp
  801b4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b53:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	75 19                	jne    801b78 <__udivdi3+0x38>
  801b5f:	39 f3                	cmp    %esi,%ebx
  801b61:	76 4d                	jbe    801bb0 <__udivdi3+0x70>
  801b63:	31 ff                	xor    %edi,%edi
  801b65:	89 e8                	mov    %ebp,%eax
  801b67:	89 f2                	mov    %esi,%edx
  801b69:	f7 f3                	div    %ebx
  801b6b:	89 fa                	mov    %edi,%edx
  801b6d:	83 c4 1c             	add    $0x1c,%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5f                   	pop    %edi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    
  801b75:	8d 76 00             	lea    0x0(%esi),%esi
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	76 14                	jbe    801b90 <__udivdi3+0x50>
  801b7c:	31 ff                	xor    %edi,%edi
  801b7e:	31 c0                	xor    %eax,%eax
  801b80:	89 fa                	mov    %edi,%edx
  801b82:	83 c4 1c             	add    $0x1c,%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
  801b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b90:	0f bd f8             	bsr    %eax,%edi
  801b93:	83 f7 1f             	xor    $0x1f,%edi
  801b96:	75 48                	jne    801be0 <__udivdi3+0xa0>
  801b98:	39 f0                	cmp    %esi,%eax
  801b9a:	72 06                	jb     801ba2 <__udivdi3+0x62>
  801b9c:	31 c0                	xor    %eax,%eax
  801b9e:	39 eb                	cmp    %ebp,%ebx
  801ba0:	77 de                	ja     801b80 <__udivdi3+0x40>
  801ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba7:	eb d7                	jmp    801b80 <__udivdi3+0x40>
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	89 d9                	mov    %ebx,%ecx
  801bb2:	85 db                	test   %ebx,%ebx
  801bb4:	75 0b                	jne    801bc1 <__udivdi3+0x81>
  801bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbb:	31 d2                	xor    %edx,%edx
  801bbd:	f7 f3                	div    %ebx
  801bbf:	89 c1                	mov    %eax,%ecx
  801bc1:	31 d2                	xor    %edx,%edx
  801bc3:	89 f0                	mov    %esi,%eax
  801bc5:	f7 f1                	div    %ecx
  801bc7:	89 c6                	mov    %eax,%esi
  801bc9:	89 e8                	mov    %ebp,%eax
  801bcb:	89 f7                	mov    %esi,%edi
  801bcd:	f7 f1                	div    %ecx
  801bcf:	89 fa                	mov    %edi,%edx
  801bd1:	83 c4 1c             	add    $0x1c,%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	ba 20 00 00 00       	mov    $0x20,%edx
  801be7:	29 fa                	sub    %edi,%edx
  801be9:	d3 e0                	shl    %cl,%eax
  801beb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bef:	89 d1                	mov    %edx,%ecx
  801bf1:	89 d8                	mov    %ebx,%eax
  801bf3:	d3 e8                	shr    %cl,%eax
  801bf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bf9:	09 c1                	or     %eax,%ecx
  801bfb:	89 f0                	mov    %esi,%eax
  801bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e3                	shl    %cl,%ebx
  801c05:	89 d1                	mov    %edx,%ecx
  801c07:	d3 e8                	shr    %cl,%eax
  801c09:	89 f9                	mov    %edi,%ecx
  801c0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c0f:	89 eb                	mov    %ebp,%ebx
  801c11:	d3 e6                	shl    %cl,%esi
  801c13:	89 d1                	mov    %edx,%ecx
  801c15:	d3 eb                	shr    %cl,%ebx
  801c17:	09 f3                	or     %esi,%ebx
  801c19:	89 c6                	mov    %eax,%esi
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	89 d8                	mov    %ebx,%eax
  801c1f:	f7 74 24 08          	divl   0x8(%esp)
  801c23:	89 d6                	mov    %edx,%esi
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	f7 64 24 0c          	mull   0xc(%esp)
  801c2b:	39 d6                	cmp    %edx,%esi
  801c2d:	72 19                	jb     801c48 <__udivdi3+0x108>
  801c2f:	89 f9                	mov    %edi,%ecx
  801c31:	d3 e5                	shl    %cl,%ebp
  801c33:	39 c5                	cmp    %eax,%ebp
  801c35:	73 04                	jae    801c3b <__udivdi3+0xfb>
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	74 0d                	je     801c48 <__udivdi3+0x108>
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	31 ff                	xor    %edi,%edi
  801c3f:	e9 3c ff ff ff       	jmp    801b80 <__udivdi3+0x40>
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4b:	31 ff                	xor    %edi,%edi
  801c4d:	e9 2e ff ff ff       	jmp    801b80 <__udivdi3+0x40>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
  801c6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c7b:	89 f0                	mov    %esi,%eax
  801c7d:	89 da                	mov    %ebx,%edx
  801c7f:	85 ff                	test   %edi,%edi
  801c81:	75 15                	jne    801c98 <__umoddi3+0x38>
  801c83:	39 dd                	cmp    %ebx,%ebp
  801c85:	76 39                	jbe    801cc0 <__umoddi3+0x60>
  801c87:	f7 f5                	div    %ebp
  801c89:	89 d0                	mov    %edx,%eax
  801c8b:	31 d2                	xor    %edx,%edx
  801c8d:	83 c4 1c             	add    $0x1c,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    
  801c95:	8d 76 00             	lea    0x0(%esi),%esi
  801c98:	39 df                	cmp    %ebx,%edi
  801c9a:	77 f1                	ja     801c8d <__umoddi3+0x2d>
  801c9c:	0f bd cf             	bsr    %edi,%ecx
  801c9f:	83 f1 1f             	xor    $0x1f,%ecx
  801ca2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ca6:	75 40                	jne    801ce8 <__umoddi3+0x88>
  801ca8:	39 df                	cmp    %ebx,%edi
  801caa:	72 04                	jb     801cb0 <__umoddi3+0x50>
  801cac:	39 f5                	cmp    %esi,%ebp
  801cae:	77 dd                	ja     801c8d <__umoddi3+0x2d>
  801cb0:	89 da                	mov    %ebx,%edx
  801cb2:	89 f0                	mov    %esi,%eax
  801cb4:	29 e8                	sub    %ebp,%eax
  801cb6:	19 fa                	sbb    %edi,%edx
  801cb8:	eb d3                	jmp    801c8d <__umoddi3+0x2d>
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	89 e9                	mov    %ebp,%ecx
  801cc2:	85 ed                	test   %ebp,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0x71>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f5                	div    %ebp
  801ccf:	89 c1                	mov    %eax,%ecx
  801cd1:	89 d8                	mov    %ebx,%eax
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	f7 f1                	div    %ecx
  801cd7:	89 f0                	mov    %esi,%eax
  801cd9:	f7 f1                	div    %ecx
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	31 d2                	xor    %edx,%edx
  801cdf:	eb ac                	jmp    801c8d <__umoddi3+0x2d>
  801ce1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cec:	ba 20 00 00 00       	mov    $0x20,%edx
  801cf1:	29 c2                	sub    %eax,%edx
  801cf3:	89 c1                	mov    %eax,%ecx
  801cf5:	89 e8                	mov    %ebp,%eax
  801cf7:	d3 e7                	shl    %cl,%edi
  801cf9:	89 d1                	mov    %edx,%ecx
  801cfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cff:	d3 e8                	shr    %cl,%eax
  801d01:	89 c1                	mov    %eax,%ecx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	09 f9                	or     %edi,%ecx
  801d09:	89 df                	mov    %ebx,%edi
  801d0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	d3 e5                	shl    %cl,%ebp
  801d13:	89 d1                	mov    %edx,%ecx
  801d15:	d3 ef                	shr    %cl,%edi
  801d17:	89 c1                	mov    %eax,%ecx
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	d3 e3                	shl    %cl,%ebx
  801d1d:	89 d1                	mov    %edx,%ecx
  801d1f:	89 fa                	mov    %edi,%edx
  801d21:	d3 e8                	shr    %cl,%eax
  801d23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d28:	09 d8                	or     %ebx,%eax
  801d2a:	f7 74 24 08          	divl   0x8(%esp)
  801d2e:	89 d3                	mov    %edx,%ebx
  801d30:	d3 e6                	shl    %cl,%esi
  801d32:	f7 e5                	mul    %ebp
  801d34:	89 c7                	mov    %eax,%edi
  801d36:	89 d1                	mov    %edx,%ecx
  801d38:	39 d3                	cmp    %edx,%ebx
  801d3a:	72 06                	jb     801d42 <__umoddi3+0xe2>
  801d3c:	75 0e                	jne    801d4c <__umoddi3+0xec>
  801d3e:	39 c6                	cmp    %eax,%esi
  801d40:	73 0a                	jae    801d4c <__umoddi3+0xec>
  801d42:	29 e8                	sub    %ebp,%eax
  801d44:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d48:	89 d1                	mov    %edx,%ecx
  801d4a:	89 c7                	mov    %eax,%edi
  801d4c:	89 f5                	mov    %esi,%ebp
  801d4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d52:	29 fd                	sub    %edi,%ebp
  801d54:	19 cb                	sbb    %ecx,%ebx
  801d56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d5b:	89 d8                	mov    %ebx,%eax
  801d5d:	d3 e0                	shl    %cl,%eax
  801d5f:	89 f1                	mov    %esi,%ecx
  801d61:	d3 ed                	shr    %cl,%ebp
  801d63:	d3 eb                	shr    %cl,%ebx
  801d65:	09 e8                	or     %ebp,%eax
  801d67:	89 da                	mov    %ebx,%edx
  801d69:	83 c4 1c             	add    $0x1c,%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    
