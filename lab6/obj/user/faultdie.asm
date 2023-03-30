
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
  800045:	68 00 23 80 00       	push   $0x802300
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
  80006c:	e8 2c 0d 00 00       	call   800d9d <set_pgfault_handler>
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
  8000cc:	e8 39 0f 00 00       	call   80100a <close_all>
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
  8001d7:	e8 e4 1e 00 00       	call   8020c0 <__udivdi3>
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
  800215:	e8 c6 1f 00 00       	call   8021e0 <__umoddi3>
  80021a:	83 c4 14             	add    $0x14,%esp
  80021d:	0f be 80 26 23 80 00 	movsbl 0x802326(%eax),%eax
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
  8002d7:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
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
  8003a5:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 18                	je     8003c8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003b0:	52                   	push   %edx
  8003b1:	68 79 27 80 00       	push   $0x802779
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 92 fe ff ff       	call   80024f <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c3:	e9 66 02 00 00       	jmp    80062e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003c8:	50                   	push   %eax
  8003c9:	68 3e 23 80 00       	push   $0x80233e
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
  8003f0:	b8 37 23 80 00       	mov    $0x802337,%eax
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
  800afc:	68 1f 26 80 00       	push   $0x80261f
  800b01:	6a 2a                	push   $0x2a
  800b03:	68 3c 26 80 00       	push   $0x80263c
  800b08:	e8 3a 14 00 00       	call   801f47 <_panic>

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
  800b7d:	68 1f 26 80 00       	push   $0x80261f
  800b82:	6a 2a                	push   $0x2a
  800b84:	68 3c 26 80 00       	push   $0x80263c
  800b89:	e8 b9 13 00 00       	call   801f47 <_panic>

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
  800bbf:	68 1f 26 80 00       	push   $0x80261f
  800bc4:	6a 2a                	push   $0x2a
  800bc6:	68 3c 26 80 00       	push   $0x80263c
  800bcb:	e8 77 13 00 00       	call   801f47 <_panic>

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
  800c01:	68 1f 26 80 00       	push   $0x80261f
  800c06:	6a 2a                	push   $0x2a
  800c08:	68 3c 26 80 00       	push   $0x80263c
  800c0d:	e8 35 13 00 00       	call   801f47 <_panic>

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
  800c43:	68 1f 26 80 00       	push   $0x80261f
  800c48:	6a 2a                	push   $0x2a
  800c4a:	68 3c 26 80 00       	push   $0x80263c
  800c4f:	e8 f3 12 00 00       	call   801f47 <_panic>

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
  800c85:	68 1f 26 80 00       	push   $0x80261f
  800c8a:	6a 2a                	push   $0x2a
  800c8c:	68 3c 26 80 00       	push   $0x80263c
  800c91:	e8 b1 12 00 00       	call   801f47 <_panic>

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
  800cc7:	68 1f 26 80 00       	push   $0x80261f
  800ccc:	6a 2a                	push   $0x2a
  800cce:	68 3c 26 80 00       	push   $0x80263c
  800cd3:	e8 6f 12 00 00       	call   801f47 <_panic>

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
  800d2b:	68 1f 26 80 00       	push   $0x80261f
  800d30:	6a 2a                	push   $0x2a
  800d32:	68 3c 26 80 00       	push   $0x80263c
  800d37:	e8 0b 12 00 00       	call   801f47 <_panic>

00800d3c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d4c:	89 d1                	mov    %edx,%ecx
  800d4e:	89 d3                	mov    %edx,%ebx
  800d50:	89 d7                	mov    %edx,%edi
  800d52:	89 d6                	mov    %edx,%esi
  800d54:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d71:	89 df                	mov    %ebx,%edi
  800d73:	89 de                	mov    %ebx,%esi
  800d75:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	b8 10 00 00 00       	mov    $0x10,%eax
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800da3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800daa:	74 0a                	je     800db6 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	a3 04 40 80 00       	mov    %eax,0x804004
}
  800db4:	c9                   	leave  
  800db5:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800db6:	e8 52 fd ff ff       	call   800b0d <sys_getenvid>
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	68 07 0e 00 00       	push   $0xe07
  800dc3:	68 00 f0 bf ee       	push   $0xeebff000
  800dc8:	50                   	push   %eax
  800dc9:	e8 7d fd ff ff       	call   800b4b <sys_page_alloc>
		if (r < 0) {
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	78 2c                	js     800e01 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800dd5:	e8 33 fd ff ff       	call   800b0d <sys_getenvid>
  800dda:	83 ec 08             	sub    $0x8,%esp
  800ddd:	68 13 0e 80 00       	push   $0x800e13
  800de2:	50                   	push   %eax
  800de3:	e8 ae fe ff ff       	call   800c96 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	79 bd                	jns    800dac <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800def:	50                   	push   %eax
  800df0:	68 8c 26 80 00       	push   $0x80268c
  800df5:	6a 28                	push   $0x28
  800df7:	68 c2 26 80 00       	push   $0x8026c2
  800dfc:	e8 46 11 00 00       	call   801f47 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800e01:	50                   	push   %eax
  800e02:	68 4c 26 80 00       	push   $0x80264c
  800e07:	6a 23                	push   $0x23
  800e09:	68 c2 26 80 00       	push   $0x8026c2
  800e0e:	e8 34 11 00 00       	call   801f47 <_panic>

00800e13 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e13:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e14:	a1 04 40 80 00       	mov    0x804004,%eax
	call *%eax
  800e19:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e1b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800e1e:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800e22:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e25:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800e29:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e2d:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800e2f:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800e32:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800e33:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800e36:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800e37:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800e38:	c3                   	ret    

00800e39 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e44:	c1 e8 0c             	shr    $0xc,%eax
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e59:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e68:	89 c2                	mov    %eax,%edx
  800e6a:	c1 ea 16             	shr    $0x16,%edx
  800e6d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e74:	f6 c2 01             	test   $0x1,%dl
  800e77:	74 29                	je     800ea2 <fd_alloc+0x42>
  800e79:	89 c2                	mov    %eax,%edx
  800e7b:	c1 ea 0c             	shr    $0xc,%edx
  800e7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e85:	f6 c2 01             	test   $0x1,%dl
  800e88:	74 18                	je     800ea2 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800e8a:	05 00 10 00 00       	add    $0x1000,%eax
  800e8f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e94:	75 d2                	jne    800e68 <fd_alloc+0x8>
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800e9b:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800ea0:	eb 05                	jmp    800ea7 <fd_alloc+0x47>
			return 0;
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 02                	mov    %eax,(%edx)
}
  800eac:	89 c8                	mov    %ecx,%eax
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb6:	83 f8 1f             	cmp    $0x1f,%eax
  800eb9:	77 30                	ja     800eeb <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ebb:	c1 e0 0c             	shl    $0xc,%eax
  800ebe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec3:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	74 24                	je     800ef2 <fd_lookup+0x42>
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	c1 ea 0c             	shr    $0xc,%edx
  800ed3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eda:	f6 c2 01             	test   $0x1,%dl
  800edd:	74 1a                	je     800ef9 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee2:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    
		return -E_INVAL;
  800eeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef0:	eb f7                	jmp    800ee9 <fd_lookup+0x39>
		return -E_INVAL;
  800ef2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef7:	eb f0                	jmp    800ee9 <fd_lookup+0x39>
  800ef9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efe:	eb e9                	jmp    800ee9 <fd_lookup+0x39>

00800f00 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	53                   	push   %ebx
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0f:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800f14:	39 13                	cmp    %edx,(%ebx)
  800f16:	74 37                	je     800f4f <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800f18:	83 c0 01             	add    $0x1,%eax
  800f1b:	8b 1c 85 4c 27 80 00 	mov    0x80274c(,%eax,4),%ebx
  800f22:	85 db                	test   %ebx,%ebx
  800f24:	75 ee                	jne    800f14 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f26:	a1 00 40 80 00       	mov    0x804000,%eax
  800f2b:	8b 40 48             	mov    0x48(%eax),%eax
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	52                   	push   %edx
  800f32:	50                   	push   %eax
  800f33:	68 d0 26 80 00       	push   $0x8026d0
  800f38:	e8 38 f2 ff ff       	call   800175 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800f45:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f48:	89 1a                	mov    %ebx,(%edx)
}
  800f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    
			return 0;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f54:	eb ef                	jmp    800f45 <dev_lookup+0x45>

00800f56 <fd_close>:
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 24             	sub    $0x24,%esp
  800f5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f62:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f68:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f69:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f6f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f72:	50                   	push   %eax
  800f73:	e8 38 ff ff ff       	call   800eb0 <fd_lookup>
  800f78:	89 c3                	mov    %eax,%ebx
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 05                	js     800f86 <fd_close+0x30>
	    || fd != fd2)
  800f81:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f84:	74 16                	je     800f9c <fd_close+0x46>
		return (must_exist ? r : 0);
  800f86:	89 f8                	mov    %edi,%eax
  800f88:	84 c0                	test   %al,%al
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	0f 44 d8             	cmove  %eax,%ebx
}
  800f92:	89 d8                	mov    %ebx,%eax
  800f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	ff 36                	push   (%esi)
  800fa5:	e8 56 ff ff ff       	call   800f00 <dev_lookup>
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 1a                	js     800fcd <fd_close+0x77>
		if (dev->dev_close)
  800fb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	74 0b                	je     800fcd <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	56                   	push   %esi
  800fc6:	ff d0                	call   *%eax
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	56                   	push   %esi
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 f8 fb ff ff       	call   800bd0 <sys_page_unmap>
	return r;
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	eb b5                	jmp    800f92 <fd_close+0x3c>

00800fdd <close>:

int
close(int fdnum)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 75 08             	push   0x8(%ebp)
  800fea:	e8 c1 fe ff ff       	call   800eb0 <fd_lookup>
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 02                	jns    800ff8 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    
		return fd_close(fd, 1);
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	6a 01                	push   $0x1
  800ffd:	ff 75 f4             	push   -0xc(%ebp)
  801000:	e8 51 ff ff ff       	call   800f56 <fd_close>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	eb ec                	jmp    800ff6 <close+0x19>

0080100a <close_all>:

void
close_all(void)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801011:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	53                   	push   %ebx
  80101a:	e8 be ff ff ff       	call   800fdd <close>
	for (i = 0; i < MAXFD; i++)
  80101f:	83 c3 01             	add    $0x1,%ebx
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	83 fb 20             	cmp    $0x20,%ebx
  801028:	75 ec                	jne    801016 <close_all+0xc>
}
  80102a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801038:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80103b:	50                   	push   %eax
  80103c:	ff 75 08             	push   0x8(%ebp)
  80103f:	e8 6c fe ff ff       	call   800eb0 <fd_lookup>
  801044:	89 c3                	mov    %eax,%ebx
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 7f                	js     8010cc <dup+0x9d>
		return r;
	close(newfdnum);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	ff 75 0c             	push   0xc(%ebp)
  801053:	e8 85 ff ff ff       	call   800fdd <close>

	newfd = INDEX2FD(newfdnum);
  801058:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105b:	c1 e6 0c             	shl    $0xc,%esi
  80105e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801064:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801067:	89 3c 24             	mov    %edi,(%esp)
  80106a:	e8 da fd ff ff       	call   800e49 <fd2data>
  80106f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801071:	89 34 24             	mov    %esi,(%esp)
  801074:	e8 d0 fd ff ff       	call   800e49 <fd2data>
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80107f:	89 d8                	mov    %ebx,%eax
  801081:	c1 e8 16             	shr    $0x16,%eax
  801084:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108b:	a8 01                	test   $0x1,%al
  80108d:	74 11                	je     8010a0 <dup+0x71>
  80108f:	89 d8                	mov    %ebx,%eax
  801091:	c1 e8 0c             	shr    $0xc,%eax
  801094:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109b:	f6 c2 01             	test   $0x1,%dl
  80109e:	75 36                	jne    8010d6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a0:	89 f8                	mov    %edi,%eax
  8010a2:	c1 e8 0c             	shr    $0xc,%eax
  8010a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b4:	50                   	push   %eax
  8010b5:	56                   	push   %esi
  8010b6:	6a 00                	push   $0x0
  8010b8:	57                   	push   %edi
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 ce fa ff ff       	call   800b8e <sys_page_map>
  8010c0:	89 c3                	mov    %eax,%ebx
  8010c2:	83 c4 20             	add    $0x20,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 33                	js     8010fc <dup+0xcd>
		goto err;

	return newfdnum;
  8010c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010cc:	89 d8                	mov    %ebx,%eax
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e5:	50                   	push   %eax
  8010e6:	ff 75 d4             	push   -0x2c(%ebp)
  8010e9:	6a 00                	push   $0x0
  8010eb:	53                   	push   %ebx
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 9b fa ff ff       	call   800b8e <sys_page_map>
  8010f3:	89 c3                	mov    %eax,%ebx
  8010f5:	83 c4 20             	add    $0x20,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	79 a4                	jns    8010a0 <dup+0x71>
	sys_page_unmap(0, newfd);
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	56                   	push   %esi
  801100:	6a 00                	push   $0x0
  801102:	e8 c9 fa ff ff       	call   800bd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801107:	83 c4 08             	add    $0x8,%esp
  80110a:	ff 75 d4             	push   -0x2c(%ebp)
  80110d:	6a 00                	push   $0x0
  80110f:	e8 bc fa ff ff       	call   800bd0 <sys_page_unmap>
	return r;
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	eb b3                	jmp    8010cc <dup+0x9d>

00801119 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	83 ec 18             	sub    $0x18,%esp
  801121:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801124:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	56                   	push   %esi
  801129:	e8 82 fd ff ff       	call   800eb0 <fd_lookup>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 3c                	js     801171 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801135:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	ff 33                	push   (%ebx)
  801141:	e8 ba fd ff ff       	call   800f00 <dev_lookup>
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 24                	js     801171 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114d:	8b 43 08             	mov    0x8(%ebx),%eax
  801150:	83 e0 03             	and    $0x3,%eax
  801153:	83 f8 01             	cmp    $0x1,%eax
  801156:	74 20                	je     801178 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115b:	8b 40 08             	mov    0x8(%eax),%eax
  80115e:	85 c0                	test   %eax,%eax
  801160:	74 37                	je     801199 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	ff 75 10             	push   0x10(%ebp)
  801168:	ff 75 0c             	push   0xc(%ebp)
  80116b:	53                   	push   %ebx
  80116c:	ff d0                	call   *%eax
  80116e:	83 c4 10             	add    $0x10,%esp
}
  801171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801178:	a1 00 40 80 00       	mov    0x804000,%eax
  80117d:	8b 40 48             	mov    0x48(%eax),%eax
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	56                   	push   %esi
  801184:	50                   	push   %eax
  801185:	68 11 27 80 00       	push   $0x802711
  80118a:	e8 e6 ef ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801197:	eb d8                	jmp    801171 <read+0x58>
		return -E_NOT_SUPP;
  801199:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80119e:	eb d1                	jmp    801171 <read+0x58>

008011a0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b4:	eb 02                	jmp    8011b8 <readn+0x18>
  8011b6:	01 c3                	add    %eax,%ebx
  8011b8:	39 f3                	cmp    %esi,%ebx
  8011ba:	73 21                	jae    8011dd <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	89 f0                	mov    %esi,%eax
  8011c1:	29 d8                	sub    %ebx,%eax
  8011c3:	50                   	push   %eax
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	03 45 0c             	add    0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	57                   	push   %edi
  8011cb:	e8 49 ff ff ff       	call   801119 <read>
		if (m < 0)
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 04                	js     8011db <readn+0x3b>
			return m;
		if (m == 0)
  8011d7:	75 dd                	jne    8011b6 <readn+0x16>
  8011d9:	eb 02                	jmp    8011dd <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011db:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011dd:	89 d8                	mov    %ebx,%eax
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 18             	sub    $0x18,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	53                   	push   %ebx
  8011f7:	e8 b4 fc ff ff       	call   800eb0 <fd_lookup>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 37                	js     80123a <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	ff 36                	push   (%esi)
  80120f:	e8 ec fc ff ff       	call   800f00 <dev_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 1f                	js     80123a <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80121f:	74 20                	je     801241 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801221:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801224:	8b 40 0c             	mov    0xc(%eax),%eax
  801227:	85 c0                	test   %eax,%eax
  801229:	74 37                	je     801262 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	ff 75 10             	push   0x10(%ebp)
  801231:	ff 75 0c             	push   0xc(%ebp)
  801234:	56                   	push   %esi
  801235:	ff d0                	call   *%eax
  801237:	83 c4 10             	add    $0x10,%esp
}
  80123a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801241:	a1 00 40 80 00       	mov    0x804000,%eax
  801246:	8b 40 48             	mov    0x48(%eax),%eax
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	53                   	push   %ebx
  80124d:	50                   	push   %eax
  80124e:	68 2d 27 80 00       	push   $0x80272d
  801253:	e8 1d ef ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801260:	eb d8                	jmp    80123a <write+0x53>
		return -E_NOT_SUPP;
  801262:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801267:	eb d1                	jmp    80123a <write+0x53>

00801269 <seek>:

int
seek(int fdnum, off_t offset)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	ff 75 08             	push   0x8(%ebp)
  801276:	e8 35 fc ff ff       	call   800eb0 <fd_lookup>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 0e                	js     801290 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801282:	8b 55 0c             	mov    0xc(%ebp),%edx
  801285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801288:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 18             	sub    $0x18,%esp
  80129a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	53                   	push   %ebx
  8012a2:	e8 09 fc ff ff       	call   800eb0 <fd_lookup>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 34                	js     8012e2 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 36                	push   (%esi)
  8012ba:	e8 41 fc ff ff       	call   800f00 <dev_lookup>
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	78 1c                	js     8012e2 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c6:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012ca:	74 1d                	je     8012e9 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cf:	8b 40 18             	mov    0x18(%eax),%eax
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	74 34                	je     80130a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 75 0c             	push   0xc(%ebp)
  8012dc:	56                   	push   %esi
  8012dd:	ff d0                	call   *%eax
  8012df:	83 c4 10             	add    $0x10,%esp
}
  8012e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012e9:	a1 00 40 80 00       	mov    0x804000,%eax
  8012ee:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f1:	83 ec 04             	sub    $0x4,%esp
  8012f4:	53                   	push   %ebx
  8012f5:	50                   	push   %eax
  8012f6:	68 f0 26 80 00       	push   $0x8026f0
  8012fb:	e8 75 ee ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801308:	eb d8                	jmp    8012e2 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80130a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80130f:	eb d1                	jmp    8012e2 <ftruncate+0x50>

00801311 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	83 ec 18             	sub    $0x18,%esp
  801319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	ff 75 08             	push   0x8(%ebp)
  801323:	e8 88 fb ff ff       	call   800eb0 <fd_lookup>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 49                	js     801378 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 36                	push   (%esi)
  80133b:	e8 c0 fb ff ff       	call   800f00 <dev_lookup>
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 31                	js     801378 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801347:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80134e:	74 2f                	je     80137f <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801350:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801353:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80135a:	00 00 00 
	stat->st_isdir = 0;
  80135d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801364:	00 00 00 
	stat->st_dev = dev;
  801367:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	53                   	push   %ebx
  801371:	56                   	push   %esi
  801372:	ff 50 14             	call   *0x14(%eax)
  801375:	83 c4 10             	add    $0x10,%esp
}
  801378:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    
		return -E_NOT_SUPP;
  80137f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801384:	eb f2                	jmp    801378 <fstat+0x67>

00801386 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	6a 00                	push   $0x0
  801390:	ff 75 08             	push   0x8(%ebp)
  801393:	e8 e4 01 00 00       	call   80157c <open>
  801398:	89 c3                	mov    %eax,%ebx
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 1b                	js     8013bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	ff 75 0c             	push   0xc(%ebp)
  8013a7:	50                   	push   %eax
  8013a8:	e8 64 ff ff ff       	call   801311 <fstat>
  8013ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8013af:	89 1c 24             	mov    %ebx,(%esp)
  8013b2:	e8 26 fc ff ff       	call   800fdd <close>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 f3                	mov    %esi,%ebx
}
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	89 c6                	mov    %eax,%esi
  8013cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ce:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8013d5:	74 27                	je     8013fe <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d7:	6a 07                	push   $0x7
  8013d9:	68 00 50 80 00       	push   $0x805000
  8013de:	56                   	push   %esi
  8013df:	ff 35 00 60 80 00    	push   0x806000
  8013e5:	e8 0a 0c 00 00       	call   801ff4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ea:	83 c4 0c             	add    $0xc,%esp
  8013ed:	6a 00                	push   $0x0
  8013ef:	53                   	push   %ebx
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 96 0b 00 00       	call   801f8d <ipc_recv>
}
  8013f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fa:	5b                   	pop    %ebx
  8013fb:	5e                   	pop    %esi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013fe:	83 ec 0c             	sub    $0xc,%esp
  801401:	6a 01                	push   $0x1
  801403:	e8 40 0c 00 00       	call   802048 <ipc_find_env>
  801408:	a3 00 60 80 00       	mov    %eax,0x806000
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	eb c5                	jmp    8013d7 <fsipc+0x12>

00801412 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	8b 40 0c             	mov    0xc(%eax),%eax
  80141e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801423:	8b 45 0c             	mov    0xc(%ebp),%eax
  801426:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80142b:	ba 00 00 00 00       	mov    $0x0,%edx
  801430:	b8 02 00 00 00       	mov    $0x2,%eax
  801435:	e8 8b ff ff ff       	call   8013c5 <fsipc>
}
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <devfile_flush>:
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	8b 40 0c             	mov    0xc(%eax),%eax
  801448:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	b8 06 00 00 00       	mov    $0x6,%eax
  801457:	e8 69 ff ff ff       	call   8013c5 <fsipc>
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <devfile_stat>:
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	53                   	push   %ebx
  801462:	83 ec 04             	sub    $0x4,%esp
  801465:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801468:	8b 45 08             	mov    0x8(%ebp),%eax
  80146b:	8b 40 0c             	mov    0xc(%eax),%eax
  80146e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801473:	ba 00 00 00 00       	mov    $0x0,%edx
  801478:	b8 05 00 00 00       	mov    $0x5,%eax
  80147d:	e8 43 ff ff ff       	call   8013c5 <fsipc>
  801482:	85 c0                	test   %eax,%eax
  801484:	78 2c                	js     8014b2 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	68 00 50 80 00       	push   $0x805000
  80148e:	53                   	push   %ebx
  80148f:	e8 bb f2 ff ff       	call   80074f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801494:	a1 80 50 80 00       	mov    0x805080,%eax
  801499:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80149f:	a1 84 50 80 00       	mov    0x805084,%eax
  8014a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <devfile_write>:
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 0c             	sub    $0xc,%esp
  8014bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014c5:	39 d0                	cmp    %edx,%eax
  8014c7:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8014cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014d6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014db:	50                   	push   %eax
  8014dc:	ff 75 0c             	push   0xc(%ebp)
  8014df:	68 08 50 80 00       	push   $0x805008
  8014e4:	e8 fc f3 ff ff       	call   8008e5 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8014f3:	e8 cd fe ff ff       	call   8013c5 <fsipc>
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devfile_read>:
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801502:	8b 45 08             	mov    0x8(%ebp),%eax
  801505:	8b 40 0c             	mov    0xc(%eax),%eax
  801508:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80150d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 03 00 00 00       	mov    $0x3,%eax
  80151d:	e8 a3 fe ff ff       	call   8013c5 <fsipc>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	85 c0                	test   %eax,%eax
  801526:	78 1f                	js     801547 <devfile_read+0x4d>
	assert(r <= n);
  801528:	39 f0                	cmp    %esi,%eax
  80152a:	77 24                	ja     801550 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80152c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801531:	7f 33                	jg     801566 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	50                   	push   %eax
  801537:	68 00 50 80 00       	push   $0x805000
  80153c:	ff 75 0c             	push   0xc(%ebp)
  80153f:	e8 a1 f3 ff ff       	call   8008e5 <memmove>
	return r;
  801544:	83 c4 10             	add    $0x10,%esp
}
  801547:	89 d8                	mov    %ebx,%eax
  801549:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    
	assert(r <= n);
  801550:	68 60 27 80 00       	push   $0x802760
  801555:	68 67 27 80 00       	push   $0x802767
  80155a:	6a 7c                	push   $0x7c
  80155c:	68 7c 27 80 00       	push   $0x80277c
  801561:	e8 e1 09 00 00       	call   801f47 <_panic>
	assert(r <= PGSIZE);
  801566:	68 87 27 80 00       	push   $0x802787
  80156b:	68 67 27 80 00       	push   $0x802767
  801570:	6a 7d                	push   $0x7d
  801572:	68 7c 27 80 00       	push   $0x80277c
  801577:	e8 cb 09 00 00       	call   801f47 <_panic>

0080157c <open>:
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 1c             	sub    $0x1c,%esp
  801584:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801587:	56                   	push   %esi
  801588:	e8 87 f1 ff ff       	call   800714 <strlen>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801595:	7f 6c                	jg     801603 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	e8 bd f8 ff ff       	call   800e60 <fd_alloc>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 3c                	js     8015e8 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	56                   	push   %esi
  8015b0:	68 00 50 80 00       	push   $0x805000
  8015b5:	e8 95 f1 ff ff       	call   80074f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bd:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ca:	e8 f6 fd ff ff       	call   8013c5 <fsipc>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 19                	js     8015f1 <open+0x75>
	return fd2num(fd);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	ff 75 f4             	push   -0xc(%ebp)
  8015de:	e8 56 f8 ff ff       	call   800e39 <fd2num>
  8015e3:	89 c3                	mov    %eax,%ebx
  8015e5:	83 c4 10             	add    $0x10,%esp
}
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    
		fd_close(fd, 0);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	6a 00                	push   $0x0
  8015f6:	ff 75 f4             	push   -0xc(%ebp)
  8015f9:	e8 58 f9 ff ff       	call   800f56 <fd_close>
		return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb e5                	jmp    8015e8 <open+0x6c>
		return -E_BAD_PATH;
  801603:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801608:	eb de                	jmp    8015e8 <open+0x6c>

0080160a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801610:	ba 00 00 00 00       	mov    $0x0,%edx
  801615:	b8 08 00 00 00       	mov    $0x8,%eax
  80161a:	e8 a6 fd ff ff       	call   8013c5 <fsipc>
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801627:	68 93 27 80 00       	push   $0x802793
  80162c:	ff 75 0c             	push   0xc(%ebp)
  80162f:	e8 1b f1 ff ff       	call   80074f <strcpy>
	return 0;
}
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <devsock_close>:
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	53                   	push   %ebx
  80163f:	83 ec 10             	sub    $0x10,%esp
  801642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801645:	53                   	push   %ebx
  801646:	e8 36 0a 00 00       	call   802081 <pageref>
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	83 c4 10             	add    $0x10,%esp
		return 0;
  801650:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801655:	83 fa 01             	cmp    $0x1,%edx
  801658:	74 05                	je     80165f <devsock_close+0x24>
}
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80165f:	83 ec 0c             	sub    $0xc,%esp
  801662:	ff 73 0c             	push   0xc(%ebx)
  801665:	e8 b7 02 00 00       	call   801921 <nsipc_close>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	eb eb                	jmp    80165a <devsock_close+0x1f>

0080166f <devsock_write>:
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801675:	6a 00                	push   $0x0
  801677:	ff 75 10             	push   0x10(%ebp)
  80167a:	ff 75 0c             	push   0xc(%ebp)
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	ff 70 0c             	push   0xc(%eax)
  801683:	e8 79 03 00 00       	call   801a01 <nsipc_send>
}
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <devsock_read>:
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801690:	6a 00                	push   $0x0
  801692:	ff 75 10             	push   0x10(%ebp)
  801695:	ff 75 0c             	push   0xc(%ebp)
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	ff 70 0c             	push   0xc(%eax)
  80169e:	e8 ef 02 00 00       	call   801992 <nsipc_recv>
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <fd2sockid>:
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016ae:	52                   	push   %edx
  8016af:	50                   	push   %eax
  8016b0:	e8 fb f7 ff ff       	call   800eb0 <fd_lookup>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 10                	js     8016cc <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016c5:	39 08                	cmp    %ecx,(%eax)
  8016c7:	75 05                	jne    8016ce <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016c9:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d3:	eb f7                	jmp    8016cc <fd2sockid+0x27>

008016d5 <alloc_sockfd>:
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 1c             	sub    $0x1c,%esp
  8016dd:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	e8 78 f7 ff ff       	call   800e60 <fd_alloc>
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 43                	js     801734 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016f1:	83 ec 04             	sub    $0x4,%esp
  8016f4:	68 07 04 00 00       	push   $0x407
  8016f9:	ff 75 f4             	push   -0xc(%ebp)
  8016fc:	6a 00                	push   $0x0
  8016fe:	e8 48 f4 ff ff       	call   800b4b <sys_page_alloc>
  801703:	89 c3                	mov    %eax,%ebx
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 28                	js     801734 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80170c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801715:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801721:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	50                   	push   %eax
  801728:	e8 0c f7 ff ff       	call   800e39 <fd2num>
  80172d:	89 c3                	mov    %eax,%ebx
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	eb 0c                	jmp    801740 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801734:	83 ec 0c             	sub    $0xc,%esp
  801737:	56                   	push   %esi
  801738:	e8 e4 01 00 00       	call   801921 <nsipc_close>
		return r;
  80173d:	83 c4 10             	add    $0x10,%esp
}
  801740:	89 d8                	mov    %ebx,%eax
  801742:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <accept>:
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	e8 4e ff ff ff       	call   8016a5 <fd2sockid>
  801757:	85 c0                	test   %eax,%eax
  801759:	78 1b                	js     801776 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	ff 75 10             	push   0x10(%ebp)
  801761:	ff 75 0c             	push   0xc(%ebp)
  801764:	50                   	push   %eax
  801765:	e8 0e 01 00 00       	call   801878 <nsipc_accept>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 05                	js     801776 <accept+0x2d>
	return alloc_sockfd(r);
  801771:	e8 5f ff ff ff       	call   8016d5 <alloc_sockfd>
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <bind>:
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	e8 1f ff ff ff       	call   8016a5 <fd2sockid>
  801786:	85 c0                	test   %eax,%eax
  801788:	78 12                	js     80179c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	ff 75 10             	push   0x10(%ebp)
  801790:	ff 75 0c             	push   0xc(%ebp)
  801793:	50                   	push   %eax
  801794:	e8 31 01 00 00       	call   8018ca <nsipc_bind>
  801799:	83 c4 10             	add    $0x10,%esp
}
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <shutdown>:
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	e8 f9 fe ff ff       	call   8016a5 <fd2sockid>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 0f                	js     8017bf <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	ff 75 0c             	push   0xc(%ebp)
  8017b6:	50                   	push   %eax
  8017b7:	e8 43 01 00 00       	call   8018ff <nsipc_shutdown>
  8017bc:	83 c4 10             	add    $0x10,%esp
}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <connect>:
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	e8 d6 fe ff ff       	call   8016a5 <fd2sockid>
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	78 12                	js     8017e5 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8017d3:	83 ec 04             	sub    $0x4,%esp
  8017d6:	ff 75 10             	push   0x10(%ebp)
  8017d9:	ff 75 0c             	push   0xc(%ebp)
  8017dc:	50                   	push   %eax
  8017dd:	e8 59 01 00 00       	call   80193b <nsipc_connect>
  8017e2:	83 c4 10             	add    $0x10,%esp
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <listen>:
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	e8 b0 fe ff ff       	call   8016a5 <fd2sockid>
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 0f                	js     801808 <listen+0x21>
	return nsipc_listen(r, backlog);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	ff 75 0c             	push   0xc(%ebp)
  8017ff:	50                   	push   %eax
  801800:	e8 6b 01 00 00       	call   801970 <nsipc_listen>
  801805:	83 c4 10             	add    $0x10,%esp
}
  801808:	c9                   	leave  
  801809:	c3                   	ret    

0080180a <socket>:

int
socket(int domain, int type, int protocol)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801810:	ff 75 10             	push   0x10(%ebp)
  801813:	ff 75 0c             	push   0xc(%ebp)
  801816:	ff 75 08             	push   0x8(%ebp)
  801819:	e8 41 02 00 00       	call   801a5f <nsipc_socket>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	78 05                	js     80182a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801825:	e8 ab fe ff ff       	call   8016d5 <alloc_sockfd>
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801835:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80183c:	74 26                	je     801864 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80183e:	6a 07                	push   $0x7
  801840:	68 00 70 80 00       	push   $0x807000
  801845:	53                   	push   %ebx
  801846:	ff 35 00 80 80 00    	push   0x808000
  80184c:	e8 a3 07 00 00       	call   801ff4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801851:	83 c4 0c             	add    $0xc,%esp
  801854:	6a 00                	push   $0x0
  801856:	6a 00                	push   $0x0
  801858:	6a 00                	push   $0x0
  80185a:	e8 2e 07 00 00       	call   801f8d <ipc_recv>
}
  80185f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801862:	c9                   	leave  
  801863:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	6a 02                	push   $0x2
  801869:	e8 da 07 00 00       	call   802048 <ipc_find_env>
  80186e:	a3 00 80 80 00       	mov    %eax,0x808000
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	eb c6                	jmp    80183e <nsipc+0x12>

00801878 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801888:	8b 06                	mov    (%esi),%eax
  80188a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80188f:	b8 01 00 00 00       	mov    $0x1,%eax
  801894:	e8 93 ff ff ff       	call   80182c <nsipc>
  801899:	89 c3                	mov    %eax,%ebx
  80189b:	85 c0                	test   %eax,%eax
  80189d:	79 09                	jns    8018a8 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80189f:	89 d8                	mov    %ebx,%eax
  8018a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018a8:	83 ec 04             	sub    $0x4,%esp
  8018ab:	ff 35 10 70 80 00    	push   0x807010
  8018b1:	68 00 70 80 00       	push   $0x807000
  8018b6:	ff 75 0c             	push   0xc(%ebp)
  8018b9:	e8 27 f0 ff ff       	call   8008e5 <memmove>
		*addrlen = ret->ret_addrlen;
  8018be:	a1 10 70 80 00       	mov    0x807010,%eax
  8018c3:	89 06                	mov    %eax,(%esi)
  8018c5:	83 c4 10             	add    $0x10,%esp
	return r;
  8018c8:	eb d5                	jmp    80189f <nsipc_accept+0x27>

008018ca <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018dc:	53                   	push   %ebx
  8018dd:	ff 75 0c             	push   0xc(%ebp)
  8018e0:	68 04 70 80 00       	push   $0x807004
  8018e5:	e8 fb ef ff ff       	call   8008e5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018ea:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8018f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f5:	e8 32 ff ff ff       	call   80182c <nsipc>
}
  8018fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80190d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801910:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801915:	b8 03 00 00 00       	mov    $0x3,%eax
  80191a:	e8 0d ff ff ff       	call   80182c <nsipc>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <nsipc_close>:

int
nsipc_close(int s)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80192f:	b8 04 00 00 00       	mov    $0x4,%eax
  801934:	e8 f3 fe ff ff       	call   80182c <nsipc>
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80194d:	53                   	push   %ebx
  80194e:	ff 75 0c             	push   0xc(%ebp)
  801951:	68 04 70 80 00       	push   $0x807004
  801956:	e8 8a ef ff ff       	call   8008e5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80195b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801961:	b8 05 00 00 00       	mov    $0x5,%eax
  801966:	e8 c1 fe ff ff       	call   80182c <nsipc>
}
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80197e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801981:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801986:	b8 06 00 00 00       	mov    $0x6,%eax
  80198b:	e8 9c fe ff ff       	call   80182c <nsipc>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8019a2:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8019a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ab:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019b0:	b8 07 00 00 00       	mov    $0x7,%eax
  8019b5:	e8 72 fe ff ff       	call   80182c <nsipc>
  8019ba:	89 c3                	mov    %eax,%ebx
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 22                	js     8019e2 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8019c0:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019c5:	39 c6                	cmp    %eax,%esi
  8019c7:	0f 4e c6             	cmovle %esi,%eax
  8019ca:	39 c3                	cmp    %eax,%ebx
  8019cc:	7f 1d                	jg     8019eb <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	53                   	push   %ebx
  8019d2:	68 00 70 80 00       	push   $0x807000
  8019d7:	ff 75 0c             	push   0xc(%ebp)
  8019da:	e8 06 ef ff ff       	call   8008e5 <memmove>
  8019df:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019e2:	89 d8                	mov    %ebx,%eax
  8019e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e7:	5b                   	pop    %ebx
  8019e8:	5e                   	pop    %esi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019eb:	68 9f 27 80 00       	push   $0x80279f
  8019f0:	68 67 27 80 00       	push   $0x802767
  8019f5:	6a 62                	push   $0x62
  8019f7:	68 b4 27 80 00       	push   $0x8027b4
  8019fc:	e8 46 05 00 00       	call   801f47 <_panic>

00801a01 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	53                   	push   %ebx
  801a05:	83 ec 04             	sub    $0x4,%esp
  801a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801a13:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a19:	7f 2e                	jg     801a49 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a1b:	83 ec 04             	sub    $0x4,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	ff 75 0c             	push   0xc(%ebp)
  801a22:	68 0c 70 80 00       	push   $0x80700c
  801a27:	e8 b9 ee ff ff       	call   8008e5 <memmove>
	nsipcbuf.send.req_size = size;
  801a2c:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801a32:	8b 45 14             	mov    0x14(%ebp),%eax
  801a35:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801a3a:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3f:	e8 e8 fd ff ff       	call   80182c <nsipc>
}
  801a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    
	assert(size < 1600);
  801a49:	68 c0 27 80 00       	push   $0x8027c0
  801a4e:	68 67 27 80 00       	push   $0x802767
  801a53:	6a 6d                	push   $0x6d
  801a55:	68 b4 27 80 00       	push   $0x8027b4
  801a5a:	e8 e8 04 00 00       	call   801f47 <_panic>

00801a5f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801a75:	8b 45 10             	mov    0x10(%ebp),%eax
  801a78:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801a7d:	b8 09 00 00 00       	mov    $0x9,%eax
  801a82:	e8 a5 fd ff ff       	call   80182c <nsipc>
}
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	ff 75 08             	push   0x8(%ebp)
  801a97:	e8 ad f3 ff ff       	call   800e49 <fd2data>
  801a9c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a9e:	83 c4 08             	add    $0x8,%esp
  801aa1:	68 cc 27 80 00       	push   $0x8027cc
  801aa6:	53                   	push   %ebx
  801aa7:	e8 a3 ec ff ff       	call   80074f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aac:	8b 46 04             	mov    0x4(%esi),%eax
  801aaf:	2b 06                	sub    (%esi),%eax
  801ab1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801abe:	00 00 00 
	stat->st_dev = &devpipe;
  801ac1:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ac8:	30 80 00 
	return 0;
}
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	53                   	push   %ebx
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae1:	53                   	push   %ebx
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 e7 f0 ff ff       	call   800bd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae9:	89 1c 24             	mov    %ebx,(%esp)
  801aec:	e8 58 f3 ff ff       	call   800e49 <fd2data>
  801af1:	83 c4 08             	add    $0x8,%esp
  801af4:	50                   	push   %eax
  801af5:	6a 00                	push   $0x0
  801af7:	e8 d4 f0 ff ff       	call   800bd0 <sys_page_unmap>
}
  801afc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <_pipeisclosed>:
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	57                   	push   %edi
  801b05:	56                   	push   %esi
  801b06:	53                   	push   %ebx
  801b07:	83 ec 1c             	sub    $0x1c,%esp
  801b0a:	89 c7                	mov    %eax,%edi
  801b0c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b0e:	a1 00 40 80 00       	mov    0x804000,%eax
  801b13:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	57                   	push   %edi
  801b1a:	e8 62 05 00 00       	call   802081 <pageref>
  801b1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b22:	89 34 24             	mov    %esi,(%esp)
  801b25:	e8 57 05 00 00       	call   802081 <pageref>
		nn = thisenv->env_runs;
  801b2a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b30:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	39 cb                	cmp    %ecx,%ebx
  801b38:	74 1b                	je     801b55 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b3a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b3d:	75 cf                	jne    801b0e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b3f:	8b 42 58             	mov    0x58(%edx),%eax
  801b42:	6a 01                	push   $0x1
  801b44:	50                   	push   %eax
  801b45:	53                   	push   %ebx
  801b46:	68 d3 27 80 00       	push   $0x8027d3
  801b4b:	e8 25 e6 ff ff       	call   800175 <cprintf>
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	eb b9                	jmp    801b0e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b55:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b58:	0f 94 c0             	sete   %al
  801b5b:	0f b6 c0             	movzbl %al,%eax
}
  801b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <devpipe_write>:
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	57                   	push   %edi
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 28             	sub    $0x28,%esp
  801b6f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b72:	56                   	push   %esi
  801b73:	e8 d1 f2 ff ff       	call   800e49 <fd2data>
  801b78:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	bf 00 00 00 00       	mov    $0x0,%edi
  801b82:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b85:	75 09                	jne    801b90 <devpipe_write+0x2a>
	return i;
  801b87:	89 f8                	mov    %edi,%eax
  801b89:	eb 23                	jmp    801bae <devpipe_write+0x48>
			sys_yield();
  801b8b:	e8 9c ef ff ff       	call   800b2c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b90:	8b 43 04             	mov    0x4(%ebx),%eax
  801b93:	8b 0b                	mov    (%ebx),%ecx
  801b95:	8d 51 20             	lea    0x20(%ecx),%edx
  801b98:	39 d0                	cmp    %edx,%eax
  801b9a:	72 1a                	jb     801bb6 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b9c:	89 da                	mov    %ebx,%edx
  801b9e:	89 f0                	mov    %esi,%eax
  801ba0:	e8 5c ff ff ff       	call   801b01 <_pipeisclosed>
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	74 e2                	je     801b8b <devpipe_write+0x25>
				return 0;
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bbd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc0:	89 c2                	mov    %eax,%edx
  801bc2:	c1 fa 1f             	sar    $0x1f,%edx
  801bc5:	89 d1                	mov    %edx,%ecx
  801bc7:	c1 e9 1b             	shr    $0x1b,%ecx
  801bca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bcd:	83 e2 1f             	and    $0x1f,%edx
  801bd0:	29 ca                	sub    %ecx,%edx
  801bd2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bda:	83 c0 01             	add    $0x1,%eax
  801bdd:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801be0:	83 c7 01             	add    $0x1,%edi
  801be3:	eb 9d                	jmp    801b82 <devpipe_write+0x1c>

00801be5 <devpipe_read>:
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	57                   	push   %edi
  801be9:	56                   	push   %esi
  801bea:	53                   	push   %ebx
  801beb:	83 ec 18             	sub    $0x18,%esp
  801bee:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bf1:	57                   	push   %edi
  801bf2:	e8 52 f2 ff ff       	call   800e49 <fd2data>
  801bf7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	be 00 00 00 00       	mov    $0x0,%esi
  801c01:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c04:	75 13                	jne    801c19 <devpipe_read+0x34>
	return i;
  801c06:	89 f0                	mov    %esi,%eax
  801c08:	eb 02                	jmp    801c0c <devpipe_read+0x27>
				return i;
  801c0a:	89 f0                	mov    %esi,%eax
}
  801c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    
			sys_yield();
  801c14:	e8 13 ef ff ff       	call   800b2c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c19:	8b 03                	mov    (%ebx),%eax
  801c1b:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c1e:	75 18                	jne    801c38 <devpipe_read+0x53>
			if (i > 0)
  801c20:	85 f6                	test   %esi,%esi
  801c22:	75 e6                	jne    801c0a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c24:	89 da                	mov    %ebx,%edx
  801c26:	89 f8                	mov    %edi,%eax
  801c28:	e8 d4 fe ff ff       	call   801b01 <_pipeisclosed>
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	74 e3                	je     801c14 <devpipe_read+0x2f>
				return 0;
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	eb d4                	jmp    801c0c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c38:	99                   	cltd   
  801c39:	c1 ea 1b             	shr    $0x1b,%edx
  801c3c:	01 d0                	add    %edx,%eax
  801c3e:	83 e0 1f             	and    $0x1f,%eax
  801c41:	29 d0                	sub    %edx,%eax
  801c43:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c4e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c51:	83 c6 01             	add    $0x1,%esi
  801c54:	eb ab                	jmp    801c01 <devpipe_read+0x1c>

00801c56 <pipe>:
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 f9 f1 ff ff       	call   800e60 <fd_alloc>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	0f 88 23 01 00 00    	js     801d97 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	ff 75 f4             	push   -0xc(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 c5 ee ff ff       	call   800b4b <sys_page_alloc>
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	0f 88 04 01 00 00    	js     801d97 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	e8 c1 f1 ff ff       	call   800e60 <fd_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	0f 88 db 00 00 00    	js     801d87 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cac:	83 ec 04             	sub    $0x4,%esp
  801caf:	68 07 04 00 00       	push   $0x407
  801cb4:	ff 75 f0             	push   -0x10(%ebp)
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 8d ee ff ff       	call   800b4b <sys_page_alloc>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 bc 00 00 00    	js     801d87 <pipe+0x131>
	va = fd2data(fd0);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	push   -0xc(%ebp)
  801cd1:	e8 73 f1 ff ff       	call   800e49 <fd2data>
  801cd6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd8:	83 c4 0c             	add    $0xc,%esp
  801cdb:	68 07 04 00 00       	push   $0x407
  801ce0:	50                   	push   %eax
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 63 ee ff ff       	call   800b4b <sys_page_alloc>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	0f 88 82 00 00 00    	js     801d77 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	ff 75 f0             	push   -0x10(%ebp)
  801cfb:	e8 49 f1 ff ff       	call   800e49 <fd2data>
  801d00:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d07:	50                   	push   %eax
  801d08:	6a 00                	push   $0x0
  801d0a:	56                   	push   %esi
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 7c ee ff ff       	call   800b8e <sys_page_map>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 4e                	js     801d69 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d1b:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d23:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d28:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d32:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d37:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 f4             	push   -0xc(%ebp)
  801d44:	e8 f0 f0 ff ff       	call   800e39 <fd2num>
  801d49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d4e:	83 c4 04             	add    $0x4,%esp
  801d51:	ff 75 f0             	push   -0x10(%ebp)
  801d54:	e8 e0 f0 ff ff       	call   800e39 <fd2num>
  801d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d67:	eb 2e                	jmp    801d97 <pipe+0x141>
	sys_page_unmap(0, va);
  801d69:	83 ec 08             	sub    $0x8,%esp
  801d6c:	56                   	push   %esi
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 5c ee ff ff       	call   800bd0 <sys_page_unmap>
  801d74:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d77:	83 ec 08             	sub    $0x8,%esp
  801d7a:	ff 75 f0             	push   -0x10(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 4c ee ff ff       	call   800bd0 <sys_page_unmap>
  801d84:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	ff 75 f4             	push   -0xc(%ebp)
  801d8d:	6a 00                	push   $0x0
  801d8f:	e8 3c ee ff ff       	call   800bd0 <sys_page_unmap>
  801d94:	83 c4 10             	add    $0x10,%esp
}
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <pipeisclosed>:
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da9:	50                   	push   %eax
  801daa:	ff 75 08             	push   0x8(%ebp)
  801dad:	e8 fe f0 ff ff       	call   800eb0 <fd_lookup>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 18                	js     801dd1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	ff 75 f4             	push   -0xc(%ebp)
  801dbf:	e8 85 f0 ff ff       	call   800e49 <fd2data>
  801dc4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc9:	e8 33 fd ff ff       	call   801b01 <_pipeisclosed>
  801dce:	83 c4 10             	add    $0x10,%esp
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd8:	c3                   	ret    

00801dd9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ddf:	68 eb 27 80 00       	push   $0x8027eb
  801de4:	ff 75 0c             	push   0xc(%ebp)
  801de7:	e8 63 e9 ff ff       	call   80074f <strcpy>
	return 0;
}
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devcons_write>:
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	57                   	push   %edi
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dff:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e04:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e0a:	eb 2e                	jmp    801e3a <devcons_write+0x47>
		m = n - tot;
  801e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0f:	29 f3                	sub    %esi,%ebx
  801e11:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e16:	39 c3                	cmp    %eax,%ebx
  801e18:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	53                   	push   %ebx
  801e1f:	89 f0                	mov    %esi,%eax
  801e21:	03 45 0c             	add    0xc(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	57                   	push   %edi
  801e26:	e8 ba ea ff ff       	call   8008e5 <memmove>
		sys_cputs(buf, m);
  801e2b:	83 c4 08             	add    $0x8,%esp
  801e2e:	53                   	push   %ebx
  801e2f:	57                   	push   %edi
  801e30:	e8 5a ec ff ff       	call   800a8f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e35:	01 de                	add    %ebx,%esi
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3d:	72 cd                	jb     801e0c <devcons_write+0x19>
}
  801e3f:	89 f0                	mov    %esi,%eax
  801e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <devcons_read>:
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 08             	sub    $0x8,%esp
  801e4f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e58:	75 07                	jne    801e61 <devcons_read+0x18>
  801e5a:	eb 1f                	jmp    801e7b <devcons_read+0x32>
		sys_yield();
  801e5c:	e8 cb ec ff ff       	call   800b2c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e61:	e8 47 ec ff ff       	call   800aad <sys_cgetc>
  801e66:	85 c0                	test   %eax,%eax
  801e68:	74 f2                	je     801e5c <devcons_read+0x13>
	if (c < 0)
  801e6a:	78 0f                	js     801e7b <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e6c:	83 f8 04             	cmp    $0x4,%eax
  801e6f:	74 0c                	je     801e7d <devcons_read+0x34>
	*(char*)vbuf = c;
  801e71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e74:	88 02                	mov    %al,(%edx)
	return 1;
  801e76:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    
		return 0;
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	eb f7                	jmp    801e7b <devcons_read+0x32>

00801e84 <cputchar>:
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e90:	6a 01                	push   $0x1
  801e92:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	e8 f4 eb ff ff       	call   800a8f <sys_cputs>
}
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <getchar>:
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ea6:	6a 01                	push   $0x1
  801ea8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	6a 00                	push   $0x0
  801eae:	e8 66 f2 ff ff       	call   801119 <read>
	if (r < 0)
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 06                	js     801ec0 <getchar+0x20>
	if (r < 1)
  801eba:	74 06                	je     801ec2 <getchar+0x22>
	return c;
  801ebc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    
		return -E_EOF;
  801ec2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ec7:	eb f7                	jmp    801ec0 <getchar+0x20>

00801ec9 <iscons>:
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ecf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed2:	50                   	push   %eax
  801ed3:	ff 75 08             	push   0x8(%ebp)
  801ed6:	e8 d5 ef ff ff       	call   800eb0 <fd_lookup>
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 11                	js     801ef3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eeb:	39 10                	cmp    %edx,(%eax)
  801eed:	0f 94 c0             	sete   %al
  801ef0:	0f b6 c0             	movzbl %al,%eax
}
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <opencons>:
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	e8 5c ef ff ff       	call   800e60 <fd_alloc>
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 3a                	js     801f45 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f0b:	83 ec 04             	sub    $0x4,%esp
  801f0e:	68 07 04 00 00       	push   $0x407
  801f13:	ff 75 f4             	push   -0xc(%ebp)
  801f16:	6a 00                	push   $0x0
  801f18:	e8 2e ec ff ff       	call   800b4b <sys_page_alloc>
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 21                	js     801f45 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f27:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f2d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	50                   	push   %eax
  801f3d:	e8 f7 ee ff ff       	call   800e39 <fd2num>
  801f42:	83 c4 10             	add    $0x10,%esp
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f4c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f4f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f55:	e8 b3 eb ff ff       	call   800b0d <sys_getenvid>
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	ff 75 0c             	push   0xc(%ebp)
  801f60:	ff 75 08             	push   0x8(%ebp)
  801f63:	56                   	push   %esi
  801f64:	50                   	push   %eax
  801f65:	68 f8 27 80 00       	push   $0x8027f8
  801f6a:	e8 06 e2 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f6f:	83 c4 18             	add    $0x18,%esp
  801f72:	53                   	push   %ebx
  801f73:	ff 75 10             	push   0x10(%ebp)
  801f76:	e8 a9 e1 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801f7b:	c7 04 24 e4 27 80 00 	movl   $0x8027e4,(%esp)
  801f82:	e8 ee e1 ff ff       	call   800175 <cprintf>
  801f87:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f8a:	cc                   	int3   
  801f8b:	eb fd                	jmp    801f8a <_panic+0x43>

00801f8d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	56                   	push   %esi
  801f91:	53                   	push   %ebx
  801f92:	8b 75 08             	mov    0x8(%ebp),%esi
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fa2:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801fa5:	83 ec 0c             	sub    $0xc,%esp
  801fa8:	50                   	push   %eax
  801fa9:	e8 4d ed ff ff       	call   800cfb <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 f6                	test   %esi,%esi
  801fb3:	74 14                	je     801fc9 <ipc_recv+0x3c>
  801fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	78 09                	js     801fc7 <ipc_recv+0x3a>
  801fbe:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fc4:	8b 52 74             	mov    0x74(%edx),%edx
  801fc7:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801fc9:	85 db                	test   %ebx,%ebx
  801fcb:	74 14                	je     801fe1 <ipc_recv+0x54>
  801fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 09                	js     801fdf <ipc_recv+0x52>
  801fd6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fdc:	8b 52 78             	mov    0x78(%edx),%edx
  801fdf:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 08                	js     801fed <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801fe5:	a1 00 40 80 00       	mov    0x804000,%eax
  801fea:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	83 ec 0c             	sub    $0xc,%esp
  801ffd:	8b 7d 08             	mov    0x8(%ebp),%edi
  802000:	8b 75 0c             	mov    0xc(%ebp),%esi
  802003:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802006:	85 db                	test   %ebx,%ebx
  802008:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80200d:	0f 44 d8             	cmove  %eax,%ebx
  802010:	eb 05                	jmp    802017 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802012:	e8 15 eb ff ff       	call   800b2c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802017:	ff 75 14             	push   0x14(%ebp)
  80201a:	53                   	push   %ebx
  80201b:	56                   	push   %esi
  80201c:	57                   	push   %edi
  80201d:	e8 b6 ec ff ff       	call   800cd8 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802028:	74 e8                	je     802012 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80202a:	85 c0                	test   %eax,%eax
  80202c:	78 08                	js     802036 <ipc_send+0x42>
	}while (r<0);

}
  80202e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802036:	50                   	push   %eax
  802037:	68 1b 28 80 00       	push   $0x80281b
  80203c:	6a 3d                	push   $0x3d
  80203e:	68 2f 28 80 00       	push   $0x80282f
  802043:	e8 ff fe ff ff       	call   801f47 <_panic>

00802048 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80204e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802053:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802056:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80205c:	8b 52 50             	mov    0x50(%edx),%edx
  80205f:	39 ca                	cmp    %ecx,%edx
  802061:	74 11                	je     802074 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802063:	83 c0 01             	add    $0x1,%eax
  802066:	3d 00 04 00 00       	cmp    $0x400,%eax
  80206b:	75 e6                	jne    802053 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
  802072:	eb 0b                	jmp    80207f <ipc_find_env+0x37>
			return envs[i].env_id;
  802074:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802077:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80207c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    

00802081 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802087:	89 c2                	mov    %eax,%edx
  802089:	c1 ea 16             	shr    $0x16,%edx
  80208c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802093:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802098:	f6 c1 01             	test   $0x1,%cl
  80209b:	74 1c                	je     8020b9 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80209d:	c1 e8 0c             	shr    $0xc,%eax
  8020a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020a7:	a8 01                	test   $0x1,%al
  8020a9:	74 0e                	je     8020b9 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ab:	c1 e8 0c             	shr    $0xc,%eax
  8020ae:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020b5:	ef 
  8020b6:	0f b7 d2             	movzwl %dx,%edx
}
  8020b9:	89 d0                	mov    %edx,%eax
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__udivdi3>:
  8020c0:	f3 0f 1e fb          	endbr32 
  8020c4:	55                   	push   %ebp
  8020c5:	57                   	push   %edi
  8020c6:	56                   	push   %esi
  8020c7:	53                   	push   %ebx
  8020c8:	83 ec 1c             	sub    $0x1c,%esp
  8020cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	75 19                	jne    8020f8 <__udivdi3+0x38>
  8020df:	39 f3                	cmp    %esi,%ebx
  8020e1:	76 4d                	jbe    802130 <__udivdi3+0x70>
  8020e3:	31 ff                	xor    %edi,%edi
  8020e5:	89 e8                	mov    %ebp,%eax
  8020e7:	89 f2                	mov    %esi,%edx
  8020e9:	f7 f3                	div    %ebx
  8020eb:	89 fa                	mov    %edi,%edx
  8020ed:	83 c4 1c             	add    $0x1c,%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	8d 76 00             	lea    0x0(%esi),%esi
  8020f8:	39 f0                	cmp    %esi,%eax
  8020fa:	76 14                	jbe    802110 <__udivdi3+0x50>
  8020fc:	31 ff                	xor    %edi,%edi
  8020fe:	31 c0                	xor    %eax,%eax
  802100:	89 fa                	mov    %edi,%edx
  802102:	83 c4 1c             	add    $0x1c,%esp
  802105:	5b                   	pop    %ebx
  802106:	5e                   	pop    %esi
  802107:	5f                   	pop    %edi
  802108:	5d                   	pop    %ebp
  802109:	c3                   	ret    
  80210a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802110:	0f bd f8             	bsr    %eax,%edi
  802113:	83 f7 1f             	xor    $0x1f,%edi
  802116:	75 48                	jne    802160 <__udivdi3+0xa0>
  802118:	39 f0                	cmp    %esi,%eax
  80211a:	72 06                	jb     802122 <__udivdi3+0x62>
  80211c:	31 c0                	xor    %eax,%eax
  80211e:	39 eb                	cmp    %ebp,%ebx
  802120:	77 de                	ja     802100 <__udivdi3+0x40>
  802122:	b8 01 00 00 00       	mov    $0x1,%eax
  802127:	eb d7                	jmp    802100 <__udivdi3+0x40>
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d9                	mov    %ebx,%ecx
  802132:	85 db                	test   %ebx,%ebx
  802134:	75 0b                	jne    802141 <__udivdi3+0x81>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f3                	div    %ebx
  80213f:	89 c1                	mov    %eax,%ecx
  802141:	31 d2                	xor    %edx,%edx
  802143:	89 f0                	mov    %esi,%eax
  802145:	f7 f1                	div    %ecx
  802147:	89 c6                	mov    %eax,%esi
  802149:	89 e8                	mov    %ebp,%eax
  80214b:	89 f7                	mov    %esi,%edi
  80214d:	f7 f1                	div    %ecx
  80214f:	89 fa                	mov    %edi,%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 f9                	mov    %edi,%ecx
  802162:	ba 20 00 00 00       	mov    $0x20,%edx
  802167:	29 fa                	sub    %edi,%edx
  802169:	d3 e0                	shl    %cl,%eax
  80216b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216f:	89 d1                	mov    %edx,%ecx
  802171:	89 d8                	mov    %ebx,%eax
  802173:	d3 e8                	shr    %cl,%eax
  802175:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802179:	09 c1                	or     %eax,%ecx
  80217b:	89 f0                	mov    %esi,%eax
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f9                	mov    %edi,%ecx
  802183:	d3 e3                	shl    %cl,%ebx
  802185:	89 d1                	mov    %edx,%ecx
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 f9                	mov    %edi,%ecx
  80218b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80218f:	89 eb                	mov    %ebp,%ebx
  802191:	d3 e6                	shl    %cl,%esi
  802193:	89 d1                	mov    %edx,%ecx
  802195:	d3 eb                	shr    %cl,%ebx
  802197:	09 f3                	or     %esi,%ebx
  802199:	89 c6                	mov    %eax,%esi
  80219b:	89 f2                	mov    %esi,%edx
  80219d:	89 d8                	mov    %ebx,%eax
  80219f:	f7 74 24 08          	divl   0x8(%esp)
  8021a3:	89 d6                	mov    %edx,%esi
  8021a5:	89 c3                	mov    %eax,%ebx
  8021a7:	f7 64 24 0c          	mull   0xc(%esp)
  8021ab:	39 d6                	cmp    %edx,%esi
  8021ad:	72 19                	jb     8021c8 <__udivdi3+0x108>
  8021af:	89 f9                	mov    %edi,%ecx
  8021b1:	d3 e5                	shl    %cl,%ebp
  8021b3:	39 c5                	cmp    %eax,%ebp
  8021b5:	73 04                	jae    8021bb <__udivdi3+0xfb>
  8021b7:	39 d6                	cmp    %edx,%esi
  8021b9:	74 0d                	je     8021c8 <__udivdi3+0x108>
  8021bb:	89 d8                	mov    %ebx,%eax
  8021bd:	31 ff                	xor    %edi,%edi
  8021bf:	e9 3c ff ff ff       	jmp    802100 <__udivdi3+0x40>
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021cb:	31 ff                	xor    %edi,%edi
  8021cd:	e9 2e ff ff ff       	jmp    802100 <__udivdi3+0x40>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	f3 0f 1e fb          	endbr32 
  8021e4:	55                   	push   %ebp
  8021e5:	57                   	push   %edi
  8021e6:	56                   	push   %esi
  8021e7:	53                   	push   %ebx
  8021e8:	83 ec 1c             	sub    $0x1c,%esp
  8021eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021fb:	89 f0                	mov    %esi,%eax
  8021fd:	89 da                	mov    %ebx,%edx
  8021ff:	85 ff                	test   %edi,%edi
  802201:	75 15                	jne    802218 <__umoddi3+0x38>
  802203:	39 dd                	cmp    %ebx,%ebp
  802205:	76 39                	jbe    802240 <__umoddi3+0x60>
  802207:	f7 f5                	div    %ebp
  802209:	89 d0                	mov    %edx,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	83 c4 1c             	add    $0x1c,%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    
  802215:	8d 76 00             	lea    0x0(%esi),%esi
  802218:	39 df                	cmp    %ebx,%edi
  80221a:	77 f1                	ja     80220d <__umoddi3+0x2d>
  80221c:	0f bd cf             	bsr    %edi,%ecx
  80221f:	83 f1 1f             	xor    $0x1f,%ecx
  802222:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802226:	75 40                	jne    802268 <__umoddi3+0x88>
  802228:	39 df                	cmp    %ebx,%edi
  80222a:	72 04                	jb     802230 <__umoddi3+0x50>
  80222c:	39 f5                	cmp    %esi,%ebp
  80222e:	77 dd                	ja     80220d <__umoddi3+0x2d>
  802230:	89 da                	mov    %ebx,%edx
  802232:	89 f0                	mov    %esi,%eax
  802234:	29 e8                	sub    %ebp,%eax
  802236:	19 fa                	sbb    %edi,%edx
  802238:	eb d3                	jmp    80220d <__umoddi3+0x2d>
  80223a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802240:	89 e9                	mov    %ebp,%ecx
  802242:	85 ed                	test   %ebp,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x71>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f5                	div    %ebp
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	89 d8                	mov    %ebx,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f1                	div    %ecx
  802257:	89 f0                	mov    %esi,%eax
  802259:	f7 f1                	div    %ecx
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	31 d2                	xor    %edx,%edx
  80225f:	eb ac                	jmp    80220d <__umoddi3+0x2d>
  802261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802268:	8b 44 24 04          	mov    0x4(%esp),%eax
  80226c:	ba 20 00 00 00       	mov    $0x20,%edx
  802271:	29 c2                	sub    %eax,%edx
  802273:	89 c1                	mov    %eax,%ecx
  802275:	89 e8                	mov    %ebp,%eax
  802277:	d3 e7                	shl    %cl,%edi
  802279:	89 d1                	mov    %edx,%ecx
  80227b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80227f:	d3 e8                	shr    %cl,%eax
  802281:	89 c1                	mov    %eax,%ecx
  802283:	8b 44 24 04          	mov    0x4(%esp),%eax
  802287:	09 f9                	or     %edi,%ecx
  802289:	89 df                	mov    %ebx,%edi
  80228b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	d3 e5                	shl    %cl,%ebp
  802293:	89 d1                	mov    %edx,%ecx
  802295:	d3 ef                	shr    %cl,%edi
  802297:	89 c1                	mov    %eax,%ecx
  802299:	89 f0                	mov    %esi,%eax
  80229b:	d3 e3                	shl    %cl,%ebx
  80229d:	89 d1                	mov    %edx,%ecx
  80229f:	89 fa                	mov    %edi,%edx
  8022a1:	d3 e8                	shr    %cl,%eax
  8022a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022a8:	09 d8                	or     %ebx,%eax
  8022aa:	f7 74 24 08          	divl   0x8(%esp)
  8022ae:	89 d3                	mov    %edx,%ebx
  8022b0:	d3 e6                	shl    %cl,%esi
  8022b2:	f7 e5                	mul    %ebp
  8022b4:	89 c7                	mov    %eax,%edi
  8022b6:	89 d1                	mov    %edx,%ecx
  8022b8:	39 d3                	cmp    %edx,%ebx
  8022ba:	72 06                	jb     8022c2 <__umoddi3+0xe2>
  8022bc:	75 0e                	jne    8022cc <__umoddi3+0xec>
  8022be:	39 c6                	cmp    %eax,%esi
  8022c0:	73 0a                	jae    8022cc <__umoddi3+0xec>
  8022c2:	29 e8                	sub    %ebp,%eax
  8022c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022c8:	89 d1                	mov    %edx,%ecx
  8022ca:	89 c7                	mov    %eax,%edi
  8022cc:	89 f5                	mov    %esi,%ebp
  8022ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022d2:	29 fd                	sub    %edi,%ebp
  8022d4:	19 cb                	sbb    %ecx,%ebx
  8022d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022db:	89 d8                	mov    %ebx,%eax
  8022dd:	d3 e0                	shl    %cl,%eax
  8022df:	89 f1                	mov    %esi,%ecx
  8022e1:	d3 ed                	shr    %cl,%ebp
  8022e3:	d3 eb                	shr    %cl,%ebx
  8022e5:	09 e8                	or     %ebp,%eax
  8022e7:	89 da                	mov    %ebx,%edx
  8022e9:	83 c4 1c             	add    $0x1c,%esp
  8022ec:	5b                   	pop    %ebx
  8022ed:	5e                   	pop    %esi
  8022ee:	5f                   	pop    %edi
  8022ef:	5d                   	pop    %ebp
  8022f0:	c3                   	ret    
