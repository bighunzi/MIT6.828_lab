
obj/user/yield：     文件格式 elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 0f 80 00       	push   $0x800fa0
  800048:	e8 3a 01 00 00       	call   800187 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 e4 0a 00 00       	call   800b3e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 0f 80 00       	push   $0x800fc0
  80006c:	e8 16 01 00 00       	call   800187 <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ec 0f 80 00       	push   $0x800fec
  80008d:	e8 f5 00 00 00       	call   800187 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 75 0a 00 00       	call   800b1f <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 f1 09 00 00       	call   800ade <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	74 09                	je     80011a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	68 ff 00 00 00       	push   $0xff
  800122:	8d 43 08             	lea    0x8(%ebx),%eax
  800125:	50                   	push   %eax
  800126:	e8 76 09 00 00       	call   800aa1 <sys_cputs>
		b->idx = 0;
  80012b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	eb db                	jmp    800111 <putch+0x1f>

00800136 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800146:	00 00 00 
	b.cnt = 0;
  800149:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800150:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800153:	ff 75 0c             	push   0xc(%ebp)
  800156:	ff 75 08             	push   0x8(%ebp)
  800159:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	68 f2 00 80 00       	push   $0x8000f2
  800165:	e8 14 01 00 00       	call   80027e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016a:	83 c4 08             	add    $0x8,%esp
  80016d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800173:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	e8 22 09 00 00       	call   800aa1 <sys_cputs>

	return b.cnt;
}
  80017f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800190:	50                   	push   %eax
  800191:	ff 75 08             	push   0x8(%ebp)
  800194:	e8 9d ff ff ff       	call   800136 <vcprintf>
	va_end(ap);

	return cnt;
}
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	57                   	push   %edi
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 1c             	sub    $0x1c,%esp
  8001a4:	89 c7                	mov    %eax,%edi
  8001a6:	89 d6                	mov    %edx,%esi
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ae:	89 d1                	mov    %edx,%ecx
  8001b0:	89 c2                	mov    %eax,%edx
  8001b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001c8:	39 c2                	cmp    %eax,%edx
  8001ca:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001cd:	72 3e                	jb     80020d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cf:	83 ec 0c             	sub    $0xc,%esp
  8001d2:	ff 75 18             	push   0x18(%ebp)
  8001d5:	83 eb 01             	sub    $0x1,%ebx
  8001d8:	53                   	push   %ebx
  8001d9:	50                   	push   %eax
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	ff 75 e4             	push   -0x1c(%ebp)
  8001e0:	ff 75 e0             	push   -0x20(%ebp)
  8001e3:	ff 75 dc             	push   -0x24(%ebp)
  8001e6:	ff 75 d8             	push   -0x28(%ebp)
  8001e9:	e8 72 0b 00 00       	call   800d60 <__udivdi3>
  8001ee:	83 c4 18             	add    $0x18,%esp
  8001f1:	52                   	push   %edx
  8001f2:	50                   	push   %eax
  8001f3:	89 f2                	mov    %esi,%edx
  8001f5:	89 f8                	mov    %edi,%eax
  8001f7:	e8 9f ff ff ff       	call   80019b <printnum>
  8001fc:	83 c4 20             	add    $0x20,%esp
  8001ff:	eb 13                	jmp    800214 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	ff 75 18             	push   0x18(%ebp)
  800208:	ff d7                	call   *%edi
  80020a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80020d:	83 eb 01             	sub    $0x1,%ebx
  800210:	85 db                	test   %ebx,%ebx
  800212:	7f ed                	jg     800201 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	56                   	push   %esi
  800218:	83 ec 04             	sub    $0x4,%esp
  80021b:	ff 75 e4             	push   -0x1c(%ebp)
  80021e:	ff 75 e0             	push   -0x20(%ebp)
  800221:	ff 75 dc             	push   -0x24(%ebp)
  800224:	ff 75 d8             	push   -0x28(%ebp)
  800227:	e8 54 0c 00 00       	call   800e80 <__umoddi3>
  80022c:	83 c4 14             	add    $0x14,%esp
  80022f:	0f be 80 15 10 80 00 	movsbl 0x801015(%eax),%eax
  800236:	50                   	push   %eax
  800237:	ff d7                	call   *%edi
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	3b 50 04             	cmp    0x4(%eax),%edx
  800253:	73 0a                	jae    80025f <sprintputch+0x1b>
		*b->buf++ = ch;
  800255:	8d 4a 01             	lea    0x1(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	88 02                	mov    %al,(%edx)
}
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <printfmt>:
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800267:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026a:	50                   	push   %eax
  80026b:	ff 75 10             	push   0x10(%ebp)
  80026e:	ff 75 0c             	push   0xc(%ebp)
  800271:	ff 75 08             	push   0x8(%ebp)
  800274:	e8 05 00 00 00       	call   80027e <vprintfmt>
}
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <vprintfmt>:
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	57                   	push   %edi
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
  800284:	83 ec 3c             	sub    $0x3c,%esp
  800287:	8b 75 08             	mov    0x8(%ebp),%esi
  80028a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800290:	eb 0a                	jmp    80029c <vprintfmt+0x1e>
			putch(ch, putdat);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	53                   	push   %ebx
  800296:	50                   	push   %eax
  800297:	ff d6                	call   *%esi
  800299:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029c:	83 c7 01             	add    $0x1,%edi
  80029f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a3:	83 f8 25             	cmp    $0x25,%eax
  8002a6:	74 0c                	je     8002b4 <vprintfmt+0x36>
			if (ch == '\0')
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	75 e6                	jne    800292 <vprintfmt+0x14>
}
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    
		padc = ' ';
  8002b4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002b8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002bf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002cd:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002d2:	8d 47 01             	lea    0x1(%edi),%eax
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	0f b6 17             	movzbl (%edi),%edx
  8002db:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002de:	3c 55                	cmp    $0x55,%al
  8002e0:	0f 87 bb 03 00 00    	ja     8006a1 <vprintfmt+0x423>
  8002e6:	0f b6 c0             	movzbl %al,%eax
  8002e9:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8002f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002f3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002f7:	eb d9                	jmp    8002d2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fc:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800300:	eb d0                	jmp    8002d2 <vprintfmt+0x54>
  800302:	0f b6 d2             	movzbl %dl,%edx
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800308:	b8 00 00 00 00       	mov    $0x0,%eax
  80030d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800310:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800313:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800317:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80031a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80031d:	83 f9 09             	cmp    $0x9,%ecx
  800320:	77 55                	ja     800377 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800322:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800325:	eb e9                	jmp    800310 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8b 00                	mov    (%eax),%eax
  80032c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8d 40 04             	lea    0x4(%eax),%eax
  800335:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80033b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80033f:	79 91                	jns    8002d2 <vprintfmt+0x54>
				width = precision, precision = -1;
  800341:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800344:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800347:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80034e:	eb 82                	jmp    8002d2 <vprintfmt+0x54>
  800350:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800353:	85 d2                	test   %edx,%edx
  800355:	b8 00 00 00 00       	mov    $0x0,%eax
  80035a:	0f 49 c2             	cmovns %edx,%eax
  80035d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800363:	e9 6a ff ff ff       	jmp    8002d2 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80036b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800372:	e9 5b ff ff ff       	jmp    8002d2 <vprintfmt+0x54>
  800377:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80037a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037d:	eb bc                	jmp    80033b <vprintfmt+0xbd>
			lflag++;
  80037f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800385:	e9 48 ff ff ff       	jmp    8002d2 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80038a:	8b 45 14             	mov    0x14(%ebp),%eax
  80038d:	8d 78 04             	lea    0x4(%eax),%edi
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	53                   	push   %ebx
  800394:	ff 30                	push   (%eax)
  800396:	ff d6                	call   *%esi
			break;
  800398:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80039b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80039e:	e9 9d 02 00 00       	jmp    800640 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8d 78 04             	lea    0x4(%eax),%edi
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	89 d0                	mov    %edx,%eax
  8003ad:	f7 d8                	neg    %eax
  8003af:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 08             	cmp    $0x8,%eax
  8003b5:	7f 23                	jg     8003da <vprintfmt+0x15c>
  8003b7:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	74 18                	je     8003da <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003c2:	52                   	push   %edx
  8003c3:	68 36 10 80 00       	push   $0x801036
  8003c8:	53                   	push   %ebx
  8003c9:	56                   	push   %esi
  8003ca:	e8 92 fe ff ff       	call   800261 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d5:	e9 66 02 00 00       	jmp    800640 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003da:	50                   	push   %eax
  8003db:	68 2d 10 80 00       	push   $0x80102d
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	e8 7a fe ff ff       	call   800261 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ea:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ed:	e9 4e 02 00 00       	jmp    800640 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	83 c0 04             	add    $0x4,%eax
  8003f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800400:	85 d2                	test   %edx,%edx
  800402:	b8 26 10 80 00       	mov    $0x801026,%eax
  800407:	0f 45 c2             	cmovne %edx,%eax
  80040a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80040d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800411:	7e 06                	jle    800419 <vprintfmt+0x19b>
  800413:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800417:	75 0d                	jne    800426 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80041c:	89 c7                	mov    %eax,%edi
  80041e:	03 45 e0             	add    -0x20(%ebp),%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800424:	eb 55                	jmp    80047b <vprintfmt+0x1fd>
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	ff 75 d8             	push   -0x28(%ebp)
  80042c:	ff 75 cc             	push   -0x34(%ebp)
  80042f:	e8 0a 03 00 00       	call   80073e <strnlen>
  800434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800437:	29 c1                	sub    %eax,%ecx
  800439:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800441:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	eb 0f                	jmp    800459 <vprintfmt+0x1db>
					putch(padc, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 e0             	push   -0x20(%ebp)
  800451:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ef 01             	sub    $0x1,%edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f ed                	jg     80044a <vprintfmt+0x1cc>
  80045d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	0f 49 c2             	cmovns %edx,%eax
  80046a:	29 c2                	sub    %eax,%edx
  80046c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80046f:	eb a8                	jmp    800419 <vprintfmt+0x19b>
					putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	52                   	push   %edx
  800476:	ff d6                	call   *%esi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800480:	83 c7 01             	add    $0x1,%edi
  800483:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800487:	0f be d0             	movsbl %al,%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	74 4b                	je     8004d9 <vprintfmt+0x25b>
  80048e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800492:	78 06                	js     80049a <vprintfmt+0x21c>
  800494:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800498:	78 1e                	js     8004b8 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80049a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049e:	74 d1                	je     800471 <vprintfmt+0x1f3>
  8004a0:	0f be c0             	movsbl %al,%eax
  8004a3:	83 e8 20             	sub    $0x20,%eax
  8004a6:	83 f8 5e             	cmp    $0x5e,%eax
  8004a9:	76 c6                	jbe    800471 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	6a 3f                	push   $0x3f
  8004b1:	ff d6                	call   *%esi
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	eb c3                	jmp    80047b <vprintfmt+0x1fd>
  8004b8:	89 cf                	mov    %ecx,%edi
  8004ba:	eb 0e                	jmp    8004ca <vprintfmt+0x24c>
				putch(' ', putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	6a 20                	push   $0x20
  8004c2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004c4:	83 ef 01             	sub    $0x1,%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 ff                	test   %edi,%edi
  8004cc:	7f ee                	jg     8004bc <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ce:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d4:	e9 67 01 00 00       	jmp    800640 <vprintfmt+0x3c2>
  8004d9:	89 cf                	mov    %ecx,%edi
  8004db:	eb ed                	jmp    8004ca <vprintfmt+0x24c>
	if (lflag >= 2)
  8004dd:	83 f9 01             	cmp    $0x1,%ecx
  8004e0:	7f 1b                	jg     8004fd <vprintfmt+0x27f>
	else if (lflag)
  8004e2:	85 c9                	test   %ecx,%ecx
  8004e4:	74 63                	je     800549 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ee:	99                   	cltd   
  8004ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 40 04             	lea    0x4(%eax),%eax
  8004f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fb:	eb 17                	jmp    800514 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8b 50 04             	mov    0x4(%eax),%edx
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800508:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 40 08             	lea    0x8(%eax),%eax
  800511:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800514:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800517:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80051a:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80051f:	85 c9                	test   %ecx,%ecx
  800521:	0f 89 ff 00 00 00    	jns    800626 <vprintfmt+0x3a8>
				putch('-', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	53                   	push   %ebx
  80052b:	6a 2d                	push   $0x2d
  80052d:	ff d6                	call   *%esi
				num = -(long long) num;
  80052f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800532:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800535:	f7 da                	neg    %edx
  800537:	83 d1 00             	adc    $0x0,%ecx
  80053a:	f7 d9                	neg    %ecx
  80053c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80053f:	bf 0a 00 00 00       	mov    $0xa,%edi
  800544:	e9 dd 00 00 00       	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	99                   	cltd   
  800552:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	eb b4                	jmp    800514 <vprintfmt+0x296>
	if (lflag >= 2)
  800560:	83 f9 01             	cmp    $0x1,%ecx
  800563:	7f 1e                	jg     800583 <vprintfmt+0x305>
	else if (lflag)
  800565:	85 c9                	test   %ecx,%ecx
  800567:	74 32                	je     80059b <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800579:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80057e:	e9 a3 00 00 00       	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 10                	mov    (%eax),%edx
  800588:	8b 48 04             	mov    0x4(%eax),%ecx
  80058b:	8d 40 08             	lea    0x8(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800591:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800596:	e9 8b 00 00 00       	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ab:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005b0:	eb 74                	jmp    800626 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005b2:	83 f9 01             	cmp    $0x1,%ecx
  8005b5:	7f 1b                	jg     8005d2 <vprintfmt+0x354>
	else if (lflag)
  8005b7:	85 c9                	test   %ecx,%ecx
  8005b9:	74 2c                	je     8005e7 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005cb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005d0:	eb 54                	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005da:	8d 40 08             	lea    0x8(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005e5:	eb 3f                	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f1:	8d 40 04             	lea    0x4(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005f7:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005fc:	eb 28                	jmp    800626 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 10                	mov    (%eax),%edx
  800613:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800618:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80061b:	8d 40 04             	lea    0x4(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800621:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80062d:	50                   	push   %eax
  80062e:	ff 75 e0             	push   -0x20(%ebp)
  800631:	57                   	push   %edi
  800632:	51                   	push   %ecx
  800633:	52                   	push   %edx
  800634:	89 da                	mov    %ebx,%edx
  800636:	89 f0                	mov    %esi,%eax
  800638:	e8 5e fb ff ff       	call   80019b <printnum>
			break;
  80063d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800643:	e9 54 fc ff ff       	jmp    80029c <vprintfmt+0x1e>
	if (lflag >= 2)
  800648:	83 f9 01             	cmp    $0x1,%ecx
  80064b:	7f 1b                	jg     800668 <vprintfmt+0x3ea>
	else if (lflag)
  80064d:	85 c9                	test   %ecx,%ecx
  80064f:	74 2c                	je     80067d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800661:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800666:	eb be                	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	8b 48 04             	mov    0x4(%eax),%ecx
  800670:	8d 40 08             	lea    0x8(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800676:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80067b:	eb a9                	jmp    800626 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	b9 00 00 00 00       	mov    $0x0,%ecx
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800692:	eb 92                	jmp    800626 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 25                	push   $0x25
  80069a:	ff d6                	call   *%esi
			break;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb 9f                	jmp    800640 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 25                	push   $0x25
  8006a7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	89 f8                	mov    %edi,%eax
  8006ae:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b2:	74 05                	je     8006b9 <vprintfmt+0x43b>
  8006b4:	83 e8 01             	sub    $0x1,%eax
  8006b7:	eb f5                	jmp    8006ae <vprintfmt+0x430>
  8006b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006bc:	eb 82                	jmp    800640 <vprintfmt+0x3c2>

008006be <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 18             	sub    $0x18,%esp
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	74 26                	je     800705 <vsnprintf+0x47>
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	7e 22                	jle    800705 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e3:	ff 75 14             	push   0x14(%ebp)
  8006e6:	ff 75 10             	push   0x10(%ebp)
  8006e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ec:	50                   	push   %eax
  8006ed:	68 44 02 80 00       	push   $0x800244
  8006f2:	e8 87 fb ff ff       	call   80027e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800700:	83 c4 10             	add    $0x10,%esp
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    
		return -E_INVAL;
  800705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070a:	eb f7                	jmp    800703 <vsnprintf+0x45>

0080070c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800712:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800715:	50                   	push   %eax
  800716:	ff 75 10             	push   0x10(%ebp)
  800719:	ff 75 0c             	push   0xc(%ebp)
  80071c:	ff 75 08             	push   0x8(%ebp)
  80071f:	e8 9a ff ff ff       	call   8006be <vsnprintf>
	va_end(ap);

	return rc;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072c:	b8 00 00 00 00       	mov    $0x0,%eax
  800731:	eb 03                	jmp    800736 <strlen+0x10>
		n++;
  800733:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f7                	jne    800733 <strlen+0xd>
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 03                	jmp    800751 <strnlen+0x13>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800751:	39 d0                	cmp    %edx,%eax
  800753:	74 08                	je     80075d <strnlen+0x1f>
  800755:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800759:	75 f3                	jne    80074e <strnlen+0x10>
  80075b:	89 c2                	mov    %eax,%edx
	return n;
}
  80075d:	89 d0                	mov    %edx,%eax
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	53                   	push   %ebx
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800774:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800777:	83 c0 01             	add    $0x1,%eax
  80077a:	84 d2                	test   %dl,%dl
  80077c:	75 f2                	jne    800770 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077e:	89 c8                	mov    %ecx,%eax
  800780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	53                   	push   %ebx
  800789:	83 ec 10             	sub    $0x10,%esp
  80078c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078f:	53                   	push   %ebx
  800790:	e8 91 ff ff ff       	call   800726 <strlen>
  800795:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800798:	ff 75 0c             	push   0xc(%ebp)
  80079b:	01 d8                	add    %ebx,%eax
  80079d:	50                   	push   %eax
  80079e:	e8 be ff ff ff       	call   800761 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	56                   	push   %esi
  8007ae:	53                   	push   %ebx
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 f3                	mov    %esi,%ebx
  8007b7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	eb 0f                	jmp    8007cd <strncpy+0x23>
		*dst++ = *src;
  8007be:	83 c0 01             	add    $0x1,%eax
  8007c1:	0f b6 0a             	movzbl (%edx),%ecx
  8007c4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c7:	80 f9 01             	cmp    $0x1,%cl
  8007ca:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007cd:	39 d8                	cmp    %ebx,%eax
  8007cf:	75 ed                	jne    8007be <strncpy+0x14>
	}
	return ret;
}
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	74 21                	je     80080c <strlcpy+0x35>
  8007eb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ef:	89 f2                	mov    %esi,%edx
  8007f1:	eb 09                	jmp    8007fc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f3:	83 c1 01             	add    $0x1,%ecx
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007fc:	39 c2                	cmp    %eax,%edx
  8007fe:	74 09                	je     800809 <strlcpy+0x32>
  800800:	0f b6 19             	movzbl (%ecx),%ebx
  800803:	84 db                	test   %bl,%bl
  800805:	75 ec                	jne    8007f3 <strlcpy+0x1c>
  800807:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800809:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 06                	jmp    800823 <strcmp+0x11>
		p++, q++;
  80081d:	83 c1 01             	add    $0x1,%ecx
  800820:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800823:	0f b6 01             	movzbl (%ecx),%eax
  800826:	84 c0                	test   %al,%al
  800828:	74 04                	je     80082e <strcmp+0x1c>
  80082a:	3a 02                	cmp    (%edx),%al
  80082c:	74 ef                	je     80081d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 c0             	movzbl %al,%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	89 c3                	mov    %eax,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800847:	eb 06                	jmp    80084f <strncmp+0x17>
		n--, p++, q++;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80084f:	39 d8                	cmp    %ebx,%eax
  800851:	74 18                	je     80086b <strncmp+0x33>
  800853:	0f b6 08             	movzbl (%eax),%ecx
  800856:	84 c9                	test   %cl,%cl
  800858:	74 04                	je     80085e <strncmp+0x26>
  80085a:	3a 0a                	cmp    (%edx),%cl
  80085c:	74 eb                	je     800849 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 00             	movzbl (%eax),%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800869:	c9                   	leave  
  80086a:	c3                   	ret    
		return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
  800870:	eb f4                	jmp    800866 <strncmp+0x2e>

00800872 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087c:	eb 03                	jmp    800881 <strchr+0xf>
  80087e:	83 c0 01             	add    $0x1,%eax
  800881:	0f b6 10             	movzbl (%eax),%edx
  800884:	84 d2                	test   %dl,%dl
  800886:	74 06                	je     80088e <strchr+0x1c>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	75 f2                	jne    80087e <strchr+0xc>
  80088c:	eb 05                	jmp    800893 <strchr+0x21>
			return (char *) s;
	return 0;
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a2:	38 ca                	cmp    %cl,%dl
  8008a4:	74 09                	je     8008af <strfind+0x1a>
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	74 05                	je     8008af <strfind+0x1a>
	for (; *s; s++)
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	eb f0                	jmp    80089f <strfind+0xa>
			break;
	return (char *) s;
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bd:	85 c9                	test   %ecx,%ecx
  8008bf:	74 2f                	je     8008f0 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	09 c8                	or     %ecx,%eax
  8008c5:	a8 03                	test   $0x3,%al
  8008c7:	75 21                	jne    8008ea <memset+0x39>
		c &= 0xFF;
  8008c9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cd:	89 d0                	mov    %edx,%eax
  8008cf:	c1 e0 08             	shl    $0x8,%eax
  8008d2:	89 d3                	mov    %edx,%ebx
  8008d4:	c1 e3 18             	shl    $0x18,%ebx
  8008d7:	89 d6                	mov    %edx,%esi
  8008d9:	c1 e6 10             	shl    $0x10,%esi
  8008dc:	09 f3                	or     %esi,%ebx
  8008de:	09 da                	or     %ebx,%edx
  8008e0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008e5:	fc                   	cld    
  8008e6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e8:	eb 06                	jmp    8008f0 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	fc                   	cld    
  8008ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5f                   	pop    %edi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800905:	39 c6                	cmp    %eax,%esi
  800907:	73 32                	jae    80093b <memmove+0x44>
  800909:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090c:	39 c2                	cmp    %eax,%edx
  80090e:	76 2b                	jbe    80093b <memmove+0x44>
		s += n;
		d += n;
  800910:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800913:	89 d6                	mov    %edx,%esi
  800915:	09 fe                	or     %edi,%esi
  800917:	09 ce                	or     %ecx,%esi
  800919:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091f:	75 0e                	jne    80092f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800921:	83 ef 04             	sub    $0x4,%edi
  800924:	8d 72 fc             	lea    -0x4(%edx),%esi
  800927:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80092a:	fd                   	std    
  80092b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092d:	eb 09                	jmp    800938 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092f:	83 ef 01             	sub    $0x1,%edi
  800932:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800935:	fd                   	std    
  800936:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800938:	fc                   	cld    
  800939:	eb 1a                	jmp    800955 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093b:	89 f2                	mov    %esi,%edx
  80093d:	09 c2                	or     %eax,%edx
  80093f:	09 ca                	or     %ecx,%edx
  800941:	f6 c2 03             	test   $0x3,%dl
  800944:	75 0a                	jne    800950 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800946:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 05                	jmp    800955 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800950:	89 c7                	mov    %eax,%edi
  800952:	fc                   	cld    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80095f:	ff 75 10             	push   0x10(%ebp)
  800962:	ff 75 0c             	push   0xc(%ebp)
  800965:	ff 75 08             	push   0x8(%ebp)
  800968:	e8 8a ff ff ff       	call   8008f7 <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	89 c6                	mov    %eax,%esi
  80097c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097f:	eb 06                	jmp    800987 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800987:	39 f0                	cmp    %esi,%eax
  800989:	74 14                	je     80099f <memcmp+0x30>
		if (*s1 != *s2)
  80098b:	0f b6 08             	movzbl (%eax),%ecx
  80098e:	0f b6 1a             	movzbl (%edx),%ebx
  800991:	38 d9                	cmp    %bl,%cl
  800993:	74 ec                	je     800981 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800995:	0f b6 c1             	movzbl %cl,%eax
  800998:	0f b6 db             	movzbl %bl,%ebx
  80099b:	29 d8                	sub    %ebx,%eax
  80099d:	eb 05                	jmp    8009a4 <memcmp+0x35>
	}

	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b1:	89 c2                	mov    %eax,%edx
  8009b3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b6:	eb 03                	jmp    8009bb <memfind+0x13>
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	39 d0                	cmp    %edx,%eax
  8009bd:	73 04                	jae    8009c3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bf:	38 08                	cmp    %cl,(%eax)
  8009c1:	75 f5                	jne    8009b8 <memfind+0x10>
			break;
	return (void *) s;
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	eb 03                	jmp    8009d6 <strtol+0x11>
		s++;
  8009d3:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009d6:	0f b6 02             	movzbl (%edx),%eax
  8009d9:	3c 20                	cmp    $0x20,%al
  8009db:	74 f6                	je     8009d3 <strtol+0xe>
  8009dd:	3c 09                	cmp    $0x9,%al
  8009df:	74 f2                	je     8009d3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009e1:	3c 2b                	cmp    $0x2b,%al
  8009e3:	74 2a                	je     800a0f <strtol+0x4a>
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ea:	3c 2d                	cmp    $0x2d,%al
  8009ec:	74 2b                	je     800a19 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f4:	75 0f                	jne    800a05 <strtol+0x40>
  8009f6:	80 3a 30             	cmpb   $0x30,(%edx)
  8009f9:	74 28                	je     800a23 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	85 db                	test   %ebx,%ebx
  8009fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a02:	0f 44 d8             	cmove  %eax,%ebx
  800a05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a0d:	eb 46                	jmp    800a55 <strtol+0x90>
		s++;
  800a0f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
  800a17:	eb d5                	jmp    8009ee <strtol+0x29>
		s++, neg = 1;
  800a19:	83 c2 01             	add    $0x1,%edx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a21:	eb cb                	jmp    8009ee <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a27:	74 0e                	je     800a37 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	75 d8                	jne    800a05 <strtol+0x40>
		s++, base = 8;
  800a2d:	83 c2 01             	add    $0x1,%edx
  800a30:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a35:	eb ce                	jmp    800a05 <strtol+0x40>
		s += 2, base = 16;
  800a37:	83 c2 02             	add    $0x2,%edx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb c4                	jmp    800a05 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a41:	0f be c0             	movsbl %al,%eax
  800a44:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a47:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a4a:	7d 3a                	jge    800a86 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a4c:	83 c2 01             	add    $0x1,%edx
  800a4f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a53:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a55:	0f b6 02             	movzbl (%edx),%eax
  800a58:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 09             	cmp    $0x9,%bl
  800a60:	76 df                	jbe    800a41 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a62:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a6c:	0f be c0             	movsbl %al,%eax
  800a6f:	83 e8 57             	sub    $0x57,%eax
  800a72:	eb d3                	jmp    800a47 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a74:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a7e:	0f be c0             	movsbl %al,%eax
  800a81:	83 e8 37             	sub    $0x37,%eax
  800a84:	eb c1                	jmp    800a47 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8a:	74 05                	je     800a91 <strtol+0xcc>
		*endptr = (char *) s;
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a91:	89 c8                	mov    %ecx,%eax
  800a93:	f7 d8                	neg    %eax
  800a95:	85 ff                	test   %edi,%edi
  800a97:	0f 45 c8             	cmovne %eax,%ecx
}
  800a9a:	89 c8                	mov    %ecx,%eax
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab2:	89 c3                	mov    %eax,%ebx
  800ab4:	89 c7                	mov    %eax,%edi
  800ab6:	89 c6                	mov    %eax,%esi
  800ab8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_cgetc>:

int
sys_cgetc(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	89 d1                	mov    %edx,%ecx
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	89 d7                	mov    %edx,%edi
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ae7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	b8 03 00 00 00       	mov    $0x3,%eax
  800af4:	89 cb                	mov    %ecx,%ebx
  800af6:	89 cf                	mov    %ecx,%edi
  800af8:	89 ce                	mov    %ecx,%esi
  800afa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800afc:	85 c0                	test   %eax,%eax
  800afe:	7f 08                	jg     800b08 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b08:	83 ec 0c             	sub    $0xc,%esp
  800b0b:	50                   	push   %eax
  800b0c:	6a 03                	push   $0x3
  800b0e:	68 64 12 80 00       	push   $0x801264
  800b13:	6a 2a                	push   $0x2a
  800b15:	68 81 12 80 00       	push   $0x801281
  800b1a:	e8 ed 01 00 00       	call   800d0c <_panic>

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	b8 04 00 00 00       	mov    $0x4,%eax
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7f 08                	jg     800b89 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	50                   	push   %eax
  800b8d:	6a 04                	push   $0x4
  800b8f:	68 64 12 80 00       	push   $0x801264
  800b94:	6a 2a                	push   $0x2a
  800b96:	68 81 12 80 00       	push   $0x801281
  800b9b:	e8 6c 01 00 00       	call   800d0c <_panic>

00800ba0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bba:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7f 08                	jg     800bcb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 05                	push   $0x5
  800bd1:	68 64 12 80 00       	push   $0x801264
  800bd6:	6a 2a                	push   $0x2a
  800bd8:	68 81 12 80 00       	push   $0x801281
  800bdd:	e8 2a 01 00 00       	call   800d0c <_panic>

00800be2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7f 08                	jg     800c0d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 06                	push   $0x6
  800c13:	68 64 12 80 00       	push   $0x801264
  800c18:	6a 2a                	push   $0x2a
  800c1a:	68 81 12 80 00       	push   $0x801281
  800c1f:	e8 e8 00 00 00       	call   800d0c <_panic>

00800c24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7f 08                	jg     800c4f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 08                	push   $0x8
  800c55:	68 64 12 80 00       	push   $0x801264
  800c5a:	6a 2a                	push   $0x2a
  800c5c:	68 81 12 80 00       	push   $0x801281
  800c61:	e8 a6 00 00 00       	call   800d0c <_panic>

00800c66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7f 08                	jg     800c91 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 09                	push   $0x9
  800c97:	68 64 12 80 00       	push   $0x801264
  800c9c:	6a 2a                	push   $0x2a
  800c9e:	68 81 12 80 00       	push   $0x801281
  800ca3:	e8 64 00 00 00       	call   800d0c <_panic>

00800ca8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb9:	be 00 00 00 00       	mov    $0x0,%esi
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce1:	89 cb                	mov    %ecx,%ebx
  800ce3:	89 cf                	mov    %ecx,%edi
  800ce5:	89 ce                	mov    %ecx,%esi
  800ce7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7f 08                	jg     800cf5 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 0c                	push   $0xc
  800cfb:	68 64 12 80 00       	push   $0x801264
  800d00:	6a 2a                	push   $0x2a
  800d02:	68 81 12 80 00       	push   $0x801281
  800d07:	e8 00 00 00 00       	call   800d0c <_panic>

00800d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d11:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d14:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d1a:	e8 00 fe ff ff       	call   800b1f <sys_getenvid>
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	ff 75 0c             	push   0xc(%ebp)
  800d25:	ff 75 08             	push   0x8(%ebp)
  800d28:	56                   	push   %esi
  800d29:	50                   	push   %eax
  800d2a:	68 90 12 80 00       	push   $0x801290
  800d2f:	e8 53 f4 ff ff       	call   800187 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d34:	83 c4 18             	add    $0x18,%esp
  800d37:	53                   	push   %ebx
  800d38:	ff 75 10             	push   0x10(%ebp)
  800d3b:	e8 f6 f3 ff ff       	call   800136 <vcprintf>
	cprintf("\n");
  800d40:	c7 04 24 b3 12 80 00 	movl   $0x8012b3,(%esp)
  800d47:	e8 3b f4 ff ff       	call   800187 <cprintf>
  800d4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d4f:	cc                   	int3   
  800d50:	eb fd                	jmp    800d4f <_panic+0x43>
  800d52:	66 90                	xchg   %ax,%ax
  800d54:	66 90                	xchg   %ax,%ax
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__udivdi3>:
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 1c             	sub    $0x1c,%esp
  800d6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d73:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	75 19                	jne    800d98 <__udivdi3+0x38>
  800d7f:	39 f3                	cmp    %esi,%ebx
  800d81:	76 4d                	jbe    800dd0 <__udivdi3+0x70>
  800d83:	31 ff                	xor    %edi,%edi
  800d85:	89 e8                	mov    %ebp,%eax
  800d87:	89 f2                	mov    %esi,%edx
  800d89:	f7 f3                	div    %ebx
  800d8b:	89 fa                	mov    %edi,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 f0                	cmp    %esi,%eax
  800d9a:	76 14                	jbe    800db0 <__udivdi3+0x50>
  800d9c:	31 ff                	xor    %edi,%edi
  800d9e:	31 c0                	xor    %eax,%eax
  800da0:	89 fa                	mov    %edi,%edx
  800da2:	83 c4 1c             	add    $0x1c,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
  800daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db0:	0f bd f8             	bsr    %eax,%edi
  800db3:	83 f7 1f             	xor    $0x1f,%edi
  800db6:	75 48                	jne    800e00 <__udivdi3+0xa0>
  800db8:	39 f0                	cmp    %esi,%eax
  800dba:	72 06                	jb     800dc2 <__udivdi3+0x62>
  800dbc:	31 c0                	xor    %eax,%eax
  800dbe:	39 eb                	cmp    %ebp,%ebx
  800dc0:	77 de                	ja     800da0 <__udivdi3+0x40>
  800dc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc7:	eb d7                	jmp    800da0 <__udivdi3+0x40>
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 d9                	mov    %ebx,%ecx
  800dd2:	85 db                	test   %ebx,%ebx
  800dd4:	75 0b                	jne    800de1 <__udivdi3+0x81>
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	f7 f3                	div    %ebx
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	31 d2                	xor    %edx,%edx
  800de3:	89 f0                	mov    %esi,%eax
  800de5:	f7 f1                	div    %ecx
  800de7:	89 c6                	mov    %eax,%esi
  800de9:	89 e8                	mov    %ebp,%eax
  800deb:	89 f7                	mov    %esi,%edi
  800ded:	f7 f1                	div    %ecx
  800def:	89 fa                	mov    %edi,%edx
  800df1:	83 c4 1c             	add    $0x1c,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 f9                	mov    %edi,%ecx
  800e02:	ba 20 00 00 00       	mov    $0x20,%edx
  800e07:	29 fa                	sub    %edi,%edx
  800e09:	d3 e0                	shl    %cl,%eax
  800e0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0f:	89 d1                	mov    %edx,%ecx
  800e11:	89 d8                	mov    %ebx,%eax
  800e13:	d3 e8                	shr    %cl,%eax
  800e15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e19:	09 c1                	or     %eax,%ecx
  800e1b:	89 f0                	mov    %esi,%eax
  800e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e3                	shl    %cl,%ebx
  800e25:	89 d1                	mov    %edx,%ecx
  800e27:	d3 e8                	shr    %cl,%eax
  800e29:	89 f9                	mov    %edi,%ecx
  800e2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e2f:	89 eb                	mov    %ebp,%ebx
  800e31:	d3 e6                	shl    %cl,%esi
  800e33:	89 d1                	mov    %edx,%ecx
  800e35:	d3 eb                	shr    %cl,%ebx
  800e37:	09 f3                	or     %esi,%ebx
  800e39:	89 c6                	mov    %eax,%esi
  800e3b:	89 f2                	mov    %esi,%edx
  800e3d:	89 d8                	mov    %ebx,%eax
  800e3f:	f7 74 24 08          	divl   0x8(%esp)
  800e43:	89 d6                	mov    %edx,%esi
  800e45:	89 c3                	mov    %eax,%ebx
  800e47:	f7 64 24 0c          	mull   0xc(%esp)
  800e4b:	39 d6                	cmp    %edx,%esi
  800e4d:	72 19                	jb     800e68 <__udivdi3+0x108>
  800e4f:	89 f9                	mov    %edi,%ecx
  800e51:	d3 e5                	shl    %cl,%ebp
  800e53:	39 c5                	cmp    %eax,%ebp
  800e55:	73 04                	jae    800e5b <__udivdi3+0xfb>
  800e57:	39 d6                	cmp    %edx,%esi
  800e59:	74 0d                	je     800e68 <__udivdi3+0x108>
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	31 ff                	xor    %edi,%edi
  800e5f:	e9 3c ff ff ff       	jmp    800da0 <__udivdi3+0x40>
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e6b:	31 ff                	xor    %edi,%edi
  800e6d:	e9 2e ff ff ff       	jmp    800da0 <__udivdi3+0x40>
  800e72:	66 90                	xchg   %ax,%ax
  800e74:	66 90                	xchg   %ax,%ax
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__umoddi3>:
  800e80:	f3 0f 1e fb          	endbr32 
  800e84:	55                   	push   %ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 1c             	sub    $0x1c,%esp
  800e8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e93:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e97:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e9b:	89 f0                	mov    %esi,%eax
  800e9d:	89 da                	mov    %ebx,%edx
  800e9f:	85 ff                	test   %edi,%edi
  800ea1:	75 15                	jne    800eb8 <__umoddi3+0x38>
  800ea3:	39 dd                	cmp    %ebx,%ebp
  800ea5:	76 39                	jbe    800ee0 <__umoddi3+0x60>
  800ea7:	f7 f5                	div    %ebp
  800ea9:	89 d0                	mov    %edx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	83 c4 1c             	add    $0x1c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
  800eb8:	39 df                	cmp    %ebx,%edi
  800eba:	77 f1                	ja     800ead <__umoddi3+0x2d>
  800ebc:	0f bd cf             	bsr    %edi,%ecx
  800ebf:	83 f1 1f             	xor    $0x1f,%ecx
  800ec2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ec6:	75 40                	jne    800f08 <__umoddi3+0x88>
  800ec8:	39 df                	cmp    %ebx,%edi
  800eca:	72 04                	jb     800ed0 <__umoddi3+0x50>
  800ecc:	39 f5                	cmp    %esi,%ebp
  800ece:	77 dd                	ja     800ead <__umoddi3+0x2d>
  800ed0:	89 da                	mov    %ebx,%edx
  800ed2:	89 f0                	mov    %esi,%eax
  800ed4:	29 e8                	sub    %ebp,%eax
  800ed6:	19 fa                	sbb    %edi,%edx
  800ed8:	eb d3                	jmp    800ead <__umoddi3+0x2d>
  800eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee0:	89 e9                	mov    %ebp,%ecx
  800ee2:	85 ed                	test   %ebp,%ebp
  800ee4:	75 0b                	jne    800ef1 <__umoddi3+0x71>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f5                	div    %ebp
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	89 d8                	mov    %ebx,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	f7 f1                	div    %ecx
  800ef7:	89 f0                	mov    %esi,%eax
  800ef9:	f7 f1                	div    %ecx
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	31 d2                	xor    %edx,%edx
  800eff:	eb ac                	jmp    800ead <__umoddi3+0x2d>
  800f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f08:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f0c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f11:	29 c2                	sub    %eax,%edx
  800f13:	89 c1                	mov    %eax,%ecx
  800f15:	89 e8                	mov    %ebp,%eax
  800f17:	d3 e7                	shl    %cl,%edi
  800f19:	89 d1                	mov    %edx,%ecx
  800f1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f1f:	d3 e8                	shr    %cl,%eax
  800f21:	89 c1                	mov    %eax,%ecx
  800f23:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f27:	09 f9                	or     %edi,%ecx
  800f29:	89 df                	mov    %ebx,%edi
  800f2b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	d3 e5                	shl    %cl,%ebp
  800f33:	89 d1                	mov    %edx,%ecx
  800f35:	d3 ef                	shr    %cl,%edi
  800f37:	89 c1                	mov    %eax,%ecx
  800f39:	89 f0                	mov    %esi,%eax
  800f3b:	d3 e3                	shl    %cl,%ebx
  800f3d:	89 d1                	mov    %edx,%ecx
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	d3 e8                	shr    %cl,%eax
  800f43:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f48:	09 d8                	or     %ebx,%eax
  800f4a:	f7 74 24 08          	divl   0x8(%esp)
  800f4e:	89 d3                	mov    %edx,%ebx
  800f50:	d3 e6                	shl    %cl,%esi
  800f52:	f7 e5                	mul    %ebp
  800f54:	89 c7                	mov    %eax,%edi
  800f56:	89 d1                	mov    %edx,%ecx
  800f58:	39 d3                	cmp    %edx,%ebx
  800f5a:	72 06                	jb     800f62 <__umoddi3+0xe2>
  800f5c:	75 0e                	jne    800f6c <__umoddi3+0xec>
  800f5e:	39 c6                	cmp    %eax,%esi
  800f60:	73 0a                	jae    800f6c <__umoddi3+0xec>
  800f62:	29 e8                	sub    %ebp,%eax
  800f64:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f68:	89 d1                	mov    %edx,%ecx
  800f6a:	89 c7                	mov    %eax,%edi
  800f6c:	89 f5                	mov    %esi,%ebp
  800f6e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f72:	29 fd                	sub    %edi,%ebp
  800f74:	19 cb                	sbb    %ecx,%ebx
  800f76:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	d3 e0                	shl    %cl,%eax
  800f7f:	89 f1                	mov    %esi,%ecx
  800f81:	d3 ed                	shr    %cl,%ebp
  800f83:	d3 eb                	shr    %cl,%ebx
  800f85:	09 e8                	or     %ebp,%eax
  800f87:	89 da                	mov    %ebx,%edx
  800f89:	83 c4 1c             	add    $0x1c,%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
