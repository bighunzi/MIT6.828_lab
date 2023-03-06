
obj/user/faultdie：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	push   (%edx)
  800045:	68 20 10 80 00       	push   $0x801020
  80004a:	e8 1e 01 00 00       	call   80016d <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 b1 0a 00 00       	call   800b05 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 68 0a 00 00       	call   800ac4 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 81 0c 00 00       	call   800cf2 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 75 0a 00 00       	call   800b05 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 f1 09 00 00       	call   800ac4 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	74 09                	je     800100 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	68 ff 00 00 00       	push   $0xff
  800108:	8d 43 08             	lea    0x8(%ebx),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 76 09 00 00       	call   800a87 <sys_cputs>
		b->idx = 0;
  800111:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	eb db                	jmp    8000f7 <putch+0x1f>

0080011c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800125:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012c:	00 00 00 
	b.cnt = 0;
  80012f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800136:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800139:	ff 75 0c             	push   0xc(%ebp)
  80013c:	ff 75 08             	push   0x8(%ebp)
  80013f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	68 d8 00 80 00       	push   $0x8000d8
  80014b:	e8 14 01 00 00       	call   800264 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	83 c4 08             	add    $0x8,%esp
  800153:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	e8 22 09 00 00       	call   800a87 <sys_cputs>

	return b.cnt;
}
  800165:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800176:	50                   	push   %eax
  800177:	ff 75 08             	push   0x8(%ebp)
  80017a:	e8 9d ff ff ff       	call   80011c <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 1c             	sub    $0x1c,%esp
  80018a:	89 c7                	mov    %eax,%edi
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	8b 55 0c             	mov    0xc(%ebp),%edx
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 c2                	mov    %eax,%edx
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019e:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ae:	39 c2                	cmp    %eax,%edx
  8001b0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b3:	72 3e                	jb     8001f3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 18             	push   0x18(%ebp)
  8001bb:	83 eb 01             	sub    $0x1,%ebx
  8001be:	53                   	push   %ebx
  8001bf:	50                   	push   %eax
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	ff 75 e4             	push   -0x1c(%ebp)
  8001c6:	ff 75 e0             	push   -0x20(%ebp)
  8001c9:	ff 75 dc             	push   -0x24(%ebp)
  8001cc:	ff 75 d8             	push   -0x28(%ebp)
  8001cf:	e8 0c 0c 00 00       	call   800de0 <__udivdi3>
  8001d4:	83 c4 18             	add    $0x18,%esp
  8001d7:	52                   	push   %edx
  8001d8:	50                   	push   %eax
  8001d9:	89 f2                	mov    %esi,%edx
  8001db:	89 f8                	mov    %edi,%eax
  8001dd:	e8 9f ff ff ff       	call   800181 <printnum>
  8001e2:	83 c4 20             	add    $0x20,%esp
  8001e5:	eb 13                	jmp    8001fa <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	56                   	push   %esi
  8001eb:	ff 75 18             	push   0x18(%ebp)
  8001ee:	ff d7                	call   *%edi
  8001f0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f3:	83 eb 01             	sub    $0x1,%ebx
  8001f6:	85 db                	test   %ebx,%ebx
  8001f8:	7f ed                	jg     8001e7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	56                   	push   %esi
  8001fe:	83 ec 04             	sub    $0x4,%esp
  800201:	ff 75 e4             	push   -0x1c(%ebp)
  800204:	ff 75 e0             	push   -0x20(%ebp)
  800207:	ff 75 dc             	push   -0x24(%ebp)
  80020a:	ff 75 d8             	push   -0x28(%ebp)
  80020d:	e8 ee 0c 00 00       	call   800f00 <__umoddi3>
  800212:	83 c4 14             	add    $0x14,%esp
  800215:	0f be 80 46 10 80 00 	movsbl 0x801046(%eax),%eax
  80021c:	50                   	push   %eax
  80021d:	ff d7                	call   *%edi
}
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800230:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800234:	8b 10                	mov    (%eax),%edx
  800236:	3b 50 04             	cmp    0x4(%eax),%edx
  800239:	73 0a                	jae    800245 <sprintputch+0x1b>
		*b->buf++ = ch;
  80023b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	88 02                	mov    %al,(%edx)
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <printfmt>:
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800250:	50                   	push   %eax
  800251:	ff 75 10             	push   0x10(%ebp)
  800254:	ff 75 0c             	push   0xc(%ebp)
  800257:	ff 75 08             	push   0x8(%ebp)
  80025a:	e8 05 00 00 00       	call   800264 <vprintfmt>
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <vprintfmt>:
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 3c             	sub    $0x3c,%esp
  80026d:	8b 75 08             	mov    0x8(%ebp),%esi
  800270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800273:	8b 7d 10             	mov    0x10(%ebp),%edi
  800276:	eb 0a                	jmp    800282 <vprintfmt+0x1e>
			putch(ch, putdat);
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	53                   	push   %ebx
  80027c:	50                   	push   %eax
  80027d:	ff d6                	call   *%esi
  80027f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800282:	83 c7 01             	add    $0x1,%edi
  800285:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800289:	83 f8 25             	cmp    $0x25,%eax
  80028c:	74 0c                	je     80029a <vprintfmt+0x36>
			if (ch == '\0')
  80028e:	85 c0                	test   %eax,%eax
  800290:	75 e6                	jne    800278 <vprintfmt+0x14>
}
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    
		padc = ' ';
  80029a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80029e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002a5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002b3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002b8:	8d 47 01             	lea    0x1(%edi),%eax
  8002bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002be:	0f b6 17             	movzbl (%edi),%edx
  8002c1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002c4:	3c 55                	cmp    $0x55,%al
  8002c6:	0f 87 bb 03 00 00    	ja     800687 <vprintfmt+0x423>
  8002cc:	0f b6 c0             	movzbl %al,%eax
  8002cf:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  8002d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002d9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002dd:	eb d9                	jmp    8002b8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002e2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002e6:	eb d0                	jmp    8002b8 <vprintfmt+0x54>
  8002e8:	0f b6 d2             	movzbl %dl,%edx
  8002eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002fd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800300:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800303:	83 f9 09             	cmp    $0x9,%ecx
  800306:	77 55                	ja     80035d <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800308:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80030b:	eb e9                	jmp    8002f6 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80030d:	8b 45 14             	mov    0x14(%ebp),%eax
  800310:	8b 00                	mov    (%eax),%eax
  800312:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8d 40 04             	lea    0x4(%eax),%eax
  80031b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800321:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800325:	79 91                	jns    8002b8 <vprintfmt+0x54>
				width = precision, precision = -1;
  800327:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80032a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800334:	eb 82                	jmp    8002b8 <vprintfmt+0x54>
  800336:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800339:	85 d2                	test   %edx,%edx
  80033b:	b8 00 00 00 00       	mov    $0x0,%eax
  800340:	0f 49 c2             	cmovns %edx,%eax
  800343:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800349:	e9 6a ff ff ff       	jmp    8002b8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800351:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800358:	e9 5b ff ff ff       	jmp    8002b8 <vprintfmt+0x54>
  80035d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800360:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800363:	eb bc                	jmp    800321 <vprintfmt+0xbd>
			lflag++;
  800365:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80036b:	e9 48 ff ff ff       	jmp    8002b8 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 78 04             	lea    0x4(%eax),%edi
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	53                   	push   %ebx
  80037a:	ff 30                	push   (%eax)
  80037c:	ff d6                	call   *%esi
			break;
  80037e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800381:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800384:	e9 9d 02 00 00       	jmp    800626 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 78 04             	lea    0x4(%eax),%edi
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	89 d0                	mov    %edx,%eax
  800393:	f7 d8                	neg    %eax
  800395:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800398:	83 f8 08             	cmp    $0x8,%eax
  80039b:	7f 23                	jg     8003c0 <vprintfmt+0x15c>
  80039d:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  8003a4:	85 d2                	test   %edx,%edx
  8003a6:	74 18                	je     8003c0 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003a8:	52                   	push   %edx
  8003a9:	68 67 10 80 00       	push   $0x801067
  8003ae:	53                   	push   %ebx
  8003af:	56                   	push   %esi
  8003b0:	e8 92 fe ff ff       	call   800247 <printfmt>
  8003b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003bb:	e9 66 02 00 00       	jmp    800626 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003c0:	50                   	push   %eax
  8003c1:	68 5e 10 80 00       	push   $0x80105e
  8003c6:	53                   	push   %ebx
  8003c7:	56                   	push   %esi
  8003c8:	e8 7a fe ff ff       	call   800247 <printfmt>
  8003cd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003d3:	e9 4e 02 00 00       	jmp    800626 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	83 c0 04             	add    $0x4,%eax
  8003de:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	b8 57 10 80 00       	mov    $0x801057,%eax
  8003ed:	0f 45 c2             	cmovne %edx,%eax
  8003f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f7:	7e 06                	jle    8003ff <vprintfmt+0x19b>
  8003f9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003fd:	75 0d                	jne    80040c <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800402:	89 c7                	mov    %eax,%edi
  800404:	03 45 e0             	add    -0x20(%ebp),%eax
  800407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040a:	eb 55                	jmp    800461 <vprintfmt+0x1fd>
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	ff 75 d8             	push   -0x28(%ebp)
  800412:	ff 75 cc             	push   -0x34(%ebp)
  800415:	e8 0a 03 00 00       	call   800724 <strnlen>
  80041a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041d:	29 c1                	sub    %eax,%ecx
  80041f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800427:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80042b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80042e:	eb 0f                	jmp    80043f <vprintfmt+0x1db>
					putch(padc, putdat);
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	53                   	push   %ebx
  800434:	ff 75 e0             	push   -0x20(%ebp)
  800437:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	83 ef 01             	sub    $0x1,%edi
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	85 ff                	test   %edi,%edi
  800441:	7f ed                	jg     800430 <vprintfmt+0x1cc>
  800443:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800446:	85 d2                	test   %edx,%edx
  800448:	b8 00 00 00 00       	mov    $0x0,%eax
  80044d:	0f 49 c2             	cmovns %edx,%eax
  800450:	29 c2                	sub    %eax,%edx
  800452:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800455:	eb a8                	jmp    8003ff <vprintfmt+0x19b>
					putch(ch, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	52                   	push   %edx
  80045c:	ff d6                	call   *%esi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800464:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800466:	83 c7 01             	add    $0x1,%edi
  800469:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046d:	0f be d0             	movsbl %al,%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	74 4b                	je     8004bf <vprintfmt+0x25b>
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	78 06                	js     800480 <vprintfmt+0x21c>
  80047a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80047e:	78 1e                	js     80049e <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800480:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800484:	74 d1                	je     800457 <vprintfmt+0x1f3>
  800486:	0f be c0             	movsbl %al,%eax
  800489:	83 e8 20             	sub    $0x20,%eax
  80048c:	83 f8 5e             	cmp    $0x5e,%eax
  80048f:	76 c6                	jbe    800457 <vprintfmt+0x1f3>
					putch('?', putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	53                   	push   %ebx
  800495:	6a 3f                	push   $0x3f
  800497:	ff d6                	call   *%esi
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	eb c3                	jmp    800461 <vprintfmt+0x1fd>
  80049e:	89 cf                	mov    %ecx,%edi
  8004a0:	eb 0e                	jmp    8004b0 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	6a 20                	push   $0x20
  8004a8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004aa:	83 ef 01             	sub    $0x1,%edi
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	85 ff                	test   %edi,%edi
  8004b2:	7f ee                	jg     8004a2 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ba:	e9 67 01 00 00       	jmp    800626 <vprintfmt+0x3c2>
  8004bf:	89 cf                	mov    %ecx,%edi
  8004c1:	eb ed                	jmp    8004b0 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004c3:	83 f9 01             	cmp    $0x1,%ecx
  8004c6:	7f 1b                	jg     8004e3 <vprintfmt+0x27f>
	else if (lflag)
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	74 63                	je     80052f <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d4:	99                   	cltd   
  8004d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 40 04             	lea    0x4(%eax),%eax
  8004de:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e1:	eb 17                	jmp    8004fa <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8b 50 04             	mov    0x4(%eax),%edx
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 40 08             	lea    0x8(%eax),%eax
  8004f7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800500:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800505:	85 c9                	test   %ecx,%ecx
  800507:	0f 89 ff 00 00 00    	jns    80060c <vprintfmt+0x3a8>
				putch('-', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	6a 2d                	push   $0x2d
  800513:	ff d6                	call   *%esi
				num = -(long long) num;
  800515:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800518:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051b:	f7 da                	neg    %edx
  80051d:	83 d1 00             	adc    $0x0,%ecx
  800520:	f7 d9                	neg    %ecx
  800522:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800525:	bf 0a 00 00 00       	mov    $0xa,%edi
  80052a:	e9 dd 00 00 00       	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	99                   	cltd   
  800538:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 40 04             	lea    0x4(%eax),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
  800544:	eb b4                	jmp    8004fa <vprintfmt+0x296>
	if (lflag >= 2)
  800546:	83 f9 01             	cmp    $0x1,%ecx
  800549:	7f 1e                	jg     800569 <vprintfmt+0x305>
	else if (lflag)
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	74 32                	je     800581 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 10                	mov    (%eax),%edx
  800554:	b9 00 00 00 00       	mov    $0x0,%ecx
  800559:	8d 40 04             	lea    0x4(%eax),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800564:	e9 a3 00 00 00       	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	8b 48 04             	mov    0x4(%eax),%ecx
  800571:	8d 40 08             	lea    0x8(%eax),%eax
  800574:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800577:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80057c:	e9 8b 00 00 00       	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 10                	mov    (%eax),%edx
  800586:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058b:	8d 40 04             	lea    0x4(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800591:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800596:	eb 74                	jmp    80060c <vprintfmt+0x3a8>
	if (lflag >= 2)
  800598:	83 f9 01             	cmp    $0x1,%ecx
  80059b:	7f 1b                	jg     8005b8 <vprintfmt+0x354>
	else if (lflag)
  80059d:	85 c9                	test   %ecx,%ecx
  80059f:	74 2c                	je     8005cd <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005b1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005b6:	eb 54                	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 10                	mov    (%eax),%edx
  8005bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c0:	8d 40 08             	lea    0x8(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005cb:	eb 3f                	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005dd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005e2:	eb 28                	jmp    80060c <vprintfmt+0x3a8>
			putch('0', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 30                	push   $0x30
  8005ea:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ec:	83 c4 08             	add    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 78                	push   $0x78
  8005f2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005fe:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800601:	8d 40 04             	lea    0x4(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800607:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800613:	50                   	push   %eax
  800614:	ff 75 e0             	push   -0x20(%ebp)
  800617:	57                   	push   %edi
  800618:	51                   	push   %ecx
  800619:	52                   	push   %edx
  80061a:	89 da                	mov    %ebx,%edx
  80061c:	89 f0                	mov    %esi,%eax
  80061e:	e8 5e fb ff ff       	call   800181 <printnum>
			break;
  800623:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800629:	e9 54 fc ff ff       	jmp    800282 <vprintfmt+0x1e>
	if (lflag >= 2)
  80062e:	83 f9 01             	cmp    $0x1,%ecx
  800631:	7f 1b                	jg     80064e <vprintfmt+0x3ea>
	else if (lflag)
  800633:	85 c9                	test   %ecx,%ecx
  800635:	74 2c                	je     800663 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80064c:	eb be                	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	8b 48 04             	mov    0x4(%eax),%ecx
  800656:	8d 40 08             	lea    0x8(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800661:	eb a9                	jmp    80060c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800673:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800678:	eb 92                	jmp    80060c <vprintfmt+0x3a8>
			putch(ch, putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 25                	push   $0x25
  800680:	ff d6                	call   *%esi
			break;
  800682:	83 c4 10             	add    $0x10,%esp
  800685:	eb 9f                	jmp    800626 <vprintfmt+0x3c2>
			putch('%', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 25                	push   $0x25
  80068d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	89 f8                	mov    %edi,%eax
  800694:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800698:	74 05                	je     80069f <vprintfmt+0x43b>
  80069a:	83 e8 01             	sub    $0x1,%eax
  80069d:	eb f5                	jmp    800694 <vprintfmt+0x430>
  80069f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a2:	eb 82                	jmp    800626 <vprintfmt+0x3c2>

008006a4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 26                	je     8006eb <vsnprintf+0x47>
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	7e 22                	jle    8006eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c9:	ff 75 14             	push   0x14(%ebp)
  8006cc:	ff 75 10             	push   0x10(%ebp)
  8006cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	68 2a 02 80 00       	push   $0x80022a
  8006d8:	e8 87 fb ff ff       	call   800264 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	83 c4 10             	add    $0x10,%esp
}
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f0:	eb f7                	jmp    8006e9 <vsnprintf+0x45>

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 10             	push   0x10(%ebp)
  8006ff:	ff 75 0c             	push   0xc(%ebp)
  800702:	ff 75 08             	push   0x8(%ebp)
  800705:	e8 9a ff ff ff       	call   8006a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 03                	jmp    80071c <strlen+0x10>
		n++;
  800719:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80071c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800720:	75 f7                	jne    800719 <strlen+0xd>
	return n;
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	b8 00 00 00 00       	mov    $0x0,%eax
  800732:	eb 03                	jmp    800737 <strnlen+0x13>
		n++;
  800734:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 d0                	cmp    %edx,%eax
  800739:	74 08                	je     800743 <strnlen+0x1f>
  80073b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073f:	75 f3                	jne    800734 <strnlen+0x10>
  800741:	89 c2                	mov    %eax,%edx
	return n;
}
  800743:	89 d0                	mov    %edx,%eax
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80075a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80075d:	83 c0 01             	add    $0x1,%eax
  800760:	84 d2                	test   %dl,%dl
  800762:	75 f2                	jne    800756 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800764:	89 c8                	mov    %ecx,%eax
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	83 ec 10             	sub    $0x10,%esp
  800772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800775:	53                   	push   %ebx
  800776:	e8 91 ff ff ff       	call   80070c <strlen>
  80077b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80077e:	ff 75 0c             	push   0xc(%ebp)
  800781:	01 d8                	add    %ebx,%eax
  800783:	50                   	push   %eax
  800784:	e8 be ff ff ff       	call   800747 <strcpy>
	return dst;
}
  800789:	89 d8                	mov    %ebx,%eax
  80078b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079b:	89 f3                	mov    %esi,%ebx
  80079d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a0:	89 f0                	mov    %esi,%eax
  8007a2:	eb 0f                	jmp    8007b3 <strncpy+0x23>
		*dst++ = *src;
  8007a4:	83 c0 01             	add    $0x1,%eax
  8007a7:	0f b6 0a             	movzbl (%edx),%ecx
  8007aa:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ad:	80 f9 01             	cmp    $0x1,%cl
  8007b0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007b3:	39 d8                	cmp    %ebx,%eax
  8007b5:	75 ed                	jne    8007a4 <strncpy+0x14>
	}
	return ret;
}
  8007b7:	89 f0                	mov    %esi,%eax
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007cb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	74 21                	je     8007f2 <strlcpy+0x35>
  8007d1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	eb 09                	jmp    8007e2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d9:	83 c1 01             	add    $0x1,%ecx
  8007dc:	83 c2 01             	add    $0x1,%edx
  8007df:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007e2:	39 c2                	cmp    %eax,%edx
  8007e4:	74 09                	je     8007ef <strlcpy+0x32>
  8007e6:	0f b6 19             	movzbl (%ecx),%ebx
  8007e9:	84 db                	test   %bl,%bl
  8007eb:	75 ec                	jne    8007d9 <strlcpy+0x1c>
  8007ed:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f2:	29 f0                	sub    %esi,%eax
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800801:	eb 06                	jmp    800809 <strcmp+0x11>
		p++, q++;
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800809:	0f b6 01             	movzbl (%ecx),%eax
  80080c:	84 c0                	test   %al,%al
  80080e:	74 04                	je     800814 <strcmp+0x1c>
  800810:	3a 02                	cmp    (%edx),%al
  800812:	74 ef                	je     800803 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800814:	0f b6 c0             	movzbl %al,%eax
  800817:	0f b6 12             	movzbl (%edx),%edx
  80081a:	29 d0                	sub    %edx,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
  800828:	89 c3                	mov    %eax,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082d:	eb 06                	jmp    800835 <strncmp+0x17>
		n--, p++, q++;
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800835:	39 d8                	cmp    %ebx,%eax
  800837:	74 18                	je     800851 <strncmp+0x33>
  800839:	0f b6 08             	movzbl (%eax),%ecx
  80083c:	84 c9                	test   %cl,%cl
  80083e:	74 04                	je     800844 <strncmp+0x26>
  800840:	3a 0a                	cmp    (%edx),%cl
  800842:	74 eb                	je     80082f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800844:	0f b6 00             	movzbl (%eax),%eax
  800847:	0f b6 12             	movzbl (%edx),%edx
  80084a:	29 d0                	sub    %edx,%eax
}
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    
		return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb f4                	jmp    80084c <strncmp+0x2e>

00800858 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800862:	eb 03                	jmp    800867 <strchr+0xf>
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	0f b6 10             	movzbl (%eax),%edx
  80086a:	84 d2                	test   %dl,%dl
  80086c:	74 06                	je     800874 <strchr+0x1c>
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	75 f2                	jne    800864 <strchr+0xc>
  800872:	eb 05                	jmp    800879 <strchr+0x21>
			return (char *) s;
	return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800885:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 09                	je     800895 <strfind+0x1a>
  80088c:	84 d2                	test   %dl,%dl
  80088e:	74 05                	je     800895 <strfind+0x1a>
	for (; *s; s++)
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	eb f0                	jmp    800885 <strfind+0xa>
			break;
	return (char *) s;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	57                   	push   %edi
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a3:	85 c9                	test   %ecx,%ecx
  8008a5:	74 2f                	je     8008d6 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a7:	89 f8                	mov    %edi,%eax
  8008a9:	09 c8                	or     %ecx,%eax
  8008ab:	a8 03                	test   $0x3,%al
  8008ad:	75 21                	jne    8008d0 <memset+0x39>
		c &= 0xFF;
  8008af:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b3:	89 d0                	mov    %edx,%eax
  8008b5:	c1 e0 08             	shl    $0x8,%eax
  8008b8:	89 d3                	mov    %edx,%ebx
  8008ba:	c1 e3 18             	shl    $0x18,%ebx
  8008bd:	89 d6                	mov    %edx,%esi
  8008bf:	c1 e6 10             	shl    $0x10,%esi
  8008c2:	09 f3                	or     %esi,%ebx
  8008c4:	09 da                	or     %ebx,%edx
  8008c6:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008cb:	fc                   	cld    
  8008cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ce:	eb 06                	jmp    8008d6 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d3:	fc                   	cld    
  8008d4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d6:	89 f8                	mov    %edi,%eax
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008eb:	39 c6                	cmp    %eax,%esi
  8008ed:	73 32                	jae    800921 <memmove+0x44>
  8008ef:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f2:	39 c2                	cmp    %eax,%edx
  8008f4:	76 2b                	jbe    800921 <memmove+0x44>
		s += n;
		d += n;
  8008f6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f9:	89 d6                	mov    %edx,%esi
  8008fb:	09 fe                	or     %edi,%esi
  8008fd:	09 ce                	or     %ecx,%esi
  8008ff:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800905:	75 0e                	jne    800915 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800907:	83 ef 04             	sub    $0x4,%edi
  80090a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800910:	fd                   	std    
  800911:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800913:	eb 09                	jmp    80091e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800915:	83 ef 01             	sub    $0x1,%edi
  800918:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80091b:	fd                   	std    
  80091c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091e:	fc                   	cld    
  80091f:	eb 1a                	jmp    80093b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 f2                	mov    %esi,%edx
  800923:	09 c2                	or     %eax,%edx
  800925:	09 ca                	or     %ecx,%edx
  800927:	f6 c2 03             	test   $0x3,%dl
  80092a:	75 0a                	jne    800936 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 05                	jmp    80093b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800945:	ff 75 10             	push   0x10(%ebp)
  800948:	ff 75 0c             	push   0xc(%ebp)
  80094b:	ff 75 08             	push   0x8(%ebp)
  80094e:	e8 8a ff ff ff       	call   8008dd <memmove>
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800960:	89 c6                	mov    %eax,%esi
  800962:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800965:	eb 06                	jmp    80096d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  80096d:	39 f0                	cmp    %esi,%eax
  80096f:	74 14                	je     800985 <memcmp+0x30>
		if (*s1 != *s2)
  800971:	0f b6 08             	movzbl (%eax),%ecx
  800974:	0f b6 1a             	movzbl (%edx),%ebx
  800977:	38 d9                	cmp    %bl,%cl
  800979:	74 ec                	je     800967 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  80097b:	0f b6 c1             	movzbl %cl,%eax
  80097e:	0f b6 db             	movzbl %bl,%ebx
  800981:	29 d8                	sub    %ebx,%eax
  800983:	eb 05                	jmp    80098a <memcmp+0x35>
	}

	return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800997:	89 c2                	mov    %eax,%edx
  800999:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099c:	eb 03                	jmp    8009a1 <memfind+0x13>
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 04                	jae    8009a9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a5:	38 08                	cmp    %cl,(%eax)
  8009a7:	75 f5                	jne    80099e <memfind+0x10>
			break;
	return (void *) s;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b7:	eb 03                	jmp    8009bc <strtol+0x11>
		s++;
  8009b9:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009bc:	0f b6 02             	movzbl (%edx),%eax
  8009bf:	3c 20                	cmp    $0x20,%al
  8009c1:	74 f6                	je     8009b9 <strtol+0xe>
  8009c3:	3c 09                	cmp    $0x9,%al
  8009c5:	74 f2                	je     8009b9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009c7:	3c 2b                	cmp    $0x2b,%al
  8009c9:	74 2a                	je     8009f5 <strtol+0x4a>
	int neg = 0;
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009d0:	3c 2d                	cmp    $0x2d,%al
  8009d2:	74 2b                	je     8009ff <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009da:	75 0f                	jne    8009eb <strtol+0x40>
  8009dc:	80 3a 30             	cmpb   $0x30,(%edx)
  8009df:	74 28                	je     800a09 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e1:	85 db                	test   %ebx,%ebx
  8009e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009e8:	0f 44 d8             	cmove  %eax,%ebx
  8009eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009f3:	eb 46                	jmp    800a3b <strtol+0x90>
		s++;
  8009f5:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fd:	eb d5                	jmp    8009d4 <strtol+0x29>
		s++, neg = 1;
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	bf 01 00 00 00       	mov    $0x1,%edi
  800a07:	eb cb                	jmp    8009d4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a0d:	74 0e                	je     800a1d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a0f:	85 db                	test   %ebx,%ebx
  800a11:	75 d8                	jne    8009eb <strtol+0x40>
		s++, base = 8;
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a1b:	eb ce                	jmp    8009eb <strtol+0x40>
		s += 2, base = 16;
  800a1d:	83 c2 02             	add    $0x2,%edx
  800a20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a25:	eb c4                	jmp    8009eb <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a27:	0f be c0             	movsbl %al,%eax
  800a2a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a2d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a30:	7d 3a                	jge    800a6c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a32:	83 c2 01             	add    $0x1,%edx
  800a35:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a39:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a3b:	0f b6 02             	movzbl (%edx),%eax
  800a3e:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a41:	89 f3                	mov    %esi,%ebx
  800a43:	80 fb 09             	cmp    $0x9,%bl
  800a46:	76 df                	jbe    800a27 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a48:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a4b:	89 f3                	mov    %esi,%ebx
  800a4d:	80 fb 19             	cmp    $0x19,%bl
  800a50:	77 08                	ja     800a5a <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a52:	0f be c0             	movsbl %al,%eax
  800a55:	83 e8 57             	sub    $0x57,%eax
  800a58:	eb d3                	jmp    800a2d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a5a:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	80 fb 19             	cmp    $0x19,%bl
  800a62:	77 08                	ja     800a6c <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a64:	0f be c0             	movsbl %al,%eax
  800a67:	83 e8 37             	sub    $0x37,%eax
  800a6a:	eb c1                	jmp    800a2d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a70:	74 05                	je     800a77 <strtol+0xcc>
		*endptr = (char *) s;
  800a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a75:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a77:	89 c8                	mov    %ecx,%eax
  800a79:	f7 d8                	neg    %eax
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	0f 45 c8             	cmovne %eax,%ecx
}
  800a80:	89 c8                	mov    %ecx,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	89 c3                	mov    %eax,%ebx
  800a9a:	89 c7                	mov    %eax,%edi
  800a9c:	89 c6                	mov    %eax,%esi
  800a9e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab5:	89 d1                	mov    %edx,%ecx
  800ab7:	89 d3                	mov    %edx,%ebx
  800ab9:	89 d7                	mov    %edx,%edi
  800abb:	89 d6                	mov    %edx,%esi
  800abd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800acd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	b8 03 00 00 00       	mov    $0x3,%eax
  800ada:	89 cb                	mov    %ecx,%ebx
  800adc:	89 cf                	mov    %ecx,%edi
  800ade:	89 ce                	mov    %ecx,%esi
  800ae0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	7f 08                	jg     800aee <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	50                   	push   %eax
  800af2:	6a 03                	push   $0x3
  800af4:	68 84 12 80 00       	push   $0x801284
  800af9:	6a 2a                	push   $0x2a
  800afb:	68 a1 12 80 00       	push   $0x8012a1
  800b00:	e8 89 02 00 00       	call   800d8e <_panic>

00800b05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 02 00 00 00       	mov    $0x2,%eax
  800b15:	89 d1                	mov    %edx,%ecx
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_yield>:

void
sys_yield(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b4c:	be 00 00 00 00       	mov    $0x0,%esi
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b57:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5f:	89 f7                	mov    %esi,%edi
  800b61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7f 08                	jg     800b6f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	50                   	push   %eax
  800b73:	6a 04                	push   $0x4
  800b75:	68 84 12 80 00       	push   $0x801284
  800b7a:	6a 2a                	push   $0x2a
  800b7c:	68 a1 12 80 00       	push   $0x8012a1
  800b81:	e8 08 02 00 00       	call   800d8e <_panic>

00800b86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7f 08                	jg     800bb1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	50                   	push   %eax
  800bb5:	6a 05                	push   $0x5
  800bb7:	68 84 12 80 00       	push   $0x801284
  800bbc:	6a 2a                	push   $0x2a
  800bbe:	68 a1 12 80 00       	push   $0x8012a1
  800bc3:	e8 c6 01 00 00       	call   800d8e <_panic>

00800bc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	b8 06 00 00 00       	mov    $0x6,%eax
  800be1:	89 df                	mov    %ebx,%edi
  800be3:	89 de                	mov    %ebx,%esi
  800be5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7f 08                	jg     800bf3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 06                	push   $0x6
  800bf9:	68 84 12 80 00       	push   $0x801284
  800bfe:	6a 2a                	push   $0x2a
  800c00:	68 a1 12 80 00       	push   $0x8012a1
  800c05:	e8 84 01 00 00       	call   800d8e <_panic>

00800c0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	89 de                	mov    %ebx,%esi
  800c27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7f 08                	jg     800c35 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	50                   	push   %eax
  800c39:	6a 08                	push   $0x8
  800c3b:	68 84 12 80 00       	push   $0x801284
  800c40:	6a 2a                	push   $0x2a
  800c42:	68 a1 12 80 00       	push   $0x8012a1
  800c47:	e8 42 01 00 00       	call   800d8e <_panic>

00800c4c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	b8 09 00 00 00       	mov    $0x9,%eax
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 09                	push   $0x9
  800c7d:	68 84 12 80 00       	push   $0x801284
  800c82:	6a 2a                	push   $0x2a
  800c84:	68 a1 12 80 00       	push   $0x8012a1
  800c89:	e8 00 01 00 00       	call   800d8e <_panic>

00800c8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800caa:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc7:	89 cb                	mov    %ecx,%ebx
  800cc9:	89 cf                	mov    %ecx,%edi
  800ccb:	89 ce                	mov    %ecx,%esi
  800ccd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7f 08                	jg     800cdb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 0c                	push   $0xc
  800ce1:	68 84 12 80 00       	push   $0x801284
  800ce6:	6a 2a                	push   $0x2a
  800ce8:	68 a1 12 80 00       	push   $0x8012a1
  800ced:	e8 9c 00 00 00       	call   800d8e <_panic>

00800cf2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800cf8:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cff:	74 0a                	je     800d0b <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800d0b:	e8 f5 fd ff ff       	call   800b05 <sys_getenvid>
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	68 07 0e 00 00       	push   $0xe07
  800d18:	68 00 f0 bf ee       	push   $0xeebff000
  800d1d:	50                   	push   %eax
  800d1e:	e8 20 fe ff ff       	call   800b43 <sys_page_alloc>
		if (r < 0) {
  800d23:	83 c4 10             	add    $0x10,%esp
  800d26:	85 c0                	test   %eax,%eax
  800d28:	78 2c                	js     800d56 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d2a:	e8 d6 fd ff ff       	call   800b05 <sys_getenvid>
  800d2f:	83 ec 08             	sub    $0x8,%esp
  800d32:	68 68 0d 80 00       	push   $0x800d68
  800d37:	50                   	push   %eax
  800d38:	e8 0f ff ff ff       	call   800c4c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	79 bd                	jns    800d01 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800d44:	50                   	push   %eax
  800d45:	68 f0 12 80 00       	push   $0x8012f0
  800d4a:	6a 28                	push   $0x28
  800d4c:	68 26 13 80 00       	push   $0x801326
  800d51:	e8 38 00 00 00       	call   800d8e <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800d56:	50                   	push   %eax
  800d57:	68 b0 12 80 00       	push   $0x8012b0
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 26 13 80 00       	push   $0x801326
  800d63:	e8 26 00 00 00       	call   800d8e <_panic>

00800d68 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d68:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d69:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d6e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d70:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800d73:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800d77:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800d7a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800d7e:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800d82:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800d84:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800d87:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800d88:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800d8b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800d8c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800d8d:	c3                   	ret    

00800d8e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d96:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d9c:	e8 64 fd ff ff       	call   800b05 <sys_getenvid>
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	ff 75 0c             	push   0xc(%ebp)
  800da7:	ff 75 08             	push   0x8(%ebp)
  800daa:	56                   	push   %esi
  800dab:	50                   	push   %eax
  800dac:	68 34 13 80 00       	push   $0x801334
  800db1:	e8 b7 f3 ff ff       	call   80016d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800db6:	83 c4 18             	add    $0x18,%esp
  800db9:	53                   	push   %ebx
  800dba:	ff 75 10             	push   0x10(%ebp)
  800dbd:	e8 5a f3 ff ff       	call   80011c <vcprintf>
	cprintf("\n");
  800dc2:	c7 04 24 3a 10 80 00 	movl   $0x80103a,(%esp)
  800dc9:	e8 9f f3 ff ff       	call   80016d <cprintf>
  800dce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dd1:	cc                   	int3   
  800dd2:	eb fd                	jmp    800dd1 <_panic+0x43>
  800dd4:	66 90                	xchg   %ax,%ax
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 1c             	sub    $0x1c,%esp
  800deb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800def:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800df3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	75 19                	jne    800e18 <__udivdi3+0x38>
  800dff:	39 f3                	cmp    %esi,%ebx
  800e01:	76 4d                	jbe    800e50 <__udivdi3+0x70>
  800e03:	31 ff                	xor    %edi,%edi
  800e05:	89 e8                	mov    %ebp,%eax
  800e07:	89 f2                	mov    %esi,%edx
  800e09:	f7 f3                	div    %ebx
  800e0b:	89 fa                	mov    %edi,%edx
  800e0d:	83 c4 1c             	add    $0x1c,%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	39 f0                	cmp    %esi,%eax
  800e1a:	76 14                	jbe    800e30 <__udivdi3+0x50>
  800e1c:	31 ff                	xor    %edi,%edi
  800e1e:	31 c0                	xor    %eax,%eax
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	83 c4 1c             	add    $0x1c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
  800e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e30:	0f bd f8             	bsr    %eax,%edi
  800e33:	83 f7 1f             	xor    $0x1f,%edi
  800e36:	75 48                	jne    800e80 <__udivdi3+0xa0>
  800e38:	39 f0                	cmp    %esi,%eax
  800e3a:	72 06                	jb     800e42 <__udivdi3+0x62>
  800e3c:	31 c0                	xor    %eax,%eax
  800e3e:	39 eb                	cmp    %ebp,%ebx
  800e40:	77 de                	ja     800e20 <__udivdi3+0x40>
  800e42:	b8 01 00 00 00       	mov    $0x1,%eax
  800e47:	eb d7                	jmp    800e20 <__udivdi3+0x40>
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d9                	mov    %ebx,%ecx
  800e52:	85 db                	test   %ebx,%ebx
  800e54:	75 0b                	jne    800e61 <__udivdi3+0x81>
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f3                	div    %ebx
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	31 d2                	xor    %edx,%edx
  800e63:	89 f0                	mov    %esi,%eax
  800e65:	f7 f1                	div    %ecx
  800e67:	89 c6                	mov    %eax,%esi
  800e69:	89 e8                	mov    %ebp,%eax
  800e6b:	89 f7                	mov    %esi,%edi
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 fa                	mov    %edi,%edx
  800e71:	83 c4 1c             	add    $0x1c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 f9                	mov    %edi,%ecx
  800e82:	ba 20 00 00 00       	mov    $0x20,%edx
  800e87:	29 fa                	sub    %edi,%edx
  800e89:	d3 e0                	shl    %cl,%eax
  800e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e8f:	89 d1                	mov    %edx,%ecx
  800e91:	89 d8                	mov    %ebx,%eax
  800e93:	d3 e8                	shr    %cl,%eax
  800e95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e99:	09 c1                	or     %eax,%ecx
  800e9b:	89 f0                	mov    %esi,%eax
  800e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e3                	shl    %cl,%ebx
  800ea5:	89 d1                	mov    %edx,%ecx
  800ea7:	d3 e8                	shr    %cl,%eax
  800ea9:	89 f9                	mov    %edi,%ecx
  800eab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eaf:	89 eb                	mov    %ebp,%ebx
  800eb1:	d3 e6                	shl    %cl,%esi
  800eb3:	89 d1                	mov    %edx,%ecx
  800eb5:	d3 eb                	shr    %cl,%ebx
  800eb7:	09 f3                	or     %esi,%ebx
  800eb9:	89 c6                	mov    %eax,%esi
  800ebb:	89 f2                	mov    %esi,%edx
  800ebd:	89 d8                	mov    %ebx,%eax
  800ebf:	f7 74 24 08          	divl   0x8(%esp)
  800ec3:	89 d6                	mov    %edx,%esi
  800ec5:	89 c3                	mov    %eax,%ebx
  800ec7:	f7 64 24 0c          	mull   0xc(%esp)
  800ecb:	39 d6                	cmp    %edx,%esi
  800ecd:	72 19                	jb     800ee8 <__udivdi3+0x108>
  800ecf:	89 f9                	mov    %edi,%ecx
  800ed1:	d3 e5                	shl    %cl,%ebp
  800ed3:	39 c5                	cmp    %eax,%ebp
  800ed5:	73 04                	jae    800edb <__udivdi3+0xfb>
  800ed7:	39 d6                	cmp    %edx,%esi
  800ed9:	74 0d                	je     800ee8 <__udivdi3+0x108>
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	31 ff                	xor    %edi,%edi
  800edf:	e9 3c ff ff ff       	jmp    800e20 <__udivdi3+0x40>
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eeb:	31 ff                	xor    %edi,%edi
  800eed:	e9 2e ff ff ff       	jmp    800e20 <__udivdi3+0x40>
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f13:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800f17:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800f1b:	89 f0                	mov    %esi,%eax
  800f1d:	89 da                	mov    %ebx,%edx
  800f1f:	85 ff                	test   %edi,%edi
  800f21:	75 15                	jne    800f38 <__umoddi3+0x38>
  800f23:	39 dd                	cmp    %ebx,%ebp
  800f25:	76 39                	jbe    800f60 <__umoddi3+0x60>
  800f27:	f7 f5                	div    %ebp
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	39 df                	cmp    %ebx,%edi
  800f3a:	77 f1                	ja     800f2d <__umoddi3+0x2d>
  800f3c:	0f bd cf             	bsr    %edi,%ecx
  800f3f:	83 f1 1f             	xor    $0x1f,%ecx
  800f42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f46:	75 40                	jne    800f88 <__umoddi3+0x88>
  800f48:	39 df                	cmp    %ebx,%edi
  800f4a:	72 04                	jb     800f50 <__umoddi3+0x50>
  800f4c:	39 f5                	cmp    %esi,%ebp
  800f4e:	77 dd                	ja     800f2d <__umoddi3+0x2d>
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	89 f0                	mov    %esi,%eax
  800f54:	29 e8                	sub    %ebp,%eax
  800f56:	19 fa                	sbb    %edi,%edx
  800f58:	eb d3                	jmp    800f2d <__umoddi3+0x2d>
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	89 e9                	mov    %ebp,%ecx
  800f62:	85 ed                	test   %ebp,%ebp
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x71>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f5                	div    %ebp
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f1                	div    %ecx
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	f7 f1                	div    %ecx
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	eb ac                	jmp    800f2d <__umoddi3+0x2d>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f8c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f91:	29 c2                	sub    %eax,%edx
  800f93:	89 c1                	mov    %eax,%ecx
  800f95:	89 e8                	mov    %ebp,%eax
  800f97:	d3 e7                	shl    %cl,%edi
  800f99:	89 d1                	mov    %edx,%ecx
  800f9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f9f:	d3 e8                	shr    %cl,%eax
  800fa1:	89 c1                	mov    %eax,%ecx
  800fa3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fa7:	09 f9                	or     %edi,%ecx
  800fa9:	89 df                	mov    %ebx,%edi
  800fab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	d3 e5                	shl    %cl,%ebp
  800fb3:	89 d1                	mov    %edx,%ecx
  800fb5:	d3 ef                	shr    %cl,%edi
  800fb7:	89 c1                	mov    %eax,%ecx
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	d3 e3                	shl    %cl,%ebx
  800fbd:	89 d1                	mov    %edx,%ecx
  800fbf:	89 fa                	mov    %edi,%edx
  800fc1:	d3 e8                	shr    %cl,%eax
  800fc3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fc8:	09 d8                	or     %ebx,%eax
  800fca:	f7 74 24 08          	divl   0x8(%esp)
  800fce:	89 d3                	mov    %edx,%ebx
  800fd0:	d3 e6                	shl    %cl,%esi
  800fd2:	f7 e5                	mul    %ebp
  800fd4:	89 c7                	mov    %eax,%edi
  800fd6:	89 d1                	mov    %edx,%ecx
  800fd8:	39 d3                	cmp    %edx,%ebx
  800fda:	72 06                	jb     800fe2 <__umoddi3+0xe2>
  800fdc:	75 0e                	jne    800fec <__umoddi3+0xec>
  800fde:	39 c6                	cmp    %eax,%esi
  800fe0:	73 0a                	jae    800fec <__umoddi3+0xec>
  800fe2:	29 e8                	sub    %ebp,%eax
  800fe4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fe8:	89 d1                	mov    %edx,%ecx
  800fea:	89 c7                	mov    %eax,%edi
  800fec:	89 f5                	mov    %esi,%ebp
  800fee:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ff2:	29 fd                	sub    %edi,%ebp
  800ff4:	19 cb                	sbb    %ecx,%ebx
  800ff6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ffb:	89 d8                	mov    %ebx,%eax
  800ffd:	d3 e0                	shl    %cl,%eax
  800fff:	89 f1                	mov    %esi,%ecx
  801001:	d3 ed                	shr    %cl,%ebp
  801003:	d3 eb                	shr    %cl,%ebx
  801005:	09 e8                	or     %ebp,%eax
  801007:	89 da                	mov    %ebx,%edx
  801009:	83 c4 1c             	add    $0x1c,%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    
