
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 0f 80 00       	push   $0x800f60
  80003e:	e8 08 01 00 00       	call   80014b <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 0f 80 00       	push   $0x800f6e
  800054:	e8 f2 00 00 00       	call   80014b <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 75 0a 00 00       	call   800ae3 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 f1 09 00 00       	call   800aa2 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	74 09                	je     8000de <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	68 ff 00 00 00       	push   $0xff
  8000e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	e8 76 09 00 00       	call   800a65 <sys_cputs>
		b->idx = 0;
  8000ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	eb db                	jmp    8000d5 <putch+0x1f>

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	push   0xc(%ebp)
  80011a:	ff 75 08             	push   0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b6 00 80 00       	push   $0x8000b6
  800129:	e8 14 01 00 00       	call   800242 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 22 09 00 00       	call   800a65 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	push   0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 c2                	mov    %eax,%edx
  800176:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800179:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800182:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800185:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80018c:	39 c2                	cmp    %eax,%edx
  80018e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800191:	72 3e                	jb     8001d1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	ff 75 18             	push   0x18(%ebp)
  800199:	83 eb 01             	sub    $0x1,%ebx
  80019c:	53                   	push   %ebx
  80019d:	50                   	push   %eax
  80019e:	83 ec 08             	sub    $0x8,%esp
  8001a1:	ff 75 e4             	push   -0x1c(%ebp)
  8001a4:	ff 75 e0             	push   -0x20(%ebp)
  8001a7:	ff 75 dc             	push   -0x24(%ebp)
  8001aa:	ff 75 d8             	push   -0x28(%ebp)
  8001ad:	e8 6e 0b 00 00       	call   800d20 <__udivdi3>
  8001b2:	83 c4 18             	add    $0x18,%esp
  8001b5:	52                   	push   %edx
  8001b6:	50                   	push   %eax
  8001b7:	89 f2                	mov    %esi,%edx
  8001b9:	89 f8                	mov    %edi,%eax
  8001bb:	e8 9f ff ff ff       	call   80015f <printnum>
  8001c0:	83 c4 20             	add    $0x20,%esp
  8001c3:	eb 13                	jmp    8001d8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	56                   	push   %esi
  8001c9:	ff 75 18             	push   0x18(%ebp)
  8001cc:	ff d7                	call   *%edi
  8001ce:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d1:	83 eb 01             	sub    $0x1,%ebx
  8001d4:	85 db                	test   %ebx,%ebx
  8001d6:	7f ed                	jg     8001c5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d8:	83 ec 08             	sub    $0x8,%esp
  8001db:	56                   	push   %esi
  8001dc:	83 ec 04             	sub    $0x4,%esp
  8001df:	ff 75 e4             	push   -0x1c(%ebp)
  8001e2:	ff 75 e0             	push   -0x20(%ebp)
  8001e5:	ff 75 dc             	push   -0x24(%ebp)
  8001e8:	ff 75 d8             	push   -0x28(%ebp)
  8001eb:	e8 50 0c 00 00       	call   800e40 <__umoddi3>
  8001f0:	83 c4 14             	add    $0x14,%esp
  8001f3:	0f be 80 8f 0f 80 00 	movsbl 0x800f8f(%eax),%eax
  8001fa:	50                   	push   %eax
  8001fb:	ff d7                	call   *%edi
}
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5f                   	pop    %edi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    

00800208 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800212:	8b 10                	mov    (%eax),%edx
  800214:	3b 50 04             	cmp    0x4(%eax),%edx
  800217:	73 0a                	jae    800223 <sprintputch+0x1b>
		*b->buf++ = ch;
  800219:	8d 4a 01             	lea    0x1(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	88 02                	mov    %al,(%edx)
}
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <printfmt>:
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80022b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022e:	50                   	push   %eax
  80022f:	ff 75 10             	push   0x10(%ebp)
  800232:	ff 75 0c             	push   0xc(%ebp)
  800235:	ff 75 08             	push   0x8(%ebp)
  800238:	e8 05 00 00 00       	call   800242 <vprintfmt>
}
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <vprintfmt>:
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	57                   	push   %edi
  800246:	56                   	push   %esi
  800247:	53                   	push   %ebx
  800248:	83 ec 3c             	sub    $0x3c,%esp
  80024b:	8b 75 08             	mov    0x8(%ebp),%esi
  80024e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800251:	8b 7d 10             	mov    0x10(%ebp),%edi
  800254:	eb 0a                	jmp    800260 <vprintfmt+0x1e>
			putch(ch, putdat);
  800256:	83 ec 08             	sub    $0x8,%esp
  800259:	53                   	push   %ebx
  80025a:	50                   	push   %eax
  80025b:	ff d6                	call   *%esi
  80025d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800260:	83 c7 01             	add    $0x1,%edi
  800263:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800267:	83 f8 25             	cmp    $0x25,%eax
  80026a:	74 0c                	je     800278 <vprintfmt+0x36>
			if (ch == '\0')
  80026c:	85 c0                	test   %eax,%eax
  80026e:	75 e6                	jne    800256 <vprintfmt+0x14>
}
  800270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    
		padc = ' ';
  800278:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80027c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800283:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80028a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800291:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800296:	8d 47 01             	lea    0x1(%edi),%eax
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	0f b6 17             	movzbl (%edi),%edx
  80029f:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a2:	3c 55                	cmp    $0x55,%al
  8002a4:	0f 87 bb 03 00 00    	ja     800665 <vprintfmt+0x423>
  8002aa:	0f b6 c0             	movzbl %al,%eax
  8002ad:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  8002b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002bb:	eb d9                	jmp    800296 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002c4:	eb d0                	jmp    800296 <vprintfmt+0x54>
  8002c6:	0f b6 d2             	movzbl %dl,%edx
  8002c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002db:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002de:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e1:	83 f9 09             	cmp    $0x9,%ecx
  8002e4:	77 55                	ja     80033b <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e9:	eb e9                	jmp    8002d4 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8d 40 04             	lea    0x4(%eax),%eax
  8002f9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800303:	79 91                	jns    800296 <vprintfmt+0x54>
				width = precision, precision = -1;
  800305:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800308:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800312:	eb 82                	jmp    800296 <vprintfmt+0x54>
  800314:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800317:	85 d2                	test   %edx,%edx
  800319:	b8 00 00 00 00       	mov    $0x0,%eax
  80031e:	0f 49 c2             	cmovns %edx,%eax
  800321:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800327:	e9 6a ff ff ff       	jmp    800296 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80032f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800336:	e9 5b ff ff ff       	jmp    800296 <vprintfmt+0x54>
  80033b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800341:	eb bc                	jmp    8002ff <vprintfmt+0xbd>
			lflag++;
  800343:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800349:	e9 48 ff ff ff       	jmp    800296 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	8d 78 04             	lea    0x4(%eax),%edi
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	53                   	push   %ebx
  800358:	ff 30                	push   (%eax)
  80035a:	ff d6                	call   *%esi
			break;
  80035c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80035f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800362:	e9 9d 02 00 00       	jmp    800604 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 78 04             	lea    0x4(%eax),%edi
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	89 d0                	mov    %edx,%eax
  800371:	f7 d8                	neg    %eax
  800373:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800376:	83 f8 08             	cmp    $0x8,%eax
  800379:	7f 23                	jg     80039e <vprintfmt+0x15c>
  80037b:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  800382:	85 d2                	test   %edx,%edx
  800384:	74 18                	je     80039e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800386:	52                   	push   %edx
  800387:	68 b0 0f 80 00       	push   $0x800fb0
  80038c:	53                   	push   %ebx
  80038d:	56                   	push   %esi
  80038e:	e8 92 fe ff ff       	call   800225 <printfmt>
  800393:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800396:	89 7d 14             	mov    %edi,0x14(%ebp)
  800399:	e9 66 02 00 00       	jmp    800604 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80039e:	50                   	push   %eax
  80039f:	68 a7 0f 80 00       	push   $0x800fa7
  8003a4:	53                   	push   %ebx
  8003a5:	56                   	push   %esi
  8003a6:	e8 7a fe ff ff       	call   800225 <printfmt>
  8003ab:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b1:	e9 4e 02 00 00       	jmp    800604 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	83 c0 04             	add    $0x4,%eax
  8003bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003c4:	85 d2                	test   %edx,%edx
  8003c6:	b8 a0 0f 80 00       	mov    $0x800fa0,%eax
  8003cb:	0f 45 c2             	cmovne %edx,%eax
  8003ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	7e 06                	jle    8003dd <vprintfmt+0x19b>
  8003d7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003db:	75 0d                	jne    8003ea <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e0:	89 c7                	mov    %eax,%edi
  8003e2:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e8:	eb 55                	jmp    80043f <vprintfmt+0x1fd>
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	ff 75 d8             	push   -0x28(%ebp)
  8003f0:	ff 75 cc             	push   -0x34(%ebp)
  8003f3:	e8 0a 03 00 00       	call   800702 <strnlen>
  8003f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003fb:	29 c1                	sub    %eax,%ecx
  8003fd:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800405:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800409:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80040c:	eb 0f                	jmp    80041d <vprintfmt+0x1db>
					putch(padc, putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	53                   	push   %ebx
  800412:	ff 75 e0             	push   -0x20(%ebp)
  800415:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ef 01             	sub    $0x1,%edi
  80041a:	83 c4 10             	add    $0x10,%esp
  80041d:	85 ff                	test   %edi,%edi
  80041f:	7f ed                	jg     80040e <vprintfmt+0x1cc>
  800421:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800424:	85 d2                	test   %edx,%edx
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	0f 49 c2             	cmovns %edx,%eax
  80042e:	29 c2                	sub    %eax,%edx
  800430:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800433:	eb a8                	jmp    8003dd <vprintfmt+0x19b>
					putch(ch, putdat);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	52                   	push   %edx
  80043a:	ff d6                	call   *%esi
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800442:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800444:	83 c7 01             	add    $0x1,%edi
  800447:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044b:	0f be d0             	movsbl %al,%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	74 4b                	je     80049d <vprintfmt+0x25b>
  800452:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800456:	78 06                	js     80045e <vprintfmt+0x21c>
  800458:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80045c:	78 1e                	js     80047c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80045e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800462:	74 d1                	je     800435 <vprintfmt+0x1f3>
  800464:	0f be c0             	movsbl %al,%eax
  800467:	83 e8 20             	sub    $0x20,%eax
  80046a:	83 f8 5e             	cmp    $0x5e,%eax
  80046d:	76 c6                	jbe    800435 <vprintfmt+0x1f3>
					putch('?', putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	53                   	push   %ebx
  800473:	6a 3f                	push   $0x3f
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	eb c3                	jmp    80043f <vprintfmt+0x1fd>
  80047c:	89 cf                	mov    %ecx,%edi
  80047e:	eb 0e                	jmp    80048e <vprintfmt+0x24c>
				putch(' ', putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	6a 20                	push   $0x20
  800486:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800488:	83 ef 01             	sub    $0x1,%edi
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	85 ff                	test   %edi,%edi
  800490:	7f ee                	jg     800480 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800495:	89 45 14             	mov    %eax,0x14(%ebp)
  800498:	e9 67 01 00 00       	jmp    800604 <vprintfmt+0x3c2>
  80049d:	89 cf                	mov    %ecx,%edi
  80049f:	eb ed                	jmp    80048e <vprintfmt+0x24c>
	if (lflag >= 2)
  8004a1:	83 f9 01             	cmp    $0x1,%ecx
  8004a4:	7f 1b                	jg     8004c1 <vprintfmt+0x27f>
	else if (lflag)
  8004a6:	85 c9                	test   %ecx,%ecx
  8004a8:	74 63                	je     80050d <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b2:	99                   	cltd   
  8004b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 40 04             	lea    0x4(%eax),%eax
  8004bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bf:	eb 17                	jmp    8004d8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8b 50 04             	mov    0x4(%eax),%edx
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 40 08             	lea    0x8(%eax),%eax
  8004d5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004de:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004e3:	85 c9                	test   %ecx,%ecx
  8004e5:	0f 89 ff 00 00 00    	jns    8005ea <vprintfmt+0x3a8>
				putch('-', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	6a 2d                	push   $0x2d
  8004f1:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f9:	f7 da                	neg    %edx
  8004fb:	83 d1 00             	adc    $0x0,%ecx
  8004fe:	f7 d9                	neg    %ecx
  800500:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800503:	bf 0a 00 00 00       	mov    $0xa,%edi
  800508:	e9 dd 00 00 00       	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800515:	99                   	cltd   
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 04             	lea    0x4(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	eb b4                	jmp    8004d8 <vprintfmt+0x296>
	if (lflag >= 2)
  800524:	83 f9 01             	cmp    $0x1,%ecx
  800527:	7f 1e                	jg     800547 <vprintfmt+0x305>
	else if (lflag)
  800529:	85 c9                	test   %ecx,%ecx
  80052b:	74 32                	je     80055f <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8b 10                	mov    (%eax),%edx
  800532:	b9 00 00 00 00       	mov    $0x0,%ecx
  800537:	8d 40 04             	lea    0x4(%eax),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80053d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800542:	e9 a3 00 00 00       	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 10                	mov    (%eax),%edx
  80054c:	8b 48 04             	mov    0x4(%eax),%ecx
  80054f:	8d 40 08             	lea    0x8(%eax),%eax
  800552:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800555:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80055a:	e9 8b 00 00 00       	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 10                	mov    (%eax),%edx
  800564:	b9 00 00 00 00       	mov    $0x0,%ecx
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800574:	eb 74                	jmp    8005ea <vprintfmt+0x3a8>
	if (lflag >= 2)
  800576:	83 f9 01             	cmp    $0x1,%ecx
  800579:	7f 1b                	jg     800596 <vprintfmt+0x354>
	else if (lflag)
  80057b:	85 c9                	test   %ecx,%ecx
  80057d:	74 2c                	je     8005ab <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 10                	mov    (%eax),%edx
  800584:	b9 00 00 00 00       	mov    $0x0,%ecx
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80058f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800594:	eb 54                	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8b 48 04             	mov    0x4(%eax),%ecx
  80059e:	8d 40 08             	lea    0x8(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005a4:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005a9:	eb 3f                	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 10                	mov    (%eax),%edx
  8005b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b5:	8d 40 04             	lea    0x4(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005c0:	eb 28                	jmp    8005ea <vprintfmt+0x3a8>
			putch('0', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 30                	push   $0x30
  8005c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ca:	83 c4 08             	add    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 78                	push   $0x78
  8005d0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005dc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005e5:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005f1:	50                   	push   %eax
  8005f2:	ff 75 e0             	push   -0x20(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	51                   	push   %ecx
  8005f7:	52                   	push   %edx
  8005f8:	89 da                	mov    %ebx,%edx
  8005fa:	89 f0                	mov    %esi,%eax
  8005fc:	e8 5e fb ff ff       	call   80015f <printnum>
			break;
  800601:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800607:	e9 54 fc ff ff       	jmp    800260 <vprintfmt+0x1e>
	if (lflag >= 2)
  80060c:	83 f9 01             	cmp    $0x1,%ecx
  80060f:	7f 1b                	jg     80062c <vprintfmt+0x3ea>
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 2c                	je     800641 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800625:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80062a:	eb be                	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	8b 48 04             	mov    0x4(%eax),%ecx
  800634:	8d 40 08             	lea    0x8(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80063f:	eb a9                	jmp    8005ea <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800651:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800656:	eb 92                	jmp    8005ea <vprintfmt+0x3a8>
			putch(ch, putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 25                	push   $0x25
  80065e:	ff d6                	call   *%esi
			break;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 9f                	jmp    800604 <vprintfmt+0x3c2>
			putch('%', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 25                	push   $0x25
  80066b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	89 f8                	mov    %edi,%eax
  800672:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800676:	74 05                	je     80067d <vprintfmt+0x43b>
  800678:	83 e8 01             	sub    $0x1,%eax
  80067b:	eb f5                	jmp    800672 <vprintfmt+0x430>
  80067d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800680:	eb 82                	jmp    800604 <vprintfmt+0x3c2>

00800682 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 18             	sub    $0x18,%esp
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800691:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800695:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800698:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	74 26                	je     8006c9 <vsnprintf+0x47>
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	7e 22                	jle    8006c9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a7:	ff 75 14             	push   0x14(%ebp)
  8006aa:	ff 75 10             	push   0x10(%ebp)
  8006ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b0:	50                   	push   %eax
  8006b1:	68 08 02 80 00       	push   $0x800208
  8006b6:	e8 87 fb ff ff       	call   800242 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c4:	83 c4 10             	add    $0x10,%esp
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    
		return -E_INVAL;
  8006c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ce:	eb f7                	jmp    8006c7 <vsnprintf+0x45>

008006d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 10             	push   0x10(%ebp)
  8006dd:	ff 75 0c             	push   0xc(%ebp)
  8006e0:	ff 75 08             	push   0x8(%ebp)
  8006e3:	e8 9a ff ff ff       	call   800682 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	eb 03                	jmp    8006fa <strlen+0x10>
		n++;
  8006f7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fe:	75 f7                	jne    8006f7 <strlen+0xd>
	return n;
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
  800710:	eb 03                	jmp    800715 <strnlen+0x13>
		n++;
  800712:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	39 d0                	cmp    %edx,%eax
  800717:	74 08                	je     800721 <strnlen+0x1f>
  800719:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071d:	75 f3                	jne    800712 <strnlen+0x10>
  80071f:	89 c2                	mov    %eax,%edx
	return n;
}
  800721:	89 d0                	mov    %edx,%eax
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
  800734:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800738:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80073b:	83 c0 01             	add    $0x1,%eax
  80073e:	84 d2                	test   %dl,%dl
  800740:	75 f2                	jne    800734 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800742:	89 c8                	mov    %ecx,%eax
  800744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	53                   	push   %ebx
  80074d:	83 ec 10             	sub    $0x10,%esp
  800750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800753:	53                   	push   %ebx
  800754:	e8 91 ff ff ff       	call   8006ea <strlen>
  800759:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80075c:	ff 75 0c             	push   0xc(%ebp)
  80075f:	01 d8                	add    %ebx,%eax
  800761:	50                   	push   %eax
  800762:	e8 be ff ff ff       	call   800725 <strcpy>
	return dst;
}
  800767:	89 d8                	mov    %ebx,%eax
  800769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	56                   	push   %esi
  800772:	53                   	push   %ebx
  800773:	8b 75 08             	mov    0x8(%ebp),%esi
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
  800779:	89 f3                	mov    %esi,%ebx
  80077b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	89 f0                	mov    %esi,%eax
  800780:	eb 0f                	jmp    800791 <strncpy+0x23>
		*dst++ = *src;
  800782:	83 c0 01             	add    $0x1,%eax
  800785:	0f b6 0a             	movzbl (%edx),%ecx
  800788:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078b:	80 f9 01             	cmp    $0x1,%cl
  80078e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800791:	39 d8                	cmp    %ebx,%eax
  800793:	75 ed                	jne    800782 <strncpy+0x14>
	}
	return ret;
}
  800795:	89 f0                	mov    %esi,%eax
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 21                	je     8007d0 <strlcpy+0x35>
  8007af:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b3:	89 f2                	mov    %esi,%edx
  8007b5:	eb 09                	jmp    8007c0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b7:	83 c1 01             	add    $0x1,%ecx
  8007ba:	83 c2 01             	add    $0x1,%edx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007c0:	39 c2                	cmp    %eax,%edx
  8007c2:	74 09                	je     8007cd <strlcpy+0x32>
  8007c4:	0f b6 19             	movzbl (%ecx),%ebx
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 ec                	jne    8007b7 <strlcpy+0x1c>
  8007cb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d0:	29 f0                	sub    %esi,%eax
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007df:	eb 06                	jmp    8007e7 <strcmp+0x11>
		p++, q++;
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007e7:	0f b6 01             	movzbl (%ecx),%eax
  8007ea:	84 c0                	test   %al,%al
  8007ec:	74 04                	je     8007f2 <strcmp+0x1c>
  8007ee:	3a 02                	cmp    (%edx),%al
  8007f0:	74 ef                	je     8007e1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f2:	0f b6 c0             	movzbl %al,%eax
  8007f5:	0f b6 12             	movzbl (%edx),%edx
  8007f8:	29 d0                	sub    %edx,%eax
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 c3                	mov    %eax,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080b:	eb 06                	jmp    800813 <strncmp+0x17>
		n--, p++, q++;
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800813:	39 d8                	cmp    %ebx,%eax
  800815:	74 18                	je     80082f <strncmp+0x33>
  800817:	0f b6 08             	movzbl (%eax),%ecx
  80081a:	84 c9                	test   %cl,%cl
  80081c:	74 04                	je     800822 <strncmp+0x26>
  80081e:	3a 0a                	cmp    (%edx),%cl
  800820:	74 eb                	je     80080d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 00             	movzbl (%eax),%eax
  800825:	0f b6 12             	movzbl (%edx),%edx
  800828:	29 d0                	sub    %edx,%eax
}
  80082a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    
		return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
  800834:	eb f4                	jmp    80082a <strncmp+0x2e>

00800836 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800840:	eb 03                	jmp    800845 <strchr+0xf>
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	0f b6 10             	movzbl (%eax),%edx
  800848:	84 d2                	test   %dl,%dl
  80084a:	74 06                	je     800852 <strchr+0x1c>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	75 f2                	jne    800842 <strchr+0xc>
  800850:	eb 05                	jmp    800857 <strchr+0x21>
			return (char *) s;
	return 0;
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800863:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800866:	38 ca                	cmp    %cl,%dl
  800868:	74 09                	je     800873 <strfind+0x1a>
  80086a:	84 d2                	test   %dl,%dl
  80086c:	74 05                	je     800873 <strfind+0x1a>
	for (; *s; s++)
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	eb f0                	jmp    800863 <strfind+0xa>
			break;
	return (char *) s;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	57                   	push   %edi
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 2f                	je     8008b4 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800885:	89 f8                	mov    %edi,%eax
  800887:	09 c8                	or     %ecx,%eax
  800889:	a8 03                	test   $0x3,%al
  80088b:	75 21                	jne    8008ae <memset+0x39>
		c &= 0xFF;
  80088d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800891:	89 d0                	mov    %edx,%eax
  800893:	c1 e0 08             	shl    $0x8,%eax
  800896:	89 d3                	mov    %edx,%ebx
  800898:	c1 e3 18             	shl    $0x18,%ebx
  80089b:	89 d6                	mov    %edx,%esi
  80089d:	c1 e6 10             	shl    $0x10,%esi
  8008a0:	09 f3                	or     %esi,%ebx
  8008a2:	09 da                	or     %ebx,%edx
  8008a4:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008a9:	fc                   	cld    
  8008aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ac:	eb 06                	jmp    8008b4 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b1:	fc                   	cld    
  8008b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b4:	89 f8                	mov    %edi,%eax
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5f                   	pop    %edi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c9:	39 c6                	cmp    %eax,%esi
  8008cb:	73 32                	jae    8008ff <memmove+0x44>
  8008cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d0:	39 c2                	cmp    %eax,%edx
  8008d2:	76 2b                	jbe    8008ff <memmove+0x44>
		s += n;
		d += n;
  8008d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d7:	89 d6                	mov    %edx,%esi
  8008d9:	09 fe                	or     %edi,%esi
  8008db:	09 ce                	or     %ecx,%esi
  8008dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e3:	75 0e                	jne    8008f3 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e5:	83 ef 04             	sub    $0x4,%edi
  8008e8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008ee:	fd                   	std    
  8008ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f1:	eb 09                	jmp    8008fc <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f3:	83 ef 01             	sub    $0x1,%edi
  8008f6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f9:	fd                   	std    
  8008fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fc:	fc                   	cld    
  8008fd:	eb 1a                	jmp    800919 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ff:	89 f2                	mov    %esi,%edx
  800901:	09 c2                	or     %eax,%edx
  800903:	09 ca                	or     %ecx,%edx
  800905:	f6 c2 03             	test   $0x3,%dl
  800908:	75 0a                	jne    800914 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800912:	eb 05                	jmp    800919 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800914:	89 c7                	mov    %eax,%edi
  800916:	fc                   	cld    
  800917:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800923:	ff 75 10             	push   0x10(%ebp)
  800926:	ff 75 0c             	push   0xc(%ebp)
  800929:	ff 75 08             	push   0x8(%ebp)
  80092c:	e8 8a ff ff ff       	call   8008bb <memmove>
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	89 c6                	mov    %eax,%esi
  800940:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	eb 06                	jmp    80094b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80094b:	39 f0                	cmp    %esi,%eax
  80094d:	74 14                	je     800963 <memcmp+0x30>
		if (*s1 != *s2)
  80094f:	0f b6 08             	movzbl (%eax),%ecx
  800952:	0f b6 1a             	movzbl (%edx),%ebx
  800955:	38 d9                	cmp    %bl,%cl
  800957:	74 ec                	je     800945 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800959:	0f b6 c1             	movzbl %cl,%eax
  80095c:	0f b6 db             	movzbl %bl,%ebx
  80095f:	29 d8                	sub    %ebx,%eax
  800961:	eb 05                	jmp    800968 <memcmp+0x35>
	}

	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800975:	89 c2                	mov    %eax,%edx
  800977:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097a:	eb 03                	jmp    80097f <memfind+0x13>
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	73 04                	jae    800987 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800983:	38 08                	cmp    %cl,(%eax)
  800985:	75 f5                	jne    80097c <memfind+0x10>
			break;
	return (void *) s;
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	57                   	push   %edi
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 55 08             	mov    0x8(%ebp),%edx
  800992:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800995:	eb 03                	jmp    80099a <strtol+0x11>
		s++;
  800997:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80099a:	0f b6 02             	movzbl (%edx),%eax
  80099d:	3c 20                	cmp    $0x20,%al
  80099f:	74 f6                	je     800997 <strtol+0xe>
  8009a1:	3c 09                	cmp    $0x9,%al
  8009a3:	74 f2                	je     800997 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009a5:	3c 2b                	cmp    $0x2b,%al
  8009a7:	74 2a                	je     8009d3 <strtol+0x4a>
	int neg = 0;
  8009a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ae:	3c 2d                	cmp    $0x2d,%al
  8009b0:	74 2b                	je     8009dd <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b8:	75 0f                	jne    8009c9 <strtol+0x40>
  8009ba:	80 3a 30             	cmpb   $0x30,(%edx)
  8009bd:	74 28                	je     8009e7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009c6:	0f 44 d8             	cmove  %eax,%ebx
  8009c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d1:	eb 46                	jmp    800a19 <strtol+0x90>
		s++;
  8009d3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009db:	eb d5                	jmp    8009b2 <strtol+0x29>
		s++, neg = 1;
  8009dd:	83 c2 01             	add    $0x1,%edx
  8009e0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e5:	eb cb                	jmp    8009b2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009eb:	74 0e                	je     8009fb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009ed:	85 db                	test   %ebx,%ebx
  8009ef:	75 d8                	jne    8009c9 <strtol+0x40>
		s++, base = 8;
  8009f1:	83 c2 01             	add    $0x1,%edx
  8009f4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009f9:	eb ce                	jmp    8009c9 <strtol+0x40>
		s += 2, base = 16;
  8009fb:	83 c2 02             	add    $0x2,%edx
  8009fe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a03:	eb c4                	jmp    8009c9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a05:	0f be c0             	movsbl %al,%eax
  800a08:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a0b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a0e:	7d 3a                	jge    800a4a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a10:	83 c2 01             	add    $0x1,%edx
  800a13:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a17:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a19:	0f b6 02             	movzbl (%edx),%eax
  800a1c:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 09             	cmp    $0x9,%bl
  800a24:	76 df                	jbe    800a05 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a26:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	80 fb 19             	cmp    $0x19,%bl
  800a2e:	77 08                	ja     800a38 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a30:	0f be c0             	movsbl %al,%eax
  800a33:	83 e8 57             	sub    $0x57,%eax
  800a36:	eb d3                	jmp    800a0b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a38:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 19             	cmp    $0x19,%bl
  800a40:	77 08                	ja     800a4a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a42:	0f be c0             	movsbl %al,%eax
  800a45:	83 e8 37             	sub    $0x37,%eax
  800a48:	eb c1                	jmp    800a0b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4e:	74 05                	je     800a55 <strtol+0xcc>
		*endptr = (char *) s;
  800a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a53:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a55:	89 c8                	mov    %ecx,%eax
  800a57:	f7 d8                	neg    %eax
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	0f 45 c8             	cmovne %eax,%ecx
}
  800a5e:	89 c8                	mov    %ecx,%eax
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	89 c7                	mov    %eax,%edi
  800a7a:	89 c6                	mov    %eax,%esi
  800a7c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a93:	89 d1                	mov    %edx,%ecx
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	89 d7                	mov    %edx,%edi
  800a99:	89 d6                	mov    %edx,%esi
  800a9b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab8:	89 cb                	mov    %ecx,%ebx
  800aba:	89 cf                	mov    %ecx,%edi
  800abc:	89 ce                	mov    %ecx,%esi
  800abe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	7f 08                	jg     800acc <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800acc:	83 ec 0c             	sub    $0xc,%esp
  800acf:	50                   	push   %eax
  800ad0:	6a 03                	push   $0x3
  800ad2:	68 e4 11 80 00       	push   $0x8011e4
  800ad7:	6a 2a                	push   $0x2a
  800ad9:	68 01 12 80 00       	push   $0x801201
  800ade:	e8 ed 01 00 00       	call   800cd0 <_panic>

00800ae3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 02 00 00 00       	mov    $0x2,%eax
  800af3:	89 d1                	mov    %edx,%ecx
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	89 d7                	mov    %edx,%edi
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_yield>:

void
sys_yield(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b2a:	be 00 00 00 00       	mov    $0x0,%esi
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3d:	89 f7                	mov    %esi,%edi
  800b3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7f 08                	jg     800b4d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	50                   	push   %eax
  800b51:	6a 04                	push   $0x4
  800b53:	68 e4 11 80 00       	push   $0x8011e4
  800b58:	6a 2a                	push   $0x2a
  800b5a:	68 01 12 80 00       	push   $0x801201
  800b5f:	e8 6c 01 00 00       	call   800cd0 <_panic>

00800b64 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	b8 05 00 00 00       	mov    $0x5,%eax
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7f 08                	jg     800b8f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 05                	push   $0x5
  800b95:	68 e4 11 80 00       	push   $0x8011e4
  800b9a:	6a 2a                	push   $0x2a
  800b9c:	68 01 12 80 00       	push   $0x801201
  800ba1:	e8 2a 01 00 00       	call   800cd0 <_panic>

00800ba6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800baf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbf:	89 df                	mov    %ebx,%edi
  800bc1:	89 de                	mov    %ebx,%esi
  800bc3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7f 08                	jg     800bd1 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	50                   	push   %eax
  800bd5:	6a 06                	push   $0x6
  800bd7:	68 e4 11 80 00       	push   $0x8011e4
  800bdc:	6a 2a                	push   $0x2a
  800bde:	68 01 12 80 00       	push   $0x801201
  800be3:	e8 e8 00 00 00       	call   800cd0 <_panic>

00800be8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	b8 08 00 00 00       	mov    $0x8,%eax
  800c01:	89 df                	mov    %ebx,%edi
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7f 08                	jg     800c13 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 08                	push   $0x8
  800c19:	68 e4 11 80 00       	push   $0x8011e4
  800c1e:	6a 2a                	push   $0x2a
  800c20:	68 01 12 80 00       	push   $0x801201
  800c25:	e8 a6 00 00 00       	call   800cd0 <_panic>

00800c2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c43:	89 df                	mov    %ebx,%edi
  800c45:	89 de                	mov    %ebx,%esi
  800c47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7f 08                	jg     800c55 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 09                	push   $0x9
  800c5b:	68 e4 11 80 00       	push   $0x8011e4
  800c60:	6a 2a                	push   $0x2a
  800c62:	68 01 12 80 00       	push   $0x801201
  800c67:	e8 64 00 00 00       	call   800cd0 <_panic>

00800c6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7d:	be 00 00 00 00       	mov    $0x0,%esi
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c88:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca5:	89 cb                	mov    %ecx,%ebx
  800ca7:	89 cf                	mov    %ecx,%edi
  800ca9:	89 ce                	mov    %ecx,%esi
  800cab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7f 08                	jg     800cb9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 0c                	push   $0xc
  800cbf:	68 e4 11 80 00       	push   $0x8011e4
  800cc4:	6a 2a                	push   $0x2a
  800cc6:	68 01 12 80 00       	push   $0x801201
  800ccb:	e8 00 00 00 00       	call   800cd0 <_panic>

00800cd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cd5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cd8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cde:	e8 00 fe ff ff       	call   800ae3 <sys_getenvid>
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	ff 75 0c             	push   0xc(%ebp)
  800ce9:	ff 75 08             	push   0x8(%ebp)
  800cec:	56                   	push   %esi
  800ced:	50                   	push   %eax
  800cee:	68 10 12 80 00       	push   $0x801210
  800cf3:	e8 53 f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cf8:	83 c4 18             	add    $0x18,%esp
  800cfb:	53                   	push   %ebx
  800cfc:	ff 75 10             	push   0x10(%ebp)
  800cff:	e8 f6 f3 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800d04:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  800d0b:	e8 3b f4 ff ff       	call   80014b <cprintf>
  800d10:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d13:	cc                   	int3   
  800d14:	eb fd                	jmp    800d13 <_panic+0x43>
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__udivdi3>:
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
  800d2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	75 19                	jne    800d58 <__udivdi3+0x38>
  800d3f:	39 f3                	cmp    %esi,%ebx
  800d41:	76 4d                	jbe    800d90 <__udivdi3+0x70>
  800d43:	31 ff                	xor    %edi,%edi
  800d45:	89 e8                	mov    %ebp,%eax
  800d47:	89 f2                	mov    %esi,%edx
  800d49:	f7 f3                	div    %ebx
  800d4b:	89 fa                	mov    %edi,%edx
  800d4d:	83 c4 1c             	add    $0x1c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	39 f0                	cmp    %esi,%eax
  800d5a:	76 14                	jbe    800d70 <__udivdi3+0x50>
  800d5c:	31 ff                	xor    %edi,%edi
  800d5e:	31 c0                	xor    %eax,%eax
  800d60:	89 fa                	mov    %edi,%edx
  800d62:	83 c4 1c             	add    $0x1c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
  800d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d70:	0f bd f8             	bsr    %eax,%edi
  800d73:	83 f7 1f             	xor    $0x1f,%edi
  800d76:	75 48                	jne    800dc0 <__udivdi3+0xa0>
  800d78:	39 f0                	cmp    %esi,%eax
  800d7a:	72 06                	jb     800d82 <__udivdi3+0x62>
  800d7c:	31 c0                	xor    %eax,%eax
  800d7e:	39 eb                	cmp    %ebp,%ebx
  800d80:	77 de                	ja     800d60 <__udivdi3+0x40>
  800d82:	b8 01 00 00 00       	mov    $0x1,%eax
  800d87:	eb d7                	jmp    800d60 <__udivdi3+0x40>
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 d9                	mov    %ebx,%ecx
  800d92:	85 db                	test   %ebx,%ebx
  800d94:	75 0b                	jne    800da1 <__udivdi3+0x81>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f3                	div    %ebx
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	89 f0                	mov    %esi,%eax
  800da5:	f7 f1                	div    %ecx
  800da7:	89 c6                	mov    %eax,%esi
  800da9:	89 e8                	mov    %ebp,%eax
  800dab:	89 f7                	mov    %esi,%edi
  800dad:	f7 f1                	div    %ecx
  800daf:	89 fa                	mov    %edi,%edx
  800db1:	83 c4 1c             	add    $0x1c,%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	89 f9                	mov    %edi,%ecx
  800dc2:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc7:	29 fa                	sub    %edi,%edx
  800dc9:	d3 e0                	shl    %cl,%eax
  800dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	d3 e8                	shr    %cl,%eax
  800dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dd9:	09 c1                	or     %eax,%ecx
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e3                	shl    %cl,%ebx
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800def:	89 eb                	mov    %ebp,%ebx
  800df1:	d3 e6                	shl    %cl,%esi
  800df3:	89 d1                	mov    %edx,%ecx
  800df5:	d3 eb                	shr    %cl,%ebx
  800df7:	09 f3                	or     %esi,%ebx
  800df9:	89 c6                	mov    %eax,%esi
  800dfb:	89 f2                	mov    %esi,%edx
  800dfd:	89 d8                	mov    %ebx,%eax
  800dff:	f7 74 24 08          	divl   0x8(%esp)
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	f7 64 24 0c          	mull   0xc(%esp)
  800e0b:	39 d6                	cmp    %edx,%esi
  800e0d:	72 19                	jb     800e28 <__udivdi3+0x108>
  800e0f:	89 f9                	mov    %edi,%ecx
  800e11:	d3 e5                	shl    %cl,%ebp
  800e13:	39 c5                	cmp    %eax,%ebp
  800e15:	73 04                	jae    800e1b <__udivdi3+0xfb>
  800e17:	39 d6                	cmp    %edx,%esi
  800e19:	74 0d                	je     800e28 <__udivdi3+0x108>
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	31 ff                	xor    %edi,%edi
  800e1f:	e9 3c ff ff ff       	jmp    800d60 <__udivdi3+0x40>
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e2b:	31 ff                	xor    %edi,%edi
  800e2d:	e9 2e ff ff ff       	jmp    800d60 <__udivdi3+0x40>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 1c             	sub    $0x1c,%esp
  800e4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	89 da                	mov    %ebx,%edx
  800e5f:	85 ff                	test   %edi,%edi
  800e61:	75 15                	jne    800e78 <__umoddi3+0x38>
  800e63:	39 dd                	cmp    %ebx,%ebp
  800e65:	76 39                	jbe    800ea0 <__umoddi3+0x60>
  800e67:	f7 f5                	div    %ebp
  800e69:	89 d0                	mov    %edx,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	83 c4 1c             	add    $0x1c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	39 df                	cmp    %ebx,%edi
  800e7a:	77 f1                	ja     800e6d <__umoddi3+0x2d>
  800e7c:	0f bd cf             	bsr    %edi,%ecx
  800e7f:	83 f1 1f             	xor    $0x1f,%ecx
  800e82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e86:	75 40                	jne    800ec8 <__umoddi3+0x88>
  800e88:	39 df                	cmp    %ebx,%edi
  800e8a:	72 04                	jb     800e90 <__umoddi3+0x50>
  800e8c:	39 f5                	cmp    %esi,%ebp
  800e8e:	77 dd                	ja     800e6d <__umoddi3+0x2d>
  800e90:	89 da                	mov    %ebx,%edx
  800e92:	89 f0                	mov    %esi,%eax
  800e94:	29 e8                	sub    %ebp,%eax
  800e96:	19 fa                	sbb    %edi,%edx
  800e98:	eb d3                	jmp    800e6d <__umoddi3+0x2d>
  800e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea0:	89 e9                	mov    %ebp,%ecx
  800ea2:	85 ed                	test   %ebp,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x71>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f5                	div    %ebp
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 d8                	mov    %ebx,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f1                	div    %ecx
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	f7 f1                	div    %ecx
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	eb ac                	jmp    800e6d <__umoddi3+0x2d>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ecc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ed1:	29 c2                	sub    %eax,%edx
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	89 e8                	mov    %ebp,%eax
  800ed7:	d3 e7                	shl    %cl,%edi
  800ed9:	89 d1                	mov    %edx,%ecx
  800edb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800edf:	d3 e8                	shr    %cl,%eax
  800ee1:	89 c1                	mov    %eax,%ecx
  800ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee7:	09 f9                	or     %edi,%ecx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	d3 e5                	shl    %cl,%ebp
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	d3 ef                	shr    %cl,%edi
  800ef7:	89 c1                	mov    %eax,%ecx
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	d3 e3                	shl    %cl,%ebx
  800efd:	89 d1                	mov    %edx,%ecx
  800eff:	89 fa                	mov    %edi,%edx
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f08:	09 d8                	or     %ebx,%eax
  800f0a:	f7 74 24 08          	divl   0x8(%esp)
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	d3 e6                	shl    %cl,%esi
  800f12:	f7 e5                	mul    %ebp
  800f14:	89 c7                	mov    %eax,%edi
  800f16:	89 d1                	mov    %edx,%ecx
  800f18:	39 d3                	cmp    %edx,%ebx
  800f1a:	72 06                	jb     800f22 <__umoddi3+0xe2>
  800f1c:	75 0e                	jne    800f2c <__umoddi3+0xec>
  800f1e:	39 c6                	cmp    %eax,%esi
  800f20:	73 0a                	jae    800f2c <__umoddi3+0xec>
  800f22:	29 e8                	sub    %ebp,%eax
  800f24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 c7                	mov    %eax,%edi
  800f2c:	89 f5                	mov    %esi,%ebp
  800f2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f32:	29 fd                	sub    %edi,%ebp
  800f34:	19 cb                	sbb    %ecx,%ebx
  800f36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	d3 e0                	shl    %cl,%eax
  800f3f:	89 f1                	mov    %esi,%ecx
  800f41:	d3 ed                	shr    %cl,%ebp
  800f43:	d3 eb                	shr    %cl,%ebx
  800f45:	09 e8                	or     %ebp,%eax
  800f47:	89 da                	mov    %ebx,%edx
  800f49:	83 c4 1c             	add    $0x1c,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    
