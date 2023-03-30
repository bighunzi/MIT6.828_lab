
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
  80003a:	68 c0 25 80 00       	push   $0x8025c0
  80003f:	e8 66 01 00 00       	call   8001aa <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 87 0e 00 00       	call   800ed0 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 26 80 00       	push   $0x802638
  800058:	e8 4d 01 00 00       	call   8001aa <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 25 80 00       	push   $0x8025e8
  80006c:	e8 39 01 00 00       	call   8001aa <cprintf>
	sys_yield();
  800071:	e8 eb 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  800076:	e8 e6 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  80007b:	e8 e1 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  800080:	e8 dc 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  800085:	e8 d7 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  80008a:	e8 d2 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  80008f:	e8 cd 0a 00 00       	call   800b61 <sys_yield>
	sys_yield();
  800094:	e8 c8 0a 00 00       	call   800b61 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  8000a0:	e8 05 01 00 00       	call   8001aa <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 54 0a 00 00       	call   800b01 <sys_env_destroy>
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
  8000c0:	e8 7d 0a 00 00       	call   800b42 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 1b 11 00 00       	call   801221 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 f1 09 00 00       	call   800b01 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	74 09                	je     80013d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800134:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 76 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	eb db                	jmp    800134 <putch+0x1f>

00800159 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800162:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800169:	00 00 00 
	b.cnt = 0;
  80016c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800173:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800176:	ff 75 0c             	push   0xc(%ebp)
  800179:	ff 75 08             	push   0x8(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	68 15 01 80 00       	push   $0x800115
  800188:	e8 14 01 00 00       	call   8002a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018d:	83 c4 08             	add    $0x8,%esp
  800190:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 22 09 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001a2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b3:	50                   	push   %eax
  8001b4:	ff 75 08             	push   0x8(%ebp)
  8001b7:	e8 9d ff ff ff       	call   800159 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 1c             	sub    $0x1c,%esp
  8001c7:	89 c7                	mov    %eax,%edi
  8001c9:	89 d6                	mov    %edx,%esi
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 d1                	mov    %edx,%ecx
  8001d3:	89 c2                	mov    %eax,%edx
  8001d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001db:	8b 45 10             	mov    0x10(%ebp),%eax
  8001de:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001eb:	39 c2                	cmp    %eax,%edx
  8001ed:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f0:	72 3e                	jb     800230 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	ff 75 18             	push   0x18(%ebp)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	53                   	push   %ebx
  8001fc:	50                   	push   %eax
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	push   -0x1c(%ebp)
  800203:	ff 75 e0             	push   -0x20(%ebp)
  800206:	ff 75 dc             	push   -0x24(%ebp)
  800209:	ff 75 d8             	push   -0x28(%ebp)
  80020c:	e8 5f 21 00 00       	call   802370 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9f ff ff ff       	call   8001be <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 13                	jmp    800237 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	push   0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800230:	83 eb 01             	sub    $0x1,%ebx
  800233:	85 db                	test   %ebx,%ebx
  800235:	7f ed                	jg     800224 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	83 ec 04             	sub    $0x4,%esp
  80023e:	ff 75 e4             	push   -0x1c(%ebp)
  800241:	ff 75 e0             	push   -0x20(%ebp)
  800244:	ff 75 dc             	push   -0x24(%ebp)
  800247:	ff 75 d8             	push   -0x28(%ebp)
  80024a:	e8 41 22 00 00       	call   802490 <__umoddi3>
  80024f:	83 c4 14             	add    $0x14,%esp
  800252:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
  800259:	50                   	push   %eax
  80025a:	ff d7                	call   *%edi
}
  80025c:	83 c4 10             	add    $0x10,%esp
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800271:	8b 10                	mov    (%eax),%edx
  800273:	3b 50 04             	cmp    0x4(%eax),%edx
  800276:	73 0a                	jae    800282 <sprintputch+0x1b>
		*b->buf++ = ch;
  800278:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	88 02                	mov    %al,(%edx)
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <printfmt>:
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 10             	push   0x10(%ebp)
  800291:	ff 75 0c             	push   0xc(%ebp)
  800294:	ff 75 08             	push   0x8(%ebp)
  800297:	e8 05 00 00 00       	call   8002a1 <vprintfmt>
}
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <vprintfmt>:
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 3c             	sub    $0x3c,%esp
  8002aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b3:	eb 0a                	jmp    8002bf <vprintfmt+0x1e>
			putch(ch, putdat);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	53                   	push   %ebx
  8002b9:	50                   	push   %eax
  8002ba:	ff d6                	call   *%esi
  8002bc:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bf:	83 c7 01             	add    $0x1,%edi
  8002c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c6:	83 f8 25             	cmp    $0x25,%eax
  8002c9:	74 0c                	je     8002d7 <vprintfmt+0x36>
			if (ch == '\0')
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	75 e6                	jne    8002b5 <vprintfmt+0x14>
}
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    
		padc = ' ';
  8002d7:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002db:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8d 47 01             	lea    0x1(%edi),%eax
  8002f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fb:	0f b6 17             	movzbl (%edi),%edx
  8002fe:	8d 42 dd             	lea    -0x23(%edx),%eax
  800301:	3c 55                	cmp    $0x55,%al
  800303:	0f 87 bb 03 00 00    	ja     8006c4 <vprintfmt+0x423>
  800309:	0f b6 c0             	movzbl %al,%eax
  80030c:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800316:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80031a:	eb d9                	jmp    8002f5 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800323:	eb d0                	jmp    8002f5 <vprintfmt+0x54>
  800325:	0f b6 d2             	movzbl %dl,%edx
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800340:	83 f9 09             	cmp    $0x9,%ecx
  800343:	77 55                	ja     80039a <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800348:	eb e9                	jmp    800333 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 40 04             	lea    0x4(%eax),%eax
  800358:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800362:	79 91                	jns    8002f5 <vprintfmt+0x54>
				width = precision, precision = -1;
  800364:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800371:	eb 82                	jmp    8002f5 <vprintfmt+0x54>
  800373:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800376:	85 d2                	test   %edx,%edx
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	0f 49 c2             	cmovns %edx,%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800386:	e9 6a ff ff ff       	jmp    8002f5 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800395:	e9 5b ff ff ff       	jmp    8002f5 <vprintfmt+0x54>
  80039a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a0:	eb bc                	jmp    80035e <vprintfmt+0xbd>
			lflag++;
  8003a2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a8:	e9 48 ff ff ff       	jmp    8002f5 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 78 04             	lea    0x4(%eax),%edi
  8003b3:	83 ec 08             	sub    $0x8,%esp
  8003b6:	53                   	push   %ebx
  8003b7:	ff 30                	push   (%eax)
  8003b9:	ff d6                	call   *%esi
			break;
  8003bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c1:	e9 9d 02 00 00       	jmp    800663 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 78 04             	lea    0x4(%eax),%edi
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	89 d0                	mov    %edx,%eax
  8003d0:	f7 d8                	neg    %eax
  8003d2:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d5:	83 f8 0f             	cmp    $0xf,%eax
  8003d8:	7f 23                	jg     8003fd <vprintfmt+0x15c>
  8003da:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	74 18                	je     8003fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003e5:	52                   	push   %edx
  8003e6:	68 01 2b 80 00       	push   $0x802b01
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 92 fe ff ff       	call   800284 <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f8:	e9 66 02 00 00       	jmp    800663 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003fd:	50                   	push   %eax
  8003fe:	68 78 26 80 00       	push   $0x802678
  800403:	53                   	push   %ebx
  800404:	56                   	push   %esi
  800405:	e8 7a fe ff ff       	call   800284 <printfmt>
  80040a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800410:	e9 4e 02 00 00       	jmp    800663 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	83 c0 04             	add    $0x4,%eax
  80041b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800423:	85 d2                	test   %edx,%edx
  800425:	b8 71 26 80 00       	mov    $0x802671,%eax
  80042a:	0f 45 c2             	cmovne %edx,%eax
  80042d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800430:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800434:	7e 06                	jle    80043c <vprintfmt+0x19b>
  800436:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80043a:	75 0d                	jne    800449 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80043f:	89 c7                	mov    %eax,%edi
  800441:	03 45 e0             	add    -0x20(%ebp),%eax
  800444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800447:	eb 55                	jmp    80049e <vprintfmt+0x1fd>
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 d8             	push   -0x28(%ebp)
  80044f:	ff 75 cc             	push   -0x34(%ebp)
  800452:	e8 0a 03 00 00       	call   800761 <strnlen>
  800457:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045a:	29 c1                	sub    %eax,%ecx
  80045c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800464:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800468:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	eb 0f                	jmp    80047c <vprintfmt+0x1db>
					putch(padc, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	ff 75 e0             	push   -0x20(%ebp)
  800474:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ef 01             	sub    $0x1,%edi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	85 ff                	test   %edi,%edi
  80047e:	7f ed                	jg     80046d <vprintfmt+0x1cc>
  800480:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800483:	85 d2                	test   %edx,%edx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c2             	cmovns %edx,%eax
  80048d:	29 c2                	sub    %eax,%edx
  80048f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800492:	eb a8                	jmp    80043c <vprintfmt+0x19b>
					putch(ch, putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	53                   	push   %ebx
  800498:	52                   	push   %edx
  800499:	ff d6                	call   *%esi
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a3:	83 c7 01             	add    $0x1,%edi
  8004a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004aa:	0f be d0             	movsbl %al,%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	74 4b                	je     8004fc <vprintfmt+0x25b>
  8004b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b5:	78 06                	js     8004bd <vprintfmt+0x21c>
  8004b7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004bb:	78 1e                	js     8004db <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c1:	74 d1                	je     800494 <vprintfmt+0x1f3>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 c6                	jbe    800494 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	6a 3f                	push   $0x3f
  8004d4:	ff d6                	call   *%esi
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	eb c3                	jmp    80049e <vprintfmt+0x1fd>
  8004db:	89 cf                	mov    %ecx,%edi
  8004dd:	eb 0e                	jmp    8004ed <vprintfmt+0x24c>
				putch(' ', putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	6a 20                	push   $0x20
  8004e5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ee                	jg     8004df <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f7:	e9 67 01 00 00       	jmp    800663 <vprintfmt+0x3c2>
  8004fc:	89 cf                	mov    %ecx,%edi
  8004fe:	eb ed                	jmp    8004ed <vprintfmt+0x24c>
	if (lflag >= 2)
  800500:	83 f9 01             	cmp    $0x1,%ecx
  800503:	7f 1b                	jg     800520 <vprintfmt+0x27f>
	else if (lflag)
  800505:	85 c9                	test   %ecx,%ecx
  800507:	74 63                	je     80056c <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800511:	99                   	cltd   
  800512:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 40 04             	lea    0x4(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	eb 17                	jmp    800537 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8b 50 04             	mov    0x4(%eax),%edx
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 08             	lea    0x8(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053d:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800542:	85 c9                	test   %ecx,%ecx
  800544:	0f 89 ff 00 00 00    	jns    800649 <vprintfmt+0x3a8>
				putch('-', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 2d                	push   $0x2d
  800550:	ff d6                	call   *%esi
				num = -(long long) num;
  800552:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800555:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800558:	f7 da                	neg    %edx
  80055a:	83 d1 00             	adc    $0x0,%ecx
  80055d:	f7 d9                	neg    %ecx
  80055f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800562:	bf 0a 00 00 00       	mov    $0xa,%edi
  800567:	e9 dd 00 00 00       	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	99                   	cltd   
  800575:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 40 04             	lea    0x4(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
  800581:	eb b4                	jmp    800537 <vprintfmt+0x296>
	if (lflag >= 2)
  800583:	83 f9 01             	cmp    $0x1,%ecx
  800586:	7f 1e                	jg     8005a6 <vprintfmt+0x305>
	else if (lflag)
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	74 32                	je     8005be <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	b9 00 00 00 00       	mov    $0x0,%ecx
  800596:	8d 40 04             	lea    0x4(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005a1:	e9 a3 00 00 00       	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ae:	8d 40 08             	lea    0x8(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005b9:	e9 8b 00 00 00       	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ce:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005d3:	eb 74                	jmp    800649 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005d5:	83 f9 01             	cmp    $0x1,%ecx
  8005d8:	7f 1b                	jg     8005f5 <vprintfmt+0x354>
	else if (lflag)
  8005da:	85 c9                	test   %ecx,%ecx
  8005dc:	74 2c                	je     80060a <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ee:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005f3:	eb 54                	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fd:	8d 40 08             	lea    0x8(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800603:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800608:	eb 3f                	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8b 10                	mov    (%eax),%edx
  80060f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800614:	8d 40 04             	lea    0x4(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80061a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80061f:	eb 28                	jmp    800649 <vprintfmt+0x3a8>
			putch('0', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 30                	push   $0x30
  800627:	ff d6                	call   *%esi
			putch('x', putdat);
  800629:	83 c4 08             	add    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 78                	push   $0x78
  80062f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80063e:	8d 40 04             	lea    0x4(%eax),%eax
  800641:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800644:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800650:	50                   	push   %eax
  800651:	ff 75 e0             	push   -0x20(%ebp)
  800654:	57                   	push   %edi
  800655:	51                   	push   %ecx
  800656:	52                   	push   %edx
  800657:	89 da                	mov    %ebx,%edx
  800659:	89 f0                	mov    %esi,%eax
  80065b:	e8 5e fb ff ff       	call   8001be <printnum>
			break;
  800660:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800666:	e9 54 fc ff ff       	jmp    8002bf <vprintfmt+0x1e>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7f 1b                	jg     80068b <vprintfmt+0x3ea>
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 2c                	je     8006a0 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800684:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800689:	eb be                	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	8b 48 04             	mov    0x4(%eax),%ecx
  800693:	8d 40 08             	lea    0x8(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800699:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80069e:	eb a9                	jmp    800649 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006aa:	8d 40 04             	lea    0x4(%eax),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006b5:	eb 92                	jmp    800649 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 25                	push   $0x25
  8006bd:	ff d6                	call   *%esi
			break;
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 9f                	jmp    800663 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 25                	push   $0x25
  8006ca:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	89 f8                	mov    %edi,%eax
  8006d1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006d5:	74 05                	je     8006dc <vprintfmt+0x43b>
  8006d7:	83 e8 01             	sub    $0x1,%eax
  8006da:	eb f5                	jmp    8006d1 <vprintfmt+0x430>
  8006dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006df:	eb 82                	jmp    800663 <vprintfmt+0x3c2>

008006e1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 18             	sub    $0x18,%esp
  8006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 26                	je     800728 <vsnprintf+0x47>
  800702:	85 d2                	test   %edx,%edx
  800704:	7e 22                	jle    800728 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800706:	ff 75 14             	push   0x14(%ebp)
  800709:	ff 75 10             	push   0x10(%ebp)
  80070c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070f:	50                   	push   %eax
  800710:	68 67 02 80 00       	push   $0x800267
  800715:	e8 87 fb ff ff       	call   8002a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800723:	83 c4 10             	add    $0x10,%esp
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    
		return -E_INVAL;
  800728:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072d:	eb f7                	jmp    800726 <vsnprintf+0x45>

0080072f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800738:	50                   	push   %eax
  800739:	ff 75 10             	push   0x10(%ebp)
  80073c:	ff 75 0c             	push   0xc(%ebp)
  80073f:	ff 75 08             	push   0x8(%ebp)
  800742:	e8 9a ff ff ff       	call   8006e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 03                	jmp    800759 <strlen+0x10>
		n++;
  800756:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800759:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075d:	75 f7                	jne    800756 <strlen+0xd>
	return n;
}
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	eb 03                	jmp    800774 <strnlen+0x13>
		n++;
  800771:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	39 d0                	cmp    %edx,%eax
  800776:	74 08                	je     800780 <strnlen+0x1f>
  800778:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077c:	75 f3                	jne    800771 <strnlen+0x10>
  80077e:	89 c2                	mov    %eax,%edx
	return n;
}
  800780:	89 d0                	mov    %edx,%eax
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800797:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80079a:	83 c0 01             	add    $0x1,%eax
  80079d:	84 d2                	test   %dl,%dl
  80079f:	75 f2                	jne    800793 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a1:	89 c8                	mov    %ecx,%eax
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 10             	sub    $0x10,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b2:	53                   	push   %ebx
  8007b3:	e8 91 ff ff ff       	call   800749 <strlen>
  8007b8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007bb:	ff 75 0c             	push   0xc(%ebp)
  8007be:	01 d8                	add    %ebx,%eax
  8007c0:	50                   	push   %eax
  8007c1:	e8 be ff ff ff       	call   800784 <strcpy>
	return dst;
}
  8007c6:	89 d8                	mov    %ebx,%eax
  8007c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d8:	89 f3                	mov    %esi,%ebx
  8007da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	eb 0f                	jmp    8007f0 <strncpy+0x23>
		*dst++ = *src;
  8007e1:	83 c0 01             	add    $0x1,%eax
  8007e4:	0f b6 0a             	movzbl (%edx),%ecx
  8007e7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ea:	80 f9 01             	cmp    $0x1,%cl
  8007ed:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007f0:	39 d8                	cmp    %ebx,%eax
  8007f2:	75 ed                	jne    8007e1 <strncpy+0x14>
	}
	return ret;
}
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	8b 55 10             	mov    0x10(%ebp),%edx
  800808:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080a:	85 d2                	test   %edx,%edx
  80080c:	74 21                	je     80082f <strlcpy+0x35>
  80080e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 09                	jmp    80081f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	83 c2 01             	add    $0x1,%edx
  80081c:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80081f:	39 c2                	cmp    %eax,%edx
  800821:	74 09                	je     80082c <strlcpy+0x32>
  800823:	0f b6 19             	movzbl (%ecx),%ebx
  800826:	84 db                	test   %bl,%bl
  800828:	75 ec                	jne    800816 <strlcpy+0x1c>
  80082a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80082c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082f:	29 f0                	sub    %esi,%eax
}
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083e:	eb 06                	jmp    800846 <strcmp+0x11>
		p++, q++;
  800840:	83 c1 01             	add    $0x1,%ecx
  800843:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800846:	0f b6 01             	movzbl (%ecx),%eax
  800849:	84 c0                	test   %al,%al
  80084b:	74 04                	je     800851 <strcmp+0x1c>
  80084d:	3a 02                	cmp    (%edx),%al
  80084f:	74 ef                	je     800840 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800851:	0f b6 c0             	movzbl %al,%eax
  800854:	0f b6 12             	movzbl (%edx),%edx
  800857:	29 d0                	sub    %edx,%eax
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	89 c3                	mov    %eax,%ebx
  800867:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086a:	eb 06                	jmp    800872 <strncmp+0x17>
		n--, p++, q++;
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800872:	39 d8                	cmp    %ebx,%eax
  800874:	74 18                	je     80088e <strncmp+0x33>
  800876:	0f b6 08             	movzbl (%eax),%ecx
  800879:	84 c9                	test   %cl,%cl
  80087b:	74 04                	je     800881 <strncmp+0x26>
  80087d:	3a 0a                	cmp    (%edx),%cl
  80087f:	74 eb                	je     80086c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800881:	0f b6 00             	movzbl (%eax),%eax
  800884:	0f b6 12             	movzbl (%edx),%edx
  800887:	29 d0                	sub    %edx,%eax
}
  800889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    
		return 0;
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	eb f4                	jmp    800889 <strncmp+0x2e>

00800895 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089f:	eb 03                	jmp    8008a4 <strchr+0xf>
  8008a1:	83 c0 01             	add    $0x1,%eax
  8008a4:	0f b6 10             	movzbl (%eax),%edx
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	74 06                	je     8008b1 <strchr+0x1c>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	75 f2                	jne    8008a1 <strchr+0xc>
  8008af:	eb 05                	jmp    8008b6 <strchr+0x21>
			return (char *) s;
	return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c5:	38 ca                	cmp    %cl,%dl
  8008c7:	74 09                	je     8008d2 <strfind+0x1a>
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	74 05                	je     8008d2 <strfind+0x1a>
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	eb f0                	jmp    8008c2 <strfind+0xa>
			break;
	return (char *) s;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 2f                	je     800913 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	09 c8                	or     %ecx,%eax
  8008e8:	a8 03                	test   $0x3,%al
  8008ea:	75 21                	jne    80090d <memset+0x39>
		c &= 0xFF;
  8008ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	c1 e0 08             	shl    $0x8,%eax
  8008f5:	89 d3                	mov    %edx,%ebx
  8008f7:	c1 e3 18             	shl    $0x18,%ebx
  8008fa:	89 d6                	mov    %edx,%esi
  8008fc:	c1 e6 10             	shl    $0x10,%esi
  8008ff:	09 f3                	or     %esi,%ebx
  800901:	09 da                	or     %ebx,%edx
  800903:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800905:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800908:	fc                   	cld    
  800909:	f3 ab                	rep stos %eax,%es:(%edi)
  80090b:	eb 06                	jmp    800913 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 f8                	mov    %edi,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 75 0c             	mov    0xc(%ebp),%esi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800928:	39 c6                	cmp    %eax,%esi
  80092a:	73 32                	jae    80095e <memmove+0x44>
  80092c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092f:	39 c2                	cmp    %eax,%edx
  800931:	76 2b                	jbe    80095e <memmove+0x44>
		s += n;
		d += n;
  800933:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 d6                	mov    %edx,%esi
  800938:	09 fe                	or     %edi,%esi
  80093a:	09 ce                	or     %ecx,%esi
  80093c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800942:	75 0e                	jne    800952 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800944:	83 ef 04             	sub    $0x4,%edi
  800947:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80094d:	fd                   	std    
  80094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800950:	eb 09                	jmp    80095b <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800952:	83 ef 01             	sub    $0x1,%edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 1a                	jmp    800978 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	89 f2                	mov    %esi,%edx
  800960:	09 c2                	or     %eax,%edx
  800962:	09 ca                	or     %ecx,%edx
  800964:	f6 c2 03             	test   $0x3,%dl
  800967:	75 0a                	jne    800973 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800969:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 05                	jmp    800978 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800973:	89 c7                	mov    %eax,%edi
  800975:	fc                   	cld    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800982:	ff 75 10             	push   0x10(%ebp)
  800985:	ff 75 0c             	push   0xc(%ebp)
  800988:	ff 75 08             	push   0x8(%ebp)
  80098b:	e8 8a ff ff ff       	call   80091a <memmove>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 c6                	mov    %eax,%esi
  80099f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a2:	eb 06                	jmp    8009aa <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009aa:	39 f0                	cmp    %esi,%eax
  8009ac:	74 14                	je     8009c2 <memcmp+0x30>
		if (*s1 != *s2)
  8009ae:	0f b6 08             	movzbl (%eax),%ecx
  8009b1:	0f b6 1a             	movzbl (%edx),%ebx
  8009b4:	38 d9                	cmp    %bl,%cl
  8009b6:	74 ec                	je     8009a4 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009b8:	0f b6 c1             	movzbl %cl,%eax
  8009bb:	0f b6 db             	movzbl %bl,%ebx
  8009be:	29 d8                	sub    %ebx,%eax
  8009c0:	eb 05                	jmp    8009c7 <memcmp+0x35>
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d4:	89 c2                	mov    %eax,%edx
  8009d6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d9:	eb 03                	jmp    8009de <memfind+0x13>
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	73 04                	jae    8009e6 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e2:	38 08                	cmp    %cl,(%eax)
  8009e4:	75 f5                	jne    8009db <memfind+0x10>
			break;
	return (void *) s;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f4:	eb 03                	jmp    8009f9 <strtol+0x11>
		s++;
  8009f6:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009f9:	0f b6 02             	movzbl (%edx),%eax
  8009fc:	3c 20                	cmp    $0x20,%al
  8009fe:	74 f6                	je     8009f6 <strtol+0xe>
  800a00:	3c 09                	cmp    $0x9,%al
  800a02:	74 f2                	je     8009f6 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a04:	3c 2b                	cmp    $0x2b,%al
  800a06:	74 2a                	je     800a32 <strtol+0x4a>
	int neg = 0;
  800a08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a0d:	3c 2d                	cmp    $0x2d,%al
  800a0f:	74 2b                	je     800a3c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a11:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a17:	75 0f                	jne    800a28 <strtol+0x40>
  800a19:	80 3a 30             	cmpb   $0x30,(%edx)
  800a1c:	74 28                	je     800a46 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1e:	85 db                	test   %ebx,%ebx
  800a20:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a25:	0f 44 d8             	cmove  %eax,%ebx
  800a28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a30:	eb 46                	jmp    800a78 <strtol+0x90>
		s++;
  800a32:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a35:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3a:	eb d5                	jmp    800a11 <strtol+0x29>
		s++, neg = 1;
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a44:	eb cb                	jmp    800a11 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a46:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4a:	74 0e                	je     800a5a <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	75 d8                	jne    800a28 <strtol+0x40>
		s++, base = 8;
  800a50:	83 c2 01             	add    $0x1,%edx
  800a53:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a58:	eb ce                	jmp    800a28 <strtol+0x40>
		s += 2, base = 16;
  800a5a:	83 c2 02             	add    $0x2,%edx
  800a5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a62:	eb c4                	jmp    800a28 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a64:	0f be c0             	movsbl %al,%eax
  800a67:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6a:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a6d:	7d 3a                	jge    800aa9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a6f:	83 c2 01             	add    $0x1,%edx
  800a72:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a76:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a78:	0f b6 02             	movzbl (%edx),%eax
  800a7b:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 09             	cmp    $0x9,%bl
  800a83:	76 df                	jbe    800a64 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a8f:	0f be c0             	movsbl %al,%eax
  800a92:	83 e8 57             	sub    $0x57,%eax
  800a95:	eb d3                	jmp    800a6a <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a97:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aa1:	0f be c0             	movsbl %al,%eax
  800aa4:	83 e8 37             	sub    $0x37,%eax
  800aa7:	eb c1                	jmp    800a6a <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aad:	74 05                	je     800ab4 <strtol+0xcc>
		*endptr = (char *) s;
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ab4:	89 c8                	mov    %ecx,%eax
  800ab6:	f7 d8                	neg    %eax
  800ab8:	85 ff                	test   %edi,%edi
  800aba:	0f 45 c8             	cmovne %eax,%ecx
}
  800abd:	89 c8                	mov    %ecx,%eax
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	b8 03 00 00 00       	mov    $0x3,%eax
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7f 08                	jg     800b2b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 03                	push   $0x3
  800b31:	68 5f 29 80 00       	push   $0x80295f
  800b36:	6a 2a                	push   $0x2a
  800b38:	68 7c 29 80 00       	push   $0x80297c
  800b3d:	e8 1c 16 00 00       	call   80215e <_panic>

00800b42 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_yield>:

void
sys_yield(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b89:	be 00 00 00 00       	mov    $0x0,%esi
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	b8 04 00 00 00       	mov    $0x4,%eax
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	89 f7                	mov    %esi,%edi
  800b9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7f 08                	jg     800bac <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800bb0:	6a 04                	push   $0x4
  800bb2:	68 5f 29 80 00       	push   $0x80295f
  800bb7:	6a 2a                	push   $0x2a
  800bb9:	68 7c 29 80 00       	push   $0x80297c
  800bbe:	e8 9b 15 00 00       	call   80215e <_panic>

00800bc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 75 18             	mov    0x18(%ebp),%esi
  800be0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7f 08                	jg     800bee <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 05                	push   $0x5
  800bf4:	68 5f 29 80 00       	push   $0x80295f
  800bf9:	6a 2a                	push   $0x2a
  800bfb:	68 7c 29 80 00       	push   $0x80297c
  800c00:	e8 59 15 00 00       	call   80215e <_panic>

00800c05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7f 08                	jg     800c30 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 06                	push   $0x6
  800c36:	68 5f 29 80 00       	push   $0x80295f
  800c3b:	6a 2a                	push   $0x2a
  800c3d:	68 7c 29 80 00       	push   $0x80297c
  800c42:	e8 17 15 00 00       	call   80215e <_panic>

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7f 08                	jg     800c72 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 08                	push   $0x8
  800c78:	68 5f 29 80 00       	push   $0x80295f
  800c7d:	6a 2a                	push   $0x2a
  800c7f:	68 7c 29 80 00       	push   $0x80297c
  800c84:	e8 d5 14 00 00       	call   80215e <_panic>

00800c89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 09                	push   $0x9
  800cba:	68 5f 29 80 00       	push   $0x80295f
  800cbf:	6a 2a                	push   $0x2a
  800cc1:	68 7c 29 80 00       	push   $0x80297c
  800cc6:	e8 93 14 00 00       	call   80215e <_panic>

00800ccb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800cfa:	6a 0a                	push   $0xa
  800cfc:	68 5f 29 80 00       	push   $0x80295f
  800d01:	6a 2a                	push   $0x2a
  800d03:	68 7c 29 80 00       	push   $0x80297c
  800d08:	e8 51 14 00 00       	call   80215e <_panic>

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1e:	be 00 00 00 00       	mov    $0x0,%esi
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	89 ce                	mov    %ecx,%esi
  800d4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	7f 08                	jg     800d5a <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	50                   	push   %eax
  800d5e:	6a 0d                	push   $0xd
  800d60:	68 5f 29 80 00       	push   $0x80295f
  800d65:	6a 2a                	push   $0x2a
  800d67:	68 7c 29 80 00       	push   $0x80297c
  800d6c:	e8 ed 13 00 00       	call   80215e <_panic>

00800d71 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d81:	89 d1                	mov    %edx,%ecx
  800d83:	89 d3                	mov    %edx,%ebx
  800d85:	89 d7                	mov    %edx,%edi
  800d87:	89 d6                	mov    %edx,%esi
  800d89:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dda:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ddc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de0:	0f 84 8e 00 00 00    	je     800e74 <pgfault+0xa2>
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	c1 e8 0c             	shr    $0xc,%eax
  800deb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df2:	f6 c4 08             	test   $0x8,%ah
  800df5:	74 7d                	je     800e74 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800df7:	e8 46 fd ff ff       	call   800b42 <sys_getenvid>
  800dfc:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800dfe:	83 ec 04             	sub    $0x4,%esp
  800e01:	6a 07                	push   $0x7
  800e03:	68 00 f0 7f 00       	push   $0x7ff000
  800e08:	50                   	push   %eax
  800e09:	e8 72 fd ff ff       	call   800b80 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	78 73                	js     800e88 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e15:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	68 00 10 00 00       	push   $0x1000
  800e23:	56                   	push   %esi
  800e24:	68 00 f0 7f 00       	push   $0x7ff000
  800e29:	e8 ec fa ff ff       	call   80091a <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e2e:	83 c4 08             	add    $0x8,%esp
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	e8 cd fd ff ff       	call   800c05 <sys_page_unmap>
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	78 5b                	js     800e9a <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	6a 07                	push   $0x7
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	68 00 f0 7f 00       	push   $0x7ff000
  800e4b:	53                   	push   %ebx
  800e4c:	e8 72 fd ff ff       	call   800bc3 <sys_page_map>
  800e51:	83 c4 20             	add    $0x20,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	78 54                	js     800eac <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	68 00 f0 7f 00       	push   $0x7ff000
  800e60:	53                   	push   %ebx
  800e61:	e8 9f fd ff ff       	call   800c05 <sys_page_unmap>
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 51                	js     800ebe <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	68 8c 29 80 00       	push   $0x80298c
  800e7c:	6a 1d                	push   $0x1d
  800e7e:	68 08 2a 80 00       	push   $0x802a08
  800e83:	e8 d6 12 00 00       	call   80215e <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e88:	50                   	push   %eax
  800e89:	68 c4 29 80 00       	push   $0x8029c4
  800e8e:	6a 29                	push   $0x29
  800e90:	68 08 2a 80 00       	push   $0x802a08
  800e95:	e8 c4 12 00 00       	call   80215e <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e9a:	50                   	push   %eax
  800e9b:	68 e8 29 80 00       	push   $0x8029e8
  800ea0:	6a 2e                	push   $0x2e
  800ea2:	68 08 2a 80 00       	push   $0x802a08
  800ea7:	e8 b2 12 00 00       	call   80215e <_panic>
		panic("pgfault: page map failed (%e)", r);
  800eac:	50                   	push   %eax
  800ead:	68 13 2a 80 00       	push   $0x802a13
  800eb2:	6a 30                	push   $0x30
  800eb4:	68 08 2a 80 00       	push   $0x802a08
  800eb9:	e8 a0 12 00 00       	call   80215e <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 e8 29 80 00       	push   $0x8029e8
  800ec4:	6a 32                	push   $0x32
  800ec6:	68 08 2a 80 00       	push   $0x802a08
  800ecb:	e8 8e 12 00 00       	call   80215e <_panic>

00800ed0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ed9:	68 d2 0d 80 00       	push   $0x800dd2
  800ede:	e8 c1 12 00 00       	call   8021a4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee3:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee8:	cd 30                	int    $0x30
  800eea:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 2d                	js     800f21 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ef4:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ef9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800efd:	75 73                	jne    800f72 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eff:	e8 3e fc ff ff       	call   800b42 <sys_getenvid>
  800f04:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f09:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f0c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f11:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f16:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f21:	50                   	push   %eax
  800f22:	68 31 2a 80 00       	push   $0x802a31
  800f27:	6a 78                	push   $0x78
  800f29:	68 08 2a 80 00       	push   $0x802a08
  800f2e:	e8 2b 12 00 00       	call   80215e <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f33:	83 ec 0c             	sub    $0xc,%esp
  800f36:	ff 75 e4             	push   -0x1c(%ebp)
  800f39:	57                   	push   %edi
  800f3a:	ff 75 dc             	push   -0x24(%ebp)
  800f3d:	57                   	push   %edi
  800f3e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f41:	56                   	push   %esi
  800f42:	e8 7c fc ff ff       	call   800bc3 <sys_page_map>
	if(r<0) return r;
  800f47:	83 c4 20             	add    $0x20,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	78 cb                	js     800f19 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	ff 75 e4             	push   -0x1c(%ebp)
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	e8 66 fc ff ff       	call   800bc3 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 76                	js     800fda <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f64:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f6a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f70:	74 75                	je     800fe7 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f72:	89 d8                	mov    %ebx,%eax
  800f74:	c1 e8 16             	shr    $0x16,%eax
  800f77:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7e:	a8 01                	test   $0x1,%al
  800f80:	74 e2                	je     800f64 <fork+0x94>
  800f82:	89 de                	mov    %ebx,%esi
  800f84:	c1 ee 0c             	shr    $0xc,%esi
  800f87:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f8e:	a8 01                	test   $0x1,%al
  800f90:	74 d2                	je     800f64 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800f92:	e8 ab fb ff ff       	call   800b42 <sys_getenvid>
  800f97:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800f9a:	89 f7                	mov    %esi,%edi
  800f9c:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800f9f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa6:	89 c1                	mov    %eax,%ecx
  800fa8:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fb1:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fb8:	f6 c6 04             	test   $0x4,%dh
  800fbb:	0f 85 72 ff ff ff    	jne    800f33 <fork+0x63>
		perm &= ~PTE_W;
  800fc1:	25 05 0e 00 00       	and    $0xe05,%eax
  800fc6:	80 cc 08             	or     $0x8,%ah
  800fc9:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800fcf:	0f 44 c1             	cmove  %ecx,%eax
  800fd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fd5:	e9 59 ff ff ff       	jmp    800f33 <fork+0x63>
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	0f 4f c2             	cmovg  %edx,%eax
  800fe2:	e9 32 ff ff ff       	jmp    800f19 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800fe7:	83 ec 04             	sub    $0x4,%esp
  800fea:	6a 07                	push   $0x7
  800fec:	68 00 f0 bf ee       	push   $0xeebff000
  800ff1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ff4:	57                   	push   %edi
  800ff5:	e8 86 fb ff ff       	call   800b80 <sys_page_alloc>
	if(r<0) return r;
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	0f 88 14 ff ff ff    	js     800f19 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	68 1a 22 80 00       	push   $0x80221a
  80100d:	57                   	push   %edi
  80100e:	e8 b8 fc ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 88 fb fe ff ff    	js     800f19 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	6a 02                	push   $0x2
  801023:	57                   	push   %edi
  801024:	e8 1e fc ff ff       	call   800c47 <sys_env_set_status>
	if(r<0) return r;
  801029:	83 c4 10             	add    $0x10,%esp
	return envid;
  80102c:	85 c0                	test   %eax,%eax
  80102e:	0f 49 c7             	cmovns %edi,%eax
  801031:	e9 e3 fe ff ff       	jmp    800f19 <fork+0x49>

00801036 <sfork>:

// Challenge!
int
sfork(void)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103c:	68 41 2a 80 00       	push   $0x802a41
  801041:	68 a1 00 00 00       	push   $0xa1
  801046:	68 08 2a 80 00       	push   $0x802a08
  80104b:	e8 0e 11 00 00       	call   80215e <_panic>

00801050 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80106b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801070:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80107f:	89 c2                	mov    %eax,%edx
  801081:	c1 ea 16             	shr    $0x16,%edx
  801084:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108b:	f6 c2 01             	test   $0x1,%dl
  80108e:	74 29                	je     8010b9 <fd_alloc+0x42>
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 0c             	shr    $0xc,%edx
  801095:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 18                	je     8010b9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010a1:	05 00 10 00 00       	add    $0x1000,%eax
  8010a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ab:	75 d2                	jne    80107f <fd_alloc+0x8>
  8010ad:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8010b2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8010b7:	eb 05                	jmp    8010be <fd_alloc+0x47>
			return 0;
  8010b9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	89 02                	mov    %eax,(%edx)
}
  8010c3:	89 c8                	mov    %ecx,%eax
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cd:	83 f8 1f             	cmp    $0x1f,%eax
  8010d0:	77 30                	ja     801102 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d2:	c1 e0 0c             	shl    $0xc,%eax
  8010d5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010da:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	74 24                	je     801109 <fd_lookup+0x42>
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	c1 ea 0c             	shr    $0xc,%edx
  8010ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f1:	f6 c2 01             	test   $0x1,%dl
  8010f4:	74 1a                	je     801110 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    
		return -E_INVAL;
  801102:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801107:	eb f7                	jmp    801100 <fd_lookup+0x39>
		return -E_INVAL;
  801109:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110e:	eb f0                	jmp    801100 <fd_lookup+0x39>
  801110:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801115:	eb e9                	jmp    801100 <fd_lookup+0x39>

00801117 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	53                   	push   %ebx
  80111b:	83 ec 04             	sub    $0x4,%esp
  80111e:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801121:	b8 00 00 00 00       	mov    $0x0,%eax
  801126:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80112b:	39 13                	cmp    %edx,(%ebx)
  80112d:	74 37                	je     801166 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80112f:	83 c0 01             	add    $0x1,%eax
  801132:	8b 1c 85 d4 2a 80 00 	mov    0x802ad4(,%eax,4),%ebx
  801139:	85 db                	test   %ebx,%ebx
  80113b:	75 ee                	jne    80112b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80113d:	a1 00 40 80 00       	mov    0x804000,%eax
  801142:	8b 40 48             	mov    0x48(%eax),%eax
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	52                   	push   %edx
  801149:	50                   	push   %eax
  80114a:	68 58 2a 80 00       	push   $0x802a58
  80114f:	e8 56 f0 ff ff       	call   8001aa <cprintf>
	*dev = 0;
	return -E_INVAL;
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80115c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115f:	89 1a                	mov    %ebx,(%edx)
}
  801161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801164:	c9                   	leave  
  801165:	c3                   	ret    
			return 0;
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
  80116b:	eb ef                	jmp    80115c <dev_lookup+0x45>

0080116d <fd_close>:
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 24             	sub    $0x24,%esp
  801176:	8b 75 08             	mov    0x8(%ebp),%esi
  801179:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80117f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801180:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801186:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801189:	50                   	push   %eax
  80118a:	e8 38 ff ff ff       	call   8010c7 <fd_lookup>
  80118f:	89 c3                	mov    %eax,%ebx
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 05                	js     80119d <fd_close+0x30>
	    || fd != fd2)
  801198:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80119b:	74 16                	je     8011b3 <fd_close+0x46>
		return (must_exist ? r : 0);
  80119d:	89 f8                	mov    %edi,%eax
  80119f:	84 c0                	test   %al,%al
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a6:	0f 44 d8             	cmove  %eax,%ebx
}
  8011a9:	89 d8                	mov    %ebx,%eax
  8011ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5f                   	pop    %edi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 36                	push   (%esi)
  8011bc:	e8 56 ff ff ff       	call   801117 <dev_lookup>
  8011c1:	89 c3                	mov    %eax,%ebx
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 1a                	js     8011e4 <fd_close+0x77>
		if (dev->dev_close)
  8011ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	74 0b                	je     8011e4 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	56                   	push   %esi
  8011dd:	ff d0                	call   *%eax
  8011df:	89 c3                	mov    %eax,%ebx
  8011e1:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	6a 00                	push   $0x0
  8011ea:	e8 16 fa ff ff       	call   800c05 <sys_page_unmap>
	return r;
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	eb b5                	jmp    8011a9 <fd_close+0x3c>

008011f4 <close>:

int
close(int fdnum)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 08             	push   0x8(%ebp)
  801201:	e8 c1 fe ff ff       	call   8010c7 <fd_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	79 02                	jns    80120f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    
		return fd_close(fd, 1);
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	6a 01                	push   $0x1
  801214:	ff 75 f4             	push   -0xc(%ebp)
  801217:	e8 51 ff ff ff       	call   80116d <fd_close>
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	eb ec                	jmp    80120d <close+0x19>

00801221 <close_all>:

void
close_all(void)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	53                   	push   %ebx
  801225:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	53                   	push   %ebx
  801231:	e8 be ff ff ff       	call   8011f4 <close>
	for (i = 0; i < MAXFD; i++)
  801236:	83 c3 01             	add    $0x1,%ebx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	83 fb 20             	cmp    $0x20,%ebx
  80123f:	75 ec                	jne    80122d <close_all+0xc>
}
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	57                   	push   %edi
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	ff 75 08             	push   0x8(%ebp)
  801256:	e8 6c fe ff ff       	call   8010c7 <fd_lookup>
  80125b:	89 c3                	mov    %eax,%ebx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 7f                	js     8012e3 <dup+0x9d>
		return r;
	close(newfdnum);
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	ff 75 0c             	push   0xc(%ebp)
  80126a:	e8 85 ff ff ff       	call   8011f4 <close>

	newfd = INDEX2FD(newfdnum);
  80126f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801272:	c1 e6 0c             	shl    $0xc,%esi
  801275:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80127b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80127e:	89 3c 24             	mov    %edi,(%esp)
  801281:	e8 da fd ff ff       	call   801060 <fd2data>
  801286:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801288:	89 34 24             	mov    %esi,(%esp)
  80128b:	e8 d0 fd ff ff       	call   801060 <fd2data>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801296:	89 d8                	mov    %ebx,%eax
  801298:	c1 e8 16             	shr    $0x16,%eax
  80129b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a2:	a8 01                	test   $0x1,%al
  8012a4:	74 11                	je     8012b7 <dup+0x71>
  8012a6:	89 d8                	mov    %ebx,%eax
  8012a8:	c1 e8 0c             	shr    $0xc,%eax
  8012ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	75 36                	jne    8012ed <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b7:	89 f8                	mov    %edi,%eax
  8012b9:	c1 e8 0c             	shr    $0xc,%eax
  8012bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cb:	50                   	push   %eax
  8012cc:	56                   	push   %esi
  8012cd:	6a 00                	push   $0x0
  8012cf:	57                   	push   %edi
  8012d0:	6a 00                	push   $0x0
  8012d2:	e8 ec f8 ff ff       	call   800bc3 <sys_page_map>
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 20             	add    $0x20,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 33                	js     801313 <dup+0xcd>
		goto err;

	return newfdnum;
  8012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012e3:	89 d8                	mov    %ebx,%eax
  8012e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f4:	83 ec 0c             	sub    $0xc,%esp
  8012f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 d4             	push   -0x2c(%ebp)
  801300:	6a 00                	push   $0x0
  801302:	53                   	push   %ebx
  801303:	6a 00                	push   $0x0
  801305:	e8 b9 f8 ff ff       	call   800bc3 <sys_page_map>
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	83 c4 20             	add    $0x20,%esp
  80130f:	85 c0                	test   %eax,%eax
  801311:	79 a4                	jns    8012b7 <dup+0x71>
	sys_page_unmap(0, newfd);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	56                   	push   %esi
  801317:	6a 00                	push   $0x0
  801319:	e8 e7 f8 ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131e:	83 c4 08             	add    $0x8,%esp
  801321:	ff 75 d4             	push   -0x2c(%ebp)
  801324:	6a 00                	push   $0x0
  801326:	e8 da f8 ff ff       	call   800c05 <sys_page_unmap>
	return r;
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	eb b3                	jmp    8012e3 <dup+0x9d>

00801330 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	56                   	push   %esi
  801334:	53                   	push   %ebx
  801335:	83 ec 18             	sub    $0x18,%esp
  801338:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	56                   	push   %esi
  801340:	e8 82 fd ff ff       	call   8010c7 <fd_lookup>
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 3c                	js     801388 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	ff 33                	push   (%ebx)
  801358:	e8 ba fd ff ff       	call   801117 <dev_lookup>
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	78 24                	js     801388 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801364:	8b 43 08             	mov    0x8(%ebx),%eax
  801367:	83 e0 03             	and    $0x3,%eax
  80136a:	83 f8 01             	cmp    $0x1,%eax
  80136d:	74 20                	je     80138f <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	8b 40 08             	mov    0x8(%eax),%eax
  801375:	85 c0                	test   %eax,%eax
  801377:	74 37                	je     8013b0 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801379:	83 ec 04             	sub    $0x4,%esp
  80137c:	ff 75 10             	push   0x10(%ebp)
  80137f:	ff 75 0c             	push   0xc(%ebp)
  801382:	53                   	push   %ebx
  801383:	ff d0                	call   *%eax
  801385:	83 c4 10             	add    $0x10,%esp
}
  801388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138f:	a1 00 40 80 00       	mov    0x804000,%eax
  801394:	8b 40 48             	mov    0x48(%eax),%eax
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	56                   	push   %esi
  80139b:	50                   	push   %eax
  80139c:	68 99 2a 80 00       	push   $0x802a99
  8013a1:	e8 04 ee ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ae:	eb d8                	jmp    801388 <read+0x58>
		return -E_NOT_SUPP;
  8013b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013b5:	eb d1                	jmp    801388 <read+0x58>

008013b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	57                   	push   %edi
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cb:	eb 02                	jmp    8013cf <readn+0x18>
  8013cd:	01 c3                	add    %eax,%ebx
  8013cf:	39 f3                	cmp    %esi,%ebx
  8013d1:	73 21                	jae    8013f4 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	89 f0                	mov    %esi,%eax
  8013d8:	29 d8                	sub    %ebx,%eax
  8013da:	50                   	push   %eax
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	03 45 0c             	add    0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	57                   	push   %edi
  8013e2:	e8 49 ff ff ff       	call   801330 <read>
		if (m < 0)
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 04                	js     8013f2 <readn+0x3b>
			return m;
		if (m == 0)
  8013ee:	75 dd                	jne    8013cd <readn+0x16>
  8013f0:	eb 02                	jmp    8013f4 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f2:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8013f4:	89 d8                	mov    %ebx,%eax
  8013f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5f                   	pop    %edi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 18             	sub    $0x18,%esp
  801406:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801409:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	53                   	push   %ebx
  80140e:	e8 b4 fc ff ff       	call   8010c7 <fd_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 37                	js     801451 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	ff 36                	push   (%esi)
  801426:	e8 ec fc ff ff       	call   801117 <dev_lookup>
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 1f                	js     801451 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801432:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801436:	74 20                	je     801458 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801438:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143b:	8b 40 0c             	mov    0xc(%eax),%eax
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 37                	je     801479 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	ff 75 10             	push   0x10(%ebp)
  801448:	ff 75 0c             	push   0xc(%ebp)
  80144b:	56                   	push   %esi
  80144c:	ff d0                	call   *%eax
  80144e:	83 c4 10             	add    $0x10,%esp
}
  801451:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801458:	a1 00 40 80 00       	mov    0x804000,%eax
  80145d:	8b 40 48             	mov    0x48(%eax),%eax
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	53                   	push   %ebx
  801464:	50                   	push   %eax
  801465:	68 b5 2a 80 00       	push   $0x802ab5
  80146a:	e8 3b ed ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801477:	eb d8                	jmp    801451 <write+0x53>
		return -E_NOT_SUPP;
  801479:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80147e:	eb d1                	jmp    801451 <write+0x53>

00801480 <seek>:

int
seek(int fdnum, off_t offset)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	ff 75 08             	push   0x8(%ebp)
  80148d:	e8 35 fc ff ff       	call   8010c7 <fd_lookup>
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 0e                	js     8014a7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801499:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 18             	sub    $0x18,%esp
  8014b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	53                   	push   %ebx
  8014b9:	e8 09 fc ff ff       	call   8010c7 <fd_lookup>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 34                	js     8014f9 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	ff 36                	push   (%esi)
  8014d1:	e8 41 fc ff ff       	call   801117 <dev_lookup>
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 1c                	js     8014f9 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014dd:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014e1:	74 1d                	je     801500 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8014e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e6:	8b 40 18             	mov    0x18(%eax),%eax
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	74 34                	je     801521 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	ff 75 0c             	push   0xc(%ebp)
  8014f3:	56                   	push   %esi
  8014f4:	ff d0                	call   *%eax
  8014f6:	83 c4 10             	add    $0x10,%esp
}
  8014f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5e                   	pop    %esi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    
			thisenv->env_id, fdnum);
  801500:	a1 00 40 80 00       	mov    0x804000,%eax
  801505:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	53                   	push   %ebx
  80150c:	50                   	push   %eax
  80150d:	68 78 2a 80 00       	push   $0x802a78
  801512:	e8 93 ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151f:	eb d8                	jmp    8014f9 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801521:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801526:	eb d1                	jmp    8014f9 <ftruncate+0x50>

00801528 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 18             	sub    $0x18,%esp
  801530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801533:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	ff 75 08             	push   0x8(%ebp)
  80153a:	e8 88 fb ff ff       	call   8010c7 <fd_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 49                	js     80158f <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801546:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	ff 36                	push   (%esi)
  801552:	e8 c0 fb ff ff       	call   801117 <dev_lookup>
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 31                	js     80158f <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801565:	74 2f                	je     801596 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801567:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80156a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801571:	00 00 00 
	stat->st_isdir = 0;
  801574:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80157b:	00 00 00 
	stat->st_dev = dev;
  80157e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	53                   	push   %ebx
  801588:	56                   	push   %esi
  801589:	ff 50 14             	call   *0x14(%eax)
  80158c:	83 c4 10             	add    $0x10,%esp
}
  80158f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    
		return -E_NOT_SUPP;
  801596:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80159b:	eb f2                	jmp    80158f <fstat+0x67>

0080159d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	56                   	push   %esi
  8015a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	6a 00                	push   $0x0
  8015a7:	ff 75 08             	push   0x8(%ebp)
  8015aa:	e8 e4 01 00 00       	call   801793 <open>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 1b                	js     8015d3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	ff 75 0c             	push   0xc(%ebp)
  8015be:	50                   	push   %eax
  8015bf:	e8 64 ff ff ff       	call   801528 <fstat>
  8015c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8015c6:	89 1c 24             	mov    %ebx,(%esp)
  8015c9:	e8 26 fc ff ff       	call   8011f4 <close>
	return r;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	89 f3                	mov    %esi,%ebx
}
  8015d3:	89 d8                	mov    %ebx,%eax
  8015d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	89 c6                	mov    %eax,%esi
  8015e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8015ec:	74 27                	je     801615 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ee:	6a 07                	push   $0x7
  8015f0:	68 00 50 80 00       	push   $0x805000
  8015f5:	56                   	push   %esi
  8015f6:	ff 35 00 60 80 00    	push   0x806000
  8015fc:	e8 a6 0c 00 00       	call   8022a7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801601:	83 c4 0c             	add    $0xc,%esp
  801604:	6a 00                	push   $0x0
  801606:	53                   	push   %ebx
  801607:	6a 00                	push   $0x0
  801609:	e8 32 0c 00 00       	call   802240 <ipc_recv>
}
  80160e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	6a 01                	push   $0x1
  80161a:	e8 dc 0c 00 00       	call   8022fb <ipc_find_env>
  80161f:	a3 00 60 80 00       	mov    %eax,0x806000
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb c5                	jmp    8015ee <fsipc+0x12>

00801629 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80162f:	8b 45 08             	mov    0x8(%ebp),%eax
  801632:	8b 40 0c             	mov    0xc(%eax),%eax
  801635:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 02 00 00 00       	mov    $0x2,%eax
  80164c:	e8 8b ff ff ff       	call   8015dc <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devfile_flush>:
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	8b 40 0c             	mov    0xc(%eax),%eax
  80165f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 06 00 00 00       	mov    $0x6,%eax
  80166e:	e8 69 ff ff ff       	call   8015dc <fsipc>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <devfile_stat>:
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 40 0c             	mov    0xc(%eax),%eax
  801685:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 05 00 00 00       	mov    $0x5,%eax
  801694:	e8 43 ff ff ff       	call   8015dc <fsipc>
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 2c                	js     8016c9 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	68 00 50 80 00       	push   $0x805000
  8016a5:	53                   	push   %ebx
  8016a6:	e8 d9 f0 ff ff       	call   800784 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8016bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_write>:
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016dc:	39 d0                	cmp    %edx,%eax
  8016de:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016ed:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016f2:	50                   	push   %eax
  8016f3:	ff 75 0c             	push   0xc(%ebp)
  8016f6:	68 08 50 80 00       	push   $0x805008
  8016fb:	e8 1a f2 ff ff       	call   80091a <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	b8 04 00 00 00       	mov    $0x4,%eax
  80170a:	e8 cd fe ff ff       	call   8015dc <fsipc>
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <devfile_read>:
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801724:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172a:	ba 00 00 00 00       	mov    $0x0,%edx
  80172f:	b8 03 00 00 00       	mov    $0x3,%eax
  801734:	e8 a3 fe ff ff       	call   8015dc <fsipc>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 1f                	js     80175e <devfile_read+0x4d>
	assert(r <= n);
  80173f:	39 f0                	cmp    %esi,%eax
  801741:	77 24                	ja     801767 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801743:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801748:	7f 33                	jg     80177d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	50                   	push   %eax
  80174e:	68 00 50 80 00       	push   $0x805000
  801753:	ff 75 0c             	push   0xc(%ebp)
  801756:	e8 bf f1 ff ff       	call   80091a <memmove>
	return r;
  80175b:	83 c4 10             	add    $0x10,%esp
}
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    
	assert(r <= n);
  801767:	68 e8 2a 80 00       	push   $0x802ae8
  80176c:	68 ef 2a 80 00       	push   $0x802aef
  801771:	6a 7c                	push   $0x7c
  801773:	68 04 2b 80 00       	push   $0x802b04
  801778:	e8 e1 09 00 00       	call   80215e <_panic>
	assert(r <= PGSIZE);
  80177d:	68 0f 2b 80 00       	push   $0x802b0f
  801782:	68 ef 2a 80 00       	push   $0x802aef
  801787:	6a 7d                	push   $0x7d
  801789:	68 04 2b 80 00       	push   $0x802b04
  80178e:	e8 cb 09 00 00       	call   80215e <_panic>

00801793 <open>:
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
  801798:	83 ec 1c             	sub    $0x1c,%esp
  80179b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80179e:	56                   	push   %esi
  80179f:	e8 a5 ef ff ff       	call   800749 <strlen>
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ac:	7f 6c                	jg     80181a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b4:	50                   	push   %eax
  8017b5:	e8 bd f8 ff ff       	call   801077 <fd_alloc>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 3c                	js     8017ff <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	56                   	push   %esi
  8017c7:	68 00 50 80 00       	push   $0x805000
  8017cc:	e8 b3 ef ff ff       	call   800784 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e1:	e8 f6 fd ff ff       	call   8015dc <fsipc>
  8017e6:	89 c3                	mov    %eax,%ebx
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 19                	js     801808 <open+0x75>
	return fd2num(fd);
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	ff 75 f4             	push   -0xc(%ebp)
  8017f5:	e8 56 f8 ff ff       	call   801050 <fd2num>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	83 c4 10             	add    $0x10,%esp
}
  8017ff:	89 d8                	mov    %ebx,%eax
  801801:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    
		fd_close(fd, 0);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	6a 00                	push   $0x0
  80180d:	ff 75 f4             	push   -0xc(%ebp)
  801810:	e8 58 f9 ff ff       	call   80116d <fd_close>
		return r;
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	eb e5                	jmp    8017ff <open+0x6c>
		return -E_BAD_PATH;
  80181a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80181f:	eb de                	jmp    8017ff <open+0x6c>

00801821 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 08 00 00 00       	mov    $0x8,%eax
  801831:	e8 a6 fd ff ff       	call   8015dc <fsipc>
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80183e:	68 1b 2b 80 00       	push   $0x802b1b
  801843:	ff 75 0c             	push   0xc(%ebp)
  801846:	e8 39 ef ff ff       	call   800784 <strcpy>
	return 0;
}
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <devsock_close>:
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	53                   	push   %ebx
  801856:	83 ec 10             	sub    $0x10,%esp
  801859:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80185c:	53                   	push   %ebx
  80185d:	e8 d2 0a 00 00       	call   802334 <pageref>
  801862:	89 c2                	mov    %eax,%edx
  801864:	83 c4 10             	add    $0x10,%esp
		return 0;
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80186c:	83 fa 01             	cmp    $0x1,%edx
  80186f:	74 05                	je     801876 <devsock_close+0x24>
}
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	ff 73 0c             	push   0xc(%ebx)
  80187c:	e8 b7 02 00 00       	call   801b38 <nsipc_close>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	eb eb                	jmp    801871 <devsock_close+0x1f>

00801886 <devsock_write>:
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80188c:	6a 00                	push   $0x0
  80188e:	ff 75 10             	push   0x10(%ebp)
  801891:	ff 75 0c             	push   0xc(%ebp)
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	ff 70 0c             	push   0xc(%eax)
  80189a:	e8 79 03 00 00       	call   801c18 <nsipc_send>
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <devsock_read>:
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018a7:	6a 00                	push   $0x0
  8018a9:	ff 75 10             	push   0x10(%ebp)
  8018ac:	ff 75 0c             	push   0xc(%ebp)
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	ff 70 0c             	push   0xc(%eax)
  8018b5:	e8 ef 02 00 00       	call   801ba9 <nsipc_recv>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <fd2sockid>:
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018c2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018c5:	52                   	push   %edx
  8018c6:	50                   	push   %eax
  8018c7:	e8 fb f7 ff ff       	call   8010c7 <fd_lookup>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 10                	js     8018e3 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8018d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d6:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018dc:	39 08                	cmp    %ecx,(%eax)
  8018de:	75 05                	jne    8018e5 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8018e0:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    
		return -E_NOT_SUPP;
  8018e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018ea:	eb f7                	jmp    8018e3 <fd2sockid+0x27>

008018ec <alloc_sockfd>:
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 1c             	sub    $0x1c,%esp
  8018f4:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8018f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	e8 78 f7 ff ff       	call   801077 <fd_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 43                	js     80194b <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801908:	83 ec 04             	sub    $0x4,%esp
  80190b:	68 07 04 00 00       	push   $0x407
  801910:	ff 75 f4             	push   -0xc(%ebp)
  801913:	6a 00                	push   $0x0
  801915:	e8 66 f2 ff ff       	call   800b80 <sys_page_alloc>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 28                	js     80194b <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801926:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80192c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801931:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801938:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	50                   	push   %eax
  80193f:	e8 0c f7 ff ff       	call   801050 <fd2num>
  801944:	89 c3                	mov    %eax,%ebx
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	eb 0c                	jmp    801957 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80194b:	83 ec 0c             	sub    $0xc,%esp
  80194e:	56                   	push   %esi
  80194f:	e8 e4 01 00 00       	call   801b38 <nsipc_close>
		return r;
  801954:	83 c4 10             	add    $0x10,%esp
}
  801957:	89 d8                	mov    %ebx,%eax
  801959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195c:	5b                   	pop    %ebx
  80195d:	5e                   	pop    %esi
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <accept>:
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	e8 4e ff ff ff       	call   8018bc <fd2sockid>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 1b                	js     80198d <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801972:	83 ec 04             	sub    $0x4,%esp
  801975:	ff 75 10             	push   0x10(%ebp)
  801978:	ff 75 0c             	push   0xc(%ebp)
  80197b:	50                   	push   %eax
  80197c:	e8 0e 01 00 00       	call   801a8f <nsipc_accept>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 05                	js     80198d <accept+0x2d>
	return alloc_sockfd(r);
  801988:	e8 5f ff ff ff       	call   8018ec <alloc_sockfd>
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <bind>:
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	e8 1f ff ff ff       	call   8018bc <fd2sockid>
  80199d:	85 c0                	test   %eax,%eax
  80199f:	78 12                	js     8019b3 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8019a1:	83 ec 04             	sub    $0x4,%esp
  8019a4:	ff 75 10             	push   0x10(%ebp)
  8019a7:	ff 75 0c             	push   0xc(%ebp)
  8019aa:	50                   	push   %eax
  8019ab:	e8 31 01 00 00       	call   801ae1 <nsipc_bind>
  8019b0:	83 c4 10             	add    $0x10,%esp
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <shutdown>:
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	e8 f9 fe ff ff       	call   8018bc <fd2sockid>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 0f                	js     8019d6 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	ff 75 0c             	push   0xc(%ebp)
  8019cd:	50                   	push   %eax
  8019ce:	e8 43 01 00 00       	call   801b16 <nsipc_shutdown>
  8019d3:	83 c4 10             	add    $0x10,%esp
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <connect>:
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	e8 d6 fe ff ff       	call   8018bc <fd2sockid>
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 12                	js     8019fc <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8019ea:	83 ec 04             	sub    $0x4,%esp
  8019ed:	ff 75 10             	push   0x10(%ebp)
  8019f0:	ff 75 0c             	push   0xc(%ebp)
  8019f3:	50                   	push   %eax
  8019f4:	e8 59 01 00 00       	call   801b52 <nsipc_connect>
  8019f9:	83 c4 10             	add    $0x10,%esp
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <listen>:
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	e8 b0 fe ff ff       	call   8018bc <fd2sockid>
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 0f                	js     801a1f <listen+0x21>
	return nsipc_listen(r, backlog);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	ff 75 0c             	push   0xc(%ebp)
  801a16:	50                   	push   %eax
  801a17:	e8 6b 01 00 00       	call   801b87 <nsipc_listen>
  801a1c:	83 c4 10             	add    $0x10,%esp
}
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a27:	ff 75 10             	push   0x10(%ebp)
  801a2a:	ff 75 0c             	push   0xc(%ebp)
  801a2d:	ff 75 08             	push   0x8(%ebp)
  801a30:	e8 41 02 00 00       	call   801c76 <nsipc_socket>
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 05                	js     801a41 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a3c:	e8 ab fe ff ff       	call   8018ec <alloc_sockfd>
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	53                   	push   %ebx
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a4c:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801a53:	74 26                	je     801a7b <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a55:	6a 07                	push   $0x7
  801a57:	68 00 70 80 00       	push   $0x807000
  801a5c:	53                   	push   %ebx
  801a5d:	ff 35 00 80 80 00    	push   0x808000
  801a63:	e8 3f 08 00 00       	call   8022a7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a68:	83 c4 0c             	add    $0xc,%esp
  801a6b:	6a 00                	push   $0x0
  801a6d:	6a 00                	push   $0x0
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 ca 07 00 00       	call   802240 <ipc_recv>
}
  801a76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	6a 02                	push   $0x2
  801a80:	e8 76 08 00 00       	call   8022fb <ipc_find_env>
  801a85:	a3 00 80 80 00       	mov    %eax,0x808000
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	eb c6                	jmp    801a55 <nsipc+0x12>

00801a8f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a9f:	8b 06                	mov    (%esi),%eax
  801aa1:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  801aab:	e8 93 ff ff ff       	call   801a43 <nsipc>
  801ab0:	89 c3                	mov    %eax,%ebx
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	79 09                	jns    801abf <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ab6:	89 d8                	mov    %ebx,%eax
  801ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801abf:	83 ec 04             	sub    $0x4,%esp
  801ac2:	ff 35 10 70 80 00    	push   0x807010
  801ac8:	68 00 70 80 00       	push   $0x807000
  801acd:	ff 75 0c             	push   0xc(%ebp)
  801ad0:	e8 45 ee ff ff       	call   80091a <memmove>
		*addrlen = ret->ret_addrlen;
  801ad5:	a1 10 70 80 00       	mov    0x807010,%eax
  801ada:	89 06                	mov    %eax,(%esi)
  801adc:	83 c4 10             	add    $0x10,%esp
	return r;
  801adf:	eb d5                	jmp    801ab6 <nsipc_accept+0x27>

00801ae1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 08             	sub    $0x8,%esp
  801ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801af3:	53                   	push   %ebx
  801af4:	ff 75 0c             	push   0xc(%ebp)
  801af7:	68 04 70 80 00       	push   $0x807004
  801afc:	e8 19 ee ff ff       	call   80091a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b01:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b07:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0c:	e8 32 ff ff ff       	call   801a43 <nsipc>
}
  801b11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b27:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801b2c:	b8 03 00 00 00       	mov    $0x3,%eax
  801b31:	e8 0d ff ff ff       	call   801a43 <nsipc>
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <nsipc_close>:

int
nsipc_close(int s)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801b46:	b8 04 00 00 00       	mov    $0x4,%eax
  801b4b:	e8 f3 fe ff ff       	call   801a43 <nsipc>
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b64:	53                   	push   %ebx
  801b65:	ff 75 0c             	push   0xc(%ebp)
  801b68:	68 04 70 80 00       	push   $0x807004
  801b6d:	e8 a8 ed ff ff       	call   80091a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b72:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801b78:	b8 05 00 00 00       	mov    $0x5,%eax
  801b7d:	e8 c1 fe ff ff       	call   801a43 <nsipc>
}
  801b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b98:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801b9d:	b8 06 00 00 00       	mov    $0x6,%eax
  801ba2:	e8 9c fe ff ff       	call   801a43 <nsipc>
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	56                   	push   %esi
  801bad:	53                   	push   %ebx
  801bae:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801bb9:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc2:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bc7:	b8 07 00 00 00       	mov    $0x7,%eax
  801bcc:	e8 72 fe ff ff       	call   801a43 <nsipc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 22                	js     801bf9 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801bd7:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801bdc:	39 c6                	cmp    %eax,%esi
  801bde:	0f 4e c6             	cmovle %esi,%eax
  801be1:	39 c3                	cmp    %eax,%ebx
  801be3:	7f 1d                	jg     801c02 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	53                   	push   %ebx
  801be9:	68 00 70 80 00       	push   $0x807000
  801bee:	ff 75 0c             	push   0xc(%ebp)
  801bf1:	e8 24 ed ff ff       	call   80091a <memmove>
  801bf6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801bf9:	89 d8                	mov    %ebx,%eax
  801bfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c02:	68 27 2b 80 00       	push   $0x802b27
  801c07:	68 ef 2a 80 00       	push   $0x802aef
  801c0c:	6a 62                	push   $0x62
  801c0e:	68 3c 2b 80 00       	push   $0x802b3c
  801c13:	e8 46 05 00 00       	call   80215e <_panic>

00801c18 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c2a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c30:	7f 2e                	jg     801c60 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c32:	83 ec 04             	sub    $0x4,%esp
  801c35:	53                   	push   %ebx
  801c36:	ff 75 0c             	push   0xc(%ebp)
  801c39:	68 0c 70 80 00       	push   $0x80700c
  801c3e:	e8 d7 ec ff ff       	call   80091a <memmove>
	nsipcbuf.send.req_size = size;
  801c43:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801c49:	8b 45 14             	mov    0x14(%ebp),%eax
  801c4c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801c51:	b8 08 00 00 00       	mov    $0x8,%eax
  801c56:	e8 e8 fd ff ff       	call   801a43 <nsipc>
}
  801c5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    
	assert(size < 1600);
  801c60:	68 48 2b 80 00       	push   $0x802b48
  801c65:	68 ef 2a 80 00       	push   $0x802aef
  801c6a:	6a 6d                	push   $0x6d
  801c6c:	68 3c 2b 80 00       	push   $0x802b3c
  801c71:	e8 e8 04 00 00       	call   80215e <_panic>

00801c76 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801c84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c87:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801c94:	b8 09 00 00 00       	mov    $0x9,%eax
  801c99:	e8 a5 fd ff ff       	call   801a43 <nsipc>
}
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    

00801ca0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ca8:	83 ec 0c             	sub    $0xc,%esp
  801cab:	ff 75 08             	push   0x8(%ebp)
  801cae:	e8 ad f3 ff ff       	call   801060 <fd2data>
  801cb3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cb5:	83 c4 08             	add    $0x8,%esp
  801cb8:	68 54 2b 80 00       	push   $0x802b54
  801cbd:	53                   	push   %ebx
  801cbe:	e8 c1 ea ff ff       	call   800784 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc3:	8b 46 04             	mov    0x4(%esi),%eax
  801cc6:	2b 06                	sub    (%esi),%eax
  801cc8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cd5:	00 00 00 
	stat->st_dev = &devpipe;
  801cd8:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cdf:	30 80 00 
	return 0;
}
  801ce2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf8:	53                   	push   %ebx
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 05 ef ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d00:	89 1c 24             	mov    %ebx,(%esp)
  801d03:	e8 58 f3 ff ff       	call   801060 <fd2data>
  801d08:	83 c4 08             	add    $0x8,%esp
  801d0b:	50                   	push   %eax
  801d0c:	6a 00                	push   $0x0
  801d0e:	e8 f2 ee ff ff       	call   800c05 <sys_page_unmap>
}
  801d13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <_pipeisclosed>:
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 1c             	sub    $0x1c,%esp
  801d21:	89 c7                	mov    %eax,%edi
  801d23:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d25:	a1 00 40 80 00       	mov    0x804000,%eax
  801d2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d2d:	83 ec 0c             	sub    $0xc,%esp
  801d30:	57                   	push   %edi
  801d31:	e8 fe 05 00 00       	call   802334 <pageref>
  801d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d39:	89 34 24             	mov    %esi,(%esp)
  801d3c:	e8 f3 05 00 00       	call   802334 <pageref>
		nn = thisenv->env_runs;
  801d41:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	39 cb                	cmp    %ecx,%ebx
  801d4f:	74 1b                	je     801d6c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d51:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d54:	75 cf                	jne    801d25 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d56:	8b 42 58             	mov    0x58(%edx),%eax
  801d59:	6a 01                	push   $0x1
  801d5b:	50                   	push   %eax
  801d5c:	53                   	push   %ebx
  801d5d:	68 5b 2b 80 00       	push   $0x802b5b
  801d62:	e8 43 e4 ff ff       	call   8001aa <cprintf>
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	eb b9                	jmp    801d25 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d6c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d6f:	0f 94 c0             	sete   %al
  801d72:	0f b6 c0             	movzbl %al,%eax
}
  801d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <devpipe_write>:
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	57                   	push   %edi
  801d81:	56                   	push   %esi
  801d82:	53                   	push   %ebx
  801d83:	83 ec 28             	sub    $0x28,%esp
  801d86:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d89:	56                   	push   %esi
  801d8a:	e8 d1 f2 ff ff       	call   801060 <fd2data>
  801d8f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	bf 00 00 00 00       	mov    $0x0,%edi
  801d99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9c:	75 09                	jne    801da7 <devpipe_write+0x2a>
	return i;
  801d9e:	89 f8                	mov    %edi,%eax
  801da0:	eb 23                	jmp    801dc5 <devpipe_write+0x48>
			sys_yield();
  801da2:	e8 ba ed ff ff       	call   800b61 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801da7:	8b 43 04             	mov    0x4(%ebx),%eax
  801daa:	8b 0b                	mov    (%ebx),%ecx
  801dac:	8d 51 20             	lea    0x20(%ecx),%edx
  801daf:	39 d0                	cmp    %edx,%eax
  801db1:	72 1a                	jb     801dcd <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801db3:	89 da                	mov    %ebx,%edx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	e8 5c ff ff ff       	call   801d18 <_pipeisclosed>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	74 e2                	je     801da2 <devpipe_write+0x25>
				return 0;
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dd4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dd7:	89 c2                	mov    %eax,%edx
  801dd9:	c1 fa 1f             	sar    $0x1f,%edx
  801ddc:	89 d1                	mov    %edx,%ecx
  801dde:	c1 e9 1b             	shr    $0x1b,%ecx
  801de1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801de4:	83 e2 1f             	and    $0x1f,%edx
  801de7:	29 ca                	sub    %ecx,%edx
  801de9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ded:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801df1:	83 c0 01             	add    $0x1,%eax
  801df4:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801df7:	83 c7 01             	add    $0x1,%edi
  801dfa:	eb 9d                	jmp    801d99 <devpipe_write+0x1c>

00801dfc <devpipe_read>:
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	57                   	push   %edi
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	83 ec 18             	sub    $0x18,%esp
  801e05:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e08:	57                   	push   %edi
  801e09:	e8 52 f2 ff ff       	call   801060 <fd2data>
  801e0e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	be 00 00 00 00       	mov    $0x0,%esi
  801e18:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1b:	75 13                	jne    801e30 <devpipe_read+0x34>
	return i;
  801e1d:	89 f0                	mov    %esi,%eax
  801e1f:	eb 02                	jmp    801e23 <devpipe_read+0x27>
				return i;
  801e21:	89 f0                	mov    %esi,%eax
}
  801e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e26:	5b                   	pop    %ebx
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    
			sys_yield();
  801e2b:	e8 31 ed ff ff       	call   800b61 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e30:	8b 03                	mov    (%ebx),%eax
  801e32:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e35:	75 18                	jne    801e4f <devpipe_read+0x53>
			if (i > 0)
  801e37:	85 f6                	test   %esi,%esi
  801e39:	75 e6                	jne    801e21 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801e3b:	89 da                	mov    %ebx,%edx
  801e3d:	89 f8                	mov    %edi,%eax
  801e3f:	e8 d4 fe ff ff       	call   801d18 <_pipeisclosed>
  801e44:	85 c0                	test   %eax,%eax
  801e46:	74 e3                	je     801e2b <devpipe_read+0x2f>
				return 0;
  801e48:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4d:	eb d4                	jmp    801e23 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e4f:	99                   	cltd   
  801e50:	c1 ea 1b             	shr    $0x1b,%edx
  801e53:	01 d0                	add    %edx,%eax
  801e55:	83 e0 1f             	and    $0x1f,%eax
  801e58:	29 d0                	sub    %edx,%eax
  801e5a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e62:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e65:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e68:	83 c6 01             	add    $0x1,%esi
  801e6b:	eb ab                	jmp    801e18 <devpipe_read+0x1c>

00801e6d <pipe>:
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 f9 f1 ff ff       	call   801077 <fd_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	0f 88 23 01 00 00    	js     801fae <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8b:	83 ec 04             	sub    $0x4,%esp
  801e8e:	68 07 04 00 00       	push   $0x407
  801e93:	ff 75 f4             	push   -0xc(%ebp)
  801e96:	6a 00                	push   $0x0
  801e98:	e8 e3 ec ff ff       	call   800b80 <sys_page_alloc>
  801e9d:	89 c3                	mov    %eax,%ebx
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	0f 88 04 01 00 00    	js     801fae <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb0:	50                   	push   %eax
  801eb1:	e8 c1 f1 ff ff       	call   801077 <fd_alloc>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 db 00 00 00    	js     801f9e <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	68 07 04 00 00       	push   $0x407
  801ecb:	ff 75 f0             	push   -0x10(%ebp)
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 ab ec ff ff       	call   800b80 <sys_page_alloc>
  801ed5:	89 c3                	mov    %eax,%ebx
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	0f 88 bc 00 00 00    	js     801f9e <pipe+0x131>
	va = fd2data(fd0);
  801ee2:	83 ec 0c             	sub    $0xc,%esp
  801ee5:	ff 75 f4             	push   -0xc(%ebp)
  801ee8:	e8 73 f1 ff ff       	call   801060 <fd2data>
  801eed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eef:	83 c4 0c             	add    $0xc,%esp
  801ef2:	68 07 04 00 00       	push   $0x407
  801ef7:	50                   	push   %eax
  801ef8:	6a 00                	push   $0x0
  801efa:	e8 81 ec ff ff       	call   800b80 <sys_page_alloc>
  801eff:	89 c3                	mov    %eax,%ebx
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	0f 88 82 00 00 00    	js     801f8e <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	ff 75 f0             	push   -0x10(%ebp)
  801f12:	e8 49 f1 ff ff       	call   801060 <fd2data>
  801f17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f1e:	50                   	push   %eax
  801f1f:	6a 00                	push   $0x0
  801f21:	56                   	push   %esi
  801f22:	6a 00                	push   $0x0
  801f24:	e8 9a ec ff ff       	call   800bc3 <sys_page_map>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	83 c4 20             	add    $0x20,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 4e                	js     801f80 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801f32:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801f37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f3a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f3f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f46:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f49:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f55:	83 ec 0c             	sub    $0xc,%esp
  801f58:	ff 75 f4             	push   -0xc(%ebp)
  801f5b:	e8 f0 f0 ff ff       	call   801050 <fd2num>
  801f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f63:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f65:	83 c4 04             	add    $0x4,%esp
  801f68:	ff 75 f0             	push   -0x10(%ebp)
  801f6b:	e8 e0 f0 ff ff       	call   801050 <fd2num>
  801f70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f73:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7e:	eb 2e                	jmp    801fae <pipe+0x141>
	sys_page_unmap(0, va);
  801f80:	83 ec 08             	sub    $0x8,%esp
  801f83:	56                   	push   %esi
  801f84:	6a 00                	push   $0x0
  801f86:	e8 7a ec ff ff       	call   800c05 <sys_page_unmap>
  801f8b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f8e:	83 ec 08             	sub    $0x8,%esp
  801f91:	ff 75 f0             	push   -0x10(%ebp)
  801f94:	6a 00                	push   $0x0
  801f96:	e8 6a ec ff ff       	call   800c05 <sys_page_unmap>
  801f9b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f9e:	83 ec 08             	sub    $0x8,%esp
  801fa1:	ff 75 f4             	push   -0xc(%ebp)
  801fa4:	6a 00                	push   $0x0
  801fa6:	e8 5a ec ff ff       	call   800c05 <sys_page_unmap>
  801fab:	83 c4 10             	add    $0x10,%esp
}
  801fae:	89 d8                	mov    %ebx,%eax
  801fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <pipeisclosed>:
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc0:	50                   	push   %eax
  801fc1:	ff 75 08             	push   0x8(%ebp)
  801fc4:	e8 fe f0 ff ff       	call   8010c7 <fd_lookup>
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 18                	js     801fe8 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801fd0:	83 ec 0c             	sub    $0xc,%esp
  801fd3:	ff 75 f4             	push   -0xc(%ebp)
  801fd6:	e8 85 f0 ff ff       	call   801060 <fd2data>
  801fdb:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe0:	e8 33 fd ff ff       	call   801d18 <_pipeisclosed>
  801fe5:	83 c4 10             	add    $0x10,%esp
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801fea:	b8 00 00 00 00       	mov    $0x0,%eax
  801fef:	c3                   	ret    

00801ff0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ff6:	68 73 2b 80 00       	push   $0x802b73
  801ffb:	ff 75 0c             	push   0xc(%ebp)
  801ffe:	e8 81 e7 ff ff       	call   800784 <strcpy>
	return 0;
}
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <devcons_write>:
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	57                   	push   %edi
  80200e:	56                   	push   %esi
  80200f:	53                   	push   %ebx
  802010:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802016:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80201b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802021:	eb 2e                	jmp    802051 <devcons_write+0x47>
		m = n - tot;
  802023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802026:	29 f3                	sub    %esi,%ebx
  802028:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80202d:	39 c3                	cmp    %eax,%ebx
  80202f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802032:	83 ec 04             	sub    $0x4,%esp
  802035:	53                   	push   %ebx
  802036:	89 f0                	mov    %esi,%eax
  802038:	03 45 0c             	add    0xc(%ebp),%eax
  80203b:	50                   	push   %eax
  80203c:	57                   	push   %edi
  80203d:	e8 d8 e8 ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  802042:	83 c4 08             	add    $0x8,%esp
  802045:	53                   	push   %ebx
  802046:	57                   	push   %edi
  802047:	e8 78 ea ff ff       	call   800ac4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80204c:	01 de                	add    %ebx,%esi
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	3b 75 10             	cmp    0x10(%ebp),%esi
  802054:	72 cd                	jb     802023 <devcons_write+0x19>
}
  802056:	89 f0                	mov    %esi,%eax
  802058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <devcons_read>:
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 08             	sub    $0x8,%esp
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80206b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80206f:	75 07                	jne    802078 <devcons_read+0x18>
  802071:	eb 1f                	jmp    802092 <devcons_read+0x32>
		sys_yield();
  802073:	e8 e9 ea ff ff       	call   800b61 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802078:	e8 65 ea ff ff       	call   800ae2 <sys_cgetc>
  80207d:	85 c0                	test   %eax,%eax
  80207f:	74 f2                	je     802073 <devcons_read+0x13>
	if (c < 0)
  802081:	78 0f                	js     802092 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802083:	83 f8 04             	cmp    $0x4,%eax
  802086:	74 0c                	je     802094 <devcons_read+0x34>
	*(char*)vbuf = c;
  802088:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208b:	88 02                	mov    %al,(%edx)
	return 1;
  80208d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802092:	c9                   	leave  
  802093:	c3                   	ret    
		return 0;
  802094:	b8 00 00 00 00       	mov    $0x0,%eax
  802099:	eb f7                	jmp    802092 <devcons_read+0x32>

0080209b <cputchar>:
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020a7:	6a 01                	push   $0x1
  8020a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ac:	50                   	push   %eax
  8020ad:	e8 12 ea ff ff       	call   800ac4 <sys_cputs>
}
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <getchar>:
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020bd:	6a 01                	push   $0x1
  8020bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c2:	50                   	push   %eax
  8020c3:	6a 00                	push   $0x0
  8020c5:	e8 66 f2 ff ff       	call   801330 <read>
	if (r < 0)
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 06                	js     8020d7 <getchar+0x20>
	if (r < 1)
  8020d1:	74 06                	je     8020d9 <getchar+0x22>
	return c;
  8020d3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020d7:	c9                   	leave  
  8020d8:	c3                   	ret    
		return -E_EOF;
  8020d9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020de:	eb f7                	jmp    8020d7 <getchar+0x20>

008020e0 <iscons>:
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	ff 75 08             	push   0x8(%ebp)
  8020ed:	e8 d5 ef ff ff       	call   8010c7 <fd_lookup>
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 11                	js     80210a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802102:	39 10                	cmp    %edx,(%eax)
  802104:	0f 94 c0             	sete   %al
  802107:	0f b6 c0             	movzbl %al,%eax
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <opencons>:
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	e8 5c ef ff ff       	call   801077 <fd_alloc>
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 3a                	js     80215c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802122:	83 ec 04             	sub    $0x4,%esp
  802125:	68 07 04 00 00       	push   $0x407
  80212a:	ff 75 f4             	push   -0xc(%ebp)
  80212d:	6a 00                	push   $0x0
  80212f:	e8 4c ea ff ff       	call   800b80 <sys_page_alloc>
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	85 c0                	test   %eax,%eax
  802139:	78 21                	js     80215c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80213b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802144:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802146:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802149:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802150:	83 ec 0c             	sub    $0xc,%esp
  802153:	50                   	push   %eax
  802154:	e8 f7 ee ff ff       	call   801050 <fd2num>
  802159:	83 c4 10             	add    $0x10,%esp
}
  80215c:	c9                   	leave  
  80215d:	c3                   	ret    

0080215e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	56                   	push   %esi
  802162:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802163:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802166:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80216c:	e8 d1 e9 ff ff       	call   800b42 <sys_getenvid>
  802171:	83 ec 0c             	sub    $0xc,%esp
  802174:	ff 75 0c             	push   0xc(%ebp)
  802177:	ff 75 08             	push   0x8(%ebp)
  80217a:	56                   	push   %esi
  80217b:	50                   	push   %eax
  80217c:	68 80 2b 80 00       	push   $0x802b80
  802181:	e8 24 e0 ff ff       	call   8001aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802186:	83 c4 18             	add    $0x18,%esp
  802189:	53                   	push   %ebx
  80218a:	ff 75 10             	push   0x10(%ebp)
  80218d:	e8 c7 df ff ff       	call   800159 <vcprintf>
	cprintf("\n");
  802192:	c7 04 24 54 26 80 00 	movl   $0x802654,(%esp)
  802199:	e8 0c e0 ff ff       	call   8001aa <cprintf>
  80219e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021a1:	cc                   	int3   
  8021a2:	eb fd                	jmp    8021a1 <_panic+0x43>

008021a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8021aa:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8021b1:	74 0a                	je     8021bd <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b6:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8021bd:	e8 80 e9 ff ff       	call   800b42 <sys_getenvid>
  8021c2:	83 ec 04             	sub    $0x4,%esp
  8021c5:	68 07 0e 00 00       	push   $0xe07
  8021ca:	68 00 f0 bf ee       	push   $0xeebff000
  8021cf:	50                   	push   %eax
  8021d0:	e8 ab e9 ff ff       	call   800b80 <sys_page_alloc>
		if (r < 0) {
  8021d5:	83 c4 10             	add    $0x10,%esp
  8021d8:	85 c0                	test   %eax,%eax
  8021da:	78 2c                	js     802208 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8021dc:	e8 61 e9 ff ff       	call   800b42 <sys_getenvid>
  8021e1:	83 ec 08             	sub    $0x8,%esp
  8021e4:	68 1a 22 80 00       	push   $0x80221a
  8021e9:	50                   	push   %eax
  8021ea:	e8 dc ea ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8021ef:	83 c4 10             	add    $0x10,%esp
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	79 bd                	jns    8021b3 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8021f6:	50                   	push   %eax
  8021f7:	68 e4 2b 80 00       	push   $0x802be4
  8021fc:	6a 28                	push   $0x28
  8021fe:	68 1a 2c 80 00       	push   $0x802c1a
  802203:	e8 56 ff ff ff       	call   80215e <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802208:	50                   	push   %eax
  802209:	68 a4 2b 80 00       	push   $0x802ba4
  80220e:	6a 23                	push   $0x23
  802210:	68 1a 2c 80 00       	push   $0x802c1a
  802215:	e8 44 ff ff ff       	call   80215e <_panic>

0080221a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80221a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80221b:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802220:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802222:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802225:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802229:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80222c:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802230:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802234:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802236:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802239:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80223a:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80223d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80223e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80223f:	c3                   	ret    

00802240 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	56                   	push   %esi
  802244:	53                   	push   %ebx
  802245:	8b 75 08             	mov    0x8(%ebp),%esi
  802248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80224e:	85 c0                	test   %eax,%eax
  802250:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802255:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802258:	83 ec 0c             	sub    $0xc,%esp
  80225b:	50                   	push   %eax
  80225c:	e8 cf ea ff ff       	call   800d30 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802261:	83 c4 10             	add    $0x10,%esp
  802264:	85 f6                	test   %esi,%esi
  802266:	74 14                	je     80227c <ipc_recv+0x3c>
  802268:	ba 00 00 00 00       	mov    $0x0,%edx
  80226d:	85 c0                	test   %eax,%eax
  80226f:	78 09                	js     80227a <ipc_recv+0x3a>
  802271:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802277:	8b 52 74             	mov    0x74(%edx),%edx
  80227a:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80227c:	85 db                	test   %ebx,%ebx
  80227e:	74 14                	je     802294 <ipc_recv+0x54>
  802280:	ba 00 00 00 00       	mov    $0x0,%edx
  802285:	85 c0                	test   %eax,%eax
  802287:	78 09                	js     802292 <ipc_recv+0x52>
  802289:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80228f:	8b 52 78             	mov    0x78(%edx),%edx
  802292:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802294:	85 c0                	test   %eax,%eax
  802296:	78 08                	js     8022a0 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802298:	a1 00 40 80 00       	mov    0x804000,%eax
  80229d:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    

008022a7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
  8022aa:	57                   	push   %edi
  8022ab:	56                   	push   %esi
  8022ac:	53                   	push   %ebx
  8022ad:	83 ec 0c             	sub    $0xc,%esp
  8022b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8022b9:	85 db                	test   %ebx,%ebx
  8022bb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022c0:	0f 44 d8             	cmove  %eax,%ebx
  8022c3:	eb 05                	jmp    8022ca <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022c5:	e8 97 e8 ff ff       	call   800b61 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8022ca:	ff 75 14             	push   0x14(%ebp)
  8022cd:	53                   	push   %ebx
  8022ce:	56                   	push   %esi
  8022cf:	57                   	push   %edi
  8022d0:	e8 38 ea ff ff       	call   800d0d <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022db:	74 e8                	je     8022c5 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 08                	js     8022e9 <ipc_send+0x42>
	}while (r<0);

}
  8022e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8022e9:	50                   	push   %eax
  8022ea:	68 28 2c 80 00       	push   $0x802c28
  8022ef:	6a 3d                	push   $0x3d
  8022f1:	68 3c 2c 80 00       	push   $0x802c3c
  8022f6:	e8 63 fe ff ff       	call   80215e <_panic>

008022fb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802306:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802309:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80230f:	8b 52 50             	mov    0x50(%edx),%edx
  802312:	39 ca                	cmp    %ecx,%edx
  802314:	74 11                	je     802327 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802316:	83 c0 01             	add    $0x1,%eax
  802319:	3d 00 04 00 00       	cmp    $0x400,%eax
  80231e:	75 e6                	jne    802306 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802320:	b8 00 00 00 00       	mov    $0x0,%eax
  802325:	eb 0b                	jmp    802332 <ipc_find_env+0x37>
			return envs[i].env_id;
  802327:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80232a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80232f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    

00802334 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80233a:	89 c2                	mov    %eax,%edx
  80233c:	c1 ea 16             	shr    $0x16,%edx
  80233f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802346:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80234b:	f6 c1 01             	test   $0x1,%cl
  80234e:	74 1c                	je     80236c <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802350:	c1 e8 0c             	shr    $0xc,%eax
  802353:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80235a:	a8 01                	test   $0x1,%al
  80235c:	74 0e                	je     80236c <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80235e:	c1 e8 0c             	shr    $0xc,%eax
  802361:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802368:	ef 
  802369:	0f b7 d2             	movzwl %dx,%edx
}
  80236c:	89 d0                	mov    %edx,%eax
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <__udivdi3>:
  802370:	f3 0f 1e fb          	endbr32 
  802374:	55                   	push   %ebp
  802375:	57                   	push   %edi
  802376:	56                   	push   %esi
  802377:	53                   	push   %ebx
  802378:	83 ec 1c             	sub    $0x1c,%esp
  80237b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80237f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802383:	8b 74 24 34          	mov    0x34(%esp),%esi
  802387:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80238b:	85 c0                	test   %eax,%eax
  80238d:	75 19                	jne    8023a8 <__udivdi3+0x38>
  80238f:	39 f3                	cmp    %esi,%ebx
  802391:	76 4d                	jbe    8023e0 <__udivdi3+0x70>
  802393:	31 ff                	xor    %edi,%edi
  802395:	89 e8                	mov    %ebp,%eax
  802397:	89 f2                	mov    %esi,%edx
  802399:	f7 f3                	div    %ebx
  80239b:	89 fa                	mov    %edi,%edx
  80239d:	83 c4 1c             	add    $0x1c,%esp
  8023a0:	5b                   	pop    %ebx
  8023a1:	5e                   	pop    %esi
  8023a2:	5f                   	pop    %edi
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    
  8023a5:	8d 76 00             	lea    0x0(%esi),%esi
  8023a8:	39 f0                	cmp    %esi,%eax
  8023aa:	76 14                	jbe    8023c0 <__udivdi3+0x50>
  8023ac:	31 ff                	xor    %edi,%edi
  8023ae:	31 c0                	xor    %eax,%eax
  8023b0:	89 fa                	mov    %edi,%edx
  8023b2:	83 c4 1c             	add    $0x1c,%esp
  8023b5:	5b                   	pop    %ebx
  8023b6:	5e                   	pop    %esi
  8023b7:	5f                   	pop    %edi
  8023b8:	5d                   	pop    %ebp
  8023b9:	c3                   	ret    
  8023ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c0:	0f bd f8             	bsr    %eax,%edi
  8023c3:	83 f7 1f             	xor    $0x1f,%edi
  8023c6:	75 48                	jne    802410 <__udivdi3+0xa0>
  8023c8:	39 f0                	cmp    %esi,%eax
  8023ca:	72 06                	jb     8023d2 <__udivdi3+0x62>
  8023cc:	31 c0                	xor    %eax,%eax
  8023ce:	39 eb                	cmp    %ebp,%ebx
  8023d0:	77 de                	ja     8023b0 <__udivdi3+0x40>
  8023d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d7:	eb d7                	jmp    8023b0 <__udivdi3+0x40>
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	89 d9                	mov    %ebx,%ecx
  8023e2:	85 db                	test   %ebx,%ebx
  8023e4:	75 0b                	jne    8023f1 <__udivdi3+0x81>
  8023e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	f7 f3                	div    %ebx
  8023ef:	89 c1                	mov    %eax,%ecx
  8023f1:	31 d2                	xor    %edx,%edx
  8023f3:	89 f0                	mov    %esi,%eax
  8023f5:	f7 f1                	div    %ecx
  8023f7:	89 c6                	mov    %eax,%esi
  8023f9:	89 e8                	mov    %ebp,%eax
  8023fb:	89 f7                	mov    %esi,%edi
  8023fd:	f7 f1                	div    %ecx
  8023ff:	89 fa                	mov    %edi,%edx
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	89 f9                	mov    %edi,%ecx
  802412:	ba 20 00 00 00       	mov    $0x20,%edx
  802417:	29 fa                	sub    %edi,%edx
  802419:	d3 e0                	shl    %cl,%eax
  80241b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80241f:	89 d1                	mov    %edx,%ecx
  802421:	89 d8                	mov    %ebx,%eax
  802423:	d3 e8                	shr    %cl,%eax
  802425:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802429:	09 c1                	or     %eax,%ecx
  80242b:	89 f0                	mov    %esi,%eax
  80242d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802431:	89 f9                	mov    %edi,%ecx
  802433:	d3 e3                	shl    %cl,%ebx
  802435:	89 d1                	mov    %edx,%ecx
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 f9                	mov    %edi,%ecx
  80243b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80243f:	89 eb                	mov    %ebp,%ebx
  802441:	d3 e6                	shl    %cl,%esi
  802443:	89 d1                	mov    %edx,%ecx
  802445:	d3 eb                	shr    %cl,%ebx
  802447:	09 f3                	or     %esi,%ebx
  802449:	89 c6                	mov    %eax,%esi
  80244b:	89 f2                	mov    %esi,%edx
  80244d:	89 d8                	mov    %ebx,%eax
  80244f:	f7 74 24 08          	divl   0x8(%esp)
  802453:	89 d6                	mov    %edx,%esi
  802455:	89 c3                	mov    %eax,%ebx
  802457:	f7 64 24 0c          	mull   0xc(%esp)
  80245b:	39 d6                	cmp    %edx,%esi
  80245d:	72 19                	jb     802478 <__udivdi3+0x108>
  80245f:	89 f9                	mov    %edi,%ecx
  802461:	d3 e5                	shl    %cl,%ebp
  802463:	39 c5                	cmp    %eax,%ebp
  802465:	73 04                	jae    80246b <__udivdi3+0xfb>
  802467:	39 d6                	cmp    %edx,%esi
  802469:	74 0d                	je     802478 <__udivdi3+0x108>
  80246b:	89 d8                	mov    %ebx,%eax
  80246d:	31 ff                	xor    %edi,%edi
  80246f:	e9 3c ff ff ff       	jmp    8023b0 <__udivdi3+0x40>
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80247b:	31 ff                	xor    %edi,%edi
  80247d:	e9 2e ff ff ff       	jmp    8023b0 <__udivdi3+0x40>
  802482:	66 90                	xchg   %ax,%ax
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	f3 0f 1e fb          	endbr32 
  802494:	55                   	push   %ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 1c             	sub    $0x1c,%esp
  80249b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80249f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024a3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024a7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024ab:	89 f0                	mov    %esi,%eax
  8024ad:	89 da                	mov    %ebx,%edx
  8024af:	85 ff                	test   %edi,%edi
  8024b1:	75 15                	jne    8024c8 <__umoddi3+0x38>
  8024b3:	39 dd                	cmp    %ebx,%ebp
  8024b5:	76 39                	jbe    8024f0 <__umoddi3+0x60>
  8024b7:	f7 f5                	div    %ebp
  8024b9:	89 d0                	mov    %edx,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	83 c4 1c             	add    $0x1c,%esp
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    
  8024c5:	8d 76 00             	lea    0x0(%esi),%esi
  8024c8:	39 df                	cmp    %ebx,%edi
  8024ca:	77 f1                	ja     8024bd <__umoddi3+0x2d>
  8024cc:	0f bd cf             	bsr    %edi,%ecx
  8024cf:	83 f1 1f             	xor    $0x1f,%ecx
  8024d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024d6:	75 40                	jne    802518 <__umoddi3+0x88>
  8024d8:	39 df                	cmp    %ebx,%edi
  8024da:	72 04                	jb     8024e0 <__umoddi3+0x50>
  8024dc:	39 f5                	cmp    %esi,%ebp
  8024de:	77 dd                	ja     8024bd <__umoddi3+0x2d>
  8024e0:	89 da                	mov    %ebx,%edx
  8024e2:	89 f0                	mov    %esi,%eax
  8024e4:	29 e8                	sub    %ebp,%eax
  8024e6:	19 fa                	sbb    %edi,%edx
  8024e8:	eb d3                	jmp    8024bd <__umoddi3+0x2d>
  8024ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f0:	89 e9                	mov    %ebp,%ecx
  8024f2:	85 ed                	test   %ebp,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x71>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f5                	div    %ebp
  8024ff:	89 c1                	mov    %eax,%ecx
  802501:	89 d8                	mov    %ebx,%eax
  802503:	31 d2                	xor    %edx,%edx
  802505:	f7 f1                	div    %ecx
  802507:	89 f0                	mov    %esi,%eax
  802509:	f7 f1                	div    %ecx
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	31 d2                	xor    %edx,%edx
  80250f:	eb ac                	jmp    8024bd <__umoddi3+0x2d>
  802511:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802518:	8b 44 24 04          	mov    0x4(%esp),%eax
  80251c:	ba 20 00 00 00       	mov    $0x20,%edx
  802521:	29 c2                	sub    %eax,%edx
  802523:	89 c1                	mov    %eax,%ecx
  802525:	89 e8                	mov    %ebp,%eax
  802527:	d3 e7                	shl    %cl,%edi
  802529:	89 d1                	mov    %edx,%ecx
  80252b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80252f:	d3 e8                	shr    %cl,%eax
  802531:	89 c1                	mov    %eax,%ecx
  802533:	8b 44 24 04          	mov    0x4(%esp),%eax
  802537:	09 f9                	or     %edi,%ecx
  802539:	89 df                	mov    %ebx,%edi
  80253b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80253f:	89 c1                	mov    %eax,%ecx
  802541:	d3 e5                	shl    %cl,%ebp
  802543:	89 d1                	mov    %edx,%ecx
  802545:	d3 ef                	shr    %cl,%edi
  802547:	89 c1                	mov    %eax,%ecx
  802549:	89 f0                	mov    %esi,%eax
  80254b:	d3 e3                	shl    %cl,%ebx
  80254d:	89 d1                	mov    %edx,%ecx
  80254f:	89 fa                	mov    %edi,%edx
  802551:	d3 e8                	shr    %cl,%eax
  802553:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802558:	09 d8                	or     %ebx,%eax
  80255a:	f7 74 24 08          	divl   0x8(%esp)
  80255e:	89 d3                	mov    %edx,%ebx
  802560:	d3 e6                	shl    %cl,%esi
  802562:	f7 e5                	mul    %ebp
  802564:	89 c7                	mov    %eax,%edi
  802566:	89 d1                	mov    %edx,%ecx
  802568:	39 d3                	cmp    %edx,%ebx
  80256a:	72 06                	jb     802572 <__umoddi3+0xe2>
  80256c:	75 0e                	jne    80257c <__umoddi3+0xec>
  80256e:	39 c6                	cmp    %eax,%esi
  802570:	73 0a                	jae    80257c <__umoddi3+0xec>
  802572:	29 e8                	sub    %ebp,%eax
  802574:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802578:	89 d1                	mov    %edx,%ecx
  80257a:	89 c7                	mov    %eax,%edi
  80257c:	89 f5                	mov    %esi,%ebp
  80257e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802582:	29 fd                	sub    %edi,%ebp
  802584:	19 cb                	sbb    %ecx,%ebx
  802586:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80258b:	89 d8                	mov    %ebx,%eax
  80258d:	d3 e0                	shl    %cl,%eax
  80258f:	89 f1                	mov    %esi,%ecx
  802591:	d3 ed                	shr    %cl,%ebp
  802593:	d3 eb                	shr    %cl,%ebx
  802595:	09 e8                	or     %ebp,%eax
  802597:	89 da                	mov    %ebx,%edx
  802599:	83 c4 1c             	add    $0x1c,%esp
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5f                   	pop    %edi
  80259f:	5d                   	pop    %ebp
  8025a0:	c3                   	ret    
