
obj/user/divzero：     文件格式 elf32-i386


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
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 60 0f 80 00       	push   $0x800f60
  800056:	e8 f2 00 00 00       	call   80014d <cprintf>
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
  80006b:	e8 75 0a 00 00       	call   800ae5 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 f1 09 00 00       	call   800aa4 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	74 09                	je     8000e0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	68 ff 00 00 00       	push   $0xff
  8000e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000eb:	50                   	push   %eax
  8000ec:	e8 76 09 00 00       	call   800a67 <sys_cputs>
		b->idx = 0;
  8000f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	eb db                	jmp    8000d7 <putch+0x1f>

008000fc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800105:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010c:	00 00 00 
	b.cnt = 0;
  80010f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800116:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800119:	ff 75 0c             	push   0xc(%ebp)
  80011c:	ff 75 08             	push   0x8(%ebp)
  80011f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800125:	50                   	push   %eax
  800126:	68 b8 00 80 00       	push   $0x8000b8
  80012b:	e8 14 01 00 00       	call   800244 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800130:	83 c4 08             	add    $0x8,%esp
  800133:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	e8 22 09 00 00       	call   800a67 <sys_cputs>

	return b.cnt;
}
  800145:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800153:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800156:	50                   	push   %eax
  800157:	ff 75 08             	push   0x8(%ebp)
  80015a:	e8 9d ff ff ff       	call   8000fc <vcprintf>
	va_end(ap);

	return cnt;
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
  800167:	83 ec 1c             	sub    $0x1c,%esp
  80016a:	89 c7                	mov    %eax,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	8b 55 0c             	mov    0xc(%ebp),%edx
  800174:	89 d1                	mov    %edx,%ecx
  800176:	89 c2                	mov    %eax,%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80017e:	8b 45 10             	mov    0x10(%ebp),%eax
  800181:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800184:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800187:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80018e:	39 c2                	cmp    %eax,%edx
  800190:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800193:	72 3e                	jb     8001d3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	push   0x18(%ebp)
  80019b:	83 eb 01             	sub    $0x1,%ebx
  80019e:	53                   	push   %ebx
  80019f:	50                   	push   %eax
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 e4             	push   -0x1c(%ebp)
  8001a6:	ff 75 e0             	push   -0x20(%ebp)
  8001a9:	ff 75 dc             	push   -0x24(%ebp)
  8001ac:	ff 75 d8             	push   -0x28(%ebp)
  8001af:	e8 6c 0b 00 00       	call   800d20 <__udivdi3>
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	52                   	push   %edx
  8001b8:	50                   	push   %eax
  8001b9:	89 f2                	mov    %esi,%edx
  8001bb:	89 f8                	mov    %edi,%eax
  8001bd:	e8 9f ff ff ff       	call   800161 <printnum>
  8001c2:	83 c4 20             	add    $0x20,%esp
  8001c5:	eb 13                	jmp    8001da <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	ff 75 18             	push   0x18(%ebp)
  8001ce:	ff d7                	call   *%edi
  8001d0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d3:	83 eb 01             	sub    $0x1,%ebx
  8001d6:	85 db                	test   %ebx,%ebx
  8001d8:	7f ed                	jg     8001c7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	56                   	push   %esi
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	ff 75 e4             	push   -0x1c(%ebp)
  8001e4:	ff 75 e0             	push   -0x20(%ebp)
  8001e7:	ff 75 dc             	push   -0x24(%ebp)
  8001ea:	ff 75 d8             	push   -0x28(%ebp)
  8001ed:	e8 4e 0c 00 00       	call   800e40 <__umoddi3>
  8001f2:	83 c4 14             	add    $0x14,%esp
  8001f5:	0f be 80 78 0f 80 00 	movsbl 0x800f78(%eax),%eax
  8001fc:	50                   	push   %eax
  8001fd:	ff d7                	call   *%edi
}
  8001ff:	83 c4 10             	add    $0x10,%esp
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800210:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800214:	8b 10                	mov    (%eax),%edx
  800216:	3b 50 04             	cmp    0x4(%eax),%edx
  800219:	73 0a                	jae    800225 <sprintputch+0x1b>
		*b->buf++ = ch;
  80021b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 45 08             	mov    0x8(%ebp),%eax
  800223:	88 02                	mov    %al,(%edx)
}
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <printfmt>:
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80022d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800230:	50                   	push   %eax
  800231:	ff 75 10             	push   0x10(%ebp)
  800234:	ff 75 0c             	push   0xc(%ebp)
  800237:	ff 75 08             	push   0x8(%ebp)
  80023a:	e8 05 00 00 00       	call   800244 <vprintfmt>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <vprintfmt>:
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 3c             	sub    $0x3c,%esp
  80024d:	8b 75 08             	mov    0x8(%ebp),%esi
  800250:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800253:	8b 7d 10             	mov    0x10(%ebp),%edi
  800256:	eb 0a                	jmp    800262 <vprintfmt+0x1e>
			putch(ch, putdat);
  800258:	83 ec 08             	sub    $0x8,%esp
  80025b:	53                   	push   %ebx
  80025c:	50                   	push   %eax
  80025d:	ff d6                	call   *%esi
  80025f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800262:	83 c7 01             	add    $0x1,%edi
  800265:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800269:	83 f8 25             	cmp    $0x25,%eax
  80026c:	74 0c                	je     80027a <vprintfmt+0x36>
			if (ch == '\0')
  80026e:	85 c0                	test   %eax,%eax
  800270:	75 e6                	jne    800258 <vprintfmt+0x14>
}
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    
		padc = ' ';
  80027a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80027e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800285:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80028c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800293:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800298:	8d 47 01             	lea    0x1(%edi),%eax
  80029b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029e:	0f b6 17             	movzbl (%edi),%edx
  8002a1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a4:	3c 55                	cmp    $0x55,%al
  8002a6:	0f 87 bb 03 00 00    	ja     800667 <vprintfmt+0x423>
  8002ac:	0f b6 c0             	movzbl %al,%eax
  8002af:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
  8002b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002bd:	eb d9                	jmp    800298 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002c6:	eb d0                	jmp    800298 <vprintfmt+0x54>
  8002c8:	0f b6 d2             	movzbl %dl,%edx
  8002cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002dd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e3:	83 f9 09             	cmp    $0x9,%ecx
  8002e6:	77 55                	ja     80033d <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002eb:	eb e9                	jmp    8002d6 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f0:	8b 00                	mov    (%eax),%eax
  8002f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f8:	8d 40 04             	lea    0x4(%eax),%eax
  8002fb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800301:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800305:	79 91                	jns    800298 <vprintfmt+0x54>
				width = precision, precision = -1;
  800307:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80030a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800314:	eb 82                	jmp    800298 <vprintfmt+0x54>
  800316:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800319:	85 d2                	test   %edx,%edx
  80031b:	b8 00 00 00 00       	mov    $0x0,%eax
  800320:	0f 49 c2             	cmovns %edx,%eax
  800323:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800329:	e9 6a ff ff ff       	jmp    800298 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800331:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800338:	e9 5b ff ff ff       	jmp    800298 <vprintfmt+0x54>
  80033d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800340:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800343:	eb bc                	jmp    800301 <vprintfmt+0xbd>
			lflag++;
  800345:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80034b:	e9 48 ff ff ff       	jmp    800298 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 78 04             	lea    0x4(%eax),%edi
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	ff 30                	push   (%eax)
  80035c:	ff d6                	call   *%esi
			break;
  80035e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800361:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800364:	e9 9d 02 00 00       	jmp    800606 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 78 04             	lea    0x4(%eax),%edi
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	89 d0                	mov    %edx,%eax
  800373:	f7 d8                	neg    %eax
  800375:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800378:	83 f8 08             	cmp    $0x8,%eax
  80037b:	7f 23                	jg     8003a0 <vprintfmt+0x15c>
  80037d:	8b 14 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%edx
  800384:	85 d2                	test   %edx,%edx
  800386:	74 18                	je     8003a0 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800388:	52                   	push   %edx
  800389:	68 99 0f 80 00       	push   $0x800f99
  80038e:	53                   	push   %ebx
  80038f:	56                   	push   %esi
  800390:	e8 92 fe ff ff       	call   800227 <printfmt>
  800395:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800398:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039b:	e9 66 02 00 00       	jmp    800606 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003a0:	50                   	push   %eax
  8003a1:	68 90 0f 80 00       	push   $0x800f90
  8003a6:	53                   	push   %ebx
  8003a7:	56                   	push   %esi
  8003a8:	e8 7a fe ff ff       	call   800227 <printfmt>
  8003ad:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b3:	e9 4e 02 00 00       	jmp    800606 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	83 c0 04             	add    $0x4,%eax
  8003be:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	b8 89 0f 80 00       	mov    $0x800f89,%eax
  8003cd:	0f 45 c2             	cmovne %edx,%eax
  8003d0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d7:	7e 06                	jle    8003df <vprintfmt+0x19b>
  8003d9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003dd:	75 0d                	jne    8003ec <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003df:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e2:	89 c7                	mov    %eax,%edi
  8003e4:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ea:	eb 55                	jmp    800441 <vprintfmt+0x1fd>
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	ff 75 d8             	push   -0x28(%ebp)
  8003f2:	ff 75 cc             	push   -0x34(%ebp)
  8003f5:	e8 0a 03 00 00       	call   800704 <strnlen>
  8003fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003fd:	29 c1                	sub    %eax,%ecx
  8003ff:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800407:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80040e:	eb 0f                	jmp    80041f <vprintfmt+0x1db>
					putch(padc, putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	53                   	push   %ebx
  800414:	ff 75 e0             	push   -0x20(%ebp)
  800417:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	83 ef 01             	sub    $0x1,%edi
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	85 ff                	test   %edi,%edi
  800421:	7f ed                	jg     800410 <vprintfmt+0x1cc>
  800423:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	b8 00 00 00 00       	mov    $0x0,%eax
  80042d:	0f 49 c2             	cmovns %edx,%eax
  800430:	29 c2                	sub    %eax,%edx
  800432:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800435:	eb a8                	jmp    8003df <vprintfmt+0x19b>
					putch(ch, putdat);
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	52                   	push   %edx
  80043c:	ff d6                	call   *%esi
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800444:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800446:	83 c7 01             	add    $0x1,%edi
  800449:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044d:	0f be d0             	movsbl %al,%edx
  800450:	85 d2                	test   %edx,%edx
  800452:	74 4b                	je     80049f <vprintfmt+0x25b>
  800454:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800458:	78 06                	js     800460 <vprintfmt+0x21c>
  80045a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80045e:	78 1e                	js     80047e <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800460:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800464:	74 d1                	je     800437 <vprintfmt+0x1f3>
  800466:	0f be c0             	movsbl %al,%eax
  800469:	83 e8 20             	sub    $0x20,%eax
  80046c:	83 f8 5e             	cmp    $0x5e,%eax
  80046f:	76 c6                	jbe    800437 <vprintfmt+0x1f3>
					putch('?', putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	6a 3f                	push   $0x3f
  800477:	ff d6                	call   *%esi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	eb c3                	jmp    800441 <vprintfmt+0x1fd>
  80047e:	89 cf                	mov    %ecx,%edi
  800480:	eb 0e                	jmp    800490 <vprintfmt+0x24c>
				putch(' ', putdat);
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	53                   	push   %ebx
  800486:	6a 20                	push   $0x20
  800488:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80048a:	83 ef 01             	sub    $0x1,%edi
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	85 ff                	test   %edi,%edi
  800492:	7f ee                	jg     800482 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800494:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800497:	89 45 14             	mov    %eax,0x14(%ebp)
  80049a:	e9 67 01 00 00       	jmp    800606 <vprintfmt+0x3c2>
  80049f:	89 cf                	mov    %ecx,%edi
  8004a1:	eb ed                	jmp    800490 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004a3:	83 f9 01             	cmp    $0x1,%ecx
  8004a6:	7f 1b                	jg     8004c3 <vprintfmt+0x27f>
	else if (lflag)
  8004a8:	85 c9                	test   %ecx,%ecx
  8004aa:	74 63                	je     80050f <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b4:	99                   	cltd   
  8004b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 40 04             	lea    0x4(%eax),%eax
  8004be:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c1:	eb 17                	jmp    8004da <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8b 50 04             	mov    0x4(%eax),%edx
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 40 08             	lea    0x8(%eax),%eax
  8004d7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e0:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	0f 89 ff 00 00 00    	jns    8005ec <vprintfmt+0x3a8>
				putch('-', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	6a 2d                	push   $0x2d
  8004f3:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fb:	f7 da                	neg    %edx
  8004fd:	83 d1 00             	adc    $0x0,%ecx
  800500:	f7 d9                	neg    %ecx
  800502:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800505:	bf 0a 00 00 00       	mov    $0xa,%edi
  80050a:	e9 dd 00 00 00       	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800517:	99                   	cltd   
  800518:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
  800524:	eb b4                	jmp    8004da <vprintfmt+0x296>
	if (lflag >= 2)
  800526:	83 f9 01             	cmp    $0x1,%ecx
  800529:	7f 1e                	jg     800549 <vprintfmt+0x305>
	else if (lflag)
  80052b:	85 c9                	test   %ecx,%ecx
  80052d:	74 32                	je     800561 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 10                	mov    (%eax),%edx
  800534:	b9 00 00 00 00       	mov    $0x0,%ecx
  800539:	8d 40 04             	lea    0x4(%eax),%eax
  80053c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80053f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800544:	e9 a3 00 00 00       	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	8b 48 04             	mov    0x4(%eax),%ecx
  800551:	8d 40 08             	lea    0x8(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800557:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80055c:	e9 8b 00 00 00       	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 10                	mov    (%eax),%edx
  800566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800571:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800576:	eb 74                	jmp    8005ec <vprintfmt+0x3a8>
	if (lflag >= 2)
  800578:	83 f9 01             	cmp    $0x1,%ecx
  80057b:	7f 1b                	jg     800598 <vprintfmt+0x354>
	else if (lflag)
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	74 2c                	je     8005ad <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 10                	mov    (%eax),%edx
  800586:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058b:	8d 40 04             	lea    0x4(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800591:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800596:	eb 54                	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a0:	8d 40 08             	lea    0x8(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005a6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005ab:	eb 3f                	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005c2:	eb 28                	jmp    8005ec <vprintfmt+0x3a8>
			putch('0', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 30                	push   $0x30
  8005ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8005cc:	83 c4 08             	add    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 78                	push   $0x78
  8005d2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 10                	mov    (%eax),%edx
  8005d9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005de:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005e7:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005f3:	50                   	push   %eax
  8005f4:	ff 75 e0             	push   -0x20(%ebp)
  8005f7:	57                   	push   %edi
  8005f8:	51                   	push   %ecx
  8005f9:	52                   	push   %edx
  8005fa:	89 da                	mov    %ebx,%edx
  8005fc:	89 f0                	mov    %esi,%eax
  8005fe:	e8 5e fb ff ff       	call   800161 <printnum>
			break;
  800603:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800609:	e9 54 fc ff ff       	jmp    800262 <vprintfmt+0x1e>
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7f 1b                	jg     80062e <vprintfmt+0x3ea>
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	74 2c                	je     800643 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800627:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80062c:	eb be                	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	8b 48 04             	mov    0x4(%eax),%ecx
  800636:	8d 40 08             	lea    0x8(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800641:	eb a9                	jmp    8005ec <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800658:	eb 92                	jmp    8005ec <vprintfmt+0x3a8>
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 25                	push   $0x25
  800660:	ff d6                	call   *%esi
			break;
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 9f                	jmp    800606 <vprintfmt+0x3c2>
			putch('%', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 25                	push   $0x25
  80066d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	89 f8                	mov    %edi,%eax
  800674:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800678:	74 05                	je     80067f <vprintfmt+0x43b>
  80067a:	83 e8 01             	sub    $0x1,%eax
  80067d:	eb f5                	jmp    800674 <vprintfmt+0x430>
  80067f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800682:	eb 82                	jmp    800606 <vprintfmt+0x3c2>

00800684 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	83 ec 18             	sub    $0x18,%esp
  80068a:	8b 45 08             	mov    0x8(%ebp),%eax
  80068d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800690:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800693:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800697:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 26                	je     8006cb <vsnprintf+0x47>
  8006a5:	85 d2                	test   %edx,%edx
  8006a7:	7e 22                	jle    8006cb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a9:	ff 75 14             	push   0x14(%ebp)
  8006ac:	ff 75 10             	push   0x10(%ebp)
  8006af:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b2:	50                   	push   %eax
  8006b3:	68 0a 02 80 00       	push   $0x80020a
  8006b8:	e8 87 fb ff ff       	call   800244 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c6:	83 c4 10             	add    $0x10,%esp
}
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    
		return -E_INVAL;
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d0:	eb f7                	jmp    8006c9 <vsnprintf+0x45>

008006d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006db:	50                   	push   %eax
  8006dc:	ff 75 10             	push   0x10(%ebp)
  8006df:	ff 75 0c             	push   0xc(%ebp)
  8006e2:	ff 75 08             	push   0x8(%ebp)
  8006e5:	e8 9a ff ff ff       	call   800684 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	eb 03                	jmp    8006fc <strlen+0x10>
		n++;
  8006f9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006fc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800700:	75 f7                	jne    8006f9 <strlen+0xd>
	return n;
}
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	b8 00 00 00 00       	mov    $0x0,%eax
  800712:	eb 03                	jmp    800717 <strnlen+0x13>
		n++;
  800714:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	39 d0                	cmp    %edx,%eax
  800719:	74 08                	je     800723 <strnlen+0x1f>
  80071b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071f:	75 f3                	jne    800714 <strnlen+0x10>
  800721:	89 c2                	mov    %eax,%edx
	return n;
}
  800723:	89 d0                	mov    %edx,%eax
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80073a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80073d:	83 c0 01             	add    $0x1,%eax
  800740:	84 d2                	test   %dl,%dl
  800742:	75 f2                	jne    800736 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800744:	89 c8                	mov    %ecx,%eax
  800746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	83 ec 10             	sub    $0x10,%esp
  800752:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800755:	53                   	push   %ebx
  800756:	e8 91 ff ff ff       	call   8006ec <strlen>
  80075b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80075e:	ff 75 0c             	push   0xc(%ebp)
  800761:	01 d8                	add    %ebx,%eax
  800763:	50                   	push   %eax
  800764:	e8 be ff ff ff       	call   800727 <strcpy>
	return dst;
}
  800769:	89 d8                	mov    %ebx,%eax
  80076b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077b:	89 f3                	mov    %esi,%ebx
  80077d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800780:	89 f0                	mov    %esi,%eax
  800782:	eb 0f                	jmp    800793 <strncpy+0x23>
		*dst++ = *src;
  800784:	83 c0 01             	add    $0x1,%eax
  800787:	0f b6 0a             	movzbl (%edx),%ecx
  80078a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078d:	80 f9 01             	cmp    $0x1,%cl
  800790:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800793:	39 d8                	cmp    %ebx,%eax
  800795:	75 ed                	jne    800784 <strncpy+0x14>
	}
	return ret;
}
  800797:	89 f0                	mov    %esi,%eax
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	74 21                	je     8007d2 <strlcpy+0x35>
  8007b1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	eb 09                	jmp    8007c2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b9:	83 c1 01             	add    $0x1,%ecx
  8007bc:	83 c2 01             	add    $0x1,%edx
  8007bf:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007c2:	39 c2                	cmp    %eax,%edx
  8007c4:	74 09                	je     8007cf <strlcpy+0x32>
  8007c6:	0f b6 19             	movzbl (%ecx),%ebx
  8007c9:	84 db                	test   %bl,%bl
  8007cb:	75 ec                	jne    8007b9 <strlcpy+0x1c>
  8007cd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007cf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d2:	29 f0                	sub    %esi,%eax
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e1:	eb 06                	jmp    8007e9 <strcmp+0x11>
		p++, q++;
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007e9:	0f b6 01             	movzbl (%ecx),%eax
  8007ec:	84 c0                	test   %al,%al
  8007ee:	74 04                	je     8007f4 <strcmp+0x1c>
  8007f0:	3a 02                	cmp    (%edx),%al
  8007f2:	74 ef                	je     8007e3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f4:	0f b6 c0             	movzbl %al,%eax
  8007f7:	0f b6 12             	movzbl (%edx),%edx
  8007fa:	29 d0                	sub    %edx,%eax
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	89 c3                	mov    %eax,%ebx
  80080a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080d:	eb 06                	jmp    800815 <strncmp+0x17>
		n--, p++, q++;
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800815:	39 d8                	cmp    %ebx,%eax
  800817:	74 18                	je     800831 <strncmp+0x33>
  800819:	0f b6 08             	movzbl (%eax),%ecx
  80081c:	84 c9                	test   %cl,%cl
  80081e:	74 04                	je     800824 <strncmp+0x26>
  800820:	3a 0a                	cmp    (%edx),%cl
  800822:	74 eb                	je     80080f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800824:	0f b6 00             	movzbl (%eax),%eax
  800827:	0f b6 12             	movzbl (%edx),%edx
  80082a:	29 d0                	sub    %edx,%eax
}
  80082c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082f:	c9                   	leave  
  800830:	c3                   	ret    
		return 0;
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
  800836:	eb f4                	jmp    80082c <strncmp+0x2e>

00800838 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800842:	eb 03                	jmp    800847 <strchr+0xf>
  800844:	83 c0 01             	add    $0x1,%eax
  800847:	0f b6 10             	movzbl (%eax),%edx
  80084a:	84 d2                	test   %dl,%dl
  80084c:	74 06                	je     800854 <strchr+0x1c>
		if (*s == c)
  80084e:	38 ca                	cmp    %cl,%dl
  800850:	75 f2                	jne    800844 <strchr+0xc>
  800852:	eb 05                	jmp    800859 <strchr+0x21>
			return (char *) s;
	return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800865:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 09                	je     800875 <strfind+0x1a>
  80086c:	84 d2                	test   %dl,%dl
  80086e:	74 05                	je     800875 <strfind+0x1a>
	for (; *s; s++)
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	eb f0                	jmp    800865 <strfind+0xa>
			break;
	return (char *) s;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	57                   	push   %edi
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800880:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	74 2f                	je     8008b6 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800887:	89 f8                	mov    %edi,%eax
  800889:	09 c8                	or     %ecx,%eax
  80088b:	a8 03                	test   $0x3,%al
  80088d:	75 21                	jne    8008b0 <memset+0x39>
		c &= 0xFF;
  80088f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800893:	89 d0                	mov    %edx,%eax
  800895:	c1 e0 08             	shl    $0x8,%eax
  800898:	89 d3                	mov    %edx,%ebx
  80089a:	c1 e3 18             	shl    $0x18,%ebx
  80089d:	89 d6                	mov    %edx,%esi
  80089f:	c1 e6 10             	shl    $0x10,%esi
  8008a2:	09 f3                	or     %esi,%ebx
  8008a4:	09 da                	or     %ebx,%edx
  8008a6:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008ab:	fc                   	cld    
  8008ac:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ae:	eb 06                	jmp    8008b6 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	fc                   	cld    
  8008b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b6:	89 f8                	mov    %edi,%eax
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5f                   	pop    %edi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cb:	39 c6                	cmp    %eax,%esi
  8008cd:	73 32                	jae    800901 <memmove+0x44>
  8008cf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d2:	39 c2                	cmp    %eax,%edx
  8008d4:	76 2b                	jbe    800901 <memmove+0x44>
		s += n;
		d += n;
  8008d6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d9:	89 d6                	mov    %edx,%esi
  8008db:	09 fe                	or     %edi,%esi
  8008dd:	09 ce                	or     %ecx,%esi
  8008df:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e5:	75 0e                	jne    8008f5 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e7:	83 ef 04             	sub    $0x4,%edi
  8008ea:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ed:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008f0:	fd                   	std    
  8008f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f3:	eb 09                	jmp    8008fe <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f5:	83 ef 01             	sub    $0x1,%edi
  8008f8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008fb:	fd                   	std    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fe:	fc                   	cld    
  8008ff:	eb 1a                	jmp    80091b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800901:	89 f2                	mov    %esi,%edx
  800903:	09 c2                	or     %eax,%edx
  800905:	09 ca                	or     %ecx,%edx
  800907:	f6 c2 03             	test   $0x3,%dl
  80090a:	75 0a                	jne    800916 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80090f:	89 c7                	mov    %eax,%edi
  800911:	fc                   	cld    
  800912:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800914:	eb 05                	jmp    80091b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800925:	ff 75 10             	push   0x10(%ebp)
  800928:	ff 75 0c             	push   0xc(%ebp)
  80092b:	ff 75 08             	push   0x8(%ebp)
  80092e:	e8 8a ff ff ff       	call   8008bd <memmove>
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 c6                	mov    %eax,%esi
  800942:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800945:	eb 06                	jmp    80094d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80094d:	39 f0                	cmp    %esi,%eax
  80094f:	74 14                	je     800965 <memcmp+0x30>
		if (*s1 != *s2)
  800951:	0f b6 08             	movzbl (%eax),%ecx
  800954:	0f b6 1a             	movzbl (%edx),%ebx
  800957:	38 d9                	cmp    %bl,%cl
  800959:	74 ec                	je     800947 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  80095b:	0f b6 c1             	movzbl %cl,%eax
  80095e:	0f b6 db             	movzbl %bl,%ebx
  800961:	29 d8                	sub    %ebx,%eax
  800963:	eb 05                	jmp    80096a <memcmp+0x35>
	}

	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800977:	89 c2                	mov    %eax,%edx
  800979:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097c:	eb 03                	jmp    800981 <memfind+0x13>
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	39 d0                	cmp    %edx,%eax
  800983:	73 04                	jae    800989 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	38 08                	cmp    %cl,(%eax)
  800987:	75 f5                	jne    80097e <memfind+0x10>
			break;
	return (void *) s;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	57                   	push   %edi
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 55 08             	mov    0x8(%ebp),%edx
  800994:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	eb 03                	jmp    80099c <strtol+0x11>
		s++;
  800999:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80099c:	0f b6 02             	movzbl (%edx),%eax
  80099f:	3c 20                	cmp    $0x20,%al
  8009a1:	74 f6                	je     800999 <strtol+0xe>
  8009a3:	3c 09                	cmp    $0x9,%al
  8009a5:	74 f2                	je     800999 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009a7:	3c 2b                	cmp    $0x2b,%al
  8009a9:	74 2a                	je     8009d5 <strtol+0x4a>
	int neg = 0;
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009b0:	3c 2d                	cmp    $0x2d,%al
  8009b2:	74 2b                	je     8009df <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ba:	75 0f                	jne    8009cb <strtol+0x40>
  8009bc:	80 3a 30             	cmpb   $0x30,(%edx)
  8009bf:	74 28                	je     8009e9 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c1:	85 db                	test   %ebx,%ebx
  8009c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009c8:	0f 44 d8             	cmove  %eax,%ebx
  8009cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d3:	eb 46                	jmp    800a1b <strtol+0x90>
		s++;
  8009d5:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009dd:	eb d5                	jmp    8009b4 <strtol+0x29>
		s++, neg = 1;
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e7:	eb cb                	jmp    8009b4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ed:	74 0e                	je     8009fd <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	75 d8                	jne    8009cb <strtol+0x40>
		s++, base = 8;
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009fb:	eb ce                	jmp    8009cb <strtol+0x40>
		s += 2, base = 16;
  8009fd:	83 c2 02             	add    $0x2,%edx
  800a00:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a05:	eb c4                	jmp    8009cb <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a07:	0f be c0             	movsbl %al,%eax
  800a0a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a0d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a10:	7d 3a                	jge    800a4c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a12:	83 c2 01             	add    $0x1,%edx
  800a15:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a19:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a1b:	0f b6 02             	movzbl (%edx),%eax
  800a1e:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 09             	cmp    $0x9,%bl
  800a26:	76 df                	jbe    800a07 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a28:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 08                	ja     800a3a <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a32:	0f be c0             	movsbl %al,%eax
  800a35:	83 e8 57             	sub    $0x57,%eax
  800a38:	eb d3                	jmp    800a0d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a3a:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a3d:	89 f3                	mov    %esi,%ebx
  800a3f:	80 fb 19             	cmp    $0x19,%bl
  800a42:	77 08                	ja     800a4c <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a44:	0f be c0             	movsbl %al,%eax
  800a47:	83 e8 37             	sub    $0x37,%eax
  800a4a:	eb c1                	jmp    800a0d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a50:	74 05                	je     800a57 <strtol+0xcc>
		*endptr = (char *) s;
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a57:	89 c8                	mov    %ecx,%eax
  800a59:	f7 d8                	neg    %eax
  800a5b:	85 ff                	test   %edi,%edi
  800a5d:	0f 45 c8             	cmovne %eax,%ecx
}
  800a60:	89 c8                	mov    %ecx,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a78:	89 c3                	mov    %eax,%ebx
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	89 c6                	mov    %eax,%esi
  800a7e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a90:	b8 01 00 00 00       	mov    $0x1,%eax
  800a95:	89 d1                	mov    %edx,%ecx
  800a97:	89 d3                	mov    %edx,%ebx
  800a99:	89 d7                	mov    %edx,%edi
  800a9b:	89 d6                	mov    %edx,%esi
  800a9d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aba:	89 cb                	mov    %ecx,%ebx
  800abc:	89 cf                	mov    %ecx,%edi
  800abe:	89 ce                	mov    %ecx,%esi
  800ac0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	7f 08                	jg     800ace <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	50                   	push   %eax
  800ad2:	6a 03                	push   $0x3
  800ad4:	68 c4 11 80 00       	push   $0x8011c4
  800ad9:	6a 2a                	push   $0x2a
  800adb:	68 e1 11 80 00       	push   $0x8011e1
  800ae0:	e8 ed 01 00 00       	call   800cd2 <_panic>

00800ae5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 02 00 00 00       	mov    $0x2,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_yield>:

void
sys_yield(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b2c:	be 00 00 00 00       	mov    $0x0,%esi
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3f:	89 f7                	mov    %esi,%edi
  800b41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7f 08                	jg     800b4f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 04                	push   $0x4
  800b55:	68 c4 11 80 00       	push   $0x8011c4
  800b5a:	6a 2a                	push   $0x2a
  800b5c:	68 e1 11 80 00       	push   $0x8011e1
  800b61:	e8 6c 01 00 00       	call   800cd2 <_panic>

00800b66 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b80:	8b 75 18             	mov    0x18(%ebp),%esi
  800b83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7f 08                	jg     800b91 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	50                   	push   %eax
  800b95:	6a 05                	push   $0x5
  800b97:	68 c4 11 80 00       	push   $0x8011c4
  800b9c:	6a 2a                	push   $0x2a
  800b9e:	68 e1 11 80 00       	push   $0x8011e1
  800ba3:	e8 2a 01 00 00       	call   800cd2 <_panic>

00800ba8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc1:	89 df                	mov    %ebx,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7f 08                	jg     800bd3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 06                	push   $0x6
  800bd9:	68 c4 11 80 00       	push   $0x8011c4
  800bde:	6a 2a                	push   $0x2a
  800be0:	68 e1 11 80 00       	push   $0x8011e1
  800be5:	e8 e8 00 00 00       	call   800cd2 <_panic>

00800bea <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	b8 08 00 00 00       	mov    $0x8,%eax
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	89 de                	mov    %ebx,%esi
  800c07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7f 08                	jg     800c15 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 08                	push   $0x8
  800c1b:	68 c4 11 80 00       	push   $0x8011c4
  800c20:	6a 2a                	push   $0x2a
  800c22:	68 e1 11 80 00       	push   $0x8011e1
  800c27:	e8 a6 00 00 00       	call   800cd2 <_panic>

00800c2c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	b8 09 00 00 00       	mov    $0x9,%eax
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 09                	push   $0x9
  800c5d:	68 c4 11 80 00       	push   $0x8011c4
  800c62:	6a 2a                	push   $0x2a
  800c64:	68 e1 11 80 00       	push   $0x8011e1
  800c69:	e8 64 00 00 00       	call   800cd2 <_panic>

00800c6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7f:	be 00 00 00 00       	mov    $0x0,%esi
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca7:	89 cb                	mov    %ecx,%ebx
  800ca9:	89 cf                	mov    %ecx,%edi
  800cab:	89 ce                	mov    %ecx,%esi
  800cad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7f 08                	jg     800cbb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 0c                	push   $0xc
  800cc1:	68 c4 11 80 00       	push   $0x8011c4
  800cc6:	6a 2a                	push   $0x2a
  800cc8:	68 e1 11 80 00       	push   $0x8011e1
  800ccd:	e8 00 00 00 00       	call   800cd2 <_panic>

00800cd2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cd7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cda:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ce0:	e8 00 fe ff ff       	call   800ae5 <sys_getenvid>
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	ff 75 0c             	push   0xc(%ebp)
  800ceb:	ff 75 08             	push   0x8(%ebp)
  800cee:	56                   	push   %esi
  800cef:	50                   	push   %eax
  800cf0:	68 f0 11 80 00       	push   $0x8011f0
  800cf5:	e8 53 f4 ff ff       	call   80014d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cfa:	83 c4 18             	add    $0x18,%esp
  800cfd:	53                   	push   %ebx
  800cfe:	ff 75 10             	push   0x10(%ebp)
  800d01:	e8 f6 f3 ff ff       	call   8000fc <vcprintf>
	cprintf("\n");
  800d06:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  800d0d:	e8 3b f4 ff ff       	call   80014d <cprintf>
  800d12:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d15:	cc                   	int3   
  800d16:	eb fd                	jmp    800d15 <_panic+0x43>
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
