
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
	call libmain
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 32 00 00 00       	call   800071 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80004c:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	b9 00 00 00 00       	mov    $0x0,%ecx
  800059:	99                   	cltd   
  80005a:	f7 f9                	idiv   %ecx
  80005c:	50                   	push   %eax
  80005d:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  800063:	50                   	push   %eax
  800064:	e8 23 01 00 00       	call   80018c <cprintf>
}
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006f:	c9                   	leave  
  800070:	c3                   	ret    

00800071 <__x86.get_pc_thunk.bx>:
  800071:	8b 1c 24             	mov    (%esp),%ebx
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	53                   	push   %ebx
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	e8 f0 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800081:	81 c3 7f 1f 00 00    	add    $0x1f7f,%ebx
  800087:	8b 45 08             	mov    0x8(%ebp),%eax
  80008a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008d:	c7 83 30 00 00 00 00 	movl   $0x0,0x30(%ebx)
  800094:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 c0                	test   %eax,%eax
  800099:	7e 08                	jle    8000a3 <libmain+0x2e>
		binaryname = argv[0];
  80009b:	8b 0a                	mov    (%edx),%ecx
  80009d:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a3:	83 ec 08             	sub    $0x8,%esp
  8000a6:	52                   	push   %edx
  8000a7:	50                   	push   %eax
  8000a8:	e8 86 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ad:	e8 08 00 00 00       	call   8000ba <exit>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	53                   	push   %ebx
  8000be:	83 ec 10             	sub    $0x10,%esp
  8000c1:	e8 ab ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000c6:	81 c3 3a 1f 00 00    	add    $0x1f3a,%ebx
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 a2 0a 00 00       	call   800b75 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
  8000e0:	e8 8c ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000e5:	81 c3 1b 1f 00 00    	add    $0x1f1b,%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000ee:	8b 16                	mov    (%esi),%edx
  8000f0:	8d 42 01             	lea    0x1(%edx),%eax
  8000f3:	89 06                	mov    %eax,(%esi)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800101:	74 0b                	je     80010e <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800103:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	68 ff 00 00 00       	push   $0xff
  800116:	8d 46 08             	lea    0x8(%esi),%eax
  800119:	50                   	push   %eax
  80011a:	e8 19 0a 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  80011f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	eb d9                	jmp    800103 <putch+0x28>

0080012a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	53                   	push   %ebx
  80012e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800134:	e8 38 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800139:	81 c3 c7 1e 00 00    	add    $0x1ec7,%ebx
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
  800160:	8d 83 db e0 ff ff    	lea    -0x1f25(%ebx),%eax
  800166:	50                   	push   %eax
  800167:	e8 2c 01 00 00       	call   800298 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016c:	83 c4 08             	add    $0x8,%esp
  80016f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800175:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	e8 b7 09 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800181:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	push   0x8(%ebp)
  800199:	e8 8c ff ff ff       	call   80012a <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 2c             	sub    $0x2c,%esp
  8001a9:	e8 0b 06 00 00       	call   8007b9 <__x86.get_pc_thunk.cx>
  8001ae:	81 c1 52 1e 00 00    	add    $0x1e52,%ecx
  8001b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001b7:	89 c7                	mov    %eax,%edi
  8001b9:	89 d6                	mov    %edx,%esi
  8001bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c1:	89 d1                	mov    %edx,%ecx
  8001c3:	89 c2                	mov    %eax,%edx
  8001c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001db:	39 c2                	cmp    %eax,%edx
  8001dd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e0:	72 41                	jb     800223 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	ff 75 18             	push   0x18(%ebp)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	53                   	push   %ebx
  8001ec:	50                   	push   %eax
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 e4             	push   -0x1c(%ebp)
  8001f3:	ff 75 e0             	push   -0x20(%ebp)
  8001f6:	ff 75 d4             	push   -0x2c(%ebp)
  8001f9:	ff 75 d0             	push   -0x30(%ebp)
  8001fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001ff:	e8 4c 0a 00 00       	call   800c50 <__udivdi3>
  800204:	83 c4 18             	add    $0x18,%esp
  800207:	52                   	push   %edx
  800208:	50                   	push   %eax
  800209:	89 f2                	mov    %esi,%edx
  80020b:	89 f8                	mov    %edi,%eax
  80020d:	e8 8e ff ff ff       	call   8001a0 <printnum>
  800212:	83 c4 20             	add    $0x20,%esp
  800215:	eb 13                	jmp    80022a <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	56                   	push   %esi
  80021b:	ff 75 18             	push   0x18(%ebp)
  80021e:	ff d7                	call   *%edi
  800220:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	85 db                	test   %ebx,%ebx
  800228:	7f ed                	jg     800217 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	83 ec 04             	sub    $0x4,%esp
  800231:	ff 75 e4             	push   -0x1c(%ebp)
  800234:	ff 75 e0             	push   -0x20(%ebp)
  800237:	ff 75 d4             	push   -0x2c(%ebp)
  80023a:	ff 75 d0             	push   -0x30(%ebp)
  80023d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800240:	e8 2b 0b 00 00       	call   800d70 <__umoddi3>
  800245:	83 c4 14             	add    $0x14,%esp
  800248:	0f be 84 03 9c ee ff 	movsbl -0x1164(%ebx,%eax,1),%eax
  80024f:	ff 
  800250:	50                   	push   %eax
  800251:	ff d7                	call   *%edi
}
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800264:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	3b 50 04             	cmp    0x4(%eax),%edx
  80026d:	73 0a                	jae    800279 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	88 02                	mov    %al,(%edx)
}
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <printfmt>:
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800281:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800284:	50                   	push   %eax
  800285:	ff 75 10             	push   0x10(%ebp)
  800288:	ff 75 0c             	push   0xc(%ebp)
  80028b:	ff 75 08             	push   0x8(%ebp)
  80028e:	e8 05 00 00 00       	call   800298 <vprintfmt>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <vprintfmt>:
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 3c             	sub    $0x3c,%esp
  8002a1:	e8 0f 05 00 00       	call   8007b5 <__x86.get_pc_thunk.ax>
  8002a6:	05 5a 1d 00 00       	add    $0x1d5a,%eax
  8002ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002b7:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002bd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c0:	eb 0a                	jmp    8002cc <vprintfmt+0x34>
			putch(ch, putdat);
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	57                   	push   %edi
  8002c6:	50                   	push   %eax
  8002c7:	ff d6                	call   *%esi
  8002c9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cc:	83 c3 01             	add    $0x1,%ebx
  8002cf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002d3:	83 f8 25             	cmp    $0x25,%eax
  8002d6:	74 0c                	je     8002e4 <vprintfmt+0x4c>
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	75 e6                	jne    8002c2 <vprintfmt+0x2a>
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    
		padc = ' ';
  8002e4:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002e8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002ef:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f6:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800302:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800305:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8d 43 01             	lea    0x1(%ebx),%eax
  80030b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030e:	0f b6 13             	movzbl (%ebx),%edx
  800311:	8d 42 dd             	lea    -0x23(%edx),%eax
  800314:	3c 55                	cmp    $0x55,%al
  800316:	0f 87 fd 03 00 00    	ja     800719 <.L20>
  80031c:	0f b6 c0             	movzbl %al,%eax
  80031f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800322:	89 ce                	mov    %ecx,%esi
  800324:	03 b4 81 2c ef ff ff 	add    -0x10d4(%ecx,%eax,4),%esi
  80032b:	ff e6                	jmp    *%esi

0080032d <.L68>:
  80032d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800330:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800334:	eb d2                	jmp    800308 <vprintfmt+0x70>

00800336 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800339:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80033d:	eb c9                	jmp    800308 <vprintfmt+0x70>

0080033f <.L31>:
  80033f:	0f b6 d2             	movzbl %dl,%edx
  800342:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800345:	b8 00 00 00 00       	mov    $0x0,%eax
  80034a:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80034d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800350:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800354:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800357:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035a:	83 f9 09             	cmp    $0x9,%ecx
  80035d:	77 58                	ja     8003b7 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80035f:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800362:	eb e9                	jmp    80034d <.L31+0xe>

00800364 <.L34>:
			precision = va_arg(ap, int);
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8b 00                	mov    (%eax),%eax
  800369:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	8d 40 04             	lea    0x4(%eax),%eax
  800372:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800378:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80037c:	79 8a                	jns    800308 <vprintfmt+0x70>
				width = precision, precision = -1;
  80037e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800381:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800384:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038b:	e9 78 ff ff ff       	jmp    800308 <vprintfmt+0x70>

00800390 <.L33>:
  800390:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800393:	85 d2                	test   %edx,%edx
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
  80039a:	0f 49 c2             	cmovns %edx,%eax
  80039d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a3:	e9 60 ff ff ff       	jmp    800308 <vprintfmt+0x70>

008003a8 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003ab:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003b2:	e9 51 ff ff ff       	jmp    800308 <vprintfmt+0x70>
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8003bd:	eb b9                	jmp    800378 <.L34+0x14>

008003bf <.L27>:
			lflag++;
  8003bf:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003c6:	e9 3d ff ff ff       	jmp    800308 <vprintfmt+0x70>

008003cb <.L30>:
			putch(va_arg(ap, int), putdat);
  8003cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 58 04             	lea    0x4(%eax),%ebx
  8003d4:	83 ec 08             	sub    $0x8,%esp
  8003d7:	57                   	push   %edi
  8003d8:	ff 30                	push   (%eax)
  8003da:	ff d6                	call   *%esi
			break;
  8003dc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003df:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003e2:	e9 c8 02 00 00       	jmp    8006af <.L25+0x45>

008003e7 <.L28>:
			err = va_arg(ap, int);
  8003e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 58 04             	lea    0x4(%eax),%ebx
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	89 d0                	mov    %edx,%eax
  8003f4:	f7 d8                	neg    %eax
  8003f6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f9:	83 f8 06             	cmp    $0x6,%eax
  8003fc:	7f 27                	jg     800425 <.L28+0x3e>
  8003fe:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800401:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	74 1d                	je     800425 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800408:	52                   	push   %edx
  800409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040c:	8d 80 bd ee ff ff    	lea    -0x1143(%eax),%eax
  800412:	50                   	push   %eax
  800413:	57                   	push   %edi
  800414:	56                   	push   %esi
  800415:	e8 61 fe ff ff       	call   80027b <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041d:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800420:	e9 8a 02 00 00       	jmp    8006af <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800425:	50                   	push   %eax
  800426:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800429:	8d 80 b4 ee ff ff    	lea    -0x114c(%eax),%eax
  80042f:	50                   	push   %eax
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	e8 44 fe ff ff       	call   80027b <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043a:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 6d 02 00 00       	jmp    8006af <.L25+0x45>

00800442 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 75 08             	mov    0x8(%ebp),%esi
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	83 c0 04             	add    $0x4,%eax
  80044b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800453:	85 d2                	test   %edx,%edx
  800455:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800458:	8d 80 ad ee ff ff    	lea    -0x1153(%eax),%eax
  80045e:	0f 45 c2             	cmovne %edx,%eax
  800461:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800464:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800468:	7e 06                	jle    800470 <.L24+0x2e>
  80046a:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80046e:	75 0d                	jne    80047d <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800473:	89 c3                	mov    %eax,%ebx
  800475:	03 45 d4             	add    -0x2c(%ebp),%eax
  800478:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80047b:	eb 58                	jmp    8004d5 <.L24+0x93>
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 d8             	push   -0x28(%ebp)
  800483:	ff 75 c8             	push   -0x38(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	e8 47 03 00 00       	call   8007d5 <strnlen>
  80048e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800491:	29 c2                	sub    %eax,%edx
  800493:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80049b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80049f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	eb 0f                	jmp    8004b3 <.L24+0x71>
					putch(padc, putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	57                   	push   %edi
  8004a8:	ff 75 d4             	push   -0x2c(%ebp)
  8004ab:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	85 db                	test   %ebx,%ebx
  8004b5:	7f ed                	jg     8004a4 <.L24+0x62>
  8004b7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	0f 49 c2             	cmovns %edx,%eax
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004c9:	eb a5                	jmp    800470 <.L24+0x2e>
					putch(ch, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	57                   	push   %edi
  8004cf:	52                   	push   %edx
  8004d0:	ff d6                	call   *%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004d8:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 c3 01             	add    $0x1,%ebx
  8004dd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004e1:	0f be d0             	movsbl %al,%edx
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	74 4b                	je     800533 <.L24+0xf1>
  8004e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ec:	78 06                	js     8004f4 <.L24+0xb2>
  8004ee:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f2:	78 1e                	js     800512 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004f8:	74 d1                	je     8004cb <.L24+0x89>
  8004fa:	0f be c0             	movsbl %al,%eax
  8004fd:	83 e8 20             	sub    $0x20,%eax
  800500:	83 f8 5e             	cmp    $0x5e,%eax
  800503:	76 c6                	jbe    8004cb <.L24+0x89>
					putch('?', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	57                   	push   %edi
  800509:	6a 3f                	push   $0x3f
  80050b:	ff d6                	call   *%esi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb c3                	jmp    8004d5 <.L24+0x93>
  800512:	89 cb                	mov    %ecx,%ebx
  800514:	eb 0e                	jmp    800524 <.L24+0xe2>
				putch(' ', putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	57                   	push   %edi
  80051a:	6a 20                	push   $0x20
  80051c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051e:	83 eb 01             	sub    $0x1,%ebx
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ee                	jg     800516 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800528:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80052b:	89 45 14             	mov    %eax,0x14(%ebp)
  80052e:	e9 7c 01 00 00       	jmp    8006af <.L25+0x45>
  800533:	89 cb                	mov    %ecx,%ebx
  800535:	eb ed                	jmp    800524 <.L24+0xe2>

00800537 <.L29>:
	if (lflag >= 2)
  800537:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	83 f9 01             	cmp    $0x1,%ecx
  800540:	7f 1b                	jg     80055d <.L29+0x26>
	else if (lflag)
  800542:	85 c9                	test   %ecx,%ecx
  800544:	74 63                	je     8005a9 <.L29+0x72>
		return va_arg(*ap, long);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	99                   	cltd   
  80054f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb 17                	jmp    800574 <.L29+0x3d>
		return va_arg(*ap, long long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 50 04             	mov    0x4(%eax),%edx
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 40 08             	lea    0x8(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800574:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800577:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80057a:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80057f:	85 db                	test   %ebx,%ebx
  800581:	0f 89 0e 01 00 00    	jns    800695 <.L25+0x2b>
				putch('-', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	6a 2d                	push   $0x2d
  80058d:	ff d6                	call   *%esi
				num = -(long long) num;
  80058f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800592:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800595:	f7 d9                	neg    %ecx
  800597:	83 d3 00             	adc    $0x0,%ebx
  80059a:	f7 db                	neg    %ebx
  80059c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059f:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005a4:	e9 ec 00 00 00       	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	99                   	cltd   
  8005b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005be:	eb b4                	jmp    800574 <.L29+0x3d>

008005c0 <.L23>:
	if (lflag >= 2)
  8005c0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	83 f9 01             	cmp    $0x1,%ecx
  8005c9:	7f 1e                	jg     8005e9 <.L23+0x29>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	74 32                	je     800601 <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 08                	mov    (%eax),%ecx
  8005d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005df:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005e4:	e9 ac 00 00 00       	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 08                	mov    (%eax),%ecx
  8005ee:	8b 58 04             	mov    0x4(%eax),%ebx
  8005f1:	8d 40 08             	lea    0x8(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005fc:	e9 94 00 00 00       	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 08                	mov    (%eax),%ecx
  800606:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060b:	8d 40 04             	lea    0x4(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800611:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800616:	eb 7d                	jmp    800695 <.L25+0x2b>

00800618 <.L26>:
	if (lflag >= 2)
  800618:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	83 f9 01             	cmp    $0x1,%ecx
  800621:	7f 1b                	jg     80063e <.L26+0x26>
	else if (lflag)
  800623:	85 c9                	test   %ecx,%ecx
  800625:	74 2c                	je     800653 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 08                	mov    (%eax),%ecx
  80062c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800637:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  80063c:	eb 57                	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 08                	mov    (%eax),%ecx
  800643:	8b 58 04             	mov    0x4(%eax),%ebx
  800646:	8d 40 08             	lea    0x8(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064c:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  800651:	eb 42                	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 08                	mov    (%eax),%ecx
  800658:	bb 00 00 00 00       	mov    $0x0,%ebx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800663:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  800668:	eb 2b                	jmp    800695 <.L25+0x2b>

0080066a <.L25>:
			putch('0', putdat);
  80066a:	8b 75 08             	mov    0x8(%ebp),%esi
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	57                   	push   %edi
  800671:	6a 30                	push   $0x30
  800673:	ff d6                	call   *%esi
			putch('x', putdat);
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	57                   	push   %edi
  800679:	6a 78                	push   $0x78
  80067b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 08                	mov    (%eax),%ecx
  800682:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800687:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068a:	8d 40 04             	lea    0x4(%eax),%eax
  80068d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800690:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800695:	83 ec 0c             	sub    $0xc,%esp
  800698:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80069c:	50                   	push   %eax
  80069d:	ff 75 d4             	push   -0x2c(%ebp)
  8006a0:	52                   	push   %edx
  8006a1:	53                   	push   %ebx
  8006a2:	51                   	push   %ecx
  8006a3:	89 fa                	mov    %edi,%edx
  8006a5:	89 f0                	mov    %esi,%eax
  8006a7:	e8 f4 fa ff ff       	call   8001a0 <printnum>
			break;
  8006ac:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b2:	e9 15 fc ff ff       	jmp    8002cc <vprintfmt+0x34>

008006b7 <.L21>:
	if (lflag >= 2)
  8006b7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bd:	83 f9 01             	cmp    $0x1,%ecx
  8006c0:	7f 1b                	jg     8006dd <.L21+0x26>
	else if (lflag)
  8006c2:	85 c9                	test   %ecx,%ecx
  8006c4:	74 2c                	je     8006f2 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 08                	mov    (%eax),%ecx
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006db:	eb b8                	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 08                	mov    (%eax),%ecx
  8006e2:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e5:	8d 40 08             	lea    0x8(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006eb:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006f0:	eb a3                	jmp    800695 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 08                	mov    (%eax),%ecx
  8006f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800702:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  800707:	eb 8c                	jmp    800695 <.L25+0x2b>

00800709 <.L35>:
			putch(ch, putdat);
  800709:	8b 75 08             	mov    0x8(%ebp),%esi
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	57                   	push   %edi
  800710:	6a 25                	push   $0x25
  800712:	ff d6                	call   *%esi
			break;
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 96                	jmp    8006af <.L25+0x45>

00800719 <.L20>:
			putch('%', putdat);
  800719:	8b 75 08             	mov    0x8(%ebp),%esi
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	57                   	push   %edi
  800720:	6a 25                	push   $0x25
  800722:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	89 d8                	mov    %ebx,%eax
  800729:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072d:	74 05                	je     800734 <.L20+0x1b>
  80072f:	83 e8 01             	sub    $0x1,%eax
  800732:	eb f5                	jmp    800729 <.L20+0x10>
  800734:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800737:	e9 73 ff ff ff       	jmp    8006af <.L25+0x45>

0080073c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	83 ec 14             	sub    $0x14,%esp
  800743:	e8 29 f9 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800748:	81 c3 b8 18 00 00    	add    $0x18b8,%ebx
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800754:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800757:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800765:	85 c0                	test   %eax,%eax
  800767:	74 2b                	je     800794 <vsnprintf+0x58>
  800769:	85 d2                	test   %edx,%edx
  80076b:	7e 27                	jle    800794 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076d:	ff 75 14             	push   0x14(%ebp)
  800770:	ff 75 10             	push   0x10(%ebp)
  800773:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	8d 83 5e e2 ff ff    	lea    -0x1da2(%ebx),%eax
  80077d:	50                   	push   %eax
  80077e:	e8 15 fb ff ff       	call   800298 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800786:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	83 c4 10             	add    $0x10,%esp
}
  80078f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800792:	c9                   	leave  
  800793:	c3                   	ret    
		return -E_INVAL;
  800794:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800799:	eb f4                	jmp    80078f <vsnprintf+0x53>

0080079b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a4:	50                   	push   %eax
  8007a5:	ff 75 10             	push   0x10(%ebp)
  8007a8:	ff 75 0c             	push   0xc(%ebp)
  8007ab:	ff 75 08             	push   0x8(%ebp)
  8007ae:	e8 89 ff ff ff       	call   80073c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <__x86.get_pc_thunk.ax>:
  8007b5:	8b 04 24             	mov    (%esp),%eax
  8007b8:	c3                   	ret    

008007b9 <__x86.get_pc_thunk.cx>:
  8007b9:	8b 0c 24             	mov    (%esp),%ecx
  8007bc:	c3                   	ret    

008007bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	eb 03                	jmp    8007cd <strlen+0x10>
		n++;
  8007ca:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d1:	75 f7                	jne    8007ca <strlen+0xd>
	return n;
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strnlen+0x13>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e8:	39 d0                	cmp    %edx,%eax
  8007ea:	74 08                	je     8007f4 <strnlen+0x1f>
  8007ec:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f0:	75 f3                	jne    8007e5 <strnlen+0x10>
  8007f2:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f4:	89 d0                	mov    %edx,%eax
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80080b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	84 d2                	test   %dl,%dl
  800813:	75 f2                	jne    800807 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	89 c8                	mov    %ecx,%eax
  800817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	83 ec 10             	sub    $0x10,%esp
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800826:	53                   	push   %ebx
  800827:	e8 91 ff ff ff       	call   8007bd <strlen>
  80082c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80082f:	ff 75 0c             	push   0xc(%ebp)
  800832:	01 d8                	add    %ebx,%eax
  800834:	50                   	push   %eax
  800835:	e8 be ff ff ff       	call   8007f8 <strcpy>
	return dst;
}
  80083a:	89 d8                	mov    %ebx,%eax
  80083c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 75 08             	mov    0x8(%ebp),%esi
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 f3                	mov    %esi,%ebx
  80084e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	89 f0                	mov    %esi,%eax
  800853:	eb 0f                	jmp    800864 <strncpy+0x23>
		*dst++ = *src;
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	0f b6 0a             	movzbl (%edx),%ecx
  80085b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085e:	80 f9 01             	cmp    $0x1,%cl
  800861:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	75 ed                	jne    800855 <strncpy+0x14>
	}
	return ret;
}
  800868:	89 f0                	mov    %esi,%eax
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 75 08             	mov    0x8(%ebp),%esi
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
  80087c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087e:	85 d2                	test   %edx,%edx
  800880:	74 21                	je     8008a3 <strlcpy+0x35>
  800882:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800886:	89 f2                	mov    %esi,%edx
  800888:	eb 09                	jmp    800893 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	83 c1 01             	add    $0x1,%ecx
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 09                	je     8008a0 <strlcpy+0x32>
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	84 db                	test   %bl,%bl
  80089c:	75 ec                	jne    80088a <strlcpy+0x1c>
  80089e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a3:	29 f0                	sub    %esi,%eax
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strcmp+0x11>
		p++, q++;
  8008b4:	83 c1 01             	add    $0x1,%ecx
  8008b7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x1c>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	74 ef                	je     8008b4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d9:	89 c3                	mov    %eax,%ebx
  8008db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008de:	eb 06                	jmp    8008e6 <strncmp+0x17>
		n--, p++, q++;
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e6:	39 d8                	cmp    %ebx,%eax
  8008e8:	74 18                	je     800902 <strncmp+0x33>
  8008ea:	0f b6 08             	movzbl (%eax),%ecx
  8008ed:	84 c9                	test   %cl,%cl
  8008ef:	74 04                	je     8008f5 <strncmp+0x26>
  8008f1:	3a 0a                	cmp    (%edx),%cl
  8008f3:	74 eb                	je     8008e0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 00             	movzbl (%eax),%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    
		return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
  800907:	eb f4                	jmp    8008fd <strncmp+0x2e>

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	eb 03                	jmp    800918 <strchr+0xf>
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
  80091b:	84 d2                	test   %dl,%dl
  80091d:	74 06                	je     800925 <strchr+0x1c>
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	75 f2                	jne    800915 <strchr+0xc>
  800923:	eb 05                	jmp    80092a <strchr+0x21>
			return (char *) s;
	return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800936:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 09                	je     800946 <strfind+0x1a>
  80093d:	84 d2                	test   %dl,%dl
  80093f:	74 05                	je     800946 <strfind+0x1a>
	for (; *s; s++)
  800941:	83 c0 01             	add    $0x1,%eax
  800944:	eb f0                	jmp    800936 <strfind+0xa>
			break;
	return (char *) s;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 2f                	je     800987 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800958:	89 f8                	mov    %edi,%eax
  80095a:	09 c8                	or     %ecx,%eax
  80095c:	a8 03                	test   $0x3,%al
  80095e:	75 21                	jne    800981 <memset+0x39>
		c &= 0xFF;
  800960:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800964:	89 d0                	mov    %edx,%eax
  800966:	c1 e0 08             	shl    $0x8,%eax
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 18             	shl    $0x18,%ebx
  80096e:	89 d6                	mov    %edx,%esi
  800970:	c1 e6 10             	shl    $0x10,%esi
  800973:	09 f3                	or     %esi,%ebx
  800975:	09 da                	or     %ebx,%edx
  800977:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800979:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097c:	fc                   	cld    
  80097d:	f3 ab                	rep stos %eax,%es:(%edi)
  80097f:	eb 06                	jmp    800987 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	fc                   	cld    
  800985:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800987:	89 f8                	mov    %edi,%eax
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 32                	jae    8009d2 <memmove+0x44>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 c2                	cmp    %eax,%edx
  8009a5:	76 2b                	jbe    8009d2 <memmove+0x44>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	09 fe                	or     %edi,%esi
  8009ae:	09 ce                	or     %ecx,%esi
  8009b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b6:	75 0e                	jne    8009c6 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b8:	83 ef 04             	sub    $0x4,%edi
  8009bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c1:	fd                   	std    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 09                	jmp    8009cf <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c6:	83 ef 01             	sub    $0x1,%edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 1a                	jmp    8009ec <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	89 f2                	mov    %esi,%edx
  8009d4:	09 c2                	or     %eax,%edx
  8009d6:	09 ca                	or     %ecx,%edx
  8009d8:	f6 c2 03             	test   $0x3,%dl
  8009db:	75 0a                	jne    8009e7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 05                	jmp    8009ec <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009e7:	89 c7                	mov    %eax,%edi
  8009e9:	fc                   	cld    
  8009ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f6:	ff 75 10             	push   0x10(%ebp)
  8009f9:	ff 75 0c             	push   0xc(%ebp)
  8009fc:	ff 75 08             	push   0x8(%ebp)
  8009ff:	e8 8a ff ff ff       	call   80098e <memmove>
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a11:	89 c6                	mov    %eax,%esi
  800a13:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	eb 06                	jmp    800a1e <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a1e:	39 f0                	cmp    %esi,%eax
  800a20:	74 14                	je     800a36 <memcmp+0x30>
		if (*s1 != *s2)
  800a22:	0f b6 08             	movzbl (%eax),%ecx
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	38 d9                	cmp    %bl,%cl
  800a2a:	74 ec                	je     800a18 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a2c:	0f b6 c1             	movzbl %cl,%eax
  800a2f:	0f b6 db             	movzbl %bl,%ebx
  800a32:	29 d8                	sub    %ebx,%eax
  800a34:	eb 05                	jmp    800a3b <memcmp+0x35>
	}

	return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a48:	89 c2                	mov    %eax,%edx
  800a4a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4d:	eb 03                	jmp    800a52 <memfind+0x13>
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	39 d0                	cmp    %edx,%eax
  800a54:	73 04                	jae    800a5a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	75 f5                	jne    800a4f <memfind+0x10>
			break;
	return (void *) s;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 03                	jmp    800a6d <strtol+0x11>
		s++;
  800a6a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a6d:	0f b6 02             	movzbl (%edx),%eax
  800a70:	3c 20                	cmp    $0x20,%al
  800a72:	74 f6                	je     800a6a <strtol+0xe>
  800a74:	3c 09                	cmp    $0x9,%al
  800a76:	74 f2                	je     800a6a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a78:	3c 2b                	cmp    $0x2b,%al
  800a7a:	74 2a                	je     800aa6 <strtol+0x4a>
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	74 2b                	je     800ab0 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a85:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8b:	75 0f                	jne    800a9c <strtol+0x40>
  800a8d:	80 3a 30             	cmpb   $0x30,(%edx)
  800a90:	74 28                	je     800aba <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a99:	0f 44 d8             	cmove  %eax,%ebx
  800a9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa4:	eb 46                	jmp    800aec <strtol+0x90>
		s++;
  800aa6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb d5                	jmp    800a85 <strtol+0x29>
		s++, neg = 1;
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab8:	eb cb                	jmp    800a85 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abe:	74 0e                	je     800ace <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ac0:	85 db                	test   %ebx,%ebx
  800ac2:	75 d8                	jne    800a9c <strtol+0x40>
		s++, base = 8;
  800ac4:	83 c2 01             	add    $0x1,%edx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800acc:	eb ce                	jmp    800a9c <strtol+0x40>
		s += 2, base = 16;
  800ace:	83 c2 02             	add    $0x2,%edx
  800ad1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad6:	eb c4                	jmp    800a9c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad8:	0f be c0             	movsbl %al,%eax
  800adb:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ade:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ae1:	7d 3a                	jge    800b1d <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aea:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aec:	0f b6 02             	movzbl (%edx),%eax
  800aef:	8d 70 d0             	lea    -0x30(%eax),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 09             	cmp    $0x9,%bl
  800af7:	76 df                	jbe    800ad8 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800af9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 08                	ja     800b0b <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b03:	0f be c0             	movsbl %al,%eax
  800b06:	83 e8 57             	sub    $0x57,%eax
  800b09:	eb d3                	jmp    800ade <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 08                	ja     800b1d <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b15:	0f be c0             	movsbl %al,%eax
  800b18:	83 e8 37             	sub    $0x37,%eax
  800b1b:	eb c1                	jmp    800ade <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b21:	74 05                	je     800b28 <strtol+0xcc>
		*endptr = (char *) s;
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b28:	89 c8                	mov    %ecx,%eax
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 45 c8             	cmovne %eax,%ecx
}
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 1c             	sub    $0x1c,%esp
  800b7e:	e8 32 fc ff ff       	call   8007b5 <__x86.get_pc_thunk.ax>
  800b83:	05 7d 14 00 00       	add    $0x147d,%eax
  800b88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	b8 03 00 00 00       	mov    $0x3,%eax
  800b98:	89 cb                	mov    %ecx,%ebx
  800b9a:	89 cf                	mov    %ecx,%edi
  800b9c:	89 ce                	mov    %ecx,%esi
  800b9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7f 08                	jg     800bac <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 03                	push   $0x3
  800bb2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bb5:	8d 83 84 f0 ff ff    	lea    -0xf7c(%ebx),%eax
  800bbb:	50                   	push   %eax
  800bbc:	6a 23                	push   $0x23
  800bbe:	8d 83 a1 f0 ff ff    	lea    -0xf5f(%ebx),%eax
  800bc4:	50                   	push   %eax
  800bc5:	e8 1f 00 00 00       	call   800be9 <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	e8 7a f4 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800bf7:	81 c3 09 14 00 00    	add    $0x1409,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bfd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c00:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c06:	8b 38                	mov    (%eax),%edi
  800c08:	e8 bd ff ff ff       	call   800bca <sys_getenvid>
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	ff 75 0c             	push   0xc(%ebp)
  800c13:	ff 75 08             	push   0x8(%ebp)
  800c16:	57                   	push   %edi
  800c17:	50                   	push   %eax
  800c18:	8d 83 b0 f0 ff ff    	lea    -0xf50(%ebx),%eax
  800c1e:	50                   	push   %eax
  800c1f:	e8 68 f5 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c24:	83 c4 18             	add    $0x18,%esp
  800c27:	56                   	push   %esi
  800c28:	ff 75 10             	push   0x10(%ebp)
  800c2b:	e8 fa f4 ff ff       	call   80012a <vcprintf>
	cprintf("\n");
  800c30:	8d 83 90 ee ff ff    	lea    -0x1170(%ebx),%eax
  800c36:	89 04 24             	mov    %eax,(%esp)
  800c39:	e8 4e f5 ff ff       	call   80018c <cprintf>
  800c3e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c41:	cc                   	int3   
  800c42:	eb fd                	jmp    800c41 <_panic+0x58>
  800c44:	66 90                	xchg   %ax,%ax
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	66 90                	xchg   %ax,%ax
  800c4a:	66 90                	xchg   %ax,%ax
  800c4c:	66 90                	xchg   %ax,%ax
  800c4e:	66 90                	xchg   %ax,%ax

00800c50 <__udivdi3>:
  800c50:	f3 0f 1e fb          	endbr32 
  800c54:	55                   	push   %ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 1c             	sub    $0x1c,%esp
  800c5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	75 19                	jne    800c88 <__udivdi3+0x38>
  800c6f:	39 f3                	cmp    %esi,%ebx
  800c71:	76 4d                	jbe    800cc0 <__udivdi3+0x70>
  800c73:	31 ff                	xor    %edi,%edi
  800c75:	89 e8                	mov    %ebp,%eax
  800c77:	89 f2                	mov    %esi,%edx
  800c79:	f7 f3                	div    %ebx
  800c7b:	89 fa                	mov    %edi,%edx
  800c7d:	83 c4 1c             	add    $0x1c,%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    
  800c85:	8d 76 00             	lea    0x0(%esi),%esi
  800c88:	39 f0                	cmp    %esi,%eax
  800c8a:	76 14                	jbe    800ca0 <__udivdi3+0x50>
  800c8c:	31 ff                	xor    %edi,%edi
  800c8e:	31 c0                	xor    %eax,%eax
  800c90:	89 fa                	mov    %edi,%edx
  800c92:	83 c4 1c             	add    $0x1c,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    
  800c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca0:	0f bd f8             	bsr    %eax,%edi
  800ca3:	83 f7 1f             	xor    $0x1f,%edi
  800ca6:	75 48                	jne    800cf0 <__udivdi3+0xa0>
  800ca8:	39 f0                	cmp    %esi,%eax
  800caa:	72 06                	jb     800cb2 <__udivdi3+0x62>
  800cac:	31 c0                	xor    %eax,%eax
  800cae:	39 eb                	cmp    %ebp,%ebx
  800cb0:	77 de                	ja     800c90 <__udivdi3+0x40>
  800cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb7:	eb d7                	jmp    800c90 <__udivdi3+0x40>
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 d9                	mov    %ebx,%ecx
  800cc2:	85 db                	test   %ebx,%ebx
  800cc4:	75 0b                	jne    800cd1 <__udivdi3+0x81>
  800cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccb:	31 d2                	xor    %edx,%edx
  800ccd:	f7 f3                	div    %ebx
  800ccf:	89 c1                	mov    %eax,%ecx
  800cd1:	31 d2                	xor    %edx,%edx
  800cd3:	89 f0                	mov    %esi,%eax
  800cd5:	f7 f1                	div    %ecx
  800cd7:	89 c6                	mov    %eax,%esi
  800cd9:	89 e8                	mov    %ebp,%eax
  800cdb:	89 f7                	mov    %esi,%edi
  800cdd:	f7 f1                	div    %ecx
  800cdf:	89 fa                	mov    %edi,%edx
  800ce1:	83 c4 1c             	add    $0x1c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	89 f9                	mov    %edi,%ecx
  800cf2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cf7:	29 fa                	sub    %edi,%edx
  800cf9:	d3 e0                	shl    %cl,%eax
  800cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	89 d8                	mov    %ebx,%eax
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d09:	09 c1                	or     %eax,%ecx
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d11:	89 f9                	mov    %edi,%ecx
  800d13:	d3 e3                	shl    %cl,%ebx
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 f9                	mov    %edi,%ecx
  800d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d1f:	89 eb                	mov    %ebp,%ebx
  800d21:	d3 e6                	shl    %cl,%esi
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	d3 eb                	shr    %cl,%ebx
  800d27:	09 f3                	or     %esi,%ebx
  800d29:	89 c6                	mov    %eax,%esi
  800d2b:	89 f2                	mov    %esi,%edx
  800d2d:	89 d8                	mov    %ebx,%eax
  800d2f:	f7 74 24 08          	divl   0x8(%esp)
  800d33:	89 d6                	mov    %edx,%esi
  800d35:	89 c3                	mov    %eax,%ebx
  800d37:	f7 64 24 0c          	mull   0xc(%esp)
  800d3b:	39 d6                	cmp    %edx,%esi
  800d3d:	72 19                	jb     800d58 <__udivdi3+0x108>
  800d3f:	89 f9                	mov    %edi,%ecx
  800d41:	d3 e5                	shl    %cl,%ebp
  800d43:	39 c5                	cmp    %eax,%ebp
  800d45:	73 04                	jae    800d4b <__udivdi3+0xfb>
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	74 0d                	je     800d58 <__udivdi3+0x108>
  800d4b:	89 d8                	mov    %ebx,%eax
  800d4d:	31 ff                	xor    %edi,%edi
  800d4f:	e9 3c ff ff ff       	jmp    800c90 <__udivdi3+0x40>
  800d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d58:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d5b:	31 ff                	xor    %edi,%edi
  800d5d:	e9 2e ff ff ff       	jmp    800c90 <__udivdi3+0x40>
  800d62:	66 90                	xchg   %ax,%ax
  800d64:	66 90                	xchg   %ax,%ax
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <__umoddi3>:
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 1c             	sub    $0x1c,%esp
  800d7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	89 da                	mov    %ebx,%edx
  800d8f:	85 ff                	test   %edi,%edi
  800d91:	75 15                	jne    800da8 <__umoddi3+0x38>
  800d93:	39 dd                	cmp    %ebx,%ebp
  800d95:	76 39                	jbe    800dd0 <__umoddi3+0x60>
  800d97:	f7 f5                	div    %ebp
  800d99:	89 d0                	mov    %edx,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	83 c4 1c             	add    $0x1c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi
  800da8:	39 df                	cmp    %ebx,%edi
  800daa:	77 f1                	ja     800d9d <__umoddi3+0x2d>
  800dac:	0f bd cf             	bsr    %edi,%ecx
  800daf:	83 f1 1f             	xor    $0x1f,%ecx
  800db2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800db6:	75 40                	jne    800df8 <__umoddi3+0x88>
  800db8:	39 df                	cmp    %ebx,%edi
  800dba:	72 04                	jb     800dc0 <__umoddi3+0x50>
  800dbc:	39 f5                	cmp    %esi,%ebp
  800dbe:	77 dd                	ja     800d9d <__umoddi3+0x2d>
  800dc0:	89 da                	mov    %ebx,%edx
  800dc2:	89 f0                	mov    %esi,%eax
  800dc4:	29 e8                	sub    %ebp,%eax
  800dc6:	19 fa                	sbb    %edi,%edx
  800dc8:	eb d3                	jmp    800d9d <__umoddi3+0x2d>
  800dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd0:	89 e9                	mov    %ebp,%ecx
  800dd2:	85 ed                	test   %ebp,%ebp
  800dd4:	75 0b                	jne    800de1 <__umoddi3+0x71>
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	f7 f5                	div    %ebp
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	89 d8                	mov    %ebx,%eax
  800de3:	31 d2                	xor    %edx,%edx
  800de5:	f7 f1                	div    %ecx
  800de7:	89 f0                	mov    %esi,%eax
  800de9:	f7 f1                	div    %ecx
  800deb:	89 d0                	mov    %edx,%eax
  800ded:	31 d2                	xor    %edx,%edx
  800def:	eb ac                	jmp    800d9d <__umoddi3+0x2d>
  800df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dfc:	ba 20 00 00 00       	mov    $0x20,%edx
  800e01:	29 c2                	sub    %eax,%edx
  800e03:	89 c1                	mov    %eax,%ecx
  800e05:	89 e8                	mov    %ebp,%eax
  800e07:	d3 e7                	shl    %cl,%edi
  800e09:	89 d1                	mov    %edx,%ecx
  800e0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e0f:	d3 e8                	shr    %cl,%eax
  800e11:	89 c1                	mov    %eax,%ecx
  800e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e17:	09 f9                	or     %edi,%ecx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	d3 e5                	shl    %cl,%ebp
  800e23:	89 d1                	mov    %edx,%ecx
  800e25:	d3 ef                	shr    %cl,%edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	d3 e3                	shl    %cl,%ebx
  800e2d:	89 d1                	mov    %edx,%ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	d3 e8                	shr    %cl,%eax
  800e33:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e38:	09 d8                	or     %ebx,%eax
  800e3a:	f7 74 24 08          	divl   0x8(%esp)
  800e3e:	89 d3                	mov    %edx,%ebx
  800e40:	d3 e6                	shl    %cl,%esi
  800e42:	f7 e5                	mul    %ebp
  800e44:	89 c7                	mov    %eax,%edi
  800e46:	89 d1                	mov    %edx,%ecx
  800e48:	39 d3                	cmp    %edx,%ebx
  800e4a:	72 06                	jb     800e52 <__umoddi3+0xe2>
  800e4c:	75 0e                	jne    800e5c <__umoddi3+0xec>
  800e4e:	39 c6                	cmp    %eax,%esi
  800e50:	73 0a                	jae    800e5c <__umoddi3+0xec>
  800e52:	29 e8                	sub    %ebp,%eax
  800e54:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e58:	89 d1                	mov    %edx,%ecx
  800e5a:	89 c7                	mov    %eax,%edi
  800e5c:	89 f5                	mov    %esi,%ebp
  800e5e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e62:	29 fd                	sub    %edi,%ebp
  800e64:	19 cb                	sbb    %ecx,%ebx
  800e66:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e6b:	89 d8                	mov    %ebx,%eax
  800e6d:	d3 e0                	shl    %cl,%eax
  800e6f:	89 f1                	mov    %esi,%ecx
  800e71:	d3 ed                	shr    %cl,%ebp
  800e73:	d3 eb                	shr    %cl,%ebx
  800e75:	09 e8                	or     %ebp,%eax
  800e77:	89 da                	mov    %ebx,%edx
  800e79:	83 c4 1c             	add    $0x1c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    
