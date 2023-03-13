
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  800045:	68 40 1e 80 00       	push   $0x801e40
  80004a:	e8 26 01 00 00       	call   800175 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 b9 0a 00 00       	call   800b0d <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 70 0a 00 00       	call   800acc <sys_env_destroy>
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
  80006c:	e8 cb 0c 00 00       	call   800d3c <set_pgfault_handler>
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
  80008b:	e8 7d 0a 00 00       	call   800b0d <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 d3 0e 00 00       	call   800fa4 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 f1 09 00 00       	call   800acc <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	74 09                	je     800108 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ff:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800106:	c9                   	leave  
  800107:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	68 ff 00 00 00       	push   $0xff
  800110:	8d 43 08             	lea    0x8(%ebx),%eax
  800113:	50                   	push   %eax
  800114:	e8 76 09 00 00       	call   800a8f <sys_cputs>
		b->idx = 0;
  800119:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	eb db                	jmp    8000ff <putch+0x1f>

00800124 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	push   0xc(%ebp)
  800144:	ff 75 08             	push   0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 e0 00 80 00       	push   $0x8000e0
  800153:	e8 14 01 00 00       	call   80026c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 22 09 00 00       	call   800a8f <sys_cputs>

	return b.cnt;
}
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	push   0x8(%ebp)
  800182:	e8 9d ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 d1                	mov    %edx,%ecx
  80019e:	89 c2                	mov    %eax,%edx
  8001a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b6:	39 c2                	cmp    %eax,%edx
  8001b8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001bb:	72 3e                	jb     8001fb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bd:	83 ec 0c             	sub    $0xc,%esp
  8001c0:	ff 75 18             	push   0x18(%ebp)
  8001c3:	83 eb 01             	sub    $0x1,%ebx
  8001c6:	53                   	push   %ebx
  8001c7:	50                   	push   %eax
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	ff 75 e4             	push   -0x1c(%ebp)
  8001ce:	ff 75 e0             	push   -0x20(%ebp)
  8001d1:	ff 75 dc             	push   -0x24(%ebp)
  8001d4:	ff 75 d8             	push   -0x28(%ebp)
  8001d7:	e8 14 1a 00 00       	call   801bf0 <__udivdi3>
  8001dc:	83 c4 18             	add    $0x18,%esp
  8001df:	52                   	push   %edx
  8001e0:	50                   	push   %eax
  8001e1:	89 f2                	mov    %esi,%edx
  8001e3:	89 f8                	mov    %edi,%eax
  8001e5:	e8 9f ff ff ff       	call   800189 <printnum>
  8001ea:	83 c4 20             	add    $0x20,%esp
  8001ed:	eb 13                	jmp    800202 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	56                   	push   %esi
  8001f3:	ff 75 18             	push   0x18(%ebp)
  8001f6:	ff d7                	call   *%edi
  8001f8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fb:	83 eb 01             	sub    $0x1,%ebx
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	7f ed                	jg     8001ef <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	56                   	push   %esi
  800206:	83 ec 04             	sub    $0x4,%esp
  800209:	ff 75 e4             	push   -0x1c(%ebp)
  80020c:	ff 75 e0             	push   -0x20(%ebp)
  80020f:	ff 75 dc             	push   -0x24(%ebp)
  800212:	ff 75 d8             	push   -0x28(%ebp)
  800215:	e8 f6 1a 00 00       	call   801d10 <__umoddi3>
  80021a:	83 c4 14             	add    $0x14,%esp
  80021d:	0f be 80 66 1e 80 00 	movsbl 0x801e66(%eax),%eax
  800224:	50                   	push   %eax
  800225:	ff d7                	call   *%edi
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5f                   	pop    %edi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800238:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	3b 50 04             	cmp    0x4(%eax),%edx
  800241:	73 0a                	jae    80024d <sprintputch+0x1b>
		*b->buf++ = ch;
  800243:	8d 4a 01             	lea    0x1(%edx),%ecx
  800246:	89 08                	mov    %ecx,(%eax)
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	88 02                	mov    %al,(%edx)
}
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <printfmt>:
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800258:	50                   	push   %eax
  800259:	ff 75 10             	push   0x10(%ebp)
  80025c:	ff 75 0c             	push   0xc(%ebp)
  80025f:	ff 75 08             	push   0x8(%ebp)
  800262:	e8 05 00 00 00       	call   80026c <vprintfmt>
}
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <vprintfmt>:
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	8b 75 08             	mov    0x8(%ebp),%esi
  800278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027e:	eb 0a                	jmp    80028a <vprintfmt+0x1e>
			putch(ch, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	ff d6                	call   *%esi
  800287:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80028a:	83 c7 01             	add    $0x1,%edi
  80028d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800291:	83 f8 25             	cmp    $0x25,%eax
  800294:	74 0c                	je     8002a2 <vprintfmt+0x36>
			if (ch == '\0')
  800296:	85 c0                	test   %eax,%eax
  800298:	75 e6                	jne    800280 <vprintfmt+0x14>
}
  80029a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029d:	5b                   	pop    %ebx
  80029e:	5e                   	pop    %esi
  80029f:	5f                   	pop    %edi
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    
		padc = ' ';
  8002a2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ad:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c0:	8d 47 01             	lea    0x1(%edi),%eax
  8002c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c6:	0f b6 17             	movzbl (%edi),%edx
  8002c9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cc:	3c 55                	cmp    $0x55,%al
  8002ce:	0f 87 bb 03 00 00    	ja     80068f <vprintfmt+0x423>
  8002d4:	0f b6 c0             	movzbl %al,%eax
  8002d7:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  8002de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002e5:	eb d9                	jmp    8002c0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ea:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002ee:	eb d0                	jmp    8002c0 <vprintfmt+0x54>
  8002f0:	0f b6 d2             	movzbl %dl,%edx
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 55                	ja     800365 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8b 00                	mov    (%eax),%eax
  80031a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 40 04             	lea    0x4(%eax),%eax
  800323:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800329:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80032d:	79 91                	jns    8002c0 <vprintfmt+0x54>
				width = precision, precision = -1;
  80032f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800332:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800335:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80033c:	eb 82                	jmp    8002c0 <vprintfmt+0x54>
  80033e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800341:	85 d2                	test   %edx,%edx
  800343:	b8 00 00 00 00       	mov    $0x0,%eax
  800348:	0f 49 c2             	cmovns %edx,%eax
  80034b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800351:	e9 6a ff ff ff       	jmp    8002c0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800359:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800360:	e9 5b ff ff ff       	jmp    8002c0 <vprintfmt+0x54>
  800365:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800368:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036b:	eb bc                	jmp    800329 <vprintfmt+0xbd>
			lflag++;
  80036d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800373:	e9 48 ff ff ff       	jmp    8002c0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 78 04             	lea    0x4(%eax),%edi
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	53                   	push   %ebx
  800382:	ff 30                	push   (%eax)
  800384:	ff d6                	call   *%esi
			break;
  800386:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800389:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038c:	e9 9d 02 00 00       	jmp    80062e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 78 04             	lea    0x4(%eax),%edi
  800397:	8b 10                	mov    (%eax),%edx
  800399:	89 d0                	mov    %edx,%eax
  80039b:	f7 d8                	neg    %eax
  80039d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a0:	83 f8 0f             	cmp    $0xf,%eax
  8003a3:	7f 23                	jg     8003c8 <vprintfmt+0x15c>
  8003a5:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 18                	je     8003c8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003b0:	52                   	push   %edx
  8003b1:	68 b5 22 80 00       	push   $0x8022b5
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 92 fe ff ff       	call   80024f <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c3:	e9 66 02 00 00       	jmp    80062e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003c8:	50                   	push   %eax
  8003c9:	68 7e 1e 80 00       	push   $0x801e7e
  8003ce:	53                   	push   %ebx
  8003cf:	56                   	push   %esi
  8003d0:	e8 7a fe ff ff       	call   80024f <printfmt>
  8003d5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003db:	e9 4e 02 00 00       	jmp    80062e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	83 c0 04             	add    $0x4,%eax
  8003e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003ee:	85 d2                	test   %edx,%edx
  8003f0:	b8 77 1e 80 00       	mov    $0x801e77,%eax
  8003f5:	0f 45 c2             	cmovne %edx,%eax
  8003f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	7e 06                	jle    800407 <vprintfmt+0x19b>
  800401:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800405:	75 0d                	jne    800414 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800407:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80040a:	89 c7                	mov    %eax,%edi
  80040c:	03 45 e0             	add    -0x20(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	eb 55                	jmp    800469 <vprintfmt+0x1fd>
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 d8             	push   -0x28(%ebp)
  80041a:	ff 75 cc             	push   -0x34(%ebp)
  80041d:	e8 0a 03 00 00       	call   80072c <strnlen>
  800422:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800425:	29 c1                	sub    %eax,%ecx
  800427:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80042f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	eb 0f                	jmp    800447 <vprintfmt+0x1db>
					putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 75 e0             	push   -0x20(%ebp)
  80043f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ef 01             	sub    $0x1,%edi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 ff                	test   %edi,%edi
  800449:	7f ed                	jg     800438 <vprintfmt+0x1cc>
  80044b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	0f 49 c2             	cmovns %edx,%eax
  800458:	29 c2                	sub    %eax,%edx
  80045a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80045d:	eb a8                	jmp    800407 <vprintfmt+0x19b>
					putch(ch, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	52                   	push   %edx
  800464:	ff d6                	call   *%esi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046e:	83 c7 01             	add    $0x1,%edi
  800471:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800475:	0f be d0             	movsbl %al,%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	74 4b                	je     8004c7 <vprintfmt+0x25b>
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	78 06                	js     800488 <vprintfmt+0x21c>
  800482:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800486:	78 1e                	js     8004a6 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800488:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048c:	74 d1                	je     80045f <vprintfmt+0x1f3>
  80048e:	0f be c0             	movsbl %al,%eax
  800491:	83 e8 20             	sub    $0x20,%eax
  800494:	83 f8 5e             	cmp    $0x5e,%eax
  800497:	76 c6                	jbe    80045f <vprintfmt+0x1f3>
					putch('?', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	6a 3f                	push   $0x3f
  80049f:	ff d6                	call   *%esi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	eb c3                	jmp    800469 <vprintfmt+0x1fd>
  8004a6:	89 cf                	mov    %ecx,%edi
  8004a8:	eb 0e                	jmp    8004b8 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	7f ee                	jg     8004aa <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	e9 67 01 00 00       	jmp    80062e <vprintfmt+0x3c2>
  8004c7:	89 cf                	mov    %ecx,%edi
  8004c9:	eb ed                	jmp    8004b8 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004cb:	83 f9 01             	cmp    $0x1,%ecx
  8004ce:	7f 1b                	jg     8004eb <vprintfmt+0x27f>
	else if (lflag)
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	74 63                	je     800537 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004dc:	99                   	cltd   
  8004dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 40 04             	lea    0x4(%eax),%eax
  8004e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e9:	eb 17                	jmp    800502 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8b 50 04             	mov    0x4(%eax),%edx
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 40 08             	lea    0x8(%eax),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800502:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800505:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800508:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80050d:	85 c9                	test   %ecx,%ecx
  80050f:	0f 89 ff 00 00 00    	jns    800614 <vprintfmt+0x3a8>
				putch('-', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	6a 2d                	push   $0x2d
  80051b:	ff d6                	call   *%esi
				num = -(long long) num;
  80051d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800523:	f7 da                	neg    %edx
  800525:	83 d1 00             	adc    $0x0,%ecx
  800528:	f7 d9                	neg    %ecx
  80052a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052d:	bf 0a 00 00 00       	mov    $0xa,%edi
  800532:	e9 dd 00 00 00       	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	99                   	cltd   
  800540:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 40 04             	lea    0x4(%eax),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
  80054c:	eb b4                	jmp    800502 <vprintfmt+0x296>
	if (lflag >= 2)
  80054e:	83 f9 01             	cmp    $0x1,%ecx
  800551:	7f 1e                	jg     800571 <vprintfmt+0x305>
	else if (lflag)
  800553:	85 c9                	test   %ecx,%ecx
  800555:	74 32                	je     800589 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800567:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80056c:	e9 a3 00 00 00       	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 10                	mov    (%eax),%edx
  800576:	8b 48 04             	mov    0x4(%eax),%ecx
  800579:	8d 40 08             	lea    0x8(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800584:	e9 8b 00 00 00       	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800593:	8d 40 04             	lea    0x4(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800599:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80059e:	eb 74                	jmp    800614 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005a0:	83 f9 01             	cmp    $0x1,%ecx
  8005a3:	7f 1b                	jg     8005c0 <vprintfmt+0x354>
	else if (lflag)
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	74 2c                	je     8005d5 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005b9:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005be:	eb 54                	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 10                	mov    (%eax),%edx
  8005c5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c8:	8d 40 08             	lea    0x8(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ce:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005d3:	eb 3f                	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005e5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005ea:	eb 28                	jmp    800614 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 30                	push   $0x30
  8005f2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f4:	83 c4 08             	add    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 78                	push   $0x78
  8005fa:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800606:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80060f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80061b:	50                   	push   %eax
  80061c:	ff 75 e0             	push   -0x20(%ebp)
  80061f:	57                   	push   %edi
  800620:	51                   	push   %ecx
  800621:	52                   	push   %edx
  800622:	89 da                	mov    %ebx,%edx
  800624:	89 f0                	mov    %esi,%eax
  800626:	e8 5e fb ff ff       	call   800189 <printnum>
			break;
  80062b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800631:	e9 54 fc ff ff       	jmp    80028a <vprintfmt+0x1e>
	if (lflag >= 2)
  800636:	83 f9 01             	cmp    $0x1,%ecx
  800639:	7f 1b                	jg     800656 <vprintfmt+0x3ea>
	else if (lflag)
  80063b:	85 c9                	test   %ecx,%ecx
  80063d:	74 2c                	je     80066b <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	b9 00 00 00 00       	mov    $0x0,%ecx
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800654:	eb be                	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	8b 48 04             	mov    0x4(%eax),%ecx
  80065e:	8d 40 08             	lea    0x8(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800664:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800669:	eb a9                	jmp    800614 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 10                	mov    (%eax),%edx
  800670:	b9 00 00 00 00       	mov    $0x0,%ecx
  800675:	8d 40 04             	lea    0x4(%eax),%eax
  800678:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800680:	eb 92                	jmp    800614 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	6a 25                	push   $0x25
  800688:	ff d6                	call   *%esi
			break;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 9f                	jmp    80062e <vprintfmt+0x3c2>
			putch('%', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 25                	push   $0x25
  800695:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	89 f8                	mov    %edi,%eax
  80069c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a0:	74 05                	je     8006a7 <vprintfmt+0x43b>
  8006a2:	83 e8 01             	sub    $0x1,%eax
  8006a5:	eb f5                	jmp    80069c <vprintfmt+0x430>
  8006a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006aa:	eb 82                	jmp    80062e <vprintfmt+0x3c2>

008006ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	83 ec 18             	sub    $0x18,%esp
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	74 26                	je     8006f3 <vsnprintf+0x47>
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	7e 22                	jle    8006f3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d1:	ff 75 14             	push   0x14(%ebp)
  8006d4:	ff 75 10             	push   0x10(%ebp)
  8006d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	68 32 02 80 00       	push   $0x800232
  8006e0:	e8 87 fb ff ff       	call   80026c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ee:	83 c4 10             	add    $0x10,%esp
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    
		return -E_INVAL;
  8006f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f8:	eb f7                	jmp    8006f1 <vsnprintf+0x45>

008006fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800703:	50                   	push   %eax
  800704:	ff 75 10             	push   0x10(%ebp)
  800707:	ff 75 0c             	push   0xc(%ebp)
  80070a:	ff 75 08             	push   0x8(%ebp)
  80070d:	e8 9a ff ff ff       	call   8006ac <vsnprintf>
	va_end(ap);

	return rc;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	eb 03                	jmp    800724 <strlen+0x10>
		n++;
  800721:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800724:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800728:	75 f7                	jne    800721 <strlen+0xd>
	return n;
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	eb 03                	jmp    80073f <strnlen+0x13>
		n++;
  80073c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	39 d0                	cmp    %edx,%eax
  800741:	74 08                	je     80074b <strnlen+0x1f>
  800743:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800747:	75 f3                	jne    80073c <strnlen+0x10>
  800749:	89 c2                	mov    %eax,%edx
	return n;
}
  80074b:	89 d0                	mov    %edx,%eax
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800762:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800765:	83 c0 01             	add    $0x1,%eax
  800768:	84 d2                	test   %dl,%dl
  80076a:	75 f2                	jne    80075e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80076c:	89 c8                	mov    %ecx,%eax
  80076e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	83 ec 10             	sub    $0x10,%esp
  80077a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077d:	53                   	push   %ebx
  80077e:	e8 91 ff ff ff       	call   800714 <strlen>
  800783:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800786:	ff 75 0c             	push   0xc(%ebp)
  800789:	01 d8                	add    %ebx,%eax
  80078b:	50                   	push   %eax
  80078c:	e8 be ff ff ff       	call   80074f <strcpy>
	return dst;
}
  800791:	89 d8                	mov    %ebx,%eax
  800793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a3:	89 f3                	mov    %esi,%ebx
  8007a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	eb 0f                	jmp    8007bb <strncpy+0x23>
		*dst++ = *src;
  8007ac:	83 c0 01             	add    $0x1,%eax
  8007af:	0f b6 0a             	movzbl (%edx),%ecx
  8007b2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b5:	80 f9 01             	cmp    $0x1,%cl
  8007b8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007bb:	39 d8                	cmp    %ebx,%eax
  8007bd:	75 ed                	jne    8007ac <strncpy+0x14>
	}
	return ret;
}
  8007bf:	89 f0                	mov    %esi,%eax
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 21                	je     8007fa <strlcpy+0x35>
  8007d9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007dd:	89 f2                	mov    %esi,%edx
  8007df:	eb 09                	jmp    8007ea <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007ea:	39 c2                	cmp    %eax,%edx
  8007ec:	74 09                	je     8007f7 <strlcpy+0x32>
  8007ee:	0f b6 19             	movzbl (%ecx),%ebx
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ec                	jne    8007e1 <strlcpy+0x1c>
  8007f5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fa:	29 f0                	sub    %esi,%eax
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800809:	eb 06                	jmp    800811 <strcmp+0x11>
		p++, q++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 04                	je     80081c <strcmp+0x1c>
  800818:	3a 02                	cmp    (%edx),%al
  80081a:	74 ef                	je     80080b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081c:	0f b6 c0             	movzbl %al,%eax
  80081f:	0f b6 12             	movzbl (%edx),%edx
  800822:	29 d0                	sub    %edx,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 c3                	mov    %eax,%ebx
  800832:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800835:	eb 06                	jmp    80083d <strncmp+0x17>
		n--, p++, q++;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80083d:	39 d8                	cmp    %ebx,%eax
  80083f:	74 18                	je     800859 <strncmp+0x33>
  800841:	0f b6 08             	movzbl (%eax),%ecx
  800844:	84 c9                	test   %cl,%cl
  800846:	74 04                	je     80084c <strncmp+0x26>
  800848:	3a 0a                	cmp    (%edx),%cl
  80084a:	74 eb                	je     800837 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084c:	0f b6 00             	movzbl (%eax),%eax
  80084f:	0f b6 12             	movzbl (%edx),%edx
  800852:	29 d0                	sub    %edx,%eax
}
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    
		return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb f4                	jmp    800854 <strncmp+0x2e>

00800860 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	eb 03                	jmp    80086f <strchr+0xf>
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
  800872:	84 d2                	test   %dl,%dl
  800874:	74 06                	je     80087c <strchr+0x1c>
		if (*s == c)
  800876:	38 ca                	cmp    %cl,%dl
  800878:	75 f2                	jne    80086c <strchr+0xc>
  80087a:	eb 05                	jmp    800881 <strchr+0x21>
			return (char *) s;
	return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 09                	je     80089d <strfind+0x1a>
  800894:	84 d2                	test   %dl,%dl
  800896:	74 05                	je     80089d <strfind+0x1a>
	for (; *s; s++)
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	eb f0                	jmp    80088d <strfind+0xa>
			break;
	return (char *) s;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	57                   	push   %edi
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ab:	85 c9                	test   %ecx,%ecx
  8008ad:	74 2f                	je     8008de <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008af:	89 f8                	mov    %edi,%eax
  8008b1:	09 c8                	or     %ecx,%eax
  8008b3:	a8 03                	test   $0x3,%al
  8008b5:	75 21                	jne    8008d8 <memset+0x39>
		c &= 0xFF;
  8008b7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bb:	89 d0                	mov    %edx,%eax
  8008bd:	c1 e0 08             	shl    $0x8,%eax
  8008c0:	89 d3                	mov    %edx,%ebx
  8008c2:	c1 e3 18             	shl    $0x18,%ebx
  8008c5:	89 d6                	mov    %edx,%esi
  8008c7:	c1 e6 10             	shl    $0x10,%esi
  8008ca:	09 f3                	or     %esi,%ebx
  8008cc:	09 da                	or     %ebx,%edx
  8008ce:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008d3:	fc                   	cld    
  8008d4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d6:	eb 06                	jmp    8008de <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	fc                   	cld    
  8008dc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008de:	89 f8                	mov    %edi,%eax
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	57                   	push   %edi
  8008e9:	56                   	push   %esi
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f3:	39 c6                	cmp    %eax,%esi
  8008f5:	73 32                	jae    800929 <memmove+0x44>
  8008f7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fa:	39 c2                	cmp    %eax,%edx
  8008fc:	76 2b                	jbe    800929 <memmove+0x44>
		s += n;
		d += n;
  8008fe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800901:	89 d6                	mov    %edx,%esi
  800903:	09 fe                	or     %edi,%esi
  800905:	09 ce                	or     %ecx,%esi
  800907:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090d:	75 0e                	jne    80091d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80090f:	83 ef 04             	sub    $0x4,%edi
  800912:	8d 72 fc             	lea    -0x4(%edx),%esi
  800915:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800918:	fd                   	std    
  800919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091b:	eb 09                	jmp    800926 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80091d:	83 ef 01             	sub    $0x1,%edi
  800920:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800923:	fd                   	std    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800926:	fc                   	cld    
  800927:	eb 1a                	jmp    800943 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800929:	89 f2                	mov    %esi,%edx
  80092b:	09 c2                	or     %eax,%edx
  80092d:	09 ca                	or     %ecx,%edx
  80092f:	f6 c2 03             	test   $0x3,%dl
  800932:	75 0a                	jne    80093e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800934:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800937:	89 c7                	mov    %eax,%edi
  800939:	fc                   	cld    
  80093a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093c:	eb 05                	jmp    800943 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80094d:	ff 75 10             	push   0x10(%ebp)
  800950:	ff 75 0c             	push   0xc(%ebp)
  800953:	ff 75 08             	push   0x8(%ebp)
  800956:	e8 8a ff ff ff       	call   8008e5 <memmove>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
  800968:	89 c6                	mov    %eax,%esi
  80096a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096d:	eb 06                	jmp    800975 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800975:	39 f0                	cmp    %esi,%eax
  800977:	74 14                	je     80098d <memcmp+0x30>
		if (*s1 != *s2)
  800979:	0f b6 08             	movzbl (%eax),%ecx
  80097c:	0f b6 1a             	movzbl (%edx),%ebx
  80097f:	38 d9                	cmp    %bl,%cl
  800981:	74 ec                	je     80096f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800983:	0f b6 c1             	movzbl %cl,%eax
  800986:	0f b6 db             	movzbl %bl,%ebx
  800989:	29 d8                	sub    %ebx,%eax
  80098b:	eb 05                	jmp    800992 <memcmp+0x35>
	}

	return 0;
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80099f:	89 c2                	mov    %eax,%edx
  8009a1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a4:	eb 03                	jmp    8009a9 <memfind+0x13>
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 04                	jae    8009b1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ad:	38 08                	cmp    %cl,(%eax)
  8009af:	75 f5                	jne    8009a6 <memfind+0x10>
			break;
	return (void *) s;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	eb 03                	jmp    8009c4 <strtol+0x11>
		s++;
  8009c1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009c4:	0f b6 02             	movzbl (%edx),%eax
  8009c7:	3c 20                	cmp    $0x20,%al
  8009c9:	74 f6                	je     8009c1 <strtol+0xe>
  8009cb:	3c 09                	cmp    $0x9,%al
  8009cd:	74 f2                	je     8009c1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009cf:	3c 2b                	cmp    $0x2b,%al
  8009d1:	74 2a                	je     8009fd <strtol+0x4a>
	int neg = 0;
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009d8:	3c 2d                	cmp    $0x2d,%al
  8009da:	74 2b                	je     800a07 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e2:	75 0f                	jne    8009f3 <strtol+0x40>
  8009e4:	80 3a 30             	cmpb   $0x30,(%edx)
  8009e7:	74 28                	je     800a11 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e9:	85 db                	test   %ebx,%ebx
  8009eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f0:	0f 44 d8             	cmove  %eax,%ebx
  8009f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009fb:	eb 46                	jmp    800a43 <strtol+0x90>
		s++;
  8009fd:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
  800a05:	eb d5                	jmp    8009dc <strtol+0x29>
		s++, neg = 1;
  800a07:	83 c2 01             	add    $0x1,%edx
  800a0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0f:	eb cb                	jmp    8009dc <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a11:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a15:	74 0e                	je     800a25 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a17:	85 db                	test   %ebx,%ebx
  800a19:	75 d8                	jne    8009f3 <strtol+0x40>
		s++, base = 8;
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a23:	eb ce                	jmp    8009f3 <strtol+0x40>
		s += 2, base = 16;
  800a25:	83 c2 02             	add    $0x2,%edx
  800a28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2d:	eb c4                	jmp    8009f3 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a2f:	0f be c0             	movsbl %al,%eax
  800a32:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a35:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a38:	7d 3a                	jge    800a74 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a3a:	83 c2 01             	add    $0x1,%edx
  800a3d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a41:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a43:	0f b6 02             	movzbl (%edx),%eax
  800a46:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a49:	89 f3                	mov    %esi,%ebx
  800a4b:	80 fb 09             	cmp    $0x9,%bl
  800a4e:	76 df                	jbe    800a2f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a50:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	80 fb 19             	cmp    $0x19,%bl
  800a58:	77 08                	ja     800a62 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a5a:	0f be c0             	movsbl %al,%eax
  800a5d:	83 e8 57             	sub    $0x57,%eax
  800a60:	eb d3                	jmp    800a35 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a62:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a6c:	0f be c0             	movsbl %al,%eax
  800a6f:	83 e8 37             	sub    $0x37,%eax
  800a72:	eb c1                	jmp    800a35 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a78:	74 05                	je     800a7f <strtol+0xcc>
		*endptr = (char *) s;
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a7f:	89 c8                	mov    %ecx,%eax
  800a81:	f7 d8                	neg    %eax
  800a83:	85 ff                	test   %edi,%edi
  800a85:	0f 45 c8             	cmovne %eax,%ecx
}
  800a88:	89 c8                	mov    %ecx,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	89 c6                	mov    %eax,%esi
  800aa6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <sys_cgetc>:

int
sys_cgetc(void)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab8:	b8 01 00 00 00       	mov    $0x1,%eax
  800abd:	89 d1                	mov    %edx,%ecx
  800abf:	89 d3                	mov    %edx,%ebx
  800ac1:	89 d7                	mov    %edx,%edi
  800ac3:	89 d6                	mov    %edx,%esi
  800ac5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ad5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae2:	89 cb                	mov    %ecx,%ebx
  800ae4:	89 cf                	mov    %ecx,%edi
  800ae6:	89 ce                	mov    %ecx,%esi
  800ae8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800aea:	85 c0                	test   %eax,%eax
  800aec:	7f 08                	jg     800af6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	50                   	push   %eax
  800afa:	6a 03                	push   $0x3
  800afc:	68 5f 21 80 00       	push   $0x80215f
  800b01:	6a 2a                	push   $0x2a
  800b03:	68 7c 21 80 00       	push   $0x80217c
  800b08:	e8 6c 0f 00 00       	call   801a79 <_panic>

00800b0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1d:	89 d1                	mov    %edx,%ecx
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	89 d7                	mov    %edx,%edi
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_yield>:

void
sys_yield(void)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3c:	89 d1                	mov    %edx,%ecx
  800b3e:	89 d3                	mov    %edx,%ebx
  800b40:	89 d7                	mov    %edx,%edi
  800b42:	89 d6                	mov    %edx,%esi
  800b44:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b54:	be 00 00 00 00       	mov    $0x0,%esi
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b67:	89 f7                	mov    %esi,%edi
  800b69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7f 08                	jg     800b77 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	50                   	push   %eax
  800b7b:	6a 04                	push   $0x4
  800b7d:	68 5f 21 80 00       	push   $0x80215f
  800b82:	6a 2a                	push   $0x2a
  800b84:	68 7c 21 80 00       	push   $0x80217c
  800b89:	e8 eb 0e 00 00       	call   801a79 <_panic>

00800b8e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	7f 08                	jg     800bb9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 05                	push   $0x5
  800bbf:	68 5f 21 80 00       	push   $0x80215f
  800bc4:	6a 2a                	push   $0x2a
  800bc6:	68 7c 21 80 00       	push   $0x80217c
  800bcb:	e8 a9 0e 00 00       	call   801a79 <_panic>

00800bd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	b8 06 00 00 00       	mov    $0x6,%eax
  800be9:	89 df                	mov    %ebx,%edi
  800beb:	89 de                	mov    %ebx,%esi
  800bed:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7f 08                	jg     800bfb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 06                	push   $0x6
  800c01:	68 5f 21 80 00       	push   $0x80215f
  800c06:	6a 2a                	push   $0x2a
  800c08:	68 7c 21 80 00       	push   $0x80217c
  800c0d:	e8 67 0e 00 00       	call   801a79 <_panic>

00800c12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2b:	89 df                	mov    %ebx,%edi
  800c2d:	89 de                	mov    %ebx,%esi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7f 08                	jg     800c3d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 08                	push   $0x8
  800c43:	68 5f 21 80 00       	push   $0x80215f
  800c48:	6a 2a                	push   $0x2a
  800c4a:	68 7c 21 80 00       	push   $0x80217c
  800c4f:	e8 25 0e 00 00       	call   801a79 <_panic>

00800c54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6d:	89 df                	mov    %ebx,%edi
  800c6f:	89 de                	mov    %ebx,%esi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 09                	push   $0x9
  800c85:	68 5f 21 80 00       	push   $0x80215f
  800c8a:	6a 2a                	push   $0x2a
  800c8c:	68 7c 21 80 00       	push   $0x80217c
  800c91:	e8 e3 0d 00 00       	call   801a79 <_panic>

00800c96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 0a                	push   $0xa
  800cc7:	68 5f 21 80 00       	push   $0x80215f
  800ccc:	6a 2a                	push   $0x2a
  800cce:	68 7c 21 80 00       	push   $0x80217c
  800cd3:	e8 a1 0d 00 00       	call   801a79 <_panic>

00800cd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce9:	be 00 00 00 00       	mov    $0x0,%esi
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d11:	89 cb                	mov    %ecx,%ebx
  800d13:	89 cf                	mov    %ecx,%edi
  800d15:	89 ce                	mov    %ecx,%esi
  800d17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7f 08                	jg     800d25 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 0d                	push   $0xd
  800d2b:	68 5f 21 80 00       	push   $0x80215f
  800d30:	6a 2a                	push   $0x2a
  800d32:	68 7c 21 80 00       	push   $0x80217c
  800d37:	e8 3d 0d 00 00       	call   801a79 <_panic>

00800d3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800d42:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d49:	74 0a                	je     800d55 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800d55:	e8 b3 fd ff ff       	call   800b0d <sys_getenvid>
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 0e 00 00       	push   $0xe07
  800d62:	68 00 f0 bf ee       	push   $0xeebff000
  800d67:	50                   	push   %eax
  800d68:	e8 de fd ff ff       	call   800b4b <sys_page_alloc>
		if (r < 0) {
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	78 2c                	js     800da0 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d74:	e8 94 fd ff ff       	call   800b0d <sys_getenvid>
  800d79:	83 ec 08             	sub    $0x8,%esp
  800d7c:	68 b2 0d 80 00       	push   $0x800db2
  800d81:	50                   	push   %eax
  800d82:	e8 0f ff ff ff       	call   800c96 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	79 bd                	jns    800d4b <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800d8e:	50                   	push   %eax
  800d8f:	68 cc 21 80 00       	push   $0x8021cc
  800d94:	6a 28                	push   $0x28
  800d96:	68 02 22 80 00       	push   $0x802202
  800d9b:	e8 d9 0c 00 00       	call   801a79 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800da0:	50                   	push   %eax
  800da1:	68 8c 21 80 00       	push   $0x80218c
  800da6:	6a 23                	push   $0x23
  800da8:	68 02 22 80 00       	push   $0x802202
  800dad:	e8 c7 0c 00 00       	call   801a79 <_panic>

00800db2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800db2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800db3:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800db8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dba:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800dbd:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800dc1:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800dc4:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800dc8:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800dcc:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800dce:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800dd1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800dd2:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800dd5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800dd6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800dd7:	c3                   	ret    

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	05 00 00 00 30       	add    $0x30000000,%eax
  800de3:	c1 e8 0c             	shr    $0xc,%eax
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	c1 ea 16             	shr    $0x16,%edx
  800e0c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e13:	f6 c2 01             	test   $0x1,%dl
  800e16:	74 29                	je     800e41 <fd_alloc+0x42>
  800e18:	89 c2                	mov    %eax,%edx
  800e1a:	c1 ea 0c             	shr    $0xc,%edx
  800e1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e24:	f6 c2 01             	test   $0x1,%dl
  800e27:	74 18                	je     800e41 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e29:	05 00 10 00 00       	add    $0x1000,%eax
  800e2e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e33:	75 d2                	jne    800e07 <fd_alloc+0x8>
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e3a:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800e3f:	eb 05                	jmp    800e46 <fd_alloc+0x47>
			return 0;
  800e41:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 02                	mov    %eax,(%edx)
}
  800e4b:	89 c8                	mov    %ecx,%eax
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e55:	83 f8 1f             	cmp    $0x1f,%eax
  800e58:	77 30                	ja     800e8a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5a:	c1 e0 0c             	shl    $0xc,%eax
  800e5d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e62:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e68:	f6 c2 01             	test   $0x1,%dl
  800e6b:	74 24                	je     800e91 <fd_lookup+0x42>
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	c1 ea 0c             	shr    $0xc,%edx
  800e72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e79:	f6 c2 01             	test   $0x1,%dl
  800e7c:	74 1a                	je     800e98 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e81:	89 02                	mov    %eax,(%edx)
	return 0;
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
		return -E_INVAL;
  800e8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8f:	eb f7                	jmp    800e88 <fd_lookup+0x39>
		return -E_INVAL;
  800e91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e96:	eb f0                	jmp    800e88 <fd_lookup+0x39>
  800e98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9d:	eb e9                	jmp    800e88 <fd_lookup+0x39>

00800e9f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	b8 8c 22 80 00       	mov    $0x80228c,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800eae:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800eb3:	39 13                	cmp    %edx,(%ebx)
  800eb5:	74 32                	je     800ee9 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800eb7:	83 c0 04             	add    $0x4,%eax
  800eba:	8b 18                	mov    (%eax),%ebx
  800ebc:	85 db                	test   %ebx,%ebx
  800ebe:	75 f3                	jne    800eb3 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec0:	a1 00 40 80 00       	mov    0x804000,%eax
  800ec5:	8b 40 48             	mov    0x48(%eax),%eax
  800ec8:	83 ec 04             	sub    $0x4,%esp
  800ecb:	52                   	push   %edx
  800ecc:	50                   	push   %eax
  800ecd:	68 10 22 80 00       	push   $0x802210
  800ed2:	e8 9e f2 ff ff       	call   800175 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800ed7:	83 c4 10             	add    $0x10,%esp
  800eda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800edf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee2:	89 1a                	mov    %ebx,(%edx)
}
  800ee4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    
			return 0;
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	eb ef                	jmp    800edf <dev_lookup+0x40>

00800ef0 <fd_close>:
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 24             	sub    $0x24,%esp
  800ef9:	8b 75 08             	mov    0x8(%ebp),%esi
  800efc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f02:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f03:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f09:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0c:	50                   	push   %eax
  800f0d:	e8 3d ff ff ff       	call   800e4f <fd_lookup>
  800f12:	89 c3                	mov    %eax,%ebx
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 05                	js     800f20 <fd_close+0x30>
	    || fd != fd2)
  800f1b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f1e:	74 16                	je     800f36 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f20:	89 f8                	mov    %edi,%eax
  800f22:	84 c0                	test   %al,%al
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	0f 44 d8             	cmove  %eax,%ebx
}
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	ff 36                	push   (%esi)
  800f3f:	e8 5b ff ff ff       	call   800e9f <dev_lookup>
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 1a                	js     800f67 <fd_close+0x77>
		if (dev->dev_close)
  800f4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f50:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	74 0b                	je     800f67 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	56                   	push   %esi
  800f60:	ff d0                	call   *%eax
  800f62:	89 c3                	mov    %eax,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 5e fc ff ff       	call   800bd0 <sys_page_unmap>
	return r;
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	eb b5                	jmp    800f2c <fd_close+0x3c>

00800f77 <close>:

int
close(int fdnum)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 75 08             	push   0x8(%ebp)
  800f84:	e8 c6 fe ff ff       	call   800e4f <fd_lookup>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 02                	jns    800f92 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    
		return fd_close(fd, 1);
  800f92:	83 ec 08             	sub    $0x8,%esp
  800f95:	6a 01                	push   $0x1
  800f97:	ff 75 f4             	push   -0xc(%ebp)
  800f9a:	e8 51 ff ff ff       	call   800ef0 <fd_close>
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	eb ec                	jmp    800f90 <close+0x19>

00800fa4 <close_all>:

void
close_all(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	53                   	push   %ebx
  800fb4:	e8 be ff ff ff       	call   800f77 <close>
	for (i = 0; i < MAXFD; i++)
  800fb9:	83 c3 01             	add    $0x1,%ebx
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	83 fb 20             	cmp    $0x20,%ebx
  800fc2:	75 ec                	jne    800fb0 <close_all+0xc>
}
  800fc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd5:	50                   	push   %eax
  800fd6:	ff 75 08             	push   0x8(%ebp)
  800fd9:	e8 71 fe ff ff       	call   800e4f <fd_lookup>
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 7f                	js     801066 <dup+0x9d>
		return r;
	close(newfdnum);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	ff 75 0c             	push   0xc(%ebp)
  800fed:	e8 85 ff ff ff       	call   800f77 <close>

	newfd = INDEX2FD(newfdnum);
  800ff2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ff5:	c1 e6 0c             	shl    $0xc,%esi
  800ff8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800ffe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801001:	89 3c 24             	mov    %edi,(%esp)
  801004:	e8 df fd ff ff       	call   800de8 <fd2data>
  801009:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80100b:	89 34 24             	mov    %esi,(%esp)
  80100e:	e8 d5 fd ff ff       	call   800de8 <fd2data>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	c1 e8 16             	shr    $0x16,%eax
  80101e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801025:	a8 01                	test   $0x1,%al
  801027:	74 11                	je     80103a <dup+0x71>
  801029:	89 d8                	mov    %ebx,%eax
  80102b:	c1 e8 0c             	shr    $0xc,%eax
  80102e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801035:	f6 c2 01             	test   $0x1,%dl
  801038:	75 36                	jne    801070 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103a:	89 f8                	mov    %edi,%eax
  80103c:	c1 e8 0c             	shr    $0xc,%eax
  80103f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	25 07 0e 00 00       	and    $0xe07,%eax
  80104e:	50                   	push   %eax
  80104f:	56                   	push   %esi
  801050:	6a 00                	push   $0x0
  801052:	57                   	push   %edi
  801053:	6a 00                	push   $0x0
  801055:	e8 34 fb ff ff       	call   800b8e <sys_page_map>
  80105a:	89 c3                	mov    %eax,%ebx
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 33                	js     801096 <dup+0xcd>
		goto err;

	return newfdnum;
  801063:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801066:	89 d8                	mov    %ebx,%eax
  801068:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801070:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	25 07 0e 00 00       	and    $0xe07,%eax
  80107f:	50                   	push   %eax
  801080:	ff 75 d4             	push   -0x2c(%ebp)
  801083:	6a 00                	push   $0x0
  801085:	53                   	push   %ebx
  801086:	6a 00                	push   $0x0
  801088:	e8 01 fb ff ff       	call   800b8e <sys_page_map>
  80108d:	89 c3                	mov    %eax,%ebx
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	79 a4                	jns    80103a <dup+0x71>
	sys_page_unmap(0, newfd);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	56                   	push   %esi
  80109a:	6a 00                	push   $0x0
  80109c:	e8 2f fb ff ff       	call   800bd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a1:	83 c4 08             	add    $0x8,%esp
  8010a4:	ff 75 d4             	push   -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 22 fb ff ff       	call   800bd0 <sys_page_unmap>
	return r;
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	eb b3                	jmp    801066 <dup+0x9d>

008010b3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 18             	sub    $0x18,%esp
  8010bb:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	56                   	push   %esi
  8010c3:	e8 87 fd ff ff       	call   800e4f <fd_lookup>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 3c                	js     80110b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8010d2:	83 ec 08             	sub    $0x8,%esp
  8010d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	ff 33                	push   (%ebx)
  8010db:	e8 bf fd ff ff       	call   800e9f <dev_lookup>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 24                	js     80110b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e7:	8b 43 08             	mov    0x8(%ebx),%eax
  8010ea:	83 e0 03             	and    $0x3,%eax
  8010ed:	83 f8 01             	cmp    $0x1,%eax
  8010f0:	74 20                	je     801112 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f5:	8b 40 08             	mov    0x8(%eax),%eax
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	74 37                	je     801133 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	ff 75 10             	push   0x10(%ebp)
  801102:	ff 75 0c             	push   0xc(%ebp)
  801105:	53                   	push   %ebx
  801106:	ff d0                	call   *%eax
  801108:	83 c4 10             	add    $0x10,%esp
}
  80110b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801112:	a1 00 40 80 00       	mov    0x804000,%eax
  801117:	8b 40 48             	mov    0x48(%eax),%eax
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	56                   	push   %esi
  80111e:	50                   	push   %eax
  80111f:	68 51 22 80 00       	push   $0x802251
  801124:	e8 4c f0 ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801131:	eb d8                	jmp    80110b <read+0x58>
		return -E_NOT_SUPP;
  801133:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801138:	eb d1                	jmp    80110b <read+0x58>

0080113a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	8b 7d 08             	mov    0x8(%ebp),%edi
  801146:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114e:	eb 02                	jmp    801152 <readn+0x18>
  801150:	01 c3                	add    %eax,%ebx
  801152:	39 f3                	cmp    %esi,%ebx
  801154:	73 21                	jae    801177 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	89 f0                	mov    %esi,%eax
  80115b:	29 d8                	sub    %ebx,%eax
  80115d:	50                   	push   %eax
  80115e:	89 d8                	mov    %ebx,%eax
  801160:	03 45 0c             	add    0xc(%ebp),%eax
  801163:	50                   	push   %eax
  801164:	57                   	push   %edi
  801165:	e8 49 ff ff ff       	call   8010b3 <read>
		if (m < 0)
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 04                	js     801175 <readn+0x3b>
			return m;
		if (m == 0)
  801171:	75 dd                	jne    801150 <readn+0x16>
  801173:	eb 02                	jmp    801177 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801175:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801177:	89 d8                	mov    %ebx,%eax
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	56                   	push   %esi
  801185:	53                   	push   %ebx
  801186:	83 ec 18             	sub    $0x18,%esp
  801189:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118f:	50                   	push   %eax
  801190:	53                   	push   %ebx
  801191:	e8 b9 fc ff ff       	call   800e4f <fd_lookup>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 37                	js     8011d4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a6:	50                   	push   %eax
  8011a7:	ff 36                	push   (%esi)
  8011a9:	e8 f1 fc ff ff       	call   800e9f <dev_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 1f                	js     8011d4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011b9:	74 20                	je     8011db <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011be:	8b 40 0c             	mov    0xc(%eax),%eax
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	74 37                	je     8011fc <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	ff 75 10             	push   0x10(%ebp)
  8011cb:	ff 75 0c             	push   0xc(%ebp)
  8011ce:	56                   	push   %esi
  8011cf:	ff d0                	call   *%eax
  8011d1:	83 c4 10             	add    $0x10,%esp
}
  8011d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011db:	a1 00 40 80 00       	mov    0x804000,%eax
  8011e0:	8b 40 48             	mov    0x48(%eax),%eax
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	53                   	push   %ebx
  8011e7:	50                   	push   %eax
  8011e8:	68 6d 22 80 00       	push   $0x80226d
  8011ed:	e8 83 ef ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fa:	eb d8                	jmp    8011d4 <write+0x53>
		return -E_NOT_SUPP;
  8011fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801201:	eb d1                	jmp    8011d4 <write+0x53>

00801203 <seek>:

int
seek(int fdnum, off_t offset)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	ff 75 08             	push   0x8(%ebp)
  801210:	e8 3a fc ff ff       	call   800e4f <fd_lookup>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 0e                	js     80122a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80121c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801222:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 18             	sub    $0x18,%esp
  801234:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801237:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	53                   	push   %ebx
  80123c:	e8 0e fc ff ff       	call   800e4f <fd_lookup>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 34                	js     80127c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 36                	push   (%esi)
  801254:	e8 46 fc ff ff       	call   800e9f <dev_lookup>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 1c                	js     80127c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801260:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801264:	74 1d                	je     801283 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801269:	8b 40 18             	mov    0x18(%eax),%eax
  80126c:	85 c0                	test   %eax,%eax
  80126e:	74 34                	je     8012a4 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801270:	83 ec 08             	sub    $0x8,%esp
  801273:	ff 75 0c             	push   0xc(%ebp)
  801276:	56                   	push   %esi
  801277:	ff d0                	call   *%eax
  801279:	83 c4 10             	add    $0x10,%esp
}
  80127c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    
			thisenv->env_id, fdnum);
  801283:	a1 00 40 80 00       	mov    0x804000,%eax
  801288:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	53                   	push   %ebx
  80128f:	50                   	push   %eax
  801290:	68 30 22 80 00       	push   $0x802230
  801295:	e8 db ee ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a2:	eb d8                	jmp    80127c <ftruncate+0x50>
		return -E_NOT_SUPP;
  8012a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a9:	eb d1                	jmp    80127c <ftruncate+0x50>

008012ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 18             	sub    $0x18,%esp
  8012b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	ff 75 08             	push   0x8(%ebp)
  8012bd:	e8 8d fb ff ff       	call   800e4f <fd_lookup>
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 49                	js     801312 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d2:	50                   	push   %eax
  8012d3:	ff 36                	push   (%esi)
  8012d5:	e8 c5 fb ff ff       	call   800e9f <dev_lookup>
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 31                	js     801312 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8012e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012e8:	74 2f                	je     801319 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f4:	00 00 00 
	stat->st_isdir = 0;
  8012f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012fe:	00 00 00 
	stat->st_dev = dev;
  801301:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	53                   	push   %ebx
  80130b:	56                   	push   %esi
  80130c:	ff 50 14             	call   *0x14(%eax)
  80130f:	83 c4 10             	add    $0x10,%esp
}
  801312:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    
		return -E_NOT_SUPP;
  801319:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80131e:	eb f2                	jmp    801312 <fstat+0x67>

00801320 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	6a 00                	push   $0x0
  80132a:	ff 75 08             	push   0x8(%ebp)
  80132d:	e8 e4 01 00 00       	call   801516 <open>
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 1b                	js     801356 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	ff 75 0c             	push   0xc(%ebp)
  801341:	50                   	push   %eax
  801342:	e8 64 ff ff ff       	call   8012ab <fstat>
  801347:	89 c6                	mov    %eax,%esi
	close(fd);
  801349:	89 1c 24             	mov    %ebx,(%esp)
  80134c:	e8 26 fc ff ff       	call   800f77 <close>
	return r;
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	89 f3                	mov    %esi,%ebx
}
  801356:	89 d8                	mov    %ebx,%eax
  801358:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5e                   	pop    %esi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	89 c6                	mov    %eax,%esi
  801366:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801368:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80136f:	74 27                	je     801398 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801371:	6a 07                	push   $0x7
  801373:	68 00 50 80 00       	push   $0x805000
  801378:	56                   	push   %esi
  801379:	ff 35 00 60 80 00    	push   0x806000
  80137f:	e8 a2 07 00 00       	call   801b26 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801384:	83 c4 0c             	add    $0xc,%esp
  801387:	6a 00                	push   $0x0
  801389:	53                   	push   %ebx
  80138a:	6a 00                	push   $0x0
  80138c:	e8 2e 07 00 00       	call   801abf <ipc_recv>
}
  801391:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	6a 01                	push   $0x1
  80139d:	e8 d8 07 00 00       	call   801b7a <ipc_find_env>
  8013a2:	a3 00 60 80 00       	mov    %eax,0x806000
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb c5                	jmp    801371 <fsipc+0x12>

008013ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8013cf:	e8 8b ff ff ff       	call   80135f <fsipc>
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <devfile_flush>:
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f1:	e8 69 ff ff ff       	call   80135f <fsipc>
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devfile_stat>:
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 05 00 00 00       	mov    $0x5,%eax
  801417:	e8 43 ff ff ff       	call   80135f <fsipc>
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 2c                	js     80144c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	68 00 50 80 00       	push   $0x805000
  801428:	53                   	push   %ebx
  801429:	e8 21 f3 ff ff       	call   80074f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80142e:	a1 80 50 80 00       	mov    0x805080,%eax
  801433:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801439:	a1 84 50 80 00       	mov    0x805084,%eax
  80143e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <devfile_write>:
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	8b 45 10             	mov    0x10(%ebp),%eax
  80145a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80145f:	39 d0                	cmp    %edx,%eax
  801461:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801464:	8b 55 08             	mov    0x8(%ebp),%edx
  801467:	8b 52 0c             	mov    0xc(%edx),%edx
  80146a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801470:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801475:	50                   	push   %eax
  801476:	ff 75 0c             	push   0xc(%ebp)
  801479:	68 08 50 80 00       	push   $0x805008
  80147e:	e8 62 f4 ff ff       	call   8008e5 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 04 00 00 00       	mov    $0x4,%eax
  80148d:	e8 cd fe ff ff       	call   80135f <fsipc>
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <devfile_read>:
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b7:	e8 a3 fe ff ff       	call   80135f <fsipc>
  8014bc:	89 c3                	mov    %eax,%ebx
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 1f                	js     8014e1 <devfile_read+0x4d>
	assert(r <= n);
  8014c2:	39 f0                	cmp    %esi,%eax
  8014c4:	77 24                	ja     8014ea <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014cb:	7f 33                	jg     801500 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	50                   	push   %eax
  8014d1:	68 00 50 80 00       	push   $0x805000
  8014d6:	ff 75 0c             	push   0xc(%ebp)
  8014d9:	e8 07 f4 ff ff       	call   8008e5 <memmove>
	return r;
  8014de:	83 c4 10             	add    $0x10,%esp
}
  8014e1:	89 d8                	mov    %ebx,%eax
  8014e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    
	assert(r <= n);
  8014ea:	68 9c 22 80 00       	push   $0x80229c
  8014ef:	68 a3 22 80 00       	push   $0x8022a3
  8014f4:	6a 7c                	push   $0x7c
  8014f6:	68 b8 22 80 00       	push   $0x8022b8
  8014fb:	e8 79 05 00 00       	call   801a79 <_panic>
	assert(r <= PGSIZE);
  801500:	68 c3 22 80 00       	push   $0x8022c3
  801505:	68 a3 22 80 00       	push   $0x8022a3
  80150a:	6a 7d                	push   $0x7d
  80150c:	68 b8 22 80 00       	push   $0x8022b8
  801511:	e8 63 05 00 00       	call   801a79 <_panic>

00801516 <open>:
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 1c             	sub    $0x1c,%esp
  80151e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801521:	56                   	push   %esi
  801522:	e8 ed f1 ff ff       	call   800714 <strlen>
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152f:	7f 6c                	jg     80159d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801531:	83 ec 0c             	sub    $0xc,%esp
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	e8 c2 f8 ff ff       	call   800dff <fd_alloc>
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 3c                	js     801582 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	56                   	push   %esi
  80154a:	68 00 50 80 00       	push   $0x805000
  80154f:	e8 fb f1 ff ff       	call   80074f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801554:	8b 45 0c             	mov    0xc(%ebp),%eax
  801557:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155f:	b8 01 00 00 00       	mov    $0x1,%eax
  801564:	e8 f6 fd ff ff       	call   80135f <fsipc>
  801569:	89 c3                	mov    %eax,%ebx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 19                	js     80158b <open+0x75>
	return fd2num(fd);
  801572:	83 ec 0c             	sub    $0xc,%esp
  801575:	ff 75 f4             	push   -0xc(%ebp)
  801578:	e8 5b f8 ff ff       	call   800dd8 <fd2num>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
}
  801582:	89 d8                	mov    %ebx,%eax
  801584:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
		fd_close(fd, 0);
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	6a 00                	push   $0x0
  801590:	ff 75 f4             	push   -0xc(%ebp)
  801593:	e8 58 f9 ff ff       	call   800ef0 <fd_close>
		return r;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	eb e5                	jmp    801582 <open+0x6c>
		return -E_BAD_PATH;
  80159d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015a2:	eb de                	jmp    801582 <open+0x6c>

008015a4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015af:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b4:	e8 a6 fd ff ff       	call   80135f <fsipc>
}
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	ff 75 08             	push   0x8(%ebp)
  8015c9:	e8 1a f8 ff ff       	call   800de8 <fd2data>
  8015ce:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	68 cf 22 80 00       	push   $0x8022cf
  8015d8:	53                   	push   %ebx
  8015d9:	e8 71 f1 ff ff       	call   80074f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015de:	8b 46 04             	mov    0x4(%esi),%eax
  8015e1:	2b 06                	sub    (%esi),%eax
  8015e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f0:	00 00 00 
	stat->st_dev = &devpipe;
  8015f3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015fa:	30 80 00 
	return 0;
}
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801602:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	53                   	push   %ebx
  80160d:	83 ec 0c             	sub    $0xc,%esp
  801610:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801613:	53                   	push   %ebx
  801614:	6a 00                	push   $0x0
  801616:	e8 b5 f5 ff ff       	call   800bd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80161b:	89 1c 24             	mov    %ebx,(%esp)
  80161e:	e8 c5 f7 ff ff       	call   800de8 <fd2data>
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	50                   	push   %eax
  801627:	6a 00                	push   $0x0
  801629:	e8 a2 f5 ff ff       	call   800bd0 <sys_page_unmap>
}
  80162e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <_pipeisclosed>:
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	57                   	push   %edi
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	83 ec 1c             	sub    $0x1c,%esp
  80163c:	89 c7                	mov    %eax,%edi
  80163e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801640:	a1 00 40 80 00       	mov    0x804000,%eax
  801645:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	57                   	push   %edi
  80164c:	e8 62 05 00 00       	call   801bb3 <pageref>
  801651:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801654:	89 34 24             	mov    %esi,(%esp)
  801657:	e8 57 05 00 00       	call   801bb3 <pageref>
		nn = thisenv->env_runs;
  80165c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801662:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	39 cb                	cmp    %ecx,%ebx
  80166a:	74 1b                	je     801687 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80166c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80166f:	75 cf                	jne    801640 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801671:	8b 42 58             	mov    0x58(%edx),%eax
  801674:	6a 01                	push   $0x1
  801676:	50                   	push   %eax
  801677:	53                   	push   %ebx
  801678:	68 d6 22 80 00       	push   $0x8022d6
  80167d:	e8 f3 ea ff ff       	call   800175 <cprintf>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb b9                	jmp    801640 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801687:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80168a:	0f 94 c0             	sete   %al
  80168d:	0f b6 c0             	movzbl %al,%eax
}
  801690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5f                   	pop    %edi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <devpipe_write>:
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	57                   	push   %edi
  80169c:	56                   	push   %esi
  80169d:	53                   	push   %ebx
  80169e:	83 ec 28             	sub    $0x28,%esp
  8016a1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016a4:	56                   	push   %esi
  8016a5:	e8 3e f7 ff ff       	call   800de8 <fd2data>
  8016aa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	bf 00 00 00 00       	mov    $0x0,%edi
  8016b4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016b7:	75 09                	jne    8016c2 <devpipe_write+0x2a>
	return i;
  8016b9:	89 f8                	mov    %edi,%eax
  8016bb:	eb 23                	jmp    8016e0 <devpipe_write+0x48>
			sys_yield();
  8016bd:	e8 6a f4 ff ff       	call   800b2c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016c2:	8b 43 04             	mov    0x4(%ebx),%eax
  8016c5:	8b 0b                	mov    (%ebx),%ecx
  8016c7:	8d 51 20             	lea    0x20(%ecx),%edx
  8016ca:	39 d0                	cmp    %edx,%eax
  8016cc:	72 1a                	jb     8016e8 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8016ce:	89 da                	mov    %ebx,%edx
  8016d0:	89 f0                	mov    %esi,%eax
  8016d2:	e8 5c ff ff ff       	call   801633 <_pipeisclosed>
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	74 e2                	je     8016bd <devpipe_write+0x25>
				return 0;
  8016db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5f                   	pop    %edi
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016eb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016ef:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	c1 fa 1f             	sar    $0x1f,%edx
  8016f7:	89 d1                	mov    %edx,%ecx
  8016f9:	c1 e9 1b             	shr    $0x1b,%ecx
  8016fc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016ff:	83 e2 1f             	and    $0x1f,%edx
  801702:	29 ca                	sub    %ecx,%edx
  801704:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801708:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80170c:	83 c0 01             	add    $0x1,%eax
  80170f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801712:	83 c7 01             	add    $0x1,%edi
  801715:	eb 9d                	jmp    8016b4 <devpipe_write+0x1c>

00801717 <devpipe_read>:
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	57                   	push   %edi
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 18             	sub    $0x18,%esp
  801720:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801723:	57                   	push   %edi
  801724:	e8 bf f6 ff ff       	call   800de8 <fd2data>
  801729:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	be 00 00 00 00       	mov    $0x0,%esi
  801733:	3b 75 10             	cmp    0x10(%ebp),%esi
  801736:	75 13                	jne    80174b <devpipe_read+0x34>
	return i;
  801738:	89 f0                	mov    %esi,%eax
  80173a:	eb 02                	jmp    80173e <devpipe_read+0x27>
				return i;
  80173c:	89 f0                	mov    %esi,%eax
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    
			sys_yield();
  801746:	e8 e1 f3 ff ff       	call   800b2c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80174b:	8b 03                	mov    (%ebx),%eax
  80174d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801750:	75 18                	jne    80176a <devpipe_read+0x53>
			if (i > 0)
  801752:	85 f6                	test   %esi,%esi
  801754:	75 e6                	jne    80173c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801756:	89 da                	mov    %ebx,%edx
  801758:	89 f8                	mov    %edi,%eax
  80175a:	e8 d4 fe ff ff       	call   801633 <_pipeisclosed>
  80175f:	85 c0                	test   %eax,%eax
  801761:	74 e3                	je     801746 <devpipe_read+0x2f>
				return 0;
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
  801768:	eb d4                	jmp    80173e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80176a:	99                   	cltd   
  80176b:	c1 ea 1b             	shr    $0x1b,%edx
  80176e:	01 d0                	add    %edx,%eax
  801770:	83 e0 1f             	and    $0x1f,%eax
  801773:	29 d0                	sub    %edx,%eax
  801775:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80177a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801780:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801783:	83 c6 01             	add    $0x1,%esi
  801786:	eb ab                	jmp    801733 <devpipe_read+0x1c>

00801788 <pipe>:
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	e8 66 f6 ff ff       	call   800dff <fd_alloc>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	0f 88 23 01 00 00    	js     8018c9 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	68 07 04 00 00       	push   $0x407
  8017ae:	ff 75 f4             	push   -0xc(%ebp)
  8017b1:	6a 00                	push   $0x0
  8017b3:	e8 93 f3 ff ff       	call   800b4b <sys_page_alloc>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	0f 88 04 01 00 00    	js     8018c9 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cb:	50                   	push   %eax
  8017cc:	e8 2e f6 ff ff       	call   800dff <fd_alloc>
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	0f 88 db 00 00 00    	js     8018b9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	68 07 04 00 00       	push   $0x407
  8017e6:	ff 75 f0             	push   -0x10(%ebp)
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 5b f3 ff ff       	call   800b4b <sys_page_alloc>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	0f 88 bc 00 00 00    	js     8018b9 <pipe+0x131>
	va = fd2data(fd0);
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	ff 75 f4             	push   -0xc(%ebp)
  801803:	e8 e0 f5 ff ff       	call   800de8 <fd2data>
  801808:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180a:	83 c4 0c             	add    $0xc,%esp
  80180d:	68 07 04 00 00       	push   $0x407
  801812:	50                   	push   %eax
  801813:	6a 00                	push   $0x0
  801815:	e8 31 f3 ff ff       	call   800b4b <sys_page_alloc>
  80181a:	89 c3                	mov    %eax,%ebx
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	0f 88 82 00 00 00    	js     8018a9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	ff 75 f0             	push   -0x10(%ebp)
  80182d:	e8 b6 f5 ff ff       	call   800de8 <fd2data>
  801832:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801839:	50                   	push   %eax
  80183a:	6a 00                	push   $0x0
  80183c:	56                   	push   %esi
  80183d:	6a 00                	push   $0x0
  80183f:	e8 4a f3 ff ff       	call   800b8e <sys_page_map>
  801844:	89 c3                	mov    %eax,%ebx
  801846:	83 c4 20             	add    $0x20,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 4e                	js     80189b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80184d:	a1 20 30 80 00       	mov    0x803020,%eax
  801852:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801855:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801861:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801864:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801869:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 f4             	push   -0xc(%ebp)
  801876:	e8 5d f5 ff ff       	call   800dd8 <fd2num>
  80187b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80187e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801880:	83 c4 04             	add    $0x4,%esp
  801883:	ff 75 f0             	push   -0x10(%ebp)
  801886:	e8 4d f5 ff ff       	call   800dd8 <fd2num>
  80188b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	bb 00 00 00 00       	mov    $0x0,%ebx
  801899:	eb 2e                	jmp    8018c9 <pipe+0x141>
	sys_page_unmap(0, va);
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	56                   	push   %esi
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 2a f3 ff ff       	call   800bd0 <sys_page_unmap>
  8018a6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	ff 75 f0             	push   -0x10(%ebp)
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 1a f3 ff ff       	call   800bd0 <sys_page_unmap>
  8018b6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	ff 75 f4             	push   -0xc(%ebp)
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 0a f3 ff ff       	call   800bd0 <sys_page_unmap>
  8018c6:	83 c4 10             	add    $0x10,%esp
}
  8018c9:	89 d8                	mov    %ebx,%eax
  8018cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5e                   	pop    %esi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <pipeisclosed>:
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	ff 75 08             	push   0x8(%ebp)
  8018df:	e8 6b f5 ff ff       	call   800e4f <fd_lookup>
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 18                	js     801903 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	ff 75 f4             	push   -0xc(%ebp)
  8018f1:	e8 f2 f4 ff ff       	call   800de8 <fd2data>
  8018f6:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8018f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fb:	e8 33 fd ff ff       	call   801633 <_pipeisclosed>
  801900:	83 c4 10             	add    $0x10,%esp
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
  80190a:	c3                   	ret    

0080190b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801911:	68 ee 22 80 00       	push   $0x8022ee
  801916:	ff 75 0c             	push   0xc(%ebp)
  801919:	e8 31 ee ff ff       	call   80074f <strcpy>
	return 0;
}
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <devcons_write>:
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	57                   	push   %edi
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801931:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801936:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80193c:	eb 2e                	jmp    80196c <devcons_write+0x47>
		m = n - tot;
  80193e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801941:	29 f3                	sub    %esi,%ebx
  801943:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801948:	39 c3                	cmp    %eax,%ebx
  80194a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80194d:	83 ec 04             	sub    $0x4,%esp
  801950:	53                   	push   %ebx
  801951:	89 f0                	mov    %esi,%eax
  801953:	03 45 0c             	add    0xc(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	57                   	push   %edi
  801958:	e8 88 ef ff ff       	call   8008e5 <memmove>
		sys_cputs(buf, m);
  80195d:	83 c4 08             	add    $0x8,%esp
  801960:	53                   	push   %ebx
  801961:	57                   	push   %edi
  801962:	e8 28 f1 ff ff       	call   800a8f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801967:	01 de                	add    %ebx,%esi
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80196f:	72 cd                	jb     80193e <devcons_write+0x19>
}
  801971:	89 f0                	mov    %esi,%eax
  801973:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5f                   	pop    %edi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <devcons_read>:
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801986:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80198a:	75 07                	jne    801993 <devcons_read+0x18>
  80198c:	eb 1f                	jmp    8019ad <devcons_read+0x32>
		sys_yield();
  80198e:	e8 99 f1 ff ff       	call   800b2c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801993:	e8 15 f1 ff ff       	call   800aad <sys_cgetc>
  801998:	85 c0                	test   %eax,%eax
  80199a:	74 f2                	je     80198e <devcons_read+0x13>
	if (c < 0)
  80199c:	78 0f                	js     8019ad <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80199e:	83 f8 04             	cmp    $0x4,%eax
  8019a1:	74 0c                	je     8019af <devcons_read+0x34>
	*(char*)vbuf = c;
  8019a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a6:	88 02                	mov    %al,(%edx)
	return 1;
  8019a8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    
		return 0;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	eb f7                	jmp    8019ad <devcons_read+0x32>

008019b6 <cputchar>:
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8019c2:	6a 01                	push   $0x1
  8019c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019c7:	50                   	push   %eax
  8019c8:	e8 c2 f0 ff ff       	call   800a8f <sys_cputs>
}
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <getchar>:
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8019d8:	6a 01                	push   $0x1
  8019da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019dd:	50                   	push   %eax
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 ce f6 ff ff       	call   8010b3 <read>
	if (r < 0)
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 06                	js     8019f2 <getchar+0x20>
	if (r < 1)
  8019ec:	74 06                	je     8019f4 <getchar+0x22>
	return c;
  8019ee:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    
		return -E_EOF;
  8019f4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8019f9:	eb f7                	jmp    8019f2 <getchar+0x20>

008019fb <iscons>:
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	ff 75 08             	push   0x8(%ebp)
  801a08:	e8 42 f4 ff ff       	call   800e4f <fd_lookup>
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 11                	js     801a25 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a17:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a1d:	39 10                	cmp    %edx,(%eax)
  801a1f:	0f 94 c0             	sete   %al
  801a22:	0f b6 c0             	movzbl %al,%eax
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <opencons>:
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	e8 c9 f3 ff ff       	call   800dff <fd_alloc>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 3a                	js     801a77 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a3d:	83 ec 04             	sub    $0x4,%esp
  801a40:	68 07 04 00 00       	push   $0x407
  801a45:	ff 75 f4             	push   -0xc(%ebp)
  801a48:	6a 00                	push   $0x0
  801a4a:	e8 fc f0 ff ff       	call   800b4b <sys_page_alloc>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 21                	js     801a77 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a59:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a64:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	50                   	push   %eax
  801a6f:	e8 64 f3 ff ff       	call   800dd8 <fd2num>
  801a74:	83 c4 10             	add    $0x10,%esp
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a7e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a81:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a87:	e8 81 f0 ff ff       	call   800b0d <sys_getenvid>
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	ff 75 0c             	push   0xc(%ebp)
  801a92:	ff 75 08             	push   0x8(%ebp)
  801a95:	56                   	push   %esi
  801a96:	50                   	push   %eax
  801a97:	68 fc 22 80 00       	push   $0x8022fc
  801a9c:	e8 d4 e6 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801aa1:	83 c4 18             	add    $0x18,%esp
  801aa4:	53                   	push   %ebx
  801aa5:	ff 75 10             	push   0x10(%ebp)
  801aa8:	e8 77 e6 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801aad:	c7 04 24 e7 22 80 00 	movl   $0x8022e7,(%esp)
  801ab4:	e8 bc e6 ff ff       	call   800175 <cprintf>
  801ab9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801abc:	cc                   	int3   
  801abd:	eb fd                	jmp    801abc <_panic+0x43>

00801abf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801acd:	85 c0                	test   %eax,%eax
  801acf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ad4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	50                   	push   %eax
  801adb:	e8 1b f2 ff ff       	call   800cfb <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	85 f6                	test   %esi,%esi
  801ae5:	74 14                	je     801afb <ipc_recv+0x3c>
  801ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 09                	js     801af9 <ipc_recv+0x3a>
  801af0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801af6:	8b 52 74             	mov    0x74(%edx),%edx
  801af9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801afb:	85 db                	test   %ebx,%ebx
  801afd:	74 14                	je     801b13 <ipc_recv+0x54>
  801aff:	ba 00 00 00 00       	mov    $0x0,%edx
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 09                	js     801b11 <ipc_recv+0x52>
  801b08:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b0e:	8b 52 78             	mov    0x78(%edx),%edx
  801b11:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 08                	js     801b1f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801b17:	a1 00 40 80 00       	mov    0x804000,%eax
  801b1c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	57                   	push   %edi
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801b38:	85 db                	test   %ebx,%ebx
  801b3a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b3f:	0f 44 d8             	cmove  %eax,%ebx
  801b42:	eb 05                	jmp    801b49 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b44:	e8 e3 ef ff ff       	call   800b2c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801b49:	ff 75 14             	push   0x14(%ebp)
  801b4c:	53                   	push   %ebx
  801b4d:	56                   	push   %esi
  801b4e:	57                   	push   %edi
  801b4f:	e8 84 f1 ff ff       	call   800cd8 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b5a:	74 e8                	je     801b44 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 08                	js     801b68 <ipc_send+0x42>
	}while (r<0);

}
  801b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b68:	50                   	push   %eax
  801b69:	68 1f 23 80 00       	push   $0x80231f
  801b6e:	6a 3d                	push   $0x3d
  801b70:	68 33 23 80 00       	push   $0x802333
  801b75:	e8 ff fe ff ff       	call   801a79 <_panic>

00801b7a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b85:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b88:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b8e:	8b 52 50             	mov    0x50(%edx),%edx
  801b91:	39 ca                	cmp    %ecx,%edx
  801b93:	74 11                	je     801ba6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b95:	83 c0 01             	add    $0x1,%eax
  801b98:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b9d:	75 e6                	jne    801b85 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba4:	eb 0b                	jmp    801bb1 <ipc_find_env+0x37>
			return envs[i].env_id;
  801ba6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ba9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bae:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	c1 ea 16             	shr    $0x16,%edx
  801bbe:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801bc5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801bca:	f6 c1 01             	test   $0x1,%cl
  801bcd:	74 1c                	je     801beb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801bcf:	c1 e8 0c             	shr    $0xc,%eax
  801bd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bd9:	a8 01                	test   $0x1,%al
  801bdb:	74 0e                	je     801beb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bdd:	c1 e8 0c             	shr    $0xc,%eax
  801be0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801be7:	ef 
  801be8:	0f b7 d2             	movzwl %dx,%edx
}
  801beb:	89 d0                	mov    %edx,%eax
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    
  801bef:	90                   	nop

00801bf0 <__udivdi3>:
  801bf0:	f3 0f 1e fb          	endbr32 
  801bf4:	55                   	push   %ebp
  801bf5:	57                   	push   %edi
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	83 ec 1c             	sub    $0x1c,%esp
  801bfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801bff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c03:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	75 19                	jne    801c28 <__udivdi3+0x38>
  801c0f:	39 f3                	cmp    %esi,%ebx
  801c11:	76 4d                	jbe    801c60 <__udivdi3+0x70>
  801c13:	31 ff                	xor    %edi,%edi
  801c15:	89 e8                	mov    %ebp,%eax
  801c17:	89 f2                	mov    %esi,%edx
  801c19:	f7 f3                	div    %ebx
  801c1b:	89 fa                	mov    %edi,%edx
  801c1d:	83 c4 1c             	add    $0x1c,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	39 f0                	cmp    %esi,%eax
  801c2a:	76 14                	jbe    801c40 <__udivdi3+0x50>
  801c2c:	31 ff                	xor    %edi,%edi
  801c2e:	31 c0                	xor    %eax,%eax
  801c30:	89 fa                	mov    %edi,%edx
  801c32:	83 c4 1c             	add    $0x1c,%esp
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5f                   	pop    %edi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    
  801c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c40:	0f bd f8             	bsr    %eax,%edi
  801c43:	83 f7 1f             	xor    $0x1f,%edi
  801c46:	75 48                	jne    801c90 <__udivdi3+0xa0>
  801c48:	39 f0                	cmp    %esi,%eax
  801c4a:	72 06                	jb     801c52 <__udivdi3+0x62>
  801c4c:	31 c0                	xor    %eax,%eax
  801c4e:	39 eb                	cmp    %ebp,%ebx
  801c50:	77 de                	ja     801c30 <__udivdi3+0x40>
  801c52:	b8 01 00 00 00       	mov    $0x1,%eax
  801c57:	eb d7                	jmp    801c30 <__udivdi3+0x40>
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 d9                	mov    %ebx,%ecx
  801c62:	85 db                	test   %ebx,%ebx
  801c64:	75 0b                	jne    801c71 <__udivdi3+0x81>
  801c66:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6b:	31 d2                	xor    %edx,%edx
  801c6d:	f7 f3                	div    %ebx
  801c6f:	89 c1                	mov    %eax,%ecx
  801c71:	31 d2                	xor    %edx,%edx
  801c73:	89 f0                	mov    %esi,%eax
  801c75:	f7 f1                	div    %ecx
  801c77:	89 c6                	mov    %eax,%esi
  801c79:	89 e8                	mov    %ebp,%eax
  801c7b:	89 f7                	mov    %esi,%edi
  801c7d:	f7 f1                	div    %ecx
  801c7f:	89 fa                	mov    %edi,%edx
  801c81:	83 c4 1c             	add    $0x1c,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 f9                	mov    %edi,%ecx
  801c92:	ba 20 00 00 00       	mov    $0x20,%edx
  801c97:	29 fa                	sub    %edi,%edx
  801c99:	d3 e0                	shl    %cl,%eax
  801c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9f:	89 d1                	mov    %edx,%ecx
  801ca1:	89 d8                	mov    %ebx,%eax
  801ca3:	d3 e8                	shr    %cl,%eax
  801ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ca9:	09 c1                	or     %eax,%ecx
  801cab:	89 f0                	mov    %esi,%eax
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f9                	mov    %edi,%ecx
  801cb3:	d3 e3                	shl    %cl,%ebx
  801cb5:	89 d1                	mov    %edx,%ecx
  801cb7:	d3 e8                	shr    %cl,%eax
  801cb9:	89 f9                	mov    %edi,%ecx
  801cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cbf:	89 eb                	mov    %ebp,%ebx
  801cc1:	d3 e6                	shl    %cl,%esi
  801cc3:	89 d1                	mov    %edx,%ecx
  801cc5:	d3 eb                	shr    %cl,%ebx
  801cc7:	09 f3                	or     %esi,%ebx
  801cc9:	89 c6                	mov    %eax,%esi
  801ccb:	89 f2                	mov    %esi,%edx
  801ccd:	89 d8                	mov    %ebx,%eax
  801ccf:	f7 74 24 08          	divl   0x8(%esp)
  801cd3:	89 d6                	mov    %edx,%esi
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	f7 64 24 0c          	mull   0xc(%esp)
  801cdb:	39 d6                	cmp    %edx,%esi
  801cdd:	72 19                	jb     801cf8 <__udivdi3+0x108>
  801cdf:	89 f9                	mov    %edi,%ecx
  801ce1:	d3 e5                	shl    %cl,%ebp
  801ce3:	39 c5                	cmp    %eax,%ebp
  801ce5:	73 04                	jae    801ceb <__udivdi3+0xfb>
  801ce7:	39 d6                	cmp    %edx,%esi
  801ce9:	74 0d                	je     801cf8 <__udivdi3+0x108>
  801ceb:	89 d8                	mov    %ebx,%eax
  801ced:	31 ff                	xor    %edi,%edi
  801cef:	e9 3c ff ff ff       	jmp    801c30 <__udivdi3+0x40>
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cfb:	31 ff                	xor    %edi,%edi
  801cfd:	e9 2e ff ff ff       	jmp    801c30 <__udivdi3+0x40>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	f3 0f 1e fb          	endbr32 
  801d14:	55                   	push   %ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 1c             	sub    $0x1c,%esp
  801d1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801d27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801d2b:	89 f0                	mov    %esi,%eax
  801d2d:	89 da                	mov    %ebx,%edx
  801d2f:	85 ff                	test   %edi,%edi
  801d31:	75 15                	jne    801d48 <__umoddi3+0x38>
  801d33:	39 dd                	cmp    %ebx,%ebp
  801d35:	76 39                	jbe    801d70 <__umoddi3+0x60>
  801d37:	f7 f5                	div    %ebp
  801d39:	89 d0                	mov    %edx,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	83 c4 1c             	add    $0x1c,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	39 df                	cmp    %ebx,%edi
  801d4a:	77 f1                	ja     801d3d <__umoddi3+0x2d>
  801d4c:	0f bd cf             	bsr    %edi,%ecx
  801d4f:	83 f1 1f             	xor    $0x1f,%ecx
  801d52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d56:	75 40                	jne    801d98 <__umoddi3+0x88>
  801d58:	39 df                	cmp    %ebx,%edi
  801d5a:	72 04                	jb     801d60 <__umoddi3+0x50>
  801d5c:	39 f5                	cmp    %esi,%ebp
  801d5e:	77 dd                	ja     801d3d <__umoddi3+0x2d>
  801d60:	89 da                	mov    %ebx,%edx
  801d62:	89 f0                	mov    %esi,%eax
  801d64:	29 e8                	sub    %ebp,%eax
  801d66:	19 fa                	sbb    %edi,%edx
  801d68:	eb d3                	jmp    801d3d <__umoddi3+0x2d>
  801d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d70:	89 e9                	mov    %ebp,%ecx
  801d72:	85 ed                	test   %ebp,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x71>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f5                	div    %ebp
  801d7f:	89 c1                	mov    %eax,%ecx
  801d81:	89 d8                	mov    %ebx,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f1                	div    %ecx
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	f7 f1                	div    %ecx
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	31 d2                	xor    %edx,%edx
  801d8f:	eb ac                	jmp    801d3d <__umoddi3+0x2d>
  801d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d98:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d9c:	ba 20 00 00 00       	mov    $0x20,%edx
  801da1:	29 c2                	sub    %eax,%edx
  801da3:	89 c1                	mov    %eax,%ecx
  801da5:	89 e8                	mov    %ebp,%eax
  801da7:	d3 e7                	shl    %cl,%edi
  801da9:	89 d1                	mov    %edx,%ecx
  801dab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801daf:	d3 e8                	shr    %cl,%eax
  801db1:	89 c1                	mov    %eax,%ecx
  801db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801db7:	09 f9                	or     %edi,%ecx
  801db9:	89 df                	mov    %ebx,%edi
  801dbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbf:	89 c1                	mov    %eax,%ecx
  801dc1:	d3 e5                	shl    %cl,%ebp
  801dc3:	89 d1                	mov    %edx,%ecx
  801dc5:	d3 ef                	shr    %cl,%edi
  801dc7:	89 c1                	mov    %eax,%ecx
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	d3 e3                	shl    %cl,%ebx
  801dcd:	89 d1                	mov    %edx,%ecx
  801dcf:	89 fa                	mov    %edi,%edx
  801dd1:	d3 e8                	shr    %cl,%eax
  801dd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dd8:	09 d8                	or     %ebx,%eax
  801dda:	f7 74 24 08          	divl   0x8(%esp)
  801dde:	89 d3                	mov    %edx,%ebx
  801de0:	d3 e6                	shl    %cl,%esi
  801de2:	f7 e5                	mul    %ebp
  801de4:	89 c7                	mov    %eax,%edi
  801de6:	89 d1                	mov    %edx,%ecx
  801de8:	39 d3                	cmp    %edx,%ebx
  801dea:	72 06                	jb     801df2 <__umoddi3+0xe2>
  801dec:	75 0e                	jne    801dfc <__umoddi3+0xec>
  801dee:	39 c6                	cmp    %eax,%esi
  801df0:	73 0a                	jae    801dfc <__umoddi3+0xec>
  801df2:	29 e8                	sub    %ebp,%eax
  801df4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801df8:	89 d1                	mov    %edx,%ecx
  801dfa:	89 c7                	mov    %eax,%edi
  801dfc:	89 f5                	mov    %esi,%ebp
  801dfe:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e02:	29 fd                	sub    %edi,%ebp
  801e04:	19 cb                	sbb    %ecx,%ebx
  801e06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e0b:	89 d8                	mov    %ebx,%eax
  801e0d:	d3 e0                	shl    %cl,%eax
  801e0f:	89 f1                	mov    %esi,%ecx
  801e11:	d3 ed                	shr    %cl,%ebp
  801e13:	d3 eb                	shr    %cl,%ebx
  801e15:	09 e8                	or     %ebp,%eax
  801e17:	89 da                	mov    %ebx,%edx
  801e19:	83 c4 1c             	add    $0x1c,%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    
