
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
  800051:	68 60 22 80 00       	push   $0x802260
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
  8000ac:	e8 9d 0e 00 00       	call   800f4e <close_all>
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
  8001b7:	e8 54 1e 00 00       	call   802010 <__udivdi3>
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
  8001f5:	e8 36 1f 00 00       	call   802130 <__umoddi3>
  8001fa:	83 c4 14             	add    $0x14,%esp
  8001fd:	0f be 80 78 22 80 00 	movsbl 0x802278(%eax),%eax
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
  8002b7:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  800385:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 18                	je     8003a8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800390:	52                   	push   %edx
  800391:	68 55 26 80 00       	push   $0x802655
  800396:	53                   	push   %ebx
  800397:	56                   	push   %esi
  800398:	e8 92 fe ff ff       	call   80022f <printfmt>
  80039d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a3:	e9 66 02 00 00       	jmp    80060e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003a8:	50                   	push   %eax
  8003a9:	68 90 22 80 00       	push   $0x802290
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
  8003d0:	b8 89 22 80 00       	mov    $0x802289,%eax
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
  800adc:	68 7f 25 80 00       	push   $0x80257f
  800ae1:	6a 2a                	push   $0x2a
  800ae3:	68 9c 25 80 00       	push   $0x80259c
  800ae8:	e8 9e 13 00 00       	call   801e8b <_panic>

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
  800b5d:	68 7f 25 80 00       	push   $0x80257f
  800b62:	6a 2a                	push   $0x2a
  800b64:	68 9c 25 80 00       	push   $0x80259c
  800b69:	e8 1d 13 00 00       	call   801e8b <_panic>

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
  800b9f:	68 7f 25 80 00       	push   $0x80257f
  800ba4:	6a 2a                	push   $0x2a
  800ba6:	68 9c 25 80 00       	push   $0x80259c
  800bab:	e8 db 12 00 00       	call   801e8b <_panic>

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
  800be1:	68 7f 25 80 00       	push   $0x80257f
  800be6:	6a 2a                	push   $0x2a
  800be8:	68 9c 25 80 00       	push   $0x80259c
  800bed:	e8 99 12 00 00       	call   801e8b <_panic>

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
  800c23:	68 7f 25 80 00       	push   $0x80257f
  800c28:	6a 2a                	push   $0x2a
  800c2a:	68 9c 25 80 00       	push   $0x80259c
  800c2f:	e8 57 12 00 00       	call   801e8b <_panic>

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
  800c65:	68 7f 25 80 00       	push   $0x80257f
  800c6a:	6a 2a                	push   $0x2a
  800c6c:	68 9c 25 80 00       	push   $0x80259c
  800c71:	e8 15 12 00 00       	call   801e8b <_panic>

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
  800ca7:	68 7f 25 80 00       	push   $0x80257f
  800cac:	6a 2a                	push   $0x2a
  800cae:	68 9c 25 80 00       	push   $0x80259c
  800cb3:	e8 d3 11 00 00       	call   801e8b <_panic>

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
  800d0b:	68 7f 25 80 00       	push   $0x80257f
  800d10:	6a 2a                	push   $0x2a
  800d12:	68 9c 25 80 00       	push   $0x80259c
  800d17:	e8 6f 11 00 00       	call   801e8b <_panic>

00800d1c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d2c:	89 d1                	mov    %edx,%ecx
  800d2e:	89 d3                	mov    %edx,%ebx
  800d30:	89 d7                	mov    %edx,%edi
  800d32:	89 d6                	mov    %edx,%esi
  800d34:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	b8 10 00 00 00       	mov    $0x10,%eax
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	05 00 00 00 30       	add    $0x30000000,%eax
  800d88:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d9d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	c1 ea 16             	shr    $0x16,%edx
  800db1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db8:	f6 c2 01             	test   $0x1,%dl
  800dbb:	74 29                	je     800de6 <fd_alloc+0x42>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 ea 0c             	shr    $0xc,%edx
  800dc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc9:	f6 c2 01             	test   $0x1,%dl
  800dcc:	74 18                	je     800de6 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dce:	05 00 10 00 00       	add    $0x1000,%eax
  800dd3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd8:	75 d2                	jne    800dac <fd_alloc+0x8>
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ddf:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800de4:	eb 05                	jmp    800deb <fd_alloc+0x47>
			return 0;
  800de6:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 02                	mov    %eax,(%edx)
}
  800df0:	89 c8                	mov    %ecx,%eax
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfa:	83 f8 1f             	cmp    $0x1f,%eax
  800dfd:	77 30                	ja     800e2f <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dff:	c1 e0 0c             	shl    $0xc,%eax
  800e02:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e07:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 24                	je     800e36 <fd_lookup+0x42>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	c1 ea 0c             	shr    $0xc,%edx
  800e17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1e:	f6 c2 01             	test   $0x1,%dl
  800e21:	74 1a                	je     800e3d <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e26:	89 02                	mov    %eax,(%edx)
	return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    
		return -E_INVAL;
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e34:	eb f7                	jmp    800e2d <fd_lookup+0x39>
		return -E_INVAL;
  800e36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3b:	eb f0                	jmp    800e2d <fd_lookup+0x39>
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e42:	eb e9                	jmp    800e2d <fd_lookup+0x39>

00800e44 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e53:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e58:	39 13                	cmp    %edx,(%ebx)
  800e5a:	74 37                	je     800e93 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e5c:	83 c0 01             	add    $0x1,%eax
  800e5f:	8b 1c 85 28 26 80 00 	mov    0x802628(,%eax,4),%ebx
  800e66:	85 db                	test   %ebx,%ebx
  800e68:	75 ee                	jne    800e58 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e6f:	8b 40 48             	mov    0x48(%eax),%eax
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	52                   	push   %edx
  800e76:	50                   	push   %eax
  800e77:	68 ac 25 80 00       	push   $0x8025ac
  800e7c:	e8 d4 f2 ff ff       	call   800155 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8c:	89 1a                	mov    %ebx,(%edx)
}
  800e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    
			return 0;
  800e93:	b8 00 00 00 00       	mov    $0x0,%eax
  800e98:	eb ef                	jmp    800e89 <dev_lookup+0x45>

00800e9a <fd_close>:
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 24             	sub    $0x24,%esp
  800ea3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eac:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ead:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb6:	50                   	push   %eax
  800eb7:	e8 38 ff ff ff       	call   800df4 <fd_lookup>
  800ebc:	89 c3                	mov    %eax,%ebx
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	78 05                	js     800eca <fd_close+0x30>
	    || fd != fd2)
  800ec5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ec8:	74 16                	je     800ee0 <fd_close+0x46>
		return (must_exist ? r : 0);
  800eca:	89 f8                	mov    %edi,%eax
  800ecc:	84 c0                	test   %al,%al
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee6:	50                   	push   %eax
  800ee7:	ff 36                	push   (%esi)
  800ee9:	e8 56 ff ff ff       	call   800e44 <dev_lookup>
  800eee:	89 c3                	mov    %eax,%ebx
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 1a                	js     800f11 <fd_close+0x77>
		if (dev->dev_close)
  800ef7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efa:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	74 0b                	je     800f11 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	56                   	push   %esi
  800f0a:	ff d0                	call   *%eax
  800f0c:	89 c3                	mov    %eax,%ebx
  800f0e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	56                   	push   %esi
  800f15:	6a 00                	push   $0x0
  800f17:	e8 94 fc ff ff       	call   800bb0 <sys_page_unmap>
	return r;
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	eb b5                	jmp    800ed6 <fd_close+0x3c>

00800f21 <close>:

int
close(int fdnum)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2a:	50                   	push   %eax
  800f2b:	ff 75 08             	push   0x8(%ebp)
  800f2e:	e8 c1 fe ff ff       	call   800df4 <fd_lookup>
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	79 02                	jns    800f3c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    
		return fd_close(fd, 1);
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	6a 01                	push   $0x1
  800f41:	ff 75 f4             	push   -0xc(%ebp)
  800f44:	e8 51 ff ff ff       	call   800e9a <fd_close>
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	eb ec                	jmp    800f3a <close+0x19>

00800f4e <close_all>:

void
close_all(void)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	53                   	push   %ebx
  800f52:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	53                   	push   %ebx
  800f5e:	e8 be ff ff ff       	call   800f21 <close>
	for (i = 0; i < MAXFD; i++)
  800f63:	83 c3 01             	add    $0x1,%ebx
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	83 fb 20             	cmp    $0x20,%ebx
  800f6c:	75 ec                	jne    800f5a <close_all+0xc>
}
  800f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	ff 75 08             	push   0x8(%ebp)
  800f83:	e8 6c fe ff ff       	call   800df4 <fd_lookup>
  800f88:	89 c3                	mov    %eax,%ebx
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 7f                	js     801010 <dup+0x9d>
		return r;
	close(newfdnum);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	ff 75 0c             	push   0xc(%ebp)
  800f97:	e8 85 ff ff ff       	call   800f21 <close>

	newfd = INDEX2FD(newfdnum);
  800f9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f9f:	c1 e6 0c             	shl    $0xc,%esi
  800fa2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fa8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fab:	89 3c 24             	mov    %edi,(%esp)
  800fae:	e8 da fd ff ff       	call   800d8d <fd2data>
  800fb3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb5:	89 34 24             	mov    %esi,(%esp)
  800fb8:	e8 d0 fd ff ff       	call   800d8d <fd2data>
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc3:	89 d8                	mov    %ebx,%eax
  800fc5:	c1 e8 16             	shr    $0x16,%eax
  800fc8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcf:	a8 01                	test   $0x1,%al
  800fd1:	74 11                	je     800fe4 <dup+0x71>
  800fd3:	89 d8                	mov    %ebx,%eax
  800fd5:	c1 e8 0c             	shr    $0xc,%eax
  800fd8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdf:	f6 c2 01             	test   $0x1,%dl
  800fe2:	75 36                	jne    80101a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe4:	89 f8                	mov    %edi,%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
  800fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff8:	50                   	push   %eax
  800ff9:	56                   	push   %esi
  800ffa:	6a 00                	push   $0x0
  800ffc:	57                   	push   %edi
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 6a fb ff ff       	call   800b6e <sys_page_map>
  801004:	89 c3                	mov    %eax,%ebx
  801006:	83 c4 20             	add    $0x20,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 33                	js     801040 <dup+0xcd>
		goto err;

	return newfdnum;
  80100d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801010:	89 d8                	mov    %ebx,%eax
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80101a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	25 07 0e 00 00       	and    $0xe07,%eax
  801029:	50                   	push   %eax
  80102a:	ff 75 d4             	push   -0x2c(%ebp)
  80102d:	6a 00                	push   $0x0
  80102f:	53                   	push   %ebx
  801030:	6a 00                	push   $0x0
  801032:	e8 37 fb ff ff       	call   800b6e <sys_page_map>
  801037:	89 c3                	mov    %eax,%ebx
  801039:	83 c4 20             	add    $0x20,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	79 a4                	jns    800fe4 <dup+0x71>
	sys_page_unmap(0, newfd);
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	56                   	push   %esi
  801044:	6a 00                	push   $0x0
  801046:	e8 65 fb ff ff       	call   800bb0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80104b:	83 c4 08             	add    $0x8,%esp
  80104e:	ff 75 d4             	push   -0x2c(%ebp)
  801051:	6a 00                	push   $0x0
  801053:	e8 58 fb ff ff       	call   800bb0 <sys_page_unmap>
	return r;
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	eb b3                	jmp    801010 <dup+0x9d>

0080105d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
  801062:	83 ec 18             	sub    $0x18,%esp
  801065:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801068:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106b:	50                   	push   %eax
  80106c:	56                   	push   %esi
  80106d:	e8 82 fd ff ff       	call   800df4 <fd_lookup>
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	78 3c                	js     8010b5 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801079:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80107c:	83 ec 08             	sub    $0x8,%esp
  80107f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801082:	50                   	push   %eax
  801083:	ff 33                	push   (%ebx)
  801085:	e8 ba fd ff ff       	call   800e44 <dev_lookup>
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	78 24                	js     8010b5 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801091:	8b 43 08             	mov    0x8(%ebx),%eax
  801094:	83 e0 03             	and    $0x3,%eax
  801097:	83 f8 01             	cmp    $0x1,%eax
  80109a:	74 20                	je     8010bc <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80109c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109f:	8b 40 08             	mov    0x8(%eax),%eax
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	74 37                	je     8010dd <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	ff 75 10             	push   0x10(%ebp)
  8010ac:	ff 75 0c             	push   0xc(%ebp)
  8010af:	53                   	push   %ebx
  8010b0:	ff d0                	call   *%eax
  8010b2:	83 c4 10             	add    $0x10,%esp
}
  8010b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c1:	8b 40 48             	mov    0x48(%eax),%eax
  8010c4:	83 ec 04             	sub    $0x4,%esp
  8010c7:	56                   	push   %esi
  8010c8:	50                   	push   %eax
  8010c9:	68 ed 25 80 00       	push   $0x8025ed
  8010ce:	e8 82 f0 ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010db:	eb d8                	jmp    8010b5 <read+0x58>
		return -E_NOT_SUPP;
  8010dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010e2:	eb d1                	jmp    8010b5 <read+0x58>

008010e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	eb 02                	jmp    8010fc <readn+0x18>
  8010fa:	01 c3                	add    %eax,%ebx
  8010fc:	39 f3                	cmp    %esi,%ebx
  8010fe:	73 21                	jae    801121 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	89 f0                	mov    %esi,%eax
  801105:	29 d8                	sub    %ebx,%eax
  801107:	50                   	push   %eax
  801108:	89 d8                	mov    %ebx,%eax
  80110a:	03 45 0c             	add    0xc(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	57                   	push   %edi
  80110f:	e8 49 ff ff ff       	call   80105d <read>
		if (m < 0)
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 04                	js     80111f <readn+0x3b>
			return m;
		if (m == 0)
  80111b:	75 dd                	jne    8010fa <readn+0x16>
  80111d:	eb 02                	jmp    801121 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80111f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801121:	89 d8                	mov    %ebx,%eax
  801123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	83 ec 18             	sub    $0x18,%esp
  801133:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801136:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	53                   	push   %ebx
  80113b:	e8 b4 fc ff ff       	call   800df4 <fd_lookup>
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 37                	js     80117e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801147:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	ff 36                	push   (%esi)
  801153:	e8 ec fc ff ff       	call   800e44 <dev_lookup>
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 1f                	js     80117e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801163:	74 20                	je     801185 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	8b 40 0c             	mov    0xc(%eax),%eax
  80116b:	85 c0                	test   %eax,%eax
  80116d:	74 37                	je     8011a6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 10             	push   0x10(%ebp)
  801175:	ff 75 0c             	push   0xc(%ebp)
  801178:	56                   	push   %esi
  801179:	ff d0                	call   *%eax
  80117b:	83 c4 10             	add    $0x10,%esp
}
  80117e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801185:	a1 04 40 80 00       	mov    0x804004,%eax
  80118a:	8b 40 48             	mov    0x48(%eax),%eax
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	53                   	push   %ebx
  801191:	50                   	push   %eax
  801192:	68 09 26 80 00       	push   $0x802609
  801197:	e8 b9 ef ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a4:	eb d8                	jmp    80117e <write+0x53>
		return -E_NOT_SUPP;
  8011a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ab:	eb d1                	jmp    80117e <write+0x53>

008011ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	ff 75 08             	push   0x8(%ebp)
  8011ba:	e8 35 fc ff ff       	call   800df4 <fd_lookup>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 0e                	js     8011d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 18             	sub    $0x18,%esp
  8011de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	53                   	push   %ebx
  8011e6:	e8 09 fc ff ff       	call   800df4 <fd_lookup>
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 34                	js     801226 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	ff 36                	push   (%esi)
  8011fe:	e8 41 fc ff ff       	call   800e44 <dev_lookup>
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 1c                	js     801226 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80120e:	74 1d                	je     80122d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801210:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801213:	8b 40 18             	mov    0x18(%eax),%eax
  801216:	85 c0                	test   %eax,%eax
  801218:	74 34                	je     80124e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	ff 75 0c             	push   0xc(%ebp)
  801220:	56                   	push   %esi
  801221:	ff d0                	call   *%eax
  801223:	83 c4 10             	add    $0x10,%esp
}
  801226:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801229:	5b                   	pop    %ebx
  80122a:	5e                   	pop    %esi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80122d:	a1 04 40 80 00       	mov    0x804004,%eax
  801232:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	53                   	push   %ebx
  801239:	50                   	push   %eax
  80123a:	68 cc 25 80 00       	push   $0x8025cc
  80123f:	e8 11 ef ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb d8                	jmp    801226 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80124e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801253:	eb d1                	jmp    801226 <ftruncate+0x50>

00801255 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 18             	sub    $0x18,%esp
  80125d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801260:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	ff 75 08             	push   0x8(%ebp)
  801267:	e8 88 fb ff ff       	call   800df4 <fd_lookup>
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 49                	js     8012bc <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801273:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	ff 36                	push   (%esi)
  80127f:	e8 c0 fb ff ff       	call   800e44 <dev_lookup>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 31                	js     8012bc <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801292:	74 2f                	je     8012c3 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801294:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801297:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80129e:	00 00 00 
	stat->st_isdir = 0;
  8012a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a8:	00 00 00 
	stat->st_dev = dev;
  8012ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	53                   	push   %ebx
  8012b5:	56                   	push   %esi
  8012b6:	ff 50 14             	call   *0x14(%eax)
  8012b9:	83 c4 10             	add    $0x10,%esp
}
  8012bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    
		return -E_NOT_SUPP;
  8012c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c8:	eb f2                	jmp    8012bc <fstat+0x67>

008012ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	6a 00                	push   $0x0
  8012d4:	ff 75 08             	push   0x8(%ebp)
  8012d7:	e8 e4 01 00 00       	call   8014c0 <open>
  8012dc:	89 c3                	mov    %eax,%ebx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 1b                	js     801300 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 0c             	push   0xc(%ebp)
  8012eb:	50                   	push   %eax
  8012ec:	e8 64 ff ff ff       	call   801255 <fstat>
  8012f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f3:	89 1c 24             	mov    %ebx,(%esp)
  8012f6:	e8 26 fc ff ff       	call   800f21 <close>
	return r;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	89 f3                	mov    %esi,%ebx
}
  801300:	89 d8                	mov    %ebx,%eax
  801302:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801305:	5b                   	pop    %ebx
  801306:	5e                   	pop    %esi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
  80130e:	89 c6                	mov    %eax,%esi
  801310:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801312:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801319:	74 27                	je     801342 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131b:	6a 07                	push   $0x7
  80131d:	68 00 50 80 00       	push   $0x805000
  801322:	56                   	push   %esi
  801323:	ff 35 00 60 80 00    	push   0x806000
  801329:	e8 0a 0c 00 00       	call   801f38 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80132e:	83 c4 0c             	add    $0xc,%esp
  801331:	6a 00                	push   $0x0
  801333:	53                   	push   %ebx
  801334:	6a 00                	push   $0x0
  801336:	e8 96 0b 00 00       	call   801ed1 <ipc_recv>
}
  80133b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133e:	5b                   	pop    %ebx
  80133f:	5e                   	pop    %esi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	6a 01                	push   $0x1
  801347:	e8 40 0c 00 00       	call   801f8c <ipc_find_env>
  80134c:	a3 00 60 80 00       	mov    %eax,0x806000
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	eb c5                	jmp    80131b <fsipc+0x12>

00801356 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	8b 40 0c             	mov    0xc(%eax),%eax
  801362:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	b8 02 00 00 00       	mov    $0x2,%eax
  801379:	e8 8b ff ff ff       	call   801309 <fsipc>
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <devfile_flush>:
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	8b 40 0c             	mov    0xc(%eax),%eax
  80138c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801391:	ba 00 00 00 00       	mov    $0x0,%edx
  801396:	b8 06 00 00 00       	mov    $0x6,%eax
  80139b:	e8 69 ff ff ff       	call   801309 <fsipc>
}
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <devfile_stat>:
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c1:	e8 43 ff ff ff       	call   801309 <fsipc>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 2c                	js     8013f6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	68 00 50 80 00       	push   $0x805000
  8013d2:	53                   	push   %ebx
  8013d3:	e8 57 f3 ff ff       	call   80072f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e3:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <devfile_write>:
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 0c             	sub    $0xc,%esp
  801401:	8b 45 10             	mov    0x10(%ebp),%eax
  801404:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801409:	39 d0                	cmp    %edx,%eax
  80140b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140e:	8b 55 08             	mov    0x8(%ebp),%edx
  801411:	8b 52 0c             	mov    0xc(%edx),%edx
  801414:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80141a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80141f:	50                   	push   %eax
  801420:	ff 75 0c             	push   0xc(%ebp)
  801423:	68 08 50 80 00       	push   $0x805008
  801428:	e8 98 f4 ff ff       	call   8008c5 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	b8 04 00 00 00       	mov    $0x4,%eax
  801437:	e8 cd fe ff ff       	call   801309 <fsipc>
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <devfile_read>:
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
  801443:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	8b 40 0c             	mov    0xc(%eax),%eax
  80144c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801451:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 03 00 00 00       	mov    $0x3,%eax
  801461:	e8 a3 fe ff ff       	call   801309 <fsipc>
  801466:	89 c3                	mov    %eax,%ebx
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 1f                	js     80148b <devfile_read+0x4d>
	assert(r <= n);
  80146c:	39 f0                	cmp    %esi,%eax
  80146e:	77 24                	ja     801494 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801470:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801475:	7f 33                	jg     8014aa <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	50                   	push   %eax
  80147b:	68 00 50 80 00       	push   $0x805000
  801480:	ff 75 0c             	push   0xc(%ebp)
  801483:	e8 3d f4 ff ff       	call   8008c5 <memmove>
	return r;
  801488:	83 c4 10             	add    $0x10,%esp
}
  80148b:	89 d8                	mov    %ebx,%eax
  80148d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    
	assert(r <= n);
  801494:	68 3c 26 80 00       	push   $0x80263c
  801499:	68 43 26 80 00       	push   $0x802643
  80149e:	6a 7c                	push   $0x7c
  8014a0:	68 58 26 80 00       	push   $0x802658
  8014a5:	e8 e1 09 00 00       	call   801e8b <_panic>
	assert(r <= PGSIZE);
  8014aa:	68 63 26 80 00       	push   $0x802663
  8014af:	68 43 26 80 00       	push   $0x802643
  8014b4:	6a 7d                	push   $0x7d
  8014b6:	68 58 26 80 00       	push   $0x802658
  8014bb:	e8 cb 09 00 00       	call   801e8b <_panic>

008014c0 <open>:
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 1c             	sub    $0x1c,%esp
  8014c8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014cb:	56                   	push   %esi
  8014cc:	e8 23 f2 ff ff       	call   8006f4 <strlen>
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d9:	7f 6c                	jg     801547 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	e8 bd f8 ff ff       	call   800da4 <fd_alloc>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 3c                	js     80152c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	56                   	push   %esi
  8014f4:	68 00 50 80 00       	push   $0x805000
  8014f9:	e8 31 f2 ff ff       	call   80072f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801501:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801506:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801509:	b8 01 00 00 00       	mov    $0x1,%eax
  80150e:	e8 f6 fd ff ff       	call   801309 <fsipc>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 19                	js     801535 <open+0x75>
	return fd2num(fd);
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	ff 75 f4             	push   -0xc(%ebp)
  801522:	e8 56 f8 ff ff       	call   800d7d <fd2num>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	83 c4 10             	add    $0x10,%esp
}
  80152c:	89 d8                	mov    %ebx,%eax
  80152e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801531:	5b                   	pop    %ebx
  801532:	5e                   	pop    %esi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    
		fd_close(fd, 0);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	6a 00                	push   $0x0
  80153a:	ff 75 f4             	push   -0xc(%ebp)
  80153d:	e8 58 f9 ff ff       	call   800e9a <fd_close>
		return r;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	eb e5                	jmp    80152c <open+0x6c>
		return -E_BAD_PATH;
  801547:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80154c:	eb de                	jmp    80152c <open+0x6c>

0080154e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801554:	ba 00 00 00 00       	mov    $0x0,%edx
  801559:	b8 08 00 00 00       	mov    $0x8,%eax
  80155e:	e8 a6 fd ff ff       	call   801309 <fsipc>
}
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80156b:	68 6f 26 80 00       	push   $0x80266f
  801570:	ff 75 0c             	push   0xc(%ebp)
  801573:	e8 b7 f1 ff ff       	call   80072f <strcpy>
	return 0;
}
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <devsock_close>:
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 10             	sub    $0x10,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801589:	53                   	push   %ebx
  80158a:	e8 36 0a 00 00       	call   801fc5 <pageref>
  80158f:	89 c2                	mov    %eax,%edx
  801591:	83 c4 10             	add    $0x10,%esp
		return 0;
  801594:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801599:	83 fa 01             	cmp    $0x1,%edx
  80159c:	74 05                	je     8015a3 <devsock_close+0x24>
}
  80159e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	ff 73 0c             	push   0xc(%ebx)
  8015a9:	e8 b7 02 00 00       	call   801865 <nsipc_close>
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	eb eb                	jmp    80159e <devsock_close+0x1f>

008015b3 <devsock_write>:
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015b9:	6a 00                	push   $0x0
  8015bb:	ff 75 10             	push   0x10(%ebp)
  8015be:	ff 75 0c             	push   0xc(%ebp)
  8015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c4:	ff 70 0c             	push   0xc(%eax)
  8015c7:	e8 79 03 00 00       	call   801945 <nsipc_send>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devsock_read>:
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015d4:	6a 00                	push   $0x0
  8015d6:	ff 75 10             	push   0x10(%ebp)
  8015d9:	ff 75 0c             	push   0xc(%ebp)
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	ff 70 0c             	push   0xc(%eax)
  8015e2:	e8 ef 02 00 00       	call   8018d6 <nsipc_recv>
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <fd2sockid>:
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015ef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015f2:	52                   	push   %edx
  8015f3:	50                   	push   %eax
  8015f4:	e8 fb f7 ff ff       	call   800df4 <fd_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 10                	js     801610 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801603:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801609:	39 08                	cmp    %ecx,(%eax)
  80160b:	75 05                	jne    801612 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801610:	c9                   	leave  
  801611:	c3                   	ret    
		return -E_NOT_SUPP;
  801612:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801617:	eb f7                	jmp    801610 <fd2sockid+0x27>

00801619 <alloc_sockfd>:
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	56                   	push   %esi
  80161d:	53                   	push   %ebx
  80161e:	83 ec 1c             	sub    $0x1c,%esp
  801621:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801623:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	e8 78 f7 ff ff       	call   800da4 <fd_alloc>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 43                	js     801678 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	68 07 04 00 00       	push   $0x407
  80163d:	ff 75 f4             	push   -0xc(%ebp)
  801640:	6a 00                	push   $0x0
  801642:	e8 e4 f4 ff ff       	call   800b2b <sys_page_alloc>
  801647:	89 c3                	mov    %eax,%ebx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 28                	js     801678 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801653:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801659:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80165b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801665:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	50                   	push   %eax
  80166c:	e8 0c f7 ff ff       	call   800d7d <fd2num>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	eb 0c                	jmp    801684 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801678:	83 ec 0c             	sub    $0xc,%esp
  80167b:	56                   	push   %esi
  80167c:	e8 e4 01 00 00       	call   801865 <nsipc_close>
		return r;
  801681:	83 c4 10             	add    $0x10,%esp
}
  801684:	89 d8                	mov    %ebx,%eax
  801686:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    

0080168d <accept>:
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801693:	8b 45 08             	mov    0x8(%ebp),%eax
  801696:	e8 4e ff ff ff       	call   8015e9 <fd2sockid>
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 1b                	js     8016ba <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	ff 75 10             	push   0x10(%ebp)
  8016a5:	ff 75 0c             	push   0xc(%ebp)
  8016a8:	50                   	push   %eax
  8016a9:	e8 0e 01 00 00       	call   8017bc <nsipc_accept>
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 05                	js     8016ba <accept+0x2d>
	return alloc_sockfd(r);
  8016b5:	e8 5f ff ff ff       	call   801619 <alloc_sockfd>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <bind>:
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	e8 1f ff ff ff       	call   8015e9 <fd2sockid>
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 12                	js     8016e0 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	ff 75 10             	push   0x10(%ebp)
  8016d4:	ff 75 0c             	push   0xc(%ebp)
  8016d7:	50                   	push   %eax
  8016d8:	e8 31 01 00 00       	call   80180e <nsipc_bind>
  8016dd:	83 c4 10             	add    $0x10,%esp
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <shutdown>:
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	e8 f9 fe ff ff       	call   8015e9 <fd2sockid>
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 0f                	js     801703 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	ff 75 0c             	push   0xc(%ebp)
  8016fa:	50                   	push   %eax
  8016fb:	e8 43 01 00 00       	call   801843 <nsipc_shutdown>
  801700:	83 c4 10             	add    $0x10,%esp
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <connect>:
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	e8 d6 fe ff ff       	call   8015e9 <fd2sockid>
  801713:	85 c0                	test   %eax,%eax
  801715:	78 12                	js     801729 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801717:	83 ec 04             	sub    $0x4,%esp
  80171a:	ff 75 10             	push   0x10(%ebp)
  80171d:	ff 75 0c             	push   0xc(%ebp)
  801720:	50                   	push   %eax
  801721:	e8 59 01 00 00       	call   80187f <nsipc_connect>
  801726:	83 c4 10             	add    $0x10,%esp
}
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <listen>:
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	e8 b0 fe ff ff       	call   8015e9 <fd2sockid>
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 0f                	js     80174c <listen+0x21>
	return nsipc_listen(r, backlog);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	ff 75 0c             	push   0xc(%ebp)
  801743:	50                   	push   %eax
  801744:	e8 6b 01 00 00       	call   8018b4 <nsipc_listen>
  801749:	83 c4 10             	add    $0x10,%esp
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <socket>:

int
socket(int domain, int type, int protocol)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801754:	ff 75 10             	push   0x10(%ebp)
  801757:	ff 75 0c             	push   0xc(%ebp)
  80175a:	ff 75 08             	push   0x8(%ebp)
  80175d:	e8 41 02 00 00       	call   8019a3 <nsipc_socket>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 05                	js     80176e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801769:	e8 ab fe ff ff       	call   801619 <alloc_sockfd>
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801779:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801780:	74 26                	je     8017a8 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801782:	6a 07                	push   $0x7
  801784:	68 00 70 80 00       	push   $0x807000
  801789:	53                   	push   %ebx
  80178a:	ff 35 00 80 80 00    	push   0x808000
  801790:	e8 a3 07 00 00       	call   801f38 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801795:	83 c4 0c             	add    $0xc,%esp
  801798:	6a 00                	push   $0x0
  80179a:	6a 00                	push   $0x0
  80179c:	6a 00                	push   $0x0
  80179e:	e8 2e 07 00 00       	call   801ed1 <ipc_recv>
}
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017a8:	83 ec 0c             	sub    $0xc,%esp
  8017ab:	6a 02                	push   $0x2
  8017ad:	e8 da 07 00 00       	call   801f8c <ipc_find_env>
  8017b2:	a3 00 80 80 00       	mov    %eax,0x808000
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb c6                	jmp    801782 <nsipc+0x12>

008017bc <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017cc:	8b 06                	mov    (%esi),%eax
  8017ce:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d8:	e8 93 ff ff ff       	call   801770 <nsipc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	79 09                	jns    8017ec <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017e3:	89 d8                	mov    %ebx,%eax
  8017e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	ff 35 10 70 80 00    	push   0x807010
  8017f5:	68 00 70 80 00       	push   $0x807000
  8017fa:	ff 75 0c             	push   0xc(%ebp)
  8017fd:	e8 c3 f0 ff ff       	call   8008c5 <memmove>
		*addrlen = ret->ret_addrlen;
  801802:	a1 10 70 80 00       	mov    0x807010,%eax
  801807:	89 06                	mov    %eax,(%esi)
  801809:	83 c4 10             	add    $0x10,%esp
	return r;
  80180c:	eb d5                	jmp    8017e3 <nsipc_accept+0x27>

0080180e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801820:	53                   	push   %ebx
  801821:	ff 75 0c             	push   0xc(%ebp)
  801824:	68 04 70 80 00       	push   $0x807004
  801829:	e8 97 f0 ff ff       	call   8008c5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80182e:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801834:	b8 02 00 00 00       	mov    $0x2,%eax
  801839:	e8 32 ff ff ff       	call   801770 <nsipc>
}
  80183e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801859:	b8 03 00 00 00       	mov    $0x3,%eax
  80185e:	e8 0d ff ff ff       	call   801770 <nsipc>
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <nsipc_close>:

int
nsipc_close(int s)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801873:	b8 04 00 00 00       	mov    $0x4,%eax
  801878:	e8 f3 fe ff ff       	call   801770 <nsipc>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	53                   	push   %ebx
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801891:	53                   	push   %ebx
  801892:	ff 75 0c             	push   0xc(%ebp)
  801895:	68 04 70 80 00       	push   $0x807004
  80189a:	e8 26 f0 ff ff       	call   8008c5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80189f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018a5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018aa:	e8 c1 fe ff ff       	call   801770 <nsipc>
}
  8018af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c5:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8018cf:	e8 9c fe ff ff       	call   801770 <nsipc>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018e6:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ef:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018f4:	b8 07 00 00 00       	mov    $0x7,%eax
  8018f9:	e8 72 fe ff ff       	call   801770 <nsipc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	85 c0                	test   %eax,%eax
  801902:	78 22                	js     801926 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801904:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801909:	39 c6                	cmp    %eax,%esi
  80190b:	0f 4e c6             	cmovle %esi,%eax
  80190e:	39 c3                	cmp    %eax,%ebx
  801910:	7f 1d                	jg     80192f <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801912:	83 ec 04             	sub    $0x4,%esp
  801915:	53                   	push   %ebx
  801916:	68 00 70 80 00       	push   $0x807000
  80191b:	ff 75 0c             	push   0xc(%ebp)
  80191e:	e8 a2 ef ff ff       	call   8008c5 <memmove>
  801923:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801926:	89 d8                	mov    %ebx,%eax
  801928:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80192f:	68 7b 26 80 00       	push   $0x80267b
  801934:	68 43 26 80 00       	push   $0x802643
  801939:	6a 62                	push   $0x62
  80193b:	68 90 26 80 00       	push   $0x802690
  801940:	e8 46 05 00 00       	call   801e8b <_panic>

00801945 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	53                   	push   %ebx
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801957:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80195d:	7f 2e                	jg     80198d <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80195f:	83 ec 04             	sub    $0x4,%esp
  801962:	53                   	push   %ebx
  801963:	ff 75 0c             	push   0xc(%ebp)
  801966:	68 0c 70 80 00       	push   $0x80700c
  80196b:	e8 55 ef ff ff       	call   8008c5 <memmove>
	nsipcbuf.send.req_size = size;
  801970:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801976:	8b 45 14             	mov    0x14(%ebp),%eax
  801979:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80197e:	b8 08 00 00 00       	mov    $0x8,%eax
  801983:	e8 e8 fd ff ff       	call   801770 <nsipc>
}
  801988:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    
	assert(size < 1600);
  80198d:	68 9c 26 80 00       	push   $0x80269c
  801992:	68 43 26 80 00       	push   $0x802643
  801997:	6a 6d                	push   $0x6d
  801999:	68 90 26 80 00       	push   $0x802690
  80199e:	e8 e8 04 00 00       	call   801e8b <_panic>

008019a3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8019c6:	e8 a5 fd ff ff       	call   801770 <nsipc>
}
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    

008019cd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 08             	push   0x8(%ebp)
  8019db:	e8 ad f3 ff ff       	call   800d8d <fd2data>
  8019e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e2:	83 c4 08             	add    $0x8,%esp
  8019e5:	68 a8 26 80 00       	push   $0x8026a8
  8019ea:	53                   	push   %ebx
  8019eb:	e8 3f ed ff ff       	call   80072f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f0:	8b 46 04             	mov    0x4(%esi),%eax
  8019f3:	2b 06                	sub    (%esi),%eax
  8019f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a02:	00 00 00 
	stat->st_dev = &devpipe;
  801a05:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a0c:	30 80 00 
	return 0;
}
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a25:	53                   	push   %ebx
  801a26:	6a 00                	push   $0x0
  801a28:	e8 83 f1 ff ff       	call   800bb0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2d:	89 1c 24             	mov    %ebx,(%esp)
  801a30:	e8 58 f3 ff ff       	call   800d8d <fd2data>
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	50                   	push   %eax
  801a39:	6a 00                	push   $0x0
  801a3b:	e8 70 f1 ff ff       	call   800bb0 <sys_page_unmap>
}
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <_pipeisclosed>:
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	57                   	push   %edi
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 1c             	sub    $0x1c,%esp
  801a4e:	89 c7                	mov    %eax,%edi
  801a50:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a52:	a1 04 40 80 00       	mov    0x804004,%eax
  801a57:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	57                   	push   %edi
  801a5e:	e8 62 05 00 00       	call   801fc5 <pageref>
  801a63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a66:	89 34 24             	mov    %esi,(%esp)
  801a69:	e8 57 05 00 00       	call   801fc5 <pageref>
		nn = thisenv->env_runs;
  801a6e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a74:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	39 cb                	cmp    %ecx,%ebx
  801a7c:	74 1b                	je     801a99 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a7e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a81:	75 cf                	jne    801a52 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a83:	8b 42 58             	mov    0x58(%edx),%eax
  801a86:	6a 01                	push   $0x1
  801a88:	50                   	push   %eax
  801a89:	53                   	push   %ebx
  801a8a:	68 af 26 80 00       	push   $0x8026af
  801a8f:	e8 c1 e6 ff ff       	call   800155 <cprintf>
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	eb b9                	jmp    801a52 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a99:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a9c:	0f 94 c0             	sete   %al
  801a9f:	0f b6 c0             	movzbl %al,%eax
}
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <devpipe_write>:
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	57                   	push   %edi
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 28             	sub    $0x28,%esp
  801ab3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ab6:	56                   	push   %esi
  801ab7:	e8 d1 f2 ff ff       	call   800d8d <fd2data>
  801abc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac9:	75 09                	jne    801ad4 <devpipe_write+0x2a>
	return i;
  801acb:	89 f8                	mov    %edi,%eax
  801acd:	eb 23                	jmp    801af2 <devpipe_write+0x48>
			sys_yield();
  801acf:	e8 38 f0 ff ff       	call   800b0c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad7:	8b 0b                	mov    (%ebx),%ecx
  801ad9:	8d 51 20             	lea    0x20(%ecx),%edx
  801adc:	39 d0                	cmp    %edx,%eax
  801ade:	72 1a                	jb     801afa <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ae0:	89 da                	mov    %ebx,%edx
  801ae2:	89 f0                	mov    %esi,%eax
  801ae4:	e8 5c ff ff ff       	call   801a45 <_pipeisclosed>
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	74 e2                	je     801acf <devpipe_write+0x25>
				return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5f                   	pop    %edi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b01:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b04:	89 c2                	mov    %eax,%edx
  801b06:	c1 fa 1f             	sar    $0x1f,%edx
  801b09:	89 d1                	mov    %edx,%ecx
  801b0b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b11:	83 e2 1f             	and    $0x1f,%edx
  801b14:	29 ca                	sub    %ecx,%edx
  801b16:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b1a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1e:	83 c0 01             	add    $0x1,%eax
  801b21:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b24:	83 c7 01             	add    $0x1,%edi
  801b27:	eb 9d                	jmp    801ac6 <devpipe_write+0x1c>

00801b29 <devpipe_read>:
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	57                   	push   %edi
  801b2d:	56                   	push   %esi
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 18             	sub    $0x18,%esp
  801b32:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b35:	57                   	push   %edi
  801b36:	e8 52 f2 ff ff       	call   800d8d <fd2data>
  801b3b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	be 00 00 00 00       	mov    $0x0,%esi
  801b45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b48:	75 13                	jne    801b5d <devpipe_read+0x34>
	return i;
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	eb 02                	jmp    801b50 <devpipe_read+0x27>
				return i;
  801b4e:	89 f0                	mov    %esi,%eax
}
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
			sys_yield();
  801b58:	e8 af ef ff ff       	call   800b0c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b5d:	8b 03                	mov    (%ebx),%eax
  801b5f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b62:	75 18                	jne    801b7c <devpipe_read+0x53>
			if (i > 0)
  801b64:	85 f6                	test   %esi,%esi
  801b66:	75 e6                	jne    801b4e <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b68:	89 da                	mov    %ebx,%edx
  801b6a:	89 f8                	mov    %edi,%eax
  801b6c:	e8 d4 fe ff ff       	call   801a45 <_pipeisclosed>
  801b71:	85 c0                	test   %eax,%eax
  801b73:	74 e3                	je     801b58 <devpipe_read+0x2f>
				return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	eb d4                	jmp    801b50 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7c:	99                   	cltd   
  801b7d:	c1 ea 1b             	shr    $0x1b,%edx
  801b80:	01 d0                	add    %edx,%eax
  801b82:	83 e0 1f             	and    $0x1f,%eax
  801b85:	29 d0                	sub    %edx,%eax
  801b87:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b92:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b95:	83 c6 01             	add    $0x1,%esi
  801b98:	eb ab                	jmp    801b45 <devpipe_read+0x1c>

00801b9a <pipe>:
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	56                   	push   %esi
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	e8 f9 f1 ff ff       	call   800da4 <fd_alloc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	0f 88 23 01 00 00    	js     801cdb <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	68 07 04 00 00       	push   $0x407
  801bc0:	ff 75 f4             	push   -0xc(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 61 ef ff ff       	call   800b2b <sys_page_alloc>
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 04 01 00 00    	js     801cdb <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 c1 f1 ff ff       	call   800da4 <fd_alloc>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 db 00 00 00    	js     801ccb <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	ff 75 f0             	push   -0x10(%ebp)
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 29 ef ff ff       	call   800b2b <sys_page_alloc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 bc 00 00 00    	js     801ccb <pipe+0x131>
	va = fd2data(fd0);
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 f4             	push   -0xc(%ebp)
  801c15:	e8 73 f1 ff ff       	call   800d8d <fd2data>
  801c1a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1c:	83 c4 0c             	add    $0xc,%esp
  801c1f:	68 07 04 00 00       	push   $0x407
  801c24:	50                   	push   %eax
  801c25:	6a 00                	push   $0x0
  801c27:	e8 ff ee ff ff       	call   800b2b <sys_page_alloc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	0f 88 82 00 00 00    	js     801cbb <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	ff 75 f0             	push   -0x10(%ebp)
  801c3f:	e8 49 f1 ff ff       	call   800d8d <fd2data>
  801c44:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4b:	50                   	push   %eax
  801c4c:	6a 00                	push   $0x0
  801c4e:	56                   	push   %esi
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 18 ef ff ff       	call   800b6e <sys_page_map>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 20             	add    $0x20,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 4e                	js     801cad <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c5f:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c67:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6c:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c73:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c76:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	ff 75 f4             	push   -0xc(%ebp)
  801c88:	e8 f0 f0 ff ff       	call   800d7d <fd2num>
  801c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c90:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c92:	83 c4 04             	add    $0x4,%esp
  801c95:	ff 75 f0             	push   -0x10(%ebp)
  801c98:	e8 e0 f0 ff ff       	call   800d7d <fd2num>
  801c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cab:	eb 2e                	jmp    801cdb <pipe+0x141>
	sys_page_unmap(0, va);
  801cad:	83 ec 08             	sub    $0x8,%esp
  801cb0:	56                   	push   %esi
  801cb1:	6a 00                	push   $0x0
  801cb3:	e8 f8 ee ff ff       	call   800bb0 <sys_page_unmap>
  801cb8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	ff 75 f0             	push   -0x10(%ebp)
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 e8 ee ff ff       	call   800bb0 <sys_page_unmap>
  801cc8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ccb:	83 ec 08             	sub    $0x8,%esp
  801cce:	ff 75 f4             	push   -0xc(%ebp)
  801cd1:	6a 00                	push   $0x0
  801cd3:	e8 d8 ee ff ff       	call   800bb0 <sys_page_unmap>
  801cd8:	83 c4 10             	add    $0x10,%esp
}
  801cdb:	89 d8                	mov    %ebx,%eax
  801cdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <pipeisclosed>:
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ced:	50                   	push   %eax
  801cee:	ff 75 08             	push   0x8(%ebp)
  801cf1:	e8 fe f0 ff ff       	call   800df4 <fd_lookup>
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 18                	js     801d15 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	ff 75 f4             	push   -0xc(%ebp)
  801d03:	e8 85 f0 ff ff       	call   800d8d <fd2data>
  801d08:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	e8 33 fd ff ff       	call   801a45 <_pipeisclosed>
  801d12:	83 c4 10             	add    $0x10,%esp
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1c:	c3                   	ret    

00801d1d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d23:	68 c7 26 80 00       	push   $0x8026c7
  801d28:	ff 75 0c             	push   0xc(%ebp)
  801d2b:	e8 ff e9 ff ff       	call   80072f <strcpy>
	return 0;
}
  801d30:	b8 00 00 00 00       	mov    $0x0,%eax
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <devcons_write>:
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	57                   	push   %edi
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d43:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d48:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d4e:	eb 2e                	jmp    801d7e <devcons_write+0x47>
		m = n - tot;
  801d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d53:	29 f3                	sub    %esi,%ebx
  801d55:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d5a:	39 c3                	cmp    %eax,%ebx
  801d5c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d5f:	83 ec 04             	sub    $0x4,%esp
  801d62:	53                   	push   %ebx
  801d63:	89 f0                	mov    %esi,%eax
  801d65:	03 45 0c             	add    0xc(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	57                   	push   %edi
  801d6a:	e8 56 eb ff ff       	call   8008c5 <memmove>
		sys_cputs(buf, m);
  801d6f:	83 c4 08             	add    $0x8,%esp
  801d72:	53                   	push   %ebx
  801d73:	57                   	push   %edi
  801d74:	e8 f6 ec ff ff       	call   800a6f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d79:	01 de                	add    %ebx,%esi
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d81:	72 cd                	jb     801d50 <devcons_write+0x19>
}
  801d83:	89 f0                	mov    %esi,%eax
  801d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5e                   	pop    %esi
  801d8a:	5f                   	pop    %edi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    

00801d8d <devcons_read>:
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	83 ec 08             	sub    $0x8,%esp
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9c:	75 07                	jne    801da5 <devcons_read+0x18>
  801d9e:	eb 1f                	jmp    801dbf <devcons_read+0x32>
		sys_yield();
  801da0:	e8 67 ed ff ff       	call   800b0c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801da5:	e8 e3 ec ff ff       	call   800a8d <sys_cgetc>
  801daa:	85 c0                	test   %eax,%eax
  801dac:	74 f2                	je     801da0 <devcons_read+0x13>
	if (c < 0)
  801dae:	78 0f                	js     801dbf <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801db0:	83 f8 04             	cmp    $0x4,%eax
  801db3:	74 0c                	je     801dc1 <devcons_read+0x34>
	*(char*)vbuf = c;
  801db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db8:	88 02                	mov    %al,(%edx)
	return 1;
  801dba:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    
		return 0;
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc6:	eb f7                	jmp    801dbf <devcons_read+0x32>

00801dc8 <cputchar>:
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dd4:	6a 01                	push   $0x1
  801dd6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd9:	50                   	push   %eax
  801dda:	e8 90 ec ff ff       	call   800a6f <sys_cputs>
}
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <getchar>:
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801dea:	6a 01                	push   $0x1
  801dec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	6a 00                	push   $0x0
  801df2:	e8 66 f2 ff ff       	call   80105d <read>
	if (r < 0)
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 06                	js     801e04 <getchar+0x20>
	if (r < 1)
  801dfe:	74 06                	je     801e06 <getchar+0x22>
	return c;
  801e00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    
		return -E_EOF;
  801e06:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e0b:	eb f7                	jmp    801e04 <getchar+0x20>

00801e0d <iscons>:
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	ff 75 08             	push   0x8(%ebp)
  801e1a:	e8 d5 ef ff ff       	call   800df4 <fd_lookup>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 11                	js     801e37 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e2f:	39 10                	cmp    %edx,(%eax)
  801e31:	0f 94 c0             	sete   %al
  801e34:	0f b6 c0             	movzbl %al,%eax
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <opencons>:
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	e8 5c ef ff ff       	call   800da4 <fd_alloc>
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 3a                	js     801e89 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	68 07 04 00 00       	push   $0x407
  801e57:	ff 75 f4             	push   -0xc(%ebp)
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 ca ec ff ff       	call   800b2b <sys_page_alloc>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 21                	js     801e89 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e71:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e76:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e7d:	83 ec 0c             	sub    $0xc,%esp
  801e80:	50                   	push   %eax
  801e81:	e8 f7 ee ff ff       	call   800d7d <fd2num>
  801e86:	83 c4 10             	add    $0x10,%esp
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e90:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e93:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e99:	e8 4f ec ff ff       	call   800aed <sys_getenvid>
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	ff 75 0c             	push   0xc(%ebp)
  801ea4:	ff 75 08             	push   0x8(%ebp)
  801ea7:	56                   	push   %esi
  801ea8:	50                   	push   %eax
  801ea9:	68 d4 26 80 00       	push   $0x8026d4
  801eae:	e8 a2 e2 ff ff       	call   800155 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eb3:	83 c4 18             	add    $0x18,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	ff 75 10             	push   0x10(%ebp)
  801eba:	e8 45 e2 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  801ebf:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  801ec6:	e8 8a e2 ff ff       	call   800155 <cprintf>
  801ecb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ece:	cc                   	int3   
  801ecf:	eb fd                	jmp    801ece <_panic+0x43>

00801ed1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	56                   	push   %esi
  801ed5:	53                   	push   %ebx
  801ed6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee6:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ee9:	83 ec 0c             	sub    $0xc,%esp
  801eec:	50                   	push   %eax
  801eed:	e8 e9 ed ff ff       	call   800cdb <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 f6                	test   %esi,%esi
  801ef7:	74 14                	je     801f0d <ipc_recv+0x3c>
  801ef9:	ba 00 00 00 00       	mov    $0x0,%edx
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 09                	js     801f0b <ipc_recv+0x3a>
  801f02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f08:	8b 52 74             	mov    0x74(%edx),%edx
  801f0b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f0d:	85 db                	test   %ebx,%ebx
  801f0f:	74 14                	je     801f25 <ipc_recv+0x54>
  801f11:	ba 00 00 00 00       	mov    $0x0,%edx
  801f16:	85 c0                	test   %eax,%eax
  801f18:	78 09                	js     801f23 <ipc_recv+0x52>
  801f1a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f20:	8b 52 78             	mov    0x78(%edx),%edx
  801f23:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 08                	js     801f31 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f29:	a1 04 40 80 00       	mov    0x804004,%eax
  801f2e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	57                   	push   %edi
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f4a:	85 db                	test   %ebx,%ebx
  801f4c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f51:	0f 44 d8             	cmove  %eax,%ebx
  801f54:	eb 05                	jmp    801f5b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f56:	e8 b1 eb ff ff       	call   800b0c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f5b:	ff 75 14             	push   0x14(%ebp)
  801f5e:	53                   	push   %ebx
  801f5f:	56                   	push   %esi
  801f60:	57                   	push   %edi
  801f61:	e8 52 ed ff ff       	call   800cb8 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6c:	74 e8                	je     801f56 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 08                	js     801f7a <ipc_send+0x42>
	}while (r<0);

}
  801f72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f75:	5b                   	pop    %ebx
  801f76:	5e                   	pop    %esi
  801f77:	5f                   	pop    %edi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f7a:	50                   	push   %eax
  801f7b:	68 f7 26 80 00       	push   $0x8026f7
  801f80:	6a 3d                	push   $0x3d
  801f82:	68 0b 27 80 00       	push   $0x80270b
  801f87:	e8 ff fe ff ff       	call   801e8b <_panic>

00801f8c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f97:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f9a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa0:	8b 52 50             	mov    0x50(%edx),%edx
  801fa3:	39 ca                	cmp    %ecx,%edx
  801fa5:	74 11                	je     801fb8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fa7:	83 c0 01             	add    $0x1,%eax
  801faa:	3d 00 04 00 00       	cmp    $0x400,%eax
  801faf:	75 e6                	jne    801f97 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb6:	eb 0b                	jmp    801fc3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fb8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fbb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcb:	89 c2                	mov    %eax,%edx
  801fcd:	c1 ea 16             	shr    $0x16,%edx
  801fd0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fdc:	f6 c1 01             	test   $0x1,%cl
  801fdf:	74 1c                	je     801ffd <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fe1:	c1 e8 0c             	shr    $0xc,%eax
  801fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801feb:	a8 01                	test   $0x1,%al
  801fed:	74 0e                	je     801ffd <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fef:	c1 e8 0c             	shr    $0xc,%eax
  801ff2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff9:	ef 
  801ffa:	0f b7 d2             	movzwl %dx,%edx
}
  801ffd:	89 d0                	mov    %edx,%eax
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    
  802001:	66 90                	xchg   %ax,%ax
  802003:	66 90                	xchg   %ax,%ax
  802005:	66 90                	xchg   %ax,%ax
  802007:	66 90                	xchg   %ax,%ax
  802009:	66 90                	xchg   %ax,%ax
  80200b:	66 90                	xchg   %ax,%ax
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80201f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802023:	8b 74 24 34          	mov    0x34(%esp),%esi
  802027:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 19                	jne    802048 <__udivdi3+0x38>
  80202f:	39 f3                	cmp    %esi,%ebx
  802031:	76 4d                	jbe    802080 <__udivdi3+0x70>
  802033:	31 ff                	xor    %edi,%edi
  802035:	89 e8                	mov    %ebp,%eax
  802037:	89 f2                	mov    %esi,%edx
  802039:	f7 f3                	div    %ebx
  80203b:	89 fa                	mov    %edi,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	76 14                	jbe    802060 <__udivdi3+0x50>
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	31 c0                	xor    %eax,%eax
  802050:	89 fa                	mov    %edi,%edx
  802052:	83 c4 1c             	add    $0x1c,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802060:	0f bd f8             	bsr    %eax,%edi
  802063:	83 f7 1f             	xor    $0x1f,%edi
  802066:	75 48                	jne    8020b0 <__udivdi3+0xa0>
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	72 06                	jb     802072 <__udivdi3+0x62>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 de                	ja     802050 <__udivdi3+0x40>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb d7                	jmp    802050 <__udivdi3+0x40>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d9                	mov    %ebx,%ecx
  802082:	85 db                	test   %ebx,%ebx
  802084:	75 0b                	jne    802091 <__udivdi3+0x81>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f3                	div    %ebx
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c6                	mov    %eax,%esi
  802099:	89 e8                	mov    %ebp,%eax
  80209b:	89 f7                	mov    %esi,%edi
  80209d:	f7 f1                	div    %ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020b7:	29 fa                	sub    %edi,%edx
  8020b9:	d3 e0                	shl    %cl,%eax
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	89 d1                	mov    %edx,%ecx
  8020c1:	89 d8                	mov    %ebx,%eax
  8020c3:	d3 e8                	shr    %cl,%eax
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 c1                	or     %eax,%ecx
  8020cb:	89 f0                	mov    %esi,%eax
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 d1                	mov    %edx,%ecx
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	89 eb                	mov    %ebp,%ebx
  8020e1:	d3 e6                	shl    %cl,%esi
  8020e3:	89 d1                	mov    %edx,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 f3                	or     %esi,%ebx
  8020e9:	89 c6                	mov    %eax,%esi
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	f7 74 24 08          	divl   0x8(%esp)
  8020f3:	89 d6                	mov    %edx,%esi
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	f7 64 24 0c          	mull   0xc(%esp)
  8020fb:	39 d6                	cmp    %edx,%esi
  8020fd:	72 19                	jb     802118 <__udivdi3+0x108>
  8020ff:	89 f9                	mov    %edi,%ecx
  802101:	d3 e5                	shl    %cl,%ebp
  802103:	39 c5                	cmp    %eax,%ebp
  802105:	73 04                	jae    80210b <__udivdi3+0xfb>
  802107:	39 d6                	cmp    %edx,%esi
  802109:	74 0d                	je     802118 <__udivdi3+0x108>
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	31 ff                	xor    %edi,%edi
  80210f:	e9 3c ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80211b:	31 ff                	xor    %edi,%edi
  80211d:	e9 2e ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
  80213b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80213f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802143:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802147:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 da                	mov    %ebx,%edx
  80214f:	85 ff                	test   %edi,%edi
  802151:	75 15                	jne    802168 <__umoddi3+0x38>
  802153:	39 dd                	cmp    %ebx,%ebp
  802155:	76 39                	jbe    802190 <__umoddi3+0x60>
  802157:	f7 f5                	div    %ebp
  802159:	89 d0                	mov    %edx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 1c             	add    $0x1c,%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	77 f1                	ja     80215d <__umoddi3+0x2d>
  80216c:	0f bd cf             	bsr    %edi,%ecx
  80216f:	83 f1 1f             	xor    $0x1f,%ecx
  802172:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802176:	75 40                	jne    8021b8 <__umoddi3+0x88>
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	72 04                	jb     802180 <__umoddi3+0x50>
  80217c:	39 f5                	cmp    %esi,%ebp
  80217e:	77 dd                	ja     80215d <__umoddi3+0x2d>
  802180:	89 da                	mov    %ebx,%edx
  802182:	89 f0                	mov    %esi,%eax
  802184:	29 e8                	sub    %ebp,%eax
  802186:	19 fa                	sbb    %edi,%edx
  802188:	eb d3                	jmp    80215d <__umoddi3+0x2d>
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	89 e9                	mov    %ebp,%ecx
  802192:	85 ed                	test   %ebp,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x71>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f5                	div    %ebp
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	f7 f1                	div    %ecx
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	eb ac                	jmp    80215d <__umoddi3+0x2d>
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021c1:	29 c2                	sub    %eax,%edx
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	d3 e7                	shl    %cl,%edi
  8021c9:	89 d1                	mov    %edx,%ecx
  8021cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021cf:	d3 e8                	shr    %cl,%eax
  8021d1:	89 c1                	mov    %eax,%ecx
  8021d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021d7:	09 f9                	or     %edi,%ecx
  8021d9:	89 df                	mov    %ebx,%edi
  8021db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	d3 e5                	shl    %cl,%ebp
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 ef                	shr    %cl,%edi
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	d3 e3                	shl    %cl,%ebx
  8021ed:	89 d1                	mov    %edx,%ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	d3 e8                	shr    %cl,%eax
  8021f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021f8:	09 d8                	or     %ebx,%eax
  8021fa:	f7 74 24 08          	divl   0x8(%esp)
  8021fe:	89 d3                	mov    %edx,%ebx
  802200:	d3 e6                	shl    %cl,%esi
  802202:	f7 e5                	mul    %ebp
  802204:	89 c7                	mov    %eax,%edi
  802206:	89 d1                	mov    %edx,%ecx
  802208:	39 d3                	cmp    %edx,%ebx
  80220a:	72 06                	jb     802212 <__umoddi3+0xe2>
  80220c:	75 0e                	jne    80221c <__umoddi3+0xec>
  80220e:	39 c6                	cmp    %eax,%esi
  802210:	73 0a                	jae    80221c <__umoddi3+0xec>
  802212:	29 e8                	sub    %ebp,%eax
  802214:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802218:	89 d1                	mov    %edx,%ecx
  80221a:	89 c7                	mov    %eax,%edi
  80221c:	89 f5                	mov    %esi,%ebp
  80221e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802222:	29 fd                	sub    %edi,%ebp
  802224:	19 cb                	sbb    %ecx,%ebx
  802226:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80222b:	89 d8                	mov    %ebx,%eax
  80222d:	d3 e0                	shl    %cl,%eax
  80222f:	89 f1                	mov    %esi,%ecx
  802231:	d3 ed                	shr    %cl,%ebp
  802233:	d3 eb                	shr    %cl,%ebx
  802235:	09 e8                	or     %ebp,%eax
  802237:	89 da                	mov    %ebx,%edx
  802239:	83 c4 1c             	add    $0x1c,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
