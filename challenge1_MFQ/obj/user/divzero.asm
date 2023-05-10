
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
  800056:	e8 fd 00 00 00       	call   800158 <cprintf>
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
  80006b:	e8 80 0a 00 00       	call   800af0 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0a 00 00 00       	call   8000a9 <exit>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000af:	e8 9d 0e 00 00       	call   800f51 <close_all>
	sys_env_destroy(0);
  8000b4:	83 ec 0c             	sub    $0xc,%esp
  8000b7:	6a 00                	push   $0x0
  8000b9:	e8 f1 09 00 00       	call   800aaf <sys_env_destroy>
}
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cd:	8b 13                	mov    (%ebx),%edx
  8000cf:	8d 42 01             	lea    0x1(%edx),%eax
  8000d2:	89 03                	mov    %eax,(%ebx)
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e0:	74 09                	je     8000eb <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	68 ff 00 00 00       	push   $0xff
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	50                   	push   %eax
  8000f7:	e8 76 09 00 00       	call   800a72 <sys_cputs>
		b->idx = 0;
  8000fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	eb db                	jmp    8000e2 <putch+0x1f>

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	ff 75 0c             	push   0xc(%ebp)
  800127:	ff 75 08             	push   0x8(%ebp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	50                   	push   %eax
  800131:	68 c3 00 80 00       	push   $0x8000c3
  800136:	e8 14 01 00 00       	call   80024f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	83 c4 08             	add    $0x8,%esp
  80013e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800144:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 22 09 00 00       	call   800a72 <sys_cputs>

	return b.cnt;
}
  800150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	50                   	push   %eax
  800162:	ff 75 08             	push   0x8(%ebp)
  800165:	e8 9d ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 1c             	sub    $0x1c,%esp
  800175:	89 c7                	mov    %eax,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 c2                	mov    %eax,%edx
  800183:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800186:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800189:	8b 45 10             	mov    0x10(%ebp),%eax
  80018c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800192:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800199:	39 c2                	cmp    %eax,%edx
  80019b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80019e:	72 3e                	jb     8001de <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	ff 75 18             	push   0x18(%ebp)
  8001a6:	83 eb 01             	sub    $0x1,%ebx
  8001a9:	53                   	push   %ebx
  8001aa:	50                   	push   %eax
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	ff 75 e4             	push   -0x1c(%ebp)
  8001b1:	ff 75 e0             	push   -0x20(%ebp)
  8001b4:	ff 75 dc             	push   -0x24(%ebp)
  8001b7:	ff 75 d8             	push   -0x28(%ebp)
  8001ba:	e8 61 1e 00 00       	call   802020 <__udivdi3>
  8001bf:	83 c4 18             	add    $0x18,%esp
  8001c2:	52                   	push   %edx
  8001c3:	50                   	push   %eax
  8001c4:	89 f2                	mov    %esi,%edx
  8001c6:	89 f8                	mov    %edi,%eax
  8001c8:	e8 9f ff ff ff       	call   80016c <printnum>
  8001cd:	83 c4 20             	add    $0x20,%esp
  8001d0:	eb 13                	jmp    8001e5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d2:	83 ec 08             	sub    $0x8,%esp
  8001d5:	56                   	push   %esi
  8001d6:	ff 75 18             	push   0x18(%ebp)
  8001d9:	ff d7                	call   *%edi
  8001db:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001de:	83 eb 01             	sub    $0x1,%ebx
  8001e1:	85 db                	test   %ebx,%ebx
  8001e3:	7f ed                	jg     8001d2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	83 ec 04             	sub    $0x4,%esp
  8001ec:	ff 75 e4             	push   -0x1c(%ebp)
  8001ef:	ff 75 e0             	push   -0x20(%ebp)
  8001f2:	ff 75 dc             	push   -0x24(%ebp)
  8001f5:	ff 75 d8             	push   -0x28(%ebp)
  8001f8:	e8 43 1f 00 00       	call   802140 <__umoddi3>
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	0f be 80 78 22 80 00 	movsbl 0x802278(%eax),%eax
  800207:	50                   	push   %eax
  800208:	ff d7                	call   *%edi
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021f:	8b 10                	mov    (%eax),%edx
  800221:	3b 50 04             	cmp    0x4(%eax),%edx
  800224:	73 0a                	jae    800230 <sprintputch+0x1b>
		*b->buf++ = ch;
  800226:	8d 4a 01             	lea    0x1(%edx),%ecx
  800229:	89 08                	mov    %ecx,(%eax)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	88 02                	mov    %al,(%edx)
}
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <printfmt>:
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800238:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 10             	push   0x10(%ebp)
  80023f:	ff 75 0c             	push   0xc(%ebp)
  800242:	ff 75 08             	push   0x8(%ebp)
  800245:	e8 05 00 00 00       	call   80024f <vprintfmt>
}
  80024a:	83 c4 10             	add    $0x10,%esp
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <vprintfmt>:
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 3c             	sub    $0x3c,%esp
  800258:	8b 75 08             	mov    0x8(%ebp),%esi
  80025b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800261:	eb 0a                	jmp    80026d <vprintfmt+0x1e>
			putch(ch, putdat);
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	53                   	push   %ebx
  800267:	50                   	push   %eax
  800268:	ff d6                	call   *%esi
  80026a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80026d:	83 c7 01             	add    $0x1,%edi
  800270:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800274:	83 f8 25             	cmp    $0x25,%eax
  800277:	74 0c                	je     800285 <vprintfmt+0x36>
			if (ch == '\0')
  800279:	85 c0                	test   %eax,%eax
  80027b:	75 e6                	jne    800263 <vprintfmt+0x14>
}
  80027d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5f                   	pop    %edi
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    
		padc = ' ';
  800285:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800289:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800290:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800297:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80029e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a3:	8d 47 01             	lea    0x1(%edi),%eax
  8002a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a9:	0f b6 17             	movzbl (%edi),%edx
  8002ac:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002af:	3c 55                	cmp    $0x55,%al
  8002b1:	0f 87 bb 03 00 00    	ja     800672 <vprintfmt+0x423>
  8002b7:	0f b6 c0             	movzbl %al,%eax
  8002ba:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8002c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c4:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c8:	eb d9                	jmp    8002a3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002cd:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d1:	eb d0                	jmp    8002a3 <vprintfmt+0x54>
  8002d3:	0f b6 d2             	movzbl %dl,%edx
  8002d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002eb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ee:	83 f9 09             	cmp    $0x9,%ecx
  8002f1:	77 55                	ja     800348 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f6:	eb e9                	jmp    8002e1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fb:	8b 00                	mov    (%eax),%eax
  8002fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800300:	8b 45 14             	mov    0x14(%ebp),%eax
  800303:	8d 40 04             	lea    0x4(%eax),%eax
  800306:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80030c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800310:	79 91                	jns    8002a3 <vprintfmt+0x54>
				width = precision, precision = -1;
  800312:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800315:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800318:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031f:	eb 82                	jmp    8002a3 <vprintfmt+0x54>
  800321:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800324:	85 d2                	test   %edx,%edx
  800326:	b8 00 00 00 00       	mov    $0x0,%eax
  80032b:	0f 49 c2             	cmovns %edx,%eax
  80032e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800334:	e9 6a ff ff ff       	jmp    8002a3 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80033c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800343:	e9 5b ff ff ff       	jmp    8002a3 <vprintfmt+0x54>
  800348:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034e:	eb bc                	jmp    80030c <vprintfmt+0xbd>
			lflag++;
  800350:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800356:	e9 48 ff ff ff       	jmp    8002a3 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 78 04             	lea    0x4(%eax),%edi
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	53                   	push   %ebx
  800365:	ff 30                	push   (%eax)
  800367:	ff d6                	call   *%esi
			break;
  800369:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80036c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036f:	e9 9d 02 00 00       	jmp    800611 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 78 04             	lea    0x4(%eax),%edi
  80037a:	8b 10                	mov    (%eax),%edx
  80037c:	89 d0                	mov    %edx,%eax
  80037e:	f7 d8                	neg    %eax
  800380:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800383:	83 f8 0f             	cmp    $0xf,%eax
  800386:	7f 23                	jg     8003ab <vprintfmt+0x15c>
  800388:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80038f:	85 d2                	test   %edx,%edx
  800391:	74 18                	je     8003ab <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800393:	52                   	push   %edx
  800394:	68 55 26 80 00       	push   $0x802655
  800399:	53                   	push   %ebx
  80039a:	56                   	push   %esi
  80039b:	e8 92 fe ff ff       	call   800232 <printfmt>
  8003a0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a6:	e9 66 02 00 00       	jmp    800611 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003ab:	50                   	push   %eax
  8003ac:	68 90 22 80 00       	push   $0x802290
  8003b1:	53                   	push   %ebx
  8003b2:	56                   	push   %esi
  8003b3:	e8 7a fe ff ff       	call   800232 <printfmt>
  8003b8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003be:	e9 4e 02 00 00       	jmp    800611 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	83 c0 04             	add    $0x4,%eax
  8003c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	b8 89 22 80 00       	mov    $0x802289,%eax
  8003d8:	0f 45 c2             	cmovne %edx,%eax
  8003db:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e2:	7e 06                	jle    8003ea <vprintfmt+0x19b>
  8003e4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e8:	75 0d                	jne    8003f7 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003ed:	89 c7                	mov    %eax,%edi
  8003ef:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	eb 55                	jmp    80044c <vprintfmt+0x1fd>
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	ff 75 d8             	push   -0x28(%ebp)
  8003fd:	ff 75 cc             	push   -0x34(%ebp)
  800400:	e8 0a 03 00 00       	call   80070f <strnlen>
  800405:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800408:	29 c1                	sub    %eax,%ecx
  80040a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80040d:	83 c4 10             	add    $0x10,%esp
  800410:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800412:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	eb 0f                	jmp    80042a <vprintfmt+0x1db>
					putch(padc, putdat);
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	53                   	push   %ebx
  80041f:	ff 75 e0             	push   -0x20(%ebp)
  800422:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800424:	83 ef 01             	sub    $0x1,%edi
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	85 ff                	test   %edi,%edi
  80042c:	7f ed                	jg     80041b <vprintfmt+0x1cc>
  80042e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800431:	85 d2                	test   %edx,%edx
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	0f 49 c2             	cmovns %edx,%eax
  80043b:	29 c2                	sub    %eax,%edx
  80043d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800440:	eb a8                	jmp    8003ea <vprintfmt+0x19b>
					putch(ch, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	52                   	push   %edx
  800447:	ff d6                	call   *%esi
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800451:	83 c7 01             	add    $0x1,%edi
  800454:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800458:	0f be d0             	movsbl %al,%edx
  80045b:	85 d2                	test   %edx,%edx
  80045d:	74 4b                	je     8004aa <vprintfmt+0x25b>
  80045f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800463:	78 06                	js     80046b <vprintfmt+0x21c>
  800465:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800469:	78 1e                	js     800489 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80046b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046f:	74 d1                	je     800442 <vprintfmt+0x1f3>
  800471:	0f be c0             	movsbl %al,%eax
  800474:	83 e8 20             	sub    $0x20,%eax
  800477:	83 f8 5e             	cmp    $0x5e,%eax
  80047a:	76 c6                	jbe    800442 <vprintfmt+0x1f3>
					putch('?', putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	6a 3f                	push   $0x3f
  800482:	ff d6                	call   *%esi
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	eb c3                	jmp    80044c <vprintfmt+0x1fd>
  800489:	89 cf                	mov    %ecx,%edi
  80048b:	eb 0e                	jmp    80049b <vprintfmt+0x24c>
				putch(' ', putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	53                   	push   %ebx
  800491:	6a 20                	push   $0x20
  800493:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800495:	83 ef 01             	sub    $0x1,%edi
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	85 ff                	test   %edi,%edi
  80049d:	7f ee                	jg     80048d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80049f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a5:	e9 67 01 00 00       	jmp    800611 <vprintfmt+0x3c2>
  8004aa:	89 cf                	mov    %ecx,%edi
  8004ac:	eb ed                	jmp    80049b <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ae:	83 f9 01             	cmp    $0x1,%ecx
  8004b1:	7f 1b                	jg     8004ce <vprintfmt+0x27f>
	else if (lflag)
  8004b3:	85 c9                	test   %ecx,%ecx
  8004b5:	74 63                	je     80051a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bf:	99                   	cltd   
  8004c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 40 04             	lea    0x4(%eax),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cc:	eb 17                	jmp    8004e5 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8b 50 04             	mov    0x4(%eax),%edx
  8004d4:	8b 00                	mov    (%eax),%eax
  8004d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 40 08             	lea    0x8(%eax),%eax
  8004e2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004eb:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004f0:	85 c9                	test   %ecx,%ecx
  8004f2:	0f 89 ff 00 00 00    	jns    8005f7 <vprintfmt+0x3a8>
				putch('-', putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	6a 2d                	push   $0x2d
  8004fe:	ff d6                	call   *%esi
				num = -(long long) num;
  800500:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800503:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800506:	f7 da                	neg    %edx
  800508:	83 d1 00             	adc    $0x0,%ecx
  80050b:	f7 d9                	neg    %ecx
  80050d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800510:	bf 0a 00 00 00       	mov    $0xa,%edi
  800515:	e9 dd 00 00 00       	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	99                   	cltd   
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 40 04             	lea    0x4(%eax),%eax
  80052c:	89 45 14             	mov    %eax,0x14(%ebp)
  80052f:	eb b4                	jmp    8004e5 <vprintfmt+0x296>
	if (lflag >= 2)
  800531:	83 f9 01             	cmp    $0x1,%ecx
  800534:	7f 1e                	jg     800554 <vprintfmt+0x305>
	else if (lflag)
  800536:	85 c9                	test   %ecx,%ecx
  800538:	74 32                	je     80056c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 10                	mov    (%eax),%edx
  80053f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800544:	8d 40 04             	lea    0x4(%eax),%eax
  800547:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80054f:	e9 a3 00 00 00       	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8b 10                	mov    (%eax),%edx
  800559:	8b 48 04             	mov    0x4(%eax),%ecx
  80055c:	8d 40 08             	lea    0x8(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800562:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800567:	e9 8b 00 00 00       	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 10                	mov    (%eax),%edx
  800571:	b9 00 00 00 00       	mov    $0x0,%ecx
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800581:	eb 74                	jmp    8005f7 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800583:	83 f9 01             	cmp    $0x1,%ecx
  800586:	7f 1b                	jg     8005a3 <vprintfmt+0x354>
	else if (lflag)
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	74 2c                	je     8005b8 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	b9 00 00 00 00       	mov    $0x0,%ecx
  800596:	8d 40 04             	lea    0x4(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80059c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005a1:	eb 54                	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ab:	8d 40 08             	lea    0x8(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005b1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005b6:	eb 3f                	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 10                	mov    (%eax),%edx
  8005bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c2:	8d 40 04             	lea    0x4(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005cd:	eb 28                	jmp    8005f7 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 30                	push   $0x30
  8005d5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d7:	83 c4 08             	add    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	6a 78                	push   $0x78
  8005dd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f2:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005fe:	50                   	push   %eax
  8005ff:	ff 75 e0             	push   -0x20(%ebp)
  800602:	57                   	push   %edi
  800603:	51                   	push   %ecx
  800604:	52                   	push   %edx
  800605:	89 da                	mov    %ebx,%edx
  800607:	89 f0                	mov    %esi,%eax
  800609:	e8 5e fb ff ff       	call   80016c <printnum>
			break;
  80060e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800614:	e9 54 fc ff ff       	jmp    80026d <vprintfmt+0x1e>
	if (lflag >= 2)
  800619:	83 f9 01             	cmp    $0x1,%ecx
  80061c:	7f 1b                	jg     800639 <vprintfmt+0x3ea>
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	74 2c                	je     80064e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062c:	8d 40 04             	lea    0x4(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800632:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800637:	eb be                	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80064c:	eb a9                	jmp    8005f7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	b9 00 00 00 00       	mov    $0x0,%ecx
  800658:	8d 40 04             	lea    0x4(%eax),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800663:	eb 92                	jmp    8005f7 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 25                	push   $0x25
  80066b:	ff d6                	call   *%esi
			break;
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	eb 9f                	jmp    800611 <vprintfmt+0x3c2>
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	89 f8                	mov    %edi,%eax
  80067f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800683:	74 05                	je     80068a <vprintfmt+0x43b>
  800685:	83 e8 01             	sub    $0x1,%eax
  800688:	eb f5                	jmp    80067f <vprintfmt+0x430>
  80068a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068d:	eb 82                	jmp    800611 <vprintfmt+0x3c2>

0080068f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	83 ec 18             	sub    $0x18,%esp
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 26                	je     8006d6 <vsnprintf+0x47>
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	7e 22                	jle    8006d6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b4:	ff 75 14             	push   0x14(%ebp)
  8006b7:	ff 75 10             	push   0x10(%ebp)
  8006ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	68 15 02 80 00       	push   $0x800215
  8006c3:	e8 87 fb ff ff       	call   80024f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	83 c4 10             	add    $0x10,%esp
}
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    
		return -E_INVAL;
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006db:	eb f7                	jmp    8006d4 <vsnprintf+0x45>

008006dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e6:	50                   	push   %eax
  8006e7:	ff 75 10             	push   0x10(%ebp)
  8006ea:	ff 75 0c             	push   0xc(%ebp)
  8006ed:	ff 75 08             	push   0x8(%ebp)
  8006f0:	e8 9a ff ff ff       	call   80068f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	eb 03                	jmp    800707 <strlen+0x10>
		n++;
  800704:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800707:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070b:	75 f7                	jne    800704 <strlen+0xd>
	return n;
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800715:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	eb 03                	jmp    800722 <strnlen+0x13>
		n++;
  80071f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800722:	39 d0                	cmp    %edx,%eax
  800724:	74 08                	je     80072e <strnlen+0x1f>
  800726:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072a:	75 f3                	jne    80071f <strnlen+0x10>
  80072c:	89 c2                	mov    %eax,%edx
	return n;
}
  80072e:	89 d0                	mov    %edx,%eax
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800739:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073c:	b8 00 00 00 00       	mov    $0x0,%eax
  800741:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800745:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800748:	83 c0 01             	add    $0x1,%eax
  80074b:	84 d2                	test   %dl,%dl
  80074d:	75 f2                	jne    800741 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074f:	89 c8                	mov    %ecx,%eax
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	83 ec 10             	sub    $0x10,%esp
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 91 ff ff ff       	call   8006f7 <strlen>
  800766:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	push   0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 be ff ff ff       	call   800732 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f0                	mov    %esi,%eax
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c0 01             	add    $0x1,%eax
  800792:	0f b6 0a             	movzbl (%edx),%ecx
  800795:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 f9 01             	cmp    $0x1,%cl
  80079b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80079e:	39 d8                	cmp    %ebx,%eax
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 21                	je     8007dd <strlcpy+0x35>
  8007bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 09                	jmp    8007cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 09                	je     8007da <strlcpy+0x32>
  8007d1:	0f b6 19             	movzbl (%ecx),%ebx
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ec                	jne    8007c4 <strlcpy+0x1c>
  8007d8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dd:	29 f0                	sub    %esi,%eax
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strcmp+0x11>
		p++, q++;
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x1c>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 ef                	je     8007ee <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 06                	jmp    800820 <strncmp+0x17>
		n--, p++, q++;
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 18                	je     80083c <strncmp+0x33>
  800824:	0f b6 08             	movzbl (%eax),%ecx
  800827:	84 c9                	test   %cl,%cl
  800829:	74 04                	je     80082f <strncmp+0x26>
  80082b:	3a 0a                	cmp    (%edx),%cl
  80082d:	74 eb                	je     80081a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
}
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    
		return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb f4                	jmp    800837 <strncmp+0x2e>

00800843 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084d:	eb 03                	jmp    800852 <strchr+0xf>
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	0f b6 10             	movzbl (%eax),%edx
  800855:	84 d2                	test   %dl,%dl
  800857:	74 06                	je     80085f <strchr+0x1c>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	75 f2                	jne    80084f <strchr+0xc>
  80085d:	eb 05                	jmp    800864 <strchr+0x21>
			return (char *) s;
	return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800870:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800873:	38 ca                	cmp    %cl,%dl
  800875:	74 09                	je     800880 <strfind+0x1a>
  800877:	84 d2                	test   %dl,%dl
  800879:	74 05                	je     800880 <strfind+0x1a>
	for (; *s; s++)
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	eb f0                	jmp    800870 <strfind+0xa>
			break;
	return (char *) s;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 2f                	je     8008c1 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800892:	89 f8                	mov    %edi,%eax
  800894:	09 c8                	or     %ecx,%eax
  800896:	a8 03                	test   $0x3,%al
  800898:	75 21                	jne    8008bb <memset+0x39>
		c &= 0xFF;
  80089a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089e:	89 d0                	mov    %edx,%eax
  8008a0:	c1 e0 08             	shl    $0x8,%eax
  8008a3:	89 d3                	mov    %edx,%ebx
  8008a5:	c1 e3 18             	shl    $0x18,%ebx
  8008a8:	89 d6                	mov    %edx,%esi
  8008aa:	c1 e6 10             	shl    $0x10,%esi
  8008ad:	09 f3                	or     %esi,%ebx
  8008af:	09 da                	or     %ebx,%edx
  8008b1:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 06                	jmp    8008c1 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 32                	jae    80090c <memmove+0x44>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 c2                	cmp    %eax,%edx
  8008df:	76 2b                	jbe    80090c <memmove+0x44>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	09 fe                	or     %edi,%esi
  8008e8:	09 ce                	or     %ecx,%esi
  8008ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f0:	75 0e                	jne    800900 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f2:	83 ef 04             	sub    $0x4,%edi
  8008f5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008fb:	fd                   	std    
  8008fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fe:	eb 09                	jmp    800909 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800900:	83 ef 01             	sub    $0x1,%edi
  800903:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800906:	fd                   	std    
  800907:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800909:	fc                   	cld    
  80090a:	eb 1a                	jmp    800926 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090c:	89 f2                	mov    %esi,%edx
  80090e:	09 c2                	or     %eax,%edx
  800910:	09 ca                	or     %ecx,%edx
  800912:	f6 c2 03             	test   $0x3,%dl
  800915:	75 0a                	jne    800921 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800917:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80091a:	89 c7                	mov    %eax,%edi
  80091c:	fc                   	cld    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 05                	jmp    800926 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800930:	ff 75 10             	push   0x10(%ebp)
  800933:	ff 75 0c             	push   0xc(%ebp)
  800936:	ff 75 08             	push   0x8(%ebp)
  800939:	e8 8a ff ff ff       	call   8008c8 <memmove>
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094b:	89 c6                	mov    %eax,%esi
  80094d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800950:	eb 06                	jmp    800958 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800958:	39 f0                	cmp    %esi,%eax
  80095a:	74 14                	je     800970 <memcmp+0x30>
		if (*s1 != *s2)
  80095c:	0f b6 08             	movzbl (%eax),%ecx
  80095f:	0f b6 1a             	movzbl (%edx),%ebx
  800962:	38 d9                	cmp    %bl,%cl
  800964:	74 ec                	je     800952 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800966:	0f b6 c1             	movzbl %cl,%eax
  800969:	0f b6 db             	movzbl %bl,%ebx
  80096c:	29 d8                	sub    %ebx,%eax
  80096e:	eb 05                	jmp    800975 <memcmp+0x35>
	}

	return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800982:	89 c2                	mov    %eax,%edx
  800984:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800987:	eb 03                	jmp    80098c <memfind+0x13>
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	39 d0                	cmp    %edx,%eax
  80098e:	73 04                	jae    800994 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800990:	38 08                	cmp    %cl,(%eax)
  800992:	75 f5                	jne    800989 <memfind+0x10>
			break;
	return (void *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 55 08             	mov    0x8(%ebp),%edx
  80099f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	eb 03                	jmp    8009a7 <strtol+0x11>
		s++;
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009a7:	0f b6 02             	movzbl (%edx),%eax
  8009aa:	3c 20                	cmp    $0x20,%al
  8009ac:	74 f6                	je     8009a4 <strtol+0xe>
  8009ae:	3c 09                	cmp    $0x9,%al
  8009b0:	74 f2                	je     8009a4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009b2:	3c 2b                	cmp    $0x2b,%al
  8009b4:	74 2a                	je     8009e0 <strtol+0x4a>
	int neg = 0;
  8009b6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009bb:	3c 2d                	cmp    $0x2d,%al
  8009bd:	74 2b                	je     8009ea <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c5:	75 0f                	jne    8009d6 <strtol+0x40>
  8009c7:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ca:	74 28                	je     8009f4 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cc:	85 db                	test   %ebx,%ebx
  8009ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d3:	0f 44 d8             	cmove  %eax,%ebx
  8009d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009db:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009de:	eb 46                	jmp    800a26 <strtol+0x90>
		s++;
  8009e0:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e8:	eb d5                	jmp    8009bf <strtol+0x29>
		s++, neg = 1;
  8009ea:	83 c2 01             	add    $0x1,%edx
  8009ed:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f2:	eb cb                	jmp    8009bf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f8:	74 0e                	je     800a08 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 d8                	jne    8009d6 <strtol+0x40>
		s++, base = 8;
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a06:	eb ce                	jmp    8009d6 <strtol+0x40>
		s += 2, base = 16;
  800a08:	83 c2 02             	add    $0x2,%edx
  800a0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a10:	eb c4                	jmp    8009d6 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a12:	0f be c0             	movsbl %al,%eax
  800a15:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a18:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a1b:	7d 3a                	jge    800a57 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a1d:	83 c2 01             	add    $0x1,%edx
  800a20:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a24:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a26:	0f b6 02             	movzbl (%edx),%eax
  800a29:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a2c:	89 f3                	mov    %esi,%ebx
  800a2e:	80 fb 09             	cmp    $0x9,%bl
  800a31:	76 df                	jbe    800a12 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a33:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 08                	ja     800a45 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a3d:	0f be c0             	movsbl %al,%eax
  800a40:	83 e8 57             	sub    $0x57,%eax
  800a43:	eb d3                	jmp    800a18 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a45:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 19             	cmp    $0x19,%bl
  800a4d:	77 08                	ja     800a57 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a4f:	0f be c0             	movsbl %al,%eax
  800a52:	83 e8 37             	sub    $0x37,%eax
  800a55:	eb c1                	jmp    800a18 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5b:	74 05                	je     800a62 <strtol+0xcc>
		*endptr = (char *) s;
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a62:	89 c8                	mov    %ecx,%eax
  800a64:	f7 d8                	neg    %eax
  800a66:	85 ff                	test   %edi,%edi
  800a68:	0f 45 c8             	cmovne %eax,%ecx
}
  800a6b:	89 c8                	mov    %ecx,%eax
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a83:	89 c3                	mov    %eax,%ebx
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	89 c6                	mov    %eax,%esi
  800a89:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa0:	89 d1                	mov    %edx,%ecx
  800aa2:	89 d3                	mov    %edx,%ebx
  800aa4:	89 d7                	mov    %edx,%edi
  800aa6:	89 d6                	mov    %edx,%esi
  800aa8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ab8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac5:	89 cb                	mov    %ecx,%ebx
  800ac7:	89 cf                	mov    %ecx,%edi
  800ac9:	89 ce                	mov    %ecx,%esi
  800acb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800acd:	85 c0                	test   %eax,%eax
  800acf:	7f 08                	jg     800ad9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	50                   	push   %eax
  800add:	6a 03                	push   $0x3
  800adf:	68 7f 25 80 00       	push   $0x80257f
  800ae4:	6a 2a                	push   $0x2a
  800ae6:	68 9c 25 80 00       	push   $0x80259c
  800aeb:	e8 9e 13 00 00       	call   801e8e <_panic>

00800af0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 02 00 00 00       	mov    $0x2,%eax
  800b00:	89 d1                	mov    %edx,%ecx
  800b02:	89 d3                	mov    %edx,%ebx
  800b04:	89 d7                	mov    %edx,%edi
  800b06:	89 d6                	mov    %edx,%esi
  800b08:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_yield>:

void
sys_yield(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b1f:	89 d1                	mov    %edx,%ecx
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	89 d7                	mov    %edx,%edi
  800b25:	89 d6                	mov    %edx,%esi
  800b27:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b37:	be 00 00 00 00       	mov    $0x0,%esi
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	b8 04 00 00 00       	mov    $0x4,%eax
  800b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4a:	89 f7                	mov    %esi,%edi
  800b4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7f 08                	jg     800b5a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	50                   	push   %eax
  800b5e:	6a 04                	push   $0x4
  800b60:	68 7f 25 80 00       	push   $0x80257f
  800b65:	6a 2a                	push   $0x2a
  800b67:	68 9c 25 80 00       	push   $0x80259c
  800b6c:	e8 1d 13 00 00       	call   801e8e <_panic>

00800b71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b80:	b8 05 00 00 00       	mov    $0x5,%eax
  800b85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b90:	85 c0                	test   %eax,%eax
  800b92:	7f 08                	jg     800b9c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 05                	push   $0x5
  800ba2:	68 7f 25 80 00       	push   $0x80257f
  800ba7:	6a 2a                	push   $0x2a
  800ba9:	68 9c 25 80 00       	push   $0x80259c
  800bae:	e8 db 12 00 00       	call   801e8e <_panic>

00800bb3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcc:	89 df                	mov    %ebx,%edi
  800bce:	89 de                	mov    %ebx,%esi
  800bd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7f 08                	jg     800bde <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 06                	push   $0x6
  800be4:	68 7f 25 80 00       	push   $0x80257f
  800be9:	6a 2a                	push   $0x2a
  800beb:	68 9c 25 80 00       	push   $0x80259c
  800bf0:	e8 99 12 00 00       	call   801e8e <_panic>

00800bf5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0e:	89 df                	mov    %ebx,%edi
  800c10:	89 de                	mov    %ebx,%esi
  800c12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7f 08                	jg     800c20 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800c24:	6a 08                	push   $0x8
  800c26:	68 7f 25 80 00       	push   $0x80257f
  800c2b:	6a 2a                	push   $0x2a
  800c2d:	68 9c 25 80 00       	push   $0x80259c
  800c32:	e8 57 12 00 00       	call   801e8e <_panic>

00800c37 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c50:	89 df                	mov    %ebx,%edi
  800c52:	89 de                	mov    %ebx,%esi
  800c54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7f 08                	jg     800c62 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800c66:	6a 09                	push   $0x9
  800c68:	68 7f 25 80 00       	push   $0x80257f
  800c6d:	6a 2a                	push   $0x2a
  800c6f:	68 9c 25 80 00       	push   $0x80259c
  800c74:	e8 15 12 00 00       	call   801e8e <_panic>

00800c79 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c92:	89 df                	mov    %ebx,%edi
  800c94:	89 de                	mov    %ebx,%esi
  800c96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7f 08                	jg     800ca4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800ca8:	6a 0a                	push   $0xa
  800caa:	68 7f 25 80 00       	push   $0x80257f
  800caf:	6a 2a                	push   $0x2a
  800cb1:	68 9c 25 80 00       	push   $0x80259c
  800cb6:	e8 d3 11 00 00       	call   801e8e <_panic>

00800cbb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf4:	89 cb                	mov    %ecx,%ebx
  800cf6:	89 cf                	mov    %ecx,%edi
  800cf8:	89 ce                	mov    %ecx,%esi
  800cfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7f 08                	jg     800d08 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 0d                	push   $0xd
  800d0e:	68 7f 25 80 00       	push   $0x80257f
  800d13:	6a 2a                	push   $0x2a
  800d15:	68 9c 25 80 00       	push   $0x80259c
  800d1a:	e8 6f 11 00 00       	call   801e8e <_panic>

00800d1f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 d3                	mov    %edx,%ebx
  800d33:	89 d7                	mov    %edx,%edi
  800d35:	89 d6                	mov    %edx,%esi
  800d37:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	b8 10 00 00 00       	mov    $0x10,%eax
  800d75:	89 df                	mov    %ebx,%edi
  800d77:	89 de                	mov    %ebx,%esi
  800d79:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	c1 ea 16             	shr    $0x16,%edx
  800db4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dbb:	f6 c2 01             	test   $0x1,%dl
  800dbe:	74 29                	je     800de9 <fd_alloc+0x42>
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	c1 ea 0c             	shr    $0xc,%edx
  800dc5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcc:	f6 c2 01             	test   $0x1,%dl
  800dcf:	74 18                	je     800de9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dd1:	05 00 10 00 00       	add    $0x1000,%eax
  800dd6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ddb:	75 d2                	jne    800daf <fd_alloc+0x8>
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800de2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800de7:	eb 05                	jmp    800dee <fd_alloc+0x47>
			return 0;
  800de9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	89 02                	mov    %eax,(%edx)
}
  800df3:	89 c8                	mov    %ecx,%eax
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfd:	83 f8 1f             	cmp    $0x1f,%eax
  800e00:	77 30                	ja     800e32 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e02:	c1 e0 0c             	shl    $0xc,%eax
  800e05:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e10:	f6 c2 01             	test   $0x1,%dl
  800e13:	74 24                	je     800e39 <fd_lookup+0x42>
  800e15:	89 c2                	mov    %eax,%edx
  800e17:	c1 ea 0c             	shr    $0xc,%edx
  800e1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e21:	f6 c2 01             	test   $0x1,%dl
  800e24:	74 1a                	je     800e40 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e29:	89 02                	mov    %eax,(%edx)
	return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
		return -E_INVAL;
  800e32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e37:	eb f7                	jmp    800e30 <fd_lookup+0x39>
		return -E_INVAL;
  800e39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3e:	eb f0                	jmp    800e30 <fd_lookup+0x39>
  800e40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e45:	eb e9                	jmp    800e30 <fd_lookup+0x39>

00800e47 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	53                   	push   %ebx
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e5b:	39 13                	cmp    %edx,(%ebx)
  800e5d:	74 37                	je     800e96 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e5f:	83 c0 01             	add    $0x1,%eax
  800e62:	8b 1c 85 28 26 80 00 	mov    0x802628(,%eax,4),%ebx
  800e69:	85 db                	test   %ebx,%ebx
  800e6b:	75 ee                	jne    800e5b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e72:	8b 40 58             	mov    0x58(%eax),%eax
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	52                   	push   %edx
  800e79:	50                   	push   %eax
  800e7a:	68 ac 25 80 00       	push   $0x8025ac
  800e7f:	e8 d4 f2 ff ff       	call   800158 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8f:	89 1a                	mov    %ebx,(%edx)
}
  800e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    
			return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb ef                	jmp    800e8c <dev_lookup+0x45>

00800e9d <fd_close>:
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 24             	sub    $0x24,%esp
  800ea6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eaf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb9:	50                   	push   %eax
  800eba:	e8 38 ff ff ff       	call   800df7 <fd_lookup>
  800ebf:	89 c3                	mov    %eax,%ebx
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 05                	js     800ecd <fd_close+0x30>
	    || fd != fd2)
  800ec8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ecb:	74 16                	je     800ee3 <fd_close+0x46>
		return (must_exist ? r : 0);
  800ecd:	89 f8                	mov    %edi,%eax
  800ecf:	84 c0                	test   %al,%al
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed9:	89 d8                	mov    %ebx,%eax
  800edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee9:	50                   	push   %eax
  800eea:	ff 36                	push   (%esi)
  800eec:	e8 56 ff ff ff       	call   800e47 <dev_lookup>
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	78 1a                	js     800f14 <fd_close+0x77>
		if (dev->dev_close)
  800efa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efd:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f05:	85 c0                	test   %eax,%eax
  800f07:	74 0b                	je     800f14 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	56                   	push   %esi
  800f0d:	ff d0                	call   *%eax
  800f0f:	89 c3                	mov    %eax,%ebx
  800f11:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f14:	83 ec 08             	sub    $0x8,%esp
  800f17:	56                   	push   %esi
  800f18:	6a 00                	push   $0x0
  800f1a:	e8 94 fc ff ff       	call   800bb3 <sys_page_unmap>
	return r;
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	eb b5                	jmp    800ed9 <fd_close+0x3c>

00800f24 <close>:

int
close(int fdnum)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 75 08             	push   0x8(%ebp)
  800f31:	e8 c1 fe ff ff       	call   800df7 <fd_lookup>
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	79 02                	jns    800f3f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    
		return fd_close(fd, 1);
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	6a 01                	push   $0x1
  800f44:	ff 75 f4             	push   -0xc(%ebp)
  800f47:	e8 51 ff ff ff       	call   800e9d <fd_close>
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	eb ec                	jmp    800f3d <close+0x19>

00800f51 <close_all>:

void
close_all(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	53                   	push   %ebx
  800f55:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	53                   	push   %ebx
  800f61:	e8 be ff ff ff       	call   800f24 <close>
	for (i = 0; i < MAXFD; i++)
  800f66:	83 c3 01             	add    $0x1,%ebx
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	83 fb 20             	cmp    $0x20,%ebx
  800f6f:	75 ec                	jne    800f5d <close_all+0xc>
}
  800f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	ff 75 08             	push   0x8(%ebp)
  800f86:	e8 6c fe ff ff       	call   800df7 <fd_lookup>
  800f8b:	89 c3                	mov    %eax,%ebx
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 7f                	js     801013 <dup+0x9d>
		return r;
	close(newfdnum);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	ff 75 0c             	push   0xc(%ebp)
  800f9a:	e8 85 ff ff ff       	call   800f24 <close>

	newfd = INDEX2FD(newfdnum);
  800f9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa2:	c1 e6 0c             	shl    $0xc,%esi
  800fa5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fae:	89 3c 24             	mov    %edi,(%esp)
  800fb1:	e8 da fd ff ff       	call   800d90 <fd2data>
  800fb6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb8:	89 34 24             	mov    %esi,(%esp)
  800fbb:	e8 d0 fd ff ff       	call   800d90 <fd2data>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	c1 e8 16             	shr    $0x16,%eax
  800fcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	74 11                	je     800fe7 <dup+0x71>
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	c1 e8 0c             	shr    $0xc,%eax
  800fdb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe2:	f6 c2 01             	test   $0x1,%dl
  800fe5:	75 36                	jne    80101d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe7:	89 f8                	mov    %edi,%eax
  800fe9:	c1 e8 0c             	shr    $0xc,%eax
  800fec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffb:	50                   	push   %eax
  800ffc:	56                   	push   %esi
  800ffd:	6a 00                	push   $0x0
  800fff:	57                   	push   %edi
  801000:	6a 00                	push   $0x0
  801002:	e8 6a fb ff ff       	call   800b71 <sys_page_map>
  801007:	89 c3                	mov    %eax,%ebx
  801009:	83 c4 20             	add    $0x20,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 33                	js     801043 <dup+0xcd>
		goto err;

	return newfdnum;
  801010:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801013:	89 d8                	mov    %ebx,%eax
  801015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80101d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	25 07 0e 00 00       	and    $0xe07,%eax
  80102c:	50                   	push   %eax
  80102d:	ff 75 d4             	push   -0x2c(%ebp)
  801030:	6a 00                	push   $0x0
  801032:	53                   	push   %ebx
  801033:	6a 00                	push   $0x0
  801035:	e8 37 fb ff ff       	call   800b71 <sys_page_map>
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 a4                	jns    800fe7 <dup+0x71>
	sys_page_unmap(0, newfd);
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	e8 65 fb ff ff       	call   800bb3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80104e:	83 c4 08             	add    $0x8,%esp
  801051:	ff 75 d4             	push   -0x2c(%ebp)
  801054:	6a 00                	push   $0x0
  801056:	e8 58 fb ff ff       	call   800bb3 <sys_page_unmap>
	return r;
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	eb b3                	jmp    801013 <dup+0x9d>

00801060 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	83 ec 18             	sub    $0x18,%esp
  801068:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80106b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106e:	50                   	push   %eax
  80106f:	56                   	push   %esi
  801070:	e8 82 fd ff ff       	call   800df7 <fd_lookup>
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 3c                	js     8010b8 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80107f:	83 ec 08             	sub    $0x8,%esp
  801082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801085:	50                   	push   %eax
  801086:	ff 33                	push   (%ebx)
  801088:	e8 ba fd ff ff       	call   800e47 <dev_lookup>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 24                	js     8010b8 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801094:	8b 43 08             	mov    0x8(%ebx),%eax
  801097:	83 e0 03             	and    $0x3,%eax
  80109a:	83 f8 01             	cmp    $0x1,%eax
  80109d:	74 20                	je     8010bf <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80109f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a2:	8b 40 08             	mov    0x8(%eax),%eax
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	74 37                	je     8010e0 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	ff 75 10             	push   0x10(%ebp)
  8010af:	ff 75 0c             	push   0xc(%ebp)
  8010b2:	53                   	push   %ebx
  8010b3:	ff d0                	call   *%eax
  8010b5:	83 c4 10             	add    $0x10,%esp
}
  8010b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bb:	5b                   	pop    %ebx
  8010bc:	5e                   	pop    %esi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c4:	8b 40 58             	mov    0x58(%eax),%eax
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	56                   	push   %esi
  8010cb:	50                   	push   %eax
  8010cc:	68 ed 25 80 00       	push   $0x8025ed
  8010d1:	e8 82 f0 ff ff       	call   800158 <cprintf>
		return -E_INVAL;
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010de:	eb d8                	jmp    8010b8 <read+0x58>
		return -E_NOT_SUPP;
  8010e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010e5:	eb d1                	jmp    8010b8 <read+0x58>

008010e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fb:	eb 02                	jmp    8010ff <readn+0x18>
  8010fd:	01 c3                	add    %eax,%ebx
  8010ff:	39 f3                	cmp    %esi,%ebx
  801101:	73 21                	jae    801124 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801103:	83 ec 04             	sub    $0x4,%esp
  801106:	89 f0                	mov    %esi,%eax
  801108:	29 d8                	sub    %ebx,%eax
  80110a:	50                   	push   %eax
  80110b:	89 d8                	mov    %ebx,%eax
  80110d:	03 45 0c             	add    0xc(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	57                   	push   %edi
  801112:	e8 49 ff ff ff       	call   801060 <read>
		if (m < 0)
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 04                	js     801122 <readn+0x3b>
			return m;
		if (m == 0)
  80111e:	75 dd                	jne    8010fd <readn+0x16>
  801120:	eb 02                	jmp    801124 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801122:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801124:	89 d8                	mov    %ebx,%eax
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 18             	sub    $0x18,%esp
  801136:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801139:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	53                   	push   %ebx
  80113e:	e8 b4 fc ff ff       	call   800df7 <fd_lookup>
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 37                	js     801181 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	ff 36                	push   (%esi)
  801156:	e8 ec fc ff ff       	call   800e47 <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 1f                	js     801181 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801162:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801166:	74 20                	je     801188 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	8b 40 0c             	mov    0xc(%eax),%eax
  80116e:	85 c0                	test   %eax,%eax
  801170:	74 37                	je     8011a9 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	ff 75 10             	push   0x10(%ebp)
  801178:	ff 75 0c             	push   0xc(%ebp)
  80117b:	56                   	push   %esi
  80117c:	ff d0                	call   *%eax
  80117e:	83 c4 10             	add    $0x10,%esp
}
  801181:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801188:	a1 04 40 80 00       	mov    0x804004,%eax
  80118d:	8b 40 58             	mov    0x58(%eax),%eax
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	53                   	push   %ebx
  801194:	50                   	push   %eax
  801195:	68 09 26 80 00       	push   $0x802609
  80119a:	e8 b9 ef ff ff       	call   800158 <cprintf>
		return -E_INVAL;
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a7:	eb d8                	jmp    801181 <write+0x53>
		return -E_NOT_SUPP;
  8011a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ae:	eb d1                	jmp    801181 <write+0x53>

008011b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 75 08             	push   0x8(%ebp)
  8011bd:	e8 35 fc ff ff       	call   800df7 <fd_lookup>
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 0e                	js     8011d7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 18             	sub    $0x18,%esp
  8011e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	53                   	push   %ebx
  8011e9:	e8 09 fc ff ff       	call   800df7 <fd_lookup>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 34                	js     801229 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	ff 36                	push   (%esi)
  801201:	e8 41 fc ff ff       	call   800e47 <dev_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 1c                	js     801229 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801211:	74 1d                	je     801230 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801213:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801216:	8b 40 18             	mov    0x18(%eax),%eax
  801219:	85 c0                	test   %eax,%eax
  80121b:	74 34                	je     801251 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121d:	83 ec 08             	sub    $0x8,%esp
  801220:	ff 75 0c             	push   0xc(%ebp)
  801223:	56                   	push   %esi
  801224:	ff d0                	call   *%eax
  801226:	83 c4 10             	add    $0x10,%esp
}
  801229:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801230:	a1 04 40 80 00       	mov    0x804004,%eax
  801235:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	53                   	push   %ebx
  80123c:	50                   	push   %eax
  80123d:	68 cc 25 80 00       	push   $0x8025cc
  801242:	e8 11 ef ff ff       	call   800158 <cprintf>
		return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124f:	eb d8                	jmp    801229 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801251:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801256:	eb d1                	jmp    801229 <ftruncate+0x50>

00801258 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 18             	sub    $0x18,%esp
  801260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801263:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	ff 75 08             	push   0x8(%ebp)
  80126a:	e8 88 fb ff ff       	call   800df7 <fd_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 49                	js     8012bf <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801276:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127f:	50                   	push   %eax
  801280:	ff 36                	push   (%esi)
  801282:	e8 c0 fb ff ff       	call   800e47 <dev_lookup>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 31                	js     8012bf <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80128e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801291:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801295:	74 2f                	je     8012c6 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801297:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80129a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a1:	00 00 00 
	stat->st_isdir = 0;
  8012a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ab:	00 00 00 
	stat->st_dev = dev;
  8012ae:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	53                   	push   %ebx
  8012b8:	56                   	push   %esi
  8012b9:	ff 50 14             	call   *0x14(%eax)
  8012bc:	83 c4 10             	add    $0x10,%esp
}
  8012bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    
		return -E_NOT_SUPP;
  8012c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cb:	eb f2                	jmp    8012bf <fstat+0x67>

008012cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	56                   	push   %esi
  8012d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	6a 00                	push   $0x0
  8012d7:	ff 75 08             	push   0x8(%ebp)
  8012da:	e8 e4 01 00 00       	call   8014c3 <open>
  8012df:	89 c3                	mov    %eax,%ebx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 1b                	js     801303 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	ff 75 0c             	push   0xc(%ebp)
  8012ee:	50                   	push   %eax
  8012ef:	e8 64 ff ff ff       	call   801258 <fstat>
  8012f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f6:	89 1c 24             	mov    %ebx,(%esp)
  8012f9:	e8 26 fc ff ff       	call   800f24 <close>
	return r;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	89 f3                	mov    %esi,%ebx
}
  801303:	89 d8                	mov    %ebx,%eax
  801305:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801308:	5b                   	pop    %ebx
  801309:	5e                   	pop    %esi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	89 c6                	mov    %eax,%esi
  801313:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801315:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80131c:	74 27                	je     801345 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131e:	6a 07                	push   $0x7
  801320:	68 00 50 80 00       	push   $0x805000
  801325:	56                   	push   %esi
  801326:	ff 35 00 60 80 00    	push   0x806000
  80132c:	e8 13 0c 00 00       	call   801f44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801331:	83 c4 0c             	add    $0xc,%esp
  801334:	6a 00                	push   $0x0
  801336:	53                   	push   %ebx
  801337:	6a 00                	push   $0x0
  801339:	e8 96 0b 00 00       	call   801ed4 <ipc_recv>
}
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	6a 01                	push   $0x1
  80134a:	e8 49 0c 00 00       	call   801f98 <ipc_find_env>
  80134f:	a3 00 60 80 00       	mov    %eax,0x806000
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	eb c5                	jmp    80131e <fsipc+0x12>

00801359 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80135f:	8b 45 08             	mov    0x8(%ebp),%eax
  801362:	8b 40 0c             	mov    0xc(%eax),%eax
  801365:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80136a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	b8 02 00 00 00       	mov    $0x2,%eax
  80137c:	e8 8b ff ff ff       	call   80130c <fsipc>
}
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <devfile_flush>:
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
  80138c:	8b 40 0c             	mov    0xc(%eax),%eax
  80138f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801394:	ba 00 00 00 00       	mov    $0x0,%edx
  801399:	b8 06 00 00 00       	mov    $0x6,%eax
  80139e:	e8 69 ff ff ff       	call   80130c <fsipc>
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <devfile_stat>:
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c4:	e8 43 ff ff ff       	call   80130c <fsipc>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 2c                	js     8013f9 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	68 00 50 80 00       	push   $0x805000
  8013d5:	53                   	push   %ebx
  8013d6:	e8 57 f3 ff ff       	call   800732 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013db:	a1 80 50 80 00       	mov    0x805080,%eax
  8013e0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e6:	a1 84 50 80 00       	mov    0x805084,%eax
  8013eb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <devfile_write>:
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 0c             	sub    $0xc,%esp
  801404:	8b 45 10             	mov    0x10(%ebp),%eax
  801407:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80140c:	39 d0                	cmp    %edx,%eax
  80140e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801411:	8b 55 08             	mov    0x8(%ebp),%edx
  801414:	8b 52 0c             	mov    0xc(%edx),%edx
  801417:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80141d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801422:	50                   	push   %eax
  801423:	ff 75 0c             	push   0xc(%ebp)
  801426:	68 08 50 80 00       	push   $0x805008
  80142b:	e8 98 f4 ff ff       	call   8008c8 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801430:	ba 00 00 00 00       	mov    $0x0,%edx
  801435:	b8 04 00 00 00       	mov    $0x4,%eax
  80143a:	e8 cd fe ff ff       	call   80130c <fsipc>
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <devfile_read>:
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801449:	8b 45 08             	mov    0x8(%ebp),%eax
  80144c:	8b 40 0c             	mov    0xc(%eax),%eax
  80144f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801454:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 03 00 00 00       	mov    $0x3,%eax
  801464:	e8 a3 fe ff ff       	call   80130c <fsipc>
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 1f                	js     80148e <devfile_read+0x4d>
	assert(r <= n);
  80146f:	39 f0                	cmp    %esi,%eax
  801471:	77 24                	ja     801497 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801473:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801478:	7f 33                	jg     8014ad <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	50                   	push   %eax
  80147e:	68 00 50 80 00       	push   $0x805000
  801483:	ff 75 0c             	push   0xc(%ebp)
  801486:	e8 3d f4 ff ff       	call   8008c8 <memmove>
	return r;
  80148b:	83 c4 10             	add    $0x10,%esp
}
  80148e:	89 d8                	mov    %ebx,%eax
  801490:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    
	assert(r <= n);
  801497:	68 3c 26 80 00       	push   $0x80263c
  80149c:	68 43 26 80 00       	push   $0x802643
  8014a1:	6a 7c                	push   $0x7c
  8014a3:	68 58 26 80 00       	push   $0x802658
  8014a8:	e8 e1 09 00 00       	call   801e8e <_panic>
	assert(r <= PGSIZE);
  8014ad:	68 63 26 80 00       	push   $0x802663
  8014b2:	68 43 26 80 00       	push   $0x802643
  8014b7:	6a 7d                	push   $0x7d
  8014b9:	68 58 26 80 00       	push   $0x802658
  8014be:	e8 cb 09 00 00       	call   801e8e <_panic>

008014c3 <open>:
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 1c             	sub    $0x1c,%esp
  8014cb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014ce:	56                   	push   %esi
  8014cf:	e8 23 f2 ff ff       	call   8006f7 <strlen>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014dc:	7f 6c                	jg     80154a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e4:	50                   	push   %eax
  8014e5:	e8 bd f8 ff ff       	call   800da7 <fd_alloc>
  8014ea:	89 c3                	mov    %eax,%ebx
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 3c                	js     80152f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	56                   	push   %esi
  8014f7:	68 00 50 80 00       	push   $0x805000
  8014fc:	e8 31 f2 ff ff       	call   800732 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801509:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80150c:	b8 01 00 00 00       	mov    $0x1,%eax
  801511:	e8 f6 fd ff ff       	call   80130c <fsipc>
  801516:	89 c3                	mov    %eax,%ebx
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 19                	js     801538 <open+0x75>
	return fd2num(fd);
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	ff 75 f4             	push   -0xc(%ebp)
  801525:	e8 56 f8 ff ff       	call   800d80 <fd2num>
  80152a:	89 c3                	mov    %eax,%ebx
  80152c:	83 c4 10             	add    $0x10,%esp
}
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    
		fd_close(fd, 0);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	6a 00                	push   $0x0
  80153d:	ff 75 f4             	push   -0xc(%ebp)
  801540:	e8 58 f9 ff ff       	call   800e9d <fd_close>
		return r;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	eb e5                	jmp    80152f <open+0x6c>
		return -E_BAD_PATH;
  80154a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80154f:	eb de                	jmp    80152f <open+0x6c>

00801551 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801557:	ba 00 00 00 00       	mov    $0x0,%edx
  80155c:	b8 08 00 00 00       	mov    $0x8,%eax
  801561:	e8 a6 fd ff ff       	call   80130c <fsipc>
}
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80156e:	68 6f 26 80 00       	push   $0x80266f
  801573:	ff 75 0c             	push   0xc(%ebp)
  801576:	e8 b7 f1 ff ff       	call   800732 <strcpy>
	return 0;
}
  80157b:	b8 00 00 00 00       	mov    $0x0,%eax
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <devsock_close>:
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	53                   	push   %ebx
  801586:	83 ec 10             	sub    $0x10,%esp
  801589:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80158c:	53                   	push   %ebx
  80158d:	e8 45 0a 00 00       	call   801fd7 <pageref>
  801592:	89 c2                	mov    %eax,%edx
  801594:	83 c4 10             	add    $0x10,%esp
		return 0;
  801597:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80159c:	83 fa 01             	cmp    $0x1,%edx
  80159f:	74 05                	je     8015a6 <devsock_close+0x24>
}
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015a6:	83 ec 0c             	sub    $0xc,%esp
  8015a9:	ff 73 0c             	push   0xc(%ebx)
  8015ac:	e8 b7 02 00 00       	call   801868 <nsipc_close>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb eb                	jmp    8015a1 <devsock_close+0x1f>

008015b6 <devsock_write>:
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015bc:	6a 00                	push   $0x0
  8015be:	ff 75 10             	push   0x10(%ebp)
  8015c1:	ff 75 0c             	push   0xc(%ebp)
  8015c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c7:	ff 70 0c             	push   0xc(%eax)
  8015ca:	e8 79 03 00 00       	call   801948 <nsipc_send>
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <devsock_read>:
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015d7:	6a 00                	push   $0x0
  8015d9:	ff 75 10             	push   0x10(%ebp)
  8015dc:	ff 75 0c             	push   0xc(%ebp)
  8015df:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e2:	ff 70 0c             	push   0xc(%eax)
  8015e5:	e8 ef 02 00 00       	call   8018d9 <nsipc_recv>
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <fd2sockid>:
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015f2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015f5:	52                   	push   %edx
  8015f6:	50                   	push   %eax
  8015f7:	e8 fb f7 ff ff       	call   800df7 <fd_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 10                	js     801613 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801603:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801606:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80160c:	39 08                	cmp    %ecx,(%eax)
  80160e:	75 05                	jne    801615 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801610:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801613:	c9                   	leave  
  801614:	c3                   	ret    
		return -E_NOT_SUPP;
  801615:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161a:	eb f7                	jmp    801613 <fd2sockid+0x27>

0080161c <alloc_sockfd>:
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	56                   	push   %esi
  801620:	53                   	push   %ebx
  801621:	83 ec 1c             	sub    $0x1c,%esp
  801624:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801626:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	e8 78 f7 ff ff       	call   800da7 <fd_alloc>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 43                	js     80167b <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	68 07 04 00 00       	push   $0x407
  801640:	ff 75 f4             	push   -0xc(%ebp)
  801643:	6a 00                	push   $0x0
  801645:	e8 e4 f4 ff ff       	call   800b2e <sys_page_alloc>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 28                	js     80167b <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80165c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801668:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	50                   	push   %eax
  80166f:	e8 0c f7 ff ff       	call   800d80 <fd2num>
  801674:	89 c3                	mov    %eax,%ebx
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	eb 0c                	jmp    801687 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80167b:	83 ec 0c             	sub    $0xc,%esp
  80167e:	56                   	push   %esi
  80167f:	e8 e4 01 00 00       	call   801868 <nsipc_close>
		return r;
  801684:	83 c4 10             	add    $0x10,%esp
}
  801687:	89 d8                	mov    %ebx,%eax
  801689:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <accept>:
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	e8 4e ff ff ff       	call   8015ec <fd2sockid>
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 1b                	js     8016bd <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	ff 75 10             	push   0x10(%ebp)
  8016a8:	ff 75 0c             	push   0xc(%ebp)
  8016ab:	50                   	push   %eax
  8016ac:	e8 0e 01 00 00       	call   8017bf <nsipc_accept>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 05                	js     8016bd <accept+0x2d>
	return alloc_sockfd(r);
  8016b8:	e8 5f ff ff ff       	call   80161c <alloc_sockfd>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <bind>:
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	e8 1f ff ff ff       	call   8015ec <fd2sockid>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 12                	js     8016e3 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016d1:	83 ec 04             	sub    $0x4,%esp
  8016d4:	ff 75 10             	push   0x10(%ebp)
  8016d7:	ff 75 0c             	push   0xc(%ebp)
  8016da:	50                   	push   %eax
  8016db:	e8 31 01 00 00       	call   801811 <nsipc_bind>
  8016e0:	83 c4 10             	add    $0x10,%esp
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <shutdown>:
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	e8 f9 fe ff ff       	call   8015ec <fd2sockid>
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 0f                	js     801706 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	ff 75 0c             	push   0xc(%ebp)
  8016fd:	50                   	push   %eax
  8016fe:	e8 43 01 00 00       	call   801846 <nsipc_shutdown>
  801703:	83 c4 10             	add    $0x10,%esp
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <connect>:
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	e8 d6 fe ff ff       	call   8015ec <fd2sockid>
  801716:	85 c0                	test   %eax,%eax
  801718:	78 12                	js     80172c <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	ff 75 10             	push   0x10(%ebp)
  801720:	ff 75 0c             	push   0xc(%ebp)
  801723:	50                   	push   %eax
  801724:	e8 59 01 00 00       	call   801882 <nsipc_connect>
  801729:	83 c4 10             	add    $0x10,%esp
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <listen>:
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	e8 b0 fe ff ff       	call   8015ec <fd2sockid>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 0f                	js     80174f <listen+0x21>
	return nsipc_listen(r, backlog);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	ff 75 0c             	push   0xc(%ebp)
  801746:	50                   	push   %eax
  801747:	e8 6b 01 00 00       	call   8018b7 <nsipc_listen>
  80174c:	83 c4 10             	add    $0x10,%esp
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <socket>:

int
socket(int domain, int type, int protocol)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801757:	ff 75 10             	push   0x10(%ebp)
  80175a:	ff 75 0c             	push   0xc(%ebp)
  80175d:	ff 75 08             	push   0x8(%ebp)
  801760:	e8 41 02 00 00       	call   8019a6 <nsipc_socket>
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 05                	js     801771 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80176c:	e8 ab fe ff ff       	call   80161c <alloc_sockfd>
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80177c:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801783:	74 26                	je     8017ab <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801785:	6a 07                	push   $0x7
  801787:	68 00 70 80 00       	push   $0x807000
  80178c:	53                   	push   %ebx
  80178d:	ff 35 00 80 80 00    	push   0x808000
  801793:	e8 ac 07 00 00       	call   801f44 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801798:	83 c4 0c             	add    $0xc,%esp
  80179b:	6a 00                	push   $0x0
  80179d:	6a 00                	push   $0x0
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 2e 07 00 00       	call   801ed4 <ipc_recv>
}
  8017a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	6a 02                	push   $0x2
  8017b0:	e8 e3 07 00 00       	call   801f98 <ipc_find_env>
  8017b5:	a3 00 80 80 00       	mov    %eax,0x808000
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb c6                	jmp    801785 <nsipc+0x12>

008017bf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	56                   	push   %esi
  8017c3:	53                   	push   %ebx
  8017c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017cf:	8b 06                	mov    (%esi),%eax
  8017d1:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017db:	e8 93 ff ff ff       	call   801773 <nsipc>
  8017e0:	89 c3                	mov    %eax,%ebx
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	79 09                	jns    8017ef <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017e6:	89 d8                	mov    %ebx,%eax
  8017e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5e                   	pop    %esi
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ef:	83 ec 04             	sub    $0x4,%esp
  8017f2:	ff 35 10 70 80 00    	push   0x807010
  8017f8:	68 00 70 80 00       	push   $0x807000
  8017fd:	ff 75 0c             	push   0xc(%ebp)
  801800:	e8 c3 f0 ff ff       	call   8008c8 <memmove>
		*addrlen = ret->ret_addrlen;
  801805:	a1 10 70 80 00       	mov    0x807010,%eax
  80180a:	89 06                	mov    %eax,(%esi)
  80180c:	83 c4 10             	add    $0x10,%esp
	return r;
  80180f:	eb d5                	jmp    8017e6 <nsipc_accept+0x27>

00801811 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801823:	53                   	push   %ebx
  801824:	ff 75 0c             	push   0xc(%ebp)
  801827:	68 04 70 80 00       	push   $0x807004
  80182c:	e8 97 f0 ff ff       	call   8008c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801831:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801837:	b8 02 00 00 00       	mov    $0x2,%eax
  80183c:	e8 32 ff ff ff       	call   801773 <nsipc>
}
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801854:	8b 45 0c             	mov    0xc(%ebp),%eax
  801857:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80185c:	b8 03 00 00 00       	mov    $0x3,%eax
  801861:	e8 0d ff ff ff       	call   801773 <nsipc>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <nsipc_close>:

int
nsipc_close(int s)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801876:	b8 04 00 00 00       	mov    $0x4,%eax
  80187b:	e8 f3 fe ff ff       	call   801773 <nsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801894:	53                   	push   %ebx
  801895:	ff 75 0c             	push   0xc(%ebp)
  801898:	68 04 70 80 00       	push   $0x807004
  80189d:	e8 26 f0 ff ff       	call   8008c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018a2:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ad:	e8 c1 fe ff ff       	call   801773 <nsipc>
}
  8018b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d2:	e8 9c fe ff ff       	call   801773 <nsipc>
}
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018e9:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f2:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8018fc:	e8 72 fe ff ff       	call   801773 <nsipc>
  801901:	89 c3                	mov    %eax,%ebx
  801903:	85 c0                	test   %eax,%eax
  801905:	78 22                	js     801929 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801907:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80190c:	39 c6                	cmp    %eax,%esi
  80190e:	0f 4e c6             	cmovle %esi,%eax
  801911:	39 c3                	cmp    %eax,%ebx
  801913:	7f 1d                	jg     801932 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	53                   	push   %ebx
  801919:	68 00 70 80 00       	push   $0x807000
  80191e:	ff 75 0c             	push   0xc(%ebp)
  801921:	e8 a2 ef ff ff       	call   8008c8 <memmove>
  801926:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801929:	89 d8                	mov    %ebx,%eax
  80192b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801932:	68 7b 26 80 00       	push   $0x80267b
  801937:	68 43 26 80 00       	push   $0x802643
  80193c:	6a 62                	push   $0x62
  80193e:	68 90 26 80 00       	push   $0x802690
  801943:	e8 46 05 00 00       	call   801e8e <_panic>

00801948 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80195a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801960:	7f 2e                	jg     801990 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	53                   	push   %ebx
  801966:	ff 75 0c             	push   0xc(%ebp)
  801969:	68 0c 70 80 00       	push   $0x80700c
  80196e:	e8 55 ef ff ff       	call   8008c8 <memmove>
	nsipcbuf.send.req_size = size;
  801973:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801979:	8b 45 14             	mov    0x14(%ebp),%eax
  80197c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801981:	b8 08 00 00 00       	mov    $0x8,%eax
  801986:	e8 e8 fd ff ff       	call   801773 <nsipc>
}
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    
	assert(size < 1600);
  801990:	68 9c 26 80 00       	push   $0x80269c
  801995:	68 43 26 80 00       	push   $0x802643
  80199a:	6a 6d                	push   $0x6d
  80199c:	68 90 26 80 00       	push   $0x802690
  8019a1:	e8 e8 04 00 00       	call   801e8e <_panic>

008019a6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8019c9:	e8 a5 fd ff ff       	call   801773 <nsipc>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 08             	push   0x8(%ebp)
  8019de:	e8 ad f3 ff ff       	call   800d90 <fd2data>
  8019e3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e5:	83 c4 08             	add    $0x8,%esp
  8019e8:	68 a8 26 80 00       	push   $0x8026a8
  8019ed:	53                   	push   %ebx
  8019ee:	e8 3f ed ff ff       	call   800732 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f3:	8b 46 04             	mov    0x4(%esi),%eax
  8019f6:	2b 06                	sub    (%esi),%eax
  8019f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a05:	00 00 00 
	stat->st_dev = &devpipe;
  801a08:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a0f:	30 80 00 
	return 0;
}
  801a12:	b8 00 00 00 00       	mov    $0x0,%eax
  801a17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	53                   	push   %ebx
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a28:	53                   	push   %ebx
  801a29:	6a 00                	push   $0x0
  801a2b:	e8 83 f1 ff ff       	call   800bb3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 58 f3 ff ff       	call   800d90 <fd2data>
  801a38:	83 c4 08             	add    $0x8,%esp
  801a3b:	50                   	push   %eax
  801a3c:	6a 00                	push   $0x0
  801a3e:	e8 70 f1 ff ff       	call   800bb3 <sys_page_unmap>
}
  801a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <_pipeisclosed>:
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	57                   	push   %edi
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 1c             	sub    $0x1c,%esp
  801a51:	89 c7                	mov    %eax,%edi
  801a53:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a55:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5a:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a5d:	83 ec 0c             	sub    $0xc,%esp
  801a60:	57                   	push   %edi
  801a61:	e8 71 05 00 00       	call   801fd7 <pageref>
  801a66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a69:	89 34 24             	mov    %esi,(%esp)
  801a6c:	e8 66 05 00 00       	call   801fd7 <pageref>
		nn = thisenv->env_runs;
  801a71:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a77:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	39 cb                	cmp    %ecx,%ebx
  801a7f:	74 1b                	je     801a9c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a81:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a84:	75 cf                	jne    801a55 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a86:	8b 42 68             	mov    0x68(%edx),%eax
  801a89:	6a 01                	push   $0x1
  801a8b:	50                   	push   %eax
  801a8c:	53                   	push   %ebx
  801a8d:	68 af 26 80 00       	push   $0x8026af
  801a92:	e8 c1 e6 ff ff       	call   800158 <cprintf>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	eb b9                	jmp    801a55 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a9c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a9f:	0f 94 c0             	sete   %al
  801aa2:	0f b6 c0             	movzbl %al,%eax
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <devpipe_write>:
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	57                   	push   %edi
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 28             	sub    $0x28,%esp
  801ab6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ab9:	56                   	push   %esi
  801aba:	e8 d1 f2 ff ff       	call   800d90 <fd2data>
  801abf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801acc:	75 09                	jne    801ad7 <devpipe_write+0x2a>
	return i;
  801ace:	89 f8                	mov    %edi,%eax
  801ad0:	eb 23                	jmp    801af5 <devpipe_write+0x48>
			sys_yield();
  801ad2:	e8 38 f0 ff ff       	call   800b0f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad7:	8b 43 04             	mov    0x4(%ebx),%eax
  801ada:	8b 0b                	mov    (%ebx),%ecx
  801adc:	8d 51 20             	lea    0x20(%ecx),%edx
  801adf:	39 d0                	cmp    %edx,%eax
  801ae1:	72 1a                	jb     801afd <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ae3:	89 da                	mov    %ebx,%edx
  801ae5:	89 f0                	mov    %esi,%eax
  801ae7:	e8 5c ff ff ff       	call   801a48 <_pipeisclosed>
  801aec:	85 c0                	test   %eax,%eax
  801aee:	74 e2                	je     801ad2 <devpipe_write+0x25>
				return 0;
  801af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5f                   	pop    %edi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b00:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b04:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b07:	89 c2                	mov    %eax,%edx
  801b09:	c1 fa 1f             	sar    $0x1f,%edx
  801b0c:	89 d1                	mov    %edx,%ecx
  801b0e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b11:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b14:	83 e2 1f             	and    $0x1f,%edx
  801b17:	29 ca                	sub    %ecx,%edx
  801b19:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b1d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b21:	83 c0 01             	add    $0x1,%eax
  801b24:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b27:	83 c7 01             	add    $0x1,%edi
  801b2a:	eb 9d                	jmp    801ac9 <devpipe_write+0x1c>

00801b2c <devpipe_read>:
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 18             	sub    $0x18,%esp
  801b35:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b38:	57                   	push   %edi
  801b39:	e8 52 f2 ff ff       	call   800d90 <fd2data>
  801b3e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	be 00 00 00 00       	mov    $0x0,%esi
  801b48:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b4b:	75 13                	jne    801b60 <devpipe_read+0x34>
	return i;
  801b4d:	89 f0                	mov    %esi,%eax
  801b4f:	eb 02                	jmp    801b53 <devpipe_read+0x27>
				return i;
  801b51:	89 f0                	mov    %esi,%eax
}
  801b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5e                   	pop    %esi
  801b58:	5f                   	pop    %edi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    
			sys_yield();
  801b5b:	e8 af ef ff ff       	call   800b0f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b60:	8b 03                	mov    (%ebx),%eax
  801b62:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b65:	75 18                	jne    801b7f <devpipe_read+0x53>
			if (i > 0)
  801b67:	85 f6                	test   %esi,%esi
  801b69:	75 e6                	jne    801b51 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b6b:	89 da                	mov    %ebx,%edx
  801b6d:	89 f8                	mov    %edi,%eax
  801b6f:	e8 d4 fe ff ff       	call   801a48 <_pipeisclosed>
  801b74:	85 c0                	test   %eax,%eax
  801b76:	74 e3                	je     801b5b <devpipe_read+0x2f>
				return 0;
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7d:	eb d4                	jmp    801b53 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7f:	99                   	cltd   
  801b80:	c1 ea 1b             	shr    $0x1b,%edx
  801b83:	01 d0                	add    %edx,%eax
  801b85:	83 e0 1f             	and    $0x1f,%eax
  801b88:	29 d0                	sub    %edx,%eax
  801b8a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b92:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b95:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b98:	83 c6 01             	add    $0x1,%esi
  801b9b:	eb ab                	jmp    801b48 <devpipe_read+0x1c>

00801b9d <pipe>:
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 f9 f1 ff ff       	call   800da7 <fd_alloc>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	0f 88 23 01 00 00    	js     801cde <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbb:	83 ec 04             	sub    $0x4,%esp
  801bbe:	68 07 04 00 00       	push   $0x407
  801bc3:	ff 75 f4             	push   -0xc(%ebp)
  801bc6:	6a 00                	push   $0x0
  801bc8:	e8 61 ef ff ff       	call   800b2e <sys_page_alloc>
  801bcd:	89 c3                	mov    %eax,%ebx
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	0f 88 04 01 00 00    	js     801cde <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bda:	83 ec 0c             	sub    $0xc,%esp
  801bdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	e8 c1 f1 ff ff       	call   800da7 <fd_alloc>
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	85 c0                	test   %eax,%eax
  801bed:	0f 88 db 00 00 00    	js     801cce <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	68 07 04 00 00       	push   $0x407
  801bfb:	ff 75 f0             	push   -0x10(%ebp)
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 29 ef ff ff       	call   800b2e <sys_page_alloc>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	0f 88 bc 00 00 00    	js     801cce <pipe+0x131>
	va = fd2data(fd0);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	ff 75 f4             	push   -0xc(%ebp)
  801c18:	e8 73 f1 ff ff       	call   800d90 <fd2data>
  801c1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1f:	83 c4 0c             	add    $0xc,%esp
  801c22:	68 07 04 00 00       	push   $0x407
  801c27:	50                   	push   %eax
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 ff ee ff ff       	call   800b2e <sys_page_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 82 00 00 00    	js     801cbe <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	ff 75 f0             	push   -0x10(%ebp)
  801c42:	e8 49 f1 ff ff       	call   800d90 <fd2data>
  801c47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4e:	50                   	push   %eax
  801c4f:	6a 00                	push   $0x0
  801c51:	56                   	push   %esi
  801c52:	6a 00                	push   $0x0
  801c54:	e8 18 ef ff ff       	call   800b71 <sys_page_map>
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	83 c4 20             	add    $0x20,%esp
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	78 4e                	js     801cb0 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c62:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c79:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	ff 75 f4             	push   -0xc(%ebp)
  801c8b:	e8 f0 f0 ff ff       	call   800d80 <fd2num>
  801c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c95:	83 c4 04             	add    $0x4,%esp
  801c98:	ff 75 f0             	push   -0x10(%ebp)
  801c9b:	e8 e0 f0 ff ff       	call   800d80 <fd2num>
  801ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cae:	eb 2e                	jmp    801cde <pipe+0x141>
	sys_page_unmap(0, va);
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	56                   	push   %esi
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 f8 ee ff ff       	call   800bb3 <sys_page_unmap>
  801cbb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	ff 75 f0             	push   -0x10(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 e8 ee ff ff       	call   800bb3 <sys_page_unmap>
  801ccb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cce:	83 ec 08             	sub    $0x8,%esp
  801cd1:	ff 75 f4             	push   -0xc(%ebp)
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 d8 ee ff ff       	call   800bb3 <sys_page_unmap>
  801cdb:	83 c4 10             	add    $0x10,%esp
}
  801cde:	89 d8                	mov    %ebx,%eax
  801ce0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <pipeisclosed>:
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ced:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf0:	50                   	push   %eax
  801cf1:	ff 75 08             	push   0x8(%ebp)
  801cf4:	e8 fe f0 ff ff       	call   800df7 <fd_lookup>
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 18                	js     801d18 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d00:	83 ec 0c             	sub    $0xc,%esp
  801d03:	ff 75 f4             	push   -0xc(%ebp)
  801d06:	e8 85 f0 ff ff       	call   800d90 <fd2data>
  801d0b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d10:	e8 33 fd ff ff       	call   801a48 <_pipeisclosed>
  801d15:	83 c4 10             	add    $0x10,%esp
}
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1f:	c3                   	ret    

00801d20 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d26:	68 c7 26 80 00       	push   $0x8026c7
  801d2b:	ff 75 0c             	push   0xc(%ebp)
  801d2e:	e8 ff e9 ff ff       	call   800732 <strcpy>
	return 0;
}
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <devcons_write>:
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	57                   	push   %edi
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d46:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d4b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d51:	eb 2e                	jmp    801d81 <devcons_write+0x47>
		m = n - tot;
  801d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d56:	29 f3                	sub    %esi,%ebx
  801d58:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d5d:	39 c3                	cmp    %eax,%ebx
  801d5f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d62:	83 ec 04             	sub    $0x4,%esp
  801d65:	53                   	push   %ebx
  801d66:	89 f0                	mov    %esi,%eax
  801d68:	03 45 0c             	add    0xc(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	57                   	push   %edi
  801d6d:	e8 56 eb ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801d72:	83 c4 08             	add    $0x8,%esp
  801d75:	53                   	push   %ebx
  801d76:	57                   	push   %edi
  801d77:	e8 f6 ec ff ff       	call   800a72 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d7c:	01 de                	add    %ebx,%esi
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d84:	72 cd                	jb     801d53 <devcons_write+0x19>
}
  801d86:	89 f0                	mov    %esi,%eax
  801d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <devcons_read>:
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9f:	75 07                	jne    801da8 <devcons_read+0x18>
  801da1:	eb 1f                	jmp    801dc2 <devcons_read+0x32>
		sys_yield();
  801da3:	e8 67 ed ff ff       	call   800b0f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801da8:	e8 e3 ec ff ff       	call   800a90 <sys_cgetc>
  801dad:	85 c0                	test   %eax,%eax
  801daf:	74 f2                	je     801da3 <devcons_read+0x13>
	if (c < 0)
  801db1:	78 0f                	js     801dc2 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801db3:	83 f8 04             	cmp    $0x4,%eax
  801db6:	74 0c                	je     801dc4 <devcons_read+0x34>
	*(char*)vbuf = c;
  801db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbb:	88 02                	mov    %al,(%edx)
	return 1;
  801dbd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    
		return 0;
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	eb f7                	jmp    801dc2 <devcons_read+0x32>

00801dcb <cputchar>:
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dd7:	6a 01                	push   $0x1
  801dd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	e8 90 ec ff ff       	call   800a72 <sys_cputs>
}
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <getchar>:
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ded:	6a 01                	push   $0x1
  801def:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	6a 00                	push   $0x0
  801df5:	e8 66 f2 ff ff       	call   801060 <read>
	if (r < 0)
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 06                	js     801e07 <getchar+0x20>
	if (r < 1)
  801e01:	74 06                	je     801e09 <getchar+0x22>
	return c;
  801e03:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    
		return -E_EOF;
  801e09:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e0e:	eb f7                	jmp    801e07 <getchar+0x20>

00801e10 <iscons>:
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e19:	50                   	push   %eax
  801e1a:	ff 75 08             	push   0x8(%ebp)
  801e1d:	e8 d5 ef ff ff       	call   800df7 <fd_lookup>
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 11                	js     801e3a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e32:	39 10                	cmp    %edx,(%eax)
  801e34:	0f 94 c0             	sete   %al
  801e37:	0f b6 c0             	movzbl %al,%eax
}
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <opencons>:
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e45:	50                   	push   %eax
  801e46:	e8 5c ef ff ff       	call   800da7 <fd_alloc>
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 3a                	js     801e8c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e52:	83 ec 04             	sub    $0x4,%esp
  801e55:	68 07 04 00 00       	push   $0x407
  801e5a:	ff 75 f4             	push   -0xc(%ebp)
  801e5d:	6a 00                	push   $0x0
  801e5f:	e8 ca ec ff ff       	call   800b2e <sys_page_alloc>
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 21                	js     801e8c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e74:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e79:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	50                   	push   %eax
  801e84:	e8 f7 ee ff ff       	call   800d80 <fd2num>
  801e89:	83 c4 10             	add    $0x10,%esp
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	56                   	push   %esi
  801e92:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e96:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e9c:	e8 4f ec ff ff       	call   800af0 <sys_getenvid>
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	ff 75 0c             	push   0xc(%ebp)
  801ea7:	ff 75 08             	push   0x8(%ebp)
  801eaa:	56                   	push   %esi
  801eab:	50                   	push   %eax
  801eac:	68 d4 26 80 00       	push   $0x8026d4
  801eb1:	e8 a2 e2 ff ff       	call   800158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eb6:	83 c4 18             	add    $0x18,%esp
  801eb9:	53                   	push   %ebx
  801eba:	ff 75 10             	push   0x10(%ebp)
  801ebd:	e8 45 e2 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  801ec2:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  801ec9:	e8 8a e2 ff ff       	call   800158 <cprintf>
  801ece:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ed1:	cc                   	int3   
  801ed2:	eb fd                	jmp    801ed1 <_panic+0x43>

00801ed4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	8b 75 08             	mov    0x8(%ebp),%esi
  801edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee9:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	50                   	push   %eax
  801ef0:	e8 e9 ed ff ff       	call   800cde <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	85 f6                	test   %esi,%esi
  801efa:	74 17                	je     801f13 <ipc_recv+0x3f>
  801efc:	ba 00 00 00 00       	mov    $0x0,%edx
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 0c                	js     801f11 <ipc_recv+0x3d>
  801f05:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f0b:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f11:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f13:	85 db                	test   %ebx,%ebx
  801f15:	74 17                	je     801f2e <ipc_recv+0x5a>
  801f17:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 0c                	js     801f2c <ipc_recv+0x58>
  801f20:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f26:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f2c:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 0b                	js     801f3d <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f32:	a1 04 40 80 00       	mov    0x804004,%eax
  801f37:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	57                   	push   %edi
  801f48:	56                   	push   %esi
  801f49:	53                   	push   %ebx
  801f4a:	83 ec 0c             	sub    $0xc,%esp
  801f4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f56:	85 db                	test   %ebx,%ebx
  801f58:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f5d:	0f 44 d8             	cmove  %eax,%ebx
  801f60:	eb 05                	jmp    801f67 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f62:	e8 a8 eb ff ff       	call   800b0f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f67:	ff 75 14             	push   0x14(%ebp)
  801f6a:	53                   	push   %ebx
  801f6b:	56                   	push   %esi
  801f6c:	57                   	push   %edi
  801f6d:	e8 49 ed ff ff       	call   800cbb <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f78:	74 e8                	je     801f62 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	78 08                	js     801f86 <ipc_send+0x42>
	}while (r<0);

}
  801f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f86:	50                   	push   %eax
  801f87:	68 f7 26 80 00       	push   $0x8026f7
  801f8c:	6a 3d                	push   $0x3d
  801f8e:	68 0b 27 80 00       	push   $0x80270b
  801f93:	e8 f6 fe ff ff       	call   801e8e <_panic>

00801f98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa3:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801fa9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801faf:	8b 52 60             	mov    0x60(%edx),%edx
  801fb2:	39 ca                	cmp    %ecx,%edx
  801fb4:	74 11                	je     801fc7 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fb6:	83 c0 01             	add    $0x1,%eax
  801fb9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbe:	75 e3                	jne    801fa3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc5:	eb 0e                	jmp    801fd5 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fc7:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fcd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd2:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdd:	89 c2                	mov    %eax,%edx
  801fdf:	c1 ea 16             	shr    $0x16,%edx
  801fe2:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fe9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fee:	f6 c1 01             	test   $0x1,%cl
  801ff1:	74 1c                	je     80200f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ff3:	c1 e8 0c             	shr    $0xc,%eax
  801ff6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ffd:	a8 01                	test   $0x1,%al
  801fff:	74 0e                	je     80200f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802001:	c1 e8 0c             	shr    $0xc,%eax
  802004:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80200b:	ef 
  80200c:	0f b7 d2             	movzwl %dx,%edx
}
  80200f:	89 d0                	mov    %edx,%eax
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    
  802013:	66 90                	xchg   %ax,%ax
  802015:	66 90                	xchg   %ax,%ax
  802017:	66 90                	xchg   %ax,%ax
  802019:	66 90                	xchg   %ax,%ax
  80201b:	66 90                	xchg   %ax,%ax
  80201d:	66 90                	xchg   %ax,%ax
  80201f:	90                   	nop

00802020 <__udivdi3>:
  802020:	f3 0f 1e fb          	endbr32 
  802024:	55                   	push   %ebp
  802025:	57                   	push   %edi
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 1c             	sub    $0x1c,%esp
  80202b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80202f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802033:	8b 74 24 34          	mov    0x34(%esp),%esi
  802037:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80203b:	85 c0                	test   %eax,%eax
  80203d:	75 19                	jne    802058 <__udivdi3+0x38>
  80203f:	39 f3                	cmp    %esi,%ebx
  802041:	76 4d                	jbe    802090 <__udivdi3+0x70>
  802043:	31 ff                	xor    %edi,%edi
  802045:	89 e8                	mov    %ebp,%eax
  802047:	89 f2                	mov    %esi,%edx
  802049:	f7 f3                	div    %ebx
  80204b:	89 fa                	mov    %edi,%edx
  80204d:	83 c4 1c             	add    $0x1c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    
  802055:	8d 76 00             	lea    0x0(%esi),%esi
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	76 14                	jbe    802070 <__udivdi3+0x50>
  80205c:	31 ff                	xor    %edi,%edi
  80205e:	31 c0                	xor    %eax,%eax
  802060:	89 fa                	mov    %edi,%edx
  802062:	83 c4 1c             	add    $0x1c,%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	0f bd f8             	bsr    %eax,%edi
  802073:	83 f7 1f             	xor    $0x1f,%edi
  802076:	75 48                	jne    8020c0 <__udivdi3+0xa0>
  802078:	39 f0                	cmp    %esi,%eax
  80207a:	72 06                	jb     802082 <__udivdi3+0x62>
  80207c:	31 c0                	xor    %eax,%eax
  80207e:	39 eb                	cmp    %ebp,%ebx
  802080:	77 de                	ja     802060 <__udivdi3+0x40>
  802082:	b8 01 00 00 00       	mov    $0x1,%eax
  802087:	eb d7                	jmp    802060 <__udivdi3+0x40>
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d9                	mov    %ebx,%ecx
  802092:	85 db                	test   %ebx,%ebx
  802094:	75 0b                	jne    8020a1 <__udivdi3+0x81>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f3                	div    %ebx
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	89 f0                	mov    %esi,%eax
  8020a5:	f7 f1                	div    %ecx
  8020a7:	89 c6                	mov    %eax,%esi
  8020a9:	89 e8                	mov    %ebp,%eax
  8020ab:	89 f7                	mov    %esi,%edi
  8020ad:	f7 f1                	div    %ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 f9                	mov    %edi,%ecx
  8020c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020c7:	29 fa                	sub    %edi,%edx
  8020c9:	d3 e0                	shl    %cl,%eax
  8020cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020cf:	89 d1                	mov    %edx,%ecx
  8020d1:	89 d8                	mov    %ebx,%eax
  8020d3:	d3 e8                	shr    %cl,%eax
  8020d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020d9:	09 c1                	or     %eax,%ecx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e3                	shl    %cl,%ebx
  8020e5:	89 d1                	mov    %edx,%ecx
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	89 f9                	mov    %edi,%ecx
  8020eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ef:	89 eb                	mov    %ebp,%ebx
  8020f1:	d3 e6                	shl    %cl,%esi
  8020f3:	89 d1                	mov    %edx,%ecx
  8020f5:	d3 eb                	shr    %cl,%ebx
  8020f7:	09 f3                	or     %esi,%ebx
  8020f9:	89 c6                	mov    %eax,%esi
  8020fb:	89 f2                	mov    %esi,%edx
  8020fd:	89 d8                	mov    %ebx,%eax
  8020ff:	f7 74 24 08          	divl   0x8(%esp)
  802103:	89 d6                	mov    %edx,%esi
  802105:	89 c3                	mov    %eax,%ebx
  802107:	f7 64 24 0c          	mull   0xc(%esp)
  80210b:	39 d6                	cmp    %edx,%esi
  80210d:	72 19                	jb     802128 <__udivdi3+0x108>
  80210f:	89 f9                	mov    %edi,%ecx
  802111:	d3 e5                	shl    %cl,%ebp
  802113:	39 c5                	cmp    %eax,%ebp
  802115:	73 04                	jae    80211b <__udivdi3+0xfb>
  802117:	39 d6                	cmp    %edx,%esi
  802119:	74 0d                	je     802128 <__udivdi3+0x108>
  80211b:	89 d8                	mov    %ebx,%eax
  80211d:	31 ff                	xor    %edi,%edi
  80211f:	e9 3c ff ff ff       	jmp    802060 <__udivdi3+0x40>
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80212b:	31 ff                	xor    %edi,%edi
  80212d:	e9 2e ff ff ff       	jmp    802060 <__udivdi3+0x40>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	f3 0f 1e fb          	endbr32 
  802144:	55                   	push   %ebp
  802145:	57                   	push   %edi
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	83 ec 1c             	sub    $0x1c,%esp
  80214b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80214f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802153:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802157:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	89 da                	mov    %ebx,%edx
  80215f:	85 ff                	test   %edi,%edi
  802161:	75 15                	jne    802178 <__umoddi3+0x38>
  802163:	39 dd                	cmp    %ebx,%ebp
  802165:	76 39                	jbe    8021a0 <__umoddi3+0x60>
  802167:	f7 f5                	div    %ebp
  802169:	89 d0                	mov    %edx,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	83 c4 1c             	add    $0x1c,%esp
  802170:	5b                   	pop    %ebx
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	77 f1                	ja     80216d <__umoddi3+0x2d>
  80217c:	0f bd cf             	bsr    %edi,%ecx
  80217f:	83 f1 1f             	xor    $0x1f,%ecx
  802182:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802186:	75 40                	jne    8021c8 <__umoddi3+0x88>
  802188:	39 df                	cmp    %ebx,%edi
  80218a:	72 04                	jb     802190 <__umoddi3+0x50>
  80218c:	39 f5                	cmp    %esi,%ebp
  80218e:	77 dd                	ja     80216d <__umoddi3+0x2d>
  802190:	89 da                	mov    %ebx,%edx
  802192:	89 f0                	mov    %esi,%eax
  802194:	29 e8                	sub    %ebp,%eax
  802196:	19 fa                	sbb    %edi,%edx
  802198:	eb d3                	jmp    80216d <__umoddi3+0x2d>
  80219a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a0:	89 e9                	mov    %ebp,%ecx
  8021a2:	85 ed                	test   %ebp,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x71>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f5                	div    %ebp
  8021af:	89 c1                	mov    %eax,%ecx
  8021b1:	89 d8                	mov    %ebx,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f1                	div    %ecx
  8021b7:	89 f0                	mov    %esi,%eax
  8021b9:	f7 f1                	div    %ecx
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	31 d2                	xor    %edx,%edx
  8021bf:	eb ac                	jmp    80216d <__umoddi3+0x2d>
  8021c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021d1:	29 c2                	sub    %eax,%edx
  8021d3:	89 c1                	mov    %eax,%ecx
  8021d5:	89 e8                	mov    %ebp,%eax
  8021d7:	d3 e7                	shl    %cl,%edi
  8021d9:	89 d1                	mov    %edx,%ecx
  8021db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021df:	d3 e8                	shr    %cl,%eax
  8021e1:	89 c1                	mov    %eax,%ecx
  8021e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021e7:	09 f9                	or     %edi,%ecx
  8021e9:	89 df                	mov    %ebx,%edi
  8021eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ef:	89 c1                	mov    %eax,%ecx
  8021f1:	d3 e5                	shl    %cl,%ebp
  8021f3:	89 d1                	mov    %edx,%ecx
  8021f5:	d3 ef                	shr    %cl,%edi
  8021f7:	89 c1                	mov    %eax,%ecx
  8021f9:	89 f0                	mov    %esi,%eax
  8021fb:	d3 e3                	shl    %cl,%ebx
  8021fd:	89 d1                	mov    %edx,%ecx
  8021ff:	89 fa                	mov    %edi,%edx
  802201:	d3 e8                	shr    %cl,%eax
  802203:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802208:	09 d8                	or     %ebx,%eax
  80220a:	f7 74 24 08          	divl   0x8(%esp)
  80220e:	89 d3                	mov    %edx,%ebx
  802210:	d3 e6                	shl    %cl,%esi
  802212:	f7 e5                	mul    %ebp
  802214:	89 c7                	mov    %eax,%edi
  802216:	89 d1                	mov    %edx,%ecx
  802218:	39 d3                	cmp    %edx,%ebx
  80221a:	72 06                	jb     802222 <__umoddi3+0xe2>
  80221c:	75 0e                	jne    80222c <__umoddi3+0xec>
  80221e:	39 c6                	cmp    %eax,%esi
  802220:	73 0a                	jae    80222c <__umoddi3+0xec>
  802222:	29 e8                	sub    %ebp,%eax
  802224:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802228:	89 d1                	mov    %edx,%ecx
  80222a:	89 c7                	mov    %eax,%edi
  80222c:	89 f5                	mov    %esi,%ebp
  80222e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802232:	29 fd                	sub    %edi,%ebp
  802234:	19 cb                	sbb    %ecx,%ebx
  802236:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80223b:	89 d8                	mov    %ebx,%eax
  80223d:	d3 e0                	shl    %cl,%eax
  80223f:	89 f1                	mov    %esi,%ecx
  802241:	d3 ed                	shr    %cl,%ebp
  802243:	d3 eb                	shr    %cl,%ebx
  802245:	09 e8                	or     %ebp,%eax
  802247:	89 da                	mov    %ebx,%edx
  802249:	83 c4 1c             	add    $0x1c,%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5e                   	pop    %esi
  80224e:	5f                   	pop    %edi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    
