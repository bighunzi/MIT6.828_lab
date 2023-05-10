
obj/user/spin.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 e0 25 80 00       	push   $0x8025e0
  80003f:	e8 69 01 00 00       	call   8001ad <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 8a 0e 00 00       	call   800ed3 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 58 26 80 00       	push   $0x802658
  800058:	e8 50 01 00 00       	call   8001ad <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 08 26 80 00       	push   $0x802608
  80006c:	e8 3c 01 00 00       	call   8001ad <cprintf>
	sys_yield();
  800071:	e8 ee 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  800076:	e8 e9 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  80007b:	e8 e4 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  800080:	e8 df 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  800085:	e8 da 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  80008a:	e8 d5 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  80008f:	e8 d0 0a 00 00       	call   800b64 <sys_yield>
	sys_yield();
  800094:	e8 cb 0a 00 00       	call   800b64 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  8000a0:	e8 08 01 00 00       	call   8001ad <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 57 0a 00 00       	call   800b04 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 80 0a 00 00       	call   800b45 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000da:	85 db                	test   %ebx,%ebx
  8000dc:	7e 07                	jle    8000e5 <libmain+0x30>
		binaryname = argv[0];
  8000de:	8b 06                	mov    (%esi),%eax
  8000e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	e8 44 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 0a 00 00 00       	call   8000fe <exit>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800104:	e8 1e 11 00 00       	call   801227 <close_all>
	sys_env_destroy(0);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	6a 00                	push   $0x0
  80010e:	e8 f1 09 00 00       	call   800b04 <sys_env_destroy>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 13                	mov    (%ebx),%edx
  800124:	8d 42 01             	lea    0x1(%edx),%eax
  800127:	89 03                	mov    %eax,(%ebx)
  800129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800130:	3d ff 00 00 00       	cmp    $0xff,%eax
  800135:	74 09                	je     800140 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 76 09 00 00       	call   800ac7 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb db                	jmp    800137 <putch+0x1f>

0080015c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	ff 75 0c             	push   0xc(%ebp)
  80017c:	ff 75 08             	push   0x8(%ebp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	68 18 01 80 00       	push   $0x800118
  80018b:	e8 14 01 00 00       	call   8002a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 22 09 00 00       	call   800ac7 <sys_cputs>

	return b.cnt;
}
  8001a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b6:	50                   	push   %eax
  8001b7:	ff 75 08             	push   0x8(%ebp)
  8001ba:	e8 9d ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 1c             	sub    $0x1c,%esp
  8001ca:	89 c7                	mov    %eax,%edi
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d4:	89 d1                	mov    %edx,%ecx
  8001d6:	89 c2                	mov    %eax,%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001de:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ee:	39 c2                	cmp    %eax,%edx
  8001f0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f3:	72 3e                	jb     800233 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	push   0x18(%ebp)
  8001fb:	83 eb 01             	sub    $0x1,%ebx
  8001fe:	53                   	push   %ebx
  8001ff:	50                   	push   %eax
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 e4             	push   -0x1c(%ebp)
  800206:	ff 75 e0             	push   -0x20(%ebp)
  800209:	ff 75 dc             	push   -0x24(%ebp)
  80020c:	ff 75 d8             	push   -0x28(%ebp)
  80020f:	e8 7c 21 00 00       	call   802390 <__udivdi3>
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	52                   	push   %edx
  800218:	50                   	push   %eax
  800219:	89 f2                	mov    %esi,%edx
  80021b:	89 f8                	mov    %edi,%eax
  80021d:	e8 9f ff ff ff       	call   8001c1 <printnum>
  800222:	83 c4 20             	add    $0x20,%esp
  800225:	eb 13                	jmp    80023a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	ff 75 18             	push   0x18(%ebp)
  80022e:	ff d7                	call   *%edi
  800230:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800233:	83 eb 01             	sub    $0x1,%ebx
  800236:	85 db                	test   %ebx,%ebx
  800238:	7f ed                	jg     800227 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	56                   	push   %esi
  80023e:	83 ec 04             	sub    $0x4,%esp
  800241:	ff 75 e4             	push   -0x1c(%ebp)
  800244:	ff 75 e0             	push   -0x20(%ebp)
  800247:	ff 75 dc             	push   -0x24(%ebp)
  80024a:	ff 75 d8             	push   -0x28(%ebp)
  80024d:	e8 5e 22 00 00       	call   8024b0 <__umoddi3>
  800252:	83 c4 14             	add    $0x14,%esp
  800255:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
  80025c:	50                   	push   %eax
  80025d:	ff d7                	call   *%edi
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800270:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800274:	8b 10                	mov    (%eax),%edx
  800276:	3b 50 04             	cmp    0x4(%eax),%edx
  800279:	73 0a                	jae    800285 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	88 02                	mov    %al,(%edx)
}
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <printfmt>:
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800290:	50                   	push   %eax
  800291:	ff 75 10             	push   0x10(%ebp)
  800294:	ff 75 0c             	push   0xc(%ebp)
  800297:	ff 75 08             	push   0x8(%ebp)
  80029a:	e8 05 00 00 00       	call   8002a4 <vprintfmt>
}
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <vprintfmt>:
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 3c             	sub    $0x3c,%esp
  8002ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b6:	eb 0a                	jmp    8002c2 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	53                   	push   %ebx
  8002bc:	50                   	push   %eax
  8002bd:	ff d6                	call   *%esi
  8002bf:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c2:	83 c7 01             	add    $0x1,%edi
  8002c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c9:	83 f8 25             	cmp    $0x25,%eax
  8002cc:	74 0c                	je     8002da <vprintfmt+0x36>
			if (ch == '\0')
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	75 e6                	jne    8002b8 <vprintfmt+0x14>
}
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    
		padc = ' ';
  8002da:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	8d 47 01             	lea    0x1(%edi),%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fe:	0f b6 17             	movzbl (%edi),%edx
  800301:	8d 42 dd             	lea    -0x23(%edx),%eax
  800304:	3c 55                	cmp    $0x55,%al
  800306:	0f 87 bb 03 00 00    	ja     8006c7 <vprintfmt+0x423>
  80030c:	0f b6 c0             	movzbl %al,%eax
  80030f:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800319:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80031d:	eb d9                	jmp    8002f8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800322:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800326:	eb d0                	jmp    8002f8 <vprintfmt+0x54>
  800328:	0f b6 d2             	movzbl %dl,%edx
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032e:	b8 00 00 00 00       	mov    $0x0,%eax
  800333:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800336:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800339:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800340:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800343:	83 f9 09             	cmp    $0x9,%ecx
  800346:	77 55                	ja     80039d <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800348:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80034b:	eb e9                	jmp    800336 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80034d:	8b 45 14             	mov    0x14(%ebp),%eax
  800350:	8b 00                	mov    (%eax),%eax
  800352:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8d 40 04             	lea    0x4(%eax),%eax
  80035b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800361:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800365:	79 91                	jns    8002f8 <vprintfmt+0x54>
				width = precision, precision = -1;
  800367:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800374:	eb 82                	jmp    8002f8 <vprintfmt+0x54>
  800376:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800379:	85 d2                	test   %edx,%edx
  80037b:	b8 00 00 00 00       	mov    $0x0,%eax
  800380:	0f 49 c2             	cmovns %edx,%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800389:	e9 6a ff ff ff       	jmp    8002f8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800391:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800398:	e9 5b ff ff ff       	jmp    8002f8 <vprintfmt+0x54>
  80039d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a3:	eb bc                	jmp    800361 <vprintfmt+0xbd>
			lflag++;
  8003a5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ab:	e9 48 ff ff ff       	jmp    8002f8 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 78 04             	lea    0x4(%eax),%edi
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	53                   	push   %ebx
  8003ba:	ff 30                	push   (%eax)
  8003bc:	ff d6                	call   *%esi
			break;
  8003be:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c4:	e9 9d 02 00 00       	jmp    800666 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 78 04             	lea    0x4(%eax),%edi
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	89 d0                	mov    %edx,%eax
  8003d3:	f7 d8                	neg    %eax
  8003d5:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d8:	83 f8 0f             	cmp    $0xf,%eax
  8003db:	7f 23                	jg     800400 <vprintfmt+0x15c>
  8003dd:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	74 18                	je     800400 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003e8:	52                   	push   %edx
  8003e9:	68 21 2b 80 00       	push   $0x802b21
  8003ee:	53                   	push   %ebx
  8003ef:	56                   	push   %esi
  8003f0:	e8 92 fe ff ff       	call   800287 <printfmt>
  8003f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003fb:	e9 66 02 00 00       	jmp    800666 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800400:	50                   	push   %eax
  800401:	68 98 26 80 00       	push   $0x802698
  800406:	53                   	push   %ebx
  800407:	56                   	push   %esi
  800408:	e8 7a fe ff ff       	call   800287 <printfmt>
  80040d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800410:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 4e 02 00 00       	jmp    800666 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	83 c0 04             	add    $0x4,%eax
  80041e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800426:	85 d2                	test   %edx,%edx
  800428:	b8 91 26 80 00       	mov    $0x802691,%eax
  80042d:	0f 45 c2             	cmovne %edx,%eax
  800430:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800433:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800437:	7e 06                	jle    80043f <vprintfmt+0x19b>
  800439:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80043d:	75 0d                	jne    80044c <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800442:	89 c7                	mov    %eax,%edi
  800444:	03 45 e0             	add    -0x20(%ebp),%eax
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	eb 55                	jmp    8004a1 <vprintfmt+0x1fd>
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d8             	push   -0x28(%ebp)
  800452:	ff 75 cc             	push   -0x34(%ebp)
  800455:	e8 0a 03 00 00       	call   800764 <strnlen>
  80045a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045d:	29 c1                	sub    %eax,%ecx
  80045f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800467:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	eb 0f                	jmp    80047f <vprintfmt+0x1db>
					putch(padc, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	ff 75 e0             	push   -0x20(%ebp)
  800477:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 ef 01             	sub    $0x1,%edi
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	85 ff                	test   %edi,%edi
  800481:	7f ed                	jg     800470 <vprintfmt+0x1cc>
  800483:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	b8 00 00 00 00       	mov    $0x0,%eax
  80048d:	0f 49 c2             	cmovns %edx,%eax
  800490:	29 c2                	sub    %eax,%edx
  800492:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800495:	eb a8                	jmp    80043f <vprintfmt+0x19b>
					putch(ch, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	52                   	push   %edx
  80049c:	ff d6                	call   *%esi
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	83 c7 01             	add    $0x1,%edi
  8004a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ad:	0f be d0             	movsbl %al,%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 4b                	je     8004ff <vprintfmt+0x25b>
  8004b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b8:	78 06                	js     8004c0 <vprintfmt+0x21c>
  8004ba:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004be:	78 1e                	js     8004de <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c4:	74 d1                	je     800497 <vprintfmt+0x1f3>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 c6                	jbe    800497 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	53                   	push   %ebx
  8004d5:	6a 3f                	push   $0x3f
  8004d7:	ff d6                	call   *%esi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb c3                	jmp    8004a1 <vprintfmt+0x1fd>
  8004de:	89 cf                	mov    %ecx,%edi
  8004e0:	eb 0e                	jmp    8004f0 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 20                	push   $0x20
  8004e8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f ee                	jg     8004e2 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fa:	e9 67 01 00 00       	jmp    800666 <vprintfmt+0x3c2>
  8004ff:	89 cf                	mov    %ecx,%edi
  800501:	eb ed                	jmp    8004f0 <vprintfmt+0x24c>
	if (lflag >= 2)
  800503:	83 f9 01             	cmp    $0x1,%ecx
  800506:	7f 1b                	jg     800523 <vprintfmt+0x27f>
	else if (lflag)
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	74 63                	je     80056f <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	99                   	cltd   
  800515:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 40 04             	lea    0x4(%eax),%eax
  80051e:	89 45 14             	mov    %eax,0x14(%ebp)
  800521:	eb 17                	jmp    80053a <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 50 04             	mov    0x4(%eax),%edx
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 08             	lea    0x8(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800540:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800545:	85 c9                	test   %ecx,%ecx
  800547:	0f 89 ff 00 00 00    	jns    80064c <vprintfmt+0x3a8>
				putch('-', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	6a 2d                	push   $0x2d
  800553:	ff d6                	call   *%esi
				num = -(long long) num;
  800555:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800558:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055b:	f7 da                	neg    %edx
  80055d:	83 d1 00             	adc    $0x0,%ecx
  800560:	f7 d9                	neg    %ecx
  800562:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800565:	bf 0a 00 00 00       	mov    $0xa,%edi
  80056a:	e9 dd 00 00 00       	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	99                   	cltd   
  800578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
  800584:	eb b4                	jmp    80053a <vprintfmt+0x296>
	if (lflag >= 2)
  800586:	83 f9 01             	cmp    $0x1,%ecx
  800589:	7f 1e                	jg     8005a9 <vprintfmt+0x305>
	else if (lflag)
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	74 32                	je     8005c1 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
  800594:	b9 00 00 00 00       	mov    $0x0,%ecx
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005a4:	e9 a3 00 00 00       	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005bc:	e9 8b 00 00 00       	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005d6:	eb 74                	jmp    80064c <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005d8:	83 f9 01             	cmp    $0x1,%ecx
  8005db:	7f 1b                	jg     8005f8 <vprintfmt+0x354>
	else if (lflag)
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	74 2c                	je     80060d <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005f1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005f6:	eb 54                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	8d 40 08             	lea    0x8(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800606:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80060b:	eb 3f                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80061d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800622:	eb 28                	jmp    80064c <vprintfmt+0x3a8>
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 30                	push   $0x30
  80062a:	ff d6                	call   *%esi
			putch('x', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 78                	push   $0x78
  800632:	ff d6                	call   *%esi
			num = (unsigned long long)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	ff 75 e0             	push   -0x20(%ebp)
  800657:	57                   	push   %edi
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	89 da                	mov    %ebx,%edx
  80065c:	89 f0                	mov    %esi,%eax
  80065e:	e8 5e fb ff ff       	call   8001c1 <printnum>
			break;
  800663:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800669:	e9 54 fc ff ff       	jmp    8002c2 <vprintfmt+0x1e>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7f 1b                	jg     80068e <vprintfmt+0x3ea>
	else if (lflag)
  800673:	85 c9                	test   %ecx,%ecx
  800675:	74 2c                	je     8006a3 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800687:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80068c:	eb be                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 10                	mov    (%eax),%edx
  800693:	8b 48 04             	mov    0x4(%eax),%ecx
  800696:	8d 40 08             	lea    0x8(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006a1:	eb a9                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006b8:	eb 92                	jmp    80064c <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 25                	push   $0x25
  8006c0:	ff d6                	call   *%esi
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 9f                	jmp    800666 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	6a 25                	push   $0x25
  8006cd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	89 f8                	mov    %edi,%eax
  8006d4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006d8:	74 05                	je     8006df <vprintfmt+0x43b>
  8006da:	83 e8 01             	sub    $0x1,%eax
  8006dd:	eb f5                	jmp    8006d4 <vprintfmt+0x430>
  8006df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e2:	eb 82                	jmp    800666 <vprintfmt+0x3c2>

008006e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	push   0x14(%ebp)
  80070c:	ff 75 10             	push   0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 6a 02 80 00       	push   $0x80026a
  800718:	e8 87 fb ff ff       	call   8002a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800730:	eb f7                	jmp    800729 <vsnprintf+0x45>

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	push   0x10(%ebp)
  80073f:	ff 75 0c             	push   0xc(%ebp)
  800742:	ff 75 08             	push   0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	b8 00 00 00 00       	mov    $0x0,%eax
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 d0                	cmp    %edx,%eax
  800779:	74 08                	je     800783 <strnlen+0x1f>
  80077b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
  800781:	89 c2                	mov    %eax,%edx
	return n;
}
  800783:	89 d0                	mov    %edx,%eax
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80079a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80079d:	83 c0 01             	add    $0x1,%eax
  8007a0:	84 d2                	test   %dl,%dl
  8007a2:	75 f2                	jne    800796 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a4:	89 c8                	mov    %ecx,%eax
  8007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	83 ec 10             	sub    $0x10,%esp
  8007b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b5:	53                   	push   %ebx
  8007b6:	e8 91 ff ff ff       	call   80074c <strlen>
  8007bb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007be:	ff 75 0c             	push   0xc(%ebp)
  8007c1:	01 d8                	add    %ebx,%eax
  8007c3:	50                   	push   %eax
  8007c4:	e8 be ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007c9:	89 d8                	mov    %ebx,%eax
  8007cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	56                   	push   %esi
  8007d4:	53                   	push   %ebx
  8007d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007db:	89 f3                	mov    %esi,%ebx
  8007dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	eb 0f                	jmp    8007f3 <strncpy+0x23>
		*dst++ = *src;
  8007e4:	83 c0 01             	add    $0x1,%eax
  8007e7:	0f b6 0a             	movzbl (%edx),%ecx
  8007ea:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ed:	80 f9 01             	cmp    $0x1,%cl
  8007f0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007f3:	39 d8                	cmp    %ebx,%eax
  8007f5:	75 ed                	jne    8007e4 <strncpy+0x14>
	}
	return ret;
}
  8007f7:	89 f0                	mov    %esi,%eax
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800808:	8b 55 10             	mov    0x10(%ebp),%edx
  80080b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 21                	je     800832 <strlcpy+0x35>
  800811:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800815:	89 f2                	mov    %esi,%edx
  800817:	eb 09                	jmp    800822 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800819:	83 c1 01             	add    $0x1,%ecx
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800822:	39 c2                	cmp    %eax,%edx
  800824:	74 09                	je     80082f <strlcpy+0x32>
  800826:	0f b6 19             	movzbl (%ecx),%ebx
  800829:	84 db                	test   %bl,%bl
  80082b:	75 ec                	jne    800819 <strlcpy+0x1c>
  80082d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80082f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800832:	29 f0                	sub    %esi,%eax
}
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800841:	eb 06                	jmp    800849 <strcmp+0x11>
		p++, q++;
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	84 c0                	test   %al,%al
  80084e:	74 04                	je     800854 <strcmp+0x1c>
  800850:	3a 02                	cmp    (%edx),%al
  800852:	74 ef                	je     800843 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800854:	0f b6 c0             	movzbl %al,%eax
  800857:	0f b6 12             	movzbl (%edx),%edx
  80085a:	29 d0                	sub    %edx,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
  800868:	89 c3                	mov    %eax,%ebx
  80086a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086d:	eb 06                	jmp    800875 <strncmp+0x17>
		n--, p++, q++;
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800875:	39 d8                	cmp    %ebx,%eax
  800877:	74 18                	je     800891 <strncmp+0x33>
  800879:	0f b6 08             	movzbl (%eax),%ecx
  80087c:	84 c9                	test   %cl,%cl
  80087e:	74 04                	je     800884 <strncmp+0x26>
  800880:	3a 0a                	cmp    (%edx),%cl
  800882:	74 eb                	je     80086f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 00             	movzbl (%eax),%eax
  800887:	0f b6 12             	movzbl (%edx),%edx
  80088a:	29 d0                	sub    %edx,%eax
}
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb f4                	jmp    80088c <strncmp+0x2e>

00800898 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	eb 03                	jmp    8008a7 <strchr+0xf>
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	74 06                	je     8008b4 <strchr+0x1c>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	75 f2                	jne    8008a4 <strchr+0xc>
  8008b2:	eb 05                	jmp    8008b9 <strchr+0x21>
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	74 09                	je     8008d5 <strfind+0x1a>
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	74 05                	je     8008d5 <strfind+0x1a>
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	eb f0                	jmp    8008c5 <strfind+0xa>
			break;
	return (char *) s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 2f                	je     800916 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	09 c8                	or     %ecx,%eax
  8008eb:	a8 03                	test   $0x3,%al
  8008ed:	75 21                	jne    800910 <memset+0x39>
		c &= 0xFF;
  8008ef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f3:	89 d0                	mov    %edx,%eax
  8008f5:	c1 e0 08             	shl    $0x8,%eax
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 18             	shl    $0x18,%ebx
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 10             	shl    $0x10,%esi
  800902:	09 f3                	or     %esi,%ebx
  800904:	09 da                	or     %ebx,%edx
  800906:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800908:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090b:	fc                   	cld    
  80090c:	f3 ab                	rep stos %eax,%es:(%edi)
  80090e:	eb 06                	jmp    800916 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800910:	8b 45 0c             	mov    0xc(%ebp),%eax
  800913:	fc                   	cld    
  800914:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800916:	89 f8                	mov    %edi,%eax
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 75 0c             	mov    0xc(%ebp),%esi
  800928:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092b:	39 c6                	cmp    %eax,%esi
  80092d:	73 32                	jae    800961 <memmove+0x44>
  80092f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800932:	39 c2                	cmp    %eax,%edx
  800934:	76 2b                	jbe    800961 <memmove+0x44>
		s += n;
		d += n;
  800936:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	89 d6                	mov    %edx,%esi
  80093b:	09 fe                	or     %edi,%esi
  80093d:	09 ce                	or     %ecx,%esi
  80093f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800945:	75 0e                	jne    800955 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800947:	83 ef 04             	sub    $0x4,%edi
  80094a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800950:	fd                   	std    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 09                	jmp    80095e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800955:	83 ef 01             	sub    $0x1,%edi
  800958:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095b:	fd                   	std    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095e:	fc                   	cld    
  80095f:	eb 1a                	jmp    80097b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 f2                	mov    %esi,%edx
  800963:	09 c2                	or     %eax,%edx
  800965:	09 ca                	or     %ecx,%edx
  800967:	f6 c2 03             	test   $0x3,%dl
  80096a:	75 0a                	jne    800976 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 05                	jmp    80097b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800985:	ff 75 10             	push   0x10(%ebp)
  800988:	ff 75 0c             	push   0xc(%ebp)
  80098b:	ff 75 08             	push   0x8(%ebp)
  80098e:	e8 8a ff ff ff       	call   80091d <memmove>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a5:	eb 06                	jmp    8009ad <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009ad:	39 f0                	cmp    %esi,%eax
  8009af:	74 14                	je     8009c5 <memcmp+0x30>
		if (*s1 != *s2)
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	0f b6 1a             	movzbl (%edx),%ebx
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	74 ec                	je     8009a7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009bb:	0f b6 c1             	movzbl %cl,%eax
  8009be:	0f b6 db             	movzbl %bl,%ebx
  8009c1:	29 d8                	sub    %ebx,%eax
  8009c3:	eb 05                	jmp    8009ca <memcmp+0x35>
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d7:	89 c2                	mov    %eax,%edx
  8009d9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009dc:	eb 03                	jmp    8009e1 <memfind+0x13>
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	73 04                	jae    8009e9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	38 08                	cmp    %cl,(%eax)
  8009e7:	75 f5                	jne    8009de <memfind+0x10>
			break;
	return (void *) s;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	eb 03                	jmp    8009fc <strtol+0x11>
		s++;
  8009f9:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009fc:	0f b6 02             	movzbl (%edx),%eax
  8009ff:	3c 20                	cmp    $0x20,%al
  800a01:	74 f6                	je     8009f9 <strtol+0xe>
  800a03:	3c 09                	cmp    $0x9,%al
  800a05:	74 f2                	je     8009f9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a07:	3c 2b                	cmp    $0x2b,%al
  800a09:	74 2a                	je     800a35 <strtol+0x4a>
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	74 2b                	je     800a3f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1a:	75 0f                	jne    800a2b <strtol+0x40>
  800a1c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a1f:	74 28                	je     800a49 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a28:	0f 44 d8             	cmove  %eax,%ebx
  800a2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a30:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a33:	eb 46                	jmp    800a7b <strtol+0x90>
		s++;
  800a35:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb d5                	jmp    800a14 <strtol+0x29>
		s++, neg = 1;
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	bf 01 00 00 00       	mov    $0x1,%edi
  800a47:	eb cb                	jmp    800a14 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4d:	74 0e                	je     800a5d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	75 d8                	jne    800a2b <strtol+0x40>
		s++, base = 8;
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a5b:	eb ce                	jmp    800a2b <strtol+0x40>
		s += 2, base = 16;
  800a5d:	83 c2 02             	add    $0x2,%edx
  800a60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a65:	eb c4                	jmp    800a2b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a67:	0f be c0             	movsbl %al,%eax
  800a6a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a70:	7d 3a                	jge    800aac <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a79:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a7b:	0f b6 02             	movzbl (%edx),%eax
  800a7e:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 09             	cmp    $0x9,%bl
  800a86:	76 df                	jbe    800a67 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a92:	0f be c0             	movsbl %al,%eax
  800a95:	83 e8 57             	sub    $0x57,%eax
  800a98:	eb d3                	jmp    800a6d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 08                	ja     800aac <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aa4:	0f be c0             	movsbl %al,%eax
  800aa7:	83 e8 37             	sub    $0x37,%eax
  800aaa:	eb c1                	jmp    800a6d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab0:	74 05                	je     800ab7 <strtol+0xcc>
		*endptr = (char *) s;
  800ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ab7:	89 c8                	mov    %ecx,%eax
  800ab9:	f7 d8                	neg    %eax
  800abb:	85 ff                	test   %edi,%edi
  800abd:	0f 45 c8             	cmovne %eax,%ecx
}
  800ac0:	89 c8                	mov    %ecx,%eax
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	89 c6                	mov    %eax,%esi
  800ade:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1a:	89 cb                	mov    %ecx,%ebx
  800b1c:	89 cf                	mov    %ecx,%edi
  800b1e:	89 ce                	mov    %ecx,%esi
  800b20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	7f 08                	jg     800b2e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 03                	push   $0x3
  800b34:	68 7f 29 80 00       	push   $0x80297f
  800b39:	6a 2a                	push   $0x2a
  800b3b:	68 9c 29 80 00       	push   $0x80299c
  800b40:	e8 1f 16 00 00       	call   802164 <_panic>

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 02 00 00 00       	mov    $0x2,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_yield>:

void
sys_yield(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8c:	be 00 00 00 00       	mov    $0x0,%esi
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7f 08                	jg     800baf <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800bb3:	6a 04                	push   $0x4
  800bb5:	68 7f 29 80 00       	push   $0x80297f
  800bba:	6a 2a                	push   $0x2a
  800bbc:	68 9c 29 80 00       	push   $0x80299c
  800bc1:	e8 9e 15 00 00       	call   802164 <_panic>

00800bc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be0:	8b 75 18             	mov    0x18(%ebp),%esi
  800be3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7f 08                	jg     800bf1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 05                	push   $0x5
  800bf7:	68 7f 29 80 00       	push   $0x80297f
  800bfc:	6a 2a                	push   $0x2a
  800bfe:	68 9c 29 80 00       	push   $0x80299c
  800c03:	e8 5c 15 00 00       	call   802164 <_panic>

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7f 08                	jg     800c33 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 06                	push   $0x6
  800c39:	68 7f 29 80 00       	push   $0x80297f
  800c3e:	6a 2a                	push   $0x2a
  800c40:	68 9c 29 80 00       	push   $0x80299c
  800c45:	e8 1a 15 00 00       	call   802164 <_panic>

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7f 08                	jg     800c75 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 08                	push   $0x8
  800c7b:	68 7f 29 80 00       	push   $0x80297f
  800c80:	6a 2a                	push   $0x2a
  800c82:	68 9c 29 80 00       	push   $0x80299c
  800c87:	e8 d8 14 00 00       	call   802164 <_panic>

00800c8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7f 08                	jg     800cb7 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 09                	push   $0x9
  800cbd:	68 7f 29 80 00       	push   $0x80297f
  800cc2:	6a 2a                	push   $0x2a
  800cc4:	68 9c 29 80 00       	push   $0x80299c
  800cc9:	e8 96 14 00 00       	call   802164 <_panic>

00800cce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7f 08                	jg     800cf9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 0a                	push   $0xa
  800cff:	68 7f 29 80 00       	push   $0x80297f
  800d04:	6a 2a                	push   $0x2a
  800d06:	68 9c 29 80 00       	push   $0x80299c
  800d0b:	e8 54 14 00 00       	call   802164 <_panic>

00800d10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d21:	be 00 00 00 00       	mov    $0x0,%esi
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7f 08                	jg     800d5d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0d                	push   $0xd
  800d63:	68 7f 29 80 00       	push   $0x80297f
  800d68:	6a 2a                	push   $0x2a
  800d6a:	68 9c 29 80 00       	push   $0x80299c
  800d6f:	e8 f0 13 00 00       	call   802164 <_panic>

00800d74 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	b8 10 00 00 00       	mov    $0x10,%eax
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ddd:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ddf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de3:	0f 84 8e 00 00 00    	je     800e77 <pgfault+0xa2>
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	c1 e8 0c             	shr    $0xc,%eax
  800dee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df5:	f6 c4 08             	test   $0x8,%ah
  800df8:	74 7d                	je     800e77 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800dfa:	e8 46 fd ff ff       	call   800b45 <sys_getenvid>
  800dff:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	6a 07                	push   $0x7
  800e06:	68 00 f0 7f 00       	push   $0x7ff000
  800e0b:	50                   	push   %eax
  800e0c:	e8 72 fd ff ff       	call   800b83 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 73                	js     800e8b <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e18:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 00 10 00 00       	push   $0x1000
  800e26:	56                   	push   %esi
  800e27:	68 00 f0 7f 00       	push   $0x7ff000
  800e2c:	e8 ec fa ff ff       	call   80091d <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e31:	83 c4 08             	add    $0x8,%esp
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	e8 cd fd ff ff       	call   800c08 <sys_page_unmap>
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	78 5b                	js     800e9d <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	6a 07                	push   $0x7
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	68 00 f0 7f 00       	push   $0x7ff000
  800e4e:	53                   	push   %ebx
  800e4f:	e8 72 fd ff ff       	call   800bc6 <sys_page_map>
  800e54:	83 c4 20             	add    $0x20,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	78 54                	js     800eaf <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	68 00 f0 7f 00       	push   $0x7ff000
  800e63:	53                   	push   %ebx
  800e64:	e8 9f fd ff ff       	call   800c08 <sys_page_unmap>
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	78 51                	js     800ec1 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	68 ac 29 80 00       	push   $0x8029ac
  800e7f:	6a 1d                	push   $0x1d
  800e81:	68 28 2a 80 00       	push   $0x802a28
  800e86:	e8 d9 12 00 00       	call   802164 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e8b:	50                   	push   %eax
  800e8c:	68 e4 29 80 00       	push   $0x8029e4
  800e91:	6a 29                	push   $0x29
  800e93:	68 28 2a 80 00       	push   $0x802a28
  800e98:	e8 c7 12 00 00       	call   802164 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e9d:	50                   	push   %eax
  800e9e:	68 08 2a 80 00       	push   $0x802a08
  800ea3:	6a 2e                	push   $0x2e
  800ea5:	68 28 2a 80 00       	push   $0x802a28
  800eaa:	e8 b5 12 00 00       	call   802164 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800eaf:	50                   	push   %eax
  800eb0:	68 33 2a 80 00       	push   $0x802a33
  800eb5:	6a 30                	push   $0x30
  800eb7:	68 28 2a 80 00       	push   $0x802a28
  800ebc:	e8 a3 12 00 00       	call   802164 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ec1:	50                   	push   %eax
  800ec2:	68 08 2a 80 00       	push   $0x802a08
  800ec7:	6a 32                	push   $0x32
  800ec9:	68 28 2a 80 00       	push   $0x802a28
  800ece:	e8 91 12 00 00       	call   802164 <_panic>

00800ed3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800edc:	68 d5 0d 80 00       	push   $0x800dd5
  800ee1:	e8 c4 12 00 00       	call   8021aa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee6:	b8 07 00 00 00       	mov    $0x7,%eax
  800eeb:	cd 30                	int    $0x30
  800eed:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 30                	js     800f27 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ef7:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800efc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f00:	75 76                	jne    800f78 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f02:	e8 3e fc ff ff       	call   800b45 <sys_getenvid>
  800f07:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0c:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800f12:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f17:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f27:	50                   	push   %eax
  800f28:	68 51 2a 80 00       	push   $0x802a51
  800f2d:	6a 78                	push   $0x78
  800f2f:	68 28 2a 80 00       	push   $0x802a28
  800f34:	e8 2b 12 00 00       	call   802164 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	ff 75 e4             	push   -0x1c(%ebp)
  800f3f:	57                   	push   %edi
  800f40:	ff 75 dc             	push   -0x24(%ebp)
  800f43:	57                   	push   %edi
  800f44:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f47:	56                   	push   %esi
  800f48:	e8 79 fc ff ff       	call   800bc6 <sys_page_map>
	if(r<0) return r;
  800f4d:	83 c4 20             	add    $0x20,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 cb                	js     800f1f <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	ff 75 e4             	push   -0x1c(%ebp)
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	e8 63 fc ff ff       	call   800bc6 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 76                	js     800fe0 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f6a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f70:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f76:	74 75                	je     800fed <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	c1 e8 16             	shr    $0x16,%eax
  800f7d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f84:	a8 01                	test   $0x1,%al
  800f86:	74 e2                	je     800f6a <fork+0x97>
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	c1 ee 0c             	shr    $0xc,%esi
  800f8d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f94:	a8 01                	test   $0x1,%al
  800f96:	74 d2                	je     800f6a <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  800f98:	e8 a8 fb ff ff       	call   800b45 <sys_getenvid>
  800f9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fa0:	89 f7                	mov    %esi,%edi
  800fa2:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fa5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fac:	89 c1                	mov    %eax,%ecx
  800fae:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fb4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fb7:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fbe:	f6 c6 04             	test   $0x4,%dh
  800fc1:	0f 85 72 ff ff ff    	jne    800f39 <fork+0x66>
		perm &= ~PTE_W;
  800fc7:	25 05 0e 00 00       	and    $0xe05,%eax
  800fcc:	80 cc 08             	or     $0x8,%ah
  800fcf:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800fd5:	0f 44 c1             	cmove  %ecx,%eax
  800fd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fdb:	e9 59 ff ff ff       	jmp    800f39 <fork+0x66>
  800fe0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe5:	0f 4f c2             	cmovg  %edx,%eax
  800fe8:	e9 32 ff ff ff       	jmp    800f1f <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	6a 07                	push   $0x7
  800ff2:	68 00 f0 bf ee       	push   $0xeebff000
  800ff7:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ffa:	57                   	push   %edi
  800ffb:	e8 83 fb ff ff       	call   800b83 <sys_page_alloc>
	if(r<0) return r;
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 88 14 ff ff ff    	js     800f1f <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	68 20 22 80 00       	push   $0x802220
  801013:	57                   	push   %edi
  801014:	e8 b5 fc ff ff       	call   800cce <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	0f 88 fb fe ff ff    	js     800f1f <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	6a 02                	push   $0x2
  801029:	57                   	push   %edi
  80102a:	e8 1b fc ff ff       	call   800c4a <sys_env_set_status>
	if(r<0) return r;
  80102f:	83 c4 10             	add    $0x10,%esp
	return envid;
  801032:	85 c0                	test   %eax,%eax
  801034:	0f 49 c7             	cmovns %edi,%eax
  801037:	e9 e3 fe ff ff       	jmp    800f1f <fork+0x4c>

0080103c <sfork>:

// Challenge!
int
sfork(void)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801042:	68 61 2a 80 00       	push   $0x802a61
  801047:	68 a1 00 00 00       	push   $0xa1
  80104c:	68 28 2a 80 00       	push   $0x802a28
  801051:	e8 0e 11 00 00       	call   802164 <_panic>

00801056 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	05 00 00 00 30       	add    $0x30000000,%eax
  801061:	c1 e8 0c             	shr    $0xc,%eax
}
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801071:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801076:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801085:	89 c2                	mov    %eax,%edx
  801087:	c1 ea 16             	shr    $0x16,%edx
  80108a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801091:	f6 c2 01             	test   $0x1,%dl
  801094:	74 29                	je     8010bf <fd_alloc+0x42>
  801096:	89 c2                	mov    %eax,%edx
  801098:	c1 ea 0c             	shr    $0xc,%edx
  80109b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a2:	f6 c2 01             	test   $0x1,%dl
  8010a5:	74 18                	je     8010bf <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010a7:	05 00 10 00 00       	add    $0x1000,%eax
  8010ac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b1:	75 d2                	jne    801085 <fd_alloc+0x8>
  8010b3:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8010b8:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8010bd:	eb 05                	jmp    8010c4 <fd_alloc+0x47>
			return 0;
  8010bf:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 02                	mov    %eax,(%edx)
}
  8010c9:	89 c8                	mov    %ecx,%eax
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d3:	83 f8 1f             	cmp    $0x1f,%eax
  8010d6:	77 30                	ja     801108 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d8:	c1 e0 0c             	shl    $0xc,%eax
  8010db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e0:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 24                	je     80110f <fd_lookup+0x42>
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	c1 ea 0c             	shr    $0xc,%edx
  8010f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f7:	f6 c2 01             	test   $0x1,%dl
  8010fa:	74 1a                	je     801116 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ff:	89 02                	mov    %eax,(%edx)
	return 0;
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    
		return -E_INVAL;
  801108:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110d:	eb f7                	jmp    801106 <fd_lookup+0x39>
		return -E_INVAL;
  80110f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801114:	eb f0                	jmp    801106 <fd_lookup+0x39>
  801116:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111b:	eb e9                	jmp    801106 <fd_lookup+0x39>

0080111d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	53                   	push   %ebx
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801131:	39 13                	cmp    %edx,(%ebx)
  801133:	74 37                	je     80116c <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801135:	83 c0 01             	add    $0x1,%eax
  801138:	8b 1c 85 f4 2a 80 00 	mov    0x802af4(,%eax,4),%ebx
  80113f:	85 db                	test   %ebx,%ebx
  801141:	75 ee                	jne    801131 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801143:	a1 00 40 80 00       	mov    0x804000,%eax
  801148:	8b 40 58             	mov    0x58(%eax),%eax
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	52                   	push   %edx
  80114f:	50                   	push   %eax
  801150:	68 78 2a 80 00       	push   $0x802a78
  801155:	e8 53 f0 ff ff       	call   8001ad <cprintf>
	*dev = 0;
	return -E_INVAL;
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801162:	8b 55 0c             	mov    0xc(%ebp),%edx
  801165:	89 1a                	mov    %ebx,(%edx)
}
  801167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    
			return 0;
  80116c:	b8 00 00 00 00       	mov    $0x0,%eax
  801171:	eb ef                	jmp    801162 <dev_lookup+0x45>

00801173 <fd_close>:
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 24             	sub    $0x24,%esp
  80117c:	8b 75 08             	mov    0x8(%ebp),%esi
  80117f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801182:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801185:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801186:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80118c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118f:	50                   	push   %eax
  801190:	e8 38 ff ff ff       	call   8010cd <fd_lookup>
  801195:	89 c3                	mov    %eax,%ebx
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 05                	js     8011a3 <fd_close+0x30>
	    || fd != fd2)
  80119e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011a1:	74 16                	je     8011b9 <fd_close+0x46>
		return (must_exist ? r : 0);
  8011a3:	89 f8                	mov    %edi,%eax
  8011a5:	84 c0                	test   %al,%al
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	0f 44 d8             	cmove  %eax,%ebx
}
  8011af:	89 d8                	mov    %ebx,%eax
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff 36                	push   (%esi)
  8011c2:	e8 56 ff ff ff       	call   80111d <dev_lookup>
  8011c7:	89 c3                	mov    %eax,%ebx
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 1a                	js     8011ea <fd_close+0x77>
		if (dev->dev_close)
  8011d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	74 0b                	je     8011ea <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8011df:	83 ec 0c             	sub    $0xc,%esp
  8011e2:	56                   	push   %esi
  8011e3:	ff d0                	call   *%eax
  8011e5:	89 c3                	mov    %eax,%ebx
  8011e7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	56                   	push   %esi
  8011ee:	6a 00                	push   $0x0
  8011f0:	e8 13 fa ff ff       	call   800c08 <sys_page_unmap>
	return r;
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	eb b5                	jmp    8011af <fd_close+0x3c>

008011fa <close>:

int
close(int fdnum)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	ff 75 08             	push   0x8(%ebp)
  801207:	e8 c1 fe ff ff       	call   8010cd <fd_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	79 02                	jns    801215 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    
		return fd_close(fd, 1);
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	6a 01                	push   $0x1
  80121a:	ff 75 f4             	push   -0xc(%ebp)
  80121d:	e8 51 ff ff ff       	call   801173 <fd_close>
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	eb ec                	jmp    801213 <close+0x19>

00801227 <close_all>:

void
close_all(void)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	53                   	push   %ebx
  80122b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	53                   	push   %ebx
  801237:	e8 be ff ff ff       	call   8011fa <close>
	for (i = 0; i < MAXFD; i++)
  80123c:	83 c3 01             	add    $0x1,%ebx
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	83 fb 20             	cmp    $0x20,%ebx
  801245:	75 ec                	jne    801233 <close_all+0xc>
}
  801247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801255:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	push   0x8(%ebp)
  80125c:	e8 6c fe ff ff       	call   8010cd <fd_lookup>
  801261:	89 c3                	mov    %eax,%ebx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 7f                	js     8012e9 <dup+0x9d>
		return r;
	close(newfdnum);
  80126a:	83 ec 0c             	sub    $0xc,%esp
  80126d:	ff 75 0c             	push   0xc(%ebp)
  801270:	e8 85 ff ff ff       	call   8011fa <close>

	newfd = INDEX2FD(newfdnum);
  801275:	8b 75 0c             	mov    0xc(%ebp),%esi
  801278:	c1 e6 0c             	shl    $0xc,%esi
  80127b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801281:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801284:	89 3c 24             	mov    %edi,(%esp)
  801287:	e8 da fd ff ff       	call   801066 <fd2data>
  80128c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80128e:	89 34 24             	mov    %esi,(%esp)
  801291:	e8 d0 fd ff ff       	call   801066 <fd2data>
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129c:	89 d8                	mov    %ebx,%eax
  80129e:	c1 e8 16             	shr    $0x16,%eax
  8012a1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a8:	a8 01                	test   $0x1,%al
  8012aa:	74 11                	je     8012bd <dup+0x71>
  8012ac:	89 d8                	mov    %ebx,%eax
  8012ae:	c1 e8 0c             	shr    $0xc,%eax
  8012b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	75 36                	jne    8012f3 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012bd:	89 f8                	mov    %edi,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
  8012c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c9:	83 ec 0c             	sub    $0xc,%esp
  8012cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d1:	50                   	push   %eax
  8012d2:	56                   	push   %esi
  8012d3:	6a 00                	push   $0x0
  8012d5:	57                   	push   %edi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 e9 f8 ff ff       	call   800bc6 <sys_page_map>
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	83 c4 20             	add    $0x20,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 33                	js     801319 <dup+0xcd>
		goto err;

	return newfdnum;
  8012e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012e9:	89 d8                	mov    %ebx,%eax
  8012eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801302:	50                   	push   %eax
  801303:	ff 75 d4             	push   -0x2c(%ebp)
  801306:	6a 00                	push   $0x0
  801308:	53                   	push   %ebx
  801309:	6a 00                	push   $0x0
  80130b:	e8 b6 f8 ff ff       	call   800bc6 <sys_page_map>
  801310:	89 c3                	mov    %eax,%ebx
  801312:	83 c4 20             	add    $0x20,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	79 a4                	jns    8012bd <dup+0x71>
	sys_page_unmap(0, newfd);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	56                   	push   %esi
  80131d:	6a 00                	push   $0x0
  80131f:	e8 e4 f8 ff ff       	call   800c08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801324:	83 c4 08             	add    $0x8,%esp
  801327:	ff 75 d4             	push   -0x2c(%ebp)
  80132a:	6a 00                	push   $0x0
  80132c:	e8 d7 f8 ff ff       	call   800c08 <sys_page_unmap>
	return r;
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	eb b3                	jmp    8012e9 <dup+0x9d>

00801336 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
  80133b:	83 ec 18             	sub    $0x18,%esp
  80133e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801341:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	56                   	push   %esi
  801346:	e8 82 fd ff ff       	call   8010cd <fd_lookup>
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 3c                	js     80138e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801352:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 33                	push   (%ebx)
  80135e:	e8 ba fd ff ff       	call   80111d <dev_lookup>
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 24                	js     80138e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136a:	8b 43 08             	mov    0x8(%ebx),%eax
  80136d:	83 e0 03             	and    $0x3,%eax
  801370:	83 f8 01             	cmp    $0x1,%eax
  801373:	74 20                	je     801395 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	8b 40 08             	mov    0x8(%eax),%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	74 37                	je     8013b6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80137f:	83 ec 04             	sub    $0x4,%esp
  801382:	ff 75 10             	push   0x10(%ebp)
  801385:	ff 75 0c             	push   0xc(%ebp)
  801388:	53                   	push   %ebx
  801389:	ff d0                	call   *%eax
  80138b:	83 c4 10             	add    $0x10,%esp
}
  80138e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801395:	a1 00 40 80 00       	mov    0x804000,%eax
  80139a:	8b 40 58             	mov    0x58(%eax),%eax
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	56                   	push   %esi
  8013a1:	50                   	push   %eax
  8013a2:	68 b9 2a 80 00       	push   $0x802ab9
  8013a7:	e8 01 ee ff ff       	call   8001ad <cprintf>
		return -E_INVAL;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b4:	eb d8                	jmp    80138e <read+0x58>
		return -E_NOT_SUPP;
  8013b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013bb:	eb d1                	jmp    80138e <read+0x58>

008013bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d1:	eb 02                	jmp    8013d5 <readn+0x18>
  8013d3:	01 c3                	add    %eax,%ebx
  8013d5:	39 f3                	cmp    %esi,%ebx
  8013d7:	73 21                	jae    8013fa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	89 f0                	mov    %esi,%eax
  8013de:	29 d8                	sub    %ebx,%eax
  8013e0:	50                   	push   %eax
  8013e1:	89 d8                	mov    %ebx,%eax
  8013e3:	03 45 0c             	add    0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	57                   	push   %edi
  8013e8:	e8 49 ff ff ff       	call   801336 <read>
		if (m < 0)
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 04                	js     8013f8 <readn+0x3b>
			return m;
		if (m == 0)
  8013f4:	75 dd                	jne    8013d3 <readn+0x16>
  8013f6:	eb 02                	jmp    8013fa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8013fa:	89 d8                	mov    %ebx,%eax
  8013fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 18             	sub    $0x18,%esp
  80140c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	53                   	push   %ebx
  801414:	e8 b4 fc ff ff       	call   8010cd <fd_lookup>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 37                	js     801457 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801420:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	ff 36                	push   (%esi)
  80142c:	e8 ec fc ff ff       	call   80111d <dev_lookup>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 1f                	js     801457 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801438:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80143c:	74 20                	je     80145e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801441:	8b 40 0c             	mov    0xc(%eax),%eax
  801444:	85 c0                	test   %eax,%eax
  801446:	74 37                	je     80147f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801448:	83 ec 04             	sub    $0x4,%esp
  80144b:	ff 75 10             	push   0x10(%ebp)
  80144e:	ff 75 0c             	push   0xc(%ebp)
  801451:	56                   	push   %esi
  801452:	ff d0                	call   *%eax
  801454:	83 c4 10             	add    $0x10,%esp
}
  801457:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80145e:	a1 00 40 80 00       	mov    0x804000,%eax
  801463:	8b 40 58             	mov    0x58(%eax),%eax
  801466:	83 ec 04             	sub    $0x4,%esp
  801469:	53                   	push   %ebx
  80146a:	50                   	push   %eax
  80146b:	68 d5 2a 80 00       	push   $0x802ad5
  801470:	e8 38 ed ff ff       	call   8001ad <cprintf>
		return -E_INVAL;
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147d:	eb d8                	jmp    801457 <write+0x53>
		return -E_NOT_SUPP;
  80147f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801484:	eb d1                	jmp    801457 <write+0x53>

00801486 <seek>:

int
seek(int fdnum, off_t offset)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 08             	push   0x8(%ebp)
  801493:	e8 35 fc ff ff       	call   8010cd <fd_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 0e                	js     8014ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80149f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 18             	sub    $0x18,%esp
  8014b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	53                   	push   %ebx
  8014bf:	e8 09 fc ff ff       	call   8010cd <fd_lookup>
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 34                	js     8014ff <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 36                	push   (%esi)
  8014d7:	e8 41 fc ff ff       	call   80111d <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 1c                	js     8014ff <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014e7:	74 1d                	je     801506 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ec:	8b 40 18             	mov    0x18(%eax),%eax
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	74 34                	je     801527 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	ff 75 0c             	push   0xc(%ebp)
  8014f9:	56                   	push   %esi
  8014fa:	ff d0                	call   *%eax
  8014fc:	83 c4 10             	add    $0x10,%esp
}
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    
			thisenv->env_id, fdnum);
  801506:	a1 00 40 80 00       	mov    0x804000,%eax
  80150b:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	50                   	push   %eax
  801513:	68 98 2a 80 00       	push   $0x802a98
  801518:	e8 90 ec ff ff       	call   8001ad <cprintf>
		return -E_INVAL;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801525:	eb d8                	jmp    8014ff <ftruncate+0x50>
		return -E_NOT_SUPP;
  801527:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80152c:	eb d1                	jmp    8014ff <ftruncate+0x50>

0080152e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	83 ec 18             	sub    $0x18,%esp
  801536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801539:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	ff 75 08             	push   0x8(%ebp)
  801540:	e8 88 fb ff ff       	call   8010cd <fd_lookup>
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 49                	js     801595 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	ff 36                	push   (%esi)
  801558:	e8 c0 fb ff ff       	call   80111d <dev_lookup>
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 31                	js     801595 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801564:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801567:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80156b:	74 2f                	je     80159c <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80156d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801570:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801577:	00 00 00 
	stat->st_isdir = 0;
  80157a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801581:	00 00 00 
	stat->st_dev = dev;
  801584:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	53                   	push   %ebx
  80158e:	56                   	push   %esi
  80158f:	ff 50 14             	call   *0x14(%eax)
  801592:	83 c4 10             	add    $0x10,%esp
}
  801595:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801598:	5b                   	pop    %ebx
  801599:	5e                   	pop    %esi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    
		return -E_NOT_SUPP;
  80159c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a1:	eb f2                	jmp    801595 <fstat+0x67>

008015a3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	56                   	push   %esi
  8015a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	6a 00                	push   $0x0
  8015ad:	ff 75 08             	push   0x8(%ebp)
  8015b0:	e8 e4 01 00 00       	call   801799 <open>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 1b                	js     8015d9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	ff 75 0c             	push   0xc(%ebp)
  8015c4:	50                   	push   %eax
  8015c5:	e8 64 ff ff ff       	call   80152e <fstat>
  8015ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8015cc:	89 1c 24             	mov    %ebx,(%esp)
  8015cf:	e8 26 fc ff ff       	call   8011fa <close>
	return r;
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	89 f3                	mov    %esi,%ebx
}
  8015d9:	89 d8                	mov    %ebx,%eax
  8015db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	89 c6                	mov    %eax,%esi
  8015e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015eb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8015f2:	74 27                	je     80161b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f4:	6a 07                	push   $0x7
  8015f6:	68 00 50 80 00       	push   $0x805000
  8015fb:	56                   	push   %esi
  8015fc:	ff 35 00 60 80 00    	push   0x806000
  801602:	e8 af 0c 00 00       	call   8022b6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801607:	83 c4 0c             	add    $0xc,%esp
  80160a:	6a 00                	push   $0x0
  80160c:	53                   	push   %ebx
  80160d:	6a 00                	push   $0x0
  80160f:	e8 32 0c 00 00       	call   802246 <ipc_recv>
}
  801614:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	6a 01                	push   $0x1
  801620:	e8 e5 0c 00 00       	call   80230a <ipc_find_env>
  801625:	a3 00 60 80 00       	mov    %eax,0x806000
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb c5                	jmp    8015f4 <fsipc+0x12>

0080162f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801635:	8b 45 08             	mov    0x8(%ebp),%eax
  801638:	8b 40 0c             	mov    0xc(%eax),%eax
  80163b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801640:	8b 45 0c             	mov    0xc(%ebp),%eax
  801643:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801648:	ba 00 00 00 00       	mov    $0x0,%edx
  80164d:	b8 02 00 00 00       	mov    $0x2,%eax
  801652:	e8 8b ff ff ff       	call   8015e2 <fsipc>
}
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <devfile_flush>:
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80165f:	8b 45 08             	mov    0x8(%ebp),%eax
  801662:	8b 40 0c             	mov    0xc(%eax),%eax
  801665:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80166a:	ba 00 00 00 00       	mov    $0x0,%edx
  80166f:	b8 06 00 00 00       	mov    $0x6,%eax
  801674:	e8 69 ff ff ff       	call   8015e2 <fsipc>
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <devfile_stat>:
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801685:	8b 45 08             	mov    0x8(%ebp),%eax
  801688:	8b 40 0c             	mov    0xc(%eax),%eax
  80168b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	b8 05 00 00 00       	mov    $0x5,%eax
  80169a:	e8 43 ff ff ff       	call   8015e2 <fsipc>
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 2c                	js     8016cf <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	68 00 50 80 00       	push   $0x805000
  8016ab:	53                   	push   %ebx
  8016ac:	e8 d6 f0 ff ff       	call   800787 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8016c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <devfile_write>:
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	8b 45 10             	mov    0x10(%ebp),%eax
  8016dd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016e2:	39 d0                	cmp    %edx,%eax
  8016e4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ed:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016f3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016f8:	50                   	push   %eax
  8016f9:	ff 75 0c             	push   0xc(%ebp)
  8016fc:	68 08 50 80 00       	push   $0x805008
  801701:	e8 17 f2 ff ff       	call   80091d <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	b8 04 00 00 00       	mov    $0x4,%eax
  801710:	e8 cd fe ff ff       	call   8015e2 <fsipc>
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_read>:
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	8b 40 0c             	mov    0xc(%eax),%eax
  801725:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80172a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801730:	ba 00 00 00 00       	mov    $0x0,%edx
  801735:	b8 03 00 00 00       	mov    $0x3,%eax
  80173a:	e8 a3 fe ff ff       	call   8015e2 <fsipc>
  80173f:	89 c3                	mov    %eax,%ebx
  801741:	85 c0                	test   %eax,%eax
  801743:	78 1f                	js     801764 <devfile_read+0x4d>
	assert(r <= n);
  801745:	39 f0                	cmp    %esi,%eax
  801747:	77 24                	ja     80176d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801749:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80174e:	7f 33                	jg     801783 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	50                   	push   %eax
  801754:	68 00 50 80 00       	push   $0x805000
  801759:	ff 75 0c             	push   0xc(%ebp)
  80175c:	e8 bc f1 ff ff       	call   80091d <memmove>
	return r;
  801761:	83 c4 10             	add    $0x10,%esp
}
  801764:	89 d8                	mov    %ebx,%eax
  801766:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    
	assert(r <= n);
  80176d:	68 08 2b 80 00       	push   $0x802b08
  801772:	68 0f 2b 80 00       	push   $0x802b0f
  801777:	6a 7c                	push   $0x7c
  801779:	68 24 2b 80 00       	push   $0x802b24
  80177e:	e8 e1 09 00 00       	call   802164 <_panic>
	assert(r <= PGSIZE);
  801783:	68 2f 2b 80 00       	push   $0x802b2f
  801788:	68 0f 2b 80 00       	push   $0x802b0f
  80178d:	6a 7d                	push   $0x7d
  80178f:	68 24 2b 80 00       	push   $0x802b24
  801794:	e8 cb 09 00 00       	call   802164 <_panic>

00801799 <open>:
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 1c             	sub    $0x1c,%esp
  8017a1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017a4:	56                   	push   %esi
  8017a5:	e8 a2 ef ff ff       	call   80074c <strlen>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017b2:	7f 6c                	jg     801820 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	e8 bd f8 ff ff       	call   80107d <fd_alloc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 3c                	js     801805 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	56                   	push   %esi
  8017cd:	68 00 50 80 00       	push   $0x805000
  8017d2:	e8 b0 ef ff ff       	call   800787 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017da:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e7:	e8 f6 fd ff ff       	call   8015e2 <fsipc>
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 19                	js     80180e <open+0x75>
	return fd2num(fd);
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	ff 75 f4             	push   -0xc(%ebp)
  8017fb:	e8 56 f8 ff ff       	call   801056 <fd2num>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
}
  801805:	89 d8                	mov    %ebx,%eax
  801807:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    
		fd_close(fd, 0);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	6a 00                	push   $0x0
  801813:	ff 75 f4             	push   -0xc(%ebp)
  801816:	e8 58 f9 ff ff       	call   801173 <fd_close>
		return r;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	eb e5                	jmp    801805 <open+0x6c>
		return -E_BAD_PATH;
  801820:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801825:	eb de                	jmp    801805 <open+0x6c>

00801827 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 08 00 00 00       	mov    $0x8,%eax
  801837:	e8 a6 fd ff ff       	call   8015e2 <fsipc>
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801844:	68 3b 2b 80 00       	push   $0x802b3b
  801849:	ff 75 0c             	push   0xc(%ebp)
  80184c:	e8 36 ef ff ff       	call   800787 <strcpy>
	return 0;
}
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <devsock_close>:
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	53                   	push   %ebx
  80185c:	83 ec 10             	sub    $0x10,%esp
  80185f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801862:	53                   	push   %ebx
  801863:	e8 e1 0a 00 00       	call   802349 <pageref>
  801868:	89 c2                	mov    %eax,%edx
  80186a:	83 c4 10             	add    $0x10,%esp
		return 0;
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801872:	83 fa 01             	cmp    $0x1,%edx
  801875:	74 05                	je     80187c <devsock_close+0x24>
}
  801877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	ff 73 0c             	push   0xc(%ebx)
  801882:	e8 b7 02 00 00       	call   801b3e <nsipc_close>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb eb                	jmp    801877 <devsock_close+0x1f>

0080188c <devsock_write>:
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801892:	6a 00                	push   $0x0
  801894:	ff 75 10             	push   0x10(%ebp)
  801897:	ff 75 0c             	push   0xc(%ebp)
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	ff 70 0c             	push   0xc(%eax)
  8018a0:	e8 79 03 00 00       	call   801c1e <nsipc_send>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devsock_read>:
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ad:	6a 00                	push   $0x0
  8018af:	ff 75 10             	push   0x10(%ebp)
  8018b2:	ff 75 0c             	push   0xc(%ebp)
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	ff 70 0c             	push   0xc(%eax)
  8018bb:	e8 ef 02 00 00       	call   801baf <nsipc_recv>
}
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <fd2sockid>:
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018c8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018cb:	52                   	push   %edx
  8018cc:	50                   	push   %eax
  8018cd:	e8 fb f7 ff ff       	call   8010cd <fd_lookup>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 10                	js     8018e9 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018dc:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018e2:	39 08                	cmp    %ecx,(%eax)
  8018e4:	75 05                	jne    8018eb <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8018e6:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    
		return -E_NOT_SUPP;
  8018eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018f0:	eb f7                	jmp    8018e9 <fd2sockid+0x27>

008018f2 <alloc_sockfd>:
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 1c             	sub    $0x1c,%esp
  8018fa:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8018fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	e8 78 f7 ff ff       	call   80107d <fd_alloc>
  801905:	89 c3                	mov    %eax,%ebx
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 43                	js     801951 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80190e:	83 ec 04             	sub    $0x4,%esp
  801911:	68 07 04 00 00       	push   $0x407
  801916:	ff 75 f4             	push   -0xc(%ebp)
  801919:	6a 00                	push   $0x0
  80191b:	e8 63 f2 ff ff       	call   800b83 <sys_page_alloc>
  801920:	89 c3                	mov    %eax,%ebx
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	85 c0                	test   %eax,%eax
  801927:	78 28                	js     801951 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801932:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801937:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80193e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	50                   	push   %eax
  801945:	e8 0c f7 ff ff       	call   801056 <fd2num>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	eb 0c                	jmp    80195d <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	56                   	push   %esi
  801955:	e8 e4 01 00 00       	call   801b3e <nsipc_close>
		return r;
  80195a:	83 c4 10             	add    $0x10,%esp
}
  80195d:	89 d8                	mov    %ebx,%eax
  80195f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801962:	5b                   	pop    %ebx
  801963:	5e                   	pop    %esi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <accept>:
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	e8 4e ff ff ff       	call   8018c2 <fd2sockid>
  801974:	85 c0                	test   %eax,%eax
  801976:	78 1b                	js     801993 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	ff 75 10             	push   0x10(%ebp)
  80197e:	ff 75 0c             	push   0xc(%ebp)
  801981:	50                   	push   %eax
  801982:	e8 0e 01 00 00       	call   801a95 <nsipc_accept>
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 05                	js     801993 <accept+0x2d>
	return alloc_sockfd(r);
  80198e:	e8 5f ff ff ff       	call   8018f2 <alloc_sockfd>
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <bind>:
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	e8 1f ff ff ff       	call   8018c2 <fd2sockid>
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 12                	js     8019b9 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8019a7:	83 ec 04             	sub    $0x4,%esp
  8019aa:	ff 75 10             	push   0x10(%ebp)
  8019ad:	ff 75 0c             	push   0xc(%ebp)
  8019b0:	50                   	push   %eax
  8019b1:	e8 31 01 00 00       	call   801ae7 <nsipc_bind>
  8019b6:	83 c4 10             	add    $0x10,%esp
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <shutdown>:
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	e8 f9 fe ff ff       	call   8018c2 <fd2sockid>
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 0f                	js     8019dc <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	ff 75 0c             	push   0xc(%ebp)
  8019d3:	50                   	push   %eax
  8019d4:	e8 43 01 00 00       	call   801b1c <nsipc_shutdown>
  8019d9:	83 c4 10             	add    $0x10,%esp
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <connect>:
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	e8 d6 fe ff ff       	call   8018c2 <fd2sockid>
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 12                	js     801a02 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	ff 75 10             	push   0x10(%ebp)
  8019f6:	ff 75 0c             	push   0xc(%ebp)
  8019f9:	50                   	push   %eax
  8019fa:	e8 59 01 00 00       	call   801b58 <nsipc_connect>
  8019ff:	83 c4 10             	add    $0x10,%esp
}
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <listen>:
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	e8 b0 fe ff ff       	call   8018c2 <fd2sockid>
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 0f                	js     801a25 <listen+0x21>
	return nsipc_listen(r, backlog);
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	ff 75 0c             	push   0xc(%ebp)
  801a1c:	50                   	push   %eax
  801a1d:	e8 6b 01 00 00       	call   801b8d <nsipc_listen>
  801a22:	83 c4 10             	add    $0x10,%esp
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a2d:	ff 75 10             	push   0x10(%ebp)
  801a30:	ff 75 0c             	push   0xc(%ebp)
  801a33:	ff 75 08             	push   0x8(%ebp)
  801a36:	e8 41 02 00 00       	call   801c7c <nsipc_socket>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 05                	js     801a47 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a42:	e8 ab fe ff ff       	call   8018f2 <alloc_sockfd>
}
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 04             	sub    $0x4,%esp
  801a50:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a52:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801a59:	74 26                	je     801a81 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a5b:	6a 07                	push   $0x7
  801a5d:	68 00 70 80 00       	push   $0x807000
  801a62:	53                   	push   %ebx
  801a63:	ff 35 00 80 80 00    	push   0x808000
  801a69:	e8 48 08 00 00       	call   8022b6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a6e:	83 c4 0c             	add    $0xc,%esp
  801a71:	6a 00                	push   $0x0
  801a73:	6a 00                	push   $0x0
  801a75:	6a 00                	push   $0x0
  801a77:	e8 ca 07 00 00       	call   802246 <ipc_recv>
}
  801a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	6a 02                	push   $0x2
  801a86:	e8 7f 08 00 00       	call   80230a <ipc_find_env>
  801a8b:	a3 00 80 80 00       	mov    %eax,0x808000
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	eb c6                	jmp    801a5b <nsipc+0x12>

00801a95 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801aa5:	8b 06                	mov    (%esi),%eax
  801aa7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aac:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab1:	e8 93 ff ff ff       	call   801a49 <nsipc>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	79 09                	jns    801ac5 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801abc:	89 d8                	mov    %ebx,%eax
  801abe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ac5:	83 ec 04             	sub    $0x4,%esp
  801ac8:	ff 35 10 70 80 00    	push   0x807010
  801ace:	68 00 70 80 00       	push   $0x807000
  801ad3:	ff 75 0c             	push   0xc(%ebp)
  801ad6:	e8 42 ee ff ff       	call   80091d <memmove>
		*addrlen = ret->ret_addrlen;
  801adb:	a1 10 70 80 00       	mov    0x807010,%eax
  801ae0:	89 06                	mov    %eax,(%esi)
  801ae2:	83 c4 10             	add    $0x10,%esp
	return r;
  801ae5:	eb d5                	jmp    801abc <nsipc_accept+0x27>

00801ae7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 08             	sub    $0x8,%esp
  801aee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801af9:	53                   	push   %ebx
  801afa:	ff 75 0c             	push   0xc(%ebp)
  801afd:	68 04 70 80 00       	push   $0x807004
  801b02:	e8 16 ee ff ff       	call   80091d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b07:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b0d:	b8 02 00 00 00       	mov    $0x2,%eax
  801b12:	e8 32 ff ff ff       	call   801a49 <nsipc>
}
  801b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801b32:	b8 03 00 00 00       	mov    $0x3,%eax
  801b37:	e8 0d ff ff ff       	call   801a49 <nsipc>
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <nsipc_close>:

int
nsipc_close(int s)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801b4c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b51:	e8 f3 fe ff ff       	call   801a49 <nsipc>
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b6a:	53                   	push   %ebx
  801b6b:	ff 75 0c             	push   0xc(%ebp)
  801b6e:	68 04 70 80 00       	push   $0x807004
  801b73:	e8 a5 ed ff ff       	call   80091d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b78:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801b7e:	b8 05 00 00 00       	mov    $0x5,%eax
  801b83:	e8 c1 fe ff ff       	call   801a49 <nsipc>
}
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ba3:	b8 06 00 00 00       	mov    $0x6,%eax
  801ba8:	e8 9c fe ff ff       	call   801a49 <nsipc>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801bbf:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801bc5:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc8:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bcd:	b8 07 00 00 00       	mov    $0x7,%eax
  801bd2:	e8 72 fe ff ff       	call   801a49 <nsipc>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 22                	js     801bff <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801bdd:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801be2:	39 c6                	cmp    %eax,%esi
  801be4:	0f 4e c6             	cmovle %esi,%eax
  801be7:	39 c3                	cmp    %eax,%ebx
  801be9:	7f 1d                	jg     801c08 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801beb:	83 ec 04             	sub    $0x4,%esp
  801bee:	53                   	push   %ebx
  801bef:	68 00 70 80 00       	push   $0x807000
  801bf4:	ff 75 0c             	push   0xc(%ebp)
  801bf7:	e8 21 ed ff ff       	call   80091d <memmove>
  801bfc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801bff:	89 d8                	mov    %ebx,%eax
  801c01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c08:	68 47 2b 80 00       	push   $0x802b47
  801c0d:	68 0f 2b 80 00       	push   $0x802b0f
  801c12:	6a 62                	push   $0x62
  801c14:	68 5c 2b 80 00       	push   $0x802b5c
  801c19:	e8 46 05 00 00       	call   802164 <_panic>

00801c1e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	53                   	push   %ebx
  801c22:	83 ec 04             	sub    $0x4,%esp
  801c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c30:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c36:	7f 2e                	jg     801c66 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c38:	83 ec 04             	sub    $0x4,%esp
  801c3b:	53                   	push   %ebx
  801c3c:	ff 75 0c             	push   0xc(%ebp)
  801c3f:	68 0c 70 80 00       	push   $0x80700c
  801c44:	e8 d4 ec ff ff       	call   80091d <memmove>
	nsipcbuf.send.req_size = size;
  801c49:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801c4f:	8b 45 14             	mov    0x14(%ebp),%eax
  801c52:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801c57:	b8 08 00 00 00       	mov    $0x8,%eax
  801c5c:	e8 e8 fd ff ff       	call   801a49 <nsipc>
}
  801c61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    
	assert(size < 1600);
  801c66:	68 68 2b 80 00       	push   $0x802b68
  801c6b:	68 0f 2b 80 00       	push   $0x802b0f
  801c70:	6a 6d                	push   $0x6d
  801c72:	68 5c 2b 80 00       	push   $0x802b5c
  801c77:	e8 e8 04 00 00       	call   802164 <_panic>

00801c7c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8d:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801c92:	8b 45 10             	mov    0x10(%ebp),%eax
  801c95:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801c9a:	b8 09 00 00 00       	mov    $0x9,%eax
  801c9f:	e8 a5 fd ff ff       	call   801a49 <nsipc>
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	56                   	push   %esi
  801caa:	53                   	push   %ebx
  801cab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 08             	push   0x8(%ebp)
  801cb4:	e8 ad f3 ff ff       	call   801066 <fd2data>
  801cb9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cbb:	83 c4 08             	add    $0x8,%esp
  801cbe:	68 74 2b 80 00       	push   $0x802b74
  801cc3:	53                   	push   %ebx
  801cc4:	e8 be ea ff ff       	call   800787 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc9:	8b 46 04             	mov    0x4(%esi),%eax
  801ccc:	2b 06                	sub    (%esi),%eax
  801cce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cd4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cdb:	00 00 00 
	stat->st_dev = &devpipe;
  801cde:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ce5:	30 80 00 
	return 0;
}
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ced:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	53                   	push   %ebx
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cfe:	53                   	push   %ebx
  801cff:	6a 00                	push   $0x0
  801d01:	e8 02 ef ff ff       	call   800c08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d06:	89 1c 24             	mov    %ebx,(%esp)
  801d09:	e8 58 f3 ff ff       	call   801066 <fd2data>
  801d0e:	83 c4 08             	add    $0x8,%esp
  801d11:	50                   	push   %eax
  801d12:	6a 00                	push   $0x0
  801d14:	e8 ef ee ff ff       	call   800c08 <sys_page_unmap>
}
  801d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <_pipeisclosed>:
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	89 c7                	mov    %eax,%edi
  801d29:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d2b:	a1 00 40 80 00       	mov    0x804000,%eax
  801d30:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d33:	83 ec 0c             	sub    $0xc,%esp
  801d36:	57                   	push   %edi
  801d37:	e8 0d 06 00 00       	call   802349 <pageref>
  801d3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d3f:	89 34 24             	mov    %esi,(%esp)
  801d42:	e8 02 06 00 00       	call   802349 <pageref>
		nn = thisenv->env_runs;
  801d47:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d4d:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	39 cb                	cmp    %ecx,%ebx
  801d55:	74 1b                	je     801d72 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d57:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d5a:	75 cf                	jne    801d2b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d5c:	8b 42 68             	mov    0x68(%edx),%eax
  801d5f:	6a 01                	push   $0x1
  801d61:	50                   	push   %eax
  801d62:	53                   	push   %ebx
  801d63:	68 7b 2b 80 00       	push   $0x802b7b
  801d68:	e8 40 e4 ff ff       	call   8001ad <cprintf>
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	eb b9                	jmp    801d2b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d72:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d75:	0f 94 c0             	sete   %al
  801d78:	0f b6 c0             	movzbl %al,%eax
}
  801d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <devpipe_write>:
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	57                   	push   %edi
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	83 ec 28             	sub    $0x28,%esp
  801d8c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d8f:	56                   	push   %esi
  801d90:	e8 d1 f2 ff ff       	call   801066 <fd2data>
  801d95:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801da2:	75 09                	jne    801dad <devpipe_write+0x2a>
	return i;
  801da4:	89 f8                	mov    %edi,%eax
  801da6:	eb 23                	jmp    801dcb <devpipe_write+0x48>
			sys_yield();
  801da8:	e8 b7 ed ff ff       	call   800b64 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dad:	8b 43 04             	mov    0x4(%ebx),%eax
  801db0:	8b 0b                	mov    (%ebx),%ecx
  801db2:	8d 51 20             	lea    0x20(%ecx),%edx
  801db5:	39 d0                	cmp    %edx,%eax
  801db7:	72 1a                	jb     801dd3 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801db9:	89 da                	mov    %ebx,%edx
  801dbb:	89 f0                	mov    %esi,%eax
  801dbd:	e8 5c ff ff ff       	call   801d1e <_pipeisclosed>
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	74 e2                	je     801da8 <devpipe_write+0x25>
				return 0;
  801dc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dda:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ddd:	89 c2                	mov    %eax,%edx
  801ddf:	c1 fa 1f             	sar    $0x1f,%edx
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	c1 e9 1b             	shr    $0x1b,%ecx
  801de7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dea:	83 e2 1f             	and    $0x1f,%edx
  801ded:	29 ca                	sub    %ecx,%edx
  801def:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801df3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801df7:	83 c0 01             	add    $0x1,%eax
  801dfa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801dfd:	83 c7 01             	add    $0x1,%edi
  801e00:	eb 9d                	jmp    801d9f <devpipe_write+0x1c>

00801e02 <devpipe_read>:
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 18             	sub    $0x18,%esp
  801e0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e0e:	57                   	push   %edi
  801e0f:	e8 52 f2 ff ff       	call   801066 <fd2data>
  801e14:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	be 00 00 00 00       	mov    $0x0,%esi
  801e1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e21:	75 13                	jne    801e36 <devpipe_read+0x34>
	return i;
  801e23:	89 f0                	mov    %esi,%eax
  801e25:	eb 02                	jmp    801e29 <devpipe_read+0x27>
				return i;
  801e27:	89 f0                	mov    %esi,%eax
}
  801e29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5e                   	pop    %esi
  801e2e:	5f                   	pop    %edi
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    
			sys_yield();
  801e31:	e8 2e ed ff ff       	call   800b64 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e36:	8b 03                	mov    (%ebx),%eax
  801e38:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e3b:	75 18                	jne    801e55 <devpipe_read+0x53>
			if (i > 0)
  801e3d:	85 f6                	test   %esi,%esi
  801e3f:	75 e6                	jne    801e27 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801e41:	89 da                	mov    %ebx,%edx
  801e43:	89 f8                	mov    %edi,%eax
  801e45:	e8 d4 fe ff ff       	call   801d1e <_pipeisclosed>
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	74 e3                	je     801e31 <devpipe_read+0x2f>
				return 0;
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e53:	eb d4                	jmp    801e29 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e55:	99                   	cltd   
  801e56:	c1 ea 1b             	shr    $0x1b,%edx
  801e59:	01 d0                	add    %edx,%eax
  801e5b:	83 e0 1f             	and    $0x1f,%eax
  801e5e:	29 d0                	sub    %edx,%eax
  801e60:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e68:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e6b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e6e:	83 c6 01             	add    $0x1,%esi
  801e71:	eb ab                	jmp    801e1e <devpipe_read+0x1c>

00801e73 <pipe>:
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7e:	50                   	push   %eax
  801e7f:	e8 f9 f1 ff ff       	call   80107d <fd_alloc>
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	0f 88 23 01 00 00    	js     801fb4 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e91:	83 ec 04             	sub    $0x4,%esp
  801e94:	68 07 04 00 00       	push   $0x407
  801e99:	ff 75 f4             	push   -0xc(%ebp)
  801e9c:	6a 00                	push   $0x0
  801e9e:	e8 e0 ec ff ff       	call   800b83 <sys_page_alloc>
  801ea3:	89 c3                	mov    %eax,%ebx
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	0f 88 04 01 00 00    	js     801fb4 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	e8 c1 f1 ff ff       	call   80107d <fd_alloc>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	0f 88 db 00 00 00    	js     801fa4 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec9:	83 ec 04             	sub    $0x4,%esp
  801ecc:	68 07 04 00 00       	push   $0x407
  801ed1:	ff 75 f0             	push   -0x10(%ebp)
  801ed4:	6a 00                	push   $0x0
  801ed6:	e8 a8 ec ff ff       	call   800b83 <sys_page_alloc>
  801edb:	89 c3                	mov    %eax,%ebx
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 88 bc 00 00 00    	js     801fa4 <pipe+0x131>
	va = fd2data(fd0);
  801ee8:	83 ec 0c             	sub    $0xc,%esp
  801eeb:	ff 75 f4             	push   -0xc(%ebp)
  801eee:	e8 73 f1 ff ff       	call   801066 <fd2data>
  801ef3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef5:	83 c4 0c             	add    $0xc,%esp
  801ef8:	68 07 04 00 00       	push   $0x407
  801efd:	50                   	push   %eax
  801efe:	6a 00                	push   $0x0
  801f00:	e8 7e ec ff ff       	call   800b83 <sys_page_alloc>
  801f05:	89 c3                	mov    %eax,%ebx
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	0f 88 82 00 00 00    	js     801f94 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	ff 75 f0             	push   -0x10(%ebp)
  801f18:	e8 49 f1 ff ff       	call   801066 <fd2data>
  801f1d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f24:	50                   	push   %eax
  801f25:	6a 00                	push   $0x0
  801f27:	56                   	push   %esi
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 97 ec ff ff       	call   800bc6 <sys_page_map>
  801f2f:	89 c3                	mov    %eax,%ebx
  801f31:	83 c4 20             	add    $0x20,%esp
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 4e                	js     801f86 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801f38:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801f3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f40:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f45:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f4f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f54:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	ff 75 f4             	push   -0xc(%ebp)
  801f61:	e8 f0 f0 ff ff       	call   801056 <fd2num>
  801f66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f69:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f6b:	83 c4 04             	add    $0x4,%esp
  801f6e:	ff 75 f0             	push   -0x10(%ebp)
  801f71:	e8 e0 f0 ff ff       	call   801056 <fd2num>
  801f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f79:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f84:	eb 2e                	jmp    801fb4 <pipe+0x141>
	sys_page_unmap(0, va);
  801f86:	83 ec 08             	sub    $0x8,%esp
  801f89:	56                   	push   %esi
  801f8a:	6a 00                	push   $0x0
  801f8c:	e8 77 ec ff ff       	call   800c08 <sys_page_unmap>
  801f91:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f94:	83 ec 08             	sub    $0x8,%esp
  801f97:	ff 75 f0             	push   -0x10(%ebp)
  801f9a:	6a 00                	push   $0x0
  801f9c:	e8 67 ec ff ff       	call   800c08 <sys_page_unmap>
  801fa1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fa4:	83 ec 08             	sub    $0x8,%esp
  801fa7:	ff 75 f4             	push   -0xc(%ebp)
  801faa:	6a 00                	push   $0x0
  801fac:	e8 57 ec ff ff       	call   800c08 <sys_page_unmap>
  801fb1:	83 c4 10             	add    $0x10,%esp
}
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb9:	5b                   	pop    %ebx
  801fba:	5e                   	pop    %esi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    

00801fbd <pipeisclosed>:
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc6:	50                   	push   %eax
  801fc7:	ff 75 08             	push   0x8(%ebp)
  801fca:	e8 fe f0 ff ff       	call   8010cd <fd_lookup>
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 18                	js     801fee <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	ff 75 f4             	push   -0xc(%ebp)
  801fdc:	e8 85 f0 ff ff       	call   801066 <fd2data>
  801fe1:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe6:	e8 33 fd ff ff       	call   801d1e <_pipeisclosed>
  801feb:	83 c4 10             	add    $0x10,%esp
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff5:	c3                   	ret    

00801ff6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ffc:	68 93 2b 80 00       	push   $0x802b93
  802001:	ff 75 0c             	push   0xc(%ebp)
  802004:	e8 7e e7 ff ff       	call   800787 <strcpy>
	return 0;
}
  802009:	b8 00 00 00 00       	mov    $0x0,%eax
  80200e:	c9                   	leave  
  80200f:	c3                   	ret    

00802010 <devcons_write>:
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	57                   	push   %edi
  802014:	56                   	push   %esi
  802015:	53                   	push   %ebx
  802016:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80201c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802021:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802027:	eb 2e                	jmp    802057 <devcons_write+0x47>
		m = n - tot;
  802029:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80202c:	29 f3                	sub    %esi,%ebx
  80202e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802033:	39 c3                	cmp    %eax,%ebx
  802035:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	53                   	push   %ebx
  80203c:	89 f0                	mov    %esi,%eax
  80203e:	03 45 0c             	add    0xc(%ebp),%eax
  802041:	50                   	push   %eax
  802042:	57                   	push   %edi
  802043:	e8 d5 e8 ff ff       	call   80091d <memmove>
		sys_cputs(buf, m);
  802048:	83 c4 08             	add    $0x8,%esp
  80204b:	53                   	push   %ebx
  80204c:	57                   	push   %edi
  80204d:	e8 75 ea ff ff       	call   800ac7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802052:	01 de                	add    %ebx,%esi
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	3b 75 10             	cmp    0x10(%ebp),%esi
  80205a:	72 cd                	jb     802029 <devcons_write+0x19>
}
  80205c:	89 f0                	mov    %esi,%eax
  80205e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    

00802066 <devcons_read>:
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	83 ec 08             	sub    $0x8,%esp
  80206c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802071:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802075:	75 07                	jne    80207e <devcons_read+0x18>
  802077:	eb 1f                	jmp    802098 <devcons_read+0x32>
		sys_yield();
  802079:	e8 e6 ea ff ff       	call   800b64 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80207e:	e8 62 ea ff ff       	call   800ae5 <sys_cgetc>
  802083:	85 c0                	test   %eax,%eax
  802085:	74 f2                	je     802079 <devcons_read+0x13>
	if (c < 0)
  802087:	78 0f                	js     802098 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802089:	83 f8 04             	cmp    $0x4,%eax
  80208c:	74 0c                	je     80209a <devcons_read+0x34>
	*(char*)vbuf = c;
  80208e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802091:	88 02                	mov    %al,(%edx)
	return 1;
  802093:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802098:	c9                   	leave  
  802099:	c3                   	ret    
		return 0;
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
  80209f:	eb f7                	jmp    802098 <devcons_read+0x32>

008020a1 <cputchar>:
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020aa:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020ad:	6a 01                	push   $0x1
  8020af:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b2:	50                   	push   %eax
  8020b3:	e8 0f ea ff ff       	call   800ac7 <sys_cputs>
}
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	c9                   	leave  
  8020bc:	c3                   	ret    

008020bd <getchar>:
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020c3:	6a 01                	push   $0x1
  8020c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c8:	50                   	push   %eax
  8020c9:	6a 00                	push   $0x0
  8020cb:	e8 66 f2 ff ff       	call   801336 <read>
	if (r < 0)
  8020d0:	83 c4 10             	add    $0x10,%esp
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	78 06                	js     8020dd <getchar+0x20>
	if (r < 1)
  8020d7:	74 06                	je     8020df <getchar+0x22>
	return c;
  8020d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020dd:	c9                   	leave  
  8020de:	c3                   	ret    
		return -E_EOF;
  8020df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020e4:	eb f7                	jmp    8020dd <getchar+0x20>

008020e6 <iscons>:
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ef:	50                   	push   %eax
  8020f0:	ff 75 08             	push   0x8(%ebp)
  8020f3:	e8 d5 ef ff ff       	call   8010cd <fd_lookup>
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	78 11                	js     802110 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8020ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802102:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802108:	39 10                	cmp    %edx,(%eax)
  80210a:	0f 94 c0             	sete   %al
  80210d:	0f b6 c0             	movzbl %al,%eax
}
  802110:	c9                   	leave  
  802111:	c3                   	ret    

00802112 <opencons>:
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211b:	50                   	push   %eax
  80211c:	e8 5c ef ff ff       	call   80107d <fd_alloc>
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	85 c0                	test   %eax,%eax
  802126:	78 3a                	js     802162 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802128:	83 ec 04             	sub    $0x4,%esp
  80212b:	68 07 04 00 00       	push   $0x407
  802130:	ff 75 f4             	push   -0xc(%ebp)
  802133:	6a 00                	push   $0x0
  802135:	e8 49 ea ff ff       	call   800b83 <sys_page_alloc>
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 21                	js     802162 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802144:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80214a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80214c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	50                   	push   %eax
  80215a:	e8 f7 ee ff ff       	call   801056 <fd2num>
  80215f:	83 c4 10             	add    $0x10,%esp
}
  802162:	c9                   	leave  
  802163:	c3                   	ret    

00802164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	56                   	push   %esi
  802168:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802169:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80216c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802172:	e8 ce e9 ff ff       	call   800b45 <sys_getenvid>
  802177:	83 ec 0c             	sub    $0xc,%esp
  80217a:	ff 75 0c             	push   0xc(%ebp)
  80217d:	ff 75 08             	push   0x8(%ebp)
  802180:	56                   	push   %esi
  802181:	50                   	push   %eax
  802182:	68 a0 2b 80 00       	push   $0x802ba0
  802187:	e8 21 e0 ff ff       	call   8001ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80218c:	83 c4 18             	add    $0x18,%esp
  80218f:	53                   	push   %ebx
  802190:	ff 75 10             	push   0x10(%ebp)
  802193:	e8 c4 df ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  802198:	c7 04 24 74 26 80 00 	movl   $0x802674,(%esp)
  80219f:	e8 09 e0 ff ff       	call   8001ad <cprintf>
  8021a4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021a7:	cc                   	int3   
  8021a8:	eb fd                	jmp    8021a7 <_panic+0x43>

008021aa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8021b0:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8021b7:	74 0a                	je     8021c3 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bc:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8021c3:	e8 7d e9 ff ff       	call   800b45 <sys_getenvid>
  8021c8:	83 ec 04             	sub    $0x4,%esp
  8021cb:	68 07 0e 00 00       	push   $0xe07
  8021d0:	68 00 f0 bf ee       	push   $0xeebff000
  8021d5:	50                   	push   %eax
  8021d6:	e8 a8 e9 ff ff       	call   800b83 <sys_page_alloc>
		if (r < 0) {
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 2c                	js     80220e <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8021e2:	e8 5e e9 ff ff       	call   800b45 <sys_getenvid>
  8021e7:	83 ec 08             	sub    $0x8,%esp
  8021ea:	68 20 22 80 00       	push   $0x802220
  8021ef:	50                   	push   %eax
  8021f0:	e8 d9 ea ff ff       	call   800cce <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8021f5:	83 c4 10             	add    $0x10,%esp
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	79 bd                	jns    8021b9 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8021fc:	50                   	push   %eax
  8021fd:	68 04 2c 80 00       	push   $0x802c04
  802202:	6a 28                	push   $0x28
  802204:	68 3a 2c 80 00       	push   $0x802c3a
  802209:	e8 56 ff ff ff       	call   802164 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80220e:	50                   	push   %eax
  80220f:	68 c4 2b 80 00       	push   $0x802bc4
  802214:	6a 23                	push   $0x23
  802216:	68 3a 2c 80 00       	push   $0x802c3a
  80221b:	e8 44 ff ff ff       	call   802164 <_panic>

00802220 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802220:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802221:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802226:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802228:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80222b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80222f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802232:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802236:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80223a:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80223c:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80223f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802240:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802243:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802244:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802245:	c3                   	ret    

00802246 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	56                   	push   %esi
  80224a:	53                   	push   %ebx
  80224b:	8b 75 08             	mov    0x8(%ebp),%esi
  80224e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802251:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802254:	85 c0                	test   %eax,%eax
  802256:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80225b:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80225e:	83 ec 0c             	sub    $0xc,%esp
  802261:	50                   	push   %eax
  802262:	e8 cc ea ff ff       	call   800d33 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802267:	83 c4 10             	add    $0x10,%esp
  80226a:	85 f6                	test   %esi,%esi
  80226c:	74 17                	je     802285 <ipc_recv+0x3f>
  80226e:	ba 00 00 00 00       	mov    $0x0,%edx
  802273:	85 c0                	test   %eax,%eax
  802275:	78 0c                	js     802283 <ipc_recv+0x3d>
  802277:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80227d:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802283:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802285:	85 db                	test   %ebx,%ebx
  802287:	74 17                	je     8022a0 <ipc_recv+0x5a>
  802289:	ba 00 00 00 00       	mov    $0x0,%edx
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 0c                	js     80229e <ipc_recv+0x58>
  802292:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802298:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80229e:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8022a0:	85 c0                	test   %eax,%eax
  8022a2:	78 0b                	js     8022af <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8022a4:	a1 00 40 80 00       	mov    0x804000,%eax
  8022a9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8022af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b2:	5b                   	pop    %ebx
  8022b3:	5e                   	pop    %esi
  8022b4:	5d                   	pop    %ebp
  8022b5:	c3                   	ret    

008022b6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	57                   	push   %edi
  8022ba:	56                   	push   %esi
  8022bb:	53                   	push   %ebx
  8022bc:	83 ec 0c             	sub    $0xc,%esp
  8022bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8022c8:	85 db                	test   %ebx,%ebx
  8022ca:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022cf:	0f 44 d8             	cmove  %eax,%ebx
  8022d2:	eb 05                	jmp    8022d9 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022d4:	e8 8b e8 ff ff       	call   800b64 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8022d9:	ff 75 14             	push   0x14(%ebp)
  8022dc:	53                   	push   %ebx
  8022dd:	56                   	push   %esi
  8022de:	57                   	push   %edi
  8022df:	e8 2c ea ff ff       	call   800d10 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022e4:	83 c4 10             	add    $0x10,%esp
  8022e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ea:	74 e8                	je     8022d4 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	78 08                	js     8022f8 <ipc_send+0x42>
	}while (r<0);

}
  8022f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8022f8:	50                   	push   %eax
  8022f9:	68 48 2c 80 00       	push   $0x802c48
  8022fe:	6a 3d                	push   $0x3d
  802300:	68 5c 2c 80 00       	push   $0x802c5c
  802305:	e8 5a fe ff ff       	call   802164 <_panic>

0080230a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802315:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80231b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802321:	8b 52 60             	mov    0x60(%edx),%edx
  802324:	39 ca                	cmp    %ecx,%edx
  802326:	74 11                	je     802339 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802328:	83 c0 01             	add    $0x1,%eax
  80232b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802330:	75 e3                	jne    802315 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
  802337:	eb 0e                	jmp    802347 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802339:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80233f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802344:	8b 40 58             	mov    0x58(%eax),%eax
}
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    

00802349 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802349:	55                   	push   %ebp
  80234a:	89 e5                	mov    %esp,%ebp
  80234c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80234f:	89 c2                	mov    %eax,%edx
  802351:	c1 ea 16             	shr    $0x16,%edx
  802354:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80235b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802360:	f6 c1 01             	test   $0x1,%cl
  802363:	74 1c                	je     802381 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802365:	c1 e8 0c             	shr    $0xc,%eax
  802368:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80236f:	a8 01                	test   $0x1,%al
  802371:	74 0e                	je     802381 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802373:	c1 e8 0c             	shr    $0xc,%eax
  802376:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80237d:	ef 
  80237e:	0f b7 d2             	movzwl %dx,%edx
}
  802381:	89 d0                	mov    %edx,%eax
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    
  802385:	66 90                	xchg   %ax,%ax
  802387:	66 90                	xchg   %ax,%ax
  802389:	66 90                	xchg   %ax,%ax
  80238b:	66 90                	xchg   %ax,%ax
  80238d:	66 90                	xchg   %ax,%ax
  80238f:	90                   	nop

00802390 <__udivdi3>:
  802390:	f3 0f 1e fb          	endbr32 
  802394:	55                   	push   %ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 1c             	sub    $0x1c,%esp
  80239b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80239f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	75 19                	jne    8023c8 <__udivdi3+0x38>
  8023af:	39 f3                	cmp    %esi,%ebx
  8023b1:	76 4d                	jbe    802400 <__udivdi3+0x70>
  8023b3:	31 ff                	xor    %edi,%edi
  8023b5:	89 e8                	mov    %ebp,%eax
  8023b7:	89 f2                	mov    %esi,%edx
  8023b9:	f7 f3                	div    %ebx
  8023bb:	89 fa                	mov    %edi,%edx
  8023bd:	83 c4 1c             	add    $0x1c,%esp
  8023c0:	5b                   	pop    %ebx
  8023c1:	5e                   	pop    %esi
  8023c2:	5f                   	pop    %edi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	8d 76 00             	lea    0x0(%esi),%esi
  8023c8:	39 f0                	cmp    %esi,%eax
  8023ca:	76 14                	jbe    8023e0 <__udivdi3+0x50>
  8023cc:	31 ff                	xor    %edi,%edi
  8023ce:	31 c0                	xor    %eax,%eax
  8023d0:	89 fa                	mov    %edi,%edx
  8023d2:	83 c4 1c             	add    $0x1c,%esp
  8023d5:	5b                   	pop    %ebx
  8023d6:	5e                   	pop    %esi
  8023d7:	5f                   	pop    %edi
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    
  8023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e0:	0f bd f8             	bsr    %eax,%edi
  8023e3:	83 f7 1f             	xor    $0x1f,%edi
  8023e6:	75 48                	jne    802430 <__udivdi3+0xa0>
  8023e8:	39 f0                	cmp    %esi,%eax
  8023ea:	72 06                	jb     8023f2 <__udivdi3+0x62>
  8023ec:	31 c0                	xor    %eax,%eax
  8023ee:	39 eb                	cmp    %ebp,%ebx
  8023f0:	77 de                	ja     8023d0 <__udivdi3+0x40>
  8023f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f7:	eb d7                	jmp    8023d0 <__udivdi3+0x40>
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	89 d9                	mov    %ebx,%ecx
  802402:	85 db                	test   %ebx,%ebx
  802404:	75 0b                	jne    802411 <__udivdi3+0x81>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f3                	div    %ebx
  80240f:	89 c1                	mov    %eax,%ecx
  802411:	31 d2                	xor    %edx,%edx
  802413:	89 f0                	mov    %esi,%eax
  802415:	f7 f1                	div    %ecx
  802417:	89 c6                	mov    %eax,%esi
  802419:	89 e8                	mov    %ebp,%eax
  80241b:	89 f7                	mov    %esi,%edi
  80241d:	f7 f1                	div    %ecx
  80241f:	89 fa                	mov    %edi,%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 f9                	mov    %edi,%ecx
  802432:	ba 20 00 00 00       	mov    $0x20,%edx
  802437:	29 fa                	sub    %edi,%edx
  802439:	d3 e0                	shl    %cl,%eax
  80243b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80243f:	89 d1                	mov    %edx,%ecx
  802441:	89 d8                	mov    %ebx,%eax
  802443:	d3 e8                	shr    %cl,%eax
  802445:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802449:	09 c1                	or     %eax,%ecx
  80244b:	89 f0                	mov    %esi,%eax
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f9                	mov    %edi,%ecx
  802453:	d3 e3                	shl    %cl,%ebx
  802455:	89 d1                	mov    %edx,%ecx
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 f9                	mov    %edi,%ecx
  80245b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80245f:	89 eb                	mov    %ebp,%ebx
  802461:	d3 e6                	shl    %cl,%esi
  802463:	89 d1                	mov    %edx,%ecx
  802465:	d3 eb                	shr    %cl,%ebx
  802467:	09 f3                	or     %esi,%ebx
  802469:	89 c6                	mov    %eax,%esi
  80246b:	89 f2                	mov    %esi,%edx
  80246d:	89 d8                	mov    %ebx,%eax
  80246f:	f7 74 24 08          	divl   0x8(%esp)
  802473:	89 d6                	mov    %edx,%esi
  802475:	89 c3                	mov    %eax,%ebx
  802477:	f7 64 24 0c          	mull   0xc(%esp)
  80247b:	39 d6                	cmp    %edx,%esi
  80247d:	72 19                	jb     802498 <__udivdi3+0x108>
  80247f:	89 f9                	mov    %edi,%ecx
  802481:	d3 e5                	shl    %cl,%ebp
  802483:	39 c5                	cmp    %eax,%ebp
  802485:	73 04                	jae    80248b <__udivdi3+0xfb>
  802487:	39 d6                	cmp    %edx,%esi
  802489:	74 0d                	je     802498 <__udivdi3+0x108>
  80248b:	89 d8                	mov    %ebx,%eax
  80248d:	31 ff                	xor    %edi,%edi
  80248f:	e9 3c ff ff ff       	jmp    8023d0 <__udivdi3+0x40>
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80249b:	31 ff                	xor    %edi,%edi
  80249d:	e9 2e ff ff ff       	jmp    8023d0 <__udivdi3+0x40>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	f3 0f 1e fb          	endbr32 
  8024b4:	55                   	push   %ebp
  8024b5:	57                   	push   %edi
  8024b6:	56                   	push   %esi
  8024b7:	53                   	push   %ebx
  8024b8:	83 ec 1c             	sub    $0x1c,%esp
  8024bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024cb:	89 f0                	mov    %esi,%eax
  8024cd:	89 da                	mov    %ebx,%edx
  8024cf:	85 ff                	test   %edi,%edi
  8024d1:	75 15                	jne    8024e8 <__umoddi3+0x38>
  8024d3:	39 dd                	cmp    %ebx,%ebp
  8024d5:	76 39                	jbe    802510 <__umoddi3+0x60>
  8024d7:	f7 f5                	div    %ebp
  8024d9:	89 d0                	mov    %edx,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	83 c4 1c             	add    $0x1c,%esp
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
  8024e8:	39 df                	cmp    %ebx,%edi
  8024ea:	77 f1                	ja     8024dd <__umoddi3+0x2d>
  8024ec:	0f bd cf             	bsr    %edi,%ecx
  8024ef:	83 f1 1f             	xor    $0x1f,%ecx
  8024f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024f6:	75 40                	jne    802538 <__umoddi3+0x88>
  8024f8:	39 df                	cmp    %ebx,%edi
  8024fa:	72 04                	jb     802500 <__umoddi3+0x50>
  8024fc:	39 f5                	cmp    %esi,%ebp
  8024fe:	77 dd                	ja     8024dd <__umoddi3+0x2d>
  802500:	89 da                	mov    %ebx,%edx
  802502:	89 f0                	mov    %esi,%eax
  802504:	29 e8                	sub    %ebp,%eax
  802506:	19 fa                	sbb    %edi,%edx
  802508:	eb d3                	jmp    8024dd <__umoddi3+0x2d>
  80250a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802510:	89 e9                	mov    %ebp,%ecx
  802512:	85 ed                	test   %ebp,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x71>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f5                	div    %ebp
  80251f:	89 c1                	mov    %eax,%ecx
  802521:	89 d8                	mov    %ebx,%eax
  802523:	31 d2                	xor    %edx,%edx
  802525:	f7 f1                	div    %ecx
  802527:	89 f0                	mov    %esi,%eax
  802529:	f7 f1                	div    %ecx
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	31 d2                	xor    %edx,%edx
  80252f:	eb ac                	jmp    8024dd <__umoddi3+0x2d>
  802531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802538:	8b 44 24 04          	mov    0x4(%esp),%eax
  80253c:	ba 20 00 00 00       	mov    $0x20,%edx
  802541:	29 c2                	sub    %eax,%edx
  802543:	89 c1                	mov    %eax,%ecx
  802545:	89 e8                	mov    %ebp,%eax
  802547:	d3 e7                	shl    %cl,%edi
  802549:	89 d1                	mov    %edx,%ecx
  80254b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80254f:	d3 e8                	shr    %cl,%eax
  802551:	89 c1                	mov    %eax,%ecx
  802553:	8b 44 24 04          	mov    0x4(%esp),%eax
  802557:	09 f9                	or     %edi,%ecx
  802559:	89 df                	mov    %ebx,%edi
  80255b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80255f:	89 c1                	mov    %eax,%ecx
  802561:	d3 e5                	shl    %cl,%ebp
  802563:	89 d1                	mov    %edx,%ecx
  802565:	d3 ef                	shr    %cl,%edi
  802567:	89 c1                	mov    %eax,%ecx
  802569:	89 f0                	mov    %esi,%eax
  80256b:	d3 e3                	shl    %cl,%ebx
  80256d:	89 d1                	mov    %edx,%ecx
  80256f:	89 fa                	mov    %edi,%edx
  802571:	d3 e8                	shr    %cl,%eax
  802573:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802578:	09 d8                	or     %ebx,%eax
  80257a:	f7 74 24 08          	divl   0x8(%esp)
  80257e:	89 d3                	mov    %edx,%ebx
  802580:	d3 e6                	shl    %cl,%esi
  802582:	f7 e5                	mul    %ebp
  802584:	89 c7                	mov    %eax,%edi
  802586:	89 d1                	mov    %edx,%ecx
  802588:	39 d3                	cmp    %edx,%ebx
  80258a:	72 06                	jb     802592 <__umoddi3+0xe2>
  80258c:	75 0e                	jne    80259c <__umoddi3+0xec>
  80258e:	39 c6                	cmp    %eax,%esi
  802590:	73 0a                	jae    80259c <__umoddi3+0xec>
  802592:	29 e8                	sub    %ebp,%eax
  802594:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802598:	89 d1                	mov    %edx,%ecx
  80259a:	89 c7                	mov    %eax,%edi
  80259c:	89 f5                	mov    %esi,%ebp
  80259e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025a2:	29 fd                	sub    %edi,%ebp
  8025a4:	19 cb                	sbb    %ecx,%ebx
  8025a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025ab:	89 d8                	mov    %ebx,%eax
  8025ad:	d3 e0                	shl    %cl,%eax
  8025af:	89 f1                	mov    %esi,%ecx
  8025b1:	d3 ed                	shr    %cl,%ebp
  8025b3:	d3 eb                	shr    %cl,%ebx
  8025b5:	09 e8                	or     %ebp,%eax
  8025b7:	89 da                	mov    %ebx,%edx
  8025b9:	83 c4 1c             	add    $0x1c,%esp
  8025bc:	5b                   	pop    %ebx
  8025bd:	5e                   	pop    %esi
  8025be:	5f                   	pop    %edi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    
