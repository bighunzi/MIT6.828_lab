
obj/user/faultread.debug：     文件格式 elf32-i386


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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	push   0x0
  80003f:	68 60 22 80 00       	push   $0x802260
  800044:	e8 fd 00 00 00       	call   800146 <cprintf>
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
  800059:	e8 80 0a 00 00       	call   800ade <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009d:	e8 9d 0e 00 00       	call   800f3f <close_all>
	sys_env_destroy(0);
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	6a 00                	push   $0x0
  8000a7:	e8 f1 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000bb:	8b 13                	mov    (%ebx),%edx
  8000bd:	8d 42 01             	lea    0x1(%edx),%eax
  8000c0:	89 03                	mov    %eax,(%ebx)
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ce:	74 09                	je     8000d9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000d9:	83 ec 08             	sub    $0x8,%esp
  8000dc:	68 ff 00 00 00       	push   $0xff
  8000e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e4:	50                   	push   %eax
  8000e5:	e8 76 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	eb db                	jmp    8000d0 <putch+0x1f>

008000f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800105:	00 00 00 
	b.cnt = 0;
  800108:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800112:	ff 75 0c             	push   0xc(%ebp)
  800115:	ff 75 08             	push   0x8(%ebp)
  800118:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011e:	50                   	push   %eax
  80011f:	68 b1 00 80 00       	push   $0x8000b1
  800124:	e8 14 01 00 00       	call   80023d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800132:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	e8 22 09 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  80013e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014f:	50                   	push   %eax
  800150:	ff 75 08             	push   0x8(%ebp)
  800153:	e8 9d ff ff ff       	call   8000f5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 1c             	sub    $0x1c,%esp
  800163:	89 c7                	mov    %eax,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	8b 45 08             	mov    0x8(%ebp),%eax
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 d1                	mov    %edx,%ecx
  80016f:	89 c2                	mov    %eax,%edx
  800171:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800174:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800177:	8b 45 10             	mov    0x10(%ebp),%eax
  80017a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800180:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800187:	39 c2                	cmp    %eax,%edx
  800189:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80018c:	72 3e                	jb     8001cc <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	ff 75 18             	push   0x18(%ebp)
  800194:	83 eb 01             	sub    $0x1,%ebx
  800197:	53                   	push   %ebx
  800198:	50                   	push   %eax
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	ff 75 e4             	push   -0x1c(%ebp)
  80019f:	ff 75 e0             	push   -0x20(%ebp)
  8001a2:	ff 75 dc             	push   -0x24(%ebp)
  8001a5:	ff 75 d8             	push   -0x28(%ebp)
  8001a8:	e8 63 1e 00 00       	call   802010 <__udivdi3>
  8001ad:	83 c4 18             	add    $0x18,%esp
  8001b0:	52                   	push   %edx
  8001b1:	50                   	push   %eax
  8001b2:	89 f2                	mov    %esi,%edx
  8001b4:	89 f8                	mov    %edi,%eax
  8001b6:	e8 9f ff ff ff       	call   80015a <printnum>
  8001bb:	83 c4 20             	add    $0x20,%esp
  8001be:	eb 13                	jmp    8001d3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	56                   	push   %esi
  8001c4:	ff 75 18             	push   0x18(%ebp)
  8001c7:	ff d7                	call   *%edi
  8001c9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001cc:	83 eb 01             	sub    $0x1,%ebx
  8001cf:	85 db                	test   %ebx,%ebx
  8001d1:	7f ed                	jg     8001c0 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	56                   	push   %esi
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	ff 75 e4             	push   -0x1c(%ebp)
  8001dd:	ff 75 e0             	push   -0x20(%ebp)
  8001e0:	ff 75 dc             	push   -0x24(%ebp)
  8001e3:	ff 75 d8             	push   -0x28(%ebp)
  8001e6:	e8 45 1f 00 00       	call   802130 <__umoddi3>
  8001eb:	83 c4 14             	add    $0x14,%esp
  8001ee:	0f be 80 88 22 80 00 	movsbl 0x802288(%eax),%eax
  8001f5:	50                   	push   %eax
  8001f6:	ff d7                	call   *%edi
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5f                   	pop    %edi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800209:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80020d:	8b 10                	mov    (%eax),%edx
  80020f:	3b 50 04             	cmp    0x4(%eax),%edx
  800212:	73 0a                	jae    80021e <sprintputch+0x1b>
		*b->buf++ = ch;
  800214:	8d 4a 01             	lea    0x1(%edx),%ecx
  800217:	89 08                	mov    %ecx,(%eax)
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	88 02                	mov    %al,(%edx)
}
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <printfmt>:
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800226:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800229:	50                   	push   %eax
  80022a:	ff 75 10             	push   0x10(%ebp)
  80022d:	ff 75 0c             	push   0xc(%ebp)
  800230:	ff 75 08             	push   0x8(%ebp)
  800233:	e8 05 00 00 00       	call   80023d <vprintfmt>
}
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <vprintfmt>:
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 3c             	sub    $0x3c,%esp
  800246:	8b 75 08             	mov    0x8(%ebp),%esi
  800249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80024f:	eb 0a                	jmp    80025b <vprintfmt+0x1e>
			putch(ch, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	53                   	push   %ebx
  800255:	50                   	push   %eax
  800256:	ff d6                	call   *%esi
  800258:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80025b:	83 c7 01             	add    $0x1,%edi
  80025e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800262:	83 f8 25             	cmp    $0x25,%eax
  800265:	74 0c                	je     800273 <vprintfmt+0x36>
			if (ch == '\0')
  800267:	85 c0                	test   %eax,%eax
  800269:	75 e6                	jne    800251 <vprintfmt+0x14>
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		padc = ' ';
  800273:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800277:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80027e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800285:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80028c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800291:	8d 47 01             	lea    0x1(%edi),%eax
  800294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800297:	0f b6 17             	movzbl (%edi),%edx
  80029a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80029d:	3c 55                	cmp    $0x55,%al
  80029f:	0f 87 bb 03 00 00    	ja     800660 <vprintfmt+0x423>
  8002a5:	0f b6 c0             	movzbl %al,%eax
  8002a8:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8002af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002b6:	eb d9                	jmp    800291 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8002b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002bb:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002bf:	eb d0                	jmp    800291 <vprintfmt+0x54>
  8002c1:	0f b6 d2             	movzbl %dl,%edx
  8002c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002dc:	83 f9 09             	cmp    $0x9,%ecx
  8002df:	77 55                	ja     800336 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8002e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e4:	eb e9                	jmp    8002cf <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8b 00                	mov    (%eax),%eax
  8002eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f1:	8d 40 04             	lea    0x4(%eax),%eax
  8002f4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002fe:	79 91                	jns    800291 <vprintfmt+0x54>
				width = precision, precision = -1;
  800300:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800303:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800306:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80030d:	eb 82                	jmp    800291 <vprintfmt+0x54>
  80030f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800312:	85 d2                	test   %edx,%edx
  800314:	b8 00 00 00 00       	mov    $0x0,%eax
  800319:	0f 49 c2             	cmovns %edx,%eax
  80031c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800322:	e9 6a ff ff ff       	jmp    800291 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80032a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800331:	e9 5b ff ff ff       	jmp    800291 <vprintfmt+0x54>
  800336:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800339:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033c:	eb bc                	jmp    8002fa <vprintfmt+0xbd>
			lflag++;
  80033e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800344:	e9 48 ff ff ff       	jmp    800291 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800349:	8b 45 14             	mov    0x14(%ebp),%eax
  80034c:	8d 78 04             	lea    0x4(%eax),%edi
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	53                   	push   %ebx
  800353:	ff 30                	push   (%eax)
  800355:	ff d6                	call   *%esi
			break;
  800357:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80035a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80035d:	e9 9d 02 00 00       	jmp    8005ff <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800362:	8b 45 14             	mov    0x14(%ebp),%eax
  800365:	8d 78 04             	lea    0x4(%eax),%edi
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	89 d0                	mov    %edx,%eax
  80036c:	f7 d8                	neg    %eax
  80036e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800371:	83 f8 0f             	cmp    $0xf,%eax
  800374:	7f 23                	jg     800399 <vprintfmt+0x15c>
  800376:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80037d:	85 d2                	test   %edx,%edx
  80037f:	74 18                	je     800399 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800381:	52                   	push   %edx
  800382:	68 55 26 80 00       	push   $0x802655
  800387:	53                   	push   %ebx
  800388:	56                   	push   %esi
  800389:	e8 92 fe ff ff       	call   800220 <printfmt>
  80038e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800391:	89 7d 14             	mov    %edi,0x14(%ebp)
  800394:	e9 66 02 00 00       	jmp    8005ff <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800399:	50                   	push   %eax
  80039a:	68 a0 22 80 00       	push   $0x8022a0
  80039f:	53                   	push   %ebx
  8003a0:	56                   	push   %esi
  8003a1:	e8 7a fe ff ff       	call   800220 <printfmt>
  8003a6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ac:	e9 4e 02 00 00       	jmp    8005ff <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	83 c0 04             	add    $0x4,%eax
  8003b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003bf:	85 d2                	test   %edx,%edx
  8003c1:	b8 99 22 80 00       	mov    $0x802299,%eax
  8003c6:	0f 45 c2             	cmovne %edx,%eax
  8003c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d0:	7e 06                	jle    8003d8 <vprintfmt+0x19b>
  8003d2:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003d6:	75 0d                	jne    8003e5 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003db:	89 c7                	mov    %eax,%edi
  8003dd:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	eb 55                	jmp    80043a <vprintfmt+0x1fd>
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 d8             	push   -0x28(%ebp)
  8003eb:	ff 75 cc             	push   -0x34(%ebp)
  8003ee:	e8 0a 03 00 00       	call   8006fd <strnlen>
  8003f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f6:	29 c1                	sub    %eax,%ecx
  8003f8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800400:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800407:	eb 0f                	jmp    800418 <vprintfmt+0x1db>
					putch(padc, putdat);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	53                   	push   %ebx
  80040d:	ff 75 e0             	push   -0x20(%ebp)
  800410:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800412:	83 ef 01             	sub    $0x1,%edi
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	85 ff                	test   %edi,%edi
  80041a:	7f ed                	jg     800409 <vprintfmt+0x1cc>
  80041c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80041f:	85 d2                	test   %edx,%edx
  800421:	b8 00 00 00 00       	mov    $0x0,%eax
  800426:	0f 49 c2             	cmovns %edx,%eax
  800429:	29 c2                	sub    %eax,%edx
  80042b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042e:	eb a8                	jmp    8003d8 <vprintfmt+0x19b>
					putch(ch, putdat);
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	53                   	push   %ebx
  800434:	52                   	push   %edx
  800435:	ff d6                	call   *%esi
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043f:	83 c7 01             	add    $0x1,%edi
  800442:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800446:	0f be d0             	movsbl %al,%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	74 4b                	je     800498 <vprintfmt+0x25b>
  80044d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800451:	78 06                	js     800459 <vprintfmt+0x21c>
  800453:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800457:	78 1e                	js     800477 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800459:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045d:	74 d1                	je     800430 <vprintfmt+0x1f3>
  80045f:	0f be c0             	movsbl %al,%eax
  800462:	83 e8 20             	sub    $0x20,%eax
  800465:	83 f8 5e             	cmp    $0x5e,%eax
  800468:	76 c6                	jbe    800430 <vprintfmt+0x1f3>
					putch('?', putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	6a 3f                	push   $0x3f
  800470:	ff d6                	call   *%esi
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb c3                	jmp    80043a <vprintfmt+0x1fd>
  800477:	89 cf                	mov    %ecx,%edi
  800479:	eb 0e                	jmp    800489 <vprintfmt+0x24c>
				putch(' ', putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	6a 20                	push   $0x20
  800481:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ee                	jg     80047b <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80048d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800490:	89 45 14             	mov    %eax,0x14(%ebp)
  800493:	e9 67 01 00 00       	jmp    8005ff <vprintfmt+0x3c2>
  800498:	89 cf                	mov    %ecx,%edi
  80049a:	eb ed                	jmp    800489 <vprintfmt+0x24c>
	if (lflag >= 2)
  80049c:	83 f9 01             	cmp    $0x1,%ecx
  80049f:	7f 1b                	jg     8004bc <vprintfmt+0x27f>
	else if (lflag)
  8004a1:	85 c9                	test   %ecx,%ecx
  8004a3:	74 63                	je     800508 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8b 00                	mov    (%eax),%eax
  8004aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ad:	99                   	cltd   
  8004ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 40 04             	lea    0x4(%eax),%eax
  8004b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ba:	eb 17                	jmp    8004d3 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8b 50 04             	mov    0x4(%eax),%edx
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 40 08             	lea    0x8(%eax),%eax
  8004d0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004d9:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8004de:	85 c9                	test   %ecx,%ecx
  8004e0:	0f 89 ff 00 00 00    	jns    8005e5 <vprintfmt+0x3a8>
				putch('-', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	6a 2d                	push   $0x2d
  8004ec:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f4:	f7 da                	neg    %edx
  8004f6:	83 d1 00             	adc    $0x0,%ecx
  8004f9:	f7 d9                	neg    %ecx
  8004fb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004fe:	bf 0a 00 00 00       	mov    $0xa,%edi
  800503:	e9 dd 00 00 00       	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	99                   	cltd   
  800511:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 40 04             	lea    0x4(%eax),%eax
  80051a:	89 45 14             	mov    %eax,0x14(%ebp)
  80051d:	eb b4                	jmp    8004d3 <vprintfmt+0x296>
	if (lflag >= 2)
  80051f:	83 f9 01             	cmp    $0x1,%ecx
  800522:	7f 1e                	jg     800542 <vprintfmt+0x305>
	else if (lflag)
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 32                	je     80055a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 10                	mov    (%eax),%edx
  80052d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800532:	8d 40 04             	lea    0x4(%eax),%eax
  800535:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800538:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80053d:	e9 a3 00 00 00       	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 10                	mov    (%eax),%edx
  800547:	8b 48 04             	mov    0x4(%eax),%ecx
  80054a:	8d 40 08             	lea    0x8(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800550:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800555:	e9 8b 00 00 00       	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 10                	mov    (%eax),%edx
  80055f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800564:	8d 40 04             	lea    0x4(%eax),%eax
  800567:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80056f:	eb 74                	jmp    8005e5 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800571:	83 f9 01             	cmp    $0x1,%ecx
  800574:	7f 1b                	jg     800591 <vprintfmt+0x354>
	else if (lflag)
  800576:	85 c9                	test   %ecx,%ecx
  800578:	74 2c                	je     8005a6 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 10                	mov    (%eax),%edx
  80057f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80058a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80058f:	eb 54                	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8b 48 04             	mov    0x4(%eax),%ecx
  800599:	8d 40 08             	lea    0x8(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80059f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8005a4:	eb 3f                	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b0:	8d 40 04             	lea    0x4(%eax),%eax
  8005b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005b6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8005bb:	eb 28                	jmp    8005e5 <vprintfmt+0x3a8>
			putch('0', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 30                	push   $0x30
  8005c3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c5:	83 c4 08             	add    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	6a 78                	push   $0x78
  8005cb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005d7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005e0:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8005e5:	83 ec 0c             	sub    $0xc,%esp
  8005e8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005ec:	50                   	push   %eax
  8005ed:	ff 75 e0             	push   -0x20(%ebp)
  8005f0:	57                   	push   %edi
  8005f1:	51                   	push   %ecx
  8005f2:	52                   	push   %edx
  8005f3:	89 da                	mov    %ebx,%edx
  8005f5:	89 f0                	mov    %esi,%eax
  8005f7:	e8 5e fb ff ff       	call   80015a <printnum>
			break;
  8005fc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800602:	e9 54 fc ff ff       	jmp    80025b <vprintfmt+0x1e>
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7f 1b                	jg     800627 <vprintfmt+0x3ea>
	else if (lflag)
  80060c:	85 c9                	test   %ecx,%ecx
  80060e:	74 2c                	je     80063c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800620:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800625:	eb be                	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	8b 48 04             	mov    0x4(%eax),%ecx
  80062f:	8d 40 08             	lea    0x8(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800635:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80063a:	eb a9                	jmp    8005e5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
  800646:	8d 40 04             	lea    0x4(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800651:	eb 92                	jmp    8005e5 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 25                	push   $0x25
  800659:	ff d6                	call   *%esi
			break;
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	eb 9f                	jmp    8005ff <vprintfmt+0x3c2>
			putch('%', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 25                	push   $0x25
  800666:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	89 f8                	mov    %edi,%eax
  80066d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800671:	74 05                	je     800678 <vprintfmt+0x43b>
  800673:	83 e8 01             	sub    $0x1,%eax
  800676:	eb f5                	jmp    80066d <vprintfmt+0x430>
  800678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80067b:	eb 82                	jmp    8005ff <vprintfmt+0x3c2>

0080067d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 18             	sub    $0x18,%esp
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800690:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 26                	je     8006c4 <vsnprintf+0x47>
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	7e 22                	jle    8006c4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a2:	ff 75 14             	push   0x14(%ebp)
  8006a5:	ff 75 10             	push   0x10(%ebp)
  8006a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	68 03 02 80 00       	push   $0x800203
  8006b1:	e8 87 fb ff ff       	call   80023d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bf:	83 c4 10             	add    $0x10,%esp
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    
		return -E_INVAL;
  8006c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c9:	eb f7                	jmp    8006c2 <vsnprintf+0x45>

008006cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d4:	50                   	push   %eax
  8006d5:	ff 75 10             	push   0x10(%ebp)
  8006d8:	ff 75 0c             	push   0xc(%ebp)
  8006db:	ff 75 08             	push   0x8(%ebp)
  8006de:	e8 9a ff ff ff       	call   80067d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	eb 03                	jmp    8006f5 <strlen+0x10>
		n++;
  8006f2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8006f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f9:	75 f7                	jne    8006f2 <strlen+0xd>
	return n;
}
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800703:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 03                	jmp    800710 <strnlen+0x13>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800710:	39 d0                	cmp    %edx,%eax
  800712:	74 08                	je     80071c <strnlen+0x1f>
  800714:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800718:	75 f3                	jne    80070d <strnlen+0x10>
  80071a:	89 c2                	mov    %eax,%edx
	return n;
}
  80071c:	89 d0                	mov    %edx,%eax
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800733:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800736:	83 c0 01             	add    $0x1,%eax
  800739:	84 d2                	test   %dl,%dl
  80073b:	75 f2                	jne    80072f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80073d:	89 c8                	mov    %ecx,%eax
  80073f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	83 ec 10             	sub    $0x10,%esp
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074e:	53                   	push   %ebx
  80074f:	e8 91 ff ff ff       	call   8006e5 <strlen>
  800754:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800757:	ff 75 0c             	push   0xc(%ebp)
  80075a:	01 d8                	add    %ebx,%eax
  80075c:	50                   	push   %eax
  80075d:	e8 be ff ff ff       	call   800720 <strcpy>
	return dst;
}
  800762:	89 d8                	mov    %ebx,%eax
  800764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
  800774:	89 f3                	mov    %esi,%ebx
  800776:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800779:	89 f0                	mov    %esi,%eax
  80077b:	eb 0f                	jmp    80078c <strncpy+0x23>
		*dst++ = *src;
  80077d:	83 c0 01             	add    $0x1,%eax
  800780:	0f b6 0a             	movzbl (%edx),%ecx
  800783:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800786:	80 f9 01             	cmp    $0x1,%cl
  800789:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80078c:	39 d8                	cmp    %ebx,%eax
  80078e:	75 ed                	jne    80077d <strncpy+0x14>
	}
	return ret;
}
  800790:	89 f0                	mov    %esi,%eax
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	74 21                	je     8007cb <strlcpy+0x35>
  8007aa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ae:	89 f2                	mov    %esi,%edx
  8007b0:	eb 09                	jmp    8007bb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b2:	83 c1 01             	add    $0x1,%ecx
  8007b5:	83 c2 01             	add    $0x1,%edx
  8007b8:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8007bb:	39 c2                	cmp    %eax,%edx
  8007bd:	74 09                	je     8007c8 <strlcpy+0x32>
  8007bf:	0f b6 19             	movzbl (%ecx),%ebx
  8007c2:	84 db                	test   %bl,%bl
  8007c4:	75 ec                	jne    8007b2 <strlcpy+0x1c>
  8007c6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007c8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007cb:	29 f0                	sub    %esi,%eax
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007da:	eb 06                	jmp    8007e2 <strcmp+0x11>
		p++, q++;
  8007dc:	83 c1 01             	add    $0x1,%ecx
  8007df:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8007e2:	0f b6 01             	movzbl (%ecx),%eax
  8007e5:	84 c0                	test   %al,%al
  8007e7:	74 04                	je     8007ed <strcmp+0x1c>
  8007e9:	3a 02                	cmp    (%edx),%al
  8007eb:	74 ef                	je     8007dc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	0f b6 c0             	movzbl %al,%eax
  8007f0:	0f b6 12             	movzbl (%edx),%edx
  8007f3:	29 d0                	sub    %edx,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	89 c3                	mov    %eax,%ebx
  800803:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800806:	eb 06                	jmp    80080e <strncmp+0x17>
		n--, p++, q++;
  800808:	83 c0 01             	add    $0x1,%eax
  80080b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80080e:	39 d8                	cmp    %ebx,%eax
  800810:	74 18                	je     80082a <strncmp+0x33>
  800812:	0f b6 08             	movzbl (%eax),%ecx
  800815:	84 c9                	test   %cl,%cl
  800817:	74 04                	je     80081d <strncmp+0x26>
  800819:	3a 0a                	cmp    (%edx),%cl
  80081b:	74 eb                	je     800808 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081d:	0f b6 00             	movzbl (%eax),%eax
  800820:	0f b6 12             	movzbl (%edx),%edx
  800823:	29 d0                	sub    %edx,%eax
}
  800825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800828:	c9                   	leave  
  800829:	c3                   	ret    
		return 0;
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
  80082f:	eb f4                	jmp    800825 <strncmp+0x2e>

00800831 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083b:	eb 03                	jmp    800840 <strchr+0xf>
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 10             	movzbl (%eax),%edx
  800843:	84 d2                	test   %dl,%dl
  800845:	74 06                	je     80084d <strchr+0x1c>
		if (*s == c)
  800847:	38 ca                	cmp    %cl,%dl
  800849:	75 f2                	jne    80083d <strchr+0xc>
  80084b:	eb 05                	jmp    800852 <strchr+0x21>
			return (char *) s;
	return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800861:	38 ca                	cmp    %cl,%dl
  800863:	74 09                	je     80086e <strfind+0x1a>
  800865:	84 d2                	test   %dl,%dl
  800867:	74 05                	je     80086e <strfind+0x1a>
	for (; *s; s++)
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	eb f0                	jmp    80085e <strfind+0xa>
			break;
	return (char *) s;
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	57                   	push   %edi
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 7d 08             	mov    0x8(%ebp),%edi
  800879:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087c:	85 c9                	test   %ecx,%ecx
  80087e:	74 2f                	je     8008af <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800880:	89 f8                	mov    %edi,%eax
  800882:	09 c8                	or     %ecx,%eax
  800884:	a8 03                	test   $0x3,%al
  800886:	75 21                	jne    8008a9 <memset+0x39>
		c &= 0xFF;
  800888:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	c1 e0 08             	shl    $0x8,%eax
  800891:	89 d3                	mov    %edx,%ebx
  800893:	c1 e3 18             	shl    $0x18,%ebx
  800896:	89 d6                	mov    %edx,%esi
  800898:	c1 e6 10             	shl    $0x10,%esi
  80089b:	09 f3                	or     %esi,%ebx
  80089d:	09 da                	or     %ebx,%edx
  80089f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008a4:	fc                   	cld    
  8008a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a7:	eb 06                	jmp    8008af <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ac:	fc                   	cld    
  8008ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008af:	89 f8                	mov    %edi,%eax
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5f                   	pop    %edi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	57                   	push   %edi
  8008ba:	56                   	push   %esi
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c4:	39 c6                	cmp    %eax,%esi
  8008c6:	73 32                	jae    8008fa <memmove+0x44>
  8008c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cb:	39 c2                	cmp    %eax,%edx
  8008cd:	76 2b                	jbe    8008fa <memmove+0x44>
		s += n;
		d += n;
  8008cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	89 d6                	mov    %edx,%esi
  8008d4:	09 fe                	or     %edi,%esi
  8008d6:	09 ce                	or     %ecx,%esi
  8008d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008de:	75 0e                	jne    8008ee <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e0:	83 ef 04             	sub    $0x4,%edi
  8008e3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008e9:	fd                   	std    
  8008ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ec:	eb 09                	jmp    8008f7 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ee:	83 ef 01             	sub    $0x1,%edi
  8008f1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f4:	fd                   	std    
  8008f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f7:	fc                   	cld    
  8008f8:	eb 1a                	jmp    800914 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	89 f2                	mov    %esi,%edx
  8008fc:	09 c2                	or     %eax,%edx
  8008fe:	09 ca                	or     %ecx,%edx
  800900:	f6 c2 03             	test   $0x3,%dl
  800903:	75 0a                	jne    80090f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800905:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800908:	89 c7                	mov    %eax,%edi
  80090a:	fc                   	cld    
  80090b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090d:	eb 05                	jmp    800914 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80090f:	89 c7                	mov    %eax,%edi
  800911:	fc                   	cld    
  800912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80091e:	ff 75 10             	push   0x10(%ebp)
  800921:	ff 75 0c             	push   0xc(%ebp)
  800924:	ff 75 08             	push   0x8(%ebp)
  800927:	e8 8a ff ff ff       	call   8008b6 <memmove>
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093e:	eb 06                	jmp    800946 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800946:	39 f0                	cmp    %esi,%eax
  800948:	74 14                	je     80095e <memcmp+0x30>
		if (*s1 != *s2)
  80094a:	0f b6 08             	movzbl (%eax),%ecx
  80094d:	0f b6 1a             	movzbl (%edx),%ebx
  800950:	38 d9                	cmp    %bl,%cl
  800952:	74 ec                	je     800940 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800954:	0f b6 c1             	movzbl %cl,%eax
  800957:	0f b6 db             	movzbl %bl,%ebx
  80095a:	29 d8                	sub    %ebx,%eax
  80095c:	eb 05                	jmp    800963 <memcmp+0x35>
	}

	return 0;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800970:	89 c2                	mov    %eax,%edx
  800972:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800975:	eb 03                	jmp    80097a <memfind+0x13>
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 04                	jae    800982 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097e:	38 08                	cmp    %cl,(%eax)
  800980:	75 f5                	jne    800977 <memfind+0x10>
			break;
	return (void *) s;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 55 08             	mov    0x8(%ebp),%edx
  80098d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800990:	eb 03                	jmp    800995 <strtol+0x11>
		s++;
  800992:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800995:	0f b6 02             	movzbl (%edx),%eax
  800998:	3c 20                	cmp    $0x20,%al
  80099a:	74 f6                	je     800992 <strtol+0xe>
  80099c:	3c 09                	cmp    $0x9,%al
  80099e:	74 f2                	je     800992 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009a0:	3c 2b                	cmp    $0x2b,%al
  8009a2:	74 2a                	je     8009ce <strtol+0x4a>
	int neg = 0;
  8009a4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009a9:	3c 2d                	cmp    $0x2d,%al
  8009ab:	74 2b                	je     8009d8 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b3:	75 0f                	jne    8009c4 <strtol+0x40>
  8009b5:	80 3a 30             	cmpb   $0x30,(%edx)
  8009b8:	74 28                	je     8009e2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ba:	85 db                	test   %ebx,%ebx
  8009bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009c1:	0f 44 d8             	cmove  %eax,%ebx
  8009c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009cc:	eb 46                	jmp    800a14 <strtol+0x90>
		s++;
  8009ce:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d6:	eb d5                	jmp    8009ad <strtol+0x29>
		s++, neg = 1;
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e0:	eb cb                	jmp    8009ad <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e6:	74 0e                	je     8009f6 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8009e8:	85 db                	test   %ebx,%ebx
  8009ea:	75 d8                	jne    8009c4 <strtol+0x40>
		s++, base = 8;
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009f4:	eb ce                	jmp    8009c4 <strtol+0x40>
		s += 2, base = 16;
  8009f6:	83 c2 02             	add    $0x2,%edx
  8009f9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fe:	eb c4                	jmp    8009c4 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a00:	0f be c0             	movsbl %al,%eax
  800a03:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a06:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a09:	7d 3a                	jge    800a45 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a0b:	83 c2 01             	add    $0x1,%edx
  800a0e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a12:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a14:	0f b6 02             	movzbl (%edx),%eax
  800a17:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	80 fb 09             	cmp    $0x9,%bl
  800a1f:	76 df                	jbe    800a00 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a21:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 19             	cmp    $0x19,%bl
  800a29:	77 08                	ja     800a33 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a2b:	0f be c0             	movsbl %al,%eax
  800a2e:	83 e8 57             	sub    $0x57,%eax
  800a31:	eb d3                	jmp    800a06 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a33:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 08                	ja     800a45 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a3d:	0f be c0             	movsbl %al,%eax
  800a40:	83 e8 37             	sub    $0x37,%eax
  800a43:	eb c1                	jmp    800a06 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a49:	74 05                	je     800a50 <strtol+0xcc>
		*endptr = (char *) s;
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800a50:	89 c8                	mov    %ecx,%eax
  800a52:	f7 d8                	neg    %eax
  800a54:	85 ff                	test   %edi,%edi
  800a56:	0f 45 c8             	cmovne %eax,%ecx
}
  800a59:	89 c8                	mov    %ecx,%eax
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	8b 55 08             	mov    0x8(%ebp),%edx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7f 08                	jg     800ac7 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	50                   	push   %eax
  800acb:	6a 03                	push   $0x3
  800acd:	68 7f 25 80 00       	push   $0x80257f
  800ad2:	6a 2a                	push   $0x2a
  800ad4:	68 9c 25 80 00       	push   $0x80259c
  800ad9:	e8 9e 13 00 00       	call   801e7c <_panic>

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_yield>:

void
sys_yield(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b25:	be 00 00 00 00       	mov    $0x0,%esi
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b30:	b8 04 00 00 00       	mov    $0x4,%eax
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	89 f7                	mov    %esi,%edi
  800b3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7f 08                	jg     800b48 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 04                	push   $0x4
  800b4e:	68 7f 25 80 00       	push   $0x80257f
  800b53:	6a 2a                	push   $0x2a
  800b55:	68 9c 25 80 00       	push   $0x80259c
  800b5a:	e8 1d 13 00 00       	call   801e7c <_panic>

00800b5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7f 08                	jg     800b8a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 05                	push   $0x5
  800b90:	68 7f 25 80 00       	push   $0x80257f
  800b95:	6a 2a                	push   $0x2a
  800b97:	68 9c 25 80 00       	push   $0x80259c
  800b9c:	e8 db 12 00 00       	call   801e7c <_panic>

00800ba1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bba:	89 df                	mov    %ebx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7f 08                	jg     800bcc <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 06                	push   $0x6
  800bd2:	68 7f 25 80 00       	push   $0x80257f
  800bd7:	6a 2a                	push   $0x2a
  800bd9:	68 9c 25 80 00       	push   $0x80259c
  800bde:	e8 99 12 00 00       	call   801e7c <_panic>

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7f 08                	jg     800c0e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 08                	push   $0x8
  800c14:	68 7f 25 80 00       	push   $0x80257f
  800c19:	6a 2a                	push   $0x2a
  800c1b:	68 9c 25 80 00       	push   $0x80259c
  800c20:	e8 57 12 00 00       	call   801e7c <_panic>

00800c25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7f 08                	jg     800c50 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 09                	push   $0x9
  800c56:	68 7f 25 80 00       	push   $0x80257f
  800c5b:	6a 2a                	push   $0x2a
  800c5d:	68 9c 25 80 00       	push   $0x80259c
  800c62:	e8 15 12 00 00       	call   801e7c <_panic>

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7f 08                	jg     800c92 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 0a                	push   $0xa
  800c98:	68 7f 25 80 00       	push   $0x80257f
  800c9d:	6a 2a                	push   $0x2a
  800c9f:	68 9c 25 80 00       	push   $0x80259c
  800ca4:	e8 d3 11 00 00       	call   801e7c <_panic>

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cba:	be 00 00 00 00       	mov    $0x0,%esi
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 0d                	push   $0xd
  800cfc:	68 7f 25 80 00       	push   $0x80257f
  800d01:	6a 2a                	push   $0x2a
  800d03:	68 9c 25 80 00       	push   $0x80259c
  800d08:	e8 6f 11 00 00       	call   801e7c <_panic>

00800d0d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1d:	89 d1                	mov    %edx,%ecx
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	89 d7                	mov    %edx,%edi
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	b8 10 00 00 00       	mov    $0x10,%eax
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	05 00 00 00 30       	add    $0x30000000,%eax
  800d79:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	c1 ea 16             	shr    $0x16,%edx
  800da2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da9:	f6 c2 01             	test   $0x1,%dl
  800dac:	74 29                	je     800dd7 <fd_alloc+0x42>
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 0c             	shr    $0xc,%edx
  800db3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 18                	je     800dd7 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800dbf:	05 00 10 00 00       	add    $0x1000,%eax
  800dc4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc9:	75 d2                	jne    800d9d <fd_alloc+0x8>
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800dd0:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800dd5:	eb 05                	jmp    800ddc <fd_alloc+0x47>
			return 0;
  800dd7:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 02                	mov    %eax,(%edx)
}
  800de1:	89 c8                	mov    %ecx,%eax
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800deb:	83 f8 1f             	cmp    $0x1f,%eax
  800dee:	77 30                	ja     800e20 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df0:	c1 e0 0c             	shl    $0xc,%eax
  800df3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df8:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800dfe:	f6 c2 01             	test   $0x1,%dl
  800e01:	74 24                	je     800e27 <fd_lookup+0x42>
  800e03:	89 c2                	mov    %eax,%edx
  800e05:	c1 ea 0c             	shr    $0xc,%edx
  800e08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0f:	f6 c2 01             	test   $0x1,%dl
  800e12:	74 1a                	je     800e2e <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e17:	89 02                	mov    %eax,(%edx)
	return 0;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    
		return -E_INVAL;
  800e20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e25:	eb f7                	jmp    800e1e <fd_lookup+0x39>
		return -E_INVAL;
  800e27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2c:	eb f0                	jmp    800e1e <fd_lookup+0x39>
  800e2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e33:	eb e9                	jmp    800e1e <fd_lookup+0x39>

00800e35 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	53                   	push   %ebx
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e44:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800e49:	39 13                	cmp    %edx,(%ebx)
  800e4b:	74 37                	je     800e84 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800e4d:	83 c0 01             	add    $0x1,%eax
  800e50:	8b 1c 85 28 26 80 00 	mov    0x802628(,%eax,4),%ebx
  800e57:	85 db                	test   %ebx,%ebx
  800e59:	75 ee                	jne    800e49 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e5b:	a1 00 40 80 00       	mov    0x804000,%eax
  800e60:	8b 40 58             	mov    0x58(%eax),%eax
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	52                   	push   %edx
  800e67:	50                   	push   %eax
  800e68:	68 ac 25 80 00       	push   $0x8025ac
  800e6d:	e8 d4 f2 ff ff       	call   800146 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7d:	89 1a                	mov    %ebx,(%edx)
}
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    
			return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	eb ef                	jmp    800e7a <dev_lookup+0x45>

00800e8b <fd_close>:
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 24             	sub    $0x24,%esp
  800e94:	8b 75 08             	mov    0x8(%ebp),%esi
  800e97:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e9d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea4:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea7:	50                   	push   %eax
  800ea8:	e8 38 ff ff ff       	call   800de5 <fd_lookup>
  800ead:	89 c3                	mov    %eax,%ebx
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	78 05                	js     800ebb <fd_close+0x30>
	    || fd != fd2)
  800eb6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eb9:	74 16                	je     800ed1 <fd_close+0x46>
		return (must_exist ? r : 0);
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	84 c0                	test   %al,%al
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	0f 44 d8             	cmove  %eax,%ebx
}
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed1:	83 ec 08             	sub    $0x8,%esp
  800ed4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ed7:	50                   	push   %eax
  800ed8:	ff 36                	push   (%esi)
  800eda:	e8 56 ff ff ff       	call   800e35 <dev_lookup>
  800edf:	89 c3                	mov    %eax,%ebx
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	78 1a                	js     800f02 <fd_close+0x77>
		if (dev->dev_close)
  800ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eeb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	74 0b                	je     800f02 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800ef7:	83 ec 0c             	sub    $0xc,%esp
  800efa:	56                   	push   %esi
  800efb:	ff d0                	call   *%eax
  800efd:	89 c3                	mov    %eax,%ebx
  800eff:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	56                   	push   %esi
  800f06:	6a 00                	push   $0x0
  800f08:	e8 94 fc ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	eb b5                	jmp    800ec7 <fd_close+0x3c>

00800f12 <close>:

int
close(int fdnum)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1b:	50                   	push   %eax
  800f1c:	ff 75 08             	push   0x8(%ebp)
  800f1f:	e8 c1 fe ff ff       	call   800de5 <fd_lookup>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 02                	jns    800f2d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    
		return fd_close(fd, 1);
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	6a 01                	push   $0x1
  800f32:	ff 75 f4             	push   -0xc(%ebp)
  800f35:	e8 51 ff ff ff       	call   800e8b <fd_close>
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	eb ec                	jmp    800f2b <close+0x19>

00800f3f <close_all>:

void
close_all(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	53                   	push   %ebx
  800f43:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	53                   	push   %ebx
  800f4f:	e8 be ff ff ff       	call   800f12 <close>
	for (i = 0; i < MAXFD; i++)
  800f54:	83 c3 01             	add    $0x1,%ebx
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	83 fb 20             	cmp    $0x20,%ebx
  800f5d:	75 ec                	jne    800f4b <close_all+0xc>
}
  800f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f70:	50                   	push   %eax
  800f71:	ff 75 08             	push   0x8(%ebp)
  800f74:	e8 6c fe ff ff       	call   800de5 <fd_lookup>
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 7f                	js     801001 <dup+0x9d>
		return r;
	close(newfdnum);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	ff 75 0c             	push   0xc(%ebp)
  800f88:	e8 85 ff ff ff       	call   800f12 <close>

	newfd = INDEX2FD(newfdnum);
  800f8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f90:	c1 e6 0c             	shl    $0xc,%esi
  800f93:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f9c:	89 3c 24             	mov    %edi,(%esp)
  800f9f:	e8 da fd ff ff       	call   800d7e <fd2data>
  800fa4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fa6:	89 34 24             	mov    %esi,(%esp)
  800fa9:	e8 d0 fd ff ff       	call   800d7e <fd2data>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb4:	89 d8                	mov    %ebx,%eax
  800fb6:	c1 e8 16             	shr    $0x16,%eax
  800fb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc0:	a8 01                	test   $0x1,%al
  800fc2:	74 11                	je     800fd5 <dup+0x71>
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	c1 e8 0c             	shr    $0xc,%eax
  800fc9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd0:	f6 c2 01             	test   $0x1,%dl
  800fd3:	75 36                	jne    80100b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd5:	89 f8                	mov    %edi,%eax
  800fd7:	c1 e8 0c             	shr    $0xc,%eax
  800fda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe9:	50                   	push   %eax
  800fea:	56                   	push   %esi
  800feb:	6a 00                	push   $0x0
  800fed:	57                   	push   %edi
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 6a fb ff ff       	call   800b5f <sys_page_map>
  800ff5:	89 c3                	mov    %eax,%ebx
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 33                	js     801031 <dup+0xcd>
		goto err;

	return newfdnum;
  800ffe:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801001:	89 d8                	mov    %ebx,%eax
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80100b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	25 07 0e 00 00       	and    $0xe07,%eax
  80101a:	50                   	push   %eax
  80101b:	ff 75 d4             	push   -0x2c(%ebp)
  80101e:	6a 00                	push   $0x0
  801020:	53                   	push   %ebx
  801021:	6a 00                	push   $0x0
  801023:	e8 37 fb ff ff       	call   800b5f <sys_page_map>
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 a4                	jns    800fd5 <dup+0x71>
	sys_page_unmap(0, newfd);
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	56                   	push   %esi
  801035:	6a 00                	push   $0x0
  801037:	e8 65 fb ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80103c:	83 c4 08             	add    $0x8,%esp
  80103f:	ff 75 d4             	push   -0x2c(%ebp)
  801042:	6a 00                	push   $0x0
  801044:	e8 58 fb ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	eb b3                	jmp    801001 <dup+0x9d>

0080104e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 18             	sub    $0x18,%esp
  801056:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801059:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	56                   	push   %esi
  80105e:	e8 82 fd ff ff       	call   800de5 <fd_lookup>
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	78 3c                	js     8010a6 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801073:	50                   	push   %eax
  801074:	ff 33                	push   (%ebx)
  801076:	e8 ba fd ff ff       	call   800e35 <dev_lookup>
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 24                	js     8010a6 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801082:	8b 43 08             	mov    0x8(%ebx),%eax
  801085:	83 e0 03             	and    $0x3,%eax
  801088:	83 f8 01             	cmp    $0x1,%eax
  80108b:	74 20                	je     8010ad <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80108d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801090:	8b 40 08             	mov    0x8(%eax),%eax
  801093:	85 c0                	test   %eax,%eax
  801095:	74 37                	je     8010ce <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	ff 75 10             	push   0x10(%ebp)
  80109d:	ff 75 0c             	push   0xc(%ebp)
  8010a0:	53                   	push   %ebx
  8010a1:	ff d0                	call   *%eax
  8010a3:	83 c4 10             	add    $0x10,%esp
}
  8010a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ad:	a1 00 40 80 00       	mov    0x804000,%eax
  8010b2:	8b 40 58             	mov    0x58(%eax),%eax
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	56                   	push   %esi
  8010b9:	50                   	push   %eax
  8010ba:	68 ed 25 80 00       	push   $0x8025ed
  8010bf:	e8 82 f0 ff ff       	call   800146 <cprintf>
		return -E_INVAL;
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cc:	eb d8                	jmp    8010a6 <read+0x58>
		return -E_NOT_SUPP;
  8010ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010d3:	eb d1                	jmp    8010a6 <read+0x58>

008010d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e9:	eb 02                	jmp    8010ed <readn+0x18>
  8010eb:	01 c3                	add    %eax,%ebx
  8010ed:	39 f3                	cmp    %esi,%ebx
  8010ef:	73 21                	jae    801112 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	89 f0                	mov    %esi,%eax
  8010f6:	29 d8                	sub    %ebx,%eax
  8010f8:	50                   	push   %eax
  8010f9:	89 d8                	mov    %ebx,%eax
  8010fb:	03 45 0c             	add    0xc(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	57                   	push   %edi
  801100:	e8 49 ff ff ff       	call   80104e <read>
		if (m < 0)
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 04                	js     801110 <readn+0x3b>
			return m;
		if (m == 0)
  80110c:	75 dd                	jne    8010eb <readn+0x16>
  80110e:	eb 02                	jmp    801112 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801110:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801112:	89 d8                	mov    %ebx,%eax
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 18             	sub    $0x18,%esp
  801124:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801127:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	53                   	push   %ebx
  80112c:	e8 b4 fc ff ff       	call   800de5 <fd_lookup>
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	85 c0                	test   %eax,%eax
  801136:	78 37                	js     80116f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801138:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80113b:	83 ec 08             	sub    $0x8,%esp
  80113e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	ff 36                	push   (%esi)
  801144:	e8 ec fc ff ff       	call   800e35 <dev_lookup>
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 1f                	js     80116f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801150:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801154:	74 20                	je     801176 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801159:	8b 40 0c             	mov    0xc(%eax),%eax
  80115c:	85 c0                	test   %eax,%eax
  80115e:	74 37                	je     801197 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	ff 75 10             	push   0x10(%ebp)
  801166:	ff 75 0c             	push   0xc(%ebp)
  801169:	56                   	push   %esi
  80116a:	ff d0                	call   *%eax
  80116c:	83 c4 10             	add    $0x10,%esp
}
  80116f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801176:	a1 00 40 80 00       	mov    0x804000,%eax
  80117b:	8b 40 58             	mov    0x58(%eax),%eax
  80117e:	83 ec 04             	sub    $0x4,%esp
  801181:	53                   	push   %ebx
  801182:	50                   	push   %eax
  801183:	68 09 26 80 00       	push   $0x802609
  801188:	e8 b9 ef ff ff       	call   800146 <cprintf>
		return -E_INVAL;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801195:	eb d8                	jmp    80116f <write+0x53>
		return -E_NOT_SUPP;
  801197:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80119c:	eb d1                	jmp    80116f <write+0x53>

0080119e <seek>:

int
seek(int fdnum, off_t offset)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a7:	50                   	push   %eax
  8011a8:	ff 75 08             	push   0x8(%ebp)
  8011ab:	e8 35 fc ff ff       	call   800de5 <fd_lookup>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 0e                	js     8011c5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 18             	sub    $0x18,%esp
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	53                   	push   %ebx
  8011d7:	e8 09 fc ff ff       	call   800de5 <fd_lookup>
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 34                	js     801217 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	ff 36                	push   (%esi)
  8011ef:	e8 41 fc ff ff       	call   800e35 <dev_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 1c                	js     801217 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011fb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8011ff:	74 1d                	je     80121e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801201:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801204:	8b 40 18             	mov    0x18(%eax),%eax
  801207:	85 c0                	test   %eax,%eax
  801209:	74 34                	je     80123f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	ff 75 0c             	push   0xc(%ebp)
  801211:	56                   	push   %esi
  801212:	ff d0                	call   *%eax
  801214:	83 c4 10             	add    $0x10,%esp
}
  801217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80121e:	a1 00 40 80 00       	mov    0x804000,%eax
  801223:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801226:	83 ec 04             	sub    $0x4,%esp
  801229:	53                   	push   %ebx
  80122a:	50                   	push   %eax
  80122b:	68 cc 25 80 00       	push   $0x8025cc
  801230:	e8 11 ef ff ff       	call   800146 <cprintf>
		return -E_INVAL;
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123d:	eb d8                	jmp    801217 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80123f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801244:	eb d1                	jmp    801217 <ftruncate+0x50>

00801246 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 18             	sub    $0x18,%esp
  80124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801251:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801254:	50                   	push   %eax
  801255:	ff 75 08             	push   0x8(%ebp)
  801258:	e8 88 fb ff ff       	call   800de5 <fd_lookup>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 49                	js     8012ad <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 36                	push   (%esi)
  801270:	e8 c0 fb ff ff       	call   800e35 <dev_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 31                	js     8012ad <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80127c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801283:	74 2f                	je     8012b4 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801285:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801288:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128f:	00 00 00 
	stat->st_isdir = 0;
  801292:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801299:	00 00 00 
	stat->st_dev = dev;
  80129c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	53                   	push   %ebx
  8012a6:	56                   	push   %esi
  8012a7:	ff 50 14             	call   *0x14(%eax)
  8012aa:	83 c4 10             	add    $0x10,%esp
}
  8012ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    
		return -E_NOT_SUPP;
  8012b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b9:	eb f2                	jmp    8012ad <fstat+0x67>

008012bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	6a 00                	push   $0x0
  8012c5:	ff 75 08             	push   0x8(%ebp)
  8012c8:	e8 e4 01 00 00       	call   8014b1 <open>
  8012cd:	89 c3                	mov    %eax,%ebx
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 1b                	js     8012f1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 75 0c             	push   0xc(%ebp)
  8012dc:	50                   	push   %eax
  8012dd:	e8 64 ff ff ff       	call   801246 <fstat>
  8012e2:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e4:	89 1c 24             	mov    %ebx,(%esp)
  8012e7:	e8 26 fc ff ff       	call   800f12 <close>
	return r;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	89 f3                	mov    %esi,%ebx
}
  8012f1:	89 d8                	mov    %ebx,%eax
  8012f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	89 c6                	mov    %eax,%esi
  801301:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801303:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80130a:	74 27                	je     801333 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80130c:	6a 07                	push   $0x7
  80130e:	68 00 50 80 00       	push   $0x805000
  801313:	56                   	push   %esi
  801314:	ff 35 00 60 80 00    	push   0x806000
  80131a:	e8 13 0c 00 00       	call   801f32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80131f:	83 c4 0c             	add    $0xc,%esp
  801322:	6a 00                	push   $0x0
  801324:	53                   	push   %ebx
  801325:	6a 00                	push   $0x0
  801327:	e8 96 0b 00 00       	call   801ec2 <ipc_recv>
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	6a 01                	push   $0x1
  801338:	e8 49 0c 00 00       	call   801f86 <ipc_find_env>
  80133d:	a3 00 60 80 00       	mov    %eax,0x806000
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	eb c5                	jmp    80130c <fsipc+0x12>

00801347 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	8b 40 0c             	mov    0xc(%eax),%eax
  801353:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801360:	ba 00 00 00 00       	mov    $0x0,%edx
  801365:	b8 02 00 00 00       	mov    $0x2,%eax
  80136a:	e8 8b ff ff ff       	call   8012fa <fsipc>
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <devfile_flush>:
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	8b 40 0c             	mov    0xc(%eax),%eax
  80137d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801382:	ba 00 00 00 00       	mov    $0x0,%edx
  801387:	b8 06 00 00 00       	mov    $0x6,%eax
  80138c:	e8 69 ff ff ff       	call   8012fa <fsipc>
}
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <devfile_stat>:
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	53                   	push   %ebx
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b2:	e8 43 ff ff ff       	call   8012fa <fsipc>
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 2c                	js     8013e7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	68 00 50 80 00       	push   $0x805000
  8013c3:	53                   	push   %ebx
  8013c4:	e8 57 f3 ff ff       	call   800720 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <devfile_write>:
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013fa:	39 d0                	cmp    %edx,%eax
  8013fc:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801402:	8b 52 0c             	mov    0xc(%edx),%edx
  801405:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80140b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801410:	50                   	push   %eax
  801411:	ff 75 0c             	push   0xc(%ebp)
  801414:	68 08 50 80 00       	push   $0x805008
  801419:	e8 98 f4 ff ff       	call   8008b6 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80141e:	ba 00 00 00 00       	mov    $0x0,%edx
  801423:	b8 04 00 00 00       	mov    $0x4,%eax
  801428:	e8 cd fe ff ff       	call   8012fa <fsipc>
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <devfile_read>:
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801442:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801448:	ba 00 00 00 00       	mov    $0x0,%edx
  80144d:	b8 03 00 00 00       	mov    $0x3,%eax
  801452:	e8 a3 fe ff ff       	call   8012fa <fsipc>
  801457:	89 c3                	mov    %eax,%ebx
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 1f                	js     80147c <devfile_read+0x4d>
	assert(r <= n);
  80145d:	39 f0                	cmp    %esi,%eax
  80145f:	77 24                	ja     801485 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801461:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801466:	7f 33                	jg     80149b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	50                   	push   %eax
  80146c:	68 00 50 80 00       	push   $0x805000
  801471:	ff 75 0c             	push   0xc(%ebp)
  801474:	e8 3d f4 ff ff       	call   8008b6 <memmove>
	return r;
  801479:	83 c4 10             	add    $0x10,%esp
}
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    
	assert(r <= n);
  801485:	68 3c 26 80 00       	push   $0x80263c
  80148a:	68 43 26 80 00       	push   $0x802643
  80148f:	6a 7c                	push   $0x7c
  801491:	68 58 26 80 00       	push   $0x802658
  801496:	e8 e1 09 00 00       	call   801e7c <_panic>
	assert(r <= PGSIZE);
  80149b:	68 63 26 80 00       	push   $0x802663
  8014a0:	68 43 26 80 00       	push   $0x802643
  8014a5:	6a 7d                	push   $0x7d
  8014a7:	68 58 26 80 00       	push   $0x802658
  8014ac:	e8 cb 09 00 00       	call   801e7c <_panic>

008014b1 <open>:
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	56                   	push   %esi
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 1c             	sub    $0x1c,%esp
  8014b9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014bc:	56                   	push   %esi
  8014bd:	e8 23 f2 ff ff       	call   8006e5 <strlen>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ca:	7f 6c                	jg     801538 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014cc:	83 ec 0c             	sub    $0xc,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	e8 bd f8 ff ff       	call   800d95 <fd_alloc>
  8014d8:	89 c3                	mov    %eax,%ebx
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 3c                	js     80151d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	56                   	push   %esi
  8014e5:	68 00 50 80 00       	push   $0x805000
  8014ea:	e8 31 f2 ff ff       	call   800720 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ff:	e8 f6 fd ff ff       	call   8012fa <fsipc>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 19                	js     801526 <open+0x75>
	return fd2num(fd);
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	ff 75 f4             	push   -0xc(%ebp)
  801513:	e8 56 f8 ff ff       	call   800d6e <fd2num>
  801518:	89 c3                	mov    %eax,%ebx
  80151a:	83 c4 10             	add    $0x10,%esp
}
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    
		fd_close(fd, 0);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	6a 00                	push   $0x0
  80152b:	ff 75 f4             	push   -0xc(%ebp)
  80152e:	e8 58 f9 ff ff       	call   800e8b <fd_close>
		return r;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb e5                	jmp    80151d <open+0x6c>
		return -E_BAD_PATH;
  801538:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80153d:	eb de                	jmp    80151d <open+0x6c>

0080153f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	b8 08 00 00 00       	mov    $0x8,%eax
  80154f:	e8 a6 fd ff ff       	call   8012fa <fsipc>
}
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80155c:	68 6f 26 80 00       	push   $0x80266f
  801561:	ff 75 0c             	push   0xc(%ebp)
  801564:	e8 b7 f1 ff ff       	call   800720 <strcpy>
	return 0;
}
  801569:	b8 00 00 00 00       	mov    $0x0,%eax
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <devsock_close>:
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	53                   	push   %ebx
  801574:	83 ec 10             	sub    $0x10,%esp
  801577:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80157a:	53                   	push   %ebx
  80157b:	e8 45 0a 00 00       	call   801fc5 <pageref>
  801580:	89 c2                	mov    %eax,%edx
  801582:	83 c4 10             	add    $0x10,%esp
		return 0;
  801585:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80158a:	83 fa 01             	cmp    $0x1,%edx
  80158d:	74 05                	je     801594 <devsock_close+0x24>
}
  80158f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801592:	c9                   	leave  
  801593:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	ff 73 0c             	push   0xc(%ebx)
  80159a:	e8 b7 02 00 00       	call   801856 <nsipc_close>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	eb eb                	jmp    80158f <devsock_close+0x1f>

008015a4 <devsock_write>:
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015aa:	6a 00                	push   $0x0
  8015ac:	ff 75 10             	push   0x10(%ebp)
  8015af:	ff 75 0c             	push   0xc(%ebp)
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	ff 70 0c             	push   0xc(%eax)
  8015b8:	e8 79 03 00 00       	call   801936 <nsipc_send>
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <devsock_read>:
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015c5:	6a 00                	push   $0x0
  8015c7:	ff 75 10             	push   0x10(%ebp)
  8015ca:	ff 75 0c             	push   0xc(%ebp)
  8015cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d0:	ff 70 0c             	push   0xc(%eax)
  8015d3:	e8 ef 02 00 00       	call   8018c7 <nsipc_recv>
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <fd2sockid>:
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015e3:	52                   	push   %edx
  8015e4:	50                   	push   %eax
  8015e5:	e8 fb f7 ff ff       	call   800de5 <fd_lookup>
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 10                	js     801601 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8015f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015fa:	39 08                	cmp    %ecx,(%eax)
  8015fc:	75 05                	jne    801603 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8015fe:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801601:	c9                   	leave  
  801602:	c3                   	ret    
		return -E_NOT_SUPP;
  801603:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801608:	eb f7                	jmp    801601 <fd2sockid+0x27>

0080160a <alloc_sockfd>:
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	83 ec 1c             	sub    $0x1c,%esp
  801612:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	e8 78 f7 ff ff       	call   800d95 <fd_alloc>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 43                	js     801669 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	68 07 04 00 00       	push   $0x407
  80162e:	ff 75 f4             	push   -0xc(%ebp)
  801631:	6a 00                	push   $0x0
  801633:	e8 e4 f4 ff ff       	call   800b1c <sys_page_alloc>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 28                	js     801669 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801641:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801644:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80164a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80164c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801656:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	50                   	push   %eax
  80165d:	e8 0c f7 ff ff       	call   800d6e <fd2num>
  801662:	89 c3                	mov    %eax,%ebx
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	eb 0c                	jmp    801675 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801669:	83 ec 0c             	sub    $0xc,%esp
  80166c:	56                   	push   %esi
  80166d:	e8 e4 01 00 00       	call   801856 <nsipc_close>
		return r;
  801672:	83 c4 10             	add    $0x10,%esp
}
  801675:	89 d8                	mov    %ebx,%eax
  801677:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <accept>:
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801684:	8b 45 08             	mov    0x8(%ebp),%eax
  801687:	e8 4e ff ff ff       	call   8015da <fd2sockid>
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 1b                	js     8016ab <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801690:	83 ec 04             	sub    $0x4,%esp
  801693:	ff 75 10             	push   0x10(%ebp)
  801696:	ff 75 0c             	push   0xc(%ebp)
  801699:	50                   	push   %eax
  80169a:	e8 0e 01 00 00       	call   8017ad <nsipc_accept>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 05                	js     8016ab <accept+0x2d>
	return alloc_sockfd(r);
  8016a6:	e8 5f ff ff ff       	call   80160a <alloc_sockfd>
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <bind>:
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	e8 1f ff ff ff       	call   8015da <fd2sockid>
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 12                	js     8016d1 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8016bf:	83 ec 04             	sub    $0x4,%esp
  8016c2:	ff 75 10             	push   0x10(%ebp)
  8016c5:	ff 75 0c             	push   0xc(%ebp)
  8016c8:	50                   	push   %eax
  8016c9:	e8 31 01 00 00       	call   8017ff <nsipc_bind>
  8016ce:	83 c4 10             	add    $0x10,%esp
}
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <shutdown>:
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	e8 f9 fe ff ff       	call   8015da <fd2sockid>
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 0f                	js     8016f4 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	ff 75 0c             	push   0xc(%ebp)
  8016eb:	50                   	push   %eax
  8016ec:	e8 43 01 00 00       	call   801834 <nsipc_shutdown>
  8016f1:	83 c4 10             	add    $0x10,%esp
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <connect>:
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	e8 d6 fe ff ff       	call   8015da <fd2sockid>
  801704:	85 c0                	test   %eax,%eax
  801706:	78 12                	js     80171a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	ff 75 10             	push   0x10(%ebp)
  80170e:	ff 75 0c             	push   0xc(%ebp)
  801711:	50                   	push   %eax
  801712:	e8 59 01 00 00       	call   801870 <nsipc_connect>
  801717:	83 c4 10             	add    $0x10,%esp
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <listen>:
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	e8 b0 fe ff ff       	call   8015da <fd2sockid>
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 0f                	js     80173d <listen+0x21>
	return nsipc_listen(r, backlog);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	ff 75 0c             	push   0xc(%ebp)
  801734:	50                   	push   %eax
  801735:	e8 6b 01 00 00       	call   8018a5 <nsipc_listen>
  80173a:	83 c4 10             	add    $0x10,%esp
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <socket>:

int
socket(int domain, int type, int protocol)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801745:	ff 75 10             	push   0x10(%ebp)
  801748:	ff 75 0c             	push   0xc(%ebp)
  80174b:	ff 75 08             	push   0x8(%ebp)
  80174e:	e8 41 02 00 00       	call   801994 <nsipc_socket>
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 05                	js     80175f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80175a:	e8 ab fe ff ff       	call   80160a <alloc_sockfd>
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 04             	sub    $0x4,%esp
  801768:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80176a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801771:	74 26                	je     801799 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801773:	6a 07                	push   $0x7
  801775:	68 00 70 80 00       	push   $0x807000
  80177a:	53                   	push   %ebx
  80177b:	ff 35 00 80 80 00    	push   0x808000
  801781:	e8 ac 07 00 00       	call   801f32 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801786:	83 c4 0c             	add    $0xc,%esp
  801789:	6a 00                	push   $0x0
  80178b:	6a 00                	push   $0x0
  80178d:	6a 00                	push   $0x0
  80178f:	e8 2e 07 00 00       	call   801ec2 <ipc_recv>
}
  801794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801797:	c9                   	leave  
  801798:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	6a 02                	push   $0x2
  80179e:	e8 e3 07 00 00       	call   801f86 <ipc_find_env>
  8017a3:	a3 00 80 80 00       	mov    %eax,0x808000
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	eb c6                	jmp    801773 <nsipc+0x12>

008017ad <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
  8017b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017bd:	8b 06                	mov    (%esi),%eax
  8017bf:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c9:	e8 93 ff ff ff       	call   801761 <nsipc>
  8017ce:	89 c3                	mov    %eax,%ebx
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	79 09                	jns    8017dd <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8017d4:	89 d8                	mov    %ebx,%eax
  8017d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017dd:	83 ec 04             	sub    $0x4,%esp
  8017e0:	ff 35 10 70 80 00    	push   0x807010
  8017e6:	68 00 70 80 00       	push   $0x807000
  8017eb:	ff 75 0c             	push   0xc(%ebp)
  8017ee:	e8 c3 f0 ff ff       	call   8008b6 <memmove>
		*addrlen = ret->ret_addrlen;
  8017f3:	a1 10 70 80 00       	mov    0x807010,%eax
  8017f8:	89 06                	mov    %eax,(%esi)
  8017fa:	83 c4 10             	add    $0x10,%esp
	return r;
  8017fd:	eb d5                	jmp    8017d4 <nsipc_accept+0x27>

008017ff <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801809:	8b 45 08             	mov    0x8(%ebp),%eax
  80180c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801811:	53                   	push   %ebx
  801812:	ff 75 0c             	push   0xc(%ebp)
  801815:	68 04 70 80 00       	push   $0x807004
  80181a:	e8 97 f0 ff ff       	call   8008b6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80181f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801825:	b8 02 00 00 00       	mov    $0x2,%eax
  80182a:	e8 32 ff ff ff       	call   801761 <nsipc>
}
  80182f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801842:	8b 45 0c             	mov    0xc(%ebp),%eax
  801845:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80184a:	b8 03 00 00 00       	mov    $0x3,%eax
  80184f:	e8 0d ff ff ff       	call   801761 <nsipc>
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <nsipc_close>:

int
nsipc_close(int s)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801864:	b8 04 00 00 00       	mov    $0x4,%eax
  801869:	e8 f3 fe ff ff       	call   801761 <nsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801882:	53                   	push   %ebx
  801883:	ff 75 0c             	push   0xc(%ebp)
  801886:	68 04 70 80 00       	push   $0x807004
  80188b:	e8 26 f0 ff ff       	call   8008b6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801890:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801896:	b8 05 00 00 00       	mov    $0x5,%eax
  80189b:	e8 c1 fe ff ff       	call   801761 <nsipc>
}
  8018a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8018bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c0:	e8 9c fe ff ff       	call   801761 <nsipc>
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
  8018cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8018d7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8018dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018ea:	e8 72 fe ff ff       	call   801761 <nsipc>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 22                	js     801917 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8018f5:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8018fa:	39 c6                	cmp    %eax,%esi
  8018fc:	0f 4e c6             	cmovle %esi,%eax
  8018ff:	39 c3                	cmp    %eax,%ebx
  801901:	7f 1d                	jg     801920 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	53                   	push   %ebx
  801907:	68 00 70 80 00       	push   $0x807000
  80190c:	ff 75 0c             	push   0xc(%ebp)
  80190f:	e8 a2 ef ff ff       	call   8008b6 <memmove>
  801914:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801917:	89 d8                	mov    %ebx,%eax
  801919:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801920:	68 7b 26 80 00       	push   $0x80267b
  801925:	68 43 26 80 00       	push   $0x802643
  80192a:	6a 62                	push   $0x62
  80192c:	68 90 26 80 00       	push   $0x802690
  801931:	e8 46 05 00 00       	call   801e7c <_panic>

00801936 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 04             	sub    $0x4,%esp
  80193d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801948:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80194e:	7f 2e                	jg     80197e <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801950:	83 ec 04             	sub    $0x4,%esp
  801953:	53                   	push   %ebx
  801954:	ff 75 0c             	push   0xc(%ebp)
  801957:	68 0c 70 80 00       	push   $0x80700c
  80195c:	e8 55 ef ff ff       	call   8008b6 <memmove>
	nsipcbuf.send.req_size = size;
  801961:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801967:	8b 45 14             	mov    0x14(%ebp),%eax
  80196a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80196f:	b8 08 00 00 00       	mov    $0x8,%eax
  801974:	e8 e8 fd ff ff       	call   801761 <nsipc>
}
  801979:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    
	assert(size < 1600);
  80197e:	68 9c 26 80 00       	push   $0x80269c
  801983:	68 43 26 80 00       	push   $0x802643
  801988:	6a 6d                	push   $0x6d
  80198a:	68 90 26 80 00       	push   $0x802690
  80198f:	e8 e8 04 00 00       	call   801e7c <_panic>

00801994 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8019a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8019aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ad:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8019b2:	b8 09 00 00 00       	mov    $0x9,%eax
  8019b7:	e8 a5 fd ff ff       	call   801761 <nsipc>
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	ff 75 08             	push   0x8(%ebp)
  8019cc:	e8 ad f3 ff ff       	call   800d7e <fd2data>
  8019d1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d3:	83 c4 08             	add    $0x8,%esp
  8019d6:	68 a8 26 80 00       	push   $0x8026a8
  8019db:	53                   	push   %ebx
  8019dc:	e8 3f ed ff ff       	call   800720 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e1:	8b 46 04             	mov    0x4(%esi),%eax
  8019e4:	2b 06                	sub    (%esi),%eax
  8019e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f3:	00 00 00 
	stat->st_dev = &devpipe;
  8019f6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019fd:	30 80 00 
	return 0;
}
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
  801a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a16:	53                   	push   %ebx
  801a17:	6a 00                	push   $0x0
  801a19:	e8 83 f1 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a1e:	89 1c 24             	mov    %ebx,(%esp)
  801a21:	e8 58 f3 ff ff       	call   800d7e <fd2data>
  801a26:	83 c4 08             	add    $0x8,%esp
  801a29:	50                   	push   %eax
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 70 f1 ff ff       	call   800ba1 <sys_page_unmap>
}
  801a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <_pipeisclosed>:
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 1c             	sub    $0x1c,%esp
  801a3f:	89 c7                	mov    %eax,%edi
  801a41:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a43:	a1 00 40 80 00       	mov    0x804000,%eax
  801a48:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	57                   	push   %edi
  801a4f:	e8 71 05 00 00       	call   801fc5 <pageref>
  801a54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a57:	89 34 24             	mov    %esi,(%esp)
  801a5a:	e8 66 05 00 00       	call   801fc5 <pageref>
		nn = thisenv->env_runs;
  801a5f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a65:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	39 cb                	cmp    %ecx,%ebx
  801a6d:	74 1b                	je     801a8a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a6f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a72:	75 cf                	jne    801a43 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a74:	8b 42 68             	mov    0x68(%edx),%eax
  801a77:	6a 01                	push   $0x1
  801a79:	50                   	push   %eax
  801a7a:	53                   	push   %ebx
  801a7b:	68 af 26 80 00       	push   $0x8026af
  801a80:	e8 c1 e6 ff ff       	call   800146 <cprintf>
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb b9                	jmp    801a43 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a8a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a8d:	0f 94 c0             	sete   %al
  801a90:	0f b6 c0             	movzbl %al,%eax
}
  801a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5f                   	pop    %edi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <devpipe_write>:
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 28             	sub    $0x28,%esp
  801aa4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801aa7:	56                   	push   %esi
  801aa8:	e8 d1 f2 ff ff       	call   800d7e <fd2data>
  801aad:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aba:	75 09                	jne    801ac5 <devpipe_write+0x2a>
	return i;
  801abc:	89 f8                	mov    %edi,%eax
  801abe:	eb 23                	jmp    801ae3 <devpipe_write+0x48>
			sys_yield();
  801ac0:	e8 38 f0 ff ff       	call   800afd <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac8:	8b 0b                	mov    (%ebx),%ecx
  801aca:	8d 51 20             	lea    0x20(%ecx),%edx
  801acd:	39 d0                	cmp    %edx,%eax
  801acf:	72 1a                	jb     801aeb <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ad1:	89 da                	mov    %ebx,%edx
  801ad3:	89 f0                	mov    %esi,%eax
  801ad5:	e8 5c ff ff ff       	call   801a36 <_pipeisclosed>
  801ada:	85 c0                	test   %eax,%eax
  801adc:	74 e2                	je     801ac0 <devpipe_write+0x25>
				return 0;
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	c1 fa 1f             	sar    $0x1f,%edx
  801afa:	89 d1                	mov    %edx,%ecx
  801afc:	c1 e9 1b             	shr    $0x1b,%ecx
  801aff:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b02:	83 e2 1f             	and    $0x1f,%edx
  801b05:	29 ca                	sub    %ecx,%edx
  801b07:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b0b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b15:	83 c7 01             	add    $0x1,%edi
  801b18:	eb 9d                	jmp    801ab7 <devpipe_write+0x1c>

00801b1a <devpipe_read>:
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	57                   	push   %edi
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 18             	sub    $0x18,%esp
  801b23:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b26:	57                   	push   %edi
  801b27:	e8 52 f2 ff ff       	call   800d7e <fd2data>
  801b2c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	be 00 00 00 00       	mov    $0x0,%esi
  801b36:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b39:	75 13                	jne    801b4e <devpipe_read+0x34>
	return i;
  801b3b:	89 f0                	mov    %esi,%eax
  801b3d:	eb 02                	jmp    801b41 <devpipe_read+0x27>
				return i;
  801b3f:	89 f0                	mov    %esi,%eax
}
  801b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b44:	5b                   	pop    %ebx
  801b45:	5e                   	pop    %esi
  801b46:	5f                   	pop    %edi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    
			sys_yield();
  801b49:	e8 af ef ff ff       	call   800afd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b4e:	8b 03                	mov    (%ebx),%eax
  801b50:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b53:	75 18                	jne    801b6d <devpipe_read+0x53>
			if (i > 0)
  801b55:	85 f6                	test   %esi,%esi
  801b57:	75 e6                	jne    801b3f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b59:	89 da                	mov    %ebx,%edx
  801b5b:	89 f8                	mov    %edi,%eax
  801b5d:	e8 d4 fe ff ff       	call   801a36 <_pipeisclosed>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	74 e3                	je     801b49 <devpipe_read+0x2f>
				return 0;
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6b:	eb d4                	jmp    801b41 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6d:	99                   	cltd   
  801b6e:	c1 ea 1b             	shr    $0x1b,%edx
  801b71:	01 d0                	add    %edx,%eax
  801b73:	83 e0 1f             	and    $0x1f,%eax
  801b76:	29 d0                	sub    %edx,%eax
  801b78:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b80:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b83:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b86:	83 c6 01             	add    $0x1,%esi
  801b89:	eb ab                	jmp    801b36 <devpipe_read+0x1c>

00801b8b <pipe>:
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	e8 f9 f1 ff ff       	call   800d95 <fd_alloc>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	0f 88 23 01 00 00    	js     801ccc <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba9:	83 ec 04             	sub    $0x4,%esp
  801bac:	68 07 04 00 00       	push   $0x407
  801bb1:	ff 75 f4             	push   -0xc(%ebp)
  801bb4:	6a 00                	push   $0x0
  801bb6:	e8 61 ef ff ff       	call   800b1c <sys_page_alloc>
  801bbb:	89 c3                	mov    %eax,%ebx
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	0f 88 04 01 00 00    	js     801ccc <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bce:	50                   	push   %eax
  801bcf:	e8 c1 f1 ff ff       	call   800d95 <fd_alloc>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 db 00 00 00    	js     801cbc <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be1:	83 ec 04             	sub    $0x4,%esp
  801be4:	68 07 04 00 00       	push   $0x407
  801be9:	ff 75 f0             	push   -0x10(%ebp)
  801bec:	6a 00                	push   $0x0
  801bee:	e8 29 ef ff ff       	call   800b1c <sys_page_alloc>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	0f 88 bc 00 00 00    	js     801cbc <pipe+0x131>
	va = fd2data(fd0);
  801c00:	83 ec 0c             	sub    $0xc,%esp
  801c03:	ff 75 f4             	push   -0xc(%ebp)
  801c06:	e8 73 f1 ff ff       	call   800d7e <fd2data>
  801c0b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0d:	83 c4 0c             	add    $0xc,%esp
  801c10:	68 07 04 00 00       	push   $0x407
  801c15:	50                   	push   %eax
  801c16:	6a 00                	push   $0x0
  801c18:	e8 ff ee ff ff       	call   800b1c <sys_page_alloc>
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	0f 88 82 00 00 00    	js     801cac <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 ec 0c             	sub    $0xc,%esp
  801c2d:	ff 75 f0             	push   -0x10(%ebp)
  801c30:	e8 49 f1 ff ff       	call   800d7e <fd2data>
  801c35:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c3c:	50                   	push   %eax
  801c3d:	6a 00                	push   $0x0
  801c3f:	56                   	push   %esi
  801c40:	6a 00                	push   $0x0
  801c42:	e8 18 ef ff ff       	call   800b5f <sys_page_map>
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	83 c4 20             	add    $0x20,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 4e                	js     801c9e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c50:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c58:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c5d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c64:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c67:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff 75 f4             	push   -0xc(%ebp)
  801c79:	e8 f0 f0 ff ff       	call   800d6e <fd2num>
  801c7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c83:	83 c4 04             	add    $0x4,%esp
  801c86:	ff 75 f0             	push   -0x10(%ebp)
  801c89:	e8 e0 f0 ff ff       	call   800d6e <fd2num>
  801c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c91:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c9c:	eb 2e                	jmp    801ccc <pipe+0x141>
	sys_page_unmap(0, va);
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	56                   	push   %esi
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 f8 ee ff ff       	call   800ba1 <sys_page_unmap>
  801ca9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	ff 75 f0             	push   -0x10(%ebp)
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 e8 ee ff ff       	call   800ba1 <sys_page_unmap>
  801cb9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	ff 75 f4             	push   -0xc(%ebp)
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 d8 ee ff ff       	call   800ba1 <sys_page_unmap>
  801cc9:	83 c4 10             	add    $0x10,%esp
}
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <pipeisclosed>:
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cde:	50                   	push   %eax
  801cdf:	ff 75 08             	push   0x8(%ebp)
  801ce2:	e8 fe f0 ff ff       	call   800de5 <fd_lookup>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 18                	js     801d06 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	ff 75 f4             	push   -0xc(%ebp)
  801cf4:	e8 85 f0 ff ff       	call   800d7e <fd2data>
  801cf9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfe:	e8 33 fd ff ff       	call   801a36 <_pipeisclosed>
  801d03:	83 c4 10             	add    $0x10,%esp
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0d:	c3                   	ret    

00801d0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d14:	68 c7 26 80 00       	push   $0x8026c7
  801d19:	ff 75 0c             	push   0xc(%ebp)
  801d1c:	e8 ff e9 ff ff       	call   800720 <strcpy>
	return 0;
}
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <devcons_write>:
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d34:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d39:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d3f:	eb 2e                	jmp    801d6f <devcons_write+0x47>
		m = n - tot;
  801d41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d44:	29 f3                	sub    %esi,%ebx
  801d46:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d4b:	39 c3                	cmp    %eax,%ebx
  801d4d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d50:	83 ec 04             	sub    $0x4,%esp
  801d53:	53                   	push   %ebx
  801d54:	89 f0                	mov    %esi,%eax
  801d56:	03 45 0c             	add    0xc(%ebp),%eax
  801d59:	50                   	push   %eax
  801d5a:	57                   	push   %edi
  801d5b:	e8 56 eb ff ff       	call   8008b6 <memmove>
		sys_cputs(buf, m);
  801d60:	83 c4 08             	add    $0x8,%esp
  801d63:	53                   	push   %ebx
  801d64:	57                   	push   %edi
  801d65:	e8 f6 ec ff ff       	call   800a60 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d6a:	01 de                	add    %ebx,%esi
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d72:	72 cd                	jb     801d41 <devcons_write+0x19>
}
  801d74:	89 f0                	mov    %esi,%eax
  801d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <devcons_read>:
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 08             	sub    $0x8,%esp
  801d84:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d8d:	75 07                	jne    801d96 <devcons_read+0x18>
  801d8f:	eb 1f                	jmp    801db0 <devcons_read+0x32>
		sys_yield();
  801d91:	e8 67 ed ff ff       	call   800afd <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d96:	e8 e3 ec ff ff       	call   800a7e <sys_cgetc>
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	74 f2                	je     801d91 <devcons_read+0x13>
	if (c < 0)
  801d9f:	78 0f                	js     801db0 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801da1:	83 f8 04             	cmp    $0x4,%eax
  801da4:	74 0c                	je     801db2 <devcons_read+0x34>
	*(char*)vbuf = c;
  801da6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da9:	88 02                	mov    %al,(%edx)
	return 1;
  801dab:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    
		return 0;
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
  801db7:	eb f7                	jmp    801db0 <devcons_read+0x32>

00801db9 <cputchar>:
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dc5:	6a 01                	push   $0x1
  801dc7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	e8 90 ec ff ff       	call   800a60 <sys_cputs>
}
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <getchar>:
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ddb:	6a 01                	push   $0x1
  801ddd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	6a 00                	push   $0x0
  801de3:	e8 66 f2 ff ff       	call   80104e <read>
	if (r < 0)
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 06                	js     801df5 <getchar+0x20>
	if (r < 1)
  801def:	74 06                	je     801df7 <getchar+0x22>
	return c;
  801df1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    
		return -E_EOF;
  801df7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dfc:	eb f7                	jmp    801df5 <getchar+0x20>

00801dfe <iscons>:
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	ff 75 08             	push   0x8(%ebp)
  801e0b:	e8 d5 ef ff ff       	call   800de5 <fd_lookup>
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 11                	js     801e28 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e20:	39 10                	cmp    %edx,(%eax)
  801e22:	0f 94 c0             	sete   %al
  801e25:	0f b6 c0             	movzbl %al,%eax
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <opencons>:
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	e8 5c ef ff ff       	call   800d95 <fd_alloc>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 3a                	js     801e7a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	68 07 04 00 00       	push   $0x407
  801e48:	ff 75 f4             	push   -0xc(%ebp)
  801e4b:	6a 00                	push   $0x0
  801e4d:	e8 ca ec ff ff       	call   800b1c <sys_page_alloc>
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 21                	js     801e7a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e62:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	50                   	push   %eax
  801e72:	e8 f7 ee ff ff       	call   800d6e <fd2num>
  801e77:	83 c4 10             	add    $0x10,%esp
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e81:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e84:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e8a:	e8 4f ec ff ff       	call   800ade <sys_getenvid>
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 75 0c             	push   0xc(%ebp)
  801e95:	ff 75 08             	push   0x8(%ebp)
  801e98:	56                   	push   %esi
  801e99:	50                   	push   %eax
  801e9a:	68 d4 26 80 00       	push   $0x8026d4
  801e9f:	e8 a2 e2 ff ff       	call   800146 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ea4:	83 c4 18             	add    $0x18,%esp
  801ea7:	53                   	push   %ebx
  801ea8:	ff 75 10             	push   0x10(%ebp)
  801eab:	e8 45 e2 ff ff       	call   8000f5 <vcprintf>
	cprintf("\n");
  801eb0:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  801eb7:	e8 8a e2 ff ff       	call   800146 <cprintf>
  801ebc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ebf:	cc                   	int3   
  801ec0:	eb fd                	jmp    801ebf <_panic+0x43>

00801ec2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	8b 75 08             	mov    0x8(%ebp),%esi
  801eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed7:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	50                   	push   %eax
  801ede:	e8 e9 ed ff ff       	call   800ccc <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	85 f6                	test   %esi,%esi
  801ee8:	74 17                	je     801f01 <ipc_recv+0x3f>
  801eea:	ba 00 00 00 00       	mov    $0x0,%edx
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 0c                	js     801eff <ipc_recv+0x3d>
  801ef3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef9:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801eff:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f01:	85 db                	test   %ebx,%ebx
  801f03:	74 17                	je     801f1c <ipc_recv+0x5a>
  801f05:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 0c                	js     801f1a <ipc_recv+0x58>
  801f0e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f14:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f1a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 0b                	js     801f2b <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f20:	a1 00 40 80 00       	mov    0x804000,%eax
  801f25:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 0c             	sub    $0xc,%esp
  801f3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f44:	85 db                	test   %ebx,%ebx
  801f46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f4b:	0f 44 d8             	cmove  %eax,%ebx
  801f4e:	eb 05                	jmp    801f55 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f50:	e8 a8 eb ff ff       	call   800afd <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f55:	ff 75 14             	push   0x14(%ebp)
  801f58:	53                   	push   %ebx
  801f59:	56                   	push   %esi
  801f5a:	57                   	push   %edi
  801f5b:	e8 49 ed ff ff       	call   800ca9 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f66:	74 e8                	je     801f50 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 08                	js     801f74 <ipc_send+0x42>
	}while (r<0);

}
  801f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f74:	50                   	push   %eax
  801f75:	68 f7 26 80 00       	push   $0x8026f7
  801f7a:	6a 3d                	push   $0x3d
  801f7c:	68 0b 27 80 00       	push   $0x80270b
  801f81:	e8 f6 fe ff ff       	call   801e7c <_panic>

00801f86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f91:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f97:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f9d:	8b 52 60             	mov    0x60(%edx),%edx
  801fa0:	39 ca                	cmp    %ecx,%edx
  801fa2:	74 11                	je     801fb5 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fa4:	83 c0 01             	add    $0x1,%eax
  801fa7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fac:	75 e3                	jne    801f91 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb3:	eb 0e                	jmp    801fc3 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fb5:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fbb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc0:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcb:	89 c2                	mov    %eax,%edx
  801fcd:	c1 ea 16             	shr    $0x16,%edx
  801fd0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fdc:	f6 c1 01             	test   $0x1,%cl
  801fdf:	74 1c                	je     801ffd <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fe1:	c1 e8 0c             	shr    $0xc,%eax
  801fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801feb:	a8 01                	test   $0x1,%al
  801fed:	74 0e                	je     801ffd <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fef:	c1 e8 0c             	shr    $0xc,%eax
  801ff2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff9:	ef 
  801ffa:	0f b7 d2             	movzwl %dx,%edx
}
  801ffd:	89 d0                	mov    %edx,%eax
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    
  802001:	66 90                	xchg   %ax,%ax
  802003:	66 90                	xchg   %ax,%ax
  802005:	66 90                	xchg   %ax,%ax
  802007:	66 90                	xchg   %ax,%ax
  802009:	66 90                	xchg   %ax,%ax
  80200b:	66 90                	xchg   %ax,%ax
  80200d:	66 90                	xchg   %ax,%ax
  80200f:	90                   	nop

00802010 <__udivdi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80201f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802023:	8b 74 24 34          	mov    0x34(%esp),%esi
  802027:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 19                	jne    802048 <__udivdi3+0x38>
  80202f:	39 f3                	cmp    %esi,%ebx
  802031:	76 4d                	jbe    802080 <__udivdi3+0x70>
  802033:	31 ff                	xor    %edi,%edi
  802035:	89 e8                	mov    %ebp,%eax
  802037:	89 f2                	mov    %esi,%edx
  802039:	f7 f3                	div    %ebx
  80203b:	89 fa                	mov    %edi,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	76 14                	jbe    802060 <__udivdi3+0x50>
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	31 c0                	xor    %eax,%eax
  802050:	89 fa                	mov    %edi,%edx
  802052:	83 c4 1c             	add    $0x1c,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802060:	0f bd f8             	bsr    %eax,%edi
  802063:	83 f7 1f             	xor    $0x1f,%edi
  802066:	75 48                	jne    8020b0 <__udivdi3+0xa0>
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	72 06                	jb     802072 <__udivdi3+0x62>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 de                	ja     802050 <__udivdi3+0x40>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb d7                	jmp    802050 <__udivdi3+0x40>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d9                	mov    %ebx,%ecx
  802082:	85 db                	test   %ebx,%ebx
  802084:	75 0b                	jne    802091 <__udivdi3+0x81>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f3                	div    %ebx
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c6                	mov    %eax,%esi
  802099:	89 e8                	mov    %ebp,%eax
  80209b:	89 f7                	mov    %esi,%edi
  80209d:	f7 f1                	div    %ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020b7:	29 fa                	sub    %edi,%edx
  8020b9:	d3 e0                	shl    %cl,%eax
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	89 d1                	mov    %edx,%ecx
  8020c1:	89 d8                	mov    %ebx,%eax
  8020c3:	d3 e8                	shr    %cl,%eax
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 c1                	or     %eax,%ecx
  8020cb:	89 f0                	mov    %esi,%eax
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 d1                	mov    %edx,%ecx
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	89 eb                	mov    %ebp,%ebx
  8020e1:	d3 e6                	shl    %cl,%esi
  8020e3:	89 d1                	mov    %edx,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 f3                	or     %esi,%ebx
  8020e9:	89 c6                	mov    %eax,%esi
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	f7 74 24 08          	divl   0x8(%esp)
  8020f3:	89 d6                	mov    %edx,%esi
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	f7 64 24 0c          	mull   0xc(%esp)
  8020fb:	39 d6                	cmp    %edx,%esi
  8020fd:	72 19                	jb     802118 <__udivdi3+0x108>
  8020ff:	89 f9                	mov    %edi,%ecx
  802101:	d3 e5                	shl    %cl,%ebp
  802103:	39 c5                	cmp    %eax,%ebp
  802105:	73 04                	jae    80210b <__udivdi3+0xfb>
  802107:	39 d6                	cmp    %edx,%esi
  802109:	74 0d                	je     802118 <__udivdi3+0x108>
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	31 ff                	xor    %edi,%edi
  80210f:	e9 3c ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80211b:	31 ff                	xor    %edi,%edi
  80211d:	e9 2e ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
  80213b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80213f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802143:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802147:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 da                	mov    %ebx,%edx
  80214f:	85 ff                	test   %edi,%edi
  802151:	75 15                	jne    802168 <__umoddi3+0x38>
  802153:	39 dd                	cmp    %ebx,%ebp
  802155:	76 39                	jbe    802190 <__umoddi3+0x60>
  802157:	f7 f5                	div    %ebp
  802159:	89 d0                	mov    %edx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 1c             	add    $0x1c,%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	77 f1                	ja     80215d <__umoddi3+0x2d>
  80216c:	0f bd cf             	bsr    %edi,%ecx
  80216f:	83 f1 1f             	xor    $0x1f,%ecx
  802172:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802176:	75 40                	jne    8021b8 <__umoddi3+0x88>
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	72 04                	jb     802180 <__umoddi3+0x50>
  80217c:	39 f5                	cmp    %esi,%ebp
  80217e:	77 dd                	ja     80215d <__umoddi3+0x2d>
  802180:	89 da                	mov    %ebx,%edx
  802182:	89 f0                	mov    %esi,%eax
  802184:	29 e8                	sub    %ebp,%eax
  802186:	19 fa                	sbb    %edi,%edx
  802188:	eb d3                	jmp    80215d <__umoddi3+0x2d>
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	89 e9                	mov    %ebp,%ecx
  802192:	85 ed                	test   %ebp,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x71>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f5                	div    %ebp
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	f7 f1                	div    %ecx
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	eb ac                	jmp    80215d <__umoddi3+0x2d>
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021c1:	29 c2                	sub    %eax,%edx
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	d3 e7                	shl    %cl,%edi
  8021c9:	89 d1                	mov    %edx,%ecx
  8021cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021cf:	d3 e8                	shr    %cl,%eax
  8021d1:	89 c1                	mov    %eax,%ecx
  8021d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021d7:	09 f9                	or     %edi,%ecx
  8021d9:	89 df                	mov    %ebx,%edi
  8021db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	d3 e5                	shl    %cl,%ebp
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 ef                	shr    %cl,%edi
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	d3 e3                	shl    %cl,%ebx
  8021ed:	89 d1                	mov    %edx,%ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	d3 e8                	shr    %cl,%eax
  8021f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021f8:	09 d8                	or     %ebx,%eax
  8021fa:	f7 74 24 08          	divl   0x8(%esp)
  8021fe:	89 d3                	mov    %edx,%ebx
  802200:	d3 e6                	shl    %cl,%esi
  802202:	f7 e5                	mul    %ebp
  802204:	89 c7                	mov    %eax,%edi
  802206:	89 d1                	mov    %edx,%ecx
  802208:	39 d3                	cmp    %edx,%ebx
  80220a:	72 06                	jb     802212 <__umoddi3+0xe2>
  80220c:	75 0e                	jne    80221c <__umoddi3+0xec>
  80220e:	39 c6                	cmp    %eax,%esi
  802210:	73 0a                	jae    80221c <__umoddi3+0xec>
  802212:	29 e8                	sub    %ebp,%eax
  802214:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802218:	89 d1                	mov    %edx,%ecx
  80221a:	89 c7                	mov    %eax,%edi
  80221c:	89 f5                	mov    %esi,%ebp
  80221e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802222:	29 fd                	sub    %edi,%ebp
  802224:	19 cb                	sbb    %ecx,%ebx
  802226:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80222b:	89 d8                	mov    %ebx,%eax
  80222d:	d3 e0                	shl    %cl,%eax
  80222f:	89 f1                	mov    %esi,%ecx
  802231:	d3 ed                	shr    %cl,%ebp
  802233:	d3 eb                	shr    %cl,%ebx
  802235:	09 e8                	or     %ebp,%eax
  802237:	89 da                	mov    %ebx,%edx
  802239:	83 c4 1c             	add    $0x1c,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
