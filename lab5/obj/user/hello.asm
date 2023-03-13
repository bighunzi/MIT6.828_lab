
obj/user/hello.debug：     文件格式 elf32-i386


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
  800039:	68 80 1d 80 00       	push   $0x801d80
  80003e:	e8 10 01 00 00       	call   800153 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 00 40 80 00       	mov    0x804000,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 1d 80 00       	push   $0x801d8e
  800054:	e8 fa 00 00 00       	call   800153 <cprintf>
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
  800069:	e8 7d 0a 00 00       	call   800aeb <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 37 0e 00 00       	call   800ee6 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 f1 09 00 00       	call   800aaa <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	74 09                	je     8000e6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	68 ff 00 00 00       	push   $0xff
  8000ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 76 09 00 00       	call   800a6d <sys_cputs>
		b->idx = 0;
  8000f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	eb db                	jmp    8000dd <putch+0x1f>

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	push   0xc(%ebp)
  800122:	ff 75 08             	push   0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 be 00 80 00       	push   $0x8000be
  800131:	e8 14 01 00 00       	call   80024a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 22 09 00 00       	call   800a6d <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	push   0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 c2                	mov    %eax,%edx
  80017e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800181:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800194:	39 c2                	cmp    %eax,%edx
  800196:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800199:	72 3e                	jb     8001d9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 18             	push   0x18(%ebp)
  8001a1:	83 eb 01             	sub    $0x1,%ebx
  8001a4:	53                   	push   %ebx
  8001a5:	50                   	push   %eax
  8001a6:	83 ec 08             	sub    $0x8,%esp
  8001a9:	ff 75 e4             	push   -0x1c(%ebp)
  8001ac:	ff 75 e0             	push   -0x20(%ebp)
  8001af:	ff 75 dc             	push   -0x24(%ebp)
  8001b2:	ff 75 d8             	push   -0x28(%ebp)
  8001b5:	e8 86 19 00 00       	call   801b40 <__udivdi3>
  8001ba:	83 c4 18             	add    $0x18,%esp
  8001bd:	52                   	push   %edx
  8001be:	50                   	push   %eax
  8001bf:	89 f2                	mov    %esi,%edx
  8001c1:	89 f8                	mov    %edi,%eax
  8001c3:	e8 9f ff ff ff       	call   800167 <printnum>
  8001c8:	83 c4 20             	add    $0x20,%esp
  8001cb:	eb 13                	jmp    8001e0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	56                   	push   %esi
  8001d1:	ff 75 18             	push   0x18(%ebp)
  8001d4:	ff d7                	call   *%edi
  8001d6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d9:	83 eb 01             	sub    $0x1,%ebx
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7f ed                	jg     8001cd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	56                   	push   %esi
  8001e4:	83 ec 04             	sub    $0x4,%esp
  8001e7:	ff 75 e4             	push   -0x1c(%ebp)
  8001ea:	ff 75 e0             	push   -0x20(%ebp)
  8001ed:	ff 75 dc             	push   -0x24(%ebp)
  8001f0:	ff 75 d8             	push   -0x28(%ebp)
  8001f3:	e8 68 1a 00 00       	call   801c60 <__umoddi3>
  8001f8:	83 c4 14             	add    $0x14,%esp
  8001fb:	0f be 80 af 1d 80 00 	movsbl 0x801daf(%eax),%eax
  800202:	50                   	push   %eax
  800203:	ff d7                	call   *%edi
}
  800205:	83 c4 10             	add    $0x10,%esp
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800216:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021a:	8b 10                	mov    (%eax),%edx
  80021c:	3b 50 04             	cmp    0x4(%eax),%edx
  80021f:	73 0a                	jae    80022b <sprintputch+0x1b>
		*b->buf++ = ch;
  800221:	8d 4a 01             	lea    0x1(%edx),%ecx
  800224:	89 08                	mov    %ecx,(%eax)
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	88 02                	mov    %al,(%edx)
}
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <printfmt>:
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800233:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800236:	50                   	push   %eax
  800237:	ff 75 10             	push   0x10(%ebp)
  80023a:	ff 75 0c             	push   0xc(%ebp)
  80023d:	ff 75 08             	push   0x8(%ebp)
  800240:	e8 05 00 00 00       	call   80024a <vprintfmt>
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <vprintfmt>:
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 3c             	sub    $0x3c,%esp
  800253:	8b 75 08             	mov    0x8(%ebp),%esi
  800256:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800259:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025c:	eb 0a                	jmp    800268 <vprintfmt+0x1e>
			putch(ch, putdat);
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	53                   	push   %ebx
  800262:	50                   	push   %eax
  800263:	ff d6                	call   *%esi
  800265:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800268:	83 c7 01             	add    $0x1,%edi
  80026b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80026f:	83 f8 25             	cmp    $0x25,%eax
  800272:	74 0c                	je     800280 <vprintfmt+0x36>
			if (ch == '\0')
  800274:	85 c0                	test   %eax,%eax
  800276:	75 e6                	jne    80025e <vprintfmt+0x14>
}
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    
		padc = ' ';
  800280:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800284:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800299:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80029e:	8d 47 01             	lea    0x1(%edi),%eax
  8002a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a4:	0f b6 17             	movzbl (%edi),%edx
  8002a7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002aa:	3c 55                	cmp    $0x55,%al
  8002ac:	0f 87 bb 03 00 00    	ja     80066d <vprintfmt+0x423>
  8002b2:	0f b6 c0             	movzbl %al,%eax
  8002b5:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
  8002bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002bf:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c3:	eb d9                	jmp    80029e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002cc:	eb d0                	jmp    80029e <vprintfmt+0x54>
  8002ce:	0f b6 d2             	movzbl %dl,%edx
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e9:	83 f9 09             	cmp    $0x9,%ecx
  8002ec:	77 55                	ja     800343 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f1:	eb e9                	jmp    8002dc <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8b 00                	mov    (%eax),%eax
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 40 04             	lea    0x4(%eax),%eax
  800301:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800307:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030b:	79 91                	jns    80029e <vprintfmt+0x54>
				width = precision, precision = -1;
  80030d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800310:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800313:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031a:	eb 82                	jmp    80029e <vprintfmt+0x54>
  80031c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80031f:	85 d2                	test   %edx,%edx
  800321:	b8 00 00 00 00       	mov    $0x0,%eax
  800326:	0f 49 c2             	cmovns %edx,%eax
  800329:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80032f:	e9 6a ff ff ff       	jmp    80029e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800337:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80033e:	e9 5b ff ff ff       	jmp    80029e <vprintfmt+0x54>
  800343:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800346:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800349:	eb bc                	jmp    800307 <vprintfmt+0xbd>
			lflag++;
  80034b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800351:	e9 48 ff ff ff       	jmp    80029e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8d 78 04             	lea    0x4(%eax),%edi
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	ff 30                	push   (%eax)
  800362:	ff d6                	call   *%esi
			break;
  800364:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800367:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036a:	e9 9d 02 00 00       	jmp    80060c <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8d 78 04             	lea    0x4(%eax),%edi
  800375:	8b 10                	mov    (%eax),%edx
  800377:	89 d0                	mov    %edx,%eax
  800379:	f7 d8                	neg    %eax
  80037b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037e:	83 f8 0f             	cmp    $0xf,%eax
  800381:	7f 23                	jg     8003a6 <vprintfmt+0x15c>
  800383:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 18                	je     8003a6 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80038e:	52                   	push   %edx
  80038f:	68 91 21 80 00       	push   $0x802191
  800394:	53                   	push   %ebx
  800395:	56                   	push   %esi
  800396:	e8 92 fe ff ff       	call   80022d <printfmt>
  80039b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039e:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a1:	e9 66 02 00 00       	jmp    80060c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003a6:	50                   	push   %eax
  8003a7:	68 c7 1d 80 00       	push   $0x801dc7
  8003ac:	53                   	push   %ebx
  8003ad:	56                   	push   %esi
  8003ae:	e8 7a fe ff ff       	call   80022d <printfmt>
  8003b3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b9:	e9 4e 02 00 00       	jmp    80060c <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	83 c0 04             	add    $0x4,%eax
  8003c4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003cc:	85 d2                	test   %edx,%edx
  8003ce:	b8 c0 1d 80 00       	mov    $0x801dc0,%eax
  8003d3:	0f 45 c2             	cmovne %edx,%eax
  8003d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003dd:	7e 06                	jle    8003e5 <vprintfmt+0x19b>
  8003df:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e3:	75 0d                	jne    8003f2 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e8:	89 c7                	mov    %eax,%edi
  8003ea:	03 45 e0             	add    -0x20(%ebp),%eax
  8003ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f0:	eb 55                	jmp    800447 <vprintfmt+0x1fd>
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	ff 75 d8             	push   -0x28(%ebp)
  8003f8:	ff 75 cc             	push   -0x34(%ebp)
  8003fb:	e8 0a 03 00 00       	call   80070a <strnlen>
  800400:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800403:	29 c1                	sub    %eax,%ecx
  800405:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800408:	83 c4 10             	add    $0x10,%esp
  80040b:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80040d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800414:	eb 0f                	jmp    800425 <vprintfmt+0x1db>
					putch(padc, putdat);
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	53                   	push   %ebx
  80041a:	ff 75 e0             	push   -0x20(%ebp)
  80041d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	83 ef 01             	sub    $0x1,%edi
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	85 ff                	test   %edi,%edi
  800427:	7f ed                	jg     800416 <vprintfmt+0x1cc>
  800429:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	0f 49 c2             	cmovns %edx,%eax
  800436:	29 c2                	sub    %eax,%edx
  800438:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043b:	eb a8                	jmp    8003e5 <vprintfmt+0x19b>
					putch(ch, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	52                   	push   %edx
  800442:	ff d6                	call   *%esi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044c:	83 c7 01             	add    $0x1,%edi
  80044f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800453:	0f be d0             	movsbl %al,%edx
  800456:	85 d2                	test   %edx,%edx
  800458:	74 4b                	je     8004a5 <vprintfmt+0x25b>
  80045a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045e:	78 06                	js     800466 <vprintfmt+0x21c>
  800460:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800464:	78 1e                	js     800484 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800466:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046a:	74 d1                	je     80043d <vprintfmt+0x1f3>
  80046c:	0f be c0             	movsbl %al,%eax
  80046f:	83 e8 20             	sub    $0x20,%eax
  800472:	83 f8 5e             	cmp    $0x5e,%eax
  800475:	76 c6                	jbe    80043d <vprintfmt+0x1f3>
					putch('?', putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	6a 3f                	push   $0x3f
  80047d:	ff d6                	call   *%esi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb c3                	jmp    800447 <vprintfmt+0x1fd>
  800484:	89 cf                	mov    %ecx,%edi
  800486:	eb 0e                	jmp    800496 <vprintfmt+0x24c>
				putch(' ', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	53                   	push   %ebx
  80048c:	6a 20                	push   $0x20
  80048e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800490:	83 ef 01             	sub    $0x1,%edi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	85 ff                	test   %edi,%edi
  800498:	7f ee                	jg     800488 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049d:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a0:	e9 67 01 00 00       	jmp    80060c <vprintfmt+0x3c2>
  8004a5:	89 cf                	mov    %ecx,%edi
  8004a7:	eb ed                	jmp    800496 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004a9:	83 f9 01             	cmp    $0x1,%ecx
  8004ac:	7f 1b                	jg     8004c9 <vprintfmt+0x27f>
	else if (lflag)
  8004ae:	85 c9                	test   %ecx,%ecx
  8004b0:	74 63                	je     800515 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ba:	99                   	cltd   
  8004bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 40 04             	lea    0x4(%eax),%eax
  8004c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c7:	eb 17                	jmp    8004e0 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8b 50 04             	mov    0x4(%eax),%edx
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 40 08             	lea    0x8(%eax),%eax
  8004dd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e6:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004eb:	85 c9                	test   %ecx,%ecx
  8004ed:	0f 89 ff 00 00 00    	jns    8005f2 <vprintfmt+0x3a8>
				putch('-', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	6a 2d                	push   $0x2d
  8004f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800501:	f7 da                	neg    %edx
  800503:	83 d1 00             	adc    $0x0,%ecx
  800506:	f7 d9                	neg    %ecx
  800508:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800510:	e9 dd 00 00 00       	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051d:	99                   	cltd   
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 04             	lea    0x4(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
  80052a:	eb b4                	jmp    8004e0 <vprintfmt+0x296>
	if (lflag >= 2)
  80052c:	83 f9 01             	cmp    $0x1,%ecx
  80052f:	7f 1e                	jg     80054f <vprintfmt+0x305>
	else if (lflag)
  800531:	85 c9                	test   %ecx,%ecx
  800533:	74 32                	je     800567 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8b 10                	mov    (%eax),%edx
  80053a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053f:	8d 40 04             	lea    0x4(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800545:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80054a:	e9 a3 00 00 00       	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 10                	mov    (%eax),%edx
  800554:	8b 48 04             	mov    0x4(%eax),%ecx
  800557:	8d 40 08             	lea    0x8(%eax),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800562:	e9 8b 00 00 00       	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8b 10                	mov    (%eax),%edx
  80056c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800571:	8d 40 04             	lea    0x4(%eax),%eax
  800574:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800577:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80057c:	eb 74                	jmp    8005f2 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80057e:	83 f9 01             	cmp    $0x1,%ecx
  800581:	7f 1b                	jg     80059e <vprintfmt+0x354>
	else if (lflag)
  800583:	85 c9                	test   %ecx,%ecx
  800585:	74 2c                	je     8005b3 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 10                	mov    (%eax),%edx
  80058c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800591:	8d 40 04             	lea    0x4(%eax),%eax
  800594:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800597:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80059c:	eb 54                	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ac:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005b1:	eb 3f                	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bd:	8d 40 04             	lea    0x4(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c3:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005c8:	eb 28                	jmp    8005f2 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 30                	push   $0x30
  8005d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d2:	83 c4 08             	add    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 78                	push   $0x78
  8005d8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ed:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005f2:	83 ec 0c             	sub    $0xc,%esp
  8005f5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 e0             	push   -0x20(%ebp)
  8005fd:	57                   	push   %edi
  8005fe:	51                   	push   %ecx
  8005ff:	52                   	push   %edx
  800600:	89 da                	mov    %ebx,%edx
  800602:	89 f0                	mov    %esi,%eax
  800604:	e8 5e fb ff ff       	call   800167 <printnum>
			break;
  800609:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060f:	e9 54 fc ff ff       	jmp    800268 <vprintfmt+0x1e>
	if (lflag >= 2)
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7f 1b                	jg     800634 <vprintfmt+0x3ea>
	else if (lflag)
  800619:	85 c9                	test   %ecx,%ecx
  80061b:	74 2c                	je     800649 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800632:	eb be                	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	8b 48 04             	mov    0x4(%eax),%ecx
  80063c:	8d 40 08             	lea    0x8(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800642:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800647:	eb a9                	jmp    8005f2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800659:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80065e:	eb 92                	jmp    8005f2 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 25                	push   $0x25
  800666:	ff d6                	call   *%esi
			break;
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	eb 9f                	jmp    80060c <vprintfmt+0x3c2>
			putch('%', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	6a 25                	push   $0x25
  800673:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	89 f8                	mov    %edi,%eax
  80067a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80067e:	74 05                	je     800685 <vprintfmt+0x43b>
  800680:	83 e8 01             	sub    $0x1,%eax
  800683:	eb f5                	jmp    80067a <vprintfmt+0x430>
  800685:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800688:	eb 82                	jmp    80060c <vprintfmt+0x3c2>

0080068a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 18             	sub    $0x18,%esp
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800699:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	74 26                	je     8006d1 <vsnprintf+0x47>
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	7e 22                	jle    8006d1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006af:	ff 75 14             	push   0x14(%ebp)
  8006b2:	ff 75 10             	push   0x10(%ebp)
  8006b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b8:	50                   	push   %eax
  8006b9:	68 10 02 80 00       	push   $0x800210
  8006be:	e8 87 fb ff ff       	call   80024a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cc:	83 c4 10             	add    $0x10,%esp
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    
		return -E_INVAL;
  8006d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d6:	eb f7                	jmp    8006cf <vsnprintf+0x45>

008006d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e1:	50                   	push   %eax
  8006e2:	ff 75 10             	push   0x10(%ebp)
  8006e5:	ff 75 0c             	push   0xc(%ebp)
  8006e8:	ff 75 08             	push   0x8(%ebp)
  8006eb:	e8 9a ff ff ff       	call   80068a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fd:	eb 03                	jmp    800702 <strlen+0x10>
		n++;
  8006ff:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800702:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800706:	75 f7                	jne    8006ff <strlen+0xd>
	return n;
}
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  800718:	eb 03                	jmp    80071d <strnlen+0x13>
		n++;
  80071a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071d:	39 d0                	cmp    %edx,%eax
  80071f:	74 08                	je     800729 <strnlen+0x1f>
  800721:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800725:	75 f3                	jne    80071a <strnlen+0x10>
  800727:	89 c2                	mov    %eax,%edx
	return n;
}
  800729:	89 d0                	mov    %edx,%eax
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800740:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800743:	83 c0 01             	add    $0x1,%eax
  800746:	84 d2                	test   %dl,%dl
  800748:	75 f2                	jne    80073c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074a:	89 c8                	mov    %ecx,%eax
  80074c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	53                   	push   %ebx
  800755:	83 ec 10             	sub    $0x10,%esp
  800758:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075b:	53                   	push   %ebx
  80075c:	e8 91 ff ff ff       	call   8006f2 <strlen>
  800761:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800764:	ff 75 0c             	push   0xc(%ebp)
  800767:	01 d8                	add    %ebx,%eax
  800769:	50                   	push   %eax
  80076a:	e8 be ff ff ff       	call   80072d <strcpy>
	return dst;
}
  80076f:	89 d8                	mov    %ebx,%eax
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800781:	89 f3                	mov    %esi,%ebx
  800783:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800786:	89 f0                	mov    %esi,%eax
  800788:	eb 0f                	jmp    800799 <strncpy+0x23>
		*dst++ = *src;
  80078a:	83 c0 01             	add    $0x1,%eax
  80078d:	0f b6 0a             	movzbl (%edx),%ecx
  800790:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800793:	80 f9 01             	cmp    $0x1,%cl
  800796:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800799:	39 d8                	cmp    %ebx,%eax
  80079b:	75 ed                	jne    80078a <strncpy+0x14>
	}
	return ret;
}
  80079d:	89 f0                	mov    %esi,%eax
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	74 21                	je     8007d8 <strlcpy+0x35>
  8007b7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bb:	89 f2                	mov    %esi,%edx
  8007bd:	eb 09                	jmp    8007c8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007bf:	83 c1 01             	add    $0x1,%ecx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007c8:	39 c2                	cmp    %eax,%edx
  8007ca:	74 09                	je     8007d5 <strlcpy+0x32>
  8007cc:	0f b6 19             	movzbl (%ecx),%ebx
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ec                	jne    8007bf <strlcpy+0x1c>
  8007d3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007d5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d8:	29 f0                	sub    %esi,%eax
}
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e7:	eb 06                	jmp    8007ef <strcmp+0x11>
		p++, q++;
  8007e9:	83 c1 01             	add    $0x1,%ecx
  8007ec:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007ef:	0f b6 01             	movzbl (%ecx),%eax
  8007f2:	84 c0                	test   %al,%al
  8007f4:	74 04                	je     8007fa <strcmp+0x1c>
  8007f6:	3a 02                	cmp    (%edx),%al
  8007f8:	74 ef                	je     8007e9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fa:	0f b6 c0             	movzbl %al,%eax
  8007fd:	0f b6 12             	movzbl (%edx),%edx
  800800:	29 d0                	sub    %edx,%eax
}
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	89 c3                	mov    %eax,%ebx
  800810:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800813:	eb 06                	jmp    80081b <strncmp+0x17>
		n--, p++, q++;
  800815:	83 c0 01             	add    $0x1,%eax
  800818:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80081b:	39 d8                	cmp    %ebx,%eax
  80081d:	74 18                	je     800837 <strncmp+0x33>
  80081f:	0f b6 08             	movzbl (%eax),%ecx
  800822:	84 c9                	test   %cl,%cl
  800824:	74 04                	je     80082a <strncmp+0x26>
  800826:	3a 0a                	cmp    (%edx),%cl
  800828:	74 eb                	je     800815 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082a:	0f b6 00             	movzbl (%eax),%eax
  80082d:	0f b6 12             	movzbl (%edx),%edx
  800830:	29 d0                	sub    %edx,%eax
}
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    
		return 0;
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
  80083c:	eb f4                	jmp    800832 <strncmp+0x2e>

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 03                	jmp    80084d <strchr+0xf>
  80084a:	83 c0 01             	add    $0x1,%eax
  80084d:	0f b6 10             	movzbl (%eax),%edx
  800850:	84 d2                	test   %dl,%dl
  800852:	74 06                	je     80085a <strchr+0x1c>
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	75 f2                	jne    80084a <strchr+0xc>
  800858:	eb 05                	jmp    80085f <strchr+0x21>
			return (char *) s;
	return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 09                	je     80087b <strfind+0x1a>
  800872:	84 d2                	test   %dl,%dl
  800874:	74 05                	je     80087b <strfind+0x1a>
	for (; *s; s++)
  800876:	83 c0 01             	add    $0x1,%eax
  800879:	eb f0                	jmp    80086b <strfind+0xa>
			break;
	return (char *) s;
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 7d 08             	mov    0x8(%ebp),%edi
  800886:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 2f                	je     8008bc <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088d:	89 f8                	mov    %edi,%eax
  80088f:	09 c8                	or     %ecx,%eax
  800891:	a8 03                	test   $0x3,%al
  800893:	75 21                	jne    8008b6 <memset+0x39>
		c &= 0xFF;
  800895:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800899:	89 d0                	mov    %edx,%eax
  80089b:	c1 e0 08             	shl    $0x8,%eax
  80089e:	89 d3                	mov    %edx,%ebx
  8008a0:	c1 e3 18             	shl    $0x18,%ebx
  8008a3:	89 d6                	mov    %edx,%esi
  8008a5:	c1 e6 10             	shl    $0x10,%esi
  8008a8:	09 f3                	or     %esi,%ebx
  8008aa:	09 da                	or     %ebx,%edx
  8008ac:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ae:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008b1:	fc                   	cld    
  8008b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b4:	eb 06                	jmp    8008bc <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b9:	fc                   	cld    
  8008ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bc:	89 f8                	mov    %edi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	57                   	push   %edi
  8008c7:	56                   	push   %esi
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d1:	39 c6                	cmp    %eax,%esi
  8008d3:	73 32                	jae    800907 <memmove+0x44>
  8008d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d8:	39 c2                	cmp    %eax,%edx
  8008da:	76 2b                	jbe    800907 <memmove+0x44>
		s += n;
		d += n;
  8008dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008df:	89 d6                	mov    %edx,%esi
  8008e1:	09 fe                	or     %edi,%esi
  8008e3:	09 ce                	or     %ecx,%esi
  8008e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008eb:	75 0e                	jne    8008fb <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ed:	83 ef 04             	sub    $0x4,%edi
  8008f0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008f6:	fd                   	std    
  8008f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f9:	eb 09                	jmp    800904 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fb:	83 ef 01             	sub    $0x1,%edi
  8008fe:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800901:	fd                   	std    
  800902:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800904:	fc                   	cld    
  800905:	eb 1a                	jmp    800921 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800907:	89 f2                	mov    %esi,%edx
  800909:	09 c2                	or     %eax,%edx
  80090b:	09 ca                	or     %ecx,%edx
  80090d:	f6 c2 03             	test   $0x3,%dl
  800910:	75 0a                	jne    80091c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800912:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800915:	89 c7                	mov    %eax,%edi
  800917:	fc                   	cld    
  800918:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091a:	eb 05                	jmp    800921 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80091c:	89 c7                	mov    %eax,%edi
  80091e:	fc                   	cld    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80092b:	ff 75 10             	push   0x10(%ebp)
  80092e:	ff 75 0c             	push   0xc(%ebp)
  800931:	ff 75 08             	push   0x8(%ebp)
  800934:	e8 8a ff ff ff       	call   8008c3 <memmove>
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	89 c6                	mov    %eax,%esi
  800948:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	eb 06                	jmp    800953 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800953:	39 f0                	cmp    %esi,%eax
  800955:	74 14                	je     80096b <memcmp+0x30>
		if (*s1 != *s2)
  800957:	0f b6 08             	movzbl (%eax),%ecx
  80095a:	0f b6 1a             	movzbl (%edx),%ebx
  80095d:	38 d9                	cmp    %bl,%cl
  80095f:	74 ec                	je     80094d <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c1             	movzbl %cl,%eax
  800964:	0f b6 db             	movzbl %bl,%ebx
  800967:	29 d8                	sub    %ebx,%eax
  800969:	eb 05                	jmp    800970 <memcmp+0x35>
	}

	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800982:	eb 03                	jmp    800987 <memfind+0x13>
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	39 d0                	cmp    %edx,%eax
  800989:	73 04                	jae    80098f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	38 08                	cmp    %cl,(%eax)
  80098d:	75 f5                	jne    800984 <memfind+0x10>
			break;
	return (void *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 55 08             	mov    0x8(%ebp),%edx
  80099a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099d:	eb 03                	jmp    8009a2 <strtol+0x11>
		s++;
  80099f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009a2:	0f b6 02             	movzbl (%edx),%eax
  8009a5:	3c 20                	cmp    $0x20,%al
  8009a7:	74 f6                	je     80099f <strtol+0xe>
  8009a9:	3c 09                	cmp    $0x9,%al
  8009ab:	74 f2                	je     80099f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ad:	3c 2b                	cmp    $0x2b,%al
  8009af:	74 2a                	je     8009db <strtol+0x4a>
	int neg = 0;
  8009b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009b6:	3c 2d                	cmp    $0x2d,%al
  8009b8:	74 2b                	je     8009e5 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c0:	75 0f                	jne    8009d1 <strtol+0x40>
  8009c2:	80 3a 30             	cmpb   $0x30,(%edx)
  8009c5:	74 28                	je     8009ef <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c7:	85 db                	test   %ebx,%ebx
  8009c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ce:	0f 44 d8             	cmove  %eax,%ebx
  8009d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d9:	eb 46                	jmp    800a21 <strtol+0x90>
		s++;
  8009db:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009de:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e3:	eb d5                	jmp    8009ba <strtol+0x29>
		s++, neg = 1;
  8009e5:	83 c2 01             	add    $0x1,%edx
  8009e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ed:	eb cb                	jmp    8009ba <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f3:	74 0e                	je     800a03 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	75 d8                	jne    8009d1 <strtol+0x40>
		s++, base = 8;
  8009f9:	83 c2 01             	add    $0x1,%edx
  8009fc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a01:	eb ce                	jmp    8009d1 <strtol+0x40>
		s += 2, base = 16;
  800a03:	83 c2 02             	add    $0x2,%edx
  800a06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0b:	eb c4                	jmp    8009d1 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a0d:	0f be c0             	movsbl %al,%eax
  800a10:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a13:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a16:	7d 3a                	jge    800a52 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a1f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a21:	0f b6 02             	movzbl (%edx),%eax
  800a24:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a27:	89 f3                	mov    %esi,%ebx
  800a29:	80 fb 09             	cmp    $0x9,%bl
  800a2c:	76 df                	jbe    800a0d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a2e:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a31:	89 f3                	mov    %esi,%ebx
  800a33:	80 fb 19             	cmp    $0x19,%bl
  800a36:	77 08                	ja     800a40 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a38:	0f be c0             	movsbl %al,%eax
  800a3b:	83 e8 57             	sub    $0x57,%eax
  800a3e:	eb d3                	jmp    800a13 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a43:	89 f3                	mov    %esi,%ebx
  800a45:	80 fb 19             	cmp    $0x19,%bl
  800a48:	77 08                	ja     800a52 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a4a:	0f be c0             	movsbl %al,%eax
  800a4d:	83 e8 37             	sub    $0x37,%eax
  800a50:	eb c1                	jmp    800a13 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a56:	74 05                	je     800a5d <strtol+0xcc>
		*endptr = (char *) s;
  800a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a5d:	89 c8                	mov    %ecx,%eax
  800a5f:	f7 d8                	neg    %eax
  800a61:	85 ff                	test   %edi,%edi
  800a63:	0f 45 c8             	cmovne %eax,%ecx
}
  800a66:	89 c8                	mov    %ecx,%eax
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7e:	89 c3                	mov    %eax,%ebx
  800a80:	89 c7                	mov    %eax,%edi
  800a82:	89 c6                	mov    %eax,%esi
  800a84:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9b:	89 d1                	mov    %edx,%ecx
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ab3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac0:	89 cb                	mov    %ecx,%ebx
  800ac2:	89 cf                	mov    %ecx,%edi
  800ac4:	89 ce                	mov    %ecx,%esi
  800ac6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	7f 08                	jg     800ad4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	50                   	push   %eax
  800ad8:	6a 03                	push   $0x3
  800ada:	68 bf 20 80 00       	push   $0x8020bf
  800adf:	6a 2a                	push   $0x2a
  800ae1:	68 dc 20 80 00       	push   $0x8020dc
  800ae6:	e8 d0 0e 00 00       	call   8019bb <_panic>

00800aeb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	b8 02 00 00 00       	mov    $0x2,%eax
  800afb:	89 d1                	mov    %edx,%ecx
  800afd:	89 d3                	mov    %edx,%ebx
  800aff:	89 d7                	mov    %edx,%edi
  800b01:	89 d6                	mov    %edx,%esi
  800b03:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_yield>:

void
sys_yield(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b32:	be 00 00 00 00       	mov    $0x0,%esi
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b45:	89 f7                	mov    %esi,%edi
  800b47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	7f 08                	jg     800b55 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	50                   	push   %eax
  800b59:	6a 04                	push   $0x4
  800b5b:	68 bf 20 80 00       	push   $0x8020bf
  800b60:	6a 2a                	push   $0x2a
  800b62:	68 dc 20 80 00       	push   $0x8020dc
  800b67:	e8 4f 0e 00 00       	call   8019bb <_panic>

00800b6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b86:	8b 75 18             	mov    0x18(%ebp),%esi
  800b89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7f 08                	jg     800b97 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 05                	push   $0x5
  800b9d:	68 bf 20 80 00       	push   $0x8020bf
  800ba2:	6a 2a                	push   $0x2a
  800ba4:	68 dc 20 80 00       	push   $0x8020dc
  800ba9:	e8 0d 0e 00 00       	call   8019bb <_panic>

00800bae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc7:	89 df                	mov    %ebx,%edi
  800bc9:	89 de                	mov    %ebx,%esi
  800bcb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	7f 08                	jg     800bd9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	50                   	push   %eax
  800bdd:	6a 06                	push   $0x6
  800bdf:	68 bf 20 80 00       	push   $0x8020bf
  800be4:	6a 2a                	push   $0x2a
  800be6:	68 dc 20 80 00       	push   $0x8020dc
  800beb:	e8 cb 0d 00 00       	call   8019bb <_panic>

00800bf0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 08 00 00 00       	mov    $0x8,%eax
  800c09:	89 df                	mov    %ebx,%edi
  800c0b:	89 de                	mov    %ebx,%esi
  800c0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7f 08                	jg     800c1b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	50                   	push   %eax
  800c1f:	6a 08                	push   $0x8
  800c21:	68 bf 20 80 00       	push   $0x8020bf
  800c26:	6a 2a                	push   $0x2a
  800c28:	68 dc 20 80 00       	push   $0x8020dc
  800c2d:	e8 89 0d 00 00       	call   8019bb <_panic>

00800c32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4b:	89 df                	mov    %ebx,%edi
  800c4d:	89 de                	mov    %ebx,%esi
  800c4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7f 08                	jg     800c5d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 09                	push   $0x9
  800c63:	68 bf 20 80 00       	push   $0x8020bf
  800c68:	6a 2a                	push   $0x2a
  800c6a:	68 dc 20 80 00       	push   $0x8020dc
  800c6f:	e8 47 0d 00 00       	call   8019bb <_panic>

00800c74 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7f 08                	jg     800c9f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 0a                	push   $0xa
  800ca5:	68 bf 20 80 00       	push   $0x8020bf
  800caa:	6a 2a                	push   $0x2a
  800cac:	68 dc 20 80 00       	push   $0x8020dc
  800cb1:	e8 05 0d 00 00       	call   8019bb <_panic>

00800cb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc7:	be 00 00 00 00       	mov    $0x0,%esi
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cef:	89 cb                	mov    %ecx,%ebx
  800cf1:	89 cf                	mov    %ecx,%edi
  800cf3:	89 ce                	mov    %ecx,%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 0d                	push   $0xd
  800d09:	68 bf 20 80 00       	push   $0x8020bf
  800d0e:	6a 2a                	push   $0x2a
  800d10:	68 dc 20 80 00       	push   $0x8020dc
  800d15:	e8 a1 0c 00 00       	call   8019bb <_panic>

00800d1a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	05 00 00 00 30       	add    $0x30000000,%eax
  800d25:	c1 e8 0c             	shr    $0xc,%eax
}
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d3a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	c1 ea 16             	shr    $0x16,%edx
  800d4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d55:	f6 c2 01             	test   $0x1,%dl
  800d58:	74 29                	je     800d83 <fd_alloc+0x42>
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	c1 ea 0c             	shr    $0xc,%edx
  800d5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d66:	f6 c2 01             	test   $0x1,%dl
  800d69:	74 18                	je     800d83 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800d6b:	05 00 10 00 00       	add    $0x1000,%eax
  800d70:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d75:	75 d2                	jne    800d49 <fd_alloc+0x8>
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800d7c:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800d81:	eb 05                	jmp    800d88 <fd_alloc+0x47>
			return 0;
  800d83:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 02                	mov    %eax,(%edx)
}
  800d8d:	89 c8                	mov    %ecx,%eax
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d97:	83 f8 1f             	cmp    $0x1f,%eax
  800d9a:	77 30                	ja     800dcc <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d9c:	c1 e0 0c             	shl    $0xc,%eax
  800d9f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800da4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800daa:	f6 c2 01             	test   $0x1,%dl
  800dad:	74 24                	je     800dd3 <fd_lookup+0x42>
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	c1 ea 0c             	shr    $0xc,%edx
  800db4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbb:	f6 c2 01             	test   $0x1,%dl
  800dbe:	74 1a                	je     800dda <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc3:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
		return -E_INVAL;
  800dcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd1:	eb f7                	jmp    800dca <fd_lookup+0x39>
		return -E_INVAL;
  800dd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd8:	eb f0                	jmp    800dca <fd_lookup+0x39>
  800dda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ddf:	eb e9                	jmp    800dca <fd_lookup+0x39>

00800de1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	53                   	push   %ebx
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	b8 68 21 80 00       	mov    $0x802168,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800df0:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800df5:	39 13                	cmp    %edx,(%ebx)
  800df7:	74 32                	je     800e2b <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800df9:	83 c0 04             	add    $0x4,%eax
  800dfc:	8b 18                	mov    (%eax),%ebx
  800dfe:	85 db                	test   %ebx,%ebx
  800e00:	75 f3                	jne    800df5 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e02:	a1 00 40 80 00       	mov    0x804000,%eax
  800e07:	8b 40 48             	mov    0x48(%eax),%eax
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	52                   	push   %edx
  800e0e:	50                   	push   %eax
  800e0f:	68 ec 20 80 00       	push   $0x8020ec
  800e14:	e8 3a f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e24:	89 1a                	mov    %ebx,(%edx)
}
  800e26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    
			return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e30:	eb ef                	jmp    800e21 <dev_lookup+0x40>

00800e32 <fd_close>:
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 24             	sub    $0x24,%esp
  800e3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e41:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e44:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e45:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e4b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e4e:	50                   	push   %eax
  800e4f:	e8 3d ff ff ff       	call   800d91 <fd_lookup>
  800e54:	89 c3                	mov    %eax,%ebx
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 05                	js     800e62 <fd_close+0x30>
	    || fd != fd2)
  800e5d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e60:	74 16                	je     800e78 <fd_close+0x46>
		return (must_exist ? r : 0);
  800e62:	89 f8                	mov    %edi,%eax
  800e64:	84 c0                	test   %al,%al
  800e66:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6b:	0f 44 d8             	cmove  %eax,%ebx
}
  800e6e:	89 d8                	mov    %ebx,%eax
  800e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e7e:	50                   	push   %eax
  800e7f:	ff 36                	push   (%esi)
  800e81:	e8 5b ff ff ff       	call   800de1 <dev_lookup>
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	78 1a                	js     800ea9 <fd_close+0x77>
		if (dev->dev_close)
  800e8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e92:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e95:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	74 0b                	je     800ea9 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	56                   	push   %esi
  800ea2:	ff d0                	call   *%eax
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	56                   	push   %esi
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 fa fc ff ff       	call   800bae <sys_page_unmap>
	return r;
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	eb b5                	jmp    800e6e <fd_close+0x3c>

00800eb9 <close>:

int
close(int fdnum)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec2:	50                   	push   %eax
  800ec3:	ff 75 08             	push   0x8(%ebp)
  800ec6:	e8 c6 fe ff ff       	call   800d91 <fd_lookup>
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	79 02                	jns    800ed4 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    
		return fd_close(fd, 1);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	6a 01                	push   $0x1
  800ed9:	ff 75 f4             	push   -0xc(%ebp)
  800edc:	e8 51 ff ff ff       	call   800e32 <fd_close>
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	eb ec                	jmp    800ed2 <close+0x19>

00800ee6 <close_all>:

void
close_all(void)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	53                   	push   %ebx
  800ef6:	e8 be ff ff ff       	call   800eb9 <close>
	for (i = 0; i < MAXFD; i++)
  800efb:	83 c3 01             	add    $0x1,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	83 fb 20             	cmp    $0x20,%ebx
  800f04:	75 ec                	jne    800ef2 <close_all+0xc>
}
  800f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f14:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f17:	50                   	push   %eax
  800f18:	ff 75 08             	push   0x8(%ebp)
  800f1b:	e8 71 fe ff ff       	call   800d91 <fd_lookup>
  800f20:	89 c3                	mov    %eax,%ebx
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	85 c0                	test   %eax,%eax
  800f27:	78 7f                	js     800fa8 <dup+0x9d>
		return r;
	close(newfdnum);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	ff 75 0c             	push   0xc(%ebp)
  800f2f:	e8 85 ff ff ff       	call   800eb9 <close>

	newfd = INDEX2FD(newfdnum);
  800f34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f37:	c1 e6 0c             	shl    $0xc,%esi
  800f3a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f43:	89 3c 24             	mov    %edi,(%esp)
  800f46:	e8 df fd ff ff       	call   800d2a <fd2data>
  800f4b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f4d:	89 34 24             	mov    %esi,(%esp)
  800f50:	e8 d5 fd ff ff       	call   800d2a <fd2data>
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f5b:	89 d8                	mov    %ebx,%eax
  800f5d:	c1 e8 16             	shr    $0x16,%eax
  800f60:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f67:	a8 01                	test   $0x1,%al
  800f69:	74 11                	je     800f7c <dup+0x71>
  800f6b:	89 d8                	mov    %ebx,%eax
  800f6d:	c1 e8 0c             	shr    $0xc,%eax
  800f70:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f77:	f6 c2 01             	test   $0x1,%dl
  800f7a:	75 36                	jne    800fb2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f7c:	89 f8                	mov    %edi,%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
  800f81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f90:	50                   	push   %eax
  800f91:	56                   	push   %esi
  800f92:	6a 00                	push   $0x0
  800f94:	57                   	push   %edi
  800f95:	6a 00                	push   $0x0
  800f97:	e8 d0 fb ff ff       	call   800b6c <sys_page_map>
  800f9c:	89 c3                	mov    %eax,%ebx
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 33                	js     800fd8 <dup+0xcd>
		goto err;

	return newfdnum;
  800fa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fa8:	89 d8                	mov    %ebx,%eax
  800faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb9:	83 ec 0c             	sub    $0xc,%esp
  800fbc:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc1:	50                   	push   %eax
  800fc2:	ff 75 d4             	push   -0x2c(%ebp)
  800fc5:	6a 00                	push   $0x0
  800fc7:	53                   	push   %ebx
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 9d fb ff ff       	call   800b6c <sys_page_map>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	79 a4                	jns    800f7c <dup+0x71>
	sys_page_unmap(0, newfd);
  800fd8:	83 ec 08             	sub    $0x8,%esp
  800fdb:	56                   	push   %esi
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 cb fb ff ff       	call   800bae <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe3:	83 c4 08             	add    $0x8,%esp
  800fe6:	ff 75 d4             	push   -0x2c(%ebp)
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 be fb ff ff       	call   800bae <sys_page_unmap>
	return r;
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	eb b3                	jmp    800fa8 <dup+0x9d>

00800ff5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 18             	sub    $0x18,%esp
  800ffd:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801000:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	56                   	push   %esi
  801005:	e8 87 fd ff ff       	call   800d91 <fd_lookup>
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 3c                	js     80104d <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801011:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101a:	50                   	push   %eax
  80101b:	ff 33                	push   (%ebx)
  80101d:	e8 bf fd ff ff       	call   800de1 <dev_lookup>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 24                	js     80104d <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801029:	8b 43 08             	mov    0x8(%ebx),%eax
  80102c:	83 e0 03             	and    $0x3,%eax
  80102f:	83 f8 01             	cmp    $0x1,%eax
  801032:	74 20                	je     801054 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801037:	8b 40 08             	mov    0x8(%eax),%eax
  80103a:	85 c0                	test   %eax,%eax
  80103c:	74 37                	je     801075 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80103e:	83 ec 04             	sub    $0x4,%esp
  801041:	ff 75 10             	push   0x10(%ebp)
  801044:	ff 75 0c             	push   0xc(%ebp)
  801047:	53                   	push   %ebx
  801048:	ff d0                	call   *%eax
  80104a:	83 c4 10             	add    $0x10,%esp
}
  80104d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801054:	a1 00 40 80 00       	mov    0x804000,%eax
  801059:	8b 40 48             	mov    0x48(%eax),%eax
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	56                   	push   %esi
  801060:	50                   	push   %eax
  801061:	68 2d 21 80 00       	push   $0x80212d
  801066:	e8 e8 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801073:	eb d8                	jmp    80104d <read+0x58>
		return -E_NOT_SUPP;
  801075:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80107a:	eb d1                	jmp    80104d <read+0x58>

0080107c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	8b 7d 08             	mov    0x8(%ebp),%edi
  801088:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801090:	eb 02                	jmp    801094 <readn+0x18>
  801092:	01 c3                	add    %eax,%ebx
  801094:	39 f3                	cmp    %esi,%ebx
  801096:	73 21                	jae    8010b9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	89 f0                	mov    %esi,%eax
  80109d:	29 d8                	sub    %ebx,%eax
  80109f:	50                   	push   %eax
  8010a0:	89 d8                	mov    %ebx,%eax
  8010a2:	03 45 0c             	add    0xc(%ebp),%eax
  8010a5:	50                   	push   %eax
  8010a6:	57                   	push   %edi
  8010a7:	e8 49 ff ff ff       	call   800ff5 <read>
		if (m < 0)
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 04                	js     8010b7 <readn+0x3b>
			return m;
		if (m == 0)
  8010b3:	75 dd                	jne    801092 <readn+0x16>
  8010b5:	eb 02                	jmp    8010b9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 18             	sub    $0x18,%esp
  8010cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	53                   	push   %ebx
  8010d3:	e8 b9 fc ff ff       	call   800d91 <fd_lookup>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 37                	js     801116 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010df:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	ff 36                	push   (%esi)
  8010eb:	e8 f1 fc ff ff       	call   800de1 <dev_lookup>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 1f                	js     801116 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010f7:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8010fb:	74 20                	je     80111d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801100:	8b 40 0c             	mov    0xc(%eax),%eax
  801103:	85 c0                	test   %eax,%eax
  801105:	74 37                	je     80113e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	ff 75 10             	push   0x10(%ebp)
  80110d:	ff 75 0c             	push   0xc(%ebp)
  801110:	56                   	push   %esi
  801111:	ff d0                	call   *%eax
  801113:	83 c4 10             	add    $0x10,%esp
}
  801116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80111d:	a1 00 40 80 00       	mov    0x804000,%eax
  801122:	8b 40 48             	mov    0x48(%eax),%eax
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	53                   	push   %ebx
  801129:	50                   	push   %eax
  80112a:	68 49 21 80 00       	push   $0x802149
  80112f:	e8 1f f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113c:	eb d8                	jmp    801116 <write+0x53>
		return -E_NOT_SUPP;
  80113e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801143:	eb d1                	jmp    801116 <write+0x53>

00801145 <seek>:

int
seek(int fdnum, off_t offset)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114e:	50                   	push   %eax
  80114f:	ff 75 08             	push   0x8(%ebp)
  801152:	e8 3a fc ff ff       	call   800d91 <fd_lookup>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 0e                	js     80116c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80115e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801164:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801167:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 18             	sub    $0x18,%esp
  801176:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801179:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	53                   	push   %ebx
  80117e:	e8 0e fc ff ff       	call   800d91 <fd_lookup>
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	85 c0                	test   %eax,%eax
  801188:	78 34                	js     8011be <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	ff 36                	push   (%esi)
  801196:	e8 46 fc ff ff       	call   800de1 <dev_lookup>
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 1c                	js     8011be <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a2:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011a6:	74 1d                	je     8011c5 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ab:	8b 40 18             	mov    0x18(%eax),%eax
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	74 34                	je     8011e6 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	ff 75 0c             	push   0xc(%ebp)
  8011b8:	56                   	push   %esi
  8011b9:	ff d0                	call   *%eax
  8011bb:	83 c4 10             	add    $0x10,%esp
}
  8011be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8011c5:	a1 00 40 80 00       	mov    0x804000,%eax
  8011ca:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	53                   	push   %ebx
  8011d1:	50                   	push   %eax
  8011d2:	68 0c 21 80 00       	push   $0x80210c
  8011d7:	e8 77 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb d8                	jmp    8011be <ftruncate+0x50>
		return -E_NOT_SUPP;
  8011e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011eb:	eb d1                	jmp    8011be <ftruncate+0x50>

008011ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	56                   	push   %esi
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 18             	sub    $0x18,%esp
  8011f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	ff 75 08             	push   0x8(%ebp)
  8011ff:	e8 8d fb ff ff       	call   800d91 <fd_lookup>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 49                	js     801254 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	ff 36                	push   (%esi)
  801217:	e8 c5 fb ff ff       	call   800de1 <dev_lookup>
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 31                	js     801254 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801223:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801226:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80122a:	74 2f                	je     80125b <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80122c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80122f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801236:	00 00 00 
	stat->st_isdir = 0;
  801239:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801240:	00 00 00 
	stat->st_dev = dev;
  801243:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	53                   	push   %ebx
  80124d:	56                   	push   %esi
  80124e:	ff 50 14             	call   *0x14(%eax)
  801251:	83 c4 10             	add    $0x10,%esp
}
  801254:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    
		return -E_NOT_SUPP;
  80125b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801260:	eb f2                	jmp    801254 <fstat+0x67>

00801262 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	6a 00                	push   $0x0
  80126c:	ff 75 08             	push   0x8(%ebp)
  80126f:	e8 e4 01 00 00       	call   801458 <open>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 1b                	js     801298 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	ff 75 0c             	push   0xc(%ebp)
  801283:	50                   	push   %eax
  801284:	e8 64 ff ff ff       	call   8011ed <fstat>
  801289:	89 c6                	mov    %eax,%esi
	close(fd);
  80128b:	89 1c 24             	mov    %ebx,(%esp)
  80128e:	e8 26 fc ff ff       	call   800eb9 <close>
	return r;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	89 f3                	mov    %esi,%ebx
}
  801298:	89 d8                	mov    %ebx,%eax
  80129a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	89 c6                	mov    %eax,%esi
  8012a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012aa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8012b1:	74 27                	je     8012da <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012b3:	6a 07                	push   $0x7
  8012b5:	68 00 50 80 00       	push   $0x805000
  8012ba:	56                   	push   %esi
  8012bb:	ff 35 00 60 80 00    	push   0x806000
  8012c1:	e8 a2 07 00 00       	call   801a68 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012c6:	83 c4 0c             	add    $0xc,%esp
  8012c9:	6a 00                	push   $0x0
  8012cb:	53                   	push   %ebx
  8012cc:	6a 00                	push   $0x0
  8012ce:	e8 2e 07 00 00       	call   801a01 <ipc_recv>
}
  8012d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	6a 01                	push   $0x1
  8012df:	e8 d8 07 00 00       	call   801abc <ipc_find_env>
  8012e4:	a3 00 60 80 00       	mov    %eax,0x806000
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	eb c5                	jmp    8012b3 <fsipc+0x12>

008012ee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012fa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801302:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801307:	ba 00 00 00 00       	mov    $0x0,%edx
  80130c:	b8 02 00 00 00       	mov    $0x2,%eax
  801311:	e8 8b ff ff ff       	call   8012a1 <fsipc>
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <devfile_flush>:
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80131e:	8b 45 08             	mov    0x8(%ebp),%eax
  801321:	8b 40 0c             	mov    0xc(%eax),%eax
  801324:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801329:	ba 00 00 00 00       	mov    $0x0,%edx
  80132e:	b8 06 00 00 00       	mov    $0x6,%eax
  801333:	e8 69 ff ff ff       	call   8012a1 <fsipc>
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <devfile_stat>:
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 04             	sub    $0x4,%esp
  801341:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801344:	8b 45 08             	mov    0x8(%ebp),%eax
  801347:	8b 40 0c             	mov    0xc(%eax),%eax
  80134a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80134f:	ba 00 00 00 00       	mov    $0x0,%edx
  801354:	b8 05 00 00 00       	mov    $0x5,%eax
  801359:	e8 43 ff ff ff       	call   8012a1 <fsipc>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 2c                	js     80138e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	68 00 50 80 00       	push   $0x805000
  80136a:	53                   	push   %ebx
  80136b:	e8 bd f3 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801370:	a1 80 50 80 00       	mov    0x805080,%eax
  801375:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80137b:	a1 84 50 80 00       	mov    0x805084,%eax
  801380:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <devfile_write>:
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	8b 45 10             	mov    0x10(%ebp),%eax
  80139c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013a1:	39 d0                	cmp    %edx,%eax
  8013a3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ac:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013b2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013b7:	50                   	push   %eax
  8013b8:	ff 75 0c             	push   0xc(%ebp)
  8013bb:	68 08 50 80 00       	push   $0x805008
  8013c0:	e8 fe f4 ff ff       	call   8008c3 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8013c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8013cf:	e8 cd fe ff ff       	call   8012a1 <fsipc>
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <devfile_read>:
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
  8013db:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013e9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8013f9:	e8 a3 fe ff ff       	call   8012a1 <fsipc>
  8013fe:	89 c3                	mov    %eax,%ebx
  801400:	85 c0                	test   %eax,%eax
  801402:	78 1f                	js     801423 <devfile_read+0x4d>
	assert(r <= n);
  801404:	39 f0                	cmp    %esi,%eax
  801406:	77 24                	ja     80142c <devfile_read+0x56>
	assert(r <= PGSIZE);
  801408:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80140d:	7f 33                	jg     801442 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	50                   	push   %eax
  801413:	68 00 50 80 00       	push   $0x805000
  801418:	ff 75 0c             	push   0xc(%ebp)
  80141b:	e8 a3 f4 ff ff       	call   8008c3 <memmove>
	return r;
  801420:	83 c4 10             	add    $0x10,%esp
}
  801423:	89 d8                	mov    %ebx,%eax
  801425:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    
	assert(r <= n);
  80142c:	68 78 21 80 00       	push   $0x802178
  801431:	68 7f 21 80 00       	push   $0x80217f
  801436:	6a 7c                	push   $0x7c
  801438:	68 94 21 80 00       	push   $0x802194
  80143d:	e8 79 05 00 00       	call   8019bb <_panic>
	assert(r <= PGSIZE);
  801442:	68 9f 21 80 00       	push   $0x80219f
  801447:	68 7f 21 80 00       	push   $0x80217f
  80144c:	6a 7d                	push   $0x7d
  80144e:	68 94 21 80 00       	push   $0x802194
  801453:	e8 63 05 00 00       	call   8019bb <_panic>

00801458 <open>:
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	83 ec 1c             	sub    $0x1c,%esp
  801460:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801463:	56                   	push   %esi
  801464:	e8 89 f2 ff ff       	call   8006f2 <strlen>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801471:	7f 6c                	jg     8014df <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	e8 c2 f8 ff ff       	call   800d41 <fd_alloc>
  80147f:	89 c3                	mov    %eax,%ebx
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 3c                	js     8014c4 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	56                   	push   %esi
  80148c:	68 00 50 80 00       	push   $0x805000
  801491:	e8 97 f2 ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801496:	8b 45 0c             	mov    0xc(%ebp),%eax
  801499:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a6:	e8 f6 fd ff ff       	call   8012a1 <fsipc>
  8014ab:	89 c3                	mov    %eax,%ebx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 19                	js     8014cd <open+0x75>
	return fd2num(fd);
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	ff 75 f4             	push   -0xc(%ebp)
  8014ba:	e8 5b f8 ff ff       	call   800d1a <fd2num>
  8014bf:	89 c3                	mov    %eax,%ebx
  8014c1:	83 c4 10             	add    $0x10,%esp
}
  8014c4:	89 d8                	mov    %ebx,%eax
  8014c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5e                   	pop    %esi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    
		fd_close(fd, 0);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	6a 00                	push   $0x0
  8014d2:	ff 75 f4             	push   -0xc(%ebp)
  8014d5:	e8 58 f9 ff ff       	call   800e32 <fd_close>
		return r;
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	eb e5                	jmp    8014c4 <open+0x6c>
		return -E_BAD_PATH;
  8014df:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014e4:	eb de                	jmp    8014c4 <open+0x6c>

008014e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f6:	e8 a6 fd ff ff       	call   8012a1 <fsipc>
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	ff 75 08             	push   0x8(%ebp)
  80150b:	e8 1a f8 ff ff       	call   800d2a <fd2data>
  801510:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	68 ab 21 80 00       	push   $0x8021ab
  80151a:	53                   	push   %ebx
  80151b:	e8 0d f2 ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801520:	8b 46 04             	mov    0x4(%esi),%eax
  801523:	2b 06                	sub    (%esi),%eax
  801525:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80152b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801532:	00 00 00 
	stat->st_dev = &devpipe;
  801535:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80153c:	30 80 00 
	return 0;
}
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
  801544:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801547:	5b                   	pop    %ebx
  801548:	5e                   	pop    %esi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 0c             	sub    $0xc,%esp
  801552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801555:	53                   	push   %ebx
  801556:	6a 00                	push   $0x0
  801558:	e8 51 f6 ff ff       	call   800bae <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80155d:	89 1c 24             	mov    %ebx,(%esp)
  801560:	e8 c5 f7 ff ff       	call   800d2a <fd2data>
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	50                   	push   %eax
  801569:	6a 00                	push   $0x0
  80156b:	e8 3e f6 ff ff       	call   800bae <sys_page_unmap>
}
  801570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <_pipeisclosed>:
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	57                   	push   %edi
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	83 ec 1c             	sub    $0x1c,%esp
  80157e:	89 c7                	mov    %eax,%edi
  801580:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801582:	a1 00 40 80 00       	mov    0x804000,%eax
  801587:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	57                   	push   %edi
  80158e:	e8 62 05 00 00       	call   801af5 <pageref>
  801593:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801596:	89 34 24             	mov    %esi,(%esp)
  801599:	e8 57 05 00 00       	call   801af5 <pageref>
		nn = thisenv->env_runs;
  80159e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8015a4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	39 cb                	cmp    %ecx,%ebx
  8015ac:	74 1b                	je     8015c9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015ae:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015b1:	75 cf                	jne    801582 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015b3:	8b 42 58             	mov    0x58(%edx),%eax
  8015b6:	6a 01                	push   $0x1
  8015b8:	50                   	push   %eax
  8015b9:	53                   	push   %ebx
  8015ba:	68 b2 21 80 00       	push   $0x8021b2
  8015bf:	e8 8f eb ff ff       	call   800153 <cprintf>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	eb b9                	jmp    801582 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015c9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015cc:	0f 94 c0             	sete   %al
  8015cf:	0f b6 c0             	movzbl %al,%eax
}
  8015d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5f                   	pop    %edi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <devpipe_write>:
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	57                   	push   %edi
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 28             	sub    $0x28,%esp
  8015e3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8015e6:	56                   	push   %esi
  8015e7:	e8 3e f7 ff ff       	call   800d2a <fd2data>
  8015ec:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015f9:	75 09                	jne    801604 <devpipe_write+0x2a>
	return i;
  8015fb:	89 f8                	mov    %edi,%eax
  8015fd:	eb 23                	jmp    801622 <devpipe_write+0x48>
			sys_yield();
  8015ff:	e8 06 f5 ff ff       	call   800b0a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801604:	8b 43 04             	mov    0x4(%ebx),%eax
  801607:	8b 0b                	mov    (%ebx),%ecx
  801609:	8d 51 20             	lea    0x20(%ecx),%edx
  80160c:	39 d0                	cmp    %edx,%eax
  80160e:	72 1a                	jb     80162a <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801610:	89 da                	mov    %ebx,%edx
  801612:	89 f0                	mov    %esi,%eax
  801614:	e8 5c ff ff ff       	call   801575 <_pipeisclosed>
  801619:	85 c0                	test   %eax,%eax
  80161b:	74 e2                	je     8015ff <devpipe_write+0x25>
				return 0;
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801622:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5f                   	pop    %edi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80162a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801631:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801634:	89 c2                	mov    %eax,%edx
  801636:	c1 fa 1f             	sar    $0x1f,%edx
  801639:	89 d1                	mov    %edx,%ecx
  80163b:	c1 e9 1b             	shr    $0x1b,%ecx
  80163e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801641:	83 e2 1f             	and    $0x1f,%edx
  801644:	29 ca                	sub    %ecx,%edx
  801646:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80164a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80164e:	83 c0 01             	add    $0x1,%eax
  801651:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801654:	83 c7 01             	add    $0x1,%edi
  801657:	eb 9d                	jmp    8015f6 <devpipe_write+0x1c>

00801659 <devpipe_read>:
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 18             	sub    $0x18,%esp
  801662:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801665:	57                   	push   %edi
  801666:	e8 bf f6 ff ff       	call   800d2a <fd2data>
  80166b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	be 00 00 00 00       	mov    $0x0,%esi
  801675:	3b 75 10             	cmp    0x10(%ebp),%esi
  801678:	75 13                	jne    80168d <devpipe_read+0x34>
	return i;
  80167a:	89 f0                	mov    %esi,%eax
  80167c:	eb 02                	jmp    801680 <devpipe_read+0x27>
				return i;
  80167e:	89 f0                	mov    %esi,%eax
}
  801680:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801683:	5b                   	pop    %ebx
  801684:	5e                   	pop    %esi
  801685:	5f                   	pop    %edi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    
			sys_yield();
  801688:	e8 7d f4 ff ff       	call   800b0a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80168d:	8b 03                	mov    (%ebx),%eax
  80168f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801692:	75 18                	jne    8016ac <devpipe_read+0x53>
			if (i > 0)
  801694:	85 f6                	test   %esi,%esi
  801696:	75 e6                	jne    80167e <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801698:	89 da                	mov    %ebx,%edx
  80169a:	89 f8                	mov    %edi,%eax
  80169c:	e8 d4 fe ff ff       	call   801575 <_pipeisclosed>
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	74 e3                	je     801688 <devpipe_read+0x2f>
				return 0;
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016aa:	eb d4                	jmp    801680 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ac:	99                   	cltd   
  8016ad:	c1 ea 1b             	shr    $0x1b,%edx
  8016b0:	01 d0                	add    %edx,%eax
  8016b2:	83 e0 1f             	and    $0x1f,%eax
  8016b5:	29 d0                	sub    %edx,%eax
  8016b7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016bf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016c2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016c5:	83 c6 01             	add    $0x1,%esi
  8016c8:	eb ab                	jmp    801675 <devpipe_read+0x1c>

008016ca <pipe>:
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	e8 66 f6 ff ff       	call   800d41 <fd_alloc>
  8016db:	89 c3                	mov    %eax,%ebx
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	0f 88 23 01 00 00    	js     80180b <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e8:	83 ec 04             	sub    $0x4,%esp
  8016eb:	68 07 04 00 00       	push   $0x407
  8016f0:	ff 75 f4             	push   -0xc(%ebp)
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 2f f4 ff ff       	call   800b29 <sys_page_alloc>
  8016fa:	89 c3                	mov    %eax,%ebx
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	0f 88 04 01 00 00    	js     80180b <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801707:	83 ec 0c             	sub    $0xc,%esp
  80170a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	e8 2e f6 ff ff       	call   800d41 <fd_alloc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 88 db 00 00 00    	js     8017fb <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801720:	83 ec 04             	sub    $0x4,%esp
  801723:	68 07 04 00 00       	push   $0x407
  801728:	ff 75 f0             	push   -0x10(%ebp)
  80172b:	6a 00                	push   $0x0
  80172d:	e8 f7 f3 ff ff       	call   800b29 <sys_page_alloc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	0f 88 bc 00 00 00    	js     8017fb <pipe+0x131>
	va = fd2data(fd0);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	ff 75 f4             	push   -0xc(%ebp)
  801745:	e8 e0 f5 ff ff       	call   800d2a <fd2data>
  80174a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174c:	83 c4 0c             	add    $0xc,%esp
  80174f:	68 07 04 00 00       	push   $0x407
  801754:	50                   	push   %eax
  801755:	6a 00                	push   $0x0
  801757:	e8 cd f3 ff ff       	call   800b29 <sys_page_alloc>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	0f 88 82 00 00 00    	js     8017eb <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	ff 75 f0             	push   -0x10(%ebp)
  80176f:	e8 b6 f5 ff ff       	call   800d2a <fd2data>
  801774:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80177b:	50                   	push   %eax
  80177c:	6a 00                	push   $0x0
  80177e:	56                   	push   %esi
  80177f:	6a 00                	push   $0x0
  801781:	e8 e6 f3 ff ff       	call   800b6c <sys_page_map>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 20             	add    $0x20,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 4e                	js     8017dd <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80178f:	a1 20 30 80 00       	mov    0x803020,%eax
  801794:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801797:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801799:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179c:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8017a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ab:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017b2:	83 ec 0c             	sub    $0xc,%esp
  8017b5:	ff 75 f4             	push   -0xc(%ebp)
  8017b8:	e8 5d f5 ff ff       	call   800d1a <fd2num>
  8017bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017c2:	83 c4 04             	add    $0x4,%esp
  8017c5:	ff 75 f0             	push   -0x10(%ebp)
  8017c8:	e8 4d f5 ff ff       	call   800d1a <fd2num>
  8017cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017db:	eb 2e                	jmp    80180b <pipe+0x141>
	sys_page_unmap(0, va);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	56                   	push   %esi
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 c6 f3 ff ff       	call   800bae <sys_page_unmap>
  8017e8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	ff 75 f0             	push   -0x10(%ebp)
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 b6 f3 ff ff       	call   800bae <sys_page_unmap>
  8017f8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	ff 75 f4             	push   -0xc(%ebp)
  801801:	6a 00                	push   $0x0
  801803:	e8 a6 f3 ff ff       	call   800bae <sys_page_unmap>
  801808:	83 c4 10             	add    $0x10,%esp
}
  80180b:	89 d8                	mov    %ebx,%eax
  80180d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <pipeisclosed>:
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	ff 75 08             	push   0x8(%ebp)
  801821:	e8 6b f5 ff ff       	call   800d91 <fd_lookup>
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 18                	js     801845 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	ff 75 f4             	push   -0xc(%ebp)
  801833:	e8 f2 f4 ff ff       	call   800d2a <fd2data>
  801838:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183d:	e8 33 fd ff ff       	call   801575 <_pipeisclosed>
  801842:	83 c4 10             	add    $0x10,%esp
}
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801847:	b8 00 00 00 00       	mov    $0x0,%eax
  80184c:	c3                   	ret    

0080184d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801853:	68 ca 21 80 00       	push   $0x8021ca
  801858:	ff 75 0c             	push   0xc(%ebp)
  80185b:	e8 cd ee ff ff       	call   80072d <strcpy>
	return 0;
}
  801860:	b8 00 00 00 00       	mov    $0x0,%eax
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devcons_write>:
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	57                   	push   %edi
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801873:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801878:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80187e:	eb 2e                	jmp    8018ae <devcons_write+0x47>
		m = n - tot;
  801880:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801883:	29 f3                	sub    %esi,%ebx
  801885:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80188a:	39 c3                	cmp    %eax,%ebx
  80188c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80188f:	83 ec 04             	sub    $0x4,%esp
  801892:	53                   	push   %ebx
  801893:	89 f0                	mov    %esi,%eax
  801895:	03 45 0c             	add    0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	57                   	push   %edi
  80189a:	e8 24 f0 ff ff       	call   8008c3 <memmove>
		sys_cputs(buf, m);
  80189f:	83 c4 08             	add    $0x8,%esp
  8018a2:	53                   	push   %ebx
  8018a3:	57                   	push   %edi
  8018a4:	e8 c4 f1 ff ff       	call   800a6d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018a9:	01 de                	add    %ebx,%esi
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b1:	72 cd                	jb     801880 <devcons_write+0x19>
}
  8018b3:	89 f0                	mov    %esi,%eax
  8018b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	5f                   	pop    %edi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <devcons_read>:
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8018c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018cc:	75 07                	jne    8018d5 <devcons_read+0x18>
  8018ce:	eb 1f                	jmp    8018ef <devcons_read+0x32>
		sys_yield();
  8018d0:	e8 35 f2 ff ff       	call   800b0a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8018d5:	e8 b1 f1 ff ff       	call   800a8b <sys_cgetc>
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	74 f2                	je     8018d0 <devcons_read+0x13>
	if (c < 0)
  8018de:	78 0f                	js     8018ef <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8018e0:	83 f8 04             	cmp    $0x4,%eax
  8018e3:	74 0c                	je     8018f1 <devcons_read+0x34>
	*(char*)vbuf = c;
  8018e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e8:	88 02                	mov    %al,(%edx)
	return 1;
  8018ea:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    
		return 0;
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	eb f7                	jmp    8018ef <devcons_read+0x32>

008018f8 <cputchar>:
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801904:	6a 01                	push   $0x1
  801906:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801909:	50                   	push   %eax
  80190a:	e8 5e f1 ff ff       	call   800a6d <sys_cputs>
}
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <getchar>:
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80191a:	6a 01                	push   $0x1
  80191c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80191f:	50                   	push   %eax
  801920:	6a 00                	push   $0x0
  801922:	e8 ce f6 ff ff       	call   800ff5 <read>
	if (r < 0)
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 06                	js     801934 <getchar+0x20>
	if (r < 1)
  80192e:	74 06                	je     801936 <getchar+0x22>
	return c;
  801930:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    
		return -E_EOF;
  801936:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80193b:	eb f7                	jmp    801934 <getchar+0x20>

0080193d <iscons>:
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	ff 75 08             	push   0x8(%ebp)
  80194a:	e8 42 f4 ff ff       	call   800d91 <fd_lookup>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	78 11                	js     801967 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801959:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80195f:	39 10                	cmp    %edx,(%eax)
  801961:	0f 94 c0             	sete   %al
  801964:	0f b6 c0             	movzbl %al,%eax
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <opencons>:
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80196f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	e8 c9 f3 ff ff       	call   800d41 <fd_alloc>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 3a                	js     8019b9 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80197f:	83 ec 04             	sub    $0x4,%esp
  801982:	68 07 04 00 00       	push   $0x407
  801987:	ff 75 f4             	push   -0xc(%ebp)
  80198a:	6a 00                	push   $0x0
  80198c:	e8 98 f1 ff ff       	call   800b29 <sys_page_alloc>
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	78 21                	js     8019b9 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	50                   	push   %eax
  8019b1:	e8 64 f3 ff ff       	call   800d1a <fd2num>
  8019b6:	83 c4 10             	add    $0x10,%esp
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019c3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019c9:	e8 1d f1 ff ff       	call   800aeb <sys_getenvid>
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	ff 75 0c             	push   0xc(%ebp)
  8019d4:	ff 75 08             	push   0x8(%ebp)
  8019d7:	56                   	push   %esi
  8019d8:	50                   	push   %eax
  8019d9:	68 d8 21 80 00       	push   $0x8021d8
  8019de:	e8 70 e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019e3:	83 c4 18             	add    $0x18,%esp
  8019e6:	53                   	push   %ebx
  8019e7:	ff 75 10             	push   0x10(%ebp)
  8019ea:	e8 13 e7 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  8019ef:	c7 04 24 c3 21 80 00 	movl   $0x8021c3,(%esp)
  8019f6:	e8 58 e7 ff ff       	call   800153 <cprintf>
  8019fb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019fe:	cc                   	int3   
  8019ff:	eb fd                	jmp    8019fe <_panic+0x43>

00801a01 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	8b 75 08             	mov    0x8(%ebp),%esi
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a16:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	50                   	push   %eax
  801a1d:	e8 b7 f2 ff ff       	call   800cd9 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 f6                	test   %esi,%esi
  801a27:	74 14                	je     801a3d <ipc_recv+0x3c>
  801a29:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 09                	js     801a3b <ipc_recv+0x3a>
  801a32:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a38:	8b 52 74             	mov    0x74(%edx),%edx
  801a3b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a3d:	85 db                	test   %ebx,%ebx
  801a3f:	74 14                	je     801a55 <ipc_recv+0x54>
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 09                	js     801a53 <ipc_recv+0x52>
  801a4a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a50:	8b 52 78             	mov    0x78(%edx),%edx
  801a53:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 08                	js     801a61 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a59:	a1 00 40 80 00       	mov    0x804000,%eax
  801a5e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	57                   	push   %edi
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a7a:	85 db                	test   %ebx,%ebx
  801a7c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a81:	0f 44 d8             	cmove  %eax,%ebx
  801a84:	eb 05                	jmp    801a8b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a86:	e8 7f f0 ff ff       	call   800b0a <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a8b:	ff 75 14             	push   0x14(%ebp)
  801a8e:	53                   	push   %ebx
  801a8f:	56                   	push   %esi
  801a90:	57                   	push   %edi
  801a91:	e8 20 f2 ff ff       	call   800cb6 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9c:	74 e8                	je     801a86 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 08                	js     801aaa <ipc_send+0x42>
	}while (r<0);

}
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801aaa:	50                   	push   %eax
  801aab:	68 fb 21 80 00       	push   $0x8021fb
  801ab0:	6a 3d                	push   $0x3d
  801ab2:	68 0f 22 80 00       	push   $0x80220f
  801ab7:	e8 ff fe ff ff       	call   8019bb <_panic>

00801abc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad0:	8b 52 50             	mov    0x50(%edx),%edx
  801ad3:	39 ca                	cmp    %ecx,%edx
  801ad5:	74 11                	je     801ae8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ad7:	83 c0 01             	add    $0x1,%eax
  801ada:	3d 00 04 00 00       	cmp    $0x400,%eax
  801adf:	75 e6                	jne    801ac7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae6:	eb 0b                	jmp    801af3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801ae8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aeb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afb:	89 c2                	mov    %eax,%edx
  801afd:	c1 ea 16             	shr    $0x16,%edx
  801b00:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b07:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	f6 c1 01             	test   $0x1,%cl
  801b0f:	74 1c                	je     801b2d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b11:	c1 e8 0c             	shr    $0xc,%eax
  801b14:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b1b:	a8 01                	test   $0x1,%al
  801b1d:	74 0e                	je     801b2d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b1f:	c1 e8 0c             	shr    $0xc,%eax
  801b22:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b29:	ef 
  801b2a:	0f b7 d2             	movzwl %dx,%edx
}
  801b2d:	89 d0                	mov    %edx,%eax
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    
  801b31:	66 90                	xchg   %ax,%ax
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
