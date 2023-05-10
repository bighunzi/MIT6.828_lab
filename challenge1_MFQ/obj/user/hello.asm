
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
  800039:	68 60 22 80 00       	push   $0x802260
  80003e:	e8 13 01 00 00       	call   800156 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 00 40 80 00       	mov    0x804000,%eax
  800048:	8b 40 58             	mov    0x58(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 22 80 00       	push   $0x80226e
  800054:	e8 fd 00 00 00       	call   800156 <cprintf>
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
  800069:	e8 80 0a 00 00       	call   800aee <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 0a 00 00 00       	call   8000a7 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ad:	e8 9d 0e 00 00       	call   800f4f <close_all>
	sys_env_destroy(0);
  8000b2:	83 ec 0c             	sub    $0xc,%esp
  8000b5:	6a 00                	push   $0x0
  8000b7:	e8 f1 09 00 00       	call   800aad <sys_env_destroy>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 04             	sub    $0x4,%esp
  8000c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cb:	8b 13                	mov    (%ebx),%edx
  8000cd:	8d 42 01             	lea    0x1(%edx),%eax
  8000d0:	89 03                	mov    %eax,(%ebx)
  8000d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000de:	74 09                	je     8000e9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e9:	83 ec 08             	sub    $0x8,%esp
  8000ec:	68 ff 00 00 00       	push   $0xff
  8000f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f4:	50                   	push   %eax
  8000f5:	e8 76 09 00 00       	call   800a70 <sys_cputs>
		b->idx = 0;
  8000fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	eb db                	jmp    8000e0 <putch+0x1f>

00800105 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800115:	00 00 00 
	b.cnt = 0;
  800118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800122:	ff 75 0c             	push   0xc(%ebp)
  800125:	ff 75 08             	push   0x8(%ebp)
  800128:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	68 c1 00 80 00       	push   $0x8000c1
  800134:	e8 14 01 00 00       	call   80024d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800139:	83 c4 08             	add    $0x8,%esp
  80013c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800148:	50                   	push   %eax
  800149:	e8 22 09 00 00       	call   800a70 <sys_cputs>

	return b.cnt;
}
  80014e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015f:	50                   	push   %eax
  800160:	ff 75 08             	push   0x8(%ebp)
  800163:	e8 9d ff ff ff       	call   800105 <vcprintf>
	va_end(ap);

	return cnt;
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 1c             	sub    $0x1c,%esp
  800173:	89 c7                	mov    %eax,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 d1                	mov    %edx,%ecx
  80017f:	89 c2                	mov    %eax,%edx
  800181:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800184:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800187:	8b 45 10             	mov    0x10(%ebp),%eax
  80018a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800190:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800197:	39 c2                	cmp    %eax,%edx
  800199:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80019c:	72 3e                	jb     8001dc <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 18             	push   0x18(%ebp)
  8001a4:	83 eb 01             	sub    $0x1,%ebx
  8001a7:	53                   	push   %ebx
  8001a8:	50                   	push   %eax
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	ff 75 e4             	push   -0x1c(%ebp)
  8001af:	ff 75 e0             	push   -0x20(%ebp)
  8001b2:	ff 75 dc             	push   -0x24(%ebp)
  8001b5:	ff 75 d8             	push   -0x28(%ebp)
  8001b8:	e8 63 1e 00 00       	call   802020 <__udivdi3>
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	52                   	push   %edx
  8001c1:	50                   	push   %eax
  8001c2:	89 f2                	mov    %esi,%edx
  8001c4:	89 f8                	mov    %edi,%eax
  8001c6:	e8 9f ff ff ff       	call   80016a <printnum>
  8001cb:	83 c4 20             	add    $0x20,%esp
  8001ce:	eb 13                	jmp    8001e3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 18             	push   0x18(%ebp)
  8001d7:	ff d7                	call   *%edi
  8001d9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	85 db                	test   %ebx,%ebx
  8001e1:	7f ed                	jg     8001d0 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	56                   	push   %esi
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	ff 75 e4             	push   -0x1c(%ebp)
  8001ed:	ff 75 e0             	push   -0x20(%ebp)
  8001f0:	ff 75 dc             	push   -0x24(%ebp)
  8001f3:	ff 75 d8             	push   -0x28(%ebp)
  8001f6:	e8 45 1f 00 00       	call   802140 <__umoddi3>
  8001fb:	83 c4 14             	add    $0x14,%esp
  8001fe:	0f be 80 8f 22 80 00 	movsbl 0x80228f(%eax),%eax
  800205:	50                   	push   %eax
  800206:	ff d7                	call   *%edi
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800219:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021d:	8b 10                	mov    (%eax),%edx
  80021f:	3b 50 04             	cmp    0x4(%eax),%edx
  800222:	73 0a                	jae    80022e <sprintputch+0x1b>
		*b->buf++ = ch;
  800224:	8d 4a 01             	lea    0x1(%edx),%ecx
  800227:	89 08                	mov    %ecx,(%eax)
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	88 02                	mov    %al,(%edx)
}
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <printfmt>:
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800236:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800239:	50                   	push   %eax
  80023a:	ff 75 10             	push   0x10(%ebp)
  80023d:	ff 75 0c             	push   0xc(%ebp)
  800240:	ff 75 08             	push   0x8(%ebp)
  800243:	e8 05 00 00 00       	call   80024d <vprintfmt>
}
  800248:	83 c4 10             	add    $0x10,%esp
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <vprintfmt>:
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	57                   	push   %edi
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 3c             	sub    $0x3c,%esp
  800256:	8b 75 08             	mov    0x8(%ebp),%esi
  800259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025f:	eb 0a                	jmp    80026b <vprintfmt+0x1e>
			putch(ch, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	53                   	push   %ebx
  800265:	50                   	push   %eax
  800266:	ff d6                	call   *%esi
  800268:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80026b:	83 c7 01             	add    $0x1,%edi
  80026e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800272:	83 f8 25             	cmp    $0x25,%eax
  800275:	74 0c                	je     800283 <vprintfmt+0x36>
			if (ch == '\0')
  800277:	85 c0                	test   %eax,%eax
  800279:	75 e6                	jne    800261 <vprintfmt+0x14>
}
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    
		padc = ' ';
  800283:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800287:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800295:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80029c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a1:	8d 47 01             	lea    0x1(%edi),%eax
  8002a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a7:	0f b6 17             	movzbl (%edi),%edx
  8002aa:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ad:	3c 55                	cmp    $0x55,%al
  8002af:	0f 87 bb 03 00 00    	ja     800670 <vprintfmt+0x423>
  8002b5:	0f b6 c0             	movzbl %al,%eax
  8002b8:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8002bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c6:	eb d9                	jmp    8002a1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002cb:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002cf:	eb d0                	jmp    8002a1 <vprintfmt+0x54>
  8002d1:	0f b6 d2             	movzbl %dl,%edx
  8002d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8002dc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ec:	83 f9 09             	cmp    $0x9,%ecx
  8002ef:	77 55                	ja     800346 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f4:	eb e9                	jmp    8002df <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8b 00                	mov    (%eax),%eax
  8002fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800301:	8d 40 04             	lea    0x4(%eax),%eax
  800304:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80030a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030e:	79 91                	jns    8002a1 <vprintfmt+0x54>
				width = precision, precision = -1;
  800310:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800313:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800316:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031d:	eb 82                	jmp    8002a1 <vprintfmt+0x54>
  80031f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800322:	85 d2                	test   %edx,%edx
  800324:	b8 00 00 00 00       	mov    $0x0,%eax
  800329:	0f 49 c2             	cmovns %edx,%eax
  80032c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800332:	e9 6a ff ff ff       	jmp    8002a1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80033a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800341:	e9 5b ff ff ff       	jmp    8002a1 <vprintfmt+0x54>
  800346:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800349:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034c:	eb bc                	jmp    80030a <vprintfmt+0xbd>
			lflag++;
  80034e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800354:	e9 48 ff ff ff       	jmp    8002a1 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 78 04             	lea    0x4(%eax),%edi
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	53                   	push   %ebx
  800363:	ff 30                	push   (%eax)
  800365:	ff d6                	call   *%esi
			break;
  800367:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80036a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036d:	e9 9d 02 00 00       	jmp    80060f <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 78 04             	lea    0x4(%eax),%edi
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	89 d0                	mov    %edx,%eax
  80037c:	f7 d8                	neg    %eax
  80037e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800381:	83 f8 0f             	cmp    $0xf,%eax
  800384:	7f 23                	jg     8003a9 <vprintfmt+0x15c>
  800386:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80038d:	85 d2                	test   %edx,%edx
  80038f:	74 18                	je     8003a9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800391:	52                   	push   %edx
  800392:	68 75 26 80 00       	push   $0x802675
  800397:	53                   	push   %ebx
  800398:	56                   	push   %esi
  800399:	e8 92 fe ff ff       	call   800230 <printfmt>
  80039e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a4:	e9 66 02 00 00       	jmp    80060f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003a9:	50                   	push   %eax
  8003aa:	68 a7 22 80 00       	push   $0x8022a7
  8003af:	53                   	push   %ebx
  8003b0:	56                   	push   %esi
  8003b1:	e8 7a fe ff ff       	call   800230 <printfmt>
  8003b6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003bc:	e9 4e 02 00 00       	jmp    80060f <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	83 c0 04             	add    $0x4,%eax
  8003c7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003cf:	85 d2                	test   %edx,%edx
  8003d1:	b8 a0 22 80 00       	mov    $0x8022a0,%eax
  8003d6:	0f 45 c2             	cmovne %edx,%eax
  8003d9:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e0:	7e 06                	jle    8003e8 <vprintfmt+0x19b>
  8003e2:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e6:	75 0d                	jne    8003f5 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003eb:	89 c7                	mov    %eax,%edi
  8003ed:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f3:	eb 55                	jmp    80044a <vprintfmt+0x1fd>
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	ff 75 d8             	push   -0x28(%ebp)
  8003fb:	ff 75 cc             	push   -0x34(%ebp)
  8003fe:	e8 0a 03 00 00       	call   80070d <strnlen>
  800403:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800406:	29 c1                	sub    %eax,%ecx
  800408:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80040b:	83 c4 10             	add    $0x10,%esp
  80040e:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800410:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	eb 0f                	jmp    800428 <vprintfmt+0x1db>
					putch(padc, putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	53                   	push   %ebx
  80041d:	ff 75 e0             	push   -0x20(%ebp)
  800420:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800422:	83 ef 01             	sub    $0x1,%edi
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	85 ff                	test   %edi,%edi
  80042a:	7f ed                	jg     800419 <vprintfmt+0x1cc>
  80042c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	0f 49 c2             	cmovns %edx,%eax
  800439:	29 c2                	sub    %eax,%edx
  80043b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043e:	eb a8                	jmp    8003e8 <vprintfmt+0x19b>
					putch(ch, putdat);
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	52                   	push   %edx
  800445:	ff d6                	call   *%esi
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044f:	83 c7 01             	add    $0x1,%edi
  800452:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800456:	0f be d0             	movsbl %al,%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	74 4b                	je     8004a8 <vprintfmt+0x25b>
  80045d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800461:	78 06                	js     800469 <vprintfmt+0x21c>
  800463:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800467:	78 1e                	js     800487 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800469:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046d:	74 d1                	je     800440 <vprintfmt+0x1f3>
  80046f:	0f be c0             	movsbl %al,%eax
  800472:	83 e8 20             	sub    $0x20,%eax
  800475:	83 f8 5e             	cmp    $0x5e,%eax
  800478:	76 c6                	jbe    800440 <vprintfmt+0x1f3>
					putch('?', putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	6a 3f                	push   $0x3f
  800480:	ff d6                	call   *%esi
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	eb c3                	jmp    80044a <vprintfmt+0x1fd>
  800487:	89 cf                	mov    %ecx,%edi
  800489:	eb 0e                	jmp    800499 <vprintfmt+0x24c>
				putch(' ', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	6a 20                	push   $0x20
  800491:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800493:	83 ef 01             	sub    $0x1,%edi
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	85 ff                	test   %edi,%edi
  80049b:	7f ee                	jg     80048b <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a3:	e9 67 01 00 00       	jmp    80060f <vprintfmt+0x3c2>
  8004a8:	89 cf                	mov    %ecx,%edi
  8004aa:	eb ed                	jmp    800499 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004ac:	83 f9 01             	cmp    $0x1,%ecx
  8004af:	7f 1b                	jg     8004cc <vprintfmt+0x27f>
	else if (lflag)
  8004b1:	85 c9                	test   %ecx,%ecx
  8004b3:	74 63                	je     800518 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bd:	99                   	cltd   
  8004be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 40 04             	lea    0x4(%eax),%eax
  8004c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ca:	eb 17                	jmp    8004e3 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8b 50 04             	mov    0x4(%eax),%edx
  8004d2:	8b 00                	mov    (%eax),%eax
  8004d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 40 08             	lea    0x8(%eax),%eax
  8004e0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e9:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004ee:	85 c9                	test   %ecx,%ecx
  8004f0:	0f 89 ff 00 00 00    	jns    8005f5 <vprintfmt+0x3a8>
				putch('-', putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	6a 2d                	push   $0x2d
  8004fc:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800501:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800504:	f7 da                	neg    %edx
  800506:	83 d1 00             	adc    $0x0,%ecx
  800509:	f7 d9                	neg    %ecx
  80050b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800513:	e9 dd 00 00 00       	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800520:	99                   	cltd   
  800521:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 40 04             	lea    0x4(%eax),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	eb b4                	jmp    8004e3 <vprintfmt+0x296>
	if (lflag >= 2)
  80052f:	83 f9 01             	cmp    $0x1,%ecx
  800532:	7f 1e                	jg     800552 <vprintfmt+0x305>
	else if (lflag)
  800534:	85 c9                	test   %ecx,%ecx
  800536:	74 32                	je     80056a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8b 10                	mov    (%eax),%edx
  80053d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800542:	8d 40 04             	lea    0x4(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800548:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80054d:	e9 a3 00 00 00       	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 10                	mov    (%eax),%edx
  800557:	8b 48 04             	mov    0x4(%eax),%ecx
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800560:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800565:	e9 8b 00 00 00       	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8b 10                	mov    (%eax),%edx
  80056f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80057f:	eb 74                	jmp    8005f5 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7f 1b                	jg     8005a1 <vprintfmt+0x354>
	else if (lflag)
  800586:	85 c9                	test   %ecx,%ecx
  800588:	74 2c                	je     8005b6 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 10                	mov    (%eax),%edx
  80058f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80059a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80059f:	eb 54                	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005af:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005b4:	eb 3f                	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005cb:	eb 28                	jmp    8005f5 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 30                	push   $0x30
  8005d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d5:	83 c4 08             	add    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 78                	push   $0x78
  8005db:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f0:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005fc:	50                   	push   %eax
  8005fd:	ff 75 e0             	push   -0x20(%ebp)
  800600:	57                   	push   %edi
  800601:	51                   	push   %ecx
  800602:	52                   	push   %edx
  800603:	89 da                	mov    %ebx,%edx
  800605:	89 f0                	mov    %esi,%eax
  800607:	e8 5e fb ff ff       	call   80016a <printnum>
			break;
  80060c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800612:	e9 54 fc ff ff       	jmp    80026b <vprintfmt+0x1e>
	if (lflag >= 2)
  800617:	83 f9 01             	cmp    $0x1,%ecx
  80061a:	7f 1b                	jg     800637 <vprintfmt+0x3ea>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 2c                	je     80064c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800630:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800635:	eb be                	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	8b 48 04             	mov    0x4(%eax),%ecx
  80063f:	8d 40 08             	lea    0x8(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800645:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80064a:	eb a9                	jmp    8005f5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800661:	eb 92                	jmp    8005f5 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 25                	push   $0x25
  800669:	ff d6                	call   *%esi
			break;
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	eb 9f                	jmp    80060f <vprintfmt+0x3c2>
			putch('%', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 25                	push   $0x25
  800676:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	89 f8                	mov    %edi,%eax
  80067d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800681:	74 05                	je     800688 <vprintfmt+0x43b>
  800683:	83 e8 01             	sub    $0x1,%eax
  800686:	eb f5                	jmp    80067d <vprintfmt+0x430>
  800688:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068b:	eb 82                	jmp    80060f <vprintfmt+0x3c2>

0080068d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 18             	sub    $0x18,%esp
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800699:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	74 26                	je     8006d4 <vsnprintf+0x47>
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	7e 22                	jle    8006d4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b2:	ff 75 14             	push   0x14(%ebp)
  8006b5:	ff 75 10             	push   0x10(%ebp)
  8006b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	68 13 02 80 00       	push   $0x800213
  8006c1:	e8 87 fb ff ff       	call   80024d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cf:	83 c4 10             	add    $0x10,%esp
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    
		return -E_INVAL;
  8006d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d9:	eb f7                	jmp    8006d2 <vsnprintf+0x45>

008006db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e4:	50                   	push   %eax
  8006e5:	ff 75 10             	push   0x10(%ebp)
  8006e8:	ff 75 0c             	push   0xc(%ebp)
  8006eb:	ff 75 08             	push   0x8(%ebp)
  8006ee:	e8 9a ff ff ff       	call   80068d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 03                	jmp    800705 <strlen+0x10>
		n++;
  800702:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800705:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800709:	75 f7                	jne    800702 <strlen+0xd>
	return n;
}
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	eb 03                	jmp    800720 <strnlen+0x13>
		n++;
  80071d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800720:	39 d0                	cmp    %edx,%eax
  800722:	74 08                	je     80072c <strnlen+0x1f>
  800724:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800728:	75 f3                	jne    80071d <strnlen+0x10>
  80072a:	89 c2                	mov    %eax,%edx
	return n;
}
  80072c:	89 d0                	mov    %edx,%eax
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800743:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800746:	83 c0 01             	add    $0x1,%eax
  800749:	84 d2                	test   %dl,%dl
  80074b:	75 f2                	jne    80073f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074d:	89 c8                	mov    %ecx,%eax
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	83 ec 10             	sub    $0x10,%esp
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075e:	53                   	push   %ebx
  80075f:	e8 91 ff ff ff       	call   8006f5 <strlen>
  800764:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800767:	ff 75 0c             	push   0xc(%ebp)
  80076a:	01 d8                	add    %ebx,%eax
  80076c:	50                   	push   %eax
  80076d:	e8 be ff ff ff       	call   800730 <strcpy>
	return dst;
}
  800772:	89 d8                	mov    %ebx,%eax
  800774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800777:	c9                   	leave  
  800778:	c3                   	ret    

00800779 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
  800784:	89 f3                	mov    %esi,%ebx
  800786:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800789:	89 f0                	mov    %esi,%eax
  80078b:	eb 0f                	jmp    80079c <strncpy+0x23>
		*dst++ = *src;
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	0f b6 0a             	movzbl (%edx),%ecx
  800793:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800796:	80 f9 01             	cmp    $0x1,%cl
  800799:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80079c:	39 d8                	cmp    %ebx,%eax
  80079e:	75 ed                	jne    80078d <strncpy+0x14>
	}
	return ret;
}
  8007a0:	89 f0                	mov    %esi,%eax
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	56                   	push   %esi
  8007aa:	53                   	push   %ebx
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 21                	je     8007db <strlcpy+0x35>
  8007ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007be:	89 f2                	mov    %esi,%edx
  8007c0:	eb 09                	jmp    8007cb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	83 c1 01             	add    $0x1,%ecx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007cb:	39 c2                	cmp    %eax,%edx
  8007cd:	74 09                	je     8007d8 <strlcpy+0x32>
  8007cf:	0f b6 19             	movzbl (%ecx),%ebx
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ec                	jne    8007c2 <strlcpy+0x1c>
  8007d6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007db:	29 f0                	sub    %esi,%eax
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ea:	eb 06                	jmp    8007f2 <strcmp+0x11>
		p++, q++;
  8007ec:	83 c1 01             	add    $0x1,%ecx
  8007ef:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x1c>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 ef                	je     8007ec <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 c3                	mov    %eax,%ebx
  800813:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800816:	eb 06                	jmp    80081e <strncmp+0x17>
		n--, p++, q++;
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80081e:	39 d8                	cmp    %ebx,%eax
  800820:	74 18                	je     80083a <strncmp+0x33>
  800822:	0f b6 08             	movzbl (%eax),%ecx
  800825:	84 c9                	test   %cl,%cl
  800827:	74 04                	je     80082d <strncmp+0x26>
  800829:	3a 0a                	cmp    (%edx),%cl
  80082b:	74 eb                	je     800818 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082d:	0f b6 00             	movzbl (%eax),%eax
  800830:	0f b6 12             	movzbl (%edx),%edx
  800833:	29 d0                	sub    %edx,%eax
}
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    
		return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	eb f4                	jmp    800835 <strncmp+0x2e>

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 03                	jmp    800850 <strchr+0xf>
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
  800853:	84 d2                	test   %dl,%dl
  800855:	74 06                	je     80085d <strchr+0x1c>
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
  80085b:	eb 05                	jmp    800862 <strchr+0x21>
			return (char *) s;
	return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 09                	je     80087e <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	74 05                	je     80087e <strfind+0x1a>
	for (; *s; s++)
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	eb f0                	jmp    80086e <strfind+0xa>
			break;
	return (char *) s;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	57                   	push   %edi
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	74 2f                	je     8008bf <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800890:	89 f8                	mov    %edi,%eax
  800892:	09 c8                	or     %ecx,%eax
  800894:	a8 03                	test   $0x3,%al
  800896:	75 21                	jne    8008b9 <memset+0x39>
		c &= 0xFF;
  800898:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d0                	mov    %edx,%eax
  80089e:	c1 e0 08             	shl    $0x8,%eax
  8008a1:	89 d3                	mov    %edx,%ebx
  8008a3:	c1 e3 18             	shl    $0x18,%ebx
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	c1 e6 10             	shl    $0x10,%esi
  8008ab:	09 f3                	or     %esi,%ebx
  8008ad:	09 da                	or     %ebx,%edx
  8008af:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008b4:	fc                   	cld    
  8008b5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b7:	eb 06                	jmp    8008bf <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bc:	fc                   	cld    
  8008bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bf:	89 f8                	mov    %edi,%eax
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5f                   	pop    %edi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	57                   	push   %edi
  8008ca:	56                   	push   %esi
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d4:	39 c6                	cmp    %eax,%esi
  8008d6:	73 32                	jae    80090a <memmove+0x44>
  8008d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008db:	39 c2                	cmp    %eax,%edx
  8008dd:	76 2b                	jbe    80090a <memmove+0x44>
		s += n;
		d += n;
  8008df:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	09 fe                	or     %edi,%esi
  8008e6:	09 ce                	or     %ecx,%esi
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 0e                	jne    8008fe <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f0:	83 ef 04             	sub    $0x4,%edi
  8008f3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008f9:	fd                   	std    
  8008fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fc:	eb 09                	jmp    800907 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fe:	83 ef 01             	sub    $0x1,%edi
  800901:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800904:	fd                   	std    
  800905:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800907:	fc                   	cld    
  800908:	eb 1a                	jmp    800924 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090a:	89 f2                	mov    %esi,%edx
  80090c:	09 c2                	or     %eax,%edx
  80090e:	09 ca                	or     %ecx,%edx
  800910:	f6 c2 03             	test   $0x3,%dl
  800913:	75 0a                	jne    80091f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800915:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800918:	89 c7                	mov    %eax,%edi
  80091a:	fc                   	cld    
  80091b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091d:	eb 05                	jmp    800924 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80091f:	89 c7                	mov    %eax,%edi
  800921:	fc                   	cld    
  800922:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80092e:	ff 75 10             	push   0x10(%ebp)
  800931:	ff 75 0c             	push   0xc(%ebp)
  800934:	ff 75 08             	push   0x8(%ebp)
  800937:	e8 8a ff ff ff       	call   8008c6 <memmove>
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
  800949:	89 c6                	mov    %eax,%esi
  80094b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094e:	eb 06                	jmp    800956 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800956:	39 f0                	cmp    %esi,%eax
  800958:	74 14                	je     80096e <memcmp+0x30>
		if (*s1 != *s2)
  80095a:	0f b6 08             	movzbl (%eax),%ecx
  80095d:	0f b6 1a             	movzbl (%edx),%ebx
  800960:	38 d9                	cmp    %bl,%cl
  800962:	74 ec                	je     800950 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800964:	0f b6 c1             	movzbl %cl,%eax
  800967:	0f b6 db             	movzbl %bl,%ebx
  80096a:	29 d8                	sub    %ebx,%eax
  80096c:	eb 05                	jmp    800973 <memcmp+0x35>
	}

	return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800980:	89 c2                	mov    %eax,%edx
  800982:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800985:	eb 03                	jmp    80098a <memfind+0x13>
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	39 d0                	cmp    %edx,%eax
  80098c:	73 04                	jae    800992 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	38 08                	cmp    %cl,(%eax)
  800990:	75 f5                	jne    800987 <memfind+0x10>
			break;
	return (void *) s;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
  80099d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	eb 03                	jmp    8009a5 <strtol+0x11>
		s++;
  8009a2:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009a5:	0f b6 02             	movzbl (%edx),%eax
  8009a8:	3c 20                	cmp    $0x20,%al
  8009aa:	74 f6                	je     8009a2 <strtol+0xe>
  8009ac:	3c 09                	cmp    $0x9,%al
  8009ae:	74 f2                	je     8009a2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009b0:	3c 2b                	cmp    $0x2b,%al
  8009b2:	74 2a                	je     8009de <strtol+0x4a>
	int neg = 0;
  8009b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009b9:	3c 2d                	cmp    $0x2d,%al
  8009bb:	74 2b                	je     8009e8 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c3:	75 0f                	jne    8009d4 <strtol+0x40>
  8009c5:	80 3a 30             	cmpb   $0x30,(%edx)
  8009c8:	74 28                	je     8009f2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ca:	85 db                	test   %ebx,%ebx
  8009cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d1:	0f 44 d8             	cmove  %eax,%ebx
  8009d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009dc:	eb 46                	jmp    800a24 <strtol+0x90>
		s++;
  8009de:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e6:	eb d5                	jmp    8009bd <strtol+0x29>
		s++, neg = 1;
  8009e8:	83 c2 01             	add    $0x1,%edx
  8009eb:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f0:	eb cb                	jmp    8009bd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f6:	74 0e                	je     800a06 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	75 d8                	jne    8009d4 <strtol+0x40>
		s++, base = 8;
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a04:	eb ce                	jmp    8009d4 <strtol+0x40>
		s += 2, base = 16;
  800a06:	83 c2 02             	add    $0x2,%edx
  800a09:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0e:	eb c4                	jmp    8009d4 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a10:	0f be c0             	movsbl %al,%eax
  800a13:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a16:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a19:	7d 3a                	jge    800a55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a22:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a24:	0f b6 02             	movzbl (%edx),%eax
  800a27:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 09             	cmp    $0x9,%bl
  800a2f:	76 df                	jbe    800a10 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a31:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	80 fb 19             	cmp    $0x19,%bl
  800a39:	77 08                	ja     800a43 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a3b:	0f be c0             	movsbl %al,%eax
  800a3e:	83 e8 57             	sub    $0x57,%eax
  800a41:	eb d3                	jmp    800a16 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a43:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	80 fb 19             	cmp    $0x19,%bl
  800a4b:	77 08                	ja     800a55 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a4d:	0f be c0             	movsbl %al,%eax
  800a50:	83 e8 37             	sub    $0x37,%eax
  800a53:	eb c1                	jmp    800a16 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a59:	74 05                	je     800a60 <strtol+0xcc>
		*endptr = (char *) s;
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a60:	89 c8                	mov    %ecx,%eax
  800a62:	f7 d8                	neg    %eax
  800a64:	85 ff                	test   %edi,%edi
  800a66:	0f 45 c8             	cmovne %eax,%ecx
}
  800a69:	89 c8                	mov    %ecx,%eax
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a81:	89 c3                	mov    %eax,%ebx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	89 c6                	mov    %eax,%esi
  800a87:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9e:	89 d1                	mov    %edx,%ecx
  800aa0:	89 d3                	mov    %edx,%ebx
  800aa2:	89 d7                	mov    %edx,%edi
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ab6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abb:	8b 55 08             	mov    0x8(%ebp),%edx
  800abe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac3:	89 cb                	mov    %ecx,%ebx
  800ac5:	89 cf                	mov    %ecx,%edi
  800ac7:	89 ce                	mov    %ecx,%esi
  800ac9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800acb:	85 c0                	test   %eax,%eax
  800acd:	7f 08                	jg     800ad7 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad7:	83 ec 0c             	sub    $0xc,%esp
  800ada:	50                   	push   %eax
  800adb:	6a 03                	push   $0x3
  800add:	68 9f 25 80 00       	push   $0x80259f
  800ae2:	6a 2a                	push   $0x2a
  800ae4:	68 bc 25 80 00       	push   $0x8025bc
  800ae9:	e8 9e 13 00 00       	call   801e8c <_panic>

00800aee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 02 00 00 00       	mov    $0x2,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_yield>:

void
sys_yield(void)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b1d:	89 d1                	mov    %edx,%ecx
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	89 d7                	mov    %edx,%edi
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b35:	be 00 00 00 00       	mov    $0x0,%esi
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b40:	b8 04 00 00 00       	mov    $0x4,%eax
  800b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b48:	89 f7                	mov    %esi,%edi
  800b4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	7f 08                	jg     800b58 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b58:	83 ec 0c             	sub    $0xc,%esp
  800b5b:	50                   	push   %eax
  800b5c:	6a 04                	push   $0x4
  800b5e:	68 9f 25 80 00       	push   $0x80259f
  800b63:	6a 2a                	push   $0x2a
  800b65:	68 bc 25 80 00       	push   $0x8025bc
  800b6a:	e8 1d 13 00 00       	call   801e8c <_panic>

00800b6f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b89:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 05                	push   $0x5
  800ba0:	68 9f 25 80 00       	push   $0x80259f
  800ba5:	6a 2a                	push   $0x2a
  800ba7:	68 bc 25 80 00       	push   $0x8025bc
  800bac:	e8 db 12 00 00       	call   801e8c <_panic>

00800bb1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bca:	89 df                	mov    %ebx,%edi
  800bcc:	89 de                	mov    %ebx,%esi
  800bce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7f 08                	jg     800bdc <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 06                	push   $0x6
  800be2:	68 9f 25 80 00       	push   $0x80259f
  800be7:	6a 2a                	push   $0x2a
  800be9:	68 bc 25 80 00       	push   $0x8025bc
  800bee:	e8 99 12 00 00       	call   801e8c <_panic>

00800bf3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7f 08                	jg     800c1e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 08                	push   $0x8
  800c24:	68 9f 25 80 00       	push   $0x80259f
  800c29:	6a 2a                	push   $0x2a
  800c2b:	68 bc 25 80 00       	push   $0x8025bc
  800c30:	e8 57 12 00 00       	call   801e8c <_panic>

00800c35 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4e:	89 df                	mov    %ebx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7f 08                	jg     800c60 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 09                	push   $0x9
  800c66:	68 9f 25 80 00       	push   $0x80259f
  800c6b:	6a 2a                	push   $0x2a
  800c6d:	68 bc 25 80 00       	push   $0x8025bc
  800c72:	e8 15 12 00 00       	call   801e8c <_panic>

00800c77 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7f 08                	jg     800ca2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 0a                	push   $0xa
  800ca8:	68 9f 25 80 00       	push   $0x80259f
  800cad:	6a 2a                	push   $0x2a
  800caf:	68 bc 25 80 00       	push   $0x8025bc
  800cb4:	e8 d3 11 00 00       	call   801e8c <_panic>

00800cb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf2:	89 cb                	mov    %ecx,%ebx
  800cf4:	89 cf                	mov    %ecx,%edi
  800cf6:	89 ce                	mov    %ecx,%esi
  800cf8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7f 08                	jg     800d06 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 0d                	push   $0xd
  800d0c:	68 9f 25 80 00       	push   $0x80259f
  800d11:	6a 2a                	push   $0x2a
  800d13:	68 bc 25 80 00       	push   $0x8025bc
  800d18:	e8 6f 11 00 00       	call   801e8c <_panic>

00800d1d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d2d:	89 d1                	mov    %edx,%ecx
  800d2f:	89 d3                	mov    %edx,%ebx
  800d31:	89 d7                	mov    %edx,%edi
  800d33:	89 d6                	mov    %edx,%esi
  800d35:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	b8 10 00 00 00       	mov    $0x10,%eax
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	05 00 00 00 30       	add    $0x30000000,%eax
  800d89:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d9e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	c1 ea 16             	shr    $0x16,%edx
  800db2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db9:	f6 c2 01             	test   $0x1,%dl
  800dbc:	74 29                	je     800de7 <fd_alloc+0x42>
  800dbe:	89 c2                	mov    %eax,%edx
  800dc0:	c1 ea 0c             	shr    $0xc,%edx
  800dc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dca:	f6 c2 01             	test   $0x1,%dl
  800dcd:	74 18                	je     800de7 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dcf:	05 00 10 00 00       	add    $0x1000,%eax
  800dd4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd9:	75 d2                	jne    800dad <fd_alloc+0x8>
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800de0:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800de5:	eb 05                	jmp    800dec <fd_alloc+0x47>
			return 0;
  800de7:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	89 02                	mov    %eax,(%edx)
}
  800df1:	89 c8                	mov    %ecx,%eax
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfb:	83 f8 1f             	cmp    $0x1f,%eax
  800dfe:	77 30                	ja     800e30 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e00:	c1 e0 0c             	shl    $0xc,%eax
  800e03:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e08:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e0e:	f6 c2 01             	test   $0x1,%dl
  800e11:	74 24                	je     800e37 <fd_lookup+0x42>
  800e13:	89 c2                	mov    %eax,%edx
  800e15:	c1 ea 0c             	shr    $0xc,%edx
  800e18:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1f:	f6 c2 01             	test   $0x1,%dl
  800e22:	74 1a                	je     800e3e <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e27:	89 02                	mov    %eax,(%edx)
	return 0;
  800e29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    
		return -E_INVAL;
  800e30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e35:	eb f7                	jmp    800e2e <fd_lookup+0x39>
		return -E_INVAL;
  800e37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3c:	eb f0                	jmp    800e2e <fd_lookup+0x39>
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e43:	eb e9                	jmp    800e2e <fd_lookup+0x39>

00800e45 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	53                   	push   %ebx
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e59:	39 13                	cmp    %edx,(%ebx)
  800e5b:	74 37                	je     800e94 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e5d:	83 c0 01             	add    $0x1,%eax
  800e60:	8b 1c 85 48 26 80 00 	mov    0x802648(,%eax,4),%ebx
  800e67:	85 db                	test   %ebx,%ebx
  800e69:	75 ee                	jne    800e59 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6b:	a1 00 40 80 00       	mov    0x804000,%eax
  800e70:	8b 40 58             	mov    0x58(%eax),%eax
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	52                   	push   %edx
  800e77:	50                   	push   %eax
  800e78:	68 cc 25 80 00       	push   $0x8025cc
  800e7d:	e8 d4 f2 ff ff       	call   800156 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8d:	89 1a                	mov    %ebx,(%edx)
}
  800e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    
			return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	eb ef                	jmp    800e8a <dev_lookup+0x45>

00800e9b <fd_close>:
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 24             	sub    $0x24,%esp
  800ea4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eaa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ead:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb4:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb7:	50                   	push   %eax
  800eb8:	e8 38 ff ff ff       	call   800df5 <fd_lookup>
  800ebd:	89 c3                	mov    %eax,%ebx
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 05                	js     800ecb <fd_close+0x30>
	    || fd != fd2)
  800ec6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ec9:	74 16                	je     800ee1 <fd_close+0x46>
		return (must_exist ? r : 0);
  800ecb:	89 f8                	mov    %edi,%eax
  800ecd:	84 c0                	test   %al,%al
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed4:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed7:	89 d8                	mov    %ebx,%eax
  800ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee1:	83 ec 08             	sub    $0x8,%esp
  800ee4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee7:	50                   	push   %eax
  800ee8:	ff 36                	push   (%esi)
  800eea:	e8 56 ff ff ff       	call   800e45 <dev_lookup>
  800eef:	89 c3                	mov    %eax,%ebx
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 1a                	js     800f12 <fd_close+0x77>
		if (dev->dev_close)
  800ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	74 0b                	je     800f12 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	56                   	push   %esi
  800f0b:	ff d0                	call   *%eax
  800f0d:	89 c3                	mov    %eax,%ebx
  800f0f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	56                   	push   %esi
  800f16:	6a 00                	push   $0x0
  800f18:	e8 94 fc ff ff       	call   800bb1 <sys_page_unmap>
	return r;
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	eb b5                	jmp    800ed7 <fd_close+0x3c>

00800f22 <close>:

int
close(int fdnum)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	ff 75 08             	push   0x8(%ebp)
  800f2f:	e8 c1 fe ff ff       	call   800df5 <fd_lookup>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 02                	jns    800f3d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    
		return fd_close(fd, 1);
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	6a 01                	push   $0x1
  800f42:	ff 75 f4             	push   -0xc(%ebp)
  800f45:	e8 51 ff ff ff       	call   800e9b <fd_close>
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	eb ec                	jmp    800f3b <close+0x19>

00800f4f <close_all>:

void
close_all(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	53                   	push   %ebx
  800f53:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	53                   	push   %ebx
  800f5f:	e8 be ff ff ff       	call   800f22 <close>
	for (i = 0; i < MAXFD; i++)
  800f64:	83 c3 01             	add    $0x1,%ebx
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	83 fb 20             	cmp    $0x20,%ebx
  800f6d:	75 ec                	jne    800f5b <close_all+0xc>
}
  800f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 75 08             	push   0x8(%ebp)
  800f84:	e8 6c fe ff ff       	call   800df5 <fd_lookup>
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 7f                	js     801011 <dup+0x9d>
		return r;
	close(newfdnum);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	ff 75 0c             	push   0xc(%ebp)
  800f98:	e8 85 ff ff ff       	call   800f22 <close>

	newfd = INDEX2FD(newfdnum);
  800f9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa0:	c1 e6 0c             	shl    $0xc,%esi
  800fa3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fa9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fac:	89 3c 24             	mov    %edi,(%esp)
  800faf:	e8 da fd ff ff       	call   800d8e <fd2data>
  800fb4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb6:	89 34 24             	mov    %esi,(%esp)
  800fb9:	e8 d0 fd ff ff       	call   800d8e <fd2data>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	c1 e8 16             	shr    $0x16,%eax
  800fc9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd0:	a8 01                	test   $0x1,%al
  800fd2:	74 11                	je     800fe5 <dup+0x71>
  800fd4:	89 d8                	mov    %ebx,%eax
  800fd6:	c1 e8 0c             	shr    $0xc,%eax
  800fd9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe0:	f6 c2 01             	test   $0x1,%dl
  800fe3:	75 36                	jne    80101b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe5:	89 f8                	mov    %edi,%eax
  800fe7:	c1 e8 0c             	shr    $0xc,%eax
  800fea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff9:	50                   	push   %eax
  800ffa:	56                   	push   %esi
  800ffb:	6a 00                	push   $0x0
  800ffd:	57                   	push   %edi
  800ffe:	6a 00                	push   $0x0
  801000:	e8 6a fb ff ff       	call   800b6f <sys_page_map>
  801005:	89 c3                	mov    %eax,%ebx
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 33                	js     801041 <dup+0xcd>
		goto err;

	return newfdnum;
  80100e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801011:	89 d8                	mov    %ebx,%eax
  801013:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80101b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	25 07 0e 00 00       	and    $0xe07,%eax
  80102a:	50                   	push   %eax
  80102b:	ff 75 d4             	push   -0x2c(%ebp)
  80102e:	6a 00                	push   $0x0
  801030:	53                   	push   %ebx
  801031:	6a 00                	push   $0x0
  801033:	e8 37 fb ff ff       	call   800b6f <sys_page_map>
  801038:	89 c3                	mov    %eax,%ebx
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	79 a4                	jns    800fe5 <dup+0x71>
	sys_page_unmap(0, newfd);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	56                   	push   %esi
  801045:	6a 00                	push   $0x0
  801047:	e8 65 fb ff ff       	call   800bb1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	ff 75 d4             	push   -0x2c(%ebp)
  801052:	6a 00                	push   $0x0
  801054:	e8 58 fb ff ff       	call   800bb1 <sys_page_unmap>
	return r;
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	eb b3                	jmp    801011 <dup+0x9d>

0080105e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 18             	sub    $0x18,%esp
  801066:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801069:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	56                   	push   %esi
  80106e:	e8 82 fd ff ff       	call   800df5 <fd_lookup>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 3c                	js     8010b6 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801083:	50                   	push   %eax
  801084:	ff 33                	push   (%ebx)
  801086:	e8 ba fd ff ff       	call   800e45 <dev_lookup>
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 24                	js     8010b6 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801092:	8b 43 08             	mov    0x8(%ebx),%eax
  801095:	83 e0 03             	and    $0x3,%eax
  801098:	83 f8 01             	cmp    $0x1,%eax
  80109b:	74 20                	je     8010bd <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80109d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a0:	8b 40 08             	mov    0x8(%eax),%eax
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	74 37                	je     8010de <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	ff 75 10             	push   0x10(%ebp)
  8010ad:	ff 75 0c             	push   0xc(%ebp)
  8010b0:	53                   	push   %ebx
  8010b1:	ff d0                	call   *%eax
  8010b3:	83 c4 10             	add    $0x10,%esp
}
  8010b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010bd:	a1 00 40 80 00       	mov    0x804000,%eax
  8010c2:	8b 40 58             	mov    0x58(%eax),%eax
  8010c5:	83 ec 04             	sub    $0x4,%esp
  8010c8:	56                   	push   %esi
  8010c9:	50                   	push   %eax
  8010ca:	68 0d 26 80 00       	push   $0x80260d
  8010cf:	e8 82 f0 ff ff       	call   800156 <cprintf>
		return -E_INVAL;
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dc:	eb d8                	jmp    8010b6 <read+0x58>
		return -E_NOT_SUPP;
  8010de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010e3:	eb d1                	jmp    8010b6 <read+0x58>

008010e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f9:	eb 02                	jmp    8010fd <readn+0x18>
  8010fb:	01 c3                	add    %eax,%ebx
  8010fd:	39 f3                	cmp    %esi,%ebx
  8010ff:	73 21                	jae    801122 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	89 f0                	mov    %esi,%eax
  801106:	29 d8                	sub    %ebx,%eax
  801108:	50                   	push   %eax
  801109:	89 d8                	mov    %ebx,%eax
  80110b:	03 45 0c             	add    0xc(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	57                   	push   %edi
  801110:	e8 49 ff ff ff       	call   80105e <read>
		if (m < 0)
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 04                	js     801120 <readn+0x3b>
			return m;
		if (m == 0)
  80111c:	75 dd                	jne    8010fb <readn+0x16>
  80111e:	eb 02                	jmp    801122 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801120:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801122:	89 d8                	mov    %ebx,%eax
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 18             	sub    $0x18,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	53                   	push   %ebx
  80113c:	e8 b4 fc ff ff       	call   800df5 <fd_lookup>
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	78 37                	js     80117f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801148:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	ff 36                	push   (%esi)
  801154:	e8 ec fc ff ff       	call   800e45 <dev_lookup>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 1f                	js     80117f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801160:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801164:	74 20                	je     801186 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801169:	8b 40 0c             	mov    0xc(%eax),%eax
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 37                	je     8011a7 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	ff 75 10             	push   0x10(%ebp)
  801176:	ff 75 0c             	push   0xc(%ebp)
  801179:	56                   	push   %esi
  80117a:	ff d0                	call   *%eax
  80117c:	83 c4 10             	add    $0x10,%esp
}
  80117f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801186:	a1 00 40 80 00       	mov    0x804000,%eax
  80118b:	8b 40 58             	mov    0x58(%eax),%eax
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	53                   	push   %ebx
  801192:	50                   	push   %eax
  801193:	68 29 26 80 00       	push   $0x802629
  801198:	e8 b9 ef ff ff       	call   800156 <cprintf>
		return -E_INVAL;
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a5:	eb d8                	jmp    80117f <write+0x53>
		return -E_NOT_SUPP;
  8011a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ac:	eb d1                	jmp    80117f <write+0x53>

008011ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 75 08             	push   0x8(%ebp)
  8011bb:	e8 35 fc ff ff       	call   800df5 <fd_lookup>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 0e                	js     8011d5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 18             	sub    $0x18,%esp
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	53                   	push   %ebx
  8011e7:	e8 09 fc ff ff       	call   800df5 <fd_lookup>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 34                	js     801227 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fc:	50                   	push   %eax
  8011fd:	ff 36                	push   (%esi)
  8011ff:	e8 41 fc ff ff       	call   800e45 <dev_lookup>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 1c                	js     801227 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80120f:	74 1d                	je     80122e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801211:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801214:	8b 40 18             	mov    0x18(%eax),%eax
  801217:	85 c0                	test   %eax,%eax
  801219:	74 34                	je     80124f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121b:	83 ec 08             	sub    $0x8,%esp
  80121e:	ff 75 0c             	push   0xc(%ebp)
  801221:	56                   	push   %esi
  801222:	ff d0                	call   *%eax
  801224:	83 c4 10             	add    $0x10,%esp
}
  801227:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80122e:	a1 00 40 80 00       	mov    0x804000,%eax
  801233:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	53                   	push   %ebx
  80123a:	50                   	push   %eax
  80123b:	68 ec 25 80 00       	push   $0x8025ec
  801240:	e8 11 ef ff ff       	call   800156 <cprintf>
		return -E_INVAL;
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124d:	eb d8                	jmp    801227 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80124f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801254:	eb d1                	jmp    801227 <ftruncate+0x50>

00801256 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 18             	sub    $0x18,%esp
  80125e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	ff 75 08             	push   0x8(%ebp)
  801268:	e8 88 fb ff ff       	call   800df5 <fd_lookup>
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 49                	js     8012bd <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801274:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	ff 36                	push   (%esi)
  801280:	e8 c0 fb ff ff       	call   800e45 <dev_lookup>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 31                	js     8012bd <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801293:	74 2f                	je     8012c4 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801295:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801298:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80129f:	00 00 00 
	stat->st_isdir = 0;
  8012a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a9:	00 00 00 
	stat->st_dev = dev;
  8012ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	56                   	push   %esi
  8012b7:	ff 50 14             	call   *0x14(%eax)
  8012ba:	83 c4 10             	add    $0x10,%esp
}
  8012bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
		return -E_NOT_SUPP;
  8012c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c9:	eb f2                	jmp    8012bd <fstat+0x67>

008012cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	6a 00                	push   $0x0
  8012d5:	ff 75 08             	push   0x8(%ebp)
  8012d8:	e8 e4 01 00 00       	call   8014c1 <open>
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 1b                	js     801301 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	ff 75 0c             	push   0xc(%ebp)
  8012ec:	50                   	push   %eax
  8012ed:	e8 64 ff ff ff       	call   801256 <fstat>
  8012f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f4:	89 1c 24             	mov    %ebx,(%esp)
  8012f7:	e8 26 fc ff ff       	call   800f22 <close>
	return r;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	89 f3                	mov    %esi,%ebx
}
  801301:	89 d8                	mov    %ebx,%eax
  801303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	89 c6                	mov    %eax,%esi
  801311:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801313:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80131a:	74 27                	je     801343 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131c:	6a 07                	push   $0x7
  80131e:	68 00 50 80 00       	push   $0x805000
  801323:	56                   	push   %esi
  801324:	ff 35 00 60 80 00    	push   0x806000
  80132a:	e8 13 0c 00 00       	call   801f42 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80132f:	83 c4 0c             	add    $0xc,%esp
  801332:	6a 00                	push   $0x0
  801334:	53                   	push   %ebx
  801335:	6a 00                	push   $0x0
  801337:	e8 96 0b 00 00       	call   801ed2 <ipc_recv>
}
  80133c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	6a 01                	push   $0x1
  801348:	e8 49 0c 00 00       	call   801f96 <ipc_find_env>
  80134d:	a3 00 60 80 00       	mov    %eax,0x806000
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	eb c5                	jmp    80131c <fsipc+0x12>

00801357 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	8b 40 0c             	mov    0xc(%eax),%eax
  801363:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801368:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801370:	ba 00 00 00 00       	mov    $0x0,%edx
  801375:	b8 02 00 00 00       	mov    $0x2,%eax
  80137a:	e8 8b ff ff ff       	call   80130a <fsipc>
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <devfile_flush>:
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	8b 40 0c             	mov    0xc(%eax),%eax
  80138d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
  801397:	b8 06 00 00 00       	mov    $0x6,%eax
  80139c:	e8 69 ff ff ff       	call   80130a <fsipc>
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <devfile_stat>:
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c2:	e8 43 ff ff ff       	call   80130a <fsipc>
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 2c                	js     8013f7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	68 00 50 80 00       	push   $0x805000
  8013d3:	53                   	push   %ebx
  8013d4:	e8 57 f3 ff ff       	call   800730 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_write>:
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	8b 45 10             	mov    0x10(%ebp),%eax
  801405:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80140a:	39 d0                	cmp    %edx,%eax
  80140c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140f:	8b 55 08             	mov    0x8(%ebp),%edx
  801412:	8b 52 0c             	mov    0xc(%edx),%edx
  801415:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80141b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801420:	50                   	push   %eax
  801421:	ff 75 0c             	push   0xc(%ebp)
  801424:	68 08 50 80 00       	push   $0x805008
  801429:	e8 98 f4 ff ff       	call   8008c6 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80142e:	ba 00 00 00 00       	mov    $0x0,%edx
  801433:	b8 04 00 00 00       	mov    $0x4,%eax
  801438:	e8 cd fe ff ff       	call   80130a <fsipc>
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_read>:
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	8b 40 0c             	mov    0xc(%eax),%eax
  80144d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801452:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801458:	ba 00 00 00 00       	mov    $0x0,%edx
  80145d:	b8 03 00 00 00       	mov    $0x3,%eax
  801462:	e8 a3 fe ff ff       	call   80130a <fsipc>
  801467:	89 c3                	mov    %eax,%ebx
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 1f                	js     80148c <devfile_read+0x4d>
	assert(r <= n);
  80146d:	39 f0                	cmp    %esi,%eax
  80146f:	77 24                	ja     801495 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801471:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801476:	7f 33                	jg     8014ab <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	50                   	push   %eax
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	ff 75 0c             	push   0xc(%ebp)
  801484:	e8 3d f4 ff ff       	call   8008c6 <memmove>
	return r;
  801489:	83 c4 10             	add    $0x10,%esp
}
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
	assert(r <= n);
  801495:	68 5c 26 80 00       	push   $0x80265c
  80149a:	68 63 26 80 00       	push   $0x802663
  80149f:	6a 7c                	push   $0x7c
  8014a1:	68 78 26 80 00       	push   $0x802678
  8014a6:	e8 e1 09 00 00       	call   801e8c <_panic>
	assert(r <= PGSIZE);
  8014ab:	68 83 26 80 00       	push   $0x802683
  8014b0:	68 63 26 80 00       	push   $0x802663
  8014b5:	6a 7d                	push   $0x7d
  8014b7:	68 78 26 80 00       	push   $0x802678
  8014bc:	e8 cb 09 00 00       	call   801e8c <_panic>

008014c1 <open>:
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 1c             	sub    $0x1c,%esp
  8014c9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014cc:	56                   	push   %esi
  8014cd:	e8 23 f2 ff ff       	call   8006f5 <strlen>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014da:	7f 6c                	jg     801548 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	e8 bd f8 ff ff       	call   800da5 <fd_alloc>
  8014e8:	89 c3                	mov    %eax,%ebx
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 3c                	js     80152d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014f1:	83 ec 08             	sub    $0x8,%esp
  8014f4:	56                   	push   %esi
  8014f5:	68 00 50 80 00       	push   $0x805000
  8014fa:	e8 31 f2 ff ff       	call   800730 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801502:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801507:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80150a:	b8 01 00 00 00       	mov    $0x1,%eax
  80150f:	e8 f6 fd ff ff       	call   80130a <fsipc>
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 19                	js     801536 <open+0x75>
	return fd2num(fd);
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	ff 75 f4             	push   -0xc(%ebp)
  801523:	e8 56 f8 ff ff       	call   800d7e <fd2num>
  801528:	89 c3                	mov    %eax,%ebx
  80152a:	83 c4 10             	add    $0x10,%esp
}
  80152d:	89 d8                	mov    %ebx,%eax
  80152f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    
		fd_close(fd, 0);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	6a 00                	push   $0x0
  80153b:	ff 75 f4             	push   -0xc(%ebp)
  80153e:	e8 58 f9 ff ff       	call   800e9b <fd_close>
		return r;
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	eb e5                	jmp    80152d <open+0x6c>
		return -E_BAD_PATH;
  801548:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80154d:	eb de                	jmp    80152d <open+0x6c>

0080154f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	b8 08 00 00 00       	mov    $0x8,%eax
  80155f:	e8 a6 fd ff ff       	call   80130a <fsipc>
}
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80156c:	68 8f 26 80 00       	push   $0x80268f
  801571:	ff 75 0c             	push   0xc(%ebp)
  801574:	e8 b7 f1 ff ff       	call   800730 <strcpy>
	return 0;
}
  801579:	b8 00 00 00 00       	mov    $0x0,%eax
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devsock_close>:
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	53                   	push   %ebx
  801584:	83 ec 10             	sub    $0x10,%esp
  801587:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80158a:	53                   	push   %ebx
  80158b:	e8 45 0a 00 00       	call   801fd5 <pageref>
  801590:	89 c2                	mov    %eax,%edx
  801592:	83 c4 10             	add    $0x10,%esp
		return 0;
  801595:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80159a:	83 fa 01             	cmp    $0x1,%edx
  80159d:	74 05                	je     8015a4 <devsock_close+0x24>
}
  80159f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015a4:	83 ec 0c             	sub    $0xc,%esp
  8015a7:	ff 73 0c             	push   0xc(%ebx)
  8015aa:	e8 b7 02 00 00       	call   801866 <nsipc_close>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb eb                	jmp    80159f <devsock_close+0x1f>

008015b4 <devsock_write>:
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015ba:	6a 00                	push   $0x0
  8015bc:	ff 75 10             	push   0x10(%ebp)
  8015bf:	ff 75 0c             	push   0xc(%ebp)
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	ff 70 0c             	push   0xc(%eax)
  8015c8:	e8 79 03 00 00       	call   801946 <nsipc_send>
}
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <devsock_read>:
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015d5:	6a 00                	push   $0x0
  8015d7:	ff 75 10             	push   0x10(%ebp)
  8015da:	ff 75 0c             	push   0xc(%ebp)
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e0:	ff 70 0c             	push   0xc(%eax)
  8015e3:	e8 ef 02 00 00       	call   8018d7 <nsipc_recv>
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <fd2sockid>:
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015f0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015f3:	52                   	push   %edx
  8015f4:	50                   	push   %eax
  8015f5:	e8 fb f7 ff ff       	call   800df5 <fd_lookup>
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 10                	js     801611 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801604:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80160a:	39 08                	cmp    %ecx,(%eax)
  80160c:	75 05                	jne    801613 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80160e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801611:	c9                   	leave  
  801612:	c3                   	ret    
		return -E_NOT_SUPP;
  801613:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801618:	eb f7                	jmp    801611 <fd2sockid+0x27>

0080161a <alloc_sockfd>:
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	83 ec 1c             	sub    $0x1c,%esp
  801622:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801624:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	e8 78 f7 ff ff       	call   800da5 <fd_alloc>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 43                	js     801679 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	68 07 04 00 00       	push   $0x407
  80163e:	ff 75 f4             	push   -0xc(%ebp)
  801641:	6a 00                	push   $0x0
  801643:	e8 e4 f4 ff ff       	call   800b2c <sys_page_alloc>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 28                	js     801679 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801654:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80165a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801666:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801669:	83 ec 0c             	sub    $0xc,%esp
  80166c:	50                   	push   %eax
  80166d:	e8 0c f7 ff ff       	call   800d7e <fd2num>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb 0c                	jmp    801685 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	56                   	push   %esi
  80167d:	e8 e4 01 00 00       	call   801866 <nsipc_close>
		return r;
  801682:	83 c4 10             	add    $0x10,%esp
}
  801685:	89 d8                	mov    %ebx,%eax
  801687:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <accept>:
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	e8 4e ff ff ff       	call   8015ea <fd2sockid>
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 1b                	js     8016bb <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	ff 75 10             	push   0x10(%ebp)
  8016a6:	ff 75 0c             	push   0xc(%ebp)
  8016a9:	50                   	push   %eax
  8016aa:	e8 0e 01 00 00       	call   8017bd <nsipc_accept>
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 05                	js     8016bb <accept+0x2d>
	return alloc_sockfd(r);
  8016b6:	e8 5f ff ff ff       	call   80161a <alloc_sockfd>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <bind>:
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	e8 1f ff ff ff       	call   8015ea <fd2sockid>
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 12                	js     8016e1 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	ff 75 10             	push   0x10(%ebp)
  8016d5:	ff 75 0c             	push   0xc(%ebp)
  8016d8:	50                   	push   %eax
  8016d9:	e8 31 01 00 00       	call   80180f <nsipc_bind>
  8016de:	83 c4 10             	add    $0x10,%esp
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <shutdown>:
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	e8 f9 fe ff ff       	call   8015ea <fd2sockid>
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 0f                	js     801704 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	ff 75 0c             	push   0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	e8 43 01 00 00       	call   801844 <nsipc_shutdown>
  801701:	83 c4 10             	add    $0x10,%esp
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <connect>:
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	e8 d6 fe ff ff       	call   8015ea <fd2sockid>
  801714:	85 c0                	test   %eax,%eax
  801716:	78 12                	js     80172a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801718:	83 ec 04             	sub    $0x4,%esp
  80171b:	ff 75 10             	push   0x10(%ebp)
  80171e:	ff 75 0c             	push   0xc(%ebp)
  801721:	50                   	push   %eax
  801722:	e8 59 01 00 00       	call   801880 <nsipc_connect>
  801727:	83 c4 10             	add    $0x10,%esp
}
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <listen>:
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	e8 b0 fe ff ff       	call   8015ea <fd2sockid>
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 0f                	js     80174d <listen+0x21>
	return nsipc_listen(r, backlog);
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	ff 75 0c             	push   0xc(%ebp)
  801744:	50                   	push   %eax
  801745:	e8 6b 01 00 00       	call   8018b5 <nsipc_listen>
  80174a:	83 c4 10             	add    $0x10,%esp
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <socket>:

int
socket(int domain, int type, int protocol)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801755:	ff 75 10             	push   0x10(%ebp)
  801758:	ff 75 0c             	push   0xc(%ebp)
  80175b:	ff 75 08             	push   0x8(%ebp)
  80175e:	e8 41 02 00 00       	call   8019a4 <nsipc_socket>
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 05                	js     80176f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80176a:	e8 ab fe ff ff       	call   80161a <alloc_sockfd>
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	83 ec 04             	sub    $0x4,%esp
  801778:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80177a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801781:	74 26                	je     8017a9 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801783:	6a 07                	push   $0x7
  801785:	68 00 70 80 00       	push   $0x807000
  80178a:	53                   	push   %ebx
  80178b:	ff 35 00 80 80 00    	push   0x808000
  801791:	e8 ac 07 00 00       	call   801f42 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801796:	83 c4 0c             	add    $0xc,%esp
  801799:	6a 00                	push   $0x0
  80179b:	6a 00                	push   $0x0
  80179d:	6a 00                	push   $0x0
  80179f:	e8 2e 07 00 00       	call   801ed2 <ipc_recv>
}
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017a9:	83 ec 0c             	sub    $0xc,%esp
  8017ac:	6a 02                	push   $0x2
  8017ae:	e8 e3 07 00 00       	call   801f96 <ipc_find_env>
  8017b3:	a3 00 80 80 00       	mov    %eax,0x808000
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	eb c6                	jmp    801783 <nsipc+0x12>

008017bd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017cd:	8b 06                	mov    (%esi),%eax
  8017cf:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d9:	e8 93 ff ff ff       	call   801771 <nsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	79 09                	jns    8017ed <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	ff 35 10 70 80 00    	push   0x807010
  8017f6:	68 00 70 80 00       	push   $0x807000
  8017fb:	ff 75 0c             	push   0xc(%ebp)
  8017fe:	e8 c3 f0 ff ff       	call   8008c6 <memmove>
		*addrlen = ret->ret_addrlen;
  801803:	a1 10 70 80 00       	mov    0x807010,%eax
  801808:	89 06                	mov    %eax,(%esi)
  80180a:	83 c4 10             	add    $0x10,%esp
	return r;
  80180d:	eb d5                	jmp    8017e4 <nsipc_accept+0x27>

0080180f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801821:	53                   	push   %ebx
  801822:	ff 75 0c             	push   0xc(%ebp)
  801825:	68 04 70 80 00       	push   $0x807004
  80182a:	e8 97 f0 ff ff       	call   8008c6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80182f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801835:	b8 02 00 00 00       	mov    $0x2,%eax
  80183a:	e8 32 ff ff ff       	call   801771 <nsipc>
}
  80183f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801842:	c9                   	leave  
  801843:	c3                   	ret    

00801844 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801852:	8b 45 0c             	mov    0xc(%ebp),%eax
  801855:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80185a:	b8 03 00 00 00       	mov    $0x3,%eax
  80185f:	e8 0d ff ff ff       	call   801771 <nsipc>
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <nsipc_close>:

int
nsipc_close(int s)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801874:	b8 04 00 00 00       	mov    $0x4,%eax
  801879:	e8 f3 fe ff ff       	call   801771 <nsipc>
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801892:	53                   	push   %ebx
  801893:	ff 75 0c             	push   0xc(%ebp)
  801896:	68 04 70 80 00       	push   $0x807004
  80189b:	e8 26 f0 ff ff       	call   8008c6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018a0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8018a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ab:	e8 c1 fe ff ff       	call   801771 <nsipc>
}
  8018b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d0:	e8 9c fe ff ff       	call   801771 <nsipc>
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018df:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018e7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018f5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018fa:	e8 72 fe ff ff       	call   801771 <nsipc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	85 c0                	test   %eax,%eax
  801903:	78 22                	js     801927 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801905:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80190a:	39 c6                	cmp    %eax,%esi
  80190c:	0f 4e c6             	cmovle %esi,%eax
  80190f:	39 c3                	cmp    %eax,%ebx
  801911:	7f 1d                	jg     801930 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801913:	83 ec 04             	sub    $0x4,%esp
  801916:	53                   	push   %ebx
  801917:	68 00 70 80 00       	push   $0x807000
  80191c:	ff 75 0c             	push   0xc(%ebp)
  80191f:	e8 a2 ef ff ff       	call   8008c6 <memmove>
  801924:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801927:	89 d8                	mov    %ebx,%eax
  801929:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801930:	68 9b 26 80 00       	push   $0x80269b
  801935:	68 63 26 80 00       	push   $0x802663
  80193a:	6a 62                	push   $0x62
  80193c:	68 b0 26 80 00       	push   $0x8026b0
  801941:	e8 46 05 00 00       	call   801e8c <_panic>

00801946 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	53                   	push   %ebx
  80194a:	83 ec 04             	sub    $0x4,%esp
  80194d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801950:	8b 45 08             	mov    0x8(%ebp),%eax
  801953:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801958:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80195e:	7f 2e                	jg     80198e <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	53                   	push   %ebx
  801964:	ff 75 0c             	push   0xc(%ebp)
  801967:	68 0c 70 80 00       	push   $0x80700c
  80196c:	e8 55 ef ff ff       	call   8008c6 <memmove>
	nsipcbuf.send.req_size = size;
  801971:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801977:	8b 45 14             	mov    0x14(%ebp),%eax
  80197a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80197f:	b8 08 00 00 00       	mov    $0x8,%eax
  801984:	e8 e8 fd ff ff       	call   801771 <nsipc>
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    
	assert(size < 1600);
  80198e:	68 bc 26 80 00       	push   $0x8026bc
  801993:	68 63 26 80 00       	push   $0x802663
  801998:	6a 6d                	push   $0x6d
  80199a:	68 b0 26 80 00       	push   $0x8026b0
  80199f:	e8 e8 04 00 00       	call   801e8c <_panic>

008019a4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bd:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019c2:	b8 09 00 00 00       	mov    $0x9,%eax
  8019c7:	e8 a5 fd ff ff       	call   801771 <nsipc>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	ff 75 08             	push   0x8(%ebp)
  8019dc:	e8 ad f3 ff ff       	call   800d8e <fd2data>
  8019e1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	68 c8 26 80 00       	push   $0x8026c8
  8019eb:	53                   	push   %ebx
  8019ec:	e8 3f ed ff ff       	call   800730 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f1:	8b 46 04             	mov    0x4(%esi),%eax
  8019f4:	2b 06                	sub    (%esi),%eax
  8019f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a03:	00 00 00 
	stat->st_dev = &devpipe;
  801a06:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a0d:	30 80 00 
	return 0;
}
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
  801a15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a26:	53                   	push   %ebx
  801a27:	6a 00                	push   $0x0
  801a29:	e8 83 f1 ff ff       	call   800bb1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2e:	89 1c 24             	mov    %ebx,(%esp)
  801a31:	e8 58 f3 ff ff       	call   800d8e <fd2data>
  801a36:	83 c4 08             	add    $0x8,%esp
  801a39:	50                   	push   %eax
  801a3a:	6a 00                	push   $0x0
  801a3c:	e8 70 f1 ff ff       	call   800bb1 <sys_page_unmap>
}
  801a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <_pipeisclosed>:
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	57                   	push   %edi
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 1c             	sub    $0x1c,%esp
  801a4f:	89 c7                	mov    %eax,%edi
  801a51:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a53:	a1 00 40 80 00       	mov    0x804000,%eax
  801a58:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	57                   	push   %edi
  801a5f:	e8 71 05 00 00       	call   801fd5 <pageref>
  801a64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a67:	89 34 24             	mov    %esi,(%esp)
  801a6a:	e8 66 05 00 00       	call   801fd5 <pageref>
		nn = thisenv->env_runs;
  801a6f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a75:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	39 cb                	cmp    %ecx,%ebx
  801a7d:	74 1b                	je     801a9a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a7f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a82:	75 cf                	jne    801a53 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a84:	8b 42 68             	mov    0x68(%edx),%eax
  801a87:	6a 01                	push   $0x1
  801a89:	50                   	push   %eax
  801a8a:	53                   	push   %ebx
  801a8b:	68 cf 26 80 00       	push   $0x8026cf
  801a90:	e8 c1 e6 ff ff       	call   800156 <cprintf>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	eb b9                	jmp    801a53 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a9a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a9d:	0f 94 c0             	sete   %al
  801aa0:	0f b6 c0             	movzbl %al,%eax
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devpipe_write>:
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 28             	sub    $0x28,%esp
  801ab4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ab7:	56                   	push   %esi
  801ab8:	e8 d1 f2 ff ff       	call   800d8e <fd2data>
  801abd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aca:	75 09                	jne    801ad5 <devpipe_write+0x2a>
	return i;
  801acc:	89 f8                	mov    %edi,%eax
  801ace:	eb 23                	jmp    801af3 <devpipe_write+0x48>
			sys_yield();
  801ad0:	e8 38 f0 ff ff       	call   800b0d <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad8:	8b 0b                	mov    (%ebx),%ecx
  801ada:	8d 51 20             	lea    0x20(%ecx),%edx
  801add:	39 d0                	cmp    %edx,%eax
  801adf:	72 1a                	jb     801afb <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ae1:	89 da                	mov    %ebx,%edx
  801ae3:	89 f0                	mov    %esi,%eax
  801ae5:	e8 5c ff ff ff       	call   801a46 <_pipeisclosed>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	74 e2                	je     801ad0 <devpipe_write+0x25>
				return 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	c1 fa 1f             	sar    $0x1f,%edx
  801b0a:	89 d1                	mov    %edx,%ecx
  801b0c:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b12:	83 e2 1f             	and    $0x1f,%edx
  801b15:	29 ca                	sub    %ecx,%edx
  801b17:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1f:	83 c0 01             	add    $0x1,%eax
  801b22:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b25:	83 c7 01             	add    $0x1,%edi
  801b28:	eb 9d                	jmp    801ac7 <devpipe_write+0x1c>

00801b2a <devpipe_read>:
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	57                   	push   %edi
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 18             	sub    $0x18,%esp
  801b33:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b36:	57                   	push   %edi
  801b37:	e8 52 f2 ff ff       	call   800d8e <fd2data>
  801b3c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	be 00 00 00 00       	mov    $0x0,%esi
  801b46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b49:	75 13                	jne    801b5e <devpipe_read+0x34>
	return i;
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	eb 02                	jmp    801b51 <devpipe_read+0x27>
				return i;
  801b4f:	89 f0                	mov    %esi,%eax
}
  801b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5f                   	pop    %edi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    
			sys_yield();
  801b59:	e8 af ef ff ff       	call   800b0d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b5e:	8b 03                	mov    (%ebx),%eax
  801b60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b63:	75 18                	jne    801b7d <devpipe_read+0x53>
			if (i > 0)
  801b65:	85 f6                	test   %esi,%esi
  801b67:	75 e6                	jne    801b4f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b69:	89 da                	mov    %ebx,%edx
  801b6b:	89 f8                	mov    %edi,%eax
  801b6d:	e8 d4 fe ff ff       	call   801a46 <_pipeisclosed>
  801b72:	85 c0                	test   %eax,%eax
  801b74:	74 e3                	je     801b59 <devpipe_read+0x2f>
				return 0;
  801b76:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7b:	eb d4                	jmp    801b51 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7d:	99                   	cltd   
  801b7e:	c1 ea 1b             	shr    $0x1b,%edx
  801b81:	01 d0                	add    %edx,%eax
  801b83:	83 e0 1f             	and    $0x1f,%eax
  801b86:	29 d0                	sub    %edx,%eax
  801b88:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b90:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b93:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b96:	83 c6 01             	add    $0x1,%esi
  801b99:	eb ab                	jmp    801b46 <devpipe_read+0x1c>

00801b9b <pipe>:
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba6:	50                   	push   %eax
  801ba7:	e8 f9 f1 ff ff       	call   800da5 <fd_alloc>
  801bac:	89 c3                	mov    %eax,%ebx
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 23 01 00 00    	js     801cdc <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb9:	83 ec 04             	sub    $0x4,%esp
  801bbc:	68 07 04 00 00       	push   $0x407
  801bc1:	ff 75 f4             	push   -0xc(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 61 ef ff ff       	call   800b2c <sys_page_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 04 01 00 00    	js     801cdc <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	e8 c1 f1 ff ff       	call   800da5 <fd_alloc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	0f 88 db 00 00 00    	js     801ccc <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf1:	83 ec 04             	sub    $0x4,%esp
  801bf4:	68 07 04 00 00       	push   $0x407
  801bf9:	ff 75 f0             	push   -0x10(%ebp)
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 29 ef ff ff       	call   800b2c <sys_page_alloc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 88 bc 00 00 00    	js     801ccc <pipe+0x131>
	va = fd2data(fd0);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 f4             	push   -0xc(%ebp)
  801c16:	e8 73 f1 ff ff       	call   800d8e <fd2data>
  801c1b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1d:	83 c4 0c             	add    $0xc,%esp
  801c20:	68 07 04 00 00       	push   $0x407
  801c25:	50                   	push   %eax
  801c26:	6a 00                	push   $0x0
  801c28:	e8 ff ee ff ff       	call   800b2c <sys_page_alloc>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	0f 88 82 00 00 00    	js     801cbc <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	ff 75 f0             	push   -0x10(%ebp)
  801c40:	e8 49 f1 ff ff       	call   800d8e <fd2data>
  801c45:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4c:	50                   	push   %eax
  801c4d:	6a 00                	push   $0x0
  801c4f:	56                   	push   %esi
  801c50:	6a 00                	push   $0x0
  801c52:	e8 18 ef ff ff       	call   800b6f <sys_page_map>
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	83 c4 20             	add    $0x20,%esp
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	78 4e                	js     801cae <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c60:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c68:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c77:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	ff 75 f4             	push   -0xc(%ebp)
  801c89:	e8 f0 f0 ff ff       	call   800d7e <fd2num>
  801c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c91:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c93:	83 c4 04             	add    $0x4,%esp
  801c96:	ff 75 f0             	push   -0x10(%ebp)
  801c99:	e8 e0 f0 ff ff       	call   800d7e <fd2num>
  801c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cac:	eb 2e                	jmp    801cdc <pipe+0x141>
	sys_page_unmap(0, va);
  801cae:	83 ec 08             	sub    $0x8,%esp
  801cb1:	56                   	push   %esi
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 f8 ee ff ff       	call   800bb1 <sys_page_unmap>
  801cb9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	ff 75 f0             	push   -0x10(%ebp)
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 e8 ee ff ff       	call   800bb1 <sys_page_unmap>
  801cc9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ccc:	83 ec 08             	sub    $0x8,%esp
  801ccf:	ff 75 f4             	push   -0xc(%ebp)
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 d8 ee ff ff       	call   800bb1 <sys_page_unmap>
  801cd9:	83 c4 10             	add    $0x10,%esp
}
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <pipeisclosed>:
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	ff 75 08             	push   0x8(%ebp)
  801cf2:	e8 fe f0 ff ff       	call   800df5 <fd_lookup>
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 18                	js     801d16 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	push   -0xc(%ebp)
  801d04:	e8 85 f0 ff ff       	call   800d8e <fd2data>
  801d09:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	e8 33 fd ff ff       	call   801a46 <_pipeisclosed>
  801d13:	83 c4 10             	add    $0x10,%esp
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1d:	c3                   	ret    

00801d1e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d24:	68 e7 26 80 00       	push   $0x8026e7
  801d29:	ff 75 0c             	push   0xc(%ebp)
  801d2c:	e8 ff e9 ff ff       	call   800730 <strcpy>
	return 0;
}
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
  801d36:	c9                   	leave  
  801d37:	c3                   	ret    

00801d38 <devcons_write>:
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d44:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d49:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d4f:	eb 2e                	jmp    801d7f <devcons_write+0x47>
		m = n - tot;
  801d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d54:	29 f3                	sub    %esi,%ebx
  801d56:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d5b:	39 c3                	cmp    %eax,%ebx
  801d5d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d60:	83 ec 04             	sub    $0x4,%esp
  801d63:	53                   	push   %ebx
  801d64:	89 f0                	mov    %esi,%eax
  801d66:	03 45 0c             	add    0xc(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	57                   	push   %edi
  801d6b:	e8 56 eb ff ff       	call   8008c6 <memmove>
		sys_cputs(buf, m);
  801d70:	83 c4 08             	add    $0x8,%esp
  801d73:	53                   	push   %ebx
  801d74:	57                   	push   %edi
  801d75:	e8 f6 ec ff ff       	call   800a70 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d7a:	01 de                	add    %ebx,%esi
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d82:	72 cd                	jb     801d51 <devcons_write+0x19>
}
  801d84:	89 f0                	mov    %esi,%eax
  801d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <devcons_read>:
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9d:	75 07                	jne    801da6 <devcons_read+0x18>
  801d9f:	eb 1f                	jmp    801dc0 <devcons_read+0x32>
		sys_yield();
  801da1:	e8 67 ed ff ff       	call   800b0d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801da6:	e8 e3 ec ff ff       	call   800a8e <sys_cgetc>
  801dab:	85 c0                	test   %eax,%eax
  801dad:	74 f2                	je     801da1 <devcons_read+0x13>
	if (c < 0)
  801daf:	78 0f                	js     801dc0 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801db1:	83 f8 04             	cmp    $0x4,%eax
  801db4:	74 0c                	je     801dc2 <devcons_read+0x34>
	*(char*)vbuf = c;
  801db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db9:	88 02                	mov    %al,(%edx)
	return 1;
  801dbb:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    
		return 0;
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc7:	eb f7                	jmp    801dc0 <devcons_read+0x32>

00801dc9 <cputchar>:
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dd5:	6a 01                	push   $0x1
  801dd7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	e8 90 ec ff ff       	call   800a70 <sys_cputs>
}
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <getchar>:
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801deb:	6a 01                	push   $0x1
  801ded:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df0:	50                   	push   %eax
  801df1:	6a 00                	push   $0x0
  801df3:	e8 66 f2 ff ff       	call   80105e <read>
	if (r < 0)
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 06                	js     801e05 <getchar+0x20>
	if (r < 1)
  801dff:	74 06                	je     801e07 <getchar+0x22>
	return c;
  801e01:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    
		return -E_EOF;
  801e07:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e0c:	eb f7                	jmp    801e05 <getchar+0x20>

00801e0e <iscons>:
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e17:	50                   	push   %eax
  801e18:	ff 75 08             	push   0x8(%ebp)
  801e1b:	e8 d5 ef ff ff       	call   800df5 <fd_lookup>
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 11                	js     801e38 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e30:	39 10                	cmp    %edx,(%eax)
  801e32:	0f 94 c0             	sete   %al
  801e35:	0f b6 c0             	movzbl %al,%eax
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <opencons>:
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	e8 5c ef ff ff       	call   800da5 <fd_alloc>
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 3a                	js     801e8a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e50:	83 ec 04             	sub    $0x4,%esp
  801e53:	68 07 04 00 00       	push   $0x407
  801e58:	ff 75 f4             	push   -0xc(%ebp)
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 ca ec ff ff       	call   800b2c <sys_page_alloc>
  801e62:	83 c4 10             	add    $0x10,%esp
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 21                	js     801e8a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e72:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e77:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	50                   	push   %eax
  801e82:	e8 f7 ee ff ff       	call   800d7e <fd2num>
  801e87:	83 c4 10             	add    $0x10,%esp
}
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	56                   	push   %esi
  801e90:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e91:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e94:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e9a:	e8 4f ec ff ff       	call   800aee <sys_getenvid>
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	ff 75 0c             	push   0xc(%ebp)
  801ea5:	ff 75 08             	push   0x8(%ebp)
  801ea8:	56                   	push   %esi
  801ea9:	50                   	push   %eax
  801eaa:	68 f4 26 80 00       	push   $0x8026f4
  801eaf:	e8 a2 e2 ff ff       	call   800156 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eb4:	83 c4 18             	add    $0x18,%esp
  801eb7:	53                   	push   %ebx
  801eb8:	ff 75 10             	push   0x10(%ebp)
  801ebb:	e8 45 e2 ff ff       	call   800105 <vcprintf>
	cprintf("\n");
  801ec0:	c7 04 24 e0 26 80 00 	movl   $0x8026e0,(%esp)
  801ec7:	e8 8a e2 ff ff       	call   800156 <cprintf>
  801ecc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ecf:	cc                   	int3   
  801ed0:	eb fd                	jmp    801ecf <_panic+0x43>

00801ed2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	56                   	push   %esi
  801ed6:	53                   	push   %ebx
  801ed7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee7:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	50                   	push   %eax
  801eee:	e8 e9 ed ff ff       	call   800cdc <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	85 f6                	test   %esi,%esi
  801ef8:	74 17                	je     801f11 <ipc_recv+0x3f>
  801efa:	ba 00 00 00 00       	mov    $0x0,%edx
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 0c                	js     801f0f <ipc_recv+0x3d>
  801f03:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f09:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f0f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f11:	85 db                	test   %ebx,%ebx
  801f13:	74 17                	je     801f2c <ipc_recv+0x5a>
  801f15:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 0c                	js     801f2a <ipc_recv+0x58>
  801f1e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f24:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f2a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	78 0b                	js     801f3b <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f30:	a1 00 40 80 00       	mov    0x804000,%eax
  801f35:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3e:	5b                   	pop    %ebx
  801f3f:	5e                   	pop    %esi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 0c             	sub    $0xc,%esp
  801f4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f54:	85 db                	test   %ebx,%ebx
  801f56:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f5b:	0f 44 d8             	cmove  %eax,%ebx
  801f5e:	eb 05                	jmp    801f65 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f60:	e8 a8 eb ff ff       	call   800b0d <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f65:	ff 75 14             	push   0x14(%ebp)
  801f68:	53                   	push   %ebx
  801f69:	56                   	push   %esi
  801f6a:	57                   	push   %edi
  801f6b:	e8 49 ed ff ff       	call   800cb9 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f76:	74 e8                	je     801f60 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 08                	js     801f84 <ipc_send+0x42>
	}while (r<0);

}
  801f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f84:	50                   	push   %eax
  801f85:	68 17 27 80 00       	push   $0x802717
  801f8a:	6a 3d                	push   $0x3d
  801f8c:	68 2b 27 80 00       	push   $0x80272b
  801f91:	e8 f6 fe ff ff       	call   801e8c <_panic>

00801f96 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa1:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801fa7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fad:	8b 52 60             	mov    0x60(%edx),%edx
  801fb0:	39 ca                	cmp    %ecx,%edx
  801fb2:	74 11                	je     801fc5 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fb4:	83 c0 01             	add    $0x1,%eax
  801fb7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbc:	75 e3                	jne    801fa1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc3:	eb 0e                	jmp    801fd3 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fc5:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd0:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdb:	89 c2                	mov    %eax,%edx
  801fdd:	c1 ea 16             	shr    $0x16,%edx
  801fe0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fe7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fec:	f6 c1 01             	test   $0x1,%cl
  801fef:	74 1c                	je     80200d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ff1:	c1 e8 0c             	shr    $0xc,%eax
  801ff4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ffb:	a8 01                	test   $0x1,%al
  801ffd:	74 0e                	je     80200d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fff:	c1 e8 0c             	shr    $0xc,%eax
  802002:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802009:	ef 
  80200a:	0f b7 d2             	movzwl %dx,%edx
}
  80200d:	89 d0                	mov    %edx,%eax
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    
  802011:	66 90                	xchg   %ax,%ax
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
