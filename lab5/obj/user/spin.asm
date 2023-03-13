
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
  80003a:	68 00 21 80 00       	push   $0x802100
  80003f:	e8 66 01 00 00       	call   8001aa <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 26 0e 00 00       	call   800e6f <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 78 21 80 00       	push   $0x802178
  800058:	e8 4d 01 00 00       	call   8001aa <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 28 21 80 00       	push   $0x802128
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
  800099:	c7 04 24 50 21 80 00 	movl   $0x802150,(%esp)
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
  800101:	e8 b5 10 00 00       	call   8011bb <close_all>
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
  80020c:	e8 9f 1c 00 00       	call   801eb0 <__udivdi3>
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
  80024a:	e8 81 1d 00 00       	call   801fd0 <__umoddi3>
  80024f:	83 c4 14             	add    $0x14,%esp
  800252:	0f be 80 a0 21 80 00 	movsbl 0x8021a0(%eax),%eax
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
  80030c:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
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
  8003da:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	74 18                	je     8003fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003e5:	52                   	push   %edx
  8003e6:	68 3d 26 80 00       	push   $0x80263d
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 92 fe ff ff       	call   800284 <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f8:	e9 66 02 00 00       	jmp    800663 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003fd:	50                   	push   %eax
  8003fe:	68 b8 21 80 00       	push   $0x8021b8
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
  800425:	b8 b1 21 80 00       	mov    $0x8021b1,%eax
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
  800b31:	68 9f 24 80 00       	push   $0x80249f
  800b36:	6a 2a                	push   $0x2a
  800b38:	68 bc 24 80 00       	push   $0x8024bc
  800b3d:	e8 4e 11 00 00       	call   801c90 <_panic>

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
  800bb2:	68 9f 24 80 00       	push   $0x80249f
  800bb7:	6a 2a                	push   $0x2a
  800bb9:	68 bc 24 80 00       	push   $0x8024bc
  800bbe:	e8 cd 10 00 00       	call   801c90 <_panic>

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
  800bf4:	68 9f 24 80 00       	push   $0x80249f
  800bf9:	6a 2a                	push   $0x2a
  800bfb:	68 bc 24 80 00       	push   $0x8024bc
  800c00:	e8 8b 10 00 00       	call   801c90 <_panic>

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
  800c36:	68 9f 24 80 00       	push   $0x80249f
  800c3b:	6a 2a                	push   $0x2a
  800c3d:	68 bc 24 80 00       	push   $0x8024bc
  800c42:	e8 49 10 00 00       	call   801c90 <_panic>

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
  800c78:	68 9f 24 80 00       	push   $0x80249f
  800c7d:	6a 2a                	push   $0x2a
  800c7f:	68 bc 24 80 00       	push   $0x8024bc
  800c84:	e8 07 10 00 00       	call   801c90 <_panic>

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
  800cba:	68 9f 24 80 00       	push   $0x80249f
  800cbf:	6a 2a                	push   $0x2a
  800cc1:	68 bc 24 80 00       	push   $0x8024bc
  800cc6:	e8 c5 0f 00 00       	call   801c90 <_panic>

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
  800cfc:	68 9f 24 80 00       	push   $0x80249f
  800d01:	6a 2a                	push   $0x2a
  800d03:	68 bc 24 80 00       	push   $0x8024bc
  800d08:	e8 83 0f 00 00       	call   801c90 <_panic>

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
  800d60:	68 9f 24 80 00       	push   $0x80249f
  800d65:	6a 2a                	push   $0x2a
  800d67:	68 bc 24 80 00       	push   $0x8024bc
  800d6c:	e8 1f 0f 00 00       	call   801c90 <_panic>

00800d71 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d79:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800d7b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d7f:	0f 84 8e 00 00 00    	je     800e13 <pgfault+0xa2>
  800d85:	89 f0                	mov    %esi,%eax
  800d87:	c1 e8 0c             	shr    $0xc,%eax
  800d8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d91:	f6 c4 08             	test   $0x8,%ah
  800d94:	74 7d                	je     800e13 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800d96:	e8 a7 fd ff ff       	call   800b42 <sys_getenvid>
  800d9b:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	6a 07                	push   $0x7
  800da2:	68 00 f0 7f 00       	push   $0x7ff000
  800da7:	50                   	push   %eax
  800da8:	e8 d3 fd ff ff       	call   800b80 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 73                	js     800e27 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800db4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	68 00 10 00 00       	push   $0x1000
  800dc2:	56                   	push   %esi
  800dc3:	68 00 f0 7f 00       	push   $0x7ff000
  800dc8:	e8 4d fb ff ff       	call   80091a <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800dcd:	83 c4 08             	add    $0x8,%esp
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	e8 2e fe ff ff       	call   800c05 <sys_page_unmap>
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	78 5b                	js     800e39 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	6a 07                	push   $0x7
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	68 00 f0 7f 00       	push   $0x7ff000
  800dea:	53                   	push   %ebx
  800deb:	e8 d3 fd ff ff       	call   800bc3 <sys_page_map>
  800df0:	83 c4 20             	add    $0x20,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 54                	js     800e4b <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800df7:	83 ec 08             	sub    $0x8,%esp
  800dfa:	68 00 f0 7f 00       	push   $0x7ff000
  800dff:	53                   	push   %ebx
  800e00:	e8 00 fe ff ff       	call   800c05 <sys_page_unmap>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 51                	js     800e5d <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	68 cc 24 80 00       	push   $0x8024cc
  800e1b:	6a 1d                	push   $0x1d
  800e1d:	68 48 25 80 00       	push   $0x802548
  800e22:	e8 69 0e 00 00       	call   801c90 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 04 25 80 00       	push   $0x802504
  800e2d:	6a 29                	push   $0x29
  800e2f:	68 48 25 80 00       	push   $0x802548
  800e34:	e8 57 0e 00 00       	call   801c90 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e39:	50                   	push   %eax
  800e3a:	68 28 25 80 00       	push   $0x802528
  800e3f:	6a 2e                	push   $0x2e
  800e41:	68 48 25 80 00       	push   $0x802548
  800e46:	e8 45 0e 00 00       	call   801c90 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e4b:	50                   	push   %eax
  800e4c:	68 53 25 80 00       	push   $0x802553
  800e51:	6a 30                	push   $0x30
  800e53:	68 48 25 80 00       	push   $0x802548
  800e58:	e8 33 0e 00 00       	call   801c90 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e5d:	50                   	push   %eax
  800e5e:	68 28 25 80 00       	push   $0x802528
  800e63:	6a 32                	push   $0x32
  800e65:	68 48 25 80 00       	push   $0x802548
  800e6a:	e8 21 0e 00 00       	call   801c90 <_panic>

00800e6f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800e78:	68 71 0d 80 00       	push   $0x800d71
  800e7d:	e8 54 0e 00 00       	call   801cd6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e82:	b8 07 00 00 00       	mov    $0x7,%eax
  800e87:	cd 30                	int    $0x30
  800e89:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 2d                	js     800ec0 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800e93:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800e98:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e9c:	75 73                	jne    800f11 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e9e:	e8 9f fc ff ff       	call   800b42 <sys_getenvid>
  800ea3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ea8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb0:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800eb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800ec0:	50                   	push   %eax
  800ec1:	68 71 25 80 00       	push   $0x802571
  800ec6:	6a 78                	push   $0x78
  800ec8:	68 48 25 80 00       	push   $0x802548
  800ecd:	e8 be 0d 00 00       	call   801c90 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	ff 75 e4             	push   -0x1c(%ebp)
  800ed8:	57                   	push   %edi
  800ed9:	ff 75 dc             	push   -0x24(%ebp)
  800edc:	57                   	push   %edi
  800edd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ee0:	56                   	push   %esi
  800ee1:	e8 dd fc ff ff       	call   800bc3 <sys_page_map>
	if(r<0) return r;
  800ee6:	83 c4 20             	add    $0x20,%esp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	78 cb                	js     800eb8 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	ff 75 e4             	push   -0x1c(%ebp)
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	e8 c7 fc ff ff       	call   800bc3 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	78 76                	js     800f79 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f03:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f09:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f0f:	74 75                	je     800f86 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	c1 e8 16             	shr    $0x16,%eax
  800f16:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1d:	a8 01                	test   $0x1,%al
  800f1f:	74 e2                	je     800f03 <fork+0x94>
  800f21:	89 de                	mov    %ebx,%esi
  800f23:	c1 ee 0c             	shr    $0xc,%esi
  800f26:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f2d:	a8 01                	test   $0x1,%al
  800f2f:	74 d2                	je     800f03 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800f31:	e8 0c fc ff ff       	call   800b42 <sys_getenvid>
  800f36:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800f39:	89 f7                	mov    %esi,%edi
  800f3b:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800f3e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f45:	89 c1                	mov    %eax,%ecx
  800f47:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800f4d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800f50:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800f57:	f6 c6 04             	test   $0x4,%dh
  800f5a:	0f 85 72 ff ff ff    	jne    800ed2 <fork+0x63>
		perm &= ~PTE_W;
  800f60:	25 05 0e 00 00       	and    $0xe05,%eax
  800f65:	80 cc 08             	or     $0x8,%ah
  800f68:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800f6e:	0f 44 c1             	cmove  %ecx,%eax
  800f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f74:	e9 59 ff ff ff       	jmp    800ed2 <fork+0x63>
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	0f 4f c2             	cmovg  %edx,%eax
  800f81:	e9 32 ff ff ff       	jmp    800eb8 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	6a 07                	push   $0x7
  800f8b:	68 00 f0 bf ee       	push   $0xeebff000
  800f90:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f93:	57                   	push   %edi
  800f94:	e8 e7 fb ff ff       	call   800b80 <sys_page_alloc>
	if(r<0) return r;
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	0f 88 14 ff ff ff    	js     800eb8 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	68 4c 1d 80 00       	push   $0x801d4c
  800fac:	57                   	push   %edi
  800fad:	e8 19 fd ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	0f 88 fb fe ff ff    	js     800eb8 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	6a 02                	push   $0x2
  800fc2:	57                   	push   %edi
  800fc3:	e8 7f fc ff ff       	call   800c47 <sys_env_set_status>
	if(r<0) return r;
  800fc8:	83 c4 10             	add    $0x10,%esp
	return envid;
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	0f 49 c7             	cmovns %edi,%eax
  800fd0:	e9 e3 fe ff ff       	jmp    800eb8 <fork+0x49>

00800fd5 <sfork>:

// Challenge!
int
sfork(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fdb:	68 81 25 80 00       	push   $0x802581
  800fe0:	68 a1 00 00 00       	push   $0xa1
  800fe5:	68 48 25 80 00       	push   $0x802548
  800fea:	e8 a1 0c 00 00       	call   801c90 <_panic>

00800fef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff5:	05 00 00 00 30       	add    $0x30000000,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
}
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80100a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80100f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80101e:	89 c2                	mov    %eax,%edx
  801020:	c1 ea 16             	shr    $0x16,%edx
  801023:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80102a:	f6 c2 01             	test   $0x1,%dl
  80102d:	74 29                	je     801058 <fd_alloc+0x42>
  80102f:	89 c2                	mov    %eax,%edx
  801031:	c1 ea 0c             	shr    $0xc,%edx
  801034:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103b:	f6 c2 01             	test   $0x1,%dl
  80103e:	74 18                	je     801058 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801040:	05 00 10 00 00       	add    $0x1000,%eax
  801045:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80104a:	75 d2                	jne    80101e <fd_alloc+0x8>
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801051:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801056:	eb 05                	jmp    80105d <fd_alloc+0x47>
			return 0;
  801058:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80105d:	8b 55 08             	mov    0x8(%ebp),%edx
  801060:	89 02                	mov    %eax,(%edx)
}
  801062:	89 c8                	mov    %ecx,%eax
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80106c:	83 f8 1f             	cmp    $0x1f,%eax
  80106f:	77 30                	ja     8010a1 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801071:	c1 e0 0c             	shl    $0xc,%eax
  801074:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801079:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80107f:	f6 c2 01             	test   $0x1,%dl
  801082:	74 24                	je     8010a8 <fd_lookup+0x42>
  801084:	89 c2                	mov    %eax,%edx
  801086:	c1 ea 0c             	shr    $0xc,%edx
  801089:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801090:	f6 c2 01             	test   $0x1,%dl
  801093:	74 1a                	je     8010af <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801095:	8b 55 0c             	mov    0xc(%ebp),%edx
  801098:	89 02                	mov    %eax,(%edx)
	return 0;
  80109a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    
		return -E_INVAL;
  8010a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010a6:	eb f7                	jmp    80109f <fd_lookup+0x39>
		return -E_INVAL;
  8010a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ad:	eb f0                	jmp    80109f <fd_lookup+0x39>
  8010af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b4:	eb e9                	jmp    80109f <fd_lookup+0x39>

008010b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c0:	b8 14 26 80 00       	mov    $0x802614,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8010c5:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8010ca:	39 13                	cmp    %edx,(%ebx)
  8010cc:	74 32                	je     801100 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8010ce:	83 c0 04             	add    $0x4,%eax
  8010d1:	8b 18                	mov    (%eax),%ebx
  8010d3:	85 db                	test   %ebx,%ebx
  8010d5:	75 f3                	jne    8010ca <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010d7:	a1 00 40 80 00       	mov    0x804000,%eax
  8010dc:	8b 40 48             	mov    0x48(%eax),%eax
  8010df:	83 ec 04             	sub    $0x4,%esp
  8010e2:	52                   	push   %edx
  8010e3:	50                   	push   %eax
  8010e4:	68 98 25 80 00       	push   $0x802598
  8010e9:	e8 bc f0 ff ff       	call   8001aa <cprintf>
	*dev = 0;
	return -E_INVAL;
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8010f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f9:	89 1a                	mov    %ebx,(%edx)
}
  8010fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    
			return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	eb ef                	jmp    8010f6 <dev_lookup+0x40>

00801107 <fd_close>:
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 24             	sub    $0x24,%esp
  801110:	8b 75 08             	mov    0x8(%ebp),%esi
  801113:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801116:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801119:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801120:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801123:	50                   	push   %eax
  801124:	e8 3d ff ff ff       	call   801066 <fd_lookup>
  801129:	89 c3                	mov    %eax,%ebx
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 05                	js     801137 <fd_close+0x30>
	    || fd != fd2)
  801132:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801135:	74 16                	je     80114d <fd_close+0x46>
		return (must_exist ? r : 0);
  801137:	89 f8                	mov    %edi,%eax
  801139:	84 c0                	test   %al,%al
  80113b:	b8 00 00 00 00       	mov    $0x0,%eax
  801140:	0f 44 d8             	cmove  %eax,%ebx
}
  801143:	89 d8                	mov    %ebx,%eax
  801145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	ff 36                	push   (%esi)
  801156:	e8 5b ff ff ff       	call   8010b6 <dev_lookup>
  80115b:	89 c3                	mov    %eax,%ebx
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 1a                	js     80117e <fd_close+0x77>
		if (dev->dev_close)
  801164:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801167:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80116a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80116f:	85 c0                	test   %eax,%eax
  801171:	74 0b                	je     80117e <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	56                   	push   %esi
  801177:	ff d0                	call   *%eax
  801179:	89 c3                	mov    %eax,%ebx
  80117b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	56                   	push   %esi
  801182:	6a 00                	push   $0x0
  801184:	e8 7c fa ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	eb b5                	jmp    801143 <fd_close+0x3c>

0080118e <close>:

int
close(int fdnum)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	ff 75 08             	push   0x8(%ebp)
  80119b:	e8 c6 fe ff ff       	call   801066 <fd_lookup>
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	79 02                	jns    8011a9 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    
		return fd_close(fd, 1);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	6a 01                	push   $0x1
  8011ae:	ff 75 f4             	push   -0xc(%ebp)
  8011b1:	e8 51 ff ff ff       	call   801107 <fd_close>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	eb ec                	jmp    8011a7 <close+0x19>

008011bb <close_all>:

void
close_all(void)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	53                   	push   %ebx
  8011cb:	e8 be ff ff ff       	call   80118e <close>
	for (i = 0; i < MAXFD; i++)
  8011d0:	83 c3 01             	add    $0x1,%ebx
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	83 fb 20             	cmp    $0x20,%ebx
  8011d9:	75 ec                	jne    8011c7 <close_all+0xc>
}
  8011db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	ff 75 08             	push   0x8(%ebp)
  8011f0:	e8 71 fe ff ff       	call   801066 <fd_lookup>
  8011f5:	89 c3                	mov    %eax,%ebx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 7f                	js     80127d <dup+0x9d>
		return r;
	close(newfdnum);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	ff 75 0c             	push   0xc(%ebp)
  801204:	e8 85 ff ff ff       	call   80118e <close>

	newfd = INDEX2FD(newfdnum);
  801209:	8b 75 0c             	mov    0xc(%ebp),%esi
  80120c:	c1 e6 0c             	shl    $0xc,%esi
  80120f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801215:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801218:	89 3c 24             	mov    %edi,(%esp)
  80121b:	e8 df fd ff ff       	call   800fff <fd2data>
  801220:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801222:	89 34 24             	mov    %esi,(%esp)
  801225:	e8 d5 fd ff ff       	call   800fff <fd2data>
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801230:	89 d8                	mov    %ebx,%eax
  801232:	c1 e8 16             	shr    $0x16,%eax
  801235:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80123c:	a8 01                	test   $0x1,%al
  80123e:	74 11                	je     801251 <dup+0x71>
  801240:	89 d8                	mov    %ebx,%eax
  801242:	c1 e8 0c             	shr    $0xc,%eax
  801245:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	75 36                	jne    801287 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801251:	89 f8                	mov    %edi,%eax
  801253:	c1 e8 0c             	shr    $0xc,%eax
  801256:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80125d:	83 ec 0c             	sub    $0xc,%esp
  801260:	25 07 0e 00 00       	and    $0xe07,%eax
  801265:	50                   	push   %eax
  801266:	56                   	push   %esi
  801267:	6a 00                	push   $0x0
  801269:	57                   	push   %edi
  80126a:	6a 00                	push   $0x0
  80126c:	e8 52 f9 ff ff       	call   800bc3 <sys_page_map>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 20             	add    $0x20,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 33                	js     8012ad <dup+0xcd>
		goto err;

	return newfdnum;
  80127a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80127d:	89 d8                	mov    %ebx,%eax
  80127f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801287:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128e:	83 ec 0c             	sub    $0xc,%esp
  801291:	25 07 0e 00 00       	and    $0xe07,%eax
  801296:	50                   	push   %eax
  801297:	ff 75 d4             	push   -0x2c(%ebp)
  80129a:	6a 00                	push   $0x0
  80129c:	53                   	push   %ebx
  80129d:	6a 00                	push   $0x0
  80129f:	e8 1f f9 ff ff       	call   800bc3 <sys_page_map>
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 20             	add    $0x20,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	79 a4                	jns    801251 <dup+0x71>
	sys_page_unmap(0, newfd);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	56                   	push   %esi
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 4d f9 ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b8:	83 c4 08             	add    $0x8,%esp
  8012bb:	ff 75 d4             	push   -0x2c(%ebp)
  8012be:	6a 00                	push   $0x0
  8012c0:	e8 40 f9 ff ff       	call   800c05 <sys_page_unmap>
	return r;
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	eb b3                	jmp    80127d <dup+0x9d>

008012ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 18             	sub    $0x18,%esp
  8012d2:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	56                   	push   %esi
  8012da:	e8 87 fd ff ff       	call   801066 <fd_lookup>
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 3c                	js     801322 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 33                	push   (%ebx)
  8012f2:	e8 bf fd ff ff       	call   8010b6 <dev_lookup>
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 24                	js     801322 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012fe:	8b 43 08             	mov    0x8(%ebx),%eax
  801301:	83 e0 03             	and    $0x3,%eax
  801304:	83 f8 01             	cmp    $0x1,%eax
  801307:	74 20                	je     801329 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130c:	8b 40 08             	mov    0x8(%eax),%eax
  80130f:	85 c0                	test   %eax,%eax
  801311:	74 37                	je     80134a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	ff 75 10             	push   0x10(%ebp)
  801319:	ff 75 0c             	push   0xc(%ebp)
  80131c:	53                   	push   %ebx
  80131d:	ff d0                	call   *%eax
  80131f:	83 c4 10             	add    $0x10,%esp
}
  801322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801329:	a1 00 40 80 00       	mov    0x804000,%eax
  80132e:	8b 40 48             	mov    0x48(%eax),%eax
  801331:	83 ec 04             	sub    $0x4,%esp
  801334:	56                   	push   %esi
  801335:	50                   	push   %eax
  801336:	68 d9 25 80 00       	push   $0x8025d9
  80133b:	e8 6a ee ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801348:	eb d8                	jmp    801322 <read+0x58>
		return -E_NOT_SUPP;
  80134a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80134f:	eb d1                	jmp    801322 <read+0x58>

00801351 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	57                   	push   %edi
  801355:	56                   	push   %esi
  801356:	53                   	push   %ebx
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80135d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801360:	bb 00 00 00 00       	mov    $0x0,%ebx
  801365:	eb 02                	jmp    801369 <readn+0x18>
  801367:	01 c3                	add    %eax,%ebx
  801369:	39 f3                	cmp    %esi,%ebx
  80136b:	73 21                	jae    80138e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	89 f0                	mov    %esi,%eax
  801372:	29 d8                	sub    %ebx,%eax
  801374:	50                   	push   %eax
  801375:	89 d8                	mov    %ebx,%eax
  801377:	03 45 0c             	add    0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	57                   	push   %edi
  80137c:	e8 49 ff ff ff       	call   8012ca <read>
		if (m < 0)
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 04                	js     80138c <readn+0x3b>
			return m;
		if (m == 0)
  801388:	75 dd                	jne    801367 <readn+0x16>
  80138a:	eb 02                	jmp    80138e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80138c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80138e:	89 d8                	mov    %ebx,%eax
  801390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
  80139d:	83 ec 18             	sub    $0x18,%esp
  8013a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	53                   	push   %ebx
  8013a8:	e8 b9 fc ff ff       	call   801066 <fd_lookup>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 37                	js     8013eb <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	ff 36                	push   (%esi)
  8013c0:	e8 f1 fc ff ff       	call   8010b6 <dev_lookup>
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 1f                	js     8013eb <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013cc:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8013d0:	74 20                	je     8013f2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	74 37                	je     801413 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	ff 75 10             	push   0x10(%ebp)
  8013e2:	ff 75 0c             	push   0xc(%ebp)
  8013e5:	56                   	push   %esi
  8013e6:	ff d0                	call   *%eax
  8013e8:	83 c4 10             	add    $0x10,%esp
}
  8013eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ee:	5b                   	pop    %ebx
  8013ef:	5e                   	pop    %esi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013f7:	8b 40 48             	mov    0x48(%eax),%eax
  8013fa:	83 ec 04             	sub    $0x4,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	50                   	push   %eax
  8013ff:	68 f5 25 80 00       	push   $0x8025f5
  801404:	e8 a1 ed ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801411:	eb d8                	jmp    8013eb <write+0x53>
		return -E_NOT_SUPP;
  801413:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801418:	eb d1                	jmp    8013eb <write+0x53>

0080141a <seek>:

int
seek(int fdnum, off_t offset)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	ff 75 08             	push   0x8(%ebp)
  801427:	e8 3a fc ff ff       	call   801066 <fd_lookup>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 0e                	js     801441 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801433:	8b 55 0c             	mov    0xc(%ebp),%edx
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80143c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	83 ec 18             	sub    $0x18,%esp
  80144b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	53                   	push   %ebx
  801453:	e8 0e fc ff ff       	call   801066 <fd_lookup>
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 34                	js     801493 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	ff 36                	push   (%esi)
  80146b:	e8 46 fc ff ff       	call   8010b6 <dev_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 1c                	js     801493 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801477:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80147b:	74 1d                	je     80149a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801480:	8b 40 18             	mov    0x18(%eax),%eax
  801483:	85 c0                	test   %eax,%eax
  801485:	74 34                	je     8014bb <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	ff 75 0c             	push   0xc(%ebp)
  80148d:	56                   	push   %esi
  80148e:	ff d0                	call   *%eax
  801490:	83 c4 10             	add    $0x10,%esp
}
  801493:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801496:	5b                   	pop    %ebx
  801497:	5e                   	pop    %esi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    
			thisenv->env_id, fdnum);
  80149a:	a1 00 40 80 00       	mov    0x804000,%eax
  80149f:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	53                   	push   %ebx
  8014a6:	50                   	push   %eax
  8014a7:	68 b8 25 80 00       	push   $0x8025b8
  8014ac:	e8 f9 ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b9:	eb d8                	jmp    801493 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8014bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c0:	eb d1                	jmp    801493 <ftruncate+0x50>

008014c2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 18             	sub    $0x18,%esp
  8014ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	ff 75 08             	push   0x8(%ebp)
  8014d4:	e8 8d fb ff ff       	call   801066 <fd_lookup>
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 49                	js     801529 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	ff 36                	push   (%esi)
  8014ec:	e8 c5 fb ff ff       	call   8010b6 <dev_lookup>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 31                	js     801529 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8014f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014ff:	74 2f                	je     801530 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801501:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801504:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80150b:	00 00 00 
	stat->st_isdir = 0;
  80150e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801515:	00 00 00 
	stat->st_dev = dev;
  801518:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	53                   	push   %ebx
  801522:	56                   	push   %esi
  801523:	ff 50 14             	call   *0x14(%eax)
  801526:	83 c4 10             	add    $0x10,%esp
}
  801529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
		return -E_NOT_SUPP;
  801530:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801535:	eb f2                	jmp    801529 <fstat+0x67>

00801537 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	56                   	push   %esi
  80153b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	6a 00                	push   $0x0
  801541:	ff 75 08             	push   0x8(%ebp)
  801544:	e8 e4 01 00 00       	call   80172d <open>
  801549:	89 c3                	mov    %eax,%ebx
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 1b                	js     80156d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	ff 75 0c             	push   0xc(%ebp)
  801558:	50                   	push   %eax
  801559:	e8 64 ff ff ff       	call   8014c2 <fstat>
  80155e:	89 c6                	mov    %eax,%esi
	close(fd);
  801560:	89 1c 24             	mov    %ebx,(%esp)
  801563:	e8 26 fc ff ff       	call   80118e <close>
	return r;
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	89 f3                	mov    %esi,%ebx
}
  80156d:	89 d8                	mov    %ebx,%eax
  80156f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	89 c6                	mov    %eax,%esi
  80157d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80157f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801586:	74 27                	je     8015af <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801588:	6a 07                	push   $0x7
  80158a:	68 00 50 80 00       	push   $0x805000
  80158f:	56                   	push   %esi
  801590:	ff 35 00 60 80 00    	push   0x806000
  801596:	e8 3e 08 00 00       	call   801dd9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80159b:	83 c4 0c             	add    $0xc,%esp
  80159e:	6a 00                	push   $0x0
  8015a0:	53                   	push   %ebx
  8015a1:	6a 00                	push   $0x0
  8015a3:	e8 ca 07 00 00       	call   801d72 <ipc_recv>
}
  8015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	6a 01                	push   $0x1
  8015b4:	e8 74 08 00 00       	call   801e2d <ipc_find_env>
  8015b9:	a3 00 60 80 00       	mov    %eax,0x806000
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	eb c5                	jmp    801588 <fsipc+0x12>

008015c3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e1:	b8 02 00 00 00       	mov    $0x2,%eax
  8015e6:	e8 8b ff ff ff       	call   801576 <fsipc>
}
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <devfile_flush>:
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801603:	b8 06 00 00 00       	mov    $0x6,%eax
  801608:	e8 69 ff ff ff       	call   801576 <fsipc>
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <devfile_stat>:
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	8b 40 0c             	mov    0xc(%eax),%eax
  80161f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801624:	ba 00 00 00 00       	mov    $0x0,%edx
  801629:	b8 05 00 00 00       	mov    $0x5,%eax
  80162e:	e8 43 ff ff ff       	call   801576 <fsipc>
  801633:	85 c0                	test   %eax,%eax
  801635:	78 2c                	js     801663 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	68 00 50 80 00       	push   $0x805000
  80163f:	53                   	push   %ebx
  801640:	e8 3f f1 ff ff       	call   800784 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801645:	a1 80 50 80 00       	mov    0x805080,%eax
  80164a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801650:	a1 84 50 80 00       	mov    0x805084,%eax
  801655:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801663:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <devfile_write>:
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	8b 45 10             	mov    0x10(%ebp),%eax
  801671:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801676:	39 d0                	cmp    %edx,%eax
  801678:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80167b:	8b 55 08             	mov    0x8(%ebp),%edx
  80167e:	8b 52 0c             	mov    0xc(%edx),%edx
  801681:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801687:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80168c:	50                   	push   %eax
  80168d:	ff 75 0c             	push   0xc(%ebp)
  801690:	68 08 50 80 00       	push   $0x805008
  801695:	e8 80 f2 ff ff       	call   80091a <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80169a:	ba 00 00 00 00       	mov    $0x0,%edx
  80169f:	b8 04 00 00 00       	mov    $0x4,%eax
  8016a4:	e8 cd fe ff ff       	call   801576 <fsipc>
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <devfile_read>:
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	56                   	push   %esi
  8016af:	53                   	push   %ebx
  8016b0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ce:	e8 a3 fe ff ff       	call   801576 <fsipc>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 1f                	js     8016f8 <devfile_read+0x4d>
	assert(r <= n);
  8016d9:	39 f0                	cmp    %esi,%eax
  8016db:	77 24                	ja     801701 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8016dd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016e2:	7f 33                	jg     801717 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	50                   	push   %eax
  8016e8:	68 00 50 80 00       	push   $0x805000
  8016ed:	ff 75 0c             	push   0xc(%ebp)
  8016f0:	e8 25 f2 ff ff       	call   80091a <memmove>
	return r;
  8016f5:	83 c4 10             	add    $0x10,%esp
}
  8016f8:	89 d8                	mov    %ebx,%eax
  8016fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    
	assert(r <= n);
  801701:	68 24 26 80 00       	push   $0x802624
  801706:	68 2b 26 80 00       	push   $0x80262b
  80170b:	6a 7c                	push   $0x7c
  80170d:	68 40 26 80 00       	push   $0x802640
  801712:	e8 79 05 00 00       	call   801c90 <_panic>
	assert(r <= PGSIZE);
  801717:	68 4b 26 80 00       	push   $0x80264b
  80171c:	68 2b 26 80 00       	push   $0x80262b
  801721:	6a 7d                	push   $0x7d
  801723:	68 40 26 80 00       	push   $0x802640
  801728:	e8 63 05 00 00       	call   801c90 <_panic>

0080172d <open>:
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	83 ec 1c             	sub    $0x1c,%esp
  801735:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801738:	56                   	push   %esi
  801739:	e8 0b f0 ff ff       	call   800749 <strlen>
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801746:	7f 6c                	jg     8017b4 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801748:	83 ec 0c             	sub    $0xc,%esp
  80174b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	e8 c2 f8 ff ff       	call   801016 <fd_alloc>
  801754:	89 c3                	mov    %eax,%ebx
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 3c                	js     801799 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	56                   	push   %esi
  801761:	68 00 50 80 00       	push   $0x805000
  801766:	e8 19 f0 ff ff       	call   800784 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801773:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801776:	b8 01 00 00 00       	mov    $0x1,%eax
  80177b:	e8 f6 fd ff ff       	call   801576 <fsipc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 19                	js     8017a2 <open+0x75>
	return fd2num(fd);
  801789:	83 ec 0c             	sub    $0xc,%esp
  80178c:	ff 75 f4             	push   -0xc(%ebp)
  80178f:	e8 5b f8 ff ff       	call   800fef <fd2num>
  801794:	89 c3                	mov    %eax,%ebx
  801796:	83 c4 10             	add    $0x10,%esp
}
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    
		fd_close(fd, 0);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	6a 00                	push   $0x0
  8017a7:	ff 75 f4             	push   -0xc(%ebp)
  8017aa:	e8 58 f9 ff ff       	call   801107 <fd_close>
		return r;
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb e5                	jmp    801799 <open+0x6c>
		return -E_BAD_PATH;
  8017b4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8017b9:	eb de                	jmp    801799 <open+0x6c>

008017bb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8017cb:	e8 a6 fd ff ff       	call   801576 <fsipc>
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	ff 75 08             	push   0x8(%ebp)
  8017e0:	e8 1a f8 ff ff       	call   800fff <fd2data>
  8017e5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017e7:	83 c4 08             	add    $0x8,%esp
  8017ea:	68 57 26 80 00       	push   $0x802657
  8017ef:	53                   	push   %ebx
  8017f0:	e8 8f ef ff ff       	call   800784 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f5:	8b 46 04             	mov    0x4(%esi),%eax
  8017f8:	2b 06                	sub    (%esi),%eax
  8017fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801800:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801807:	00 00 00 
	stat->st_dev = &devpipe;
  80180a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801811:	30 80 00 
	return 0;
}
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
  801819:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80182a:	53                   	push   %ebx
  80182b:	6a 00                	push   $0x0
  80182d:	e8 d3 f3 ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801832:	89 1c 24             	mov    %ebx,(%esp)
  801835:	e8 c5 f7 ff ff       	call   800fff <fd2data>
  80183a:	83 c4 08             	add    $0x8,%esp
  80183d:	50                   	push   %eax
  80183e:	6a 00                	push   $0x0
  801840:	e8 c0 f3 ff ff       	call   800c05 <sys_page_unmap>
}
  801845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <_pipeisclosed>:
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	83 ec 1c             	sub    $0x1c,%esp
  801853:	89 c7                	mov    %eax,%edi
  801855:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801857:	a1 00 40 80 00       	mov    0x804000,%eax
  80185c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	57                   	push   %edi
  801863:	e8 fe 05 00 00       	call   801e66 <pageref>
  801868:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80186b:	89 34 24             	mov    %esi,(%esp)
  80186e:	e8 f3 05 00 00       	call   801e66 <pageref>
		nn = thisenv->env_runs;
  801873:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801879:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	39 cb                	cmp    %ecx,%ebx
  801881:	74 1b                	je     80189e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801883:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801886:	75 cf                	jne    801857 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801888:	8b 42 58             	mov    0x58(%edx),%eax
  80188b:	6a 01                	push   $0x1
  80188d:	50                   	push   %eax
  80188e:	53                   	push   %ebx
  80188f:	68 5e 26 80 00       	push   $0x80265e
  801894:	e8 11 e9 ff ff       	call   8001aa <cprintf>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	eb b9                	jmp    801857 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80189e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018a1:	0f 94 c0             	sete   %al
  8018a4:	0f b6 c0             	movzbl %al,%eax
}
  8018a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5f                   	pop    %edi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <devpipe_write>:
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	57                   	push   %edi
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 28             	sub    $0x28,%esp
  8018b8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018bb:	56                   	push   %esi
  8018bc:	e8 3e f7 ff ff       	call   800fff <fd2data>
  8018c1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8018cb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018ce:	75 09                	jne    8018d9 <devpipe_write+0x2a>
	return i;
  8018d0:	89 f8                	mov    %edi,%eax
  8018d2:	eb 23                	jmp    8018f7 <devpipe_write+0x48>
			sys_yield();
  8018d4:	e8 88 f2 ff ff       	call   800b61 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8018dc:	8b 0b                	mov    (%ebx),%ecx
  8018de:	8d 51 20             	lea    0x20(%ecx),%edx
  8018e1:	39 d0                	cmp    %edx,%eax
  8018e3:	72 1a                	jb     8018ff <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8018e5:	89 da                	mov    %ebx,%edx
  8018e7:	89 f0                	mov    %esi,%eax
  8018e9:	e8 5c ff ff ff       	call   80184a <_pipeisclosed>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	74 e2                	je     8018d4 <devpipe_write+0x25>
				return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5f                   	pop    %edi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801902:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801906:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801909:	89 c2                	mov    %eax,%edx
  80190b:	c1 fa 1f             	sar    $0x1f,%edx
  80190e:	89 d1                	mov    %edx,%ecx
  801910:	c1 e9 1b             	shr    $0x1b,%ecx
  801913:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801916:	83 e2 1f             	and    $0x1f,%edx
  801919:	29 ca                	sub    %ecx,%edx
  80191b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80191f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801923:	83 c0 01             	add    $0x1,%eax
  801926:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801929:	83 c7 01             	add    $0x1,%edi
  80192c:	eb 9d                	jmp    8018cb <devpipe_write+0x1c>

0080192e <devpipe_read>:
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 18             	sub    $0x18,%esp
  801937:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80193a:	57                   	push   %edi
  80193b:	e8 bf f6 ff ff       	call   800fff <fd2data>
  801940:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	be 00 00 00 00       	mov    $0x0,%esi
  80194a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80194d:	75 13                	jne    801962 <devpipe_read+0x34>
	return i;
  80194f:	89 f0                	mov    %esi,%eax
  801951:	eb 02                	jmp    801955 <devpipe_read+0x27>
				return i;
  801953:	89 f0                	mov    %esi,%eax
}
  801955:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5f                   	pop    %edi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    
			sys_yield();
  80195d:	e8 ff f1 ff ff       	call   800b61 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801962:	8b 03                	mov    (%ebx),%eax
  801964:	3b 43 04             	cmp    0x4(%ebx),%eax
  801967:	75 18                	jne    801981 <devpipe_read+0x53>
			if (i > 0)
  801969:	85 f6                	test   %esi,%esi
  80196b:	75 e6                	jne    801953 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80196d:	89 da                	mov    %ebx,%edx
  80196f:	89 f8                	mov    %edi,%eax
  801971:	e8 d4 fe ff ff       	call   80184a <_pipeisclosed>
  801976:	85 c0                	test   %eax,%eax
  801978:	74 e3                	je     80195d <devpipe_read+0x2f>
				return 0;
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
  80197f:	eb d4                	jmp    801955 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801981:	99                   	cltd   
  801982:	c1 ea 1b             	shr    $0x1b,%edx
  801985:	01 d0                	add    %edx,%eax
  801987:	83 e0 1f             	and    $0x1f,%eax
  80198a:	29 d0                	sub    %edx,%eax
  80198c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801991:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801994:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801997:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80199a:	83 c6 01             	add    $0x1,%esi
  80199d:	eb ab                	jmp    80194a <devpipe_read+0x1c>

0080199f <pipe>:
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	e8 66 f6 ff ff       	call   801016 <fd_alloc>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	0f 88 23 01 00 00    	js     801ae0 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	68 07 04 00 00       	push   $0x407
  8019c5:	ff 75 f4             	push   -0xc(%ebp)
  8019c8:	6a 00                	push   $0x0
  8019ca:	e8 b1 f1 ff ff       	call   800b80 <sys_page_alloc>
  8019cf:	89 c3                	mov    %eax,%ebx
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	0f 88 04 01 00 00    	js     801ae0 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	e8 2e f6 ff ff       	call   801016 <fd_alloc>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	0f 88 db 00 00 00    	js     801ad0 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f5:	83 ec 04             	sub    $0x4,%esp
  8019f8:	68 07 04 00 00       	push   $0x407
  8019fd:	ff 75 f0             	push   -0x10(%ebp)
  801a00:	6a 00                	push   $0x0
  801a02:	e8 79 f1 ff ff       	call   800b80 <sys_page_alloc>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	0f 88 bc 00 00 00    	js     801ad0 <pipe+0x131>
	va = fd2data(fd0);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	ff 75 f4             	push   -0xc(%ebp)
  801a1a:	e8 e0 f5 ff ff       	call   800fff <fd2data>
  801a1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a21:	83 c4 0c             	add    $0xc,%esp
  801a24:	68 07 04 00 00       	push   $0x407
  801a29:	50                   	push   %eax
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 4f f1 ff ff       	call   800b80 <sys_page_alloc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 82 00 00 00    	js     801ac0 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	ff 75 f0             	push   -0x10(%ebp)
  801a44:	e8 b6 f5 ff ff       	call   800fff <fd2data>
  801a49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a50:	50                   	push   %eax
  801a51:	6a 00                	push   $0x0
  801a53:	56                   	push   %esi
  801a54:	6a 00                	push   $0x0
  801a56:	e8 68 f1 ff ff       	call   800bc3 <sys_page_map>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	83 c4 20             	add    $0x20,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 4e                	js     801ab2 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801a64:	a1 20 30 80 00       	mov    0x803020,%eax
  801a69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a6c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801a6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a71:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801a78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a7b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	ff 75 f4             	push   -0xc(%ebp)
  801a8d:	e8 5d f5 ff ff       	call   800fef <fd2num>
  801a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a95:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a97:	83 c4 04             	add    $0x4,%esp
  801a9a:	ff 75 f0             	push   -0x10(%ebp)
  801a9d:	e8 4d f5 ff ff       	call   800fef <fd2num>
  801aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ab0:	eb 2e                	jmp    801ae0 <pipe+0x141>
	sys_page_unmap(0, va);
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	56                   	push   %esi
  801ab6:	6a 00                	push   $0x0
  801ab8:	e8 48 f1 ff ff       	call   800c05 <sys_page_unmap>
  801abd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ac0:	83 ec 08             	sub    $0x8,%esp
  801ac3:	ff 75 f0             	push   -0x10(%ebp)
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 38 f1 ff ff       	call   800c05 <sys_page_unmap>
  801acd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ad0:	83 ec 08             	sub    $0x8,%esp
  801ad3:	ff 75 f4             	push   -0xc(%ebp)
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 28 f1 ff ff       	call   800c05 <sys_page_unmap>
  801add:	83 c4 10             	add    $0x10,%esp
}
  801ae0:	89 d8                	mov    %ebx,%eax
  801ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <pipeisclosed>:
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af2:	50                   	push   %eax
  801af3:	ff 75 08             	push   0x8(%ebp)
  801af6:	e8 6b f5 ff ff       	call   801066 <fd_lookup>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 18                	js     801b1a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	ff 75 f4             	push   -0xc(%ebp)
  801b08:	e8 f2 f4 ff ff       	call   800fff <fd2data>
  801b0d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b12:	e8 33 fd ff ff       	call   80184a <_pipeisclosed>
  801b17:	83 c4 10             	add    $0x10,%esp
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b21:	c3                   	ret    

00801b22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b28:	68 76 26 80 00       	push   $0x802676
  801b2d:	ff 75 0c             	push   0xc(%ebp)
  801b30:	e8 4f ec ff ff       	call   800784 <strcpy>
	return 0;
}
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <devcons_write>:
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b48:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b4d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b53:	eb 2e                	jmp    801b83 <devcons_write+0x47>
		m = n - tot;
  801b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b58:	29 f3                	sub    %esi,%ebx
  801b5a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b5f:	39 c3                	cmp    %eax,%ebx
  801b61:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b64:	83 ec 04             	sub    $0x4,%esp
  801b67:	53                   	push   %ebx
  801b68:	89 f0                	mov    %esi,%eax
  801b6a:	03 45 0c             	add    0xc(%ebp),%eax
  801b6d:	50                   	push   %eax
  801b6e:	57                   	push   %edi
  801b6f:	e8 a6 ed ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  801b74:	83 c4 08             	add    $0x8,%esp
  801b77:	53                   	push   %ebx
  801b78:	57                   	push   %edi
  801b79:	e8 46 ef ff ff       	call   800ac4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b7e:	01 de                	add    %ebx,%esi
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b86:	72 cd                	jb     801b55 <devcons_write+0x19>
}
  801b88:	89 f0                	mov    %esi,%eax
  801b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5f                   	pop    %edi
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    

00801b92 <devcons_read>:
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 08             	sub    $0x8,%esp
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ba1:	75 07                	jne    801baa <devcons_read+0x18>
  801ba3:	eb 1f                	jmp    801bc4 <devcons_read+0x32>
		sys_yield();
  801ba5:	e8 b7 ef ff ff       	call   800b61 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801baa:	e8 33 ef ff ff       	call   800ae2 <sys_cgetc>
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	74 f2                	je     801ba5 <devcons_read+0x13>
	if (c < 0)
  801bb3:	78 0f                	js     801bc4 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801bb5:	83 f8 04             	cmp    $0x4,%eax
  801bb8:	74 0c                	je     801bc6 <devcons_read+0x34>
	*(char*)vbuf = c;
  801bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbd:	88 02                	mov    %al,(%edx)
	return 1;
  801bbf:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    
		return 0;
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcb:	eb f7                	jmp    801bc4 <devcons_read+0x32>

00801bcd <cputchar>:
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801bd9:	6a 01                	push   $0x1
  801bdb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	e8 e0 ee ff ff       	call   800ac4 <sys_cputs>
}
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <getchar>:
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801bef:	6a 01                	push   $0x1
  801bf1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	6a 00                	push   $0x0
  801bf7:	e8 ce f6 ff ff       	call   8012ca <read>
	if (r < 0)
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 06                	js     801c09 <getchar+0x20>
	if (r < 1)
  801c03:	74 06                	je     801c0b <getchar+0x22>
	return c;
  801c05:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    
		return -E_EOF;
  801c0b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c10:	eb f7                	jmp    801c09 <getchar+0x20>

00801c12 <iscons>:
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1b:	50                   	push   %eax
  801c1c:	ff 75 08             	push   0x8(%ebp)
  801c1f:	e8 42 f4 ff ff       	call   801066 <fd_lookup>
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 11                	js     801c3c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c34:	39 10                	cmp    %edx,(%eax)
  801c36:	0f 94 c0             	sete   %al
  801c39:	0f b6 c0             	movzbl %al,%eax
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <opencons>:
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c47:	50                   	push   %eax
  801c48:	e8 c9 f3 ff ff       	call   801016 <fd_alloc>
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 3a                	js     801c8e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	68 07 04 00 00       	push   $0x407
  801c5c:	ff 75 f4             	push   -0xc(%ebp)
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 1a ef ff ff       	call   800b80 <sys_page_alloc>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 21                	js     801c8e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c76:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	50                   	push   %eax
  801c86:	e8 64 f3 ff ff       	call   800fef <fd2num>
  801c8b:	83 c4 10             	add    $0x10,%esp
}
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c95:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c98:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c9e:	e8 9f ee ff ff       	call   800b42 <sys_getenvid>
  801ca3:	83 ec 0c             	sub    $0xc,%esp
  801ca6:	ff 75 0c             	push   0xc(%ebp)
  801ca9:	ff 75 08             	push   0x8(%ebp)
  801cac:	56                   	push   %esi
  801cad:	50                   	push   %eax
  801cae:	68 84 26 80 00       	push   $0x802684
  801cb3:	e8 f2 e4 ff ff       	call   8001aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cb8:	83 c4 18             	add    $0x18,%esp
  801cbb:	53                   	push   %ebx
  801cbc:	ff 75 10             	push   0x10(%ebp)
  801cbf:	e8 95 e4 ff ff       	call   800159 <vcprintf>
	cprintf("\n");
  801cc4:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  801ccb:	e8 da e4 ff ff       	call   8001aa <cprintf>
  801cd0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cd3:	cc                   	int3   
  801cd4:	eb fd                	jmp    801cd3 <_panic+0x43>

00801cd6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801cdc:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801ce3:	74 0a                	je     801cef <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce8:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801cef:	e8 4e ee ff ff       	call   800b42 <sys_getenvid>
  801cf4:	83 ec 04             	sub    $0x4,%esp
  801cf7:	68 07 0e 00 00       	push   $0xe07
  801cfc:	68 00 f0 bf ee       	push   $0xeebff000
  801d01:	50                   	push   %eax
  801d02:	e8 79 ee ff ff       	call   800b80 <sys_page_alloc>
		if (r < 0) {
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 2c                	js     801d3a <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801d0e:	e8 2f ee ff ff       	call   800b42 <sys_getenvid>
  801d13:	83 ec 08             	sub    $0x8,%esp
  801d16:	68 4c 1d 80 00       	push   $0x801d4c
  801d1b:	50                   	push   %eax
  801d1c:	e8 aa ef ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	79 bd                	jns    801ce5 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801d28:	50                   	push   %eax
  801d29:	68 e8 26 80 00       	push   $0x8026e8
  801d2e:	6a 28                	push   $0x28
  801d30:	68 1e 27 80 00       	push   $0x80271e
  801d35:	e8 56 ff ff ff       	call   801c90 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801d3a:	50                   	push   %eax
  801d3b:	68 a8 26 80 00       	push   $0x8026a8
  801d40:	6a 23                	push   $0x23
  801d42:	68 1e 27 80 00       	push   $0x80271e
  801d47:	e8 44 ff ff ff       	call   801c90 <_panic>

00801d4c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d4c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d4d:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801d52:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d54:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801d57:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801d5b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801d5e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801d62:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801d66:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801d68:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801d6b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801d6c:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801d6f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801d70:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801d71:	c3                   	ret    

00801d72 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	56                   	push   %esi
  801d76:	53                   	push   %ebx
  801d77:	8b 75 08             	mov    0x8(%ebp),%esi
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801d80:	85 c0                	test   %eax,%eax
  801d82:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d87:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801d8a:	83 ec 0c             	sub    $0xc,%esp
  801d8d:	50                   	push   %eax
  801d8e:	e8 9d ef ff ff       	call   800d30 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 f6                	test   %esi,%esi
  801d98:	74 14                	je     801dae <ipc_recv+0x3c>
  801d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 09                	js     801dac <ipc_recv+0x3a>
  801da3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801da9:	8b 52 74             	mov    0x74(%edx),%edx
  801dac:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801dae:	85 db                	test   %ebx,%ebx
  801db0:	74 14                	je     801dc6 <ipc_recv+0x54>
  801db2:	ba 00 00 00 00       	mov    $0x0,%edx
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 09                	js     801dc4 <ipc_recv+0x52>
  801dbb:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801dc1:	8b 52 78             	mov    0x78(%edx),%edx
  801dc4:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 08                	js     801dd2 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801dca:	a1 00 40 80 00       	mov    0x804000,%eax
  801dcf:	8b 40 70             	mov    0x70(%eax),%eax
}
  801dd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	57                   	push   %edi
  801ddd:	56                   	push   %esi
  801dde:	53                   	push   %ebx
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801de8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801deb:	85 db                	test   %ebx,%ebx
  801ded:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801df2:	0f 44 d8             	cmove  %eax,%ebx
  801df5:	eb 05                	jmp    801dfc <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801df7:	e8 65 ed ff ff       	call   800b61 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801dfc:	ff 75 14             	push   0x14(%ebp)
  801dff:	53                   	push   %ebx
  801e00:	56                   	push   %esi
  801e01:	57                   	push   %edi
  801e02:	e8 06 ef ff ff       	call   800d0d <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e0d:	74 e8                	je     801df7 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 08                	js     801e1b <ipc_send+0x42>
	}while (r<0);

}
  801e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e16:	5b                   	pop    %ebx
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801e1b:	50                   	push   %eax
  801e1c:	68 2c 27 80 00       	push   $0x80272c
  801e21:	6a 3d                	push   $0x3d
  801e23:	68 40 27 80 00       	push   $0x802740
  801e28:	e8 63 fe ff ff       	call   801c90 <_panic>

00801e2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e38:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e3b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e41:	8b 52 50             	mov    0x50(%edx),%edx
  801e44:	39 ca                	cmp    %ecx,%edx
  801e46:	74 11                	je     801e59 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801e48:	83 c0 01             	add    $0x1,%eax
  801e4b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e50:	75 e6                	jne    801e38 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	eb 0b                	jmp    801e64 <ipc_find_env+0x37>
			return envs[i].env_id;
  801e59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e61:	8b 40 48             	mov    0x48(%eax),%eax
}
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	c1 ea 16             	shr    $0x16,%edx
  801e71:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801e78:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801e7d:	f6 c1 01             	test   $0x1,%cl
  801e80:	74 1c                	je     801e9e <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801e82:	c1 e8 0c             	shr    $0xc,%eax
  801e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e8c:	a8 01                	test   $0x1,%al
  801e8e:	74 0e                	je     801e9e <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e90:	c1 e8 0c             	shr    $0xc,%eax
  801e93:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801e9a:	ef 
  801e9b:	0f b7 d2             	movzwl %dx,%edx
}
  801e9e:	89 d0                	mov    %edx,%eax
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    
  801ea2:	66 90                	xchg   %ax,%ax
  801ea4:	66 90                	xchg   %ax,%ax
  801ea6:	66 90                	xchg   %ax,%ax
  801ea8:	66 90                	xchg   %ax,%ax
  801eaa:	66 90                	xchg   %ax,%ax
  801eac:	66 90                	xchg   %ax,%ax
  801eae:	66 90                	xchg   %ax,%ax

00801eb0 <__udivdi3>:
  801eb0:	f3 0f 1e fb          	endbr32 
  801eb4:	55                   	push   %ebp
  801eb5:	57                   	push   %edi
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	83 ec 1c             	sub    $0x1c,%esp
  801ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ebf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ec3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ec7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	75 19                	jne    801ee8 <__udivdi3+0x38>
  801ecf:	39 f3                	cmp    %esi,%ebx
  801ed1:	76 4d                	jbe    801f20 <__udivdi3+0x70>
  801ed3:	31 ff                	xor    %edi,%edi
  801ed5:	89 e8                	mov    %ebp,%eax
  801ed7:	89 f2                	mov    %esi,%edx
  801ed9:	f7 f3                	div    %ebx
  801edb:	89 fa                	mov    %edi,%edx
  801edd:	83 c4 1c             	add    $0x1c,%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    
  801ee5:	8d 76 00             	lea    0x0(%esi),%esi
  801ee8:	39 f0                	cmp    %esi,%eax
  801eea:	76 14                	jbe    801f00 <__udivdi3+0x50>
  801eec:	31 ff                	xor    %edi,%edi
  801eee:	31 c0                	xor    %eax,%eax
  801ef0:	89 fa                	mov    %edi,%edx
  801ef2:	83 c4 1c             	add    $0x1c,%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
  801efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f00:	0f bd f8             	bsr    %eax,%edi
  801f03:	83 f7 1f             	xor    $0x1f,%edi
  801f06:	75 48                	jne    801f50 <__udivdi3+0xa0>
  801f08:	39 f0                	cmp    %esi,%eax
  801f0a:	72 06                	jb     801f12 <__udivdi3+0x62>
  801f0c:	31 c0                	xor    %eax,%eax
  801f0e:	39 eb                	cmp    %ebp,%ebx
  801f10:	77 de                	ja     801ef0 <__udivdi3+0x40>
  801f12:	b8 01 00 00 00       	mov    $0x1,%eax
  801f17:	eb d7                	jmp    801ef0 <__udivdi3+0x40>
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	89 d9                	mov    %ebx,%ecx
  801f22:	85 db                	test   %ebx,%ebx
  801f24:	75 0b                	jne    801f31 <__udivdi3+0x81>
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f3                	div    %ebx
  801f2f:	89 c1                	mov    %eax,%ecx
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	89 f0                	mov    %esi,%eax
  801f35:	f7 f1                	div    %ecx
  801f37:	89 c6                	mov    %eax,%esi
  801f39:	89 e8                	mov    %ebp,%eax
  801f3b:	89 f7                	mov    %esi,%edi
  801f3d:	f7 f1                	div    %ecx
  801f3f:	89 fa                	mov    %edi,%edx
  801f41:	83 c4 1c             	add    $0x1c,%esp
  801f44:	5b                   	pop    %ebx
  801f45:	5e                   	pop    %esi
  801f46:	5f                   	pop    %edi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 f9                	mov    %edi,%ecx
  801f52:	ba 20 00 00 00       	mov    $0x20,%edx
  801f57:	29 fa                	sub    %edi,%edx
  801f59:	d3 e0                	shl    %cl,%eax
  801f5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5f:	89 d1                	mov    %edx,%ecx
  801f61:	89 d8                	mov    %ebx,%eax
  801f63:	d3 e8                	shr    %cl,%eax
  801f65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f69:	09 c1                	or     %eax,%ecx
  801f6b:	89 f0                	mov    %esi,%eax
  801f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f71:	89 f9                	mov    %edi,%ecx
  801f73:	d3 e3                	shl    %cl,%ebx
  801f75:	89 d1                	mov    %edx,%ecx
  801f77:	d3 e8                	shr    %cl,%eax
  801f79:	89 f9                	mov    %edi,%ecx
  801f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f7f:	89 eb                	mov    %ebp,%ebx
  801f81:	d3 e6                	shl    %cl,%esi
  801f83:	89 d1                	mov    %edx,%ecx
  801f85:	d3 eb                	shr    %cl,%ebx
  801f87:	09 f3                	or     %esi,%ebx
  801f89:	89 c6                	mov    %eax,%esi
  801f8b:	89 f2                	mov    %esi,%edx
  801f8d:	89 d8                	mov    %ebx,%eax
  801f8f:	f7 74 24 08          	divl   0x8(%esp)
  801f93:	89 d6                	mov    %edx,%esi
  801f95:	89 c3                	mov    %eax,%ebx
  801f97:	f7 64 24 0c          	mull   0xc(%esp)
  801f9b:	39 d6                	cmp    %edx,%esi
  801f9d:	72 19                	jb     801fb8 <__udivdi3+0x108>
  801f9f:	89 f9                	mov    %edi,%ecx
  801fa1:	d3 e5                	shl    %cl,%ebp
  801fa3:	39 c5                	cmp    %eax,%ebp
  801fa5:	73 04                	jae    801fab <__udivdi3+0xfb>
  801fa7:	39 d6                	cmp    %edx,%esi
  801fa9:	74 0d                	je     801fb8 <__udivdi3+0x108>
  801fab:	89 d8                	mov    %ebx,%eax
  801fad:	31 ff                	xor    %edi,%edi
  801faf:	e9 3c ff ff ff       	jmp    801ef0 <__udivdi3+0x40>
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801fbb:	31 ff                	xor    %edi,%edi
  801fbd:	e9 2e ff ff ff       	jmp    801ef0 <__udivdi3+0x40>
  801fc2:	66 90                	xchg   %ax,%ax
  801fc4:	66 90                	xchg   %ax,%ax
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__umoddi3>:
  801fd0:	f3 0f 1e fb          	endbr32 
  801fd4:	55                   	push   %ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	83 ec 1c             	sub    $0x1c,%esp
  801fdb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801fdf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801fe3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801fe7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801feb:	89 f0                	mov    %esi,%eax
  801fed:	89 da                	mov    %ebx,%edx
  801fef:	85 ff                	test   %edi,%edi
  801ff1:	75 15                	jne    802008 <__umoddi3+0x38>
  801ff3:	39 dd                	cmp    %ebx,%ebp
  801ff5:	76 39                	jbe    802030 <__umoddi3+0x60>
  801ff7:	f7 f5                	div    %ebp
  801ff9:	89 d0                	mov    %edx,%eax
  801ffb:	31 d2                	xor    %edx,%edx
  801ffd:	83 c4 1c             	add    $0x1c,%esp
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    
  802005:	8d 76 00             	lea    0x0(%esi),%esi
  802008:	39 df                	cmp    %ebx,%edi
  80200a:	77 f1                	ja     801ffd <__umoddi3+0x2d>
  80200c:	0f bd cf             	bsr    %edi,%ecx
  80200f:	83 f1 1f             	xor    $0x1f,%ecx
  802012:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802016:	75 40                	jne    802058 <__umoddi3+0x88>
  802018:	39 df                	cmp    %ebx,%edi
  80201a:	72 04                	jb     802020 <__umoddi3+0x50>
  80201c:	39 f5                	cmp    %esi,%ebp
  80201e:	77 dd                	ja     801ffd <__umoddi3+0x2d>
  802020:	89 da                	mov    %ebx,%edx
  802022:	89 f0                	mov    %esi,%eax
  802024:	29 e8                	sub    %ebp,%eax
  802026:	19 fa                	sbb    %edi,%edx
  802028:	eb d3                	jmp    801ffd <__umoddi3+0x2d>
  80202a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802030:	89 e9                	mov    %ebp,%ecx
  802032:	85 ed                	test   %ebp,%ebp
  802034:	75 0b                	jne    802041 <__umoddi3+0x71>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f5                	div    %ebp
  80203f:	89 c1                	mov    %eax,%ecx
  802041:	89 d8                	mov    %ebx,%eax
  802043:	31 d2                	xor    %edx,%edx
  802045:	f7 f1                	div    %ecx
  802047:	89 f0                	mov    %esi,%eax
  802049:	f7 f1                	div    %ecx
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	31 d2                	xor    %edx,%edx
  80204f:	eb ac                	jmp    801ffd <__umoddi3+0x2d>
  802051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802058:	8b 44 24 04          	mov    0x4(%esp),%eax
  80205c:	ba 20 00 00 00       	mov    $0x20,%edx
  802061:	29 c2                	sub    %eax,%edx
  802063:	89 c1                	mov    %eax,%ecx
  802065:	89 e8                	mov    %ebp,%eax
  802067:	d3 e7                	shl    %cl,%edi
  802069:	89 d1                	mov    %edx,%ecx
  80206b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80206f:	d3 e8                	shr    %cl,%eax
  802071:	89 c1                	mov    %eax,%ecx
  802073:	8b 44 24 04          	mov    0x4(%esp),%eax
  802077:	09 f9                	or     %edi,%ecx
  802079:	89 df                	mov    %ebx,%edi
  80207b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	d3 e5                	shl    %cl,%ebp
  802083:	89 d1                	mov    %edx,%ecx
  802085:	d3 ef                	shr    %cl,%edi
  802087:	89 c1                	mov    %eax,%ecx
  802089:	89 f0                	mov    %esi,%eax
  80208b:	d3 e3                	shl    %cl,%ebx
  80208d:	89 d1                	mov    %edx,%ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	d3 e8                	shr    %cl,%eax
  802093:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802098:	09 d8                	or     %ebx,%eax
  80209a:	f7 74 24 08          	divl   0x8(%esp)
  80209e:	89 d3                	mov    %edx,%ebx
  8020a0:	d3 e6                	shl    %cl,%esi
  8020a2:	f7 e5                	mul    %ebp
  8020a4:	89 c7                	mov    %eax,%edi
  8020a6:	89 d1                	mov    %edx,%ecx
  8020a8:	39 d3                	cmp    %edx,%ebx
  8020aa:	72 06                	jb     8020b2 <__umoddi3+0xe2>
  8020ac:	75 0e                	jne    8020bc <__umoddi3+0xec>
  8020ae:	39 c6                	cmp    %eax,%esi
  8020b0:	73 0a                	jae    8020bc <__umoddi3+0xec>
  8020b2:	29 e8                	sub    %ebp,%eax
  8020b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8020b8:	89 d1                	mov    %edx,%ecx
  8020ba:	89 c7                	mov    %eax,%edi
  8020bc:	89 f5                	mov    %esi,%ebp
  8020be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8020c2:	29 fd                	sub    %edi,%ebp
  8020c4:	19 cb                	sbb    %ecx,%ebx
  8020c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8020cb:	89 d8                	mov    %ebx,%eax
  8020cd:	d3 e0                	shl    %cl,%eax
  8020cf:	89 f1                	mov    %esi,%ecx
  8020d1:	d3 ed                	shr    %cl,%ebp
  8020d3:	d3 eb                	shr    %cl,%ebx
  8020d5:	09 e8                	or     %ebp,%eax
  8020d7:	89 da                	mov    %ebx,%edx
  8020d9:	83 c4 1c             	add    $0x1c,%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5e                   	pop    %esi
  8020de:	5f                   	pop    %edi
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    
