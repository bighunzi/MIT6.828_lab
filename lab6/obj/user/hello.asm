
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
  800039:	68 40 22 80 00       	push   $0x802240
  80003e:	e8 10 01 00 00       	call   800153 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 00 40 80 00       	mov    0x804000,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 4e 22 80 00       	push   $0x80224e
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
  8000aa:	e8 9d 0e 00 00       	call   800f4c <close_all>
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
  8001b5:	e8 46 1e 00 00       	call   802000 <__udivdi3>
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
  8001f3:	e8 28 1f 00 00       	call   802120 <__umoddi3>
  8001f8:	83 c4 14             	add    $0x14,%esp
  8001fb:	0f be 80 6f 22 80 00 	movsbl 0x80226f(%eax),%eax
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
  8002b5:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  800383:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 18                	je     8003a6 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80038e:	52                   	push   %edx
  80038f:	68 55 26 80 00       	push   $0x802655
  800394:	53                   	push   %ebx
  800395:	56                   	push   %esi
  800396:	e8 92 fe ff ff       	call   80022d <printfmt>
  80039b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039e:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a1:	e9 66 02 00 00       	jmp    80060c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003a6:	50                   	push   %eax
  8003a7:	68 87 22 80 00       	push   $0x802287
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
  8003ce:	b8 80 22 80 00       	mov    $0x802280,%eax
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
  800ada:	68 7f 25 80 00       	push   $0x80257f
  800adf:	6a 2a                	push   $0x2a
  800ae1:	68 9c 25 80 00       	push   $0x80259c
  800ae6:	e8 9e 13 00 00       	call   801e89 <_panic>

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
  800b5b:	68 7f 25 80 00       	push   $0x80257f
  800b60:	6a 2a                	push   $0x2a
  800b62:	68 9c 25 80 00       	push   $0x80259c
  800b67:	e8 1d 13 00 00       	call   801e89 <_panic>

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
  800b9d:	68 7f 25 80 00       	push   $0x80257f
  800ba2:	6a 2a                	push   $0x2a
  800ba4:	68 9c 25 80 00       	push   $0x80259c
  800ba9:	e8 db 12 00 00       	call   801e89 <_panic>

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
  800bdf:	68 7f 25 80 00       	push   $0x80257f
  800be4:	6a 2a                	push   $0x2a
  800be6:	68 9c 25 80 00       	push   $0x80259c
  800beb:	e8 99 12 00 00       	call   801e89 <_panic>

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
  800c21:	68 7f 25 80 00       	push   $0x80257f
  800c26:	6a 2a                	push   $0x2a
  800c28:	68 9c 25 80 00       	push   $0x80259c
  800c2d:	e8 57 12 00 00       	call   801e89 <_panic>

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
  800c63:	68 7f 25 80 00       	push   $0x80257f
  800c68:	6a 2a                	push   $0x2a
  800c6a:	68 9c 25 80 00       	push   $0x80259c
  800c6f:	e8 15 12 00 00       	call   801e89 <_panic>

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
  800ca5:	68 7f 25 80 00       	push   $0x80257f
  800caa:	6a 2a                	push   $0x2a
  800cac:	68 9c 25 80 00       	push   $0x80259c
  800cb1:	e8 d3 11 00 00       	call   801e89 <_panic>

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
  800d09:	68 7f 25 80 00       	push   $0x80257f
  800d0e:	6a 2a                	push   $0x2a
  800d10:	68 9c 25 80 00       	push   $0x80259c
  800d15:	e8 6f 11 00 00       	call   801e89 <_panic>

00800d1a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d2a:	89 d1                	mov    %edx,%ecx
  800d2c:	89 d3                	mov    %edx,%ebx
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 d6                	mov    %edx,%esi
  800d32:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	b8 10 00 00 00       	mov    $0x10,%eax
  800d70:	89 df                	mov    %ebx,%edi
  800d72:	89 de                	mov    %ebx,%esi
  800d74:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	05 00 00 00 30       	add    $0x30000000,%eax
  800d86:	c1 e8 0c             	shr    $0xc,%eax
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d9b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800daa:	89 c2                	mov    %eax,%edx
  800dac:	c1 ea 16             	shr    $0x16,%edx
  800daf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db6:	f6 c2 01             	test   $0x1,%dl
  800db9:	74 29                	je     800de4 <fd_alloc+0x42>
  800dbb:	89 c2                	mov    %eax,%edx
  800dbd:	c1 ea 0c             	shr    $0xc,%edx
  800dc0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc7:	f6 c2 01             	test   $0x1,%dl
  800dca:	74 18                	je     800de4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dcc:	05 00 10 00 00       	add    $0x1000,%eax
  800dd1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd6:	75 d2                	jne    800daa <fd_alloc+0x8>
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800ddd:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800de2:	eb 05                	jmp    800de9 <fd_alloc+0x47>
			return 0;
  800de4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 02                	mov    %eax,(%edx)
}
  800dee:	89 c8                	mov    %ecx,%eax
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df8:	83 f8 1f             	cmp    $0x1f,%eax
  800dfb:	77 30                	ja     800e2d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dfd:	c1 e0 0c             	shl    $0xc,%eax
  800e00:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e05:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e0b:	f6 c2 01             	test   $0x1,%dl
  800e0e:	74 24                	je     800e34 <fd_lookup+0x42>
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	c1 ea 0c             	shr    $0xc,%edx
  800e15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	74 1a                	je     800e3b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e24:	89 02                	mov    %eax,(%edx)
	return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
		return -E_INVAL;
  800e2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e32:	eb f7                	jmp    800e2b <fd_lookup+0x39>
		return -E_INVAL;
  800e34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e39:	eb f0                	jmp    800e2b <fd_lookup+0x39>
  800e3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e40:	eb e9                	jmp    800e2b <fd_lookup+0x39>

00800e42 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	53                   	push   %ebx
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e51:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e56:	39 13                	cmp    %edx,(%ebx)
  800e58:	74 37                	je     800e91 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e5a:	83 c0 01             	add    $0x1,%eax
  800e5d:	8b 1c 85 28 26 80 00 	mov    0x802628(,%eax,4),%ebx
  800e64:	85 db                	test   %ebx,%ebx
  800e66:	75 ee                	jne    800e56 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e68:	a1 00 40 80 00       	mov    0x804000,%eax
  800e6d:	8b 40 48             	mov    0x48(%eax),%eax
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	52                   	push   %edx
  800e74:	50                   	push   %eax
  800e75:	68 ac 25 80 00       	push   $0x8025ac
  800e7a:	e8 d4 f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8a:	89 1a                	mov    %ebx,(%edx)
}
  800e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    
			return 0;
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	eb ef                	jmp    800e87 <dev_lookup+0x45>

00800e98 <fd_close>:
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 24             	sub    $0x24,%esp
  800ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eaa:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb4:	50                   	push   %eax
  800eb5:	e8 38 ff ff ff       	call   800df2 <fd_lookup>
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	78 05                	js     800ec8 <fd_close+0x30>
	    || fd != fd2)
  800ec3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ec6:	74 16                	je     800ede <fd_close+0x46>
		return (must_exist ? r : 0);
  800ec8:	89 f8                	mov    %edi,%eax
  800eca:	84 c0                	test   %al,%al
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed1:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee4:	50                   	push   %eax
  800ee5:	ff 36                	push   (%esi)
  800ee7:	e8 56 ff ff ff       	call   800e42 <dev_lookup>
  800eec:	89 c3                	mov    %eax,%ebx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	78 1a                	js     800f0f <fd_close+0x77>
		if (dev->dev_close)
  800ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	74 0b                	je     800f0f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	56                   	push   %esi
  800f08:	ff d0                	call   *%eax
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f0f:	83 ec 08             	sub    $0x8,%esp
  800f12:	56                   	push   %esi
  800f13:	6a 00                	push   $0x0
  800f15:	e8 94 fc ff ff       	call   800bae <sys_page_unmap>
	return r;
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	eb b5                	jmp    800ed4 <fd_close+0x3c>

00800f1f <close>:

int
close(int fdnum)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 75 08             	push   0x8(%ebp)
  800f2c:	e8 c1 fe ff ff       	call   800df2 <fd_lookup>
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 02                	jns    800f3a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    
		return fd_close(fd, 1);
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	6a 01                	push   $0x1
  800f3f:	ff 75 f4             	push   -0xc(%ebp)
  800f42:	e8 51 ff ff ff       	call   800e98 <fd_close>
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	eb ec                	jmp    800f38 <close+0x19>

00800f4c <close_all>:

void
close_all(void)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	53                   	push   %ebx
  800f5c:	e8 be ff ff ff       	call   800f1f <close>
	for (i = 0; i < MAXFD; i++)
  800f61:	83 c3 01             	add    $0x1,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	83 fb 20             	cmp    $0x20,%ebx
  800f6a:	75 ec                	jne    800f58 <close_all+0xc>
}
  800f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7d:	50                   	push   %eax
  800f7e:	ff 75 08             	push   0x8(%ebp)
  800f81:	e8 6c fe ff ff       	call   800df2 <fd_lookup>
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 7f                	js     80100e <dup+0x9d>
		return r;
	close(newfdnum);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	ff 75 0c             	push   0xc(%ebp)
  800f95:	e8 85 ff ff ff       	call   800f1f <close>

	newfd = INDEX2FD(newfdnum);
  800f9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f9d:	c1 e6 0c             	shl    $0xc,%esi
  800fa0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fa9:	89 3c 24             	mov    %edi,(%esp)
  800fac:	e8 da fd ff ff       	call   800d8b <fd2data>
  800fb1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb3:	89 34 24             	mov    %esi,(%esp)
  800fb6:	e8 d0 fd ff ff       	call   800d8b <fd2data>
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	c1 e8 16             	shr    $0x16,%eax
  800fc6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcd:	a8 01                	test   $0x1,%al
  800fcf:	74 11                	je     800fe2 <dup+0x71>
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	c1 e8 0c             	shr    $0xc,%eax
  800fd6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdd:	f6 c2 01             	test   $0x1,%dl
  800fe0:	75 36                	jne    801018 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe2:	89 f8                	mov    %edi,%eax
  800fe4:	c1 e8 0c             	shr    $0xc,%eax
  800fe7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff6:	50                   	push   %eax
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	57                   	push   %edi
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 6a fb ff ff       	call   800b6c <sys_page_map>
  801002:	89 c3                	mov    %eax,%ebx
  801004:	83 c4 20             	add    $0x20,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	78 33                	js     80103e <dup+0xcd>
		goto err;

	return newfdnum;
  80100b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801018:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	25 07 0e 00 00       	and    $0xe07,%eax
  801027:	50                   	push   %eax
  801028:	ff 75 d4             	push   -0x2c(%ebp)
  80102b:	6a 00                	push   $0x0
  80102d:	53                   	push   %ebx
  80102e:	6a 00                	push   $0x0
  801030:	e8 37 fb ff ff       	call   800b6c <sys_page_map>
  801035:	89 c3                	mov    %eax,%ebx
  801037:	83 c4 20             	add    $0x20,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	79 a4                	jns    800fe2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	56                   	push   %esi
  801042:	6a 00                	push   $0x0
  801044:	e8 65 fb ff ff       	call   800bae <sys_page_unmap>
	sys_page_unmap(0, nva);
  801049:	83 c4 08             	add    $0x8,%esp
  80104c:	ff 75 d4             	push   -0x2c(%ebp)
  80104f:	6a 00                	push   $0x0
  801051:	e8 58 fb ff ff       	call   800bae <sys_page_unmap>
	return r;
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	eb b3                	jmp    80100e <dup+0x9d>

0080105b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 18             	sub    $0x18,%esp
  801063:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801066:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	56                   	push   %esi
  80106b:	e8 82 fd ff ff       	call   800df2 <fd_lookup>
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 3c                	js     8010b3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801077:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	ff 33                	push   (%ebx)
  801083:	e8 ba fd ff ff       	call   800e42 <dev_lookup>
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 24                	js     8010b3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80108f:	8b 43 08             	mov    0x8(%ebx),%eax
  801092:	83 e0 03             	and    $0x3,%eax
  801095:	83 f8 01             	cmp    $0x1,%eax
  801098:	74 20                	je     8010ba <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80109a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109d:	8b 40 08             	mov    0x8(%eax),%eax
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	74 37                	je     8010db <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a4:	83 ec 04             	sub    $0x4,%esp
  8010a7:	ff 75 10             	push   0x10(%ebp)
  8010aa:	ff 75 0c             	push   0xc(%ebp)
  8010ad:	53                   	push   %ebx
  8010ae:	ff d0                	call   *%eax
  8010b0:	83 c4 10             	add    $0x10,%esp
}
  8010b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8010bf:	8b 40 48             	mov    0x48(%eax),%eax
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	56                   	push   %esi
  8010c6:	50                   	push   %eax
  8010c7:	68 ed 25 80 00       	push   $0x8025ed
  8010cc:	e8 82 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d9:	eb d8                	jmp    8010b3 <read+0x58>
		return -E_NOT_SUPP;
  8010db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010e0:	eb d1                	jmp    8010b3 <read+0x58>

008010e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f6:	eb 02                	jmp    8010fa <readn+0x18>
  8010f8:	01 c3                	add    %eax,%ebx
  8010fa:	39 f3                	cmp    %esi,%ebx
  8010fc:	73 21                	jae    80111f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	89 f0                	mov    %esi,%eax
  801103:	29 d8                	sub    %ebx,%eax
  801105:	50                   	push   %eax
  801106:	89 d8                	mov    %ebx,%eax
  801108:	03 45 0c             	add    0xc(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	57                   	push   %edi
  80110d:	e8 49 ff ff ff       	call   80105b <read>
		if (m < 0)
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	78 04                	js     80111d <readn+0x3b>
			return m;
		if (m == 0)
  801119:	75 dd                	jne    8010f8 <readn+0x16>
  80111b:	eb 02                	jmp    80111f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80111d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80111f:	89 d8                	mov    %ebx,%eax
  801121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	56                   	push   %esi
  80112d:	53                   	push   %ebx
  80112e:	83 ec 18             	sub    $0x18,%esp
  801131:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801134:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801137:	50                   	push   %eax
  801138:	53                   	push   %ebx
  801139:	e8 b4 fc ff ff       	call   800df2 <fd_lookup>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	78 37                	js     80117c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801145:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801148:	83 ec 08             	sub    $0x8,%esp
  80114b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114e:	50                   	push   %eax
  80114f:	ff 36                	push   (%esi)
  801151:	e8 ec fc ff ff       	call   800e42 <dev_lookup>
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 1f                	js     80117c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801161:	74 20                	je     801183 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	8b 40 0c             	mov    0xc(%eax),%eax
  801169:	85 c0                	test   %eax,%eax
  80116b:	74 37                	je     8011a4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	ff 75 10             	push   0x10(%ebp)
  801173:	ff 75 0c             	push   0xc(%ebp)
  801176:	56                   	push   %esi
  801177:	ff d0                	call   *%eax
  801179:	83 c4 10             	add    $0x10,%esp
}
  80117c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801183:	a1 00 40 80 00       	mov    0x804000,%eax
  801188:	8b 40 48             	mov    0x48(%eax),%eax
  80118b:	83 ec 04             	sub    $0x4,%esp
  80118e:	53                   	push   %ebx
  80118f:	50                   	push   %eax
  801190:	68 09 26 80 00       	push   $0x802609
  801195:	e8 b9 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a2:	eb d8                	jmp    80117c <write+0x53>
		return -E_NOT_SUPP;
  8011a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a9:	eb d1                	jmp    80117c <write+0x53>

008011ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	ff 75 08             	push   0x8(%ebp)
  8011b8:	e8 35 fc ff ff       	call   800df2 <fd_lookup>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 0e                	js     8011d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 18             	sub    $0x18,%esp
  8011dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	53                   	push   %ebx
  8011e4:	e8 09 fc ff ff       	call   800df2 <fd_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 34                	js     801224 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 36                	push   (%esi)
  8011fc:	e8 41 fc ff ff       	call   800e42 <dev_lookup>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 1c                	js     801224 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801208:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80120c:	74 1d                	je     80122b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80120e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801211:	8b 40 18             	mov    0x18(%eax),%eax
  801214:	85 c0                	test   %eax,%eax
  801216:	74 34                	je     80124c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	ff 75 0c             	push   0xc(%ebp)
  80121e:	56                   	push   %esi
  80121f:	ff d0                	call   *%eax
  801221:	83 c4 10             	add    $0x10,%esp
}
  801224:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80122b:	a1 00 40 80 00       	mov    0x804000,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	68 cc 25 80 00       	push   $0x8025cc
  80123d:	e8 11 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124a:	eb d8                	jmp    801224 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80124c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801251:	eb d1                	jmp    801224 <ftruncate+0x50>

00801253 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 18             	sub    $0x18,%esp
  80125b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	ff 75 08             	push   0x8(%ebp)
  801265:	e8 88 fb ff ff       	call   800df2 <fd_lookup>
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 49                	js     8012ba <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801271:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 36                	push   (%esi)
  80127d:	e8 c0 fb ff ff       	call   800e42 <dev_lookup>
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 31                	js     8012ba <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801290:	74 2f                	je     8012c1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801292:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801295:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80129c:	00 00 00 
	stat->st_isdir = 0;
  80129f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a6:	00 00 00 
	stat->st_dev = dev;
  8012a9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	53                   	push   %ebx
  8012b3:	56                   	push   %esi
  8012b4:	ff 50 14             	call   *0x14(%eax)
  8012b7:	83 c4 10             	add    $0x10,%esp
}
  8012ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    
		return -E_NOT_SUPP;
  8012c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c6:	eb f2                	jmp    8012ba <fstat+0x67>

008012c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	6a 00                	push   $0x0
  8012d2:	ff 75 08             	push   0x8(%ebp)
  8012d5:	e8 e4 01 00 00       	call   8014be <open>
  8012da:	89 c3                	mov    %eax,%ebx
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 1b                	js     8012fe <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	ff 75 0c             	push   0xc(%ebp)
  8012e9:	50                   	push   %eax
  8012ea:	e8 64 ff ff ff       	call   801253 <fstat>
  8012ef:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f1:	89 1c 24             	mov    %ebx,(%esp)
  8012f4:	e8 26 fc ff ff       	call   800f1f <close>
	return r;
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	89 f3                	mov    %esi,%ebx
}
  8012fe:	89 d8                	mov    %ebx,%eax
  801300:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
  80130c:	89 c6                	mov    %eax,%esi
  80130e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801310:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801317:	74 27                	je     801340 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801319:	6a 07                	push   $0x7
  80131b:	68 00 50 80 00       	push   $0x805000
  801320:	56                   	push   %esi
  801321:	ff 35 00 60 80 00    	push   0x806000
  801327:	e8 0a 0c 00 00       	call   801f36 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80132c:	83 c4 0c             	add    $0xc,%esp
  80132f:	6a 00                	push   $0x0
  801331:	53                   	push   %ebx
  801332:	6a 00                	push   $0x0
  801334:	e8 96 0b 00 00       	call   801ecf <ipc_recv>
}
  801339:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	6a 01                	push   $0x1
  801345:	e8 40 0c 00 00       	call   801f8a <ipc_find_env>
  80134a:	a3 00 60 80 00       	mov    %eax,0x806000
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	eb c5                	jmp    801319 <fsipc+0x12>

00801354 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	8b 40 0c             	mov    0xc(%eax),%eax
  801360:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801365:	8b 45 0c             	mov    0xc(%ebp),%eax
  801368:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136d:	ba 00 00 00 00       	mov    $0x0,%edx
  801372:	b8 02 00 00 00       	mov    $0x2,%eax
  801377:	e8 8b ff ff ff       	call   801307 <fsipc>
}
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <devfile_flush>:
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801384:	8b 45 08             	mov    0x8(%ebp),%eax
  801387:	8b 40 0c             	mov    0xc(%eax),%eax
  80138a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80138f:	ba 00 00 00 00       	mov    $0x0,%edx
  801394:	b8 06 00 00 00       	mov    $0x6,%eax
  801399:	e8 69 ff ff ff       	call   801307 <fsipc>
}
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <devfile_stat>:
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 04             	sub    $0x4,%esp
  8013a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8013bf:	e8 43 ff ff ff       	call   801307 <fsipc>
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 2c                	js     8013f4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	68 00 50 80 00       	push   $0x805000
  8013d0:	53                   	push   %ebx
  8013d1:	e8 57 f3 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e1:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <devfile_write>:
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801402:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801407:	39 d0                	cmp    %edx,%eax
  801409:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140c:	8b 55 08             	mov    0x8(%ebp),%edx
  80140f:	8b 52 0c             	mov    0xc(%edx),%edx
  801412:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801418:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80141d:	50                   	push   %eax
  80141e:	ff 75 0c             	push   0xc(%ebp)
  801421:	68 08 50 80 00       	push   $0x805008
  801426:	e8 98 f4 ff ff       	call   8008c3 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80142b:	ba 00 00 00 00       	mov    $0x0,%edx
  801430:	b8 04 00 00 00       	mov    $0x4,%eax
  801435:	e8 cd fe ff ff       	call   801307 <fsipc>
}
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <devfile_read>:
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	8b 40 0c             	mov    0xc(%eax),%eax
  80144a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	b8 03 00 00 00       	mov    $0x3,%eax
  80145f:	e8 a3 fe ff ff       	call   801307 <fsipc>
  801464:	89 c3                	mov    %eax,%ebx
  801466:	85 c0                	test   %eax,%eax
  801468:	78 1f                	js     801489 <devfile_read+0x4d>
	assert(r <= n);
  80146a:	39 f0                	cmp    %esi,%eax
  80146c:	77 24                	ja     801492 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80146e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801473:	7f 33                	jg     8014a8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	50                   	push   %eax
  801479:	68 00 50 80 00       	push   $0x805000
  80147e:	ff 75 0c             	push   0xc(%ebp)
  801481:	e8 3d f4 ff ff       	call   8008c3 <memmove>
	return r;
  801486:	83 c4 10             	add    $0x10,%esp
}
  801489:	89 d8                	mov    %ebx,%eax
  80148b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    
	assert(r <= n);
  801492:	68 3c 26 80 00       	push   $0x80263c
  801497:	68 43 26 80 00       	push   $0x802643
  80149c:	6a 7c                	push   $0x7c
  80149e:	68 58 26 80 00       	push   $0x802658
  8014a3:	e8 e1 09 00 00       	call   801e89 <_panic>
	assert(r <= PGSIZE);
  8014a8:	68 63 26 80 00       	push   $0x802663
  8014ad:	68 43 26 80 00       	push   $0x802643
  8014b2:	6a 7d                	push   $0x7d
  8014b4:	68 58 26 80 00       	push   $0x802658
  8014b9:	e8 cb 09 00 00       	call   801e89 <_panic>

008014be <open>:
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 1c             	sub    $0x1c,%esp
  8014c6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014c9:	56                   	push   %esi
  8014ca:	e8 23 f2 ff ff       	call   8006f2 <strlen>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d7:	7f 6c                	jg     801545 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	e8 bd f8 ff ff       	call   800da2 <fd_alloc>
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 3c                	js     80152a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	56                   	push   %esi
  8014f2:	68 00 50 80 00       	push   $0x805000
  8014f7:	e8 31 f2 ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801504:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801507:	b8 01 00 00 00       	mov    $0x1,%eax
  80150c:	e8 f6 fd ff ff       	call   801307 <fsipc>
  801511:	89 c3                	mov    %eax,%ebx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 19                	js     801533 <open+0x75>
	return fd2num(fd);
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	ff 75 f4             	push   -0xc(%ebp)
  801520:	e8 56 f8 ff ff       	call   800d7b <fd2num>
  801525:	89 c3                	mov    %eax,%ebx
  801527:	83 c4 10             	add    $0x10,%esp
}
  80152a:	89 d8                	mov    %ebx,%eax
  80152c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    
		fd_close(fd, 0);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	6a 00                	push   $0x0
  801538:	ff 75 f4             	push   -0xc(%ebp)
  80153b:	e8 58 f9 ff ff       	call   800e98 <fd_close>
		return r;
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	eb e5                	jmp    80152a <open+0x6c>
		return -E_BAD_PATH;
  801545:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80154a:	eb de                	jmp    80152a <open+0x6c>

0080154c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
  801557:	b8 08 00 00 00       	mov    $0x8,%eax
  80155c:	e8 a6 fd ff ff       	call   801307 <fsipc>
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801569:	68 6f 26 80 00       	push   $0x80266f
  80156e:	ff 75 0c             	push   0xc(%ebp)
  801571:	e8 b7 f1 ff ff       	call   80072d <strcpy>
	return 0;
}
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <devsock_close>:
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 10             	sub    $0x10,%esp
  801584:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801587:	53                   	push   %ebx
  801588:	e8 36 0a 00 00       	call   801fc3 <pageref>
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801597:	83 fa 01             	cmp    $0x1,%edx
  80159a:	74 05                	je     8015a1 <devsock_close+0x24>
}
  80159c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015a1:	83 ec 0c             	sub    $0xc,%esp
  8015a4:	ff 73 0c             	push   0xc(%ebx)
  8015a7:	e8 b7 02 00 00       	call   801863 <nsipc_close>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb eb                	jmp    80159c <devsock_close+0x1f>

008015b1 <devsock_write>:
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015b7:	6a 00                	push   $0x0
  8015b9:	ff 75 10             	push   0x10(%ebp)
  8015bc:	ff 75 0c             	push   0xc(%ebp)
  8015bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c2:	ff 70 0c             	push   0xc(%eax)
  8015c5:	e8 79 03 00 00       	call   801943 <nsipc_send>
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <devsock_read>:
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015d2:	6a 00                	push   $0x0
  8015d4:	ff 75 10             	push   0x10(%ebp)
  8015d7:	ff 75 0c             	push   0xc(%ebp)
  8015da:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dd:	ff 70 0c             	push   0xc(%eax)
  8015e0:	e8 ef 02 00 00       	call   8018d4 <nsipc_recv>
}
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <fd2sockid>:
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015ed:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015f0:	52                   	push   %edx
  8015f1:	50                   	push   %eax
  8015f2:	e8 fb f7 ff ff       	call   800df2 <fd_lookup>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 10                	js     80160e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8015fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801601:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801607:	39 08                	cmp    %ecx,(%eax)
  801609:	75 05                	jne    801610 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80160b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    
		return -E_NOT_SUPP;
  801610:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801615:	eb f7                	jmp    80160e <fd2sockid+0x27>

00801617 <alloc_sockfd>:
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 1c             	sub    $0x1c,%esp
  80161f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	e8 78 f7 ff ff       	call   800da2 <fd_alloc>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 43                	js     801676 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	68 07 04 00 00       	push   $0x407
  80163b:	ff 75 f4             	push   -0xc(%ebp)
  80163e:	6a 00                	push   $0x0
  801640:	e8 e4 f4 ff ff       	call   800b29 <sys_page_alloc>
  801645:	89 c3                	mov    %eax,%ebx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 28                	js     801676 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801651:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801657:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801663:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	50                   	push   %eax
  80166a:	e8 0c f7 ff ff       	call   800d7b <fd2num>
  80166f:	89 c3                	mov    %eax,%ebx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb 0c                	jmp    801682 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	56                   	push   %esi
  80167a:	e8 e4 01 00 00       	call   801863 <nsipc_close>
		return r;
  80167f:	83 c4 10             	add    $0x10,%esp
}
  801682:	89 d8                	mov    %ebx,%eax
  801684:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <accept>:
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	e8 4e ff ff ff       	call   8015e7 <fd2sockid>
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 1b                	js     8016b8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	ff 75 10             	push   0x10(%ebp)
  8016a3:	ff 75 0c             	push   0xc(%ebp)
  8016a6:	50                   	push   %eax
  8016a7:	e8 0e 01 00 00       	call   8017ba <nsipc_accept>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 05                	js     8016b8 <accept+0x2d>
	return alloc_sockfd(r);
  8016b3:	e8 5f ff ff ff       	call   801617 <alloc_sockfd>
}
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <bind>:
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	e8 1f ff ff ff       	call   8015e7 <fd2sockid>
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 12                	js     8016de <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016cc:	83 ec 04             	sub    $0x4,%esp
  8016cf:	ff 75 10             	push   0x10(%ebp)
  8016d2:	ff 75 0c             	push   0xc(%ebp)
  8016d5:	50                   	push   %eax
  8016d6:	e8 31 01 00 00       	call   80180c <nsipc_bind>
  8016db:	83 c4 10             	add    $0x10,%esp
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <shutdown>:
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	e8 f9 fe ff ff       	call   8015e7 <fd2sockid>
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 0f                	js     801701 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	ff 75 0c             	push   0xc(%ebp)
  8016f8:	50                   	push   %eax
  8016f9:	e8 43 01 00 00       	call   801841 <nsipc_shutdown>
  8016fe:	83 c4 10             	add    $0x10,%esp
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <connect>:
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	e8 d6 fe ff ff       	call   8015e7 <fd2sockid>
  801711:	85 c0                	test   %eax,%eax
  801713:	78 12                	js     801727 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	ff 75 10             	push   0x10(%ebp)
  80171b:	ff 75 0c             	push   0xc(%ebp)
  80171e:	50                   	push   %eax
  80171f:	e8 59 01 00 00       	call   80187d <nsipc_connect>
  801724:	83 c4 10             	add    $0x10,%esp
}
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <listen>:
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	e8 b0 fe ff ff       	call   8015e7 <fd2sockid>
  801737:	85 c0                	test   %eax,%eax
  801739:	78 0f                	js     80174a <listen+0x21>
	return nsipc_listen(r, backlog);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	ff 75 0c             	push   0xc(%ebp)
  801741:	50                   	push   %eax
  801742:	e8 6b 01 00 00       	call   8018b2 <nsipc_listen>
  801747:	83 c4 10             	add    $0x10,%esp
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <socket>:

int
socket(int domain, int type, int protocol)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801752:	ff 75 10             	push   0x10(%ebp)
  801755:	ff 75 0c             	push   0xc(%ebp)
  801758:	ff 75 08             	push   0x8(%ebp)
  80175b:	e8 41 02 00 00       	call   8019a1 <nsipc_socket>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 05                	js     80176c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801767:	e8 ab fe ff ff       	call   801617 <alloc_sockfd>
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	53                   	push   %ebx
  801772:	83 ec 04             	sub    $0x4,%esp
  801775:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801777:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80177e:	74 26                	je     8017a6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801780:	6a 07                	push   $0x7
  801782:	68 00 70 80 00       	push   $0x807000
  801787:	53                   	push   %ebx
  801788:	ff 35 00 80 80 00    	push   0x808000
  80178e:	e8 a3 07 00 00       	call   801f36 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801793:	83 c4 0c             	add    $0xc,%esp
  801796:	6a 00                	push   $0x0
  801798:	6a 00                	push   $0x0
  80179a:	6a 00                	push   $0x0
  80179c:	e8 2e 07 00 00       	call   801ecf <ipc_recv>
}
  8017a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	6a 02                	push   $0x2
  8017ab:	e8 da 07 00 00       	call   801f8a <ipc_find_env>
  8017b0:	a3 00 80 80 00       	mov    %eax,0x808000
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb c6                	jmp    801780 <nsipc+0x12>

008017ba <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017ca:	8b 06                	mov    (%esi),%eax
  8017cc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d6:	e8 93 ff ff ff       	call   80176e <nsipc>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	79 09                	jns    8017ea <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017e1:	89 d8                	mov    %ebx,%eax
  8017e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ea:	83 ec 04             	sub    $0x4,%esp
  8017ed:	ff 35 10 70 80 00    	push   0x807010
  8017f3:	68 00 70 80 00       	push   $0x807000
  8017f8:	ff 75 0c             	push   0xc(%ebp)
  8017fb:	e8 c3 f0 ff ff       	call   8008c3 <memmove>
		*addrlen = ret->ret_addrlen;
  801800:	a1 10 70 80 00       	mov    0x807010,%eax
  801805:	89 06                	mov    %eax,(%esi)
  801807:	83 c4 10             	add    $0x10,%esp
	return r;
  80180a:	eb d5                	jmp    8017e1 <nsipc_accept+0x27>

0080180c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80181e:	53                   	push   %ebx
  80181f:	ff 75 0c             	push   0xc(%ebp)
  801822:	68 04 70 80 00       	push   $0x807004
  801827:	e8 97 f0 ff ff       	call   8008c3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80182c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801832:	b8 02 00 00 00       	mov    $0x2,%eax
  801837:	e8 32 ff ff ff       	call   80176e <nsipc>
}
  80183c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80184f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801852:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801857:	b8 03 00 00 00       	mov    $0x3,%eax
  80185c:	e8 0d ff ff ff       	call   80176e <nsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <nsipc_close>:

int
nsipc_close(int s)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801871:	b8 04 00 00 00       	mov    $0x4,%eax
  801876:	e8 f3 fe ff ff       	call   80176e <nsipc>
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	53                   	push   %ebx
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80188f:	53                   	push   %ebx
  801890:	ff 75 0c             	push   0xc(%ebp)
  801893:	68 04 70 80 00       	push   $0x807004
  801898:	e8 26 f0 ff ff       	call   8008c3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80189d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a8:	e8 c1 fe ff ff       	call   80176e <nsipc>
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8018cd:	e8 9c fe ff ff       	call   80176e <nsipc>
}
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018e4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ed:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018f2:	b8 07 00 00 00       	mov    $0x7,%eax
  8018f7:	e8 72 fe ff ff       	call   80176e <nsipc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 22                	js     801924 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801902:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801907:	39 c6                	cmp    %eax,%esi
  801909:	0f 4e c6             	cmovle %esi,%eax
  80190c:	39 c3                	cmp    %eax,%ebx
  80190e:	7f 1d                	jg     80192d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801910:	83 ec 04             	sub    $0x4,%esp
  801913:	53                   	push   %ebx
  801914:	68 00 70 80 00       	push   $0x807000
  801919:	ff 75 0c             	push   0xc(%ebp)
  80191c:	e8 a2 ef ff ff       	call   8008c3 <memmove>
  801921:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801924:	89 d8                	mov    %ebx,%eax
  801926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80192d:	68 7b 26 80 00       	push   $0x80267b
  801932:	68 43 26 80 00       	push   $0x802643
  801937:	6a 62                	push   $0x62
  801939:	68 90 26 80 00       	push   $0x802690
  80193e:	e8 46 05 00 00       	call   801e89 <_panic>

00801943 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801955:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80195b:	7f 2e                	jg     80198b <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80195d:	83 ec 04             	sub    $0x4,%esp
  801960:	53                   	push   %ebx
  801961:	ff 75 0c             	push   0xc(%ebp)
  801964:	68 0c 70 80 00       	push   $0x80700c
  801969:	e8 55 ef ff ff       	call   8008c3 <memmove>
	nsipcbuf.send.req_size = size;
  80196e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801974:	8b 45 14             	mov    0x14(%ebp),%eax
  801977:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80197c:	b8 08 00 00 00       	mov    $0x8,%eax
  801981:	e8 e8 fd ff ff       	call   80176e <nsipc>
}
  801986:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801989:	c9                   	leave  
  80198a:	c3                   	ret    
	assert(size < 1600);
  80198b:	68 9c 26 80 00       	push   $0x80269c
  801990:	68 43 26 80 00       	push   $0x802643
  801995:	6a 6d                	push   $0x6d
  801997:	68 90 26 80 00       	push   $0x802690
  80199c:	e8 e8 04 00 00       	call   801e89 <_panic>

008019a1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ba:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019bf:	b8 09 00 00 00       	mov    $0x9,%eax
  8019c4:	e8 a5 fd ff ff       	call   80176e <nsipc>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 75 08             	push   0x8(%ebp)
  8019d9:	e8 ad f3 ff ff       	call   800d8b <fd2data>
  8019de:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e0:	83 c4 08             	add    $0x8,%esp
  8019e3:	68 a8 26 80 00       	push   $0x8026a8
  8019e8:	53                   	push   %ebx
  8019e9:	e8 3f ed ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ee:	8b 46 04             	mov    0x4(%esi),%eax
  8019f1:	2b 06                	sub    (%esi),%eax
  8019f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a00:	00 00 00 
	stat->st_dev = &devpipe;
  801a03:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a0a:	30 80 00 
	return 0;
}
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a23:	53                   	push   %ebx
  801a24:	6a 00                	push   $0x0
  801a26:	e8 83 f1 ff ff       	call   800bae <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2b:	89 1c 24             	mov    %ebx,(%esp)
  801a2e:	e8 58 f3 ff ff       	call   800d8b <fd2data>
  801a33:	83 c4 08             	add    $0x8,%esp
  801a36:	50                   	push   %eax
  801a37:	6a 00                	push   $0x0
  801a39:	e8 70 f1 ff ff       	call   800bae <sys_page_unmap>
}
  801a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <_pipeisclosed>:
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	57                   	push   %edi
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 1c             	sub    $0x1c,%esp
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a50:	a1 00 40 80 00       	mov    0x804000,%eax
  801a55:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	57                   	push   %edi
  801a5c:	e8 62 05 00 00       	call   801fc3 <pageref>
  801a61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a64:	89 34 24             	mov    %esi,(%esp)
  801a67:	e8 57 05 00 00       	call   801fc3 <pageref>
		nn = thisenv->env_runs;
  801a6c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a72:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	39 cb                	cmp    %ecx,%ebx
  801a7a:	74 1b                	je     801a97 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a7f:	75 cf                	jne    801a50 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a81:	8b 42 58             	mov    0x58(%edx),%eax
  801a84:	6a 01                	push   $0x1
  801a86:	50                   	push   %eax
  801a87:	53                   	push   %ebx
  801a88:	68 af 26 80 00       	push   $0x8026af
  801a8d:	e8 c1 e6 ff ff       	call   800153 <cprintf>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb b9                	jmp    801a50 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a97:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a9a:	0f 94 c0             	sete   %al
  801a9d:	0f b6 c0             	movzbl %al,%eax
}
  801aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <devpipe_write>:
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 28             	sub    $0x28,%esp
  801ab1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ab4:	56                   	push   %esi
  801ab5:	e8 d1 f2 ff ff       	call   800d8b <fd2data>
  801aba:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac7:	75 09                	jne    801ad2 <devpipe_write+0x2a>
	return i;
  801ac9:	89 f8                	mov    %edi,%eax
  801acb:	eb 23                	jmp    801af0 <devpipe_write+0x48>
			sys_yield();
  801acd:	e8 38 f0 ff ff       	call   800b0a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad2:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad5:	8b 0b                	mov    (%ebx),%ecx
  801ad7:	8d 51 20             	lea    0x20(%ecx),%edx
  801ada:	39 d0                	cmp    %edx,%eax
  801adc:	72 1a                	jb     801af8 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ade:	89 da                	mov    %ebx,%edx
  801ae0:	89 f0                	mov    %esi,%eax
  801ae2:	e8 5c ff ff ff       	call   801a43 <_pipeisclosed>
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	74 e2                	je     801acd <devpipe_write+0x25>
				return 0;
  801aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5f                   	pop    %edi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	c1 fa 1f             	sar    $0x1f,%edx
  801b07:	89 d1                	mov    %edx,%ecx
  801b09:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b0f:	83 e2 1f             	and    $0x1f,%edx
  801b12:	29 ca                	sub    %ecx,%edx
  801b14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1c:	83 c0 01             	add    $0x1,%eax
  801b1f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b22:	83 c7 01             	add    $0x1,%edi
  801b25:	eb 9d                	jmp    801ac4 <devpipe_write+0x1c>

00801b27 <devpipe_read>:
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	57                   	push   %edi
  801b2b:	56                   	push   %esi
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 18             	sub    $0x18,%esp
  801b30:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b33:	57                   	push   %edi
  801b34:	e8 52 f2 ff ff       	call   800d8b <fd2data>
  801b39:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	be 00 00 00 00       	mov    $0x0,%esi
  801b43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b46:	75 13                	jne    801b5b <devpipe_read+0x34>
	return i;
  801b48:	89 f0                	mov    %esi,%eax
  801b4a:	eb 02                	jmp    801b4e <devpipe_read+0x27>
				return i;
  801b4c:	89 f0                	mov    %esi,%eax
}
  801b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    
			sys_yield();
  801b56:	e8 af ef ff ff       	call   800b0a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b5b:	8b 03                	mov    (%ebx),%eax
  801b5d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b60:	75 18                	jne    801b7a <devpipe_read+0x53>
			if (i > 0)
  801b62:	85 f6                	test   %esi,%esi
  801b64:	75 e6                	jne    801b4c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b66:	89 da                	mov    %ebx,%edx
  801b68:	89 f8                	mov    %edi,%eax
  801b6a:	e8 d4 fe ff ff       	call   801a43 <_pipeisclosed>
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	74 e3                	je     801b56 <devpipe_read+0x2f>
				return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
  801b78:	eb d4                	jmp    801b4e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7a:	99                   	cltd   
  801b7b:	c1 ea 1b             	shr    $0x1b,%edx
  801b7e:	01 d0                	add    %edx,%eax
  801b80:	83 e0 1f             	and    $0x1f,%eax
  801b83:	29 d0                	sub    %edx,%eax
  801b85:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b90:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b93:	83 c6 01             	add    $0x1,%esi
  801b96:	eb ab                	jmp    801b43 <devpipe_read+0x1c>

00801b98 <pipe>:
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 f9 f1 ff ff       	call   800da2 <fd_alloc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 23 01 00 00    	js     801cd9 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	68 07 04 00 00       	push   $0x407
  801bbe:	ff 75 f4             	push   -0xc(%ebp)
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 61 ef ff ff       	call   800b29 <sys_page_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	0f 88 04 01 00 00    	js     801cd9 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 c1 f1 ff ff       	call   800da2 <fd_alloc>
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 db 00 00 00    	js     801cc9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	68 07 04 00 00       	push   $0x407
  801bf6:	ff 75 f0             	push   -0x10(%ebp)
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 29 ef ff ff       	call   800b29 <sys_page_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 bc 00 00 00    	js     801cc9 <pipe+0x131>
	va = fd2data(fd0);
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	ff 75 f4             	push   -0xc(%ebp)
  801c13:	e8 73 f1 ff ff       	call   800d8b <fd2data>
  801c18:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1a:	83 c4 0c             	add    $0xc,%esp
  801c1d:	68 07 04 00 00       	push   $0x407
  801c22:	50                   	push   %eax
  801c23:	6a 00                	push   $0x0
  801c25:	e8 ff ee ff ff       	call   800b29 <sys_page_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 82 00 00 00    	js     801cb9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	ff 75 f0             	push   -0x10(%ebp)
  801c3d:	e8 49 f1 ff ff       	call   800d8b <fd2data>
  801c42:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c49:	50                   	push   %eax
  801c4a:	6a 00                	push   $0x0
  801c4c:	56                   	push   %esi
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 18 ef ff ff       	call   800b6c <sys_page_map>
  801c54:	89 c3                	mov    %eax,%ebx
  801c56:	83 c4 20             	add    $0x20,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 4e                	js     801cab <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c5d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c65:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c71:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c74:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c79:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	ff 75 f4             	push   -0xc(%ebp)
  801c86:	e8 f0 f0 ff ff       	call   800d7b <fd2num>
  801c8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c90:	83 c4 04             	add    $0x4,%esp
  801c93:	ff 75 f0             	push   -0x10(%ebp)
  801c96:	e8 e0 f0 ff ff       	call   800d7b <fd2num>
  801c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca9:	eb 2e                	jmp    801cd9 <pipe+0x141>
	sys_page_unmap(0, va);
  801cab:	83 ec 08             	sub    $0x8,%esp
  801cae:	56                   	push   %esi
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 f8 ee ff ff       	call   800bae <sys_page_unmap>
  801cb6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cb9:	83 ec 08             	sub    $0x8,%esp
  801cbc:	ff 75 f0             	push   -0x10(%ebp)
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 e8 ee ff ff       	call   800bae <sys_page_unmap>
  801cc6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cc9:	83 ec 08             	sub    $0x8,%esp
  801ccc:	ff 75 f4             	push   -0xc(%ebp)
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 d8 ee ff ff       	call   800bae <sys_page_unmap>
  801cd6:	83 c4 10             	add    $0x10,%esp
}
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <pipeisclosed>:
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	ff 75 08             	push   0x8(%ebp)
  801cef:	e8 fe f0 ff ff       	call   800df2 <fd_lookup>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 18                	js     801d13 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f4             	push   -0xc(%ebp)
  801d01:	e8 85 f0 ff ff       	call   800d8b <fd2data>
  801d06:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0b:	e8 33 fd ff ff       	call   801a43 <_pipeisclosed>
  801d10:	83 c4 10             	add    $0x10,%esp
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d15:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1a:	c3                   	ret    

00801d1b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d21:	68 c7 26 80 00       	push   $0x8026c7
  801d26:	ff 75 0c             	push   0xc(%ebp)
  801d29:	e8 ff e9 ff ff       	call   80072d <strcpy>
	return 0;
}
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <devcons_write>:
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	57                   	push   %edi
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d41:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d46:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d4c:	eb 2e                	jmp    801d7c <devcons_write+0x47>
		m = n - tot;
  801d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d51:	29 f3                	sub    %esi,%ebx
  801d53:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d58:	39 c3                	cmp    %eax,%ebx
  801d5a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	53                   	push   %ebx
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	03 45 0c             	add    0xc(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	57                   	push   %edi
  801d68:	e8 56 eb ff ff       	call   8008c3 <memmove>
		sys_cputs(buf, m);
  801d6d:	83 c4 08             	add    $0x8,%esp
  801d70:	53                   	push   %ebx
  801d71:	57                   	push   %edi
  801d72:	e8 f6 ec ff ff       	call   800a6d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d77:	01 de                	add    %ebx,%esi
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d7f:	72 cd                	jb     801d4e <devcons_write+0x19>
}
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5f                   	pop    %edi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <devcons_read>:
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9a:	75 07                	jne    801da3 <devcons_read+0x18>
  801d9c:	eb 1f                	jmp    801dbd <devcons_read+0x32>
		sys_yield();
  801d9e:	e8 67 ed ff ff       	call   800b0a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801da3:	e8 e3 ec ff ff       	call   800a8b <sys_cgetc>
  801da8:	85 c0                	test   %eax,%eax
  801daa:	74 f2                	je     801d9e <devcons_read+0x13>
	if (c < 0)
  801dac:	78 0f                	js     801dbd <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801dae:	83 f8 04             	cmp    $0x4,%eax
  801db1:	74 0c                	je     801dbf <devcons_read+0x34>
	*(char*)vbuf = c;
  801db3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db6:	88 02                	mov    %al,(%edx)
	return 1;
  801db8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    
		return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc4:	eb f7                	jmp    801dbd <devcons_read+0x32>

00801dc6 <cputchar>:
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dd2:	6a 01                	push   $0x1
  801dd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd7:	50                   	push   %eax
  801dd8:	e8 90 ec ff ff       	call   800a6d <sys_cputs>
}
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <getchar>:
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801de8:	6a 01                	push   $0x1
  801dea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	6a 00                	push   $0x0
  801df0:	e8 66 f2 ff ff       	call   80105b <read>
	if (r < 0)
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 06                	js     801e02 <getchar+0x20>
	if (r < 1)
  801dfc:	74 06                	je     801e04 <getchar+0x22>
	return c;
  801dfe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e02:	c9                   	leave  
  801e03:	c3                   	ret    
		return -E_EOF;
  801e04:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e09:	eb f7                	jmp    801e02 <getchar+0x20>

00801e0b <iscons>:
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e14:	50                   	push   %eax
  801e15:	ff 75 08             	push   0x8(%ebp)
  801e18:	e8 d5 ef ff ff       	call   800df2 <fd_lookup>
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	85 c0                	test   %eax,%eax
  801e22:	78 11                	js     801e35 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e27:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e2d:	39 10                	cmp    %edx,(%eax)
  801e2f:	0f 94 c0             	sete   %al
  801e32:	0f b6 c0             	movzbl %al,%eax
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <opencons>:
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	e8 5c ef ff ff       	call   800da2 <fd_alloc>
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 3a                	js     801e87 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4d:	83 ec 04             	sub    $0x4,%esp
  801e50:	68 07 04 00 00       	push   $0x407
  801e55:	ff 75 f4             	push   -0xc(%ebp)
  801e58:	6a 00                	push   $0x0
  801e5a:	e8 ca ec ff ff       	call   800b29 <sys_page_alloc>
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 21                	js     801e87 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e69:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e6f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e74:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	50                   	push   %eax
  801e7f:	e8 f7 ee ff ff       	call   800d7b <fd2num>
  801e84:	83 c4 10             	add    $0x10,%esp
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	56                   	push   %esi
  801e8d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e8e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e91:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e97:	e8 4f ec ff ff       	call   800aeb <sys_getenvid>
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	ff 75 0c             	push   0xc(%ebp)
  801ea2:	ff 75 08             	push   0x8(%ebp)
  801ea5:	56                   	push   %esi
  801ea6:	50                   	push   %eax
  801ea7:	68 d4 26 80 00       	push   $0x8026d4
  801eac:	e8 a2 e2 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eb1:	83 c4 18             	add    $0x18,%esp
  801eb4:	53                   	push   %ebx
  801eb5:	ff 75 10             	push   0x10(%ebp)
  801eb8:	e8 45 e2 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801ebd:	c7 04 24 c0 26 80 00 	movl   $0x8026c0,(%esp)
  801ec4:	e8 8a e2 ff ff       	call   800153 <cprintf>
  801ec9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ecc:	cc                   	int3   
  801ecd:	eb fd                	jmp    801ecc <_panic+0x43>

00801ecf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801edd:	85 c0                	test   %eax,%eax
  801edf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ee7:	83 ec 0c             	sub    $0xc,%esp
  801eea:	50                   	push   %eax
  801eeb:	e8 e9 ed ff ff       	call   800cd9 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	85 f6                	test   %esi,%esi
  801ef5:	74 14                	je     801f0b <ipc_recv+0x3c>
  801ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 09                	js     801f09 <ipc_recv+0x3a>
  801f00:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f06:	8b 52 74             	mov    0x74(%edx),%edx
  801f09:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f0b:	85 db                	test   %ebx,%ebx
  801f0d:	74 14                	je     801f23 <ipc_recv+0x54>
  801f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 09                	js     801f21 <ipc_recv+0x52>
  801f18:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f1e:	8b 52 78             	mov    0x78(%edx),%edx
  801f21:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 08                	js     801f2f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f27:	a1 00 40 80 00       	mov    0x804000,%eax
  801f2c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    

00801f36 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	57                   	push   %edi
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	83 ec 0c             	sub    $0xc,%esp
  801f3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f42:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f48:	85 db                	test   %ebx,%ebx
  801f4a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f4f:	0f 44 d8             	cmove  %eax,%ebx
  801f52:	eb 05                	jmp    801f59 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f54:	e8 b1 eb ff ff       	call   800b0a <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f59:	ff 75 14             	push   0x14(%ebp)
  801f5c:	53                   	push   %ebx
  801f5d:	56                   	push   %esi
  801f5e:	57                   	push   %edi
  801f5f:	e8 52 ed ff ff       	call   800cb6 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6a:	74 e8                	je     801f54 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 08                	js     801f78 <ipc_send+0x42>
	}while (r<0);

}
  801f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f78:	50                   	push   %eax
  801f79:	68 f7 26 80 00       	push   $0x8026f7
  801f7e:	6a 3d                	push   $0x3d
  801f80:	68 0b 27 80 00       	push   $0x80270b
  801f85:	e8 ff fe ff ff       	call   801e89 <_panic>

00801f8a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f95:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f98:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f9e:	8b 52 50             	mov    0x50(%edx),%edx
  801fa1:	39 ca                	cmp    %ecx,%edx
  801fa3:	74 11                	je     801fb6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fa5:	83 c0 01             	add    $0x1,%eax
  801fa8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fad:	75 e6                	jne    801f95 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb4:	eb 0b                	jmp    801fc1 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fb6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fbe:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	c1 ea 16             	shr    $0x16,%edx
  801fce:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fda:	f6 c1 01             	test   $0x1,%cl
  801fdd:	74 1c                	je     801ffb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fdf:	c1 e8 0c             	shr    $0xc,%eax
  801fe2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe9:	a8 01                	test   $0x1,%al
  801feb:	74 0e                	je     801ffb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fed:	c1 e8 0c             	shr    $0xc,%eax
  801ff0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff7:	ef 
  801ff8:	0f b7 d2             	movzwl %dx,%edx
}
  801ffb:	89 d0                	mov    %edx,%eax
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	f3 0f 1e fb          	endbr32 
  802004:	55                   	push   %ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 1c             	sub    $0x1c,%esp
  80200b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80200f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802013:	8b 74 24 34          	mov    0x34(%esp),%esi
  802017:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80201b:	85 c0                	test   %eax,%eax
  80201d:	75 19                	jne    802038 <__udivdi3+0x38>
  80201f:	39 f3                	cmp    %esi,%ebx
  802021:	76 4d                	jbe    802070 <__udivdi3+0x70>
  802023:	31 ff                	xor    %edi,%edi
  802025:	89 e8                	mov    %ebp,%eax
  802027:	89 f2                	mov    %esi,%edx
  802029:	f7 f3                	div    %ebx
  80202b:	89 fa                	mov    %edi,%edx
  80202d:	83 c4 1c             	add    $0x1c,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	76 14                	jbe    802050 <__udivdi3+0x50>
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	31 c0                	xor    %eax,%eax
  802040:	89 fa                	mov    %edi,%edx
  802042:	83 c4 1c             	add    $0x1c,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	0f bd f8             	bsr    %eax,%edi
  802053:	83 f7 1f             	xor    $0x1f,%edi
  802056:	75 48                	jne    8020a0 <__udivdi3+0xa0>
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	72 06                	jb     802062 <__udivdi3+0x62>
  80205c:	31 c0                	xor    %eax,%eax
  80205e:	39 eb                	cmp    %ebp,%ebx
  802060:	77 de                	ja     802040 <__udivdi3+0x40>
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	eb d7                	jmp    802040 <__udivdi3+0x40>
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d9                	mov    %ebx,%ecx
  802072:	85 db                	test   %ebx,%ebx
  802074:	75 0b                	jne    802081 <__udivdi3+0x81>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f3                	div    %ebx
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c6                	mov    %eax,%esi
  802089:	89 e8                	mov    %ebp,%eax
  80208b:	89 f7                	mov    %esi,%edi
  80208d:	f7 f1                	div    %ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	83 c4 1c             	add    $0x1c,%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5f                   	pop    %edi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 f9                	mov    %edi,%ecx
  8020a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020a7:	29 fa                	sub    %edi,%edx
  8020a9:	d3 e0                	shl    %cl,%eax
  8020ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020af:	89 d1                	mov    %edx,%ecx
  8020b1:	89 d8                	mov    %ebx,%eax
  8020b3:	d3 e8                	shr    %cl,%eax
  8020b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020b9:	09 c1                	or     %eax,%ecx
  8020bb:	89 f0                	mov    %esi,%eax
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e3                	shl    %cl,%ebx
  8020c5:	89 d1                	mov    %edx,%ecx
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 f9                	mov    %edi,%ecx
  8020cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020cf:	89 eb                	mov    %ebp,%ebx
  8020d1:	d3 e6                	shl    %cl,%esi
  8020d3:	89 d1                	mov    %edx,%ecx
  8020d5:	d3 eb                	shr    %cl,%ebx
  8020d7:	09 f3                	or     %esi,%ebx
  8020d9:	89 c6                	mov    %eax,%esi
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	89 d8                	mov    %ebx,%eax
  8020df:	f7 74 24 08          	divl   0x8(%esp)
  8020e3:	89 d6                	mov    %edx,%esi
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	f7 64 24 0c          	mull   0xc(%esp)
  8020eb:	39 d6                	cmp    %edx,%esi
  8020ed:	72 19                	jb     802108 <__udivdi3+0x108>
  8020ef:	89 f9                	mov    %edi,%ecx
  8020f1:	d3 e5                	shl    %cl,%ebp
  8020f3:	39 c5                	cmp    %eax,%ebp
  8020f5:	73 04                	jae    8020fb <__udivdi3+0xfb>
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	74 0d                	je     802108 <__udivdi3+0x108>
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	31 ff                	xor    %edi,%edi
  8020ff:	e9 3c ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80210b:	31 ff                	xor    %edi,%edi
  80210d:	e9 2e ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80212f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802133:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802137:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80213b:	89 f0                	mov    %esi,%eax
  80213d:	89 da                	mov    %ebx,%edx
  80213f:	85 ff                	test   %edi,%edi
  802141:	75 15                	jne    802158 <__umoddi3+0x38>
  802143:	39 dd                	cmp    %ebx,%ebp
  802145:	76 39                	jbe    802180 <__umoddi3+0x60>
  802147:	f7 f5                	div    %ebp
  802149:	89 d0                	mov    %edx,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	77 f1                	ja     80214d <__umoddi3+0x2d>
  80215c:	0f bd cf             	bsr    %edi,%ecx
  80215f:	83 f1 1f             	xor    $0x1f,%ecx
  802162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802166:	75 40                	jne    8021a8 <__umoddi3+0x88>
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	72 04                	jb     802170 <__umoddi3+0x50>
  80216c:	39 f5                	cmp    %esi,%ebp
  80216e:	77 dd                	ja     80214d <__umoddi3+0x2d>
  802170:	89 da                	mov    %ebx,%edx
  802172:	89 f0                	mov    %esi,%eax
  802174:	29 e8                	sub    %ebp,%eax
  802176:	19 fa                	sbb    %edi,%edx
  802178:	eb d3                	jmp    80214d <__umoddi3+0x2d>
  80217a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802180:	89 e9                	mov    %ebp,%ecx
  802182:	85 ed                	test   %ebp,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x71>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f5                	div    %ebp
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	89 d8                	mov    %ebx,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f1                	div    %ecx
  802197:	89 f0                	mov    %esi,%eax
  802199:	f7 f1                	div    %ecx
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	eb ac                	jmp    80214d <__umoddi3+0x2d>
  8021a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b1:	29 c2                	sub    %eax,%edx
  8021b3:	89 c1                	mov    %eax,%ecx
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	d3 e7                	shl    %cl,%edi
  8021b9:	89 d1                	mov    %edx,%ecx
  8021bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021bf:	d3 e8                	shr    %cl,%eax
  8021c1:	89 c1                	mov    %eax,%ecx
  8021c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c7:	09 f9                	or     %edi,%ecx
  8021c9:	89 df                	mov    %ebx,%edi
  8021cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	d3 e5                	shl    %cl,%ebp
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	d3 ef                	shr    %cl,%edi
  8021d7:	89 c1                	mov    %eax,%ecx
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	d3 e3                	shl    %cl,%ebx
  8021dd:	89 d1                	mov    %edx,%ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	d3 e8                	shr    %cl,%eax
  8021e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021e8:	09 d8                	or     %ebx,%eax
  8021ea:	f7 74 24 08          	divl   0x8(%esp)
  8021ee:	89 d3                	mov    %edx,%ebx
  8021f0:	d3 e6                	shl    %cl,%esi
  8021f2:	f7 e5                	mul    %ebp
  8021f4:	89 c7                	mov    %eax,%edi
  8021f6:	89 d1                	mov    %edx,%ecx
  8021f8:	39 d3                	cmp    %edx,%ebx
  8021fa:	72 06                	jb     802202 <__umoddi3+0xe2>
  8021fc:	75 0e                	jne    80220c <__umoddi3+0xec>
  8021fe:	39 c6                	cmp    %eax,%esi
  802200:	73 0a                	jae    80220c <__umoddi3+0xec>
  802202:	29 e8                	sub    %ebp,%eax
  802204:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802208:	89 d1                	mov    %edx,%ecx
  80220a:	89 c7                	mov    %eax,%edi
  80220c:	89 f5                	mov    %esi,%ebp
  80220e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802212:	29 fd                	sub    %edi,%ebp
  802214:	19 cb                	sbb    %ecx,%ebx
  802216:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80221b:	89 d8                	mov    %ebx,%eax
  80221d:	d3 e0                	shl    %cl,%eax
  80221f:	89 f1                	mov    %esi,%ecx
  802221:	d3 ed                	shr    %cl,%ebp
  802223:	d3 eb                	shr    %cl,%ebx
  802225:	09 e8                	or     %ebp,%eax
  802227:	89 da                	mov    %ebx,%edx
  802229:	83 c4 1c             	add    $0x1c,%esp
  80222c:	5b                   	pop    %ebx
  80222d:	5e                   	pop    %esi
  80222e:	5f                   	pop    %edi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    
