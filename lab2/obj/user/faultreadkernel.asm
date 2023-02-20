
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
	call libmain
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
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
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800045:	ff 35 00 00 10 f0    	push   0xf0100000
  80004b:	8d 83 74 ee ff ff    	lea    -0x118c(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 23 01 00 00       	call   80017a <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
  80006a:	e8 f0 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 45 08             	mov    0x8(%ebp),%eax
  800078:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007b:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800082:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	7e 08                	jle    800091 <libmain+0x2e>
		binaryname = argv[0];
  800089:	8b 0a                	mov    (%edx),%ecx
  80008b:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	52                   	push   %edx
  800095:	50                   	push   %eax
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 10             	sub    $0x10,%esp
  8000af:	e8 ab ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000b4:	81 c3 4c 1f 00 00    	add    $0x1f4c,%ebx
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 a2 0a 00 00       	call   800b63 <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
  8000ce:	e8 8c ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000d3:	81 c3 2d 1f 00 00    	add    $0x1f2d,%ebx
  8000d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000dc:	8b 16                	mov    (%esi),%edx
  8000de:	8d 42 01             	lea    0x1(%edx),%eax
  8000e1:	89 06                	mov    %eax,(%esi)
  8000e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e6:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	74 0b                	je     8000fc <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f1:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8000f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	68 ff 00 00 00       	push   $0xff
  800104:	8d 46 08             	lea    0x8(%esi),%eax
  800107:	50                   	push   %eax
  800108:	e8 19 0a 00 00       	call   800b26 <sys_cputs>
		b->idx = 0;
  80010d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	eb d9                	jmp    8000f1 <putch+0x28>

00800118 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800122:	e8 38 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800127:	81 c3 d9 1e 00 00    	add    $0x1ed9,%ebx
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
  80014e:	8d 83 c9 e0 ff ff    	lea    -0x1f37(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 2c 01 00 00       	call   800286 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800163:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	e8 b7 09 00 00       	call   800b26 <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800180:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800183:	50                   	push   %eax
  800184:	ff 75 08             	push   0x8(%ebp)
  800187:	e8 8c ff ff ff       	call   800118 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 2c             	sub    $0x2c,%esp
  800197:	e8 0b 06 00 00       	call   8007a7 <__x86.get_pc_thunk.cx>
  80019c:	81 c1 64 1e 00 00    	add    $0x1e64,%ecx
  8001a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a5:	89 c7                	mov    %eax,%edi
  8001a7:	89 d6                	mov    %edx,%esi
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001af:	89 d1                	mov    %edx,%ecx
  8001b1:	89 c2                	mov    %eax,%edx
  8001b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001c9:	39 c2                	cmp    %eax,%edx
  8001cb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ce:	72 41                	jb     800211 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	push   0x18(%ebp)
  8001d6:	83 eb 01             	sub    $0x1,%ebx
  8001d9:	53                   	push   %ebx
  8001da:	50                   	push   %eax
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	ff 75 e4             	push   -0x1c(%ebp)
  8001e1:	ff 75 e0             	push   -0x20(%ebp)
  8001e4:	ff 75 d4             	push   -0x2c(%ebp)
  8001e7:	ff 75 d0             	push   -0x30(%ebp)
  8001ea:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001ed:	e8 4e 0a 00 00       	call   800c40 <__udivdi3>
  8001f2:	83 c4 18             	add    $0x18,%esp
  8001f5:	52                   	push   %edx
  8001f6:	50                   	push   %eax
  8001f7:	89 f2                	mov    %esi,%edx
  8001f9:	89 f8                	mov    %edi,%eax
  8001fb:	e8 8e ff ff ff       	call   80018e <printnum>
  800200:	83 c4 20             	add    $0x20,%esp
  800203:	eb 13                	jmp    800218 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	ff 75 18             	push   0x18(%ebp)
  80020c:	ff d7                	call   *%edi
  80020e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800211:	83 eb 01             	sub    $0x1,%ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f ed                	jg     800205 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	56                   	push   %esi
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 e4             	push   -0x1c(%ebp)
  800222:	ff 75 e0             	push   -0x20(%ebp)
  800225:	ff 75 d4             	push   -0x2c(%ebp)
  800228:	ff 75 d0             	push   -0x30(%ebp)
  80022b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80022e:	e8 2d 0b 00 00       	call   800d60 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 84 03 a5 ee ff 	movsbl -0x115b(%ebx,%eax,1),%eax
  80023d:	ff 
  80023e:	50                   	push   %eax
  80023f:	ff d7                	call   *%edi
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800252:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800256:	8b 10                	mov    (%eax),%edx
  800258:	3b 50 04             	cmp    0x4(%eax),%edx
  80025b:	73 0a                	jae    800267 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	88 02                	mov    %al,(%edx)
}
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <printfmt>:
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80026f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800272:	50                   	push   %eax
  800273:	ff 75 10             	push   0x10(%ebp)
  800276:	ff 75 0c             	push   0xc(%ebp)
  800279:	ff 75 08             	push   0x8(%ebp)
  80027c:	e8 05 00 00 00       	call   800286 <vprintfmt>
}
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <vprintfmt>:
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 3c             	sub    $0x3c,%esp
  80028f:	e8 0f 05 00 00       	call   8007a3 <__x86.get_pc_thunk.ax>
  800294:	05 6c 1d 00 00       	add    $0x1d6c,%eax
  800299:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029c:	8b 75 08             	mov    0x8(%ebp),%esi
  80029f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002a5:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002ab:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002ae:	eb 0a                	jmp    8002ba <vprintfmt+0x34>
			putch(ch, putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	57                   	push   %edi
  8002b4:	50                   	push   %eax
  8002b5:	ff d6                	call   *%esi
  8002b7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ba:	83 c3 01             	add    $0x1,%ebx
  8002bd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002c1:	83 f8 25             	cmp    $0x25,%eax
  8002c4:	74 0c                	je     8002d2 <vprintfmt+0x4c>
			if (ch == '\0')
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	75 e6                	jne    8002b0 <vprintfmt+0x2a>
}
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    
		padc = ' ';
  8002d2:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002d6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8002eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8002f3:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8d 43 01             	lea    0x1(%ebx),%eax
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	0f b6 13             	movzbl (%ebx),%edx
  8002ff:	8d 42 dd             	lea    -0x23(%edx),%eax
  800302:	3c 55                	cmp    $0x55,%al
  800304:	0f 87 fd 03 00 00    	ja     800707 <.L20>
  80030a:	0f b6 c0             	movzbl %al,%eax
  80030d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800310:	89 ce                	mov    %ecx,%esi
  800312:	03 b4 81 34 ef ff ff 	add    -0x10cc(%ecx,%eax,4),%esi
  800319:	ff e6                	jmp    *%esi

0080031b <.L68>:
  80031b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80031e:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800322:	eb d2                	jmp    8002f6 <vprintfmt+0x70>

00800324 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800327:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80032b:	eb c9                	jmp    8002f6 <vprintfmt+0x70>

0080032d <.L31>:
  80032d:	0f b6 d2             	movzbl %dl,%edx
  800330:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800333:	b8 00 00 00 00       	mov    $0x0,%eax
  800338:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80033b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800342:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800345:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800348:	83 f9 09             	cmp    $0x9,%ecx
  80034b:	77 58                	ja     8003a5 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80034d:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800350:	eb e9                	jmp    80033b <.L31+0xe>

00800352 <.L34>:
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 40 04             	lea    0x4(%eax),%eax
  800360:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800366:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80036a:	79 8a                	jns    8002f6 <vprintfmt+0x70>
				width = precision, precision = -1;
  80036c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800372:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800379:	e9 78 ff ff ff       	jmp    8002f6 <vprintfmt+0x70>

0080037e <.L33>:
  80037e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800381:	85 d2                	test   %edx,%edx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	0f 49 c2             	cmovns %edx,%eax
  80038b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800391:	e9 60 ff ff ff       	jmp    8002f6 <vprintfmt+0x70>

00800396 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800399:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003a0:	e9 51 ff ff ff       	jmp    8002f6 <vprintfmt+0x70>
  8003a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8003ab:	eb b9                	jmp    800366 <.L34+0x14>

008003ad <.L27>:
			lflag++;
  8003ad:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003b4:	e9 3d ff ff ff       	jmp    8002f6 <vprintfmt+0x70>

008003b9 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 58 04             	lea    0x4(%eax),%ebx
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	57                   	push   %edi
  8003c6:	ff 30                	push   (%eax)
  8003c8:	ff d6                	call   *%esi
			break;
  8003ca:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cd:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003d0:	e9 c8 02 00 00       	jmp    80069d <.L25+0x45>

008003d5 <.L28>:
			err = va_arg(ap, int);
  8003d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 58 04             	lea    0x4(%eax),%ebx
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	89 d0                	mov    %edx,%eax
  8003e2:	f7 d8                	neg    %eax
  8003e4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e7:	83 f8 06             	cmp    $0x6,%eax
  8003ea:	7f 27                	jg     800413 <.L28+0x3e>
  8003ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003ef:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	74 1d                	je     800413 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8003f6:	52                   	push   %edx
  8003f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fa:	8d 80 c6 ee ff ff    	lea    -0x113a(%eax),%eax
  800400:	50                   	push   %eax
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	e8 61 fe ff ff       	call   800269 <printfmt>
  800408:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040b:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80040e:	e9 8a 02 00 00       	jmp    80069d <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800413:	50                   	push   %eax
  800414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800417:	8d 80 bd ee ff ff    	lea    -0x1143(%eax),%eax
  80041d:	50                   	push   %eax
  80041e:	57                   	push   %edi
  80041f:	56                   	push   %esi
  800420:	e8 44 fe ff ff       	call   800269 <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800428:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80042b:	e9 6d 02 00 00       	jmp    80069d <.L25+0x45>

00800430 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800430:	8b 75 08             	mov    0x8(%ebp),%esi
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	83 c0 04             	add    $0x4,%eax
  800439:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800441:	85 d2                	test   %edx,%edx
  800443:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800446:	8d 80 b6 ee ff ff    	lea    -0x114a(%eax),%eax
  80044c:	0f 45 c2             	cmovne %edx,%eax
  80044f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800452:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800456:	7e 06                	jle    80045e <.L24+0x2e>
  800458:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80045c:	75 0d                	jne    80046b <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800461:	89 c3                	mov    %eax,%ebx
  800463:	03 45 d4             	add    -0x2c(%ebp),%eax
  800466:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800469:	eb 58                	jmp    8004c3 <.L24+0x93>
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	ff 75 d8             	push   -0x28(%ebp)
  800471:	ff 75 c8             	push   -0x38(%ebp)
  800474:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800477:	e8 47 03 00 00       	call   8007c3 <strnlen>
  80047c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80047f:	29 c2                	sub    %eax,%edx
  800481:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800489:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80048d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	eb 0f                	jmp    8004a1 <.L24+0x71>
					putch(padc, putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	57                   	push   %edi
  800496:	ff 75 d4             	push   -0x2c(%ebp)
  800499:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	83 eb 01             	sub    $0x1,%ebx
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	85 db                	test   %ebx,%ebx
  8004a3:	7f ed                	jg     800492 <.L24+0x62>
  8004a5:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 49 c2             	cmovns %edx,%eax
  8004b2:	29 c2                	sub    %eax,%edx
  8004b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004b7:	eb a5                	jmp    80045e <.L24+0x2e>
					putch(ch, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	57                   	push   %edi
  8004bd:	52                   	push   %edx
  8004be:	ff d6                	call   *%esi
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004c6:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 c3 01             	add    $0x1,%ebx
  8004cb:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004cf:	0f be d0             	movsbl %al,%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 4b                	je     800521 <.L24+0xf1>
  8004d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004da:	78 06                	js     8004e2 <.L24+0xb2>
  8004dc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e0:	78 1e                	js     800500 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004e6:	74 d1                	je     8004b9 <.L24+0x89>
  8004e8:	0f be c0             	movsbl %al,%eax
  8004eb:	83 e8 20             	sub    $0x20,%eax
  8004ee:	83 f8 5e             	cmp    $0x5e,%eax
  8004f1:	76 c6                	jbe    8004b9 <.L24+0x89>
					putch('?', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	57                   	push   %edi
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff d6                	call   *%esi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	eb c3                	jmp    8004c3 <.L24+0x93>
  800500:	89 cb                	mov    %ecx,%ebx
  800502:	eb 0e                	jmp    800512 <.L24+0xe2>
				putch(' ', putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	57                   	push   %edi
  800508:	6a 20                	push   $0x20
  80050a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80050c:	83 eb 01             	sub    $0x1,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 db                	test   %ebx,%ebx
  800514:	7f ee                	jg     800504 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	e9 7c 01 00 00       	jmp    80069d <.L25+0x45>
  800521:	89 cb                	mov    %ecx,%ebx
  800523:	eb ed                	jmp    800512 <.L24+0xe2>

00800525 <.L29>:
	if (lflag >= 2)
  800525:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7f 1b                	jg     80054b <.L29+0x26>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 63                	je     800597 <.L29+0x72>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	99                   	cltd   
  80053d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 40 04             	lea    0x4(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
  800549:	eb 17                	jmp    800562 <.L29+0x3d>
		return va_arg(*ap, long long);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 08             	lea    0x8(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800562:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800565:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800568:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80056d:	85 db                	test   %ebx,%ebx
  80056f:	0f 89 0e 01 00 00    	jns    800683 <.L25+0x2b>
				putch('-', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	6a 2d                	push   $0x2d
  80057b:	ff d6                	call   *%esi
				num = -(long long) num;
  80057d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800580:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800583:	f7 d9                	neg    %ecx
  800585:	83 d3 00             	adc    $0x0,%ebx
  800588:	f7 db                	neg    %ebx
  80058a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058d:	ba 0a 00 00 00       	mov    $0xa,%edx
  800592:	e9 ec 00 00 00       	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, int);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	99                   	cltd   
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ac:	eb b4                	jmp    800562 <.L29+0x3d>

008005ae <.L23>:
	if (lflag >= 2)
  8005ae:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7f 1e                	jg     8005d7 <.L23+0x29>
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	74 32                	je     8005ef <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 08                	mov    (%eax),%ecx
  8005c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005d2:	e9 ac 00 00 00       	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 08                	mov    (%eax),%ecx
  8005dc:	8b 58 04             	mov    0x4(%eax),%ebx
  8005df:	8d 40 08             	lea    0x8(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e5:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005ea:	e9 94 00 00 00       	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 08                	mov    (%eax),%ecx
  8005f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ff:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800604:	eb 7d                	jmp    800683 <.L25+0x2b>

00800606 <.L26>:
	if (lflag >= 2)
  800606:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800609:	8b 75 08             	mov    0x8(%ebp),%esi
  80060c:	83 f9 01             	cmp    $0x1,%ecx
  80060f:	7f 1b                	jg     80062c <.L26+0x26>
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 2c                	je     800641 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 08                	mov    (%eax),%ecx
  80061a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800625:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  80062a:	eb 57                	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 08                	mov    (%eax),%ecx
  800631:	8b 58 04             	mov    0x4(%eax),%ebx
  800634:	8d 40 08             	lea    0x8(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063a:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  80063f:	eb 42                	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 08                	mov    (%eax),%ecx
  800646:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800651:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  800656:	eb 2b                	jmp    800683 <.L25+0x2b>

00800658 <.L25>:
			putch('0', putdat);
  800658:	8b 75 08             	mov    0x8(%ebp),%esi
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	57                   	push   %edi
  80065f:	6a 30                	push   $0x30
  800661:	ff d6                	call   *%esi
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	57                   	push   %edi
  800667:	6a 78                	push   $0x78
  800669:	ff d6                	call   *%esi
			num = (unsigned long long)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 08                	mov    (%eax),%ecx
  800670:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800675:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067e:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80068a:	50                   	push   %eax
  80068b:	ff 75 d4             	push   -0x2c(%ebp)
  80068e:	52                   	push   %edx
  80068f:	53                   	push   %ebx
  800690:	51                   	push   %ecx
  800691:	89 fa                	mov    %edi,%edx
  800693:	89 f0                	mov    %esi,%eax
  800695:	e8 f4 fa ff ff       	call   80018e <printnum>
			break;
  80069a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80069d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a0:	e9 15 fc ff ff       	jmp    8002ba <vprintfmt+0x34>

008006a5 <.L21>:
	if (lflag >= 2)
  8006a5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ab:	83 f9 01             	cmp    $0x1,%ecx
  8006ae:	7f 1b                	jg     8006cb <.L21+0x26>
	else if (lflag)
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	74 2c                	je     8006e0 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 08                	mov    (%eax),%ecx
  8006b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c4:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006c9:	eb b8                	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 08                	mov    (%eax),%ecx
  8006d0:	8b 58 04             	mov    0x4(%eax),%ebx
  8006d3:	8d 40 08             	lea    0x8(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006de:	eb a3                	jmp    800683 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 08                	mov    (%eax),%ecx
  8006e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006f5:	eb 8c                	jmp    800683 <.L25+0x2b>

008006f7 <.L35>:
			putch(ch, putdat);
  8006f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	57                   	push   %edi
  8006fe:	6a 25                	push   $0x25
  800700:	ff d6                	call   *%esi
			break;
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 96                	jmp    80069d <.L25+0x45>

00800707 <.L20>:
			putch('%', putdat);
  800707:	8b 75 08             	mov    0x8(%ebp),%esi
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	57                   	push   %edi
  80070e:	6a 25                	push   $0x25
  800710:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	89 d8                	mov    %ebx,%eax
  800717:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071b:	74 05                	je     800722 <.L20+0x1b>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	eb f5                	jmp    800717 <.L20+0x10>
  800722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800725:	e9 73 ff ff ff       	jmp    80069d <.L25+0x45>

0080072a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	53                   	push   %ebx
  80072e:	83 ec 14             	sub    $0x14,%esp
  800731:	e8 29 f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800736:	81 c3 ca 18 00 00    	add    $0x18ca,%ebx
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 2b                	je     800782 <vsnprintf+0x58>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 27                	jle    800782 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	ff 75 14             	push   0x14(%ebp)
  80075e:	ff 75 10             	push   0x10(%ebp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	8d 83 4c e2 ff ff    	lea    -0x1db4(%ebx),%eax
  80076b:	50                   	push   %eax
  80076c:	e8 15 fb ff ff       	call   800286 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800771:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800774:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800777:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077a:	83 c4 10             	add    $0x10,%esp
}
  80077d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800780:	c9                   	leave  
  800781:	c3                   	ret    
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800787:	eb f4                	jmp    80077d <vsnprintf+0x53>

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	50                   	push   %eax
  800793:	ff 75 10             	push   0x10(%ebp)
  800796:	ff 75 0c             	push   0xc(%ebp)
  800799:	ff 75 08             	push   0x8(%ebp)
  80079c:	e8 89 ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <__x86.get_pc_thunk.ax>:
  8007a3:	8b 04 24             	mov    (%esp),%eax
  8007a6:	c3                   	ret    

008007a7 <__x86.get_pc_thunk.cx>:
  8007a7:	8b 0c 24             	mov    (%esp),%ecx
  8007aa:	c3                   	ret    

008007ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 03                	jmp    8007bb <strlen+0x10>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bf:	75 f7                	jne    8007b8 <strlen+0xd>
	return n;
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 03                	jmp    8007d6 <strnlen+0x13>
		n++;
  8007d3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d6:	39 d0                	cmp    %edx,%eax
  8007d8:	74 08                	je     8007e2 <strnlen+0x1f>
  8007da:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007de:	75 f3                	jne    8007d3 <strnlen+0x10>
  8007e0:	89 c2                	mov    %eax,%edx
	return n;
}
  8007e2:	89 d0                	mov    %edx,%eax
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007fc:	83 c0 01             	add    $0x1,%eax
  8007ff:	84 d2                	test   %dl,%dl
  800801:	75 f2                	jne    8007f5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800803:	89 c8                	mov    %ecx,%eax
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	83 ec 10             	sub    $0x10,%esp
  800811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800814:	53                   	push   %ebx
  800815:	e8 91 ff ff ff       	call   8007ab <strlen>
  80081a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80081d:	ff 75 0c             	push   0xc(%ebp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	50                   	push   %eax
  800823:	e8 be ff ff ff       	call   8007e6 <strcpy>
	return dst;
}
  800828:	89 d8                	mov    %ebx,%eax
  80082a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	89 f3                	mov    %esi,%ebx
  80083c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083f:	89 f0                	mov    %esi,%eax
  800841:	eb 0f                	jmp    800852 <strncpy+0x23>
		*dst++ = *src;
  800843:	83 c0 01             	add    $0x1,%eax
  800846:	0f b6 0a             	movzbl (%edx),%ecx
  800849:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084c:	80 f9 01             	cmp    $0x1,%cl
  80084f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	75 ed                	jne    800843 <strncpy+0x14>
	}
	return ret;
}
  800856:	89 f0                	mov    %esi,%eax
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 75 08             	mov    0x8(%ebp),%esi
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	8b 55 10             	mov    0x10(%ebp),%edx
  80086a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086c:	85 d2                	test   %edx,%edx
  80086e:	74 21                	je     800891 <strlcpy+0x35>
  800870:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800874:	89 f2                	mov    %esi,%edx
  800876:	eb 09                	jmp    800881 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800878:	83 c1 01             	add    $0x1,%ecx
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800881:	39 c2                	cmp    %eax,%edx
  800883:	74 09                	je     80088e <strlcpy+0x32>
  800885:	0f b6 19             	movzbl (%ecx),%ebx
  800888:	84 db                	test   %bl,%bl
  80088a:	75 ec                	jne    800878 <strlcpy+0x1c>
  80088c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80088e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800891:	29 f0                	sub    %esi,%eax
}
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a0:	eb 06                	jmp    8008a8 <strcmp+0x11>
		p++, q++;
  8008a2:	83 c1 01             	add    $0x1,%ecx
  8008a5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a8:	0f b6 01             	movzbl (%ecx),%eax
  8008ab:	84 c0                	test   %al,%al
  8008ad:	74 04                	je     8008b3 <strcmp+0x1c>
  8008af:	3a 02                	cmp    (%edx),%al
  8008b1:	74 ef                	je     8008a2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 c0             	movzbl %al,%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 c3                	mov    %eax,%ebx
  8008c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cc:	eb 06                	jmp    8008d4 <strncmp+0x17>
		n--, p++, q++;
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d4:	39 d8                	cmp    %ebx,%eax
  8008d6:	74 18                	je     8008f0 <strncmp+0x33>
  8008d8:	0f b6 08             	movzbl (%eax),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	74 04                	je     8008e3 <strncmp+0x26>
  8008df:	3a 0a                	cmp    (%edx),%cl
  8008e1:	74 eb                	je     8008ce <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 12             	movzbl (%edx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
}
  8008eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    
		return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f5:	eb f4                	jmp    8008eb <strncmp+0x2e>

008008f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	eb 03                	jmp    800906 <strchr+0xf>
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	0f b6 10             	movzbl (%eax),%edx
  800909:	84 d2                	test   %dl,%dl
  80090b:	74 06                	je     800913 <strchr+0x1c>
		if (*s == c)
  80090d:	38 ca                	cmp    %cl,%dl
  80090f:	75 f2                	jne    800903 <strchr+0xc>
  800911:	eb 05                	jmp    800918 <strchr+0x21>
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 09                	je     800934 <strfind+0x1a>
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 05                	je     800934 <strfind+0x1a>
	for (; *s; s++)
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	eb f0                	jmp    800924 <strfind+0xa>
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 2f                	je     800975 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800946:	89 f8                	mov    %edi,%eax
  800948:	09 c8                	or     %ecx,%eax
  80094a:	a8 03                	test   $0x3,%al
  80094c:	75 21                	jne    80096f <memset+0x39>
		c &= 0xFF;
  80094e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800952:	89 d0                	mov    %edx,%eax
  800954:	c1 e0 08             	shl    $0x8,%eax
  800957:	89 d3                	mov    %edx,%ebx
  800959:	c1 e3 18             	shl    $0x18,%ebx
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	c1 e6 10             	shl    $0x10,%esi
  800961:	09 f3                	or     %esi,%ebx
  800963:	09 da                	or     %ebx,%edx
  800965:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800967:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80096a:	fc                   	cld    
  80096b:	f3 ab                	rep stos %eax,%es:(%edi)
  80096d:	eb 06                	jmp    800975 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 32                	jae    8009c0 <memmove+0x44>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 c2                	cmp    %eax,%edx
  800993:	76 2b                	jbe    8009c0 <memmove+0x44>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	89 d6                	mov    %edx,%esi
  80099a:	09 fe                	or     %edi,%esi
  80099c:	09 ce                	or     %ecx,%esi
  80099e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a4:	75 0e                	jne    8009b4 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a6:	83 ef 04             	sub    $0x4,%edi
  8009a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009af:	fd                   	std    
  8009b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b2:	eb 09                	jmp    8009bd <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b4:	83 ef 01             	sub    $0x1,%edi
  8009b7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bd:	fc                   	cld    
  8009be:	eb 1a                	jmp    8009da <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c0:	89 f2                	mov    %esi,%edx
  8009c2:	09 c2                	or     %eax,%edx
  8009c4:	09 ca                	or     %ecx,%edx
  8009c6:	f6 c2 03             	test   $0x3,%dl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e4:	ff 75 10             	push   0x10(%ebp)
  8009e7:	ff 75 0c             	push   0xc(%ebp)
  8009ea:	ff 75 08             	push   0x8(%ebp)
  8009ed:	e8 8a ff ff ff       	call   80097c <memmove>
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ff:	89 c6                	mov    %eax,%esi
  800a01:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a04:	eb 06                	jmp    800a0c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a0c:	39 f0                	cmp    %esi,%eax
  800a0e:	74 14                	je     800a24 <memcmp+0x30>
		if (*s1 != *s2)
  800a10:	0f b6 08             	movzbl (%eax),%ecx
  800a13:	0f b6 1a             	movzbl (%edx),%ebx
  800a16:	38 d9                	cmp    %bl,%cl
  800a18:	74 ec                	je     800a06 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c1             	movzbl %cl,%eax
  800a1d:	0f b6 db             	movzbl %bl,%ebx
  800a20:	29 d8                	sub    %ebx,%eax
  800a22:	eb 05                	jmp    800a29 <memcmp+0x35>
	}

	return 0;
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a36:	89 c2                	mov    %eax,%edx
  800a38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3b:	eb 03                	jmp    800a40 <memfind+0x13>
  800a3d:	83 c0 01             	add    $0x1,%eax
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 04                	jae    800a48 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	38 08                	cmp    %cl,(%eax)
  800a46:	75 f5                	jne    800a3d <memfind+0x10>
			break;
	return (void *) s;
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a56:	eb 03                	jmp    800a5b <strtol+0x11>
		s++;
  800a58:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a5b:	0f b6 02             	movzbl (%edx),%eax
  800a5e:	3c 20                	cmp    $0x20,%al
  800a60:	74 f6                	je     800a58 <strtol+0xe>
  800a62:	3c 09                	cmp    $0x9,%al
  800a64:	74 f2                	je     800a58 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a66:	3c 2b                	cmp    $0x2b,%al
  800a68:	74 2a                	je     800a94 <strtol+0x4a>
	int neg = 0;
  800a6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a6f:	3c 2d                	cmp    $0x2d,%al
  800a71:	74 2b                	je     800a9e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a73:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a79:	75 0f                	jne    800a8a <strtol+0x40>
  800a7b:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7e:	74 28                	je     800aa8 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a87:	0f 44 d8             	cmove  %eax,%ebx
  800a8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a92:	eb 46                	jmp    800ada <strtol+0x90>
		s++;
  800a94:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9c:	eb d5                	jmp    800a73 <strtol+0x29>
		s++, neg = 1;
  800a9e:	83 c2 01             	add    $0x1,%edx
  800aa1:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa6:	eb cb                	jmp    800a73 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aac:	74 0e                	je     800abc <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	75 d8                	jne    800a8a <strtol+0x40>
		s++, base = 8;
  800ab2:	83 c2 01             	add    $0x1,%edx
  800ab5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aba:	eb ce                	jmp    800a8a <strtol+0x40>
		s += 2, base = 16;
  800abc:	83 c2 02             	add    $0x2,%edx
  800abf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac4:	eb c4                	jmp    800a8a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac6:	0f be c0             	movsbl %al,%eax
  800ac9:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acc:	3b 45 10             	cmp    0x10(%ebp),%eax
  800acf:	7d 3a                	jge    800b0b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c2 01             	add    $0x1,%edx
  800ad4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ad8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ada:	0f b6 02             	movzbl (%edx),%eax
  800add:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 09             	cmp    $0x9,%bl
  800ae5:	76 df                	jbe    800ac6 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ae7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800af1:	0f be c0             	movsbl %al,%eax
  800af4:	83 e8 57             	sub    $0x57,%eax
  800af7:	eb d3                	jmp    800acc <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800af9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 08                	ja     800b0b <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b03:	0f be c0             	movsbl %al,%eax
  800b06:	83 e8 37             	sub    $0x37,%eax
  800b09:	eb c1                	jmp    800acc <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0f:	74 05                	je     800b16 <strtol+0xcc>
		*endptr = (char *) s;
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b16:	89 c8                	mov    %ecx,%eax
  800b18:	f7 d8                	neg    %eax
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	0f 45 c8             	cmovne %eax,%ecx
}
  800b1f:	89 c8                	mov    %ecx,%eax
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	89 c6                	mov    %eax,%esi
  800b3d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b54:	89 d1                	mov    %edx,%ecx
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 1c             	sub    $0x1c,%esp
  800b6c:	e8 32 fc ff ff       	call   8007a3 <__x86.get_pc_thunk.ax>
  800b71:	05 8f 14 00 00       	add    $0x148f,%eax
  800b76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	89 cb                	mov    %ecx,%ebx
  800b88:	89 cf                	mov    %ecx,%edi
  800b8a:	89 ce                	mov    %ecx,%esi
  800b8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800b9e:	6a 03                	push   $0x3
  800ba0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ba3:	8d 83 8c f0 ff ff    	lea    -0xf74(%ebx),%eax
  800ba9:	50                   	push   %eax
  800baa:	6a 23                	push   $0x23
  800bac:	8d 83 a9 f0 ff ff    	lea    -0xf57(%ebx),%eax
  800bb2:	50                   	push   %eax
  800bb3:	e8 1f 00 00 00       	call   800bd7 <_panic>

00800bb8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	e8 7a f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800be5:	81 c3 1b 14 00 00    	add    $0x141b,%ebx
	va_list ap;

	va_start(ap, fmt);
  800beb:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bee:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bf4:	8b 38                	mov    (%eax),%edi
  800bf6:	e8 bd ff ff ff       	call   800bb8 <sys_getenvid>
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	ff 75 0c             	push   0xc(%ebp)
  800c01:	ff 75 08             	push   0x8(%ebp)
  800c04:	57                   	push   %edi
  800c05:	50                   	push   %eax
  800c06:	8d 83 b8 f0 ff ff    	lea    -0xf48(%ebx),%eax
  800c0c:	50                   	push   %eax
  800c0d:	e8 68 f5 ff ff       	call   80017a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c12:	83 c4 18             	add    $0x18,%esp
  800c15:	56                   	push   %esi
  800c16:	ff 75 10             	push   0x10(%ebp)
  800c19:	e8 fa f4 ff ff       	call   800118 <vcprintf>
	cprintf("\n");
  800c1e:	8d 83 db f0 ff ff    	lea    -0xf25(%ebx),%eax
  800c24:	89 04 24             	mov    %eax,(%esp)
  800c27:	e8 4e f5 ff ff       	call   80017a <cprintf>
  800c2c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c2f:	cc                   	int3   
  800c30:	eb fd                	jmp    800c2f <_panic+0x58>
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	66 90                	xchg   %ax,%ax
  800c36:	66 90                	xchg   %ax,%ax
  800c38:	66 90                	xchg   %ax,%ax
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <__udivdi3>:
  800c40:	f3 0f 1e fb          	endbr32 
  800c44:	55                   	push   %ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 1c             	sub    $0x1c,%esp
  800c4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c53:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	75 19                	jne    800c78 <__udivdi3+0x38>
  800c5f:	39 f3                	cmp    %esi,%ebx
  800c61:	76 4d                	jbe    800cb0 <__udivdi3+0x70>
  800c63:	31 ff                	xor    %edi,%edi
  800c65:	89 e8                	mov    %ebp,%eax
  800c67:	89 f2                	mov    %esi,%edx
  800c69:	f7 f3                	div    %ebx
  800c6b:	89 fa                	mov    %edi,%edx
  800c6d:	83 c4 1c             	add    $0x1c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
  800c75:	8d 76 00             	lea    0x0(%esi),%esi
  800c78:	39 f0                	cmp    %esi,%eax
  800c7a:	76 14                	jbe    800c90 <__udivdi3+0x50>
  800c7c:	31 ff                	xor    %edi,%edi
  800c7e:	31 c0                	xor    %eax,%eax
  800c80:	89 fa                	mov    %edi,%edx
  800c82:	83 c4 1c             	add    $0x1c,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
  800c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c90:	0f bd f8             	bsr    %eax,%edi
  800c93:	83 f7 1f             	xor    $0x1f,%edi
  800c96:	75 48                	jne    800ce0 <__udivdi3+0xa0>
  800c98:	39 f0                	cmp    %esi,%eax
  800c9a:	72 06                	jb     800ca2 <__udivdi3+0x62>
  800c9c:	31 c0                	xor    %eax,%eax
  800c9e:	39 eb                	cmp    %ebp,%ebx
  800ca0:	77 de                	ja     800c80 <__udivdi3+0x40>
  800ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca7:	eb d7                	jmp    800c80 <__udivdi3+0x40>
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 d9                	mov    %ebx,%ecx
  800cb2:	85 db                	test   %ebx,%ebx
  800cb4:	75 0b                	jne    800cc1 <__udivdi3+0x81>
  800cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbb:	31 d2                	xor    %edx,%edx
  800cbd:	f7 f3                	div    %ebx
  800cbf:	89 c1                	mov    %eax,%ecx
  800cc1:	31 d2                	xor    %edx,%edx
  800cc3:	89 f0                	mov    %esi,%eax
  800cc5:	f7 f1                	div    %ecx
  800cc7:	89 c6                	mov    %eax,%esi
  800cc9:	89 e8                	mov    %ebp,%eax
  800ccb:	89 f7                	mov    %esi,%edi
  800ccd:	f7 f1                	div    %ecx
  800ccf:	89 fa                	mov    %edi,%edx
  800cd1:	83 c4 1c             	add    $0x1c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
  800cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	89 f9                	mov    %edi,%ecx
  800ce2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ce7:	29 fa                	sub    %edi,%edx
  800ce9:	d3 e0                	shl    %cl,%eax
  800ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cef:	89 d1                	mov    %edx,%ecx
  800cf1:	89 d8                	mov    %ebx,%eax
  800cf3:	d3 e8                	shr    %cl,%eax
  800cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cf9:	09 c1                	or     %eax,%ecx
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d01:	89 f9                	mov    %edi,%ecx
  800d03:	d3 e3                	shl    %cl,%ebx
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 f9                	mov    %edi,%ecx
  800d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d0f:	89 eb                	mov    %ebp,%ebx
  800d11:	d3 e6                	shl    %cl,%esi
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	d3 eb                	shr    %cl,%ebx
  800d17:	09 f3                	or     %esi,%ebx
  800d19:	89 c6                	mov    %eax,%esi
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 d8                	mov    %ebx,%eax
  800d1f:	f7 74 24 08          	divl   0x8(%esp)
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	89 c3                	mov    %eax,%ebx
  800d27:	f7 64 24 0c          	mull   0xc(%esp)
  800d2b:	39 d6                	cmp    %edx,%esi
  800d2d:	72 19                	jb     800d48 <__udivdi3+0x108>
  800d2f:	89 f9                	mov    %edi,%ecx
  800d31:	d3 e5                	shl    %cl,%ebp
  800d33:	39 c5                	cmp    %eax,%ebp
  800d35:	73 04                	jae    800d3b <__udivdi3+0xfb>
  800d37:	39 d6                	cmp    %edx,%esi
  800d39:	74 0d                	je     800d48 <__udivdi3+0x108>
  800d3b:	89 d8                	mov    %ebx,%eax
  800d3d:	31 ff                	xor    %edi,%edi
  800d3f:	e9 3c ff ff ff       	jmp    800c80 <__udivdi3+0x40>
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d4b:	31 ff                	xor    %edi,%edi
  800d4d:	e9 2e ff ff ff       	jmp    800c80 <__udivdi3+0x40>
  800d52:	66 90                	xchg   %ax,%ax
  800d54:	66 90                	xchg   %ax,%ax
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 1c             	sub    $0x1c,%esp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d7b:	89 f0                	mov    %esi,%eax
  800d7d:	89 da                	mov    %ebx,%edx
  800d7f:	85 ff                	test   %edi,%edi
  800d81:	75 15                	jne    800d98 <__umoddi3+0x38>
  800d83:	39 dd                	cmp    %ebx,%ebp
  800d85:	76 39                	jbe    800dc0 <__umoddi3+0x60>
  800d87:	f7 f5                	div    %ebp
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 df                	cmp    %ebx,%edi
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cf             	bsr    %edi,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	75 40                	jne    800de8 <__umoddi3+0x88>
  800da8:	39 df                	cmp    %ebx,%edi
  800daa:	72 04                	jb     800db0 <__umoddi3+0x50>
  800dac:	39 f5                	cmp    %esi,%ebp
  800dae:	77 dd                	ja     800d8d <__umoddi3+0x2d>
  800db0:	89 da                	mov    %ebx,%edx
  800db2:	89 f0                	mov    %esi,%eax
  800db4:	29 e8                	sub    %ebp,%eax
  800db6:	19 fa                	sbb    %edi,%edx
  800db8:	eb d3                	jmp    800d8d <__umoddi3+0x2d>
  800dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc0:	89 e9                	mov    %ebp,%ecx
  800dc2:	85 ed                	test   %ebp,%ebp
  800dc4:	75 0b                	jne    800dd1 <__umoddi3+0x71>
  800dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	f7 f5                	div    %ebp
  800dcf:	89 c1                	mov    %eax,%ecx
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	31 d2                	xor    %edx,%edx
  800dd5:	f7 f1                	div    %ecx
  800dd7:	89 f0                	mov    %esi,%eax
  800dd9:	f7 f1                	div    %ecx
  800ddb:	89 d0                	mov    %edx,%eax
  800ddd:	31 d2                	xor    %edx,%edx
  800ddf:	eb ac                	jmp    800d8d <__umoddi3+0x2d>
  800de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dec:	ba 20 00 00 00       	mov    $0x20,%edx
  800df1:	29 c2                	sub    %eax,%edx
  800df3:	89 c1                	mov    %eax,%ecx
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	d3 e7                	shl    %cl,%edi
  800df9:	89 d1                	mov    %edx,%ecx
  800dfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dff:	d3 e8                	shr    %cl,%eax
  800e01:	89 c1                	mov    %eax,%ecx
  800e03:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e07:	09 f9                	or     %edi,%ecx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e0f:	89 c1                	mov    %eax,%ecx
  800e11:	d3 e5                	shl    %cl,%ebp
  800e13:	89 d1                	mov    %edx,%ecx
  800e15:	d3 ef                	shr    %cl,%edi
  800e17:	89 c1                	mov    %eax,%ecx
  800e19:	89 f0                	mov    %esi,%eax
  800e1b:	d3 e3                	shl    %cl,%ebx
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 fa                	mov    %edi,%edx
  800e21:	d3 e8                	shr    %cl,%eax
  800e23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e28:	09 d8                	or     %ebx,%eax
  800e2a:	f7 74 24 08          	divl   0x8(%esp)
  800e2e:	89 d3                	mov    %edx,%ebx
  800e30:	d3 e6                	shl    %cl,%esi
  800e32:	f7 e5                	mul    %ebp
  800e34:	89 c7                	mov    %eax,%edi
  800e36:	89 d1                	mov    %edx,%ecx
  800e38:	39 d3                	cmp    %edx,%ebx
  800e3a:	72 06                	jb     800e42 <__umoddi3+0xe2>
  800e3c:	75 0e                	jne    800e4c <__umoddi3+0xec>
  800e3e:	39 c6                	cmp    %eax,%esi
  800e40:	73 0a                	jae    800e4c <__umoddi3+0xec>
  800e42:	29 e8                	sub    %ebp,%eax
  800e44:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e48:	89 d1                	mov    %edx,%ecx
  800e4a:	89 c7                	mov    %eax,%edi
  800e4c:	89 f5                	mov    %esi,%ebp
  800e4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e52:	29 fd                	sub    %edi,%ebp
  800e54:	19 cb                	sbb    %ecx,%ebx
  800e56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	d3 e0                	shl    %cl,%eax
  800e5f:	89 f1                	mov    %esi,%ecx
  800e61:	d3 ed                	shr    %cl,%ebp
  800e63:	d3 eb                	shr    %cl,%ebx
  800e65:	09 e8                	or     %ebp,%eax
  800e67:	89 da                	mov    %ebx,%edx
  800e69:	83 c4 1c             	add    $0x1c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    
