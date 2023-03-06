
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80003f:	68 60 0f 80 00       	push   $0x800f60
  800044:	e8 f2 00 00 00       	call   80013b <cprintf>
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
  800059:	e8 75 0a 00 00       	call   800ad3 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 f1 09 00 00       	call   800a92 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	74 09                	je     8000ce <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	68 ff 00 00 00       	push   $0xff
  8000d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d9:	50                   	push   %eax
  8000da:	e8 76 09 00 00       	call   800a55 <sys_cputs>
		b->idx = 0;
  8000df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	eb db                	jmp    8000c5 <putch+0x1f>

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	push   0xc(%ebp)
  80010a:	ff 75 08             	push   0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a6 00 80 00       	push   $0x8000a6
  800119:	e8 14 01 00 00       	call   800232 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 22 09 00 00       	call   800a55 <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	push   0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 c7                	mov    %eax,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 c2                	mov    %eax,%edx
  800166:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800169:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80016c:	8b 45 10             	mov    0x10(%ebp),%eax
  80016f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800172:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800175:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80017c:	39 c2                	cmp    %eax,%edx
  80017e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800181:	72 3e                	jb     8001c1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 18             	push   0x18(%ebp)
  800189:	83 eb 01             	sub    $0x1,%ebx
  80018c:	53                   	push   %ebx
  80018d:	50                   	push   %eax
  80018e:	83 ec 08             	sub    $0x8,%esp
  800191:	ff 75 e4             	push   -0x1c(%ebp)
  800194:	ff 75 e0             	push   -0x20(%ebp)
  800197:	ff 75 dc             	push   -0x24(%ebp)
  80019a:	ff 75 d8             	push   -0x28(%ebp)
  80019d:	e8 6e 0b 00 00       	call   800d10 <__udivdi3>
  8001a2:	83 c4 18             	add    $0x18,%esp
  8001a5:	52                   	push   %edx
  8001a6:	50                   	push   %eax
  8001a7:	89 f2                	mov    %esi,%edx
  8001a9:	89 f8                	mov    %edi,%eax
  8001ab:	e8 9f ff ff ff       	call   80014f <printnum>
  8001b0:	83 c4 20             	add    $0x20,%esp
  8001b3:	eb 13                	jmp    8001c8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	56                   	push   %esi
  8001b9:	ff 75 18             	push   0x18(%ebp)
  8001bc:	ff d7                	call   *%edi
  8001be:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001c1:	83 eb 01             	sub    $0x1,%ebx
  8001c4:	85 db                	test   %ebx,%ebx
  8001c6:	7f ed                	jg     8001b5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	56                   	push   %esi
  8001cc:	83 ec 04             	sub    $0x4,%esp
  8001cf:	ff 75 e4             	push   -0x1c(%ebp)
  8001d2:	ff 75 e0             	push   -0x20(%ebp)
  8001d5:	ff 75 dc             	push   -0x24(%ebp)
  8001d8:	ff 75 d8             	push   -0x28(%ebp)
  8001db:	e8 50 0c 00 00       	call   800e30 <__umoddi3>
  8001e0:	83 c4 14             	add    $0x14,%esp
  8001e3:	0f be 80 91 0f 80 00 	movsbl 0x800f91(%eax),%eax
  8001ea:	50                   	push   %eax
  8001eb:	ff d7                	call   *%edi
}
  8001ed:	83 c4 10             	add    $0x10,%esp
  8001f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5e                   	pop    %esi
  8001f5:	5f                   	pop    %edi
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800202:	8b 10                	mov    (%eax),%edx
  800204:	3b 50 04             	cmp    0x4(%eax),%edx
  800207:	73 0a                	jae    800213 <sprintputch+0x1b>
		*b->buf++ = ch;
  800209:	8d 4a 01             	lea    0x1(%edx),%ecx
  80020c:	89 08                	mov    %ecx,(%eax)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	88 02                	mov    %al,(%edx)
}
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <printfmt>:
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80021b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 10             	push   0x10(%ebp)
  800222:	ff 75 0c             	push   0xc(%ebp)
  800225:	ff 75 08             	push   0x8(%ebp)
  800228:	e8 05 00 00 00       	call   800232 <vprintfmt>
}
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <vprintfmt>:
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 3c             	sub    $0x3c,%esp
  80023b:	8b 75 08             	mov    0x8(%ebp),%esi
  80023e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800241:	8b 7d 10             	mov    0x10(%ebp),%edi
  800244:	eb 0a                	jmp    800250 <vprintfmt+0x1e>
			putch(ch, putdat);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	53                   	push   %ebx
  80024a:	50                   	push   %eax
  80024b:	ff d6                	call   *%esi
  80024d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800250:	83 c7 01             	add    $0x1,%edi
  800253:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800257:	83 f8 25             	cmp    $0x25,%eax
  80025a:	74 0c                	je     800268 <vprintfmt+0x36>
			if (ch == '\0')
  80025c:	85 c0                	test   %eax,%eax
  80025e:	75 e6                	jne    800246 <vprintfmt+0x14>
}
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    
		padc = ' ';
  800268:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80026c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800273:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80027a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800281:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800286:	8d 47 01             	lea    0x1(%edi),%eax
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	0f b6 17             	movzbl (%edi),%edx
  80028f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800292:	3c 55                	cmp    $0x55,%al
  800294:	0f 87 bb 03 00 00    	ja     800655 <vprintfmt+0x423>
  80029a:	0f b6 c0             	movzbl %al,%eax
  80029d:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  8002a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002a7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002ab:	eb d9                	jmp    800286 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002b0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002b4:	eb d0                	jmp    800286 <vprintfmt+0x54>
  8002b6:	0f b6 d2             	movzbl %dl,%edx
  8002b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002cb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ce:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d1:	83 f9 09             	cmp    $0x9,%ecx
  8002d4:	77 55                	ja     80032b <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002d6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002d9:	eb e9                	jmp    8002c4 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002db:	8b 45 14             	mov    0x14(%ebp),%eax
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8d 40 04             	lea    0x4(%eax),%eax
  8002e9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f3:	79 91                	jns    800286 <vprintfmt+0x54>
				width = precision, precision = -1;
  8002f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800302:	eb 82                	jmp    800286 <vprintfmt+0x54>
  800304:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800307:	85 d2                	test   %edx,%edx
  800309:	b8 00 00 00 00       	mov    $0x0,%eax
  80030e:	0f 49 c2             	cmovns %edx,%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800317:	e9 6a ff ff ff       	jmp    800286 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80031f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800326:	e9 5b ff ff ff       	jmp    800286 <vprintfmt+0x54>
  80032b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	eb bc                	jmp    8002ef <vprintfmt+0xbd>
			lflag++;
  800333:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800339:	e9 48 ff ff ff       	jmp    800286 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 78 04             	lea    0x4(%eax),%edi
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	ff 30                	push   (%eax)
  80034a:	ff d6                	call   *%esi
			break;
  80034c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80034f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800352:	e9 9d 02 00 00       	jmp    8005f4 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 78 04             	lea    0x4(%eax),%edi
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	89 d0                	mov    %edx,%eax
  800361:	f7 d8                	neg    %eax
  800363:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800366:	83 f8 08             	cmp    $0x8,%eax
  800369:	7f 23                	jg     80038e <vprintfmt+0x15c>
  80036b:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  800372:	85 d2                	test   %edx,%edx
  800374:	74 18                	je     80038e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800376:	52                   	push   %edx
  800377:	68 b2 0f 80 00       	push   $0x800fb2
  80037c:	53                   	push   %ebx
  80037d:	56                   	push   %esi
  80037e:	e8 92 fe ff ff       	call   800215 <printfmt>
  800383:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800386:	89 7d 14             	mov    %edi,0x14(%ebp)
  800389:	e9 66 02 00 00       	jmp    8005f4 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80038e:	50                   	push   %eax
  80038f:	68 a9 0f 80 00       	push   $0x800fa9
  800394:	53                   	push   %ebx
  800395:	56                   	push   %esi
  800396:	e8 7a fe ff ff       	call   800215 <printfmt>
  80039b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a1:	e9 4e 02 00 00       	jmp    8005f4 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	83 c0 04             	add    $0x4,%eax
  8003ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	b8 a2 0f 80 00       	mov    $0x800fa2,%eax
  8003bb:	0f 45 c2             	cmovne %edx,%eax
  8003be:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c5:	7e 06                	jle    8003cd <vprintfmt+0x19b>
  8003c7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003cb:	75 0d                	jne    8003da <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d0:	89 c7                	mov    %eax,%edi
  8003d2:	03 45 e0             	add    -0x20(%ebp),%eax
  8003d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d8:	eb 55                	jmp    80042f <vprintfmt+0x1fd>
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	ff 75 d8             	push   -0x28(%ebp)
  8003e0:	ff 75 cc             	push   -0x34(%ebp)
  8003e3:	e8 0a 03 00 00       	call   8006f2 <strnlen>
  8003e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003eb:	29 c1                	sub    %eax,%ecx
  8003ed:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8003f5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fc:	eb 0f                	jmp    80040d <vprintfmt+0x1db>
					putch(padc, putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	53                   	push   %ebx
  800402:	ff 75 e0             	push   -0x20(%ebp)
  800405:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800407:	83 ef 01             	sub    $0x1,%edi
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	85 ff                	test   %edi,%edi
  80040f:	7f ed                	jg     8003fe <vprintfmt+0x1cc>
  800411:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800414:	85 d2                	test   %edx,%edx
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
  80041b:	0f 49 c2             	cmovns %edx,%eax
  80041e:	29 c2                	sub    %eax,%edx
  800420:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800423:	eb a8                	jmp    8003cd <vprintfmt+0x19b>
					putch(ch, putdat);
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	53                   	push   %ebx
  800429:	52                   	push   %edx
  80042a:	ff d6                	call   *%esi
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800432:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800434:	83 c7 01             	add    $0x1,%edi
  800437:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80043b:	0f be d0             	movsbl %al,%edx
  80043e:	85 d2                	test   %edx,%edx
  800440:	74 4b                	je     80048d <vprintfmt+0x25b>
  800442:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800446:	78 06                	js     80044e <vprintfmt+0x21c>
  800448:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80044c:	78 1e                	js     80046c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80044e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800452:	74 d1                	je     800425 <vprintfmt+0x1f3>
  800454:	0f be c0             	movsbl %al,%eax
  800457:	83 e8 20             	sub    $0x20,%eax
  80045a:	83 f8 5e             	cmp    $0x5e,%eax
  80045d:	76 c6                	jbe    800425 <vprintfmt+0x1f3>
					putch('?', putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	6a 3f                	push   $0x3f
  800465:	ff d6                	call   *%esi
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	eb c3                	jmp    80042f <vprintfmt+0x1fd>
  80046c:	89 cf                	mov    %ecx,%edi
  80046e:	eb 0e                	jmp    80047e <vprintfmt+0x24c>
				putch(' ', putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	6a 20                	push   $0x20
  800476:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800478:	83 ef 01             	sub    $0x1,%edi
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	85 ff                	test   %edi,%edi
  800480:	7f ee                	jg     800470 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800485:	89 45 14             	mov    %eax,0x14(%ebp)
  800488:	e9 67 01 00 00       	jmp    8005f4 <vprintfmt+0x3c2>
  80048d:	89 cf                	mov    %ecx,%edi
  80048f:	eb ed                	jmp    80047e <vprintfmt+0x24c>
	if (lflag >= 2)
  800491:	83 f9 01             	cmp    $0x1,%ecx
  800494:	7f 1b                	jg     8004b1 <vprintfmt+0x27f>
	else if (lflag)
  800496:	85 c9                	test   %ecx,%ecx
  800498:	74 63                	je     8004fd <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a2:	99                   	cltd   
  8004a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 40 04             	lea    0x4(%eax),%eax
  8004ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8004af:	eb 17                	jmp    8004c8 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 50 04             	mov    0x4(%eax),%edx
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 40 08             	lea    0x8(%eax),%eax
  8004c5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004ce:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	0f 89 ff 00 00 00    	jns    8005da <vprintfmt+0x3a8>
				putch('-', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 2d                	push   $0x2d
  8004e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8004e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e9:	f7 da                	neg    %edx
  8004eb:	83 d1 00             	adc    $0x0,%ecx
  8004ee:	f7 d9                	neg    %ecx
  8004f0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004f3:	bf 0a 00 00 00       	mov    $0xa,%edi
  8004f8:	e9 dd 00 00 00       	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800505:	99                   	cltd   
  800506:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 40 04             	lea    0x4(%eax),%eax
  80050f:	89 45 14             	mov    %eax,0x14(%ebp)
  800512:	eb b4                	jmp    8004c8 <vprintfmt+0x296>
	if (lflag >= 2)
  800514:	83 f9 01             	cmp    $0x1,%ecx
  800517:	7f 1e                	jg     800537 <vprintfmt+0x305>
	else if (lflag)
  800519:	85 c9                	test   %ecx,%ecx
  80051b:	74 32                	je     80054f <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8b 10                	mov    (%eax),%edx
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
  800527:	8d 40 04             	lea    0x4(%eax),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80052d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800532:	e9 a3 00 00 00       	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	8b 48 04             	mov    0x4(%eax),%ecx
  80053f:	8d 40 08             	lea    0x8(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800545:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80054a:	e9 8b 00 00 00       	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 10                	mov    (%eax),%edx
  800554:	b9 00 00 00 00       	mov    $0x0,%ecx
  800559:	8d 40 04             	lea    0x4(%eax),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800564:	eb 74                	jmp    8005da <vprintfmt+0x3a8>
	if (lflag >= 2)
  800566:	83 f9 01             	cmp    $0x1,%ecx
  800569:	7f 1b                	jg     800586 <vprintfmt+0x354>
	else if (lflag)
  80056b:	85 c9                	test   %ecx,%ecx
  80056d:	74 2c                	je     80059b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 10                	mov    (%eax),%edx
  800574:	b9 00 00 00 00       	mov    $0x0,%ecx
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80057f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800584:	eb 54                	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 10                	mov    (%eax),%edx
  80058b:	8b 48 04             	mov    0x4(%eax),%ecx
  80058e:	8d 40 08             	lea    0x8(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800594:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800599:	eb 3f                	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ab:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005b0:	eb 28                	jmp    8005da <vprintfmt+0x3a8>
			putch('0', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 30                	push   $0x30
  8005b8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ba:	83 c4 08             	add    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 78                	push   $0x78
  8005c0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005cc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005d5:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005da:	83 ec 0c             	sub    $0xc,%esp
  8005dd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005e1:	50                   	push   %eax
  8005e2:	ff 75 e0             	push   -0x20(%ebp)
  8005e5:	57                   	push   %edi
  8005e6:	51                   	push   %ecx
  8005e7:	52                   	push   %edx
  8005e8:	89 da                	mov    %ebx,%edx
  8005ea:	89 f0                	mov    %esi,%eax
  8005ec:	e8 5e fb ff ff       	call   80014f <printnum>
			break;
  8005f1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005f7:	e9 54 fc ff ff       	jmp    800250 <vprintfmt+0x1e>
	if (lflag >= 2)
  8005fc:	83 f9 01             	cmp    $0x1,%ecx
  8005ff:	7f 1b                	jg     80061c <vprintfmt+0x3ea>
	else if (lflag)
  800601:	85 c9                	test   %ecx,%ecx
  800603:	74 2c                	je     800631 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060f:	8d 40 04             	lea    0x4(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800615:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80061a:	eb be                	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 10                	mov    (%eax),%edx
  800621:	8b 48 04             	mov    0x4(%eax),%ecx
  800624:	8d 40 08             	lea    0x8(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80062f:	eb a9                	jmp    8005da <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800641:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800646:	eb 92                	jmp    8005da <vprintfmt+0x3a8>
			putch(ch, putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 25                	push   $0x25
  80064e:	ff d6                	call   *%esi
			break;
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	eb 9f                	jmp    8005f4 <vprintfmt+0x3c2>
			putch('%', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 25                	push   $0x25
  80065b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	89 f8                	mov    %edi,%eax
  800662:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800666:	74 05                	je     80066d <vprintfmt+0x43b>
  800668:	83 e8 01             	sub    $0x1,%eax
  80066b:	eb f5                	jmp    800662 <vprintfmt+0x430>
  80066d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800670:	eb 82                	jmp    8005f4 <vprintfmt+0x3c2>

00800672 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 18             	sub    $0x18,%esp
  800678:	8b 45 08             	mov    0x8(%ebp),%eax
  80067b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800681:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800685:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068f:	85 c0                	test   %eax,%eax
  800691:	74 26                	je     8006b9 <vsnprintf+0x47>
  800693:	85 d2                	test   %edx,%edx
  800695:	7e 22                	jle    8006b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800697:	ff 75 14             	push   0x14(%ebp)
  80069a:	ff 75 10             	push   0x10(%ebp)
  80069d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a0:	50                   	push   %eax
  8006a1:	68 f8 01 80 00       	push   $0x8001f8
  8006a6:	e8 87 fb ff ff       	call   800232 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b4:	83 c4 10             	add    $0x10,%esp
}
  8006b7:	c9                   	leave  
  8006b8:	c3                   	ret    
		return -E_INVAL;
  8006b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006be:	eb f7                	jmp    8006b7 <vsnprintf+0x45>

008006c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c9:	50                   	push   %eax
  8006ca:	ff 75 10             	push   0x10(%ebp)
  8006cd:	ff 75 0c             	push   0xc(%ebp)
  8006d0:	ff 75 08             	push   0x8(%ebp)
  8006d3:	e8 9a ff ff ff       	call   800672 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e5:	eb 03                	jmp    8006ea <strlen+0x10>
		n++;
  8006e7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ee:	75 f7                	jne    8006e7 <strlen+0xd>
	return n;
}
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 03                	jmp    800705 <strnlen+0x13>
		n++;
  800702:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800705:	39 d0                	cmp    %edx,%eax
  800707:	74 08                	je     800711 <strnlen+0x1f>
  800709:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070d:	75 f3                	jne    800702 <strnlen+0x10>
  80070f:	89 c2                	mov    %eax,%edx
	return n;
}
  800711:	89 d0                	mov    %edx,%eax
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	53                   	push   %ebx
  800719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
  800724:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800728:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80072b:	83 c0 01             	add    $0x1,%eax
  80072e:	84 d2                	test   %dl,%dl
  800730:	75 f2                	jne    800724 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800732:	89 c8                	mov    %ecx,%eax
  800734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	83 ec 10             	sub    $0x10,%esp
  800740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800743:	53                   	push   %ebx
  800744:	e8 91 ff ff ff       	call   8006da <strlen>
  800749:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80074c:	ff 75 0c             	push   0xc(%ebp)
  80074f:	01 d8                	add    %ebx,%eax
  800751:	50                   	push   %eax
  800752:	e8 be ff ff ff       	call   800715 <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	8b 75 08             	mov    0x8(%ebp),%esi
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
  800769:	89 f3                	mov    %esi,%ebx
  80076b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076e:	89 f0                	mov    %esi,%eax
  800770:	eb 0f                	jmp    800781 <strncpy+0x23>
		*dst++ = *src;
  800772:	83 c0 01             	add    $0x1,%eax
  800775:	0f b6 0a             	movzbl (%edx),%ecx
  800778:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077b:	80 f9 01             	cmp    $0x1,%cl
  80077e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800781:	39 d8                	cmp    %ebx,%eax
  800783:	75 ed                	jne    800772 <strncpy+0x14>
	}
	return ret;
}
  800785:	89 f0                	mov    %esi,%eax
  800787:	5b                   	pop    %ebx
  800788:	5e                   	pop    %esi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800796:	8b 55 10             	mov    0x10(%ebp),%edx
  800799:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 21                	je     8007c0 <strlcpy+0x35>
  80079f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 09                	jmp    8007b0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 09                	je     8007bd <strlcpy+0x32>
  8007b4:	0f b6 19             	movzbl (%ecx),%ebx
  8007b7:	84 db                	test   %bl,%bl
  8007b9:	75 ec                	jne    8007a7 <strlcpy+0x1c>
  8007bb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c0:	29 f0                	sub    %esi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cf:	eb 06                	jmp    8007d7 <strcmp+0x11>
		p++, q++;
  8007d1:	83 c1 01             	add    $0x1,%ecx
  8007d4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007d7:	0f b6 01             	movzbl (%ecx),%eax
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 04                	je     8007e2 <strcmp+0x1c>
  8007de:	3a 02                	cmp    (%edx),%al
  8007e0:	74 ef                	je     8007d1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e2:	0f b6 c0             	movzbl %al,%eax
  8007e5:	0f b6 12             	movzbl (%edx),%edx
  8007e8:	29 d0                	sub    %edx,%eax
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 c3                	mov    %eax,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fb:	eb 06                	jmp    800803 <strncmp+0x17>
		n--, p++, q++;
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800803:	39 d8                	cmp    %ebx,%eax
  800805:	74 18                	je     80081f <strncmp+0x33>
  800807:	0f b6 08             	movzbl (%eax),%ecx
  80080a:	84 c9                	test   %cl,%cl
  80080c:	74 04                	je     800812 <strncmp+0x26>
  80080e:	3a 0a                	cmp    (%edx),%cl
  800810:	74 eb                	je     8007fd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800812:	0f b6 00             	movzbl (%eax),%eax
  800815:	0f b6 12             	movzbl (%edx),%edx
  800818:	29 d0                	sub    %edx,%eax
}
  80081a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    
		return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb f4                	jmp    80081a <strncmp+0x2e>

00800826 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800830:	eb 03                	jmp    800835 <strchr+0xf>
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	0f b6 10             	movzbl (%eax),%edx
  800838:	84 d2                	test   %dl,%dl
  80083a:	74 06                	je     800842 <strchr+0x1c>
		if (*s == c)
  80083c:	38 ca                	cmp    %cl,%dl
  80083e:	75 f2                	jne    800832 <strchr+0xc>
  800840:	eb 05                	jmp    800847 <strchr+0x21>
			return (char *) s;
	return 0;
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800853:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800856:	38 ca                	cmp    %cl,%dl
  800858:	74 09                	je     800863 <strfind+0x1a>
  80085a:	84 d2                	test   %dl,%dl
  80085c:	74 05                	je     800863 <strfind+0x1a>
	for (; *s; s++)
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	eb f0                	jmp    800853 <strfind+0xa>
			break;
	return (char *) s;
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800871:	85 c9                	test   %ecx,%ecx
  800873:	74 2f                	je     8008a4 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800875:	89 f8                	mov    %edi,%eax
  800877:	09 c8                	or     %ecx,%eax
  800879:	a8 03                	test   $0x3,%al
  80087b:	75 21                	jne    80089e <memset+0x39>
		c &= 0xFF;
  80087d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800881:	89 d0                	mov    %edx,%eax
  800883:	c1 e0 08             	shl    $0x8,%eax
  800886:	89 d3                	mov    %edx,%ebx
  800888:	c1 e3 18             	shl    $0x18,%ebx
  80088b:	89 d6                	mov    %edx,%esi
  80088d:	c1 e6 10             	shl    $0x10,%esi
  800890:	09 f3                	or     %esi,%ebx
  800892:	09 da                	or     %ebx,%edx
  800894:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800896:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 06                	jmp    8008a4 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	fc                   	cld    
  8008a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a4:	89 f8                	mov    %edi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b9:	39 c6                	cmp    %eax,%esi
  8008bb:	73 32                	jae    8008ef <memmove+0x44>
  8008bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c0:	39 c2                	cmp    %eax,%edx
  8008c2:	76 2b                	jbe    8008ef <memmove+0x44>
		s += n;
		d += n;
  8008c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	09 fe                	or     %edi,%esi
  8008cb:	09 ce                	or     %ecx,%esi
  8008cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d3:	75 0e                	jne    8008e3 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d5:	83 ef 04             	sub    $0x4,%edi
  8008d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008de:	fd                   	std    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 09                	jmp    8008ec <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e3:	83 ef 01             	sub    $0x1,%edi
  8008e6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008e9:	fd                   	std    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ec:	fc                   	cld    
  8008ed:	eb 1a                	jmp    800909 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ef:	89 f2                	mov    %esi,%edx
  8008f1:	09 c2                	or     %eax,%edx
  8008f3:	09 ca                	or     %ecx,%edx
  8008f5:	f6 c2 03             	test   $0x3,%dl
  8008f8:	75 0a                	jne    800904 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008fd:	89 c7                	mov    %eax,%edi
  8008ff:	fc                   	cld    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 05                	jmp    800909 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800904:	89 c7                	mov    %eax,%edi
  800906:	fc                   	cld    
  800907:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800913:	ff 75 10             	push   0x10(%ebp)
  800916:	ff 75 0c             	push   0xc(%ebp)
  800919:	ff 75 08             	push   0x8(%ebp)
  80091c:	e8 8a ff ff ff       	call   8008ab <memmove>
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	eb 06                	jmp    80093b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80093b:	39 f0                	cmp    %esi,%eax
  80093d:	74 14                	je     800953 <memcmp+0x30>
		if (*s1 != *s2)
  80093f:	0f b6 08             	movzbl (%eax),%ecx
  800942:	0f b6 1a             	movzbl (%edx),%ebx
  800945:	38 d9                	cmp    %bl,%cl
  800947:	74 ec                	je     800935 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800949:	0f b6 c1             	movzbl %cl,%eax
  80094c:	0f b6 db             	movzbl %bl,%ebx
  80094f:	29 d8                	sub    %ebx,%eax
  800951:	eb 05                	jmp    800958 <memcmp+0x35>
	}

	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800965:	89 c2                	mov    %eax,%edx
  800967:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096a:	eb 03                	jmp    80096f <memfind+0x13>
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	39 d0                	cmp    %edx,%eax
  800971:	73 04                	jae    800977 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800973:	38 08                	cmp    %cl,(%eax)
  800975:	75 f5                	jne    80096c <memfind+0x10>
			break;
	return (void *) s;
}
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 55 08             	mov    0x8(%ebp),%edx
  800982:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800985:	eb 03                	jmp    80098a <strtol+0x11>
		s++;
  800987:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80098a:	0f b6 02             	movzbl (%edx),%eax
  80098d:	3c 20                	cmp    $0x20,%al
  80098f:	74 f6                	je     800987 <strtol+0xe>
  800991:	3c 09                	cmp    $0x9,%al
  800993:	74 f2                	je     800987 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800995:	3c 2b                	cmp    $0x2b,%al
  800997:	74 2a                	je     8009c3 <strtol+0x4a>
	int neg = 0;
  800999:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80099e:	3c 2d                	cmp    $0x2d,%al
  8009a0:	74 2b                	je     8009cd <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a8:	75 0f                	jne    8009b9 <strtol+0x40>
  8009aa:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ad:	74 28                	je     8009d7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009af:	85 db                	test   %ebx,%ebx
  8009b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b6:	0f 44 d8             	cmove  %eax,%ebx
  8009b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009c1:	eb 46                	jmp    800a09 <strtol+0x90>
		s++;
  8009c3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cb:	eb d5                	jmp    8009a2 <strtol+0x29>
		s++, neg = 1;
  8009cd:	83 c2 01             	add    $0x1,%edx
  8009d0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d5:	eb cb                	jmp    8009a2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009db:	74 0e                	je     8009eb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009dd:	85 db                	test   %ebx,%ebx
  8009df:	75 d8                	jne    8009b9 <strtol+0x40>
		s++, base = 8;
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009e9:	eb ce                	jmp    8009b9 <strtol+0x40>
		s += 2, base = 16;
  8009eb:	83 c2 02             	add    $0x2,%edx
  8009ee:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f3:	eb c4                	jmp    8009b9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009f5:	0f be c0             	movsbl %al,%eax
  8009f8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009fb:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009fe:	7d 3a                	jge    800a3a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a07:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a09:	0f b6 02             	movzbl (%edx),%eax
  800a0c:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a0f:	89 f3                	mov    %esi,%ebx
  800a11:	80 fb 09             	cmp    $0x9,%bl
  800a14:	76 df                	jbe    8009f5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a16:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	80 fb 19             	cmp    $0x19,%bl
  800a1e:	77 08                	ja     800a28 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a20:	0f be c0             	movsbl %al,%eax
  800a23:	83 e8 57             	sub    $0x57,%eax
  800a26:	eb d3                	jmp    8009fb <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a28:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 08                	ja     800a3a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a32:	0f be c0             	movsbl %al,%eax
  800a35:	83 e8 37             	sub    $0x37,%eax
  800a38:	eb c1                	jmp    8009fb <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3e:	74 05                	je     800a45 <strtol+0xcc>
		*endptr = (char *) s;
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a45:	89 c8                	mov    %ecx,%eax
  800a47:	f7 d8                	neg    %eax
  800a49:	85 ff                	test   %edi,%edi
  800a4b:	0f 45 c8             	cmovne %eax,%ecx
}
  800a4e:	89 c8                	mov    %ecx,%eax
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a66:	89 c3                	mov    %eax,%ebx
  800a68:	89 c7                	mov    %eax,%edi
  800a6a:	89 c6                	mov    %eax,%esi
  800a6c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a79:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a83:	89 d1                	mov    %edx,%ecx
  800a85:	89 d3                	mov    %edx,%ebx
  800a87:	89 d7                	mov    %edx,%edi
  800a89:	89 d6                	mov    %edx,%esi
  800a8b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800a9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa3:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa8:	89 cb                	mov    %ecx,%ebx
  800aaa:	89 cf                	mov    %ecx,%edi
  800aac:	89 ce                	mov    %ecx,%esi
  800aae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ab0:	85 c0                	test   %eax,%eax
  800ab2:	7f 08                	jg     800abc <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	50                   	push   %eax
  800ac0:	6a 03                	push   $0x3
  800ac2:	68 e4 11 80 00       	push   $0x8011e4
  800ac7:	6a 2a                	push   $0x2a
  800ac9:	68 01 12 80 00       	push   $0x801201
  800ace:	e8 ed 01 00 00       	call   800cc0 <_panic>

00800ad3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae3:	89 d1                	mov    %edx,%ecx
  800ae5:	89 d3                	mov    %edx,%ebx
  800ae7:	89 d7                	mov    %edx,%edi
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_yield>:

void
sys_yield(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b1a:	be 00 00 00 00       	mov    $0x0,%esi
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2d:	89 f7                	mov    %esi,%edi
  800b2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7f 08                	jg     800b3d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 04                	push   $0x4
  800b43:	68 e4 11 80 00       	push   $0x8011e4
  800b48:	6a 2a                	push   $0x2a
  800b4a:	68 01 12 80 00       	push   $0x801201
  800b4f:	e8 6c 01 00 00       	call   800cc0 <_panic>

00800b54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b63:	b8 05 00 00 00       	mov    $0x5,%eax
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7f 08                	jg     800b7f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 05                	push   $0x5
  800b85:	68 e4 11 80 00       	push   $0x8011e4
  800b8a:	6a 2a                	push   $0x2a
  800b8c:	68 01 12 80 00       	push   $0x801201
  800b91:	e8 2a 01 00 00       	call   800cc0 <_panic>

00800b96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	b8 06 00 00 00       	mov    $0x6,%eax
  800baf:	89 df                	mov    %ebx,%edi
  800bb1:	89 de                	mov    %ebx,%esi
  800bb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7f 08                	jg     800bc1 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 06                	push   $0x6
  800bc7:	68 e4 11 80 00       	push   $0x8011e4
  800bcc:	6a 2a                	push   $0x2a
  800bce:	68 01 12 80 00       	push   $0x801201
  800bd3:	e8 e8 00 00 00       	call   800cc0 <_panic>

00800bd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7f 08                	jg     800c03 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 08                	push   $0x8
  800c09:	68 e4 11 80 00       	push   $0x8011e4
  800c0e:	6a 2a                	push   $0x2a
  800c10:	68 01 12 80 00       	push   $0x801201
  800c15:	e8 a6 00 00 00       	call   800cc0 <_panic>

00800c1a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	89 de                	mov    %ebx,%esi
  800c37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7f 08                	jg     800c45 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 09                	push   $0x9
  800c4b:	68 e4 11 80 00       	push   $0x8011e4
  800c50:	6a 2a                	push   $0x2a
  800c52:	68 01 12 80 00       	push   $0x801201
  800c57:	e8 64 00 00 00       	call   800cc0 <_panic>

00800c5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6d:	be 00 00 00 00       	mov    $0x0,%esi
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c78:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c95:	89 cb                	mov    %ecx,%ebx
  800c97:	89 cf                	mov    %ecx,%edi
  800c99:	89 ce                	mov    %ecx,%esi
  800c9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7f 08                	jg     800ca9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 0c                	push   $0xc
  800caf:	68 e4 11 80 00       	push   $0x8011e4
  800cb4:	6a 2a                	push   $0x2a
  800cb6:	68 01 12 80 00       	push   $0x801201
  800cbb:	e8 00 00 00 00       	call   800cc0 <_panic>

00800cc0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cc5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cc8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cce:	e8 00 fe ff ff       	call   800ad3 <sys_getenvid>
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	ff 75 0c             	push   0xc(%ebp)
  800cd9:	ff 75 08             	push   0x8(%ebp)
  800cdc:	56                   	push   %esi
  800cdd:	50                   	push   %eax
  800cde:	68 10 12 80 00       	push   $0x801210
  800ce3:	e8 53 f4 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ce8:	83 c4 18             	add    $0x18,%esp
  800ceb:	53                   	push   %ebx
  800cec:	ff 75 10             	push   0x10(%ebp)
  800cef:	e8 f6 f3 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800cf4:	c7 04 24 33 12 80 00 	movl   $0x801233,(%esp)
  800cfb:	e8 3b f4 ff ff       	call   80013b <cprintf>
  800d00:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d03:	cc                   	int3   
  800d04:	eb fd                	jmp    800d03 <_panic+0x43>
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 1c             	sub    $0x1c,%esp
  800d1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	75 19                	jne    800d48 <__udivdi3+0x38>
  800d2f:	39 f3                	cmp    %esi,%ebx
  800d31:	76 4d                	jbe    800d80 <__udivdi3+0x70>
  800d33:	31 ff                	xor    %edi,%edi
  800d35:	89 e8                	mov    %ebp,%eax
  800d37:	89 f2                	mov    %esi,%edx
  800d39:	f7 f3                	div    %ebx
  800d3b:	89 fa                	mov    %edi,%edx
  800d3d:	83 c4 1c             	add    $0x1c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 f0                	cmp    %esi,%eax
  800d4a:	76 14                	jbe    800d60 <__udivdi3+0x50>
  800d4c:	31 ff                	xor    %edi,%edi
  800d4e:	31 c0                	xor    %eax,%eax
  800d50:	89 fa                	mov    %edi,%edx
  800d52:	83 c4 1c             	add    $0x1c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    
  800d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d60:	0f bd f8             	bsr    %eax,%edi
  800d63:	83 f7 1f             	xor    $0x1f,%edi
  800d66:	75 48                	jne    800db0 <__udivdi3+0xa0>
  800d68:	39 f0                	cmp    %esi,%eax
  800d6a:	72 06                	jb     800d72 <__udivdi3+0x62>
  800d6c:	31 c0                	xor    %eax,%eax
  800d6e:	39 eb                	cmp    %ebp,%ebx
  800d70:	77 de                	ja     800d50 <__udivdi3+0x40>
  800d72:	b8 01 00 00 00       	mov    $0x1,%eax
  800d77:	eb d7                	jmp    800d50 <__udivdi3+0x40>
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	89 d9                	mov    %ebx,%ecx
  800d82:	85 db                	test   %ebx,%ebx
  800d84:	75 0b                	jne    800d91 <__udivdi3+0x81>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f3                	div    %ebx
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	89 f0                	mov    %esi,%eax
  800d95:	f7 f1                	div    %ecx
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	89 e8                	mov    %ebp,%eax
  800d9b:	89 f7                	mov    %esi,%edi
  800d9d:	f7 f1                	div    %ecx
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	83 c4 1c             	add    $0x1c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	ba 20 00 00 00       	mov    $0x20,%edx
  800db7:	29 fa                	sub    %edi,%edx
  800db9:	d3 e0                	shl    %cl,%eax
  800dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	d3 e8                	shr    %cl,%eax
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 c1                	or     %eax,%ecx
  800dcb:	89 f0                	mov    %esi,%eax
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	89 eb                	mov    %ebp,%ebx
  800de1:	d3 e6                	shl    %cl,%esi
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 f3                	or     %esi,%ebx
  800de9:	89 c6                	mov    %eax,%esi
  800deb:	89 f2                	mov    %esi,%edx
  800ded:	89 d8                	mov    %ebx,%eax
  800def:	f7 74 24 08          	divl   0x8(%esp)
  800df3:	89 d6                	mov    %edx,%esi
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	f7 64 24 0c          	mull   0xc(%esp)
  800dfb:	39 d6                	cmp    %edx,%esi
  800dfd:	72 19                	jb     800e18 <__udivdi3+0x108>
  800dff:	89 f9                	mov    %edi,%ecx
  800e01:	d3 e5                	shl    %cl,%ebp
  800e03:	39 c5                	cmp    %eax,%ebp
  800e05:	73 04                	jae    800e0b <__udivdi3+0xfb>
  800e07:	39 d6                	cmp    %edx,%esi
  800e09:	74 0d                	je     800e18 <__udivdi3+0x108>
  800e0b:	89 d8                	mov    %ebx,%eax
  800e0d:	31 ff                	xor    %edi,%edi
  800e0f:	e9 3c ff ff ff       	jmp    800d50 <__udivdi3+0x40>
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e1b:	31 ff                	xor    %edi,%edi
  800e1d:	e9 2e ff ff ff       	jmp    800d50 <__udivdi3+0x40>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 1c             	sub    $0x1c,%esp
  800e3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e4b:	89 f0                	mov    %esi,%eax
  800e4d:	89 da                	mov    %ebx,%edx
  800e4f:	85 ff                	test   %edi,%edi
  800e51:	75 15                	jne    800e68 <__umoddi3+0x38>
  800e53:	39 dd                	cmp    %ebx,%ebp
  800e55:	76 39                	jbe    800e90 <__umoddi3+0x60>
  800e57:	f7 f5                	div    %ebp
  800e59:	89 d0                	mov    %edx,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	83 c4 1c             	add    $0x1c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	39 df                	cmp    %ebx,%edi
  800e6a:	77 f1                	ja     800e5d <__umoddi3+0x2d>
  800e6c:	0f bd cf             	bsr    %edi,%ecx
  800e6f:	83 f1 1f             	xor    $0x1f,%ecx
  800e72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e76:	75 40                	jne    800eb8 <__umoddi3+0x88>
  800e78:	39 df                	cmp    %ebx,%edi
  800e7a:	72 04                	jb     800e80 <__umoddi3+0x50>
  800e7c:	39 f5                	cmp    %esi,%ebp
  800e7e:	77 dd                	ja     800e5d <__umoddi3+0x2d>
  800e80:	89 da                	mov    %ebx,%edx
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	29 e8                	sub    %ebp,%eax
  800e86:	19 fa                	sbb    %edi,%edx
  800e88:	eb d3                	jmp    800e5d <__umoddi3+0x2d>
  800e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e90:	89 e9                	mov    %ebp,%ecx
  800e92:	85 ed                	test   %ebp,%ebp
  800e94:	75 0b                	jne    800ea1 <__umoddi3+0x71>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f5                	div    %ebp
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	f7 f1                	div    %ecx
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	eb ac                	jmp    800e5d <__umoddi3+0x2d>
  800eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ebc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ec1:	29 c2                	sub    %eax,%edx
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	89 e8                	mov    %ebp,%eax
  800ec7:	d3 e7                	shl    %cl,%edi
  800ec9:	89 d1                	mov    %edx,%ecx
  800ecb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ecf:	d3 e8                	shr    %cl,%eax
  800ed1:	89 c1                	mov    %eax,%ecx
  800ed3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ed7:	09 f9                	or     %edi,%ecx
  800ed9:	89 df                	mov    %ebx,%edi
  800edb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	d3 e5                	shl    %cl,%ebp
  800ee3:	89 d1                	mov    %edx,%ecx
  800ee5:	d3 ef                	shr    %cl,%edi
  800ee7:	89 c1                	mov    %eax,%ecx
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	d3 e3                	shl    %cl,%ebx
  800eed:	89 d1                	mov    %edx,%ecx
  800eef:	89 fa                	mov    %edi,%edx
  800ef1:	d3 e8                	shr    %cl,%eax
  800ef3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ef8:	09 d8                	or     %ebx,%eax
  800efa:	f7 74 24 08          	divl   0x8(%esp)
  800efe:	89 d3                	mov    %edx,%ebx
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	f7 e5                	mul    %ebp
  800f04:	89 c7                	mov    %eax,%edi
  800f06:	89 d1                	mov    %edx,%ecx
  800f08:	39 d3                	cmp    %edx,%ebx
  800f0a:	72 06                	jb     800f12 <__umoddi3+0xe2>
  800f0c:	75 0e                	jne    800f1c <__umoddi3+0xec>
  800f0e:	39 c6                	cmp    %eax,%esi
  800f10:	73 0a                	jae    800f1c <__umoddi3+0xec>
  800f12:	29 e8                	sub    %ebp,%eax
  800f14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f18:	89 d1                	mov    %edx,%ecx
  800f1a:	89 c7                	mov    %eax,%edi
  800f1c:	89 f5                	mov    %esi,%ebp
  800f1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f22:	29 fd                	sub    %edi,%ebp
  800f24:	19 cb                	sbb    %ecx,%ebx
  800f26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f2b:	89 d8                	mov    %ebx,%eax
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 f1                	mov    %esi,%ecx
  800f31:	d3 ed                	shr    %cl,%ebp
  800f33:	d3 eb                	shr    %cl,%ebx
  800f35:	09 e8                	or     %ebp,%eax
  800f37:	89 da                	mov    %ebx,%edx
  800f39:	83 c4 1c             	add    $0x1c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
