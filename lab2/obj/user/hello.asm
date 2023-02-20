
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 3e 01 00 00       	call   80018f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 92 ee ff ff    	lea    -0x116e(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 23 01 00 00       	call   80018f <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	53                   	push   %ebx
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	e8 f0 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800084:	81 c3 7c 1f 00 00    	add    $0x1f7c,%ebx
  80008a:	8b 45 08             	mov    0x8(%ebp),%eax
  80008d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800090:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800097:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	85 c0                	test   %eax,%eax
  80009c:	7e 08                	jle    8000a6 <libmain+0x2e>
		binaryname = argv[0];
  80009e:	8b 0a                	mov    (%edx),%ecx
  8000a0:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a6:	83 ec 08             	sub    $0x8,%esp
  8000a9:	52                   	push   %edx
  8000aa:	50                   	push   %eax
  8000ab:	e8 83 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b0:	e8 08 00 00 00       	call   8000bd <exit>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	53                   	push   %ebx
  8000c1:	83 ec 10             	sub    $0x10,%esp
  8000c4:	e8 ab ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000c9:	81 c3 37 1f 00 00    	add    $0x1f37,%ebx
	sys_env_destroy(0);
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 a2 0a 00 00       	call   800b78 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	e8 8c ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e8:	81 c3 18 1f 00 00    	add    $0x1f18,%ebx
  8000ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f1:	8b 16                	mov    (%esi),%edx
  8000f3:	8d 42 01             	lea    0x1(%edx),%eax
  8000f6:	89 06                	mov    %eax,(%esi)
  8000f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fb:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800104:	74 0b                	je     800111 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800106:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 46 08             	lea    0x8(%esi),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 19 0a 00 00       	call   800b3b <sys_cputs>
		b->idx = 0;
  800122:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	eb d9                	jmp    800106 <putch+0x28>

0080012d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	53                   	push   %ebx
  800131:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800137:	e8 38 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80013c:	81 c3 c4 1e 00 00    	add    $0x1ec4,%ebx
	struct printbuf b;

	b.idx = 0;
  800142:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800149:	00 00 00 
	b.cnt = 0;
  80014c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800153:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800156:	ff 75 0c             	push   0xc(%ebp)
  800159:	ff 75 08             	push   0x8(%ebp)
  80015c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800162:	50                   	push   %eax
  800163:	8d 83 de e0 ff ff    	lea    -0x1f22(%ebx),%eax
  800169:	50                   	push   %eax
  80016a:	e8 2c 01 00 00       	call   80029b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 b7 09 00 00       	call   800b3b <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800195:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800198:	50                   	push   %eax
  800199:	ff 75 08             	push   0x8(%ebp)
  80019c:	e8 8c ff ff ff       	call   80012d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 2c             	sub    $0x2c,%esp
  8001ac:	e8 0b 06 00 00       	call   8007bc <__x86.get_pc_thunk.cx>
  8001b1:	81 c1 4f 1e 00 00    	add    $0x1e4f,%ecx
  8001b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ba:	89 c7                	mov    %eax,%edi
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c4:	89 d1                	mov    %edx,%ecx
  8001c6:	89 c2                	mov    %eax,%edx
  8001c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001cb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001de:	39 c2                	cmp    %eax,%edx
  8001e0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e3:	72 41                	jb     800226 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	ff 75 18             	push   0x18(%ebp)
  8001eb:	83 eb 01             	sub    $0x1,%ebx
  8001ee:	53                   	push   %ebx
  8001ef:	50                   	push   %eax
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	ff 75 e4             	push   -0x1c(%ebp)
  8001f6:	ff 75 e0             	push   -0x20(%ebp)
  8001f9:	ff 75 d4             	push   -0x2c(%ebp)
  8001fc:	ff 75 d0             	push   -0x30(%ebp)
  8001ff:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800202:	e8 49 0a 00 00       	call   800c50 <__udivdi3>
  800207:	83 c4 18             	add    $0x18,%esp
  80020a:	52                   	push   %edx
  80020b:	50                   	push   %eax
  80020c:	89 f2                	mov    %esi,%edx
  80020e:	89 f8                	mov    %edi,%eax
  800210:	e8 8e ff ff ff       	call   8001a3 <printnum>
  800215:	83 c4 20             	add    $0x20,%esp
  800218:	eb 13                	jmp    80022d <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	56                   	push   %esi
  80021e:	ff 75 18             	push   0x18(%ebp)
  800221:	ff d7                	call   *%edi
  800223:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800226:	83 eb 01             	sub    $0x1,%ebx
  800229:	85 db                	test   %ebx,%ebx
  80022b:	7f ed                	jg     80021a <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	83 ec 04             	sub    $0x4,%esp
  800234:	ff 75 e4             	push   -0x1c(%ebp)
  800237:	ff 75 e0             	push   -0x20(%ebp)
  80023a:	ff 75 d4             	push   -0x2c(%ebp)
  80023d:	ff 75 d0             	push   -0x30(%ebp)
  800240:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800243:	e8 28 0b 00 00       	call   800d70 <__umoddi3>
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	0f be 84 03 b3 ee ff 	movsbl -0x114d(%ebx,%eax,1),%eax
  800252:	ff 
  800253:	50                   	push   %eax
  800254:	ff d7                	call   *%edi
}
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800267:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	3b 50 04             	cmp    0x4(%eax),%edx
  800270:	73 0a                	jae    80027c <sprintputch+0x1b>
		*b->buf++ = ch;
  800272:	8d 4a 01             	lea    0x1(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 45 08             	mov    0x8(%ebp),%eax
  80027a:	88 02                	mov    %al,(%edx)
}
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <printfmt>:
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800284:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800287:	50                   	push   %eax
  800288:	ff 75 10             	push   0x10(%ebp)
  80028b:	ff 75 0c             	push   0xc(%ebp)
  80028e:	ff 75 08             	push   0x8(%ebp)
  800291:	e8 05 00 00 00       	call   80029b <vprintfmt>
}
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <vprintfmt>:
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	57                   	push   %edi
  80029f:	56                   	push   %esi
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 3c             	sub    $0x3c,%esp
  8002a4:	e8 0f 05 00 00       	call   8007b8 <__x86.get_pc_thunk.ax>
  8002a9:	05 57 1d 00 00       	add    $0x1d57,%eax
  8002ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002ba:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002c0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c3:	eb 0a                	jmp    8002cf <vprintfmt+0x34>
			putch(ch, putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	57                   	push   %edi
  8002c9:	50                   	push   %eax
  8002ca:	ff d6                	call   *%esi
  8002cc:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cf:	83 c3 01             	add    $0x1,%ebx
  8002d2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002d6:	83 f8 25             	cmp    $0x25,%eax
  8002d9:	74 0c                	je     8002e7 <vprintfmt+0x4c>
			if (ch == '\0')
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	75 e6                	jne    8002c5 <vprintfmt+0x2a>
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    
		padc = ' ';
  8002e7:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002eb:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  800300:	b9 00 00 00 00       	mov    $0x0,%ecx
  800305:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800308:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8d 43 01             	lea    0x1(%ebx),%eax
  80030e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800311:	0f b6 13             	movzbl (%ebx),%edx
  800314:	8d 42 dd             	lea    -0x23(%edx),%eax
  800317:	3c 55                	cmp    $0x55,%al
  800319:	0f 87 fd 03 00 00    	ja     80071c <.L20>
  80031f:	0f b6 c0             	movzbl %al,%eax
  800322:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800325:	89 ce                	mov    %ecx,%esi
  800327:	03 b4 81 40 ef ff ff 	add    -0x10c0(%ecx,%eax,4),%esi
  80032e:	ff e6                	jmp    *%esi

00800330 <.L68>:
  800330:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800333:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800337:	eb d2                	jmp    80030b <vprintfmt+0x70>

00800339 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80033c:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800340:	eb c9                	jmp    80030b <vprintfmt+0x70>

00800342 <.L31>:
  800342:	0f b6 d2             	movzbl %dl,%edx
  800345:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800348:	b8 00 00 00 00       	mov    $0x0,%eax
  80034d:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800350:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800353:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800357:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80035a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035d:	83 f9 09             	cmp    $0x9,%ecx
  800360:	77 58                	ja     8003ba <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800362:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800365:	eb e9                	jmp    800350 <.L31+0xe>

00800367 <.L34>:
			precision = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8d 40 04             	lea    0x4(%eax),%eax
  800375:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80037b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80037f:	79 8a                	jns    80030b <vprintfmt+0x70>
				width = precision, precision = -1;
  800381:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800384:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800387:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038e:	e9 78 ff ff ff       	jmp    80030b <vprintfmt+0x70>

00800393 <.L33>:
  800393:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800396:	85 d2                	test   %edx,%edx
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	0f 49 c2             	cmovns %edx,%eax
  8003a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a6:	e9 60 ff ff ff       	jmp    80030b <vprintfmt+0x70>

008003ab <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003ae:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003b5:	e9 51 ff ff ff       	jmp    80030b <vprintfmt+0x70>
  8003ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8003c0:	eb b9                	jmp    80037b <.L34+0x14>

008003c2 <.L27>:
			lflag++;
  8003c2:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003c9:	e9 3d ff ff ff       	jmp    80030b <vprintfmt+0x70>

008003ce <.L30>:
			putch(va_arg(ap, int), putdat);
  8003ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 58 04             	lea    0x4(%eax),%ebx
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	57                   	push   %edi
  8003db:	ff 30                	push   (%eax)
  8003dd:	ff d6                	call   *%esi
			break;
  8003df:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e2:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003e5:	e9 c8 02 00 00       	jmp    8006b2 <.L25+0x45>

008003ea <.L28>:
			err = va_arg(ap, int);
  8003ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 58 04             	lea    0x4(%eax),%ebx
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	89 d0                	mov    %edx,%eax
  8003f7:	f7 d8                	neg    %eax
  8003f9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fc:	83 f8 06             	cmp    $0x6,%eax
  8003ff:	7f 27                	jg     800428 <.L28+0x3e>
  800401:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800404:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800407:	85 d2                	test   %edx,%edx
  800409:	74 1d                	je     800428 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  80040b:	52                   	push   %edx
  80040c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040f:	8d 80 d4 ee ff ff    	lea    -0x112c(%eax),%eax
  800415:	50                   	push   %eax
  800416:	57                   	push   %edi
  800417:	56                   	push   %esi
  800418:	e8 61 fe ff ff       	call   80027e <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800423:	e9 8a 02 00 00       	jmp    8006b2 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800428:	50                   	push   %eax
  800429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042c:	8d 80 cb ee ff ff    	lea    -0x1135(%eax),%eax
  800432:	50                   	push   %eax
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	e8 44 fe ff ff       	call   80027e <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043d:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 6d 02 00 00       	jmp    8006b2 <.L25+0x45>

00800445 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800445:	8b 75 08             	mov    0x8(%ebp),%esi
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	83 c0 04             	add    $0x4,%eax
  80044e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800456:	85 d2                	test   %edx,%edx
  800458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045b:	8d 80 c4 ee ff ff    	lea    -0x113c(%eax),%eax
  800461:	0f 45 c2             	cmovne %edx,%eax
  800464:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800467:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046b:	7e 06                	jle    800473 <.L24+0x2e>
  80046d:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800471:	75 0d                	jne    800480 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800476:	89 c3                	mov    %eax,%ebx
  800478:	03 45 d4             	add    -0x2c(%ebp),%eax
  80047b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80047e:	eb 58                	jmp    8004d8 <.L24+0x93>
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 d8             	push   -0x28(%ebp)
  800486:	ff 75 c8             	push   -0x38(%ebp)
  800489:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048c:	e8 47 03 00 00       	call   8007d8 <strnlen>
  800491:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80049e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8004a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	eb 0f                	jmp    8004b6 <.L24+0x71>
					putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	57                   	push   %edi
  8004ab:	ff 75 d4             	push   -0x2c(%ebp)
  8004ae:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	83 eb 01             	sub    $0x1,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 db                	test   %ebx,%ebx
  8004b8:	7f ed                	jg     8004a7 <.L24+0x62>
  8004ba:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c4:	0f 49 c2             	cmovns %edx,%eax
  8004c7:	29 c2                	sub    %eax,%edx
  8004c9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004cc:	eb a5                	jmp    800473 <.L24+0x2e>
					putch(ch, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	57                   	push   %edi
  8004d2:	52                   	push   %edx
  8004d3:	ff d6                	call   *%esi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004db:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	83 c3 01             	add    $0x1,%ebx
  8004e0:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004e4:	0f be d0             	movsbl %al,%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	74 4b                	je     800536 <.L24+0xf1>
  8004eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ef:	78 06                	js     8004f7 <.L24+0xb2>
  8004f1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f5:	78 1e                	js     800515 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004fb:	74 d1                	je     8004ce <.L24+0x89>
  8004fd:	0f be c0             	movsbl %al,%eax
  800500:	83 e8 20             	sub    $0x20,%eax
  800503:	83 f8 5e             	cmp    $0x5e,%eax
  800506:	76 c6                	jbe    8004ce <.L24+0x89>
					putch('?', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	57                   	push   %edi
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff d6                	call   *%esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb c3                	jmp    8004d8 <.L24+0x93>
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 0e                	jmp    800527 <.L24+0xe2>
				putch(' ', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	57                   	push   %edi
  80051d:	6a 20                	push   $0x20
  80051f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 db                	test   %ebx,%ebx
  800529:	7f ee                	jg     800519 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80052e:	89 45 14             	mov    %eax,0x14(%ebp)
  800531:	e9 7c 01 00 00       	jmp    8006b2 <.L25+0x45>
  800536:	89 cb                	mov    %ecx,%ebx
  800538:	eb ed                	jmp    800527 <.L24+0xe2>

0080053a <.L29>:
	if (lflag >= 2)
  80053a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	83 f9 01             	cmp    $0x1,%ecx
  800543:	7f 1b                	jg     800560 <.L29+0x26>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 63                	je     8005ac <.L29+0x72>
		return va_arg(*ap, long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	99                   	cltd   
  800552:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	eb 17                	jmp    800577 <.L29+0x3d>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 50 04             	mov    0x4(%eax),%edx
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 40 08             	lea    0x8(%eax),%eax
  800574:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800577:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80057a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80057d:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800582:	85 db                	test   %ebx,%ebx
  800584:	0f 89 0e 01 00 00    	jns    800698 <.L25+0x2b>
				putch('-', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	57                   	push   %edi
  80058e:	6a 2d                	push   $0x2d
  800590:	ff d6                	call   *%esi
				num = -(long long) num;
  800592:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800595:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800598:	f7 d9                	neg    %ecx
  80059a:	83 d3 00             	adc    $0x0,%ebx
  80059d:	f7 db                	neg    %ebx
  80059f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a2:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005a7:	e9 ec 00 00 00       	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	99                   	cltd   
  8005b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c1:	eb b4                	jmp    800577 <.L29+0x3d>

008005c3 <.L23>:
	if (lflag >= 2)
  8005c3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7f 1e                	jg     8005ec <.L23+0x29>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 32                	je     800604 <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 08                	mov    (%eax),%ecx
  8005d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005e7:	e9 ac 00 00 00       	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 08                	mov    (%eax),%ecx
  8005f1:	8b 58 04             	mov    0x4(%eax),%ebx
  8005f4:	8d 40 08             	lea    0x8(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005ff:	e9 94 00 00 00       	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 08                	mov    (%eax),%ecx
  800609:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800614:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800619:	eb 7d                	jmp    800698 <.L25+0x2b>

0080061b <.L26>:
	if (lflag >= 2)
  80061b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	83 f9 01             	cmp    $0x1,%ecx
  800624:	7f 1b                	jg     800641 <.L26+0x26>
	else if (lflag)
  800626:	85 c9                	test   %ecx,%ecx
  800628:	74 2c                	je     800656 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 08                	mov    (%eax),%ecx
  80062f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063a:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  80063f:	eb 57                	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 08                	mov    (%eax),%ecx
  800646:	8b 58 04             	mov    0x4(%eax),%ebx
  800649:	8d 40 08             	lea    0x8(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064f:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  800654:	eb 42                	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 08                	mov    (%eax),%ecx
  80065b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800666:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  80066b:	eb 2b                	jmp    800698 <.L25+0x2b>

0080066d <.L25>:
			putch('0', putdat);
  80066d:	8b 75 08             	mov    0x8(%ebp),%esi
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	57                   	push   %edi
  800674:	6a 30                	push   $0x30
  800676:	ff d6                	call   *%esi
			putch('x', putdat);
  800678:	83 c4 08             	add    $0x8,%esp
  80067b:	57                   	push   %edi
  80067c:	6a 78                	push   $0x78
  80067e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 08                	mov    (%eax),%ecx
  800685:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80069f:	50                   	push   %eax
  8006a0:	ff 75 d4             	push   -0x2c(%ebp)
  8006a3:	52                   	push   %edx
  8006a4:	53                   	push   %ebx
  8006a5:	51                   	push   %ecx
  8006a6:	89 fa                	mov    %edi,%edx
  8006a8:	89 f0                	mov    %esi,%eax
  8006aa:	e8 f4 fa ff ff       	call   8001a3 <printnum>
			break;
  8006af:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006b2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b5:	e9 15 fc ff ff       	jmp    8002cf <vprintfmt+0x34>

008006ba <.L21>:
	if (lflag >= 2)
  8006ba:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	83 f9 01             	cmp    $0x1,%ecx
  8006c3:	7f 1b                	jg     8006e0 <.L21+0x26>
	else if (lflag)
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	74 2c                	je     8006f5 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 08                	mov    (%eax),%ecx
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006de:	eb b8                	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 08                	mov    (%eax),%ecx
  8006e5:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e8:	8d 40 08             	lea    0x8(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ee:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006f3:	eb a3                	jmp    800698 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 08                	mov    (%eax),%ecx
  8006fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  80070a:	eb 8c                	jmp    800698 <.L25+0x2b>

0080070c <.L35>:
			putch(ch, putdat);
  80070c:	8b 75 08             	mov    0x8(%ebp),%esi
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	57                   	push   %edi
  800713:	6a 25                	push   $0x25
  800715:	ff d6                	call   *%esi
			break;
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 96                	jmp    8006b2 <.L25+0x45>

0080071c <.L20>:
			putch('%', putdat);
  80071c:	8b 75 08             	mov    0x8(%ebp),%esi
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 25                	push   $0x25
  800725:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	89 d8                	mov    %ebx,%eax
  80072c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800730:	74 05                	je     800737 <.L20+0x1b>
  800732:	83 e8 01             	sub    $0x1,%eax
  800735:	eb f5                	jmp    80072c <.L20+0x10>
  800737:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073a:	e9 73 ff ff ff       	jmp    8006b2 <.L25+0x45>

0080073f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	83 ec 14             	sub    $0x14,%esp
  800746:	e8 29 f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80074b:	81 c3 b5 18 00 00    	add    $0x18b5,%ebx
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800757:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800768:	85 c0                	test   %eax,%eax
  80076a:	74 2b                	je     800797 <vsnprintf+0x58>
  80076c:	85 d2                	test   %edx,%edx
  80076e:	7e 27                	jle    800797 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800770:	ff 75 14             	push   0x14(%ebp)
  800773:	ff 75 10             	push   0x10(%ebp)
  800776:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	8d 83 61 e2 ff ff    	lea    -0x1d9f(%ebx),%eax
  800780:	50                   	push   %eax
  800781:	e8 15 fb ff ff       	call   80029b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800786:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800789:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078f:	83 c4 10             	add    $0x10,%esp
}
  800792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800795:	c9                   	leave  
  800796:	c3                   	ret    
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb f4                	jmp    800792 <vsnprintf+0x53>

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	push   0x10(%ebp)
  8007ab:	ff 75 0c             	push   0xc(%ebp)
  8007ae:	ff 75 08             	push   0x8(%ebp)
  8007b1:	e8 89 ff ff ff       	call   80073f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <__x86.get_pc_thunk.ax>:
  8007b8:	8b 04 24             	mov    (%esp),%eax
  8007bb:	c3                   	ret    

008007bc <__x86.get_pc_thunk.cx>:
  8007bc:	8b 0c 24             	mov    (%esp),%ecx
  8007bf:	c3                   	ret    

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strlen+0x10>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d4:	75 f7                	jne    8007cd <strlen+0xd>
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 03                	jmp    8007eb <strnlen+0x13>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 08                	je     8007f7 <strnlen+0x1f>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f3                	jne    8007e8 <strnlen+0x10>
  8007f5:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f7:	89 d0                	mov    %edx,%eax
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80080e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800811:	83 c0 01             	add    $0x1,%eax
  800814:	84 d2                	test   %dl,%dl
  800816:	75 f2                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800818:	89 c8                	mov    %ecx,%eax
  80081a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	83 ec 10             	sub    $0x10,%esp
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800829:	53                   	push   %ebx
  80082a:	e8 91 ff ff ff       	call   8007c0 <strlen>
  80082f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800832:	ff 75 0c             	push   0xc(%ebp)
  800835:	01 d8                	add    %ebx,%eax
  800837:	50                   	push   %eax
  800838:	e8 be ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 f3                	mov    %esi,%ebx
  800851:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	89 f0                	mov    %esi,%eax
  800856:	eb 0f                	jmp    800867 <strncpy+0x23>
		*dst++ = *src;
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	0f b6 0a             	movzbl (%edx),%ecx
  80085e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800861:	80 f9 01             	cmp    $0x1,%cl
  800864:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	75 ed                	jne    800858 <strncpy+0x14>
	}
	return ret;
}
  80086b:	89 f0                	mov    %esi,%eax
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 75 08             	mov    0x8(%ebp),%esi
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087c:	8b 55 10             	mov    0x10(%ebp),%edx
  80087f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800881:	85 d2                	test   %edx,%edx
  800883:	74 21                	je     8008a6 <strlcpy+0x35>
  800885:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800889:	89 f2                	mov    %esi,%edx
  80088b:	eb 09                	jmp    800896 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800896:	39 c2                	cmp    %eax,%edx
  800898:	74 09                	je     8008a3 <strlcpy+0x32>
  80089a:	0f b6 19             	movzbl (%ecx),%ebx
  80089d:	84 db                	test   %bl,%bl
  80089f:	75 ec                	jne    80088d <strlcpy+0x1c>
  8008a1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a6:	29 f0                	sub    %esi,%eax
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b5:	eb 06                	jmp    8008bd <strcmp+0x11>
		p++, q++;
  8008b7:	83 c1 01             	add    $0x1,%ecx
  8008ba:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008bd:	0f b6 01             	movzbl (%ecx),%eax
  8008c0:	84 c0                	test   %al,%al
  8008c2:	74 04                	je     8008c8 <strcmp+0x1c>
  8008c4:	3a 02                	cmp    (%edx),%al
  8008c6:	74 ef                	je     8008b7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 c0             	movzbl %al,%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 c3                	mov    %eax,%ebx
  8008de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e1:	eb 06                	jmp    8008e9 <strncmp+0x17>
		n--, p++, q++;
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e9:	39 d8                	cmp    %ebx,%eax
  8008eb:	74 18                	je     800905 <strncmp+0x33>
  8008ed:	0f b6 08             	movzbl (%eax),%ecx
  8008f0:	84 c9                	test   %cl,%cl
  8008f2:	74 04                	je     8008f8 <strncmp+0x26>
  8008f4:	3a 0a                	cmp    (%edx),%cl
  8008f6:	74 eb                	je     8008e3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800903:	c9                   	leave  
  800904:	c3                   	ret    
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	eb f4                	jmp    800900 <strncmp+0x2e>

0080090c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800916:	eb 03                	jmp    80091b <strchr+0xf>
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	0f b6 10             	movzbl (%eax),%edx
  80091e:	84 d2                	test   %dl,%dl
  800920:	74 06                	je     800928 <strchr+0x1c>
		if (*s == c)
  800922:	38 ca                	cmp    %cl,%dl
  800924:	75 f2                	jne    800918 <strchr+0xc>
  800926:	eb 05                	jmp    80092d <strchr+0x21>
			return (char *) s;
	return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800939:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093c:	38 ca                	cmp    %cl,%dl
  80093e:	74 09                	je     800949 <strfind+0x1a>
  800940:	84 d2                	test   %dl,%dl
  800942:	74 05                	je     800949 <strfind+0x1a>
	for (; *s; s++)
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	eb f0                	jmp    800939 <strfind+0xa>
			break;
	return (char *) s;
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 7d 08             	mov    0x8(%ebp),%edi
  800954:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800957:	85 c9                	test   %ecx,%ecx
  800959:	74 2f                	je     80098a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	09 c8                	or     %ecx,%eax
  80095f:	a8 03                	test   $0x3,%al
  800961:	75 21                	jne    800984 <memset+0x39>
		c &= 0xFF;
  800963:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800967:	89 d0                	mov    %edx,%eax
  800969:	c1 e0 08             	shl    $0x8,%eax
  80096c:	89 d3                	mov    %edx,%ebx
  80096e:	c1 e3 18             	shl    $0x18,%ebx
  800971:	89 d6                	mov    %edx,%esi
  800973:	c1 e6 10             	shl    $0x10,%esi
  800976:	09 f3                	or     %esi,%ebx
  800978:	09 da                	or     %ebx,%edx
  80097a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097f:	fc                   	cld    
  800980:	f3 ab                	rep stos %eax,%es:(%edi)
  800982:	eb 06                	jmp    80098a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800984:	8b 45 0c             	mov    0xc(%ebp),%eax
  800987:	fc                   	cld    
  800988:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098a:	89 f8                	mov    %edi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099f:	39 c6                	cmp    %eax,%esi
  8009a1:	73 32                	jae    8009d5 <memmove+0x44>
  8009a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a6:	39 c2                	cmp    %eax,%edx
  8009a8:	76 2b                	jbe    8009d5 <memmove+0x44>
		s += n;
		d += n;
  8009aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	09 fe                	or     %edi,%esi
  8009b1:	09 ce                	or     %ecx,%esi
  8009b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b9:	75 0e                	jne    8009c9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009bb:	83 ef 04             	sub    $0x4,%edi
  8009be:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c4:	fd                   	std    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 09                	jmp    8009d2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c9:	83 ef 01             	sub    $0x1,%edi
  8009cc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cf:	fd                   	std    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d2:	fc                   	cld    
  8009d3:	eb 1a                	jmp    8009ef <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	89 f2                	mov    %esi,%edx
  8009d7:	09 c2                	or     %eax,%edx
  8009d9:	09 ca                	or     %ecx,%edx
  8009db:	f6 c2 03             	test   $0x3,%dl
  8009de:	75 0a                	jne    8009ea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e8:	eb 05                	jmp    8009ef <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009ea:	89 c7                	mov    %eax,%edi
  8009ec:	fc                   	cld    
  8009ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f9:	ff 75 10             	push   0x10(%ebp)
  8009fc:	ff 75 0c             	push   0xc(%ebp)
  8009ff:	ff 75 08             	push   0x8(%ebp)
  800a02:	e8 8a ff ff ff       	call   800991 <memmove>
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a14:	89 c6                	mov    %eax,%esi
  800a16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	eb 06                	jmp    800a21 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a21:	39 f0                	cmp    %esi,%eax
  800a23:	74 14                	je     800a39 <memcmp+0x30>
		if (*s1 != *s2)
  800a25:	0f b6 08             	movzbl (%eax),%ecx
  800a28:	0f b6 1a             	movzbl (%edx),%ebx
  800a2b:	38 d9                	cmp    %bl,%cl
  800a2d:	74 ec                	je     800a1b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a2f:	0f b6 c1             	movzbl %cl,%eax
  800a32:	0f b6 db             	movzbl %bl,%ebx
  800a35:	29 d8                	sub    %ebx,%eax
  800a37:	eb 05                	jmp    800a3e <memcmp+0x35>
	}

	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a50:	eb 03                	jmp    800a55 <memfind+0x13>
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	39 d0                	cmp    %edx,%eax
  800a57:	73 04                	jae    800a5d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	38 08                	cmp    %cl,(%eax)
  800a5b:	75 f5                	jne    800a52 <memfind+0x10>
			break;
	return (void *) s;
}
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 55 08             	mov    0x8(%ebp),%edx
  800a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	eb 03                	jmp    800a70 <strtol+0x11>
		s++;
  800a6d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a70:	0f b6 02             	movzbl (%edx),%eax
  800a73:	3c 20                	cmp    $0x20,%al
  800a75:	74 f6                	je     800a6d <strtol+0xe>
  800a77:	3c 09                	cmp    $0x9,%al
  800a79:	74 f2                	je     800a6d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a7b:	3c 2b                	cmp    $0x2b,%al
  800a7d:	74 2a                	je     800aa9 <strtol+0x4a>
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a84:	3c 2d                	cmp    $0x2d,%al
  800a86:	74 2b                	je     800ab3 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8e:	75 0f                	jne    800a9f <strtol+0x40>
  800a90:	80 3a 30             	cmpb   $0x30,(%edx)
  800a93:	74 28                	je     800abd <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9c:	0f 44 d8             	cmove  %eax,%ebx
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa7:	eb 46                	jmp    800aef <strtol+0x90>
		s++;
  800aa9:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab1:	eb d5                	jmp    800a88 <strtol+0x29>
		s++, neg = 1;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	bf 01 00 00 00       	mov    $0x1,%edi
  800abb:	eb cb                	jmp    800a88 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac1:	74 0e                	je     800ad1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 d8                	jne    800a9f <strtol+0x40>
		s++, base = 8;
  800ac7:	83 c2 01             	add    $0x1,%edx
  800aca:	bb 08 00 00 00       	mov    $0x8,%ebx
  800acf:	eb ce                	jmp    800a9f <strtol+0x40>
		s += 2, base = 16;
  800ad1:	83 c2 02             	add    $0x2,%edx
  800ad4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad9:	eb c4                	jmp    800a9f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800adb:	0f be c0             	movsbl %al,%eax
  800ade:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ae4:	7d 3a                	jge    800b20 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ae6:	83 c2 01             	add    $0x1,%edx
  800ae9:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aed:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aef:	0f b6 02             	movzbl (%edx),%eax
  800af2:	8d 70 d0             	lea    -0x30(%eax),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 09             	cmp    $0x9,%bl
  800afa:	76 df                	jbe    800adb <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800afc:	8d 70 9f             	lea    -0x61(%eax),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 08                	ja     800b0e <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b06:	0f be c0             	movsbl %al,%eax
  800b09:	83 e8 57             	sub    $0x57,%eax
  800b0c:	eb d3                	jmp    800ae1 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b0e:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	80 fb 19             	cmp    $0x19,%bl
  800b16:	77 08                	ja     800b20 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b18:	0f be c0             	movsbl %al,%eax
  800b1b:	83 e8 37             	sub    $0x37,%eax
  800b1e:	eb c1                	jmp    800ae1 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 05                	je     800b2b <strtol+0xcc>
		*endptr = (char *) s;
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b2b:	89 c8                	mov    %ecx,%eax
  800b2d:	f7 d8                	neg    %eax
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c8             	cmovne %eax,%ecx
}
  800b34:	89 c8                	mov    %ecx,%eax
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	89 c6                	mov    %eax,%esi
  800b52:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 01 00 00 00       	mov    $0x1,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 1c             	sub    $0x1c,%esp
  800b81:	e8 32 fc ff ff       	call   8007b8 <__x86.get_pc_thunk.ax>
  800b86:	05 7a 14 00 00       	add    $0x147a,%eax
  800b8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9b:	89 cb                	mov    %ecx,%ebx
  800b9d:	89 cf                	mov    %ecx,%edi
  800b9f:	89 ce                	mov    %ecx,%esi
  800ba1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7f 08                	jg     800baf <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 03                	push   $0x3
  800bb5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bb8:	8d 83 98 f0 ff ff    	lea    -0xf68(%ebx),%eax
  800bbe:	50                   	push   %eax
  800bbf:	6a 23                	push   $0x23
  800bc1:	8d 83 b5 f0 ff ff    	lea    -0xf4b(%ebx),%eax
  800bc7:	50                   	push   %eax
  800bc8:	e8 1f 00 00 00       	call   800bec <_panic>

00800bcd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdd:	89 d1                	mov    %edx,%ecx
  800bdf:	89 d3                	mov    %edx,%ebx
  800be1:	89 d7                	mov    %edx,%edi
  800be3:	89 d6                	mov    %edx,%esi
  800be5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	e8 7a f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800bfa:	81 c3 06 14 00 00    	add    $0x1406,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c00:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c03:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c09:	8b 38                	mov    (%eax),%edi
  800c0b:	e8 bd ff ff ff       	call   800bcd <sys_getenvid>
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	ff 75 0c             	push   0xc(%ebp)
  800c16:	ff 75 08             	push   0x8(%ebp)
  800c19:	57                   	push   %edi
  800c1a:	50                   	push   %eax
  800c1b:	8d 83 c4 f0 ff ff    	lea    -0xf3c(%ebx),%eax
  800c21:	50                   	push   %eax
  800c22:	e8 68 f5 ff ff       	call   80018f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c27:	83 c4 18             	add    $0x18,%esp
  800c2a:	56                   	push   %esi
  800c2b:	ff 75 10             	push   0x10(%ebp)
  800c2e:	e8 fa f4 ff ff       	call   80012d <vcprintf>
	cprintf("\n");
  800c33:	8d 83 90 ee ff ff    	lea    -0x1170(%ebx),%eax
  800c39:	89 04 24             	mov    %eax,(%esp)
  800c3c:	e8 4e f5 ff ff       	call   80018f <cprintf>
  800c41:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c44:	cc                   	int3   
  800c45:	eb fd                	jmp    800c44 <_panic+0x58>
  800c47:	66 90                	xchg   %ax,%ax
  800c49:	66 90                	xchg   %ax,%ax
  800c4b:	66 90                	xchg   %ax,%ax
  800c4d:	66 90                	xchg   %ax,%ax
  800c4f:	90                   	nop

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
